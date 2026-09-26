package com.zhiyue.client

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import java.io.ByteArrayOutputStream

/**
 * Stores and accesses the tree URI granted by Android's system document picker.
 *
 * The URI is kept in app-private preferences and is only used with the
 * ContentResolver. It is never sent to Dart as a path or included in a
 * network request.
 */
class CloudFolderStore(private val context: Context) {
    private val preferences = context.getSharedPreferences(
        PREFERENCES_NAME,
        Context.MODE_PRIVATE,
    )

    fun hasFolder(): Boolean {
        val uri = storedUri() ?: return false
        val root = DocumentFile.fromTreeUri(context, uri) ?: return false
        return root.exists()
    }

    fun folderName(): String? {
        val uri = storedUri() ?: return null
        val root = DocumentFile.fromTreeUri(context, uri) ?: return null
        return root.name?.takeIf { it.isNotBlank() }
    }

    fun remember(uri: Uri) {
        preferences.edit().putString(TREE_URI_KEY, uri.toString()).apply()
    }

    fun clear() {
        storedUri()?.let { uri ->
            runCatching {
                context.contentResolver.releasePersistableUriPermission(
                    uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                )
            }
        }
        preferences.edit().remove(TREE_URI_KEY).apply()
    }

    fun testConnection() {
        val root = rootOrThrow()
        if (!root.exists()) throw CloudFolderPermissionException()
    }

    fun ensureDirectory(path: String) {
        findDirectory(path, create = true)
    }

    fun read(path: String): ByteArray? {
        val parts = validatePath(path)
        if (parts.isEmpty()) throw CloudFolderPathException()
        val parent = findDirectoryParts(parts.dropLast(1), create = false) ?: return null
        val file = parent.findFile(parts.last()) ?: return null
        if (!file.exists() || file.isDirectory) return null
        val input = context.contentResolver.openInputStream(file.uri)
            ?: throw CloudFolderPermissionException()
        return input.use { stream ->
            val output = ByteArrayOutputStream()
            val buffer = ByteArray(BUFFER_SIZE)
            var total = 0
            while (true) {
                val count = stream.read(buffer)
                if (count < 0) break
                total += count
                if (total > MAX_FILE_BYTES) throw CloudFolderSizeException()
                output.write(buffer, 0, count)
            }
            output.toByteArray()
        }
    }

    fun write(path: String, bytes: ByteArray, contentType: String?) {
        if (bytes.size > MAX_FILE_BYTES) throw CloudFolderSizeException()
        val parts = validatePath(path)
        if (parts.isEmpty()) throw CloudFolderPathException()
        val parent = findDirectoryParts(parts.dropLast(1), create = true)
            ?: throw CloudFolderPermissionException()
        val fileName = parts.last()
        val file = parent.findFile(fileName)?.also {
            if (it.isDirectory) throw CloudFolderPathException()
        } ?: parent.createFile(
            contentType?.takeIf { MIME_TYPE_PATTERN.matches(it) }
                ?: "application/octet-stream",
            fileName,
        ) ?: throw CloudFolderPermissionException()
        val output = context.contentResolver.openOutputStream(file.uri, "wt")
            ?: context.contentResolver.openOutputStream(file.uri)
            ?: throw CloudFolderPermissionException()
        output.use { it.write(bytes) }
    }

    private fun findDirectory(path: String, create: Boolean): DocumentFile {
        val directory = findDirectoryParts(validatePath(path), create)
        return directory ?: throw CloudFolderPermissionException()
    }

    private fun findDirectoryParts(
        parts: List<String>,
        create: Boolean,
    ): DocumentFile? {
        var current = rootOrThrow()
        for (part in parts) {
            val existing = current.findFile(part)
            if (existing != null) {
                if (!existing.isDirectory) throw CloudFolderPathException()
                current = existing
                continue
            }
            if (!create) return null
            current = current.createDirectory(part)
                ?: throw CloudFolderPermissionException()
        }
        return current
    }

    private fun rootOrThrow(): DocumentFile {
        val uri = storedUri() ?: throw CloudFolderPermissionException()
        return DocumentFile.fromTreeUri(context, uri)
            ?.takeIf { it.exists() }
            ?: throw CloudFolderPermissionException()
    }

    private fun storedUri(): Uri? = preferences.getString(TREE_URI_KEY, null)
        ?.let { value -> runCatching { Uri.parse(value) }.getOrNull() }

    private fun validatePath(path: String): List<String> {
        if (path.length > MAX_PATH_LENGTH || path.contains('\u0000')) {
            throw CloudFolderPathException()
        }
        val normalized = path.trim().replace('\\', '/')
        if (normalized.startsWith('/')) throw CloudFolderPathException()
        val parts = normalized.split('/').filter { it.isNotBlank() && it != "." }
        if (parts.any { part ->
                part == ".." ||
                    part.length > MAX_PART_LENGTH ||
                    part.any { character -> character.code < 0x20 || character == '\u007f' }
            }
        ) {
            throw CloudFolderPathException()
        }
        return parts
    }

    class CloudFolderPermissionException : IllegalStateException()

    class CloudFolderPathException : IllegalArgumentException()

    class CloudFolderSizeException : IllegalArgumentException()

    companion object {
        private const val PREFERENCES_NAME = "cloud_folder"
        private const val TREE_URI_KEY = "tree_uri"
        private const val BUFFER_SIZE = 16 * 1024
        private const val MAX_FILE_BYTES = 64 * 1024 * 1024
        private const val MAX_PATH_LENGTH = 1024
        private const val MAX_PART_LENGTH = 180
        private val MIME_TYPE_PATTERN = Regex("^[A-Za-z0-9!#$&^_.+/-]{1,160}$")
    }
}
