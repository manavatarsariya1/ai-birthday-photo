package com.aibirthdayphoto.ai_birthday_photo

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    private var shortcutChannel: MethodChannel? = null
    private var pendingShortcut: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingShortcut = intent?.getStringExtra("shortcut_type")
        if (!isTaskRoot && intent?.hasCategory(Intent.CATEGORY_LAUNCHER) == true && Intent.ACTION_MAIN == intent?.action) {
            finish()
            return
        }
        // Check install referrer on launch
        GoogleAdsReferrerHelper.checkReferrer(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val shortcut = intent.getStringExtra("shortcut_type")
        if (!shortcut.isNullOrEmpty()) {
            shortcutChannel?.invokeMethod("onShortcutTapped", shortcut)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        shortcutChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.aibirthdayphoto/shortcuts"
        )
        shortcutChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialShortcut") {
                result.success(pendingShortcut)
                pendingShortcut = null
            } else {
                result.notImplemented()
            }
        }

        val pkgName = context.packageName

        // 1. Register Referrer Channels (both package-specific and generic)
        val referrerChannels = listOf("$pkgName/referrer", "flutter_getx_project_structure/referrer")
        for (channelName in referrerChannels) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
                when (call.method) {
                    "isFromGoogleAds" -> {
                        result.success(GoogleAdsReferrerHelper.isFromGoogleAds(context))
                    }
                    "getAttributionType" -> {
                        result.success(GoogleAdsReferrerHelper.getAttributionType(context))
                    }
                    "checkReferrer" -> {
                        GoogleAdsReferrerHelper.checkReferrer(context) { type ->
                            result.success(type != GoogleAdsReferrerHelper.TYPE_ORGANIC)
                        }
                    }
                    "checkAttributionType" -> {
                        GoogleAdsReferrerHelper.checkReferrer(context) { type ->
                            result.success(type)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }

        // 2. Register Device Info Channels (both package-specific and generic)
        val deviceInfoChannels = listOf("$pkgName/device_info", "flutter_getx_project_structure/device_info")
        for (channelName in deviceInfoChannels) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceInfo" -> {
                        result.success(DeviceInfoHelper.getDeviceInfo(context))
                    }
                    else -> result.notImplemented()
                }
            }
        }

        // 3. Register All Google Mobile Ads Native Ad Factories
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeAd",
            NativeAdFactoryMedium(context)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "listTileNativeAd",
            NativeAdFactorySmall(context)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeAdMain",
            NativeAdFactoryLarge(context)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeAdMediaSquare",
            NativeAdFactoryMediaSquare(context)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeAdExit",
            NativeAdFactoryExit(context)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "splashFullNativeAd",
            NativeAdFactorySplashFull(context)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeAdSplashFull",
            NativeAdFactorySplashFull(context)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeAdLanguageLargeMedia",
            NativeAdFactoryLanguageLargeMedia(context)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        // Unregister Google Mobile Ads native ad factories
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTileNativeAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeAdMain")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeAdMediaSquare")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeAdExit")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "splashFullNativeAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeAdSplashFull")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeAdLanguageLargeMedia")

        super.cleanUpFlutterEngine(flutterEngine)
    }
}
