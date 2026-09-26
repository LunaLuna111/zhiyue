import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cloud_sync_auth.dart';
import 'webdav_client.dart';
import 'webdav_models.dart';

/// Stores sync files in the OneDrive app folder through Microsoft Graph.
class CloudSyncClient implements SyncFileClient {
  CloudSyncClient({
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
  final Future<String> Function(WebDavProviderKind)? tokenProvider;
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
    await _oneDriveRoot();
    await ensureDirectory();
  }

  @override
  Future<void> ensureDirectory([String relative = '']) async {
    await _oneDriveRoot();
    final segments = _safeSegments(_root, relative);
    const root = 'https://graph.microsoft.com/v1.0/me/drive/special/approot';
    var path = '';
    for (final segment in segments) {
      final children = path.isEmpty
          ? '$root/children'
          : '$root:/$path:/children';
      final response = await _request(
        'POST',
        Uri.parse(children),
        body: utf8.encode(
          jsonEncode({
            'name': segment,
            'folder': <String, Object>{},
            '@microsoft.graph.conflictBehavior': 'fail',
          }),
        ),
        contentType: 'application/json',
      );
      if (response.statusCode != 201 && response.statusCode != 409) {
        _fail('创建目录', response);
      }
      path = path.isEmpty
          ? Uri.encodeComponent(segment)
          : '$path/${Uri.encodeComponent(segment)}';
    }
  }

  @override
  Future<List<int>?> getBytes(String relative) async {
    final response = await _request('GET', _contentUri(relative));
    if (response.statusCode == 404) return null;
    if (response.statusCode == 302) {
      final location = Uri.tryParse(response.headers['location'] ?? '');
      if (location == null ||
          location.scheme != 'https' ||
          location.userInfo.isNotEmpty) {
        throw const FormatException('OneDrive 下载地址无效');
      }
      // Graph returns a short-lived preauthenticated URL. Never send the Graph
      // bearer token to the redirect target.
      final request = http.Request('GET', location)..followRedirects = false;
      final streamed = await _http
          .send(request)
          .timeout(const Duration(seconds: 45));
      final bytes = await streamed.stream.toBytes();
      if (bytes.length > _maxBytes) {
        throw const FormatException('云端响应超过 64 MiB 限制');
      }
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw StateError('云盘下载失败（HTTP ${streamed.statusCode}）');
      }
      return bytes;
    }
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
    final response = await _request(
      'PUT',
      _contentUri(relative),
      body: body,
      contentType: contentType,
    );
    _requireSuccess('上传', response);
  }

  @override
  Future<Map<String, dynamic>?> getJson(String relative) async {
    final bytes = await getBytes(relative);
    if (bytes == null) return null;
    final value = jsonDecode(utf8.decode(bytes));
    if (value is! Map) throw const FormatException('云端同步 JSON 不是对象');
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  @override
  Future<void> putJson(String relative, Map<String, dynamic> value) => putBytes(
    relative,
    utf8.encode(jsonEncode(value)),
    contentType: 'application/json',
  );

  Future<void> _oneDriveRoot() async {
    final response = await _request(
      'GET',
      Uri.parse('https://graph.microsoft.com/v1.0/me/drive/special/approot'),
    );
    _requireSuccess('打开应用文件夹', response);
  }

  Uri _contentUri(String relative) {
    final path = _safeSegments(
      _root,
      relative,
    ).map(Uri.encodeComponent).join('/');
    return Uri.parse(
      'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$path:/content',
    );
  }

  static List<String> _safeSegments(String root, String relative) {
    final segments = <String>[];
    for (final input in [root, relative]) {
      for (final segment in input.replaceAll('\\', '/').split('/')) {
        if (segment.isEmpty || segment == '.') continue;
        if (segment == '..' || segment.codeUnits.any((c) => c < 0x20)) {
          throw const FormatException('云端同步路径无效');
        }
        segments.add(segment);
      }
    }
    return segments;
  }

  Future<http.Response> _request(
    String method,
    Uri uri, {
    List<int>? body,
    String? contentType,
  }) async {
    if (_closed) throw StateError('云盘客户端已经关闭');
    if (uri.scheme != 'https' || uri.host != 'graph.microsoft.com') {
      throw const FormatException('云盘请求地址无效');
    }
    final token =
        await (tokenProvider?.call(settings.provider) ??
            _auth.accessToken(settings.provider));
    final request = http.Request(method, uri)
      ..followRedirects = false
      ..headers['Authorization'] = 'Bearer $token';
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
    _fail(operation, response);
  }

  Never _fail(String operation, http.Response response) =>
      throw StateError('云盘$operation失败（HTTP ${response.statusCode}）');
}
