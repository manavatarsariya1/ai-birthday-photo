import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/settings/settings_controller.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_button.dart';
import '../../utils/common_switch.dart';
import '../../utils/common_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    LogEventManager.logEvent('settings_view');

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 28.h),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.text(
              title: 'Settings',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: AppColors.blackColor,
            ),
            SizedBox(height: 16.h),

            // ── PRO Upgrade Banner ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: CommonText.text(
                          title: 'Birthday Photo & Video Maker PRO',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          textColor: AppColors.whiteColor,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.verified_rounded,
                        size: 16.r,
                        color: AppColors.whiteColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  CommonText.text(
                    title:
                        'Unlimited 4K HD Video Exports & all VIP\ncelebration templates unlocked',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.whiteColor.withValues(alpha: 0.9),
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: controller.openPaywall,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(9999.r),
                      ),
                      alignment: Alignment.center,
                      child: CommonText.text(
                        title: 'Upgrade Plan',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.blackColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // ── MY CONTENT AND DATA ───────────────────────────────────
            _SectionHeader('MY CONTENT AND DATA'),
            SizedBox(height: 8.h),
            _SettingsGroupCard(
              children: [
                _SettingsTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Creation',
                  subtitle: 'Stored AI videos & portrait sets',
                  onTap: () => AppToast.showInfo('Coming soon'),
                ),
                _divider(),
                _SettingsTile(
                  icon: Icons.celebration_outlined,
                  title: 'Birthday Reminder',
                  subtitle: 'Family, friends & colleagues',
                  onTap: controller.openReminders,
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // ── PREFERENCES ───────────────────────────────────────────
            _SectionHeader('PREFERENCES'),
            SizedBox(height: 8.h),
            _SettingsGroupCard(
              children: [
                _SettingsTile(
                  icon: Icons.translate_rounded,
                  title: 'Language',
                  subtitle: 'Interface & AI prompts',
                  trailingText: 'English (US)',
                  onTap: controller.openLanguage,
                ),
                _divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Row(
                    children: [
                      _IconBadge(icon: Icons.notifications_none_rounded),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.text(
                              title: 'Notification Preferences',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              textColor: AppColors.blackColor,
                            ),
                            SizedBox(height: 2.h),
                            CommonText.text(
                              title: 'Birthday reminders alerts',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              textColor:
                                  AppColors.blackColor.withValues(alpha: 0.55),
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () => CommonSwitch(
                          value: controller.notificationsEnabled.value,
                          onChanged: (v) =>
                              controller.notificationsEnabled.value = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // ── SUPPORT & FEEDBACK ────────────────────────────────────
            _SectionHeader('SUPPORT & FEEDBACK'),
            SizedBox(height: 8.h),
            _SettingsGroupCard(
              children: [
                _SettingsTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Send Feedback',
                  subtitle: 'Suggest Your ideas to improve',
                  onTap: controller.openFeedback,
                ),
                _divider(),
                _SettingsTile(
                  icon: Icons.star_outline_rounded,
                  title: 'Rate App',
                  subtitle: 'Share love on the App Store',
                  onTap: () => _showRateAppSheet(context),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // ── PREMIUM & CREDITS ─────────────────────────────────────
            _SectionHeader('PREMIUM & CREDITS'),
            SizedBox(height: 8.h),
            _SettingsGroupCard(
              children: [
                _SettingsTile(
                  icon: Icons.laptop_mac_rounded,
                  title: 'Restore Purchases',
                  subtitle: 'Sync existing App Store purchases',
                  onTap: controller.restorePurchases,
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // ── LEGAL CONTENT ─────────────────────────────────────────
            _SectionHeader('LEGAL CONTENT'),
            SizedBox(height: 8.h),
            _SettingsGroupCard(
              children: [
                _SettingsTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Privacy Policy',
                  onTap: () => AppToast.showInfo('Privacy Policy'),
                ),
                _divider(),
                _SettingsTile(
                  icon: Icons.gavel_rounded,
                  title: 'Terms of Use',
                  onTap: () => AppToast.showInfo('Terms of Use'),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // ── Version Footer ────────────────────────────────────────
            Center(
              child: Obx(
                () => CommonText.text(
                  title: controller.appVersionLabel.value,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.blackColor.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        color: AppColors.blackColor.withValues(alpha: 0.06),
      );

  Future<void> _showRateAppSheet(BuildContext context) async {
    LogEventManager.logEvent('rate_app_sheet_view');
    final rating = 5.obs;

    String ratingLabel(int r) {
      switch (r) {
        case 1:
          return '1.0 • Needs Work';
        case 2:
          return '2.0 • Could Be Better';
        case 3:
          return '3.0 • Good';
        case 4:
          return '4.0 • Really Like It!';
        default:
          return '5.0 • Absolutely Love It!';
      }
    }

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
              Container(
                width: 64.r,
                height: 64.r,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cake_rounded,
                  size: 32.r,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(height: 14.h),
              CommonText.text(
                title: 'Enjoying This App?',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
              ),
              SizedBox(height: 6.h),
              CommonText.text(
                title:
                    'Tap a star to your experience. Your love\nfuels magical celebration styles!',
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < rating.value;
                    return GestureDetector(
                      onTap: () => rating.value = i + 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Icon(
                          Icons.star_rounded,
                          size: 34.r,
                          color: filled
                              ? const Color(0xFFF5A623)
                              : AppColors.blackColor.withValues(alpha: 0.15),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9999.r),
                  ),
                  child: CommonText.text(
                    title: ratingLabel(rating.value),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.primaryPink,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              CommonButton.primary(
                onTap: () {
                  LogEventManager.logEvent(
                    'rate_app_submit_click',
                    {'rating': rating.value},
                  );
                  Get.back();
                  AppToast.showSuccess('Thanks for rating us ${rating.value}★!');
                },
                title: 'Rate App',
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () => Get.back(),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                  child: CommonText.text(
                    title: 'Cancel',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.blackColor.withValues(alpha: 0.6),
                  ),
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
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return CommonText.text(
      title: title,
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      textColor: AppColors.blackColor.withValues(alpha: 0.7),
    );
  }
}

class _SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.reminderCardBg,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(children: children),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 18.r,
        color: AppColors.primaryPink,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            _IconBadge(icon: icon),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText.text(
                    title: title,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.blackColor,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    CommonText.text(
                      title: subtitle!,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.blackColor.withValues(alpha: 0.55),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              CommonText.text(
                title: trailingText!,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.65),
              ),
              SizedBox(width: 4.w),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: AppColors.blackColor.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}
