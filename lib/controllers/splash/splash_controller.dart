import 'dart:async';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logSplashView();
    _startInitFlow();
  }

  Future<void> _startInitFlow() async {
    progress.value = 0.3;
    await Future.delayed(const Duration(milliseconds: 900));
    progress.value = 0.7;
    await Future.delayed(const Duration(milliseconds: 900));
    progress.value = 1.0;
    await Future.delayed(const Duration(milliseconds: 350));
    Get.offAllNamed(AppRoutes.language);
  }
}
