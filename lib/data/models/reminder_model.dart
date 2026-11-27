import 'package:flutter/material.dart';

class ReminderModel {
  final String id;
  final String fullName;
  final String occasion;
  final String relationship;
  final int month;
  final int day;
  final int? birthYear;
  final bool repeatAnnually;
  final List<String> notificationTimings;
  final int reminderHour;
  final int reminderMinute;
  final bool isAm;
  final String? photoPath;
  final Color avatarColor;

  const ReminderModel({
    required this.id,
    required this.fullName,
    required this.occasion,
    required this.relationship,
    required this.month,
    required this.day,
    this.birthYear,
    this.repeatAnnually = true,
    this.notificationTimings = const ['on_day', '1_day'],
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.isAm = true,
    this.photoPath,
    required this.avatarColor,
  });

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'R';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  DateTime get nextOccurrence {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var candidate = DateTime(now.year, month, day);
    if (candidate.isBefore(today)) {
      candidate = DateTime(now.year + 1, month, day);
    }
    return candidate;
  }

  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return nextOccurrence.difference(today).inDays;
  }

  String get section {
    final d = daysUntil;
    if (d <= 7) return 'THIS WEEK';
    if (d <= 30) return 'THIS MONTH';
    return 'LATER';
  }

  String get displayTitle {
    if (occasion == 'Birthday' && birthYear != null) {
      final age = nextOccurrence.year - birthYear!;
      if (age > 0) {
        return "$fullName's ${_ordinal(age)} Birthday";
      }
    }
    return occasion == 'Birthday'
        ? "$fullName's Birthday"
        : '$fullName • $occasion';
  }

  String get displaySubtitle {
    final d = daysUntil;
    if (d == 0) return 'Today';
    if (d == 1) return 'Tomorrow';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr = '${months[month - 1]} $day';
    if (d <= 7) return 'Next Week ($dateStr)';
    return occasion == 'Birthday' ? dateStr : '$dateStr • $occasion';
  }

  static String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }
}
