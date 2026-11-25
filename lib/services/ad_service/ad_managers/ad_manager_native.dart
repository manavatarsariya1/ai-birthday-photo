import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

import '../../consent_service.dart';
import '../../log_event_manager.dart';
import '../ad_helper.dart';
import '../ad_label_key.dart';
import '../ad_services.dart';

enum NativeAdScreenType { onboarding, languageSelection }

class AdManagerNative {
  static const String _tag = "AdManagerNative";

  // ========== ONBOARDING NATIVE AD VARIABLES ==========
  static NativeAd? onboardingNativeAd;
  static bool _isOnboardingLoaded = false;
  static Timer? _onboardingLoadTimer;
  static List<String> _onboardingAdIds = [];
  static int _currentOnboardingIndex = 0;
  static bool _isOnboardingSequentialLoading = false;
  static bool _wasOnboardingShownAndDismissed = false;
  static bool _isOnboardingLoadingFailed = false;

  // ========== LANGUAGE SELECTION NATIVE AD VARIABLES ==========
  static NativeAd? languageSelectionNativeAd;
  static bool _isLanguageSelectionLoaded = false;
  static Timer? _languageSelectionLoadTimer;
  static List<String> _languageSelectionAdIds = [];
  static int _currentLanguageSelectionIndex = 0;
  static bool _isLanguageSelectionSequentialLoading = false;
  static bool _wasLanguageSelectionShownAndDismissed = false;
  static bool _isLanguageSelectionLoadingFailed = false;

  // ========== PRELOADED NATIVE ADS POOL ==========
  static final Map<String, NativeAd?> _preloadedNativeAds = {};
  static final Map<String, bool> _preloadedNativeLoaded = {};
  static final Map<String, VoidCallback> _adClickListeners = {};

  static void registerAdClickListener(String label, VoidCallback callback) {
    _adClickListeners[label] = callback;
  }

  static void unregisterAdClickListener(String label) {
    _adClickListeners.remove(label);
  }

  static String _resolveFactoryIdForLabel(String adLabel) {
    final remoteLayout =
        ADHelper.getNativeLayout(adLabel).toLowerCase().trim();
    if (remoteLayout == 'large' || remoteLayout == 'big') {
      return "nativeAdMain";
    } else if (remoteLayout == 'languagelargemedia' ||
        remoteLayout == 'language_large_media' ||
        remoteLayout == 'large_media') {
      return "nativeAdLanguageLargeMedia";
    } else if (remoteLayout == 'medium') {
      return "nativeAd";
    } else if (remoteLayout == 'mediasquare' ||
        remoteLayout == 'media_square') {
      return "nativeAdMediaSquare";
    } else if (remoteLayout == 'exit') {
      return "nativeAdExit";
    } else if (remoteLayout == 'small' || remoteLayout == 'listtile') {
      return "listTileNativeAd";
    }
    if (adLabel == ADLabelKey.languageScreen) {
      return "nativeAdLanguageLargeMedia";
    }
    return "nativeAd";
  }

  /// Preload a native ad by adLabel with automatic or custom factoryId
  static Future<void> preloadNativeAd(
    String adLabel, {
    String? factoryId,
  }) async {
    if (GetPlatform.isIOS) return;
    final connected = await ADService.isNetworkConnected();
    if (ADService.isSubscribed() ||
        !connected ||
        !ADService.getAdShowStatus() ||
        ADService.suppressAdsUntilHomeScreen) {
      return;
    }

    if (!ADHelper.isAdEnable(adLabel)) {
      if (kDebugMode) {
        debugPrint(
          '[$_tag] 🚫 [PRELOAD SKIPPED] Native Ad: $adLabel is disabled in Remote Config',
        );
      }
      return;
    }

    if ((_preloadedNativeAds[adLabel] != null &&
            _preloadedNativeLoaded[adLabel] == true) ||
        _preloadInFlight.contains(adLabel)) {
      return;
    }

    final ids = ADHelper.nativeAdIdsForLabel(adLabel)
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (ids.isEmpty) return;
    _preloadInFlight.add(adLabel);
    _preloadAt(adLabel, ids, 0, factoryId ?? _resolveFactoryIdForLabel(adLabel));
  }

  /// Waterfall over the placement's native ID list: ID 1 fails -> ID 2 -> ...
  static void _preloadAt(
    String adLabel,
    List<String> ids,
    int index,
    String resolvedFactoryId,
  ) {
    if (index >= ids.length ||
        !_preloadInFlight.contains(adLabel) ||
        !ADHelper.isAdEnable(adLabel)) {
      _preloadInFlight.remove(adLabel);
      return;
    }
    final adUnitId = ids[index];

    if (kDebugMode) {
      debugPrint(
        "[$_tag] 🚀 [PRELOAD START] Native Ad: $adLabel | Factory: $resolvedFactoryId | ID ${index + 1}/${ids.length}: $adUnitId",
      );
    }

    LogEventManager.trackAdRequest(
      adPlatform: 'Admob',
      adUnitId: adUnitId,
      adType: 'native',
    );

    final nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: resolvedFactoryId,
      request: ConsentService.getAdRequest(),
      listener: NativeAdListener(
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          final revenue = valueMicros / 1000000.0;
          LogEventManager.logPaidAdEvent(
            screenName: adLabel,
            revenue: revenue,
            precision: precision.index,
            adUnitId: adUnitId,
            adType: 'native',
            currency: currencyCode,
            adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
            network: ad.responseInfo?.mediationAdapterClassName,
          );
        },
        onAdLoaded: (ad) {
          _preloadInFlight.remove(adLabel);
          if (ADService.isSubscribed()) {
            ad.dispose();
            return;
          }
          if (kDebugMode) {
            debugPrint('[$_tag] 🎯 [PRELOAD SUCCESS] Native Ad: $adLabel');
          }
          _preloadedNativeAds[adLabel] = ad as NativeAd;
          _preloadedNativeLoaded[adLabel] = true;
          LogEventManager.trackAdMatchedRequest(
            adPlatform: 'Admob',
            adUnitId: adUnitId,
            adType: 'native',
            responseInfo: ad.responseInfo,
          );
          LogEventManager.logNativeAdLoad(adLabel);
          LogEventManager.logDedicatedNativeAdLoad(adLabel);
        },
        onAdClicked: (ad) {
          if (kDebugMode) {
            debugPrint('[$_tag] 🎯 [PRELOAD CLICKED] Native Ad: $adLabel');
          }
          LogEventManager.logAdClick(
            screenName: adLabel,
            adUnitId: adUnitId,
            adPlatform: 'Admob',
            adFormat: 'native',
            adSource:
                ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ??
                'Admob',
            network: ad.responseInfo?.mediationAdapterClassName ?? 'unknown',
          );
          LogEventManager.logNativeAdClick(adLabel);
          LogEventManager.logDedicatedNativeAdClick(adLabel);
          _adClickListeners[adLabel]?.call();
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint(
              '[$_tag] ❌ [PRELOAD FAIL] Native Ad: $adLabel: ${error.message}',
            );
          }
          ad.dispose();
          _preloadedNativeAds[adLabel] = null;
          _preloadedNativeLoaded[adLabel] = false;
          LogEventManager.logNativeAdFailToLoad(adLabel, error.message);
          LogEventManager.logDedicatedNativeAdFail(adLabel, error.message);
          _preloadAt(adLabel, ids, index + 1, resolvedFactoryId);
        },
      ),
    );

    nativeAd
        .load()
        .catchError((_) => _preloadAt(adLabel, ids, index + 1, resolvedFactoryId));
  }

  static final Set<String> _preloadInFlight = {};

  static void disposeAllPreloaded() {
    for (final ad in _preloadedNativeAds.values) {
      ad?.dispose();
    }
    _preloadedNativeAds.clear();
    _preloadedNativeLoaded.clear();
    _preloadInFlight.clear();
  }

  /// Get preloaded native ad for an adLabel if available
  static NativeAd? consumePreloadedAd(String adLabel) {
    if (_preloadedNativeLoaded[adLabel] == true &&
        _preloadedNativeAds[adLabel] != null) {
      final ad = _preloadedNativeAds[adLabel];
      _preloadedNativeAds[adLabel] = null;
      _preloadedNativeLoaded[adLabel] = false;
      return ad;
    }
    return null;
  }

  /// Check if preloaded native ad is ready
  static bool isPreloadedAdReady(String adLabel) {
    return _preloadedNativeLoaded[adLabel] == true &&
        _preloadedNativeAds[adLabel] != null;
  }

  // ========== COMMON VARIABLES ==========
  static final int _adLoadTimeFrequency =
      ADHelper.onboardNativeSecound() * 1000;

  static VoidCallback? onOnboardingNativeAdLoaded;
  static VoidCallback? onLanguageSelectionNativeAdLoaded;

  static void _safeUpdateController(NativeAdScreenType screenType) {
    if (screenType == NativeAdScreenType.onboarding) {
      onOnboardingNativeAdLoaded?.call();
    } else if (screenType == NativeAdScreenType.languageSelection) {
      onLanguageSelectionNativeAdLoaded?.call();
    }
  }

  /// Load native ads with timer
  static Future<void> loadNativeAdsTimer({
    required String adLabel,
    required String screenName,
    required VoidCallback onAdDismissed,
    String factoryId = "nativeAd",
  }) async {
    if (GetPlatform.isIOS) return;
    final screenType = adLabel.contains('onboard')
        ? NativeAdScreenType.onboarding
        : NativeAdScreenType.languageSelection;

    final connected = await ADService.isNetworkConnected();
    if (ADService.isSubscribed() ||
        !connected ||
        !ADService.getAdShowStatus() ||
        ADService.suppressAdsUntilHomeScreen ||
        isNativeLoaded(screenType)) {
      return;
    }

    if (!ADHelper.isAdEnable(adLabel)) {
      return;
    }

    if (screenType == NativeAdScreenType.onboarding) {
      _onboardingAdIds = ADHelper.onboardNativeList()
          .where((e) => e.trim().isNotEmpty)
          .toList();
      if (_onboardingAdIds.isEmpty) return;
    } else {
      _languageSelectionAdIds = ADHelper.languageNativeList()
          .where((e) => e.trim().isNotEmpty)
          .toList();
      if (_languageSelectionAdIds.isEmpty) return;
    }

    _startSequentialLoading(
      adLabel,
      screenName,
      onAdDismissed,
      screenType,
      factoryId: factoryId,
    );
  }

  /// Load native ads immediately
  static Future<void> loadNativeAds({
    required String adLabel,
    required String screenName,
    required VoidCallback onAdDismissed,
    String factoryId = "nativeAd",
  }) async {
    final screenType = adLabel.contains('onboard')
        ? NativeAdScreenType.onboarding
        : NativeAdScreenType.languageSelection;

    final connected = await ADService.isNetworkConnected();
    if (ADService.isSubscribed() ||
        !connected ||
        !ADService.getAdShowStatus() ||
        ADService.suppressAdsUntilHomeScreen ||
        isNativeLoaded(screenType)) {
      return;
    }

    if (!ADHelper.isAdEnable(adLabel)) {
      return;
    }

    if (screenType == NativeAdScreenType.onboarding) {
      _onboardingAdIds = ADHelper.onboardNativeList()
          .where((e) => e.trim().isNotEmpty)
          .toList();
      if (_onboardingAdIds.isEmpty) return;
    } else {
      _languageSelectionAdIds = ADHelper.languageNativeList()
          .where((e) => e.trim().isNotEmpty)
          .toList();
      if (_languageSelectionAdIds.isEmpty) return;
    }

    await _loadAdmobNative(
      adLabel,
      screenName,
      onAdDismissed,
      screenType,
      factoryId: factoryId,
    );
  }

  static void _startSequentialLoading(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
    NativeAdScreenType screenType, {
    String factoryId = "nativeAd",
  }) {
    if (screenType == NativeAdScreenType.onboarding) {
      if (_isOnboardingSequentialLoading) return;
      _isOnboardingSequentialLoading = true;
      _isOnboardingLoadingFailed = false;
      _currentOnboardingIndex = 0;
      _wasOnboardingShownAndDismissed = false;
    } else {
      if (_isLanguageSelectionSequentialLoading) return;
      _isLanguageSelectionSequentialLoading = true;
      _isLanguageSelectionLoadingFailed = false;
      _currentLanguageSelectionIndex = 0;
      _wasLanguageSelectionShownAndDismissed = false;
    }

    _safeUpdateController(screenType);
    _loadNextAdWithTimer(
      adLabel,
      screenName,
      onAdDismissed,
      screenType,
      factoryId: factoryId,
    );
  }

  static void _loadNextAdWithTimer(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
    NativeAdScreenType screenType, {
    String factoryId = "nativeAd",
  }) {
    final adIds = screenType == NativeAdScreenType.onboarding
        ? _onboardingAdIds
        : _languageSelectionAdIds;
    final currentIndex = screenType == NativeAdScreenType.onboarding
        ? _currentOnboardingIndex
        : _currentLanguageSelectionIndex;
    final timer = screenType == NativeAdScreenType.onboarding
        ? _onboardingLoadTimer
        : _languageSelectionLoadTimer;

    if (currentIndex >= adIds.length) {
      timer?.cancel();
      if (screenType == NativeAdScreenType.onboarding) {
        _isOnboardingSequentialLoading = false;
        _isOnboardingLoadingFailed = true;
      } else {
        _isLanguageSelectionSequentialLoading = false;
        _isLanguageSelectionLoadingFailed = true;
      }
      _safeUpdateController(screenType);
      onAdDismissed();
      return;
    }

    _loadAdmobNative(
      adLabel,
      screenName,
      onAdDismissed,
      screenType,
      factoryId: factoryId,
    );

    timer?.cancel();
    final newTimer = Timer(Duration(milliseconds: _adLoadTimeFrequency), () {
      if (ADService.isSubscribed()) {
        timer?.cancel();
        if (screenType == NativeAdScreenType.onboarding) {
          _isOnboardingSequentialLoading = false;
        } else {
          _isLanguageSelectionSequentialLoading = false;
        }
        return;
      }

      final wasShown = screenType == NativeAdScreenType.onboarding
          ? _wasOnboardingShownAndDismissed
          : _wasLanguageSelectionShownAndDismissed;
      final isLoaded = screenType == NativeAdScreenType.onboarding
          ? _isOnboardingLoaded
          : _isLanguageSelectionLoaded;

      if (!wasShown && !isLoaded) {
        if (screenType == NativeAdScreenType.onboarding) {
          _currentOnboardingIndex++;
        } else {
          _currentLanguageSelectionIndex++;
        }
        _loadNextAdWithTimer(
          adLabel,
          screenName,
          onAdDismissed,
          screenType,
          factoryId: factoryId,
        );
      } else {
        timer?.cancel();
        if (screenType == NativeAdScreenType.onboarding) {
          _isOnboardingSequentialLoading = false;
        } else {
          _isLanguageSelectionSequentialLoading = false;
        }
      }
    });

    if (screenType == NativeAdScreenType.onboarding) {
      _onboardingLoadTimer = newTimer;
    } else {
      _languageSelectionLoadTimer = newTimer;
    }
  }

  static Future<void> _loadAdmobNative(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
    NativeAdScreenType screenType, {
    String factoryId = "nativeAd",
  }) async {
    if (ADService.isSubscribed()) {
      return;
    }

    final currentAd = screenType == NativeAdScreenType.onboarding
        ? onboardingNativeAd
        : languageSelectionNativeAd;
    if (currentAd != null) return;

    try {
      final adIds = screenType == NativeAdScreenType.onboarding
          ? _onboardingAdIds
          : _languageSelectionAdIds;
      if (adIds.isEmpty) return;

      final currentIndex = screenType == NativeAdScreenType.onboarding
          ? _currentOnboardingIndex
          : _currentLanguageSelectionIndex;

      final adUnitId = adIds[currentIndex % adIds.length].trim();
      if (adUnitId.isEmpty) return;

      LogEventManager.trackAdRequest(
        adPlatform: 'Admob',
        adUnitId: adUnitId,
        adType: 'native',
      );

      final nativeAd = NativeAd(
        factoryId: factoryId,
        adUnitId: adUnitId,
        nativeAdOptions: NativeAdOptions(
          videoOptions: VideoOptions(
            clickToExpandRequested: true,
            customControlsRequested: true,
            startMuted: false,
          ),
        ),
        listener: NativeAdListener(
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {
            final revenue = valueMicros / 1000000.0;
            LogEventManager.logPaidAdEvent(
              screenName: adLabel,
              revenue: revenue,
              precision: precision.index,
              adUnitId: adUnitId,
              adType: 'native',
              currency: currencyCode,
              adSource:
                  ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
              network: ad.responseInfo?.mediationAdapterClassName,
            );
          },
          onAdLoaded: (ad) {
            if (kDebugMode) {
              debugPrint(
                '[$_tag] 🎯 [AD LOADED] Native Ad | Label: ${screenType.name} | ID: $adUnitId',
              );
            }
            final loadedAd = ad as NativeAd;

            LogEventManager.trackAdMatchedRequest(
              adPlatform: 'Admob',
              adUnitId: adUnitId,
              adType: 'native',
              responseInfo: ad.responseInfo,
            );
            LogEventManager.logNativeAdLoad(adLabel);
            LogEventManager.logNativeAdShow(adLabel);

            if (screenType == NativeAdScreenType.onboarding) {
              onboardingNativeAd = loadedAd;
              _isOnboardingLoaded = true;
              _isOnboardingLoadingFailed = false;
            } else {
              languageSelectionNativeAd = loadedAd;
              _isLanguageSelectionLoaded = true;
              _isLanguageSelectionLoadingFailed = false;
            }

            final timer = screenType == NativeAdScreenType.onboarding
                ? _onboardingLoadTimer
                : _languageSelectionLoadTimer;
            timer?.cancel();

            if (screenType == NativeAdScreenType.onboarding) {
              _isOnboardingSequentialLoading = false;
            } else {
              _isLanguageSelectionSequentialLoading = false;
            }

            _safeUpdateController(screenType);
          },
          onAdClicked: (ad) {
            LogEventManager.logAdClick(
              screenName: adLabel,
              adUnitId: adUnitId,
              adPlatform: 'Admob',
              adFormat: 'native',
              adSource:
                  ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ??
                  'Admob',
              network: ad.responseInfo?.mediationAdapterClassName ?? 'unknown',
            );
            LogEventManager.logNativeAdClick(adLabel);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              disposeNativeAd(screenType);
              if (screenType == NativeAdScreenType.onboarding) {
                _currentOnboardingIndex = (_currentOnboardingIndex + 1) %
                    (_onboardingAdIds.isNotEmpty ? _onboardingAdIds.length : 1);
              } else {
                _currentLanguageSelectionIndex =
                    (_currentLanguageSelectionIndex + 1) %
                        (_languageSelectionAdIds.isNotEmpty
                            ? _languageSelectionAdIds.length
                            : 1);
              }
              _loadAdmobNative(
                adLabel,
                screenName,
                () {},
                screenType,
                factoryId: factoryId,
              );
            });
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              debugPrint(
                '[$_tag] ❌ [AD LOAD FAILED] Native Ad | Label: ${screenType.name} | ID: $adUnitId | Error: ${error.message}',
              );
            }
            LogEventManager.logNativeAdFailToLoad(adLabel, error.message);

            if (screenType == NativeAdScreenType.onboarding) {
              _isOnboardingLoaded = false;
              onboardingNativeAd = null;
            } else {
              _isLanguageSelectionLoaded = false;
              languageSelectionNativeAd = null;
            }

            if (screenType == NativeAdScreenType.onboarding) {
              _currentOnboardingIndex++;
              if (_currentOnboardingIndex < _onboardingAdIds.length) {
                _loadAdmobNative(
                  adLabel,
                  screenName,
                  onAdDismissed,
                  screenType,
                  factoryId: factoryId,
                );
              } else {
                _onboardingLoadTimer?.cancel();
                _isOnboardingSequentialLoading = false;
                _isOnboardingLoadingFailed = true;
                _safeUpdateController(screenType);
              }
            } else {
              _currentLanguageSelectionIndex++;
              if (_currentLanguageSelectionIndex <
                  _languageSelectionAdIds.length) {
                _loadAdmobNative(
                  adLabel,
                  screenName,
                  onAdDismissed,
                  screenType,
                  factoryId: factoryId,
                );
              } else {
                _languageSelectionLoadTimer?.cancel();
                _isLanguageSelectionSequentialLoading = false;
                _isLanguageSelectionLoadingFailed = true;
                _safeUpdateController(screenType);
              }
            }
            ad.dispose();
          },
        ),
        request: ConsentService.getAdRequest(),
      );

      if (screenType == NativeAdScreenType.onboarding) {
        onboardingNativeAd = nativeAd;
      } else {
        languageSelectionNativeAd = nativeAd;
      }

      Future.microtask(() {
        nativeAd.load();
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          "[$_tag] Error loading AdMob ${screenType.name} Native ad: $e",
        );
      }
    }
  }

  static bool isNativeLoaded([NativeAdScreenType? screenType]) {
    if (screenType == null) {
      return _isOnboardingLoaded && onboardingNativeAd != null;
    }

    if (screenType == NativeAdScreenType.onboarding) {
      return _isOnboardingLoaded && onboardingNativeAd != null;
    } else {
      return _isLanguageSelectionLoaded && languageSelectionNativeAd != null;
    }
  }

  static bool isLoading([NativeAdScreenType? screenType]) {
    if (screenType == null) {
      return (_isOnboardingSequentialLoading &&
              !_isOnboardingLoaded &&
              !_isOnboardingLoadingFailed) ||
          (_isLanguageSelectionSequentialLoading &&
              !_isLanguageSelectionLoaded &&
              !_isLanguageSelectionLoadingFailed);
    }

    if (screenType == NativeAdScreenType.onboarding) {
      return _isOnboardingSequentialLoading &&
          !_isOnboardingLoaded &&
          !_isOnboardingLoadingFailed;
    } else {
      return _isLanguageSelectionSequentialLoading &&
          !_isLanguageSelectionLoaded &&
          !_isLanguageSelectionLoadingFailed;
    }
  }

  static bool isLoadingFailed([NativeAdScreenType? screenType]) {
    if (screenType == null) {
      return _isOnboardingLoadingFailed || _isLanguageSelectionLoadingFailed;
    }

    if (screenType == NativeAdScreenType.onboarding) {
      return _isOnboardingLoadingFailed;
    } else {
      return _isLanguageSelectionLoadingFailed;
    }
  }

  static void disposeNativeAd([NativeAdScreenType? screenType]) {
    if (screenType == null || screenType == NativeAdScreenType.onboarding) {
      onboardingNativeAd?.dispose();
      onboardingNativeAd = null;
      _isOnboardingLoaded = false;
      _isOnboardingSequentialLoading = false;
      _onboardingLoadTimer?.cancel();
      onOnboardingNativeAdLoaded?.call();
    }
    if (screenType == null ||
        screenType == NativeAdScreenType.languageSelection) {
      languageSelectionNativeAd?.dispose();
      languageSelectionNativeAd = null;
      _isLanguageSelectionLoaded = false;
      _isLanguageSelectionSequentialLoading = false;
      _languageSelectionLoadTimer?.cancel();
      onLanguageSelectionNativeAdLoaded?.call();
    }
  }
}
