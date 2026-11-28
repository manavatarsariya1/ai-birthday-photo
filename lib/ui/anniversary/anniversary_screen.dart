import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/app_assets.dart';
import '../../controllers/anniversary/anniversary_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_photo_picker_sheet.dart';
import '../../utils/common_shimmer_box.dart';
import '../../utils/common_svg_image.dart';
import '../../utils/common_text.dart';
import '../crop/crop_screen.dart';
import '../result/result_screen.dart';

class AnniversaryScreen extends StatefulWidget {
  const AnniversaryScreen({super.key});

  @override
  State<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends State<AnniversaryScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnniversaryController());
    LogEventManager.logEvent('anniversary_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(6.r),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20.r,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CommonText.text(
                    title: 'Anniversary',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.blackColor,
                  ),
                ],
              ),
            ),

            // ── Milestone Chips ───────────────────────────────────────
            SizedBox(
              height: 36.h,
              child: Obx(() {
                final cats = controller.categories;
                if (controller.isLoading.value && cats.isEmpty) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (_, __) => SizedBox(
                      width: 86.w,
                      child: CommonShimmerBox(borderRadius: 9999.r),
                    ),
                  );
                }
                if (cats.isEmpty) return const SizedBox.shrink();
                return SingleChildScrollView(
                  controller: controller.categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: List.generate(cats.length, (i) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: i < cats.length - 1 ? 8.w : 0,
                        ),
                        child: Builder(
                          builder: (pillContext) {
                            return Obx(() {
                              final isActive =
                                  controller.selectedCategoryIndex.value == i;
                              return GestureDetector(
                                onTap: () {
                                  controller.selectedCategoryIndex.value = i;
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (pillContext.mounted) {
                                      Scrollable.ensureVisible(
                                        pillContext,
                                        alignment: 0.5,
                                        duration: const Duration(
                                          milliseconds: 280,
                                        ),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  });
                                },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? AppColors.primaryGradient
                                : null,
                            color: isActive ? null : AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(9999.r),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.transparentColor
                                  : AppColors.borderColor,
                              width: 1.r,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: CommonText.text(
                            title: cats[i].name,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            textColor: isActive
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                          ),
                        ),
                      );
                    });
                          },
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
            SizedBox(height: 14.h),

            // ── 2-Column Templates Grid ───────────────────────────────
            Expanded(
              child: Obx(() {
                final items = controller.currentTemplates;
                final isLoading = controller.isLoading.value;

                if (!isLoading && items.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primaryPink,
                    onRefresh: controller.fetchAnniversaryTemplates,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 0.55.sh,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 48.r,
                                color:
                                    AppColors.blackColor.withValues(alpha: 0.25),
                              ),
                              SizedBox(height: 10.h),
                              CommonText.text(
                                title: 'No templates available',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                textColor:
                                    AppColors.blackColor.withValues(alpha: 0.45),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final count = items.isNotEmpty ? items.length : 6;

                return RefreshIndicator(
                  color: AppColors.primaryPink,
                  onRefresh: controller.fetchAnniversaryTemplates,
                  child: GridView.builder(
                    key: ValueKey(controller.selectedCategoryIndex.value),
                    cacheExtent: 1200,
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    itemCount: count,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.76,
                    ),
                    itemBuilder: (_, index) {
                      if (controller.isLoading.value && items.isEmpty) {
                        return const CommonShimmerBox();
                      }
                      final imageUrl = items.isNotEmpty
                          ? items[index].image
                          : '';
                      return GestureDetector(
                        onTap: _showAnniversaryUploadSheet,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: imageUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 500,
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                  placeholder: (_, __) => Shimmer.fromColors(
                                    baseColor: const Color(0xFFE6E6EC),
                                    highlightColor: const Color(0xFFF7F7FA),
                                    child: Container(
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.reminderCardBg,
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 28.r,
                                      color: AppColors.blackColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.reminderCardBg,
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 28.r,
                                    color: AppColors.blackColor.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
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

  void _showAnniversaryUploadSheet() {
    Get.bottomSheet(
      const _AnniversaryUploadSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
    );
  }
}

class _AnniversaryUploadSheet extends StatefulWidget {
  const _AnniversaryUploadSheet();

  @override
  State<_AnniversaryUploadSheet> createState() =>
      _AnniversaryUploadSheetState();
}

class _AnniversaryUploadSheetState extends State<_AnniversaryUploadSheet> {
  File? _malePhoto;
  File? _femalePhoto;

  bool get _hasRequiredPhotos => _malePhoto != null && _femalePhoto != null;

  Future<void> _pickInto(void Function(File) onPicked) async {
    final path = await CommonPhotoPickerSheet.show();
    if (path != null && path.isNotEmpty) {
      final File? cropped = await Get.to<File?>(
        () => CropScreen(imageFile: File(path)),
      );
      if (cropped != null && mounted) {
        setState(() => onPicked(cropped));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.blackColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.text(
                      title: 'Please Select a Photo',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor,
                    ),
                    SizedBox(height: 2.h),
                    CommonText.text(
                      title:
                          'Add a clear photo of male and female to create your beautiful moment.',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
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
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16.r,
                    color: AppColors.primaryPink,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // ── Upload Boxes ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _UploadBox(
                  label: 'Male',
                  file: _malePhoto,
                  onTap: () => _pickInto((f) => _malePhoto = f),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _UploadBox(
                  label: 'Female',
                  file: _femalePhoto,
                  onTap: () => _pickInto((f) => _femalePhoto = f),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // ── Credits Pill ──────────────────────────────────────────
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4A4348),
                borderRadius: BorderRadius.circular(9999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppAssets.coin, width: 16.r, height: 16.r),
                  SizedBox(width: 6.w),
                  CommonText.text(
                    title: '200 CREDITS  |  Balance: 550',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.whiteColor,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Upgrade to PRO Banner (Same height, width, curve as CTA)
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.paywall),
            child: Container(
              width: double.infinity,
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColors.photoPickerBg,
                borderRadius: BorderRadius.circular(9999.r),
                border: Border.all(
                  color: AppColors.photoPickerBorder,
                  width: 1.r,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CommonSvgImage(
                        imagePath: AppAssets.icPremiumCrown,
                        width: 16.r,
                        height: 16.r,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CommonText.text(
                              title: 'Upgrade to PRO',
                              fontSize: 12.5,
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
                                color: const Color(0xFFFFD54F),
                                borderRadius: BorderRadius.circular(9999.r),
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
                          title: 'Master 4K resolution & priority rendering',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.blackColor.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CommonText.text(
                    title: 'Claim ›',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.primaryPink,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Create Now / Generate CTA (Exact same height, width, curve)
          GestureDetector(
            onTap: () {
              if (!_hasRequiredPhotos) {
                AppToast.showError('Please add a photo');
                return;
              }
              final beforeFile = _malePhoto!;
              Get.back();
              Get.to(
                () => ResultScreen(beforeImage: beforeFile, isVideo: false),
              );
            },
            child: Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(9999.r),
              ),
              alignment: Alignment.center,
              child: CommonText.text(
                title: _hasRequiredPhotos ? 'Generate' : 'Create Now',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                textColor: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;

  const _UploadBox({
    required this.label,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: file == null
            ? _DashedRRectPainter(
                color: AppColors.primaryPink.withValues(alpha: 0.35),
                radius: 18.r,
                strokeWidth: 1.4.r,
              )
            : null,
        child: Container(
          height: 230.h,
          decoration: BoxDecoration(
            color: AppColors.photoPickerBg.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: file != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.file(file!, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 60.r,
                          height: 60.r,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink.withValues(
                              alpha: 0.08,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryPink.withValues(
                                alpha: 0.35,
                              ),
                              width: 1.5.r,
                            ),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 30.r,
                            color: AppColors.primaryPink.withValues(alpha: 0.5),
                          ),
                        ),
                        Positioned(
                          right: -2.r,
                          bottom: -2.r,
                          child: Container(
                            width: 22.r,
                            height: 22.r,
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 14.r,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    CommonText.text(
                      title: 'Add Image',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor,
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9999.r),
                      ),
                      child: CommonText.text(
                        title: label,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.primaryPink,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    CommonText.text(
                      title: 'Support JPG, PNG, HEIC',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.blackColor.withValues(alpha: 0.45),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;

  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}
