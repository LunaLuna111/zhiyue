import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'webdav_client.dart';
import 'webdav_models.dart';

/// A sync client backed by a folder selected through Android's system picker.
///
/// The native side owns the persistable tree URI. Dart only sends relative
/// file names, so the selected provider (including OneDrive) remains behind
/// Android's DocumentsProvider API.
class OneDriveFolderClient implements SyncFileClient {
  OneDriveFolderClient({required this.settings});

  static const MethodChannel _channel = MethodChannel(
    'com.zhiyue.client/cloud_folder',
  );

  final WebDavSettings settings;

  static bool get isAvailable =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<String?> pickFolder() async {
    if (!isAvailable) throw UnsupportedError('Android folder picker required');
    return _channel.invokeMethod<String?>('pickFolder');
  }

  static Future<bool> hasFolder() async {
    if (!isAvailable) return false;
    return await _channel.invokeMethod<bool>('hasFolder') ?? false;
  }

  static Future<void> clearFolder() async {
    if (!isAvailable) return;
    await _channel.invokeMethod<void>('clearFolder');
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> ensureDirectory([String relative = '']) async {
    _checkAvailable();
    await _channel.invokeMethod<void>('ensureDirectory', {
      'path': _path(relative),
    });
  }

  @override
  Future<void> testConnection() async {
    _checkAvailable();
    await _channel.invokeMethod<void>('testConnection');
    await ensureDirectory();
  }

  @override
  Future<List<int>?> getBytes(String relative) async {
    _checkAvailable();
    final value = await _channel.invokeMethod<Object?>('read', {
      'path': _path(relative),
    });
    if (value == null) return null;
    if (value is Uint8List) return value;
    if (value is List<int>) return List<int>.from(value);
    throw const FormatException('Invalid folder file response');
  }

  @override
  Future<void> putBytes(
    String relative,
    List<int> body, {
    String contentType = 'application/octet-stream',
  }) async {
    _checkAvailable();
    await _channel.invokeMethod<void>('write', {
      'path': _path(relative),
      'bytes': Uint8List.fromList(body),
      'contentType': contentType,
    });
  }

  @override
  Future<Map<String, dynamic>?> getJson(String relative) async {
    final body = await getBytes(relative);
    if (body == null) return null;
    final decoded = jsonDecode(utf8.decode(body));
    if (decoded is! Map) throw const FormatException('Invalid JSON object');
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }

  @override
  Future<void> putJson(String relative, Map<String, dynamic> value) async {
    await putBytes(
      relative,
      utf8.encode(jsonEncode(value)),
      contentType: 'application/json',
    );
  }

  String _path(String relative) {
    final base = settings.remoteDirectory.trim().replaceAll('\\', '/');
    final child = relative.trim().replaceAll('\\', '/');
    if (child.isEmpty) return base;
    if (base.isEmpty) return child;
    return '$base/$child';
  }

  void _checkAvailable() {
    if (!isAvailable) throw UnsupportedError('Android folder picker required');
  }
}
