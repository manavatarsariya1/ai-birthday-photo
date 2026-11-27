import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../controllers/card/card_creation_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class CardGeneratingScreen extends StatelessWidget {
  const CardGeneratingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CardCreationController>();

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: controller.templateImageUrl.value.startsWith('http')
                        ? Image.network(
                            controller.templateImageUrl.value,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Image.asset(
                            AppAssets.templatesSample,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              Obx(
                () => ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: CommonText.text(
                    title: '${controller.progress.value}%',
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    textColor: AppColors.whiteColor,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              CommonText.text(
                title: 'Creating Your Birthday Card',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
              ),
              SizedBox(height: 4.h),
              CommonText.text(
                title: 'Your personalized celebration is\ncoming to life',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
