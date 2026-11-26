import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../data/models/home_models.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';

class HomeController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxInt coinsCount = 100.obs;

  final List<CelebrationToolModel> tools = const [
    CelebrationToolModel(
      id: 'caption',
      title: 'Caption',
      subtitle: 'Poetic & Fun',
      iconPath: AppAssets.icHomeCaption,
      bgColor: AppColors.toolPinkBg,
      iconGradient: AppColors.toolPinkGradient,
    ),
    CelebrationToolModel(
      id: 'reminder',
      title: 'Reminder',
      subtitle: 'Never Forget',
      iconPath: AppAssets.icHomeReminder,
      bgColor: AppColors.toolGreenBg,
      iconGradient: AppColors.toolGreenGradient,
    ),
    CelebrationToolModel(
      id: 'age_calc',
      title: 'Age Calc',
      subtitle: 'Milestones',
      iconPath: AppAssets.icHomeCalc,
      bgColor: AppColors.toolBlueBg,
      iconGradient: AppColors.toolBlueGradient,
    ),
    CelebrationToolModel(
      id: 'anniversary',
      title: 'Anniversary',
      subtitle: 'Romantic AI',
      iconPath: AppAssets.icHomeAnniversary,
      bgColor: AppColors.toolPeachBg,
      iconGradient: AppColors.toolPeachGradient,
    ),
    CelebrationToolModel(
      id: 'card_maker',
      title: 'Card Maker',
      subtitle: 'Custom Art',
      iconPath: AppAssets.icHomeCardMaker,
      bgColor: AppColors.toolPurpleBg,
      iconGradient: AppColors.toolPurpleGradient,
    ),
    CelebrationToolModel(
      id: 'creations',
      title: 'Creations',
      subtitle: 'Saved 4K',
      iconPath: AppAssets.icHomeCreations,
      bgColor: AppColors.toolCyanBg,
      iconGradient: AppColors.toolCyanGradient,
    ),
  ];

  final List<TrendingTemplateModel> trendingTemplates = const [
    TrendingTemplateModel(
      id: 'glam_birthday',
      title: 'Glam Birthday',
      imagePath: AppAssets.sampleTemplate,
    ),
    TrendingTemplateModel(
      id: 'kids_birthday',
      title: "Kid's Birthday",
      imagePath: AppAssets.sampleTemplate,
    ),
    TrendingTemplateModel(
      id: 'floral_birthday',
      title: 'Floral Birthday',
      imagePath: AppAssets.sampleTemplate,
    ),
  ];

  final List<UpcomingBirthdayModel> upcomingBirthdays = const [
    UpcomingBirthdayModel(
      id: '1',
      initials: 'EM',
      title: "Emma's 28th Birthday",
      subtitle: 'Today',
      avatarColor: AppColors.avatarPurple,
      isToday: true,
    ),
    UpcomingBirthdayModel(
      id: '2',
      initials: 'AL',
      title: 'Alexander Davis',
      subtitle: 'Next Week (Nov 2)',
      avatarColor: AppColors.avatarBlue,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logEvent('home_view');
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    LogEventManager.logEvent('home_bottom_tab_click', {'index': index});
  }

  void onPremiumTap() {
    LogEventManager.logEvent('home_premium_click');
    Get.toNamed(AppRoutes.paywall);
  }

  void onCoinsTap() {
    LogEventManager.logEvent('home_coins_click');
  }

  void onBirthdayPhotoTap() {
    LogEventManager.logEvent('home_birthday_photo_click');
  }

  void onBirthdayVideoTap() {
    LogEventManager.logEvent('home_birthday_video_click');
  }

  void onToolTap(String toolId) {
    LogEventManager.logEvent('home_tool_click', {'tool': toolId});
  }

  void onTemplateTap(String templateId) {
    LogEventManager.logEvent('home_template_click', {'template': templateId});
  }

  void onViewAllTemplatesTap() {
    LogEventManager.logEvent('home_view_all_templates_click');
    selectedTabIndex.value = 1;
  }

  void onAddNewBirthdayTap() {
    LogEventManager.logEvent('home_add_birthday_click');
  }

  void onWishTap(String id) {
    LogEventManager.logEvent('home_wish_click', {'id': id});
  }
}
