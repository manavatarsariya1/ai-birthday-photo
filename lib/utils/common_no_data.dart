import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'common_text.dart';

class CommonNoData extends StatelessWidget {
  final String title;
  final String? subTitle;
  final IconData? icon;
  final double? padding;

  const CommonNoData({
    super.key,
    required this.title,
    this.subTitle,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padding ?? 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.layers_clear_outlined,
              size: 48.sp,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 12.h),
            CommonText.text(
              title: title,
              fontSize: 15,
              color: AppColors.getTextColor(context),
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            if (subTitle != null && subTitle!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              CommonText.text(
                title: subTitle!,
                fontSize: 12.5,
                color: AppColors.getSecondaryTextColor(context),
                fontWeight: FontWeight.normal,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
