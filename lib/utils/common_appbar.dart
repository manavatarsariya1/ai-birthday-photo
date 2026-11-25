import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'common_text.dart';

/// A reusable AppBar-style header widget.
///
/// Usage:
/// ```dart
/// CommonAppBar(title: 'Home')
/// CommonAppBar(title: 'Profile', showBackButton: true)
/// CommonAppBar(title: 'Cart', actions: [IconButton(...)])
/// ```
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackTap,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.titleColor,
    this.elevation,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.getCardColor(context),
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: showBackButton ? 0 : 16.w,
      automaticallyImplyLeading: false,
      leading: leading ?? (showBackButton ? _BackButton(onTap: onBackTap) : null),
      leadingWidth: showBackButton ? 56.w : 0,
      title: CommonText.text(
        title: title,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: titleColor ?? AppColors.getTextColor(context),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      actions: actions,
      bottom: bottom,
      shape: Border(
        bottom: BorderSide(
          color: AppColors.getBorderColor(context),
          width: 0.8,
        ),
      ),
    );
  }
}

/// A reusable custom header row (not a Flutter AppBar, for use inside Scaffold body).
///
/// Use when you need a custom header with finer layout control.
class CommonPageHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final Widget? trailing;
  final double? height;

  const CommonPageHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackTap,
    this.trailing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 56.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorderColor(context), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          if (showBackButton) _BackButton(onTap: onBackTap),
          if (!showBackButton) SizedBox(width: 16.w),
          Expanded(
            child: CommonText.text(
              title: title,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}

/// Internal back button used by both [CommonAppBar] and [CommonPageHeader].
class _BackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _BackButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.back(),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56.w,
        height: double.infinity,
        child: Center(
          child: Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundColor(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15.sp,
              color: AppColors.getTextColor(context),
            ),
          ),
        ),
      ),
    );
  }
}
