package com.aibirthdayphoto.ai_birthday_photo

import android.app.ActivityManager
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Environment
import android.os.PowerManager
import android.os.StatFs
import android.telephony.TelephonyManager
import android.view.WindowManager

object DeviceInfoHelper {

    fun getDeviceInfo(context: Context): Map<String, Any> {
        val map = HashMap<String, Any>()

        try {
            // 1. CPU Cores
            val cpuCores = Runtime.getRuntime().availableProcessors().toLong()
            map["cpu_cores"] = cpuCores

            // 2 & 3. RAM (Total & Available in MB)
            val actManager = context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            actManager?.getMemoryInfo(memInfo)
            val ramTotalMb = memInfo.totalMem / (1024L * 1024L)
            val ramAvailMb = memInfo.availMem / (1024L * 1024L)
            map["ram_total_mb"] = ramTotalMb
            map["ram_avail_mb"] = ramAvailMb

            // 4. Storage Total in GB
            val statFs = StatFs(Environment.getDataDirectory().path)
            val storageTotalGb = statFs.totalBytes / (1024L * 1024L * 1024L)
            map["storage_total_gb"] = storageTotalGb

            // 5. Is Emulator (1 for emulator, 0 for physical)
            val isEmulator: Long = if (
                Build.FINGERPRINT.startsWith("generic") ||
                Build.FINGERPRINT.startsWith("unknown") ||
                Build.MODEL.contains("google_sdk", ignoreCase = true) ||
                Build.MODEL.contains("Emulator", ignoreCase = true) ||
                Build.MODEL.contains("Android SDK built for x86", ignoreCase = true) ||
                Build.MANUFACTURER.contains("Genymotion", ignoreCase = true) ||
                (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")) ||
                "google_sdk".equals(Build.PRODUCT, ignoreCase = true) ||
                Build.HARDWARE.contains("goldfish", ignoreCase = true) ||
                Build.HARDWARE.contains("ranchu", ignoreCase = true)
            ) 1L else 0L
            map["is_emulator"] = isEmulator

            // 6. Refresh Rate (Hz)
            val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
            val refreshRate: Long = try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    context.display?.refreshRate?.toLong() ?: 60L
                } else {
                    @Suppress("DEPRECATION")
                    windowManager?.defaultDisplay?.refreshRate?.toLong() ?: 60L
                }
            } catch (_: Exception) {
                60L
            }
            map["refresh_rate"] = refreshRate

            // 7. Power Save Mode (1 if Battery Saver ON, 0 if OFF)
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
            val powerSave: Long = if (powerManager?.isPowerSaveMode == true) 1L else 0L
            map["power_save"] = powerSave

            // 8 & 9. Network & Network Type
            val connManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            val activeNetwork = connManager?.activeNetwork
            val caps = connManager?.getNetworkCapabilities(activeNetwork)

            val network: String
            val networkType: String

            when {
                caps == null -> {
                    network = "none"
                    networkType = "none"
                }
                caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
                caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> {
                    network = "wifi"
                    networkType = "wifi"
                }
                caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> {
                    network = "mobile"
                    networkType = resolveCellularType(context)
                }
                else -> {
                    network = "none"
                    networkType = "none"
                }
            }
            map["network"] = network
            map["network_type"] = networkType

        } catch (e: Exception) {
            map.putIfAbsent("cpu_cores", Runtime.getRuntime().availableProcessors().toLong())
            map.putIfAbsent("ram_total_mb", 0L)
            map.putIfAbsent("ram_avail_mb", 0L)
            map.putIfAbsent("storage_total_gb", 0L)
            map.putIfAbsent("is_emulator", 0L)
            map.putIfAbsent("refresh_rate", 60L)
            map.putIfAbsent("power_save", 0L)
            map.putIfAbsent("network", "none")
            map.putIfAbsent("network_type", "none")
        }

        return map
    }

    private fun resolveCellularType(context: Context): String {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            ?: return "mobile"
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                when (telephonyManager.dataNetworkType) {
                    TelephonyManager.NETWORK_TYPE_GPRS,
                    TelephonyManager.NETWORK_TYPE_EDGE,
                    TelephonyManager.NETWORK_TYPE_CDMA,
                    TelephonyManager.NETWORK_TYPE_1xRTT,
                    TelephonyManager.NETWORK_TYPE_IDEN,
                    TelephonyManager.NETWORK_TYPE_GSM -> "2g"

                    TelephonyManager.NETWORK_TYPE_UMTS,
                    TelephonyManager.NETWORK_TYPE_EVDO_0,
                    TelephonyManager.NETWORK_TYPE_EVDO_A,
                    TelephonyManager.NETWORK_TYPE_HSDPA,
                    TelephonyManager.NETWORK_TYPE_HSUPA,
                    TelephonyManager.NETWORK_TYPE_HSPA,
                    TelephonyManager.NETWORK_TYPE_EVDO_B,
                    TelephonyManager.NETWORK_TYPE_EHRPD,
                    TelephonyManager.NETWORK_TYPE_HSPAP,
                    TelephonyManager.NETWORK_TYPE_TD_SCDMA -> "3g"

                    TelephonyManager.NETWORK_TYPE_LTE,
                    TelephonyManager.NETWORK_TYPE_IWLAN -> "4g"

                    TelephonyManager.NETWORK_TYPE_NR -> "5g"

                    else -> "mobile"
                }
            } else {
                @Suppress("DEPRECATION")
                when (telephonyManager.networkType) {
                    TelephonyManager.NETWORK_TYPE_LTE -> "4g"
                    TelephonyManager.NETWORK_TYPE_NR -> "5g"
                    else -> "mobile"
                }
            }
        } catch (_: SecurityException) {
            "mobile"
        } catch (_: Exception) {
            "mobile"
        }
    }
}

