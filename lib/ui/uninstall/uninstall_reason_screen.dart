import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_constant.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class UninstallReasonScreen extends StatefulWidget {
  const UninstallReasonScreen({super.key});

  @override
  State<UninstallReasonScreen> createState() => _UninstallReasonScreenState();
}

class _UninstallReasonScreenState extends State<UninstallReasonScreen> {
  final TextEditingController _noteController = TextEditingController();
  int _selectedIndex = 0;
  String? _errorText;
  bool _isSubmitting = false;

  static const List<String> _reasons = [
    'Too many ads',
    'App is slow or crashing',
    'Results are not proper',
    'Missing templates or styles',
    'Too expensive / Credits issue',
    'Found another app',
    'Other reason',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LogEventManager.logEvent('uninstall_reason_view');

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
                    title: 'Tell Us Why',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.blackColor,
                  ),
                ],
              ),
            ),

            // ── Reasons List ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 20.h),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.text(
                      title: 'What made you decide to uninstall?',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.blackColor,
                    ),
                    SizedBox(height: 4.h),
                    CommonText.text(
                      title: 'Your feedback helps us improve the experience',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.blackColor.withValues(alpha: 0.55),
                    ),
                    SizedBox(height: 16.h),
                    ...List.generate(_reasons.length, (i) {
                      final isSelected = _selectedIndex == i;
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
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryPink
                                  : AppColors.transparentColor,
                              width: 1.2.r,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonText.text(
                                  title: _reasons[i],
                                  fontSize: 13.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
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
                                  color: isSelected
                                      ? null
                                      : AppColors.blackColor.withValues(
                                          alpha: 0.1,
                                        ),
                                  shape: BoxShape.circle,
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
                        ),
                      );
                    }),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.reminderCardBg,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 3,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'^\s+')),
                        ],
                        onChanged: (_) {
                          if (_errorText != null) {
                            setState(() => _errorText = null);
                          }
                        },
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: AppColors.blackColor,
                        ),
                        decoration: InputDecoration(
                          hintText: _reasons[_selectedIndex] == 'Other reason'
                              ? 'Please tell us your reason (Required)...'
                              : 'Additional feedback (Optional)...',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.blackColor.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14.r),
                        ),
                      ),
                    ),
                    if (_errorText != null) ...[
                      SizedBox(height: 6.h),
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
                ),
              ),
            ),

            // ── Bottom Actions ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
              child: Column(
                children: [
                  CommonButton.primary(
                    onTap: _submitUninstallReason,
                    title: 'Submit & Uninstall',
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutes.home),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 16.w,
                      ),
                      child: CommonText.text(
                        title: 'Back to Home',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.blackColor.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitUninstallReason() async {
    if (_isSubmitting) return;
    final note = _noteController.text.trim();
    final selected = _reasons[_selectedIndex];

    if (selected == 'Other reason' && note.isEmpty) {
      setState(() {
        _errorText = 'Please enter your reason';
      });
      return;
    }

    final reasonText = selected == 'Other reason'
        ? note
        : (note.isNotEmpty ? '$selected - $note' : selected);

    _isSubmitting = true;
    LogEventManager.logEvent('uninstall_reason_submit', {'reason': reasonText});

    try {
      await ApiService.post(
        url: '${baseUrl}uninstall/track',
        requiresAuth: true,
        body: {'uninstallReason': reasonText},
      );
    } catch (_) {}

    _isSubmitting = false;
    Get.offNamed(AppRoutes.uninstallThankYou);
  }
}
