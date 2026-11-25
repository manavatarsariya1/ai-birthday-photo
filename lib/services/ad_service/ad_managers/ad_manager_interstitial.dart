import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

import '../../consent_service.dart';
import '../../log_event_manager.dart';
import '../ad_helper.dart';
import '../ad_services.dart';

enum AdType { banner, interstitial, native, rewarded, openApp }

class AdManagerInterstitial {
  static const String _tag = "AdManagerInterstitial";

  // AdMob Interstitial ad instance
  static InterstitialAd? _admobInterstitialAd;
  static bool _isAdmobLoaded = false;
  static bool _isShowing = false;
  static bool isInterLoaded = false;

  // Timer for ad loading
  static Timer? _loadTimer;
  static final int _adLoadTimeFrequency =
      ADHelper.splashInterstitialSecound() * 1000;
  static final int _nativeAdLoadTimeFrequency =
      ADHelper.onboardNativeSecound() * 1000;

  // Ad ID lists for sequential loading
  static List<String> _admobAdIds = [];

  // Current loading index for AdMob
  static int _currentAdmobIndex = 0;

  // Track if we're in the sequential loading process
  static bool _isSequentialLoading = false;

  // Track if ad was shown and dismissed
  static bool _wasAdShownAndDismissed = false;

  // Track if native fallback is enabled
  static bool nativeFallbackEnabled = false;

  // Native ad variables
  static NativeAd? admobNativeAd;
  static bool _isNativeLoaded = false;
  static bool _wasNativeAdShownAndDismissed = false;
  static Timer? _nativeLoadTimer;
  static List<String> _nativeAdIds = [];
  static int _currentNativeIndex = 0;

  /// Load interstitial ads with timer
  static Future<void> loadInterstitialAdsTimer({
    required String adLabel,
    required String screenName,
    required VoidCallback onAdDismissed,
  }) async {
    if (GetPlatform.isIOS) {
      onAdDismissed();
      return;
    }
    if (kDebugMode) {
      debugPrint("[$_tag] Loading interstitial ads with timer for: $adLabel");
    }
    final connected = await ADService.isNetworkConnected();
    if (ADService.isSubscribed() ||
        !connected ||
        !ADService.getAdShowStatus() ||
        ADService.suppressAdsUntilHomeScreen ||
        isInterstitialLoaded()) {
      onAdDismissed();
      return;
    }
    if (!ADHelper.isAdEnable(adLabel)) {
      if (kDebugMode) {
        debugPrint("[$_tag] Ad is not enabled: $adLabel");
      }
      onAdDismissed();
      return;
    }
    _admobAdIds = ADHelper.splashInterstitialList()
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (_admobAdIds.isEmpty) {
      if (kDebugMode) {
        debugPrint("[$_tag] No valid interstitial ad IDs found. Skipping.");
      }
      onAdDismissed();
      return;
    }
    _startSequentialLoading(adLabel, screenName, onAdDismissed);
  }

  /// Start sequential loading process with intervals
  static void _startSequentialLoading(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
  ) {
    if (_isSequentialLoading) return;
    _isSequentialLoading = true;
    _currentAdmobIndex = 0;
    _wasAdShownAndDismissed = false;
    if (kDebugMode) {
      debugPrint("[$_tag] Starting sequential loading process");
    }
    _loadNextAdWithTimer(adLabel, screenName, onAdDismissed);
  }

  /// Load next ad with timer
  static void _loadNextAdWithTimer(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
  ) {
    if (_admobAdIds.isEmpty || _currentAdmobIndex >= _admobAdIds.length) {
      if (kDebugMode) {
        debugPrint(
          "[$_tag] All interstitial ad IDs exhausted in sequential loading",
        );
      }
      _isSequentialLoading = false;
      if (nativeFallbackEnabled) {
        if (kDebugMode) {
          debugPrint("[$_tag] Starting native ad fallback automatically");
        }
        startNativeAdFallback(adLabel, screenName, onAdDismissed);
      } else {
        onAdDismissed();
      }
      return;
    }
    final adUnitId = _admobAdIds[_currentAdmobIndex];
    if (kDebugMode) {
      debugPrint(
        "[$_tag] Loading ad ID ${_currentAdmobIndex + 1}/${_admobAdIds.length}: $adUnitId",
      );
    }
    _loadAdmobInterstitial(adLabel, screenName, onAdDismissed);
    _loadTimer?.cancel();
    _loadTimer = Timer(Duration(milliseconds: _adLoadTimeFrequency), () {
      if (!_wasAdShownAndDismissed) {
        if (kDebugMode) {
          debugPrint(
            "[$_tag] Splash interstitial timer reached (${_adLoadTimeFrequency}ms). Proceeding without ad.",
          );
        }
        _isSequentialLoading = false;
        _loadTimer?.cancel();
        onAdDismissed();
      }
    });
  }

  /// Load AdMob interstitial ad
  static Future<void> _loadAdmobInterstitial(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
  ) async {
    if (ADService.isSubscribed()) {
      if (kDebugMode) {
        debugPrint("[$_tag] User has subscription, skipping ad load");
      }
      onAdDismissed();
      return;
    }
    if (_admobInterstitialAd != null) return;
    try {
      if (_admobAdIds.isEmpty) {
        onAdDismissed();
        return;
      }
      final adUnitId = _admobAdIds[_currentAdmobIndex % _admobAdIds.length].trim();
      if (adUnitId.isEmpty) {
        onAdDismissed();
        return;
      }
      LogEventManager.trackAdRequest(
        adPlatform: 'Admob',
        adUnitId: adUnitId,
        adType: 'interstitial',
      );
      Future.microtask(() async {
        await InterstitialAd.load(
          adUnitId: adUnitId,
          request: ConsentService.getAdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) async {
              if (kDebugMode) {
                debugPrint(
                  '🎯 [AD LOADED] Interstitial Ad | Label: $adLabel | Index: $_currentAdmobIndex | ID: $adUnitId',
                );
              }
              LogEventManager.trackAdMatchedRequest(
                adPlatform: 'Admob',
                adUnitId: adUnitId,
                adType: 'interstitial',
                responseInfo: ad.responseInfo,
              );
              LogEventManager.logInterAdLoad(adLabel);
              if (adLabel.toLowerCase().contains('splash')) {
                LogEventManager.logSplashInterstitialLoad();
              }
              _loadTimer?.cancel();
              _loadTimer = null;
              _admobInterstitialAd = ad;
              _isAdmobLoaded = true;
              isInterLoaded = true;
              showInterstitialAd(
                adLabel: adLabel,
                screenName: screenName,
                onAdDismissed: onAdDismissed,
                onAdFailed: onAdDismissed,
              );
            },
            onAdFailedToLoad: (error) {
              if (kDebugMode) {
                debugPrint(
                  '❌ [AD LOAD FAILED] Interstitial Ad | Label: $adLabel | Index: $_currentAdmobIndex | ID: $adUnitId | Error: ${error.message}',
                );
              }
              LogEventManager.logInterAdFailToLoad(adLabel, error.message);
              _isAdmobLoaded = false;
              _admobInterstitialAd = null;

              _currentAdmobIndex++;
              if (_currentAdmobIndex < _admobAdIds.length) {
                if (kDebugMode) {
                  debugPrint("[$_tag] Trying next interstitial ad ID immediately");
                }
                _loadAdmobInterstitial(adLabel, screenName, onAdDismissed);
              } else {
                if (kDebugMode) {
                  debugPrint(
                    "[$_tag] All interstitial ad IDs failed to load. Triggering fallback/dismissed.",
                  );
                }
                _loadTimer?.cancel();
                if (nativeFallbackEnabled) {
                  startNativeAdFallback(adLabel, screenName, onAdDismissed);
                } else {
                  _isSequentialLoading = false;
                  onAdDismissed();
                }
              }
            },
          ),
        );
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("[$_tag] Error loading AdMob Interstitial: $e");
      }
      if (!_isSequentialLoading) {
        _currentAdmobIndex++;
        if (_currentAdmobIndex < _admobAdIds.length) {
          _loadAdmobInterstitial(adLabel, screenName, onAdDismissed);
        } else {
          if (kDebugMode) {
            debugPrint("[$_tag] All AdMob interstitial ad IDs failed to load");
          }
          onAdDismissed();
        }
      }
    }
  }

  static void startNativeAdFallback(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
  ) {
    if (kDebugMode) {
      debugPrint(
        "[$_tag] Starting native ad fallback after interstitial ads exhausted",
      );
    }
    _startNativeSequentialLoading(adLabel, screenName, onAdDismissed);
  }

  static void _startNativeSequentialLoading(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
  ) {
    if (kDebugMode) {
      debugPrint("[$_tag] Starting native sequential loading process");
    }
    _nativeAdIds = ADHelper.onboardNativeList();
    _loadNextNativeAdWithTimer(adLabel, screenName, onAdDismissed);
  }

  static void _loadNextNativeAdWithTimer(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
  ) {
    if (_currentNativeIndex >= _nativeAdIds.length) {
      if (kDebugMode) {
        debugPrint("[$_tag] All native ad IDs exhausted in sequential loading");
      }
      _nativeLoadTimer?.cancel();
      _isSequentialLoading = false;
      onAdDismissed();
      return;
    }
    final adUnitId = _nativeAdIds[_currentNativeIndex];
    if (kDebugMode) {
      debugPrint(
        "[$_tag] Loading native ad ID ${_currentNativeIndex + 1}/${_nativeAdIds.length}: $adUnitId",
      );
    }
    _loadAdmobNative(adLabel, screenName, onAdDismissed);
    _nativeLoadTimer?.cancel();
    _nativeLoadTimer = Timer(
      Duration(milliseconds: _nativeAdLoadTimeFrequency),
      () {
        if (ADService.isSubscribed()) {
          if (kDebugMode) {
            debugPrint(
              "[$_tag] User has subscription, stopping native sequential loading",
            );
          }
          _nativeLoadTimer?.cancel();
          _isSequentialLoading = false;
          onAdDismissed();
          return;
        }
        if (!_wasNativeAdShownAndDismissed && !_isNativeLoaded) {
          if (kDebugMode) {
            debugPrint("[$_tag] Time passed, trying next native ad ID");
          }
          _currentNativeIndex++;
          _loadNextNativeAdWithTimer(adLabel, screenName, onAdDismissed);
        } else {
          if (kDebugMode) {
            debugPrint(
              "[$_tag] Native ad was shown and dismissed or loaded, stopping sequential loading",
            );
          }
          _nativeLoadTimer?.cancel();
          _isSequentialLoading = false;
        }
      },
    );
  }

  static Future<void> _loadAdmobNative(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
  ) async {
    if (ADService.isSubscribed()) {
      if (kDebugMode) {
        debugPrint("[$_tag] User has subscription, skipping native ad load");
      }
      onAdDismissed();
      return;
    }
    if (admobNativeAd != null) return;
    try {
      final adUnitId = _nativeAdIds[_currentNativeIndex % _nativeAdIds.length];
      LogEventManager.trackAdRequest(
        adPlatform: 'Admob',
        adUnitId: adUnitId,
        adType: 'native',
      );
      admobNativeAd = NativeAd(
        factoryId: "nativeAdMain",
        adUnitId: adUnitId,
        request: ConsentService.getAdRequest(),
        listener: NativeAdListener(
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {
            final revenue = valueMicros / 1000000.0;
            LogEventManager.logPaidAdEvent(
              screenName: screenName,
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
            if (kDebugMode) {
              debugPrint(
                '🎯 [AD LOADED] Native Ad | Label: $screenName | ID: $adUnitId',
              );
            }
            admobNativeAd = ad as NativeAd;
            _isNativeLoaded = true;
            _wasNativeAdShownAndDismissed = true;
            _nativeLoadTimer?.cancel();
            _isSequentialLoading = false;
            LogEventManager.trackAdMatchedRequest(
              adPlatform: 'Admob',
              adUnitId: adUnitId,
              adType: 'native',
              responseInfo: ad.responseInfo,
            );
            onAdDismissed();
          },
          onAdClicked: (ad) {
            if (kDebugMode) {
              debugPrint('[$_tag] Native ad clicked: $screenName');
            }
            _wasNativeAdShownAndDismissed = true;
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              debugPrint(
                '❌ [AD LOAD FAILED] Native Ad | Label: $screenName | ID: $adUnitId | Error: ${error.message}',
              );
            }
            _isNativeLoaded = false;
            admobNativeAd = null;

            _currentNativeIndex++;
            if (_currentNativeIndex < _nativeAdIds.length) {
              if (kDebugMode) {
                debugPrint("[$_tag] Trying next native ad ID immediately");
              }
              _loadAdmobNative(adLabel, screenName, onAdDismissed);
            } else {
              if (kDebugMode) {
                debugPrint(
                  "[$_tag] All native ad IDs failed to load. Invoking completion.",
                );
              }
              _nativeLoadTimer?.cancel();
              _isSequentialLoading = false;
              onAdDismissed();
            }
          },
        ),
      );
      Future.microtask(() {
        admobNativeAd?.load();
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("[$_tag] Error loading AdMob Native ad: $e");
      }
      _currentNativeIndex++;
      if (_currentNativeIndex < _nativeAdIds.length) {
        _loadAdmobNative(adLabel, screenName, onAdDismissed);
      } else {
        if (kDebugMode) {
          debugPrint("[$_tag] All AdMob native ad IDs failed to load");
        }
        _nativeLoadTimer?.cancel();
        _isSequentialLoading = false;
        onAdDismissed();
      }
    }
  }

  static Future<void> showInterstitialAd({
    required String adLabel,
    required String screenName,
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailed,
  }) async {
    final connected = await ADService.isNetworkConnected();
    if (ADService.isSubscribed() ||
        !connected ||
        !ADService.getAdShowStatus() ||
        _isShowing) {
      onAdDismissed();
      return;
    }
    if (_admobInterstitialAd != null && _isAdmobLoaded) {
      await _showAdmobInterstitial(
        adLabel,
        screenName,
        onAdDismissed,
        onAdFailed,
      );
    } else {
      onAdFailed();
    }
  }

  static Future<void> _showAdmobInterstitial(
    String adLabel,
    String screenName,
    VoidCallback onAdDismissed,
    VoidCallback onAdFailed,
  ) async {
    if (_admobInterstitialAd == null || !_isAdmobLoaded) {
      onAdFailed();
      return;
    }

    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      if (kDebugMode) {
        debugPrint(
          "[$_tag] App is in background ($lifecycle). Skipping interstitial show.",
        );
      }
      onAdFailed();
      return;
    }

    ADService.showLoadingDialog();

    _isShowing = true;
    ADService.isInterShowing = true;
    ADService.isFullScreenAdShowing = true;
    _admobInterstitialAd!.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
      final revenue = valueMicros / 1000000.0;
      LogEventManager.logPaidAdEvent(
        revenue: revenue,
        currency: currencyCode,
        precision: precision.index,
        adUnitId: ad.adUnitId,
        adType: 'interstitial',
        screenName: adLabel,
        adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
        network: ad.responseInfo?.mediationAdapterClassName,
      );
    };
    _admobInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        ADService.dismissLoadingDialog();
        if (kDebugMode) {
          debugPrint("[$_tag] AdMob Interstitial ad showed");
        }
        ADService.isInterShowing = true;
        ADService.isFullScreenAdShowing = true;
        ADService.markInterstitialShown();
        LogEventManager.logInterAdShow(adLabel);
        if (adLabel.toLowerCase().contains('splash')) {
          LogEventManager.logSplashInterstitialShow();
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        ADService.dismissLoadingDialog();
        if (kDebugMode) {
          debugPrint("[$_tag] AdMob Interstitial ad dismissed");
        }
        LogEventManager.logInterAdClose(adLabel);
        if (adLabel.toLowerCase().contains('splash')) {
          LogEventManager.logSplashInterstitialClose();
        }
        _isShowing = false;
        ADService.isInterShowing = false;
        ADService.isFullScreenAdShowing = false;
        ADService.markInterstitialShown();
        ADService.markFullScreenAdDismissed();
        _isAdmobLoaded = false;
        _admobInterstitialAd = null;
        _wasAdShownAndDismissed = true;
        _isSequentialLoading = false;
        _loadTimer?.cancel();
        Future.delayed(const Duration(milliseconds: 250), () {
          onAdDismissed();
        });
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ADService.dismissLoadingDialog();
        if (kDebugMode) {
          debugPrint(
            "[$_tag] AdMob Interstitial ad failed to show: ${error.message}",
          );
        }
        if (adLabel.toLowerCase().contains('splash')) {
          LogEventManager.logSplashInterstitialFailToLoad(error.message);
        }
        _isShowing = false;
        ADService.isInterShowing = false;
        ADService.isFullScreenAdShowing = false;
        ADService.markFullScreenAdDismissed();
        _isAdmobLoaded = false;
        _isSequentialLoading = false;
        _loadTimer?.cancel();
        Future.delayed(const Duration(milliseconds: 250), () {
          onAdFailed();
        });
      },
      onAdClicked: (ad) {
        if (kDebugMode) {
          debugPrint('[$_tag] Interstitial clicked: $adLabel');
        }
        LogEventManager.logAdClick(
          screenName: adLabel,
          adUnitId: ad.adUnitId,
          adPlatform: 'Admob',
          adFormat: 'interstitial',
          adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ?? 'Admob',
          network: ad.responseInfo?.mediationAdapterClassName ?? 'unknown',
        );
      },
    );
    await _admobInterstitialAd!.show();
  }

  static void disposeInterstitial() {
    _admobInterstitialAd?.dispose();
    _admobInterstitialAd = null;
    _isAdmobLoaded = false;
    _isShowing = false;
    _loadTimer?.cancel();
    _isSequentialLoading = false;
    _wasAdShownAndDismissed = false;
    _currentAdmobIndex = 0;
  }

  static bool isInterstitialLoaded() {
    return _isAdmobLoaded && _admobInterstitialAd != null;
  }

  static bool isNativeAdAvailable() {
    return _isNativeLoaded && admobNativeAd != null;
  }
}
