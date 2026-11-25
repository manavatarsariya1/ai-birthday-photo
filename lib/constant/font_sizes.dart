import 'package:flutter_screenutil/flutter_screenutil.dart';

// ============================================================
// FontSizes — Standard Type Scale
// ============================================================
// These values are responsive via flutter_screenutil (.sp).
// Use these across the app instead of raw numbers.
// ============================================================

class FontSizes {
  FontSizes._(); // prevent instantiation

  // ── Micro ─────────────────────────────────────────────────
  static double get text8  => 8.sp;
  static double get text9  => 9.sp;
  static double get text10 => 10.sp;
  static double get text11 => 11.sp;

  // ── Small ─────────────────────────────────────────────────
  static double get text12 => 12.sp;
  static double get text13 => 13.sp;
  static double get text14 => 14.sp;
  static double get text15 => 15.sp;

  // ── Body ──────────────────────────────────────────────────
  static double get text16 => 16.sp;
  static double get text17 => 17.sp;
  static double get text18 => 18.sp;
  static double get text19 => 19.sp;

  // ── Heading ───────────────────────────────────────────────
  static double get text20 => 20.sp;
  static double get text22 => 22.sp;
  static double get text24 => 24.sp;
  static double get text25 => 25.sp;
  static double get text26 => 26.sp;
  static double get text28 => 28.sp;

  // ── Display ───────────────────────────────────────────────
  static double get text30 => 30.sp;
  static double get text32 => 32.sp;
  static double get text36 => 36.sp;
  static double get text40 => 40.sp;

  // ── Semantic Aliases ──────────────────────────────────────
  static double get caption    => text11;
  static double get label      => text12;
  static double get body       => text14;
  static double get subtitle   => text13;
  static double get title      => text18;
  static double get h3         => text20;
  static double get h2         => text24;
  static double get h1         => text28;
  static double get display    => text32;
}
