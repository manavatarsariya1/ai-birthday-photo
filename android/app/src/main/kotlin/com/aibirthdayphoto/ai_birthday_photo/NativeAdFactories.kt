package com.aibirthdayphoto.ai_birthday_photo

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.NativeAdFactory

private fun bindIconView(
    nativeAdView: NativeAdView,
    nativeAd: NativeAd,
    iconViewId: Int = R.id.ad_icon,
    textContainerId: Int = R.id.ad_text_container
) {
    val iconView = nativeAdView.findViewById<ImageView?>(iconViewId) ?: return
    val parentCard = iconView.parent as? View
    val textContainer = nativeAdView.findViewById<View?>(textContainerId)

    if (nativeAd.icon?.drawable != null) {
        iconView.setImageDrawable(nativeAd.icon?.drawable)
        iconView.visibility = View.VISIBLE
        parentCard?.visibility = View.VISIBLE
        nativeAdView.iconView = iconView
    } else {
        iconView.setImageDrawable(null)
        iconView.visibility = View.GONE
        parentCard?.visibility = View.GONE
        nativeAdView.iconView = null
        (textContainer?.layoutParams as? ViewGroup.MarginLayoutParams)?.let { lp ->
            lp.marginStart = 0
            textContainer.layoutParams = lp
        }
    }
}

// 1. Small Native Ad Factory (listTileNativeAd)
class NativeAdFactorySmall(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val ctaView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)

        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        nativeAdView.bodyView = bodyView

        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = View.VISIBLE
        } else {
            ctaView.visibility = View.GONE
        }
        nativeAdView.callToActionView = ctaView

        bindIconView(nativeAdView, nativeAd)

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}

// 2. Medium Native Ad Factory (nativeAd)
class NativeAdFactoryMedium(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.medium_native_ad, null) as NativeAdView

        val mediaView = nativeAdView.findViewById<MediaView>(R.id.ad_media)
        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val ctaView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)

        nativeAdView.mediaView = mediaView

        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        nativeAdView.bodyView = bodyView

        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = View.VISIBLE
        } else {
            ctaView.visibility = View.GONE
        }
        nativeAdView.callToActionView = ctaView

        bindIconView(nativeAdView, nativeAd)

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}

// 3. Large Native Ad Factory (nativeAdMain)
class NativeAdFactoryLarge(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.large_native_ad, null) as NativeAdView

        val mediaView = nativeAdView.findViewById<MediaView>(R.id.ad_media)
        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val ctaView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)

        nativeAdView.mediaView = mediaView

        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        nativeAdView.bodyView = bodyView

        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = View.VISIBLE
        } else {
            ctaView.visibility = View.GONE
        }
        nativeAdView.callToActionView = ctaView

        bindIconView(nativeAdView, nativeAd)

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}

// 4. Media Square Native Ad Factory (nativeAdMediaSquare)
class NativeAdFactoryMediaSquare(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.media_square_native_ad, null) as NativeAdView

        val mediaView = nativeAdView.findViewById<MediaView>(R.id.ad_media)
        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val ctaView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)

        nativeAdView.mediaView = mediaView

        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        val bodyText = if (!nativeAd.body.isNullOrEmpty()) {
            nativeAd.body
        } else {
            nativeAd.advertiser ?: nativeAd.store ?: ""
        }
        if (!bodyText.isNullOrEmpty()) {
            bodyView.text = bodyText
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        nativeAdView.bodyView = bodyView

        ctaView.text = nativeAd.callToAction ?: "INSTALL"
        nativeAdView.callToActionView = ctaView

        bindIconView(nativeAdView, nativeAd, textContainerId = R.id.ad_badge)

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}

// 5. Exit dialog Native Ad Factory (nativeAdExit)
class NativeAdFactoryExit(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.exit_native_ad, null) as NativeAdView

        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val ctaView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)
        nativeAdView.adChoicesView = nativeAdView.findViewById(R.id.ad_choices)

        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        val bodyText = if (!nativeAd.body.isNullOrEmpty()) {
            nativeAd.body
        } else {
            nativeAd.advertiser ?: nativeAd.store ?: ""
        }
        if (!bodyText.isNullOrEmpty()) {
            bodyView.text = bodyText
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        nativeAdView.bodyView = bodyView

        ctaView.text = nativeAd.callToAction ?: "Install"
        nativeAdView.callToActionView = ctaView

        bindIconView(nativeAdView, nativeAd)

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}

// 6. Splash full native fallback (splashFullNativeAd)
class NativeAdFactorySplashFull(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.splash_full_native_ad, null) as NativeAdView

        val mediaView = nativeAdView.findViewById<MediaView>(R.id.ad_media)
        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val ctaView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)

        nativeAdView.mediaView = mediaView

        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        if (!nativeAd.body.isNullOrEmpty()) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        nativeAdView.bodyView = bodyView

        ctaView.text = nativeAd.callToAction ?: "INSTALL"
        nativeAdView.callToActionView = ctaView

        bindIconView(nativeAdView, nativeAd)

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}

// 7. Language screen large media native (nativeAdLanguageLargeMedia)
class NativeAdFactoryLanguageLargeMedia(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.language_large_media_native_ad, null) as NativeAdView

        val mediaView = nativeAdView.findViewById<MediaView>(R.id.ad_media)
        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val ctaView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)

        nativeAdView.mediaView = mediaView

        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        val bodyText = if (!nativeAd.body.isNullOrEmpty()) {
            nativeAd.body
        } else {
            nativeAd.advertiser ?: nativeAd.store ?: ""
        }
        if (!bodyText.isNullOrEmpty()) {
            bodyView.text = bodyText
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        nativeAdView.bodyView = bodyView

        ctaView.text = nativeAd.callToAction ?: "Install"
        nativeAdView.callToActionView = ctaView

        bindIconView(nativeAdView, nativeAd)

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}
