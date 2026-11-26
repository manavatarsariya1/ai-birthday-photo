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
      backgroundColor: AppColors.blackColor,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview
            if (_isInitializing)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryPink,
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: CommonText.text(
                  title: _errorMessage!,
                  fontSize: 14,
                  textColor: AppColors.whiteColor,
                ),
              )
            else if (_controller != null && _controller!.value.isInitialized)
              Center(
                child: CameraPreview(_controller!),
              ),

            // Top Controls (Close, Flash, Switch)
            Positioned(
              top: 12.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleActionButton(
                    icon: Icons.close,
                    onTap: () => Get.back(),
                  ),
                  Row(
                    children: [
                      _CircleActionButton(
                        icon: _flashMode == FlashMode.off
                            ? Icons.flash_off
                            : Icons.flash_on,
                        onTap: _toggleFlash,
                      ),
                      if (_cameras.length > 1) ...[
                        SizedBox(width: 10.w),
                        _CircleActionButton(
                          icon: Icons.cameraswitch_outlined,
                          onTap: _switchCamera,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Shutter Button
            Positioned(
              bottom: 32.h,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    width: 72.r,
                    height: 72.r,
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isCapturing
                            ? AppColors.whiteColor.withValues(alpha: 0.6)
                            : AppColors.whiteColor,
                        shape: BoxShape.circle,
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
