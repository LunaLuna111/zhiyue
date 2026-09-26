import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:zhihu_api/zhihu_api.dart' as zhihu_api;

import 'api_response.dart';

const _backgroundJsonDecodeThreshold = 64 * 1024;

Object? _decodeJsonBytesSync(Uint8List bytes) =>
    jsonDecode(utf8.decode(bytes, allowMalformed: false));

Future<Object?> _decodeJsonBytes(Uint8List bytes) {
  if (bytes.length < _backgroundJsonDecodeThreshold) {
    return Future<Object?>.value(_decodeJsonBytesSync(bytes));
  }
  // Recommendation and paging payloads can be hundreds of KiB. Parsing them
  // on the UI isolate makes the network completion coincide with a long
  // frame while the user is still flinging the list.
  return compute(_decodeJsonBytesSync, bytes);
}

class ApiTransport implements zhihu_api.ApiTransport {
  ApiTransport() : _http = HttpClient() {
    _http.connectionTimeout = const Duration(seconds: 20);
    _http.userAgent = null;
    if (kDebugMode && (debugLoginCaptureProxyPort > 0 || debugProxyPort > 0)) {
      _http.findProxy = (uri) {
        if (debugLoginCaptureProxyPort > 0 &&
            isApprovedLoginCaptureTarget(uri)) {
          return 'PROXY 127.0.0.1:$debugLoginCaptureProxyPort';
        }
        if (debugProxyPort > 0 && isApprovedSaltRelayTarget(uri)) {
          return 'PROXY 127.0.0.1:$debugProxyPort';
        }
        return 'DIRECT';
      };
    }
  }

  final HttpClient _http;
  static const debugProxyPort = int.fromEnvironment('ZH_DEBUG_PROXY_PORT');
  static const debugLoginCaptureProxyPort = int.fromEnvironment(
    'ZH_LOGIN_CAPTURE_PROXY_PORT',
  );
  @visibleForTesting
  static bool isApprovedLoginCaptureTarget(Uri uri) =>
      zhihu_api.ZhihuApiTransportPolicy.isApprovedLoginCaptureTarget(uri);

  @visibleForTesting
  static bool isApprovedLoginCaptureRequest(
    String method,
    Uri uri,
    List<int>? body,
  ) => zhihu_api.ZhihuApiTransportPolicy.isApprovedLoginCaptureRequest(
    method,
    uri,
    body,
  );

  @visibleForTesting
  static bool isApprovedSaltRelayTarget(Uri uri) =>
      zhihu_api.ZhihuApiTransportPolicy.isApprovedSaltRelayTarget(uri);

  @visibleForTesting
  static bool isApprovedSaltRelayRequest(
    String method,
    Uri uri,
    List<int>? body,
  ) => zhihu_api.ZhihuApiTransportPolicy.isApprovedSaltRelayRequest(
    method,
    uri,
    body,
  );

  @visibleForTesting
  static bool isApprovedNativeHttpTarget(Uri uri) =>
      zhihu_api.ZhihuApiTransportPolicy.isApprovedNativeHttpTarget(uri);

  @visibleForTesting
  static bool isApprovedNativeHttpRequest(
    String method,
    Uri uri,
    List<int>? body,
  ) => zhihu_api.ZhihuApiTransportPolicy.isApprovedNativeHttpRequest(
    method,
    uri,
    body,
  );

  static const _androidNativeHttp = MethodChannel(
    'com.zhiyue.client/native_http',
  );
  static const _androidSaltRelay = MethodChannel(
    'com.zhiyue.client/debug_salt_relay',
  );

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    if (zhihu_api.ZhihuApiTransportPolicy.isLensVideoMetadataUri(uri) &&
        headers.keys.any(
          (key) => !const {'accept', 'user-agent'}.contains(key.toLowerCase()),
        )) {
      throw const ApiTransportException('Lens 视频元数据请求拒绝会话 Header');
    }
    if (Platform.isAndroid &&
        kDebugMode &&
        debugLoginCaptureProxyPort > 0 &&
        isApprovedLoginCaptureTarget(uri)) {
      return _sendAndroidLoginCapture(
        method: method,
        uri: uri,
        headers: headers,
        body: body,
        maxResponseBytes: maxResponseBytes,
      );
    }
    if (Platform.isAndroid &&
        kDebugMode &&
        debugProxyPort > 0 &&
        isApprovedSaltRelayTarget(uri)) {
      return _sendAndroidSaltRelay(
        method: method,
        uri: uri,
        headers: headers,
        body: body,
        maxResponseBytes: maxResponseBytes,
      );
    }
    if (Platform.isAndroid) {
      if (!isApprovedNativeHttpRequest(method, uri, body)) {
        throw const ApiTransportException('Android 原生网络通道拒绝未审核的请求');
      }
      return _sendAndroidNativeHttp(
        method: method,
        uri: uri,
        headers: headers,
        body: body,
        maxResponseBytes: maxResponseBytes,
      );
    }
    try {
      final request = await _http
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 25));
      request.followRedirects = false;
      request.maxRedirects = 0;
      for (final entry in headers.entries) {
        request.headers.set(entry.key, entry.value);
      }
      if (body != null) {
        request.contentLength = body.length;
        request.add(body);
      }
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      final builder = BytesBuilder(copy: false);
      var length = 0;
      await for (final chunk in response.timeout(const Duration(seconds: 30))) {
        length += chunk.length;
        if (length > maxResponseBytes) {
          throw const ApiTransportException('响应超过 12 MiB 安全上限');
        }
        builder.add(chunk);
      }
      final bytes = builder.takeBytes();
      Object? decoded;
      if (bytes.isNotEmpty) {
        try {
          decoded = await _decodeJsonBytes(bytes);
        } on FormatException {
          decoded = null;
        }
      }
      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        final lower = name.toLowerCase();
        // Set-Cookie values cannot be comma-joined safely because Expires may
        // itself contain a comma. Preserve all response headers for the
        // explicitly enabled private debug exchange capture.
        responseHeaders[lower] = lower == HttpHeaders.setCookieHeader
            ? values.join('\n')
            : values.join(', ');
      });
      return ApiResponse(
        uri: uri,
        statusCode: response.statusCode,
        bodyBytes: bytes.length,
        json: decoded,
        headers: responseHeaders,
        rawBody: bytes,
      );
    } on ApiTransportException {
      rethrow;
    } on TimeoutException {
      throw const ApiTransportException('请求超时');
    } on HandshakeException {
      throw const ApiTransportException('TLS 校验失败；客户端不会跳过证书验证');
    } on SocketException {
      throw const ApiTransportException('网络不可用或目标主机不可达');
    } on HttpException catch (error) {
      throw ApiTransportException('HTTP 传输失败：${error.message}');
    }
  }

  Future<ApiResponse> _sendAndroidLoginCapture({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    if (!isApprovedLoginCaptureRequest(method, uri, body)) {
      throw const ApiTransportException('登录抓包通道只允许已审核目标的 GET 或有正文 POST');
    }
    try {
      final raw = await _androidSaltRelay
          .invokeMapMethod<String, dynamic>('request', {
            'url': uri.toString(),
            'method': method,
            if (body != null) 'body': Uint8List.fromList(body),
            'headers': headers,
            'maxResponseBytes': maxResponseBytes,
            'proxyPort': debugLoginCaptureProxyPort,
            'loginCapture': true,
          })
          .timeout(const Duration(seconds: 40));
      return _decodeAndroidRelayResponse(raw, operation: '登录抓包');
    } on TimeoutException {
      throw const ApiTransportException('登录抓包请求超时');
    } on PlatformException catch (error) {
      throw ApiTransportException('登录抓包请求失败：${error.code}');
    }
  }

  Future<ApiResponse> _sendAndroidSaltRelay({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    if (!isApprovedSaltRelayRequest(method, uri, body)) {
      throw const ApiTransportException(
        'Android 盐选认证兼容通道只允许 GET 或已审计的正文读取 POST',
      );
    }
    if (headers.entries.every(
      (entry) =>
          entry.key.toLowerCase() != 'x-zh-debug-auth-relay' ||
          entry.value.toLowerCase() != 'salt',
    )) {
      throw const ApiTransportException('Android 盐选认证兼容通道缺少调试标记');
    }
    try {
      final raw = await _androidSaltRelay
          .invokeMapMethod<String, dynamic>('request', {
            'url': uri.toString(),
            'method': method,
            if (body != null) 'body': Uint8List.fromList(body),
            'headers': headers,
            'maxResponseBytes': maxResponseBytes,
            'proxyPort': debugProxyPort,
          })
          .timeout(const Duration(seconds: 40));
      return _decodeAndroidRelayResponse(raw, operation: 'Android 盐选认证兼容');
    } on TimeoutException {
      throw const ApiTransportException('Android 盐选认证兼容请求超时');
    } on PlatformException catch (error) {
      if (error.code == 'SSLHandshakeException' ||
          error.code == 'SSLPeerUnverifiedException') {
        throw const ApiTransportException('TLS 校验失败；客户端不会跳过证书验证');
      }
      throw ApiTransportException('Android 盐选认证兼容请求失败：${error.code}');
    } on MissingPluginException {
      throw const ApiTransportException('当前平台未注册 Android 盐选认证兼容通道');
    }
  }

  Future<ApiResponse> _sendAndroidNativeHttp({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    if (!isApprovedNativeHttpRequest(method, uri, body)) {
      throw const ApiTransportException('Android 原生网络通道拒绝未审核的请求');
    }
    try {
      final raw = await _androidNativeHttp
          .invokeMapMethod<String, dynamic>('request', {
            'url': uri.toString(),
            'method': method,
            if (body != null) 'body': Uint8List.fromList(body),
            'headers': headers,
            'maxResponseBytes': maxResponseBytes,
          })
          .timeout(const Duration(seconds: 40));
      return _decodeAndroidRelayResponse(
        raw,
        operation: 'Android 原生网络',
        maxResponseBytes: maxResponseBytes,
      );
    } on TimeoutException {
      throw const ApiTransportException('Android 原生网络请求超时');
    } on PlatformException catch (error) {
      if (error.code == 'SSLHandshakeException' ||
          error.code == 'SSLPeerUnverifiedException') {
        throw const ApiTransportException('TLS 校验失败；客户端不会跳过证书验证');
      }
      throw ApiTransportException('Android 原生网络请求失败：${error.code}');
    } on MissingPluginException {
      throw const ApiTransportException('当前平台未注册 Android 原生网络通道');
    }
  }

  Future<ApiResponse> _decodeAndroidRelayResponse(
    Map<String, dynamic>? raw, {
    required String operation,
    int maxResponseBytes = 12 * 1024 * 1024,
  }) async {
    if (raw == null || raw['statusCode'] is! int || raw['url'] is! String) {
      throw ApiTransportException('$operation响应格式错误');
    }
    final rawBody = raw['body'];
    final bytes = switch (rawBody) {
      Uint8List value => value,
      List value => Uint8List.fromList(value.cast<int>()),
      _ => throw ApiTransportException('$operation正文格式错误'),
    };
    if (bytes.length > maxResponseBytes) {
      throw const ApiTransportException('响应超过 12 MiB 安全上限');
    }
    Object? decoded;
    if (bytes.isNotEmpty) {
      try {
        decoded = await _decodeJsonBytes(bytes);
      } on FormatException {
        decoded = null;
      }
    }
    final responseHeaders = <String, String>{};
    final rawHeaders = raw['headers'];
    if (rawHeaders is Map) {
      for (final entry in rawHeaders.entries) {
        if (entry.key is String && entry.value is String) {
          responseHeaders[entry.key as String] = entry.value as String;
        }
      }
    }
    return ApiResponse(
      uri: Uri.parse(raw['url'] as String),
      statusCode: raw['statusCode'] as int,
      bodyBytes: bytes.length,
      json: decoded,
      headers: responseHeaders,
      rawBody: bytes,
    );
  }

  @override
  void close() => _http.close(force: false);
}
