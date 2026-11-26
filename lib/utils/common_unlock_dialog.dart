import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import 'common_button.dart';
import 'common_text.dart';

class CommonUnlockDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String buttonTitle;
  final VoidCallback onPrimaryTap;
  final VoidCallback onUpgradeTap;

  const CommonUnlockDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonTitle,
    required this.onPrimaryTap,
    required this.onUpgradeTap,
  });

  static void show({
    required String title,
    required String subtitle,
    required String buttonTitle,
    required VoidCallback onPrimaryTap,
    required VoidCallback onUpgradeTap,
  }) {
    final dialogKey = GlobalKey<_CommonUnlockDialogState>();
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Stack(
          children: [
            Center(
              child: CommonUnlockDialog(
                key: dialogKey,
                title: title,
                subtitle: subtitle,
                buttonTitle: buttonTitle,
                onPrimaryTap: onPrimaryTap,
                onUpgradeTap: onUpgradeTap,
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 12.h, right: 16.w),
                  child: GestureDetector(
                    onTap: () => dialogKey.currentState?.closeWithAnimation(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18.r,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierColor: AppColors.blackColor.withValues(alpha: 0.45),
      barrierDismissible: true,
    );
  }

  @override
  State<CommonUnlockDialog> createState() => _CommonUnlockDialogState();
}

class _CommonUnlockDialogState extends State<CommonUnlockDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _dialogFade;
  late final Animation<double> _dialogScale;
  late final Animation<double> _innerCardSlide;
  late final Animation<double> _illustrationPop;
  late final Animation<double> _goldBalloonPop;
  late final Animation<double> _pinkBalloonPop;
  late final Animation<double> _sparklesPop;

  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      reverseDuration: const Duration(milliseconds: 650),
    );

    _dialogFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
    );
    _dialogScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _innerCardSlide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.22, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _illustrationPop = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.32, 0.72, curve: Curves.easeOutBack),
    );
    _goldBalloonPop = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.48, 0.84, curve: Curves.easeOutBack),
    );
    _pinkBalloonPop = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.62, 0.95, curve: Curves.easeOutBack),
    );
    _sparklesPop = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnim = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    );

    _entranceController.forward();
  }

  Future<void> closeWithAnimation([VoidCallback? afterClose]) async {
    if (_isClosing) return;
    _isClosing = true;
    await _entranceController.reverse();
    if (mounted) {
      Get.back();
      afterClose?.call();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _dialogFade,
      child: ScaleTransition(
        scale: _dialogScale,
        child: Dialog(
          backgroundColor: AppColors.transparentColor,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 356.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final modalW = constraints.maxWidth;
                final s = modalW / 356.0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                // ── LAYER 1: Full-Width Vibrant Pink Envelope Back ──
                Positioned(
                  top: 76 * s,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22 * s),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFF92EC),
                          Color(0xFFFFA8F0),
                          Color(0xFFFFBBF3),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── LAYER 2: Narrower Rounded Blush Card (slides up) ──
                Positioned(
                  top: 34 * s,
                  left: modalW * 0.08,
                  width: modalW * 0.84,
                  height: 156 * s,
                  child: AnimatedBuilder(
                    animation: _innerCardSlide,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 100 * s * _innerCardSlide.value),
                        child: child,
                      );
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28 * s),
                      ),
                      gradient: const RadialGradient(
                        center: Alignment(0.0, 0.24),
                        radius: 0.9,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFFFF0FC),
                          Color(0xFFFFE0F8),
                        ],
                        stops: [0.0, 0.46, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFDC4BAA,
                          ).withValues(alpha: 0.14),
                          blurRadius: 18 * s,
                          offset: Offset(0, 4 * s),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),

                // ── Pop-Out Festive Vector Illustration (z-20) ──
                // Base static gift box, cake, ribbons & confetti
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _innerCardSlide.value * s),
                          child: Opacity(
                            opacity: _illustrationPop.value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.85 + 0.15 * _illustrationPop.value,
                              alignment: Alignment.bottomCenter,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: SvgPicture.string(
                        _festiveIllustrationSvg,
                        width: modalW,
                        height: 188 * s,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Independent Floating Balloons & Twinkling Sparkles
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _entranceController,
                        _floatController,
                      ]),
                      builder: (context, _) {
                        final t = _floatAnim.value;
                        final goldOffset = -4.5 * s * ((1 - t) * 0.85);
                        final pinkOffset = -5.0 * s * t;
                        final sparkleScale = 0.88 + 0.24 * t;
                        final sparkleOpacity = 0.55 + 0.45 * t;

                        return Transform.translate(
                          offset: Offset(0, _innerCardSlide.value * s),
                          child: SizedBox(
                            width: modalW,
                            height: 188 * s,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Opacity(
                                  opacity: _goldBalloonPop.value.clamp(0.0, 1.0),
                                  child: Transform.translate(
                                    offset: Offset(0, goldOffset),
                                    child: Transform.scale(
                                      scale: 0.75 + 0.25 * _goldBalloonPop.value,
                                      alignment: Alignment.bottomCenter,
                                      child: SvgPicture.string(
                                        _goldBalloonSvg,
                                        width: modalW,
                                        height: 188 * s,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: _pinkBalloonPop.value.clamp(0.0, 1.0),
                                  child: Transform.translate(
                                    offset: Offset(0, pinkOffset),
                                    child: Transform.scale(
                                      scale: 0.75 + 0.25 * _pinkBalloonPop.value,
                                      alignment: Alignment.bottomCenter,
                                      child: SvgPicture.string(
                                        _pinkBalloonSvg,
                                        width: modalW,
                                        height: 188 * s,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: (sparkleOpacity *
                                          _sparklesPop.value.clamp(0.0, 1.0))
                                      .clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: sparkleScale *
                                        (0.8 + 0.2 * _sparklesPop.value),
                                    child: SvgPicture.string(
                                      _sparklesSvg,
                                      width: modalW,
                                      height: 188 * s,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                },
                    ),
                  ),
                ),

                // ── LAYER 3: Front Soft-Pink Envelope Pocket with V-Notch ──
                Padding(
                  padding: EdgeInsets.only(top: 124 * s),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Downward V-Notch Rim SVG
                      SizedBox(
                        width: double.infinity,
                        height: 32 * s,
                        child: SvgPicture.string(_vNotchSvg, fit: BoxFit.fill),
                      ),

                      // Front Content Body
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          20 * s,
                          20 * s,
                          20 * s,
                          28 * s,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24 * s),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFF1FC), Color(0xFFFFEBFB)],
                          ),
                        ),
                        child: Column(
                          children: [
                            CommonText.text(
                              title: widget.title,
                              fontSize: 23 * s / 1.sp,
                              fontWeight: FontWeight.w700,
                              textColor: const Color(0xFF1A1619),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8 * s),
                            CommonText.text(
                              title: widget.subtitle,
                              fontSize: 13.5 * s / 1.sp,
                              fontWeight: FontWeight.w400,
                              textColor: const Color(0xFF6D676D),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                            SizedBox(height: 24 * s),
                            CommonButton.primary(
                              title: widget.buttonTitle,
                              height: 50 * s,
                              fontSize: 15.5 * s / 1.sp,
                              onTap: () {
                                Get.back();
                                widget.onPrimaryTap();
                              },
                            ),
                            SizedBox(height: 20 * s),
                            GestureDetector(
                              onTap: () {
                                Get.back();
                                widget.onUpgradeTap();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12 * s,
                                  vertical: 6 * s,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.string(
                                      _crownSvg,
                                      width: 24 * s,
                                      height: 22 * s,
                                    ),
                                    SizedBox(width: 8 * s),
                                    CommonText.text(
                                      title: 'Upgrade to Premium',
                                      fontSize: 16.5 * s / 1.sp,
                                      fontWeight: FontWeight.w700,
                                      textColor: const Color(0xFF1C181C),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ],
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
    ),
    ),
    );
  }
}

const String _vNotchSvg = '''
<svg viewBox="0 0 356 32" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 0,4 L 178,29 L 356,4 L 356,32 L 0,32 Z" fill="#fff1fc" />
  <path d="M 0,4 L 178,29 L 356,4" fill="none" stroke="#ffffff" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round" opacity="0.92" />
</svg>
''';

const String _crownSvg = '''
<svg viewBox="0 0 28 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="crownGrad" x1="14" y1="2" x2="14" y2="22" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#ffd02b" />
      <stop offset="55%" stop-color="#ff9900" />
      <stop offset="100%" stop-color="#ff7700" />
    </linearGradient>
  </defs>
  <path d="M3.5 7.5L8.2 13L14 5L19.8 13L24.5 7.5L22.2 18.2C22 19 21.3 19.5 20.5 19.5H7.5C6.7 19.5 6 19 5.8 18.2L3.5 7.5Z" fill="url(#crownGrad)" />
  <circle cx="3" cy="6" r="2" fill="#ffc41a" />
  <circle cx="14" cy="3.2" r="2.3" fill="#ffd43b" />
  <circle cx="25" cy="6" r="2" fill="#ffc41a" />
  <rect x="6.5" y="21" width="15" height="2.4" rx="1.2" fill="#ff8400" />
</svg>
''';

const String _goldBalloonSvg = '''
<svg viewBox="0 0 360 190" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="goldBalloonGrad" cx="38%" cy="30%" r="68%" fx="34%" fy="26%">
      <stop offset="0%" stop-color="#fff6de" />
      <stop offset="28%" stop-color="#e5b869" />
      <stop offset="68%" stop-color="#c68f3a" />
      <stop offset="89%" stop-color="#9e6c24" />
      <stop offset="100%" stop-color="#cda052" />
    </radialGradient>
    <radialGradient id="balloonSheenG" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.62" />
      <stop offset="55%" stop-color="#ffffff" stop-opacity="0.18" />
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0" />
    </radialGradient>
  </defs>
  <ellipse cx="87" cy="76" rx="19" ry="24" transform="rotate(-18 87 76)" fill="url(#goldBalloonGrad)" />
  <ellipse cx="80" cy="66" rx="7.5" ry="12" transform="rotate(-20 80 66)" fill="url(#balloonSheenG)" />
  <path d="M94.5 98 L98.5 102.5 Q95.5 104 92 103.2 Z" fill="#a8742a" />
  <ellipse cx="94.8" cy="98.6" rx="2.2" ry="1" transform="rotate(-18 94.8 98.6)" fill="#d6a958" />
  <path d="M96 102 C104 122, 114 134, 122 146" stroke="#c49a52" stroke-width="1.2" stroke-linecap="round" opacity="0.85" />
</svg>
''';

const String _pinkBalloonSvg = '''
<svg viewBox="0 0 360 190" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="pinkBalloonGrad" cx="38%" cy="30%" r="68%" fx="34%" fy="26%">
      <stop offset="0%" stop-color="#ffd9ee" />
      <stop offset="28%" stop-color="#e460a2" />
      <stop offset="68%" stop-color="#c4337a" />
      <stop offset="89%" stop-color="#9e205e" />
      <stop offset="100%" stop-color="#c94b8a" />
    </radialGradient>
    <radialGradient id="balloonSheenP" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.62" />
      <stop offset="55%" stop-color="#ffffff" stop-opacity="0.18" />
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0" />
    </radialGradient>
  </defs>
  <ellipse cx="112" cy="45" rx="22" ry="28" transform="rotate(-8 112 45)" fill="url(#pinkBalloonGrad)" />
  <ellipse cx="103" cy="34" rx="8.5" ry="14" transform="rotate(-14 103 34)" fill="url(#balloonSheenP)" />
  <path d="M113 72.5 L116.8 77 Q113.5 78.2 110.2 77 Z" fill="#a42564" />
  <ellipse cx="113.4" cy="72.8" rx="2.5" ry="1.1" transform="rotate(-8 113.4 72.8)" fill="#df6ca8" />
  <path d="M114 74 C106 102, 110 124, 120 144" stroke="#b55283" stroke-width="1.2" stroke-linecap="round" opacity="0.85" />
</svg>
''';

const String _sparklesSvg = '''
<svg viewBox="0 0 360 190" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g fill="#ffd257">
    <path d="M148 26 L150 32 L156 34 L150 36 L148 42 L146 36 L140 34 L146 32 Z" />
    <path d="M244 74 L246 79 L251 81 L246 83 L244 88 L242 83 L237 81 L242 79 Z" />
    <path d="M222 36 L223.5 40 L227.5 41.5 L223.5 43 L222 47 L220.5 43 L216.5 41.5 L220.5 40 Z" />
  </g>
</svg>
''';

const String _festiveIllustrationSvg = '''
<svg viewBox="0 0 360 190" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="pinkBalloonGrad" cx="38%" cy="30%" r="68%" fx="34%" fy="26%">
      <stop offset="0%" stop-color="#ffd9ee" />
      <stop offset="28%" stop-color="#e460a2" />
      <stop offset="68%" stop-color="#c4337a" />
      <stop offset="89%" stop-color="#9e205e" />
      <stop offset="100%" stop-color="#c94b8a" />
    </radialGradient>
    <radialGradient id="goldBalloonGrad" cx="38%" cy="30%" r="68%" fx="34%" fy="26%">
      <stop offset="0%" stop-color="#fff6de" />
      <stop offset="28%" stop-color="#e5b869" />
      <stop offset="68%" stop-color="#c68f3a" />
      <stop offset="89%" stop-color="#9e6c24" />
      <stop offset="100%" stop-color="#cda052" />
    </radialGradient>
    <radialGradient id="balloonSheen" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.62" />
      <stop offset="55%" stop-color="#ffffff" stop-opacity="0.18" />
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0" />
    </radialGradient>
    <linearGradient id="lidTopGrad" x1="110" y1="68" x2="250" y2="112" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#fff3da" />
      <stop offset="50%" stop-color="#ffe0b5" />
      <stop offset="100%" stop-color="#f3bc88" />
    </linearGradient>
    <linearGradient id="lidLeftGrad" x1="112" y1="90" x2="180" y2="124" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#fce0be" />
      <stop offset="100%" stop-color="#e9a977" />
    </linearGradient>
    <linearGradient id="lidRightGrad" x1="180" y1="90" x2="248" y2="124" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#e59e6d" />
      <stop offset="100%" stop-color="#c97b4c" />
    </linearGradient>
    <linearGradient id="boxLeftGrad" x1="118" y1="110" x2="180" y2="178" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#e82e7b" />
      <stop offset="100%" stop-color="#a80f51" />
    </linearGradient>
    <linearGradient id="boxRightGrad" x1="180" y1="110" x2="242" y2="178" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#c41963" />
      <stop offset="100%" stop-color="#7c083a" />
    </linearGradient>
    <linearGradient id="satinPink" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#ff6ac0" />
      <stop offset="45%" stop-color="#e6197b" />
      <stop offset="100%" stop-color="#9e074d" />
    </linearGradient>
    <linearGradient id="satinPinkLight" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#ff9bd6" />
      <stop offset="55%" stop-color="#f02488" />
      <stop offset="100%" stop-color="#b50a5c" />
    </linearGradient>
    <linearGradient id="goldTrim" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#fff4b8" />
      <stop offset="50%" stop-color="#f8b932" />
      <stop offset="100%" stop-color="#c97608" />
    </linearGradient>
    <radialGradient id="starGlow" cx="50%" cy="50%" r="55%">
      <stop offset="0%" stop-color="#ffffff" />
      <stop offset="50%" stop-color="#ffe77a" />
      <stop offset="100%" stop-color="#ffaa1d" />
    </radialGradient>
    <linearGradient id="cakeBaseGrad" x1="236" y1="126" x2="298" y2="164" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#ff99cc" />
      <stop offset="50%" stop-color="#f55ca6" />
      <stop offset="100%" stop-color="#d43282" />
    </linearGradient>
    <linearGradient id="cakeIcingGrad" x1="236" y1="116" x2="298" y2="142" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#ffffff" />
      <stop offset="100%" stop-color="#ffe4f2" />
    </linearGradient>
  </defs>
  <ellipse cx="180" cy="112" rx="92" ry="54" fill="#ffffff" opacity="0.65" />
  <path d="M188 18 C196 4, 218 8, 212 22 C209 29, 200 32, 204 40 C200 37, 194 31, 198 22 C202 14, 194 14, 188 18 Z" fill="url(#goldTrim)" />
  <path d="M244 48 C254 36, 266 42, 262 54 C258 64, 270 68, 278 58 C276 72, 260 76, 254 62 C250 52, 246 54, 244 48 Z" fill="url(#goldTrim)" />
  <path d="M276 66 C284 60, 294 64, 290 73 C286 80, 278 78, 276 66 Z" fill="url(#goldTrim)" />
  <path d="M58 92 C66 82, 76 86, 72 96 C69 102, 78 106, 84 98 C82 108, 69 111, 65 101 C63 95, 60 96, 58 92 Z" fill="url(#goldTrim)" />
  <polygon points="78,38 84,41 81,47 75,44" fill="#ec2694" />
  <polygon points="66,52 72,54 70,59 64,57" fill="#f662b4" />
  <polygon points="172,30 178,27 180,33 174,36" fill="#ec2694" />
  <polygon points="234,26 244,20 248,27 238,33" fill="#e11d8c" />
  <polygon points="306,74 312,72 314,78 308,80" fill="#d9268a" />
  <polygon points="65,116 71,119 68,125 62,122" fill="#e82491" />
  <polygon points="82,108 87,110 85,115 80,113" fill="#f789c6" />
  <path d="M68 152 C74 126, 102 120, 122 144 L122 162 C104 140, 82 142, 78 160 Z" fill="url(#satinPinkLight)" stroke="#ffd7ef" stroke-width="1" />
  <g transform="translate(4, -6)">
    <ellipse cx="268" cy="160" rx="34" ry="10" fill="#ffe7b3" stroke="#e0a63b" stroke-width="1.2" />
    <path d="M238 128 L238 156 C238 165, 298 165, 298 156 L298 128 Z" fill="url(#cakeBaseGrad)" />
    <ellipse cx="268" cy="128" rx="30" ry="11" fill="url(#cakeIcingGrad)" />
    <path d="M238 128 C238 140, 246 144, 250 137 C254 146, 262 146, 266 138 C270 148, 278 147, 282 138 C286 145, 295 142, 298 131 L298 128 C290 135, 246 135, 238 128 Z" fill="#ffffff" opacity="0.95" />
    <circle cx="250" cy="128" r="1.4" fill="#ff2a85" />
    <circle cx="258" cy="132" r="1.4" fill="#38bdf8" />
    <circle cx="267" cy="133" r="1.4" fill="#facc15" />
    <circle cx="277" cy="131" r="1.4" fill="#22c55e" />
    <circle cx="285" cy="127" r="1.4" fill="#ff2a85" />
    <circle cx="262" cy="125" r="1.3" fill="#fb923c" />
    <circle cx="274" cy="126" r="1.3" fill="#a855f7" />
    <rect x="250" y="104" width="4.2" height="22" rx="1.8" fill="#ffffff" stroke="#ff66b2" stroke-width="0.7" />
    <path d="M250 109 L254.2 112 M250 115 L254.2 118 M250 121 L254.2 124" stroke="#ff2e93" stroke-width="1.3" />
    <path d="M252.1 94 C255 98, 255 103, 252.1 104 C249.2 103, 249.2 98, 252.1 94 Z" fill="#ffb703" />
    <ellipse cx="252.1" cy="101" rx="1.1" ry="2.2" fill="#fffce0" />
    <rect x="258" y="100" width="4.2" height="25" rx="1.8" fill="#ffffff" stroke="#ff66b2" stroke-width="0.7" />
    <path d="M258 105 L262.2 108 M258 111 L262.2 114 M258 117 L262.2 120" stroke="#ff2e93" stroke-width="1.3" />
    <path d="M260.1 90 C263 94, 263 99, 260.1 100 C257.2 99, 257.2 94, 260.1 90 Z" fill="#ffb703" />
    <ellipse cx="260.1" cy="97" rx="1.1" ry="2.2" fill="#fffce0" />
    <rect x="266" y="98" width="4.4" height="28" rx="1.8" fill="#ffffff" stroke="#ff66b2" stroke-width="0.7" />
    <path d="M266 103 L270.4 106 M266 109 L270.4 112 M266 115 L270.4 118 M266 121 L270.4 124" stroke="#ff2e93" stroke-width="1.3" />
    <path d="M268.2 88 C271.2 92, 271.2 97, 268.2 98 C265.2 97, 265.2 92, 268.2 88 Z" fill="#ffb703" />
    <ellipse cx="268.2" cy="95" rx="1.2" ry="2.4" fill="#fffce0" />
    <rect x="274" y="100" width="4.2" height="25" rx="1.8" fill="#ffffff" stroke="#ff66b2" stroke-width="0.7" />
    <path d="M274 105 L278.2 108 M274 111 L278.2 114 M274 117 L278.2 120" stroke="#ff2e93" stroke-width="1.3" />
    <path d="M276.1 90 C279 94, 279 99, 276.1 100 C273.2 99, 273.2 94, 276.1 90 Z" fill="#ffb703" />
    <ellipse cx="276.1" cy="97" rx="1.1" ry="2.2" fill="#fffce0" />
    <rect x="282" y="104" width="4.2" height="22" rx="1.8" fill="#ffffff" stroke="#ff66b2" stroke-width="0.7" />
    <path d="M282 109 L286.2 112 M282 115 L286.2 118 M282 121 L286.2 124" stroke="#ff2e93" stroke-width="1.3" />
    <path d="M284.1 94 C287 98, 287 103, 284.1 104 C281.2 103, 281.2 98, 284.1 94 Z" fill="#ffb703" />
    <ellipse cx="284.1" cy="101" rx="1.1" ry="2.2" fill="#fffce0" />
  </g>
  <g>
    <polygon points="118,108 180,129 180,184 118,162" fill="url(#boxLeftGrad)" />
    <polygon points="180,129 242,108 242,162 180,184" fill="url(#boxRightGrad)" />
    <polygon points="142,116 155,121 155,175 142,170" fill="url(#satinPink)" stroke="#ffba42" stroke-width="0.8" />
    <polygon points="205,121 218,116 218,170 205,175" fill="url(#satinPink)" stroke="#ffba42" stroke-width="0.8" />
    <path d="M167 148 L170 155 L177 156 L171.5 161 L173 168 L167 164.5 L161 168 L162.5 161 L157 156 L164 155 Z" fill="url(#starGlow)" />
    <path d="M128 140 L130 144.5 L135 145.2 L131.2 148.5 L132.2 153.2 L128 150.8 L123.8 153.2 L124.8 148.5 L121 145.2 L126 144.5 Z" fill="url(#starGlow)" />
    <path d="M195 152 L197 156.5 L202 157.2 L198.2 160.5 L199.2 165.2 L195 162.8 L190.8 165.2 L191.8 160.5 L188 157.2 L193 156.5 Z" fill="url(#starGlow)" />
    <path d="M229 138 L231.2 143 L236.5 143.8 L232.4 147.4 L233.5 152.6 L229 150 L224.5 152.6 L225.6 147.4 L221.5 143.8 L226.8 143 Z" fill="url(#starGlow)" />
    <polygon points="180,68 248,90 180,113 112,90" fill="url(#lidTopGrad)" />
    <polygon points="112,90 180,113 180,130 112,107" fill="url(#lidLeftGrad)" />
    <polygon points="180,113 248,90 248,107 180,130" fill="url(#lidRightGrad)" />
    <polyline points="112,90 180,113 248,90" stroke="#ffffff" stroke-width="1.3" opacity="0.7" fill="none" />
    <polygon points="141,80 154,75 219,98 206,103" fill="url(#satinPinkLight)" stroke="#ffd670" stroke-width="0.8" />
    <polygon points="219,80 206,75 141,98 154,103" fill="url(#satinPinkLight)" stroke="#ffd670" stroke-width="0.8" />
    <polygon points="141,98 154,103 154,121 141,116" fill="url(#satinPink)" stroke="#ffd670" stroke-width="0.8" />
    <polygon points="206,103 219,98 219,116 206,121" fill="url(#satinPink)" stroke="#ffd670" stroke-width="0.8" />
    <path d="M172 90 C152 96, 134 114, 128 134 L142 128 L149 138 C154 118, 166 102, 178 96 Z" fill="url(#satinPink)" stroke="#ffd875" stroke-width="1" />
    <path d="M188 90 C208 96, 224 112, 232 132 L218 127 L211 137 C206 117, 194 102, 182 96 Z" fill="url(#satinPink)" stroke="#ffd875" stroke-width="1" />
    <path d="M174 82 C154 54, 122 60, 128 84 C132 98, 158 96, 174 88 Z" fill="url(#satinPink)" stroke="#ffd875" stroke-width="1.2" />
    <path d="M174 84 C160 66, 136 72, 140 85 C143 93, 160 91, 174 87 Z" fill="#8f0546" opacity="0.45" />
    <path d="M174 82 C158 58, 132 62, 134 78" stroke="#ffb5e0" stroke-width="2" stroke-linecap="round" opacity="0.7" />
    <path d="M186 82 C206 54, 238 60, 232 84 C228 98, 202 96, 186 88 Z" fill="url(#satinPink)" stroke="#ffd875" stroke-width="1.2" />
    <path d="M186 84 C200 66, 224 72, 220 85 C217 93, 200 91, 186 87 Z" fill="#8f0546" opacity="0.45" />
    <path d="M186 82 C202 58, 228 62, 226 78" stroke="#ffb5e0" stroke-width="2" stroke-linecap="round" opacity="0.7" />
    <rect x="171" y="76" width="18" height="16" rx="6" fill="url(#satinPinkLight)" stroke="#ffe082" stroke-width="1.2" />
    <ellipse cx="180" cy="81" rx="5.5" ry="2.2" fill="#ffffff" opacity="0.45" />
  </g>
</svg>
''';
