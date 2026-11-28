import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/app_assets.dart';
import '../../constant/app_constant.dart';
import '../../constant/app_strings.dart';
import '../../controllers/creation/creation_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../controllers/templates/templates_controller.dart';
import '../../data/models/templates_api_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_button.dart';
import '../../utils/common_autoplay_video.dart';
import '../../utils/common_text.dart';
import '../../utils/common_unlock_dialog.dart';
import '../../utils/share_helper.dart';
import '../generation/generation_screen.dart';
import 'report_problem_screen.dart';
import 'result_preview_screen.dart';

class ResultScreen extends StatefulWidget {
  final File beforeImage;
  final File? imageFile2;
  final bool isVideo;
  final bool isCard;
  final bool isAnniversary;
  final TemplateItemModel? template;
  final String? resultUrl;
  final String? jobId;

  const ResultScreen({
    super.key,
    required this.beforeImage,
    this.imageFile2,
    this.isVideo = false,
    this.isCard = false,
    this.isAnniversary = false,
    this.template,
    this.resultUrl,
    this.jobId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showAfter = true;
  bool _showWatermark = true;
  String? _reaction;
  List<Map<String, dynamic>> _moreItems = [];
  bool _isLoadingMore = true;

  Future<void> _fetchMoreSubcategories() async {
    try {
      final subId = widget.template?.id ?? '';
      final url = subId.isNotEmpty
          ? '${baseUrl}subcategories/more?subcategoryId=$subId&limit=10'
          : '${baseUrl}subcategories/more?limit=10';
      final response = await ApiService.get(url: url);
      if (!mounted) return;
      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] is List) {
          final list = (decoded['data'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
          setState(() {
            _moreItems = list;
            _isLoadingMore = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _submitReaction(String reaction) async {
    if (_reaction != null) return;
    setState(() => _reaction = reaction);
    LogEventManager.logEvent('result_${reaction}_click');
    final jobId = widget.jobId ?? '';
    if (jobId.isEmpty) return;
    final response = await ApiService.post(
      url: '${baseUrl}generations/job/$jobId/reaction',
      body: {'reaction': reaction},
    );
    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      AppToast.showSuccess('Reaction saved');
    }
  }

  @override
  void initState() {
    super.initState();
    LogEventManager.logEvent('result_view');
    _fetchMoreSubcategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SizedBox(height: 8.h),

              // ── Top Bar: Back | Crown ─────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
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
                          onTap: () => Get.to(
                            () => ReportProblemScreen(jobId: widget.jobId),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6.r),
                            child: SvgPicture.asset(
                              AppAssets.icReport,
                              width: 19.r,
                              height: 19.r,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () => Get.offAllNamed(AppRoutes.home),
                          child: Padding(
                            padding: EdgeInsets.all(6.r),
                            child: SvgPicture.asset(
                              AppAssets.icHome,
                              width: 19.r,
                              height: 19.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // ── Title & Subtitle ──────────────────────────────
              CommonText.text(
                title: 'Your Birthday Creation is Ready!',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              CommonText.text(
                title: 'Do you want to change anything?',
                fontSize: 12,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // ── Main Result Image Card ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: SizedBox(
                    height: 380.h,
                    width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _showAfter
                          ? (widget.resultUrl != null &&
                                    widget.resultUrl!.isNotEmpty
                                ? ((widget.isVideo ||
                                          widget.resultUrl!
                                              .toLowerCase()
                                              .endsWith('.mp4'))
                                      ? CommonAutoPlayVideo(
                                          videoUrl: widget.resultUrl!,
                                          enableTapToToggle: true,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: widget.resultUrl!,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                          placeholder: (_, __) =>
                                              Shimmer.fromColors(
                                            baseColor: const Color(0xFFD6D6E0),
                                            highlightColor:
                                                const Color(0xFFF5F5FA),
                                            child: Container(
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
                                        ))
                                : Image.asset(
                                    AppAssets.templatesSample,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                  ))
                          : Image.file(
                              widget.beforeImage,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),

                      // Top-left: Eye, Like, Dislike
                      Positioned(
                        top: 10.h,
                        left: 10.w,
                        child: Column(
                          children: [
                            _OverlayCircleBtn(
                              icon: Icons.visibility_outlined,
                              onTap: () {
                                LogEventManager.logEvent('result_preview_click');
                                Get.to(
                                  () => ResultPreviewScreen(
                                    resultUrl: widget.resultUrl,
                                    showWatermark: _showWatermark,
                                    onRemoveWatermark: () {
                                      CommonUnlockDialog.show(
                                        title: 'Remove Watermark',
                                        subtitle:
                                            'Watch an ad to remove the watermark, or Go premium for watermark free downloads',
                                        buttonTitle: 'Remove Watermark (Ad)',
                                        onPrimaryTap: () {
                                          setState(
                                            () => _showWatermark = false,
                                          );
                                          Get.back();
                                        },
                                        onUpgradeTap: () =>
                                            Get.toNamed(AppRoutes.paywall),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 8.h),
                            _OverlayCircleBtn(
                              icon: _reaction == 'like'
                                  ? Icons.thumb_up_alt
                                  : Icons.thumb_up_alt_outlined,
                              isSelected: _reaction == 'like',
                              isDisabled: _reaction != null,
                              onTap: _reaction == null
                                  ? () => _submitReaction('like')
                                  : () {},
                            ),
                            SizedBox(height: 8.h),
                            _OverlayCircleBtn(
                              icon: _reaction == 'dislike'
                                  ? Icons.thumb_down_alt
                                  : Icons.thumb_down_alt_outlined,
                              isSelected: _reaction == 'dislike',
                              isDisabled: _reaction != null,
                              onTap: _reaction == null
                                  ? () => _submitReaction('dislike')
                                  : () {},
                            ),
                          ],
                        ),
                      ),

                      // Bottom-left: Before | After Toggle (Photo only)
                      if (!widget.isVideo)
                        Positioned(
                        left: 10.w,
                        bottom: 10.h,
                        child: Container(
                          padding: EdgeInsets.all(3.r),
                          decoration: BoxDecoration(
                            color: AppColors.blackColor.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ToggleChip(
                                title: 'Before',
                                isSelected: !_showAfter,
                                onTap: () => setState(() => _showAfter = false),
                              ),
                              _ToggleChip(
                                title: 'After',
                                isSelected: _showAfter,
                                onTap: () => setState(() => _showAfter = true),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom-right: Watermark (App Name)
                      if (_showWatermark)
                        Positioned(
                          right: 4.w,
                          bottom: 4.h,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              CommonUnlockDialog.show(
                                title: 'Remove Watermark',
                                subtitle:
                                    'Watch an ad to remove the watermark, or Go premium for watermark free downloads',
                                buttonTitle: 'Remove Watermark (Ad)',
                                onPrimaryTap: () {
                                  setState(() => _showWatermark = false);
                                },
                                onUpgradeTap: () =>
                                    Get.toNamed(AppRoutes.paywall),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 8.r,
                                right: 8.r,
                                left: 4.w,
                                bottom: 4.h,
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.blackColor
                                          .withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: CommonText.text(
                                      title: AppStrings.appName,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      textColor: AppColors.whiteColor,
                                    ),
                                  ),
                                  Positioned(
                                    top: -6.r,
                                    right: -6.r,
                                    child: Container(
                                      width: 18.r,
                                      height: 18.r,
                                      decoration: const BoxDecoration(
                                        color: AppColors.whiteColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 12.r,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ),

              SizedBox(height: 14.h),

              // ── Save Photo / Video CTA ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CommonButton.primary(
                  title: widget.isVideo
                      ? 'Save Video'
                      : (widget.isCard ? 'Save Card' : 'Save Photo'),
                  onTap: () async {
                    LogEventManager.logEvent('result_save_click');
                    final url = widget.resultUrl ?? '';
                    if (url.isEmpty) {
                      AppToast.showError('Nothing to save');
                      return;
                    }
                    final mediaType = widget.isVideo
                        ? 'video'
                        : (widget.isCard ? 'card' : 'photo');
                    final savedItem =
                        await CreationController.saveCreationFromUrl(
                      url: url,
                      type: mediaType,
                      id: widget.jobId ?? '',
                    );
                    if (savedItem != null) {
                      AppToast.showSuccess('Saved to Creations!');
                      final creationCtrl =
                          Get.isRegistered<CreationController>()
                              ? Get.find<CreationController>()
                              : Get.put(CreationController());
                      creationCtrl.selectedTabIndex.value = mediaType == 'video'
                          ? 1
                          : (mediaType == 'card' ? 2 : 0);
                      Get.offNamed(AppRoutes.creation);
                      Get.toNamed(
                        AppRoutes.creationPreview,
                        arguments: savedItem,
                      );
                    } else {
                      AppToast.showError('Failed to save');
                    }
                  },
                ),
              ),

              SizedBox(height: 10.h),

              // ── Regenerate & Share Row ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _SecondaryActionBtn(
                        icon: Icons.auto_awesome,
                        svgPath: AppAssets.icRegenerate,
                        title: 'Regenerate',
                        onTap: () {
                          LogEventManager.logEvent('result_regenerate_click');
                          Get.off(
                            () => GenerationScreen(
                              imageFile: widget.beforeImage,
                              imageFile2: widget.imageFile2,
                              isVideo: widget.isVideo,
                              template: widget.template,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _SecondaryActionBtn(
                        icon: Icons.ios_share,
                        title: 'Share',
                        onTap: () {
                          LogEventManager.logEvent('result_share_click');
                          ShareHelper.shareText(
                            'Check out my creation made with AI Birthday!',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ── More Images (Full Width Edge-to-Edge) ─────────
              if (_isLoadingMore || _moreItems.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CommonText.text(
                      title: widget.isVideo ? 'MORE VIDEOS' : 'MORE IMAGES',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      textColor: AppColors.blackColor,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                SizedBox(
                  height: 112.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _isLoadingMore ? 4 : _moreItems.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      if (_isLoadingMore) {
                        return Shimmer.fromColors(
                          baseColor: const Color(0xFFD6D6E0),
                          highlightColor: const Color(0xFFF5F5FA),
                          child: Container(
                            width: 98.w,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        );
                      }
                      final item = _moreItems[index];
                      final coverUrl = item['coverImage']?.toString() ?? '';
                      return GestureDetector(
                        onTap: () {
                          LogEventManager.logEvent('result_more_item_click');
                          final catName =
                              item['categoryName']?.toString().toLowerCase() ??
                                  '';
                          final type = catName.contains('video')
                              ? 'video'
                              : catName.contains('card')
                                  ? 'card'
                                  : 'photo';
                          final id = item['id']?.toString() ?? '';
                          final templatesCtrl =
                              Get.isRegistered<TemplatesController>()
                                  ? Get.find<TemplatesController>()
                                  : Get.put(TemplatesController());
                          templatesCtrl.selectTypeAndCategory(type, id);
                          if (Get.isRegistered<HomeController>()) {
                            Get.find<HomeController>().selectedTabIndex.value =
                                1;
                          }
                          Get.until(
                            (route) =>
                                route.settings.name == AppRoutes.home ||
                                route.isFirst,
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: SizedBox(
                            width: 98.w,
                            child: coverUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: coverUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Shimmer.fromColors(
                                      baseColor: const Color(0xFFD6D6E0),
                                      highlightColor: const Color(0xFFF5F5FA),
                                      child: Container(
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppColors.captionCardBg,
                                    ),
                                  )
                                : Container(color: AppColors.captionCardBg),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDisabled;

  const _OverlayCircleBtn({
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.8 : 1.0,
        child: Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color:
                isSelected ? null : AppColors.blackColor.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.r, color: AppColors.whiteColor),
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.whiteColor : AppColors.transparentColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: CommonText.text(
          title: title,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          textColor: isSelected ? AppColors.blackColor : AppColors.whiteColor,
        ),
      ),
    );
  }
}

class _SecondaryActionBtn extends StatelessWidget {
  final IconData icon;
  final String? svgPath;
  final String title;
  final VoidCallback onTap;

  const _SecondaryActionBtn({
    required this.icon,
    this.svgPath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.indicatorInactive,
            width: 1.r,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgPath != null)
              SvgPicture.asset(
                svgPath!,
                width: 17.r,
                height: 17.r,
              )
            else
              Icon(icon, size: 17.r, color: AppColors.blackColor),
            SizedBox(width: 6.w),
            CommonText.text(
              title: title,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textColor: AppColors.blackColor,
            ),
          ],
        ),
      ),
    );
  }
}
