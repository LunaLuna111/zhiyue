import 'package:flutter/services.dart';

/// A single image returned by Android's system document picker.
///
/// The native side reads the content URI before returning, so callers never
/// need broad filesystem permissions and the URI cannot go stale while an
/// upload is in progress.
class NativePickedImage {
  const NativePickedImage({
    required this.bytes,
    required this.mimeType,
    required this.fileName,
  });

  final Uint8List bytes;
  final String mimeType;
  final String fileName;
}

class NativeImagePicker {
  NativeImagePicker._();

  static const _channel = MethodChannel(
    'com.zhiyue.client/media_picker',
  );

  static Future<NativePickedImage?> pickSingleImage() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'pickSingleImage',
    );
    if (result == null) return null;
    final rawBytes = result['bytes'];
    final bytes = switch (rawBytes) {
      Uint8List value => value,
      List value => Uint8List.fromList(value.cast<int>()),
      _ => throw const FormatException('系统图片选择器返回了无效图片'),
    };
    if (bytes.isEmpty) throw const FormatException('所选图片为空');
    final mimeType = (result['mimeType'] as String?)?.trim().toLowerCase();
    final fileName = (result['fileName'] as String?)?.trim();
    if (mimeType == null || !mimeType.startsWith('image/')) {
      throw const FormatException('所选文件不是图片');
    }
    return NativePickedImage(
      bytes: bytes,
      mimeType: mimeType,
      fileName: fileName == null || fileName.isEmpty ? 'profile.jpg' : fileName,
    );
  }
}
