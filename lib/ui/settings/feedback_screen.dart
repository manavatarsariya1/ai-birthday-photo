import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/settings/settings_controller.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    LogEventManager.logEvent('feedback_view');

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
                    onTap: () {
                      LogEventManager.logEvent('feedback_back_click');
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
                    title: 'Feedback',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.text(
                      title: 'HOW IS YOUR JOURNEY FEELINGS WITH US?',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor.withValues(alpha: 0.75),
                    ),
                    SizedBox(height: 10.h),

                    // Mood Selector Card
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.reminderCardBg,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          SettingsController.moods.length,
                          (i) {
                            final mood = SettingsController.moods[i];
                            return Expanded(
                              child: Obx(() {
                                final isSelected =
                                    controller.selectedMoodIndex.value == i;
                                return GestureDetector(
                                  onTap: () =>
                                      controller.selectedMoodIndex.value = i,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.h,
                                      horizontal: 4.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryPink
                                              .withValues(alpha: 0.14)
                                          : AppColors.transparentColor,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          mood['emoji'] ?? '',
                                          style: TextStyle(fontSize: 22.sp),
                                        ),
                                        SizedBox(height: 6.h),
                                        CommonText.text(
                                          title: mood['label'] ?? '',
                                          fontSize: 10.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          textColor: isSelected
                                              ? AppColors.blackColor
                                              : AppColors.blackColor
                                                  .withValues(alpha: 0.55),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Topics
                    CommonText.text(
                      title: 'WHAT IS THIS ABOUT?',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor.withValues(alpha: 0.75),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: SettingsController.topics.map((topic) {
                        return Obx(() {
                          final isSelected =
                              controller.selectedTopic.value == topic;
                          return GestureDetector(
                            onTap: () => controller.selectedTopic.value = topic,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 9.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppColors.primaryGradient
                                    : null,
                                color:
                                    isSelected ? null : AppColors.reminderCardBg,
                                borderRadius: BorderRadius.circular(9999.r),
                              ),
                              child: CommonText.text(
                                title: topic,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                textColor: isSelected
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),
                    SizedBox(height: 20.h),

                    // Detailed Feedback Card
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.reminderCardBg,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    size: 18.r,
                                    color: AppColors.primaryPink,
                                  ),
                                  SizedBox(width: 6.w),
                                  CommonText.text(
                                    title: 'Detailed Feedback',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppColors.blackColor,
                                  ),
                                ],
                              ),
                              Obx(
                                () => CommonText.text(
                                  title: '${controller.feedbackLength.value} / 500',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                  textColor: AppColors.blackColor
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: TextField(
                              controller: controller.feedbackController,
                              maxLines: 6,
                              maxLength: 500,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                color: AppColors.blackColor,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Tell us more details... What kind of themes, cake designs, or features would you like to see next?',
                                hintStyle: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: AppColors.blackColor
                                      .withValues(alpha: 0.35),
                                ),
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Send Feedback CTA ──────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
              child: CommonButton.primary(
                onTap: controller.submitFeedback,
                title: 'Send Feedback',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
