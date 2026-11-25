import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'ad_service/ad_label_key.dart';
import 'ad_service/ad_managers/revenue_threshold_manager.dart';

class LogEventManager {
  LogEventManager._();

  static FirebaseAnalytics? _analyticsInstance;
  static FirebaseAnalytics get _analytics =>
      _analyticsInstance ??= FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ---------------------------------------------------------------------------
  // Core Logger
  // ---------------------------------------------------------------------------
  static void logEvent(String name, [Map<String, dynamic>? parameters]) {
    _logEvent(name, parameters);
  }

  static void _logEvent(String name, [Map<String, dynamic>? parameters]) {
    try {
      if (Firebase.apps.isEmpty) {
        if (kDebugMode) {
          log("Cannot log event $name: Firebase not yet initialized.",
              name: "LOGEVENTMANAGER");
        }
        return;
      }

      Map<String, Object>? sanitizedParams;
      if (parameters != null) {
        sanitizedParams = {};
        parameters.forEach((key, value) {
          if (value is String) {
            // Firebase drops string parameter values longer than 100 chars.
            sanitizedParams![key] =
                value.length > 100 ? value.substring(0, 100) : value;
          } else if (value is num) {
            sanitizedParams![key] = value;
          } else if (value is bool) {
            sanitizedParams![key] = value ? 1 : 0;
          } else if (value != null) {
            sanitizedParams![key] = value.toString();
          }
        });
      }

      _analytics.logEvent(
        name: name,
        parameters: sanitizedParams,
      );
      if (kDebugMode) {
        log(
          "🔥 EVENT FIRED: $name ${parameters != null ? 'params: $parameters' : ''}",
          name: "LOGEVENTMANAGER",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log("Error logging event $name: $e", name: "LOGEVENTMANAGER");
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Event Constants & Helpers
  // ---------------------------------------------------------------------------

  // Splash Screen & App Update & ATT
  static const String splashView = "splash_view";
  static const String splashBackClick = "splash_back_click";
  static const String deviceInfo = "device_info";
  static const String forceUpdateDialogView = "force_update_dialog_view";
  static const String softUpdateDialogView = "soft_update_dialog_view";
  static const String appUpdateClick = "app_update_click";
  static const String appUpdateSkipClick = "app_update_skip_click";
  static const String attPermissionResult = "att_permission_result";

  static void logSplashView() => _logEvent(splashView);
  static void logSplashBackClick() => _logEvent(splashBackClick);
  static void logDeviceInfo({
    required int cpuCores,
    required int ramTotalMb,
    required int ramAvailMb,
    required int storageTotalGb,
    required int isEmulator,
    required int refreshRate,
    required int powerSave,
    required String network,
    required String networkType,
  }) =>
      _logEvent(deviceInfo, {
        "cpu_cores": cpuCores,
        "ram_total_mb": ramTotalMb,
        "ram_avail_mb": ramAvailMb,
        "storage_total_gb": storageTotalGb,
        "is_emulator": isEmulator,
        "refresh_rate": refreshRate,
        "power_save": powerSave,
        "network": network,
        "network_type": networkType,
      });
  static void logAttPermissionResult({required String status}) =>
      _logEvent(attPermissionResult, {"status": status});
  static void logForceUpdateDialogView({required String currentVersion, required String minVersion}) =>
      _logEvent(forceUpdateDialogView, {
        "current_version": currentVersion,
        "min_version": minVersion,
      });
  static void logSoftUpdateDialogView({required String currentVersion, required String latestVersion}) =>
      _logEvent(softUpdateDialogView, {
        "current_version": currentVersion,
        "latest_version": latestVersion,
      });
  static void logAppUpdateClick({required String updateType, required String targetVersion}) =>
      _logEvent(appUpdateClick, {
        "update_type": updateType,
        "target_version": targetVersion,
      });
  static void logAppUpdateSkipClick({required String currentVersion, required String latestVersion}) =>
      _logEvent(appUpdateSkipClick, {
        "current_version": currentVersion,
        "latest_version": latestVersion,
      });

  // Language Screen (First Time vs Settings)
  static const String firstTimeLanguageView = "first_time_language_view";
  static const String firstTimeLanguageSelectClick =
      "first_time_language_select_click";
  static const String firstTimeLanguageContinueClick =
      "first_time_language_continue_click";
  static const String firstTimeLanguageBackClick =
      "first_time_language_back_click";

  static const String settingsLanguageView = "settings_language_view";
  static const String settingsLanguageSelectClick =
      "settings_language_select_click";
  static const String settingsLanguageSaveClick =
      "settings_language_save_click";
  static const String settingsLanguageBackClick =
      "settings_language_back_click";

  // Backward-compatible generic aliases
  static const String languageView = "language_view";
  static const String languageSelectClick = "language_select_click";
  static const String languageSaveClick = "language_save_click";
  static const String languageContinueClick = "language_continue_click";
  static const String languageBackClick = "language_back_click";

  static void logFirstTimeLanguageView() => _logEvent(firstTimeLanguageView);
  static void logFirstTimeLanguageSelectClick({required String languageId}) =>
      _logEvent(firstTimeLanguageSelectClick, {"language_id": languageId});
  static void logFirstTimeLanguageContinueClick({required String languageId}) =>
      _logEvent(firstTimeLanguageContinueClick, {"language_id": languageId});
  static void logFirstTimeLanguageBackClick() =>
      _logEvent(firstTimeLanguageBackClick);

  static void logSettingsLanguageView() => _logEvent(settingsLanguageView);
  static void logSettingsLanguageSelectClick({required String languageId}) =>
      _logEvent(settingsLanguageSelectClick, {"language_id": languageId});
  static void logSettingsLanguageSaveClick({required String languageId}) =>
      _logEvent(settingsLanguageSaveClick, {"language_id": languageId});
  static void logSettingsLanguageBackClick() =>
      _logEvent(settingsLanguageBackClick);

  static void logLanguageView({bool isFirstTime = false}) {
    if (isFirstTime) {
      logFirstTimeLanguageView();
    } else {
      logSettingsLanguageView();
    }
  }

  static void logLanguageSelectClick({required String languageId}) =>
      _logEvent(languageSelectClick, {"language_id": languageId});
  static void logLanguageSaveClick({required String languageId}) =>
      _logEvent(languageSaveClick, {"language_id": languageId});
  static void logLanguageContinueClick({required String languageId}) =>
      _logEvent(languageContinueClick, {"language_id": languageId});
  static void logLanguageBackClick() => _logEvent(languageBackClick);

  // Onboarding Screen (Individual Per-Page Events)
  static const String onboarding1View = "onboarding1_view";
  static const String onboarding1ContinueClick = "onboarding1_continue_click";
  static const String onboarding1SkipClick = "onboarding1_skip_click";
  static const String onboarding1BackClick = "onboarding1_back_click";

  static const String onboarding2View = "onboarding2_view";
  static const String onboarding2ContinueClick = "onboarding2_continue_click";
  static const String onboarding2SkipClick = "onboarding2_skip_click";
  static const String onboarding2BackClick = "onboarding2_back_click";

  static const String onboarding3View = "onboarding3_view";
  static const String onboarding3ContinueClick = "onboarding3_continue_click";
  static const String onboarding3SkipClick = "onboarding3_skip_click";
  static const String onboarding3BackClick = "onboarding3_back_click";

  static const String onboarding4View = "onboarding4_view";
  static const String onboarding4ContinueClick = "onboarding4_continue_click";
  static const String onboarding4SkipClick = "onboarding4_skip_click";
  static const String onboarding4BackClick = "onboarding4_back_click";
  static const String onboarding4TargetSelectClick =
      "onboarding4_target_select_click";

  static const String onboardingAgeSheetView = "onboarding_age_sheet_view";
  static const String onboardingAgeSelectClick = "onboarding_age_select_click";
  static const String onboardingAgeDoneClick = "onboarding_age_done_click";
  static const String onboardingAgeSheetCloseClick =
      "onboarding_age_sheet_close_click";

  // Per-page log methods
  static void logOnboarding1View() => _logEvent(onboarding1View);
  static void logOnboarding1ContinueClick() =>
      _logEvent(onboarding1ContinueClick);
  static void logOnboarding1SkipClick() => _logEvent(onboarding1SkipClick);
  static void logOnboarding1BackClick() => _logEvent(onboarding1BackClick);

  static void logOnboarding2View() => _logEvent(onboarding2View);
  static void logOnboarding2ContinueClick() =>
      _logEvent(onboarding2ContinueClick);
  static void logOnboarding2SkipClick() => _logEvent(onboarding2SkipClick);
  static void logOnboarding2BackClick() => _logEvent(onboarding2BackClick);

  static void logOnboarding3View() => _logEvent(onboarding3View);
  static void logOnboarding3ContinueClick() =>
      _logEvent(onboarding3ContinueClick);
  static void logOnboarding3SkipClick() => _logEvent(onboarding3SkipClick);
  static void logOnboarding3BackClick() => _logEvent(onboarding3BackClick);

  static void logOnboarding4View() => _logEvent(onboarding4View);
  static void logOnboarding4ContinueClick() =>
      _logEvent(onboarding4ContinueClick);
  static void logOnboarding4SkipClick() => _logEvent(onboarding4SkipClick);
  static void logOnboarding4BackClick() => _logEvent(onboarding4BackClick);
  static void logOnboarding4TargetSelectClick({required String target}) =>
      _logEvent(onboarding4TargetSelectClick, {"target": target});

  static void logOnboardingPageView(int pageIndex) {
    switch (pageIndex) {
      case 0:
        logOnboarding1View();
        break;
      case 1:
        logOnboarding2View();
        break;
      case 2:
        logOnboarding3View();
        break;
      case 3:
      default:
        logOnboarding4View();
        break;
    }
  }

  static void logOnboardingPageContinueClick(int pageIndex) {
    switch (pageIndex) {
      case 0:
        logOnboarding1ContinueClick();
        break;
      case 1:
        logOnboarding2ContinueClick();
        break;
      case 2:
        logOnboarding3ContinueClick();
        break;
      case 3:
      default:
        logOnboarding4ContinueClick();
        break;
    }
  }

  static void logOnboardingPageSkipClick(int pageIndex) {
    switch (pageIndex) {
      case 0:
        logOnboarding1SkipClick();
        break;
      case 1:
        logOnboarding2SkipClick();
        break;
      case 2:
        logOnboarding3SkipClick();
        break;
      case 3:
      default:
        logOnboarding4SkipClick();
        break;
    }
  }

  static void logOnboardingPageBackClick(int pageIndex) {
    switch (pageIndex) {
      case 0:
        logOnboarding1BackClick();
        break;
      case 1:
        logOnboarding2BackClick();
        break;
      case 2:
        logOnboarding3BackClick();
        break;
      case 3:
      default:
        logOnboarding4BackClick();
        break;
    }
  }

  static void logOnboardingAgeSheetView() => _logEvent(onboardingAgeSheetView);
  static void logOnboardingAgeSelectClick({required String age}) =>
      _logEvent(onboardingAgeSelectClick, {"age": age});
  static void logOnboardingAgeDoneClick({required String selectedAge}) =>
      _logEvent(onboardingAgeDoneClick, {"selected_age": selectedAge});
  static void logOnboardingAgeSheetCloseClick() =>
      _logEvent(onboardingAgeSheetCloseClick);

  // Home Screen & Tabs
  static const String homeView = "home_view";
  static const String homeTabChange = "home_tab_change";
  static const String homeCoinClick = "home_coin_click";
  static const String homePremiumClick = "home_premium_click";
  static const String homeFilterClick = "home_filter_click";
  static const String homeFilterTargetSelectClick =
      "home_filter_target_select_click";
  static const String homeFilterApplyClick = "home_filter_apply_click";
  static const String homeFilterSheetCloseClick = "home_filter_sheet_close_click";
  static const String homeBannerClick = "home_banner_click";
  static const String homeViewAllClick = "home_view_all_click";
  static const String homeStudioItemClick = "home_studio_item_click";
  static const String homeTemplateItemClick = homeStudioItemClick;
  static const String studioView = "studio_view";
  static const String templatesView = studioView;
  static const String studioCategoryClick = "studio_category_click";
  static const String templatesCategoryClick = studioCategoryClick;
  static const String studioItemClick = "studio_item_click";
  static const String templateItemClick = studioItemClick;
  static const String creationView = "creation_view";
  static const String settingsView = "settings_view";
  static const String settingsUpgradeClick = "settings_upgrade_click";
  static const String settingsMyCreationClick = "settings_my_creation_click";
  static const String settingsLanguageOptionClick = "settings_language_click";
  static const String settingsRestorePurchaseClick = "settings_restore_purchase_click";
  static const String settingsRestorePurchaseSuccess = "settings_restore_purchase_success";
  static const String settingsRestorePurchaseFailed = "settings_restore_purchase_failed";
  static const String settingsFeedbackClick = "settings_feedback_click";
  static const String settingsShareAppClick = "settings_share_app_click";
  static const String settingsRateUsClick = "settings_rate_us_click";
  static const String settingsPrivacyPolicyClick = "settings_privacy_policy_click";
  static const String settingsTermsConditionsClick = "settings_terms_conditions_click";

  static void logHomeView() => _logEvent(homeView);
  static void logHomeTabChange({required int tabIndex, required String tabName}) =>
      _logEvent(homeTabChange, {"tab_index": tabIndex, "tab_name": tabName});
  static void logHomeCoinClick() => _logEvent(homeCoinClick);
  static void logHomePremiumClick() => _logEvent(homePremiumClick);
  static void logHomeFilterClick() => _logEvent(homeFilterClick);
  static void logHomeFilterTargetSelectClick({required String target}) =>
      _logEvent(homeFilterTargetSelectClick, {"target": target});
  static void logHomeFilterApplyClick({required String target, String? age}) =>
      _logEvent(homeFilterApplyClick, {
        "target": target,
        if (age != null) "age": age,
      });
  static void logHomeFilterSheetCloseClick() =>
      _logEvent(homeFilterSheetCloseClick);
  static void logHomeBannerClick({required int bannerIndex}) =>
      _logEvent(homeBannerClick, {"banner_index": bannerIndex});
  static void logHomeViewAllClick({required String categoryTitle}) =>
      _logEvent(homeViewAllClick, {"category_title": categoryTitle});
  static void logHomeStudioItemClick({
    required String itemId,
    required String itemTitle,
  }) =>
      _logEvent(homeStudioItemClick, {
        "item_id": itemId,
        "item_title": itemTitle,
      });
  static void logHomeTemplateItemClick({
    required String templateId,
    required String templateTitle,
  }) =>
      logHomeStudioItemClick(itemId: templateId, itemTitle: templateTitle);

  static void logStudioView() => _logEvent(studioView);
  static void logTemplatesView() => logStudioView();

  static void logStudioCategoryClick({
    required String categoryId,
    required String categoryTitle,
  }) =>
      _logEvent(studioCategoryClick, {
        "category_id": categoryId,
        "category_title": categoryTitle,
      });
  static void logTemplatesCategoryClick({
    required String categoryId,
    required String categoryTitle,
  }) =>
      logStudioCategoryClick(
        categoryId: categoryId,
        categoryTitle: categoryTitle,
      );

  static void logStudioItemClick({
    required String itemId,
    required String itemTitle,
  }) =>
      _logEvent(studioItemClick, {
        "item_id": itemId,
        "item_title": itemTitle,
      });
  static void logTemplateItemClick({
    required String templateId,
    required String templateTitle,
  }) =>
      logStudioItemClick(itemId: templateId, itemTitle: templateTitle);
  static void logCreationView() => _logEvent(creationView);
  static void logSettingsView() => _logEvent(settingsView);
  static void logSettingsUpgradeClick() => _logEvent(settingsUpgradeClick);
  static void logSettingsMyCreationClick() => _logEvent(settingsMyCreationClick);
  static void logSettingsLanguageOptionClick() => _logEvent(settingsLanguageOptionClick);
  static void logSettingsLanguageClick() => _logEvent(settingsLanguageOptionClick);
  static void logSettingsRestorePurchaseClick() => _logEvent(settingsRestorePurchaseClick);
  static void logSettingsRestorePurchaseSuccess() => _logEvent(settingsRestorePurchaseSuccess);
  static void logSettingsRestorePurchaseFailed({required String error}) =>
      _logEvent(settingsRestorePurchaseFailed, {"error": error});
  static void logSettingsFeedbackClick() => _logEvent(settingsFeedbackClick);
  static void logSettingsShareAppClick() => _logEvent(settingsShareAppClick);
  static void logSettingsRateUsClick() => _logEvent(settingsRateUsClick);
  static void logSettingsPrivacyPolicyClick() => _logEvent(settingsPrivacyPolicyClick);
  static void logSettingsTermsConditionsClick() => _logEvent(settingsTermsConditionsClick);

  // Photoshoot Detail Screen
  static const String photoshootDetailView = "photoshoot_detail_view";
  static const String photoshootDetailBackClick = "photoshoot_detail_back_click";
  static const String photoshootDetailPhotoClick = "photoshoot_detail_photo_click";

  static void logPhotoshootDetailView({required String title}) =>
      _logEvent(photoshootDetailView, {"title": title});
  static void logPhotoshootDetailBackClick({required String title}) =>
      _logEvent(photoshootDetailBackClick, {"title": title});
  static void logPhotoshootDetailPhotoClick({
    required String photoId,
    required String photoImage,
  }) =>
      _logEvent(photoshootDetailPhotoClick, {
        "photo_id": photoId,
        "photo_image": photoImage,
      });

  // Feedback Screen
  static const String feedbackView = "feedback_view";
  static const String feedbackBackClick = "feedback_back_click";
  static const String feedbackAddPhotoClick = "feedback_add_photo_click";
  static const String feedbackRemovePhotoClick = "feedback_remove_photo_click";
  static const String feedbackFormSubmit = "feedback_form_submit";
  static const String feedbackRatingSelect = "feedback_rating_select";
  static const String feedbackOptionSelect = "feedback_option_select";
  static const String feedbackSubmitClick = "feedback_submit_click";

  static void logFeedbackView() => _logEvent(feedbackView);
  static void logFeedbackBackClick() => _logEvent(feedbackBackClick);
  static void logFeedbackAddPhotoClick() => _logEvent(feedbackAddPhotoClick);
  static void logFeedbackRemovePhotoClick({required int index}) =>
      _logEvent(feedbackRemovePhotoClick, {"index": index});
  static void logFeedbackFormSubmit({
    required String title,
    required int attachmentCount,
  }) =>
      _logEvent(feedbackFormSubmit, {
        "title": title,
        "attachment_count": attachmentCount,
      });
  static void logFeedbackRatingSelect({required String rating}) =>
      _logEvent(feedbackRatingSelect, {"rating": rating});
  static void logFeedbackOptionSelect({required String option}) =>
      _logEvent(feedbackOptionSelect, {"option": option});
  static void logFeedbackSubmitClick({
    required String rating,
    required String option,
    required String comments,
  }) =>
      _logEvent(feedbackSubmitClick, {
        "rating": rating,
        "option": option,
        "comments": comments,
      });

  // Rate Us Bottom Sheet (Settings & Result Screen Separate Events)
  static const String rateUsBottomSheetShow = "rate_us_bottom_sheet_show";
  static const String rateUsStarSelect = "rate_us_star_select";
  static const String rateUsSubmitClick = "rate_us_submit_click";
  static const String rateUsFeedbackClick = "rate_us_feedback_click";
  static const String rateUsCloseClick = "rate_us_close_click";

  // Settings Rate Us Events
  static const String settingsRateUsSheetShow = "settings_rate_us_sheet_show";
  static const String settingsRateUsCloseClick = "settings_rate_us_close_click";
  static const String settingsRateUsStarSelect = "settings_rate_us_star_select";
  static const String settingsRateUsSubmitClick = "settings_rate_us_submit_click";
  static const String settingsRateUsFeedbackClick = "settings_rate_us_feedback_click";

  // Result Like Rate Us Events
  static const String resultRateUsSheetShow = "result_rate_us_sheet_show";
  static const String resultRateUsCloseClick = "result_rate_us_close_click";
  static const String resultRateUsStarSelect = "result_rate_us_star_select";
  static const String resultRateUsSubmitClick = "result_rate_us_submit_click";
  static const String resultRateUsFeedbackClick = "result_rate_us_feedback_click";

  static void logRateUsBottomSheetShow() => _logEvent(rateUsBottomSheetShow);
  static void logRateUsCloseClick() => _logEvent(rateUsCloseClick);
  static void logRateUsStarSelect({required int starCount}) =>
      _logEvent(rateUsStarSelect, {"star_count": starCount});
  static void logRateUsSubmitClick({required int starCount}) =>
      _logEvent(rateUsSubmitClick, {"star_count": starCount});
  static void logRateUsFeedbackClick({required int starCount}) =>
      _logEvent(rateUsFeedbackClick, {"star_count": starCount});

  static void logSettingsRateUsSheetShow() => _logEvent(settingsRateUsSheetShow);
  static void logSettingsRateUsCloseClick() => _logEvent(settingsRateUsCloseClick);
  static void logSettingsRateUsStarSelect({required int starCount}) =>
      _logEvent(settingsRateUsStarSelect, {"star_count": starCount});
  static void logSettingsRateUsSubmitClick({required int starCount}) =>
      _logEvent(settingsRateUsSubmitClick, {"star_count": starCount});
  static void logSettingsRateUsFeedbackClick({required int starCount}) =>
      _logEvent(settingsRateUsFeedbackClick, {"star_count": starCount});

  static void logResultRateUsSheetShow() => _logEvent(resultRateUsSheetShow);
  static void logResultRateUsCloseClick() => _logEvent(resultRateUsCloseClick);
  static void logResultRateUsStarSelect({required int starCount}) =>
      _logEvent(resultRateUsStarSelect, {"star_count": starCount});
  static void logResultRateUsSubmitClick({required int starCount}) =>
      _logEvent(resultRateUsSubmitClick, {"star_count": starCount});
  static void logResultRateUsFeedbackClick({required int starCount}) =>
      _logEvent(resultRateUsFeedbackClick, {"star_count": starCount});

  // Creation Tab
  static const String creationSelectToggle = "creation_select_toggle";
  static const String creationItemSelect = "creation_item_select";
  static const String creationItemClick = "creation_item_click";
  static const String creationItemShareClick = "creation_item_share_click";
  static const String creationItemDeleteClick = "creation_item_delete_click";
  static const String creationBatchDeleteClick = "creation_batch_delete_click";
  static const String creationSelectCloseClick = "creation_select_close_click";

  static void logCreationSelectToggle({required bool isSelecting}) =>
      _logEvent(creationSelectToggle, {"is_selecting": isSelecting});
  static void logCreationItemSelect({
    required String itemId,
    required bool isSelected,
  }) =>
      _logEvent(creationItemSelect, {
        "item_id": itemId,
        "is_selected": isSelected,
      });
  static void logCreationItemClick({required String itemId}) =>
      _logEvent(creationItemClick, {"item_id": itemId});
  static void logCreationItemShareClick({required String itemId}) =>
      _logEvent(creationItemShareClick, {"item_id": itemId});
  static void logCreationItemDeleteClick({required String itemId}) =>
      _logEvent(creationItemDeleteClick, {"item_id": itemId});
  static void logCreationBatchDeleteClick({required int count}) =>
      _logEvent(creationBatchDeleteClick, {"count": count});
  static void logCreationSelectCloseClick() =>
      _logEvent(creationSelectCloseClick);

  // Delete Confirmation Bottom Sheet
  static const String deleteConfirmationShow = "delete_confirmation_show";
  static const String deleteConfirmationConfirmClick =
      "delete_confirmation_confirm_click";
  static const String deleteConfirmationDiscardClick =
      "delete_confirmation_discard_click";
  static const String deleteConfirmationCloseClick =
      "delete_confirmation_close_click";

  static void logDeleteConfirmationShow({required int count}) =>
      _logEvent(deleteConfirmationShow, {"count": count});
  static void logDeleteConfirmationConfirmClick({required int count}) =>
      _logEvent(deleteConfirmationConfirmClick, {"count": count});
  static void logDeleteConfirmationDiscardClick() =>
      _logEvent(deleteConfirmationDiscardClick);
  static void logDeleteConfirmationCloseClick() =>
      _logEvent(deleteConfirmationCloseClick);

  // Preview / Download Screen
  static const String previewView = "preview_view";
  static const String previewBackClick = "preview_back_click";
  static const String previewHomeClick = "preview_home_click";
  static const String previewDeleteClick = "preview_delete_click";
  static const String previewRemoveWatermarkClick =
      "preview_remove_watermark_click";
  static const String previewInstagramClick = "preview_instagram_click";
  static const String previewFacebookClick = "preview_facebook_click";
  static const String previewWhatsappClick = "preview_whatsapp_click";
  static const String previewShareClick = "preview_share_click";

  static void logPreviewView({required String imagePath}) =>
      _logEvent(previewView, {"image_path": imagePath});
  static void logPreviewBackClick() => _logEvent(previewBackClick);
  static void logPreviewHomeClick() => _logEvent(previewHomeClick);
  static void logPreviewDeleteClick() => _logEvent(previewDeleteClick);
  static void logPreviewRemoveWatermarkClick() =>
      _logEvent(previewRemoveWatermarkClick);
  static void logPreviewInstagramClick() => _logEvent(previewInstagramClick);
  static void logPreviewFacebookClick() => _logEvent(previewFacebookClick);
  static void logPreviewWhatsappClick() => _logEvent(previewWhatsappClick);
  static void logPreviewShareClick() => _logEvent(previewShareClick);

  // Result Screen Events
  static const String resultView = "result_view";
  static const String resultBackClick = "result_back_click";
  static const String resultRegenerateClick = "result_regenerate_click";
  static const String resultSaveClick = "result_save_click";
  static const String resultShareClick = "result_share_click";
  static const String resultLikeClick = "result_like_click";
  static const String resultDislikeClick = "result_dislike_click";
  static const String resultRemoveWatermarkClick = "result_remove_watermark_click";
  static const String resultMoreToolClick = "result_more_tool_click";
  static const String resultDeleteClick = "result_delete_click";
  static const String resultImageClick = "result_image_click";
  static const String resultReportClick = "result_report_click";
  static const String reportSheetShow = "report_sheet_show";
  static const String reportSheetCloseClick = "report_sheet_close_click";
  static const String reportSubmitClick = "report_submit_click";
  static const String reportSuccess = "report_success";
  static const String reportFailed = "report_failed";

  static void logResultView({required String imagePath}) =>
      _logEvent(resultView, {"image_path": imagePath});
  static void logResultBackClick() => _logEvent(resultBackClick);
  static void logResultRegenerateClick() => _logEvent(resultRegenerateClick);
  static void logResultSaveClick() => _logEvent(resultSaveClick);
  static void logResultShareClick() => _logEvent(resultShareClick);
  static void logResultLikeClick() => _logEvent(resultLikeClick);
  static void logResultDislikeClick() => _logEvent(resultDislikeClick);
  static void logResultRemoveWatermarkClick() =>
      _logEvent(resultRemoveWatermarkClick);
  static void logResultMoreToolClick({required String toolTitle}) =>
      _logEvent(resultMoreToolClick, {"tool_title": toolTitle});
  static void logResultDeleteClick() => _logEvent(resultDeleteClick);
  static void logResultImageClick() => _logEvent(resultImageClick);
  static void logResultReportClick() => _logEvent(resultReportClick);
  static void logReportSheetShow() => _logEvent(reportSheetShow);
  static void logReportSheetCloseClick() => _logEvent(reportSheetCloseClick);
  static void logReportSubmitClick({required String reason}) =>
      _logEvent(reportSubmitClick, {"reason": reason});
  static void logReportSuccess() => _logEvent(reportSuccess);
  static void logReportFailed(String error) =>
      _logEvent(reportFailed, {"error": error});

  // Result Save Dialog
  static const String resultSaveDialogShow = "result_save_dialog_show";
  static const String resultSaveDialogSaveClick =
      "result_save_dialog_save_click";
  static const String resultSaveDialogDontSaveClick =
      "result_save_dialog_dont_save_click";
  static const String resultSaveDialogCloseClick =
      "result_save_dialog_close_click";

  static void logResultSaveDialogShow() => _logEvent(resultSaveDialogShow);
  static void logResultSaveDialogSaveClick() =>
      _logEvent(resultSaveDialogSaveClick);
  static void logResultSaveDialogDontSaveClick() =>
      _logEvent(resultSaveDialogDontSaveClick);
  static void logResultSaveDialogCloseClick() =>
      _logEvent(resultSaveDialogCloseClick);

  // Photo Guide / For Best Results Bottom Sheet
  static const String photoGuideSheetShow = "photo_guide_sheet_show";
  static const String photoGuideSheetGotItClick =
      "photo_guide_sheet_got_it_click";
  static const String photoGuideSheetCloseClick =
      "photo_guide_sheet_close_click";

  static void logPhotoGuideSheetShow() => _logEvent(photoGuideSheetShow);
  static void logPhotoGuideSheetGotItClick() =>
      _logEvent(photoGuideSheetGotItClick);
  static void logPhotoGuideSheetCloseClick() =>
      _logEvent(photoGuideSheetCloseClick);

  // Photo Selection / Please Select a Photo Bottom Sheet
  static const String photoSelectSheetShow = "photo_select_sheet_show";
  static const String photoSelectSheetInfoClick =
      "photo_select_sheet_info_click";
  static const String photoSelectSheetCloseClick =
      "photo_select_sheet_close_click";
  static const String photoSelectSheetPickPhoto =
      "photo_select_sheet_pick_photo";
  static const String photoSelectSheetRemovePhoto =
      "photo_select_sheet_remove_photo";
  static const String photoSelectSheetUpgradeProClick =
      "photo_select_sheet_upgrade_pro_click";
  static const String photoSelectSheetCreateNowClick =
      "photo_select_sheet_create_now_click";

  static void logPhotoSelectSheetShow({required bool isDouble}) =>
      _logEvent(photoSelectSheetShow, {"is_double": isDouble});
  static void logPhotoSelectSheetInfoClick() =>
      _logEvent(photoSelectSheetInfoClick);
  static void logPhotoSelectSheetCloseClick() =>
      _logEvent(photoSelectSheetCloseClick);
  static void logPhotoSelectSheetPickPhoto({required String slot}) =>
      _logEvent(photoSelectSheetPickPhoto, {"slot": slot});
  static void logPhotoSelectSheetRemovePhoto({required String slot}) =>
      _logEvent(photoSelectSheetRemovePhoto, {"slot": slot});
  static void logPhotoSelectSheetUpgradeProClick() =>
      _logEvent(photoSelectSheetUpgradeProClick);
  static void logPhotoSelectSheetCreateNowClick() =>
      _logEvent(photoSelectSheetCreateNowClick);

  // AI Creation Generating Screen
  static const String generatingView = "generating_view";
  static const String generatingComplete = "generating_complete";
  static const String generatingFailed = "generating_failed";
  static const String generatingRetryClick = "generating_retry_click";
  static const String generatingBackClick = "generating_back_click";

  static void logGeneratingView({String? templateTitle}) =>
      _logEvent(generatingView, {"template_title": templateTitle ?? ""});
  static void logGeneratingComplete({String? templateTitle}) =>
      _logEvent(generatingComplete, {"template_title": templateTitle ?? ""});
  static void logGeneratingFailed({
    String? error,
    String? jobId,
    String? templateId,
    String? promptId,
  }) =>
      _logEvent(generatingFailed, {
        "error": error ?? "",
        if (jobId != null && jobId.isNotEmpty) "job_id": jobId,
        if (templateId != null && templateId.isNotEmpty)
          "template_id": templateId,
        if (promptId != null && promptId.isNotEmpty) "prompt_id": promptId,
      });
  static void logGeneratingRetryClick() => _logEvent(generatingRetryClick);
  static void logGeneratingBackClick() => _logEvent(generatingBackClick);

  // Media Picker Bottom Sheet
  static const String mediaPickerShow = "media_picker_show";
  static const String mediaPickerCameraClick = "media_picker_camera_click";
  static const String mediaPickerGalleryClick = "media_picker_gallery_click";
  static const String mediaPickerCloseClick = "media_picker_close_click";

  static void logMediaPickerShow() => _logEvent(mediaPickerShow);
  static void logMediaPickerCameraClick() => _logEvent(mediaPickerCameraClick);
  static void logMediaPickerGalleryClick() => _logEvent(mediaPickerGalleryClick);
  static void logMediaPickerCloseClick() => _logEvent(mediaPickerCloseClick);

  // In-App Camera Screen
  static const String cameraCaptureView = "camera_capture_view";
  static const String cameraCaptureShutterClick = "camera_capture_shutter_click";
  static const String cameraCaptureFlashToggle = "camera_capture_flash_toggle";
  static const String cameraCaptureSwitchCamera = "camera_capture_switch_camera";
  static const String cameraCaptureBackClick = "camera_capture_back_click";

  static void logCameraCaptureView() => _logEvent(cameraCaptureView);
  static void logCameraCaptureShutterClick() =>
      _logEvent(cameraCaptureShutterClick);
  static void logCameraCaptureFlashToggle({required bool isFlashOn}) =>
      _logEvent(cameraCaptureFlashToggle, {"is_flash_on": isFlashOn});
  static void logCameraCaptureSwitchCamera({required bool isFrontCamera}) =>
      _logEvent(cameraCaptureSwitchCamera, {"is_front_camera": isFrontCamera});
  static void logCameraCaptureBackClick() => _logEvent(cameraCaptureBackClick);

  // Image Crop Screen
  static const String imageCropView = "image_crop_view";
  static const String imageCropRotateClick = "image_crop_rotate_click";
  static const String imageCropContinueClick = "image_crop_continue_click";
  static const String imageCropBackClick = "image_crop_back_click";

  static void logImageCropView() => _logEvent(imageCropView);
  static void logImageCropRotateClick() => _logEvent(imageCropRotateClick);
  static void logImageCropContinueClick() => _logEvent(imageCropContinueClick);
  static void logImageCropBackClick() => _logEvent(imageCropBackClick);

  // Exit App Bottom Sheet
  static const String homeBackClick = "home_back_click";
  static const String exitSheetShow = "exit_sheet_show";
  static const String exitSheetConfirmClick = "exit_sheet_confirm_click";
  static const String exitSheetCancelClick = "exit_sheet_cancel_click";
  static const String exitSheetCloseClick = "exit_sheet_close_click";

  static void logHomeBackClick() => _logEvent(homeBackClick);
  static void logExitSheetShow() => _logEvent(exitSheetShow);
  static void logExitSheetConfirmClick() => _logEvent(exitSheetConfirmClick);
  static void logExitSheetCancelClick() => _logEvent(exitSheetCancelClick);
  static void logExitSheetCloseClick() => _logEvent(exitSheetCloseClick);

  // Paywall Screen & In-App Purchases
  static const String paywallView = "paywall_view";
  static const String paywallCloseClick = "paywall_close_click";
  static const String paywallPlanSelect = "paywall_plan_select";
  static const String paywallContinueClick = "paywall_continue_click";
  static const String paywallTermsClick = "paywall_terms_click";
  static const String paywallPrivacyClick = "paywall_privacy_click";
  static const String paywallRestoreClick = "paywall_restore_click";
  static const String paywallViewAllPlansClick = "paywall_view_all_plans_click";
  static const String paywallAllPlansSheetShow = "paywall_all_plans_sheet_show";
  static const String paywallAllPlansSheetCloseClick =
      "paywall_all_plans_sheet_close_click";
  static const String paywallPurchaseStarted = "paywall_purchase_started";
  static const String paywallPurchaseSuccess = "paywall_purchase_success";
  static const String paywallPurchaseFailed = "paywall_purchase_failed";
  static const String paywallPurchaseCancelled = "paywall_purchase_cancelled";
  static const String paywallRestoreSuccess = "paywall_restore_success";
  static const String paywallRestoreFailed = "paywall_restore_failed";

  static void logPaywallView({int step = 1}) =>
      _logEvent(paywallView, {"step": step});
  static void logPaywallCloseClick({int step = 1}) =>
      _logEvent(paywallCloseClick, {"step": step});
  static void logPaywallPlanSelect({
    required String planId,
    String? title,
    String? price,
    int? coins,
    int step = 1,
  }) =>
      _logEvent(paywallPlanSelect, {
        "plan_id": planId,
        "step": step,
        if (title != null && title.isNotEmpty) "title": title,
        if (price != null && price.isNotEmpty) "price": price,
        if (coins != null && coins > 0) "coins": coins,
      });
  static void logPaywallContinueClick({
    required String planId,
    String? title,
    String? price,
    int? coins,
    int step = 1,
  }) =>
      _logEvent(paywallContinueClick, {
        "plan_id": planId,
        "step": step,
        if (title != null && title.isNotEmpty) "title": title,
        if (price != null && price.isNotEmpty) "price": price,
        if (coins != null && coins > 0) "coins": coins,
      });
  static void logPaywallTermsClick() => _logEvent(paywallTermsClick);
  static void logPaywallPrivacyClick() => _logEvent(paywallPrivacyClick);
  static void logPaywallRestoreClick() => _logEvent(paywallRestoreClick);
  static void logPaywallViewAllPlansClick() =>
      _logEvent(paywallViewAllPlansClick);
  static void logPaywallAllPlansSheetShow() =>
      _logEvent(paywallAllPlansSheetShow);
  static void logPaywallAllPlansSheetCloseClick() =>
      _logEvent(paywallAllPlansSheetCloseClick);
  static void logPaywallPurchaseStarted({
    required String planId,
    String? title,
    String? price,
    int? coins,
  }) =>
      _logEvent(paywallPurchaseStarted, {
        "plan_id": planId,
        if (title != null && title.isNotEmpty) "title": title,
        if (price != null && price.isNotEmpty) "price": price,
        if (coins != null && coins > 0) "coins": coins,
      });
  /// Official Firebase Analytics `purchase` conversion event with value and currency.
  /// Standard GA4 E-Commerce event that populates Monetization and In-App Purchase Revenue.
  static Future<void> logPurchase({
    required double value,
    required String currency,
    required String planId,
    String? planType,
    int? coins,
    String? transactionId,
    String? source,
  }) async {
    try {
      if (Firebase.apps.isEmpty) {
        if (kDebugMode) {
          log("Cannot log purchase: Firebase not yet initialized.",
              name: "LOGEVENTMANAGER");
        }
        return;
      }

      final validCurrency =
          currency.trim().isNotEmpty ? currency.trim().toUpperCase() : 'USD';

      await _analytics.logPurchase(
        value: value,
        currency: validCurrency,
        transactionId: transactionId,
        items: [
          AnalyticsEventItem(
            itemId: planId,
            itemName: planId,
            price: value,
            quantity: 1,
          ),
        ],
        parameters: {
          'plan_id': planId,
          if (planType != null && planType.isNotEmpty) 'plan_type': planType,
          if (coins != null && coins > 0) 'coins': coins,
          if (source != null && source.isNotEmpty) 'source': source,
        },
      );

      if (kDebugMode) {
        log(
          "🔥 FIREBASE OFFICIAL PURCHASE EVENT: planId=$planId | value=$value $validCurrency",
          name: "LOGEVENTMANAGER",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log("Error logging Firebase purchase: $e", name: "LOGEVENTMANAGER");
      }
    }
  }

  /// Common success event for every purchase (coins + subscriptions). Kept as
  /// a custom name so GA4 does not add it to revenue on top of the automatic
  /// in_app_purchase event.
  static void logPurchaseSuccess({
    required String planId,
    required String purchaseType,
    required double value,
    required String currency,
    required int coins,
    required bool isTrial,
    required String source,
  }) =>
      _logEvent('purchase_success', {
        "plan_id": planId,
        "purchase_type": purchaseType,
        "value": value,
        "currency": currency,
        "coins": coins,
        "is_trial": isTrial,
        "source": source,
      });

  static void logPaywallPurchaseSuccess({
    required String planId,
    int? coins,
    String? price,
  }) =>
      _logEvent(paywallPurchaseSuccess, {
        "plan_id": planId,
        if (coins != null && coins > 0) "coins": coins,
        if (price != null && price.isNotEmpty) "price": price,
      });
  static void logPaywallPurchaseFailed({
    required String planId,
    required String error,
  }) =>
      _logEvent(paywallPurchaseFailed, {"plan_id": planId, "error": error});
  static void logPaywallPurchaseCancelled({required String planId}) =>
      _logEvent(paywallPurchaseCancelled, {"plan_id": planId});
  static void logPaywallRestoreSuccess() => _logEvent(paywallRestoreSuccess);
  static void logPaywallRestoreFailed({required String error}) =>
      _logEvent(paywallRestoreFailed, {"error": error});

  // Remove Watermark Dialog / Sheet
  static const String removeWatermarkSheetShow =
      "remove_watermark_sheet_show";
  static const String removeWatermarkSheetAdClick =
      "remove_watermark_sheet_ad_click";
  static const String removeWatermarkSheetPremiumClick =
      "remove_watermark_sheet_premium_click";
  static const String removeWatermarkSheetCloseClick =
      "remove_watermark_sheet_close_click";

  static void logRemoveWatermarkSheetShow() =>
      _logEvent(removeWatermarkSheetShow);
  static void logRemoveWatermarkSheetAdClick() =>
      _logEvent(removeWatermarkSheetAdClick);
  static void logRemoveWatermarkSheetPremiumClick() =>
      _logEvent(removeWatermarkSheetPremiumClick);
  static void logRemoveWatermarkSheetCloseClick() =>
      _logEvent(removeWatermarkSheetCloseClick);

  // Regenerate Bottom Sheet
  static const String regenerateSheetShow = "regenerate_sheet_show";
  static const String regenerateSheetAdClick = "regenerate_sheet_ad_click";
  static const String regenerateSheetUpgradeClick =
      "regenerate_sheet_upgrade_click";
  static const String regenerateSheetCloseClick =
      "regenerate_sheet_close_click";

  static void logRegenerateSheetShow() => _logEvent(regenerateSheetShow);
  static void logRegenerateSheetAdClick() => _logEvent(regenerateSheetAdClick);
  static void logRegenerateSheetUpgradeClick() =>
      _logEvent(regenerateSheetUpgradeClick);
  static void logRegenerateSheetCloseClick() =>
      _logEvent(regenerateSheetCloseClick);

  // Face Detection / Validation
  static const String faceValidationSuccess = "face_validation_success";
  static const String faceValidationFailed = "face_validation_failed";

  static void logFaceValidationSuccess({
    required int faceCount,
    required bool singleFace,
  }) =>
      _logEvent(faceValidationSuccess, {
        'face_count': faceCount,
        'single_face': singleFace,
      });

  static void logFaceValidationFailed({
    required int faceCount,
    required bool singleFace,
    required String reason,
  }) =>
      _logEvent(faceValidationFailed, {
        'face_count': faceCount,
        'single_face': singleFace,
        'reason': reason,
      });

  // No Internet Dialog
  static const String noInternetDialogShow = "no_internet_dialog_show";
  static const String noInternetRetryClick = "no_internet_retry_click";
  static const String noInternetRestored = "no_internet_restored";

  static void logNoInternetDialogShow() => _logEvent(noInternetDialogShow);
  static void logNoInternetRetryClick({required bool hasInternet}) =>
      _logEvent(noInternetRetryClick, {"has_internet": hasInternet});
  static void logNoInternetRestored() => _logEvent(noInternetRestored);


  // ---------------------------------------------------------------------------
  // Splash Screen Waterfall & Ads
  // ---------------------------------------------------------------------------
  static void logSplashInterstitialLoad() =>
      _logEvent('splash_interstitial_load');
  static void logSplashInterstitialShow() =>
      _logEvent('splash_interstitial_show');
  static void logSplashInterstitialClick() =>
      _logEvent('splash_interstitial_click');
  static void logSplashInterstitialClose() =>
      _logEvent('splash_interstitial_close');
  static void logSplashInterstitialFailToLoad(String error) =>
      _logEvent('splash_interstitial_fail_to_load', {'error': error});

  static void logSplashAppOpenLoad() => _logEvent('splash_app_open_load');
  static void logSplashAppOpenShow() => _logEvent('splash_app_open_show');
  static void logSplashAppOpenClick() => _logEvent('splash_app_open_click');
  static void logSplashAppOpenClose() => _logEvent('splash_app_open_close');
  static void logSplashAppOpenAdClose() => _logEvent('splash_app_open_ad_close');
  static void logSplashAppOpenFailToLoad(String error) =>
      _logEvent('splash_app_open_fail_to_load', {'error': error});

  static void logSplashFullNativeAdLoad() =>
      _logEvent('splash_full_native_ad_load');
  static void logSplashFullNativeAdShow() =>
      _logEvent('splash_full_native_ad_show');
  static void logSplashFullNativeAdClick() =>
      _logEvent('splash_full_native_ad_click');
  static void logSplashFullNativeAdClose() =>
      _logEvent('splash_full_native_ad_close');
  static void logSplashFullNativeAdFailToLoad(String error) =>
      _logEvent('splash_full_native_ad_fail_to_load', {'error': error});

  // ---------------------------------------------------------------------------
  // Ad Tracking & Paid Revenue
  // ---------------------------------------------------------------------------
  static void logPaidAdImpression({
    required String screenName,
    required double adValue,
    required String precision,
    required String adUnitId,
    required String adType,
    required String countryCode,
    String? network,
    String? adSource,
  }) {
    logPaidAdEvent(
      revenue: adValue,
      currency: countryCode,
      precision: int.tryParse(precision) ?? 0,
      adUnitId: adUnitId,
      adType: adType,
      screenName: screenName,
      network: network,
      adSource: adSource,
    );
  }

  static void logPaidAdEvent({
    required double revenue,
    required String currency,
    required int precision,
    required String adUnitId,
    required String adType,
    required String screenName,
    String? network,
    String? adSource,
  }) {
    try {
      RevenueThresholdManager.processAdRevenue(
        revenue,
        adType: adType,
        currency: currency,
      );

      final Map<String, Object> params = {
        'ad_screen_name': screenName,
        'value': revenue,
        'currency': currency,
        'precision': precision,
        'ad_unit_id': adUnitId,
        'network': network ?? 'unknown',
        'ad_platform': 'Admob',
        'ad_format': adType,
        'ad_source': adSource ?? 'unknown',
      };
      _logEvent('ad_impression', params);

      // Meta (Facebook) Standard Ad Impression Event (Matches native Android AppEventsConstants + metadata)
      FacebookAppEvents().logEvent(
        name: 'AdImpression',
        parameters: {
          'fb_ad_type': adType,
          'fb_currency': currency,
          'ad_screen_name': screenName,
          'ad_unit_id': adUnitId,
          'ad_platform': 'Admob',
          'network': network ?? 'unknown',
          'ad_source': adSource ?? 'unknown',
          'value': revenue,
        },
        valueToSum: revenue,
      );
    } catch (_) {}
  }

  static void trackAdRequest({
    required String adPlatform,
    required String adUnitId,
    required String adType,
  }) {
    _logEvent(
      'track_ad_request',
      {
        'ad_platform': adPlatform,
        'ad_unit_id': adUnitId,
        'ad_format': adType,
      },
    );
  }

  static void trackAdMatchedRequest({
    required String adPlatform,
    required String adUnitId,
    required String adType,
    dynamic responseInfo,
  }) {
    final Map<String, Object> parameters = {
      'ad_platform': adPlatform,
      'ad_unit_id': adUnitId,
      'ad_format': adType,
    };
    if (responseInfo != null) {
      try {
        if (responseInfo.loadedAdapterResponseInfo != null) {
          parameters['ad_source'] =
              responseInfo.loadedAdapterResponseInfo?.adSourceName ?? 'unknown';
          parameters['ad_source_unit_id'] =
              responseInfo.loadedAdapterResponseInfo?.adSourceId ?? '';
        }
      } catch (_) {}
    }
    _logEvent('track_ad_matched_request', parameters);
  }

  static void logAdClick({
    required String screenName,
    required String adUnitId,
    required String adPlatform,
    required String adFormat,
    required String adSource,
    required String network,
  }) {
    final Map<String, Object> params = {
      'ad_screen_name': screenName,
      'ad_unit_id': adUnitId,
      'ad_platform': adPlatform,
      'ad_format': adFormat,
      'ad_source': adSource,
      'network': network,
    };
    _logEvent('ads_click', params);
  }

  // Interstitial Ad Events
  static void logInterAdLoad(String adLabel) =>
      _logEvent('inter_ad_load', {'ad_label': adLabel});
  static void logInterAdFailToLoad(String adLabel, String error) => _logEvent(
        'inter_ad_fail_to_load',
        {'ad_label': adLabel, 'error': error},
      );
  static void logInterAdShow(String adLabel) =>
      _logEvent('inter_ad_show', {'ad_label': adLabel});
  static void logInterAdClick(String adLabel) =>
      _logEvent('inter_ad_click', {'ad_label': adLabel});
  static void logInterAdClose(String adLabel) =>
      _logEvent('inter_ad_close', {'ad_label': adLabel});

  // App Open Ad Events
  static void logOpenAdLoad(String adLabel) =>
      _logEvent('open_ad_load', {'ad_label': adLabel});
  static void logOpenAdFailToLoad(String adLabel, String error) => _logEvent(
        'open_ad_fail_to_load',
        {'ad_label': adLabel, 'error': error},
      );
  static void logOpenAdShow(String adLabel) =>
      _logEvent('open_ad_show', {'ad_label': adLabel});
  static void logOpenAdClick(String adLabel) =>
      _logEvent('open_ad_click', {'ad_label': adLabel});
  static void logOpenAdClose(String adLabel) =>
      _logEvent('open_ad_close', {'ad_label': adLabel});

  // Native Ad Events
  static void logNativeAdLoad(String adLabel) =>
      _logEvent('native_ad_load', {'ad_label': adLabel});
  static void logNativeAdFailToLoad(String adLabel, String error) => _logEvent(
        'native_ad_fail_to_load',
        {'ad_label': adLabel, 'error': error},
      );
  static void logNativeAdShow(String adLabel) =>
      _logEvent('native_ad_show', {'ad_label': adLabel});
  static void logNativeAdClick(String adLabel) =>
      _logEvent('native_ad_click', {'ad_label': adLabel});

  // Banner Ad Events
  static void logBannerAdLoad(String adLabel) =>
      _logEvent('banner_ad_load', {'ad_label': adLabel});
  static void logBannerAdFailToLoad(String adLabel, String error) => _logEvent(
        'banner_ad_fail_to_load',
        {'ad_label': adLabel, 'error': error},
      );
  static void logBannerAdShow(String adLabel) =>
      _logEvent('banner_ad_show', {'ad_label': adLabel});
  static void logBannerAdClick(String adLabel) =>
      _logEvent('banner_ad_click', {'ad_label': adLabel});

  // Rewarded Ad Events
  static void logRewardAdLoad(String adLabel) =>
      _logEvent('reward_ad_load', {'ad_label': adLabel});
  static void logRewardAdFailToLoad(String adLabel, String error) => _logEvent(
        'reward_ad_fail_to_load',
        {'ad_label': adLabel, 'error': error},
      );
  static void logRewardAdShow(String adLabel) =>
      _logEvent('reward_ad_show', {'ad_label': adLabel});
  static void logRewardAdClick(String adLabel) =>
      _logEvent('reward_ad_click', {'ad_label': adLabel});
  static void logRewardAdClose(String adLabel) =>
      _logEvent('reward_ad_close', {'ad_label': adLabel});
  static void logRewardAdEarned(String adLabel) =>
      _logEvent('reward_ad_earned', {'ad_label': adLabel});

  // Dedicated Screen Ad Events (Only Splash, First-time Language, Onboarding)
  static void logLanguageNativeAdLoad() =>
      _logEvent('language_native_ad_load');
  static void logLanguageNativeAdShow() =>
      _logEvent('language_native_ad_show');
  static void logLanguageNativeAdClick() =>
      _logEvent('language_native_ad_click');
  static void logLanguageNativeAdFailToLoad(String error) =>
      _logEvent('language_native_ad_fail_to_load', {'error': error});

  static void logOnboardingNativeAdLoad() =>
      _logEvent('onboarding_native_ad_load');
  static void logOnboardingNativeAdShow() =>
      _logEvent('onboarding_native_ad_show');
  static void logOnboardingNativeAdClick() =>
      _logEvent('onboarding_native_ad_click');
  static void logOnboardingNativeAdFailToLoad(String error) =>
      _logEvent('onboarding_native_ad_fail_to_load', {'error': error});

  static bool _isLanguageAdLabel(String label) =>
      label == ADLabelKey.languageScreen;
  static bool _isOnboardingAdLabel(String label) =>
      label == ADLabelKey.onboardingScreen || label.contains('onboard');

  static void logDedicatedNativeAdLoad(String adLabel) {
    if (_isLanguageAdLabel(adLabel)) {
      logLanguageNativeAdLoad();
    } else if (_isOnboardingAdLabel(adLabel)) {
      logOnboardingNativeAdLoad();
    }
  }

  static void logDedicatedNativeAdShow(String adLabel) {
    if (_isLanguageAdLabel(adLabel)) {
      logLanguageNativeAdShow();
    } else if (_isOnboardingAdLabel(adLabel)) {
      logOnboardingNativeAdShow();
    }
  }

  static void logDedicatedNativeAdClick(String adLabel) {
    if (_isLanguageAdLabel(adLabel)) {
      logLanguageNativeAdClick();
    } else if (_isOnboardingAdLabel(adLabel)) {
      logOnboardingNativeAdClick();
    }
  }

  static void logDedicatedNativeAdFail(String adLabel, String error) {
    if (_isLanguageAdLabel(adLabel)) {
      logLanguageNativeAdFailToLoad(error);
    } else if (_isOnboardingAdLabel(adLabel)) {
      logOnboardingNativeAdFailToLoad(error);
    }
  }

  // Uninstall Flow Events
  static const String uninstallChatScreenView = "uninstall_chat_view";
  static const String uninstallReasonScreenView = "uninstall_reason_view";
  static const String thankyouView = "thankyou_view";
  static const String uninstallChatIssueClick = "uninstall_chat_issue_click";
  static const String uninstallChatStayClick = "uninstall_chat_stay_click";
  static const String uninstallChatStillWantClick = "uninstall_chat_still_want_click";
  static const String uninstallChatBackClick = "uninstall_chat_back_click";
  static const String uninstallReasonSelect = "uninstall_reason_select";
  static const String uninstallReasonCancelClick = "uninstall_reason_cancel_click";
  static const String uninstallReasonBackClick = "uninstall_reason_back_click";
  static const String uninstallFeedbackSubmitClick =
      "uninstall_feedback_submit_click";
  static const String uninstallReasonSubmitted = "uninstall_reason_submitted";
  static const String openSettings = "open_settings";
  static const String openSettingsFailed = "open_settings_failed";

  static void logUninstallChatScreenView() =>
      _logEvent(uninstallChatScreenView);
  static void logUninstallReasonScreenView() =>
      _logEvent(uninstallReasonScreenView);
  static void logThankyouView() => _logEvent(thankyouView);
  static void logUninstallChatIssueClick({required String issue}) =>
      _logEvent(uninstallChatIssueClick, {'issue': issue});
  static void logUninstallChatStayClick() => _logEvent(uninstallChatStayClick);
  static void logUninstallChatStillWantClick() =>
      _logEvent(uninstallChatStillWantClick);
  static void logUninstallChatBackClick() => _logEvent(uninstallChatBackClick);
  static void logUninstallReasonSelect({required String reason}) =>
      _logEvent(uninstallReasonSelect, {'reason': reason});
  static void logUninstallReasonCancelClick() =>
      _logEvent(uninstallReasonCancelClick);
  static void logUninstallReasonBackClick() =>
      _logEvent(uninstallReasonBackClick);
  static void logUninstallFeedbackSubmitClick() =>
      _logEvent(uninstallFeedbackSubmitClick);
  static void logUninstallReasonSubmitted({
    required String reason,
    String? otherText,
  }) =>
      _logEvent(uninstallReasonSubmitted, {
        'reason': reason,
        if (otherText != null && otherText.isNotEmpty) 'other_text': otherText,
      });
  static void logOpenSettings() => _logEvent(openSettings);
  static void logOpenSettingsFailed(String error) =>
      _logEvent(openSettingsFailed, {'error': error});

  // Permission Dialog Events
  static const String permissionDialogShow = "permission_dialog_show";
  static const String permissionDialogOpenSettingsClick =
      "permission_dialog_open_settings_click";
  static const String permissionDialogCancelClick =
      "permission_dialog_cancel_click";

  static void logPermissionDialogShow({required String permission}) =>
      _logEvent(permissionDialogShow, {'permission': permission});
  static void logPermissionDialogOpenSettingsClick({required String permission}) =>
      _logEvent(permissionDialogOpenSettingsClick, {'permission': permission});
  static void logPermissionDialogCancelClick({required String permission}) =>
      _logEvent(permissionDialogCancelClick, {'permission': permission});

  // ── No Coin Paywall Dialog Events ──────────────────────────────────────────
  static const String noCoinDialogShow = "no_coin_dialog_show";
  static const String noCoinDialogCloseClick = "no_coin_dialog_close_click";
  static const String noCoinDialogPlanSelect = "no_coin_dialog_plan_select";
  static const String noCoinDialogGetCoinsClick = "no_coin_dialog_get_coins_click";
  static const String noCoinDialogMaybeLaterClick = "no_coin_dialog_maybe_later_click";
  static const String noCoinDialogTierSelect = "no_coin_dialog_tier_select";
  static const String noCoinPurchaseStarted = "no_coin_purchase_started";
  static const String noCoinPurchaseSuccess = "no_coin_purchase_success";
  static const String noCoinPurchaseFailed = "no_coin_purchase_failed";
  static const String noCoinPurchaseCancelled = "no_coin_purchase_cancelled";

  static void logNoCoinDialogShow() => _logEvent(noCoinDialogShow);
  static void logNoCoinDialogCloseClick() => _logEvent(noCoinDialogCloseClick);
  static void logNoCoinDialogPlanSelect({
    required String planId,
    required int coins,
    String? price,
  }) =>
      _logEvent(noCoinDialogPlanSelect, {
        'plan_id': planId,
        'coins': coins,
        if (price != null && price.isNotEmpty) 'price': price,
      });
  static void logNoCoinDialogGetCoinsClick({
    required String planId,
    required int coins,
    String? price,
  }) =>
      _logEvent(noCoinDialogGetCoinsClick, {
        'plan_id': planId,
        'coins': coins,
        if (price != null && price.isNotEmpty) 'price': price,
      });
  static void logNoCoinDialogMaybeLaterClick() =>
      _logEvent(noCoinDialogMaybeLaterClick);
  static void logNoCoinDialogTierSelect({
    required int coins,
    required String price,
  }) =>
      _logEvent(noCoinDialogTierSelect, {'coins': coins, 'price': price});
  static void logNoCoinPurchaseStarted({
    required String planId,
    required int coins,
    String? price,
  }) =>
      _logEvent(noCoinPurchaseStarted, {
        'plan_id': planId,
        'coins': coins,
        if (price != null && price.isNotEmpty) 'price': price,
      });
  static void logNoCoinPurchaseSuccess({
    required String planId,
    required int coins,
    String? price,
  }) =>
      _logEvent(noCoinPurchaseSuccess, {
        'plan_id': planId,
        'coins': coins,
        if (price != null && price.isNotEmpty) 'price': price,
      });
  static void logNoCoinPurchaseFailed({
    required String planId,
    required String error,
  }) =>
      _logEvent(noCoinPurchaseFailed, {
        'plan_id': planId,
        'error': error,
      });
  static void logNoCoinPurchaseCancelled({required String planId}) =>
      _logEvent(noCoinPurchaseCancelled, {'plan_id': planId});

  // ── Login Screen Events ───────────────────────────────────────────────────
  static const String settingsLoginClick = "settings_login_click";
  static const String loginView = "login_view";
  static const String loginBackClick = "login_back_click";
  static const String loginSubmitClick = "login_submit_click";
  static const String loginSuccess = "login_success";
  static const String loginFailed = "login_failed";

  static void logSettingsLoginClick() => _logEvent(settingsLoginClick);
  static void logLoginView() => _logEvent(loginView);
  static void logLoginBackClick() => _logEvent(loginBackClick);
  static void logLoginSubmitClick() => _logEvent(loginSubmitClick);
  static void logLoginSuccess() => _logEvent(loginSuccess);
  static void logLoginFailed(String error) =>
      _logEvent(loginFailed, {'error': error});

  // ── Network & API Error Events ──────────────────────────────────────────────
  static const String apiNetworkError = "api_network_error";
  static const String apiTimeoutError = "api_timeout_error";
  static const String apiHttpError = "api_http_error";
  static const String apiUnknownError = "api_unknown_error";
  static const String imageDownloadFailed = "image_download_failed";

  static void logApiNetworkError({
    required String url,
    required String method,
    required String error,
  }) =>
      _logEvent(apiNetworkError, {
        'url': url,
        'method': method,
        'error': error,
      });

  static void logApiTimeoutError({
    required String url,
    required String method,
    required int timeoutSeconds,
  }) =>
      _logEvent(apiTimeoutError, {
        'url': url,
        'method': method,
        'timeout_seconds': timeoutSeconds,
      });

  static void logApiHttpError({
    required String url,
    required String method,
    required int statusCode,
    String? errorMessage,
  }) =>
      _logEvent(apiHttpError, {
        'url': url,
        'method': method,
        'status_code': statusCode,
        if (errorMessage != null && errorMessage.isNotEmpty)
          'error_message': errorMessage.length > 200
              ? errorMessage.substring(0, 200)
              : errorMessage,
      });

  static void logApiUnknownError({
    required String url,
    required String method,
    required String error,
  }) =>
      _logEvent(apiUnknownError, {
        'url': url,
        'method': method,
        'error': error,
      });

  static void logImageDownloadFailed({
    required String imageUrl,
    required String error,
  }) =>
      _logEvent(imageDownloadFailed, {
        'image_url': imageUrl,
        'error': error,
      });

  // ── Launcher Shortcuts ─────────────────────────────────────────────────────
  static const String shortcutStudioClick = "shortcut_studio_click";
  static const String shortcutCreationClick = "shortcut_creation_click";
  static const String shortcutUninstallClick = "shortcut_uninstall_click";

  static void logShortcutStudioClick() => _logEvent(shortcutStudioClick);
  static void logShortcutCreationClick() => _logEvent(shortcutCreationClick);
  static void logShortcutUninstallClick() => _logEvent(shortcutUninstallClick);
}



