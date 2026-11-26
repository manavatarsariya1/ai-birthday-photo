import 'package:get/get.dart';

import 'app_routes.dart';
import '../ui/home/home_screen.dart';
import '../ui/language/language_screen.dart';
import '../ui/onboarding/onboarding_screen.dart';
import '../ui/paywall/paywall_screen.dart';
import '../ui/splash/splash_screen.dart';

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
      name: AppRoutes.language,
      page: () => const LanguageScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.paywall,
      page: () => const PaywallScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
