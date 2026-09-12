package com.zhiyue.client

import android.util.Base64
import java.math.BigInteger
import java.security.KeyFactory
import java.security.SecureRandom
import java.security.spec.RSAPublicKeySpec
import javax.crypto.Cipher

/** Generates the per-request Salt key exactly through Android's RSA provider. */
object SaltManuscriptKeyGenerator {
    private const val ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    private const val MODULUS =
        "d04f1c10920d4cc202e85268bf9841c132ed478ad062b069725b49a9fa5dc077" +
            "9cd7eb981b1d8c04eae45023d2b87433825c84372d2ad1728e4dc1d1db97e301" +
            "3c554e97ec79ac73394fca8feb6a4545ffb809fc78fa7eeddb30ada6bceca314" +
            "6dbf68aab4eaf043d410a1d779161531f4bd62554aab2a02819470399ae42add"

    private val random = SecureRandom()

    fun generate(fixedRawKey: String? = null): Map<String, String> {
        val rawKey = fixedRawKey ?: buildString(16) {
            repeat(16) { append(ALPHABET[random.nextInt(ALPHABET.length)]) }
        }
        require(rawKey.length == 16 && rawKey.all(ALPHABET::contains)) {
            "rawKey must contain exactly 16 official alphabet characters"
        }
        val publicKey = KeyFactory.getInstance("RSA").generatePublic(
            RSAPublicKeySpec(BigInteger(MODULUS, 16), BigInteger.valueOf(65537L)),
        )
        val cipher = Cipher.getInstance("RSA")
        cipher.init(Cipher.ENCRYPT_MODE, publicKey, random)
        val encrypted = cipher.doFinal(rawKey.toByteArray(Charsets.UTF_8))
        return mapOf(
            "rawKey" to rawKey,
            "transKey" to Base64.encodeToString(encrypted, Base64.NO_WRAP),
        )
    }
}
