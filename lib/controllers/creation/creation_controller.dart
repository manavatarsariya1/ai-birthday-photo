import 'package:get/get.dart';

import '../../data/models/creation_model.dart';
import '../../services/log_event_manager.dart';
import '../../utils/app_toast.dart';

class CreationController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxList<CreationItemModel> creations = <CreationItemModel>[].obs;
  final RxBool isSelectionMode = false.obs;
  final RxSet<String> selectedIds = <String>{}.obs;

  static const List<String> tabs = ['Photo', 'Video', 'Card'];

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
    creations.removeWhere((c) => c.id == id);
    selectedIds.remove(id);
    if (selectedIds.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  void deleteSelected() {
    LogEventManager.logEvent('creation_delete_multi_click', {
      'count': selectedIds.length,
    });
    creations.removeWhere((c) => selectedIds.contains(c.id));
    clearSelection();
    AppToast.showSuccess('Deleted successfully');
  }
}
