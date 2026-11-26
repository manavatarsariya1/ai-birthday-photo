import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_strings.dart';
import '../../controllers/onboarding/onboarding_controller.dart';
import '../../data/models/onboarding_page_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar (Back on pages 2-3, Skip on right) ──────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    if (controller.currentIndex.value == 0) {
                      return SizedBox(width: 24.r, height: 24.r);
                    }
                    return GestureDetector(
                      onTap: controller.onBackTap,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.r,
                          color: AppColors.blackColor,
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: controller.onSkipTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 4.h,
                      ),
                      child: CommonText.text(
                        title: AppStrings.skip,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.blackColor.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── PageView Content ────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageContent(
                    page: controller.pages[index],
                  );
                },
              ),
            ),

            // ── Page Indicator Dots ─────────────────────────────
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.pages.length,
                  (index) {
                    final isActive = controller.currentIndex.value == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: isActive ? 22.w : 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.primaryGradient : null,
                        color: isActive ? null : AppColors.indicatorInactive,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    );
                  },
                ),
              );
            }),

            SizedBox(height: 20.h),

            // ── Bottom Action Button (CommonButton.primary) ─────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Obx(() {
                final isLast =
                    controller.currentIndex.value == controller.pages.length - 1;
                return CommonButton.primary(
                  onTap: controller.onNextTap,
                  title: isLast ? AppStrings.continueText : AppStrings.next,
                );
              }),
            ),

            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingPageModel page;

  const _OnboardingPageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // ── Illustration ────────────────────────────────────
          Expanded(
            child: Center(
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // ── Title with Gradient Highlight ───────────────────
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.blackColor,
              ),
              children: [
                TextSpan(text: page.titlePrefix),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: CommonText.text(
                      title: page.titleHighlight,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.whiteColor,
                    ),
                  ),
                ),
                if (page.titleSuffix.isNotEmpty)
                  TextSpan(text: page.titleSuffix),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // ── Description ─────────────────────────────────────
          CommonText.text(
            title: page.description,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            textColor: AppColors.blackColor.withValues(alpha: 0.55),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
