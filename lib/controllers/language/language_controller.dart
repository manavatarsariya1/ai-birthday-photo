import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/language_model.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';

class LanguageController extends GetxController {
  static const String _prefSelectedLanguage = 'selected_language_code';

  final RxString selectedCode = 'en'.obs;

  final List<LanguageModel> languages = const [
    LanguageModel(
      code: 'en',
      name: 'English',
      subtitle: 'United States • Global',
      flagEmoji: '🇺🇸',
    ),
    LanguageModel(
      code: 'hi',
      name: 'हिन्दी',
      subtitle: 'Hindi • भारत',
      flagEmoji: '🇮🇳',
    ),
    LanguageModel(
      code: 'es',
      name: 'Español',
      subtitle: 'Spanish • América Latina y España',
      flagEmoji: '🇪🇸',
    ),
    LanguageModel(
      code: 'fr',
      name: 'Français',
      subtitle: 'French • France & Canada',
      flagEmoji: '🇫🇷',
    ),
    LanguageModel(
      code: 'de',
      name: 'Deutsch',
      subtitle: 'German • Deutschland & Österreich',
      flagEmoji: '🇩🇪',
    ),
    LanguageModel(
      code: 'ar',
      name: 'العربية',
      subtitle: 'Arabic • الشرق الأوسط',
      flagEmoji: '🇸🇦',
    ),
    LanguageModel(
      code: 'ru',
      name: 'Русский',
      subtitle: 'Russian • Россия',
      flagEmoji: '🇷🇺',
    ),
    LanguageModel(
      code: 'ko',
      name: '한국어',
      subtitle: 'Korean • 대한민국',
      flagEmoji: '🇰🇷',
    ),
    LanguageModel(
      code: 'vi',
      name: 'Tiếng Việt',
      subtitle: 'Vietnamese • Việt Nam',
      flagEmoji: '🇻🇳',
    ),
    LanguageModel(
      code: 'fil',
      name: 'Filipino',
      subtitle: 'Filipino • Pilipinas',
      flagEmoji: '🇵🇭',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logEvent('language_view');
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefSelectedLanguage);
    if (saved != null && saved.isNotEmpty) {
      selectedCode.value = saved;
    }
  }

  void selectLanguage(String code) {
    selectedCode.value = code;
    LogEventManager.logEvent('language_select_click', {'language': code});
  }

  Future<void> onDoneTap() async {
    LogEventManager.logEvent(
      'language_done_click',
      {'language': selectedCode.value},
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSelectedLanguage, selectedCode.value);
    await Get.updateLocale(Locale(selectedCode.value));
    Get.offAllNamed(AppRoutes.onboarding);
  }
}
