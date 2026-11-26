import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../data/models/onboarding_page_model.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  List<OnboardingPageModel> get pages => [
        OnboardingPageModel(
          imagePath: AppAssets.onboarding1,
          titlePrefix: AppStrings.onboarding1TitlePrefix,
          titleHighlight: AppStrings.onboarding1TitleHighlight,
          titleSuffix: AppStrings.onboarding1TitleSuffix,
          description: AppStrings.onboarding1Desc,
        ),
        OnboardingPageModel(
          imagePath: AppAssets.onboarding2,
          titlePrefix: AppStrings.onboarding2TitlePrefix,
          titleHighlight: AppStrings.onboarding2TitleHighlight,
          titleSuffix: AppStrings.onboarding2TitleSuffix,
          description: AppStrings.onboarding2Desc,
        ),
        OnboardingPageModel(
          imagePath: AppAssets.onboarding3,
          titlePrefix: AppStrings.onboarding3TitlePrefix,
          titleHighlight: AppStrings.onboarding3TitleHighlight,
          description: AppStrings.onboarding3Desc,
        ),
      ];

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logEvent('onboarding_1_view');
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    LogEventManager.logEvent('onboarding_${index + 1}_view');
  }

  void onNextTap() {
    final idx = currentIndex.value;
    LogEventManager.logEvent('onboarding_${idx + 1}_next_click');
    if (idx < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(AppRoutes.paywall);
    }
  }

  void onBackTap() {
    final idx = currentIndex.value;
    LogEventManager.logEvent('onboarding_${idx + 1}_back_click');
    if (idx > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onSkipTap() {
    final idx = currentIndex.value;
    LogEventManager.logEvent('onboarding_${idx + 1}_skip_click');
    Get.offAllNamed(AppRoutes.paywall);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
