import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> writeDownloadedUpdate(
  Stream<List<int>> bytes, {
  required int expectedBytes,
  required void Function(int received, int total) onProgress,
  required bool Function() isCancelled,
}) async {
  final directory = await getTemporaryDirectory();
  final target = File(
    '${directory.path}${Platform.pathSeparator}'
    'zhiyue-update-${DateTime.now().microsecondsSinceEpoch}.apk',
  );
  final output = target.openWrite(mode: FileMode.writeOnly);
  var received = 0;
  try {
    await for (final chunk in bytes) {
      if (isCancelled()) throw const UpdateDownloadCancelled();
      received += chunk.length;
      if (received > expectedBytes) {
        throw const FileSystemException('更新包大于签名清单声明的大小');
      }
      output.add(chunk);
      onProgress(received, expectedBytes);
    }
    await output.flush();
    await output.close();
    if (received != expectedBytes) {
      throw const FileSystemException('更新包下载不完整');
    }
    return target.path;
  } catch (_) {
    await output.close().catchError((_) {});
    try {
      await target.delete();
    } catch (_) {}
    rethrow;
  }
}

Future<void> deleteDownloadedUpdate(String path) async {
  if (path.isEmpty) return;
  final target = File(path);
  try {
    if (await target.exists()) await target.delete();
  } catch (_) {
    // The app cache is also reclaimed by Android. Cleanup is best effort.
  }
}

class UpdateDownloadCancelled implements Exception {
  const UpdateDownloadCancelled();

  @override
  String toString() => '更新下载已取消';
}
