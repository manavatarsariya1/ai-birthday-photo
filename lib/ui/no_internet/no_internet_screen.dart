import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onTryAgain;

  const NoInternetScreen({super.key, this.onTryAgain});

  @override
  Widget build(BuildContext context) {
    LogEventManager.logEvent('no_internet_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 28.h),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                AppAssets.imgNoInternet,
                width: 210.w,
                height: 170.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 18.h),
              CommonText.text(
                title: 'No Internet Connection',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              CommonText.text(
                title:
                    'Please check your internet connection\nand try again',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CommonButton.primary(
                onTap: () {
                  LogEventManager.logEvent('no_internet_try_again_click');
                  if (onTryAgain != null) {
                    onTryAgain!();
                  } else {
                    Get.back();
                  }
                },
                title: 'Try Again',
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () => Get.back(),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                  child: CommonText.text(
                    title: 'Go Back',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.blackColor.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
