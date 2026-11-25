import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant/app_constant.dart';
import 'app_colors.dart';

class TextStyles {
  static TextStyle bold(
    double fontSize, {
    Color? fontColor = AppColors.whiteColor,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize.sp,
      fontFamily: fontFamily ?? appFontFamily,
      fontWeight: fontWeight ?? FontWeight.bold,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }

  static TextStyle semiBold(
    double fontSize, {
    Color? fontColor = AppColors.whiteColor,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize.sp + 2.sp,
      fontFamily: fontFamily ?? appFontFamily,
      fontWeight: fontWeight ?? FontWeight.w600,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }

  static TextStyle medium(
    double fontSize, {
    Color? fontColor = AppColors.whiteColor,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize.sp + 2.sp,
      fontFamily: fontFamily ?? appFontFamily,
      fontWeight: fontWeight ?? FontWeight.w500,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }

  static TextStyle regular(
    double fontSize, {
    Color? fontColor = AppColors.whiteColor,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize.sp + 2.sp,
      fontFamily: fontFamily ?? appFontFamily,
      fontWeight: fontWeight ?? FontWeight.w400,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }

  static TextStyle light(
    double fontSize, {
    Color? fontColor = AppColors.whiteColor,
    TextOverflow? textOverflow,
    String? fontFamily,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: fontColor,
      fontSize: fontSize.sp + 2.sp,
      fontFamily: fontFamily ?? appFontFamily,
      fontWeight: fontWeight ?? FontWeight.w300,
      overflow: textOverflow,
      decoration: textDecoration,
    );
  }
}
