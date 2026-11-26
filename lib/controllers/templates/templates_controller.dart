import 'package:get/get.dart';

import '../../constant/app_strings.dart';
import '../../services/log_event_manager.dart';
import '../../ui/templates/widgets/template_sheets.dart';

class TemplatesController extends GetxController {
  final RxInt selectedTypeIndex = 0.obs;
  final RxInt selectedCategoryIndex = 0.obs;

  List<String> get types => [
    AppStrings.tabPhoto,
    AppStrings.tabVideo,
    AppStrings.tabCard,
  ];

  bool get isVideoMode => selectedTypeIndex.value == 1;

  List<String> get categories => isVideoMode
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

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logEvent('templates_view');
  }

  void onTypeChanged(int index) {
    selectedTypeIndex.value = index;
    selectedCategoryIndex.value = 0;
    LogEventManager.logEvent('templates_type_click', {'type': types[index]});
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
    TemplateSheets.showTipsSheet(isVideo: isVideoMode);
  }
}
