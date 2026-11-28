import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CaptionCategoryModel {
  final String id;
  final String title;
  final String slug;
  final String icon;
  final bool isPro;
  final Color bgColor;

  const CaptionCategoryModel({
    required this.id,
    required this.title,
    this.slug = '',
    this.icon = '',
    this.isPro = false,
    required this.bgColor,
  });

  String get shortName => title.split(' ').first;

  static const List<Color> _palette = [
    AppColors.toolPinkBg,
    AppColors.toolGreenBg,
    AppColors.toolBlueBg,
    AppColors.toolPeachBg,
    AppColors.toolPurpleBg,
    AppColors.toolCyanBg,
  ];

  factory CaptionCategoryModel.fromJson(Map<String, dynamic> json, int index) {
    return CaptionCategoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      isPro: json['isPro'] == true,
      bgColor: _palette[index % _palette.length],
    );
  }
}

class CaptionItemModel {
  final String id;
  final String text;
  bool isFavorite;

  CaptionItemModel({
    required this.id,
    required this.text,
    this.isFavorite = false,
  });
}
