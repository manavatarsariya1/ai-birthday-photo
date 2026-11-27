import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../constant/app_strings.dart';
import '../../controllers/creation/creation_controller.dart';
import '../../data/models/creation_model.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';
import '../../utils/common_unlock_dialog.dart';
import '../../utils/share_helper.dart';

class CreationPreviewScreen extends StatefulWidget {
  const CreationPreviewScreen({super.key});

  @override
  State<CreationPreviewScreen> createState() => _CreationPreviewScreenState();
}

class _CreationPreviewScreenState extends State<CreationPreviewScreen> {
  bool _showWatermark = true;

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as CreationItemModel?;
    final controller = Get.find<CreationController>();
    LogEventManager.logEvent('creation_preview_view');

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
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutes.home),
                    child: Padding(
                      padding: EdgeInsets.all(6.r),
                      child: Icon(
                        Icons.home_outlined,
                        size: 22.r,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      if (item != null) {
                        controller.deleteSingle(item.id);
                      }
                      Get.back();
                    },
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

            // ── Full Preview Card ─────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 18.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item != null && item.path.startsWith('http'))
                        Image.network(item.path, fit: BoxFit.cover)
                      else if (item != null && File(item.path).existsSync())
                        Image.file(File(item.path), fit: BoxFit.cover)
                      else
                        Container(color: AppColors.reminderCardBg),

                      if (_showWatermark)
                        Positioned(
                          right: 6.w,
                          bottom: 6.h,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              CommonUnlockDialog.show(
                                title: 'Remove Watermark',
                                subtitle:
                                    'Watch an ad to remove the watermark, or Go premium for watermark free downloads',
                                buttonTitle: 'Remove Watermark (Ad)',
                                onPrimaryTap: () {
                                  setState(() => _showWatermark = false);
                                },
                                onUpgradeTap: () =>
                                    Get.toNamed(AppRoutes.paywall),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 8.r,
                                right: 8.r,
                                left: 4.w,
                                bottom: 4.h,
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.blackColor
                                          .withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: CommonText.text(
                                      title: AppStrings.appName,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      textColor: AppColors.whiteColor,
                                    ),
                                  ),
                                  Positioned(
                                    top: -6.r,
                                    right: -6.r,
                                    child: Container(
                                      width: 18.r,
                                      height: 18.r,
                                      decoration: const BoxDecoration(
                                        color: AppColors.whiteColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 12.r,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Share Button ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 20.h),
              child: CommonButton.primary(
                onTap: () => ShareHelper.shareText(
                  'Check out my creation made with AI Birthday!',
                ),
                title: 'Share',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
