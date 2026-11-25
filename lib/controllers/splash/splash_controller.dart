import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../services/ad_service/ad_managers/splash_ad_waterfall.dart';
import '../../services/device_info_service.dart';
import '../../services/log_event_manager.dart';
import '../../services/remote_config_service.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logSplashView();
    _startInitFlow();
  }

  Future<void> _startInitFlow() async {
    progress.value = 0.2;

    // 1. Log device specifications once on first launch
    unawaited(DeviceInfoService.logDeviceInfoOnce());

    // 2. Fetch remote config (Organic vs Marketing vs Meta flow)
    try {
      await RemoteConfigService.instance.fetchAndActivate();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SplashController] Remote config fetch error: $e');
      }
    }

    progress.value = 0.6;

    // Run Splash Ad Waterfall (with timeout protection)
    SplashAdWaterfall.run(
      onComplete: () {
        progress.value = 1.0;
        _navigateToNextScreen();
      },
    );
  }

  void _navigateToNextScreen() {
    // Navigate to Home (or Onboarding/Language based on prefs)
    Get.offAllNamed(AppRoutes.home);
  }
}
