import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonLoader extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;
  final double? padding;

  const CommonLoader({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padding ?? 60.h),
        child: CupertinoActivityIndicator(
          color: color,
          radius: size != null ? size! / 2 : 15.r,
        ),
      ),
    );
  }
}
