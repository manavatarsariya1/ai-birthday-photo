import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/reminders/reminders_controller.dart';
import '../../data/models/reminder_model.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_switch.dart';
import '../../utils/common_text.dart';
import 'reminder_pickers.dart';

class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RemindersController>();
    final reminderId = Get.arguments as String? ?? '';
    LogEventManager.logEvent('reminder_detail_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Obx(() {
          final item = controller.reminders.firstWhereOrNull(
            (r) => r.id == reminderId,
          );
          if (item == null) {
            return const SizedBox.shrink();
          }

          final firstName = item.fullName.trim().split(RegExp(r'\s+')).first;

          return Column(
            children: [
              // ── AppBar ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        LogEventManager.logEvent('reminder_detail_back_click');
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
                    Expanded(
                      child: CommonText.text(
                        title: '$firstName Details',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.blackColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showDeleteReminderSheet(
                        controller,
                        item,
                        _formatFullDate(item),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(6.r),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 22.r,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ─────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Summary Card
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: AppColors.captionCardBg,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Row(
                          children: [
                            _buildAvatar(item),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText.text(
                                    title: item.fullName,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    textColor: AppColors.blackColor,
                                  ),
                                  SizedBox(height: 3.h),
                                  CommonText.text(
                                    title:
                                        '${item.occasion} • ${_formatFullDate(item)}',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                    textColor: AppColors.blackColor
                                        .withValues(alpha: 0.6),
                                  ),
                                  SizedBox(height: 3.h),
                                  CommonText.text(
                                    title: item.daysUntil == 0
                                        ? 'Today!'
                                        : '${item.daysUntil} days to go',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppColors.blackColor
                                        .withValues(alpha: 0.65),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // DETAILS Section
                      CommonText.text(
                        title: 'DETAILS',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.blackColor.withValues(alpha: 0.75),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.captionCardBg,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Column(
                          children: [
                            _DetailRow(
                              label: 'Occasion',
                              value: item.occasion,
                            ),
                            Divider(
                              height: 1,
                              color: AppColors.blackColor.withValues(alpha: 0.06),
                            ),
                            _DetailRow(
                              label: 'Relationship',
                              value: item.relationship,
                            ),
                            Divider(
                              height: 1,
                              color: AppColors.blackColor.withValues(alpha: 0.06),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CommonText.text(
                                    title: 'Repeat Annually',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppColors.blackColor,
                                  ),
                                  CommonSwitch(
                                    value: item.repeatAnnually,
                                    onChanged: (v) => controller
                                        .toggleRepeatAnnually(item.id, v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // NOTIFICATION TIMING Section
                      CommonText.text(
                        title: 'NOTIFICATION TIMING',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.blackColor.withValues(alpha: 0.75),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: AppColors.captionCardBg,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Column(
                          children: [
                            if (item.notificationTimings.isNotEmpty) ...[
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: item.notificationTimings.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10.w,
                                  mainAxisSpacing: 10.h,
                                  childAspectRatio: 2.4,
                                ),
                                itemBuilder: (_, i) {
                                  final key = item.notificationTimings[i];
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CommonText.text(
                                          title: _timingTitle(key),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          textColor: AppColors.blackColor,
                                        ),
                                        SizedBox(height: 2.h),
                                        CommonText.text(
                                          title: _timingSubtitle(key),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          textColor: AppColors.blackColor
                                              .withValues(alpha: 0.55),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 12.h),
                              Divider(
                                height: 1,
                                color: AppColors.blackColor
                                    .withValues(alpha: 0.06),
                              ),
                              SizedBox(height: 12.h),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CommonText.text(
                                  title: 'Reminder Time',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  textColor: AppColors.blackColor,
                                ),
                                CommonText.text(
                                  title:
                                      '${item.reminderHour}:${item.reminderMinute.toString().padLeft(2, '0')} ${item.isAm ? 'AM' : 'PM'}',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  textColor: AppColors.blackColor
                                      .withValues(alpha: 0.75),
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

              // ── Bottom Edit Reminder CTA ────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                child: CommonButton.primary(
                  onTap: () => controller.openEditReminder(item),
                  title: 'Edit Reminder',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAvatar(ReminderModel item) {
    if (item.photoPath != null && item.photoPath!.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(item.photoPath!),
          width: 58.r,
          height: 58.r,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 58.r,
      height: 58.r,
      decoration: BoxDecoration(
        color: item.avatarColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CommonText.text(
        title: item.initials,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        textColor: AppColors.whiteColor,
      ),
    );
  }

  String _formatFullDate(ReminderModel item) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final date = item.nextOccurrence;
    final wd = weekdays[date.weekday - 1];
    final mon = RemindersController.shortMonthNames[item.month - 1];
    final yearPart = item.birthYear != null ? ', ${item.birthYear}' : '';
    return '$wd, $mon ${item.day}$yearPart';
  }

  String _timingTitle(String key) {
    switch (key) {
      case 'on_day':
        return 'On the Day';
      case '1_day':
        return '1 Day Before';
      case '3_days':
        return '3 Days Before';
      case '1_week':
        return '1 Week Before';
      default:
        return key;
    }
  }

  String _timingSubtitle(String key) {
    switch (key) {
      case 'on_day':
        return '09:00 AM Prompt';
      case '1_day':
        return 'Prep AI Gift/Card';
      case '3_days':
        return 'Gift Shipping window';
      case '1_week':
        return 'Party planning';
      default:
        return '';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText.text(
            title: label,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textColor: AppColors.blackColor,
          ),
          CommonText.text(
            title: value,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            textColor: AppColors.blackColor.withValues(alpha: 0.75),
          ),
        ],
      ),
    );
  }
}
