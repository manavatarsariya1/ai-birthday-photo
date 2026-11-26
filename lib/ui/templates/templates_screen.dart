import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../controllers/templates/templates_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TemplatesController());

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),

          // ── Header ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.text(
                  title: AppStrings.exploreTemplates,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.blackColor,
                ),
                SizedBox(height: 2.h),
                CommonText.text(
                  title: AppStrings.exploreTemplatesSubtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.blackColor.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // ── Segmented Tab: Photo | Video | Card (Sliding Pill) ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 42.h,
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Obx(() {
                final selected = controller.selectedTypeIndex.value;
                return Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeInOut,
                      alignment: Alignment(
                        -1.0 + (selected * 1.0),
                        0.0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / controller.types.length,
                        heightFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(26.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.blackColor.withValues(alpha: 0.06),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(controller.types.length, (index) {
                        final isActive = selected == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => controller.onTypeChanged(index),
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: CommonText.text(
                                title: controller.types[index],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                textColor: isActive
                                    ? AppColors.blackColor
                                    : AppColors.blackColor
                                        .withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }),
            ),
          ),

          SizedBox(height: 12.h),

          // ── Category Filter Chips ─────────────────────────────
          SizedBox(
            height: 36.h,
            child: Obx(() {
              final cats = controller.categories;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: const ClampingScrollPhysics(),
                itemCount: cats.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isActive =
                        controller.selectedCategoryIndex.value == index;
                    return GestureDetector(
                      onTap: () => controller.onCategoryChanged(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: isActive ? AppColors.primaryGradient : null,
                          color: isActive ? null : AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(9999.r),
                          border: Border.all(
                            color: isActive
                                ? AppColors.transparentColor
                                : AppColors.borderColor,
                            width: 1.r,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: CommonText.text(
                          title: cats[index],
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          textColor: isActive
                              ? AppColors.whiteColor
                              : AppColors.blackColor.withValues(alpha: 0.7),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),

          SizedBox(height: 14.h),

          // ── 2-Column Templates Grid ───────────────────────────
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              physics: const ClampingScrollPhysics(),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.76,
              ),
              itemBuilder: (context, index) {
                return Obx(() {
                  final isVideo = controller.isVideoMode;
                  return GestureDetector(
                    onTap: () => controller.onTemplateTap(index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            AppAssets.templatesSample,
                            fit: BoxFit.cover,
                          ),
                          if (isVideo) ...[
                            Center(
                              child: Container(
                                width: 34.r,
                                height: 34.r,
                                decoration: BoxDecoration(
                                  color: AppColors.blackColor
                                      .withValues(alpha: 0.45),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 22.r,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 10.h,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.blackColor
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: CommonText.text(
                                    title: 'Use Template',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
