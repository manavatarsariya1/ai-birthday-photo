import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/reminders/reminders_controller.dart';
import '../../data/models/reminder_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

Future<void> showSelectDateSheet(RemindersController controller) async {
  var tempDay = controller.selectedDay.value;
  var tempMonth = controller.selectedMonth.value;

  final dayCtrl = FixedExtentScrollController(initialItem: tempDay - 1);
  final monthCtrl = FixedExtentScrollController(initialItem: tempMonth - 1);

  await Get.bottomSheet(
    _PickerSheetContainer(
      title: 'Select Date',
      onClose: () {
        controller.selectedDay.value = tempDay;
        controller.selectedMonth.value = tempMonth;
        Get.back();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          _SelectionHighlightBar(),
          Row(
            children: [
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: dayCtrl,
                  itemExtent: 44.h,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.003,
                  onSelectedItemChanged: (i) => tempDay = i + 1,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 31,
                    builder: (_, i) => _WheelItem(
                      label: '${i + 1}',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: monthCtrl,
                  itemExtent: 44.h,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.003,
                  onSelectedItemChanged: (i) => tempMonth = i + 1,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 12,
                    builder: (_, i) => _WheelItem(
                      label: RemindersController.shortMonthNames[i],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: AppColors.transparentColor,
  );
  controller.selectedDay.value = tempDay;
  controller.selectedMonth.value = tempMonth;
}

Future<void> showSelectYearSheet(RemindersController controller) async {
  const startYear = 1940;
  final endYear = DateTime.now().year;
  var tempYear = controller.selectedYear.value.clamp(startYear, endYear);

  final yearCtrl =
      FixedExtentScrollController(initialItem: tempYear - startYear);

  await Get.bottomSheet(
    _PickerSheetContainer(
      title: 'Select Year',
      onClose: () {
        controller.selectedYear.value = tempYear;
        Get.back();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          _SelectionHighlightBar(),
          ListWheelScrollView.useDelegate(
            controller: yearCtrl,
            itemExtent: 44.h,
            physics: const FixedExtentScrollPhysics(),
            perspective: 0.003,
            onSelectedItemChanged: (i) => tempYear = startYear + i,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: endYear - startYear + 1,
              builder: (_, i) => _WheelItem(label: '${startYear + i}'),
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: AppColors.transparentColor,
  );
  controller.selectedYear.value = tempYear;
}

Future<void> showReminderTimeSheet(RemindersController controller) async {
  var tempHour = controller.reminderHour.value;
  var tempMinute = controller.reminderMinute.value;
  var tempIsAm = controller.isAm.value;

  final hourCtrl = FixedExtentScrollController(initialItem: tempHour - 1);
  final minCtrl = FixedExtentScrollController(initialItem: tempMinute);
  final periodCtrl = FixedExtentScrollController(initialItem: tempIsAm ? 0 : 1);

  await Get.bottomSheet(
    _PickerSheetContainer(
      title: 'Reminder Time',
      onClose: () {
        controller.reminderHour.value = tempHour;
        controller.reminderMinute.value = tempMinute;
        controller.isAm.value = tempIsAm;
        Get.back();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          _SelectionHighlightBar(),
          Row(
            children: [
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: hourCtrl,
                  itemExtent: 44.h,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.003,
                  onSelectedItemChanged: (i) => tempHour = i + 1,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 12,
                    builder: (_, i) =>
                        _WheelItem(label: (i + 1).toString().padLeft(2, '0')),
                  ),
                ),
              ),
              CommonText.text(
                title: ':',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.blackColor,
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: minCtrl,
                  itemExtent: 44.h,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.003,
                  onSelectedItemChanged: (i) => tempMinute = i,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 60,
                    builder: (_, i) =>
                        _WheelItem(label: i.toString().padLeft(2, '0')),
                  ),
                ),
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: periodCtrl,
                  itemExtent: 44.h,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.003,
                  onSelectedItemChanged: (i) => tempIsAm = i == 0,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 2,
                    builder: (_, i) => _WheelItem(label: i == 0 ? 'AM' : 'PM'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: AppColors.transparentColor,
  );
  controller.reminderHour.value = tempHour;
  controller.reminderMinute.value = tempMinute;
  controller.isAm.value = tempIsAm;
}

class _PickerSheetContainer extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget child;

  const _PickerSheetContainer({
    required this.title,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.blackColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 14.h),
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: CommonText.text(
                  title: title,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.blackColor,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16.r,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(height: 210.h, child: child),
        ],
      ),
    );
  }
}

class _SelectionHighlightBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 44.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryPink.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

class _WheelItem extends StatelessWidget {
  final String label;

  const _WheelItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CommonText.text(
        title: label,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        textColor: AppColors.blackColor,
      ),
    );
  }
}

Future<void> showDeleteReminderSheet(
  RemindersController controller,
  ReminderModel item,
  String formattedDate,
) async {
  await Get.bottomSheet(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.blackColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 14.h),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: CommonText.text(
                    title: 'Delete Reminder',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.blackColor,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.r,
                        color: AppColors.primaryPink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.blackColor.withValues(alpha: 0.6),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'Are you sure you want to remove the\ncelebration reminder for ',
                  ),
                  TextSpan(
                    text: item.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.captionCardBg,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  if (item.photoPath != null && item.photoPath!.isNotEmpty)
                    ClipOval(
                      child: Image.file(
                        File(item.photoPath!),
                        width: 44.r,
                        height: 44.r,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: item.avatarColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: CommonText.text(
                        title: item.initials,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.text(
                          title: item.fullName,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          textColor: AppColors.blackColor,
                        ),
                        SizedBox(height: 2.h),
                        CommonText.text(
                          title: '${item.occasion} • $formattedDate',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.blackColor.withValues(alpha: 0.55),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            CommonButton.primary(
              onTap: () {
                Get.back(); // close sheet
                controller.deleteReminder(item.id);
              },
              title: 'Delete Reminder',
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => Get.back(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                child: CommonText.text(
                  title: 'Cancel',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.blackColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: AppColors.transparentColor,
    barrierColor: AppColors.blackColor.withValues(alpha: 0.25),
  );
}
