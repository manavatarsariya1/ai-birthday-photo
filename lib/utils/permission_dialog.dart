// ignore_for_file: deprecated_member_use

import 'config_packages.dart';

class PermissionDialogUI extends StatelessWidget {
  final String type;

  const PermissionDialogUI({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (val) async => true,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText.text(
              title: 'Permission Access Needed',
              fontSize: FontSizes.text18,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: Get.height * .02),
            CommonText.text(
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
              color: AppColors.greyColor,
              title: 'The app has been denied $type permission. Please enable it from settings.',
            ),
            SizedBox(height: Get.height * .05),
            Row(
              children: [
                Expanded(
                  child: CommonWidgets.cupertinoButton(
                    color: AppColors.primaryColor,
                    onTap: () async {
                      Get.back();
                      openAppSettings();
                    },
                    height: Get.height * 0.06,
                    width: Get.width,
                    flag: false,
                    title: 'Open Settings',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CommonWidgets.cupertinoButton(
                    color: AppColors.blackColor,
                    onTap: () {
                      Get.back();
                    },
                    height: Get.height * 0.06,
                    width: Get.width,
                    flag: false,
                    title: 'Cancel',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppLockDialogUI extends StatelessWidget {
  const AppLockDialogUI({super.key});

  Future<void> _openSecuritySettings() async {
    // Open app settings natively
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (val) async => true,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText.text(
              title: "Set Up Device Security",
              fontSize: FontSizes.text18,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: Get.height * .02),
            CommonText.text(
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
              color: AppColors.greyColor,
              title:
                  "To enable App Lock, set up ${(Platform.isAndroid) ? "Fingerprint" : "Facelock"} on your device. Go to your phone's Security settings to set it up.",
            ),
            SizedBox(height: Get.height * .03),
            Row(
              children: [
                Expanded(
                  child: CommonWidgets.cupertinoButton(
                    color: AppColors.blackColor,
                    onTap: () {
                      Get.back();
                    },
                    height: Get.height * 0.06,
                    width: Get.width,
                    flag: false,
                    title: 'Cancel',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CommonWidgets.cupertinoButton(
                    color: AppColors.primaryColor,
                    onTap: () async {
                      Get.back();
                      await _openSecuritySettings();
                    },
                    height: Get.height * 0.06,
                    width: Get.width,
                    flag: false,
                    title: 'OK',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
