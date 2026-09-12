package com.zhiyue.client

import android.graphics.Bitmap
import android.graphics.Color
import com.google.zxing.BarcodeFormat
import com.google.zxing.qrcode.QRCodeWriter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class QrCodeController {
    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        if (call.method != "encode") return false
        try {
            val content = call.argument<String>("content")?.trim().orEmpty()
            val size = (call.argument<Int>("size") ?: 720).coerceIn(128, 1_024)
            if (content.isEmpty() || content.length > 2_048) {
                throw IllegalArgumentException("二维码内容无效")
            }
            val matrix = QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, size, size)
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            for (x in 0 until size) {
                for (y in 0 until size) {
                    bitmap.setPixel(x, y, if (matrix.get(x, y)) Color.BLACK else Color.WHITE)
                }
            }
            val bytes = ByteArrayOutputStream().use { output ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)
                bitmap.recycle()
                output.toByteArray()
            }
            result.success(bytes)
        } catch (error: Exception) {
            result.error("qr_encode_failed", "二维码生成失败", null)
        }
        return true
    }
}
