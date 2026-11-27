import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/reminders/reminders_controller.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_switch.dart';
import '../../utils/common_text.dart';
import 'reminder_pickers.dart';

class AddReminderScreen extends StatelessWidget {
  const AddReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RemindersController>();
    LogEventManager.logEvent('add_reminder_view');

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
                      LogEventManager.logEvent('add_reminder_back_click');
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
                    title: 'Add Reminder',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.blackColor,
                  ),
                ],
              ),
            ),

            // ── Scrollable Form ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 24.h),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Avatar Photo Picker
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
                                color: AppColors.primaryPink
                                    .withValues(alpha: 0.1),
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
                                Icons.camera_alt_outlined,
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
                        CommonText.text(
                          title: ' (Optional)',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.blackColor.withValues(alpha: 0.55),
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

                    // ── Card 1: Name, Occasion, Relationship ──────────
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Full Name'),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: TextField(
                              controller: controller.nameController,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Sophia Martinez',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.blackColor
                                      .withValues(alpha: 0.35),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  size: 20.r,
                                  color: AppColors.blackColor
                                      .withValues(alpha: 0.55),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _FieldLabel('Occasion'),
                          SizedBox(height: 8.h),
                          SizedBox(
                            height: 36.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              itemCount: RemindersController.occasions.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8.w),
                              itemBuilder: (_, index) {
                                final item =
                                    RemindersController.occasions[index];
                                return Obx(() {
                                  final isSelected =
                                      controller.selectedOccasion.value == item;
                                  return _ChoiceChip(
                                    label: item,
                                    isSelected: isSelected,
                                    onTap: () => controller
                                        .selectedOccasion.value = item,
                                  );
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _FieldLabel('Relationship'),
                          SizedBox(height: 8.h),
                          SizedBox(
                            height: 36.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              itemCount:
                                  RemindersController.relationships.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8.w),
                              itemBuilder: (_, index) {
                                final item =
                                    RemindersController.relationships[index];
                                return Obx(() {
                                  final isSelected =
                                      controller.selectedRelationship.value ==
                                          item;
                                  return _ChoiceChip(
                                    label: item,
                                    isSelected: isSelected,
                                    onTap: () => controller
                                        .selectedRelationship.value = item,
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // ── Card 2: Birthday Date, Birth Year, Repeat ─────
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Birthday Date'),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () => showSelectDateSheet(controller),
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
                                      color: AppColors.primaryPink
                                          .withValues(alpha: 0.12),
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
                                        title: controller.formattedSelectedDate,
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
                          _FieldLabel('Include birth year'),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () => showSelectYearSheet(controller),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 13.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  Obx(
                                    () => CommonText.text(
                                      title: '${controller.selectedYear.value}',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      textColor: AppColors.blackColor,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Obx(
                                    () => Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPink
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(9999.r),
                                      ),
                                      child: CommonText.text(
                                        title:
                                            'Turning ${controller.turningAge} this year',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        textColor: AppColors.primaryPink,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  CommonText.text(
                                    title: 'Edit Year',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppColors.blackColor
                                        .withValues(alpha: 0.65),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonText.text(
                                      title: 'Repeat Annually',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      textColor: AppColors.blackColor,
                                    ),
                                    SizedBox(height: 2.h),
                                    Obx(
                                      () => CommonText.text(
                                        title:
                                            'Automatic reminder recurring every ${controller.formattedSelectedDate}',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w400,
                                        textColor: AppColors.blackColor
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(
                                () => CommonSwitch(
                                  value: controller.repeatAnnually.value,
                                  onChanged: (v) =>
                                      controller.repeatAnnually.value = v,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // ── Card 3: Notification Timing & Reminder Time ───
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CommonText.text(
                                title: 'Notification Timing',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                textColor: AppColors.blackColor,
                              ),
                              CommonText.text(
                                title: 'Multi-select',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                textColor: AppColors.primaryPink,
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _TimingTile(
                                  timingKey: 'on_day',
                                  title: 'On the Day',
                                  subtitle: '09:00 AM Prompt',
                                  controller: controller,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: _TimingTile(
                                  timingKey: '1_day',
                                  title: '1 Day Before',
                                  subtitle: 'Prep AI Gift/Card',
                                  controller: controller,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: _TimingTile(
                                  timingKey: '3_days',
                                  title: '3 Days Before',
                                  subtitle: 'Gift Shipping window',
                                  controller: controller,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: _TimingTile(
                                  timingKey: '1_week',
                                  title: '1 Week Before',
                                  subtitle: 'Party planning',
                                  controller: controller,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CommonText.text(
                                title: 'Reminder Time',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                textColor: AppColors.blackColor
                                    .withValues(alpha: 0.75),
                              ),
                              GestureDetector(
                                onTap: () => showReminderTimeSheet(controller),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPink
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(9999.r),
                                  ),
                                  child: Obx(
                                    () => CommonText.text(
                                      title:
                                          '${controller.formattedReminderTime}  ›',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      textColor: AppColors.blackColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 22.h),

                    // ── Save Reminder CTA ─────────────────────────────
                    CommonButton.primary(
                      onTap: controller.saveReminder,
                      title: 'Save Reminder',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.captionCardBg,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return CommonText.text(
      title: text,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      textColor: AppColors.blackColor.withValues(alpha: 0.75),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(9999.r),
        ),
        alignment: Alignment.center,
        child: CommonText.text(
          title: label,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          textColor: isSelected ? AppColors.whiteColor : AppColors.blackColor,
        ),
      ),
    );
  }
}

class _TimingTile extends StatelessWidget {
  final String timingKey;
  final String title;
  final String subtitle;
  final RemindersController controller;

  const _TimingTile({
    required this.timingKey,
    required this.title,
    required this.subtitle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedTimings.contains(timingKey);
      return GestureDetector(
        onTap: () => controller.toggleTiming(timingKey),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CommonText.text(
                      title: title,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.blackColor,
                    ),
                  ),
                  Container(
                    width: 18.r,
                    height: 18.r,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected
                          ? null
                          : AppColors.primaryPink.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 12.r,
                            color: AppColors.whiteColor,
                          )
                        : null,
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              CommonText.text(
                title: subtitle,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      );
    });
  }
}
