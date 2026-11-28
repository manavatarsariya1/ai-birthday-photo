import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'config_packages.dart';

/// Reusable muted, looping, auto-playing network video widget.
class CommonAutoPlayVideo extends StatefulWidget {
  final String videoUrl;
  final bool enableTapToToggle;

  const CommonAutoPlayVideo({
    super.key,
    required this.videoUrl,
    this.enableTapToToggle = false,
  });

  @override
  State<CommonAutoPlayVideo> createState() => _CommonAutoPlayVideoState();
}

class _CommonAutoPlayVideoState extends State<CommonAutoPlayVideo> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (TickerMode.of(context)) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  @override
  void didUpdateWidget(covariant CommonAutoPlayVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _hasError = false;
      _initController();
    }
  }

  void _initController() {
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      _hasError = true;
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;

    controller
        .initialize()
        .then((_) {
          if (!mounted || _controller != controller) return;
          controller.setLooping(true);
          controller.setVolume(0.0);
          controller.play();
          setState(() {});
        })
        .catchError((e) {
          if (kDebugMode) {
            debugPrint('CommonAutoPlayVideo error: $e');
          }
          if (mounted && _controller == controller) {
            setState(() => _hasError = true);
          }
        });
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller.pause();
      Future.delayed(const Duration(milliseconds: 50), () {
        controller.dispose();
      });
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_hasError) {
      return Container(
        color: AppColors.captionCardBg,
        child: Center(
          child: Icon(
            Icons.videocam_off_outlined,
            size: 28.r,
            color: AppColors.blackColor.withValues(alpha: 0.2),
          ),
        ),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return Shimmer.fromColors(
        baseColor: const Color(0xFFD6D6E0),
        highlightColor: const Color(0xFFF5F5FA),
        child: Container(color: AppColors.whiteColor),
      );
    }

    final size = controller.value.size;
    final videoWidget = FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.width > 0 ? size.width : 1,
        height: size.height > 0 ? size.height : 1,
        child: VideoPlayer(controller),
      ),
    );

    if (!widget.enableTapToToggle) return videoWidget;

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final isPlaying = value.isPlaying;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              child!,
              if (!isPlaying)
                Center(
                  child: Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: AppColors.blackColor.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 34.r,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      child: videoWidget,
    );
  }
}
