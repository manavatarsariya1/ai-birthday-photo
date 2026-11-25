import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_strings.dart';
import '../../controllers/splash/splash_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Icon or Logo Placeholder
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.bolt,
                    size: 50.r,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              CommonText.text(
                title: AppStrings.appName,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                textColor: AppColors.textPrimary,
              ),
              const Spacer(),
              // Progress Bar
              Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: controller.progress.value,
                      minHeight: 6.h,
                      backgroundColor: AppColors.cardBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

