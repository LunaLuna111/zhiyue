import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'app_update_platform.dart'
    if (dart.library.io) 'app_update_platform_io.dart';
import 'app_version.dart';
import 'platform_environment.dart'
    if (dart.library.io) 'platform_environment_io.dart';

const defaultGitHubRepository = String.fromEnvironment(
  'ZHIYUE_GITHUB_REPOSITORY',
  defaultValue: 'LunaLuna111/zhiyue',
);

class InstalledAppVersion {
  const InstalledAppVersion({
    required this.versionName,
    required this.versionCode,
  });
  final String versionName;
  final int versionCode;
}

class AppUpdateRelease {
  const AppUpdateRelease({
    required this.releaseId,
    required this.tagName,
    required this.versionCode,
    required this.versionName,
    required this.publishedAt,
    required this.notes,
    required this.downloadUri,
    required this.releasePageUri,
    required this.packageSize,
    required this.packageSha256,
    required this.packageContentType,
    required this.packageFileName,
  });
  final String releaseId;
  final String tagName;
  final int versionCode;
  final String versionName;
  final DateTime publishedAt;
  final String notes;
  final Uri downloadUri;
  final Uri releasePageUri;
  final int packageSize;
  final String packageSha256;
  final String packageContentType;
  final String packageFileName;

  factory AppUpdateRelease.fromGitHub(Object? source, String repository) {
    if (source is! Map ||
        source['draft'] == true ||
        source['prerelease'] == true) {
      throw const AppUpdateException('GitHub Release 数据无效');
    }
    final tag = _text(source['tag_name'], 'Release 标签', 80);
    final assets = source['assets'];
    if (assets is! List) throw const AppUpdateException('Release 缺少安装包');
    final pattern = RegExp(r'^zhiyue-(\d+\.\d+\.\d+)(?:\+(\d+))?-arm64\.apk$');
    final matches = assets
        .whereType<Map>()
        .where(
          (asset) =>
              pattern.hasMatch(asset['name']?.toString() ?? '') &&
              asset['state'] == 'uploaded',
        )
        .toList(growable: false);
    if (matches.length != 1) {
      throw const AppUpdateException('Release 必须包含一个规范命名的 arm64 APK');
    }
    final asset = matches.single;
    final fileName = _text(asset['name'], '安装包名称', 160);
    final match = pattern.firstMatch(fileName)!;
    final versionName = match.group(1)!;
    final legacyVersionCode = int.tryParse(match.group(2) ?? '');
    final versionCode = legacyVersionCode ?? androidVersionCodeFor(versionName);
    if (tag != 'v$versionName' || versionCode < 1) {
      throw const AppUpdateException('Release 标签与安装包版本不一致');
    }
    final size = asset['size'];
    if (size is! int || size < 1 || size > 250 * 1024 * 1024) {
      throw const AppUpdateException('安装包大小无效');
    }
    final digest = asset['digest']?.toString().toLowerCase() ?? '';
    if (!RegExp(r'^sha256:[0-9a-f]{64}$').hasMatch(digest)) {
      throw const AppUpdateException('Release 缺少有效的 SHA-256 摘要');
    }
    final download = Uri.tryParse(
      asset['browser_download_url']?.toString() ?? '',
    );
    final page = Uri.tryParse(source['html_url']?.toString() ?? '');
    final expectedDownload = Uri.https(
      'github.com',
      '/$repository/releases/download/$tag/$fileName',
    );
    final expectedPage = Uri.https(
      'github.com',
      '/$repository/releases/tag/$tag',
    );
    if (download == null ||
        download.scheme != 'https' ||
        download.host != 'github.com' ||
        download.userInfo.isNotEmpty ||
        download != expectedDownload) {
      throw const AppUpdateException('安装包地址不属于指定 GitHub 仓库');
    }
    if (page == null ||
        page.scheme != 'https' ||
        page.host != 'github.com' ||
        page != expectedPage) {
      throw const AppUpdateException('Release 页面地址无效');
    }
    final publishedAt = DateTime.tryParse(
      source['published_at']?.toString() ?? '',
    )?.toUtc();
    if (publishedAt == null) throw const AppUpdateException('Release 发布时间无效');
    final rawNotes = (source['body']?.toString() ?? '').trim();
    return AppUpdateRelease(
      releaseId: source['id']?.toString() ?? tag,
      tagName: tag,
      versionCode: versionCode,
      versionName: versionName,
      publishedAt: publishedAt,
      notes: rawNotes.length <= 8000 ? rawNotes : rawNotes.substring(0, 8000),
      downloadUri: download,
      releasePageUri: page,
      packageSize: size,
      packageSha256: digest.substring(7),
      packageContentType:
          (asset['content_type']?.toString() ??
                  'application/vnd.android.package-archive')
              .trim(),
      packageFileName: fileName,
    );
  }

  static String _text(Object? value, String label, int maximum) {
    final text = value is String ? value.trim() : '';
    if (text.isEmpty || text.length > maximum) {
      throw AppUpdateException('$label无效');
    }
    return text;
  }
}

class AppUpdateManifestMetadata {
  const AppUpdateManifestMetadata({
    required this.endpoint,
    required this.fetchedAt,
    required this.responseBytes,
    this.etag,
    this.cacheControl,
  });
  final Uri endpoint;
  final DateTime fetchedAt;
  final int responseBytes;
  final String? etag;
  final String? cacheControl;
}

class AppUpdateCheck {
  const AppUpdateCheck({
    required this.installed,
    required this.release,
    this.cachedPackageAvailable = false,
    this.manifestMetadata,
  });
  final InstalledAppVersion installed;
  final AppUpdateRelease? release;
  final bool cachedPackageAvailable;
  final AppUpdateManifestMetadata? manifestMetadata;
  bool get updateAvailable =>
      release != null && release!.versionCode > installed.versionCode;
  bool get mandatory => false;
}

class AppUpdateException implements Exception {
  const AppUpdateException(this.message, {this.code});
  final String message;
  final String? code;
  @override
  String toString() => message;
}

class AppUpdateService {
  AppUpdateService({
    this.repository = defaultGitHubRepository,
    Uri? apiBaseUri,
    http.Client? client,
    MethodChannel? channel,
    this.forceSupported,
  }) : apiBaseUri = apiBaseUri ?? Uri.parse('https://api.github.com/'),
       _client = client ?? http.Client(),
       _ownsClient = client == null,
       _channel = channel ?? _defaultChannel;
  static const _defaultChannel = MethodChannel('com.zhiyue.client/app_updates');
  final String repository;
  final Uri apiBaseUri;
  final http.Client _client;
  final bool _ownsClient;
  final MethodChannel _channel;
  final bool? forceSupported;
  bool get isSupported =>
      forceSupported ??
      (!kIsWeb &&
          !zhIsFlutterTest &&
          defaultTargetPlatform == TargetPlatform.android);

  Future<InstalledAppVersion> installedVersion() async {
    if (!isSupported) {
      return const InstalledAppVersion(versionName: '0.0.0', versionCode: 1);
    }
    final raw = await _channel
        .invokeMapMethod<String, Object?>('appVersion')
        .timeout(const Duration(seconds: 5));
    final name = raw?['versionName']?.toString().trim() ?? '';
    final code = raw?['versionCode'];
    if (name.isEmpty || code is! int || code < 1) {
      throw const AppUpdateException('无法读取当前应用版本');
    }
    return InstalledAppVersion(versionName: name, versionCode: code);
  }

  Future<AppUpdateCheck> check({String channel = 'stable'}) async {
    final installed = await installedVersion();
    if (!isSupported) {
      return AppUpdateCheck(installed: installed, release: null);
    }
    if (channel != 'stable' ||
        !RegExp(r'^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$').hasMatch(repository)) {
      throw const AppUpdateException('更新通道或仓库配置无效');
    }
    final uri = apiBaseUri.resolve('repos/$repository/releases/latest');
    late final http.Response response;
    try {
      response = await _client
          .get(
            uri,
            headers: const {
              'accept': 'application/vnd.github+json',
              'x-github-api-version': '2022-11-28',
              'user-agent': 'Zhiyue-Android-Updater',
            },
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const AppUpdateException('检查更新超时，请稍后重试');
    } catch (_) {
      throw const AppUpdateException('无法连接 GitHub Releases');
    }
    final metadata = AppUpdateManifestMetadata(
      endpoint: uri,
      fetchedAt: DateTime.now().toUtc(),
      responseBytes: response.bodyBytes.length,
      etag: response.headers['etag'],
      cacheControl: response.headers['cache-control'],
    );
    if (response.statusCode == 404) {
      return AppUpdateCheck(
        installed: installed,
        release: null,
        manifestMetadata: metadata,
      );
    }
    if (response.statusCode != 200) {
      throw AppUpdateException('GitHub Releases 返回 ${response.statusCode}');
    }
    if (response.bodyBytes.length > 512 * 1024) {
      throw const AppUpdateException('Release 数据超过大小限制');
    }
    late final Object? decoded;
    try {
      decoded = jsonDecode(
        utf8.decode(response.bodyBytes, allowMalformed: false),
      );
    } catch (_) {
      throw const AppUpdateException('GitHub Release JSON 无效');
    }
    final release = AppUpdateRelease.fromGitHub(decoded, repository);
    var cached = false;
    if (release.versionCode > installed.versionCode) {
      try {
        cached =
            await _channel
                .invokeMethod<bool>(
                  'hasCachedUpdate',
                  _packageArguments(release),
                )
                .timeout(const Duration(seconds: 5)) ==
            true;
      } catch (_) {}
    }
    return AppUpdateCheck(
      installed: installed,
      release: release,
      cachedPackageAvailable: cached,
      manifestMetadata: metadata,
    );
  }

  Future<bool> canInstallPackages() async =>
      isSupported &&
      await _channel.invokeMethod<bool>('canInstallPackages') == true;

  Future<void> openInstallPermission() async {
    if (isSupported) await _channel.invokeMethod<void>('openInstallPermission');
  }

  Future<bool> downloadAndInstall(
    AppUpdateCheck check, {
    required void Function(int received, int total) onProgress,
    required bool Function() isCancelled,
  }) async {
    final release = check.release;
    if (!isSupported || release == null || !check.updateAvailable) {
      throw const AppUpdateException('没有可安装的更新');
    }
    if ((await installedVersion()).versionCode >= release.versionCode) {
      throw const AppUpdateException('当前版本已经安装，无需重复更新');
    }
    String? path;
    try {
      try {
        if (await _channel
                .invokeMethod<bool>(
                  'installCachedUpdate',
                  _packageArguments(release),
                )
                .timeout(const Duration(minutes: 1)) ==
            true) {
          onProgress(release.packageSize, release.packageSize);
          return true;
        }
      } on PlatformException catch (error) {
        if (error.code == 'install_permission_required') rethrow;
      }
      final response = await _openTrustedDownload(release.downloadUri);
      if (response.contentLength != null &&
          response.contentLength != release.packageSize) {
        throw const AppUpdateException('安装包响应大小与 Release 不一致');
      }
      path = await writeDownloadedUpdate(
        response.stream,
        expectedBytes: release.packageSize,
        onProgress: onProgress,
        isCancelled: isCancelled,
      );
      await _channel
          .invokeMapMethod<String, Object?>('verifyAndInstall', {
            'downloadedPath': path,
            ..._packageArguments(release),
          })
          .timeout(const Duration(minutes: 3));
      return false;
    } on PlatformException catch (error) {
      throw AppUpdateException(
        _nativeErrorMessage(error.code),
        code: error.code,
      );
    } on AppUpdateException {
      rethrow;
    } catch (error) {
      if (error.toString().contains('取消')) {
        throw const AppUpdateException('更新下载已取消');
      }
      throw const AppUpdateException('更新包下载或写入失败');
    } finally {
      if (path != null) await deleteDownloadedUpdate(path);
    }
  }

  Future<http.StreamedResponse> _openTrustedDownload(Uri initial) async {
    var uri = initial;
    for (var redirects = 0; redirects <= 5; redirects++) {
      if (uri.scheme != 'https' ||
          !_trustedDownloadHosts.contains(uri.host) ||
          uri.userInfo.isNotEmpty) {
        throw const AppUpdateException('安装包跳转到不受信任的地址');
      }
      final request = http.Request('GET', uri)
        ..followRedirects = false
        ..headers['accept'] = 'application/octet-stream';
      final response = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) return response;
      if ({301, 302, 303, 307, 308}.contains(response.statusCode)) {
        final location = response.headers['location'];
        if (location == null) throw const AppUpdateException('GitHub 下载跳转无效');
        uri = uri.resolve(location);
        continue;
      }
      throw AppUpdateException('安装包下载失败（${response.statusCode}）');
    }
    throw const AppUpdateException('安装包下载跳转次数过多');
  }

  static const _trustedDownloadHosts = {
    'github.com',
    'objects.githubusercontent.com',
    'release-assets.githubusercontent.com',
    'github-releases.githubusercontent.com',
  };
  static Map<String, Object> _packageArguments(AppUpdateRelease release) => {
    'plainSize': release.packageSize,
    'plainSha256': release.packageSha256,
    'versionCode': release.versionCode,
  };
  static String _nativeErrorMessage(String code) => switch (code) {
    'install_permission_required' => '请先允许知阅安装未知来源应用',
    'plain_hash_mismatch' || 'plain_size_mismatch' => '安装包校验失败',
    'apk_package_mismatch' => '安装包应用标识不匹配',
    'apk_version_mismatch' => '安装包版本与 Release 不匹配',
    'apk_signing_certificate_mismatch' => '安装包签名证书与当前应用不一致',
    _ => '更新包验证或安装失败（$code）',
  };
  void close() {
    if (_ownsClient) _client.close();
  }
}
