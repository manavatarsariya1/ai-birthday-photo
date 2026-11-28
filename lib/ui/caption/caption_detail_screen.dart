import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/caption/caption_controller.dart';
import '../../data/models/caption_models.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class CaptionDetailScreen extends StatelessWidget {
  final String title;

  const CaptionDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaptionController>();

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h),

            // ── Top Bar ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
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
                  SizedBox(width: 8.w),
                  CommonText.text(
                    title: title,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.blackColor,
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // ── Captions List ───────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoadingCaptions.value &&
                    controller.generatedCaptions.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPink,
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 200 &&
                        controller.hasMoreCaptions &&
                        !controller.isLoadingMoreCaptions.value) {
                      controller.fetchCaptions(loadMore: true);
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                    physics: const ClampingScrollPhysics(),
                    itemCount: controller.generatedCaptions.length +
                        (controller.isLoadingMoreCaptions.value ? 1 : 0),
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index >= controller.generatedCaptions.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryPink,
                            ),
                          ),
                        );
                      }
                      return CaptionCardWidget(
                        item: controller.generatedCaptions[index],
                        controller: controller,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class CaptionCardWidget extends StatelessWidget {
  final CaptionItemModel item;
  final CaptionController controller;

  const CaptionCardWidget({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.captionCardBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.text(
            title: item.text,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            textColor: AppColors.blackColor.withValues(alpha: 0.85),
            maxLines: 6,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _ActionIconCircle(
                icon: item.isFavorite ? Icons.star : Icons.star_border,
                iconColor: item.isFavorite
                    ? AppColors.primaryPink
                    : AppColors.blackColor.withValues(alpha: 0.65),
                onTap: () => controller.toggleFavorite(item),
              ),
              SizedBox(width: 8.w),
              _ActionIconCircle(
                icon: Icons.copy_outlined,
                iconColor: AppColors.blackColor.withValues(alpha: 0.65),
                onTap: () => controller.copyCaption(item.text),
              ),
              SizedBox(width: 8.w),
              _ActionIconCircle(
                icon: Icons.share_outlined,
                iconColor: AppColors.blackColor.withValues(alpha: 0.65),
                onTap: () => controller.shareCaption(item.text),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => controller.shareToWhatsApp(item.text),
                child: Container(
                  width: 30.r,
                  height: 30.r,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteColor,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(7.r),
                  child: SvgPicture.string(
                    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21l1.65-3.8a9 9 0 1 1 3.4 2.9L3 21"/><path d="M9 10a.5.5 0 0 0 1 0V9a.5.5 0 0 0-1 0v1a5 5 0 0 0 5 5h1a.5.5 0 0 0 0-1h-1a.5.5 0 0 0 0 1"/></svg>',
                    colorFilter: ColorFilter.mode(
                      AppColors.blackColor.withValues(alpha: 0.65),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIconCircle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionIconCircle({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.r,
        height: 30.r,
        decoration: const BoxDecoration(
          color: AppColors.whiteColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16.r, color: iconColor),
      ),
    );
  }
}
