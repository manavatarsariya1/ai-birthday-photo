import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/ad_service/ad_services.dart';
import '../../services/log_event_manager.dart';
import '../../utils/exit_bottom_sheet.dart';

class HomeController extends GetxController {
  final RxInt counter = 0.obs;

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logEvent("home_view");
    // Preload Interstitial for next actions
    ADService.loadInterstitialAd();
  }

  void incrementCounter() {
    counter.value++;
    LogEventManager.logEvent(
        "home_increment_click", {"new_count": counter.value});
  }

  void showFeatureWithAd() {
    // Show Interstitial with frequency cap check
    ADService.showInterstitialAd(
      onAdDismissed: () {
        incrementCounter();
      },
    );
  }

  Future<bool> onWillPop(BuildContext context) async {
    LogEventManager.logEvent("home_back_click");
    // Show exit dialog with native ad
    final shouldExit = await ExitBottomSheet.show(context);
    return shouldExit ?? false;
  }
}
