import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Stack(
              children: [
                const ModalBarrier(dismissible: false, color: Colors.black54),
                Center(
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 20.r,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
