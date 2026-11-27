import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constant/app_constant.dart';
import '../../controllers/home/home_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
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
  final RxBool isSubmittingFeedback = false.obs;

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
      feedbackLength.value = feedbackController.text.trim().length;
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

  String _mapTopicToCategory(String topic) {
    switch (topic) {
      case 'Bug or Glitch':
        return 'bug';
      case 'Other Ideas':
        return 'other';
      default:
        return 'feature';
    }
  }

  Future<void> submitFeedback() async {
    if (isSubmittingFeedback.value) return;
    final message = feedbackController.text.trim();
    if (message.isEmpty) {
      AppToast.showError('Please enter your feedback');
      return;
    }

    isSubmittingFeedback.value = true;
    try {
      final rating = selectedMoodIndex.value + 1;
      final category = _mapTopicToCategory(selectedTopic.value);

      LogEventManager.logEvent('feedback_submit_click', {
        'mood': moods[selectedMoodIndex.value]['label'] ?? '',
        'topic': selectedTopic.value,
        'rating': rating,
      });

      final response = await ApiService.post(
        url: '${baseUrl}feedback/submit',
        requiresAuth: true,
        body: {
          'rating': rating,
          'message': message,
          'category': category,
        },
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true) {
          Get.back();
          AppToast.showSuccess(
            decoded['message']?.toString() ?? 'Feedback submitted successfully',
          );
          return;
        }
        AppToast.showError(
          decoded['message']?.toString() ?? 'Failed to submit feedback',
        );
      } else {
        AppToast.showError('Failed to submit feedback');
      }
    } catch (_) {
      AppToast.showError('Something went wrong. Please try again.');
    } finally {
      isSubmittingFeedback.value = false;
    }
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
