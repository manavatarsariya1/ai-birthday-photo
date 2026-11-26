import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_strings.dart';
import '../../controllers/paywall/paywall_controller.dart';
import '../../data/models/paywall_plan_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final ScrollController _carouselController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isCarouselPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollTimer = Timer.periodic(
        const Duration(milliseconds: 16),
        (_) {
          if (!_isCarouselPaused && _carouselController.hasClients) {
            _carouselController.jumpTo(_carouselController.offset + 0.65);
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaywallController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 8.h),

              // ── Top Bar: Close (X) & Restore ──────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: controller.onCloseTap,
                      child: Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: AppColors.blackColor.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.r,
                          color: AppColors.blackColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.onRestoreTap,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 4.h,
                        ),
                        child: CommonText.text(
                          title: AppStrings.restore,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          textColor:
                              AppColors.blackColor.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // ── Title: Unlock Your Birthday Magic ─────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                    children: [
                      TextSpan(text: AppStrings.unlockYour),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: CommonText.text(
                            title: AppStrings.birthdayWord,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            textColor: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      TextSpan(text: AppStrings.magic),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // ── Subtitle ──────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 36.w),
                child: CommonText.text(
                  title: AppStrings.paywallSubtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.blackColor.withValues(alpha: 0.55),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),

              SizedBox(height: 14.h),

              // ── Horizontal Auto-Scrolling Carousel ────────────
              Listener(
                onPointerDown: (_) => _isCarouselPaused = true,
                onPointerUp: (_) => _isCarouselPaused = false,
                onPointerCancel: (_) => _isCarouselPaused = false,
                child: SizedBox(
                  height: 142.h,
                  child: ListView.separated(
                    controller: _carouselController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final items = controller.carouselItems;
                      return _CarouselCard(
                        item: items[index % items.length],
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemCount: 100000,
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              // ── Features Card (2x2 Grid) ──────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 18.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackColor.withValues(alpha: 0.04),
                        blurRadius: 10.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _FeatureItem(text: controller.features[0]),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _FeatureItem(text: controller.features[1]),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _FeatureItem(text: controller.features[2]),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _FeatureItem(text: controller.features[3]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              // ── Subscription Plans ────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: controller.plans.map((plan) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Obx(() {
                        final isSelected =
                            controller.selectedPlanId.value == plan.id;
                        return _PlanCard(
                          plan: plan,
                          isSelected: isSelected,
                          onTap: () => controller.selectPlan(plan.id),
                        );
                      }),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 4.h),

              // ── Auto Renewable Text ───────────────────────────
              CommonText.text(
                title: AppStrings.autoRenewable,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
              ),

              SizedBox(height: 10.h),

              // ── Continue CTA Button ───────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CommonButton.primary(
                  onTap: controller.onContinueTap,
                  title: AppStrings.continueText,
                ),
              ),

              SizedBox(height: 12.h),

              // ── Footer Links ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterLink(
                    title: AppStrings.restorePurchase,
                    onTap: controller.onRestoreTap,
                  ),
                  _FooterDivider(),
                  _FooterLink(
                    title: AppStrings.termsOfUse,
                    onTap: controller.onTermsTap,
                  ),
                  _FooterDivider(),
                  _FooterLink(
                    title: AppStrings.privacyPolicy,
                    onTap: controller.onPrivacyTap,
                  ),
                ],
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final PaywallCarouselModel item;

  const _CarouselCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102.w,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.asset(
                    item.imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (item.isVideo)
                  Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: AppColors.blackColor.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 18.r,
                      color: AppColors.whiteColor,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          CommonText.text(
            title: item.title,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            textColor: AppColors.blackColor.withValues(alpha: 0.8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20.r,
          height: 20.r,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 12.r,
            color: AppColors.whiteColor,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: CommonText.text(
            title: text,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            textColor: AppColors.blackColor.withValues(alpha: 0.85),
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PaywallPlanModel plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
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
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(1.5.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.backgroundColor
                : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(14.5.r),
          ),
          child: Row(
            children: [
              // Left: Plan title + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText.text(
                      title: plan.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      textColor: AppColors.blackColor,
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        CommonText.text(
                          title: plan.price,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          textColor: AppColors.blackColor,
                        ),
                        SizedBox(width: 4.w),
                        CommonText.text(
                          title: plan.period,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          textColor:
                              AppColors.blackColor.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Middle: Credits + Discount badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText.text(
                    title: plan.credits,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.blackColor,
                  ),
                  if (plan.discountBadge != null) ...[
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CommonText.text(
                        title: plan.discountBadge!,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(width: 12.w),

              // Right: Radio circle
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryPink
                        : AppColors.borderColor,
                    width: 1.5.r,
                  ),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        width: 11.r,
                        height: 11.r,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
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

class _FooterLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _FooterLink({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CommonText.text(
        title: title,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        textColor: AppColors.primaryPink,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

class _FooterDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: CommonText.text(
        title: '|',
        fontSize: 11,
        textColor: AppColors.blackColor.withValues(alpha: 0.35),
      ),
    );
  }
}
