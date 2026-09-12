import 'dart:typed_data';

/// Platform-neutral fallback.  Conditional implementations provide an actual
/// file or browser download on supported targets.
Future<String> saveChapterExportPlatform({
  required String fileName,
  required String mimeType,
  required Uint8List bytes,
}) => Future<String>.error(UnsupportedError('当前平台不支持文件导出'));
