import 'config_packages.dart';
import '../services/ad_service/ad_label_key.dart';
import '../services/ad_service/dynamic_ad_widget.dart';

class ExitBottomSheet extends StatelessWidget {
  final VoidCallback onExit;
  final VoidCallback onCancel;
  final String adLabel;
  final String? title;
  final String? description;
  final String? primaryButtonText;
  final String? secondaryButtonText;

  const ExitBottomSheet({
    super.key,
    required this.onExit,
    required this.onCancel,
    this.adLabel = ADLabelKey.exitAppBottomSheet,
    this.title,
    this.description,
    this.primaryButtonText,
    this.secondaryButtonText,
  });

  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onExit,
    VoidCallback? onCancel,
    String adLabel = ADLabelKey.exitAppBottomSheet,
    String? title,
    String? description,
    String? primaryButtonText,
    String? secondaryButtonText,
  }) {
    LogEventManager.logExitSheetShow();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2E272D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      builder: (bottomSheetContext) => ExitBottomSheet(
        onExit: onExit ?? () => Navigator.of(bottomSheetContext).pop(true),
        onCancel: onCancel ?? () => Navigator.of(bottomSheetContext).pop(false),
        adLabel: adLabel,
        title: title,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Drag Handle & Close Button ───────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                // Centered Drag Pill
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                // Top Right Close Button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      LogEventManager.logExitSheetCloseClick();
                      onCancel();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.whiteColor.withValues(alpha: 0.8),
                        size: 22.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // ── Main Heading Title ───────────────────────────────────────────
            Center(
              child: CommonText.text(
                title: title ?? AppStrings.leaveAlready,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: appFontFamily,
                color: AppColors.whiteColor,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 6.h),

            // ── Subtitle Description ─────────────────────────────────────────
            Center(
              child: CommonText.text(
                title: description ?? AppStrings.leaveAlreadyDesc,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryTextColor,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Center Illustration ──────────────────────────────────────────
            Center(
              child: Image.asset(
                AppAssets.imgExit,
                height: 170.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    SizedBox(height: 130.h),
              ),
            ),
            SizedBox(height: 12.h),

            // ── Queue Status Pill ────────────────────────────────────────────
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B323B),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.borderColor.withValues(alpha: 0.5),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14.r,
                      color: const Color(0xFFD6C075),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: CommonText.text(
                        title: AppStrings.highResolutionRenderingWaitingInQueue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.whiteColor.withValues(alpha: 0.9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // ── Dynamic Native Ad at Bottom ──────────────────────────────────
            DynamicAdWidget(
              adLabel: adLabel,
            ),
            SizedBox(height: 14.h),

            // ── Action Buttons ───────────────────────────────────────────────
            // 1. Primary Button (Continue / Stay)
            CommonButton.primary(
              onTap: () {
                LogEventManager.logExitSheetCancelClick();
                onCancel();
              },
              title: primaryButtonText ?? AppStrings.continueCreating,
              height: 54.h,
              borderRadius: 27.r,
            ),
            SizedBox(height: 12.h),

            // 2. Secondary Button (Exit / Leave)
            CommonButton(
              onTap: onExit,
              title: secondaryButtonText ?? AppStrings.exit,
              height: 54.h,
              borderRadius: 27.r,
              backgroundColor: const Color(0xFF433943),
              textColor: AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 6.h),
          ],
        ),
      ),
    );
  }
}
