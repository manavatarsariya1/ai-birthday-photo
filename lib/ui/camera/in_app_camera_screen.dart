import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class InAppCameraScreen extends StatefulWidget {
  const InAppCameraScreen({super.key});

  @override
  State<InAppCameraScreen> createState() => _InAppCameraScreenState();
}

class _InAppCameraScreenState extends State<InAppCameraScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _errorMessage = 'No camera found';
          });
        }
        return;
      }
      await _startCameraController(_selectedCameraIndex);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Camera permission denied or unavailable';
        });
      }
    }
  }

  Future<void> _startCameraController(int index) async {
    final prev = _controller;
    if (prev != null) {
      await prev.dispose();
    }

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitializing = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Failed to initialize camera';
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isInitializing) return;
    setState(() => _isInitializing = true);
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _startCameraController(_selectedCameraIndex);
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final next = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await controller.setFlashMode(next);
    setState(() => _flashMode = next);
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final file = await controller.takePicture();
      if (mounted) {
        Get.back(result: File(file.path));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141118),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(6.r),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20.r,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (_cameras.length > 1) ...[
                        _CircleActionButton(
                          icon: Icons.cameraswitch_outlined,
                          onTap: _switchCamera,
                        ),
                        SizedBox(width: 10.w),
                      ],
                      _CircleActionButton(
                        icon: _flashMode == FlashMode.off
                            ? Icons.flash_off
                            : Icons.flash_on,
                        onTap: _toggleFlash,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Rounded Camera Preview Frame ──────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isInitializing)
                        Container(
                          color: const Color(0xFF221E28),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryPink,
                            ),
                          ),
                        )
                      else if (_errorMessage != null)
                        Container(
                          color: const Color(0xFF221E28),
                          child: Center(
                            child: CommonText.text(
                              title: _errorMessage!,
                              fontSize: 14,
                              textColor: AppColors.whiteColor,
                            ),
                          ),
                        )
                      else if (_controller != null &&
                          _controller!.value.isInitialized)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.previewSize?.height ?? 1,
                            height: _controller!.value.previewSize?.width ?? 1,
                            child: CameraPreview(_controller!),
                          ),
                        ),

                      // Corner Brackets
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(18.r),
                          child: CustomPaint(
                            painter: _CornerBracketsPainter(),
                          ),
                        ),
                      ),

                      // Top Tip Pill
                      Positioned(
                        top: 16.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blackColor.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(9999.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 14.r,
                                  color: const Color(0xFFFFD54F),
                                ),
                                SizedBox(width: 6.w),
                                CommonText.text(
                                  title:
                                      'Use a clear, well-lit photo for best results',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  textColor: AppColors.whiteColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Gradient Shutter Button ────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 72.r,
                  height: 72.r,
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.whiteColor,
                      width: 3.r,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isCapturing ? null : AppColors.primaryGradient,
                      color: _isCapturing
                          ? AppColors.primaryPink.withValues(alpha: 0.6)
                          : null,
                    ),
                    child: Center(
                      child: Container(
                        width: 18.r,
                        height: 18.r,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 22.0;

    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height)
        ..lineTo(len, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: AppColors.blackColor.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20.r,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }
}
