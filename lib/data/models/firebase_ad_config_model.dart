import 'dart:convert';

FirebaseAdConfigModel firebaseAdConfigModelFromJson(String str) =>
    FirebaseAdConfigModel.fromJson(json.decode(str));

String firebaseAdConfigModelToJson(FirebaseAdConfigModel data) =>
    json.encode(data.toJson());

class FirebaseAdConfigModel {
  bool? appLiveStatus;
  String? newPackage;
  bool? showAds;
  int? firstTimeUserOpenCount;
  int? userClickCounter;
  int? bottomBarClickCounter;
  bool? isInterTimer;
  int? interTimerSecond;
  int? interstitialGap;
  bool? nativeAutoRefresh;
  int? nativeRefreshIntervalSec;
  bool? clickAfterRefreshEnable;
  List<String>? splashInterstitialList;
  List<String>? splashOpenAppAdList;
  List<String>? splashNativeAdList;
  List<int>? splashInterTimeoutsSec;
  List<String>? onboardNativeList;
  List<String>? languageNativeList;
  List<String>? interAdList;
  List<String>? nativeAdList;
  List<String>? bannerAdList;
  List<String>? openAppAdList;
  List<String>? createQrRewardList;
  int? splashInterstitialSecound;
  Map<String, AdsDatum>? adsData;

  FirebaseAdConfigModel({
    this.appLiveStatus,
    this.newPackage,
    this.showAds,
    this.firstTimeUserOpenCount,
    this.userClickCounter,
    this.bottomBarClickCounter,
    this.isInterTimer,
    this.interTimerSecond,
    this.interstitialGap,
    this.nativeAutoRefresh,
    this.nativeRefreshIntervalSec,
    this.clickAfterRefreshEnable,
    this.splashInterstitialList,
    this.splashOpenAppAdList,
    this.splashNativeAdList,
    this.splashInterTimeoutsSec,
    this.onboardNativeList,
    this.languageNativeList,
    this.interAdList,
    this.nativeAdList,
    this.bannerAdList,
    this.openAppAdList,
    this.createQrRewardList,
    this.splashInterstitialSecound,
    this.adsData,
  });

  factory FirebaseAdConfigModel.fromJson(Map<String, dynamic> json) =>
      FirebaseAdConfigModel(
        appLiveStatus: json["app_live_status"],
        newPackage: json["new_package"],
        showAds: json["show_ads"],
        firstTimeUserOpenCount: json["first_time_user_open_count"] is num
            ? (json["first_time_user_open_count"] as num).toInt()
            : json["first_time_user_sessions_count"] is num
                ? (json["first_time_user_sessions_count"] as num).toInt()
                : json["first_time_open_count"] is num
                    ? (json["first_time_open_count"] as num).toInt()
                    : null,
        userClickCounter: json["user_click_counter"],
        bottomBarClickCounter: json["bottom_bar_click_counter"],
        isInterTimer: json["is_inter_timer"],
        interTimerSecond: json["inter_timer_second"] ?? json["interstitial_gap"],
        interstitialGap: json["interstitial_gap"] ?? json["inter_timer_second"],
        nativeAutoRefresh: json["native_auto_refresh"] ?? json["auto_refresh"],
        nativeRefreshIntervalSec: json["native_refresh_interval"] is num
            ? (json["native_refresh_interval"] as num).toInt()
            : json["native_refresh_interval_sec"] is num
                ? (json["native_refresh_interval_sec"] as num).toInt()
                : json["refresh_interval"] is num
                    ? (json["refresh_interval"] as num).toInt()
                    : int.tryParse(json["native_refresh_interval"]?.toString() ??
                        json["native_refresh_interval_sec"]?.toString() ??
                        json["refresh_interval"]?.toString() ??
                        json["refresh_interval_sec"]?.toString() ??
                        ''),
        clickAfterRefreshEnable: json["click_after_refresh_enable"] ??
            json["click_after_refresh"] ??
            json["clickAfterRefreshEnable"],
        splashInterstitialList: json["splash_inter_list"] != null
            ? List<String>.from(
                json["splash_inter_list"].map((x) => x.toString()),
              )
            : json["splash_interstitial_list"] == null
                ? null
                : List<String>.from(
                    json["splash_interstitial_list"].map((x) => x.toString()),
                  ),
        splashOpenAppAdList: json["splash_open_app_ad_list"] == null
            ? null
            : List<String>.from(
                json["splash_open_app_ad_list"].map((x) => x.toString()),
              ),
        splashNativeAdList: json["splash_native_ad_list"] == null
            ? null
            : List<String>.from(
                json["splash_native_ad_list"].map((x) => x.toString()),
              ),
        splashInterTimeoutsSec: _parseIntList(json["splash_inter_timeouts_sec"]),
        onboardNativeList: json["onboarding_native_list"] != null
            ? List<String>.from(
                json["onboarding_native_list"].map((x) => x.toString()),
              )
            : json["onboard_native_list"] == null
                ? null
                : List<String>.from(
                    json["onboard_native_list"].map((x) => x.toString()),
                  ),
        languageNativeList: json["language_native_list"] == null
            ? null
            : List<String>.from(
                json["language_native_list"].map((x) => x.toString()),
              ),
        interAdList: json["inter_ad_list"] == null
            ? null
            : List<String>.from(
                json["inter_ad_list"].map((x) => x.toString()),
              ),
        nativeAdList: json["native_ad_list"] == null
            ? null
            : List<String>.from(
                json["native_ad_list"].map((x) => x.toString()),
              ),
        bannerAdList: json["banner_ad_list"] == null
            ? null
            : List<String>.from(
                json["banner_ad_list"].map((x) => x.toString()),
              ),
        openAppAdList: json["open_app_ad_list"] == null
            ? null
            : List<String>.from(
                json["open_app_ad_list"].map((x) => x.toString()),
              ),
        createQrRewardList: json["rewarded_ad_list"] != null
            ? List<String>.from(
                json["rewarded_ad_list"].map((x) => x.toString()),
              )
            : json["create_qr_reward_list"] == null
                ? null
                : List<String>.from(
                    json["create_qr_reward_list"].map((x) => x.toString()),
                  ),
        splashInterstitialSecound: json["splash_interstitial_secound"],
        adsData: json["ads_data"] == null
            ? null
            : Map<String, AdsDatum>.from(
                Map.from(json["ads_data"]).map(
                  (k, v) => MapEntry<String, AdsDatum>(
                    k.toString(),
                    AdsDatum.fromJson(v),
                  ),
                ),
              ),
      );

  static List<int>? _parseIntList(dynamic raw) {
    if (raw is! List) return null;
    return raw
        .map((e) {
          if (e is num) return e.toInt();
          return int.tryParse(e.toString()) ?? 15;
        })
        .toList();
  }

  Map<String, dynamic> toJson() => {
        "app_live_status": appLiveStatus,
        "new_package": newPackage,
        "show_ads": showAds,
        "first_time_user_open_count": firstTimeUserOpenCount,
        "user_click_counter": userClickCounter,
        "bottom_bar_click_counter": bottomBarClickCounter,
        "is_inter_timer": isInterTimer,
        "inter_timer_second": interTimerSecond,
        "interstitial_gap": interstitialGap ?? interTimerSecond,
        "splash_inter_list": splashInterstitialList,
        "splash_open_app_ad_list": splashOpenAppAdList,
        "splash_native_ad_list": splashNativeAdList,
        "splash_inter_timeouts_sec": splashInterTimeoutsSec,
        "onboarding_native_list": onboardNativeList,
        "language_native_list": languageNativeList,
        "inter_ad_list": interAdList,
        "native_ad_list": nativeAdList,
        "banner_ad_list": bannerAdList,
        "open_app_ad_list": openAppAdList,
        "rewarded_ad_list": createQrRewardList,
        "splash_interstitial_secound": splashInterstitialSecound,
        "ads_data": adsData != null
            ? Map.from(adsData!)
                .map((k, v) => MapEntry<String, dynamic>(k, v.toJson()))
            : null,
      };
}

class AdsDatum {
  String? adsName;
  String? adsType;
  String? secondaryAdsType;
  bool? enableAds;
  bool? enableAdsFirstTime;
  bool? enableAdsReturning;
  String? primaryAd;
  List<String>? fallbackSequence;
  List<FallbackAdItem>? fallbacks;
  bool? enableInterstitial;
  bool? enableAppOpen;
  bool? enableNative;
  bool? fallbackEnabled;
  bool? fallbackAppOpenEnabled;
  bool? fallbackNativeEnabled;
  String? publishers;
  String? layout;
  bool? autoRefresh;
  int? refreshIntervalSec;
  bool? clickAfterRefreshEnable;
  String? bannerType;
  bool? useClickCounter;
  List<String>? supportedTypes;
  String? adUnitId;
  List<String>? adUnitList;

  AdsDatum({
    this.adsName,
    this.adsType,
    this.secondaryAdsType,
    this.enableAds,
    this.enableAdsFirstTime,
    this.enableAdsReturning,
    this.primaryAd,
    this.fallbackSequence,
    this.fallbacks,
    this.enableInterstitial,
    this.enableAppOpen,
    this.enableNative,
    this.fallbackEnabled,
    this.fallbackAppOpenEnabled,
    this.fallbackNativeEnabled,
    this.publishers,
    this.layout,
    this.autoRefresh,
    this.refreshIntervalSec,
    this.clickAfterRefreshEnable,
    this.bannerType,
    this.useClickCounter,
    this.supportedTypes,
    this.adUnitId,
    this.adUnitList,
  });

  /// Prefers first-time / returning flags; falls back to legacy [enableAds].
  /// If the root format is disabled (e.g. interstitial disabled for first-time user)
  /// but fallbacks are enabled, returns true so the placement waterfall can run.
  bool resolveEnableAds({required bool isFirstTime}) {
    final rootEnabled = isFirstTime
        ? (enableAdsFirstTime ?? enableAds ?? false)
        : (enableAdsReturning ?? enableAds ?? false);
    if (rootEnabled) return true;

    if (fallbacks != null && fallbacks!.isNotEmpty) {
      return fallbacks!.any((fb) => fb.resolveEnable(isFirstTime: isFirstTime));
    }
    return false;
  }

  factory AdsDatum.fromJson(Map<String, dynamic> json) => AdsDatum(
        adsName: json["adsName"] ?? json["ads_name"],
        adsType: json["adsType"] ?? json["ads_type"],
        secondaryAdsType:
            json["secondaryAdsType"] ?? json["secondary_ads_type"],
        enableAds: json["enableAds"] ?? json["enable_ads"],
        enableAdsFirstTime: json["enable_ads_first_time"] ??
            json["enableAdsFirstTime"] ??
            json["first_time"],
        enableAdsReturning: json["enable_ads_returning"] ??
            json["enableAdsReturning"] ??
            json["second_time"],
        primaryAd: json["primary_ad"] ?? json["primaryAd"],
        fallbackSequence: json["fallback_sequence"] != null
            ? List<String>.from(
                json["fallback_sequence"].map((x) => x.toString()))
            : null,
        fallbacks: json["fallbacks"] != null
            ? List<FallbackAdItem>.from(
                json["fallbacks"].map((x) {
                  if (x is Map<String, dynamic>) {
                    return FallbackAdItem.fromJson(x);
                  } else if (x is Map) {
                    return FallbackAdItem.fromJson(Map<String, dynamic>.from(x));
                  } else if (x is String) {
                    return FallbackAdItem(
                      enable: true,
                      adsType: x,
                      priority: 1,
                    );
                  }
                  return FallbackAdItem();
                }),
              )
            : json["fallback_list"] != null
                ? List<FallbackAdItem>.from(
                    json["fallback_list"].map((x) {
                      if (x is Map<String, dynamic>) {
                        return FallbackAdItem.fromJson(x);
                      } else if (x is Map) {
                        return FallbackAdItem.fromJson(Map<String, dynamic>.from(x));
                      } else if (x is String) {
                        return FallbackAdItem(
                          enable: true,
                          adsType: x,
                          priority: 1,
                        );
                      }
                      return FallbackAdItem();
                    }),
                  )
                : null,
        enableInterstitial: json["enable_interstitial"] ??
            json["enableInterstitial"] ??
            json["is_interstitial_enabled"],
        enableAppOpen: json["enable_app_open"] ??
            json["enableAppOpen"] ??
            json["is_app_open_enabled"],
        enableNative: json["enable_native"] ??
            json["enableNative"] ??
            json["is_native_enabled"],
        fallbackEnabled: json["fallback_enabled"] ??
            json["fallbackEnabled"] ??
            json["enable_fallback"] ??
            json["is_fallback_enabled"],
        fallbackAppOpenEnabled: json["fallback_app_open_enabled"] ??
            json["fallbackAppOpenEnabled"] ??
            json["fallback_inter_to_app_open_enabled"] ??
            json["enable_fallback_app_open"],
        fallbackNativeEnabled: json["fallback_native_enabled"] ??
            json["fallbackNativeEnabled"] ??
            json["fallback_app_open_to_native_enabled"] ??
            json["enable_fallback_native"],
        publishers: json["publishers"],
        layout: json["layout"] ?? json["type"] ?? json["banner_type"],
        autoRefresh: json["auto_refresh"] ?? json["autoRefresh"] ?? json["native_auto_refresh"],
        refreshIntervalSec: json["refresh_interval_sec"] is num
            ? (json["refresh_interval_sec"] as num).toInt()
            : json["refresh_interval"] is num
                ? (json["refresh_interval"] as num).toInt()
                : json["native_refresh_interval"] is num
                    ? (json["native_refresh_interval"] as num).toInt()
                    : int.tryParse(json["refresh_interval_sec"]?.toString() ??
                        json["refresh_interval"]?.toString() ??
                        json["native_refresh_interval"]?.toString() ??
                        json["native_refresh_interval_sec"]?.toString() ??
                        ''),
        clickAfterRefreshEnable: json["click_after_refresh_enable"] ??
            json["click_after_refresh"] ??
            json["clickAfterRefreshEnable"],
        bannerType: json["banner_type"] ?? json["bannerType"] ?? json["layout"] ?? json["type"],
        useClickCounter: json["use_click_counter"] ?? json["useClickCounter"],
        supportedTypes: json["supported_types"] != null
            ? List<String>.from(
                json["supported_types"].map((x) => x.toString()))
            : null,
        adUnitId: json["ad_unit_id"] ?? json["adUnitId"],
        adUnitList: json["ad_unit_list"] != null
            ? List<String>.from(
                json["ad_unit_list"].map((x) => x.toString()))
            : json["adUnitList"] != null
                ? List<String>.from(
                    json["adUnitList"].map((x) => x.toString()))
                : null,
      );

  Map<String, dynamic> toJson() => {
        "adsName": adsName,
        "adsType": adsType,
        "enableAds": enableAds,
        "enable_ads_first_time": enableAdsFirstTime,
        "enable_ads_returning": enableAdsReturning,
        "primary_ad": primaryAd,
        "fallback_sequence": fallbackSequence,
        "fallbacks": fallbacks != null
            ? List<dynamic>.from(fallbacks!.map((x) => x.toJson()))
            : null,
        "enable_interstitial": enableInterstitial,
        "enable_app_open": enableAppOpen,
        "enable_native": enableNative,
        "fallback_enabled": fallbackEnabled,
        "fallback_app_open_enabled": fallbackAppOpenEnabled,
        "fallback_native_enabled": fallbackNativeEnabled,
        "publishers": publishers,
        "layout": layout,
        "auto_refresh": autoRefresh,
        "refresh_interval_sec": refreshIntervalSec,
        "click_after_refresh_enable": clickAfterRefreshEnable,
        "banner_type": bannerType,
        "use_click_counter": useClickCounter,
        "supported_types": supportedTypes,
        "ad_unit_id": adUnitId,
        "ad_unit_list": adUnitList,
      };
}

class FallbackAdItem {
  bool? enable;
  bool? enableFirstTime;
  bool? enableReturning;
  String? adsType;
  String? adUnitId;
  int? priority;
  String? layout;

  FallbackAdItem({
    this.enable,
    this.enableFirstTime,
    this.enableReturning,
    this.adsType,
    this.adUnitId,
    this.priority,
    this.layout,
  });

  /// Prefers first-time / returning flags; falls back to legacy [enable].
  bool resolveEnable({required bool isFirstTime}) {
    if (isFirstTime) {
      return enableFirstTime ?? enable ?? true;
    }
    return enableReturning ?? enable ?? true;
  }

  factory FallbackAdItem.fromJson(Map<String, dynamic> json) => FallbackAdItem(
        enable: json["enable"] ?? json["enable_ads"] ?? json["enabled"] ?? true,
        enableFirstTime: json["enable_first_time"] ??
            json["enableFirstTime"] ??
            json["enable_ads_first_time"],
        enableReturning: json["enable_returning"] ??
            json["enableReturning"] ??
            json["enable_ads_returning"],
        adsType: json["ads_type"] ?? json["adsType"] ?? json["type"] ?? json["ad_type"],
        adUnitId: json["ad_unit_id"] ?? json["adUnitId"] ?? json["id"],
        priority: json["priority"] is num
            ? (json["priority"] as num).toInt()
            : int.tryParse(json["priority"]?.toString() ?? '') ?? 1,
        layout: json["layout"] ?? json["banner_type"],
      );

  Map<String, dynamic> toJson() => {
        "enable": enable,
        "enable_first_time": enableFirstTime,
        "enable_returning": enableReturning,
        "ads_type": adsType,
        "ad_unit_id": adUnitId,
        "priority": priority,
        "layout": layout,
      };
}


