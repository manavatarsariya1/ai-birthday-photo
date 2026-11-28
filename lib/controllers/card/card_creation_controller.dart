import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/templates_api_model.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../ui/generation/generation_screen.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_app_sheets.dart';
import '../../utils/common_photo_picker_sheet.dart';
import '../../utils/pref_service.dart';
import '../home/home_controller.dart';

class CardCreationController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode venueFocusNode = FocusNode();
  final RxString nameErrorText = ''.obs;
  final RxString venueErrorText = ''.obs;
  final Rx<DateTime> celebrationDate = DateTime.now().obs;
  final RxString selectedPhotoPath = ''.obs;
  final RxString templateImageUrl = ''.obs;
  TemplateItemModel? selectedTemplate;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      templateImageUrl.value = args['imageUrl']?.toString() ?? '';
      if (args['template'] is TemplateItemModel) {
        selectedTemplate = args['template'] as TemplateItemModel;
      }
    } else if (args is String) {
      templateImageUrl.value = args;
    }
  }

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
      if (selectedTemplate?.singleFace == true) {
        final detector = FaceDetector(options: FaceDetectorOptions());
        try {
          final inputImage = InputImage.fromFile(File(path));
          final faces = await detector.processImage(inputImage);
          if (faces.isEmpty) {
            AppToast.showError(
              'No face detected. Please upload a clear face photo.',
            );
            return;
          }
          if (faces.length > 1) {
            AppToast.showError(
              'Multiple faces detected. Please upload a single face photo.',
            );
            return;
          }
        } finally {
          await detector.close();
        }
      }
      selectedPhotoPath.value = path;
    }
  }

  void generateCard() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      nameErrorText.value = 'Please enter full name';
      nameFocusNode.requestFocus();
      return;
    }
    final venue = venueController.text.trim();
    if (venue.isEmpty) {
      venueErrorText.value = 'Please enter venue';
      venueFocusNode.requestFocus();
      return;
    }
    if (selectedPhotoPath.value.isEmpty) {
      AppToast.showError('Please add a photo');
      return;
    }
    final requiredCredits = selectedTemplate?.credits ?? 1;
    final balance = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().coinsCount.value
        : (PrefService.getInt(PrefService.userCredits) ?? 0);
    if (balance < requiredCredits) {
      CommonAppSheets.showInsufficientCredits();
      return;
    }
    LogEventManager.logEvent('card_generate_click');
    Get.to(
      () => GenerationScreen(
        imageFile: File(selectedPhotoPath.value),
        template: selectedTemplate,
        customEndpoint: 'generations/card',
        imageFieldName: 'image1',
        extraFields: {
          'name': name,
          'date': formattedDate,
          'venue': venue,
        },
      ),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    nameController.dispose();
    venueController.dispose();
    nameFocusNode.dispose();
    venueFocusNode.dispose();
    super.onClose();
  }
}
