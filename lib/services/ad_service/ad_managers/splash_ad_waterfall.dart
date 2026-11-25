import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../consent_service.dart';
import '../../log_event_manager.dart';
import '../ad_helper.dart';
import '../ad_services.dart';
import '../../../ui/splash/splash_full_native_ad_screen.dart';

/// Splash-only ad waterfall:
/// Interstitial list (per-ID RC timeouts) → App Open list → Full Native list → proceed.
class SplashAdWaterfall {
  SplashAdWaterfall._();

  static const String _tag = 'SplashAdWaterfall';

  /// Runs the full splash waterfall, then invokes [onComplete] exactly once.
  static Future<void> run({required VoidCallback onComplete}) async {
    var completed = false;

    void finish() {
      if (completed) return;
      completed = true;
      ADService.isAppReadyForResumeAds = true;
      ADService.markFullScreenAdDismissed();
      onComplete();
    }

    try {
      if (GetPlatform.isIOS) {
        finish();
        return;
      }
      final connected = await ADService.isNetworkConnected();
      if (ADService.isSubscribed() ||
          !connected ||
          !ADService.getAdShowStatus() ||
          !ADHelper.isAdEnable(ADHelper.splashOpenApp)) {
        finish();
        return;
      }

      // Ensure ATT (iOS) and GDPR consent are resolved and MobileAds is initialized before ad requests
      await ConsentService.handleGDPR();
      await ConsentService.initializeMobileAds();

      final primaryType = ADHelper.getSplashPrimaryType();
      if (kDebugMode) {
        debugPrint('[$_tag] Attempting primary splash ad: $primaryType');
      }

      final primaryShown = await _tryAdFormat(primaryType, onFinished: finish);
      if (primaryShown) {
        if (!primaryType.toLowerCase().contains('native')) {
          finish();
        }
        return;
      }

      // If primary ad failed -> Execute dynamic fallback sequence
      final fallbackAds = ADHelper.getFallbackAds(ADHelper.splashOpenApp);
      if (kDebugMode) {
        debugPrint(
          '[$_tag] Primary ($primaryType) failed -> Running fallback sequence (${fallbackAds.length} fallbacks configured)',
        );
      }

      if (fallbackAds.isNotEmpty) {
        for (final fb in fallbackAds) {
          if (fb.enable == false) continue;
          final fallbackFormat = fb.adsType ?? '';
          if (fallbackFormat.toLowerCase().trim() ==
              primaryType.toLowerCase().trim()) {
            continue;
          }
          if (kDebugMode) {
            debugPrint(
              '[$_tag] Trying fallback format: $fallbackFormat (Priority: ${fb.priority}, Unit ID: ${fb.adUnitId ?? "default"})',
            );
          }
          final fallbackShown = await _tryAdFormat(
            fallbackFormat,
            customAdUnitId: fb.adUnitId,
            isFallback: true,
            onFinished: finish,
          );
          if (fallbackShown) {
            if (!fallbackFormat.toLowerCase().contains('native')) {
              finish();
            }
            return;
          }
        }
      } else {
        // Fallback to configured sequence or standard fallback sequence
        final fallbackSequence = ADHelper.getSplashFallbackSequence();
        if (kDebugMode) {
          debugPrint(
            '[$_tag] Primary ($primaryType) failed -> Using default sequence fallbacks: $fallbackSequence',
          );
        }
        for (final fallbackFormat in fallbackSequence) {
          if (fallbackFormat.toLowerCase().trim() ==
              primaryType.toLowerCase().trim()) {
            continue;
          }
          if (kDebugMode) {
            debugPrint(
              '[$_tag] Trying default fallback format: $fallbackFormat',
            );
          }
          final fallbackShown = await _tryAdFormat(
            fallbackFormat,
            isFallback: true,
            onFinished: finish,
          );
          if (fallbackShown) {
            if (!fallbackFormat.toLowerCase().contains('native')) {
              finish();
            }
            return;
          }
        }
      }

      finish();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$_tag] Splash waterfall error: $e');
      }
      finish();
    }
  }

  // ── Format Dispatcher ───────────────────────────────────────

  static Future<bool> _tryAdFormat(
    String format, {
    String? customAdUnitId,
    bool isFallback = false,
    required VoidCallback onFinished,
  }) async {
    final fmt = format.toLowerCase().trim();
    if (fmt == 'interstitial' || fmt.contains('inter')) {
      if (!isFallback && !ADHelper.isSplashInterEnabled()) return false;
      return await _tryInterstitialWaterfall(customAdUnitId: customAdUnitId);
    } else if (fmt == 'app_open' || fmt == 'open_app' || fmt.contains('open')) {
      if (!isFallback && !ADHelper.isSplashAppOpenEnabled()) return false;
      return await _tryAppOpenWaterfall(customAdUnitId: customAdUnitId);
    } else if (fmt == 'full_native' || fmt == 'native' || fmt.contains('native')) {
      if (!isFallback && !ADHelper.isSplashNativeEnabled()) return false;
      return await _tryNativeWaterfall(
        customAdUnitId: customAdUnitId,
        onFinished: onFinished,
      );
    }
    return false;
  }

  // ── Interstitial ────────────────────────────────────────────

  static Future<bool> _tryInterstitialWaterfall({String? customAdUnitId}) async {
    final ids = (customAdUnitId != null && customAdUnitId.trim().isNotEmpty)
        ? [customAdUnitId.trim()]
        : ADHelper.splashInterstitialList()
            .where((e) => e.trim().isNotEmpty)
            .toList();
    if (ids.isEmpty) return false;

    final timeouts = ADHelper.splashInterTimeoutsSec(ids.length);
    if (kDebugMode) {
      debugPrint(
          '[$_tag] Interstitial waterfall: ${ids.length} IDs, timeouts=$timeouts');
    }

    for (var i = 0; i < ids.length; i++) {
      final shown = await _loadAndShowInterstitial(
        adUnitId: ids[i],
        timeoutSec: timeouts[i],
        index: i,
      );
      if (shown) return true;
    }
    return false;
  }

  static Future<bool> _loadAndShowInterstitial({
    required String adUnitId,
    required int timeoutSec,
    required int index,
  }) {
    final completer = Completer<bool>();
    InterstitialAd? loadedAd;
    var settled = false;
    Timer? timer;

    void settle(bool value) {
      if (settled) return;
      settled = true;
      timer?.cancel();
      if (!value) {
        loadedAd?.dispose();
        loadedAd = null;
      }
      if (!completer.isCompleted) completer.complete(value);
    }

    timer = Timer(Duration(seconds: timeoutSec.clamp(1, 120)), () {
      if (kDebugMode) {
        debugPrint(
            '[$_tag] Interstitial timeout ${timeoutSec}s index=$index id=$adUnitId');
      }
      settle(false);
    });

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
          if (settled) {
            ad.dispose();
            return;
          }
          timer?.cancel();
          loadedAd = ad;
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            LogEventManager.logPaidAdEvent(
              screenName: ADHelper.splashOpenApp,
              revenue: valueMicros / 1000000.0,
              precision: precision.index,
              adUnitId: adUnitId,
              adType: 'interstitial',
              currency: currencyCode,
              adSource:
                  ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
              network: ad.responseInfo?.mediationAdapterClassName,
            );
          };
          LogEventManager.trackAdMatchedRequest(
            adPlatform: 'Admob',
            adUnitId: adUnitId,
            adType: 'interstitial',
            responseInfo: ad.responseInfo,
          );
          LogEventManager.logInterAdLoad(ADHelper.splashOpenApp);
          LogEventManager.logSplashInterstitialLoad();
          if (kDebugMode) {
            debugPrint('[$_tag] Interstitial loaded index=$index');
          }

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (shown) {
              ADService.isInterShowing = true;
              LogEventManager.logInterAdShow(ADHelper.splashOpenApp);
              LogEventManager.logSplashInterstitialShow();
            },
            onAdDismissedFullScreenContent: (shown) {
              ADService.isInterShowing = false;
              LogEventManager.logInterAdClose(ADHelper.splashOpenApp);
              LogEventManager.logSplashInterstitialClose();
              shown.dispose();
              loadedAd = null;
              Future.delayed(const Duration(milliseconds: 250), () {
                settle(true);
              });
            },
            onAdClicked: (shown) {
              LogEventManager.logAdClick(
                screenName: ADHelper.splashOpenApp,
                adUnitId: adUnitId,
                adPlatform: 'Admob',
                adFormat: 'interstitial',
                adSource:
                    ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ??
                        'Admob',
                network:
                    ad.responseInfo?.mediationAdapterClassName ?? 'unknown',
              );
              LogEventManager.logInterAdClick(ADHelper.splashOpenApp);
              LogEventManager.logSplashInterstitialClick();
            },
            onAdFailedToShowFullScreenContent: (shown, error) {
              ADService.isInterShowing = false;
              if (kDebugMode) {
                debugPrint(
                    '[$_tag] Interstitial failed to show: ${error.message}');
              }
              LogEventManager.logInterAdFailToLoad(
                  ADHelper.splashOpenApp, error.message);
              LogEventManager.logSplashInterstitialFailToLoad(error.message);
              shown.dispose();
              loadedAd = null;
              settle(false);
            },
          );

          ADService.isInterShowing = true;
          ad.show();
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint(
                '[$_tag] Interstitial fail index=$index: ${error.message}');
          }
          LogEventManager.logInterAdFailToLoad(
            ADHelper.splashOpenApp,
            error.message,
          );
          LogEventManager.logSplashInterstitialFailToLoad(error.message);
          settle(false);
        },
      ),
    );

    return completer.future;
  }

  // ── App Open ────────────────────────────────────────────────

  static Future<bool> _tryAppOpenWaterfall({String? customAdUnitId}) async {
    final ids = (customAdUnitId != null && customAdUnitId.trim().isNotEmpty)
        ? [customAdUnitId.trim()]
        : ADHelper.splashOpenAppAdList()
            .where((e) => e.trim().isNotEmpty)
            .toList();
    if (ids.isEmpty) return false;

    if (kDebugMode) {
      debugPrint('[$_tag] App Open waterfall: ${ids.length} IDs');
    }

    for (var i = 0; i < ids.length; i++) {
      final shown = await _loadAndShowAppOpen(
        adUnitId: ids[i],
        index: i,
      );
      if (shown) return true;
    }
    return false;
  }

  static Future<bool> _loadAndShowAppOpen({
    required String adUnitId,
    required int index,
  }) {
    final completer = Completer<bool>();
    AppOpenAd? loadedAd;
    var settled = false;
    Timer? timer;

    void settle(bool value) {
      if (settled) return;
      settled = true;
      timer?.cancel();
      if (!value) {
        loadedAd?.dispose();
        loadedAd = null;
      }
      if (!completer.isCompleted) completer.complete(value);
    }

    timer = Timer(const Duration(seconds: 8), () {
      if (kDebugMode) {
        debugPrint('[$_tag] App Open timeout (8s) index=$index id=$adUnitId');
      }
      settle(false);
    });

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
          if (settled) {
            ad.dispose();
            return;
          }
          timer?.cancel();
          loadedAd = ad;
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            final revenue = valueMicros / 1000000.0;
            LogEventManager.logPaidAdEvent(
              screenName: ADHelper.splashOpenApp,
              revenue: revenue,
              precision: precision.index,
              adUnitId: adUnitId,
              adType: 'app_open',
              currency: currencyCode,
              adSource:
                  ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
              network: ad.responseInfo?.mediationAdapterClassName,
            );
          };
          LogEventManager.trackAdMatchedRequest(
            adPlatform: 'Admob',
            adUnitId: adUnitId,
            adType: 'app_open',
            responseInfo: ad.responseInfo,
          );
          LogEventManager.logOpenAdLoad(ADHelper.splashOpenApp);
          LogEventManager.logSplashAppOpenLoad();
          if (kDebugMode) {
            debugPrint('[$_tag] App Open loaded index=$index');
          }

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (shown) {
              ADService.isOpenAdShowing = true;
              LogEventManager.logOpenAdShow(ADHelper.splashOpenApp);
              LogEventManager.logSplashAppOpenShow();
            },
            onAdDismissedFullScreenContent: (shown) {
              ADService.isOpenAdShowing = false;
              LogEventManager.logOpenAdClose(ADHelper.splashOpenApp);
              LogEventManager.logSplashAppOpenClose();
              shown.dispose();
              loadedAd = null;
              Future.delayed(const Duration(milliseconds: 250), () {
                settle(true);
              });
            },
            onAdFailedToShowFullScreenContent: (shown, error) {
              ADService.isOpenAdShowing = false;
              if (kDebugMode) {
                debugPrint('[$_tag] App Open failed to show: ${error.message}');
              }
              LogEventManager.logOpenAdFailToLoad(
                  ADHelper.splashOpenApp, error.message);
              LogEventManager.logSplashAppOpenFailToLoad(error.message);
              shown.dispose();
              loadedAd = null;
              settle(false);
            },
            onAdClicked: (ad) {
              LogEventManager.logAdClick(
                screenName: ADHelper.splashOpenApp,
                adUnitId: adUnitId,
                adPlatform: 'Admob',
                adFormat: 'app_open',
                adSource:
                    ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ??
                        'Admob',
                network:
                    ad.responseInfo?.mediationAdapterClassName ?? 'unknown',
              );
              LogEventManager.logOpenAdClick(ADHelper.splashOpenApp);
              LogEventManager.logSplashAppOpenClick();
            },
          );

          ADService.isOpenAdShowing = true;
          ad.show();
        },
        onAdFailedToLoad: (error) {
          timer?.cancel();
          if (kDebugMode) {
            debugPrint('[$_tag] App Open fail index=$index: ${error.message}');
          }
          LogEventManager.logOpenAdFailToLoad(
              ADHelper.splashOpenApp, error.message);
          LogEventManager.logSplashAppOpenFailToLoad(error.message);
          settle(false);
        },
      ),
    );

    return completer.future;
  }

  // ── Full Native ─────────────────────────────────────────────

  static Future<bool> _tryNativeWaterfall({
    String? customAdUnitId,
    required VoidCallback onFinished,
  }) async {
    final ids = (customAdUnitId != null && customAdUnitId.trim().isNotEmpty)
        ? [customAdUnitId.trim()]
        : ADHelper.splashNativeAdList()
            .where((e) => e.trim().isNotEmpty)
            .toList();
    if (ids.isEmpty) return false;

    if (kDebugMode) {
      debugPrint('[$_tag] Native waterfall: ${ids.length} IDs');
    }

    for (var i = 0; i < ids.length; i++) {
      final adUnitId = ids[i];
      final loadedAd = await _loadNativeAd(adUnitId: adUnitId, index: i);
      if (loadedAd != null) {
        if (kDebugMode) {
          debugPrint(
            '[$_tag] Native Ad loaded successfully (index=$i) -> Opening Full Native Screen',
          );
        }
        final result = await Get.to<bool>(
          () => SplashFullNativeAdScreen(
            adUnitIds: ids,
            preloadedAd: loadedAd,
          ),
          fullscreenDialog: true,
          transition: Transition.noTransition,
          opaque: true,
        );

        if (result == true) {
          onFinished();
          return true;
        }
        return false;
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[$_tag] All Native Ad IDs failed to load. Skipping Full Native Screen.',
      );
    }
    return false;
  }

  static Future<NativeAd?> _loadNativeAd({
    required String adUnitId,
    required int index,
  }) {
    final completer = Completer<NativeAd?>();
    var settled = false;

    void settle(NativeAd? ad) {
      if (settled) return;
      settled = true;
      if (!completer.isCompleted) completer.complete(ad);
    }

    LogEventManager.trackAdRequest(
      adPlatform: 'Admob',
      adUnitId: adUnitId,
      adType: 'native',
    );

    final nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'splashFullNativeAd',
      request: ConsentService.getAdRequest(),
      listener: NativeAdListener(
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          final revenue = valueMicros / 1000000.0;
          LogEventManager.logPaidAdEvent(
            screenName: ADHelper.splashOpenApp,
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
          final loadedNative = ad as NativeAd;
          LogEventManager.trackAdMatchedRequest(
            adPlatform: 'Admob',
            adUnitId: adUnitId,
            adType: 'native',
            responseInfo: ad.responseInfo,
          );
          LogEventManager.logNativeAdLoad('splash_full_native');
          LogEventManager.logSplashFullNativeAdLoad();
          if (kDebugMode) {
            debugPrint('[$_tag] Full Native loaded index=$index');
          }
          settle(loadedNative);
        },
        onAdClicked: (ad) {
          LogEventManager.logAdClick(
            screenName: ADHelper.splashOpenApp,
            adUnitId: adUnitId,
            adPlatform: 'Admob',
            adFormat: 'native',
            adSource:
                ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ??
                    'Admob',
            network: ad.responseInfo?.mediationAdapterClassName ?? 'unknown',
          );
          LogEventManager.logNativeAdClick('splash_full_native');
          LogEventManager.logSplashFullNativeAdClick();
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint(
              '[$_tag] Full Native load failed index=$index: ${error.message}',
            );
          }
          LogEventManager.logNativeAdFailToLoad(
            'splash_full_native',
            error.message,
          );
          LogEventManager.logSplashFullNativeAdFailToLoad(error.message);
          ad.dispose();
          settle(null);
        },
      ),
    );

    nativeAd.load();

    return completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () {
        if (kDebugMode) {
          debugPrint('[$_tag] Native ad load timeout (6s) for index=$index');
        }
        nativeAd.dispose();
        return null;
      },
    );
  }
}
