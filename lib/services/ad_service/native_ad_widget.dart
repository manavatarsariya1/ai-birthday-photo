import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../consent_service.dart';
import '../log_event_manager.dart';
import 'ad_helper.dart';
import 'ad_managers/ad_manager_native.dart';
import 'ad_services.dart';
import 'ad_visibility_mixin.dart';

enum NativeAdVariant {
  small,
  medium,
  large,
  mediaSquare,
  exit,
  languageLargeMedia,
}

enum NativeTemplateType { small, medium }

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({
    super.key,
    required this.adLabel,
    this.height = 150,
    this.templateType = NativeTemplateType.small,
    this.variant,
    this.topSpacer,
    this.onAdLoadedStatus,
  });

  final String adLabel;
  final double height;
  final NativeTemplateType templateType;
  final NativeAdVariant? variant;
  final Widget? topSpacer;
  final ValueChanged<bool>? onAdLoadedStatus;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget>
    with AdVisibilityMixin<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isFailToLoad = false;
  bool _shouldShowAd = false;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    final isEnable = ADHelper.isAdEnable(widget.adLabel);
    _shouldShowAd = isEnable;
    _isLoading = isEnable;
    _checkAdConditions();
  }

  @override
  void didUpdateWidget(covariant NativeAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adLabel != widget.adLabel) {
      _nativeAd?.dispose();
      _nativeAd = null;
      _isLoaded = false;
      _isLoading = false;
      _isFailToLoad = false;
      _checkAdConditions();
    }
  }

  void _safeSetState() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _cancelCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  Future<void> _checkAdConditions() async {
    _cancelCooldownTimer();
    final connected = await ADService.isNetworkConnected();
    if (!connected ||
        !ADService.getAdShowStatus() ||
        ADService.suppressAdsUntilHomeScreen) {
      _shouldShowAd = false;
      _isLoading = false;
      _isFailToLoad = true;
      widget.onAdLoadedStatus?.call(false);
      _safeSetState();
      return;
    }

    final isAdEnable = ADHelper.isAdEnable(widget.adLabel);
    if (isAdEnable) {
      _shouldShowAd = true;
      final preloaded = AdManagerNative.consumePreloadedAd(widget.adLabel);
      if (preloaded != null) {
        if (kDebugMode) {
          debugPrint(
            '🎯 [PRELOAD CONSUMED] Native Ad for ${widget.adLabel}',
          );
        }
        _nativeAd = preloaded;
        _isLoaded = true;
        _isLoading = false;
        _isFailToLoad = false;
        AdManagerNative.registerAdClickListener(
          widget.adLabel,
          _onPreloadedAdClicked,
        );
        widget.onAdLoadedStatus?.call(true);
        LogEventManager.logNativeAdShow(widget.adLabel);
        _dispatchDedicatedAdShow();
        if (ADService.isNativeTimerModeEnabled()) {
          ADService.markNativeAdShown();
        }
        _scheduleAutoRefresh();
        _safeSetState();
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadAd();
        }
      });
    } else {
      _shouldShowAd = false;
      _isLoading = false;
      _isFailToLoad = true;
      widget.onAdLoadedStatus?.call(false);
      _safeSetState();
    }
  }

  void _dispatchDedicatedAdLoad() =>
      LogEventManager.logDedicatedNativeAdLoad(widget.adLabel);

  void _dispatchDedicatedAdShow() =>
      LogEventManager.logDedicatedNativeAdShow(widget.adLabel);

  void _dispatchDedicatedAdClick() =>
      LogEventManager.logDedicatedNativeAdClick(widget.adLabel);

  void _dispatchDedicatedAdFail(String error) =>
      LogEventManager.logDedicatedNativeAdFail(widget.adLabel, error);

  NativeAdVariant get _resolvedVariant {
    final remoteLayout =
        ADHelper.getNativeLayout(widget.adLabel).toLowerCase().trim();
    if (remoteLayout == 'large' || remoteLayout == 'big') {
      return NativeAdVariant.large;
    } else if (remoteLayout == 'languagelargemedia' ||
        remoteLayout == 'language_large_media' ||
        remoteLayout == 'large_media') {
      return NativeAdVariant.languageLargeMedia;
    } else if (remoteLayout == 'medium') {
      return NativeAdVariant.medium;
    } else if (remoteLayout == 'small' || remoteLayout == 'listtile') {
      return NativeAdVariant.small;
    } else if (remoteLayout == 'mediasquare' ||
        remoteLayout == 'media_square') {
      return NativeAdVariant.mediaSquare;
    } else if (remoteLayout == 'exit') {
      return NativeAdVariant.exit;
    }
    if (widget.variant != null) {
      return widget.variant!;
    }
    return widget.templateType == NativeTemplateType.medium
        ? NativeAdVariant.medium
        : NativeAdVariant.small;
  }

  void _onPreloadedAdClicked() {
    // The click opens the browser / store, so the new ad is requested only once
    // the user is back and the ad is visible again.
    if (mounted && ADHelper.isClickAfterRefreshEnabled(widget.adLabel)) {
      _cancelAutoRefreshTimer();
      runWhenAdVisible(() => _refreshAd(0));
    }
  }

  void _refreshAd([int attemptIndex = 0]) {
    _cancelCooldownTimer();
    _cancelAutoRefreshTimer();
    if (!mounted) return;
    _nativeAd?.dispose();
    _nativeAd = null;
    _isLoaded = false;
    _isLoading = false;
    _isFailToLoad = false;
    setState(() {});
    _loadAd(attemptIndex);
  }

  Future<void> _loadAd([int attemptIndex = 0]) async {
    if (!mounted || _isLoaded || _nativeAd != null) return;
    // Auto-refresh / click-refresh must stop once the user goes premium or
    // the placement is disabled in Remote Config.
    if (!ADHelper.isAdEnable(widget.adLabel)) {
      _cancelAutoRefreshTimer();
      _isLoading = false;
      _isFailToLoad = true;
      widget.onAdLoadedStatus?.call(false);
      _safeSetState();
      return;
    }
    final preloaded = AdManagerNative.consumePreloadedAd(widget.adLabel);
    if (preloaded != null) {
      _nativeAd = preloaded;
      _isLoaded = true;
      _isLoading = false;
      _isFailToLoad = false;
      AdManagerNative.registerAdClickListener(
        widget.adLabel,
        _onPreloadedAdClicked,
      );
      widget.onAdLoadedStatus?.call(true);
      LogEventManager.logNativeAdShow(widget.adLabel);
      _dispatchDedicatedAdShow();
      if (ADService.isNativeTimerModeEnabled()) {
        ADService.markNativeAdShown();
      }
      _scheduleAutoRefresh();
      if (mounted) setState(() {});
      return;
    }
    _isLoading = true;
    if (mounted) {
      setState(() {});
    }
    try {
      final adIds = ADHelper.nativeAdIdsForLabel(widget.adLabel)
          .where((e) => e.trim().isNotEmpty)
          .toList();
      final adUnitId = adIds.isNotEmpty
          ? adIds[attemptIndex % adIds.length].trim()
          : ADHelper.nativeAdID(widget.adLabel).trim();

      if (adUnitId.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '🚫 [NativeAdWidget] Empty adUnitId for ${widget.adLabel}. Skipping load.',
          );
        }
        _isLoading = false;
        _isLoaded = false;
        _isFailToLoad = true;
        widget.onAdLoadedStatus?.call(false);
        _safeSetState();
        return;
      }

      final v = _resolvedVariant;
      final String factoryId;
      if (v == NativeAdVariant.mediaSquare) {
        factoryId = "nativeAdMediaSquare";
      } else if (v == NativeAdVariant.languageLargeMedia) {
        factoryId = "nativeAdLanguageLargeMedia";
      } else if (v == NativeAdVariant.large) {
        factoryId = "nativeAdMain";
      } else if (v == NativeAdVariant.medium) {
        factoryId = "nativeAd";
      } else if (v == NativeAdVariant.exit) {
        factoryId = "nativeAdExit";
      } else {
        factoryId = "listTileNativeAd";
      }
      LogEventManager.trackAdRequest(
        adPlatform: 'Admob',
        adUnitId: adUnitId,
        adType: 'native',
      );

      _nativeAd = NativeAd(
        adUnitId: adUnitId,
        request: ConsentService.getAdRequest(),
        factoryId: factoryId,
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
              adSource:
                  ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
              network: ad.responseInfo?.mediationAdapterClassName,
            );
          },
          onAdLoaded: (ad) {
            if (!mounted || ADService.isSubscribed()) {
              ad.dispose();
              if (identical(_nativeAd, ad)) _nativeAd = null;
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _isFailToLoad = true;
                });
              }
              return;
            }
            if (kDebugMode) {
              debugPrint(
                '🎯 [AD LOADED] Native Ad | Label: ${widget.adLabel} | ID: $adUnitId',
              );
            }
            _isLoading = false;
            _isLoaded = true;
            _isFailToLoad = false;
            widget.onAdLoadedStatus?.call(true);

            LogEventManager.trackAdMatchedRequest(
              adPlatform: 'Admob',
              adUnitId: adUnitId,
              adType: 'native',
              responseInfo: ad.responseInfo,
            );
            LogEventManager.logNativeAdLoad(widget.adLabel);
            LogEventManager.logNativeAdShow(widget.adLabel);
            _dispatchDedicatedAdLoad();
            _dispatchDedicatedAdShow();

            if (ADService.isNativeTimerModeEnabled()) {
              ADService.markNativeAdShown();
            }

            _scheduleAutoRefresh();

            if (mounted) {
              setState(() {});
            }
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
            _dispatchDedicatedAdClick();

            // The click opens the browser / store, so the new ad (waterfall
            // from ID 1) is requested only once the user is back and the ad
            // is visible again.
            if (ADHelper.isClickAfterRefreshEnabled(widget.adLabel)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _cancelAutoRefreshTimer();
                runWhenAdVisible(() => _refreshAd(0));
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              debugPrint(
                '❌ [AD LOAD FAILED] Native Ad | Label: ${widget.adLabel} | ID: $adUnitId | Error: ${error.message}',
              );
            }
            LogEventManager.logNativeAdFailToLoad(
              widget.adLabel,
              error.message,
            );
            _dispatchDedicatedAdFail(error.message);
            ad.dispose();
            _nativeAd = null;

            int nextIndex = attemptIndex + 1;
            while (nextIndex < adIds.length && adIds[nextIndex] == adUnitId) {
              nextIndex++;
            }

            if (nextIndex < adIds.length && mounted) {
              _isLoading = false;
              _loadAd(nextIndex);
            } else {
              _isLoading = false;
              _isLoaded = false;
              _isFailToLoad = true;
              widget.onAdLoadedStatus?.call(false);
              if (mounted) {
                setState(() {});
              }
            }
          },
        ),
      );
      Future.microtask(() {
        if (mounted && _nativeAd != null) {
          _nativeAd!.load();
        }
      });
    } catch (e) {
      _isLoading = false;
      _isFailToLoad = true;
      widget.onAdLoadedStatus?.call(false);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Timer? _autoRefreshTimer;

  void _cancelAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    cancelAdVisibilityWait();
  }

  void _scheduleAutoRefresh() {
    _cancelAutoRefreshTimer();
    if (!ADHelper.isAutoRefreshEnabled(widget.adLabel)) return;
    final intervalSec = ADHelper.getRefreshIntervalSec(widget.adLabel);
    if (intervalSec <= 0) return;
    _autoRefreshTimer = Timer(Duration(seconds: intervalSec), () {
      if (!mounted) return;
      // Background / covered by another screen / scrolled away: hold the
      // refresh until the ad is on screen again instead of wasting a request.
      runWhenAdVisible(_refreshAd);
    });
  }

  @override
  void dispose() {
    AdManagerNative.unregisterAdClickListener(widget.adLabel);
    _cancelCooldownTimer();
    _cancelAutoRefreshTimer();
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowAd || _isFailToLoad) {
      return const SizedBox.shrink();
    }
    final v = _resolvedVariant;
    final double adHeight;
    final EdgeInsets adMargin;
    final double borderRadius;

    switch (v) {
      case NativeAdVariant.small:
        adHeight = 60.0;
        adMargin = const EdgeInsets.symmetric(vertical: 4);
        borderRadius = 12.0;
        break;
      case NativeAdVariant.medium:
        adHeight = 225.0;
        adMargin = const EdgeInsets.symmetric(vertical: 4);
        borderRadius = 16.0;
        break;
      case NativeAdVariant.large:
        adHeight = 250.0;
        adMargin = const EdgeInsets.symmetric(vertical: 4);
        borderRadius = 16.0;
        break;
      case NativeAdVariant.mediaSquare:
        adHeight = 202.0;
        adMargin = const EdgeInsets.symmetric(vertical: 4);
        borderRadius = 16.0;
        break;
      case NativeAdVariant.languageLargeMedia:
        adHeight = 280.0;
        adMargin = const EdgeInsets.symmetric(vertical: 4);
        borderRadius = 16.0;
        break;
      case NativeAdVariant.exit:
        adHeight = widget.height > 0 ? widget.height : 130.0;
        adMargin = EdgeInsets.zero;
        borderRadius = 16.0;
        break;
    }

    final Widget content;
    if (_isLoading) {
      content = _AdShimmer(
        variant: v,
        templateType: widget.templateType,
        height: adHeight,
        margin: adMargin,
        borderRadius: borderRadius,
      );
    } else if (_isLoaded && _nativeAd != null) {
      content = Container(
        width: double.infinity,
        height: adHeight,
        margin: adMargin,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          height: adHeight,
          child: AdWidget(
            key: ValueKey(_nativeAd.hashCode),
            ad: _nativeAd!,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }

    if (widget.topSpacer != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.topSpacer!,
          content,
        ],
      );
    }
    return content;
  }
}

class _AdShimmer extends StatelessWidget {
  final NativeAdVariant? variant;
  final NativeTemplateType templateType;
  final double height;
  final EdgeInsets margin;
  final double borderRadius;

  const _AdShimmer({
    required this.variant,
    required this.templateType,
    required this.height,
    required this.margin,
    required this.borderRadius,
  });

  bool get _isSmall => variant != null
      ? variant == NativeAdVariant.small
      : templateType == NativeTemplateType.small;
  bool get _isLanguageLargeMedia =>
      variant == NativeAdVariant.languageLargeMedia;
  bool get _isLarge => variant == NativeAdVariant.large;
  bool get _isMediaSquare => variant == NativeAdVariant.mediaSquare;
  bool get _isExit => variant == NativeAdVariant.exit;

  @override
  Widget build(BuildContext context) {
    if (_isSmall) {
      return _buildSmallShimmer(context);
    } else if (_isMediaSquare) {
      return _buildMediaSquareShimmer(context);
    } else if (_isLanguageLargeMedia) {
      return _buildLanguageLargeMediaShimmer(context);
    } else if (_isLarge) {
      return _buildLargeShimmer(context);
    } else if (_isExit) {
      return _buildExitShimmer(context);
    } else {
      return _buildMediumShimmer(context);
    }
  }

  Widget _buildLanguageLargeMediaShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 11,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 145,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExitShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(10),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 11,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 44,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSquareShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(10),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 120,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 145,
                    height: 125,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 13,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 85,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          children: [
            // Top Row (36x36 Icon + Title + 2-line Body)
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Middle Media (Flexibly fills middle space identical to layout_weight=1)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Bottom CTA Button (36dp pill shape)
            Container(
              height: 36,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(8),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          children: [
            Container(
              height: 135,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 11,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
