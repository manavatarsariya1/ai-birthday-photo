import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/home/home_controller.dart';
import '../../controllers/templates/templates_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class UninstallRetentionScreen extends StatelessWidget {
  const UninstallRetentionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LogEventManager.logEvent('uninstall_retention_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
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
              ),
              const Spacer(),
              Container(
                width: 82.r,
                height: 82.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 44.r,
                  color: AppColors.primaryPink,
                ),
              ),
              SizedBox(height: 18.h),
              CommonText.text(
                title: 'Wait! Before You Go...',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              CommonText.text(
                title:
                    "We'd hate to see you leave. Here's what\nyou'll miss out on:",
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.reminderCardBg,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  children: [
                    _PerkRow(
                      icon: Icons.auto_awesome_rounded,
                      title: 'AI Birthday Photos',
                      subtitle: 'Create studio-quality memories in seconds',
                      onTap: () {
                        Get.offAllNamed(AppRoutes.home);
                        if (Get.isRegistered<HomeController>()) {
                          Get.find<HomeController>().selectedTabIndex.value = 1;
                        }
                      },
                    ),
                    SizedBox(height: 12.h),
                    _PerkRow(
                      icon: Icons.movie_creation_rounded,
                      title: 'AI Birthday Videos',
                      subtitle: 'Cinematic 4K celebration reels',
                      onTap: () {
                        Get.offAllNamed(AppRoutes.home);
                        if (Get.isRegistered<HomeController>()) {
                          final t = Get.isRegistered<TemplatesController>()
                              ? Get.find<TemplatesController>()
                              : Get.put(TemplatesController());
                          t.onTypeChanged(1);
                          Get.find<HomeController>().selectedTabIndex.value = 1;
                        }
                      },
                    ),
                    SizedBox(height: 12.h),
                    _PerkRow(
                      icon: Icons.notifications_active_rounded,
                      title: 'Smart Birthday Reminders',
                      subtitle: 'Never miss a loved one’s special day',
                      onTap: () {
                        Get.offAllNamed(AppRoutes.home);
                        if (Get.isRegistered<HomeController>()) {
                          Get.find<HomeController>().selectedTabIndex.value = 2;
                        }
                      },
                    ),
                    SizedBox(height: 12.h),
                    _PerkRow(
                      icon: Icons.card_giftcard_rounded,
                      title: 'Personalized Greeting Cards',
                      subtitle: 'Custom cards, wishes & captions ready to share',
                      onTap: () {
                        Get.offAllNamed(AppRoutes.home);
                        if (Get.isRegistered<HomeController>()) {
                          final t = Get.isRegistered<TemplatesController>()
                              ? Get.find<TemplatesController>()
                              : Get.put(TemplatesController());
                          t.onTypeChanged(2);
                          Get.find<HomeController>().selectedTabIndex.value = 1;
                        }
                      },
                    ),
                    SizedBox(height: 12.h),
                    _PerkRow(
                      icon: Icons.calculate_rounded,
                      title: 'Age Calculator',
                      subtitle: 'Exact age, next birthday & live stats',
                      onTap: () => Get.toNamed(AppRoutes.ageCalculator),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              CommonButton.primary(
                onTap: () {
                  LogEventManager.logEvent('uninstall_stay_click');
                  Get.offAllNamed(AppRoutes.home);
                },
                title: 'Stay & Keep Creating',
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  LogEventManager.logEvent('uninstall_continue_click');
                  Get.toNamed(AppRoutes.uninstallReason);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                  child: CommonText.text(
                    title: 'Continue to Uninstall',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.blackColor.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PerkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.r, color: AppColors.whiteColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.text(
                  title: title,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.blackColor,
                ),
                SizedBox(height: 2.h),
                CommonText.text(
                  title: subtitle,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.blackColor.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20.r,
            color: AppColors.blackColor.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}
