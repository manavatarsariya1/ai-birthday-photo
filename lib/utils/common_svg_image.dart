import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonSvgImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;

  const CommonSvgImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      imagePath,
      height: height,
      width: width,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      fit: fit ?? BoxFit.contain,
    );
  }
}
