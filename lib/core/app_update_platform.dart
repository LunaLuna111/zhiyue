import 'dart:async';

Future<String> writeDownloadedUpdate(
  Stream<List<int>> bytes, {
  required int expectedBytes,
  required void Function(int received, int total) onProgress,
  required bool Function() isCancelled,
}) => throw UnsupportedError('当前平台不支持应用内更新');

Future<void> deleteDownloadedUpdate(String path) async {}
