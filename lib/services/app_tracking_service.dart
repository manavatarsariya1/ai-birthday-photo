import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'log_event_manager.dart';

class AppTrackingService {
  AppTrackingService._();

  /// Requests App Tracking Transparency (ATT) authorization on iOS.
  /// Safe to call on all platforms (no-op on Android/Web).
  static Future<TrackingStatus> requestTrackingPermission() async {
    if (kIsWeb || !Platform.isIOS) {
      return TrackingStatus.notSupported;
    }

    try {
      final initialStatus =
          await AppTrackingTransparency.trackingAuthorizationStatus;

      if (kDebugMode) {
        debugPrint(
            '📱 [AppTrackingService] Initial ATT Status: ${initialStatus.name}');
      }

      if (initialStatus == TrackingStatus.notDetermined) {
        // Wait a short duration so the native iOS UI window hierarchy is fully ready
        await Future.delayed(const Duration(milliseconds: 400));
        final status =
            await AppTrackingTransparency.requestTrackingAuthorization();

        if (kDebugMode) {
          debugPrint(
              '📱 [AppTrackingService] Updated ATT Status: ${status.name}');
        }

        LogEventManager.logAttPermissionResult(status: status.name);
        return status;
      }

      LogEventManager.logAttPermissionResult(status: initialStatus.name);
      return initialStatus;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [AppTrackingService] Error requesting ATT: $e');
      }
      return TrackingStatus.notSupported;
    }
  }

  /// Returns the advertising identifier (IDFA) if authorized, or empty string.
  static Future<String> getAdvertisingIdentifier() async {
    if (kIsWeb || !Platform.isIOS) return '';
    try {
      final status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.authorized) {
        return await AppTrackingTransparency.getAdvertisingIdentifier();
      }
    } catch (_) {}
    return '';
  }
}
