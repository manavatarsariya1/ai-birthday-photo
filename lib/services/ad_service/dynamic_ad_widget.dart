import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ad_helper.dart';
import 'ad_services.dart';
import 'banner_ad_widget.dart';
import 'native_ad_widget.dart';

/// Dynamic Ad Widget that automatically loads a Banner Ad or Native Ad
/// based on the `adsType` configured in Firebase Remote Config for [adLabel].
class DynamicAdWidget extends StatelessWidget {
  const DynamicAdWidget({
    super.key,
    required this.adLabel,
    this.nativeVariant,
    this.nativeHeight = 95,
    this.onAdLoadedStatus,
  });

  final String adLabel;
  final NativeAdVariant? nativeVariant;
  final double nativeHeight;
  final ValueChanged<bool>? onAdLoadedStatus;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSubscribed = ADService.isSubscribed();
      if (isSubscribed || !ADService.getAdShowStatus()) {
        return const SizedBox.shrink();
      }

      final adType = ADHelper.getAdType(adLabel).toLowerCase();
      if (kDebugMode) {
        debugPrint('[DynamicAdWidget] Label: $adLabel | Resolved AdType: $adType');
      }

      if (adType.contains('banner')) {
        return BannerAdWidget(adLabel: adLabel);
      }

      return NativeAdWidget(
        adLabel: adLabel,
        variant: nativeVariant,
        height: nativeHeight,
        onAdLoadedStatus: onAdLoadedStatus,
      );
    });
  }
}
