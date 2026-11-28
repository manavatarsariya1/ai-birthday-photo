import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constant/app_constant.dart';
import '../../data/models/caption_models.dart';
import '../../services/api_service.dart';
import '../../services/log_event_manager.dart';

class CaptionController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxList<CaptionItemModel> generatedCaptions = <CaptionItemModel>[].obs;
  final RxList<CaptionItemModel> savedCaptions = <CaptionItemModel>[].obs;
  final RxList<CaptionCategoryModel> categories = <CaptionCategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingCaptions = false.obs;
  final RxBool isLoadingMoreCaptions = false.obs;
  int _currentPage = 1;
  int _totalPages = 1;
  String _currentCategoryId = '';
  String _currentName = '';

  bool get hasMoreCaptions => _currentPage < _totalPages;

  Future<void> fetchCaptions({
    String? categoryId,
    String? name,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (isLoadingMoreCaptions.value || !hasMoreCaptions) return;
      _currentPage++;
      isLoadingMoreCaptions.value = true;
    } else {
      _currentCategoryId = categoryId ?? _currentCategoryId;
      _currentName = name ?? _currentName;
      _currentPage = 1;
      _totalPages = 1;
      generatedCaptions.clear();
      isLoadingCaptions.value = true;
    }

    try {
      final encodedName = Uri.encodeQueryComponent(_currentName);
      final response = await ApiService.get(
        url:
            '${baseUrl}captions?categoryId=$_currentCategoryId&name=$encodedName&page=$_currentPage&limit=20',
      );
      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] is Map) {
          final data = decoded['data'] as Map<String, dynamic>;
          final pagination = data['pagination'] as Map<String, dynamic>?;
          _totalPages = (pagination?['totalPages'] as num?)?.toInt() ?? 1;

          final rawItems = data['items'] as List? ?? const [];
          final savedIds = savedCaptions.map((e) => e.id).toSet();
          final parsed = rawItems.map((e) {
            final map = e as Map<String, dynamic>;
            final id = map['id']?.toString() ?? '';
            return CaptionItemModel(
              id: id,
              text: map['content']?.toString() ?? '',
              isFavorite: savedIds.contains(id),
            );
          }).toList();

          if (loadMore) {
            generatedCaptions.addAll(parsed);
          } else {
            generatedCaptions.assignAll(parsed);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Captions fetch error: $e');
      }
    } finally {
      isLoadingCaptions.value = false;
      isLoadingMoreCaptions.value = false;
    }
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      final response = await ApiService.get(
        url: '${baseUrl}captions/categories',
      );
      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] is List) {
          final list = decoded['data'] as List;
          categories.assignAll(
            list
                .asMap()
                .entries
                .map(
                  (e) => CaptionCategoryModel.fromJson(
                    e.value as Map<String, dynamic>,
                    e.key,
                  ),
                )
                .toList(),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Caption categories fetch error: $e');
      }
    } finally {
      isLoadingCategories.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logEvent('caption_view');
    fetchCategories();
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    LogEventManager.logEvent('caption_tab_click', {'index': index});
  }

  void generateCaptionsFor(String name, String categoryName) {
    final targetName = name.trim().isEmpty ? 'Alice' : name.trim();
    generatedCaptions.assignAll([
      CaptionItemModel(
        id: '${categoryName}_1',
        text:
            '"Happy Birthday to my sweet $targetName, a shining star in my life\'s sky. Thank you for your boundless patience and soft laughter."',
      ),
      CaptionItemModel(
        id: '${categoryName}_2',
        text:
            '"Wishing the happiest birthday to $targetName! May your day be filled with love, warm hugs, and unforgettable moments."',
      ),
      CaptionItemModel(
        id: '${categoryName}_3',
        text:
            '"Happy Birthday $targetName! Every year with you brings more joy, brighter smiles, and endless gratitude."',
      ),
      CaptionItemModel(
        id: '${categoryName}_4',
        text:
            '"Cheers to you, $targetName! May this new chapter bring you good health, peace, and everything your heart desires."',
      ),
    ]);
  }

  void toggleFavorite(CaptionItemModel item) {
    item.isFavorite = !item.isFavorite;
    if (item.isFavorite) {
      if (!savedCaptions.any((e) => e.id == item.id)) {
        savedCaptions.add(item);
      }
    } else {
      savedCaptions.removeWhere((e) => e.id == item.id);
    }
    generatedCaptions.refresh();
    savedCaptions.refresh();
    LogEventManager.logEvent('caption_favorite_click', {'id': item.id});
  }

  Future<void> copyCaption(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    LogEventManager.logEvent('caption_copy_click');
  }

  Future<void> shareCaption(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
    LogEventManager.logEvent('caption_share_click');
  }

  Future<void> shareToWhatsApp(String text) async {
    LogEventManager.logEvent('caption_whatsapp_click');
    final uri = Uri.parse(
      'whatsapp://send?text=${Uri.encodeComponent(text)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await shareCaption(text);
    }
  }
}
