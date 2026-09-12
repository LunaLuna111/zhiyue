package com.zhiyue.client

import android.content.Context
import java.security.MessageDigest
import java.security.SecureRandom
import java.util.Locale
import java.util.UUID

/**
 * Privacy-preserving Android identity used by the Zhihu protocol adapter.
 *
 * Public hardware values describe one coherent Xiaomi 14 configuration. Every
 * identifier is synthetic and derived from a random per-install seed stored in
 * this app's private preferences. No Build, Settings.Secure, telephony, SIM,
 * network-operator, package inventory, /proc, or /sys value is consulted.
 */
internal class PrivacyDeviceProfile(context: Context) {
    private val identifiers = SyntheticIdentifiers(context.applicationContext)

    fun cloudIdDeviceInfo(): Map<String, Any> = mapOf(
        "ph_br" to BRAND,
        "ph_md" to MODEL,
        "ph_os" to OS_VERSION,
        "ph_sn" to identifiers.serial,
        "im_e" to identifiers.imeiPrimary,
        "im_s" to identifiers.imsiPrimary,
        "im_e2" to identifiers.imeiSecondary,
        "im_s2" to identifiers.imsiSecondary,
        "meid" to identifiers.meid,
        "oaid" to identifiers.oaid,
        // Huawei's secondary OAID provider is not part of this Xiaomi
        // profile. An empty value is skipped by the official form encoder.
        "additional_oaid" to "",
        "icid" to identifiers.iccid,
        "idfa" to identifiers.advertisingId,
        "mc_ad" to identifiers.macAddress,
        "device_token" to identifiers.deviceToken,
        "uuid" to identifiers.uuid,
        "mcc" to MOBILE_COUNTRY_CODE,
        "mnc" to MOBILE_NETWORK_CODE,
        "pvd_nm" to NETWORK_OPERATOR,
        "cp_tp" to CPU_TYPE,
        "cp_ct" to CPU_CORES,
        "cp_fq" to CPU_MAX_FREQUENCY_KHZ,
        "cp_us" to "27.0",
        "tt_mem" to TOTAL_MEMORY_MIB,
        "fr_mem" to FREE_MEMORY_MIB,
        "tt_st" to TOTAL_STORAGE_MIB,
        "fr_st" to FREE_STORAGE_MIB,
        "bt_ck" to 1,
        "nt_st" to 1,
        "d_n" to MODEL,
        // Deliberately neutral: never manufacture a location-like signal.
        "latitude" to 0.0,
        "longitude" to 0.0,
        "zx_zid" to "",
        "zx_aid" to "",
        "zx_tag" to "",
        "zx_expired" to 0,
        "android_id" to identifiers.androidId,
        "app_install_time" to SYNTHETIC_INSTALL_TIME_MILLIS,
    )

    fun appInfo(): String = listOf(
        "OS=Android",
        "Release=14",
        "Model=Xiaomi+14",
        "VersionName=11.4.0",
        "VersionCode=40408",
        "Product=com.zhihu.android",
        "Width=$DISPLAY_WIDTH",
        "Height=$DISPLAY_HEIGHT",
        "Installer=Market",
        "DeviceType=AndroidPhone",
        "Brand=Xiaomi",
    ).joinToString("&")

    // MS-ID is an opaque ShuZilm/SMID provider result, not a random device
    // identifier. Without that provider context, omission is the only
    // coherent privacy-preserving value.
    fun localMsId(): String = ""

    companion object {
        const val BRAND = "Xiaomi"
        const val MODEL = "Xiaomi 14"
        const val OS_VERSION = "Android 14"
        const val BUILD_ID = "UKQ1.230917.001"
        const val DISPLAY_WIDTH = 1200
        const val DISPLAY_HEIGHT = 2670
        const val CPU_TYPE = "Qualcomm Snapdragon 8 Gen 3"
        const val CPU_CORES = 8
        const val CPU_MAX_FREQUENCY_KHZ = "3300000"
        const val TOTAL_MEMORY_MIB = 12288
        const val FREE_MEMORY_MIB = 7168
        const val TOTAL_STORAGE_MIB = 524288
        const val FREE_STORAGE_MIB = 393216
        const val MOBILE_COUNTRY_CODE = "460"
        const val MOBILE_NETWORK_CODE = "00"
        const val NETWORK_OPERATOR = "China Mobile"
        const val SYNTHETIC_INSTALL_TIME_MILLIS = 1704067200000L
        const val APP_USER_AGENT =
            "com.zhihu.android/Futureve/11.4.0 Mozilla/5.0 (Linux; Android 14; " +
                "Xiaomi 14 Build/UKQ1.230917.001; wv) AppleWebKit/537.36 " +
                "(KHTML, like Gecko) Version/4.0 Chrome/57.0.1000.10 " +
                "Mobile Safari/537.36"
    }
}

private class SyntheticIdentifiers(context: Context) {
    private val seedHex = loadOrCreateSeed(context)

    val androidId = hex("android-id", 8)
    val serial = alphaNumeric("serial", 12).uppercase(Locale.US)
    val imeiPrimary = imei("imei-primary")
    val imeiSecondary = imei("imei-secondary")
    val imsiPrimary = "46000${digits("imsi-primary", 10)}"
    val imsiSecondary = "46000${digits("imsi-secondary", 10)}"
    val meid = "A10000${hex("meid", 4).uppercase(Locale.US)}"
    val oaid = uuid("oaid").lowercase(Locale.US)
    val advertisingId = uuid("advertising-id").uppercase(Locale.US)
    val macAddress = buildMacAddress()
    val iccid = "898600${digits("iccid", 14)}"
    val deviceToken = hex("device-token", 32)
    val uuid = uuid("device-uuid").lowercase(Locale.US)

    private fun digest(label: String): ByteArray = MessageDigest
        .getInstance("SHA-256")
        .digest("$label:$seedHex".toByteArray(Charsets.UTF_8))

    private fun hex(label: String, byteCount: Int): String = digest(label)
        .take(byteCount)
        .joinToString("") { byte -> "%02x".format(byte.toInt() and 0xff) }

    private fun digits(label: String, count: Int): String {
        val source = digest(label)
        return buildString(count) {
            repeat(count) { index ->
                append((source[index % source.size].toInt() and 0xff) % 10)
            }
        }
    }

    private fun alphaNumeric(label: String, count: Int): String {
        val alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        val source = digest(label)
        return buildString(count) {
            repeat(count) { index ->
                append(alphabet[(source[index % source.size].toInt() and 0xff) % alphabet.length])
            }
        }
    }

    private fun imei(label: String): String {
        // The test-style prefix is synthetic. The remaining digits are derived
        // locally and the final digit is a valid Luhn check digit; nothing is
        // read from a modem, SIM, subscriber account, or another real device.
        val body = "00499901${digits(label, 6)}"
        return body + luhnCheckDigit(body)
    }

    private fun luhnCheckDigit(body: String): Int {
        var sum = 0
        for (index in body.indices) {
            var value = body[index].digitToInt()
            if (index % 2 == 1) {
                value *= 2
                if (value > 9) value -= 9
            }
            sum += value
        }
        return (10 - (sum % 10)) % 10
    }

    private fun uuid(label: String): String {
        val bytes = digest(label).copyOfRange(0, 16)
        bytes[6] = ((bytes[6].toInt() and 0x0f) or 0x40).toByte()
        bytes[8] = ((bytes[8].toInt() and 0x3f) or 0x80).toByte()
        var mostSignificant = 0L
        var leastSignificant = 0L
        for (index in 0 until 8) {
            mostSignificant = (mostSignificant shl 8) or (bytes[index].toLong() and 0xff)
            leastSignificant = (leastSignificant shl 8) or (bytes[index + 8].toLong() and 0xff)
        }
        return UUID(mostSignificant, leastSignificant).toString()
    }

    private fun buildMacAddress(): String {
        val tail = digest("mac-address").take(5)
        return (listOf(0x02) + tail.map { it.toInt() and 0xff })
            .joinToString(":") { value -> "%02x".format(value) }
    }

    companion object {
        private const val PREFERENCES = "privacy_simulated_device_profile"
        private const val SEED_KEY = "install_seed_v1"
        private const val FALLBACK_SEED =
            "7f4bc5a86d139e027c41bf6695e8d4a33593c706a28dfcc159b5e47a83602fd1"
        private val SEED_PATTERN = Regex("^[0-9a-f]{64}$")

        private fun loadOrCreateSeed(context: Context): String {
            val fresh = generateSeed()
            return try {
                val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                val stored = preferences.getString(SEED_KEY, null)?.lowercase(Locale.US)
                if (stored != null && SEED_PATTERN.matches(stored)) {
                    stored
                } else {
                    preferences.edit().putString(SEED_KEY, fresh).commit()
                    fresh
                }
            } catch (_: Exception) {
                // Still return a process-stable synthetic seed. Nothing falls
                // back to a hardware, OS, account, SIM, or network value.
                fresh
            }
        }

        private fun generateSeed(): String = try {
            val bytes = ByteArray(32)
            SecureRandom().nextBytes(bytes)
            bytes.joinToString("") { byte -> "%02x".format(byte.toInt() and 0xff) }
        } catch (_: Exception) {
            FALLBACK_SEED
        }
    }
}
