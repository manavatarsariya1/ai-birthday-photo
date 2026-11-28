import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../constant/app_constant.dart';
import '../../constant/app_strings.dart';
import '../../data/models/templates_api_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/log_event_manager.dart';
import '../../ui/templates/widgets/template_sheets.dart';

class TemplatesController extends GetxController {
  final RxInt selectedTypeIndex = 0.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  String? _pendingCategoryId;
  int _fetchRequestId = 0;
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

  List<String> get categories => apiCategories.map((e) => e.name).toList();

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
    final int requestId = ++_fetchRequestId;
    isLoading.value = true;
    try {
      final response = await ApiService.get(
        url: '${baseUrl}templates/app?type=$_currentTypeQuery',
      );
      if (requestId != _fetchRequestId) return;
      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = TemplatesApiResponse.fromJson(decoded);
        if (parsed.success) {
          apiCategories.assignAll(parsed.data);
          if (_pendingCategoryId != null) {
            final idx = apiCategories.indexWhere(
              (c) => c.id == _pendingCategoryId,
            );
            selectedCategoryIndex.value = idx >= 0 ? idx : 0;
            _pendingCategoryId = null;
          } else {
            selectedCategoryIndex.value = 0;
          }
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

  void selectTypeAndCategory(String type, String categoryId) {
    final normalized = type.toLowerCase().trim();
    final typeIndex = normalized == 'video'
        ? 1
        : normalized == 'card'
            ? 2
            : 0;

    if (selectedTypeIndex.value == typeIndex && apiCategories.isNotEmpty) {
      final idx = apiCategories.indexWhere((c) => c.id == categoryId);
      if (idx >= 0) {
        selectedCategoryIndex.value = idx;
        return;
      }
    }

    _pendingCategoryId = categoryId;
    if (selectedTypeIndex.value != typeIndex) {
      selectedTypeIndex.value = typeIndex;
      selectedCategoryIndex.value = 0;
      apiCategories.clear();
    }
    fetchTemplates();
  }

  void onTypeChanged(int index) {
    if (selectedTypeIndex.value == index) return;
    selectedTypeIndex.value = index;
    selectedCategoryIndex.value = 0;
    apiCategories.clear();
    LogEventManager.logEvent('templates_type_click', {'type': types[index]});
    fetchTemplates();
  }

  void onCategoryChanged(int index) {
    selectedCategoryIndex.value = index;
    LogEventManager.logEvent('templates_category_click', {
      'category': categories[index],
    });
  }

  void onTemplateTap(int index) {
    LogEventManager.logEvent('templates_item_click', {
      'index': index,
      'type': types[selectedTypeIndex.value],
      'category': categories[selectedCategoryIndex.value],
    });
    final items = currentTemplates;
    final template = (items.isNotEmpty && index < items.length)
        ? items[index]
        : null;
    if (selectedTypeIndex.value == 2) {
      final imageUrl = template?.image ?? '';
      Get.toNamed(
        AppRoutes.addCardDetails,
        arguments: {'imageUrl': imageUrl, 'template': template},
      );
      return;
    }
    TemplateSheets.showTipsSheet(isVideo: isVideoMode, template: template);
  }
}
