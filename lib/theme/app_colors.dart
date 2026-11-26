import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Base Colors ───────────────────────────────────────────
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color transparentColor = Colors.transparent;

  // ── Brand & Gradient Colors ───────────────────────────────
  static const Color primaryPink = Color(0xFFF922C0);
  static const Color primaryOrange = Color(0xFFFF8701);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, primaryOrange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Background Colors ─────────────────────────────────────
  static const Color backgroundColor = Color(0xFFFFEFFC);

  // ── Indicator Colors ──────────────────────────────────────
  static const Color indicatorActive = Color(0xFFFA3D8A);
  static const Color indicatorInactive = Color(0xFFFFCAF5);

  // ── Home Tool Card Colors ─────────────────────────────────
  static const Color toolPinkBg = Color(0xFFF8E4F2);
  static const Color toolGreenBg = Color(0xFFE5F5F3);
  static const Color toolBlueBg = Color(0xFFE2F0FE);
  static const Color toolPeachBg = Color(0xFFFCEEE2);
  static const Color toolPurpleBg = Color(0xFFEDE5FD);
  static const Color toolCyanBg = Color(0xFFDEF2FB);

  static const LinearGradient toolPinkGradient = LinearGradient(
    colors: [Color(0xFFFF5991), Color(0xFFFF0059)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient toolGreenGradient = LinearGradient(
    colors: [Color(0xFF7EDD9B), Color(0xFF008B32)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient toolBlueGradient = LinearGradient(
    colors: [Color(0xFF5F9EFA), Color(0xFF0058E5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient toolPeachGradient = LinearGradient(
    colors: [Color(0xFFF2A453), Color(0xFFFF6200)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient toolPurpleGradient = LinearGradient(
    colors: [Color(0xFFB564F2), Color(0xFF7F00FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient toolCyanGradient = LinearGradient(
    colors: [Color(0xFF43CBD4), Color(0xFF00979C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color avatarPurple = Color(0xFFD946EF);
  static const Color avatarBlue = Color(0xFF6366F1);

  // ── Boilerplate Compatibility Aliases ─────────────────────
  static const Color primaryColor = primaryPink;
  static const Color secondaryColor = primaryOrange;
  static const Color background = backgroundColor;
  static const Color cardColor = whiteColor;
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color greyColor = Color(0xFF64748B);
  static const Color textPrimary = blackColor;
  static const Color primaryTextColor = whiteColor;
  static const Color secondaryTextColor = Color(0xFF64748B);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  static const Color buttonGradientStart = primaryPink;
  static const LinearGradient primaryButtonGradient = primaryGradient;

  static Color getCardColor(BuildContext context) => cardColor;
  static Color getTextColor(BuildContext context) => textPrimary;
  static Color getSecondaryTextColor(BuildContext context) =>
      secondaryTextColor;
  static Color getBorderColor(BuildContext context) => borderColor;
  static Color getBackgroundColor(BuildContext context) => backgroundColor;
  static Color getTextFieldColor(BuildContext context) => whiteColor;
}
