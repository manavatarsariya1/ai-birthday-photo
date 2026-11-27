import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constant/app_assets.dart';
import '../../controllers/creation/creation_controller.dart';
import '../../data/models/creation_model.dart';
import '../../routes/app_routes.dart';
import '../../services/log_event_manager.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../utils/common_button.dart';
import '../../utils/common_text.dart';

class CreationScreen extends StatelessWidget {
  const CreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreationController());
    LogEventManager.logEvent('creation_view');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── AppBar ────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          LogEventManager.logEvent('creation_back_click');
                          Get.back();
                        },
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
                        title: 'Creation',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.blackColor,
                      ),
                    ],
                  ),
                ),

                // ── Segmented Tab (Photo | Video | Card) ──────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9999.r),
                    ),
                    child: Obx(
                      () => Row(
                        children: List.generate(
                          CreationController.tabs.length,
                          (i) {
                            final isActive =
                                controller.selectedTabIndex.value == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => controller.onTabChanged(i),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 9.h),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.whiteColor
                                        : AppColors.transparentColor,
                                    borderRadius: BorderRadius.circular(9999.r),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: AppColors.blackColor
                                                  .withValues(alpha: 0.05),
                                              blurRadius: 6.r,
                                              offset: Offset(0, 2.h),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: CommonText.text(
                                    title: CreationController.tabs[i],
                                    fontSize: 13,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    textColor: isActive
                                        ? AppColors.blackColor
                                        : AppColors.blackColor
                                            .withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // ── Body: Empty State or Grouped Grid ─────────────────
                Expanded(
                  child: Obx(() {
                    final grouped = controller.groupedCreations;
                    if (grouped.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AppAssets.imgNoCreation,
                              width: 170.w,
                              height: 140.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 12.h),
                            CommonText.text(
                              title: 'No Creation Yet',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              textColor:
                                  AppColors.blackColor.withValues(alpha: 0.65),
                            ),
                          ],
                        ),
                      );
                    }

                    final entries = grouped.entries.toList();
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 96.h),
                      physics: const ClampingScrollPhysics(),
                      itemCount: entries.length,
                      itemBuilder: (_, sectionIdx) {
                        final entry = entries[sectionIdx];
                        final items = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.h, top: 6.h),
                              child: CommonText.text(
                                title: entry.key,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                textColor: AppColors.blackColor
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 0.76,
                              ),
                              itemBuilder: (_, i) {
                                final item = items[i];
                                return _CreationTile(
                                  item: item,
                                  controller: controller,
                                  onDeleteTap: () =>
                                      _showDeleteSheet(controller, item),
                                );
                              },
                            ),
                            SizedBox(height: 14.h),
                          ],
                        );
                      },
                    );
                  }),
                ),
              ],
            ),

            // ── Multi-Select Floating Action Buttons ──────────────────
            Obx(() {
              if (!controller.isSelectionMode.value) {
                return const SizedBox.shrink();
              }
              return Positioned(
                left: 0,
                right: 0,
                bottom: 24.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: controller.deleteSelected,
                      child: Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryPink.withValues(alpha: 0.35),
                              blurRadius: 12.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.whiteColor,
                          size: 24.r,
                        ),
                      ),
                    ),
                    SizedBox(width: 18.w),
                    GestureDetector(
                      onTap: controller.clearSelection,
                      child: Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryPink.withValues(alpha: 0.35),
                              blurRadius: 12.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.whiteColor,
                          size: 24.r,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteSheet(
    CreationController controller,
    CreationItemModel item,
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
                      title: 'Delete Photo',
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
              SizedBox(height: 6.h),
              CommonText.text(
                title: 'Are you sure you want to remove\nthis image?',
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                textColor: AppColors.blackColor.withValues(alpha: 0.55),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  width: 140.w,
                  height: 170.h,
                  child: item.path.startsWith('http')
                      ? Image.network(item.path, fit: BoxFit.cover)
                      : File(item.path).existsSync()
                          ? Image.file(File(item.path), fit: BoxFit.cover)
                          : Container(color: AppColors.reminderCardBg),
                ),
              ),
              SizedBox(height: 20.h),
              CommonButton.primary(
                onTap: () {
                  Get.back();
                  controller.deleteSingle(item.id);
                },
                title: 'Delete Photo',
              ),
              SizedBox(height: 10.h),
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
}

class _CreationTile extends StatelessWidget {
  final CreationItemModel item;
  final CreationController controller;
  final VoidCallback onDeleteTap;

  const _CreationTile({
    required this.item,
    required this.controller,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedIds.contains(item.id);
      final inSelectionMode = controller.isSelectionMode.value;

      return GestureDetector(
        onLongPress: () => controller.toggleSelection(item.id),
        onTap: () {
          if (inSelectionMode) {
            controller.toggleSelection(item.id);
          } else {
            Get.toNamed(AppRoutes.creationPreview, arguments: item);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: isSelected
                ? Border.all(color: AppColors.primaryPink, width: 2.5.r)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.path.startsWith('http'))
                  Image.network(item.path, fit: BoxFit.cover)
                else if (File(item.path).existsSync())
                  Image.file(File(item.path), fit: BoxFit.cover)
                else
                  Container(color: AppColors.reminderCardBg),

                if (inSelectionMode)
                  Positioned(
                    top: 8.r,
                    right: 8.r,
                    child: Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected
                            ? null
                            : AppColors.blackColor.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.whiteColor,
                          width: 1.5.r,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 14.r,
                              color: AppColors.whiteColor,
                            )
                          : null,
                    ),
                  )
                else
                  Positioned(
                    left: 8.w,
                    bottom: 8.h,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => AppToast.showInfo('Sharing...'),
                          child: Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: BoxDecoration(
                              color: AppColors.blackColor.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.share_outlined,
                              size: 15.r,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: onDeleteTap,
                          child: Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: BoxDecoration(
                              color: AppColors.blackColor.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 15.r,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
