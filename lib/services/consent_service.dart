import 'dart:async';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'remote_config_service.dart';
import 'ad_service/ad_services.dart';

import 'app_tracking_service.dart';

class ConsentService {
  static bool _canRequestAds = false;
  static bool _isConsentHandled = false;
  static bool _useNonPersonalizedAds = false;
  static ConsentStatus? _currentConsentStatus;
  static Future<void>? _gdprInFlight;

  static bool _isMobileAdsInitialized = false;
  static Future<void>? _mobileAdsInitFuture;

  /// Request App Tracking Transparency (ATT) authorization on iOS before ads initialization
  static Future<TrackingStatus> requestATT() async {
    return await AppTrackingService.requestTrackingPermission();
  }

  /// Check if ads can be requested based on consent status
  static bool canRequestAds() {
    return _canRequestAds && _isConsentHandled;
  }

  /// Check if non-personalized ads should be used
  static bool shouldUseNonPersonalizedAds() {
    return _useNonPersonalizedAds;
  }

  /// Explicitly initialize Mobile Ads SDK and await its completion
  static Future<void> initializeMobileAds() async {
    if (GetPlatform.isIOS) return;
    if (_isMobileAdsInitialized) return;
    if (_mobileAdsInitFuture != null) {
      await _mobileAdsInitFuture!;
      return;
    }
    _mobileAdsInitFuture = _initMobileAdsInternal();
    try {
      await _mobileAdsInitFuture!;
    } finally {
      _mobileAdsInitFuture = null;
    }
  }

  static Future<void> _initMobileAdsInternal() async {
    if (_isMobileAdsInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isMobileAdsInitialized = true;
      ADService.isSdkInitialized = true;
      if (kDebugMode) {
        debugPrint('[ConsentService] MobileAds initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConsentService] Error initializing MobileAds: $e');
      }
    }
  }

  /// Handle GDPR / UMP consent flow
  /// Should be called before any ad initialization
  static Future<void> handleGDPR() async {
    if (GetPlatform.isIOS) return;
    if (_isConsentHandled) {
      if (kDebugMode) {
        debugPrint('[ConsentService] Consent already handled, skipping');
      }
      return;
    }
    if (_gdprInFlight != null) {
      await _gdprInFlight;
      return;
    }

    _gdprInFlight = _handleGDPRInternal();
    try {
      await _gdprInFlight;
    } finally {
      _gdprInFlight = null;
    }
  }

  static Future<void> _handleGDPRInternal() async {
    final config = RemoteConfigService.getFirebaseAdConfig();
    if (config.appLiveStatus == false ||
        config.showAds == false ||
        ADService.isSubscribed()) {
      if (kDebugMode) {
        debugPrint(
          '[ConsentService] Ads disabled (show_ads: false) or user subscribed, skipping GDPR consent form',
        );
      }
      _canRequestAds = false;
      _isConsentHandled = true;
      await initializeMobileAds();
      return;
    }

    try {
      await _requestConsentInfoUpdate();
      await initializeMobileAds();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConsentService] Error handling consent: $e');
      }
      _canRequestAds = true;
      _useNonPersonalizedAds = false;
      _isConsentHandled = true;
      await initializeMobileAds();
    }
  }

  static Future<void> _requestConsentInfoUpdate() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (kDebugMode) {
          debugPrint('[ConsentService] Consent info update successful');
        }
        _currentConsentStatus =
            await ConsentInformation.instance.getConsentStatus();
        if (kDebugMode) {
          debugPrint('[ConsentService] Consent status: $_currentConsentStatus');
        }

        final bool isFormAvailable =
            await ConsentInformation.instance.isConsentFormAvailable();
        if (!isFormAvailable) {
          if (kDebugMode) {
            debugPrint(
              '[ConsentService] Consent form not available for this AdMob App ID, skipping',
            );
          }
          _canRequestAds = true;
          _useNonPersonalizedAds = false;
          _isConsentHandled = true;
          if (!completer.isCompleted) completer.complete();
          return;
        }

        await _showConsentFormIfNeeded();
        if (!completer.isCompleted) completer.complete();
      },
      (FormError error) {
        if (kDebugMode) {
          debugPrint(
              '[ConsentService] Consent info update failed: ${error.message}');
        }
        _canRequestAds = true;
        _useNonPersonalizedAds = false;
        _isConsentHandled = true;
        if (!completer.isCompleted) completer.complete();
      },
    );

    // Safety timeout: Never let the app hang on a white screen if UMP freezes
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        if (kDebugMode) {
          debugPrint(
            '[ConsentService] Consent update timeout (10s), proceeding gracefully',
          );
        }
        _canRequestAds = true;
        _useNonPersonalizedAds = false;
        _isConsentHandled = true;
      },
    );
  }

  static Future<void> _showConsentFormIfNeeded() async {
    if (_isConsentHandled) return;

    final completer = Completer<void>();
    _isConsentHandled = true;

    ConsentForm.loadAndShowConsentFormIfRequired((formError) {
      if (formError == null) {
        if (kDebugMode) {
          debugPrint('[ConsentService] Consent form choice recorded');
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              '[ConsentService] Consent form error/not required: ${formError.message}');
        }
      }
      _canRequestAds = true;
      _useNonPersonalizedAds = !_canShowPersonalizedAds();
      if (!completer.isCompleted) completer.complete();
    });

    // Safety timeout: If consent form presentation hangs or loads a blank webview
    await completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        if (kDebugMode) {
          debugPrint(
            '[ConsentService] Consent form presentation timeout (8s), unblocking UI',
          );
        }
        _canRequestAds = true;
        _useNonPersonalizedAds = false;
      },
    );
  }

  static bool _canShowPersonalizedAds() {
    try {
      return _currentConsentStatus == ConsentStatus.obtained;
    } catch (e) {
      return false;
    }
  }

  static AdRequest getAdRequest() {
    if (_useNonPersonalizedAds) {
      return const AdRequest(extras: {'npa': '1'});
    } else {
      return const AdRequest();
    }
  }
}
