import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_strings.dart';
import '../../controllers/language/language_controller.dart';
import '../../data/models/language_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LanguageController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            // ── Header: Choose Your Language + Done Pill ────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                        children: [
                          TextSpan(text: AppStrings.chooseYour),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
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
                                title: AppStrings.language,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                textColor: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: controller.onDoneTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: CommonText.text(
                        title: AppStrings.done,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CommonText.text(
                title: AppStrings.languageSubtitle,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                maxLines: 2,
              ),
            ),

            SizedBox(height: 16.h),

            // ── Language List (10 languages) ────────────────────
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
                physics: const ClampingScrollPhysics(),
                itemCount: controller.languages.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = controller.languages[index];
                  return Obx(() {
                    final isSelected =
                        controller.selectedCode.value == item.code;
                    return _LanguageTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => controller.selectLanguage(item.code),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageModel item;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(isSelected ? 1.5.r : 0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(14.5.r),
          ),
          child: Row(
            children: [
              // Flag circle
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: CommonText.text(
                  title: item.flagEmoji,
                  fontSize: 22,
                ),
              ),
              SizedBox(width: 14.w),

              // Language name & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText.text(
                      title: item.name,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.blackColor,
                    ),
                    SizedBox(height: 2.h),
                    CommonText.text(
                      title: item.subtitle,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.blackColor.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              // Radio indicator
              Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppColors.borderColor,
                          width: 1.5.r,
                        ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 14.r,
                        color: AppColors.whiteColor,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
