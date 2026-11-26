import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class ResultPreviewScreen extends StatelessWidget {
  final bool showWatermark;
  final VoidCallback onRemoveWatermark;

  const ResultPreviewScreen({
    super.key,
    required this.showWatermark,
    required this.onRemoveWatermark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),

              // Top Bar: Back, Home, Delete
              Row(
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
                        onTap: () => Get.offAllNamed(AppRoutes.home),
                        child: Padding(
                          padding: EdgeInsets.all(6.r),
                          child: Icon(
                            Icons.home_outlined,
                            size: 22.r,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Padding(
                          padding: EdgeInsets.all(6.r),
                          child: Icon(
                            Icons.delete_outline,
                            size: 22.r,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Full Preview Image with Watermark
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AppAssets.templatesSample,
                        fit: BoxFit.cover,
                      ),
                      if (showWatermark)
                        Positioned(
                          right: 12.w,
                          bottom: 12.h,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.blackColor
                                      .withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: CommonText.text(
                                  title: AppStrings.appName,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  textColor: AppColors.whiteColor,
                                ),
                              ),
                              Positioned(
                                top: -6.r,
                                right: -6.r,
                                child: GestureDetector(
                                  onTap: onRemoveWatermark,
                                  child: Container(
                                    width: 16.r,
                                    height: 16.r,
                                    decoration: const BoxDecoration(
                                      color: AppColors.whiteColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 11.r,
                                      color: AppColors.blackColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
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
