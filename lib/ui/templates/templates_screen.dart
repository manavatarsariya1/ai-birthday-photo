import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../controllers/templates/templates_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_autoplay_video.dart';
import '../../utils/common_shimmer_box.dart';
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
              if (controller.isLoading.value && cats.isEmpty) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, __) => SizedBox(
                    width: 86.w,
                    child: CommonShimmerBox(borderRadius: 9999.r),
                  ),
                );
              }
              return SingleChildScrollView(
                controller: controller.categoryScrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children: List.generate(cats.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < cats.length - 1 ? 8.w : 0,
                      ),
                      child: Builder(
                        builder: (pillContext) {
                          return Obx(() {
                            final isActive =
                                controller.selectedCategoryIndex.value == index;
                            return GestureDetector(
                              onTap: () {
                                controller.onCategoryChanged(index);
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (pillContext.mounted) {
                                    Scrollable.ensureVisible(
                                      pillContext,
                                      alignment: 0.5,
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                });
                              },
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
                      ),
                    );
                  }),
                ),
              );
            }),
          ),

          SizedBox(height: 14.h),

          // ── 2-Column Templates Grid ───────────────────────────
          Expanded(
            child: Obx(() {
              final items = controller.currentTemplates;
              final isLoading = controller.isLoading.value;

              if (!isLoading && items.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.primaryPink,
                  onRefresh: controller.fetchTemplates,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 0.55.sh,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 48.r,
                              color: AppColors.blackColor.withValues(alpha: 0.25),
                            ),
                            SizedBox(height: 10.h),
                            CommonText.text(
                              title: 'No templates available',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              textColor:
                                  AppColors.blackColor.withValues(alpha: 0.45),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              final count = items.isNotEmpty ? items.length : 6;
              final isVideo = controller.isVideoMode;

              return RefreshIndicator(
                color: AppColors.primaryPink,
                onRefresh: controller.fetchTemplates,
                child: GridView.builder(
                  key: ValueKey(
                    '${controller.selectedTypeIndex.value}_${controller.selectedCategoryIndex.value}',
                  ),
                  cacheExtent: 1200,
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  itemCount: count,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.76,
                  ),
                  itemBuilder: (context, index) {
                    if (controller.isLoading.value && items.isEmpty) {
                      return const CommonShimmerBox();
                    }
                    final imageUrl =
                        items.isNotEmpty ? items[index].image : '';
                    final pathLower =
                        (Uri.tryParse(imageUrl)?.path ?? imageUrl)
                            .toLowerCase();
                    final isVideoFile = pathLower.endsWith('.mp4') ||
                        pathLower.endsWith('.mov') ||
                        pathLower.endsWith('.m4v') ||
                        pathLower.endsWith('.webm') ||
                        pathLower.endsWith('.mkv') ||
                        pathLower.endsWith('.avi');

                    return GestureDetector(
                      onTap: () => controller.onTemplateTap(index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imageUrl.startsWith('http')
                                ? (isVideoFile
                                    ? CommonAutoPlayVideo(videoUrl: imageUrl)
                                    : CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        memCacheWidth: 500,
                                        fadeInDuration: Duration.zero,
                                        fadeOutDuration: Duration.zero,
                                        placeholder: (_, __) => Shimmer.fromColors(
                                          baseColor: const Color(0xFFE6E6EC),
                                          highlightColor:
                                              const Color(0xFFF7F7FA),
                                          child: Container(
                                            color: AppColors.whiteColor,
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          color: AppColors.captionCardBg,
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: 28.r,
                                            color: AppColors.blackColor
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                      ))
                                : Container(
                                    color: AppColors.captionCardBg,
                                    child: Icon(
                                      isVideo
                                          ? Icons.videocam_outlined
                                          : Icons.image_outlined,
                                      size: 28.r,
                                      color: AppColors.blackColor
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
