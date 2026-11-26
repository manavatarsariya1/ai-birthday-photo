import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_strings.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';
import '../result/result_screen.dart';

class GenerationScreen extends StatefulWidget {
  final File imageFile;
  final bool isVideo;

  const GenerationScreen({
    super.key,
    required this.imageFile,
    this.isVideo = false,
  });

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  int _percent = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    LogEventManager.logEvent('generation_view');
    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_percent >= 100) {
        timer.cancel();
        if (mounted) {
          Get.off(
            () => ResultScreen(
              beforeImage: widget.imageFile,
              isVideo: widget.isVideo,
            ),
          );
        }
        return;
      }
      if (mounted) {
        setState(() => _percent++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // ── Blurred Preview Card ──────────────────────────
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: SizedBox(
                    width: double.infinity,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              // ── Percentage + Status Text ──────────────────────
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: CommonText.text(
                  title: '$_percent%',
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  textColor: AppColors.whiteColor,
                ),
              ),

              SizedBox(height: 8.h),

              CommonText.text(
                title: AppStrings.creatingBirthdayMagic,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 6.h),

              CommonText.text(
                title: AppStrings.creatingBirthdayMagicSub,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
