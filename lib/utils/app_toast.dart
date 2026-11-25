import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';

class AppToast {
  // ==========================================
  // TOAST MESSAGES (Redirected to Snackbars)
  // ==========================================

  /// Show success snackbar
  static void showSuccess(String message) {
    showSuccessSnackbar("Success", message);
  }

  /// Show error snackbar
  static void showError(String message) {
    showErrorSnackbar("Error", message);
  }

  /// Show info/standard snackbar
  static void showInfo(String message) {
    showInfoSnackbar("Info", message);
  }

  /// Generic customizable toast helper -> Redirected to info snackbar
  static void show(String message, {Color? backgroundColor}) {
    showInfoSnackbar("Info", message);
  }

  // ==========================================
  // SNACKBAR MESSAGES (Get.snackbar)
  // ==========================================

  /// Show a professional, premium Get.snackbar for Success
  static void showSuccessSnackbar(String title, String message) {
    // Get.closeAllSnackbars();
    // Get.snackbar(
    //   title,
    //   message,
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: AppColors.successColor.withValues(alpha: 0.9),
    //   colorText: Colors.white,
    //   margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    //   borderRadius: 16.r,
    //   duration: const Duration(seconds: 3),
    //   icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    //   boxShadows: [
    //     BoxShadow(
    //       color: Colors.black.withValues(alpha: 0.1),
    //       blurRadius: 8,
    //       offset: const Offset(0, 4),
    //     )
    //   ],
    // );
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.successColor,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  /// Show a professional, premium Get.snackbar for Error
  static void showErrorSnackbar(String title, String message) {
    // Get.closeAllSnackbars();
    // Get.snackbar(
    //   title,
    //   message,
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: AppColors.errorColor.withValues(alpha: 0.9),
    //   colorText: Colors.white,
    //   margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    //   borderRadius: 16.r,
    //   duration: const Duration(seconds: 3),
    //   icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    //   boxShadows: [
    //     BoxShadow(
    //       color: Colors.black.withValues(alpha: 0.1),
    //       blurRadius: 8,
    //       offset: const Offset(0, 4),
    //     )
    //   ],
    // );
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.errorColor,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  /// Show a professional, premium Get.snackbar for Info
  static void showInfoSnackbar(String title, String message) {
    // Get.closeAllSnackbars();
    // Get.snackbar(
    //   title,
    //   message,
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: AppColors.infoColor.withValues(alpha: 0.9),
    //   colorText: Colors.white,
    //   margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    //   borderRadius: 16.r,
    //   duration: const Duration(seconds: 3),
    //   icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
    //   boxShadows: [
    //     BoxShadow(
    //       color: Colors.black.withValues(alpha: 0.1),
    //       blurRadius: 8,
    //       offset: const Offset(0, 4),
    //     )
    //   ],
    // );
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.infoColor,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }
}
