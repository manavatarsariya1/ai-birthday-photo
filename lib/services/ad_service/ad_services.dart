import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../constant/app_strings.dart';
import '../../data/models/firebase_ad_config_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';
import '../../utils/pref_service.dart';
import '../consent_service.dart';
import '../log_event_manager.dart';
import '../remote_config_service.dart';
import 'ad_helper.dart';
import 'ad_label_key.dart';
import 'ad_managers/ad_manager_native.dart';

class _LoadWaiter {
  final VoidCallback? onLoaded;
  final VoidCallback? onFailed;
  const _LoadWaiter(this.onLoaded, this.onFailed);
}

class ADService {
  // Ad instances
  static AppOpenAd? openAd;
  static InterstitialAd? interstitialAd;
  static RewardedAd? rewardedAd;

  static bool cameFromNoInternet = false;

  // Interstitial ad state
  static bool isInterLoaded = false;
  static bool isInterShowing = false;
  static bool _isInterLoading = false;
  static final List<_LoadWaiter> _interLoadWaiters = [];

  // Rewarded ad state
  static bool isRewardedLoaded = false;
  static bool _isRewardedLoading = false;
  static final List<_LoadWaiter> _rewardLoadWaiters = [];

  static void _notifyWaiters(List<_LoadWaiter> waiters, bool loaded) {
    final pending = List<_LoadWaiter>.from(waiters);
    waiters.clear();
    for (final w in pending) {
      loaded ? w.onLoaded?.call() : w.onFailed?.call();
    }
  }

  // Open app ad state
  static bool openAdBlock = false;
  static bool isOpenAdLoaded = false;
  static bool isOpenAdLoading = false;
  static bool isOpenAdShowing = false;
  static bool isPremiumScreenShowing = false;

  // Other state
  static bool splashOpen = false;
  static bool suppressAdsUntilHomeScreen = false;
  static bool suppressBackgroundOpenAd = false;
  static DateTime? _suppressBackgroundOpenAdUntil;
  static bool isFullScreenAdShowing = false;
  static bool isAppReadyForResumeAds = false;
  static DateTime? _lastFullScreenAdDismissedTime;
  static const int _fullScreenAdCooldownMs = 5000;
  static DateTime? _lastOpenAdShownTime;
  static const int _openAdCooldownMs = 15000;
  static int adCounter = 0;
  static int bottomBarAdCounter = 0;
  static Map<String, AdsDatum> adsData = {};
  static bool isSdkInitialized = false;

  /// Suppresses background open app ad loading and showing for a given duration
  /// (e.g. when launching Privacy Policy, Terms, Share, Camera/Gallery, Paywall, etc.)
  static void suppressBackgroundOpenAdFor([
    Duration duration = const Duration(seconds: 45),
  ]) {
    _suppressBackgroundOpenAdUntil = DateTime.now().add(duration);
    if (kDebugMode) {
      debugPrint(
        '🛡️ [ADService] Background open ad suppressed for ${duration.inSeconds}s (External URL/Share/Camera/Inter/Paywall)',
      );
    }
  }

  /// Checks if background open ad is currently suppressed
  static bool isBackgroundOpenAdSuppressed() {
    if (suppressBackgroundOpenAd) return true;
    if (_suppressBackgroundOpenAdUntil != null) {
      if (DateTime.now().isBefore(_suppressBackgroundOpenAdUntil!)) {
        return true;
      } else {
        _suppressBackgroundOpenAdUntil = null;
      }
    }
    return false;
  }

  /// Clears active suppression
  static void clearBackgroundOpenAdSuppression() {
    suppressBackgroundOpenAd = false;
    _suppressBackgroundOpenAdUntil = null;
  }

  // Cooldown
  static DateTime? _lastCounterIncrementTime;
  static const int _counterCooldownMs = 250;

  static void markFullScreenAdDismissed() {
    _lastFullScreenAdDismissedTime = DateTime.now();
    isFullScreenAdShowing = false;
    if (kDebugMode) {
      debugPrint(
        '[ADService] Full-screen ad dismissed. Resume ad cooldown active for ${_fullScreenAdCooldownMs}ms',
      );
    }
  }

  static bool isFullScreenAdCooldownActive() {
    if (_lastFullScreenAdDismissedTime == null) {
      return false;
    }
    final now = DateTime.now();
    final elapsed = now.difference(_lastFullScreenAdDismissedTime!);
    final isActive = elapsed.inMilliseconds < _fullScreenAdCooldownMs;
    if (!isActive) {
      _lastFullScreenAdDismissedTime = null;
    }
    return isActive;
  }

  static void markOpenAdShown() {
    _lastOpenAdShownTime = DateTime.now();
  }

  static bool isOpenAdCooldownActive() {
    if (_lastOpenAdShownTime == null) {
      return false;
    }
    final now = DateTime.now();
    final elapsed = now.difference(_lastOpenAdShownTime!);
    final isActive = elapsed.inMilliseconds < _openAdCooldownMs;
    if (!isActive) {
      _lastOpenAdShownTime = null;
    }
    return isActive;
  }

  static Future<bool> isNetworkConnected() async {
    final List<ConnectivityResult> results =
        await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  static final RxBool isPremiumRx = false.obs;

  static bool isSubscribed() {
    final isPrefPremium =
        PrefService.getBool(PrefService.isPremium, defaultValue: false);
    return isPremiumRx.value || isPrefPremium;
  }

  static Worker? _premiumWorker;

  /// Releases every cached full-screen / preloaded ad the moment the user
  /// becomes premium, so nothing stays in memory or gets shown afterwards.
  static void bindPremiumListener() {
    _premiumWorker ??= ever<bool>(isPremiumRx, (isPremium) {
      if (isPremium) disposeAllAds();
    });
    if (isPremiumRx.value) disposeAllAds();
  }

  static void disposeAllAds() {
    openAd?.dispose();
    openAd = null;
    isOpenAdLoaded = false;
    isOpenAdLoading = false;

    interstitialAd?.dispose();
    interstitialAd = null;
    isInterLoaded = false;
    _isInterLoading = false;
    _interLoadWaiters.clear();

    rewardedAd?.dispose();
    rewardedAd = null;
    isRewardedLoaded = false;
    _isRewardedLoading = false;
    _rewardLoadWaiters.clear();

    AdManagerNative.disposeAllPreloaded();

    if (kDebugMode) {
      debugPrint('💎 [ADService] User is premium -> all cached ads disposed');
    }
  }

  static bool getAdShowStatus() {
    if (GetPlatform.isIOS) return false;
    if (isSubscribed()) return false;
    try {
      final showAdsVal = RemoteConfigService.remoteConfig
          .getValue(RemoteConfigService.keyShowAds);
      if (showAdsVal.source == ValueSource.valueRemote && !showAdsVal.asBool()) {
        return false;
      }
      final appLiveVal = RemoteConfigService.remoteConfig
          .getValue(RemoteConfigService.keyAppLiveStatus);
      if (appLiveVal.source == ValueSource.valueRemote && !appLiveVal.asBool()) {
        return false;
      }
    } catch (_) {}
    final config = RemoteConfigService.getFirebaseAdConfig();
    if (config.appLiveStatus != true) return false;
    if (config.showAds != true) return false;
    return true;
  }

  static Future<void> initAdmob() async {
    if (GetPlatform.isIOS) return;
    if (isSdkInitialized) return;
    try {
      await ConsentService.initializeMobileAds();
      isSdkInitialized = true;
      if (kDebugMode) {
        debugPrint('[ADService] AdMob initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ADService] AdMob initialization error: $e');
      }
    }
  }

  static bool _isCounterCooldownActive() {
    if (_lastCounterIncrementTime == null) {
      return false;
    }
    final now = DateTime.now();
    final timeSinceIncrement = now.difference(_lastCounterIncrementTime!);
    final isActive = timeSinceIncrement.inMilliseconds < _counterCooldownMs;
    if (!isActive) {
      _lastCounterIncrementTime = null;
    }
    return isActive;
  }

  static void incrementUserClickCounter() {
    _incrementCounter();
  }

  static void _incrementCounter() {
    if (_isCounterCooldownActive()) {
      return;
    }
    adCounter++;
    _lastCounterIncrementTime = DateTime.now();
    if (kDebugMode) {
      debugPrint('[ADService] User click counter incremented to: $adCounter');
    }
  }

  static void incrementBottomBarCounter() {
    if (_isCounterCooldownActive()) {
      return;
    }
    bottomBarAdCounter++;
    _lastCounterIncrementTime = DateTime.now();
    if (kDebugMode) {
      debugPrint(
        '[ADService] Bottom bar click counter incremented to: $bottomBarAdCounter',
      );
    }
  }

  // Premium screen tracking
  static DateTime? _premiumScreenShownTime;
  static const int _premiumScreenCooldownMs = 10000;

  // Timer-based ad tracking
  static DateTime? _lastInterstitialShownTime;
  static DateTime? _lastBannerShownTime;
  static DateTime? _lastNativeShownTime;

  static void markPremiumScreenShown() {
    _premiumScreenShownTime = DateTime.now();
    if (kDebugMode) {
      debugPrint(
        '[ADService] Premium screen shown, blocking open app ads for $_premiumScreenCooldownMs ms',
      );
    }
  }

  static bool isPremiumScreenCooldownActive() {
    if (_premiumScreenShownTime == null) {
      return false;
    }
    final now = DateTime.now();
    final timeSinceShown = now.difference(_premiumScreenShownTime!);
    final isActive = timeSinceShown.inMilliseconds < _premiumScreenCooldownMs;
    if (!isActive) {
      _premiumScreenShownTime = null;
    }
    return isActive;
  }

  static bool isInterstitialTimerActive() {
    if (_lastInterstitialShownTime == null) {
      return false;
    }
    final gapSeconds = RemoteConfigService.interstitialGapSeconds;
    if (gapSeconds <= 0) {
      return false;
    }
    return DateTime.now().difference(_lastInterstitialShownTime!) <
        Duration(seconds: gapSeconds);
  }

  static bool isBannerTimerActive() {
    if (!RemoteConfigService.isBannerTimerEnabled) {
      return false;
    }
    if (_lastBannerShownTime == null) {
      return false;
    }
    final timerSeconds = RemoteConfigService.bannerTimerSeconds;
    if (timerSeconds <= 0) {
      return false;
    }
    return DateTime.now().difference(_lastBannerShownTime!) <
        Duration(seconds: timerSeconds);
  }

  static bool isNativeTimerModeEnabled() {
    return RemoteConfigService.isNativeTimerEnabled;
  }

  static int _nativeTimerSeconds() {
    return RemoteConfigService.nativeTimerSeconds;
  }

  static DateTime? _nativeLoadReservedUntil;
  static const Duration _nativeLoadReserveTimeout = Duration(seconds: 5);

  static bool isNativeTimerActive() {
    if (!isNativeTimerModeEnabled()) {
      return false;
    }
    if (_lastNativeShownTime == null) {
      return false;
    }
    final timerSeconds = _nativeTimerSeconds();
    if (timerSeconds <= 0) {
      return false;
    }
    final remaining = Duration(seconds: timerSeconds) -
        DateTime.now().difference(_lastNativeShownTime!);
    if (remaining <= Duration.zero) {
      _lastNativeShownTime = null;
      return false;
    }
    return true;
  }

  static bool isNativeAdLoadAllowed() {
    if (!isNativeTimerModeEnabled()) {
      return true;
    }
    final now = DateTime.now();
    if (isNativeTimerActive()) {
      return false;
    }
    if (_nativeLoadReservedUntil != null &&
        now.isBefore(_nativeLoadReservedUntil!)) {
      return false;
    }
    return true;
  }

  static bool tryReserveNativeAdLoad() {
    if (!isNativeTimerModeEnabled()) {
      return true;
    }
    final now = DateTime.now();
    if (isNativeTimerActive()) {
      return false;
    }
    if (_nativeLoadReservedUntil != null &&
        now.isBefore(_nativeLoadReservedUntil!)) {
      return false;
    }
    _nativeLoadReservedUntil = now.add(_nativeLoadReserveTimeout);
    return true;
  }

  static void cancelNativeAdLoadReservation() {
    _nativeLoadReservedUntil = null;
  }

  static void markNativeAdShown() {
    _nativeLoadReservedUntil = null;
    if (isNativeTimerModeEnabled()) {
      _lastNativeShownTime = DateTime.now();
    }
  }

  static void markInterstitialShown() {
    _lastInterstitialShownTime = DateTime.now();
  }

  static void markBannerShown() {
    _lastBannerShownTime = DateTime.now();
  }

  // ─────────────────────────────────────────────────────────────
  // App Open Ads
  // ─────────────────────────────────────────────────────────────
  static Future<void> loadOpenAd(String adLabel) async {
    if (GetPlatform.isIOS) return;
    final connected = await isNetworkConnected();
    if (isSubscribed() ||
        !connected ||
        !getAdShowStatus() ||
        !ADHelper.isAdEnable(adLabel) ||
        isBackgroundOpenAdSuppressed() ||
        isFullScreenAdShowing ||
        isInterShowing ||
        isFullScreenAdCooldownActive() ||
        isPremiumScreenShowing ||
        isPremiumScreenCooldownActive() ||
        (Get.currentRoute == AppRoutes.paywall) ||
        isOpenAdLoaded ||
        isOpenAdLoading) {
      if (kDebugMode) {
        debugPrint(
          '🛡️ [ADService] loadOpenAd suppressed or unavailable | Label: $adLabel | Suppressed: ${isBackgroundOpenAdSuppressed()} | FullScreen: $isFullScreenAdShowing | Cooldown: ${isFullScreenAdCooldownActive()}',
        );
      }
      return;
    }

    final adUnitIds = ADHelper.openAppAdList(adLabel: adLabel);
    if (adUnitIds.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '🛡️ [ADService] loadOpenAd skipped: empty open_app_ad_list for $adLabel',
        );
      }
      return;
    }

    isOpenAdLoading = true;
    _loadOpenAdAt(adLabel, adUnitIds, 0);
  }

  /// Waterfall over open_app_ad_list: ID 1 fails -> ID 2 -> ... -> give up.
  static void _loadOpenAdAt(String adLabel, List<String> ids, int index) {
    if (index >= ids.length || !ADHelper.isAdEnable(adLabel)) {
      openAd = null;
      isOpenAdLoaded = false;
      isOpenAdLoading = false;
      return;
    }
    final adUnitId = ids[index];
    LogEventManager.trackAdRequest(
      adPlatform: 'Admob',
      adUnitId: adUnitId,
      adType: 'app_open',
    );

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: ConsentService.getAdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          isOpenAdLoading = false;
          if (isSubscribed()) {
            ad.dispose();
            return;
          }
          if (kDebugMode) {
            debugPrint(
              '🎯 [AD LOADED] Open App Ad | Label: $adLabel | ID ${index + 1}/${ids.length}: $adUnitId',
            );
          }
          LogEventManager.trackAdMatchedRequest(
            adPlatform: 'Admob',
            adUnitId: adUnitId,
            adType: 'app_open',
            responseInfo: ad.responseInfo,
          );
          LogEventManager.logOpenAdLoad(adLabel);
          openAd = ad;
          isOpenAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint(
              '❌ [AD LOAD FAILED] Open App Ad | Label: $adLabel | ID ${index + 1}/${ids.length} | Error: ${error.message}',
            );
          }
          LogEventManager.logOpenAdFailToLoad(adLabel, error.message);
          _loadOpenAdAt(adLabel, ids, index + 1);
        },
      ),
    ).catchError((_) => _loadOpenAdAt(adLabel, ids, index + 1));
  }

  static void showOpenAppBackgroundAds(String adLabel) {
    if (GetPlatform.isIOS) return;
    if (isSubscribed() ||
        !getAdShowStatus() ||
        !ADHelper.isAdEnable(adLabel) ||
        !isOpenAdLoaded ||
        openAd == null ||
        openAdBlock ||
        isOpenAdShowing ||
        isInterShowing ||
        isFullScreenAdShowing ||
        isFullScreenAdCooldownActive() ||
        isOpenAdCooldownActive() ||
        isPremiumScreenShowing ||
        isPremiumScreenCooldownActive() ||
        isBackgroundOpenAdSuppressed() ||
        (Get.currentRoute == AppRoutes.paywall)) {
      if (kDebugMode) {
        debugPrint(
          '🛡️ [ADService] showOpenAppBackgroundAds skipped (Suppressed/Active Screen/Cooldown)',
        );
      }
      return;
    }

    openAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        isOpenAdShowing = true;
        isFullScreenAdShowing = true;
        markOpenAdShown();
        LogEventManager.logOpenAdShow(adLabel);
      },
      onAdDismissedFullScreenContent: (ad) {
        isOpenAdShowing = false;
        isFullScreenAdShowing = false;
        isOpenAdLoaded = false;
        openAd = null;
        markFullScreenAdDismissed();
        LogEventManager.logOpenAdClose(adLabel);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        isOpenAdShowing = false;
        isFullScreenAdShowing = false;
        isOpenAdLoaded = false;
        openAd = null;
        markFullScreenAdDismissed();
        LogEventManager.logOpenAdFailToLoad(adLabel, error.message);
      },
      onAdClicked: (ad) {
        _logFullScreenAdClick(ad, adLabel, 'app_open');
        LogEventManager.logOpenAdClick(adLabel);
      },
    );

    openAd!.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
      final revenue = valueMicros / 1000000.0;
      LogEventManager.logPaidAdEvent(
        revenue: revenue,
        currency: currencyCode,
        precision: precision.index,
        adUnitId: ad.adUnitId,
        adType: 'app_open',
        screenName: adLabel,
      );
    };

    openAd!.show();
  }

  // ─────────────────────────────────────────────────────────────
  // Interstitial Ads
  // ─────────────────────────────────────────────────────────────
  static DateTime? _interLoadedAt;
  // Google expires interstitials after 1 hour; showing a stale one fails.
  static const Duration _interMaxAge = Duration(minutes: 55);

  static bool _hasFreshInterstitial() {
    if (!isInterLoaded || interstitialAd == null) return false;
    final loadedAt = _interLoadedAt;
    if (loadedAt != null && DateTime.now().difference(loadedAt) > _interMaxAge) {
      interstitialAd?.dispose();
      interstitialAd = null;
      isInterLoaded = false;
      _interLoadedAt = null;
      return false;
    }
    return true;
  }

  static Future<void> loadInterstitialAd({
    String adLabel = ADLabelKey.homeSectionNative,
    VoidCallback? onLoaded,
    VoidCallback? onFailed,
  }) async {
    if (GetPlatform.isIOS) {
      onFailed?.call();
      return;
    }
    final connected = await isNetworkConnected();
    if (isSubscribed() ||
        !connected ||
        !getAdShowStatus() ||
        !ADHelper.isAdEnable(adLabel)) {
      onFailed?.call();
      return;
    }
    if (_hasFreshInterstitial()) {
      onLoaded?.call();
      return;
    }
    // A load is already running (e.g. the auto-reload after the previous
    // dismissal); join it instead of firing a second ad request.
    if (_isInterLoading) {
      if (onLoaded != null || onFailed != null) {
        _interLoadWaiters.add(_LoadWaiter(onLoaded, onFailed));
      }
      return;
    }

    final adUnitIds = ADHelper.interAdList();
    if (adUnitIds.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '🛡️ [ADService] loadInterstitialAd skipped: empty inter_ad_list for $adLabel',
        );
      }
      onFailed?.call();
      return;
    }

    _isInterLoading = true;
    if (onLoaded != null || onFailed != null) {
      _interLoadWaiters.add(_LoadWaiter(onLoaded, onFailed));
    }
    _loadInterstitialAt(adLabel, adUnitIds, 0);
  }

  /// Waterfall over inter_ad_list: ID 1 fails -> ID 2 -> ... -> give up.
  static void _loadInterstitialAt(String adLabel, List<String> ids, int index) {
    if (index >= ids.length || !ADHelper.isAdEnable(adLabel)) {
      _isInterLoading = false;
      interstitialAd = null;
      isInterLoaded = false;
      _notifyWaiters(_interLoadWaiters, false);
      return;
    }
    final adUnitId = ids[index];
    LogEventManager.trackAdRequest(
      adPlatform: 'Admob',
      adUnitId: adUnitId,
      adType: 'interstitial',
    );

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: ConsentService.getAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isInterLoading = false;
          if (isSubscribed()) {
            ad.dispose();
            _notifyWaiters(_interLoadWaiters, false);
            return;
          }
          if (kDebugMode) {
            debugPrint(
              '🎯 [AD LOADED] Interstitial Ad | Label: $adLabel | ID ${index + 1}/${ids.length}: $adUnitId',
            );
          }
          LogEventManager.trackAdMatchedRequest(
            adPlatform: 'Admob',
            adUnitId: adUnitId,
            adType: 'interstitial',
            responseInfo: ad.responseInfo,
          );
          LogEventManager.logInterAdLoad(adLabel);
          interstitialAd = ad;
          isInterLoaded = true;
          _interLoadedAt = DateTime.now();
          _notifyWaiters(_interLoadWaiters, true);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint(
              '❌ [AD LOAD FAILED] Interstitial Ad | Label: $adLabel | ID ${index + 1}/${ids.length} | Error: ${error.message}',
            );
          }
          LogEventManager.logInterAdFailToLoad(adLabel, error.message);
          _loadInterstitialAt(adLabel, ids, index + 1);
        },
      ),
    ).catchError((_) => _loadInterstitialAt(adLabel, ids, index + 1));
  }

  // ─────────────────────────────────────────────────────────────
  // Ad Loading Dialog
  // ─────────────────────────────────────────────────────────────
  static bool _isAdLoadingDialogShown = false;

  static void showLoadingDialog() {
    if (_isAdLoadingDialogShown) return;
    _isAdLoadingDialogShown = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: AppColors.whiteColor,
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 24.h,
              horizontal: 20.w,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: const CircularProgressIndicator(
                    color: AppColors.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(width: 20.w),
                CommonText.text(
                  title: AppStrings.loadingAd,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void dismissLoadingDialog() {
    if (_isAdLoadingDialogShown) {
      _isAdLoadingDialogShown = false;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  static void showInterstitialAd({
    String adLabel = ADLabelKey.homeSectionNative,
    VoidCallback? onDismissed,
    VoidCallback? onAdDismissed,
  }) {
    final callback = onDismissed ?? onAdDismissed ?? () {};
    if (GetPlatform.isIOS) {
      dismissLoadingDialog();
      callback();
      return;
    }
    if (isSubscribed() ||
        !getAdShowStatus() ||
        !ADHelper.isAdEnable(adLabel) ||
        !isInterLoaded ||
        interstitialAd == null ||
        isInterShowing) {
      dismissLoadingDialog();
      callback();
      return;
    }

    showLoadingDialog();

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        dismissLoadingDialog();
        isInterShowing = true;
        isFullScreenAdShowing = true;
        adCounter = 0;
        markInterstitialShown();
        LogEventManager.logInterAdShow(adLabel);
      },
      onAdDismissedFullScreenContent: (ad) {
        dismissLoadingDialog();
        isInterShowing = false;
        isFullScreenAdShowing = false;
        isInterLoaded = false;
        interstitialAd = null;
        markInterstitialShown();
        markFullScreenAdDismissed();
        LogEventManager.logInterAdClose(adLabel);
        callback();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        dismissLoadingDialog();
        isInterShowing = false;
        isFullScreenAdShowing = false;
        isInterLoaded = false;
        interstitialAd = null;
        markFullScreenAdDismissed();
        LogEventManager.logInterAdFailToLoad(adLabel, error.message);
        callback();
      },
      onAdClicked: (ad) {
        _logFullScreenAdClick(ad, adLabel, 'interstitial');
        LogEventManager.logInterAdClick(adLabel);
      },
    );

    interstitialAd!.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
      final revenue = valueMicros / 1000000.0;
      LogEventManager.logPaidAdEvent(
        revenue: revenue,
        currency: currencyCode,
        precision: precision.index,
        adUnitId: ad.adUnitId,
        adType: 'interstitial',
        screenName: adLabel,
      );
    };

    interstitialAd!.show();
  }

  static void _logFullScreenAdClick(Ad ad, String adLabel, String adFormat) {
    LogEventManager.logAdClick(
      screenName: adLabel,
      adUnitId: ad.adUnitId,
      adPlatform: 'Admob',
      adFormat: adFormat,
      adSource:
          ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? 'Admob',
      network: ad.responseInfo?.mediationAdapterClassName ?? 'unknown',
    );
  }

  static void showInterstitialOnCondition({
    required String adLabel,
    required VoidCallback onProceed,
  }) {
    if (GetPlatform.isIOS ||
        isSubscribed() ||
        !getAdShowStatus() ||
        !ADHelper.isAdEnable(adLabel)) {
      onProceed();
      return;
    }

    // user_click_counter and interstitial_gap are interstitial-only rules. If
    // Remote Config switches this placement to a rewarded ad, show it directly
    // without counting the click or checking the gap.
    if (ADHelper.getAdType(adLabel).toLowerCase().contains('reward')) {
      showActionAd(adLabel: adLabel, onProceed: onProceed);
      return;
    }

    // Increment click counter for interstitial ad trigger
    incrementUserClickCounter();

    final bool useClickCounter = !RemoteConfigService.isInterTimerEnabled &&
        ADHelper.shouldUseClickCounter(adLabel);
    final int targetClicks = RemoteConfigService.userClickCounter;

    // 1. Evaluate User Click Counter Condition. ">=" (not "%") so a click that
    // was blocked by the interstitial gap still shows on the next click instead
    // of waiting for another full cycle; the counter resets when an ad shows.
    final bool isClickConditionMet =
        !useClickCounter || (targetClicks > 0 && adCounter >= targetClicks);

    // 2. Evaluate Interstitial Gap Condition (Time gap between two Interstitial Ads)
    final bool isGapElapsed = !isInterstitialTimerActive();

    // 3. Dual Condition: BOTH user click counter AND gap condition must be satisfied
    final bool shouldShowAd = isClickConditionMet && isGapElapsed;

    final int elapsedSeconds = _lastInterstitialShownTime != null
        ? DateTime.now().difference(_lastInterstitialShownTime!).inSeconds
        : -1;
    final int requiredGapSeconds = RemoteConfigService.interstitialGapSeconds;

    if (kDebugMode) {
      debugPrint(
        '🎯 [ADService] showInterstitialOnCondition | Label: $adLabel | '
        'Clicks: $adCounter/$targetClicks (Met: $isClickConditionMet, useClickCounter: $useClickCounter) | '
        'Gap: ${elapsedSeconds == -1 ? "No previous ad" : "${elapsedSeconds}s"}/$requiredGapSeconds s (Met: $isGapElapsed) | '
        'ShouldShowAd: $shouldShowAd',
      );
    }

    if (shouldShowAd) {
      showLoadingDialog();
      if (_hasFreshInterstitial()) {
        showInterstitialAd(
          adLabel: adLabel,
          onDismissed: onProceed,
        );
      } else {
        loadInterstitialAd(
          adLabel: adLabel,
          onLoaded: () {
            showInterstitialAd(
              adLabel: adLabel,
              onDismissed: onProceed,
            );
          },
          onFailed: () {
            dismissLoadingDialog();
            onProceed();
          },
        );
      }
    } else {
      onProceed();
      // Preload only when the user is one click away from the target, so the
      // loaded ad is (almost) always shown on the next click and no request
      // is wasted. Below that, nothing is loaded at all.
      if (useClickCounter &&
          targetClicks > 1 &&
          adCounter >= targetClicks - 1 &&
          !_hasFreshInterstitial()) {
        if (kDebugMode) {
          debugPrint(
            '⏳ [ADService] Clicks $adCounter/$targetClicks -> preloading interstitial for next click',
          );
        }
        loadInterstitialAd(adLabel: adLabel);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Rewarded Ads
  // ─────────────────────────────────────────────────────────────
  static Future<void> loadRewardedAd({
    String adLabel = 'rewarded',
    VoidCallback? onLoaded,
    VoidCallback? onFailed,
  }) async {
    if (GetPlatform.isIOS) {
      onFailed?.call();
      return;
    }
    final connected = await isNetworkConnected();
    if (isSubscribed() ||
        !connected ||
        !getAdShowStatus() ||
        !ADHelper.isAdEnable(adLabel)) {
      onFailed?.call();
      return;
    }
    if (isRewardedLoaded && rewardedAd != null) {
      onLoaded?.call();
      return;
    }
    if (_isRewardedLoading) {
      if (onLoaded != null || onFailed != null) {
        _rewardLoadWaiters.add(_LoadWaiter(onLoaded, onFailed));
      }
      return;
    }

    final adUnitIds = ADHelper.rewardedAdList();
    if (adUnitIds.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '🛡️ [ADService] loadRewardedAd skipped: empty rewarded_ad_list for $adLabel',
        );
      }
      onFailed?.call();
      return;
    }

    _isRewardedLoading = true;
    if (onLoaded != null || onFailed != null) {
      _rewardLoadWaiters.add(_LoadWaiter(onLoaded, onFailed));
    }
    _loadRewardedAt(adLabel, adUnitIds, 0);
  }

  /// Waterfall over rewarded_ad_list: ID 1 fails -> ID 2 -> ... -> give up.
  static void _loadRewardedAt(String adLabel, List<String> ids, int index) {
    if (index >= ids.length || !ADHelper.isAdEnable(adLabel)) {
      rewardedAd = null;
      isRewardedLoaded = false;
      _isRewardedLoading = false;
      _notifyWaiters(_rewardLoadWaiters, false);
      return;
    }
    final adUnitId = ids[index];
    LogEventManager.trackAdRequest(
      adPlatform: 'Admob',
      adUnitId: adUnitId,
      adType: 'rewarded',
    );

    RewardedAd.load(
      adUnitId: adUnitId,
      request: ConsentService.getAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isRewardedLoading = false;
          if (isSubscribed()) {
            ad.dispose();
            _notifyWaiters(_rewardLoadWaiters, false);
            return;
          }
          if (kDebugMode) {
            debugPrint(
              '🎯 [AD LOADED] Rewarded Ad | Label: $adLabel | ID ${index + 1}/${ids.length}: $adUnitId',
            );
          }
          rewardedAd = ad;
          isRewardedLoaded = true;
          LogEventManager.trackAdMatchedRequest(
            adPlatform: 'Admob',
            adUnitId: adUnitId,
            adType: 'rewarded',
            responseInfo: ad.responseInfo,
          );
          LogEventManager.logRewardAdLoad(adLabel);
          _notifyWaiters(_rewardLoadWaiters, true);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint(
              '❌ [AD LOAD FAILED] Rewarded Ad | Label: $adLabel | ID ${index + 1}/${ids.length} | Error: ${error.message}',
            );
          }
          LogEventManager.logRewardAdFailToLoad(adLabel, error.message);
          _loadRewardedAt(adLabel, ids, index + 1);
        },
      ),
    ).catchError((_) => _loadRewardedAt(adLabel, ids, index + 1));
  }

  static void showRewardedAd({
    required String adLabel,
    required OnUserEarnedRewardCallback onUserEarnedReward,
    required VoidCallback onDismissed,
  }) {
    if (GetPlatform.isIOS ||
        isSubscribed() ||
        !getAdShowStatus() ||
        !isRewardedLoaded ||
        rewardedAd == null) {
      dismissLoadingDialog();
      onDismissed();
      return;
    }

    showLoadingDialog();

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        dismissLoadingDialog();
        isFullScreenAdShowing = true;
        LogEventManager.logRewardAdShow(adLabel);
      },
      onAdClicked: (ad) {
        _logFullScreenAdClick(ad, adLabel, 'rewarded');
        LogEventManager.logRewardAdClick(adLabel);
      },
      onAdDismissedFullScreenContent: (ad) {
        dismissLoadingDialog();
        isFullScreenAdShowing = false;
        isRewardedLoaded = false;
        rewardedAd = null;
        markFullScreenAdDismissed();
        LogEventManager.logRewardAdClose(adLabel);
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        dismissLoadingDialog();
        isFullScreenAdShowing = false;
        LogEventManager.logRewardAdFailToLoad(adLabel, error.message);
        isRewardedLoaded = false;
        rewardedAd = null;
        markFullScreenAdDismissed();
        onDismissed();
      },
    );

    rewardedAd!.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
      final revenue = valueMicros / 1000000.0;
      LogEventManager.logPaidAdEvent(
        revenue: revenue,
        currency: currencyCode,
        precision: precision.index,
        adUnitId: ad.adUnitId,
        adType: 'rewarded',
        screenName: adLabel,
      );
    };

    rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        LogEventManager.logRewardAdEarned(adLabel);
        onUserEarnedReward(ad, reward);
      },
    );
  }

  /// Show Action Ad with full Remote Config Fallback support:
  /// Primary Ad -> (if failed) -> Fallback 1 -> (if failed) -> Fallback 2 -> ... -> Continue Application (onProceed)
  static void showActionAd({
    required String adLabel,
    required VoidCallback onProceed,
  }) {
    if (GetPlatform.isIOS ||
        isSubscribed() ||
        !getAdShowStatus() ||
        !ADHelper.isAdEnable(adLabel)) {
      onProceed();
      return;
    }

    final primaryType = ADHelper.getAdType(adLabel).toLowerCase();
    final fallbackList = ADHelper.getFallbackAds(adLabel);

    // Interstitial actions (result save/share...) respect interstitial_gap;
    // rewarded actions are user-initiated and always allowed.
    if (!primaryType.contains('reward') && isInterstitialTimerActive()) {
      if (kDebugMode) {
        debugPrint(
          '⏱️ [ADService] $adLabel skipped: interstitial_gap (${RemoteConfigService.interstitialGapSeconds}s) not elapsed',
        );
      }
      onProceed();
      return;
    }

    showLoadingDialog();

    void executeFallback(int index) {
      if (index >= fallbackList.length) {
        if (kDebugMode) {
          debugPrint('[$adLabel] All fallbacks exhausted. Continuing application.');
        }
        dismissLoadingDialog();
        onProceed();
        return;
      }

      final fb = fallbackList[index];
      if (fb.enable == false) {
        executeFallback(index + 1);
        return;
      }

      final fbType = (fb.adsType ?? '').toLowerCase().trim();
      if (fbType.isEmpty || fbType == primaryType) {
        executeFallback(index + 1);
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '🔄 [ADService] Running Fallback ${index + 1}/${fallbackList.length} for $adLabel (Type: $fbType, Priority: ${fb.priority}, Unit: ${fb.adUnitId ?? "default"})',
        );
      }

      if (fbType.contains('reward')) {
        if (isRewardedLoaded && rewardedAd != null) {
          showRewardedAd(
            adLabel: adLabel,
            onUserEarnedReward: (ad, reward) {},
            onDismissed: onProceed,
          );
        } else {
          loadRewardedAd(
            adLabel: adLabel,
            onLoaded: () {
              showRewardedAd(
                adLabel: adLabel,
                onUserEarnedReward: (ad, reward) {},
                onDismissed: onProceed,
              );
            },
            onFailed: () => executeFallback(index + 1),
          );
        }
      } else if (fbType.contains('inter')) {
        // An interstitial fallback still has to respect interstitial_gap.
        if (isInterstitialTimerActive()) {
          executeFallback(index + 1);
        } else if (_hasFreshInterstitial()) {
          showInterstitialAd(
            adLabel: adLabel,
            onDismissed: onProceed,
          );
        } else {
          loadInterstitialAd(
            adLabel: adLabel,
            onLoaded: () {
              showInterstitialAd(
                adLabel: adLabel,
                onDismissed: onProceed,
              );
            },
            onFailed: () => executeFallback(index + 1),
          );
        }
      } else if (fbType.contains('open')) {
        if (isOpenAdLoaded && openAd != null) {
          showOpenAppBackgroundAds(adLabel);
          onProceed();
        } else {
          loadOpenAd(adLabel);
          executeFallback(index + 1);
        }
      } else {
        executeFallback(index + 1);
      }
    }

    if (primaryType.contains('reward')) {
      if (isRewardedLoaded && rewardedAd != null) {
        showRewardedAd(
          adLabel: adLabel,
          onUserEarnedReward: (ad, reward) {},
          onDismissed: onProceed,
        );
      } else {
        loadRewardedAd(
          adLabel: adLabel,
          onLoaded: () {
            showRewardedAd(
              adLabel: adLabel,
              onUserEarnedReward: (ad, reward) {},
              onDismissed: onProceed,
            );
          },
          onFailed: () => executeFallback(0),
        );
      }
    } else {
      // Interstitial Ad as Primary
      if (_hasFreshInterstitial()) {
        showInterstitialAd(
          adLabel: adLabel,
          onDismissed: onProceed,
        );
      } else {
        loadInterstitialAd(
          adLabel: adLabel,
          onLoaded: () {
            showInterstitialAd(
              adLabel: adLabel,
              onDismissed: onProceed,
            );
          },
          onFailed: () => executeFallback(0),
        );
      }
    }
  }

  /// Specialized helper to show ad for Action Dialog (controlled via Remote Config: reward vs interstitial)
  static void showGenerateDialogAd({
    required VoidCallback onProceed,
  }) {
    showActionAd(
      adLabel: ADLabelKey.commonPaywallClose,
      onProceed: onProceed,
    );
  }
}
