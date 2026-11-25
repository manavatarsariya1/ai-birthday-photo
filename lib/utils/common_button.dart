// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'config_packages.dart';

enum ButtonIconPosition {
  left,
  right,
}

class CommonButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? textColor;
  final Color? disabledTextColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final String? iconPath;
  final Widget? customIcon;
  final bool isIconSvg;
  final double? iconSize;
  final Color? iconColor;
  final double? iconGap;
  final ButtonIconPosition iconPosition;
  final bool isLoading;
  final bool isEnabled;
  final Gradient? gradient;
  final Gradient? disabledGradient;
  final List<BoxShadow>? boxShadow;

  const CommonButton({
    super.key,
    required this.onTap,
    required this.title,
    this.height,
    this.width,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.gradient,
    this.disabledGradient,
    this.textColor,
    this.disabledTextColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.iconPath,
    this.customIcon,
    this.isIconSvg = true,
    this.iconSize,
    this.iconColor,
    this.iconGap,
    this.iconPosition = ButtonIconPosition.left,
    this.isLoading = false,
    this.isEnabled = true,
    this.boxShadow,
  });

  // ── Factory: Primary Large Button ──────────────────────────────────────────
  factory CommonButton.primary({
    Key? key,
    required VoidCallback? onTap,
    required String title,
    double? height,
    double? width,
    double? borderRadius,
    double? fontSize,
    String? iconPath,
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Gradient? gradient,
    Color? textColor,
    Color? disabledTextColor,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    return CommonButton(
      key: key,
      onTap: onTap,
      title: title,
      height: height ?? 54.h,
      width: width ?? double.infinity,
      backgroundColor: backgroundColor,
      gradient: gradient ?? (backgroundColor == null ? AppColors.primaryButtonGradient : null),
      disabledBackgroundColor:
          disabledBackgroundColor ?? AppColors.cardColor,
      textColor: textColor ?? AppColors.primaryTextColor,
      disabledTextColor:
          disabledTextColor ?? AppColors.secondaryTextColor,
      borderRadius: borderRadius ?? 30.r,
      fontSize: fontSize ?? 16,
      fontWeight: FontWeight.bold,
      iconPath: iconPath,
      isLoading: isLoading,
      isEnabled: isEnabled,
    );
  }

  // ── Factory: Outlined Button ───────────────────────────────────────────────
  factory CommonButton.outline({
    Key? key,
    required VoidCallback? onTap,
    required String title,
    double? height,
    double? width,
    Color? borderColor,
    Color? textColor,
    double? borderRadius,
    double? fontSize,
    String? iconPath,
    bool isLoading = false,
  }) {
    return CommonButton(
      key: key,
      onTap: onTap,
      title: title,
      height: height ?? 54.h,
      width: width ?? double.infinity,
      backgroundColor: AppColors.transparentColor,
      textColor: textColor ?? AppColors.primaryTextColor,
      borderColor: borderColor ?? AppColors.buttonGradientStart,
      borderWidth: 1.5.w,
      borderRadius: borderRadius ?? 30.r,
      fontSize: fontSize ?? 16,
      fontWeight: FontWeight.w600,
      iconPath: iconPath,
      isLoading: isLoading,
    );
  }

  // ── Factory: Small / Compact Action Button (e.g. Try Now) ──────────────────
  factory CommonButton.small({
    Key? key,
    required VoidCallback? onTap,
    required String title,
    double? height,
    double? width,
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Gradient? gradient,
    Color? textColor,
    double? fontSize,
    double? borderRadius,
  }) {
    return CommonButton(
      key: key,
      onTap: onTap,
      title: title,
      height: height ?? 36.h,
      width: width ?? 90.w,
      backgroundColor: backgroundColor,
      gradient: gradient ?? (backgroundColor == null ? AppColors.primaryButtonGradient : null),
      disabledBackgroundColor: disabledBackgroundColor ?? AppColors.cardColor,
      textColor: textColor ?? AppColors.primaryTextColor,
      borderRadius: borderRadius ?? 20.r,
      fontSize: fontSize ?? 13,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 54.h;
    final effectiveGradient = isEnabled
        ? (gradient ?? (backgroundColor == null ? AppColors.primaryButtonGradient : null))
        : disabledGradient;
    final effectiveBgColor = isEnabled
        ? (effectiveGradient == null ? (backgroundColor ?? AppColors.primaryColor) : null)
        : (effectiveGradient == null ? (disabledBackgroundColor ?? AppColors.cardColor) : null);
    final effectiveTextColor = isEnabled
        ? (textColor ?? AppColors.primaryTextColor)
        : (disabledTextColor ?? AppColors.secondaryTextColor);
    final effectiveRadius = borderRadius ?? 30.r;

    return CupertinoButton(
      minSize: 10,
      pressedOpacity: 0.75,
      padding: padding ?? EdgeInsets.zero,
      onPressed: isEnabled && !isLoading ? onTap : null,
      child: Container(
        height: effectiveHeight,
        width: width ?? double.infinity,
        alignment: Alignment.center,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: borderColor != null
              ? Border.all(
                  color: borderColor!,
                  width: borderWidth ?? 1.w,
                )
              : null,
          boxShadow: boxShadow,
        ),
        child: isLoading
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final bool hasBoundedWidth = constraints.hasBoundedWidth;
                  final Widget textWidget = CommonText.text(
                    title: title,
                    color: effectiveTextColor,
                    fontWeight: fontWeight ?? FontWeight.w700,
                    fontSize: fontSize ?? 16,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  );

                  return Row(
                    mainAxisSize: width != null && width != double.infinity
                        ? MainAxisSize.min
                        : MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (iconPosition == ButtonIconPosition.left)
                        _buildIconWidget(),
                      if (iconPosition == ButtonIconPosition.left &&
                          (iconPath != null || customIcon != null))
                        SizedBox(width: iconGap ?? 8.w),
                      hasBoundedWidth
                          ? Flexible(child: textWidget)
                          : textWidget,
                      if (iconPosition == ButtonIconPosition.right &&
                          (iconPath != null || customIcon != null))
                        SizedBox(width: iconGap ?? 8.w),
                      if (iconPosition == ButtonIconPosition.right)
                        _buildIconWidget(),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildIconWidget() {
    if (customIcon != null) {
      return customIcon!;
    }
    if (iconPath != null && iconPath!.isNotEmpty) {
      final size = iconSize ?? 18.r;
      if (isIconSvg || iconPath!.endsWith('.svg')) {
        return CommonImage.svgImage(
          imagePath: iconPath!,
          width: size,
          height: size,
          color: iconColor ?? textColor ?? AppColors.whiteColor,
        );
      } else {
        return CommonImage.assetImage(
          imagePath: iconPath!,
          width: size,
          height: size,
          color: iconColor,
        );
      }
    }
    return const SizedBox.shrink();
  }
}
