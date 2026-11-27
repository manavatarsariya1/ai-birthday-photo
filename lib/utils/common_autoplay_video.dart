import 'package:video_player/video_player.dart';
import 'config_packages.dart';

/// Reusable muted, looping, auto-playing network video widget.
class CommonAutoPlayVideo extends StatefulWidget {
  final String videoUrl;

  const CommonAutoPlayVideo({super.key, required this.videoUrl});

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
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_hasError || controller == null || !controller.value.isInitialized) {
      return Container(
        color: AppColors.captionCardBg,
        child: Center(
          child: Icon(
            _hasError ? Icons.videocam_off_outlined : Icons.videocam_outlined,
            size: 28.r,
            color: AppColors.blackColor.withValues(alpha: 0.2),
          ),
        ),
      );
    }

    final size = controller.value.size;
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.width > 0 ? size.width : 1,
        height: size.height > 0 ? size.height : 1,
        child: VideoPlayer(controller),
      ),
    );
  }
}
