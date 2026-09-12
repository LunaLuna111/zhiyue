package com.zhiyue.client

import android.content.Context
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileInputStream
import java.security.MessageDigest

internal class UpdatePackageManager(private val context: Context) {
    @Synchronized
    fun appVersion(): Map<String, Any> {
        val info = context.packageManager.getPackageInfo(context.packageName, 0)
        val versionCode = packageVersionCode(info)
        migrateLegacyVerifiedUpdates()
        cleanupUpdateCache(versionCode)
        return mapOf(
            "versionName" to (info.versionName ?: BuildConfig.VERSION_NAME),
            "versionCode" to versionCode,
        )
    }

    fun canRequestPackageInstalls(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.O || context.packageManager.canRequestPackageInstalls()

    fun openInstallPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val intent = Intent(
            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
            Uri.parse("package:${context.packageName}"),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    @Synchronized
    fun hasCachedUpdate(arguments: Map<*, *>): Boolean {
        val expectedPlainSize = requiredLong(arguments, "plainSize")
        val expectedPlainHash = checkedHash(requiredString(arguments, "plainSha256"))
        val versionCode = requiredLong(arguments, "versionCode")
        require(expectedPlainSize in 1..MAX_PACKAGE_BYTES) { "invalid_plain_size" }
        require(versionCode in 1..MAX_VERSION_CODE) { "invalid_version_code" }
        val output = verifiedUpdateFile(versionCode, expectedPlainHash)
        // This method is called during the update check on Flutter's main
        // isolate. Only inspect the atomic file's size here; the click path
        // performs the complete hash/APK/signature validation off the UI
        // thread before opening the installer.
        return output.isFile && output.length() == expectedPlainSize
    }

    @Synchronized
    fun installCachedUpdate(arguments: Map<*, *>): Boolean {
        check(canRequestPackageInstalls()) { "install_permission_required" }
        val expectedPlainSize = requiredLong(arguments, "plainSize")
        val expectedPlainHash = checkedHash(requiredString(arguments, "plainSha256"))
        val versionCode = requiredLong(arguments, "versionCode")
        require(expectedPlainSize in 1..MAX_PACKAGE_BYTES) { "invalid_plain_size" }
        require(versionCode in 1..MAX_VERSION_CODE) { "invalid_version_code" }
        val output = verifiedUpdateFile(versionCode, expectedPlainHash)
        if (!validateCachedUpdate(output, expectedPlainSize, expectedPlainHash, versionCode)) {
            return false
        }
        openInstaller(output)
        return true
    }

    @Synchronized
    fun verifyAndInstall(arguments: Map<*, *>): Map<String, Any> {
        check(canRequestPackageInstalls()) { "install_permission_required" }
        val downloadedFile = checkedDownloadedFile(requiredString(arguments, "downloadedPath"))
        val expectedPlainSize = requiredLong(arguments, "plainSize")
        val expectedPlainHash = checkedHash(requiredString(arguments, "plainSha256"))
        val versionCode = requiredLong(arguments, "versionCode")
        require(expectedPlainSize in 1..MAX_PACKAGE_BYTES) { "invalid_plain_size" }
        require(versionCode in 1..MAX_VERSION_CODE) { "invalid_version_code" }
        require(downloadedFile.length() == expectedPlainSize) { "plain_size_mismatch" }
        require(hashFile(downloadedFile) == expectedPlainHash) { "plain_hash_mismatch" }

        val updateDirectory = verifiedUpdateDirectory()
        check(updateDirectory.mkdirs() || updateDirectory.isDirectory) { "update_directory_unavailable" }
        val output = verifiedUpdateFile(versionCode, expectedPlainHash)
        val partial = File(updateDirectory, ".zhiyue-$versionCode.apk.partial")
        partial.delete()
        try {
            downloadedFile.inputStream().use { input ->
                partial.outputStream().use { output -> input.copyTo(output, 64 * 1024) }
            }
            validateApk(partial, versionCode)
            if (output.exists() && !output.delete()) error("stale_update_cleanup_failed")
            check(partial.renameTo(output)) { "verified_update_move_failed" }
            cleanupVerifiedUpdatesExcept(output)
            openInstaller(output)
            return mapOf("installerOpened" to true, "versionCode" to versionCode)
        } catch (error: Exception) {
            partial.delete()
            throw error
        }
    }

    private fun checkedDownloadedFile(rawPath: String): File {
        val file = File(rawPath).canonicalFile
        val cache = context.cacheDir.canonicalFile
        require(file.path.startsWith(cache.path + File.separator) && file.isFile) {
            "invalid_downloaded_path"
        }
        return file
    }

    private fun verifiedUpdateFile(versionCode: Long, plainHash: String): File =
        File(verifiedUpdateDirectory(), "zhiyue-$versionCode-$plainHash.apk")

    private fun verifiedUpdateDirectory(): File =
        File(context.filesDir, "verified-updates")

    /** Move packages created by versions before the persistent cache was introduced. */
    private fun migrateLegacyVerifiedUpdates() {
        val legacy = File(context.cacheDir, "verified-updates")
        val target = verifiedUpdateDirectory()
        val candidates = legacy.listFiles() ?: return
        if (!target.mkdirs() && !target.isDirectory) return
        candidates.forEach { candidate ->
            if (!candidate.isFile ||
                (!candidate.name.endsWith(".apk") && !candidate.name.endsWith(".partial"))
            ) {
                return@forEach
            }
            val destination = File(target, candidate.name)
            if (!destination.exists() && candidate.renameTo(destination)) return@forEach
            candidate.delete()
        }
    }

    private fun validateCachedUpdate(
        output: File,
        expectedPlainSize: Long,
        expectedPlainHash: String,
        versionCode: Long,
    ): Boolean {
        if (!output.isFile) return false
        return try {
            require(output.length() == expectedPlainSize) { "plain_size_mismatch" }
            require(hashFile(output) == expectedPlainHash) { "plain_hash_mismatch" }
            validateApk(output, versionCode)
            true
        } catch (_: Exception) {
            // A partial or stale cache must never block a fresh, verified download.
            output.delete()
            false
        }
    }

    private fun cleanupUpdateCache(installedVersionCode: Long) {
        val directory = verifiedUpdateDirectory()
        directory.listFiles()?.forEach { candidate ->
            if (!candidate.isFile) return@forEach
            if (candidate.name.endsWith(".partial")) {
                candidate.delete()
                return@forEach
            }
            val cachedVersion = VERIFIED_APK_PATTERN.matchEntire(candidate.name)
                ?.groupValues
                ?.getOrNull(1)
                ?.toLongOrNull()
            if (candidate.name.endsWith(".apk") &&
                (cachedVersion == null || cachedVersion <= installedVersionCode)
            ) {
                candidate.delete()
            }
        }
    }

    private fun cleanupVerifiedUpdatesExcept(keep: File) {
        keep.parentFile?.listFiles()?.forEach { candidate ->
            if (candidate.isFile && candidate != keep &&
                (candidate.name.endsWith(".apk") || candidate.name.endsWith(".partial"))
            ) {
                candidate.delete()
            }
        }
    }

    private fun validateApk(apk: File, expectedVersionCode: Long) {
        val archive = packageArchiveInfo(apk) ?: throw IllegalArgumentException("invalid_apk")
        require(archive.packageName == context.packageName) { "apk_package_mismatch" }
        require(packageVersionCode(archive) == expectedVersionCode) { "apk_version_mismatch" }
        val installed = installedPackageInfo()
        require(signingCertificateDigests(archive) == signingCertificateDigests(installed)) {
            "apk_signing_certificate_mismatch"
        }
    }

    @Suppress("DEPRECATION")
    private fun packageArchiveInfo(apk: File): PackageInfo? = if (Build.VERSION.SDK_INT >= 33) {
        context.packageManager.getPackageArchiveInfo(
            apk.path,
            PackageManager.PackageInfoFlags.of(PackageManager.GET_SIGNING_CERTIFICATES.toLong()),
        )
    } else {
        context.packageManager.getPackageArchiveInfo(apk.path, PackageManager.GET_SIGNING_CERTIFICATES)
    }

    @Suppress("DEPRECATION")
    private fun installedPackageInfo(): PackageInfo = if (Build.VERSION.SDK_INT >= 33) {
        context.packageManager.getPackageInfo(
            context.packageName,
            PackageManager.PackageInfoFlags.of(PackageManager.GET_SIGNING_CERTIFICATES.toLong()),
        )
    } else {
        context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_SIGNING_CERTIFICATES)
    }

    @Suppress("DEPRECATION")
    private fun signingCertificateDigests(info: PackageInfo): Set<String> {
        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val signingInfo = info.signingInfo ?: return emptySet()
            if (signingInfo.hasMultipleSigners()) {
                signingInfo.apkContentsSigners
            } else {
                signingInfo.signingCertificateHistory
            }
        } else {
            info.signatures
        }
        return signatures.orEmpty().mapTo(linkedSetOf()) {
            MessageDigest.getInstance("SHA-256").digest(it.toByteArray()).toHex()
        }
    }

    private fun openInstaller(apk: File) {
        require(apk.isFile && apk.canRead()) { "verified_update_unreadable" }
        val uri = FileProvider.getUriForFile(
            context,
            "${BuildConfig.APPLICATION_ID}.update_files",
            apk,
        )
        val flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION
        val installIntent = Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(flags)
            clipData = ClipData.newRawUri("知阅更新包", uri)
            putExtra(Intent.EXTRA_NOT_UNKNOWN_SOURCE, true)
        }
        val handlers = context.packageManager.queryIntentActivities(
            installIntent,
            PackageManager.MATCH_DEFAULT_ONLY,
        )
        val intent = if (handlers.isNotEmpty()) {
            installIntent
        } else {
            Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                addFlags(flags)
                clipData = ClipData.newRawUri("知阅更新包", uri)
            }
        }
        val resolved = context.packageManager.queryIntentActivities(
            intent,
            PackageManager.MATCH_DEFAULT_ONLY,
        )
        require(resolved.isNotEmpty()) { "installer_unavailable" }
        resolved.forEach { info ->
            context.grantUriPermission(
                info.activityInfo.packageName,
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
        }
        context.startActivity(intent)
    }

    private fun hashFile(file: File): String {
        val digest = MessageDigest.getInstance("SHA-256")
        FileInputStream(file).use { input ->
            val buffer = ByteArray(64 * 1024)
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                digest.update(buffer, 0, count)
            }
        }
        return digest.digest().toHex()
    }

    private fun checkedHash(value: String): String {
        val normalized = value.lowercase()
        require(SHA256_PATTERN.matches(normalized)) { "invalid_sha256" }
        return normalized
    }

    private fun requiredString(arguments: Map<*, *>, key: String): String =
        (arguments[key] as? String)?.takeIf { it.isNotBlank() }
            ?: throw IllegalArgumentException("missing_$key")

    private fun requiredLong(arguments: Map<*, *>, key: String): Long =
        (arguments[key] as? Number)?.toLong()
            ?: throw IllegalArgumentException("missing_$key")

    @Suppress("DEPRECATION")
    private fun packageVersionCode(info: PackageInfo): Long =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) info.longVersionCode else info.versionCode.toLong()

    private fun ByteArray.toHex(): String = joinToString("") { "%02x".format(it.toInt() and 0xff) }

    companion object {
        private const val MAX_PACKAGE_BYTES = 250L * 1024 * 1024
        private const val MAX_VERSION_CODE = 1_000_000_000L
        private val SHA256_PATTERN = Regex("^[0-9a-f]{64}$")
        private val VERIFIED_APK_PATTERN = Regex("^zhiyue-(\\d+)-[0-9a-f]{64}\\.apk$")
    }
}
