package com.aibirthdayphoto.ai_birthday_photo

import android.content.Context
import android.content.SharedPreferences
import android.os.RemoteException
import android.util.Log
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.android.installreferrer.api.ReferrerDetails
import java.net.URLDecoder
import java.util.concurrent.atomic.AtomicBoolean

object GoogleAdsReferrerHelper {

    private const val TAG = "GoogleAdsReferrer"
    private const val PREF_NAME = "referrer_prefs"
    private const val KEY_IS_FROM_GOOGLE_ADS = "is_from_google_ads"
    private const val KEY_ATTRIBUTION_TYPE = "attribution_type"
    private const val KEY_REFERRER_CHECKED = "referrer_checked"

    const val TYPE_ORGANIC = "organic"
    const val TYPE_META = "meta"
    const val TYPE_MARKETING = "marketing"

    /**
     * Testing Override:
     * - null  -> Normal / Real Referrer logic
     * - "meta" -> Forces Meta Marketing Flow
     * - "marketing" -> Forces General Marketing Flow
     * - "organic" -> Forces Organic Flow
     */
    var TEST_OVERRIDE_TYPE: String? = null

    /**
     * Returns true if install was attributed to a marketing campaign
     * (Google Ads or Facebook / Meta Ads).
     */
    fun isFromGoogleAds(context: Context): Boolean {
        TEST_OVERRIDE_TYPE?.let { return it != TYPE_ORGANIC }
        val prefs = getPrefs(context)
        return prefs.getBoolean(KEY_IS_FROM_GOOGLE_ADS, false)
    }

    /**
     * Returns attribution type: "meta", "marketing", or "organic".
     */
    fun getAttributionType(context: Context): String {
        TEST_OVERRIDE_TYPE?.let { return it }
        val prefs = getPrefs(context)
        return prefs.getString(KEY_ATTRIBUTION_TYPE, TYPE_ORGANIC) ?: TYPE_ORGANIC
    }

    /**
     * Call this once on first app launch to check referrer.
     * [onResult] returns attribution type: "meta", "marketing", or "organic".
     */
    fun checkReferrer(context: Context, onResult: ((String) -> Unit)? = null) {
        TEST_OVERRIDE_TYPE?.let {
            onResult?.invoke(it)
            return
        }

        val prefs = getPrefs(context)

        // Only check once after install
        if (prefs.getBoolean(KEY_REFERRER_CHECKED, false)) {
            val savedType = prefs.getString(KEY_ATTRIBUTION_TYPE, TYPE_ORGANIC) ?: TYPE_ORGANIC
            onResult?.invoke(savedType)
            return
        }

        val replied = AtomicBoolean(false)
        fun reply(value: String) {
            if (replied.compareAndSet(false, true)) {
                onResult?.invoke(value)
            }
        }

        val referrerClient: InstallReferrerClient
        try {
            referrerClient = InstallReferrerClient.newBuilder(context).build()
        } catch (e: Exception) {
            Log.e(TAG, "Unable to create InstallReferrerClient: ${e.message}")
            reply(TYPE_ORGANIC)
            return
        }

        try {
            referrerClient.startConnection(object : InstallReferrerStateListener {
                override fun onInstallReferrerSetupFinished(responseCode: Int) {
                    when (responseCode) {
                        InstallReferrerClient.InstallReferrerResponse.OK -> {
                            try {
                                val details: ReferrerDetails = referrerClient.installReferrer
                                val referrerUrl: String = details.installReferrer ?: ""
                                val attributionType = resolveAttributionType(referrerUrl)
                                val isFromAds = attributionType != TYPE_ORGANIC

                                Log.d(TAG, "Referrer URL: $referrerUrl")
                                Log.d(TAG, "Attribution type: $attributionType (isFromAds: $isFromAds)")

                                prefs.edit()
                                    .putString(KEY_ATTRIBUTION_TYPE, attributionType)
                                    .putBoolean(KEY_IS_FROM_GOOGLE_ADS, isFromAds)
                                    .putBoolean(KEY_REFERRER_CHECKED, true)
                                    .apply()

                                reply(attributionType)
                            } catch (e: RemoteException) {
                                Log.e(TAG, "RemoteException: ${e.message}")
                                reply(TYPE_ORGANIC)
                            } catch (e: Exception) {
                                Log.e(TAG, "Exception: ${e.message}")
                                reply(TYPE_ORGANIC)
                            }
                        }

                        else -> {
                            Log.w(TAG, "Install Referrer unavailable (responseCode=$responseCode)")
                            reply(TYPE_ORGANIC)
                        }
                    }

                    try {
                        referrerClient.endConnection()
                    } catch (_: Exception) {
                    }
                }

                override fun onInstallReferrerServiceDisconnected() {
                    Log.w(TAG, "Service disconnected")
                    reply(TYPE_ORGANIC)
                }
            })
        } catch (e: Exception) {
            Log.e(TAG, "startConnection failed: ${e.message}")
            reply(TYPE_ORGANIC)
        }
    }

    private val GOOGLE_SOURCES = setOf(
        "google_ads", "googleads", "google-ads", "adwords", "googleadwords_int",
    )
    private val META_SOURCES = setOf(
        "facebook", "fb", "meta", "instagram", "ig", "an",
        "apps.facebook.com", "facebook_ads", "fb_ads", "meta_ads",
    )
    private val PAID_MEDIUMS = setOf(
        "cpc", "paid", "ppc", "paid_social", "paidsocial", "cpi", "display",
    )

    /**
     * Resolves attribution: "meta", "marketing", or "organic".
     */
    fun resolveAttributionType(referrerUrl: String): String {
        if (referrerUrl.isBlank()) return TYPE_ORGANIC
        val ref = try {
            URLDecoder.decode(referrerUrl, "UTF-8").lowercase()
        } catch (_: Exception) {
            referrerUrl.lowercase()
        }

        val params = ref.split("&")
            .mapNotNull { pair ->
                val idx = pair.indexOf('=')
                if (idx > 0) pair.substring(0, idx).trim() to pair.substring(idx + 1).trim() else null
            }
            .toMap()

        val source = params["utm_source"].orEmpty()
        val medium = params["utm_medium"].orEmpty()
        val hasGclid = params.containsKey("gclid") || params.containsKey("gbraid") ||
            params.containsKey("wbraid")
        val hasFbclid = params.containsKey("fbclid")

        // 1. Meta / Facebook click ID
        if (hasFbclid) return TYPE_META

        // 2. Explicit organic Play Store install
        if (medium == "organic" || source == "google-play") return TYPE_ORGANIC

        // 3. Meta Ads check by source / url
        val isMetaAds = source in META_SOURCES ||
            source.contains("facebook") ||
            source.contains("instagram") ||
            ref.contains("apps.facebook.com")

        if (isMetaAds) return TYPE_META

        // 4. Other marketing (Google Ads, UTM paid campaigns, gclid)
        val isGoogleAds = hasGclid || source in GOOGLE_SOURCES ||
            (source == "google" && medium in PAID_MEDIUMS)
        val isPaidMedium = medium in PAID_MEDIUMS

        if (isGoogleAds || isPaidMedium) return TYPE_MARKETING

        return TYPE_ORGANIC
    }

    /**
     * Marketing = Google Ads OR Facebook / Meta Ads.
     * Organic Play Store installs (utm_medium=organic) stay organic.
     */
    fun isMarketingReferrer(referrerUrl: String): Boolean {
        return resolveAttributionType(referrerUrl) != TYPE_ORGANIC
    }

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }
}
