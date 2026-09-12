package com.zhiyue.client

import android.content.Context
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.concurrent.atomic.AtomicInteger

/** Foreground reader TTS bridge. The queue is deliberately bounded to the
 * current document and never persists text or audio outside the process. */
class TtsController(context: Context) : TextToSpeech.OnInitListener {
    private val appContext = context.applicationContext
    private var engine: TextToSpeech? = null
    private var initialized = false
    private var initializationFailed = false
    private val pending = mutableListOf<(Boolean) -> Unit>()
    private val utteranceCounter = AtomicInteger(0)

    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {
            "initialize" -> {
                ensureReady { available ->
                    result.success(mapOf("available" to available))
                }
                true
            }
            "speak" -> {
                val text = call.argument<String>("text")?.trim().orEmpty()
                if (text.isEmpty() || text.length > MAX_TEXT_CHARS) {
                    result.error("invalid_text", "朗读文本为空或超过限制", null)
                } else {
                    val rate = (call.argument<Double>("rate") ?: 1.0)
                        .toFloat()
                        .coerceIn(0.5f, 2.0f)
                    ensureReady { available ->
                        if (!available) {
                            result.error("tts_unavailable", "系统中文语音不可用", null)
                        } else {
                            try {
                                speak(text, rate)
                                result.success(null)
                            } catch (error: Exception) {
                                Log.e(TAG, "speak failed", error)
                                result.error("tts_speak_failed", "系统语音启动失败", null)
                            }
                        }
                    }
                }
                true
            }
            "stop" -> {
                engine?.stop()
                Log.i(TAG, "stop")
                result.success(null)
                true
            }
            "setRate" -> {
                val rate = (call.argument<Double>("rate") ?: 1.0)
                    .toFloat()
                    .coerceIn(0.5f, 2.0f)
                engine?.setSpeechRate(rate)
                result.success(null)
                true
            }
            "isSpeaking" -> {
                result.success(engine?.isSpeaking == true)
                true
            }
            else -> false
        }
    }

    private fun ensureReady(callback: (Boolean) -> Unit) {
        if (initialized) {
            callback(!initializationFailed && engine != null)
            return
        }
        if (initializationFailed) {
            callback(false)
            return
        }
        pending += callback
        if (engine == null) {
            Log.i(TAG, "initialize")
            engine = TextToSpeech(appContext, this)
        }
    }

    override fun onInit(status: Int) {
        val tts = engine
        if (status != TextToSpeech.SUCCESS || tts == null) {
            initializationFailed = true
            initialized = true
            flushPending(false)
            Log.w(TAG, "initialize failed status=$status")
            return
        }
        val languageResult = tts.setLanguage(Locale.SIMPLIFIED_CHINESE)
        val supported = languageResult != TextToSpeech.LANG_MISSING_DATA &&
            languageResult != TextToSpeech.LANG_NOT_SUPPORTED
        if (!supported) {
            val fallback = tts.setLanguage(Locale.CHINESE)
            if (fallback == TextToSpeech.LANG_MISSING_DATA ||
                fallback == TextToSpeech.LANG_NOT_SUPPORTED) {
                initializationFailed = true
            }
        }
        initialized = true
        flushPending(!initializationFailed)
        Log.i(TAG, "initialized available=${!initializationFailed}")
    }

    private fun flushPending(available: Boolean) {
        val callbacks = pending.toList()
        pending.clear()
        callbacks.forEach { it(available) }
    }

    private fun speak(text: String, rate: Float) {
        val tts = engine ?: error("TTS is not initialized")
        tts.stop()
        tts.setSpeechRate(rate)
        val maxLength = TextToSpeech.getMaxSpeechInputLength().coerceAtMost(MAX_CHUNK_CHARS)
        val chunks = splitText(text, maxLength)
        chunks.forEachIndexed { index, chunk ->
            val queueMode = if (index == 0) TextToSpeech.QUEUE_FLUSH else TextToSpeech.QUEUE_ADD
            val params = Bundle()
            tts.speak(chunk, queueMode, params, "zh-${utteranceCounter.incrementAndGet()}")
        }
        Log.i(TAG, "queued chunks=${chunks.size} chars=${text.length} rate=$rate")
    }

    private fun splitText(text: String, maxLength: Int): List<String> {
        if (text.length <= maxLength) return listOf(text)
        val result = mutableListOf<String>()
        var cursor = 0
        while (cursor < text.length) {
            var end = minOf(text.length, cursor + maxLength)
            if (end < text.length) {
                val boundary = text.lastIndexOfAny(charArrayOf('。', '！', '？', '\n', '；'), end - 1)
                if (boundary > cursor + maxLength / 3) end = boundary + 1
            }
            result += text.substring(cursor, end)
            cursor = end
        }
        return result
    }

    fun shutdown() {
        pending.clear()
        engine?.stop()
        engine?.shutdown()
        engine = null
        initialized = false
    }

    companion object {
        private const val TAG = "zhihu-tts"
        private const val MAX_TEXT_CHARS = 500_000
        private const val MAX_CHUNK_CHARS = 3_500
    }
}
