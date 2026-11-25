// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'config_packages.dart';

class CommonWidgets {
  static Widget cupertinoButton({
    required void Function()? onTap,
    required double height,
    required double width,
    required bool flag,
    required String title,
    EdgeInsetsGeometry? padding,
    double? pressedOpacity,
    Color? color,
    Color? borderColor,
    Color? titleColor,
    double? imgSize,
    double? fontSize,
    String? img,
    FontWeight? fontWeight,
    double? radius,
  }) {
    return CupertinoButton(
      minSize: 10,
      pressedOpacity: pressedOpacity ?? .7,
      padding: padding ?? EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? AppColors.transparentColor,
          borderRadius: BorderRadius.circular(radius ?? 100),
          border: Border.all(color: borderColor ?? AppColors.transparentColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (flag)
              img!.contains('.svg')
                  ? CommonImage.svgImage(
                      imagePath: img,
                      height: imgSize ?? Get.height * 0.02,
                    )
                  : CommonImage.assetImage(
                      imagePath: img,
                      height: imgSize ?? Get.height * 0.02,
                    ),
            if (flag) SizedBox(width: Get.width * .03),
            CommonText.text(
              title: title,
              color: titleColor ?? AppColors.whiteColor,
              fontWeight: fontWeight ?? FontWeight.w600,
              fontSize: fontSize ?? FontSizes.text18,
            ),
          ],
        ),
      ),
    );
  }

  static InputDecoration decoration = InputDecoration(
    contentPadding: const EdgeInsets.only(right: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
  );

  static Widget commonAppBar({
    required Widget prefixImg,
    required String title,
    suffixWidget,
  }) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.02,
        vertical: Get.height * 0.015,
      ),
      color: AppColors.whiteColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              prefixImg,
              SizedBox(width: Get.width * 0.02),
              CommonText.marqueeText(
                title: title,
                fontSize: FontSizes.text18,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          suffixWidget ?? const SizedBox(),
        ],
      ),
    );
  }

  static Widget commonAppBar2({
    required Widget prefixImg,
    required Widget title,
    suffixWidget,
    VoidCallback? prefixOnTap,
  }) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.03,
        vertical: Get.height * 0.015,
      ),
      color: AppColors.whiteColor,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                InkWell(onTap: prefixOnTap, child: prefixImg),
                SizedBox(width: Get.width * 0.03),
                Expanded(child: title),
              ],
            ),
          ),
          SizedBox(width: Get.width * 0.03),
          suffixWidget ?? const SizedBox(),
        ],
      ),
    );
  }

  // static Widget noData({required String title}) {
  //   return Container(
  //     width: Get.width,
  //     color: AppColors.whiteColor,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         CommonImage.svgImage(
  //           imagePath: AppAssets.imgAuth,
  //           height: Get.height * 0.1,
  //           width: Get.height * 0.1,
  //         ),
  //         SizedBox(height: Get.height * 0.01),
  //         CommonText.text(
  //           title: "$title ${AppStrings.notFound}",
  //           color: AppColors.themeGreyColor,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // static void customBottomSheet(
  //   BuildContext context,
  //   bool closeFlag,
  //   Widget widgets,
  // ) {
  //   showModalBottomSheet(
  //     context: context,
  //     isDismissible: false,
  //     isScrollControlled: true,
  //     backgroundColor: AppColors.transparentColor,
  //     builder: (BuildContext context) {
  //       return SafeArea(
  //         child: Padding(
  //           padding: EdgeInsets.only(
  //             bottom: MediaQuery.of(context).viewInsets.bottom,
  //           ),
  //           child: Wrap(
  //             children: [
  //               Container(
  //                 decoration: const BoxDecoration(
  //                   color: AppColors.whiteColor,
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(16.0),
  //                     topRight: Radius.circular(16.0),
  //                   ),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 20,
  //                     vertical: 10,
  //                   ),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       CommonImage.assetImage(imagePath: AppImages.popupIcon),
  //                       (closeFlag)
  //                           ? Align(
  //                               alignment: Alignment.topRight,
  //                               child: GestureDetector(
  //                                 onTap: () {
  //                                   Get.back();
  //                                 },
  //                                 child: const Icon(
  //                                   Icons.close,
  //                                   color: AppColors.themeGreyColor,
  //                                 ),
  //                               ),
  //                             )
  //                           : const SizedBox(height: 15),
  //                       widgets,
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  static Container commonContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      color: AppColors.whiteColor,
      width: Get.width,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: Get.width * 0.04,
            vertical: Get.height * 0.018,
          ),
      child: child,
    );
  }

  static Widget numericInputButton({required String value, required onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: Get.width * 0.20,
        width: Get.width * 0.20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          color: AppColors.whiteColor,
        ),
        child: CommonText.text(
          title: value,
          fontWeight: FontWeight.w500,
          fontSize: FontSizes.text25,
          color: AppColors.blackColor,
        ),
      ),
    );
  }

  static Widget wdColumn({required String img, required String title}) {
    return Column(
      children: [
        CommonImage.assetImage(
          imagePath: img,
          height: Get.height * .07,
          width: Get.height * .07,
        ),
        const SizedBox(height: 10),
        CommonText.text(title: title, fontWeight: FontWeight.w500),
      ],
    );
  }

  static Widget commonLoader() {
    return Container(
      height: Get.height,
      width: Get.width,
      color: Colors.black38,
      alignment: Alignment.center,
      child: const Wrap(children: [CircularProgressIndicator()]),
    );
  }

  static Future<bool?> showExitConfirmationDialog(BuildContext context) async {
    return await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppColors.getCardColor(context),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: AppColors.errorColor,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 20.h),
              CommonText.text(
                title: "Exit Application",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
              ),
              SizedBox(height: 12.h),
              CommonText.text(
                title: "Are you sure you want to close the app?",
                fontSize: 13,
                color: AppColors.getSecondaryTextColor(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: CommonWidgets.cupertinoButton(
                      onTap: () {
                        Get.back(result: false);
                      },
                      height: 44.h,
                      width: double.infinity,
                      flag: false,
                      title: "Cancel",
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      titleColor: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      radius: 10.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CommonWidgets.cupertinoButton(
                      onTap: () {
                        Get.back(result: true);
                      },
                      height: 44.h,
                      width: double.infinity,
                      flag: false,
                      title: "Exit",
                      color: AppColors.errorColor,
                      titleColor: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      radius: 10.r,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showPermissionDialog(BuildContext context, {
    required String permissionName,
    required String description,
    required VoidCallback onConfirm,
  }) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: AppColors.getCardColor(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  permissionName.toLowerCase().contains('camera')
                      ? Icons.camera_alt_rounded
                      : Icons.photo_library_rounded,
                  color: AppColors.primaryColor,
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 16.h),
              CommonText.text(
                title: "$permissionName Permission Required",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              CommonText.text(
                title: description,
                fontSize: 13,
                color: AppColors.getSecondaryTextColor(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.getBorderColor(context)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CommonWidgets.cupertinoButton(
                      onTap: () {
                        Get.back();
                        onConfirm();
                      },
                      height: 44.h,
                      width: double.infinity,
                      flag: false,
                      title: "Open Settings",
                      color: AppColors.primaryColor,
                      titleColor: Colors.white,
                      radius: 12.r,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageSourceBottomSheet extends StatelessWidget {
  final void Function(ImageSource source) onSelect;
  final String? title;
  final String? subtitle;

  const ImageSourceBottomSheet({
    super.key,
    required this.onSelect,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 24.h),

          // Header Text
          CommonText.text(
            title: title ?? "Upload Document Image",
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.getTextColor(context),
          ),
          SizedBox(height: 4.h),
          CommonText.text(
            title:
                subtitle ??
                "Choose how you'd like to capture or pick your image",
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.getSecondaryTextColor(context),
          ),
          SizedBox(height: 24.h),

          // Selection Cards Row
          Row(
            children: [
              // Camera Card
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(ImageSource.camera),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(context),
                      border: Border.all(
                        color: AppColors.getBorderColor(context),
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F6FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: const Color(0xFF3F63F6),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        CommonText.text(
                          title: "Camera",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(context),
                        ),
                        SizedBox(height: 2.h),
                        CommonText.text(
                          title: "Take a photo",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // Gallery Card
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(ImageSource.gallery),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(context),
                      border: Border.all(
                        color: AppColors.getBorderColor(context),
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F6FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: const Color(0xFF3F63F6),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        CommonText.text(
                          title: "Gallery",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(context),
                        ),
                        SizedBox(height: 2.h),
                        CommonText.text(
                          title: "Choose existing",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}

class CommonBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CommonBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          Get.back();
        }
      },
      child: Container(
        width: 36.r,
        height: 36.r,
        margin: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.getBorderColor(context),
            width: 1.w,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16.sp,
          color: AppColors.getTextColor(context),
        ),
      ),
    );
  }
}
