import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../data/models/creation_model.dart';
import '../../services/log_event_manager.dart';
import '../../utils/pref_service.dart';
import '../../utils/app_toast.dart';

class CreationController extends GetxController {
  static const String _storageKey = 'saved_creations_v1';

  final RxInt selectedTabIndex = 0.obs;
  final RxList<CreationItemModel> creations = <CreationItemModel>[].obs;
  final RxBool isSelectionMode = false.obs;
  final RxSet<String> selectedIds = <String>{}.obs;

  static const List<String> tabs = ['Photo', 'Video', 'Card'];

  @override
  void onInit() {
    super.onInit();
    _loadCreations();
  }

  void _loadCreations() {
    final raw = PrefService.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      final loaded = list
          .map((e) => CreationItemModel.fromJson(e as Map<String, dynamic>))
          .where((item) => item.path.isNotEmpty && File(item.path).existsSync())
          .toList();
      creations.assignAll(loaded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Load creations error: $e');
      }
    }
  }

  static Future<void> _persistList(List<CreationItemModel> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await PrefService.setValue(_storageKey, encoded);
  }

  static Future<CreationItemModel?> saveCreationFromUrl({
    required String url,
    required String type,
    required String id,
  }) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final docsDir = await getApplicationDocumentsDirectory();
      final creationsDir = Directory('${docsDir.path}/creations');
      if (!creationsDir.existsSync()) {
        creationsDir.createSync(recursive: true);
      }

      final ext = type == 'video' ? 'mp4' : 'png';
      final safeId = id.isNotEmpty
          ? id
          : DateTime.now().millisecondsSinceEpoch.toString();
      final filePath =
          '${creationsDir.path}/${safeId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      final item = CreationItemModel(
        id: safeId,
        path: filePath,
        type: type,
        createdAt: DateTime.now(),
      );

      final existingRaw = PrefService.getString(_storageKey);
      final List<CreationItemModel> list = [];
      if (existingRaw != null && existingRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(existingRaw) as List;
          list.addAll(
            decoded.map(
              (e) => CreationItemModel.fromJson(e as Map<String, dynamic>),
            ),
          );
        } catch (_) {}
      }
      list.insert(0, item);
      await _persistList(list);

      if (Get.isRegistered<CreationController>()) {
        Get.find<CreationController>().creations.insert(0, item);
      }
      return item;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Save creation error: $e');
      }
      return null;
    }
  }

  String get currentType {
    switch (selectedTabIndex.value) {
      case 1:
        return 'video';
      case 2:
        return 'card';
      default:
        return 'photo';
    }
  }

  List<CreationItemModel> get filteredCreations =>
      creations.where((c) => c.type == currentType).toList();

  Map<String, List<CreationItemModel>> get groupedCreations {
    final map = <String, List<CreationItemModel>>{};
    for (final item in filteredCreations) {
      map.putIfAbsent(item.sectionLabel, () => []).add(item);
    }
    return map;
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    clearSelection();
  }

  void toggleSelection(String id) {
    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
    }
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
      if (selectedIds.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedIds.add(id);
    }
  }

  void clearSelection() {
    isSelectionMode.value = false;
    selectedIds.clear();
  }

  void deleteSingle(String id) {
    LogEventManager.logEvent('creation_delete_single_click');
    final idx = creations.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      final file = File(creations[idx].path);
      if (file.existsSync()) {
        file.deleteSync();
      }
      creations.removeAt(idx);
      _persistList(creations);
    }
    selectedIds.remove(id);
    if (selectedIds.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  void deleteSelected() {
    LogEventManager.logEvent('creation_delete_multi_click', {
      'count': selectedIds.length,
    });
    for (final item in creations.where((c) => selectedIds.contains(c.id))) {
      final file = File(item.path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    creations.removeWhere((c) => selectedIds.contains(c.id));
    _persistList(creations);
    clearSelection();
    AppToast.showSuccess('Deleted successfully');
  }
}
