package com.zhiyue.client

import android.content.ContentValues
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.content.Intent
import android.database.Cursor
import android.os.Handler
import android.os.Looper
import android.os.Build
import android.os.Environment
import android.net.Uri
import android.provider.OpenableColumns
import android.provider.MediaStore
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.graphics.pdf.PdfDocument
import android.webkit.CookieManager
import android.webkit.WebView
import androidx.webkit.UserAgentMetadata
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import androidx.webkit.WebSettingsCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.ByteArrayOutputStream
import java.net.URI
import java.net.InetSocketAddress
import java.net.Proxy
import java.util.Collections
import java.util.WeakHashMap
import java.util.concurrent.TimeUnit
import okhttp3.OkHttpClient
import okhttp3.Protocol
import okhttp3.Request
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody

class MainActivity : FlutterActivity() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val ttsController by lazy { TtsController(applicationContext) }
    private val qrCodeController by lazy { QrCodeController() }
    private var pendingImagePickerResult: MethodChannel.Result? = null
    private val privacyDeviceProfile by lazy {
        PrivacyDeviceProfile(applicationContext)
    }
    private val updatePackageManager by lazy {
        UpdatePackageManager(applicationContext)
    }
    private val privacyHttpClient by lazy {
        OkHttpClient.Builder()
            .followRedirects(false)
            .followSslRedirects(false)
            .retryOnConnectionFailure(false)
            .connectTimeout(20, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .callTimeout(40, TimeUnit.SECONDS)
            .protocols(listOf(Protocol.HTTP_2, Protocol.HTTP_1_1))
            .build()
    }
    private val privacyProfileWebViews = Collections.newSetFromMap(
        WeakHashMap<WebView, Boolean>(),
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/media_picker",
        ).setMethodCallHandler { call, result ->
            if (call.method != "pickSingleImage") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingImagePickerResult != null) {
                result.error("picker_busy", "图片选择器正在使用", null)
                return@setMethodCallHandler
            }
            pendingImagePickerResult = result
            try {
                startActivityForResult(
                    Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "image/*"
                        putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                    },
                    IMAGE_PICKER_REQUEST_CODE,
                )
            } catch (error: Exception) {
                pendingImagePickerResult = null
                result.error(
                    error.javaClass.simpleName.ifBlank { "picker_unavailable" },
                    "无法打开系统图片选择器",
                    null,
                )
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/app_updates",
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "appVersion" -> result.success(updatePackageManager.appVersion())
                    "hasCachedUpdate" -> {
                        @Suppress("UNCHECKED_CAST")
                        val arguments = call.arguments as? Map<String, Any?>
                            ?: throw IllegalArgumentException("arguments")
                        result.success(updatePackageManager.hasCachedUpdate(arguments))
                    }
                    "canInstallPackages" -> result.success(
                        updatePackageManager.canRequestPackageInstalls(),
                    )
                    "openInstallPermission" -> {
                        updatePackageManager.openInstallPermission()
                        result.success(null)
                    }
                    "verifyAndInstall" -> {
                        @Suppress("UNCHECKED_CAST")
                        val arguments = call.arguments as? Map<String, Any?>
                            ?: throw IllegalArgumentException("arguments")
                        Thread {
                            try {
                                val response = updatePackageManager.verifyAndInstall(arguments)
                                mainHandler.post { result.success(response) }
                            } catch (error: Exception) {
                                val code = error.message
                                    ?.takeIf { it.matches(Regex("^[a-z0-9_]{3,80}$")) }
                                    ?: error.javaClass.simpleName.ifBlank { "NativeError" }
                                mainHandler.post {
                                    result.error(code, "更新包验证或安装失败", null)
                                }
                            }
                        }.start()
                    }
                    "installCachedUpdate" -> {
                        @Suppress("UNCHECKED_CAST")
                        val arguments = call.arguments as? Map<String, Any?>
                            ?: throw IllegalArgumentException("arguments")
                        Thread {
                            try {
                                val installed = updatePackageManager.installCachedUpdate(arguments)
                                mainHandler.post { result.success(installed) }
                            } catch (error: Exception) {
                                val code = error.message
                                    ?.takeIf { it.matches(Regex("^[a-z0-9_]{3,80}$")) }
                                    ?: error.javaClass.simpleName.ifBlank { "NativeError" }
                                mainHandler.post {
                                    result.error(code, "更新包验证或安装失败", null)
                                }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                result.error(code, "应用更新操作失败", null)
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/salt_manuscript_key",
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "generate" -> result.success(
                        SaltManuscriptKeyGenerator.generate(call.argument<String>("rawKey")),
                    )
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                result.error(code, "Salt request key generation failed", null)
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/official_web_cookie",
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "sync" -> syncOfficialWebCookies(call, result)
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                result.error(code, "网页登录状态同步失败", null)
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/web_privacy",
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "installDocumentStart" -> installDocumentStartPrivacyProfile(call, result)
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                result.error(code, "WebView 隐私档案安装失败", null)
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/document_export",
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "save" -> saveExportedDocument(call, result)
                    "savePdf" -> savePdfDocument(call, result)
                    "saveImageToGallery" -> saveImageToGallery(call, result)
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                result.error(code, "文档导出失败", null)
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/tts",
        ).setMethodCallHandler { call, result ->
            if (!ttsController.handle(call, result)) result.notImplemented()
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/qr_code",
        ).setMethodCallHandler { call, result ->
            if (!qrCodeController.handle(call, result)) result.notImplemented()
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/public_web",
        ).setMethodCallHandler { call, result ->
            if (call.method != "get") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            Thread {
                try {
                    val response = fetchPublicWeb(call)
                    mainHandler.post { result.success(response) }
                } catch (error: Exception) {
                    val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                    mainHandler.post { result.error(code, "公开 Web 请求失败", null) }
                }
            }.start()
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/native_http",
        ).setMethodCallHandler { call, result ->
            if (call.method != "request") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            Thread {
                try {
                    val response = fetchNativeHttp(call)
                    mainHandler.post { result.success(response) }
                } catch (error: Exception) {
                    val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                    mainHandler.post { result.error(code, "Android 原生网络请求失败", null) }
                }
            }.start()
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/debug_salt_relay",
        ).setMethodCallHandler { call, result ->
            if (call.method != "request" && call.method != "get") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            Thread {
                try {
                    val response = fetchDebugSaltRelay(call)
                    mainHandler.post { result.success(response) }
                } catch (error: Exception) {
                    val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                    mainHandler.post { result.error(code, "盐选认证兼容请求失败", null) }
                }
            }.start()
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.zhiyue.client/cloud_id",
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "deviceInfo" -> {
                        Thread {
                            try {
                                val info = buildCloudIdDeviceInfo()
                                mainHandler.post { result.success(info) }
                            } catch (error: Exception) {
                                val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                                mainHandler.post {
                                    result.error(code, "CloudID device info failed", null)
                                }
                            }
                        }.start()
                    }
                    "appInfo" -> result.success(buildAppInfo())
                    "localMsId" -> result.success(readLocalMsId())
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                val code = error.javaClass.simpleName.ifBlank { "NativeError" }
                result.error(code, "CloudID native operation failed", null)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != IMAGE_PICKER_REQUEST_CODE) return
        val pending = pendingImagePickerResult ?: return
        pendingImagePickerResult = null
        if (resultCode != RESULT_OK || data?.data == null) {
            pending.success(null)
            return
        }
        try {
            val uri = data.data!!
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                runCatching {
                    contentResolver.takePersistableUriPermission(
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION,
                    )
                }
            }
            pending.success(readSingleImage(uri))
        } catch (error: Exception) {
            pending.error(
                error.javaClass.simpleName.ifBlank { "picker_read_failed" },
                error.message ?: "读取图片失败",
                null,
            )
        }
    }

    override fun onDestroy() {
        ttsController.shutdown()
        super.onDestroy()
    }

    private fun readSingleImage(uri: Uri): Map<String, Any> {
        val mimeType = contentResolver.getType(uri)?.lowercase().orEmpty()
        if (!mimeType.startsWith("image/")) {
            throw IllegalArgumentException("请选择图片文件")
        }
        val bytes = contentResolver.openInputStream(uri)?.use { input ->
            val output = ByteArrayOutputStream()
            val buffer = ByteArray(16 * 1024)
            var total = 0
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                total += count
                if (total > MAX_PICKED_IMAGE_BYTES) {
                    throw IllegalArgumentException("图片不能超过 20 MB")
                }
                output.write(buffer, 0, count)
            }
            output.toByteArray()
        } ?: throw IllegalArgumentException("无法读取所选图片")
        if (bytes.isEmpty()) throw IllegalArgumentException("所选图片为空")
        val displayName = contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor: Cursor ->
            if (cursor.moveToFirst()) cursor.getString(0) else null
        }.orEmpty()
        val safeName = displayName
            .substringAfterLast('/')
            .replace(Regex("[^A-Za-z0-9._-]"), "_")
            .take(120)
            .ifBlank {
                "profile.${mimeType.substringAfter('/', "jpeg").replace(Regex("[^A-Za-z0-9]"), "")}"
            }
        return mapOf(
            "bytes" to bytes,
            "mimeType" to mimeType,
            "fileName" to safeName,
        )
    }

    private fun saveExportedDocument(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name") ?: throw IllegalArgumentException("name")
        val mimeType = call.argument<String>("mimeType") ?: throw IllegalArgumentException("mimeType")
        val bytes = call.argument<ByteArray>("bytes") ?: throw IllegalArgumentException("bytes")
        if (!EXPORT_FILE_NAME.matches(name) || !EXPORT_MIME_TYPES.contains(mimeType)) {
            throw SecurityException("unsupported export")
        }
        if (bytes.isEmpty() || bytes.size > 32 * 1024 * 1024) {
            throw IllegalArgumentException("export size")
        }

        val location = saveBytesToDownloads(name, mimeType, bytes)
        result.success(mapOf("location" to location))
    }

    private fun savePdfDocument(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name") ?: throw IllegalArgumentException("name")
        val title = call.argument<String>("title")?.trim().orEmpty().ifBlank { "知阅内容" }
        val content = call.argument<String>("content") ?: throw IllegalArgumentException("content")
        if (!Regex("^[^/\\\\\\u0000-\\u001F]{1,160}\\.pdf$").matches(name) ||
            content.length > 1_000_000) {
            throw SecurityException("unsupported pdf")
        }
        val pdf = PdfDocument()
        try {
            val pageWidth = 595
            val pageHeight = 842
            val bodyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = android.graphics.Color.BLACK
                textSize = 11f
                typeface = Typeface.DEFAULT
            }
            val titlePaint = Paint(bodyPaint).apply {
                textSize = 18f
                typeface = Typeface.DEFAULT_BOLD
            }
            var pageNumber = 1
            var page = pdf.startPage(PdfDocument.PageInfo.Builder(pageWidth, pageHeight, pageNumber).create())
            var canvas: Canvas = page.canvas
            var y = 48f
            canvas.drawText(title.take(80), 40f, y, titlePaint)
            y += 34f
            fun nextPage() {
                pdf.finishPage(page)
                pageNumber += 1
                page = pdf.startPage(PdfDocument.PageInfo.Builder(pageWidth, pageHeight, pageNumber).create())
                canvas = page.canvas
                y = 48f
            }
            for (rawLine in content.split(Regex("\\r?\\n"))) {
                var line = rawLine
                if (line.isEmpty()) {
                    y += 18f
                    if (y > pageHeight - 48) nextPage()
                    continue
                }
                while (line.isNotEmpty()) {
                    val count = bodyPaint.breakText(line, true, pageWidth - 80f, null)
                    val end = count.coerceAtLeast(1).coerceAtMost(line.length)
                    canvas.drawText(line.substring(0, end), 40f, y, bodyPaint)
                    line = line.substring(end)
                    y += 18f
                    if (y > pageHeight - 48 && line.isNotEmpty()) nextPage()
                }
            }
            pdf.finishPage(page)
            val bytes = ByteArrayOutputStream().use { output ->
                pdf.writeTo(output)
                output.toByteArray()
            }
            val location = saveBytesToDownloads(name, "application/pdf", bytes)
            result.success(mapOf("location" to location))
        } finally {
            pdf.close()
        }
    }

    private fun saveBytesToDownloads(name: String, mimeType: String, bytes: ByteArray): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    Environment.DIRECTORY_DOWNLOADS + File.separator + "知阅",
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val resolver = applicationContext.contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("downloads insert")
            try {
                resolver.openOutputStream(uri, "w")?.use { it.write(bytes) }
                    ?: throw IllegalStateException("downloads stream")
                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
            } catch (error: Exception) {
                resolver.delete(uri, null, null)
                throw error
            }
            "下载/知阅/$name"
        } else {
            val directory = getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
                ?: throw IllegalStateException("downloads directory")
            check(directory.mkdirs() || directory.isDirectory)
            File(directory, name).writeBytes(bytes)
            File(directory, name).absolutePath
        }
    }

    private fun saveImageToGallery(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name") ?: throw IllegalArgumentException("name")
        val mimeType = call.argument<String>("mimeType") ?: throw IllegalArgumentException("mimeType")
        val bytes = call.argument<ByteArray>("bytes") ?: throw IllegalArgumentException("bytes")
        if (!Regex("^[A-Za-z0-9._-]{1,120}$").matches(name) ||
            !setOf("image/jpeg", "image/png", "image/webp").contains(mimeType) ||
            bytes.isEmpty() || bytes.size > 32 * 1024 * 1024) {
            throw SecurityException("unsupported image")
        }
        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, name)
            put(MediaStore.Images.Media.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + File.separator + "知阅")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        }
        val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("gallery insert")
        try {
            resolver.openOutputStream(uri, "w")?.use { it.write(bytes) }
                ?: throw IllegalStateException("gallery stream")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val ready = ContentValues().apply { put(MediaStore.Images.Media.IS_PENDING, 0) }
                resolver.update(uri, ready, null, null)
            }
            result.success(mapOf("location" to "图片/知阅/$name"))
        } catch (error: Exception) {
            resolver.delete(uri, null, null)
            throw error
        }
    }

    private fun syncOfficialWebCookies(call: MethodCall, result: MethodChannel.Result) {
        val rawUrl = call.argument<String>("url") ?: throw IllegalArgumentException("url")
        val uri = URI(rawUrl)
        if (
            uri.scheme != "https" ||
                (uri.host != "zhihu.com" && !uri.host.endsWith(".zhihu.com")) ||
                (uri.port != -1 && uri.port != 443) ||
                uri.userInfo != null
        ) {
            throw SecurityException("unreviewed official Web URL")
        }
        val source = call.argument<List<*>>("cookies") ?: emptyList<Any>()
        val cookies = source.map { item ->
            val entry = item as? Map<*, *> ?: throw IllegalArgumentException("cookie")
            val name = entry["name"] as? String ?: throw IllegalArgumentException("cookie name")
            val value = entry["value"] as? String ?: throw IllegalArgumentException("cookie value")
            if (!COOKIE_NAME.matches(name) || value.isEmpty() || value.any { it == ';' || it == '\r' || it == '\n' }) {
                throw SecurityException("unsafe cookie")
            }
            name to value
        }
        if (cookies.isEmpty()) {
            result.success(mapOf("acceptedNames" to emptyList<String>(), "presentNames" to emptyList<String>()))
            return
        }

        val manager = CookieManager.getInstance()
        manager.setAcceptCookie(true)
        val acceptedNames = mutableListOf<String>()
        var pending = cookies.size
        for ((name, value) in cookies) {
            val serialized = "$name=$value; Domain=.zhihu.com; Path=/; Secure; HttpOnly; SameSite=Lax"
            // webview_flutter_android percent-encodes cookie values before this
            // call. Zhihu z_c0 contains significant pipe and colon characters,
            // so use Android's CookieManager directly and preserve its wire form.
            manager.setCookie("https://www.zhihu.com/", serialized) { accepted ->
                if (accepted) acceptedNames.add(name)
                pending -= 1
                if (pending == 0) {
                    manager.flush()
                    val stored = manager.getCookie("https://www.zhihu.com/").orEmpty()
                    val presentNames = stored
                        .split(';')
                        .mapNotNull { part ->
                            val separator = part.indexOf('=')
                            if (separator <= 0) null else part.substring(0, separator).trim()
                        }
                        .distinct()
                    result.success(
                        mapOf(
                            "acceptedNames" to acceptedNames.distinct(),
                            "presentNames" to presentNames,
                        ),
                    )
                }
            }
        }
    }

    private fun installDocumentStartPrivacyProfile(
        call: MethodCall,
        result: MethodChannel.Result,
        attempt: Int = 0,
    ) {
        val script = call.argument<String>("script") ?: throw IllegalArgumentException("script")
        if (script.isBlank() || script.length > 64 * 1024) {
            throw IllegalArgumentException("script size")
        }
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
            result.success(mapOf("supported" to false, "installed" to false))
            return
        }
        val webViews = mutableListOf<WebView>()
        collectWebViews(window.decorView, webViews)
        if (webViews.isEmpty()) {
            if (attempt < 20) {
                mainHandler.postDelayed(
                    { installDocumentStartPrivacyProfile(call, result, attempt + 1) },
                    50L,
                )
            } else {
                result.success(mapOf("supported" to true, "installed" to false))
            }
            return
        }
        var installed = false
        for (webView in webViews) {
            configureWebViewPrivacyProfile(webView)
            if (!privacyProfileWebViews.contains(webView)) {
                WebViewCompat.addDocumentStartJavaScript(
                    webView,
                    script,
                    setOf("https://zhihu.com", "https://*.zhihu.com"),
                )
                privacyProfileWebViews.add(webView)
            }
            installed = installed || privacyProfileWebViews.contains(webView)
        }
        result.success(
            mapOf(
                "supported" to true,
                "installed" to installed,
                "webViewCount" to webViews.size,
            ),
        )
    }

    private fun configureWebViewPrivacyProfile(webView: WebView) {
        webView.settings.userAgentString = PrivacyDeviceProfile.APP_USER_AGENT
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.USER_AGENT_METADATA)) return

        val chromium = UserAgentMetadata.BrandVersion.Builder()
            .setBrand("Chromium")
            .setMajorVersion("57")
            .setFullVersion("57.0.1000.10")
            .build()
        val grease = UserAgentMetadata.BrandVersion.Builder()
            .setBrand("Not/A)Brand")
            .setMajorVersion("8")
            .setFullVersion("8.0.0.0")
            .build()
        val metadata = UserAgentMetadata.Builder()
            .setBrandVersionList(listOf(chromium, grease))
            .setFullVersion("57.0.1000.10")
            .setPlatform("Android")
            .setPlatformVersion("14.0.0")
            .setArchitecture("arm")
            .setModel(PrivacyDeviceProfile.MODEL)
            .setMobile(true)
            .setBitness(64)
            .setWow64(false)
            .build()
        WebSettingsCompat.setUserAgentMetadata(webView.settings, metadata)
    }

    private fun collectWebViews(view: View, output: MutableList<WebView>) {
        if (view is WebView) output.add(view)
        if (view is ViewGroup) {
            for (index in 0 until view.childCount) {
                collectWebViews(view.getChildAt(index), output)
            }
        }
    }

    private fun byteArrayArgument(value: Any?): ByteArray =
        when (value) {
            is ByteArray -> value
            is List<*> -> ByteArray(value.size) { index ->
                val item = value[index] as? Number ?: throw IllegalArgumentException("iv")
                item.toByte()
            }
            else -> throw IllegalArgumentException("iv")
        }

    private fun fetchPublicWeb(call: MethodCall): Map<String, Any> {
        val rawUrl = call.argument<String>("url") ?: throw IllegalArgumentException("url")
        val uri = URI(rawUrl)
        if (
            uri.scheme != "https" ||
                uri.host != "www.zhihu.com" ||
                (uri.port != -1 && uri.port != 443) ||
                uri.userInfo != null ||
                uri.fragment != null ||
                !uri.path.startsWith("/api/v4/")
        ) {
            throw SecurityException("unreviewed public Web URL")
        }
        val requestedLimit = call.argument<Int>("maxResponseBytes") ?: MAX_RESPONSE_BYTES
        val limit = requestedLimit.coerceIn(1, MAX_RESPONSE_BYTES)
        val headers = requestHeaders(call)
        if (headers.keys.any { it.lowercase() !in ALLOWED_HEADERS }) {
            throw SecurityException("unreviewed public Web header")
        }
        val effectiveHeaders = linkedMapOf(
            "Accept" to "application/json",
            "User-Agent" to APP_USER_AGENT,
        )
        effectiveHeaders.putAll(headers)
        return executePrivacyHttpRequest(uri, "GET", null, effectiveHeaders, limit)
    }

    private fun fetchNativeHttp(call: MethodCall): Map<String, Any> {
        val rawUrl = call.argument<String>("url") ?: throw IllegalArgumentException("url")
        val uri = URI(rawUrl)
        val method = (call.argument<String>("method") ?: "GET").uppercase()
        val body = call.argument<Any>("body")?.let(::byteArrayArgument)
        val headers = requestHeaders(call)
        if (
            uri.scheme != "https" ||
                uri.host !in NATIVE_HTTP_HOSTS ||
                (uri.port != -1 && uri.port != 443) ||
                uri.userInfo != null ||
                uri.fragment != null ||
                method !in NATIVE_HTTP_METHODS ||
                (uri.host == "www.zhihu.com" &&
                    !uri.path.startsWith("/api/v4/") &&
                    !isQrLoginPath(uri.path, method)) ||
                (uri.host == "lens.zhihu.com" &&
                    (method != "GET" ||
                        !LENS_VIDEO_PATH.matches(uri.path) ||
                        headers.keys.any { it.lowercase() !in ALLOWED_HEADERS })) ||
                (method == "GET" && body != null) ||
                (body?.size ?: 0) > requestBodyLimit(uri)
        ) {
            throw SecurityException("unreviewed native HTTP request")
        }
        val requestedLimit = call.argument<Int>("maxResponseBytes") ?: MAX_RESPONSE_BYTES
        val limit = requestedLimit.coerceIn(1, MAX_RESPONSE_BYTES)
        return executePrivacyHttpRequest(
            uri,
            method,
            body,
            headers,
            limit,
        )
    }

    private fun requestHeaders(call: MethodCall): LinkedHashMap<String, String> {
        val source = call.argument<Map<*, *>>("headers") ?: emptyMap<Any, Any>()
        val headers = linkedMapOf<String, String>()
        for ((rawName, rawValue) in source) {
            val name = rawName as? String ?: throw SecurityException("invalid header name")
            val value = rawValue as? String ?: throw SecurityException("invalid header value")
            val lower = name.lowercase()
            if (
                !HTTP_HEADER_NAME.matches(name) ||
                    lower in FORBIDDEN_NATIVE_HTTP_HEADERS ||
                    value.length > 8192 ||
                    value.any { it == '\r' || it == '\n' }
            ) {
                throw SecurityException("unsafe native HTTP header")
            }
            headers[name] = value
        }
        return headers
    }

    private fun requestBodyLimit(uri: URI): Int =
        if (uri.host == "api.zhihu.com" && uri.path == "/upload_image") {
            MAX_UPLOAD_REQUEST_BYTES
        } else {
            MAX_REQUEST_BYTES
        }

    private fun isQrLoginPath(path: String, method: String): Boolean =
        (method == "POST" && path == "/api/v3/account/api/login/qrcode") ||
            (method == "GET" && QR_SCAN_PATH.matches(path)) ||
            (method == "GET" && path == "/signin") ||
            (method == "POST" && path == "/udid") ||
            (method == "GET" && path == "/api/v3/oauth/captcha/v2")

    private fun executePrivacyHttpRequest(
        uri: URI,
        method: String,
        body: ByteArray?,
        headers: Map<String, String>,
        limit: Int,
    ): Map<String, Any> {
        val qrTrace = uri.host == "www.zhihu.com" &&
            (uri.path == "/signin" ||
                uri.path == "/udid" ||
                uri.path == "/api/v3/oauth/captcha/v2" ||
                uri.path == "/api/v3/account/api/login/qrcode" ||
                QR_SCAN_PATH.matches(uri.path))
        if (qrTrace) {
            val requestCookie = headers.entries.firstOrNull {
                it.key.equals("cookie", true)
            }?.value.orEmpty()
            val requestCookieNames = requestCookie
                .split(';')
                .mapNotNull { part ->
                    part.substringBefore('=').trim().takeIf { it.isNotEmpty() }
                }
                .distinct()
                .joinToString(",")
            Log.i(
                "zhihu-qr",
                "request method=$method path=${uri.path} " +
                    "query=${!uri.query.isNullOrEmpty()} " +
                    "cookie=${requestCookie.isNotEmpty()} " +
                    "cookieNames=$requestCookieNames " +
                    "xsrfHeader=${headers.keys.any { it.equals("x-xsrftoken", true) }}",
            )
        }
        val requestBuilder = Request.Builder().url(uri.toASCIIString())
        if (headers.keys.none { it.equals("user-agent", ignoreCase = true) }) {
            requestBuilder.header("User-Agent", APP_USER_AGENT)
        }
        for ((name, value) in headers) {
            requestBuilder.header(name, value)
        }
        val contentType = headers.entries.firstOrNull {
            it.key.equals("content-type", ignoreCase = true)
        }?.value?.toMediaTypeOrNull()
        when {
            method == "GET" -> requestBuilder.get()
            method == "DELETE" && body == null -> requestBuilder.delete()
            else -> requestBuilder.method(
                method,
                (body ?: ByteArray(0)).toRequestBody(contentType),
            )
        }
        privacyHttpClient.newCall(requestBuilder.build()).execute().use { response ->
            val output = ByteArrayOutputStream()
            response.body?.byteStream()?.use { input ->
                val buffer = ByteArray(8192)
                while (true) {
                    val count = input.read(buffer)
                    if (count < 0) break
                    if (output.size() + count > limit) {
                        throw IllegalStateException("response exceeds limit")
                    }
                    output.write(buffer, 0, count)
                }
            }
            val responseHeaders = linkedMapOf<String, String>()
            for (name in response.headers.names()) {
                val values = response.headers.values(name)
                responseHeaders[name.lowercase()] = if (name.equals("set-cookie", true)) {
                    values.joinToString("\n")
                } else {
                    values.joinToString(", ")
                }
            }
            responseHeaders["x-zh-native-http-protocol"] = response.protocol.toString()
            if (qrTrace) {
                val responseCookieNames = responseHeaders["set-cookie"]
                    .orEmpty()
                    .split(Regex("[\\r\\n]+"))
                    .mapNotNull { line ->
                        line.substringBefore('=').trim().takeIf { it.isNotEmpty() }
                    }
                    .distinct()
                    .joinToString(",")
                Log.i(
                    "zhihu-qr",
                    "response method=$method path=${uri.path} " +
                        "status=${response.code} bytes=${output.size()} " +
                        "setCookie=${responseHeaders.containsKey("set-cookie")} " +
                        "setCookieNames=$responseCookieNames",
                )
            }
            return mapOf(
                "url" to response.request.url.toString(),
                "statusCode" to response.code,
                "body" to output.toByteArray(),
                "headers" to responseHeaders,
            )
        }
    }

    private fun fetchDebugSaltRelay(call: MethodCall): Map<String, Any> {
        if (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE == 0) {
            throw SecurityException("debug build required")
        }
        val rawUrl = call.argument<String>("url") ?: throw IllegalArgumentException("url")
        val uri = URI(rawUrl)
        val method = (call.argument<String>("method") ?: "GET").uppercase()
        val body = call.argument<Any>("body")?.let(::byteArrayArgument)
        val loginCapture = call.argument<Boolean>("loginCapture") == true
        val isAuditedGet = method == "GET" &&
            body == null &&
            SALT_RELAY_PREFIXES.any { uri.path.startsWith(it) }
        val isAuditedContentPost = method == "POST" &&
            body != null &&
            SALT_CONTENT_PATH.matches(uri.path)
        val isAuditedLoginCapture = loginCapture &&
            ((method == "GET" && body == null) ||
                (method == "POST" && body != null && body.size <= 256 * 1024))
        if (
            uri.scheme != "https" ||
                uri.host != "api.zhihu.com" ||
                (uri.port != -1 && uri.port != 443) ||
                uri.userInfo != null ||
                uri.fragment != null ||
                (!isAuditedGet && !isAuditedContentPost && !isAuditedLoginCapture)
        ) {
            throw SecurityException("unreviewed debug relay URL")
        }
        val proxyPort = call.argument<Int>("proxyPort") ?: 0
        if (proxyPort !in 1024..65535) {
            throw SecurityException("invalid Salt relay proxy port")
        }
        val requestedLimit = call.argument<Int>("maxResponseBytes") ?: MAX_RESPONSE_BYTES
        val limit = requestedLimit.coerceIn(1, MAX_RESPONSE_BYTES)
        @Suppress("UNCHECKED_CAST")
        val headers = call.argument<Map<String, String>>("headers") ?: emptyMap()
        if (headers.values.any { it.contains('\r') || it.contains('\n') }) {
            throw SecurityException("unsafe debug relay header")
        }
        if (loginCapture) {
            if (headers.keys.any { it.lowercase() !in LOGIN_CAPTURE_ALLOWED_HEADERS }) {
                throw SecurityException("unreviewed login capture header")
            }
        } else if (
            headers.entries.none {
                it.key.equals("x-zh-debug-auth-relay", ignoreCase = true) &&
                    it.value.equals("salt", ignoreCase = true)
            } || headers.keys.any { it.lowercase() !in SALT_RELAY_ALLOWED_HEADERS }
        ) {
            throw SecurityException("unreviewed Salt relay header")
        }

        val proxy = Proxy(Proxy.Type.HTTP, InetSocketAddress("127.0.0.1", proxyPort))
        val client =
            OkHttpClient.Builder()
                .proxy(proxy)
                .followRedirects(false)
                .followSslRedirects(false)
                .connectTimeout(20, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .protocols(listOf(Protocol.HTTP_2, Protocol.HTTP_1_1))
                .build()
        val requestBuilder = Request.Builder().url(uri.toASCIIString())
        for ((name, value) in headers) {
            requestBuilder.header(name, value)
        }
        if (method == "POST") {
            if (body!!.size > 64 * 1024) {
                if (!loginCapture || body.size > 256 * 1024) {
                    throw SecurityException("debug relay request body too large")
                }
            }
            val contentType = headers.entries.firstOrNull {
                it.key.equals("content-type", ignoreCase = true)
            }?.value?.toMediaTypeOrNull()
            requestBuilder.method(method, body.toRequestBody(contentType))
        } else {
            requestBuilder.get()
        }
        client.newCall(requestBuilder.build()).execute().use { response ->
            val status = response.code
            val stream = response.body?.byteStream()
            val output = ByteArrayOutputStream()
            if (stream != null) {
                stream.use { input ->
                    val buffer = ByteArray(8192)
                    while (true) {
                        val count = input.read(buffer)
                        if (count < 0) break
                        if (output.size() + count > limit) {
                            throw IllegalStateException("response exceeds limit")
                        }
                        output.write(buffer, 0, count)
                    }
                }
            }
            val responseHeaders = mutableMapOf<String, String>()
            response.header("content-type")?.let { responseHeaders["content-type"] = it }
            response.header("x-request-id")?.let {
                responseHeaders["x-request-id"] = it
            }
            response.headers.values("set-cookie").takeIf { it.isNotEmpty() }?.let {
                responseHeaders["set-cookie"] = it.joinToString("\n")
            }
            responseHeaders["x-debug-http-protocol"] = response.protocol.toString()
            return mapOf(
                "url" to uri.toASCIIString(),
                "statusCode" to status,
                "body" to output.toByteArray(),
                "headers" to responseHeaders,
            )
        }
    }

    private fun buildCloudIdDeviceInfo(): Map<String, Any> =
        privacyDeviceProfile.cloudIdDeviceInfo()

    private fun buildAppInfo(): String = privacyDeviceProfile.appInfo()

    private fun readLocalMsId(): String = privacyDeviceProfile.localMsId()

    companion object {
        private const val IMAGE_PICKER_REQUEST_CODE = 4107
        private const val MAX_PICKED_IMAGE_BYTES = 20 * 1024 * 1024
        private const val MAX_RESPONSE_BYTES = 12 * 1024 * 1024
        private const val MAX_REQUEST_BYTES = 4 * 1024 * 1024
        private const val MAX_UPLOAD_REQUEST_BYTES = 20 * 1024 * 1024
        private val EXPORT_FILE_NAME = Regex("^[^/\\\\\\u0000-\\u001F]{1,160}\\.(txt|docx|md|html)$")
        private val EXPORT_MIME_TYPES = setOf(
            "text/plain",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "text/markdown",
            "text/html",
        )
        private val COOKIE_NAME = Regex("^[A-Za-z0-9_-]+$")
        private val HTTP_HEADER_NAME = Regex("^[A-Za-z0-9!#$%&'*+.^_`|~-]{1,128}$")
        private val NATIVE_HTTP_HOSTS = setOf(
            "api.zhihu.com",
            "appcloud.zhihu.com",
            "www.zhihu.com",
            "lens.zhihu.com",
        )
        private val LENS_VIDEO_PATH = Regex("^/api/v4/videos/[A-Za-z0-9_-]{1,128}$")
        private val QR_SCAN_PATH = Regex(
            "^/api/v3/account/api/login/qrcode/[A-Za-z0-9._~-]{1,256}/scan_info$",
        )
        private val NATIVE_HTTP_METHODS = setOf("GET", "POST", "PUT", "PATCH", "DELETE")
        private val FORBIDDEN_NATIVE_HTTP_HEADERS = setOf(
            "host",
            "content-length",
            "connection",
            "transfer-encoding",
            "proxy-authorization",
            "proxy-connection",
            "te",
            "trailer",
            "upgrade",
        )
        private val ALLOWED_HEADERS = setOf("accept", "user-agent")
        private val SALT_RELAY_PREFIXES = listOf(
            "/km-vip-zhihu-web/",
            "/km-indep-home-comm/",
            "/km-indep-home-vip-comment/",
            "/comment_v5/doc_sections/",
            "/remix-pre-web/manuscript/",
        )
        private val SALT_CONTENT_PATH = Regex(
            "^/remix-pre-web/manuscript/[0-9]+/[0-9]+/content$",
        )
        private val SALT_RELAY_ALLOWED_HEADERS = setOf(
            "accept",
            "content-type",
            "user-agent",
            "x-api-version",
            "x-app-version",
            "x-app-build",
            "x-app-bundleid",
            "x-app-flavor",
            "x-network-type",
            "x-zse-93",
            "x-zse-96",
            "x-app-za",
            "authorization",
            "x-udid",
            "cookie",
            "x-ms-id",
            "x-zh-debug-auth-relay",
        )
        private val LOGIN_CAPTURE_ALLOWED_HEADERS = setOf(
            "accept",
            "content-type",
            "user-agent",
            "authorization",
            "cookie",
            "x-api-version",
            "x-app-version",
            "x-app-build",
            "x-app-bundleid",
            "x-app-flavor",
            "x-network-type",
            "x-ad-styles",
            "x-zse-93",
            "x-zse-96",
            "x-app-za",
            "x-udid",
            "x-ms-id",
            "x-b3-traceid",
            "x-client-ri",
            "x-req-ts",
            "x-app-id",
            "x-sign-version",
            "x-req-signature",
            "za-spm",
        )
        private const val APP_USER_AGENT = PrivacyDeviceProfile.APP_USER_AGENT
    }
}
