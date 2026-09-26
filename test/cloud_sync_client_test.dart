import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zhiyue_client/core/cloud_sync_client.dart';
import 'package:zhiyue_client/core/google_drive_sync_client.dart';
import 'package:zhiyue_client/core/webdav_models.dart';

WebDavSettings _settings(WebDavProviderKind provider) => WebDavSettings(
  enabled: true,
  provider: provider,
  endpoint: '',
  remoteDirectory: 'zhiyue',
  username: '',
  secret: '',
  authMethod: WebDavAuthMethod.basic,
  syncOnStartup: false,
);

void main() {
  test('direct cloud settings require no WebDAV address or password', () {
    expect(_settings(WebDavProviderKind.googleDrive).validate(), isNull);
    expect(_settings(WebDavProviderKind.oneDrive).validate(), isNull);
  });

  test(
    'OneDrive uses app root and drops bearer on download redirect',
    () async {
      final requests = <http.Request>[];
      final client = CloudSyncClient(
        settings: _settings(WebDavProviderKind.oneDrive),
        tokenProvider: (_) async => 'test-token',
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.url.path.endsWith('/content')) {
            return http.Response(
              '',
              302,
              headers: {'location': 'https://download.example.test/file'},
            );
          }
          if (request.url.host == 'download.example.test') {
            return http.Response('data', 200);
          }
          return http.Response('{}', request.method == 'POST' ? 201 : 200);
        }),
      );
      await client.ensureDirectory('v1/answers');
      expect(requests.where((r) => r.method == 'POST').length, 3);
      expect(requests[1].url.path, endsWith('/approot/children'));
      expect(requests[2].url.path, contains('approot:/zhiyue:/children'));
      expect(await client.getBytes('v1/index.json'), utf8.encode('data'));
      expect(requests.last.headers.containsKey('Authorization'), isFalse);
      await client.close();
    },
  );

  test('Google Drive stores files in appDataFolder with bearer auth', () async {
    final requests = <http.Request>[];
    var listCount = 0;
    final client = GoogleDriveSyncClient(
      settings: _settings(WebDavProviderKind.googleDrive),
      tokenProvider: () async => 'test-google-token',
      httpClient: MockClient((request) async {
        requests.add(request);
        if (request.url.path == '/drive/v3/files') {
          listCount++;
          return http.Response(
            jsonEncode({
              'files': listCount == 1
                  ? []
                  : [
                      <String, String>{'id': 'drive-id'},
                    ],
            }),
            200,
          );
        }
        if (request.url.path == '/upload/drive/v3/files') {
          return http.Response('{"id":"drive-id"}', 200);
        }
        if (request.url.path == '/drive/v3/files/drive-id') {
          return http.Response('sync-data', 200);
        }
        return http.Response('unexpected request', 500);
      }),
    );

    await client.putBytes('v1/index.json', utf8.encode('{"version":1}'));
    final bytes = await client.getBytes('v1/index.json');

    expect(utf8.decode(bytes!), 'sync-data');
    expect(
      requests.every(
        (request) =>
            request.headers['Authorization'] == 'Bearer test-google-token',
      ),
      isTrue,
    );
    expect(requests[0].url.queryParameters['spaces'], 'appDataFolder');
    expect(requests[1].url.queryParameters['uploadType'], 'multipart');
    expect(requests[1].body, contains('appDataFolder'));
    expect(requests.last.url.queryParameters['alt'], 'media');
    await client.close();
  });
}
