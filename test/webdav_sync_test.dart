import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:zhiyue_client/core/private_key_value_store.dart';
import 'package:zhiyue_client/core/session_store.dart';
import 'package:zhiyue_client/core/webdav_client.dart';
import 'package:zhiyue_client/core/webdav_models.dart';
import 'package:zhiyue_client/core/webdav_settings_store.dart';
import 'package:zhiyue_client/core/webdav_sync_service.dart';

void main() {
  test('WebDAV settings reject insecure and path traversal endpoints', () {
    const base = WebDavSettings(
      enabled: true,
      provider: WebDavProviderKind.generic,
      endpoint: 'https://dav.example.test/',
      remoteDirectory: 'zhiyue',
      username: 'user',
      secret: 'app-password',
      authMethod: WebDavAuthMethod.basic,
      syncOnStartup: false,
    );
    expect(base.validate(), isNull);
    expect(
      base.copyWith(endpoint: 'http://dav.example.test').validate(),
      isNotNull,
    );
    expect(base.copyWith(remoteDirectory: '../outside').validate(), isNotNull);
    expect(base.copyWith(username: '').validate(), isNotNull);
    expect(base.copyWith(secret: 'secret\nvalue').validate(), isNotNull);
  });

  test('WebDAV client sends basic auth and preserves endpoint path', () async {
    final transport = _MemoryWebDavTransport();
    const settings = WebDavSettings(
      enabled: true,
      provider: WebDavProviderKind.generic,
      endpoint: 'https://dav.example.test/base/',
      remoteDirectory: 'zhiyue',
      username: 'alice',
      secret: 'secret',
      authMethod: WebDavAuthMethod.basic,
      syncOnStartup: false,
    );
    final client = WebDavClient(settings: settings, transport: transport);
    await client.putJson('v1/index.json', {'schema_version': 1});
    final request = transport.requests.single;
    expect(request.method, 'PUT');
    expect(request.uri.path, '/base/zhiyue/v1/index.json');
    expect(request.headers['Authorization'], startsWith('Basic '));
    expect(utf8.decode(request.body), contains('schema_version'));
    await client.close();
  });

  test(
    'WebDAV client retries transient server failures a bounded number of times',
    () async {
      final transport = _MemoryWebDavTransport()..transientPutFailures = 2;
      const settings = WebDavSettings(
        enabled: true,
        provider: WebDavProviderKind.generic,
        endpoint: 'https://dav.example.test/',
        remoteDirectory: 'zhiyue',
        username: 'alice',
        secret: 'secret',
        authMethod: WebDavAuthMethod.basic,
        syncOnStartup: false,
      );
      final client = WebDavClient(settings: settings, transport: transport);

      await client.putJson('v1/index.json', {'schema_version': 1});

      expect(
        transport.requests.where((request) => request.method == 'PUT'),
        hasLength(3),
      );
      await client.close();
    },
  );

  test('WebDAV sync merges histories and never uploads credentials', () async {
    final transport = _MemoryWebDavTransport();
    transport.files['/base/zhiyue/v1/index.json'] = utf8.encode(
      jsonEncode({
        'schema_version': 1,
        'updated_at': '2026-09-15T00:00:00Z',
        'answer_cache': const [],
        'salt_chapters': const [],
      }),
    );
    transport.files['/base/zhiyue/v1/search-history.json'] = utf8.encode(
      jsonEncode({
        'schema_version': 1,
        'items': ['remote query'],
      }),
    );
    transport.files['/base/zhiyue/v1/browsing-history.json'] = utf8.encode(
      jsonEncode({'schema_version': 1, 'items': const []}),
    );
    transport.files['/base/zhiyue/v1/bookshelf.json'] = utf8.encode(
      jsonEncode({'schema_version': 1, 'items': const []}),
    );
    final storage = _MemoryKeyValueStore();
    final session = SessionStore.withStorage(storage)
      ..searchHistory = const ['local query'];
    final settings = const WebDavSettings(
      enabled: true,
      provider: WebDavProviderKind.googleDriveGateway,
      endpoint: 'https://dav.example.test/base/',
      remoteDirectory: 'zhiyue',
      username: 'dav-user',
      secret: 'dav-secret',
      authMethod: WebDavAuthMethod.basic,
      syncOnStartup: false,
    );
    final settingsStore = WebDavSettingsStore(storage: storage);
    await settingsStore.save(settings);
    final service = WebDavSyncService(
      session: session,
      settingsStore: settingsStore,
      clientFactory: (_) =>
          WebDavClient(settings: settings, transport: transport),
    );

    final result = await service.sync();
    expect(result.message, contains('同步完成'));
    expect(session.searchHistory, containsAll(['local query', 'remote query']));
    final merged =
        jsonDecode(
              utf8.decode(
                transport.files['/base/zhiyue/v1/search-history.json']!,
              ),
            )
            as Map;
    expect(merged['items'], containsAll(['local query', 'remote query']));
    final uploadedBodies = transport.requests
        .where((request) => request.method == 'PUT')
        .map((request) => utf8.decode(request.body))
        .join('\n');
    expect(uploadedBodies, isNot(contains('dav-secret')));
    service.dispose();
  });
}

class _MemoryKeyValueStore implements SessionKeyValueStore {
  final values = <String, String>{};

  @override
  Future<Map<String, String>> readAll() async =>
      Map<String, String>.from(values);

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }
}

class _RecordedRequest {
  const _RecordedRequest({
    required this.method,
    required this.uri,
    required this.headers,
    required this.body,
  });

  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final List<int> body;
}

class _MemoryWebDavTransport implements WebDavTransport {
  final files = <String, List<int>>{};
  final requests = <_RecordedRequest>[];
  int transientPutFailures = 0;

  @override
  Future<WebDavResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    List<int> body = const [],
  }) async {
    requests.add(
      _RecordedRequest(
        method: method,
        uri: uri,
        headers: Map<String, String>.from(headers),
        body: List<int>.from(body),
      ),
    );
    if (method == 'MKCOL') {
      return const WebDavResponse(statusCode: 405, headers: {}, body: []);
    }
    if (method == 'PROPFIND') {
      return const WebDavResponse(statusCode: 207, headers: {}, body: []);
    }
    if (method == 'PUT') {
      if (transientPutFailures > 0) {
        transientPutFailures -= 1;
        return const WebDavResponse(statusCode: 503, headers: {}, body: []);
      }
      files[uri.path] = List<int>.from(body);
      return const WebDavResponse(statusCode: 201, headers: {}, body: []);
    }
    final stored = files[uri.path];
    if (stored == null) {
      return const WebDavResponse(statusCode: 404, headers: {}, body: []);
    }
    return WebDavResponse(statusCode: 200, headers: const {}, body: stored);
  }

  @override
  Future<void> close() async {}
}
