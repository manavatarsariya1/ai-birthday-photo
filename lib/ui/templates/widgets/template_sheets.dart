import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constant/app_assets.dart';
import '../../../constant/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../services/log_event_manager.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/app_toast.dart';
import '../../../utils/common_button.dart';
import '../../../utils/common_photo_picker_sheet.dart';
import '../../../utils/common_text.dart';
import '../../../utils/pref_service.dart';
import '../../camera/in_app_camera_screen.dart';
import '../../crop/crop_screen.dart';
import '../../generation/generation_screen.dart';

class TemplateSheets {
  TemplateSheets._();

  static void showTipsSheet({bool isVideo = false}) {
    if (PrefService.getBool(PrefService.hasSeenTipsSheet)) {
      showUploadPhotoSheet(isVideo: isVideo);
      return;
    }
    PrefService.setValue(PrefService.hasSeenTipsSheet, true);
    LogEventManager.logEvent('tips_sheet_view');
    Get.bottomSheet(
      _TipsBottomSheet(isVideo: isVideo),
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
    );
  }

  static void showUploadPhotoSheet({bool isVideo = false}) {
    LogEventManager.logEvent('upload_photo_sheet_view');
    Get.bottomSheet(
      _UploadPhotoBottomSheet(isVideo: isVideo),
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
    );
  }

  static Future<void> showImageSourceSheet({
    required ValueChanged<File> onImagePicked,
  }) async {
    LogEventManager.logEvent('image_source_sheet_view');
    final path = await CommonPhotoPickerSheet.show();
    if (path != null && path.isNotEmpty) {
      onImagePicked(File(path));
    }
  }
}

class _TipsBottomSheet extends StatelessWidget {
  final bool isVideo;

  const _TipsBottomSheet({this.isVideo = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(10.r),
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
                      title: AppStrings.tipsTitle,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor,
                    ),
                    SizedBox(height: 2.h),
                    CommonText.text(
                      title: AppStrings.tipsSubtitle,
                      fontSize: 11.5,
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
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16.r,
                    color: AppColors.blackColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          CommonText.text(
            title: AppStrings.recommended,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            textColor: AppColors.successColor,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _TipPhotoCard(
                  imagePath: AppAssets.suggestionApproval1,
                  label: AppStrings.frontFacing,
                  isGood: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _TipPhotoCard(
                  imagePath: AppAssets.suggestionApproval2,
                  label: AppStrings.goodLighting,
                  isGood: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _TipPhotoCard(
                  imagePath: AppAssets.suggestionApproval3,
                  label: AppStrings.sharpFocus,
                  isGood: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          CommonText.text(
            title: AppStrings.avoidThesePhotos,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            textColor: AppColors.errorColor,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _TipPhotoCard(
                  imagePath: AppAssets.suggestionReject1,
                  label: AppStrings.blurredFace,
                  isGood: false,
                  isBlurred: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _TipPhotoCard(
                  imagePath: AppAssets.suggestionReject2,
                  label: AppStrings.faceCovered,
                  isGood: false,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _TipPhotoCard(
                  imagePath: AppAssets.suggestionReject3,
                  label: AppStrings.multiplePeople,
                  isGood: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          CommonButton.primary(
            title: AppStrings.choosePhoto,
            onTap: () {
              LogEventManager.logEvent('tips_choose_photo_click');
              Get.back();
              TemplateSheets.showUploadPhotoSheet(isVideo: isVideo);
            },
          ),
        ],
      ),
    );
  }
}

class _TipPhotoCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isGood;
  final bool isBlurred;

  const _TipPhotoCard({
    required this.imagePath,
    required this.label,
    required this.isGood,
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(imagePath, fit: BoxFit.cover);

    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: AspectRatio(
                aspectRatio: 0.85,
                child: isBlurred
                    ? ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                        child: img,
                      )
                    : img,
              ),
            ),
            Positioned(
              top: 5.r,
              right: 5.r,
              child: Container(
                width: 18.r,
                height: 18.r,
                decoration: BoxDecoration(
                  color: isGood ? AppColors.successColor : AppColors.errorColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGood ? Icons.check : Icons.close,
                  size: 11.r,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        CommonText.text(
          title: label,
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          textColor: AppColors.blackColor.withValues(alpha: 0.8),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _UploadPhotoBottomSheet extends StatefulWidget {
  final bool isVideo;

  const _UploadPhotoBottomSheet({this.isVideo = false});

  @override
  State<_UploadPhotoBottomSheet> createState() =>
      _UploadPhotoBottomSheetState();
}

class _UploadPhotoBottomSheetState extends State<_UploadPhotoBottomSheet> {
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.text(
                      title: AppStrings.pleaseSelectPhoto,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor,
                    ),
                    SizedBox(height: 2.h),
                    CommonText.text(
                      title: AppStrings.pleaseSelectPhotoSubtitle,
                      fontSize: 11.5,
                      textColor: AppColors.blackColor.withValues(alpha: 0.55),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16.r,
                    color: AppColors.blackColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Add Image Box
          GestureDetector(
            onTap: () {
              TemplateSheets.showImageSourceSheet(
                onImagePicked: (file) async {
                  final File? cropped = await Get.to<File?>(
                    () => CropScreen(imageFile: file),
                  );
                  if (cropped != null && mounted) {
                    setState(() => _selectedImage = cropped);
                  }
                },
              );
            },
            child: CustomPaint(
              painter: _DashedRRectPainter(
                color: AppColors.uploadBorderPink,
                radius: 18.r,
                strokeWidth: 1.5.r,
              ),
              child: Container(
                width: 195.w,
                height: 225.h,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16.5.r),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 58.r,
                                height: 58.r,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.uploadIconBorderPink,
                                    width: 1.5.r,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 32.r,
                                  color: AppColors.primaryPink.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -2.r,
                                bottom: -2.r,
                                child: Container(
                                  width: 20.r,
                                  height: 20.r,
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 13.r,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          CommonText.text(
                            title: AppStrings.addImage,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            textColor: AppColors.blackColor,
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: CommonText.text(
                              title: AppStrings.babyMaleFemale,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.primaryPink,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          CommonText.text(
                            title: AppStrings.supportedFormats,
                            fontSize: 9.5,
                            textColor: AppColors.blackColor.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // Credits Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.blackColor.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAssets.coin, width: 16.r, height: 16.r),
                SizedBox(width: 6.w),
                CommonText.text(
                  title: '200 CREDITS  |  Balance: 550',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.whiteColor,
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Upgrade to PRO Banner
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.paywall);
            },
            child: Container(
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
                    width: 28.r,
                    height: 28.r,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(6.r),
                    child: SvgPicture.asset(
                      AppAssets.icPremiumCrown,
                      colorFilter: const ColorFilter.mode(
                        AppColors.whiteColor,
                        BlendMode.srcIn,
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
                              title: AppStrings.upgradeToPro,
                              fontSize: 12,
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
                          title: AppStrings.master4kRendering,
                          fontSize: 10,
                          textColor: AppColors.blackColor.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CommonText.text(
                    title: '${AppStrings.claim} >',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.primaryPink,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          CommonButton.primary(
            title: _selectedImage != null
                ? AppStrings.generate
                : AppStrings.createNow,
            onTap: () {
              if (_selectedImage == null) {
                AppToast.showError('Please add a photo');
                return;
              }
              LogEventManager.logEvent('upload_photo_generate_click');
              Get.back();
              Get.to(
                () => GenerationScreen(
                  imageFile: _selectedImage!,
                  isVideo: widget.isVideo,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ImageSourceBottomSheet extends StatelessWidget {
  final ValueChanged<File> onImagePicked;

  const _ImageSourceBottomSheet({required this.onImagePicked});

  Future<void> _pick(ImageSource source) async {
    if (source == ImageSource.camera) {
      final File? captured = await Get.to<File?>(
        () => const InAppCameraScreen(),
      );
      if (captured != null) {
        Get.back();
        onImagePicked(captured);
      }
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked != null) {
      Get.back();
      onImagePicked(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _SourceCard(
                  icon: Icons.camera_alt_outlined,
                  title: AppStrings.camera,
                  subtitle: AppStrings.takeAPhoto,
                  onTap: () => _pick(ImageSource.camera),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SourceCard(
                  icon: Icons.photo_library_outlined,
                  title: AppStrings.gallery,
                  subtitle: AppStrings.chooseExisting,
                  onTap: () => _pick(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.sourceCardBorderPink,
            width: 1.5.r,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, size: 26.r, color: AppColors.primaryPink),
            ),
            SizedBox(height: 6.h),
            CommonText.text(
              title: title,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              textColor: AppColors.blackColor,
            ),
            SizedBox(height: 2.h),
            CommonText.text(
              title: subtitle,
              fontSize: 10.5,
              textColor: AppColors.blackColor.withValues(alpha: 0.55),
            ),
          ],
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
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      strokeWidth != oldDelegate.strokeWidth;
}
