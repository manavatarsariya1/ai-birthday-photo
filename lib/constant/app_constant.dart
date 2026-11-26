import 'package:get/get.dart';

const String appFontFamily = 'Poppins';

// App Environment Constants
String appName = 'AI Birthday';
String appVersion = '1.0.0';
String dynamicAppVersion = '1.0.0';

// API Base URLs
String baseUrlLive = 'https://api.yourapp.com/';
String baseUrlDev  = 'http://192.168.0.61:7040/api/v1/';
bool isLiveMode    = false;

String get baseUrl => isLiveMode ? baseUrlLive : baseUrlDev;

// Navigation Transition
const Transition appDefaultTransition = Transition.rightToLeft;

/// Standard static constants class
class AppConstant {
  AppConstant._();

  static const String appName = 'Flutter Master Boilerplate';
  static const String appVersion = '1.0.0';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.example.flutter_getx_project_structure';
  static const String appStoreUrl =
      'https://apps.apple.com/app/id0000000000';
}
