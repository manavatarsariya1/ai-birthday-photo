import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonText {
  static Widget text({
    required String title,
    double? fontSize,
    Color? color,
    Color? textColor,
    String? fontFamily,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? letterSpacing,
    TextDecoration? decoration,
    bool isRequired = false,
  }) {
    final effectiveColor = color ?? textColor;
    if (isRequired) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: title,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize?.sp,
                color: effectiveColor,
                fontWeight: fontWeight,
                letterSpacing: letterSpacing,
                decoration: decoration,
              ),
            ),
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
    return Text(
      title,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize?.sp,
        color: effectiveColor,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }

  static Widget marqueeText({
    required String title,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
  }) {
    return Text(
      title,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize?.sp,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}
