// ============================================================
// NotificationService — Firebase Messaging Stub
// ============================================================
// This is a reusable stub located under lib/services/.
// Uncomment & implement when adding Firebase Cloud Messaging (FCM) to a project.
//
// Required packages (add to pubspec.yaml):
//   firebase_messaging: ^15.0.0
//   flutter_local_notifications: ^18.0.0
// ============================================================

import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // FCM Token
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging.
  /// Call this from main() after Firebase.initializeApp().
  Future<void> initialize() async {
    //
    // final messaging = FirebaseMessaging.instance;
    //
    // // Request permissions (iOS)
    // await messaging.requestPermission(
    //   alert: true, badge: true, sound: true,
    // );
    //
    // // Get FCM Token
    // _fcmToken = await messaging.getToken();
    //
    // // Listen to token refresh
    // messaging.onTokenRefresh.listen((token) {
    //   _fcmToken = token;
    // });
    //
    // // Handle foreground messages
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    //
    // // Handle background/terminated taps
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // void _handleForegroundMessage(RemoteMessage message) {
  //   // Show local notification or in-app banner
  // }

  // void _handleNotificationTap(RemoteMessage message) {
  //   // Navigate based on message data
  // }

  /// Subscribe to a FCM topic.
  Future<void> subscribeToTopic(String topic) async {
    // await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  /// Unsubscribe from a FCM topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    // await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  /// Delete the current FCM token (useful on logout).
  Future<void> deleteToken() async {
    // await FirebaseMessaging.instance.deleteToken();
    _fcmToken = null;
  }
}
