// ignore_for_file: file_names, must_be_immutable
import 'config_packages.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  bool isChecking = false;

  Future<void> _checkConnection() async {
    setState(() {
      isChecking = true;
    });

    // Check connectivity status
    final List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();
    
    // If we have internet, route to appropriate screen
    if (connectivityResults.isNotEmpty && connectivityResults.first != ConnectivityResult.none) {
      final isLoggedIn = PrefService.getBool('is_login', defaultValue: false);
      if (isLoggedIn) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    } else {
      AppToast.showErrorSnackbar(
        'Offline',
        'Still no internet connection. Please try again.',
      );
    }

    setState(() {
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center SVG or Icon
            const Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 24),
            CommonText.text(
              title: 'No Internet Connection',
              fontSize: FontSizes.text20,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            CommonText.text(
              textAlign: TextAlign.center,
              title: 'Please check your connection and try again.',
              fontWeight: FontWeight.w500,
              color: AppColors.greyColor,
            ),
            const SizedBox(height: 48),
            isChecking
                ? const CircularProgressIndicator()
                : CommonWidgets.cupertinoButton(
                    onTap: _checkConnection,
                    flag: false,
                    color: AppColors.primaryColor,
                    title: 'Try Again',
                    height: 50,
                    width: double.infinity,
                  ),
          ],
        ),
      ),
    );
  }
}
