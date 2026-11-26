import 'package:flutter/material.dart';

class CelebrationToolModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconPath;
  final Color bgColor;
  final LinearGradient iconGradient;

  const CelebrationToolModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.bgColor,
    required this.iconGradient,
  });
}

class TrendingTemplateModel {
  final String id;
  final String title;
  final String imagePath;

  const TrendingTemplateModel({
    required this.id,
    required this.title,
    required this.imagePath,
  });
}

class UpcomingBirthdayModel {
  final String id;
  final String initials;
  final String title;
  final String subtitle;
  final Color avatarColor;
  final bool isToday;

  const UpcomingBirthdayModel({
    required this.id,
    required this.initials,
    required this.title,
    required this.subtitle,
    required this.avatarColor,
    this.isToday = false,
  });
}
