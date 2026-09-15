import 'package:flutter_test/flutter_test.dart';
import 'package:zhiyue_client/core/app_update_service.dart';

Map<String, Object?> releaseJson({
  String repository = 'LunaLuna111/zhiyue',
  String tag = 'v0.2.0',
  String name = 'zhiyue-0.2.0+112-arm64.apk',
  String digest =
      'sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
}) => {
  'id': 112,
  'tag_name': tag,
  'draft': false,
  'prerelease': false,
  'published_at': '2026-09-12T02:00:00Z',
  'html_url': 'https://github.com/$repository/releases/tag/$tag',
  'body': '更新说明',
  'assets': [
    {
      'name': name,
      'state': 'uploaded',
      'size': 1024,
      'digest': digest,
      'content_type': 'application/vnd.android.package-archive',
      'browser_download_url':
          'https://github.com/$repository/releases/download/$tag/$name',
    },
  ],
};

void main() {
  test('parses a bounded GitHub Release APK', () {
    final release = AppUpdateRelease.fromGitHub(
      releaseJson(),
      'LunaLuna111/zhiyue',
    );
    expect(release.versionName, '0.2.0');
    expect(release.versionCode, 112);
    expect(release.packageSha256, 'a' * 64);
  });

  test('derives the Android versionCode from a public semantic version', () {
    final release = AppUpdateRelease.fromGitHub(
      releaseJson(tag: 'v0.4.0', name: 'zhiyue-0.4.0-arm64.apk'),
      'LunaLuna111/zhiyue',
    );
    expect(release.versionName, '0.4.0');
    expect(release.versionCode, 4000);
  });

  test('rejects assets outside the configured repository', () {
    final value = releaseJson();
    final asset = (value['assets']! as List).single as Map<String, Object?>;
    asset['browser_download_url'] =
        'https://github.com/example/other/releases/download/v0.2.0/'
        'zhiyue-0.2.0+112-arm64.apk';
    expect(
      () => AppUpdateRelease.fromGitHub(value, 'LunaLuna111/zhiyue'),
      throwsA(isA<AppUpdateException>()),
    );
  });

  test('requires a GitHub SHA-256 digest', () {
    expect(
      () => AppUpdateRelease.fromGitHub(
        releaseJson(digest: ''),
        'LunaLuna111/zhiyue',
      ),
      throwsA(isA<AppUpdateException>()),
    );
  });
}
