import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../constant/app_constant.dart';
import '../../constant/app_strings.dart';
import '../../data/models/templates_api_model.dart';
import '../../services/api_service.dart';
import '../../services/log_event_manager.dart';
import '../../ui/templates/widgets/template_sheets.dart';

class TemplatesController extends GetxController {
  final RxInt selectedTypeIndex = 0.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxList<TemplateCategoryModel> apiCategories =
      <TemplateCategoryModel>[].obs;

  List<String> get types => [
        AppStrings.tabPhoto,
        AppStrings.tabVideo,
        AppStrings.tabCard,
      ];

  bool get isVideoMode => selectedTypeIndex.value == 1;

  String get _currentTypeQuery {
    switch (selectedTypeIndex.value) {
      case 1:
        return 'video';
      case 2:
        return 'card';
      default:
        return 'photo';
    }
  }

  List<String> get categories {
    if (apiCategories.isNotEmpty) {
      return apiCategories.map((e) => e.name).toList();
    }
    return isVideoMode
        ? const [
            'Blow the Candle',
            'Confetti Magic',
            'Balloon Surprise',
            'Cake Cut',
          ]
        : const [
            'Trending',
            'Luxury Birthday',
            'Birthday Girl',
            'Birthday Boy',
          ];
  }

  List<TemplateItemModel> get currentTemplates {
    if (apiCategories.isEmpty) return [];
    final idx = selectedCategoryIndex.value.clamp(0, apiCategories.length - 1);
    return apiCategories[idx].templates;
  }

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logEvent('templates_view');
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    isLoading.value = true;
    try {
      final response = await ApiService.get(
        url: '${baseUrl}templates/app?type=$_currentTypeQuery',
      );
      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = TemplatesApiResponse.fromJson(decoded);
        if (parsed.success) {
          apiCategories.assignAll(parsed.data);
          selectedCategoryIndex.value = 0;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Templates fetch error: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onTypeChanged(int index) {
    if (selectedTypeIndex.value == index) return;
    selectedTypeIndex.value = index;
    selectedCategoryIndex.value = 0;
    LogEventManager.logEvent('templates_type_click', {'type': types[index]});
    fetchTemplates();
  }

  void onCategoryChanged(int index) {
    selectedCategoryIndex.value = index;
    LogEventManager.logEvent(
      'templates_category_click',
      {'category': categories[index]},
    );
  }

  void onTemplateTap(int index) {
    LogEventManager.logEvent(
      'templates_item_click',
      {
        'index': index,
        'type': types[selectedTypeIndex.value],
        'category': categories[selectedCategoryIndex.value],
      },
    );
    TemplateSheets.showTipsSheet(isVideo: isVideoMode);
  }
}
