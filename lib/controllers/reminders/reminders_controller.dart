import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/reminder_model.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../ui/camera/in_app_camera_screen.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_photo_picker_sheet.dart';

class RemindersController extends GetxController {
  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  String? _editingReminderId;

  // Add Reminder form state
  final TextEditingController nameController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final RxString nameErrorText = ''.obs;
  final RxString selectedOccasion = 'Birthday'.obs;
  final RxString selectedRelationship = 'Best Friend'.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedDay = DateTime.now().day.obs;
  final RxInt selectedYear = 1998.obs;
  final RxBool repeatAnnually = true.obs;
  final RxList<String> selectedTimings = <String>['on_day', '1_day'].obs;
  final RxInt reminderHour = 9.obs;
  final RxInt reminderMinute = 0.obs;
  final RxBool isAm = true.obs;
  final RxString selectedPhotoPath = ''.obs;

  static const List<String> occasions = [
    'Birthday',
    'Anniversary',
    'Wedding',
    'Graduation',
  ];

  static const List<String> relationships = [
    'Best Friend',
    'Sister',
    'Mom',
    'Partner',
    'Brother',
  ];

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  List<ReminderModel> get thisWeekReminders =>
      reminders.where((r) => r.section == 'THIS WEEK').toList();

  List<ReminderModel> get thisMonthReminders =>
      reminders.where((r) => r.section == 'THIS MONTH').toList();

  List<ReminderModel> get laterReminders =>
      reminders.where((r) => r.section == 'LATER').toList();

  String get formattedSelectedDate =>
      '${monthNames[selectedMonth.value - 1]} ${selectedDay.value}';

  int get turningAge => DateTime.now().year - selectedYear.value;

  String get formattedReminderTime {
    final h = reminderHour.value.toString().padLeft(2, '0');
    final m = reminderMinute.value.toString().padLeft(2, '0');
    final period = isAm.value ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void resetForm() {
    final now = DateTime.now();
    nameController.clear();
    selectedOccasion.value = 'Birthday';
    selectedRelationship.value = 'Best Friend';
    selectedMonth.value = now.month;
    selectedDay.value = now.day;
    selectedYear.value = 1998;
    repeatAnnually.value = true;
    selectedTimings.assignAll(['on_day', '1_day']);
    reminderHour.value = 9;
    reminderMinute.value = 0;
    isAm.value = true;
    selectedPhotoPath.value = '';
  }

  void openAddReminder() {
    LogEventManager.logEvent('reminders_create_click');
    _editingReminderId = null;
    resetForm();
    Get.toNamed(AppRoutes.addReminder);
  }

  void openEditReminder(ReminderModel item) {
    LogEventManager.logEvent('reminder_detail_edit_click');
    _editingReminderId = item.id;
    nameController.text = item.fullName;
    selectedOccasion.value = item.occasion;
    selectedRelationship.value = item.relationship;
    selectedMonth.value = item.month;
    selectedDay.value = item.day;
    selectedYear.value = item.birthYear ?? 1998;
    repeatAnnually.value = item.repeatAnnually;
    selectedTimings.assignAll(item.notificationTimings);
    reminderHour.value = item.reminderHour;
    reminderMinute.value = item.reminderMinute;
    isAm.value = item.isAm;
    selectedPhotoPath.value = item.photoPath ?? '';
    Get.toNamed(AppRoutes.addReminder);
  }

  void toggleRepeatAnnually(String id, bool value) {
    final index = reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final old = reminders[index];
    reminders[index] = ReminderModel(
      id: old.id,
      fullName: old.fullName,
      occasion: old.occasion,
      relationship: old.relationship,
      month: old.month,
      day: old.day,
      birthYear: old.birthYear,
      repeatAnnually: value,
      notificationTimings: old.notificationTimings,
      reminderHour: old.reminderHour,
      reminderMinute: old.reminderMinute,
      isAm: old.isAm,
      photoPath: old.photoPath,
      avatarColor: old.avatarColor,
    );
  }

  void deleteReminder(String id) {
    LogEventManager.logEvent('reminder_detail_delete_click');
    reminders.removeWhere((r) => r.id == id);
    Get.back();
  }

  void toggleTiming(String key) {
    if (selectedTimings.contains(key)) {
      selectedTimings.remove(key);
    } else {
      selectedTimings.add(key);
    }
  }

  Future<void> pickPhoto() async {
    final path = await CommonPhotoPickerSheet.show();
    if (path != null && path.isNotEmpty) {
      selectedPhotoPath.value = path;
    }
  }

  Future<void> _pickFromInAppCamera() async {
    try {
      final result = await Get.to(() => const InAppCameraScreen());
      if (result is XFile) {
        selectedPhotoPath.value = result.path;
      } else if (result is String && result.isNotEmpty) {
        selectedPhotoPath.value = result;
      }
    } catch (_) {}
  }

  Future<void> _pickFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null) {
        selectedPhotoPath.value = picked.path;
      }
    } catch (_) {}
  }

  void saveReminder() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      nameErrorText.value = 'Please enter full name';
      nameFocusNode.requestFocus();
      return;
    }

    const palette = [
      AppColors.avatarPurple,
      AppColors.avatarBlue,
      AppColors.primaryPink,
      AppColors.primaryOrange,
    ];
    final color = palette[reminders.length % palette.length];

    if (_editingReminderId != null) {
      final idx = reminders.indexWhere((r) => r.id == _editingReminderId);
      if (idx != -1) {
        reminders[idx] = ReminderModel(
          id: _editingReminderId!,
          fullName: name,
          occasion: selectedOccasion.value,
          relationship: selectedRelationship.value,
          month: selectedMonth.value,
          day: selectedDay.value,
          birthYear: selectedYear.value,
          repeatAnnually: repeatAnnually.value,
          notificationTimings: selectedTimings.toList(),
          reminderHour: reminderHour.value,
          reminderMinute: reminderMinute.value,
          isAm: isAm.value,
          photoPath: selectedPhotoPath.value.isNotEmpty
              ? selectedPhotoPath.value
              : null,
          avatarColor: reminders[idx].avatarColor,
        );
      }
      _editingReminderId = null;
    } else {
      reminders.add(
        ReminderModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fullName: name,
          occasion: selectedOccasion.value,
          relationship: selectedRelationship.value,
          month: selectedMonth.value,
          day: selectedDay.value,
          birthYear: selectedYear.value,
          repeatAnnually: repeatAnnually.value,
          notificationTimings: selectedTimings.toList(),
          reminderHour: reminderHour.value,
          reminderMinute: reminderMinute.value,
          isAm: isAm.value,
          photoPath: selectedPhotoPath.value.isNotEmpty
              ? selectedPhotoPath.value
              : null,
          avatarColor: color,
        ),
      );
    }

    LogEventManager.logEvent('add_reminder_save_click');
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    nameFocusNode.dispose();
    super.onClose();
  }
}
