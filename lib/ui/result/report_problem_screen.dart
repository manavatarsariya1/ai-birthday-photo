import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController _otherController = TextEditingController();
  int _selectedIndex = 0;
  String? _errorText;

  static const List<String> _issues = [
    'Inappropriate or Sexual Content',
    'Child Safety Concern',
    'Harmful or Offensive Content',
    'Non Consensual Intimate Content',
    'Privacy or Consent Violation',
    'Misleading or Deceptive Content',
    'Copyright or Ownership Violation',
    'Incorrect or Distorted AI Image',
    'Other Issue',
  ];

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LogEventManager.logEvent('report_problem_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(6.r),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20.r,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CommonText.text(
                    title: 'Report Problem',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.blackColor,
                  ),
                ],
              ),
            ),

            // ── Issues List ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 16.h),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: List.generate(_issues.length, (i) {
                    final isSelected = _selectedIndex == i;
                    final isOther = _issues[i] == 'Other Issue';

                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedIndex = i;
                        _errorText = null;
                      }),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.photoPickerBg
                              : AppColors.reminderCardBg,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CommonText.text(
                                    title: _issues[i],
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppColors.blackColor,
                                  ),
                                ),
                                Container(
                                  width: 20.r,
                                  height: 20.r,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? AppColors.primaryGradient
                                        : null,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: AppColors.blackColor
                                                .withValues(alpha: 0.25),
                                            width: 1.5.r,
                                          ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 13.r,
                                          color: AppColors.whiteColor,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                            if (isOther) ...[
                              SizedBox(height: 12.h),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: TextField(
                                  controller: _otherController,
                                  maxLines: 3,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(r'^\s+'),
                                    ),
                                  ],
                                  onTap: () => setState(() {
                                    _selectedIndex = i;
                                    _errorText = null;
                                  }),
                                  onChanged: (_) {
                                    if (_errorText != null) {
                                      setState(() => _errorText = null);
                                    }
                                  },
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.blackColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Describe the issue...',
                                    hintStyle: TextStyle(
                                      fontSize: 12.5.sp,
                                      color: AppColors.blackColor
                                          .withValues(alpha: 0.35),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(12.r),
                                  ),
                                ),
                              ),
                              if (_errorText != null) ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      size: 15.r,
                                      color: const Color(0xFFE53935),
                                    ),
                                    SizedBox(width: 5.w),
                                    CommonText.text(
                                      title: _errorText!,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      textColor: const Color(0xFFE53935),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── Save Report CTA ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
              child: CommonButton.primary(
                onTap: () {
                  if (_issues[_selectedIndex] == 'Other Issue' &&
                      _otherController.text.trim().isEmpty) {
                    setState(() {
                      _errorText = 'Please describe the issue';
                    });
                    return;
                  }
                  LogEventManager.logEvent('report_problem_submit', {
                    'issue': _issues[_selectedIndex],
                  });
                  Get.back();
                  AppToast.showSuccess('Report submitted. Thank you!');
                },
                title: 'Save Report',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
