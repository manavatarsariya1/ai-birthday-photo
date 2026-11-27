import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../controllers/home/home_controller.dart';
import '../../controllers/reminders/reminders_controller.dart';
import '../../data/models/reminder_model.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RemindersController());
    LogEventManager.logEvent('reminders_view');

    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.text(
                      title: 'Reminders',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor,
                    ),
                    SizedBox(height: 2.h),
                    CommonText.text(
                      title: 'Set reminder for birthday & anniversary',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.blackColor.withValues(alpha: 0.55),
                    ),
                  ],
                ),
              ),

              // ── Body: Empty State or Grouped List ───────────────────
              Expanded(
                child: Obx(() {
                  if (controller.reminders.isEmpty) {
                    return _EmptyRemindersView(
                      onCreateTap: controller.openAddReminder,
                    );
                  }

                  final thisWeek = controller.thisWeekReminders;
                  final thisMonth = controller.thisMonthReminders;
                  final later = controller.laterReminders;

                  return ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 96.h),
                    physics: const ClampingScrollPhysics(),
                    children: [
                      if (thisWeek.isNotEmpty)
                        _ReminderSection(
                          title: 'THIS WEEK',
                          items: thisWeek,
                          showWishButton: true,
                        ),
                      if (thisMonth.isNotEmpty)
                        _ReminderSection(
                          title: 'THIS MONTH',
                          items: thisMonth,
                        ),
                      if (later.isNotEmpty)
                        _ReminderSection(
                          title: 'LATER',
                          items: later,
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),

          // ── Floating '+' Button (only when reminders exist) ─────────
          Obx(() {
            if (controller.reminders.isEmpty) return const SizedBox.shrink();
            return Positioned(
              right: 20.w,
              bottom: 20.h,
              child: GestureDetector(
                onTap: controller.openAddReminder,
                child: Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.35),
                        blurRadius: 14.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColors.whiteColor,
                    size: 28.r,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EmptyRemindersView extends StatelessWidget {
  final VoidCallback onCreateTap;

  const _EmptyRemindersView({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.imgNoReminders,
            width: 253.w,
            height: 188.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 18.h),
          CommonText.text(
            title: 'No Reminders Yet',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            textColor: AppColors.blackColor.withValues(alpha: 0.65),
          ),
          SizedBox(height: 44.h),
          CommonButton.primary(
            onTap: onCreateTap,
            title: '+  Create Reminder',
          ),
        ],
      ),
    );
  }
}

class _ReminderSection extends StatelessWidget {
  final String title;
  final List<ReminderModel> items;
  final bool showWishButton;

  const _ReminderSection({
    required this.title,
    required this.items,
    this.showWishButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText.text(
              title: title,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              textColor: AppColors.blackColor.withValues(alpha: 0.75),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9999.r),
              ),
              child: CommonText.text(
                title: '${items.length} upcoming',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                textColor: AppColors.primaryPink,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _ReminderCard(
              item: item,
              showWishButton: showWishButton && item.daysUntil == 0,
            ),
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final ReminderModel item;
  final bool showWishButton;

  const _ReminderCard({
    required this.item,
    required this.showWishButton,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.reminderDetail, arguments: item.id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.captionCardBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _buildAvatar(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.text(
                  title: item.displayTitle,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.blackColor,
                ),
                SizedBox(height: 2.h),
                CommonText.text(
                  title: item.displaySubtitle,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  textColor: item.daysUntil == 0
                      ? AppColors.primaryPink
                      : AppColors.blackColor.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
          if (showWishButton)
            GestureDetector(
              onTap: () {
                LogEventManager.logEvent('reminders_wish_click');
                if (Get.isRegistered<HomeController>()) {
                  Get.find<HomeController>().selectedTabIndex.value = 1;
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(9999.r),
                ),
                child: CommonText.text(
                  title: 'Wish ✨',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.whiteColor,
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }

  Widget _buildAvatar() {
    if (item.photoPath != null && item.photoPath!.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(item.photoPath!),
          width: 44.r,
          height: 44.r,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: item.avatarColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CommonText.text(
        title: item.initials,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        textColor: AppColors.whiteColor,
      ),
    );
  }
}
