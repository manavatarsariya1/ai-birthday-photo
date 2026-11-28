import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../controllers/caption/caption_controller.dart';
import '../../data/models/caption_models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';
import 'caption_detail_screen.dart';

class CaptionScreen extends StatelessWidget {
  const CaptionScreen({super.key});

  void _showPersonalizeSheet(
    BuildContext context,
    CaptionController controller,
    CaptionCategoryModel category,
  ) {
    final nameController = TextEditingController();
    final nameFocusNode = FocusNode();
    String? errorText;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CommonText.text(
                        title: 'For ${category.shortName}',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.blackColor,
                      ),
                      SizedBox(height: 2.h),
                      CommonText.text(
                        title: AppStrings.enterNameToPersonalize,
                        fontSize: 11.5,
                        textColor: AppColors.blackColor.withValues(alpha: 0.55),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16.r,
                      color: AppColors.blackColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CommonText.text(
              title: AppStrings.enterName,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              textColor: AppColors.blackColor,
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: nameController,
              focusNode: nameFocusNode,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'^\s+')),
              ],
              onChanged: (_) {
                if (errorText != null) {
                  setModalState(() => errorText = null);
                }
              },
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: AppColors.blackColor,
              ),
              decoration: InputDecoration(
                hintText: 'Alice',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: AppColors.blackColor.withValues(alpha: 0.35),
                ),
                filled: true,
                fillColor: AppColors.captionCardBg,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (errorText != null) ...[
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 14.r,
                    color: AppColors.errorColor,
                  ),
                  SizedBox(width: 4.w),
                  CommonText.text(
                    title: errorText!,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.errorColor,
                  ),
                ],
              ),
            ],
            SizedBox(height: 16.h),
            CommonButton.primary(
              title: AppStrings.generateCaption,
              onTap: () {
                final trimmed = nameController.text.trim();
                if (trimmed.isEmpty) {
                  setModalState(() => errorText = 'Please enter a name');
                  nameFocusNode.requestFocus();
                  return;
                }
                controller.fetchCaptions(
                  categoryId: category.id,
                  name: trimmed,
                );
                Get.back();
                Get.to(
                  () => CaptionDetailScreen(
                    title: category.title,
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.paywall);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: AppColors.sourceCardBorderPink,
                    width: 1.r,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(6.r),
                      child: SvgPicture.asset(
                        AppAssets.icPremiumCrown,
                        colorFilter: const ColorFilter.mode(
                          AppColors.whiteColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CommonText.text(
                                title: AppStrings.upgradeToPro,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                textColor: AppColors.blackColor,
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD60A),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: CommonText.text(
                                  title: '50% OFF',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  textColor: AppColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                          CommonText.text(
                            title: AppStrings.forMoreUniqueCaption,
                            fontSize: 10,
                            textColor: AppColors.blackColor.withValues(
                              alpha: 0.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CommonText.text(
                      title: '${AppStrings.claim} >',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.primaryPink,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CaptionController());

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
                    title: AppStrings.birthdayCaptionTitle,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.blackColor,
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // ── Segmented Tab: Birthday Caption | Saved Caption ─
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
                  final selected = controller.selectedTabIndex.value;
                  return Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeInOut,
                        alignment: Alignment(selected == 0 ? -1.0 : 1.0, 0.0),
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          heightFactor: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(26.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blackColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 6.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.onTabChanged(0),
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: CommonText.text(
                                  title: AppStrings.birthdayCaptionTitle,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  textColor: selected == 0
                                      ? AppColors.blackColor
                                      : AppColors.blackColor.withValues(
                                          alpha: 0.55,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.onTabChanged(1),
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: CommonText.text(
                                  title: AppStrings.savedCaption,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  textColor: selected == 1
                                      ? AppColors.blackColor
                                      : AppColors.blackColor.withValues(
                                          alpha: 0.55,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),

            SizedBox(height: 16.h),

            // ── Tab Content ─────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.selectedTabIndex.value == 1) {
                  if (controller.savedCaptions.isEmpty) {
                    return Center(
                      child: CommonText.text(
                        title: AppStrings.noSavedCaptions,
                        fontSize: 14,
                        textColor: AppColors.blackColor.withValues(alpha: 0.5),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                    physics: const ClampingScrollPhysics(),
                    itemCount: controller.savedCaptions.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      return CaptionCardWidget(
                        item: controller.savedCaptions[index],
                        controller: controller,
                      );
                    },
                  );
                }

                if (controller.isLoadingCategories.value &&
                    controller.categories.isEmpty) {
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 0.88,
                    ),
                    itemBuilder: (_, __) => Shimmer.fromColors(
                      baseColor: const Color(0xFFE6E6EC),
                      highlightColor: const Color(0xFFF7F7FA),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryPink,
                  onRefresh: controller.fetchCategories,
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    itemCount: controller.categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    return GestureDetector(
                      onTap: () =>
                          _showPersonalizeSheet(context, controller, cat),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: cat.bgColor,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (cat.icon.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: cat.icon,
                                width: 72.r,
                                height: 72.r,
                                fit: BoxFit.contain,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: const Color(0xFFE6E6EC),
                                  highlightColor: const Color(0xFFF7F7FA),
                                  child: Container(
                                    width: 72.r,
                                    height: 72.r,
                                    decoration: const BoxDecoration(
                                      color: AppColors.whiteColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.auto_awesome,
                                  size: 28.r,
                                  color: AppColors.primaryPink,
                                ),
                              ),
                            SizedBox(height: 3.h),
                            CommonText.text(
                              title: cat.title.replaceFirst(' ', '\n'),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              textColor: AppColors.blackColor,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
