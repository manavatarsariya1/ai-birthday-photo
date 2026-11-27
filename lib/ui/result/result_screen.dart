import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';
import '../../utils/common_unlock_dialog.dart';
import '../../utils/share_helper.dart';
import 'report_problem_screen.dart';
import 'result_preview_screen.dart';

class ResultScreen extends StatefulWidget {
  final File beforeImage;
  final bool isVideo;
  final bool isAnniversary;

  const ResultScreen({
    super.key,
    required this.beforeImage,
    this.isVideo = false,
    this.isAnniversary = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showAfter = true;
  bool _showWatermark = true;

  @override
  void initState() {
    super.initState();
    LogEventManager.logEvent('result_view');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SizedBox(height: 8.h),

              // ── Top Bar: Back | Crown ─────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
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
                            child: SvgPicture.asset(
                              AppAssets.icReport,
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
                            child: SvgPicture.asset(
                              AppAssets.icHome,
                              width: 19.r,
                              height: 19.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // ── Title & Subtitle ──────────────────────────────
              CommonText.text(
                title: 'Your Birthday Creation is Ready!',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              CommonText.text(
                title: 'Do you want to change anything?',
                fontSize: 12,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // ── Main Result Image Card ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: SizedBox(
                    height: 380.h,
                    width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _showAfter
                          ? Image.asset(
                              AppAssets.templatesSample,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            )
                          : Image.file(
                              widget.beforeImage,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),

                      // Top-left: Eye, Like, Dislike
                      Positioned(
                        top: 10.h,
                        left: 10.w,
                        child: Column(
                          children: [
                            _OverlayCircleBtn(
                              icon: Icons.visibility_outlined,
                              onTap: () {
                                LogEventManager.logEvent('result_preview_click');
                                Get.to(
                                  () => ResultPreviewScreen(
                                    showWatermark: _showWatermark,
                                    onRemoveWatermark: () =>
                                        Get.toNamed(AppRoutes.paywall),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 8.h),
                            _OverlayCircleBtn(
                              icon: Icons.thumb_up_alt_outlined,
                              onTap: () =>
                                  LogEventManager.logEvent('result_like_click'),
                            ),
                            SizedBox(height: 8.h),
                            _OverlayCircleBtn(
                              icon: Icons.thumb_down_alt_outlined,
                              onTap: () => LogEventManager.logEvent(
                                  'result_dislike_click'),
                            ),
                          ],
                        ),
                      ),

                      // Center Play Button for Video
                      if (widget.isVideo)
                        Center(
                          child: Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.blackColor.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 30.r,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),

                      // Bottom-left: Before | After Toggle (Photo only)
                      if (!widget.isVideo)
                        Positioned(
                        left: 10.w,
                        bottom: 10.h,
                        child: Container(
                          padding: EdgeInsets.all(3.r),
                          decoration: BoxDecoration(
                            color: AppColors.blackColor.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ToggleChip(
                                title: 'Before',
                                isSelected: !_showAfter,
                                onTap: () => setState(() => _showAfter = false),
                              ),
                              _ToggleChip(
                                title: 'After',
                                isSelected: _showAfter,
                                onTap: () => setState(() => _showAfter = true),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom-right: Watermark (App Name)
                      if (_showWatermark)
                        Positioned(
                          right: 4.w,
                          bottom: 4.h,
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

              SizedBox(height: 14.h),

              // ── Save Photo / Video CTA ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CommonButton.primary(
                  title: widget.isVideo ? 'Save Video' : 'Save Photo',
                  onTap: () => LogEventManager.logEvent('result_save_click'),
                ),
              ),

              SizedBox(height: 10.h),

              // ── Regenerate & Share Row ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _SecondaryActionBtn(
                        icon: Icons.auto_awesome,
                        svgPath: AppAssets.icRegenerate,
                        title: 'Regenerate',
                        onTap: () =>
                            LogEventManager.logEvent('result_regenerate_click'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _SecondaryActionBtn(
                        icon: Icons.ios_share,
                        title: 'Share',
                        onTap: () {
                          LogEventManager.logEvent('result_share_click');
                          ShareHelper.shareText(
                            'Check out my creation made with AI Birthday!',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ── More Images (Full Width Edge-to-Edge) ─────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CommonText.text(
                    title: widget.isVideo ? 'MORE VIDEOS' : 'MORE IMAGES',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    textColor: AppColors.blackColor,
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              SizedBox(
                height: 112.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 4,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: SizedBox(
                        width: 98.w,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              AppAssets.sampleTemplate,
                              fit: BoxFit.cover,
                            ),
                            if (widget.isVideo)
                              Center(
                                child: Container(
                                  width: 28.r,
                                  height: 28.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.blackColor
                                        .withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 18.r,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayCircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.r,
        height: 30.r,
        decoration: BoxDecoration(
          color: AppColors.blackColor.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16.r, color: AppColors.whiteColor),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.whiteColor : AppColors.transparentColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: CommonText.text(
          title: title,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          textColor: isSelected ? AppColors.blackColor : AppColors.whiteColor,
        ),
      ),
    );
  }
}

class _SecondaryActionBtn extends StatelessWidget {
  final IconData icon;
  final String? svgPath;
  final String title;
  final VoidCallback onTap;

  const _SecondaryActionBtn({
    required this.icon,
    this.svgPath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.indicatorInactive,
            width: 1.r,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgPath != null)
              SvgPicture.asset(
                svgPath!,
                width: 17.r,
                height: 17.r,
              )
            else
              Icon(icon, size: 17.r, color: AppColors.blackColor),
            SizedBox(width: 6.w),
            CommonText.text(
              title: title,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textColor: AppColors.blackColor,
            ),
          ],
        ),
      ),
    );
  }
}
