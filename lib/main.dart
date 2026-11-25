import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'constant/app_constant.dart';
import 'localization/app_translations.dart';
import 'routes/app_pages.dart';
import 'services/ad_service/ad_managers/revenue_threshold_manager.dart';
import 'services/consent_service.dart';
import 'services/log_event_manager.dart';
import 'theme/app_theme.dart';
import 'utils/pref_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Silence logs in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // 1. Lock app orientation to Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // 2. Initialize SharedPreferences & Local storage
  await PrefService.init();

  // 3. Initialize Revenue Threshold Manager (Taichi Model)
  await RevenueThresholdManager.init();

  // 4. Initialize Mobile Ads & Consent
  try {
    await ConsentService.handleGDPR();
    await ConsentService.initializeMobileAds();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Main] MobileAds init error: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          defaultTransition: appDefaultTransition,
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          initialRoute: AppPages.initial,
          getPages: AppPages.pages,
          navigatorObservers: [
            LogEventManager.observer,
          ],
        );
      },
    );
  }
}
