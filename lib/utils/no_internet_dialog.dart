import 'config_packages.dart';

class NoInternetDialog extends StatefulWidget {
  const NoInternetDialog({super.key});

  static bool isShowing = false;

  static Future<void> show() async {
    if (isShowing) return;
    isShowing = true;
    await Get.dialog(
      const NoInternetDialog(),
      barrierDismissible: false,
    );
  }

  @override
  State<NoInternetDialog> createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends State<NoInternetDialog> {
  bool _isChecking = false;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
      final bool hasNetwork = results.isNotEmpty && results.first != ConnectivityResult.none;
      
      bool hasInternet = false;
      if (hasNetwork) {
        hasInternet = await InternetConnectionChecker.instance.hasConnection;
      }

      if (hasInternet) {
        NoInternetDialog.isShowing = false;
        Get.back(); // Close dialog
        AppToast.showSuccess("Internet connection restored!");
      } else {
        AppToast.showErrorSnackbar(
          "No Internet",
          "Still no internet connection. Please verify your connection and try again.",
        );
      }
    } catch (e) {
      AppToast.showErrorSnackbar("Error", "Unable to verify internet connection. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: AppColors.getBorderColor(context),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // WiFi Off Icon Header
              Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.primaryColor,
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              CommonText.text(
                title: "No Internet Connection",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Description
              CommonText.text(
                title: "You are currently offline. Please check your network connection and click try again to proceed.",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.getSecondaryTextColor(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),

              // Action Button
              _isChecking
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      ),
                    )
                  : CommonWidgets.cupertinoButton(
                      onTap: _checkConnection,
                      height: 46.h,
                      width: double.infinity,
                      flag: false,
                      title: "Try Again",
                      color: AppColors.primaryColor,
                      titleColor: Colors.white,
                      radius: 12.r,
                      fontSize: 14,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
