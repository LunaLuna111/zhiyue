import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cloud_sync_auth.dart';
import 'webdav_client.dart';
import 'webdav_models.dart';

/// Drive API adapter that writes only inside the user's private appDataFolder.
class GoogleDriveSyncClient implements SyncFileClient {
  GoogleDriveSyncClient({
    required this.settings,
    CloudSyncAuth? auth,
    http.Client? httpClient,
    this.tokenProvider,
  }) : _auth = auth ?? CloudSyncAuth.instance,
       _http = httpClient ?? http.Client();

  static const _maxBytes = 64 * 1024 * 1024;
  static const _namespace = String.fromEnvironment('CLOUD_SYNC_NAMESPACE');
  final WebDavSettings settings;
  final CloudSyncAuth _auth;
  final http.Client _http;
  final Future<String> Function()? tokenProvider;
  bool _closed = false;

  String get _root => [
    if (_namespace.isNotEmpty) _namespace,
    settings.remoteDirectory.trim().replaceAll('\\', '/'),
  ].join('/');

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _http.close();
  }

  @override
  Future<void> testConnection() async {
    await _listFiles('__zhiyue_connection_check__');
  }

  @override
  Future<void> ensureDirectory([String relative = '']) async {
    // appDataFolder provides an app-private flat namespace; paths are encoded
    // into opaque names so each synced logical file stays independent.
    _fileName(relative);
  }

  @override
  Future<List<int>?> getBytes(String relative) async {
    final id = await _findFile(_fileName(relative));
    if (id == null) return null;
    final response = await _request(
      'GET',
      Uri.https('www.googleapis.com', '/drive/v3/files/$id', {'alt': 'media'}),
    );
    if (response.statusCode == 404) return null;
    _requireSuccess('下载', response);
    return response.bodyBytes;
  }

  @override
  Future<void> putBytes(
    String relative,
    List<int> body, {
    String contentType = 'application/octet-stream',
  }) async {
    if (body.length > _maxBytes) {
      throw const FormatException('同步文件超过 64 MiB 限制');
    }
    final name = _fileName(relative);
    final id = await _findFile(name);
    if (body.length > 4 * 1024 * 1024) {
      await _resumableUpload(name, id, body, contentType);
      return;
    }
    if (id == null) {
      const boundary = 'zhiyue_drive_sync';
      final metadata = jsonEncode({
        'name': name,
        'parents': ['appDataFolder'],
      });
      final payload = <int>[
        ...utf8.encode(
          '--$boundary\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n$metadata\r\n',
        ),
        ...utf8.encode('--$boundary\r\nContent-Type: $contentType\r\n\r\n'),
        ...body,
        ...utf8.encode('\r\n--$boundary--\r\n'),
      ];
      final response = await _request(
        'POST',
        Uri.https('www.googleapis.com', '/upload/drive/v3/files', {
          'uploadType': 'multipart',
        }),
        body: payload,
        contentType: 'multipart/related; boundary=$boundary',
      );
      _requireSuccess('上传', response);
    } else {
      final response = await _request(
        'PATCH',
        Uri.https('www.googleapis.com', '/upload/drive/v3/files/$id', {
          'uploadType': 'media',
        }),
        body: body,
        contentType: contentType,
      );
      _requireSuccess('上传', response);
    }
  }

  @override
  Future<Map<String, dynamic>?> getJson(String relative) async {
    final bytes = await getBytes(relative);
    if (bytes == null) return null;
    final value = jsonDecode(utf8.decode(bytes));
    if (value is! Map) throw const FormatException('Google Drive 同步 JSON 不是对象');
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  @override
  Future<void> putJson(String relative, Map<String, dynamic> value) => putBytes(
    relative,
    utf8.encode(jsonEncode(value)),
    contentType: 'application/json',
  );

  Future<String?> _findFile(String name) async {
    final files = await _listFiles(name);
    if (files.isEmpty) return null;
    return files.first['id']?.toString();
  }

  Future<List<Map<String, dynamic>>> _listFiles(String name) async {
    final escaped = name.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
    final response = await _request(
      'GET',
      Uri.https('www.googleapis.com', '/drive/v3/files', {
        'spaces': 'appDataFolder',
        'q': "name = '$escaped' and trashed = false",
        'fields': 'files(id,name),nextPageToken',
        'pageSize': '2',
      }),
    );
    _requireSuccess('读取文件列表', response);
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map || decoded['files'] is! List) {
      throw const FormatException('Google Drive 文件列表无效');
    }
    return (decoded['files'] as List)
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList(growable: false);
  }

  Future<void> _resumableUpload(
    String name,
    String? id,
    List<int> body,
    String contentType,
  ) async {
    final isCreate = id == null;
    final start = await _request(
      isCreate ? 'POST' : 'PATCH',
      Uri.https(
        'www.googleapis.com',
        isCreate ? '/upload/drive/v3/files' : '/upload/drive/v3/files/$id',
        {'uploadType': 'resumable'},
      ),
      body: isCreate
          ? utf8.encode(
              jsonEncode({
                'name': name,
                'parents': ['appDataFolder'],
              }),
            )
          : const [],
      contentType: 'application/json',
      headers: {
        'X-Upload-Content-Type': contentType,
        'X-Upload-Content-Length': '${body.length}',
      },
    );
    _requireSuccess('启动上传', start);
    final session = Uri.tryParse(start.headers['location'] ?? '');
    if (session == null ||
        session.scheme != 'https' ||
        session.host != 'www.googleapis.com' ||
        session.userInfo.isNotEmpty) {
      throw const FormatException('Google Drive 上传地址无效');
    }
    final response = await _request(
      'PUT',
      session,
      body: body,
      contentType: contentType,
    );
    _requireSuccess('上传', response);
  }

  String _fileName(String relative) {
    final parts = <String>[];
    for (final input in [_root, relative]) {
      for (final part in input.replaceAll('\\', '/').split('/')) {
        if (part.isEmpty || part == '.') continue;
        if (part == '..' || part.codeUnits.any((unit) => unit < 0x20)) {
          throw const FormatException('云端同步路径无效');
        }
        parts.add(part);
      }
    }
    return 'zhiyue_${base64Url.encode(utf8.encode(parts.join('/'))).replaceAll('=', '')}';
  }

  Future<http.Response> _request(
    String method,
    Uri uri, {
    List<int>? body,
    String? contentType,
    Map<String, String> headers = const {},
  }) async {
    if (_closed) throw StateError('Google Drive 客户端已经关闭');
    if (uri.scheme != 'https' || uri.host != 'www.googleapis.com') {
      throw const FormatException('Google Drive 请求地址无效');
    }
    final token = await (tokenProvider?.call() ?? _auth.googleAccessToken());
    final request = http.Request(method, uri)
      ..followRedirects = false
      ..headers['Authorization'] = 'Bearer $token'
      ..headers.addAll(headers);
    if (contentType != null) request.headers['Content-Type'] = contentType;
    if (body != null) request.bodyBytes = body;
    final streamed = await _http
        .send(request)
        .timeout(const Duration(seconds: 45));
    if (streamed.contentLength != null && streamed.contentLength! > _maxBytes) {
      await streamed.stream.drain();
      throw const FormatException('云端响应超过 64 MiB 限制');
    }
    final bytes = await streamed.stream.toBytes();
    if (bytes.length > _maxBytes) {
      throw const FormatException('云端响应超过 64 MiB 限制');
    }
    return http.Response.bytes(
      bytes,
      streamed.statusCode,
      headers: streamed.headers,
    );
  }

  void _requireSuccess(String operation, http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw StateError('Google Drive $operation 失败（HTTP ${response.statusCode}）');
  }
}
