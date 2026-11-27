import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class UninstallThankYouScreen extends StatelessWidget {
  const UninstallThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LogEventManager.logEvent('uninstall_thank_you_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 28.h),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                AppAssets.imgThankYou,
                width: 210.w,
                height: 175.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 22.h),
              CommonText.text(
                title: 'Thank You for Trying\nAI Birthday!',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              CommonText.text(
                title:
                    'We truly appreciate your feedback and\nhope to see you again soon.',
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CommonButton.primary(
                onTap: () => Get.offAllNamed(AppRoutes.home),
                title: 'Back to Home',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
