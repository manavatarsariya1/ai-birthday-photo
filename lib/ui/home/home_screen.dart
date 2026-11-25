import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_strings.dart';
import '../../controllers/home/home_controller.dart';
import '../../services/ad_service/ad_label_key.dart';
import '../../services/ad_service/banner_ad_widget.dart';
import '../../services/ad_service/native_ad_widget.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_appbar.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await controller.onWillPop(context);
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CommonAppBar(
          title: AppStrings.appName,
          showBackButton: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Reusable Native Ad Card
                      NativeAdWidget(
                        adLabel: ADLabelKey.homeSectionNative,
                        templateType: NativeTemplateType.medium,
                      ),
                      SizedBox(height: 20.h),

                      // Counter Display
                      Center(
                        child: Obx(
                          () => CommonText.text(
                            title: 'Action Counter: ${controller.counter.value}',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            textColor: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Action Button triggering Interstitial Ad
                      CommonButton.primary(
                        onTap: controller.showFeatureWithAd,
                        title: 'Perform Action (With Ad)',
                      ),
                      SizedBox(height: 12.h),

                      // Direct Action Button
                      CommonButton.outline(
                        onTap: controller.incrementCounter,
                        title: 'Direct Increment',
                      ),
                    ],
                  ),
                ),
              ),

              // Reusable Banner Ad at Bottom
              BannerAdWidget(
                adLabel: ADLabelKey.homeBanner,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

