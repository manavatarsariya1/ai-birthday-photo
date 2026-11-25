import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/pref_service.dart';

/// Taichi model — Android-only repeatable daily ad-revenue milestones.
class RevenueThresholdManager {
  static bool _initialized = false;
  static DateTime? _sessionStart;

  // Daily cache
  static const String keyDailyCache = 'taichi_daily_cache';
  static const String keyDailyCacheDate = 'taichi_daily_cache_date';

  // Lifetime totals
  static const String keyLifetimeRevenue = 'taichi_lifetime_revenue';
  static const String keyAdImpressionCount = 'taichi_ad_impression_count';
  static const String keyRewardedCount = 'taichi_rewarded_count';
  static const String keyInterstitialCount = 'taichi_interstitial_count';
  static const String keyAppOpenCount = 'taichi_app_open_count';
  static const String keyBannerCount = 'taichi_banner_count';

  static const String _tag = 'RevenueThresholdManager';

  /// Call after [PrefService.init].
  static Future<void> init() async {
    try {
      _initialized = true;
      _sessionStart ??= DateTime.now();
      await _checkAndResetDailyCache();
      if (kDebugMode) {
        debugPrint('[$_tag] Taichi model initialized.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error initializing: $e');
      }
    }
  }

  /// Process one paid ad impression (Android only).
  static Future<void> processAdRevenue(
    double revenueUsd, {
    String adType = 'unknown',
    String currency = 'USD',
  }) async {
    try {
      if (!Platform.isAndroid) return;

      if (!_initialized) {
        await init();
      }
      _sessionStart ??= DateTime.now();

      final milestones = _getMilestonesFromRemoteConfig();
      if (milestones.isEmpty) {
        if (kDebugMode) {
          debugPrint('[$_tag] No milestones configured. Skipping.');
        }
        return;
      }

      await _checkAndResetDailyCache();

      // Lifetime + counters (never reset by day)
      final lifetime =
          PrefService.getDouble(keyLifetimeRevenue) + revenueUsd;
      await PrefService.setValue(keyLifetimeRevenue, lifetime);

      final impressionCount =
          PrefService.getInt(keyAdImpressionCount) + 1;
      await PrefService.setValue(keyAdImpressionCount, impressionCount);

      await _incrementAdTypeCount(adType);

      // Daily cache
      final prevCache = PrefService.getDouble(keyDailyCache);
      final dailyCache = prevCache + revenueUsd;
      await PrefService.setValue(keyDailyCache, dailyCache);

      final updatedAt = DateTime.now().millisecondsSinceEpoch;
      if (kDebugMode) {
        debugPrint(
          '[$_tag] Accumulated. prev=$prevCache + ad=$revenueUsd → daily=$dailyCache | '
          'lifetime=$lifetime | milestones=$milestones',
        );
      }

      final triggered = _largestReachedMilestone(dailyCache, milestones);
      if (triggered == null) {
        if (kDebugMode) {
          debugPrint(
            '[$_tag] Below milestone. daily=$dailyCache, lowest=${milestones.first}',
          );
        }
        return;
      }

      await _fireMilestoneEvent(
        dailyCache: dailyCache,
        milestone: triggered,
        currency: currency,
        lifetimeRevenue: lifetime,
        revenueUpdatedTime: updatedAt,
      );

      await PrefService.setValue(keyDailyCache, 0.0);
      if (kDebugMode) {
        debugPrint(
          '[$_tag] Milestone $triggered reached. Fired event and reset daily_cache to 0.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error in processAdRevenue: $e');
      }
    }
  }

  // ── Private ───────────────────────────────────────────────────

  static Future<void> _checkAndResetDailyCache() async {
    final now = DateTime.now();
    final today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final stored = PrefService.getString(keyDailyCacheDate);
    if (stored != today) {
      if (kDebugMode) {
        debugPrint(
          "[$_tag] New calendar day ('$stored' → '$today'). Resetting daily_cache.",
        );
      }
      await PrefService.setValue(keyDailyCache, 0.0);
      await PrefService.setValue(keyDailyCacheDate, today);
    }
  }

  static Future<void> _incrementAdTypeCount(String adType) async {
    final t = adType.toLowerCase().trim();
    if (t.contains('reward')) {
      await PrefService.setValue(
        keyRewardedCount,
        PrefService.getInt(keyRewardedCount) + 1,
      );
    } else if (t.contains('inter')) {
      await PrefService.setValue(
        keyInterstitialCount,
        PrefService.getInt(keyInterstitialCount) + 1,
      );
    } else if (t.contains('open')) {
      await PrefService.setValue(
        keyAppOpenCount,
        PrefService.getInt(keyAppOpenCount) + 1,
      );
    } else {
      await PrefService.setValue(
        keyBannerCount,
        PrefService.getInt(keyBannerCount) + 1,
      );
    }
  }

  static _MilestoneEntry? _largestReachedMilestone(
    double dailyCache,
    List<_MilestoneEntry> milestones,
  ) {
    _MilestoneEntry? matched;
    for (final m in milestones) {
      if (dailyCache + 1e-12 >= m.value) {
        matched = m;
      }
    }
    return matched;
  }

  static Future<void> _fireMilestoneEvent({
    required double dailyCache,
    required _MilestoneEntry milestone,
    required String currency,
    required double lifetimeRevenue,
    required int revenueUpdatedTime,
  }) async {
    final eventName = _generateEventName(milestone);
    final value = dailyCache;
    final sessionSeconds = _sessionDurationSeconds();

    final parameters = <String, Object>{
      'value': value,
      'total_session_ad_value': value,
      'currency': currency.isNotEmpty ? currency : 'USD',
      'ad_impression_count': PrefService.getInt(keyAdImpressionCount),
      'rewarded_count': PrefService.getInt(keyRewardedCount),
      'interstitial_count': PrefService.getInt(keyInterstitialCount),
      'app_open_count': PrefService.getInt(keyAppOpenCount),
      'banner_count': PrefService.getInt(keyBannerCount),
      'session_duration': sessionSeconds,
      'triggered_milestone': milestone.value,
      'total_lifetime_revenue': lifetimeRevenue,
      'revenue_updated_time': revenueUpdatedTime,
    };

    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );

    if (kDebugMode) {
      debugPrint("[$_tag] Fired '$eventName' params=$parameters");
    }
  }

  static int _sessionDurationSeconds() {
    final start = _sessionStart ?? DateTime.now();
    return DateTime.now().difference(start).inSeconds;
  }

  static List<_MilestoneEntry> _getMilestonesFromRemoteConfig() {
    try {
      final rc = FirebaseRemoteConfig.instance;
      final raw = rc.getString('repeatable_lifetime_revenue_values').trim();

      if (raw.isNotEmpty) {
        final parsed = _parseMilestones(raw);
        if (parsed.isNotEmpty) return parsed;
      }

      final fromDouble = rc.getDouble('repeatable_lifetime_revenue_values');
      if (fromDouble > 0) {
        return <_MilestoneEntry>[_MilestoneEntry(fromDouble, fromDouble.toString())];
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error reading repeatable_lifetime_revenue_values: $e');
      }
    }

    return <_MilestoneEntry>[const _MilestoneEntry(0.11, '0.11')];
  }

  static List<_MilestoneEntry> _parseMilestones(String raw) {
    final list = <_MilestoneEntry>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final item in decoded) {
          final entry = _toMilestoneEntry(item);
          if (entry != null) list.add(entry);
        }
      } else if (decoded is Map) {
        final values = decoded['values'] ?? decoded['milestones'];
        if (values is List) {
          for (final item in values) {
            final entry = _toMilestoneEntry(item);
            if (entry != null) list.add(entry);
          }
        } else {
          final single = _toMilestoneEntry(decoded['value']);
          if (single != null) list.add(single);
        }
      } else {
        final single = _toMilestoneEntry(decoded);
        if (single != null) list.add(single);
      }
    } catch (_) {
      final single = _toMilestoneEntry(raw);
      if (single != null) list.add(single);
    }

    list.sort((a, b) => a.value.compareTo(b.value));
    final unique = <_MilestoneEntry>[];
    for (final v in list) {
      if (unique.isEmpty || (unique.last.value - v.value).abs() > 1e-12) {
        unique.add(v);
      }
    }
    return unique;
  }

  static _MilestoneEntry? _toMilestoneEntry(dynamic item) {
    if (item is num) {
      final v = item.toDouble();
      return v > 0 ? _MilestoneEntry(v, item.toString()) : null;
    }
    if (item is String) {
      final trimmed = item.trim();
      final v = double.tryParse(trimmed);
      if (v != null && v > 0) return _MilestoneEntry(v, trimmed);
    }
    return null;
  }

  static String _generateEventName(_MilestoneEntry milestone) {
    // Exact string as entered in Remote Config without any mathematical rounding or truncation
    var str = milestone.rawString.trim();
    if (str.contains('e-') || str.contains('E-')) {
      final parts = str.toLowerCase().split('e-');
      final exponent = int.tryParse(parts[1]) ?? 0;
      final decimals = exponent + (parts[0].contains('.') ? parts[0].split('.')[1].length : 0);
      str = milestone.value.toStringAsFixed(decimals);
    }
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    final formatted = str.replaceAll('.', '_');
    return 'Total_Ads_Revenue_$formatted';
  }
}

class _MilestoneEntry {
  final double value;
  final String rawString;
  const _MilestoneEntry(this.value, this.rawString);

  @override
  String toString() => rawString;
}
