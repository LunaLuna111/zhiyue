import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'webdav_models.dart';

class WebDavResponse {
  const WebDavResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  final int statusCode;
  final Map<String, String> headers;
  final List<int> body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isNotFound => statusCode == 404;
}

abstract interface class WebDavTransport {
  Future<WebDavResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    List<int> body,
  });

  Future<void> close();
}

class HttpWebDavTransport implements WebDavTransport {
  HttpWebDavTransport({http.Client? client})
    : _client = client ?? http.Client();

  static const _maxRedirects = 3;

  final http.Client _client;

  @override
  Future<WebDavResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    List<int> body = const [],
  }) async {
    var current = uri;
    http.StreamedResponse? response;
    for (var redirect = 0; ; redirect++) {
      final request = http.Request(method, current)
        ..followRedirects = false
        ..maxRedirects = 0
        ..headers.addAll(headers)
        ..bodyBytes = body;
      response = await _client.send(request);
      final location = response.headers['location']?.trim();
      if (response.statusCode < 300 ||
          response.statusCode >= 400 ||
          location == null ||
          location.isEmpty) {
        break;
      }
      await response.stream.drain();
      if (redirect >= _maxRedirects) {
        throw StateError('WebDAV 重定向次数过多');
      }
      final next = current.resolve(location);
      if (!_isSafeRedirect(current, next)) {
        throw const FormatException('WebDAV 重定向必须保持 HTTPS 且同源');
      }
      current = next;
    }
    final finalResponse = response;
    final bytes = await finalResponse.stream.toBytes();
    return WebDavResponse(
      statusCode: finalResponse.statusCode,
      headers: finalResponse.headers,
      body: bytes,
    );
  }

  @override
  Future<void> close() async => _client.close();

  static bool _isSafeRedirect(Uri from, Uri to) {
    if (from.scheme.toLowerCase() != 'https' ||
        to.scheme.toLowerCase() != 'https') {
      return false;
    }
    return from.host.toLowerCase() == to.host.toLowerCase() &&
        _effectivePort(from) == _effectivePort(to);
  }

  static int _effectivePort(Uri uri) => uri.hasPort ? uri.port : 443;
}

abstract interface class SyncFileClient {
  Future<void> close();
  Future<void> ensureDirectory([String relative]);
  Future<void> testConnection();
  Future<List<int>?> getBytes(String relative);
  Future<void> putBytes(String relative, List<int> body, {String contentType});
  Future<Map<String, dynamic>?> getJson(String relative);
  Future<void> putJson(String relative, Map<String, dynamic> value);
}

class WebDavClient implements SyncFileClient {
  WebDavClient({required this.settings, WebDavTransport? transport})
    : _transport = transport ?? HttpWebDavTransport();

  static const _maxResponseBytes = 64 * 1024 * 1024;
  static const _maxAttempts = 3;

  final WebDavSettings settings;
  final WebDavTransport _transport;

  bool _closed = false;

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _transport.close();
  }

  @override
  Future<void> ensureDirectory([String relative = '']) async {
    final directory = _normalizeRelative(relative);
    final segments = directory.isEmpty
        ? const <String>[]
        : directory.split('/');
    var current = '';
    for (final segment in segments) {
      current = current.isEmpty ? segment : '$current/$segment';
      final response = await _request('MKCOL', '$current/');
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204 &&
          response.statusCode != 405) {
        throw _failure('MKCOL', relative: '$current/', response: response);
      }
    }
  }

  @override
  Future<void> testConnection() async {
    await ensureDirectory();
    final response = await _request(
      'PROPFIND',
      '',
      headers: const {'Depth': '0'},
    );
    if (response.statusCode != 200 && response.statusCode != 207) {
      throw _failure('PROPFIND', relative: '', response: response);
    }
  }

  @override
  Future<List<int>?> getBytes(String relative) async {
    final response = await _request('GET', relative);
    if (response.isNotFound) return null;
    if (!response.isSuccess) {
      throw _failure('GET', relative: relative, response: response);
    }
    return response.body;
  }

  @override
  Future<void> putBytes(
    String relative,
    List<int> body, {
    String contentType = 'application/octet-stream',
  }) async {
    if (body.length > _maxResponseBytes) {
      throw const FormatException('WebDAV 同步文件超过 64 MiB 限制');
    }
    final response = await _request(
      'PUT',
      relative,
      headers: {'Content-Type': contentType},
      body: body,
    );
    if (!response.isSuccess) {
      throw _failure('PUT', relative: relative, response: response);
    }
  }

  @override
  Future<Map<String, dynamic>?> getJson(String relative) async {
    final bytes = await getBytes(relative);
    if (bytes == null) return null;
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) throw const FormatException('远程同步 JSON 不是对象');
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('远程同步 JSON 无法解析');
    }
  }

  @override
  Future<void> putJson(String relative, Map<String, dynamic> value) async {
    await putBytes(
      relative,
      utf8.encode(jsonEncode(value)),
      contentType: 'application/json; charset=utf-8',
    );
  }

  Future<WebDavResponse> _request(
    String method,
    String relative, {
    Map<String, String> headers = const {},
    List<int> body = const [],
  }) async {
    if (_closed) throw StateError('WebDAV 客户端已经关闭');
    final uri = _buildUri(relative);
    final requestHeaders = <String, String>{
      'Accept': 'application/json, text/plain, */*',
      ..._authorizationHeaders(),
      ...headers,
    };
    Object? lastError;
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        final response = await _transport
            .send(method: method, uri: uri, headers: requestHeaders, body: body)
            .timeout(const Duration(seconds: 30));
        if (response.body.length > _maxResponseBytes) {
          throw const FormatException('WebDAV 响应超过 64 MiB 限制');
        }
        if (_shouldRetryStatus(response.statusCode) &&
            attempt + 1 < _maxAttempts) {
          await Future<void>.delayed(_retryDelay(attempt));
          continue;
        }
        return response;
      } on WebDavRequestFailure {
        rethrow;
      } on FormatException {
        rethrow;
      } on StateError {
        rethrow;
      } on Object catch (error) {
        lastError = error;
        if (attempt + 1 >= _maxAttempts) break;
        await Future<void>.delayed(_retryDelay(attempt));
      }
    }
    throw WebDavRequestFailure(
      method: method,
      uri: uri,
      statusCode: 0,
      detail: lastError?.runtimeType.toString() ?? 'UnknownError',
    );
  }

  static bool _shouldRetryStatus(int statusCode) =>
      statusCode == 408 ||
      statusCode == 425 ||
      statusCode == 429 ||
      (statusCode >= 500 && statusCode < 600);

  static Duration _retryDelay(int attempt) => switch (attempt) {
    0 => const Duration(milliseconds: 250),
    _ => const Duration(milliseconds: 750),
  };

  Map<String, String> _authorizationHeaders() {
    if (settings.authMethod == WebDavAuthMethod.bearer) {
      return {'Authorization': 'Bearer ${settings.secret}'};
    }
    final value = base64Encode(
      utf8.encode('${settings.username}:${settings.secret}'),
    );
    return {'Authorization': 'Basic $value'};
  }

  Uri _buildUri(String relative) {
    final endpoint = settings.endpointUri;
    if (endpoint == null) throw const FormatException('WebDAV 地址无效');
    final root = <String>[
      ..._segments(endpoint.path),
      ..._segments(settings.remoteDirectory),
    ];
    final child = _normalizeRelative(relative);
    final segments = <String>[...root, ..._segments(child)];
    final trailingSlash =
        relative.trim().endsWith('/') || relative.trim().isEmpty;
    final path =
        '/${segments.map(Uri.encodeComponent).join('/')}'
        '${trailingSlash ? '/' : ''}';
    return endpoint.replace(path: path, query: '', fragment: '');
  }

  static String _normalizeRelative(String value) {
    final normalized = value
        .trim()
        .replaceAll('\\', '/')
        .split('/')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty && part != '.')
        .join('/');
    if (normalized.split('/').any((part) => part == '..')) {
      throw const FormatException('WebDAV 相对路径不能包含 ..');
    }
    return normalized;
  }

  static List<String> _segments(String value) => value
      .split('/')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty && part != '.')
      .toList(growable: false);

  WebDavRequestFailure _failure(
    String method, {
    required String relative,
    required WebDavResponse response,
  }) => WebDavRequestFailure(
    method: method,
    uri: _buildUri(relative),
    statusCode: response.statusCode,
    detail: _responseDetail(response),
  );

  static String _responseDetail(WebDavResponse response) {
    if (response.body.isEmpty) return '';
    final text = utf8.decode(response.body, allowMalformed: true).trim();
    if (text.length <= 320) return text;
    return '${text.substring(0, 320)}…';
  }
}
