import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../controllers/card/card_creation_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_button.dart';
import '../../utils/common_svg_image.dart';
import '../../utils/common_text.dart';
import '../../utils/common_unlock_dialog.dart';
import '../../utils/share_helper.dart';
import '../result/report_problem_screen.dart';

class CardResultScreen extends StatefulWidget {
  const CardResultScreen({super.key});

  @override
  State<CardResultScreen> createState() => _CardResultScreenState();
}

class _CardResultScreenState extends State<CardResultScreen> {
  bool _showWatermark = true;
  bool? _liked;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CardCreationController>();
    LogEventManager.logEvent('card_result_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 16.h),
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.to(() => const ReportProblemScreen()),
                        child: Padding(
                          padding: EdgeInsets.all(6.r),
                          child: CommonSvgImage(
                            imagePath: AppAssets.icReport,
                            width: 19.r,
                            height: 19.r,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () => Get.offAllNamed(AppRoutes.home),
                        child: Padding(
                          padding: EdgeInsets.all(6.r),
                          child: CommonSvgImage(
                            imagePath: AppAssets.icHome,
                            width: 19.r,
                            height: 19.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              CommonText.text(
                title: 'Your Birthday Card is Ready!',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
              ),
              SizedBox(height: 2.h),
              CommonText.text(
                title: 'Do you want to change anything?',
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
              ),
              SizedBox(height: 14.h),

              // ── Card Preview ────────────────────────────────────────
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      controller.templateImageUrl.value.startsWith('http')
                          ? Image.network(
                              controller.templateImageUrl.value,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              AppAssets.templatesSample,
                              fit: BoxFit.cover,
                            ),

                      // Top-left: View, Like, Dislike
                      Positioned(
                        left: 10.w,
                        top: 10.h,
                        child: Column(
                          children: [
                            _ActionCircle(
                              icon: Icons.visibility_outlined,
                              onTap: () =>
                                  Get.toNamed(AppRoutes.cardFullPreview),
                            ),
                            SizedBox(height: 8.h),
                            _ActionCircle(
                              icon: Icons.thumb_up_alt_outlined,
                              isActive: _liked == true,
                              onTap: () => setState(() => _liked = true),
                            ),
                            SizedBox(height: 8.h),
                            _ActionCircle(
                              icon: Icons.thumb_down_alt_outlined,
                              isActive: _liked == false,
                              onTap: () => setState(() => _liked = false),
                            ),
                          ],
                        ),
                      ),

                      // Bottom-right: Watermark
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
              SizedBox(height: 14.h),

              // ── Save Card + Regenerate & Share ──────────────────────
              CommonButton.primary(
                onTap: () => AppToast.showSuccess('Card saved!'),
                title: 'Save Card',
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.generateCard,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(9999.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CommonSvgImage(
                              imagePath: AppAssets.icRegenerate,
                              width: 18.r,
                              height: 18.r,
                            ),
                            SizedBox(width: 6.w),
                            CommonText.text(
                              title: 'Regenerate',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              textColor: AppColors.blackColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ShareHelper.shareText(
                        'Check out my Birthday Card created with AI Birthday!',
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(9999.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.ios_share_rounded,
                              size: 18.r,
                              color: AppColors.blackColor,
                            ),
                            SizedBox(width: 6.w),
                            CommonText.text(
                              title: 'Share',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              textColor: AppColors.blackColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionCircle({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryPink
              : AppColors.blackColor.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 17.r,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }
}
