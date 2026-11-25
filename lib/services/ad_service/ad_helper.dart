import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/firebase_ad_config_model.dart';
import '../../utils/pref_service.dart';
import '../remote_config_service.dart';
import 'ad_label_key.dart';
import 'ad_services.dart';

class ADHelper {
  static const String splashOpenApp = ADLabelKey.splashOpenApp;

  // Official Google Test AdMob unit IDs (Android & iOS safe)
  static const String _fallbackInterstitialId =
      "ca-app-pub-3940256099942544/1033173712";
  static const String _fallbackSplashInterstitialId =
      "ca-app-pub-3940256099942544/1033173712";
  static const String _fallbackBannerId =
      "ca-app-pub-3940256099942544/6300978111";
  static const String _fallbackNativeId =
      "ca-app-pub-3940256099942544/2247696110";
  static const String _fallbackLanguageNativeId =
      "ca-app-pub-3940256099942544/2247696110";
  static const String _fallbackOnboardNativeId =
      "ca-app-pub-3940256099942544/2247696110";
  static const String _fallbackOpenAppId =
      "ca-app-pub-3940256099942544/9257395921";
  static const String _fallbackRewardedId =
      "ca-app-pub-3940256099942544/5224354917";

  static List<String> _cleanAdIds(List<String>? list) {
    if (list == null || list.isEmpty) return const [];
    return list
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static String _cleanAdId(String? id) {
    if (id == null) return "";
    return id.trim();
  }

  static String interAdID() {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      final list = _cleanAdIds(config.interAdList);
      if (list.isNotEmpty) {
        return list.first;
      }
      return _fallbackInterstitialId;
    } catch (_) {
      return _fallbackInterstitialId;
    }
  }

  static String bannerAdID(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      final datum = config.adsData?[adLabel];
      final datumList = _cleanAdIds(datum?.adUnitList);
      if (datumList.isNotEmpty) {
        return datumList.first;
      }
      final datumId = _cleanAdId(datum?.adUnitId);
      if (datumId.isNotEmpty) {
        return datumId;
      }
      final list = _cleanAdIds(config.bannerAdList);
      if (list.isNotEmpty) {
        return list.first;
      }
      return _fallbackBannerId;
    } catch (_) {
      return _fallbackBannerId;
    }
  }

  static String getBannerType(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      if (config.adsData?.containsKey(adLabel) == true) {
        final datum = config.adsData![adLabel];
        if (datum?.layout != null && datum!.layout!.isNotEmpty) {
          return datum.layout!.toLowerCase().trim();
        }
        if (datum?.bannerType != null && datum!.bannerType!.isNotEmpty) {
          return datum.bannerType!.toLowerCase().trim();
        }
      }
      return 'adaptive';
    } catch (_) {
      return 'adaptive';
    }
  }

  static String rewardedAdID() {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      final list = _cleanAdIds(config.createQrRewardList);
      if (list.isNotEmpty) {
        return list.first;
      }
      return _fallbackRewardedId;
    } catch (_) {
      return _fallbackRewardedId;
    }
  }

  static List<String> rewardedAdList() {
    try {
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().createQrRewardList,
      );
      if (list.isNotEmpty) return list;
      return const [_fallbackRewardedId];
    } catch (_) {
      return const [_fallbackRewardedId];
    }
  }

  /// Banner waterfall order: placement's own ad_unit_list / ad_unit_id first,
  /// then the global banner_ad_list.
  static List<String> bannerAdIds(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      final datum = config.adsData?[adLabel];
      final ids = <String>[
        ..._cleanAdIds(datum?.adUnitList),
        _cleanAdId(datum?.adUnitId),
        ..._cleanAdIds(config.bannerAdList),
      ].where((e) => e.isNotEmpty).toSet().toList();
      if (ids.isNotEmpty) return ids;
      return const [_fallbackBannerId];
    } catch (_) {
      return const [_fallbackBannerId];
    }
  }

  static String nativeAdID(String adLabel) {
    try {
      final list = nativeAdIdsForLabel(adLabel);
      if (list.isNotEmpty) {
        return list.first;
      }
      return _fallbackNativeId;
    } catch (_) {
      return _fallbackNativeId;
    }
  }

  static String openAdID(String adLabel) {
    try {
      if (adLabel == splashOpenApp) {
        final list = splashOpenAppAdList();
        if (list.isNotEmpty) return list.first;
      }
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().openAppAdList,
      );
      if (list.isNotEmpty) {
        return list.first;
      }
      return _fallbackOpenAppId;
    } catch (_) {
      return _fallbackOpenAppId;
    }
  }

  // ── Splash Flow Remote Config Controls ─────────────────────────

  static AdsDatum? get _splashFlowDatum {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      return config.adsData?['splash_open_app'] ??
          config.adsData?['splash_flow'];
    } catch (_) {
      return null;
    }
  }

  /// Returns the primary ad format: 'interstitial', 'app_open', or 'full_native' (default 'interstitial')
  static String getSplashPrimaryType() {
    try {
      final datum = _splashFlowDatum;
      final type = datum?.adsType?.toLowerCase().trim();
      if (type != null && type.isNotEmpty) return type;
      final primary = datum?.primaryAd?.toLowerCase().trim();
      if (primary != null && primary.isNotEmpty) return primary;
    } catch (_) {}
    return 'interstitial';
  }

  /// Returns the ordered fallback sequence list: e.g. ['app_open', 'full_native']
  static List<String> getSplashFallbackSequence() {
    try {
      final fallbacks = getFallbackAds(splashOpenApp);
      if (fallbacks.isNotEmpty) {
        return fallbacks
            .map((e) => e.adsType?.toLowerCase().trim() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }

      final datum = _splashFlowDatum;
      if (datum?.fallbackSequence != null) {
        return datum!.fallbackSequence!
            .map((e) => e.toLowerCase().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      // Legacy boolean fallback support if fallback_sequence is not provided
      final list = <String>[];
      if (isSplashInterToAppOpenFallbackEnabled() && isSplashAppOpenEnabled()) {
        list.add('app_open');
      }
      if (isSplashAppOpenToNativeFallbackEnabled() && isSplashNativeEnabled()) {
        list.add('full_native');
      }
      return list;
    } catch (_) {
      return ['app_open', 'full_native'];
    }
  }

  /// Returns the configured fallback ad items for an ad placement,
  /// filtered by enabled items (enable != false) and sorted by priority (ascending).
  static List<FallbackAdItem> getFallbackAds(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      AdsDatum? datum = config.adsData?[adLabel];
      if (datum == null &&
          (adLabel == ADLabelKey.splashOpenApp ||
              adLabel == ADLabelKey.splashFlow ||
              adLabel.contains('splash'))) {
        datum = _splashFlowDatum;
      }
      if (datum != null) {
        // 1. Explicit fallbacks list with enable, ads_type, ad_unit_id, priority
        if (datum.fallbacks != null && datum.fallbacks!.isNotEmpty) {
          final isFirstTime = PrefService.isFirstTimeAdUser;
          final list = datum.fallbacks!
              .where((item) =>
                  item.resolveEnable(isFirstTime: isFirstTime) &&
                  (item.adsType != null && item.adsType!.trim().isNotEmpty))
              .toList();
          list.sort((a, b) => (a.priority ?? 1).compareTo(b.priority ?? 1));
          return list;
        }

        // 2. Fallback sequence list of strings: ["app_open", "full_native"]
        if (datum.fallbackSequence != null && datum.fallbackSequence!.isNotEmpty) {
          final list = <FallbackAdItem>[];
          for (var i = 0; i < datum.fallbackSequence!.length; i++) {
            final type = datum.fallbackSequence![i].toLowerCase().trim();
            if (type.isEmpty) continue;
            bool isEnabled = true;
            if (type.contains('inter')) isEnabled = isSplashInterEnabled();
            if (type.contains('open')) isEnabled = isSplashAppOpenEnabled();
            if (type.contains('native')) isEnabled = isSplashNativeEnabled();
            if (isEnabled) {
              list.add(FallbackAdItem(
                enable: true,
                adsType: type,
                priority: i + 1,
              ));
            }
          }
          return list;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting fallback ads for $adLabel: $e');
      }
    }
    return [];
  }

  static String getSplashPrimaryAd() => getSplashPrimaryType();

  static bool isSplashInterEnabled() {
    try {
      final datum = _splashFlowDatum;
      if (datum != null) {
        if (datum.enableInterstitial != null) return datum.enableInterstitial!;
        final isFirstTime = PrefService.isFirstTimeAdUser;
        if (datum.adsType?.toLowerCase().contains('inter') == true) {
          return isFirstTime
              ? (datum.enableAdsFirstTime ?? datum.enableAds ?? true)
              : (datum.enableAdsReturning ?? datum.enableAds ?? true);
        }
        final fb = datum.fallbacks?.firstWhereOrNull(
          (f) => f.adsType?.toLowerCase().contains('inter') == true,
        );
        if (fb != null) {
          return fb.resolveEnable(isFirstTime: isFirstTime);
        }
        return datum.resolveEnableAds(
          isFirstTime: isFirstTime,
        );
      }
    } catch (_) {}
    return true;
  }

  static bool isSplashAppOpenEnabled() {
    try {
      final datum = _splashFlowDatum;
      if (datum != null) {
        if (datum.enableAppOpen != null) return datum.enableAppOpen!;
        final isFirstTime = PrefService.isFirstTimeAdUser;
        if (datum.adsType?.toLowerCase().contains('open') == true) {
          return isFirstTime
              ? (datum.enableAdsFirstTime ?? datum.enableAds ?? true)
              : (datum.enableAdsReturning ?? datum.enableAds ?? true);
        }
        final fb = datum.fallbacks?.firstWhereOrNull(
          (f) => f.adsType?.toLowerCase().contains('open') == true,
        );
        if (fb != null) {
          return fb.resolveEnable(isFirstTime: isFirstTime);
        }
        return datum.resolveEnableAds(
          isFirstTime: isFirstTime,
        );
      }
    } catch (_) {}
    return true;
  }

  static bool isSplashNativeEnabled() {
    try {
      final datum = _splashFlowDatum;
      if (datum != null) {
        if (datum.enableNative != null) return datum.enableNative!;
        final isFirstTime = PrefService.isFirstTimeAdUser;
        if (datum.adsType?.toLowerCase().contains('native') == true) {
          return isFirstTime
              ? (datum.enableAdsFirstTime ?? datum.enableAds ?? true)
              : (datum.enableAdsReturning ?? datum.enableAds ?? true);
        }
        final fb = datum.fallbacks?.firstWhereOrNull(
          (f) => f.adsType?.toLowerCase().contains('native') == true,
        );
        if (fb != null) {
          return fb.resolveEnable(isFirstTime: isFirstTime);
        }
        return datum.resolveEnableAds(
          isFirstTime: isFirstTime,
        );
      }
    } catch (_) {}
    return true;
  }

  static bool isSplashFallbackEnabled() {
    try {
      final datum = _splashFlowDatum;
      if (datum?.fallbackEnabled != null) {
        return datum!.fallbackEnabled!;
      }
    } catch (_) {}
    return true;
  }

  static bool isSplashInterToAppOpenFallbackEnabled() {
    try {
      if (!isSplashFallbackEnabled()) return false;
      final datum = _splashFlowDatum;
      if (datum?.fallbackAppOpenEnabled != null) {
        return datum!.fallbackAppOpenEnabled!;
      }
    } catch (_) {}
    return true;
  }

  static bool isSplashAppOpenToNativeFallbackEnabled() {
    try {
      if (!isSplashFallbackEnabled()) return false;
      final datum = _splashFlowDatum;
      if (datum?.fallbackNativeEnabled != null) {
        return datum!.fallbackNativeEnabled!;
      }
    } catch (_) {}
    return true;
  }

  static List<String> splashInterstitialList() {
    try {
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().splashInterstitialList,
      );
      if (list.isNotEmpty) return list;
      return const [_fallbackSplashInterstitialId, _fallbackInterstitialId];
    } catch (_) {
      return const [_fallbackSplashInterstitialId, _fallbackInterstitialId];
    }
  }

  static List<String> splashOpenAppAdList() {
    try {
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().splashOpenAppAdList,
      );
      if (list.isNotEmpty) return list;
      return const [_fallbackOpenAppId];
    } catch (_) {
      return const [_fallbackOpenAppId];
    }
  }

  static List<String> splashNativeAdList() {
    try {
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().splashNativeAdList,
      );
      if (list.isNotEmpty) return list;
      return const [_fallbackNativeId];
    } catch (_) {
      return const [_fallbackNativeId];
    }
  }

  static List<int> splashInterTimeoutsSec(int count) {
    try {
      return _padTimeouts(
        RemoteConfigService.getFirebaseAdConfig().splashInterTimeoutsSec,
        count,
        firstDefault: 10,
        restDefault: 15,
      );
    } catch (_) {
      return _padTimeouts(null, count, firstDefault: 10, restDefault: 15);
    }
  }

  static List<int> _padTimeouts(
    List<int>? raw,
    int count, {
    required int firstDefault,
    required int restDefault,
  }) {
    final out = <int>[];
    for (var i = 0; i < count; i++) {
      if (raw != null && i < raw.length && raw[i] > 0) {
        out.add(raw[i]);
      } else {
        out.add(i == 0 ? firstDefault : restDefault);
      }
    }
    return out;
  }

  static List<String> onboardNativeList() {
    try {
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().onboardNativeList,
      );
      if (list.isNotEmpty) return list;
      return const [_fallbackOnboardNativeId, _fallbackNativeId];
    } catch (_) {
      return const [_fallbackOnboardNativeId, _fallbackNativeId];
    }
  }

  static List<String> languageNativeList() {
    try {
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().languageNativeList,
      );
      if (list.isNotEmpty) return list;
      return const [_fallbackLanguageNativeId, _fallbackNativeId];
    } catch (_) {
      return const [_fallbackLanguageNativeId, _fallbackNativeId];
    }
  }

  static List<String> interAdList() {
    try {
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().interAdList,
      );
      if (list.isNotEmpty) return list;
      return const [_fallbackInterstitialId];
    } catch (_) {
      return const [_fallbackInterstitialId];
    }
  }

  static List<String> nativeAdList() {
    try {
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().nativeAdList,
      );
      if (list.isNotEmpty) return list;
      return const [_fallbackNativeId];
    } catch (_) {
      return const [_fallbackNativeId];
    }
  }

  static String nativeAdListName(String adLabel) {
    if (adLabel.contains('language')) {
      return "language_native_list";
    }
    if (adLabel.contains('onboard')) {
      return "onboarding_native_list";
    }
    return "native_ad_list";
  }

  static List<String> nativeAdIdsForLabel(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      final datum = config.adsData?[adLabel];
      final datumList = _cleanAdIds(datum?.adUnitList);
      if (datumList.isNotEmpty) {
        return datumList;
      }
      final datumId = _cleanAdId(datum?.adUnitId);
      if (datumId.isNotEmpty) {
        return [datumId];
      }
      if (adLabel.contains('language')) {
        return languageNativeList();
      }
      if (adLabel.contains('onboard')) {
        return onboardNativeList();
      }
      return nativeAdList();
    } catch (_) {
      return nativeAdList();
    }
  }

  static List<String> openAppAdList({String? adLabel}) {
    try {
      if (adLabel == splashOpenApp) {
        return splashOpenAppAdList();
      }
      final list = _cleanAdIds(
        RemoteConfigService.getFirebaseAdConfig().openAppAdList,
      );
      if (list.isNotEmpty) {
        return list;
      }
      return const [_fallbackOpenAppId];
    } catch (_) {
      return const [_fallbackOpenAppId];
    }
  }

  static int splashInterstitialSecound() {
    try {
      return RemoteConfigService.getFirebaseAdConfig()
          .splashInterstitialSecound ??
          30;
    } catch (e) {
      return 30;
    }
  }

  static int onboardNativeSecound() {
    return 30;
  }

  static bool isInFrequency(String adLabel) {
    return true;
  }

  static String getAdType(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      if (config.adsData?.containsKey(adLabel) == true &&
          config.adsData?[adLabel]?.adsType != null &&
          config.adsData![adLabel]!.adsType!.isNotEmpty) {
        return config.adsData![adLabel]!.adsType!;
      }
      if (config.adsData != null) {
        for (final entry in config.adsData!.entries) {
          if (adLabel.startsWith(entry.key) &&
              entry.value.adsType != null &&
              entry.value.adsType!.isNotEmpty) {
            return entry.value.adsType!;
          }
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  static String getNativeLayout(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      if (config.adsData?.containsKey(adLabel) == true &&
          config.adsData?[adLabel]?.layout != null) {
        return config.adsData![adLabel]!.layout ?? '';
      }
      if (config.adsData != null) {
        for (final entry in config.adsData!.entries) {
          if (adLabel.startsWith(entry.key) && entry.value.layout != null) {
            return entry.value.layout!;
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static bool isFromAdMob(String adLabel) {
    try {
      final publisher = RemoteConfigService.getFirebaseAdConfig()
          .adsData?[adLabel]
          ?.publishers;
      return publisher == 'ad_unit' || publisher == null;
    } catch (e) {
      return true;
    }
  }

  static bool isAdEnable(String adLabel) {
    if (GetPlatform.isIOS) return false;
    try {
      if (ADService.isSubscribed()) return false;
      if (!ADService.getAdShowStatus()) return false;
      if (!RemoteConfigService.isAdEnabled(adLabel)) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  static double getAdHeight(
    String adLabel, {
    required double enabledHeight,
    double disabledHeight = 0.0,
  }) {
    return isAdEnable(adLabel) ? enabledHeight : disabledHeight;
  }

  static bool isAutoRefreshEnabled(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      final specific = config.adsData?[adLabel]?.autoRefresh;
      if (specific != null) return specific;
      return config.nativeAutoRefresh ?? true;
    } catch (_) {
      return true;
    }
  }

  static int getRefreshIntervalSec(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      final specific = config.adsData?[adLabel]?.refreshIntervalSec;
      if (specific != null && specific > 0) return specific;
      final global = config.nativeRefreshIntervalSec;
      if (global != null && global > 0) return global;
      return 30;
    } catch (_) {
      return 30;
    }
  }

  static bool isClickAfterRefreshEnabled(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      final specific = config.adsData?[adLabel]?.clickAfterRefreshEnable;
      if (specific != null) return specific;
      return config.clickAfterRefreshEnable ?? true;
    } catch (_) {
      return true;
    }
  }

  static bool shouldUseClickCounter(String adLabel) {
    try {
      final config = RemoteConfigService.getFirebaseAdConfig();
      if (config.adsData?.containsKey(adLabel) == true &&
          config.adsData?[adLabel]?.useClickCounter != null) {
        return config.adsData![adLabel]!.useClickCounter!;
      }
      return true;
    } catch (_) {
      return true;
    }
  }
}
