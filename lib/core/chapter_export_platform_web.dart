import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<String> saveChapterExportPlatform({
  required String fileName,
  required String mimeType,
  required Uint8List bytes,
}) async {
  if (bytes.isEmpty || bytes.length > 32 * 1024 * 1024) {
    throw ArgumentError.value(bytes.length, 'bytes', '导出文件大小无效');
  }
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return '浏览器下载/$fileName';
}
