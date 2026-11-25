import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────
  // 🔧 Change these two for every new project
  static const Color primaryColor   = Color(0xFF2E41B6);
  static const Color secondaryColor = Color(0xFF64748B);

  // ── Neutral ───────────────────────────────────────────────
  static const Color whiteColor       = Colors.white;
  static const Color blackColor       = Color(0xFF0F172A);
  static const Color greyColor        = Color(0xFF64748B);
  static const Color backgroundColor  = Color(0xFFF8FAFC);
  static const Color borderColor      = Color(0xFFE2E8F0);

  // ── Semantic ──────────────────────────────────────────────
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor   = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor    = Color(0xFF3B82F6);

  // ── Shimmer ───────────────────────────────────────────────
  static const Color shimmerBase      = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // ── Aliases (convenience) ─────────────────────────────────
  static const Color primary          = primaryColor;
  static const Color background       = backgroundColor;
  static const Color cardBackground   = whiteColor;
  static const Color cardColor        = Color(0xFF382E34);
  static const Color textPrimary      = blackColor;
  static const Color primaryTextColor = blackColor;
  static const Color secondaryTextColor = greyColor;
  static const Color transparentColor = Colors.transparent;
  static const Color themeColor       = primaryColor;
  static const Color buttonGradientStart = primaryColor;
  static const Color buttonGradientEnd = Color(0xFF4F46E5);
  static const Gradient primaryButtonGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF4F46E5)],
  );

  // ── Dark-mode aware helpers ───────────────────────────────
  static Color getBackgroundColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0F172A) : backgroundColor;

  static Color getCardColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E293B) : whiteColor;

  static Color getTextColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFF8FAFC) : blackColor;

  static Color getSecondaryTextColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF94A3B8) : secondaryColor;

  static Color getBorderColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF334155) : borderColor;

  static Color getTextFieldColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E293B) : whiteColor;

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
