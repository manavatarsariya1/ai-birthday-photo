import 'package:get/get.dart';

import 'app_routes.dart';
import '../ui/age_calculator/age_calculator_screen.dart';
import '../ui/age_calculator/age_result_screen.dart';
import '../ui/card/add_card_details_screen.dart';
import '../ui/card/card_full_preview_screen.dart';
import '../ui/card/card_generating_screen.dart';
import '../ui/card/card_result_screen.dart';
import '../ui/creation/creation_preview_screen.dart';
import '../ui/creation/creation_screen.dart';
import '../ui/home/home_screen.dart';
import '../ui/language/language_screen.dart';
import '../ui/onboarding/onboarding_screen.dart';
import '../ui/paywall/paywall_screen.dart';
import '../ui/reminders/add_reminder_screen.dart';
import '../ui/reminders/reminder_detail_screen.dart';
import '../ui/result/report_problem_screen.dart';
import '../ui/settings/feedback_screen.dart';
import '../ui/splash/splash_screen.dart';
import '../ui/uninstall/uninstall_reason_screen.dart';
import '../ui/uninstall/uninstall_retention_screen.dart';
import '../ui/uninstall/uninstall_thank_you_screen.dart';

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
    GetPage(
      name: AppRoutes.addReminder,
      page: () => const AddReminderScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.reminderDetail,
      page: () => const ReminderDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ageCalculator,
      page: () => const AgeCalculatorScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ageResult,
      page: () => const AgeResultScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.creation,
      page: () => const CreationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.creationPreview,
      page: () => const CreationPreviewScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addCardDetails,
      page: () => const AddCardDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.cardGenerating,
      page: () => const CardGeneratingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.cardResult,
      page: () => const CardResultScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.cardFullPreview,
      page: () => const CardFullPreviewScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.uninstallRetention,
      page: () => const UninstallRetentionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.uninstallReason,
      page: () => const UninstallReasonScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.uninstallThankYou,
      page: () => const UninstallThankYouScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.reportProblem,
      page: () => const ReportProblemScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
