import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constant/app_constant.dart';
import '../data/models/app_update_model.dart';
import '../data/models/firebase_ad_config_model.dart';
import '../utils/pref_service.dart';
import 'ad_service/ad_label_key.dart';
import 'ad_service/ad_services.dart';
import 'ad_service/ad_managers/ad_manager_app_open.dart';
import 'ad_service/ad_managers/revenue_threshold_manager.dart';

class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static FirebaseRemoteConfig get remoteConfig => _remoteConfig;

  static const MethodChannel _referrerChannel = MethodChannel(
    'flutter_getx_project_structure/referrer',
  );

  /// Test Mode flag for ads (uses test_ads if enabled)
  static const bool isTestMode = false;

  // ── Remote Config Keys ─────────────────────────────────────────────────────
  // App Update
  static const String keyAndroidUpdateConfig = 'android_update_config';
  static const String keyIosUpdateConfig = 'ios_update_config';

  // Core Ads Engine Keys
  static const String keyShowAds = 'show_ads';
  static const String keyAppLiveStatus = 'app_live_status';
  static const String keyFirstTimeUserOpenCount = 'first_time_user_open_count';
  static const String keyInterstitialGap = 'interstitial_gap';
  static const String keyInterTimerSecond = 'inter_timer_second';
  static const String keyOrganicLiveAds = 'organic_live_ads_v1_0_11';
  static const String keyMarketingLiveAds = 'marketing_live_ads_v1_0_11';
  static const String keyMetaMarketingLiveAds =
      'meta_marketing_live_ads_v1_0_11';
  static const String keyLiveAds = 'live_ads_v1';
  static const String keyFirebaseAdConfig = 'firebase_ad_config';
  static const String keyTestAds = 'test_ads';
  static const String keyRepeatableLifetimeRevenueValues =
      'repeatable_lifetime_revenue_values';

  // ── Default In-App Ads Fallbacks (100% Test Ad Unit IDs) ───────────────────
  static const String defaultFirebaseAdConfigJson =
      fallbackFirebaseAdConfigJson;

  static const String fallbackFirebaseAdConfigJson = '''
{
  "app_live_status": true,
  "show_ads": true,
  "first_time_user_open_count": 2,
  "interstitial_gap": 15,
  "user_click_counter": 3,
  "is_inter_timer": false,
  "inter_timer_second": 30,
  "native_auto_refresh": true,
  "native_refresh_interval_sec": 30,
  "click_after_refresh_enable": true,
  "splash_inter_list": [
    "ca-app-pub-3940256099942544/1033173712"
  ],
  "splash_inter_timeouts_sec": [
    10
  ],
  "splash_open_app_ad_list": [
    "ca-app-pub-3940256099942544/9257395921"
  ],
  "splash_native_ad_list": [
    "ca-app-pub-3940256099942544/2247696110"
  ],
  "open_app_ad_list": [
    "ca-app-pub-3940256099942544/9257395921"
  ],
  "language_native_list": [
    "ca-app-pub-3940256099942544/2247696110"
  ],
  "onboarding_native_list": [
    "ca-app-pub-3940256099942544/2247696110"
  ],
  "inter_ad_list": [
    "ca-app-pub-3940256099942544/1033173712"
  ],
  "native_ad_list": [
    "ca-app-pub-3940256099942544/2247696110"
  ],
  "banner_ad_list": [
    "ca-app-pub-3940256099942544/6300978111"
  ],
  "rewarded_ad_list": [
    "ca-app-pub-3940256099942544/5224354917"
  ],
  "ads_data": {
    "background_open_app": {
      "ads_name": "background_open_app",
      "ads_type": "app_open",
      "enable_ads_first_time": true,
      "enable_ads_returning": true
    },
    "splash_open_app": {
      "adsName": "splash_open_app",
      "adsType": "interstitial",
      "enable_ads_first_time": true,
      "enable_ads_returning": true,
      "fallbacks": [
        {
          "enable": true,
          "enable_first_time": true,
          "enable_returning": true,
          "ads_type": "app_open",
          "priority": 1
        },
        {
          "enable": true,
          "enable_first_time": true,
          "enable_returning": true,
          "ads_type": "native",
          "priority": 2
        }
      ]
    },
    "splash_native": {
      "ads_name": "splash_native",
      "ads_type": "native",
      "enable_ads_first_time": true,
      "enable_ads_returning": true
    },
    "language_screen": {
      "ads_name": "language_screen",
      "ads_type": "native",
      "enable_ads_first_time": true,
      "enable_ads_returning": true
    },
    "onboarding_screen": {
      "ads_name": "onboarding_screen",
      "ads_type": "native",
      "enable_ads_first_time": true,
      "enable_ads_returning": true
    },
    "home_section_native": {
      "ads_name": "home_section_native",
      "ads_type": "native",
      "enable_ads_first_time": true,
      "enable_ads_returning": true
    },
    "home_banner": {
      "ads_name": "home_banner",
      "ads_type": "banner",
      "enable_ads_first_time": true,
      "enable_ads_returning": true
    },
    "exit_app_bottom_sheet": {
      "ads_name": "exit_app_bottom_sheet",
      "ads_type": "native",
      "enable_ads_first_time": true,
      "enable_ads_returning": true
    },
    "common_paywall_close": {
      "ads_name": "common_paywall_close",
      "ads_type": "interstitial",
      "enable_ads_first_time": true,
      "enable_ads_returning": true
    }
  }
}
''';

  static const String fallbackMetaAdConfigJson = '''
{
  "app_live_status": true,
  "show_ads": false,
  "first_time_user_open_count": 2,
  "interstitial_gap": 15,
  "user_click_counter": 3,
  "is_inter_timer": false,
  "inter_timer_second": 30,
  "native_auto_refresh": false,
  "native_refresh_interval_sec": 30,
  "click_after_refresh_enable": false,
  "splash_inter_list": [
    "ca-app-pub-3940256099942544/1033173712"
  ],
  "splash_inter_timeouts_sec": [
    10
  ],
  "splash_open_app_ad_list": [
    "ca-app-pub-3940256099942544/9257395921"
  ],
  "splash_native_ad_list": [
    "ca-app-pub-3940256099942544/2247696110"
  ],
  "open_app_ad_list": [
    "ca-app-pub-3940256099942544/9257395921"
  ],
  "language_native_list": [
    "ca-app-pub-3940256099942544/2247696110"
  ],
  "onboarding_native_list": [
    "ca-app-pub-3940256099942544/2247696110"
  ],
  "inter_ad_list": [
    "ca-app-pub-3940256099942544/1033173712"
  ],
  "native_ad_list": [
    "ca-app-pub-3940256099942544/2247696110"
  ],
  "banner_ad_list": [
    "ca-app-pub-3940256099942544/6300978111"
  ],
  "rewarded_ad_list": [
    "ca-app-pub-3940256099942544/5224354917"
  ],
  "ads_data": {
    "background_open_app": {
      "ads_name": "background_open_app",
      "ads_type": "app_open",
      "enable_ads_first_time": false,
      "enable_ads_returning": false
    },
    "splash_open_app": {
      "adsName": "splash_open_app",
      "adsType": "interstitial",
      "enable_ads_first_time": false,
      "enable_ads_returning": false,
      "fallbacks": []
    },
    "splash_native": {
      "ads_name": "splash_native",
      "ads_type": "native",
      "enable_ads_first_time": false,
      "enable_ads_returning": false
    },
    "language_screen": {
      "ads_name": "language_screen",
      "ads_type": "native",
      "enable_ads_first_time": false,
      "enable_ads_returning": false
    },
    "onboarding_screen": {
      "ads_name": "onboarding_screen",
      "ads_type": "native",
      "enable_ads_first_time": false,
      "enable_ads_returning": false
    },
    "home_section_native": {
      "ads_name": "home_section_native",
      "ads_type": "native",
      "enable_ads_first_time": false,
      "enable_ads_returning": false
    },
    "home_banner": {
      "ads_name": "home_banner",
      "ads_type": "banner",
      "enable_ads_first_time": false,
      "enable_ads_returning": false
    },
    "exit_app_bottom_sheet": {
      "ads_name": "exit_app_bottom_sheet",
      "ads_type": "native",
      "enable_ads_first_time": false,
      "enable_ads_returning": false
    },
    "common_paywall_close": {
      "ads_name": "common_paywall_close",
      "ads_type": "interstitial",
      "enable_ads_first_time": false,
      "enable_ads_returning": false
    }
  }
}
''';

  // In-app default configs
  static final Map<String, dynamic> _defaults = {
    keyAndroidUpdateConfig: jsonEncode({
      'min_version': '1.0.0',
      'latest_version': '1.0.0',
      'is_force_update': false,
      'is_soft_update': false,
      'update_url': AppConstant.playStoreUrl,
      'title': '',
      'message': '',
    }),
    keyIosUpdateConfig: jsonEncode({
      'min_version': '1.0.0',
      'latest_version': '1.0.0',
      'is_force_update': false,
      'is_soft_update': false,
      'update_url': AppConstant.appStoreUrl,
      'title': '',
      'message': '',
    }),
    keyShowAds: false,
    keyAppLiveStatus: false,
    keyFirstTimeUserOpenCount: 1,
    keyInterstitialGap: 15,
    keyInterTimerSecond: 15,
    'user_scenario': 'auto',
    keyOrganicLiveAds: defaultFirebaseAdConfigJson,
    keyMarketingLiveAds: defaultFirebaseAdConfigJson,
    keyMetaMarketingLiveAds: fallbackMetaAdConfigJson,
    keyLiveAds: defaultFirebaseAdConfigJson,
    keyTestAds: defaultFirebaseAdConfigJson,
    keyFirebaseAdConfig: defaultFirebaseAdConfigJson,
    keyRepeatableLifetimeRevenueValues: '0.11',
  };

  // ── Initialization ─────────────────────────────────────────────────────────
  static Future<void>? _referrerFuture;
  static Future<void>? _setupFuture;

  static Future<void> init() async {
    try {
      _referrerFuture ??= _resolveInstallReferrer();
      _setupFuture ??= _applySettingsAndDefaults();
      await _setupFuture;

      AdManagerAppOpen.instance.init();
      ADService.bindPremiumListener();
      await RevenueThresholdManager.init();

      if (kDebugMode) {
        debugPrint('✅ [RemoteConfigService] Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [RemoteConfigService] Init error: $e');
      }
    }
  }

  static Future<void> _applySettingsAndDefaults() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await _remoteConfig.setDefaults(_defaults);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [RemoteConfigService] setDefaults error: $e');
      }
    }
  }

  /// Resolves Organic vs Marketing (Meta / Other) attribution (Android only).
  static Future<void> _resolveInstallReferrer() async {
    if (!GetPlatform.isAndroid) return;
    try {
      final String? attributionType = await _referrerChannel
          .invokeMethod<String>('checkAttributionType')
          .timeout(const Duration(seconds: 3));
      if (attributionType != null && attributionType.isNotEmpty) {
        await PrefService.setValue(
          PrefService.userAttributionType,
          attributionType,
        );
        await PrefService.setValue(
          PrefService.isMarketingUser,
          attributionType != 'organic',
        );
        _invalidateAdConfigCache();
      }
      if (kDebugMode) {
        debugPrint(
          '📱 [InstallReferrer] Android attribution: $attributionType',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [InstallReferrer] Referrer check failed/timed out: $e');
      }
    }
  }

  static Future<bool>? _fetchInFlight;

  Future<bool> fetchAndActivate() => fetchLatestConfig();
  static Future<bool> fetchAdConfig() => fetchLatestConfig();

  /// Fetches & activates latest Remote Config values from Firebase
  static Future<bool> fetchLatestConfig() async {
    if (_fetchInFlight != null) {
      return await _fetchInFlight!;
    }
    _fetchInFlight = _fetchLatestConfigInternal();
    try {
      return await _fetchInFlight!;
    } finally {
      _fetchInFlight = null;
    }
  }

  static Future<bool> _fetchLatestConfigInternal() async {
    try {
      if (_setupFuture != null) await _setupFuture;
      if (_referrerFuture != null) await _referrerFuture;

      final updated = await _remoteConfig.fetchAndActivate();
      if (updated) {
        _invalidateAdConfigCache();
      }
      if (kDebugMode) {
        debugPrint(
          '🔥 [RemoteConfigService] Fetched & activated (updated: $updated)',
        );
      }
      return updated;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [RemoteConfigService] Fetch error: $e');
      }
      return false;
    }
  }

  // ── Attribution & Marketing Check ──────────────────────────────────────────
  /// Returns "meta", "marketing", or "organic"
  static String getAttributionType() {
    if (!GetPlatform.isAndroid) return 'organic';
    try {
      if (PrefService.containsKey(PrefService.userAttributionType)) {
        final saved = PrefService.getString(PrefService.userAttributionType);
        if (saved.isNotEmpty) return saved;
      }
      if (PrefService.containsKey(PrefService.isMarketingUser)) {
        return PrefService.getBool(PrefService.isMarketingUser)
            ? 'marketing'
            : 'organic';
      }
      return _remoteConfig.getBool('is_marketing_user')
          ? 'marketing'
          : 'organic';
    } catch (_) {}
    return 'organic';
  }

  static bool checkIsMarketingUser() {
    return getAttributionType() != 'organic';
  }

  static bool get isMarketingUser => checkIsMarketingUser();

  // ── Ads Config Getters ─────────────────────────────────────────────────────
  static String? _cachedAdConfigRaw;
  static FirebaseAdConfigModel? _cachedAdConfig;
  static String? _lastLoggedAdConfigKey;

  static void _invalidateAdConfigCache() {
    _cachedAdConfigRaw = null;
    _cachedAdConfig = null;
    _lastLoggedAdConfigKey = null;
  }

  static FirebaseAdConfigModel getFirebaseAdConfig() {
    String jsonStr;
    try {
      jsonStr = _resolveRemoteConfigJson();
    } catch (_) {
      jsonStr = defaultFirebaseAdConfigJson;
    }
    if (jsonStr.isEmpty) jsonStr = defaultFirebaseAdConfigJson;

    final cached = _cachedAdConfig;
    if (cached != null && jsonStr == _cachedAdConfigRaw) return cached;

    FirebaseAdConfigModel parsed;
    try {
      parsed = firebaseAdConfigModelFromJson(jsonStr);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing ad config from Remote Config: $e');
      }
      parsed = firebaseAdConfigModelFromJson(defaultFirebaseAdConfigJson);
    }
    _cachedAdConfigRaw = jsonStr;
    _cachedAdConfig = parsed;
    return parsed;
  }

  static String _resolveRemoteConfigJson() {
    final attribution = getAttributionType();

    final List<String> candidateKeys;
    if (isTestMode) {
      candidateKeys = [keyTestAds, keyFirebaseAdConfig];
    } else if (GetPlatform.isIOS) {
      candidateKeys = [
        keyLiveAds,
        'live_ads',
        keyFirebaseAdConfig,
      ];
    } else {
      candidateKeys = [
        if (attribution == 'meta') ...[
          keyMetaMarketingLiveAds,
          keyMarketingLiveAds,
        ] else if (attribution == 'marketing') ...[
          keyMarketingLiveAds,
        ] else ...[
          keyOrganicLiveAds,
        ],
        keyLiveAds,
        'live_ads',
        keyFirebaseAdConfig,
      ];
    }

    for (final key in candidateKeys) {
      try {
        final val = _remoteConfig.getValue(key);
        if (val.source == ValueSource.valueRemote &&
            val.asString().trim().isNotEmpty) {
          final str = val.asString().trim();
          if (kDebugMode && _lastLoggedAdConfigKey != key) {
            _lastLoggedAdConfigKey = key;
            debugPrint(
              '🔥 [RemoteConfig] Using REMOTE value from key: "$key" (isTestMode: $isTestMode, attribution: $attribution)',
            );
          }
          return str;
        }
      } catch (_) {}
    }

    final fetchStatus = _remoteConfig.lastFetchStatus;

    if (fetchStatus == RemoteConfigFetchStatus.success) {
      if (kDebugMode && _lastLoggedAdConfigKey != '__missing__') {
        _lastLoggedAdConfigKey = '__missing__';
        debugPrint(
          '🛡️ [RemoteConfig] Fetch succeeded, but key not found on server. Using in-app live default ads.',
        );
      }
      return attribution == 'meta'
          ? fallbackMetaAdConfigJson
          : defaultFirebaseAdConfigJson;
    }

    for (final key in candidateKeys) {
      try {
        final str = _remoteConfig.getString(key).trim();
        if (str.isNotEmpty &&
            str != defaultFirebaseAdConfigJson &&
            str != fallbackMetaAdConfigJson) {
          return str;
        }
      } catch (_) {}
    }

    return attribution == 'meta'
        ? fallbackMetaAdConfigJson
        : fallbackFirebaseAdConfigJson;
  }

  /// Number of app opens that count as "first-time" user sessions.
  static int get firstTimeUserOpenCount {
    try {
      final config = getFirebaseAdConfig();
      if (config.firstTimeUserOpenCount != null &&
          config.firstTimeUserOpenCount! > 0) {
        return config.firstTimeUserOpenCount!;
      }

      if (_remoteConfig.getAll().containsKey(keyFirstTimeUserOpenCount)) {
        final val = _remoteConfig.getInt(keyFirstTimeUserOpenCount);
        if (val > 0) return val;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [RemoteConfigService] Error reading firstTimeUserOpenCount: $e',
        );
      }
    }
    return 1;
  }

  static bool _isPlacementEnabled(AdsDatum? datum) {
    if (datum == null) return false;
    return datum.resolveEnableAds(
      isFirstTime: PrefService.isFirstTimeAdUser,
    );
  }

  static bool isAdEnabled(String adLabel) {
    if (GetPlatform.isIOS) return false;
    try {
      try {
        final showAdsVal = _remoteConfig.getValue(keyShowAds);
        if (showAdsVal.source == ValueSource.valueRemote &&
            !showAdsVal.asBool()) {
          return false;
        }
        final appLiveVal = _remoteConfig.getValue(keyAppLiveStatus);
        if (appLiveVal.source == ValueSource.valueRemote &&
            !appLiveVal.asBool()) {
          return false;
        }
      } catch (_) {}

      final config = getFirebaseAdConfig();
      if (config.appLiveStatus != true) return false;
      if (config.showAds != true) return false;

      if (adLabel == ADLabelKey.splashOpenApp ||
          adLabel == 'splash_flow') {
        if (config.adsData?.containsKey('splash_flow') == true) {
          return _isPlacementEnabled(config.adsData?['splash_flow']);
        }
        if (config.adsData?.containsKey('splash_open_app') == true) {
          return _isPlacementEnabled(config.adsData?['splash_open_app']);
        }
        return _isPlacementEnabled(config.adsData?['splash_flow']) ||
            _isPlacementEnabled(config.adsData?['splash_open_app']);
      }

      if (adLabel == ADLabelKey.backgroundOpenApp ||
          adLabel == 'app_resume') {
        return _isPlacementEnabled(config.adsData?['background_open_app']) ||
            _isPlacementEnabled(config.adsData?['app_resume']);
      }

      if (config.adsData?.containsKey(adLabel) == true) {
        return _isPlacementEnabled(config.adsData?[adLabel]);
      }

      if (config.adsData != null) {
        for (final entry in config.adsData!.entries) {
          if (adLabel.startsWith(entry.key)) {
            return _isPlacementEnabled(entry.value);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking isAdEnabled for $adLabel: $e');
      }
    }
    return false;
  }

  static bool get isInterTimerEnabled {
    try {
      return getFirebaseAdConfig().isInterTimer ?? false;
    } catch (_) {
      return false;
    }
  }

  static int get interstitialGapSeconds {
    try {
      final timerMode = isInterTimerEnabled;
      final keys = timerMode
          ? [keyInterTimerSecond, keyInterstitialGap]
          : [keyInterstitialGap, keyInterTimerSecond];

      for (final key in keys) {
        final val = _remoteConfig.getValue(key);
        if (val.source == ValueSource.valueRemote && val.asInt() > 0) {
          return val.asInt();
        }
      }
      final config = getFirebaseAdConfig();
      final ordered = timerMode
          ? [config.interTimerSecond, config.interstitialGap]
          : [config.interstitialGap, config.interTimerSecond];
      for (final s in ordered) {
        if (s != null && s > 0) return s;
      }
      return timerMode ? 30 : 15;
    } catch (_) {
      return 15;
    }
  }

  static int get interTimerSeconds => interstitialGapSeconds;

  static bool get isBannerTimerEnabled => false;
  static int get bannerTimerSeconds => 0;

  static bool get isNativeTimerEnabled => false;
  static int get nativeTimerSeconds => 0;

  static int get userClickCounter {
    try {
      return getFirebaseAdConfig().userClickCounter ?? 3;
    } catch (_) {
      return 3;
    }
  }

  static int get bottomBarClickCounter {
    try {
      return getFirebaseAdConfig().bottomBarClickCounter ?? 3;
    } catch (_) {
      return 3;
    }
  }

  // ── App Update Check ───────────────────────────────────────────────────────
  static Future<AppUpdateInfo> checkAppUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version.trim();

      final isIos = !kIsWeb && Platform.isIOS;
      final configKey = isIos ? keyIosUpdateConfig : keyAndroidUpdateConfig;

      final jsonString = _remoteConfig.getString(configKey).trim();
      AppUpdateConfig config = const AppUpdateConfig();

      if (jsonString.isNotEmpty) {
        try {
          final decoded = jsonDecode(jsonString);
          if (decoded is Map<String, dynamic>) {
            config = AppUpdateConfig.fromJson(decoded);
          }
        } catch (parseErr) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [RemoteConfigService] JSON parse error for $configKey: $parseErr',
            );
          }
        }
      }

      final minVersion = config.minVersion.trim();
      final latestVersion = config.latestVersion.trim();
      final forceUpdateFlag = config.isForceUpdate;
      final softUpdateFlag = config.isSoftUpdate;

      final updateUrl = config.updateUrl.trim();
      final resolvedUrl = updateUrl.isNotEmpty
          ? updateUrl
          : (isIos ? AppConstant.appStoreUrl : AppConstant.playStoreUrl);

      final customTitle = config.title.trim();
      final customMessage = config.message.trim();

      final cmpMin = compareVersions(currentVersion, minVersion);
      if (forceUpdateFlag || (minVersion.isNotEmpty && cmpMin < 0)) {
        return AppUpdateInfo(
          updateType: UpdateType.force,
          currentVersion: currentVersion,
          minVersion: minVersion,
          latestVersion: latestVersion,
          updateUrl: resolvedUrl,
          customTitle: customTitle.isNotEmpty ? customTitle : null,
          customMessage: customMessage.isNotEmpty ? customMessage : null,
        );
      }

      final cmpLatest = compareVersions(currentVersion, latestVersion);
      if (softUpdateFlag || (latestVersion.isNotEmpty && cmpLatest < 0)) {
        return AppUpdateInfo(
          updateType: UpdateType.soft,
          currentVersion: currentVersion,
          minVersion: minVersion,
          latestVersion: latestVersion,
          updateUrl: resolvedUrl,
          customTitle: customTitle.isNotEmpty ? customTitle : null,
          customMessage: customMessage.isNotEmpty ? customMessage : null,
        );
      }

      return AppUpdateInfo.noUpdate(
        currentVersion: currentVersion,
        minVersion: minVersion,
        latestVersion: latestVersion,
        updateUrl: resolvedUrl,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [RemoteConfigService] checkAppUpdate error: $e');
      }
      return AppUpdateInfo.noUpdate();
    }
  }

  // ── Semantic Version Comparator ────────────────────────────────────────────
  static int compareVersions(String v1, String v2) {
    if (v1.isEmpty || v2.isEmpty) return 0;
    try {
      final cleanV1 = v1.split('+').first.split('-').first.trim();
      final cleanV2 = v2.split('+').first.split('-').first.trim();

      final parts1 =
          cleanV1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final parts2 =
          cleanV2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLength =
          parts1.length > parts2.length ? parts1.length : parts2.length;
      while (parts1.length < maxLength) {
        parts1.add(0);
      }
      while (parts2.length < maxLength) {
        parts2.add(0);
      }

      for (var i = 0; i < maxLength; i++) {
        if (parts1[i] > parts2[i]) return 1;
        if (parts1[i] < parts2[i]) return -1;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [RemoteConfigService] compareVersions error ($v1, $v2): $e',
        );
      }
      return 0;
    }
  }

  // ── Generic Getters ────────────────────────────────────────────────────────
  static String getString(String key, {String defaultValue = ''}) {
    try {
      final val = _remoteConfig.getString(key);
      return val.isNotEmpty ? val : defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig.getBool(key);
    } catch (_) {
      return defaultValue;
    }
  }

  static int getInt(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig.getInt(key);
    } catch (_) {
      return defaultValue;
    }
  }

  static double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (_) {
      return defaultValue;
    }
  }
}
