import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../controllers/home/home_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../utils/app_toast.dart';

class SettingsController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxString appVersionLabel = 'Version 1.0.0'.obs;

  // Feedback form state
  final RxInt selectedMoodIndex = 3.obs;
  final RxString selectedTopic = 'New Style / Template'.obs;
  final TextEditingController feedbackController = TextEditingController();
  final RxInt feedbackLength = 0.obs;

  static const List<Map<String, String>> moods = [
    {'emoji': '😪', 'label': 'Tiring'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😊', 'label': 'Supported'},
    {'emoji': '💖', 'label': 'Loving it'},
    {'emoji': '🌟', 'label': 'Lifesaver'},
  ];

  static const List<String> topics = [
    'New Style / Template',
    'AI Photo Quality',
    'Video Generation',
    'Birthday Reminders',
    'Bug or Glitch',
    'Other Ideas',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadPackageInfo();
    feedbackController.addListener(() {
      feedbackLength.value = feedbackController.text.length;
    });
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersionLabel.value =
          'Version ${info.version} (Build ${info.buildNumber})';
    } catch (_) {}
  }

  void openPaywall() {
    LogEventManager.logEvent('settings_upgrade_click');
    Get.toNamed(AppRoutes.paywall);
  }

  void openReminders() {
    LogEventManager.logEvent('settings_reminders_click');
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().selectedTabIndex.value = 2;
    }
  }

  void openLanguage() {
    LogEventManager.logEvent('settings_language_click');
    Get.toNamed(AppRoutes.language);
  }

  void openFeedback() {
    LogEventManager.logEvent('settings_feedback_click');
    feedbackController.clear();
    selectedMoodIndex.value = 3;
    selectedTopic.value = 'New Style / Template';
    Get.toNamed(AppRoutes.feedback);
  }

  void submitFeedback() {
    if (feedbackController.text.trim().isEmpty) {
      AppToast.showError('Please enter your feedback');
      return;
    }
    LogEventManager.logEvent('feedback_submit_click', {
      'mood': moods[selectedMoodIndex.value]['label'] ?? '',
      'topic': selectedTopic.value,
    });
    Get.back();
    AppToast.showSuccess('Thank you for your feedback!');
  }

  void restorePurchases() {
    LogEventManager.logEvent('settings_restore_purchases_click');
    AppToast.showInfo('Checking for existing purchases...');
  }

  @override
  void onClose() {
    feedbackController.dispose();
    super.onClose();
  }
}
