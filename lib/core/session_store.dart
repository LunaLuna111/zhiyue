import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhihu_api/zhihu_api.dart' as zhihu_api;

import 'platform_environment.dart'
    if (dart.library.io) 'platform_environment_io.dart';
import 'cloud_id_signer.dart';
import 'recommendation_engine.dart';

part 'session_store_parts/session_models.dart';
part 'session_store_parts/session_history.dart';
part 'session_store_parts/session_preferences.dart';
part 'session_store_parts/session_credentials.dart';

abstract class _SessionStoreCore extends ChangeNotifier {
  _SessionStoreCore({
    FlutterSecureStorage? storage,
    required this._persistInFlutterTests,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const _authorizationKey = 'zh_authorization';
  static const _udidKey = 'zh_udid';
  static const _cookieKey = 'zh_cookie';
  static const _msIdKey = 'zh_ms_id';
  static const _zse96Key = 'zh_zse_96';
  static const _zse96TargetKey = 'zh_zse_96_target';
  static const _extraHeadersKey = 'zh_extra_headers';
  static const _sessionKindKey = 'zh_session_kind';
  static const _refreshTokenKey = 'zh_refresh_token';
  static const _accessTokenExpiryKey = 'zh_access_token_expiry';
  static const _accessTokenRefreshAtKey = 'zh_access_token_refresh_at';
  static const _accountUidKey = 'zh_account_uid';
  static const _accountUserIdKey = 'zh_account_user_id';
  static const _accountScopeKey = 'zh_account_scope';
  static const _accountUnlockTicketKey = 'zh_account_unlock_ticket';
  static const _accountLockInSecondsKey = 'zh_account_lock_in_seconds';
  static const _searchHistoryKey = 'zh_search_history';
  static const _maxSearchHistoryItems = 20;
  static const _readingTextSizeKey = 'zh_setting_reading_text_size';
  static const _reduceMotionKey = 'zh_setting_reduce_motion';
  static const _prefetchImagesKey = 'zh_setting_prefetch_images';
  static const _rememberSearchKey = 'zh_setting_remember_search';
  static const _showSearchHotKey = 'zh_setting_show_search_hot';
  static const _imageCachePresetKey = 'zh_setting_image_cache_preset';
  static const _startupPageKey = 'zh_setting_startup_page';
  static const _homeFeedOrderKey = 'zh_setting_home_feed_order';
  static const _refreshHomeOnReselectKey =
      'zh_setting_refresh_home_on_reselect';
  static const _feedDensityKey = 'zh_setting_feed_density';
  static const _showFeedImagesKey = 'zh_setting_show_feed_images';
  static const _showFeedMetricsKey = 'zh_setting_show_feed_metrics';
  static const _recommendationModeKey = 'zh_setting_recommendation_mode';
  static const _followSystemTextScaleKey =
      'zh_setting_follow_system_text_scale';
  static const _browsingHistoryKey = 'zh_browsing_history';
  static const _rememberBrowsingHistoryKey =
      'zh_setting_remember_browsing_history';
  static const _appLoggingEnabledKey = 'zh_setting_app_logging_enabled';
  static const _networkLoggingEnabledKey = 'zh_setting_network_logging_enabled';
  static const _performanceLoggingEnabledKey =
      'zh_setting_performance_logging_enabled';

  static const List<HomeFeedChannel> defaultHomeFeedOrder = [
    HomeFeedChannel.following,
    HomeFeedChannel.recommend,
    HomeFeedChannel.hot,
    HomeFeedChannel.story,
  ];

  final FlutterSecureStorage _storage;
  final bool _persistInFlutterTests;
  final _browsingHistoryChanges = _SessionChangeSignal();
  Future<void> _browsingHistoryWrite = Future<void>.value();
  Future<void> _credentialPersistence = Future<void>.value();
  int _credentialRevision = 0;
  bool _storageUnavailable = false;

  String authorization = '';
  String udid = '';
  String cookie = '';
  String msId = '';
  String xZse96 = '';
  String xZse96Target = '';
  String extraHeadersJson = '';
  String sessionKind = '';
  String refreshToken = '';
  DateTime? accessTokenExpiry;
  DateTime? accessTokenRefreshAt;
  String accountUid = '';
  String accountUserId = '';
  String accountScope = '';
  String accountUnlockTicket = '';
  int accountLockInSeconds = 0;
  List<String> searchHistory = const [];
  ReadingTextSize readingTextSize = ReadingTextSize.standard;
  bool reduceMotion = false;
  bool prefetchImages = true;
  bool rememberSearchHistory = true;
  bool showSearchHotSearch = true;
  ImageCachePreset imageCachePreset = ImageCachePreset.standard;
  AppStartupPage startupPage = AppStartupPage.recommend;
  List<HomeFeedChannel> homeFeedOrder = List<HomeFeedChannel>.from(
    defaultHomeFeedOrder,
  );
  bool refreshHomeOnReselect = true;
  FeedDensity feedDensity = FeedDensity.comfortable;
  bool showFeedImages = true;
  bool showFeedMetrics = true;
  RecommendationMode recommendationMode = RecommendationMode.server;
  bool followSystemTextScale = true;
  List<BrowsingHistoryEntry> browsingHistory = const [];
  bool rememberBrowsingHistory = true;

  /// Enables bounded, redacted diagnostics stored on this device.  Logging is
  /// opt-in so credentials and content are never collected unexpectedly.
  bool appLoggingEnabled = false;
  bool networkLoggingEnabled = false;
  bool performanceLoggingEnabled = false;

  /// Emits only when the local browsing-history collection changes.
  ///
  /// History writes are intentionally kept off the main session notifier so
  /// opening content cannot rebuild unrelated pages underneath its route.
  Listenable get browsingHistoryChanges => _browsingHistoryChanges;

  double get textScaleFactor => readingTextSize.scale;

  bool get hasAuthorization => authorization.trim().isNotEmpty;
  bool get hasAccountSession =>
      (sessionKind == 'account' && hasCompleteMobileContext) ||
      (sessionKind == 'qr' && hasCompleteMobileContext && cookieHasQrIdentity);
  bool get hasRefreshableAccountSession =>
      sessionKind == 'account' && hasCompleteMobileContext;
  bool get isQrSession => sessionKind == 'qr' && cookieHasQrIdentity;
  bool get cookieHasQrIdentity => cookie.split(';').any((part) {
    final separator = part.indexOf('=');
    return separator > 0 &&
        part.substring(0, separator).trim().toLowerCase() == 'z_c0' &&
        part.substring(separator + 1).trim().isNotEmpty;
  });
  bool get hasGuestSession =>
      sessionKind == 'guest' && hasCompleteMobileContext;
  bool get isAccessTokenExpired =>
      accessTokenExpiry != null && !DateTime.now().isBefore(accessTokenExpiry!);
  bool get shouldRefreshAccountToken =>
      sessionKind == 'account' &&
      refreshToken.isNotEmpty &&
      accessTokenRefreshAt != null &&
      !DateTime.now().isBefore(accessTokenRefreshAt!);
  String get sessionLabel {
    if (hasAccountSession) {
      return isAccessTokenExpired ? '登录已过期' : '已登录';
    }
    return '未登录';
  }

  bool get hasCompleteMobileContext =>
      authorization.trim().isNotEmpty && udid.trim().isNotEmpty;
  bool get hasRequestSignature =>
      xZse96.trim().isNotEmpty && xZse96Target.trim().isNotEmpty;
  bool get supportsPersistentApiSession => !kIsWeb && !zhIsFlutterTest;

  /// Monotonically identifies the active API credential state.
  ///
  /// A token refresh captures this value before performing network work and
  /// may only commit its response while the value is still unchanged. Every
  /// operation that replaces or clears credentials advances it synchronously,
  /// before its first asynchronous storage write.
  int get credentialRevision => _credentialRevision;

  @visibleForTesting
  static bool shouldDiscardLegacySyntheticMsId(String kind, String value) =>
      kind != 'imported' && RegExp(r'^[0-9a-f]{32}$').hasMatch(value);

  void _notifyChanged() => notifyListeners();

  Future<void> load() async {
    if (kIsWeb || zhIsFlutterTest) {
      // The widget-test VM has no secure-storage host registrar.  Treat it as
      // an empty in-memory session instead of starting a platform-channel
      // Future that can remain pending until a timeout timer fires.
      _storageUnavailable = true;
      _resetValues();
      notifyListeners();
      return;
    }
    // Android secure storage crosses a platform channel and decrypts its
    // backing preferences. Reading every setting separately makes startup
    // scale linearly with the number of preferences, so take one consistent
    // snapshot and decode all account and UI values from it.
    Map<String, String> stored;
    try {
      stored = await _storage.readAll().timeout(const Duration(seconds: 3));
    } on Object {
      // Linux/Windows hosts may not have a keyring service (and widget test
      // engines do not register the plugin).  Keep the session in memory and
      // let the app continue; no credential is ever copied to plain storage.
      _storageUnavailable = true;
      stored = const <String, String>{};
    }
    String? read(String key) => stored[key];

    authorization = read(_authorizationKey) ?? '';
    udid = read(_udidKey) ?? '';
    cookie = read(_cookieKey) ?? '';
    msId = read(_msIdKey) ?? '';
    xZse96 = read(_zse96Key) ?? '';
    xZse96Target = read(_zse96TargetKey) ?? '';
    extraHeadersJson = read(_extraHeadersKey) ?? '';
    sessionKind = read(_sessionKindKey) ?? '';
    // Privacy profile v1 incorrectly generated a 32-character hexadecimal
    // MS-ID. Official captures show MS-ID is an opaque provider value, and a
    // guest/account created by this client must not keep sending that known
    // synthetic shape after upgrading. User-imported contexts remain intact.
    if (shouldDiscardLegacySyntheticMsId(sessionKind, msId)) {
      msId = '';
      await _writeOrDelete(_msIdKey, '');
    }
    refreshToken = read(_refreshTokenKey) ?? '';
    final expiry = read(_accessTokenExpiryKey);
    accessTokenExpiry = expiry == null ? null : DateTime.tryParse(expiry);
    final refreshAt = read(_accessTokenRefreshAtKey);
    accessTokenRefreshAt = refreshAt == null
        ? null
        : DateTime.tryParse(refreshAt);
    accountUid = read(_accountUidKey) ?? '';
    accountUserId = read(_accountUserIdKey) ?? '';
    accountScope = read(_accountScopeKey) ?? '';
    accountUnlockTicket = read(_accountUnlockTicketKey) ?? '';
    accountLockInSeconds =
        int.tryParse(read(_accountLockInSecondsKey) ?? '') ?? 0;
    final storedSearchHistory = read(_searchHistoryKey);
    searchHistory = _decodeSearchHistory(storedSearchHistory);
    readingTextSize = _decodeEnum(
      read(_readingTextSizeKey),
      ReadingTextSize.values,
      ReadingTextSize.standard,
    );
    reduceMotion = _decodeBool(read(_reduceMotionKey), fallback: false);
    prefetchImages = _decodeBool(read(_prefetchImagesKey), fallback: true);
    rememberSearchHistory = _decodeBool(
      read(_rememberSearchKey),
      fallback: true,
    );
    if (!rememberSearchHistory) searchHistory = const [];
    showSearchHotSearch = _decodeBool(read(_showSearchHotKey), fallback: true);
    imageCachePreset = _decodeEnum(
      read(_imageCachePresetKey),
      ImageCachePreset.values,
      ImageCachePreset.standard,
    );
    startupPage = _decodeEnum(
      read(_startupPageKey),
      AppStartupPage.values,
      AppStartupPage.recommend,
    );
    homeFeedOrder = _decodeHomeFeedOrder(read(_homeFeedOrderKey));
    refreshHomeOnReselect = _decodeBool(
      read(_refreshHomeOnReselectKey),
      fallback: true,
    );
    feedDensity = _decodeEnum(
      read(_feedDensityKey),
      FeedDensity.values,
      FeedDensity.comfortable,
    );
    showFeedImages = _decodeBool(read(_showFeedImagesKey), fallback: true);
    showFeedMetrics = _decodeBool(read(_showFeedMetricsKey), fallback: true);
    recommendationMode = _decodeEnum(
      read(_recommendationModeKey),
      RecommendationMode.values,
      RecommendationMode.server,
    );
    followSystemTextScale = _decodeBool(
      read(_followSystemTextScaleKey),
      fallback: true,
    );
    browsingHistory = _decodeBrowsingHistory(read(_browsingHistoryKey));
    rememberBrowsingHistory = _decodeBool(
      read(_rememberBrowsingHistoryKey),
      fallback: true,
    );
    appLoggingEnabled = _decodeBool(
      read(_appLoggingEnabledKey),
      fallback: false,
    );
    networkLoggingEnabled = _decodeBool(
      read(_networkLoggingEnabledKey),
      fallback: false,
    );
    performanceLoggingEnabled = _decodeBool(
      read(_performanceLoggingEnabledKey),
      fallback: false,
    );
    notifyListeners();
  }

  static List<String> _decodeSearchHistory(String? encoded) {
    if (encoded == null || encoded.isEmpty) return const [];
    try {
      final value = jsonDecode(encoded);
      if (value is! List) return const [];
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty && item.length <= 512)
          .take(_maxSearchHistoryItems)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static List<BrowsingHistoryEntry> _decodeBrowsingHistory(String? encoded) {
    if (encoded == null || encoded.isEmpty) return const [];
    try {
      final value = jsonDecode(encoded);
      if (value is! List) return const [];
      final seen = <String>{};
      return value
          .map(BrowsingHistoryEntry.fromJson)
          .whereType<BrowsingHistoryEntry>()
          .where((entry) => seen.add(entry.identity))
          .take(80)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static String _boundedText(String value, int maxLength) =>
      value.length <= maxLength ? value : value.substring(0, maxLength);

  Future<void> _persistBrowsingHistory() async {
    if (kIsWeb) return;
    final encoded = browsingHistory.isEmpty
        ? null
        : jsonEncode(
            browsingHistory
                .map((entry) => entry.toJson())
                .toList(growable: false),
          );
    _browsingHistoryWrite = _browsingHistoryWrite.then(
      (_) => encoded == null
          ? _safeDelete(_browsingHistoryKey)
          : _safeWrite(key: _browsingHistoryKey, value: encoded),
    );
    await _browsingHistoryWrite;
  }

  static T _decodeEnum<T extends Enum>(
    String? encoded,
    List<T> values,
    T fallback,
  ) {
    if (encoded == null || encoded.isEmpty) return fallback;
    for (final value in values) {
      if (value.name == encoded) return value;
    }
    return fallback;
  }

  static bool _decodeBool(String? encoded, {required bool fallback}) =>
      switch (encoded) {
        'true' => true,
        'false' => false,
        _ => fallback,
      };

  static List<HomeFeedChannel> _decodeHomeFeedOrder(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      return List<HomeFeedChannel>.from(defaultHomeFeedOrder);
    }
    try {
      final value = jsonDecode(encoded);
      if (value is! List) throw const FormatException('首页分区顺序不是数组');
      final channels = value
          .whereType<String>()
          .map(
            (name) => HomeFeedChannel.values.firstWhere(
              (channel) => channel.name == name,
            ),
          )
          .toList(growable: false);
      return _validatedHomeFeedOrder(channels);
    } catch (_) {
      return List<HomeFeedChannel>.from(defaultHomeFeedOrder);
    }
  }

  static List<HomeFeedChannel> _validatedHomeFeedOrder(
    List<HomeFeedChannel> value,
  ) {
    if (value.length != HomeFeedChannel.values.length ||
        value.toSet().length != HomeFeedChannel.values.length ||
        !value.toSet().containsAll(HomeFeedChannel.values)) {
      throw const FormatException('首页分区顺序必须完整包含关注、推荐、热榜和故事');
    }
    return List<HomeFeedChannel>.unmodifiable(value);
  }

  void _resetValues() {
    authorization = '';
    udid = '';
    cookie = '';
    msId = '';
    xZse96 = '';
    xZse96Target = '';
    extraHeadersJson = '';
    sessionKind = '';
    refreshToken = '';
    accessTokenExpiry = null;
    accessTokenRefreshAt = null;
    _clearAccountMetadataValues();
  }

  void _clearAccountMetadataValues() {
    accountUid = '';
    accountUserId = '';
    accountScope = '';
    accountUnlockTicket = '';
    accountLockInSeconds = 0;
  }

  _CredentialSnapshot _credentialSnapshot() => _CredentialSnapshot(
    authorization: authorization,
    udid: udid,
    cookie: cookie,
    msId: msId,
    xZse96: xZse96,
    xZse96Target: xZse96Target,
    extraHeadersJson: extraHeadersJson,
    sessionKind: sessionKind,
    refreshToken: refreshToken,
    accessTokenExpiry: accessTokenExpiry,
    accessTokenRefreshAt: accessTokenRefreshAt,
    accountUid: accountUid,
    accountUserId: accountUserId,
    accountScope: accountScope,
    accountUnlockTicket: accountUnlockTicket,
    accountLockInSeconds: accountLockInSeconds,
  );

  Future<void> _persistCredentialSnapshot(_CredentialSnapshot snapshot) async {
    await _writeOrDelete(_authorizationKey, snapshot.authorization);
    await _writeOrDelete(_udidKey, snapshot.udid);
    await _writeOrDelete(_cookieKey, snapshot.cookie);
    await _writeOrDelete(_msIdKey, snapshot.msId);
    await _writeOrDelete(_zse96Key, snapshot.xZse96);
    await _writeOrDelete(_zse96TargetKey, snapshot.xZse96Target);
    await _writeOrDelete(_extraHeadersKey, snapshot.extraHeadersJson);
    await _writeOrDelete(_sessionKindKey, snapshot.sessionKind);
    await _writeOrDelete(_refreshTokenKey, snapshot.refreshToken);
    await _writeOrDelete(
      _accessTokenExpiryKey,
      snapshot.accessTokenExpiry?.toIso8601String() ?? '',
    );
    await _writeOrDelete(
      _accessTokenRefreshAtKey,
      snapshot.accessTokenRefreshAt?.toIso8601String() ?? '',
    );
    await _writeOrDelete(_accountUidKey, snapshot.accountUid);
    await _writeOrDelete(_accountUserIdKey, snapshot.accountUserId);
    await _writeOrDelete(_accountScopeKey, snapshot.accountScope);
    await _writeOrDelete(_accountUnlockTicketKey, snapshot.accountUnlockTicket);
    await _writeOrDelete(
      _accountLockInSecondsKey,
      snapshot.accountLockInSeconds > 0
          ? snapshot.accountLockInSeconds.toString()
          : '',
    );
  }

  Future<void> _queueCredentialPersistence(Future<void> Function() operation) {
    final queued = _credentialPersistence.then((_) => operation());
    // Keep the tail successful so one storage failure cannot permanently
    // poison later credential mutations. The returned Future still reports
    // the original failure to its caller.
    _credentialPersistence = queued.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return queued;
  }

  Future<void> _writeOrDelete(String key, String value) =>
      value.isEmpty ? _safeDelete(key) : _safeWrite(key: key, value: value);

  Future<void> _writePreference(String key, String value) =>
      kIsWeb ? Future<void>.value() : _safeWrite(key: key, value: value);

  Future<void> _safeWrite({required String key, required String value}) async {
    if (_storageUnavailable || (zhIsFlutterTest && !_persistInFlutterTests)) {
      return;
    }
    try {
      await _storage
          .write(key: key, value: value)
          .timeout(const Duration(seconds: 3));
    } on Object {
      _storageUnavailable = true;
    }
  }

  Future<void> _safeDelete(String key) async {
    if (_storageUnavailable || (zhIsFlutterTest && !_persistInFlutterTests)) {
      return;
    }
    try {
      await _storage.delete(key: key).timeout(const Duration(seconds: 3));
    } on Object {
      _storageUnavailable = true;
    }
  }

  Map<String, String> requestHeaders({
    required String method,
    required Uri uri,
  }) {
    if (kIsWeb) return const {};
    final headers = <String, String>{};
    if (authorization.isNotEmpty) headers['Authorization'] = authorization;
    if (udid.isNotEmpty) headers['x-udid'] = udid;
    if (cookie.isNotEmpty) headers['Cookie'] = cookie;
    if (msId.isNotEmpty) headers['X-MS-ID'] = msId;
    if (xZse96.isNotEmpty && signatureTarget(method, uri) == xZse96Target) {
      headers['X-Zse-96'] = xZse96;
    }
    headers.addAll(parseExtraHeaders(extraHeadersJson));
    return headers;
  }

  static String signatureTarget(String method, Uri uri) {
    final target = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    return '${method.trim().toUpperCase()} $target';
  }

  static String normalizeSignatureTarget(String source) {
    final value = source.trim();
    if (value.isEmpty) return '';
    final match = RegExp(r'^([A-Za-z]+)\s+(/\S*)$').firstMatch(value);
    if (match == null || value.contains('\r') || value.contains('\n')) {
      throw const FormatException('签名目标格式应为 METHOD /path?exact=query');
    }
    final method = match.group(1)!.toUpperCase();
    if (!const {'GET', 'POST', 'PUT', 'PATCH', 'DELETE'}.contains(method)) {
      throw const FormatException('签名目标包含不支持的 HTTP method');
    }
    final requestTarget = match.group(2)!;
    final uri = Uri.tryParse('https://api.zhihu.com$requestTarget');
    if (uri == null ||
        uri.host != 'api.zhihu.com' ||
        uri.fragment.isNotEmpty ||
        uri.userInfo.isNotEmpty) {
      throw const FormatException('签名目标必须是 api.zhihu.com 的 path/query');
    }
    return '$method $requestTarget';
  }

  static Map<String, String> parseExtraHeaders(String source) {
    if (source.trim().isEmpty) return const {};
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('附加 Header 必须是 JSON 对象');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('附加 Header 必须是 JSON 对象');
    }
    const forbidden = {
      'host',
      'content-length',
      'connection',
      'transfer-encoding',
      'authorization',
      'x-udid',
      'cookie',
      'x-ms-id',
      'x-zse-93',
      'x-zse-96',
    };
    final result = <String, String>{};
    for (final entry in decoded.entries) {
      final name = entry.key.trim();
      if (!RegExp(r"^[A-Za-z0-9!#$%&'*+.^_`|~-]{1,128}$").hasMatch(name)) {
        throw FormatException('非法 Header 名：$name');
      }
      if (forbidden.contains(name.toLowerCase())) {
        throw FormatException('不允许覆盖 Header：$name');
      }
      if (entry.value is! String) {
        throw FormatException('$name 的值必须是字符串');
      }
      final value = entry.value as String;
      _validateHeaderValue(name, value);
      result[name] = value;
    }
    return result;
  }

  static void _validateHeaderValue(String name, String value) {
    if (value.contains('\n') || value.contains('\r') || value.length > 8192) {
      throw FormatException('$name 包含换行或长度超过限制');
    }
  }
}

class SessionStore extends _SessionStoreCore
    with
        _SessionStoreHistoryMixin,
        _SessionStorePreferencesMixin,
        _SessionStoreCredentialsMixin
    implements zhihu_api.ApiSession {
  SessionStore({super.storage}) : super(persistInFlutterTests: false);

  @visibleForTesting
  SessionStore.withFlutterTestPersistence(FlutterSecureStorage storage)
    : super(storage: storage, persistInFlutterTests: true);

  static const List<HomeFeedChannel> defaultHomeFeedOrder =
      _SessionStoreCore.defaultHomeFeedOrder;

  @visibleForTesting
  static bool shouldDiscardLegacySyntheticMsId(String kind, String value) =>
      _SessionStoreCore.shouldDiscardLegacySyntheticMsId(kind, value);

  static String signatureTarget(String method, Uri uri) =>
      _SessionStoreCore.signatureTarget(method, uri);

  static String normalizeSignatureTarget(String source) =>
      _SessionStoreCore.normalizeSignatureTarget(source);

  static Map<String, String> parseExtraHeaders(String source) =>
      _SessionStoreCore.parseExtraHeaders(source);
}

class _SessionChangeSignal extends ChangeNotifier {
  void emit() => notifyListeners();
}

class _CredentialSnapshot {
  const _CredentialSnapshot({
    required this.authorization,
    required this.udid,
    required this.cookie,
    required this.msId,
    required this.xZse96,
    required this.xZse96Target,
    required this.extraHeadersJson,
    required this.sessionKind,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.accessTokenRefreshAt,
    required this.accountUid,
    required this.accountUserId,
    required this.accountScope,
    required this.accountUnlockTicket,
    required this.accountLockInSeconds,
  });

  final String authorization;
  final String udid;
  final String cookie;
  final String msId;
  final String xZse96;
  final String xZse96Target;
  final String extraHeadersJson;
  final String sessionKind;
  final String refreshToken;
  final DateTime? accessTokenExpiry;
  final DateTime? accessTokenRefreshAt;
  final String accountUid;
  final String accountUserId;
  final String accountScope;
  final String accountUnlockTicket;
  final int accountLockInSeconds;
}
