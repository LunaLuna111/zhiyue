import 'api_response.dart';
import 'session_store.dart';

Future<void> exportDebugSession(SessionStore session) async {}

Future<void> exportDebugExchange({
  required String method,
  required Uri uri,
  required Map<String, String> requestHeaders,
  required List<int>? requestBody,
  required ApiResponse response,
}) async {}

Future<void> exportDebugSaltText({
  required String decodeStatus,
  required String businessId,
  required String chapterId,
  required String rawKey,
  required String transKey,
  required String articleCode,
  required String strategy,
  required String script,
  required Object? responseJson,
  required String xhtml,
  required List<String> paragraphs,
  String? decodeError,
}) async {}
