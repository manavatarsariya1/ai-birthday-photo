// ignore_for_file: deprecated_member_use
import 'config_packages.dart';

class CommonImage {
  static Widget assetImage({
    required String imagePath,
    double? height,
    double? width,
    Color? color,
    BoxFit? boxFit,
  }) {
    return Image.asset(
      imagePath,
      fit: boxFit ?? BoxFit.contain,
      height: height,
      width: width,
      color: color,
    );
  }

  static Widget fileImage({
    required String imagePath,
    double? height,
    double? width,
    Color? color,
    BoxFit? boxFit,
    required double radius,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.file(
        File(imagePath),
        fit: boxFit ?? BoxFit.contain,
        height: height,
        width: width,
        color: color,
      ),
    );
  }

  static Widget svgImage({
    required String imagePath,
    double? height,
    double? width,
    Color? color,
    BoxFit? boxFit,
  }) {
    return SvgPicture.asset(
      imagePath,
      fit: boxFit ?? BoxFit.contain,
      height: height,
      width: width,
      color: color,
    );
  }

  static Widget networkImage({
    required String imagePath,
    required double height,
    required double width,
    required double radius,
    required String errorImagePath,
  }) {
    // Validate URL - return error widget if URL is empty or invalid
    if (imagePath.isEmpty ||
        !imagePath.startsWith('http://') && !imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          width: width,
          child: errorImagePath.endsWith('svg')
              ? svgImage(imagePath: errorImagePath)
              : assetImage(imagePath: errorImagePath),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        height: height,
        width: width,
        errorWidget: (BuildContext context, String url, Object error) {
          return errorImagePath.endsWith('svg')
              ? svgImage(imagePath: errorImagePath)
              : assetImage(imagePath: errorImagePath);
        },
        placeholder: (BuildContext context, String url) {
          return Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Container(width: width, height: height, color: Colors.white),
          );
        },
      ),
    );
  }
}

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final double? radius;
  final bool isCircle;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.radius,
    this.isCircle = false,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Container(
              height: height,
              width: width ?? double.infinity,
              color: Colors.white,
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            height: height,
            width: width ?? double.infinity,
            color: AppColors.getBorderColor(context),
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image,
              size: height != null ? (height! * 0.3).clamp(16.0, 40.0) : 24.0,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
    );

    if (isCircle) {
      return ClipOval(child: image);
    } else if (radius != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: image,
      );
    }
    return image;
  }
}
