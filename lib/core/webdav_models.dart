import 'dart:convert';

enum WebDavProviderKind { generic, googleDriveGateway, microsoftOneDrive }

extension WebDavProviderKindLabel on WebDavProviderKind {
  String get label => switch (this) {
    WebDavProviderKind.generic => '通用 WebDAV',
    WebDavProviderKind.googleDriveGateway => 'Google Drive（WebDAV 网关）',
    WebDavProviderKind.microsoftOneDrive => 'Microsoft OneDrive（WebDAV）',
  };

  String get description => switch (this) {
    WebDavProviderKind.generic => '适用于支持 WebDAV 的云盘、NAS 和自建服务。',
    WebDavProviderKind.googleDriveGateway =>
      'Google Drive 本身不提供原生 WebDAV，请填写连接到 Google Drive 的 WebDAV 网关地址。',
    WebDavProviderKind.microsoftOneDrive =>
      '填写 OneDrive 的 WebDAV 兼容入口；部分账号或服务可能已限制旧版入口。',
  };

  String get endpointHint => switch (this) {
    WebDavProviderKind.generic => 'https://dav.example.com/',
    WebDavProviderKind.googleDriveGateway => 'https://你的网关.example.com/dav/',
    WebDavProviderKind.microsoftOneDrive => 'https://d.docs.live.net/<CID>/',
  };
}

enum WebDavAuthMethod { basic, bearer }

extension WebDavAuthMethodLabel on WebDavAuthMethod {
  String get label => switch (this) {
    WebDavAuthMethod.basic => '账号密码 / 应用专用密码',
    WebDavAuthMethod.bearer => 'Bearer 访问令牌',
  };
}

class WebDavSettings {
  const WebDavSettings({
    required this.enabled,
    required this.provider,
    required this.endpoint,
    required this.remoteDirectory,
    required this.username,
    required this.secret,
    required this.authMethod,
    required this.syncOnStartup,
  });

  const WebDavSettings.disabled()
    : enabled = false,
      provider = WebDavProviderKind.generic,
      endpoint = '',
      remoteDirectory = 'zhiyue',
      username = '',
      secret = '',
      authMethod = WebDavAuthMethod.basic,
      syncOnStartup = false;

  final bool enabled;
  final WebDavProviderKind provider;
  final String endpoint;
  final String remoteDirectory;
  final String username;
  final String secret;
  final WebDavAuthMethod authMethod;
  final bool syncOnStartup;

  bool get isConfigured => enabled && validate() == null;

  Uri? get endpointUri {
    final value = endpoint.trim();
    if (value.isEmpty) return null;
    return Uri.tryParse(value);
  }

  String? validate() {
    if (!enabled) return null;
    final uri = endpointUri;
    if (uri == null || uri.host.trim().isEmpty) return 'WebDAV 地址无效';
    if (uri.scheme.toLowerCase() != 'https') {
      return 'WebDAV 地址必须使用 HTTPS';
    }
    if (uri.userInfo.isNotEmpty ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty) {
      return 'WebDAV 地址不能包含账号、密码、查询参数或片段';
    }
    final directory = _normalizeDirectory(remoteDirectory);
    if (directory.isEmpty || directory.split('/').any((part) => part == '..')) {
      return '远程目录无效';
    }
    if (authMethod == WebDavAuthMethod.basic && username.trim().isEmpty) {
      return '账号密码认证需要填写用户名';
    }
    if (secret.isEmpty) return '请填写密码、应用专用密码或访问令牌';
    if (secret.length > 8192) return '访问凭据过长';
    return null;
  }

  WebDavSettings copyWith({
    bool? enabled,
    WebDavProviderKind? provider,
    String? endpoint,
    String? remoteDirectory,
    String? username,
    String? secret,
    WebDavAuthMethod? authMethod,
    bool? syncOnStartup,
  }) => WebDavSettings(
    enabled: enabled ?? this.enabled,
    provider: provider ?? this.provider,
    endpoint: endpoint ?? this.endpoint,
    remoteDirectory: remoteDirectory ?? this.remoteDirectory,
    username: username ?? this.username,
    secret: secret ?? this.secret,
    authMethod: authMethod ?? this.authMethod,
    syncOnStartup: syncOnStartup ?? this.syncOnStartup,
  );

  Map<String, Object?> toJson() => {
    'schema_version': 1,
    'enabled': enabled,
    'provider': provider.name,
    'endpoint': endpoint.trim(),
    'remote_directory': _normalizeDirectory(remoteDirectory),
    'username': username,
    'secret': secret,
    'auth_method': authMethod.name,
    'sync_on_startup': syncOnStartup,
  };

  factory WebDavSettings.fromJson(Object? source) {
    if (source is! Map) return const WebDavSettings.disabled();
    final map = source.map((key, value) => MapEntry(key.toString(), value));
    final provider = WebDavProviderKind.values.firstWhere(
      (item) => item.name == map['provider']?.toString(),
      orElse: () => WebDavProviderKind.generic,
    );
    final authMethod = WebDavAuthMethod.values.firstWhere(
      (item) => item.name == map['auth_method']?.toString(),
      orElse: () => WebDavAuthMethod.basic,
    );
    final endpoint = _bounded(map['endpoint']?.toString() ?? '', 2048);
    final remoteDirectory = _bounded(
      _normalizeDirectory(map['remote_directory']?.toString() ?? 'zhiyue'),
      256,
    );
    return WebDavSettings(
      enabled: map['enabled'] == true,
      provider: provider,
      endpoint: endpoint,
      remoteDirectory: remoteDirectory.isEmpty ? 'zhiyue' : remoteDirectory,
      username: _bounded(map['username']?.toString() ?? '', 512),
      secret: _bounded(map['secret']?.toString() ?? '', 8192),
      authMethod: authMethod,
      syncOnStartup: map['sync_on_startup'] == true,
    );
  }

  static WebDavSettings? tryDecode(String? encoded) {
    if (encoded == null || encoded.trim().isEmpty) return null;
    try {
      return WebDavSettings.fromJson(jsonDecode(encoded));
    } on Object {
      return null;
    }
  }

  static String _normalizeDirectory(String value) => value
      .trim()
      .replaceAll('\\', '/')
      .split('/')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty && part != '.')
      .join('/');

  static String _bounded(String value, int maximum) =>
      value.length <= maximum ? value : value.substring(0, maximum);
}

enum WebDavSyncPhase { idle, loading, testing, syncing, success, failure }

class WebDavSyncStatus {
  const WebDavSyncStatus({
    required this.phase,
    required this.message,
    required this.lastSyncedAt,
    required this.uploaded,
    required this.downloaded,
  });

  const WebDavSyncStatus.initial()
    : phase = WebDavSyncPhase.idle,
      message = '',
      lastSyncedAt = null,
      uploaded = 0,
      downloaded = 0;

  final WebDavSyncPhase phase;
  final String message;
  final DateTime? lastSyncedAt;
  final int uploaded;
  final int downloaded;

  bool get isBusy =>
      phase == WebDavSyncPhase.loading ||
      phase == WebDavSyncPhase.testing ||
      phase == WebDavSyncPhase.syncing;
}

class WebDavSyncResult {
  const WebDavSyncResult({
    required this.uploaded,
    required this.downloaded,
    required this.skipped,
    required this.message,
  });

  final int uploaded;
  final int downloaded;
  final int skipped;
  final String message;
}

class WebDavRequestFailure implements Exception {
  const WebDavRequestFailure({
    required this.method,
    required this.uri,
    required this.statusCode,
    required this.detail,
  });

  final String method;
  final Uri uri;
  final int statusCode;
  final String detail;

  @override
  String toString() =>
      'WebDAV 请求失败（$method $statusCode）：${detail.trim().isEmpty ? '服务器未返回说明' : detail.trim()}';
}
