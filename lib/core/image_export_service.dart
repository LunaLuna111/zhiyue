import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Shared image preview export path for answer and comment media.
///
/// Keeping the download, MIME detection and platform channel contract in one
/// place prevents the two viewers from drifting (the old answer path always
/// used a `.jpg` filename even for PNG/WebP bytes).
class ImageExportService {
  ImageExportService._();

  static const _channel = MethodChannel(
    'com.zhiyue.client/document_export',
  );

  static Future<String?> saveNetworkImage(
    String url, {
    Map<String, String> headers = const <String, String>{},
    String filePrefix = 'zhiyue',
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('图片地址不是安全 HTTPS 地址');
    }
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('图片下载失败');
    }
    final mimeType = _mimeType(response.headers['content-type'], uri.path);
    final extension = switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final result = await _channel.invokeMethod<dynamic>('saveImageToGallery', {
      'name':
          '${_safePrefix(filePrefix)}_${DateTime.now().millisecondsSinceEpoch}.$extension',
      'mimeType': mimeType,
      'bytes': response.bodyBytes,
    });
    if (result is Map) return result['location']?.toString();
    return null;
  }
}

String _mimeType(String? header, String path) {
  final value = header?.split(';').first.trim().toLowerCase() ?? '';
  if (const {'image/jpeg', 'image/png', 'image/webp'}.contains(value)) {
    return value;
  }
  final lowerPath = path.toLowerCase();
  if (lowerPath.endsWith('.png')) return 'image/png';
  if (lowerPath.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

String _safePrefix(String value) {
  final normalized = value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
  if (normalized.isEmpty) return 'zhiyue';
  final length = normalized.length > 32 ? 32 : normalized.length;
  return normalized.substring(0, length);
}
