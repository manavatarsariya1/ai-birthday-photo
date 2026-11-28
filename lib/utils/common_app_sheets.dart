import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constant/app_assets.dart';
import '../routes/app_routes.dart';
import '../services/log_event_manager.dart';
import '../theme/app_colors.dart';
import 'common_button.dart';
import 'common_text.dart';

class CommonAppSheets {
  CommonAppSheets._();

  static Future<void> showInsufficientCredits() {
    LogEventManager.logEvent('insufficient_credits_sheet_view');
    return _showIllustrationSheet(
      title: 'Insufficient Credits',
      subtitle:
          'You need more credits to continue\ncreating your birthday photos & videos',
      imagePath: AppAssets.imgInsufficientCoins,
      primaryTitle: 'Get More Credits',
      secondaryTitle: 'Cancel',
      onPrimaryTap: () {
        Get.back();
        Get.toNamed(AppRoutes.paywall);
      },
    );
  }

  static Future<void> showPhotoAccess({VoidCallback? onAllow}) {
    LogEventManager.logEvent('photo_access_sheet_view');
    return _showIllustrationSheet(
      title: 'Allow Photo Access',
      subtitle:
          'We need access to your photos to create\nstunning birthday photo & Videos with AI',
      imagePath: AppAssets.imgGalleryAccess,
      primaryTitle: 'Allow Access',
      secondaryTitle: 'Not Now',
      onPrimaryTap: () async {
        Get.back();
        if (onAllow != null) {
          onAllow();
        } else {
          await openAppSettings();
        }
      },
    );
  }

  static Future<void> showNotificationPermission({VoidCallback? onAllow}) {
    LogEventManager.logEvent('notification_sheet_view');
    return _showIllustrationSheet(
      title: 'Stay Updated',
      subtitle:
          'Get birthday reminders, special templates\nand updates on your creations',
      imagePath: AppAssets.imgNotification,
      primaryTitle: 'Allow Notification',
      secondaryTitle: 'Not Now',
      onPrimaryTap: () async {
        Get.back();
        if (onAllow != null) {
          onAllow();
        } else {
          final status = await Permission.notification.request();
          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
        }
      },
    );
  }

  static Future<void> _showIllustrationSheet({
    required String title,
    required String subtitle,
    required String imagePath,
    required String primaryTitle,
    required String secondaryTitle,
    required VoidCallback onPrimaryTap,
  }) {
    return Get.bottomSheet(
      Container(
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
            SizedBox(height: 12.h),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: CommonText.text(
                    title: title,
                    fontSize: 19,
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
            SizedBox(height: 6.h),
            CommonText.text(
              title: subtitle,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              textColor: AppColors.blackColor.withValues(alpha: 0.55),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.h),
            Image.asset(
              imagePath,
              width: 170.w,
              height: 150.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),
            CommonButton.primary(
              onTap: onPrimaryTap,
              title: primaryTitle,
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () => Get.back(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                child: CommonText.text(
                  title: secondaryTitle,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.blackColor.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
    );
  }
}
