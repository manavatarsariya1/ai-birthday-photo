import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../controllers/splash/splash_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  // Staggered animations
  late final Animation<double> _photo1Anim;
  late final Animation<double> _photo2Anim;
  late final Animation<double> _photo3Anim;
  late final Animation<double> _balloonAnim;
  late final Animation<double> _giftAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _subtitleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _photo1Anim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _photo2Anim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.10, 0.45, curve: Curves.easeOutCubic),
    );
    _photo3Anim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.18, 0.52, curve: Curves.easeOutCubic),
    );
    _balloonAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.28, 0.62, curve: Curves.easeOutBack),
    );
    _giftAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.42, 0.74, curve: Curves.easeOutBack),
    );
    _titleAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.60, 0.88, curve: Curves.easeOutBack),
    );
    _subtitleAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.76, 1.0, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final s = screenW / 422.0;

            return Column(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Balloons (drop from top, behind couple photo)
                          Positioned(
                            top: 14 * s,
                            left: 62 * s,
                            child: Opacity(
                              opacity: _balloonAnim.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  -70 * s * (1 - _balloonAnim.value),
                                ),
                                child: Transform.rotate(
                                  angle: 4.18 * math.pi / 180,
                                  child: Image.asset(
                                    AppAssets.splashBalloon,
                                    width: 168 * s,
                                    height: 270 * s,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. Photo 1 — Birthday boy (slide from right)
                          Positioned(
                            top: 102 * s,
                            left: 204 * s,
                            child: Opacity(
                              opacity: _photo1Anim.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(
                                  60 * s * (1 - _photo1Anim.value),
                                  0,
                                ),
                                child: _SplashPhotoCard(
                                  assetPath: AppAssets.splashPhoto1,
                                  width: 158 * s,
                                  height: 206 * s,
                                  radius: 22 * s,
                                  borderWidth: 4.5 * s,
                                  angleDeg: -3.4,
                                ),
                              ),
                            ),
                          ),

                          // 3. Right ribbon
                          Positioned(
                            top: 200 * s,
                            left: 364 * s,
                            child: Opacity(
                              opacity: _giftAnim.value.clamp(0.0, 1.0),
                              child: Image.asset(
                                AppAssets.splashRibbonRight,
                                width: 34 * s,
                                height: 40 * s,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // 4. Photo 2 — Couple (slide from left, in front of balloons)
                          Positioned(
                            top: 196 * s,
                            left: 34 * s,
                            child: Opacity(
                              opacity: _photo2Anim.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(
                                  -60 * s * (1 - _photo2Anim.value),
                                  0,
                                ),
                                child: _SplashPhotoCard(
                                  assetPath: AppAssets.splashPhoto2,
                                  width: 158 * s,
                                  height: 206 * s,
                                  radius: 22 * s,
                                  borderWidth: 4.5 * s,
                                  angleDeg: -3.74,
                                ),
                              ),
                            ),
                          ),

                          // 5. Photo 3 — Girl (slide from right)
                          Positioned(
                            top: 320 * s,
                            left: 206 * s,
                            child: Opacity(
                              opacity: _photo3Anim.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(
                                  60 * s * (1 - _photo3Anim.value),
                                  0,
                                ),
                                child: _SplashPhotoCard(
                                  assetPath: AppAssets.splashPhoto3,
                                  width: 158 * s,
                                  height: 206 * s,
                                  radius: 22 * s,
                                  borderWidth: 4.5 * s,
                                  angleDeg: 4.31,
                                ),
                              ),
                            ),
                          ),

                          // 6. Left ribbon (above gift box)
                          Positioned(
                            top: 414 * s,
                            left: 44 * s,
                            child: Opacity(
                              opacity: _giftAnim.value.clamp(0.0, 1.0),
                              child: Image.asset(
                                AppAssets.splashRibbonLeft,
                                width: 35 * s,
                                height: 26 * s,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // 7. Gift Box (pop in with bounce)
                          Positioned(
                            top: 390 * s,
                            left: 55 * s,
                            child: Opacity(
                              opacity: _giftAnim.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: 0.5 + 0.5 * _giftAnim.value,
                                child: Transform.rotate(
                                  angle: -5 * math.pi / 180,
                                  child: Image.asset(
                                    AppAssets.splashGiftBox,
                                    width: 152 * s,
                                    height: 156 * s,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 8. Bottom confetti
                          Positioned(
                            top: 532 * s,
                            left: 78 * s,
                            child: Opacity(
                              opacity: _giftAnim.value.clamp(0.0, 1.0),
                              child: Image.asset(
                                AppAssets.splashConfettiBottom,
                                width: 18 * s,
                                height: 15 * s,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // 9. Party cap (top-left of AI Birthday)
                          Positioned(
                            top: 556 * s,
                            left: 65 * s,
                            child: Opacity(
                              opacity: _titleAnim.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: 0.6 + 0.4 * _titleAnim.value,
                                child: Image.asset(
                                  AppAssets.splashCap,
                                  width: 44 * s,
                                  height: 54 * s,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          // 10. Confetti burst (top-right of AI Birthday)
                          Positioned(
                            top: 564 * s,
                            left: 310 * s,
                            child: Opacity(
                              opacity: _titleAnim.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: 0.6 + 0.4 * _titleAnim.value,
                                child: Image.asset(
                                  AppAssets.splashNameAbove,
                                  width: 44 * s,
                                  height: 38 * s,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          // 11. Title: AI Birthday
                          Positioned(
                            top: 594 * s,
                            left: 0,
                            right: 0,
                            child: Opacity(
                              opacity: _titleAnim.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: 0.75 + 0.25 * _titleAnim.value,
                                child: Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        AppColors.primaryGradient.createShader(
                                      Rect.fromLTWH(
                                        0,
                                        0,
                                        bounds.width,
                                        bounds.height,
                                      ),
                                    ),
                                    child: CommonText.text(
                                      title: AppStrings.splashTitle,
                                      fontSize: 44 * s / 1.sp,
                                      fontWeight: FontWeight.w800,
                                      textColor: AppColors.whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 12. Subtitle: Photo & Video Maker
                          Positioned(
                            top: 644 * s,
                            left: 0,
                            right: 0,
                            child: Opacity(
                              opacity: _subtitleAnim.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  16 * s * (1 - _subtitleAnim.value),
                                ),
                                child: Center(
                                  child: CommonText.text(
                                    title: AppStrings.splashSubtitle,
                                    fontSize: 20 * s / 1.sp,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppColors.blackColor
                                        .withValues(alpha: 0.72),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 13. Curved pink underline
                          Positioned(
                            top: 668 * s,
                            left: 225 * s,
                            child: Opacity(
                              opacity: _subtitleAnim.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  16 * s * (1 - _subtitleAnim.value),
                                ),
                                child: Image.asset(
                                  AppAssets.splashNamesBottom,
                                  width: 97 * s,
                                  height: 11.86 * s,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // ── Bottom Progress Bar ─────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 56.w),
                  child: LayoutBuilder(
                    builder: (context, barConstraints) {
                      return Container(
                        height: 4.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.indicatorInactive,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Obx(
                            () => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: barConstraints.maxWidth *
                                  controller.progress.value.clamp(0.0, 1.0),
                              height: 4.h,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12.h),
                CommonText.text(
                  title: AppStrings.initializingEngine,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  textColor: AppColors.blackColor.withValues(alpha: 0.45),
                ),
                SizedBox(height: 28.h),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashPhotoCard extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final double radius;
  final double borderWidth;
  final double angleDeg;

  const _SplashPhotoCard({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.radius,
    required this.borderWidth,
    required this.angleDeg,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angleDeg * math.pi / 180,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.1),
              blurRadius: 14.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - borderWidth),
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
