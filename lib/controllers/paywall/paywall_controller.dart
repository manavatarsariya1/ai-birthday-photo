import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../data/models/paywall_plan_model.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';

class PaywallController extends GetxController {
  final RxString selectedPlanId = 'yearly'.obs;

  List<PaywallCarouselModel> get carouselItems => [
        PaywallCarouselModel(
          imagePath: AppAssets.paywallCarousel1,
          title: AppStrings.birthdayImage,
        ),
        PaywallCarouselModel(
          imagePath: AppAssets.paywallCarousel2,
          title: AppStrings.birthdayVideo,
          isVideo: true,
        ),
        PaywallCarouselModel(
          imagePath: AppAssets.paywallCarousel3,
          title: AppStrings.birthdayCaption,
        ),
        PaywallCarouselModel(
          imagePath: AppAssets.paywallCarousel4,
          title: AppStrings.anniversaryMoment,
        ),
      ];

  List<String> get features => [
        AppStrings.paywallFeature1,
        AppStrings.paywallFeature2,
        AppStrings.paywallFeature3,
        AppStrings.paywallFeature4,
      ];

  List<PaywallPlanModel> get plans => [
        PaywallPlanModel(
          id: 'yearly',
          title: AppStrings.yearly,
          price: '\$29.99',
          period: AppStrings.perYear,
          credits: AppStrings.credits1200,
          discountBadge: AppStrings.off50,
        ),
        PaywallPlanModel(
          id: 'monthly',
          title: AppStrings.monthly,
          price: '\$9.99',
          period: AppStrings.perMonth,
          credits: AppStrings.credits600,
          discountBadge: AppStrings.off30,
        ),
        PaywallPlanModel(
          id: 'weekly',
          title: AppStrings.weekly,
          price: '\$4.99',
          period: AppStrings.perWeek,
          credits: AppStrings.credits200,
        ),
      ];

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logEvent('paywall_view');
  }

  void selectPlan(String planId) {
    selectedPlanId.value = planId;
    LogEventManager.logEvent('paywall_plan_select_click', {'plan': planId});
  }

  void onCloseTap() {
    LogEventManager.logEvent('paywall_back_click');
    Get.offAllNamed(AppRoutes.home);
  }

  void onRestoreTap() {
    LogEventManager.logEvent('paywall_restore_click');
  }

  void onContinueTap() {
    LogEventManager.logEvent(
      'paywall_subscribe_click',
      {'plan': selectedPlanId.value},
    );
    Get.offAllNamed(AppRoutes.home);
  }

  void onTermsTap() {
    LogEventManager.logEvent('paywall_terms_click');
  }

  void onPrivacyTap() {
    LogEventManager.logEvent('paywall_privacy_click');
  }
}
