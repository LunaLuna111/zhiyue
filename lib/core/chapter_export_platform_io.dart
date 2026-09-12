import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const _androidExportChannel = MethodChannel(
  'com.zhiyue.client/document_export',
);

Future<String> saveChapterExportPlatform({
  required String fileName,
  required String mimeType,
  required Uint8List bytes,
}) async {
  if (bytes.isEmpty || bytes.length > 32 * 1024 * 1024) {
    throw ArgumentError.value(bytes.length, 'bytes', '导出文件大小无效');
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    final result = await _androidExportChannel.invokeMapMethod<String, dynamic>(
      'save',
      {'name': fileName, 'mimeType': mimeType, 'bytes': bytes},
    );
    final location = result?['location']?.toString().trim();
    return location == null || location.isEmpty ? '下载/知阅/$fileName' : location;
  }

  final directories = <Directory>[];
  try {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) directories.add(downloads);
  } catch (_) {
    // Fall through to an app-owned directory on restricted/sandboxed hosts.
  }
  try {
    final documents = await getApplicationDocumentsDirectory();
    directories.add(Directory('${documents.path}${Platform.pathSeparator}知阅'));
  } catch (_) {
    // A missing path_provider implementation is reported below with context.
  }
  Object? lastError;
  for (final directory in directories) {
    try {
      if (!directory.existsSync()) await directory.create(recursive: true);
      final target = _availableExportTarget(directory, fileName);
      await target.writeAsBytes(bytes, flush: true);
      return target.path;
    } on Object catch (error) {
      lastError = error;
    }
  }
  throw StateError('无法写入桌面下载目录${lastError == null ? '' : '：$lastError'}');
}

File _availableExportTarget(Directory directory, String fileName) {
  final separator = fileName.lastIndexOf('.');
  final stem = separator > 0 ? fileName.substring(0, separator) : fileName;
  final extension = separator > 0 ? fileName.substring(separator) : '';
  for (var suffix = 0; suffix < 10000; suffix += 1) {
    final candidateName = suffix == 0 ? fileName : '$stem ($suffix)$extension';
    final candidate = File(
      '${directory.path}${Platform.pathSeparator}$candidateName',
    );
    if (!candidate.existsSync()) return candidate;
  }
  throw StateError('导出目录中同名文件过多');
}
