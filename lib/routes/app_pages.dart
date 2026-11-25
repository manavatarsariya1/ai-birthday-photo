import 'package:get/get.dart';

import 'app_routes.dart';
import '../ui/splash/splash_screen.dart';
import '../ui/home/home_screen.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

