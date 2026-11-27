import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../constant/app_constant.dart';
import '../../data/models/templates_api_model.dart';
import '../../services/api_service.dart';

class AnniversaryController extends GetxController {
  final RxInt selectedCategoryIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxList<TemplateCategoryModel> categories =
      <TemplateCategoryModel>[].obs;

  List<TemplateItemModel> get currentTemplates {
    if (categories.isEmpty) return [];
    final idx = selectedCategoryIndex.value.clamp(0, categories.length - 1);
    return categories[idx].templates;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAnniversaryTemplates();
  }

  Future<void> fetchAnniversaryTemplates() async {
    isLoading.value = true;
    try {
      final response = await ApiService.get(
        url: '${baseUrl}templates/app?type=anniversary',
      );
      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = TemplatesApiResponse.fromJson(decoded);
        if (parsed.success) {
          categories.assignAll(parsed.data);
          selectedCategoryIndex.value = 0;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Anniversary templates error: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
