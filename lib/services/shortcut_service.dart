import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/home/home_controller.dart';
import '../routes/app_routes.dart';

class ShortcutService {
  ShortcutService._();

  static const MethodChannel _channel =
      MethodChannel('com.aibirthdayphoto/shortcuts');
  static bool _initialized = false;

  static Future<String?> getInitialShortcut() async {
    try {
      return await _channel.invokeMethod<String>('getInitialShortcut');
    } catch (_) {
      return null;
    }
  }

  static Future<void> init() async {
    if (!_initialized) {
      _initialized = true;
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onShortcutTapped') {
          final type = call.arguments as String?;
          if (type != null && type.isNotEmpty) {
            _handleShortcut(type);
          }
        }
      });
    }

    try {
      final initial = await _channel.invokeMethod<String>('getInitialShortcut');
      if (initial != null && initial.isNotEmpty) {
        _handleShortcut(initial);
      }
    } catch (_) {}
  }

  static void _handleShortcut(String type) {
    switch (type) {
      case 'uninstall_app':
        Get.toNamed(AppRoutes.uninstallRetention);
        break;
      case 'templates':
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().selectedTabIndex.value = 1;
        }
        break;
      case 'reminders':
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().selectedTabIndex.value = 2;
        }
        break;
    }
  }
}
