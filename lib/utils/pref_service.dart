import 'package:shared_preferences/shared_preferences.dart';
import '../services/remote_config_service.dart';

class PrefService {
  static SharedPreferences? _prefs;

  // Constants keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userCredits = 'user_credits';
  static const String userName = 'user_name';
  static const String isAppLock = 'is_app_lock';
  static const String deviceId = 'device_id';
  static const String isDeviceInfoLogged = 'is_device_info_logged';
  static const String isFirstTime = 'is_first_time';
  static const String isSubscribed = 'is_subscribed';

  // Attribution & Marketing
  static const String isIntroDone = 'is_intro_done';
  static const String isLanguageDone = 'is_language_done';
  static const String isMarketingUser = 'is_marketing_user';
  static const String userAttributionType = 'user_attribution_type';
  static const String isPremium = 'is_premium';
  static const String appOpenCount = 'app_open_count';

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Call once per process start after [init].
  static Future<void> recordAppOpen() async {
    if (!containsKey(appOpenCount)) {
      final existingUser = getBool(isIntroDone, defaultValue: false);
      await setValue(appOpenCount, existingUser ? 999 : 1);
      return;
    }
    await setValue(appOpenCount, getInt(appOpenCount) + 1);
  }

  /// True when the user's cold-start count is within the dynamic Remote Config threshold.
  static bool get isFirstTimeAdUser {
    final limit = RemoteConfigService.firstTimeUserOpenCount;
    return getInt(appOpenCount, defaultValue: 1) <= limit;
  }

  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // Getters
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  // Setters
  static Future<bool> setValue(String key, dynamic value) async {
    if (_prefs == null) return false;
    if (value is String) {
      return await _prefs!.setString(key, value);
    } else if (value is bool) {
      return await _prefs!.setBool(key, value);
    } else if (value is int) {
      return await _prefs!.setInt(key, value);
    } else if (value is double) {
      return await _prefs!.setDouble(key, value);
    } else if (value is List<String>) {
      return await _prefs!.setStringList(key, value);
    }
    return false;
  }

  // Clear specific key
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // Clear all preferences
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}
