import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class StatusBarWrapper extends StatelessWidget {
  final Widget child;
  final Brightness? statusBarIconBrightness;
  final Brightness? statusBarBrightness;
  final Color? statusBarColor;

  const StatusBarWrapper({
    super.key,
    required this.child,
    this.statusBarIconBrightness,
    this.statusBarBrightness,
    this.statusBarColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? AppColors.transparentColor,
        statusBarIconBrightness: statusBarIconBrightness ??
            (isDark ? Brightness.light : Brightness.dark),
        statusBarBrightness: statusBarBrightness ??
            (isDark ? Brightness.dark : Brightness.light),
        systemNavigationBarColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE0E0E0),
      ),
      child: child,
    );
  }
}
