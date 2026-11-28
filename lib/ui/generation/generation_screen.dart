import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../../constant/app_constant.dart';
import '../../constant/app_strings.dart';
import '../../controllers/home/home_controller.dart';
import '../../data/models/templates_api_model.dart';
import '../../services/api_service.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_text.dart';
import '../result/result_screen.dart';

class GenerationScreen extends StatefulWidget {
  final File imageFile;
  final File? imageFile2;
  final bool isVideo;
  final TemplateItemModel? template;
  final String customEndpoint;
  final String imageFieldName;
  final Map<String, String>? extraFields;

  const GenerationScreen({
    super.key,
    required this.imageFile,
    this.imageFile2,
    this.isVideo = false,
    this.template,
    this.customEndpoint = 'generations/generate',
    this.imageFieldName = 'image_1',
    this.extraFields,
  });

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  int _percent = 0;
  int _targetPercent = 18;
  Timer? _timer;
  Timer? _creepTimer;
  late final String _idempotencyKey;

  String _generateUuidV4() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20, 32)}';
  }

  @override
  void initState() {
    super.initState();
    _idempotencyKey = _generateUuidV4();
    LogEventManager.logEvent('generation_view');
    _timer = Timer.periodic(const Duration(milliseconds: 45), (_) {
      if (!mounted) return;
      if (_percent < _targetPercent && _percent < 99) {
        setState(() => _percent++);
      }
    });
    _creepTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted) return;
      if (_targetPercent < 95) {
        _targetPercent++;
      }
    });
    _callGenerateApi();
  }

  Future<void> _callGenerateApi() async {
    try {
      String appCheckToken = '';
      try {
        appCheckToken = await FirebaseAppCheck.instance.getToken() ?? '';
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AppCheck token error: $e');
        }
      }

      final files = <http.MultipartFile>[
        await http.MultipartFile.fromPath(
          widget.imageFieldName,
          widget.imageFile.path,
        ),
        if (widget.imageFile2 != null)
          await http.MultipartFile.fromPath('image_2', widget.imageFile2!.path),
      ];

      final response = await ApiService.multipartPost(
        url: '$baseUrl${widget.customEndpoint}',
        fields: {
          'prompt_id': widget.template?.id ?? '',
          if (widget.extraFields != null) ...widget.extraFields!,
        },
        files: files,
        headers: {
          'Idempotency-Key': _idempotencyKey,
          if (appCheckToken.isNotEmpty) 'X-Firebase-AppCheck': appCheckToken,
        },
      );

      if (!mounted) return;

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?;
        final jobId = data?['jobId']?.toString() ?? '';
        final initialProgress = (data?['progress'] as num?)?.toInt() ?? 0;

        if (mounted && initialProgress > _targetPercent) {
          _targetPercent = initialProgress.clamp(0, 100);
        }

        if (jobId.isNotEmpty) {
          await _pollJobStatus(jobId);
          return;
        }
      }

      String msg = 'Generation failed. Please try again.';
      if (response != null && response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          if (decoded['message'] != null) {
            msg = decoded['message'].toString();
          }
        } catch (_) {}
      }
      AppToast.showError(msg);
      Get.back();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Generate API error: $e');
      }
      if (!mounted) return;
      AppToast.showError('Generation failed. Please try again.');
      Get.back();
    }
  }

  Future<void> _pollJobStatus(String jobId) async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      try {
        final res = await ApiService.get(
          url: '${baseUrl}generations/job/$jobId',
        );
        if (!mounted) return;

        if (res != null && res.statusCode == 200) {
          final decoded = jsonDecode(res.body) as Map<String, dynamic>;
          final data = decoded['data'] as Map<String, dynamic>?;
          if (data == null) continue;

          final status = data['status']?.toString().toLowerCase() ?? '';
          final progress = (data['progress'] as num?)?.toInt();
          final resultUrl = data['resultUrl']?.toString();

          if (progress != null && mounted && progress > _targetPercent) {
            _targetPercent = progress.clamp(0, 100);
          }

          if (status == 'completed' &&
              resultUrl != null &&
              resultUrl.isNotEmpty) {
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().fetchCredits();
            }
            _timer?.cancel();
            _creepTimer?.cancel();
            if (mounted) {
              setState(() => _percent = 100);
            }
            if (!mounted) return;
            final mediaType = data['mediaType']?.toString().toLowerCase() ?? '';
            Get.off(
              () => ResultScreen(
                beforeImage: widget.imageFile,
                imageFile2: widget.imageFile2,
                isVideo: widget.isVideo || mediaType == 'video',
                template: widget.template,
                resultUrl: resultUrl,
                jobId: jobId,
              ),
            );
            return;
          }

          if (status == 'failed' || status == 'error') {
            final errMsg = data['error']?.toString() ??
                'Generation failed. Please try again.';
            AppToast.showError(errMsg);
            Get.back();
            return;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Job poll error: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _creepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: AppColors.whiteColor.withValues(alpha: 0.0),
                          highlightColor:
                              AppColors.whiteColor.withValues(alpha: 0.25),
                          period: const Duration(milliseconds: 1400),
                          child: Container(color: AppColors.whiteColor),
                        ),
                      ],
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
                child: Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: CommonText.text(
                    title: '$_percent%',
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    textColor: AppColors.whiteColor,
                  ),
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
      ),
    );
  }
}
