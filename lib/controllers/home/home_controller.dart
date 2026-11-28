import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_constant.dart';
import '../../constant/app_strings.dart';
import '../../data/models/home_models.dart';
import '../../data/models/home_sections_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/log_event_manager.dart';
import '../../services/shortcut_service.dart';
import '../../theme/app_colors.dart';
import '../../ui/anniversary/anniversary_screen.dart';
import '../../ui/caption/caption_screen.dart';
import '../../utils/common_app_sheets.dart';
import '../../utils/pref_service.dart';
import '../reminders/reminders_controller.dart';
import '../templates/templates_controller.dart';

class HomeController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxInt coinsCount = 0.obs;

  // Dynamic Home Sections from API
  final RxBool isLoadingHomeSections = true.obs;
  final RxString heroPhotoUrl = ''.obs;
  final RxString heroVideoUrl = ''.obs;
  final RxString heroPhotoTitle = 'Birthday Photo'.obs;
  final RxString heroVideoTitle = 'Birthday Video'.obs;
  final RxString trendingSectionTitle = ''.obs;
  final RxList<TrendingTemplateModel> dynamicTrendingTemplates =
      <TrendingTemplateModel>[].obs;

  List<CelebrationToolModel> get tools => [
    CelebrationToolModel(
      id: 'caption',
      title: AppStrings.toolCaption,
      subtitle: AppStrings.toolCaptionSub,
      iconPath: AppAssets.icHomeCaption,
      bgColor: AppColors.toolPinkBg,
      iconGradient: AppColors.toolPinkGradient,
    ),
    CelebrationToolModel(
      id: 'reminder',
      title: AppStrings.toolReminder,
      subtitle: AppStrings.toolReminderSub,
      iconPath: AppAssets.icHomeReminder,
      bgColor: AppColors.toolGreenBg,
      iconGradient: AppColors.toolGreenGradient,
    ),
    CelebrationToolModel(
      id: 'age_calc',
      title: AppStrings.toolAgeCalc,
      subtitle: AppStrings.toolAgeCalcSub,
      iconPath: AppAssets.icHomeCalc,
      bgColor: AppColors.toolBlueBg,
      iconGradient: AppColors.toolBlueGradient,
    ),
    CelebrationToolModel(
      id: 'anniversary',
      title: AppStrings.toolAnniversary,
      subtitle: AppStrings.toolAnniversarySub,
      iconPath: AppAssets.icHomeAnniversary,
      bgColor: AppColors.toolPeachBg,
      iconGradient: AppColors.toolPeachGradient,
    ),
    CelebrationToolModel(
      id: 'card_maker',
      title: AppStrings.toolCardMaker,
      subtitle: AppStrings.toolCardMakerSub,
      iconPath: AppAssets.icHomeCardMaker,
      bgColor: AppColors.toolPurpleBg,
      iconGradient: AppColors.toolPurpleGradient,
    ),
    CelebrationToolModel(
      id: 'creations',
      title: AppStrings.toolCreations,
      subtitle: AppStrings.toolCreationsSub,
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

  List<UpcomingBirthdayModel> get upcomingBirthdays {
    final remindersCtrl = Get.isRegistered<RemindersController>()
        ? Get.find<RemindersController>()
        : Get.put(RemindersController());
    final list =
        remindersCtrl.reminders.where((r) => r.daysUntil <= 30).toList()
          ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return list
        .take(5)
        .map(
          (r) => UpcomingBirthdayModel(
            id: r.id,
            initials: r.initials,
            title: r.displayTitle,
            subtitle: r.displaySubtitle,
            avatarColor: r.avatarColor,
            isToday: r.daysUntil == 0,
          ),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    coinsCount.value = PrefService.getInt(PrefService.userCredits) ?? 0;
    LogEventManager.logEvent('home_view');
    _fetchHomeSections();
    Future.microtask(ShortcutService.init);
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    if (PrefService.getBool(PrefService.hasAskedNotification)) return;
    final status = await Permission.notification.status;
    if (status.isGranted) return;
    await PrefService.setValue(PrefService.hasAskedNotification, true);
    await Future.delayed(const Duration(milliseconds: 800));
    await CommonAppSheets.showNotificationPermission();
  }

  Future<void> refreshHomeSections() =>
      Future.wait([_fetchHomeSections(), fetchCredits()]);

  Future<void> fetchCredits() async {
    try {
      final response = await ApiService.get(url: '${baseUrl}credits/me');
      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] is Map) {
          final credits =
              (decoded['data']['credits'] as num?)?.toInt() ?? coinsCount.value;
          coinsCount.value = credits;
          await PrefService.setValue(PrefService.userCredits, credits);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Fetch credits error: $e');
      }
    }
  }

  Future<void> _fetchHomeSections() async {
    isLoadingHomeSections.value = true;
    try {
      final response = await ApiService.get(url: '${baseUrl}home-sections/app');
      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = HomeSectionsResponse.fromJson(decoded);
        if (!parsed.success || parsed.data.isEmpty) return;

        for (final section in parsed.data) {
          final lowerTitle = section.title.toLowerCase();
          if (lowerTitle.contains('hero')) {
            for (final item in section.items) {
              if (item.name.toLowerCase().contains('video')) {
                if (item.name.isNotEmpty) heroVideoTitle.value = item.name;
                final url = item.videoSquare;
                if (url != null && url.isNotEmpty) {
                  heroVideoUrl.value = url;
                }
              } else {
                if (item.name.isNotEmpty) heroPhotoTitle.value = item.name;
                final url = item.imgSquare;
                if (url != null && url.isNotEmpty) {
                  heroPhotoUrl.value = url;
                }
              }
            }
          } else {
            if (section.title.isNotEmpty) {
              trendingSectionTitle.value = section.title;
            }
            if (section.items.isNotEmpty) {
              dynamicTrendingTemplates.assignAll(
                section.items
                    .map(
                      (item) => TrendingTemplateModel(
                        id: item.id,
                        title: item.name,
                        imagePath:
                            (item.imgSquare != null &&
                                item.imgSquare!.isNotEmpty)
                            ? item.imgSquare!
                            : AppAssets.sampleTemplate,
                        type: item.type,
                      ),
                    )
                    .toList(),
              );
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Home sections error: $e');
      }
    } finally {
      isLoadingHomeSections.value = false;
    }
  }

  void onTabChanged(int index) {
    if (index == 1 && selectedTabIndex.value != 1) {
      if (Get.isRegistered<TemplatesController>()) {
        Get.find<TemplatesController>().onTypeChanged(0);
      }
    }
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
    final templatesCtrl = Get.isRegistered<TemplatesController>()
        ? Get.find<TemplatesController>()
        : Get.put(TemplatesController());
    templatesCtrl.onTypeChanged(0);
    selectedTabIndex.value = 1;
  }

  void onBirthdayVideoTap() {
    LogEventManager.logEvent('home_birthday_video_click');
    final templatesCtrl = Get.isRegistered<TemplatesController>()
        ? Get.find<TemplatesController>()
        : Get.put(TemplatesController());
    templatesCtrl.onTypeChanged(1);
    selectedTabIndex.value = 1;
  }

  void onToolTap(String toolId) {
    LogEventManager.logEvent('home_tool_click', {'tool': toolId});
    if (toolId == 'caption') {
      Get.to(() => const CaptionScreen());
    } else if (toolId == 'reminder') {
      selectedTabIndex.value = 2;
    } else if (toolId == 'age_calc') {
      Get.toNamed(AppRoutes.ageCalculator);
    } else if (toolId == 'anniversary') {
      Get.to(() => const AnniversaryScreen());
    } else if (toolId == 'creations') {
      Get.toNamed(AppRoutes.creation);
    } else if (toolId == 'card_maker') {
      final templatesCtrl = Get.isRegistered<TemplatesController>()
          ? Get.find<TemplatesController>()
          : Get.put(TemplatesController());
      templatesCtrl.onTypeChanged(2);
      selectedTabIndex.value = 1;
    }
  }

  void onTemplateTap(String templateId, {String type = 'photo'}) {
    LogEventManager.logEvent('home_template_click', {
      'template': templateId,
      'type': type,
    });
    final templatesCtrl = Get.isRegistered<TemplatesController>()
        ? Get.find<TemplatesController>()
        : Get.put(TemplatesController());
    templatesCtrl.selectTypeAndCategory(type, templateId);
    selectedTabIndex.value = 1;
  }

  void onViewAllTemplatesTap() {
    LogEventManager.logEvent('home_view_all_templates_click');
    selectedTabIndex.value = 1;
  }

  void onAddNewBirthdayTap() {
    LogEventManager.logEvent('home_add_birthday_click');
    selectedTabIndex.value = 2;
  }

  void onWishTap(String id) {
    LogEventManager.logEvent('home_wish_click', {'id': id});
  }
}
