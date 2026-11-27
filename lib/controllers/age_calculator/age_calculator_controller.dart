import 'dart:async';

import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';

class AgeCalculatorController extends GetxController {
  DateTime currentDate = DateTime.now();
  final Rx<DateTime> dob = DateTime(2000, 8, 12).obs;

  // Calculated result values
  final RxInt years = 0.obs;
  final RxInt months = 0.obs;
  final RxInt days = 0.obs;
  final RxString nextBirthdayFormatted = ''.obs;
  final RxString nextBirthdayWeekday = ''.obs;
  final RxInt totalYears = 0.obs;
  final RxInt totalMonths = 0.obs;
  final RxInt totalWeeks = 0.obs;
  final RxInt totalDays = 0.obs;
  final RxInt totalHours = 0.obs;
  final RxInt totalMinutes = 0.obs;
  final RxInt totalSeconds = 0.obs;
  Timer? _liveTimer;

  static const List<String> shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String formatDate(DateTime d, {bool withComma = true}) {
    final mon = shortMonths[d.month - 1];
    return withComma ? '${d.day} $mon, ${d.year}' : '${d.day} $mon ${d.year}';
  }

  void updateDob(int day, int month, int year) {
    final maxDay = DateTime(year, month + 1, 0).day;
    final clampedDay = day.clamp(1, maxDay);
    dob.value = DateTime(year, month, clampedDay);
  }

  void calculateAge() {
    LogEventManager.logEvent('age_calculator_calculate_click');
    currentDate = DateTime.now();
    final birth = dob.value;
    final now = DateTime(currentDate.year, currentDate.month, currentDate.day);

    int y = now.year - birth.year;
    int m = now.month - birth.month;
    int d = now.day - birth.day;

    if (d < 0) {
      m -= 1;
      final prevMonthDays = DateTime(now.year, now.month, 0).day;
      d += prevMonthDays;
    }
    if (m < 0) {
      y -= 1;
      m += 12;
    }

    years.value = y.clamp(0, 200);
    months.value = m.clamp(0, 11);
    days.value = d.clamp(0, 31);

    // Next birthday
    var nextBday = DateTime(now.year, birth.month, birth.day);
    if (!nextBday.isAfter(now)) {
      nextBday = DateTime(now.year + 1, birth.month, birth.day);
    }
    nextBirthdayFormatted.value = formatDate(nextBday, withComma: false);
    nextBirthdayWeekday.value = weekdays[nextBday.weekday - 1];

    // Total lived
    _updateLivedTotals();
    startLiveTicker();

    Get.toNamed(AppRoutes.ageResult);
  }

  void _updateLivedTotals() {
    currentDate = DateTime.now();
    final diff = currentDate.difference(dob.value);
    final tDays = diff.inDays.clamp(0, 999999);
    totalYears.value = years.value;
    totalMonths.value = years.value * 12 + months.value;
    totalWeeks.value = tDays ~/ 7;
    totalDays.value = tDays;
    totalHours.value = diff.inHours.clamp(0, 999999999);
    totalMinutes.value = diff.inMinutes.clamp(0, 999999999);
    totalSeconds.value = diff.inSeconds.clamp(0, 999999999);
  }

  void startLiveTicker() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateLivedTotals();
    });
  }

  void stopLiveTicker() {
    _liveTimer?.cancel();
    _liveTimer = null;
  }

  @override
  void onClose() {
    stopLiveTicker();
    super.onClose();
  }
}
