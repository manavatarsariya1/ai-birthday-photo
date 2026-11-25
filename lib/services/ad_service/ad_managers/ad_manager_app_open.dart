import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../ad_helper.dart';
import '../ad_label_key.dart';
import '../ad_services.dart';

/// Manages background App Open Ads
class AdManagerAppOpen with WidgetsBindingObserver {
  static final AdManagerAppOpen instance = AdManagerAppOpen._internal();
  AdManagerAppOpen._internal();

  bool _isInitialized = false;
  bool _isAppInBackground = false;
  // Set when the app left the foreground for an in-app action (share sheet,
  // gallery, external link...). The very next resume must not show an open ad
  // no matter how long the user stayed outside.
  bool _pauseWasSuppressed = false;

  DateTime? _appPausedTime;

  /// Initialize lifecycle observer for background app open ads
  void init() {
    if (GetPlatform.isIOS) return;
    if (_isInitialized) return;
    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    if (kDebugMode) {
      debugPrint(
        '🚀 [AdManagerAppOpen] Initialized lifecycle observer for background app open ads',
      );
    }
  }

  /// Remove observer
  void dispose() {
    if (!_isInitialized) return;
    _isInitialized = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 1. App moved to background (paused / hidden only - NEVER inactive)
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      // If a full-screen ad (interstitial/rewarded/open) is currently showing,
      // the pause is caused by the ad activity, NOT the user leaving the app!
      if (ADService.isFullScreenAdShowing ||
          ADService.isInterShowing ||
          ADService.isOpenAdShowing) {
        if (kDebugMode) {
          debugPrint(
            '⏸️ [AdManagerAppOpen] App paused due to full-screen ad presentation. Skipping background resume flag.',
          );
        }
        return;
      }

      if (!_isAppInBackground) {
        _isAppInBackground = true;
        _appPausedTime = DateTime.now();
        _onAppPaused();
      }
    }

    // 2. App returned to foreground (resumed)
    if (state == AppLifecycleState.resumed) {
      if (_isAppInBackground) {
        _isAppInBackground = false;
        final pausedDuration = _appPausedTime != null
            ? DateTime.now().difference(_appPausedTime!)
            : Duration.zero;
        _appPausedTime = null;

        _onAppResumed(pausedDuration);
      }
    }
  }

  void _onAppPaused() {
    _pauseWasSuppressed = ADService.isBackgroundOpenAdSuppressed();
    final showAds = ADService.getAdShowStatus();
    final enabled = ADHelper.isAdEnable(ADLabelKey.backgroundOpenApp) ||
        ADHelper.isAdEnable(ADLabelKey.appResume);
    final subscribed = ADService.isSubscribed();
    final suppress = !ADService.isAppReadyForResumeAds;
    final suppressPerm = ADService.isBackgroundOpenAdSuppressed();
    final isFullScreen = ADService.isFullScreenAdShowing ||
        ADService.isInterShowing ||
        ADService.isOpenAdShowing ||
        ADService.isFullScreenAdCooldownActive();
    final isPremium = ADService.isPremiumScreenShowing ||
        ADService.isPremiumScreenCooldownActive() ||
        (Get.currentRoute == AppRoutes.paywall);

    if (subscribed ||
        !showAds ||
        !enabled ||
        suppress ||
        suppressPerm ||
        isFullScreen ||
        isPremium) {
      if (kDebugMode) {
        debugPrint(
          '⏸️ [AdManagerAppOpen] App paused -> background open ad load SUPPRESSED (subscribed: $subscribed, showAds: $showAds, enabled: $enabled, suppressPerm: $suppressPerm, isFullScreen: $isFullScreen, isPremium: $isPremium)',
        );
      }
      return;
    }

    final isLoaded = ADService.isOpenAdLoaded;
    final isLoading = ADService.isOpenAdLoading;

    if (!isLoaded && !isLoading) {
      if (kDebugMode) {
        debugPrint(
          'App paused -> Preloading background open ad (${ADLabelKey.backgroundOpenApp})',
        );
      }
      ADService.loadOpenAd(ADLabelKey.backgroundOpenApp);
    }
  }

  void _onAppResumed(Duration pausedDuration) {
    final wasSuppressed =
        _pauseWasSuppressed || ADService.isBackgroundOpenAdSuppressed();
    _pauseWasSuppressed = false;
    ADService.clearBackgroundOpenAdSuppression();
    if (wasSuppressed) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [AdManagerAppOpen] Returned from in-app action (Share/Gallery/Link). Skipping open ad once.',
        );
      }
      return;
    }

    // 1. Must have been in background for at least 1.5 seconds to avoid transient triggers
    if (pausedDuration < const Duration(milliseconds: 1500)) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [AdManagerAppOpen] App resumed too quickly (${pausedDuration.inMilliseconds}ms < 1500ms). Skipping open ad.',
        );
      }
      return;
    }

    // 2. Check if app is ready (post-splash)
    if (!ADService.isAppReadyForResumeAds) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [AdManagerAppOpen] App resumed but splash/onboarding not completed. Skipping open ad.',
        );
      }
      return;
    }

    // 3. Check if a full-screen ad is showing or cooldown is active (5s cooldown)
    if (ADService.isFullScreenAdShowing ||
        ADService.isInterShowing ||
        ADService.isOpenAdShowing ||
        ADService.isFullScreenAdCooldownActive() ||
        ADService.isOpenAdCooldownActive()) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [AdManagerAppOpen] Full-screen ad is showing or cooldown active. Skipping open ad.',
        );
      }
      return;
    }

    // 4. Check if premium screen / paywall cooldown is active
    if (ADService.isPremiumScreenShowing ||
        ADService.isPremiumScreenCooldownActive() ||
        (Get.currentRoute == AppRoutes.paywall)) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [AdManagerAppOpen] Premium screen / paywall active. Skipping open ad.',
        );
      }
      return;
    }

    final showAds = ADService.getAdShowStatus();
    final enabled = ADHelper.isAdEnable(ADLabelKey.backgroundOpenApp) ||
        ADHelper.isAdEnable(ADLabelKey.appResume);
    final subscribed = ADService.isSubscribed();

    if (subscribed || !showAds || !enabled) {
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '🎯 [AdManagerAppOpen] App resumed from real background (${pausedDuration.inSeconds}s) -> Showing background open ad (${ADLabelKey.backgroundOpenApp})',
      );
    }
    ADService.showOpenAppBackgroundAds(ADLabelKey.backgroundOpenApp);
  }
}
