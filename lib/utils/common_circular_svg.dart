import 'config_packages.dart';

class CommonCircularSvg extends StatelessWidget {
  final String imagePath;
  final Color? color;
  final double? padding;
  final double? size;

  const CommonCircularSvg({
    super.key,
    required this.imagePath,
    this.color,
    this.padding,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primaryColor;
    return Container(
      padding: EdgeInsets.all(padding ?? 12.r),
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: CommonSvgImage(imagePath: imagePath, color: activeColor),
    );
  }
}
