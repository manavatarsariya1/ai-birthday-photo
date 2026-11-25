import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Base Colors ───────────────────────────────────────────
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);

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
}
