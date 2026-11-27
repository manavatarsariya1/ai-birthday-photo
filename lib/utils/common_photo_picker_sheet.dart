import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../ui/camera/in_app_camera_screen.dart';
import 'common_text.dart';

class CommonPhotoPickerSheet {
  CommonPhotoPickerSheet._();

  static Future<String?> show() async {
    String? source;

    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.blackColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 22.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      source = 'camera';
                      Get.back();
                    },
                    child: _OptionCard(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera',
                      subtitle: 'Take a Photo',
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      source = 'gallery';
                      Get.back();
                    },
                    child: _OptionCard(
                      icon: Icons.photo_library_outlined,
                      title: 'Gallery',
                      subtitle: 'Choose existing',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.transparentColor,
    );

    if (source == 'camera') {
      final result = await Get.to(() => const InAppCameraScreen());
      if (result is File) return result.path;
      if (result is XFile) return result.path;
      if (result is String && result.isNotEmpty) return result;
    } else if (source == 'gallery') {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return picked?.path;
    }
    return null;
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.photoPickerBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.photoPickerBorder,
          width: 1.r,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 20.r,
              color: AppColors.primaryPink,
            ),
          ),
          SizedBox(height: 6.h),
          CommonText.text(
            title: title,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            textColor: AppColors.blackColor,
          ),
          SizedBox(height: 2.h),
          CommonText.text(
            title: subtitle,
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            textColor: AppColors.blackColor.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}
