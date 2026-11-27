import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_photo_picker_sheet.dart';

class CardCreationController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final Rx<DateTime> celebrationDate = DateTime.now().obs;
  final RxString selectedPhotoPath = ''.obs;
  final RxString templateImageUrl = ''.obs;

  // Generating state
  final RxInt progress = 0.obs;
  Timer? _timer;

  static const List<String> shortMonths = [
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

  String get formattedDate {
    final d = celebrationDate.value;
    return '${d.day} ${shortMonths[d.month - 1]} ${d.year}';
  }

  void updateDate(int day, int month, int year) {
    final maxDay = DateTime(year, month + 1, 0).day;
    celebrationDate.value = DateTime(year, month, day.clamp(1, maxDay));
  }

  Future<void> pickPhoto() async {
    final path = await CommonPhotoPickerSheet.show();
    if (path != null && path.isNotEmpty) {
      selectedPhotoPath.value = path;
    }
  }

  void generateCard() {
    if (selectedPhotoPath.value.isEmpty) {
      AppToast.showError('Please add a photo');
      return;
    }
    LogEventManager.logEvent('card_generate_click');
    progress.value = 0;
    Get.toNamed(AppRoutes.cardGenerating);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 35), (t) {
      if (progress.value >= 100) {
        t.cancel();
        Get.offNamed(AppRoutes.cardResult);
      } else {
        progress.value += 2;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    nameController.dispose();
    venueController.dispose();
    super.onClose();
  }
}
