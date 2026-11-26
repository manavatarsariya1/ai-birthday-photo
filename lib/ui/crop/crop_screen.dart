import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../constant/app_strings.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_text.dart';

class CropScreen extends StatefulWidget {
  final File imageFile;

  const CropScreen({super.key, required this.imageFile});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final GlobalKey _cropBoundaryKey = GlobalKey();

  int _selectedRatioIndex = 3; // 4:5 default
  int _activeToolIndex = 0; // 0: Crop, 1: Rotate, 2: Flip, 3: Reset
  int _quarterTurns = 0;
  bool _isFlipped = false;
  bool _isSaving = false;
  double _imageAspectRatio = 1.0;

  // Normalized crop rect (0.0 .. 1.0) within the image box
  Rect _cropRect = const Rect.fromLTWH(0.08, 0.08, 0.84, 0.84);

  final List<String> _ratios = const ['Original', '1:1', '3:4', '4:5', '9:16'];
  final List<double?> _aspectValues = const [null, 1.0, 3 / 4, 4 / 5, 9 / 16];

  @override
  void initState() {
    super.initState();
    LogEventManager.logEvent('crop_view');
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _imageAspectRatio =
            frame.image.width / frame.image.height.toDouble();
      });
      _onSelectRatio(_selectedRatioIndex);
    }
    frame.image.dispose();
  }

  void _onSelectRatio(int index) {
    setState(() {
      _selectedRatioIndex = index;
      final ratio = _aspectValues[index];
      if (ratio == null) {
        _cropRect = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0);
      } else {
        final imgAspect =
            _quarterTurns.isOdd ? (1 / _imageAspectRatio) : _imageAspectRatio;
        double h = 1.0;
        double w = (h * ratio) / imgAspect;
        if (w > 1.0) {
          w = 1.0;
          h = (w * imgAspect) / ratio;
        }
        _cropRect = Rect.fromLTWH((1 - w) / 2, (1 - h) / 2, w, h);
      }
    });
  }

  void _onRotate() {
    LogEventManager.logEvent('crop_rotate_click');
    setState(() {
      _activeToolIndex = 1;
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  void _onFlip() {
    LogEventManager.logEvent('crop_flip_click');
    setState(() {
      _activeToolIndex = 2;
      _isFlipped = !_isFlipped;
    });
  }

  void _onReset() {
    LogEventManager.logEvent('crop_reset_click');
    setState(() {
      _activeToolIndex = 3;
      _selectedRatioIndex = 3;
      _quarterTurns = 0;
      _isFlipped = false;
    });
    _onSelectRatio(3);
  }

  Future<void> _onDone() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    LogEventManager.logEvent('crop_done_click');

    try {
      final boundary = _cropBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final ui.Image fullImage = await boundary.toImage(pixelRatio: 2.0);
        final imgW = fullImage.width.toDouble();
        final imgH = fullImage.height.toDouble();

        final srcRect = Rect.fromLTWH(
          _cropRect.left * imgW,
          _cropRect.top * imgH,
          _cropRect.width * imgW,
          _cropRect.height * imgH,
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawImageRect(
          fullImage,
          srcRect,
          Rect.fromLTWH(0, 0, srcRect.width, srcRect.height),
          Paint(),
        );
        final croppedImage = await recorder.endRecording().toImage(
              srcRect.width.round().clamp(1, 4096),
              srcRect.height.round().clamp(1, 4096),
            );
        final byteData =
            await croppedImage.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final dir = await getTemporaryDirectory();
          final outFile = File(
            '${dir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await outFile.writeAsBytes(byteData.buffer.asUint8List());
          if (mounted) {
            Get.back(result: outFile);
            return;
          }
        }
      }
    } catch (_) {
      // Fallback to original file if capture fails
    }

    if (mounted) {
      Get.back(result: widget.imageFile);
    }
  }

  void _dragCropBox(DragUpdateDetails details, Size boxSize) {
    final dx = details.delta.dx / boxSize.width;
    final dy = details.delta.dy / boxSize.height;
    setState(() {
      final newLeft =
          (_cropRect.left + dx).clamp(0.0, 1.0 - _cropRect.width);
      final newTop =
          (_cropRect.top + dy).clamp(0.0, 1.0 - _cropRect.height);
      _cropRect = Rect.fromLTWH(
        newLeft,
        newTop,
        _cropRect.width,
        _cropRect.height,
      );
    });
  }

  void _resizeCorner(
    DragUpdateDetails details,
    Size boxSize, {
    required bool isLeft,
    required bool isTop,
  }) {
    final dx = details.delta.dx / boxSize.width;
    final dy = details.delta.dy / boxSize.height;
    const minSize = 0.2;

    setState(() {
      double left = _cropRect.left;
      double top = _cropRect.top;
      double right = _cropRect.right;
      double bottom = _cropRect.bottom;

      if (isLeft) {
        left = (left + dx).clamp(0.0, right - minSize);
      } else {
        right = (right + dx).clamp(left + minSize, 1.0);
      }

      if (isTop) {
        top = (top + dy).clamp(0.0, bottom - minSize);
      } else {
        bottom = (bottom + dy).clamp(top + minSize, 1.0);
      }

      _cropRect = Rect.fromLTRB(left, top, right, bottom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20.r,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _onDone,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.whiteColor,
                              ),
                            )
                          : CommonText.text(
                              title: AppStrings.done,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              textColor: AppColors.whiteColor,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Interactive Crop Area (Bounded Strictly to Image) ─
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _quarterTurns.isOdd
                        ? (1 / _imageAspectRatio)
                        : _imageAspectRatio,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boxSize = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        final cropPx = Rect.fromLTWH(
                          _cropRect.left * boxSize.width,
                          _cropRect.top * boxSize.height,
                          _cropRect.width * boxSize.width,
                          _cropRect.height * boxSize.height,
                        );

                        return Stack(
                          fit: StackFit.expand,
                          clipBehavior: Clip.none,
                          children: [
                            // Base Image (captured by RepaintBoundary)
                            RepaintBoundary(
                              key: _cropBoundaryKey,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..scaleByDouble(
                                    _isFlipped ? -1.0 : 1.0,
                                    1.0,
                                    1.0,
                                    1.0,
                                  ),
                                child: RotatedBox(
                                  quarterTurns: _quarterTurns,
                                  child: Image.file(
                                    widget.imageFile,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),

                            // Darkened overlay outside crop rect + 3x3 grid
                            IgnorePointer(
                              child: CustomPaint(
                                painter: _CropOverlayPainter(cropRect: cropPx),
                              ),
                            ),

                            // Draggable Crop Box
                            Positioned.fromRect(
                              rect: cropPx,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onPanUpdate: (d) => _dragCropBox(d, boxSize),
                                child: const SizedBox.expand(),
                              ),
                            ),

                            // 4 Corner Resize Handles
                            _CornerHandle(
                              left: cropPx.left - 10.r,
                              top: cropPx.top - 10.r,
                              onDrag: (d) => _resizeCorner(
                                d,
                                boxSize,
                                isLeft: true,
                                isTop: true,
                              ),
                            ),
                            _CornerHandle(
                              left: cropPx.right - 10.r,
                              top: cropPx.top - 10.r,
                              onDrag: (d) => _resizeCorner(
                                d,
                                boxSize,
                                isLeft: false,
                                isTop: true,
                              ),
                            ),
                            _CornerHandle(
                              left: cropPx.left - 10.r,
                              top: cropPx.bottom - 10.r,
                              onDrag: (d) => _resizeCorner(
                                d,
                                boxSize,
                                isLeft: true,
                                isTop: false,
                              ),
                            ),
                            _CornerHandle(
                              left: cropPx.right - 10.r,
                              top: cropPx.bottom - 10.r,
                              onDrag: (d) => _resizeCorner(
                                d,
                                boxSize,
                                isLeft: false,
                                isTop: false,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ── Aspect Ratio Chips (Centered) ───────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_ratios.length, (index) {
                final isActive = _selectedRatioIndex == index;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: GestureDetector(
                    onTap: () => _onSelectRatio(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 13.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.primaryGradient : null,
                        color: isActive
                            ? null
                            : AppColors.whiteColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CommonText.text(
                        title: _ratios[index],
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 14.h),

            // ── Bottom Toolbar with Smooth Sliding Pill ─────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 18.h),
              child: Container(
                height: 58.h,
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C22),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeInOut,
                      alignment: Alignment(
                        -1.0 + (_activeToolIndex * (2.0 / 3.0)),
                        0.0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 0.25,
                        heightFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _CropToolButton(
                            icon: Icons.crop,
                            label: 'Crop',
                            onTap: () => setState(() => _activeToolIndex = 0),
                          ),
                        ),
                        Expanded(
                          child: _CropToolButton(
                            icon: Icons.rotate_right,
                            label: 'Rotate',
                            onTap: _onRotate,
                          ),
                        ),
                        Expanded(
                          child: _CropToolButton(
                            icon: Icons.flip,
                            label: 'Flip',
                            onTap: _onFlip,
                          ),
                        ),
                        Expanded(
                          child: _CropToolButton(
                            icon: Icons.refresh,
                            label: 'Reset',
                            onTap: _onReset,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerHandle extends StatelessWidget {
  final double left;
  final double top;
  final ValueChanged<DragUpdateDetails> onDrag;

  const _CornerHandle({
    required this.left,
    required this.top,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: onDrag,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 22.r,
          height: 22.r,
          alignment: Alignment.center,
          child: Container(
            width: 12.r,
            height: 12.r,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryPink,
                width: 2.r,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CropToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CropToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.r, color: AppColors.whiteColor),
          SizedBox(height: 3.h),
          CommonText.text(
            title: label,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            textColor: AppColors.whiteColor,
          ),
        ],
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;

  const _CropOverlayPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Darken outside cropRect
    final overlayPath = Path()
      ..addRect(Offset.zero & size)
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = AppColors.blackColor.withValues(alpha: 0.55),
    );

    // White border around cropRect
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = AppColors.whiteColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 3x3 grid inside cropRect
    final gridPaint = Paint()
      ..color = AppColors.whiteColor.withValues(alpha: 0.45)
      ..strokeWidth = 0.8;

    for (var i = 1; i <= 2; i++) {
      final dx = cropRect.left + cropRect.width * (i / 3);
      canvas.drawLine(
        Offset(dx, cropRect.top),
        Offset(dx, cropRect.bottom),
        gridPaint,
      );
      final dy = cropRect.top + cropRect.height * (i / 3);
      canvas.drawLine(
        Offset(cropRect.left, dy),
        Offset(cropRect.right, dy),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) =>
      cropRect != oldDelegate.cropRect;
}
