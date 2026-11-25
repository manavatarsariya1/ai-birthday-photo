import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/pref_service.dart';
import 'log_event_manager.dart';

class DeviceInfoService {
  DeviceInfoService._();

  static const MethodChannel _channel = MethodChannel(
    'flutter_getx_project_structure/device_info',
  );

  /// Fetches native hardware/network specifications and logs the [device_info] event
  /// strictly ONCE in the lifetime of the app installation (first open only).
  /// Subsequent app opens or reopenings after app kill will NOT fire this event again.
  static Future<void> logDeviceInfoOnce() async {
    try {
      // Check persistent flag in SharedPreferences so it never fires again after app kill
      if (PrefService.getBool(PrefService.isDeviceInfoLogged, defaultValue: false)) {
        return;
      }

      if (!kIsWeb && Platform.isAndroid) {
        final Map<dynamic, dynamic>? rawMap =
            await _channel.invokeMethod<Map<dynamic, dynamic>>('getDeviceInfo');

        if (rawMap != null) {
          final cpuCores = (rawMap['cpu_cores'] as num?)?.toInt() ?? 0;
          final ramTotalMb = (rawMap['ram_total_mb'] as num?)?.toInt() ?? 0;
          final ramAvailMb = (rawMap['ram_avail_mb'] as num?)?.toInt() ?? 0;
          final storageTotalGb =
              (rawMap['storage_total_gb'] as num?)?.toInt() ?? 0;
          final isEmulator = (rawMap['is_emulator'] as num?)?.toInt() ?? 0;
          final refreshRate = (rawMap['refresh_rate'] as num?)?.toInt() ?? 60;
          final powerSave = (rawMap['power_save'] as num?)?.toInt() ?? 0;
          final network = (rawMap['network'] as String?) ?? 'none';
          final networkType = (rawMap['network_type'] as String?) ?? 'none';

          LogEventManager.logDeviceInfo(
            cpuCores: cpuCores,
            ramTotalMb: ramTotalMb,
            ramAvailMb: ramAvailMb,
            storageTotalGb: storageTotalGb,
            isEmulator: isEmulator,
            refreshRate: refreshRate,
            powerSave: powerSave,
            network: network,
            networkType: networkType,
          );

          await PrefService.setValue(PrefService.isDeviceInfoLogged, true);
          return;
        }
      }

      // iOS or Fallback
      LogEventManager.logDeviceInfo(
        cpuCores: 0,
        ramTotalMb: 0,
        ramAvailMb: 0,
        storageTotalGb: 0,
        isEmulator: 0,
        refreshRate: 60,
        powerSave: 0,
        network: 'none',
        networkType: 'none',
      );
      await PrefService.setValue(PrefService.isDeviceInfoLogged, true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [DeviceInfoService] Error logging device info: $e');
      }
    }
  }
}
