import 'package:flutter/foundation.dart' as foundation;
import 'package:zhihu_api/zhihu_api.dart' as zhihu_api;

import 'app_log.dart';
import 'cloud_id_signer.dart';
import 'debug_hooks.dart';
import 'session_store.dart';
import 'api_transport_io.dart'
    if (dart.library.js_interop) 'api_transport_web.dart';
import 'comment_emoticons.dart';
import 'content_interaction_models.dart';
import 'x_zse_signer.dart';
import 'mobile_login_body_encoder.dart';

export 'package:zhihu_api/zhihu_api.dart'
    show
        ZhihuApiClientBootstrapAndDiagnostics,
        ZhihuApiClientContentWrites,
        ZhihuApiClientGuestBootstrap,
        ZhihuApiClientMobileLogin,
        ZhihuApiClientNegativeFeedback,
        ZhihuApiClientQrLogin,
        ZhihuApiClientRequestPipeline,
        ZhihuApiClientRoutes,
        ZhihuApiClientSaltRoutes,
        ZhihuApiClientTransport;

/// The application adapter keeps the private credential database, native HTTP channels and
/// Flutter diagnostics in the app, while all endpoint/routing/signing logic
/// is provided by the reusable pure-Dart package.
class ZhihuApiClient extends zhihu_api.ZhihuApiClient {
  ZhihuApiClient(
    super.session, {
    ApiTransport? transport,
    XZseSigner? xZseSigner,
    CloudIdSigner? cloudIdSigner,
    MobileLoginBodyEncoder? mobileLoginBodyEncoder,
    zhihu_api.ApiLogger? logger,
    zhihu_api.ApiDebugSink? debugSink,
    super.retryPolicy,
    super.authenticationPolicy,
    super.cache,
  }) : super(
         transport: transport ?? ApiTransport(),
         xZseSigner: xZseSigner ?? XZseSigner(),
         cloudIdProvider: cloudIdSigner ?? CloudIdSigner(),
         mobileLoginBodyEncoder:
             mobileLoginBodyEncoder ?? MobileLoginBodyEncoder(),
         logger: logger ?? const _FlutterApiLogger(),
         debugSink: debugSink ?? const _FlutterApiDebugSink(),
       );

  @override
  SessionStore get session => super.session as SessionStore;

  static const apiHost = zhihu_api.ZhihuApiClient.apiHost;
  static const appCloudHost = zhihu_api.ZhihuApiClient.appCloudHost;
  static const publicWebHost = zhihu_api.ZhihuApiClient.publicWebHost;
  static const lensHost = zhihu_api.ZhihuApiClient.lensHost;
  static const saltParagraphCommentObjectType =
      zhihu_api.ZhihuApiClient.saltParagraphCommentObjectType;
  static const maxResponseBytes = zhihu_api.ZhihuApiClient.maxResponseBytes;
  static const debugSaltAuthorizationRelay =
      zhihu_api.ZhihuApiClient.debugSaltAuthorizationRelay;
  static const questionFeedsInitialInclude =
      zhihu_api.ZhihuApiClient.questionFeedsInitialInclude;
  static const questionFeedsInitialQuery =
      zhihu_api.ZhihuApiClient.questionFeedsInitialQuery;
  static const appUserAgent = zhihu_api.ZhihuApiClient.appUserAgent;
  static const notificationEntryNames =
      zhihu_api.ZhihuApiClient.notificationEntryNames;

  static Map<String, Object?> buildCommentBody({
    required String content,
    String replyCommentId = '',
    CommentEmoticon? sticker,
    ContentSelection? selection,
    String? imageUrl,
    int imageWidth = 0,
    int imageHeight = 0,
  }) => zhihu_api.ZhihuApiClient.buildCommentBody(
    content: content,
    replyCommentId: replyCommentId,
    sticker: sticker,
    selection: selection,
    imageUrl: imageUrl,
    imageWidth: imageWidth,
    imageHeight: imageHeight,
  );

  static Map<String, Object?> buildAnswerEditorBody({
    required String questionId,
    required String questionTitle,
    required String content,
    String? traceId,
    String? extraTag,
  }) => zhihu_api.ZhihuApiClient.buildAnswerEditorBody(
    questionId: questionId,
    questionTitle: questionTitle,
    content: content,
    traceId: traceId,
    extraTag: extraTag,
  );

  static String newSearchId() => zhihu_api.ZhihuApiClient.newSearchId();
}

class _FlutterApiLogger implements zhihu_api.ApiLogger {
  const _FlutterApiLogger();

  @override
  Future<void> record({
    required String category,
    required String level,
    required String message,
    Map<String, Object?> details = const {},
  }) => AppLogStore.instance.record(
    category: _category(category),
    level: _level(level),
    message: message,
    details: details,
  );

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String message = '未处理异常',
    String category = 'error',
  }) => AppLogStore.instance.recordError(
    error,
    stackTrace,
    message: message,
    category: _category(category),
  );

  @override
  Future<void> recordNetwork({
    required String method,
    required Uri uri,
    required String profile,
    int? statusCode,
    String? statusLabel,
    String? businessCode,
    int? bodyBytes,
    int? durationMs,
    String? errorType,
  }) => AppLogStore.instance.recordNetwork(
    method: method,
    uri: uri,
    profile: profile,
    statusCode: statusCode,
    statusLabel: statusLabel,
    businessCode: businessCode,
    bodyBytes: bodyBytes,
    durationMs: durationMs,
    errorType: errorType,
  );

  static AppLogCategory _category(String value) => switch (value.trim()) {
    'network' => AppLogCategory.network,
    'performance' => AppLogCategory.performance,
    'upload' => AppLogCategory.network,
    'error' => AppLogCategory.error,
    'authentication' => AppLogCategory.authentication,
    _ => AppLogCategory.app,
  };

  static AppLogLevel _level(String value) => switch (value.trim()) {
    'debug' => AppLogLevel.debug,
    'warning' => AppLogLevel.warning,
    'error' => AppLogLevel.error,
    _ => AppLogLevel.info,
  };
}

class _FlutterApiDebugSink implements zhihu_api.ApiDebugSink {
  const _FlutterApiDebugSink();

  @override
  bool get enabled => foundation.kDebugMode;

  @override
  void write(String message) {
    if (foundation.kDebugMode) {
      foundation.debugPrint(message, wrapWidth: 512);
    }
  }

  @override
  Future<void> recordExchange({
    required String method,
    required Uri uri,
    required Map<String, String> requestHeaders,
    required List<int>? requestBody,
    required zhihu_api.ApiResponse response,
  }) => exportDebugExchange(
    method: method,
    uri: uri,
    requestHeaders: requestHeaders,
    requestBody: requestBody,
    response: response,
  );
}
