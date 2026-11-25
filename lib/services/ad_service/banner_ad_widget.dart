import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

import '../consent_service.dart';
import '../log_event_manager.dart';
import '../../theme/app_colors.dart';
import 'ad_helper.dart';
import 'ad_services.dart';
import 'ad_visibility_mixin.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, required this.adLabel});
  final String adLabel;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AdVisibilityMixin<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isFailToLoad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoad();
    });
  }

  Future<void> _checkAndLoad() async {
    final connected = await ADService.isNetworkConnected();
    final isShowAds = ADService.getAdShowStatus();
    final isEnabled = ADHelper.isAdEnable(widget.adLabel);

    if (connected && isShowAds && isEnabled) {
      _loadAd();
    } else {
      if (mounted) {
        setState(() {
          _isFailToLoad = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isShowAds = ADService.getAdShowStatus();
    if (!isShowAds || !ADHelper.isAdEnable(widget.adLabel) || _isFailToLoad) {
      return const SizedBox.shrink();
    }
    if (_isLoading) {
      return shimmerWidget();
    }
    if (_isLoaded && _bannerAd != null) {
      final margin = EdgeInsets.symmetric(vertical: 4.h);
      return Container(
        alignment: Alignment.center,
        margin: margin,
        height: _bannerAd!.size.height.toDouble(),
        width: double.infinity,
        child: AdWidget(key: ObjectKey(_bannerAd), ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }

  /// [attemptIndex] walks the banner ID list: ID 1 fails -> ID 2 -> ...
  Future<void> _loadAd([int attemptIndex = 0]) async {
    if (!mounted) return;
    if (!ADHelper.isAdEnable(widget.adLabel)) {
      _refreshTimer?.cancel();
      cancelAdVisibilityWait();
      return;
    }
    if (attemptIndex == 0) {
      final old = _bannerAd;
      setState(() {
        _bannerAd = null;
        _isLoaded = false;
        _isLoading = true;
      });
      // Dispose only after the shimmer frame has removed the old AdWidget.
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }

    final bannerType = ADHelper.getBannerType(widget.adLabel);
    final screenWidth = MediaQuery.sizeOf(context).width.truncate();
    AdSize finalSize;

    if (bannerType == 'standard' || bannerType == 'banner') {
      finalSize = AdSize.banner; // 320x50
    } else if (bannerType == 'large' || bannerType == 'large_banner') {
      finalSize = AdSize.largeBanner; // 320x100
    } else if (bannerType == 'medium_rectangle' || bannerType == 'mrec') {
      finalSize = AdSize.mediumRectangle; // 300x250
    } else {
      // Default: adaptive banner
      final width = screenWidth > 0 ? screenWidth : 320;
      AnchoredAdaptiveBannerAdSize? adaptiveSize;
      try {
        adaptiveSize =
            // ignore: deprecated_member_use
            await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
                width);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error calculating banner ad size: $e');
        }
      }
      finalSize = adaptiveSize ?? AdSize.banner;
    }
    if (!mounted || !ADHelper.isAdEnable(widget.adLabel)) return;

    final adUnitIds = ADHelper.bannerAdIds(widget.adLabel);
    if (attemptIndex >= adUnitIds.length) {
      if (kDebugMode) {
        debugPrint(
          '🚫 [BannerAdWidget] No more banner IDs for ${widget.adLabel} (tried $attemptIndex).',
        );
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFailToLoad = true;
        });
      }
      return;
    }
    final adUnitId = adUnitIds[attemptIndex];

    LogEventManager.trackAdRequest(
      adPlatform: 'Admob',
      adUnitId: adUnitId,
      adType: 'banner',
    );

    final isCollapsible = bannerType.contains('collapsible') ||
        ADHelper.getAdType(widget.adLabel)
            .toLowerCase()
            .contains('collapsible');

    final adRequest = isCollapsible
        ? (ConsentService.shouldUseNonPersonalizedAds()
            ? const AdRequest(extras: {'collapsible': 'bottom', 'npa': '1'})
            : const AdRequest(extras: {'collapsible': 'bottom'}))
        : ConsentService.getAdRequest();

    final banner = BannerAd(
      size: finalSize,
      adUnitId: adUnitId,
      request: adRequest,
      listener: BannerAdListener(
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          final revenue = valueMicros / 1000000.0;
          LogEventManager.logPaidAdEvent(
            screenName: widget.adLabel,
            revenue: revenue,
            precision: precision.index,
            adUnitId: adUnitId,
            adType: 'banner',
            currency: currencyCode,
            adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
            network: ad.responseInfo?.mediationAdapterClassName,
          );
        },
        onAdLoaded: (ad) {
          if (!mounted || ADService.isSubscribed()) {
            ad.dispose();
            return;
          }
          LogEventManager.trackAdMatchedRequest(
            adPlatform: 'Admob',
            adUnitId: adUnitId,
            adType: 'banner',
            responseInfo: ad.responseInfo,
          );
          LogEventManager.logBannerAdLoad(widget.adLabel);
          LogEventManager.logBannerAdShow(widget.adLabel);
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoading = false;
            _isLoaded = true;
          });
          _scheduleAutoRefresh();
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint('Banner ad failed to load ($adUnitId): $error');
          }
          ad.dispose();
          LogEventManager.logBannerAdFailToLoad(widget.adLabel, error.message);
          if (!mounted) return;
          if (attemptIndex + 1 < ADHelper.bannerAdIds(widget.adLabel).length) {
            _loadAd(attemptIndex + 1);
            return;
          }
          setState(() {
            _isLoading = false;
            _isLoaded = false;
            _isFailToLoad = true;
          });
        },
        onAdClicked: (ad) {
          LogEventManager.logAdClick(
            screenName: widget.adLabel,
            adUnitId: adUnitId,
            adPlatform: 'Admob',
            adFormat: 'banner',
            adSource:
                ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName ??
                    'Admob',
            network: ad.responseInfo?.mediationAdapterClassName ?? 'unknown',
          );
          LogEventManager.logBannerAdClick(widget.adLabel);
        },
      ),
    );
    banner.load();
  }

  Timer? _refreshTimer;

  void _scheduleAutoRefresh() {
    _refreshTimer?.cancel();
    cancelAdVisibilityWait();
    if (!ADHelper.isAutoRefreshEnabled(widget.adLabel)) return;
    final intervalSec = ADHelper.getRefreshIntervalSec(widget.adLabel);
    if (intervalSec <= 0) return;
    _refreshTimer = Timer(Duration(seconds: intervalSec), () {
      if (!mounted) return;
      // Background / covered by another screen / scrolled away: hold the
      // refresh until the banner is on screen again instead of wasting a request.
      runWhenAdVisible(_loadAd);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  Widget shimmerWidget() {
    final margin = EdgeInsets.symmetric(vertical: 4.h);

    final bannerType = ADHelper.getBannerType(widget.adLabel);
    double height = 60.h;
    if (bannerType == 'large' || bannerType == 'large_banner') {
      height = 100.h;
    } else if (bannerType == 'medium_rectangle' || bannerType == 'mrec') {
      height = 250.h;
    }

    return Container(
      height: height,
      margin: margin,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Row(
          children: [
            Container(
              height: 40.h,
              width: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 10.h,
                    width: 140.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    height: 8.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 32.h,
              width: 80.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
