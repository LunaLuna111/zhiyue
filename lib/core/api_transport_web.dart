import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:zhihu_api/zhihu_api.dart' as zhihu_api;

import 'api_response.dart';

/// Browser preview transport. It can only call the loopback, GET-only bridge.
/// Session credentials are deliberately discarded even if a caller supplies
/// them, so browser storage and bridge logs never receive account material.
class ApiTransport implements zhihu_api.ApiTransport {
  ApiTransport() : _client = http.Client();

  final http.Client _client;

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    if (zhihu_api.ZhihuApiTransportPolicy.isLensVideoMetadataUri(uri)) {
      throw const ApiTransportException('浏览器预览暂不代理 Lens 视频元数据；请使用回答内已有播放列表');
    }
    if (method != 'GET' || body != null) {
      throw const ApiTransportException(
        '桌面浏览器预览只允许访客 GET；POST 请在 Android/macOS 原生客户端中执行',
      );
    }
    final previewUri = zhihu_api.ZhihuApiTransportPolicy.browserBridgeUri(uri);
    try {
      final request = http.Request(method, previewUri)
        ..followRedirects = false
        ..maxRedirects = 0;
      for (final entry in headers.entries) {
        if (zhihu_api.ZhihuApiTransportPolicy.browserAllowedHeaders.contains(
          entry.key.toLowerCase(),
        )) {
          request.headers[entry.key] = entry.value;
        }
      }
      final response = await _client
          .send(request)
          .timeout(const Duration(seconds: 35));
      final builder = BytesBuilder(copy: false);
      var length = 0;
      await for (final chunk in response.stream.timeout(
        const Duration(seconds: 35),
      )) {
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
          decoded = jsonDecode(utf8.decode(bytes, allowMalformed: false));
        } on FormatException {
          decoded = null;
        }
      }
      return ApiResponse(
        uri: uri,
        statusCode: response.statusCode,
        bodyBytes: bytes.length,
        json: decoded,
        headers: {
          'content-type': ?response.headers['content-type'],
          'x-request-id': ?response.headers['x-request-id'],
        },
        rawBody: bytes,
      );
    } on ApiTransportException {
      rethrow;
    } on TimeoutException {
      throw const ApiTransportException('桌面预览桥请求超时');
    } on http.ClientException {
      throw const ApiTransportException(
        '未连接本地桌面预览桥；请用 scripts/40_run_flutter_desktop_preview.sh 启动',
      );
    }
  }

  @override
  void close() => _client.close();
}
