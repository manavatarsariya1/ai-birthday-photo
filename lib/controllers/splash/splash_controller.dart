import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constant/app_constant.dart';
import '../../data/models/guest_login_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/log_event_manager.dart';
import '../../services/shortcut_service.dart';
import '../../utils/pref_service.dart';
import '../home/home_controller.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logSplashView();
    _startInitFlow();
  }

  Future<void> _startInitFlow() async {
    progress.value = 0.3;
    await _performGuestLogin();
    progress.value = 0.7;
    await Future.delayed(const Duration(milliseconds: 600));
    progress.value = 1.0;
    await Future.delayed(const Duration(milliseconds: 350));

    final isLanguageDone = PrefService.getBool(PrefService.isLanguageDone);
    final isIntroDone = PrefService.getBool(PrefService.isIntroDone);

    if (!isLanguageDone) {
      Get.offAllNamed(AppRoutes.language);
    } else if (!isIntroDone) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else {
      final shortcut = await ShortcutService.getInitialShortcut();
      if (shortcut == 'uninstall_app') {
        Get.offAllNamed(AppRoutes.uninstallRetention);
      } else {
        Get.offAllNamed(AppRoutes.home);
        if (shortcut == 'templates' && Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().selectedTabIndex.value = 1;
        } else if (shortcut == 'reminders' &&
            Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().selectedTabIndex.value = 2;
        }
      }
    }
  }

  Future<String> _getRealDeviceId() async {
    String resolvedId = '';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (!kIsWeb && Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        resolvedId = androidInfo.id;
      } else if (!kIsWeb && Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        resolvedId = iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeviceInfo error: $e');
      }
    }

    if (resolvedId.isNotEmpty) {
      await PrefService.setValue(PrefService.deviceId, resolvedId);
      return resolvedId;
    }
    return PrefService.getString(PrefService.deviceId);
  }

  Future<void> _performGuestLogin() async {
    try {
      final deviceId = await _getRealDeviceId();
      final packageInfo = await PackageInfo.fromPlatform();
      final realAppVersion =
          packageInfo.version.isNotEmpty ? packageInfo.version : appVersion;
      final rawCountry = PlatformDispatcher.instance.locale.countryCode ?? '';
      final countryCode = rawCountry.isNotEmpty ? rawCountry : 'US';

      final response = await ApiService.post(
        url: '${baseUrl}auth/guest-login',
        requiresAuth: false,
        body: {
          'deviceId': deviceId,
          'platform': !kIsWeb && Platform.isIOS ? 'ios' : 'android',
          'appVersion': realAppVersion,
          'fcmToken': '',
          'adSource': 'organic',
          'countryCode': countryCode,
        },
      );

      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = GuestLoginResponse.fromJson(decoded);
        if (parsed.success && parsed.data != null) {
          await PrefService.setValue(
            PrefService.accessToken,
            parsed.data!.token,
          );
          await PrefService.setValue(
            PrefService.userCredits,
            parsed.data!.credits,
          );
          if (kDebugMode) {
            debugPrint(
              'Guest login success — credits: ${parsed.data!.credits}',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Guest login error: $e');
      }
    }
  }
}
