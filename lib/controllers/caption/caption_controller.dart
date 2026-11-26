import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/caption_models.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';

class CaptionController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxList<CaptionItemModel> generatedCaptions = <CaptionItemModel>[].obs;
  final RxList<CaptionItemModel> savedCaptions = <CaptionItemModel>[].obs;

  final List<CaptionCategoryModel> categories = const [
    CaptionCategoryModel(
      id: 'mom',
      title: 'Mom\nCaption',
      shortName: 'Mom',
      emoji: '💐',
      bgColor: AppColors.toolPinkBg,
    ),
    CaptionCategoryModel(
      id: 'dad',
      title: 'Dad\nCaption',
      shortName: 'Dad',
      emoji: '👨🏻',
      bgColor: AppColors.toolGreenBg,
    ),
    CaptionCategoryModel(
      id: 'wife',
      title: 'Wife\nCaption',
      shortName: 'Wife',
      emoji: '💍',
      bgColor: AppColors.toolBlueBg,
    ),
    CaptionCategoryModel(
      id: 'husband',
      title: 'Husband\nCaption',
      shortName: 'Husband',
      emoji: '🤵🏻',
      bgColor: AppColors.toolPeachBg,
    ),
    CaptionCategoryModel(
      id: 'brother',
      title: 'Brother\nCaption',
      shortName: 'Brother',
      emoji: '🧢',
      bgColor: AppColors.toolPurpleBg,
    ),
    CaptionCategoryModel(
      id: 'sister',
      title: 'Sister\nCaption',
      shortName: 'Sister',
      emoji: '🎀',
      bgColor: AppColors.toolCyanBg,
    ),
    CaptionCategoryModel(
      id: 'son',
      title: 'Son\nCaption',
      shortName: 'Son',
      emoji: '🚀',
      bgColor: AppColors.toolPinkBg,
    ),
    CaptionCategoryModel(
      id: 'daughter',
      title: 'Daughter\nCaption',
      shortName: 'Daughter',
      emoji: '👑',
      bgColor: AppColors.toolGreenBg,
    ),
    CaptionCategoryModel(
      id: 'friend',
      title: 'Friend\nCaption',
      shortName: 'Friend',
      emoji: '💕',
      bgColor: AppColors.toolBlueBg,
    ),
    CaptionCategoryModel(
      id: 'teenager',
      title: 'Teenager\nCaption',
      shortName: 'Teenager',
      emoji: '🎧',
      bgColor: AppColors.toolPeachBg,
    ),
    CaptionCategoryModel(
      id: 'romantic',
      title: 'Romantic\nCaption',
      shortName: 'Romantic',
      emoji: '💝',
      bgColor: AppColors.toolPurpleBg,
    ),
    CaptionCategoryModel(
      id: 'funny',
      title: 'Funny\nCaption',
      shortName: 'Funny',
      emoji: '🎉',
      bgColor: AppColors.toolCyanBg,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    LogEventManager.logEvent('caption_view');
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
