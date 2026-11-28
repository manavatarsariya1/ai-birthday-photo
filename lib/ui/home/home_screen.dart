import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../controllers/home/home_controller.dart';
import '../../data/models/home_models.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_autoplay_video.dart';
import '../../utils/common_shimmer_box.dart';
import '../../utils/common_text.dart';
import '../reminders/reminders_screen.dart';
import '../settings/settings_screen.dart';
import '../templates/templates_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Obx(() {
        if (controller.selectedTabIndex.value == 1) {
          return const TemplatesScreen();
        }
        if (controller.selectedTabIndex.value == 2) {
          return const RemindersScreen();
        }
        if (controller.selectedTabIndex.value == 3) {
          return const SettingsScreen();
        }
        return SafeArea(
          child: RefreshIndicator(
            color: AppColors.primaryPink,
            onRefresh: controller.refreshHomeSections,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // ── Header ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.text(
                          title: AppStrings.homeTitle,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          textColor: AppColors.blackColor,
                        ),
                        SizedBox(height: 2.h),
                        CommonText.text(
                          title: AppStrings.homeSubtitle,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.blackColor.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Coins Pill
                  GestureDetector(
                    onTap: controller.onCoinsTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.indicatorInactive,
                          width: 1.r,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppAssets.coin,
                            width: 18.r,
                            height: 18.r,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 5.w),
                          Obx(
                            () => CommonText.text(
                              title: '${controller.coinsCount.value}',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              textColor: AppColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Premium Crown
                  GestureDetector(
                    onTap: controller.onPremiumTap,
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(7.r),
                      child: SvgPicture.asset(
                        AppAssets.icPremiumCrown,
                        colorFilter: const ColorFilter.mode(
                          AppColors.whiteColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ),

              SizedBox(height: 16.h),

              // ── Top 2 Hero Cards (Photo & Video) ──────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(() {
                  if (controller.isLoadingHomeSections.value &&
                      controller.heroPhotoUrl.value.isEmpty) {
                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 185.h,
                            child: const CommonShimmerBox(borderRadius: 18),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: SizedBox(
                            height: 185.h,
                            child: const CommonShimmerBox(borderRadius: 18),
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: _HeroFeatureCard(
                          imagePath: controller.heroPhotoUrl.value,
                          title: controller.heroPhotoTitle.value,
                          subtitle: 'Luxe Studio Magic',
                          onTap: controller.onBirthdayPhotoTap,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _HeroFeatureCard(
                          imagePath: controller.heroVideoUrl.value,
                          title: controller.heroVideoTitle.value,
                          subtitle: 'Cinematic 4K Reels',
                          isVideo: true,
                          onTap: controller.onBirthdayVideoTap,
                        ),
                      ),
                    ],
                  );
                }),
              ),

              SizedBox(height: 20.h),

              // ── Celebration Tools ─────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.text(
                      title: AppStrings.celebrationTools,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      textColor: AppColors.blackColor,
                    ),
                    SizedBox(height: 12.h),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.tools.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 0.98,
                      ),
                      itemBuilder: (context, index) {
                        final tool = controller.tools[index];
                        return _ToolCard(
                          tool: tool,
                          onTap: () => controller.onToolTap(tool.id),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // ── Trending Templates (Full Width Edge-to-Edge) ──
              Obx(() {
                if (!controller.isLoadingHomeSections.value &&
                    controller.dynamicTrendingTemplates.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      if (controller.isLoadingHomeSections.value &&
                          controller.trendingSectionTitle.value.isEmpty) {
                        return Shimmer.fromColors(
                          baseColor: const Color(0xFFD6D6E0),
                          highlightColor: const Color(0xFFF5F5FA),
                          child: Container(
                            width: 140.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        );
                      }
                      return CommonText.text(
                        title: (controller.trendingSectionTitle.value.isNotEmpty
                                ? controller.trendingSectionTitle.value
                                : AppStrings.trendingTemplates)
                            .toUpperCase(),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        textColor: AppColors.blackColor,
                      );
                    }),
                    GestureDetector(
                      onTap: controller.onViewAllTemplatesTap,
                      child: CommonText.text(
                        title: AppStrings.viewAll,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        textColor:
                            AppColors.blackColor.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              SizedBox(
                height: 156.h,
                child: Obx(() {
                  if (controller.isLoadingHomeSections.value &&
                      controller.dynamicTrendingTemplates.isEmpty) {
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (_, __) => SizedBox(
                        width: 118.w,
                        child: const CommonShimmerBox(borderRadius: 16),
                      ),
                    );
                  }
                  final list = controller.dynamicTrendingTemplates;
                  if (list.isEmpty) return const SizedBox.shrink();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    physics: const ClampingScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final tpl = list[index];
                      return _TrendingTemplateCard(
                        template: tpl,
                        onTap: () => controller.onTemplateTap(
                          tpl.id,
                          type: tpl.type,
                        ),
                      );
                    },
                  );
                }),
              ),

              SizedBox(height: 20.h),
                  ],
                );
              }),

              // ── Upcoming Birthdays ────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText.text(
                          title: AppStrings.upcomingBirthdays,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          textColor: AppColors.blackColor,
                        ),
                        GestureDetector(
                          onTap: controller.onAddNewBirthdayTap,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: CommonText.text(
                              title: AppStrings.addNew,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              textColor: AppColors.primaryPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    Obx(() {
                      final items = controller.upcomingBirthdays;
                      if (items.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 16.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: AppColors.borderColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Center(
                            child: CommonText.text(
                              title: 'No upcoming birthdays this month',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              textColor:
                                  AppColors.blackColor.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _UpcomingBirthdayTile(
                            item: item,
                            onWishTap: () => controller.onWishTap(item.id),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
        ),
        );
      }),

      // ── Bottom Navigation Bar ─────────────────────────────────
      bottomNavigationBar: Obx(() {
        final current = controller.selectedTabIndex.value;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: 0.05),
                blurRadius: 12.r,
                offset: Offset(0, -3.h),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: _BottomNavItem(
                      iconPath: AppAssets.icBottomHome,
                      label: AppStrings.navHome,
                      isSelected: current == 0,
                      onTap: () => controller.onTabChanged(0),
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      iconPath: AppAssets.icBottomTemplates,
                      label: AppStrings.navTemplates,
                      iconSize: 19.r,
                      isSelected: current == 1,
                      onTap: () => controller.onTabChanged(1),
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      iconPath: AppAssets.icBottomReminders,
                      label: AppStrings.navReminders,
                      isSelected: current == 2,
                      onTap: () => controller.onTabChanged(2),
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      iconPath: AppAssets.icBottomSettings,
                      label: AppStrings.navSettings,
                      isSelected: current == 3,
                      onTap: () => controller.onTabChanged(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _HeroFeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool isVideo;
  final VoidCallback onTap;

  const _HeroFeatureCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.isVideo = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          height: 206.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imagePath.startsWith('http')
                  ? (isVideo &&
                          ((Uri.tryParse(imagePath)?.path ?? imagePath)
                                  .toLowerCase()
                                  .endsWith('.mp4') ||
                              (Uri.tryParse(imagePath)?.path ?? imagePath)
                                  .toLowerCase()
                                  .endsWith('.mov') ||
                              (Uri.tryParse(imagePath)?.path ?? imagePath)
                                  .toLowerCase()
                                  .endsWith('.webm'))
                      ? CommonAutoPlayVideo(videoUrl: imagePath)
                      : CachedNetworkImage(
                          imageUrl: imagePath,
                          fit: BoxFit.cover,
                          memCacheWidth: 500,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: const Color(0xFFE6E6EC),
                            highlightColor: const Color(0xFFF7F7FA),
                            child: Container(color: AppColors.whiteColor),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.reminderCardBg,
                            child: Icon(
                              isVideo
                                  ? Icons.videocam_outlined
                                  : Icons.image_outlined,
                              size: 28.r,
                              color:
                                  AppColors.blackColor.withValues(alpha: 0.2),
                            ),
                          ),
                        ))
                  : Container(
                      color: AppColors.reminderCardBg,
                      child: Icon(
                        isVideo
                            ? Icons.videocam_outlined
                            : Icons.image_outlined,
                        size: 28.r,
                        color: AppColors.blackColor.withValues(alpha: 0.2),
                      ),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparentColor,
                      AppColors.blackColor.withValues(alpha: 0.72),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
              if (isVideo && !imagePath.startsWith('http'))
                Center(
                  child: Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      color: AppColors.blackColor.withValues(alpha: 0.45),
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
                left: 10.w,
                right: 10.w,
                bottom: 10.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText.text(
                      title: title,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.whiteColor,
                    ),
                    CommonText.text(
                      title: subtitle,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.whiteColor.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final CelebrationToolModel tool;
  final VoidCallback onTap;

  const _ToolCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: tool.bgColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                gradient: tool.iconGradient,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(9.r),
              child: SvgPicture.asset(
                tool.iconPath,
                colorFilter: const ColorFilter.mode(
                  AppColors.whiteColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            CommonText.text(
              title: tool.title,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textColor: AppColors.blackColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            CommonText.text(
              title: tool.subtitle,
              fontSize: 9.5,
              fontWeight: FontWeight.w400,
              textColor: AppColors.blackColor.withValues(alpha: 0.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingTemplateCard extends StatelessWidget {
  final TrendingTemplateModel template;
  final VoidCallback onTap;

  const _TrendingTemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: SizedBox(
          width: 124.w,
          child: Stack(
            fit: StackFit.expand,
            children: [
              template.imagePath.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: template.imagePath,
                      fit: BoxFit.cover,
                      memCacheWidth: 500,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: const Color(0xFFE6E6EC),
                        highlightColor: const Color(0xFFF7F7FA),
                        child: Container(color: AppColors.whiteColor),
                      ),
                      errorWidget: (_, __, ___) => Image.asset(
                        AppAssets.sampleTemplate,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(template.imagePath, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparentColor,
                      AppColors.blackColor.withValues(alpha: 0.68),
                    ],
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 8.h,
                child: CommonText.text(
                  title: template.title,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.whiteColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingBirthdayTile extends StatelessWidget {
  final UpcomingBirthdayModel item;
  final VoidCallback onWishTap;

  const _UpcomingBirthdayTile({required this.item, required this.onWishTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: item.avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: CommonText.text(
              title: item.initials,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              textColor: AppColors.whiteColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText.text(
                  title: item.title,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.blackColor,
                ),
                SizedBox(height: 2.h),
                CommonText.text(
                  title: item.subtitle,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  textColor: item.isToday
                      ? AppColors.primaryPink
                      : AppColors.blackColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          if (item.isToday)
            GestureDetector(
              onTap: onWishTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: CommonText.text(
                  title: AppStrings.wishLabel,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.whiteColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final double? iconSize;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.iconPath,
    required this.label,
    this.iconSize,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = AppColors.blackColor.withValues(alpha: 0.5);
    final size = iconSize ?? 22.r;

    final iconWidget = SizedBox(
      width: 22.r,
      height: 22.r,
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(
            isSelected ? AppColors.whiteColor : inactiveColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );

    final labelWidget = CommonText.text(
      title: label,
      fontSize: 12,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      letterSpacing: 0.28,
      textColor: isSelected ? AppColors.whiteColor : inactiveColor,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: iconWidget,
              )
            else
              iconWidget,
            SizedBox(height: 4.h),
            if (isSelected)
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: labelWidget,
              )
            else
              labelWidget,
          ],
        ),
      ),
    );
  }
}
