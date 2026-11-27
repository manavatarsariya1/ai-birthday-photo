import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/age_calculator/age_calculator_controller.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class AgeResultScreen extends StatelessWidget {
  const AgeResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgeCalculatorController>();
    LogEventManager.logEvent('age_result_view');

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) controller.stopLiveTicker();
      },
      child: Scaffold(
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
                    onTap: () {
                      LogEventManager.logEvent('age_result_back_click');
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
                    title: 'Result',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.blackColor,
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 24.h),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dates Card
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.reminderCardBg,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Current Date',
                            value: controller.formatDate(controller.currentDate),
                          ),
                          Divider(
                            height: 1,
                            color: AppColors.blackColor.withValues(alpha: 0.06),
                          ),
                          Obx(
                            () => _InfoRow(
                              label: 'Date Of Birth',
                              value: controller.formatDate(controller.dob.value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // YOUR AGE IS
                    CommonText.text(
                      title: 'YOUR AGE IS',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor.withValues(alpha: 0.75),
                    ),
                    SizedBox(height: 10.h),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _AgeStatBox(
                              value: '${controller.years.value}',
                              label: 'Years',
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _AgeStatBox(
                              value: '${controller.months.value}',
                              label: 'Months',
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _AgeStatBox(
                              value: '${controller.days.value}',
                              label: 'Days',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // NEXT BIRTHDAY
                    CommonText.text(
                      title: 'NEXT BIRTHDAY',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor.withValues(alpha: 0.75),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.reminderCardBg,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Obx(
                        () => Column(
                          children: [
                            _InfoRow(
                              label: 'Birthday',
                              value: controller.nextBirthdayFormatted.value,
                            ),
                            Divider(
                              height: 1,
                              color:
                                  AppColors.blackColor.withValues(alpha: 0.06),
                            ),
                            _InfoRow(
                              label: 'Day of the week',
                              value: controller.nextBirthdayWeekday.value,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // YOU ALREADY LIVED
                    CommonText.text(
                      title: 'YOU ALREADY LIVED',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor.withValues(alpha: 0.75),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.reminderCardBg,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Obx(
                        () => Column(
                          children: [
                            _InfoRow(
                              label: 'In Years',
                              value: '${controller.totalYears.value}',
                            ),
                            _divider(),
                            _InfoRow(
                              label: 'In Months',
                              value: '${controller.totalMonths.value}',
                            ),
                            _divider(),
                            _InfoRow(
                              label: 'In Weeks',
                              value: '${controller.totalWeeks.value}',
                            ),
                            _divider(),
                            _InfoRow(
                              label: 'In Days',
                              value: '${controller.totalDays.value}',
                            ),
                            _divider(),
                            _InfoRow(
                              label: 'In Hours',
                              value: '${controller.totalHours.value}',
                            ),
                            _divider(),
                            _InfoRow(
                              label: 'In Minutes',
                              value: '${controller.totalMinutes.value}',
                            ),
                            _divider(),
                            _InfoRow(
                              label: 'In Seconds',
                              value: '${controller.totalSeconds.value}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        color: AppColors.blackColor.withValues(alpha: 0.06),
      );
}

class _AgeStatBox extends StatelessWidget {
  final String value;
  final String label;

  const _AgeStatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.reminderCardBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          CommonText.text(
            title: value,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            textColor: AppColors.primaryPink,
          ),
          SizedBox(height: 4.h),
          CommonText.text(
            title: label,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            textColor: AppColors.blackColor.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText.text(
            title: label,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            textColor: AppColors.blackColor,
          ),
          CommonText.text(
            title: value,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            textColor: AppColors.blackColor.withValues(alpha: 0.75),
          ),
        ],
      ),
    );
  }
}
