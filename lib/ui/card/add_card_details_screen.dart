import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/card/card_creation_controller.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class AddCardDetailsScreen extends StatelessWidget {
  const AddCardDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CardCreationController());
    final args = Get.arguments;
    final argUrl = args is Map
        ? args['imageUrl']?.toString()
        : args as String?;
    if (argUrl != null && argUrl.isNotEmpty) {
      controller.templateImageUrl.value = argUrl;
    }
    LogEventManager.logEvent('add_card_details_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(6.r),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20.r,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CommonText.text(
                    title: 'Add Details',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.blackColor,
                  ),
                ],
              ),
            ),

            // ── Form ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: controller.pickPhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Obx(() {
                            final path = controller.selectedPhotoPath.value;
                            return Container(
                              width: 84.r,
                              height: 84.r,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                                image: path.isNotEmpty
                                    ? DecorationImage(
                                        image: FileImage(File(path)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: path.isEmpty
                                  ? Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 30.r,
                                      color: AppColors.primaryPink,
                                    )
                                  : null,
                            );
                          }),
                          Positioned(
                            right: -2.r,
                            bottom: -2.r,
                            child: Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 15.r,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonText.text(
                          title: 'Add Photo',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.blackColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    CommonText.text(
                      title: 'Used for celebration cards & avatars',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.blackColor.withValues(alpha: 0.45),
                    ),
                    SizedBox(height: 18.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.reminderCardBg,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText.text(
                            title: 'Full Name',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            textColor: AppColors.blackColor.withValues(
                              alpha: 0.75,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: TextField(
                              controller: controller.nameController,
                              focusNode: controller.nameFocusNode,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'^\s+'),
                                ),
                              ],
                              onChanged: (_) {
                                if (controller.nameErrorText.value.isNotEmpty) {
                                  controller.nameErrorText.value = '';
                                }
                              },
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Sophia Martinez',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.blackColor.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  size: 20.r,
                                  color: AppColors.blackColor.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                          ),
                          Obx(() {
                            if (controller.nameErrorText.value.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 14.r,
                                    color: AppColors.errorColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  CommonText.text(
                                    title: controller.nameErrorText.value,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppColors.errorColor,
                                  ),
                                ],
                              ),
                            );
                          }),
                          SizedBox(height: 16.h),
                          CommonText.text(
                            title: 'Celebration Date',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            textColor: AppColors.blackColor.withValues(
                              alpha: 0.75,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () => _showDatePicker(controller),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32.r,
                                    height: 32.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPink.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 16.r,
                                      color: AppColors.primaryPink,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Obx(
                                      () => CommonText.text(
                                        title: controller.formattedDate,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        textColor: AppColors.blackColor,
                                      ),
                                    ),
                                  ),
                                  CommonText.text(
                                    title: 'Change ›',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppColors.primaryPink,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          CommonText.text(
                            title: 'Venue',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            textColor: AppColors.blackColor.withValues(
                              alpha: 0.75,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: TextField(
                              controller: controller.venueController,
                              focusNode: controller.venueFocusNode,
                              maxLines: 3,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'^\s+'),
                                ),
                              ],
                              onChanged: (_) {
                                if (controller
                                    .venueErrorText.value.isNotEmpty) {
                                  controller.venueErrorText.value = '';
                                }
                              },
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackColor,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'The Royal Orchid Banquet Hall, 125 Rosewood Avenue, Beverly Hills...',
                                hintStyle: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.blackColor.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(14.r),
                              ),
                            ),
                          ),
                          Obx(() {
                            if (controller.venueErrorText.value.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 14.r,
                                    color: AppColors.errorColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  CommonText.text(
                                    title: controller.venueErrorText.value,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppColors.errorColor,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
              child: CommonButton.primary(
                onTap: controller.generateCard,
                title: 'Generate Card',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(CardCreationController controller) async {
    const startYear = 2020;
    final endYear = DateTime.now().year + 10;

    var tempDay = controller.celebrationDate.value.day;
    var tempMonth = controller.celebrationDate.value.month;
    var tempYear = controller.celebrationDate.value.year.clamp(
      startYear,
      endYear,
    );

    final dayCtrl = FixedExtentScrollController(initialItem: tempDay - 1);
    final monthCtrl = FixedExtentScrollController(initialItem: tempMonth - 1);
    final yearCtrl = FixedExtentScrollController(
      initialItem: tempYear - startYear,
    );

    await Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.blackColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 14.h),
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: CommonText.text(
                      title: 'Select Date',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.r,
                          color: AppColors.primaryPink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 210.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      child: Container(
                        height: 44.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: dayCtrl,
                            itemExtent: 44.h,
                            physics: const FixedExtentScrollPhysics(),
                            perspective: 0.003,
                            onSelectedItemChanged: (i) => tempDay = i + 1,
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 31,
                              builder: (_, i) => Center(
                                child: CommonText.text(
                                  title: '${i + 1}',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  textColor: AppColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: monthCtrl,
                            itemExtent: 44.h,
                            physics: const FixedExtentScrollPhysics(),
                            perspective: 0.003,
                            onSelectedItemChanged: (i) => tempMonth = i + 1,
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 12,
                              builder: (_, i) => Center(
                                child: CommonText.text(
                                  title: CardCreationController.shortMonths[i],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  textColor: AppColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: yearCtrl,
                            itemExtent: 44.h,
                            physics: const FixedExtentScrollPhysics(),
                            perspective: 0.003,
                            onSelectedItemChanged: (i) =>
                                tempYear = startYear + i,
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: endYear - startYear + 1,
                              builder: (_, i) => Center(
                                child: CommonText.text(
                                  title: '${startYear + i}',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  textColor: AppColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
      barrierColor: AppColors.blackColor.withValues(alpha: 0.25),
    );
    controller.updateDate(tempDay, tempMonth, tempYear);
  }
}
