import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../constant/app_strings.dart';
import '../../services/consent_service.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

/// Full-screen splash/onboarding native fallback
class SplashFullNativeAdScreen extends StatefulWidget {
  const SplashFullNativeAdScreen({
    super.key,
    required this.adUnitIds,
    this.preloadedAd,
    this.adLabel = 'splash_full_native',
  });

  final List<String> adUnitIds;
  final NativeAd? preloadedAd;
  final String adLabel;

  @override
  State<SplashFullNativeAdScreen> createState() =>
      _SplashFullNativeAdScreenState();
}

class _SplashFullNativeAdScreenState extends State<SplashFullNativeAdScreen> {
  static const String _tag = 'SplashFullNative';
  static const String _factoryId = 'splashFullNativeAd';

  NativeAd? _nativeAd;
  bool _isLoaded = false;
  int _index = 0;
  var _closed = false;

  bool get _isOnboarding => widget.adLabel.contains('onboarding');

  @override
  void initState() {
    super.initState();
    if (GetPlatform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishAllFailed());
      return;
    }
    if (widget.preloadedAd != null) {
      _nativeAd = widget.preloadedAd;
      _isLoaded = true;
      LogEventManager.logNativeAdShow(widget.adLabel);
      if (!_isOnboarding) {
        LogEventManager.logSplashFullNativeAdShow();
      }
    } else {
      _loadNext();
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _finishSuccess() {
    if (_closed) return;
    _closed = true;
    if (!_isOnboarding) {
      LogEventManager.logSplashFullNativeAdClose();
    }
    Get.back(result: true);
  }

  void _finishAllFailed() {
    if (_closed) return;
    _closed = true;
    Get.back(result: false);
  }

  void _loadNext() {
    if (_index >= widget.adUnitIds.length) {
      _finishAllFailed();
      return;
    }

    final adUnitId = widget.adUnitIds[_index];

    setState(() {
      _isLoaded = false;
    });

    _nativeAd?.dispose();
    _nativeAd = null;

    var settled = false;
    void settleFailAndAdvance() {
      if (settled || _closed) return;
      settled = true;
      _nativeAd?.dispose();
      _nativeAd = null;
      _index++;
      _loadNext();
    }

    if (kDebugMode) {
      debugPrint('[$_tag] Loading native index=$_index id=$adUnitId');
    }

    LogEventManager.trackAdRequest(
      adPlatform: 'Admob',
      adUnitId: adUnitId,
      adType: 'native',
    );

    final ad = NativeAd(
      adUnitId: adUnitId,
      factoryId: _factoryId,
      request: ConsentService.getAdRequest(),
      listener: NativeAdListener(
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          final revenue = valueMicros / 1000000.0;
          LogEventManager.logPaidAdEvent(
            screenName: widget.adLabel,
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
          if (settled || _closed) {
            ad.dispose();
            return;
          }
          settled = true;
          if (kDebugMode) {
            debugPrint('[$_tag] Native loaded index=$_index');
          }

          LogEventManager.trackAdMatchedRequest(
            adPlatform: 'Admob',
            adUnitId: adUnitId,
            adType: 'native',
            responseInfo: ad.responseInfo,
          );
          LogEventManager.logNativeAdLoad(widget.adLabel);
          LogEventManager.logNativeAdShow(widget.adLabel);
          if (!_isOnboarding) {
            LogEventManager.logSplashFullNativeAdLoad();
            LogEventManager.logSplashFullNativeAdShow();
          }

          if (!mounted) return;
          setState(() {
            _nativeAd = ad as NativeAd;
            _isLoaded = true;
          });
        },
        onAdClicked: (ad) {
          LogEventManager.logAdClick(
            screenName: widget.adLabel,
            adUnitId: adUnitId,
            adPlatform: 'Admob',
            adFormat: 'native',
            adSource:
                ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ??
                    'Admob',
            network: ad.responseInfo?.mediationAdapterClassName ?? 'unknown',
          );
          LogEventManager.logNativeAdClick(widget.adLabel);
          if (!_isOnboarding) {
            LogEventManager.logSplashFullNativeAdClick();
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint('[$_tag] Native fail index=$_index: ${error.message}');
          }
          LogEventManager.logNativeAdFailToLoad(widget.adLabel, error.message);
          if (!_isOnboarding) {
            LogEventManager.logSplashFullNativeAdFailToLoad(error.message);
          }
          ad.dispose();
          settleFailAndAdvance();
        },
      ),
    );

    _nativeAd = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _finishSuccess();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity!.abs() > 100) {
            if (_isLoaded) {
              _finishSuccess();
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: CommonText.text(
                          title: AppStrings.ad,
                          color: AppColors.whiteColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (_isLoaded)
                        GestureDetector(
                          onTap: _finishSuccess,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryButtonGradient,
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                            child: CommonText.text(
                              title: AppStrings.next,
                              color: AppColors.whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoaded && _nativeAd != null
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                          child: AdWidget(ad: _nativeAd!),
                        )
                      : const Center(
                          child: SizedBox.shrink(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
