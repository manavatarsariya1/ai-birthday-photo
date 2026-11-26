import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../constant/app_assets.dart';
import '../../../services/log_event_manager.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/common_button.dart';
import '../../../utils/common_text.dart';

class OfferDialog extends StatefulWidget {
  final VoidCallback onClaim;
  final VoidCallback onDismiss;

  const OfferDialog({
    super.key,
    required this.onClaim,
    required this.onDismiss,
  });

  static void show({
    required VoidCallback onClaim,
    required VoidCallback onDismiss,
  }) {
    LogEventManager.logEvent('offer_dialog_view');
    Get.dialog(
      OfferDialog(onClaim: onClaim, onDismiss: onDismiss),
      barrierDismissible: false,
    );
  }

  @override
  State<OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<OfferDialog> {
  int _remainingSeconds = 29 * 3600 + 59 * 60 + 59; // 29:59:59
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0 && mounted) {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final h = (_remainingSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparentColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 370.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final modalW = constraints.maxWidth;
            final s = modalW / 370.0;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // ── LAYER 1: Back Envelope Base (Full Width) ──
                Positioned(
                  top: 148 * s,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28 * s),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFF8EE6),
                          Color(0xFFF9AEF0),
                          Color(0xFFF5CEF5),
                        ],
                        stops: [0.0, 0.35, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── LAYER 2: Centered Narrower Offer Letter Card (86%) ──
                Positioned(
                  top: 0,
                  left: modalW * 0.07,
                  width: modalW * 0.86,
                  height: 292 * s,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      16 * s,
                      34 * s,
                      16 * s,
                      24 * s,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(26 * s),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFF2FA),
                          Color(0xFFFFF9FD),
                          Color(0xFFFFFFFF),
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFAF3C82).withValues(alpha: 0.1),
                          blurRadius: 20 * s,
                          offset: Offset(0, 4 * s),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Close (×) button
                        Positioned(
                          top: -20 * s,
                          right: -2 * s,
                          child: GestureDetector(
                            onTap: () {
                              LogEventManager.logEvent(
                                'offer_dialog_close_click',
                              );
                              Get.back();
                              widget.onDismiss();
                            },
                            child: Container(
                              width: 30 * s,
                              height: 30 * s,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF6D6EA),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 15 * s,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: 6 * s),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 23 * s,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111111),
                                  letterSpacing: -0.3,
                                ),
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Color(0xFFE01CB8),
                                          Color(0xFFFF3378),
                                          Color(0xFFFF8800),
                                        ],
                                        stops: [0.0, 0.52, 1.0],
                                      ).createShader(
                                        Rect.fromLTWH(
                                          0,
                                          0,
                                          bounds.width,
                                          bounds.height,
                                        ),
                                      ),
                                      child: CommonText.text(
                                        title: 'Limited',
                                        fontSize: 23 * s / 1.sp,
                                        fontWeight: FontWeight.w800,
                                        textColor: AppColors.whiteColor,
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' Time Offer'),
                                ],
                              ),
                            ),
                            SizedBox(height: 9 * s),
                            CommonText.text(
                              title:
                                  'Unlock premium birthday image & video\nat a special discount',
                              fontSize: 13 * s / 1.sp,
                              fontWeight: FontWeight.w500,
                              textColor: const Color(0xFF5C5C5C),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                            SizedBox(height: 14 * s),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 18 * s,
                                vertical: 7 * s,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFF6D6EA)
                                      .withValues(alpha: 0.72),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEB6EB9)
                                        .withValues(alpha: 0.12),
                                    blurRadius: 12 * s,
                                    offset: Offset(0, 3 * s),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CommonText.text(
                                    title: 'Offer ends in ',
                                    fontSize: 14 * s / 1.sp,
                                    fontWeight: FontWeight.w600,
                                    textColor: const Color(0xFF111111),
                                  ),
                                  CommonText.text(
                                    title: _formattedTime,
                                    fontSize: 14 * s / 1.sp,
                                    fontWeight: FontWeight.w700,
                                    textColor: const Color(0xFFEB2F96),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── LAYER 3: Curved Pastel-Pink Middle Pocket ──
                Positioned(
                  top: 180 * s,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 120 * s,
                    child: SvgPicture.string(
                      _layer3WaveSvg,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                // ── LAYER 4: Front White Envelope Body with Peak ─
                Padding(
                  padding: EdgeInsets.only(top: 174 * s),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Seamless upward rounded peak
                      SizedBox(
                        width: double.infinity,
                        height: 50 * s,
                        child: SvgPicture.string(
                          _layer4PeakSvg,
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Front White Content Body
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          18 * s,
                          12 * s,
                          18 * s,
                          22 * s,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(28 * s),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Pricing Banner + 50% OFF SVG Badge
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.centerRight,
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(
                                    10 * s,
                                    14 * s,
                                    80 * s,
                                    14 * s,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFEBF7),
                                        Color(0xFFFFF2FA),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(18 * s),
                                    border: Border.all(
                                      color: const Color(0xFFF8C4E6),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 100,
                                        child: Column(
                                          children: [
                                            CommonText.text(
                                              title: 'Old Price',
                                              fontSize: 12.5 * s / 1.sp,
                                              fontWeight: FontWeight.w600,
                                              textColor:
                                                  const Color(0xFF1F1F1F),
                                            ),
                                            SizedBox(height: 4 * s),
                                            CommonText.text(
                                              title: '\$49.99',
                                              fontSize: 21 * s / 1.sp,
                                              fontWeight: FontWeight.w700,
                                              textColor:
                                                  const Color(0xFF6B6B6B),
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40 * s,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 4 * s,
                                        ),
                                        color: const Color(0xFFF3C4E2),
                                      ),
                                      Expanded(
                                        flex: 115,
                                        child: Column(
                                          children: [
                                            CommonText.text(
                                              title: 'Discount Price',
                                              fontSize: 12.5 * s / 1.sp,
                                              fontWeight: FontWeight.w600,
                                              textColor:
                                                  const Color(0xFF1F1F1F),
                                            ),
                                            SizedBox(height: 4 * s),
                                            CommonText.text(
                                              title: '\$19.99',
                                              fontSize: 21 * s / 1.sp,
                                              fontWeight: FontWeight.w800,
                                              textColor:
                                                  const Color(0xFF111111),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: -10 * s,
                                  child: SvgPicture.string(
                                    _discountBadgeSvg,
                                    width: 86 * s,
                                    height: 96 * s,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20 * s),

                            // 4-Column Features Grid
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _OfferFeatureItem(
                                      iconPath: AppAssets.icOfferMeta,
                                      label: 'More AI\nGenerations',
                                      scale: s,
                                    ),
                                  ),
                                  _VerticalDivider(scale: s),
                                  Expanded(
                                    child: _OfferFeatureItem(
                                      iconPath: AppAssets.icOfferVideos,
                                      label: 'Birthday\nVideos',
                                      scale: s,
                                    ),
                                  ),
                                  _VerticalDivider(scale: s),
                                  Expanded(
                                    child: _OfferFeatureItem(
                                      iconPath: AppAssets.icOfferTemplates,
                                      label: 'Premium\nTemplates',
                                      scale: s,
                                    ),
                                  ),
                                  _VerticalDivider(scale: s),
                                  Expanded(
                                    child: _OfferFeatureItem(
                                      iconPath: AppAssets.icOfferWatermark,
                                      label: 'No\nWatermark',
                                      scale: s,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20 * s),

                            // Primary Gradient CTA Button
                            CommonButton.primary(
                              title: 'Claim Discount Now',
                              onTap: () {
                                LogEventManager.logEvent(
                                  'offer_dialog_claim_click',
                                );
                                Get.back();
                                widget.onClaim();
                              },
                            ),

                            SizedBox(height: 12 * s),

                            // Secondary Dismiss Link
                            GestureDetector(
                              onTap: () {
                                LogEventManager.logEvent(
                                  'offer_dialog_later_click',
                                );
                                Get.back();
                                widget.onDismiss();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14 * s,
                                  vertical: 6 * s,
                                ),
                                child: CommonText.text(
                                  title: 'Maybe Later',
                                  fontSize: 14.5 * s / 1.sp,
                                  fontWeight: FontWeight.w500,
                                  textColor: const Color(0xFF5C5C5C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final double scale;

  const _VerticalDivider({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: EdgeInsets.symmetric(vertical: 4 * scale),
      color: const Color(0xFFECE6EA),
    );
  }
}

class _OfferFeatureItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final double scale;

  const _OfferFeatureItem({
    required this.iconPath,
    required this.label,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46 * scale,
          height: 46 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F8),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFBD8EE)),
          ),
          padding: EdgeInsets.all(11 * scale),
          child: SvgPicture.asset(
            iconPath,
            colorFilter: const ColorFilter.mode(
              Color(0xFFE6228F),
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(height: 7 * scale),
        CommonText.text(
          title: label,
          fontSize: 11 * scale / 1.sp,
          fontWeight: FontWeight.w600,
          textColor: const Color(0xFF1F1F1F),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}

const String _layer3WaveSvg = '''
<svg viewBox="0 0 370 120" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="layer3CurveGrad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#ffb6f2" stop-opacity="0.96" />
      <stop offset="10%" stop-color="#fcc6f5" stop-opacity="0.9" />
      <stop offset="30%" stop-color="#fbe0f8" stop-opacity="0.58" />
      <stop offset="50%" stop-color="#fdf0fb" stop-opacity="0.4" />
      <stop offset="70%" stop-color="#fbe0f8" stop-opacity="0.58" />
      <stop offset="90%" stop-color="#fcc6f5" stop-opacity="0.9" />
      <stop offset="100%" stop-color="#ffb6f2" stop-opacity="0.96" />
    </linearGradient>
  </defs>
  <path d="M 0,1 L 24,1 C 78,2 136,16 185,42 C 234,16 292,2 346,1 L 370,1 L 370,120 L 0,120 Z" fill="url(#layer3CurveGrad)" stroke="none" />
</svg>
''';

const String _layer4PeakSvg = '''
<svg viewBox="0 0 370 50" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 0,50 L 0,44 L 166,7 Q 185,2 204,7 L 370,44 L 370,50 Z" fill="#ffffff" />
</svg>
''';

const String _discountBadgeSvg = '''
<svg viewBox="0 0 110 122" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="goldRimGrad" x1="12" y1="8" x2="98" y2="94" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#fff3b0" />
      <stop offset="28%" stop-color="#ffe26a" />
      <stop offset="56%" stop-color="#f59e0b" />
      <stop offset="78%" stop-color="#fff0a6" />
      <stop offset="100%" stop-color="#d97706" />
    </linearGradient>
    <linearGradient id="goldInnerGrad" x1="90" y1="14" x2="20" y2="88" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#fef08a" />
      <stop offset="50%" stop-color="#d97706" />
      <stop offset="100%" stop-color="#fde047" />
    </linearGradient>
    <radialGradient id="pinkCenterGrad" cx="42%" cy="34%" r="65%">
      <stop offset="0%" stop-color="#ff55b8" />
      <stop offset="48%" stop-color="#f0108c" />
      <stop offset="100%" stop-color="#b8006e" />
    </radialGradient>
    <linearGradient id="ribbonPink" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#ff3ca6" />
      <stop offset="100%" stop-color="#c8007a" />
    </linearGradient>
  </defs>
  <path d="M36 82 L22 114 L36 107 L44 118 L54 88 Z" fill="url(#ribbonPink)" stroke="url(#goldRimGrad)" stroke-width="2.2" stroke-linejoin="round" />
  <path d="M72 80 L94 106 L80 105 L76 116 L58 88 Z" fill="url(#ribbonPink)" stroke="url(#goldRimGrad)" stroke-width="2.2" stroke-linejoin="round" />
  <path d="M55 6 C62 6 66 11 72 13 C79 15 86 14 90 20 C94 26 93 33 96 39 C99 45 104 49 104 56 C104 63 99 67 96 73 C93 79 94 86 89 91 C84 96 77 95 71 97 C65 99 61 104 55 104 C49 104 45 99 39 97 C33 95 26 96 21 91 C16 86 17 79 14 73 C11 67 6 63 6 56 C6 49 11 45 14 39 C17 33 16 26 20 20 C24 14 31 15 38 13 C44 11 48 6 55 6 Z" fill="url(#goldRimGrad)" />
  <path d="M55 12 C61 12 64.5 16.2 70 18 C75.8 19.8 81.8 19 85.4 24.2 C89 29.4 88 35.4 90.6 40.8 C93.2 46 97.6 49.6 97.6 56 C97.6 62.4 93.2 66 90.6 71.2 C88 76.6 89 82.6 84.8 86.8 C80.6 91 74.6 90 69.2 91.8 C64 93.6 60.4 98 55 98 C49.6 98 46 93.6 40.8 91.8 C35.4 90 29.4 91 25.2 86.8 C21 82.6 22 76.6 19.4 71.2 C16.8 66 12.4 62.4 12.4 56 C12.4 49.6 16.8 46 19.4 40.8 C22 35.4 21 29.4 24.6 24.2 C28.2 19 34.2 19.8 40 18 C45.5 16.2 49 12 55 12 Z" fill="url(#pinkCenterGrad)" stroke="url(#goldInnerGrad)" stroke-width="2" />
  <ellipse cx="51" cy="27" rx="22" ry="9" transform="rotate(-10 51 27)" fill="rgba(255, 255, 255, 0.22)" />
  <g transform="rotate(-6 55 56)">
    <text x="55" y="52" text-anchor="middle" fill="#ffffff" font-family="Inter, sans-serif" font-size="22" font-weight="800" letter-spacing="-0.5">50%</text>
    <text x="55" y="75" text-anchor="middle" fill="#ffffff" font-family="Inter, sans-serif" font-size="19" font-weight="800" letter-spacing="0.4">OFF</text>
  </g>
</svg>
''';
