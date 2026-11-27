import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/age_calculator/age_calculator_controller.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class AgeCalculatorScreen extends StatelessWidget {
  const AgeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AgeCalculatorController());
    LogEventManager.logEvent('age_calculator_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AppBar ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        LogEventManager.logEvent('age_calculator_back_click');
                        Get.back();
                      },
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
                      title: 'Age Calculator',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // ── Current Date ────────────────────────────────────────
              CommonText.text(
                title: 'Current Date',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                textColor: AppColors.blackColor.withValues(alpha: 0.75),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                decoration: BoxDecoration(
                  color: AppColors.reminderCardBg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 16.r,
                        color: AppColors.primaryPink,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    CommonText.text(
                      title: controller.formatDate(controller.currentDate),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.blackColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),

              // ── Date of Birth ───────────────────────────────────────
              CommonText.text(
                title: 'Date of Birth',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                textColor: AppColors.blackColor.withValues(alpha: 0.75),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () => _showDobPicker(controller),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 13.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.reminderCardBg,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withValues(alpha: 0.12),
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
                            title: controller.formatDate(controller.dob.value),
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
              SizedBox(height: 28.h),

              // ── Calculate Age CTA ───────────────────────────────────
              CommonButton.primary(
                onTap: controller.calculateAge,
                title: 'Calculate Age',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDobPicker(AgeCalculatorController controller) async {
    const startYear = 1940;
    final endYear = DateTime.now().year;

    var tempDay = controller.dob.value.day;
    var tempMonth = controller.dob.value.month;
    var tempYear = controller.dob.value.year.clamp(startYear, endYear);

    final dayCtrl = FixedExtentScrollController(initialItem: tempDay - 1);
    final monthCtrl = FixedExtentScrollController(initialItem: tempMonth - 1);
    final yearCtrl =
        FixedExtentScrollController(initialItem: tempYear - startYear);

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
                                  title: AgeCalculatorController.shortMonths[i],
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
    controller.updateDob(tempDay, tempMonth, tempYear);
  }
}
