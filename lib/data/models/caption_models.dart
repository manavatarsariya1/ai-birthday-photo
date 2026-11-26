import 'package:flutter/material.dart';

class CaptionCategoryModel {
  final String id;
  final String title;
  final String shortName;
  final String emoji;
  final Color bgColor;

  const CaptionCategoryModel({
    required this.id,
    required this.title,
    required this.shortName,
    required this.emoji,
    required this.bgColor,
  });
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
