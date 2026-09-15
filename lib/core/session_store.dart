import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhihu_api/zhihu_api.dart' as zhihu_api;

import 'platform_environment.dart'
    if (dart.library.io) 'platform_environment_io.dart';
import 'cloud_id_signer.dart';
import 'app_log.dart';
import 'private_app_storage.dart';
import 'recommendation_engine.dart';

part 'session_store_parts/session_models.dart';
part 'session_store_parts/session_history.dart';
part 'session_store_parts/session_preferences.dart';
part 'session_store_parts/session_credentials.dart';

bool _isBearerAuthorization(String value) {
  final normalized = value.trim();
  return normalized.length > 7 &&
      normalized.substring(0, 7).toLowerCase() == 'bearer ' &&
      normalized.substring(7).trim().isNotEmpty;
}

abstract class _SessionStoreCore extends ChangeNotifier {
  _SessionStoreCore({
    FlutterSecureStorage? storage,
    SessionKeyValueStore? keyValueStore,
    required this._persistInFlutterTests,
  }) : _storage =
           keyValueStore ??
           (storage == null
               ? PrivateAppStorage.instance
               : FlutterSecureKeyValueStore(storage));

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
  static const List<String> _credentialStorageKeys = [
    _authorizationKey,
    _udidKey,
    _cookieKey,
    _msIdKey,
    _zse96Key,
    _zse96TargetKey,
    _extraHeadersKey,
    _sessionKindKey,
    _refreshTokenKey,
    _accessTokenExpiryKey,
    _accessTokenRefreshAtKey,
    _accountUidKey,
    _accountUserIdKey,
    _accountScopeKey,
    _accountUnlockTicketKey,
    _accountLockInSecondsKey,
  ];
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
  static const _authenticationLoggingEnabledKey =
      'zh_setting_authentication_logging_enabled';

  static const List<HomeFeedChannel> defaultHomeFeedOrder = [
    HomeFeedChannel.following,
    HomeFeedChannel.recommend,
    HomeFeedChannel.hot,
    HomeFeedChannel.story,
  ];

  final SessionKeyValueStore _storage;
  SessionCredentialSnapshot _durableCredentialSnapshot =
      SessionCredentialSnapshot.empty;
  bool _hasDurableCredentialSnapshot = false;
  final bool _persistInFlutterTests;
  bool _credentialStorageLoaded = false;
  final _browsingHistoryChanges = _SessionChangeSignal();
  Future<void> _browsingHistoryWrite = Future<void>.value();
  Future<void> _credentialPersistence = Future<void>.value();
  int _credentialRevision = 0;
  bool _storageUnavailable = false;
  bool _credentialStorageUnavailable = false;
  zhihu_api.ApiSessionCleanupRequest? _pendingAccountCleanup;
  bool _hasRecoverableAccountSession = false;
  int _lastDismissedCleanupRevision = -1;
  DateTime? _lastDismissedCleanupAt;

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

  /// Enables bounded, redacted diagnostics stored on this device. General
  /// diagnostics remain user configurable; authentication events have their
  /// own opt-out and default to enabled so unexpected session changes remain
  /// explainable.
  bool appLoggingEnabled = false;
  bool networkLoggingEnabled = false;
  bool performanceLoggingEnabled = false;
  bool authenticationLoggingEnabled = true;

  /// Emits only when the local browsing-history collection changes.
  ///
  /// History writes are intentionally kept off the main session notifier so
  /// opening content cannot rebuild unrelated pages underneath its route.
  Listenable get browsingHistoryChanges => _browsingHistoryChanges;

  double get textScaleFactor => readingTextSize.scale;

  bool get hasAuthorization => authorization.trim().isNotEmpty;
  bool get hasAccountSession =>
      (sessionKind == 'account' &&
          hasCompleteMobileContext &&
          _isBearerAuthorization(authorization)) ||
      (sessionKind == 'qr' && hasCompleteMobileContext && cookieHasQrIdentity);
  bool get hasStoredCredentialSession =>
      hasAccountSession ||
      (sessionKind == 'imported' && hasCompleteMobileContext);
  bool get hasRefreshableAccountSession =>
      hasAccountSession && refreshToken.trim().isNotEmpty;
  bool get isQrSession => sessionKind == 'qr' && cookieHasQrIdentity;
  bool get cookieHasQrIdentity => cookie.split(';').any((part) {
    final separator = part.indexOf('=');
    return separator > 0 &&
        part.substring(0, separator).trim().toLowerCase() == 'z_c0' &&
        part.substring(separator + 1).trim().isNotEmpty;
  });
  bool get hasGuestSession =>
      sessionKind == 'guest' &&
      hasCompleteMobileContext &&
      _isBearerAuthorization(authorization);
  bool get isAccessTokenExpired =>
      accessTokenExpiry != null && !DateTime.now().isBefore(accessTokenExpiry!);
  bool get shouldRefreshAccountToken =>
      sessionKind == 'account' &&
      refreshToken.isNotEmpty &&
      accessTokenRefreshAt != null &&
      !DateTime.now().isBefore(accessTokenRefreshAt!);
  zhihu_api.ApiSessionCleanupRequest? get pendingAccountCleanup =>
      _pendingAccountCleanup;
  bool get hasPendingAccountCleanup => _pendingAccountCleanup != null;
  bool get hasRecoverableAccountSession => _hasRecoverableAccountSession;
  String get sessionLabel {
    if (hasPendingAccountCleanup) return '登录状态待确认';
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

  /// True after the private credential database was read or successfully
  /// written. Callers must not interpret a failed read as an empty logged-out
  /// session.
  bool get isCredentialStorageReady =>
      _credentialStorageLoaded && !_credentialStorageUnavailable;

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

  /// Captures every credential and account metadata field needed to switch or
  /// roll back an account without borrowing values from the currently active
  /// account.
  SessionCredentialSnapshot captureCredentialSnapshot() =>
      _credentialSnapshot();

  /// Installs a complete credential snapshot. Account switching uses
  /// [persist] = false while it verifies `/people/self`, so a failed candidate
  /// never becomes the durable session. Other callers can persist immediately.
  Future<bool> installCredentialSnapshot(
    SessionCredentialSnapshot snapshot, {
    bool persist = true,
    int? expectedCredentialRevision,
    bool allowEmpty = false,
  }) async {
    if (expectedCredentialRevision != null &&
        expectedCredentialRevision != _credentialRevision) {
      return false;
    }
    if (!snapshot.isUsable && !(allowEmpty && snapshot.isEmpty)) return false;
    final previous = _credentialSnapshot();
    _credentialRevision += 1;
    _clearPendingAccountCleanup();
    _applyCredentialSnapshot(snapshot);
    if (!persist) {
      _notifyChanged();
      return true;
    }
    return _commitCredentialMutation(
      previous: previous,
      next: snapshot,
      operation: 'install_credential_snapshot',
    );
  }

  /// Persists the current in-memory snapshot without changing it. This is
  /// used after a candidate account passed identity verification.
  Future<bool> persistCurrentCredentialSnapshot({
    int? expectedCredentialRevision,
  }) async {
    if (expectedCredentialRevision != null &&
        expectedCredentialRevision != _credentialRevision) {
      return false;
    }
    final snapshot = _credentialSnapshot();
    try {
      await _queueCredentialPersistence(
        () => _persistCredentialSnapshot(snapshot),
      );
      _durableCredentialSnapshot = snapshot;
      _hasDurableCredentialSnapshot = true;
      _credentialStorageLoaded = true;
      return true;
    } on Object catch (error, stackTrace) {
      _recordAuthenticationLog(
        '当前会话写入失败，保留旧的持久化凭据',
        level: AppLogLevel.error,
        details: {
          'operation': 'persist_current_credential_snapshot',
          'error_type': error.runtimeType.toString(),
          'action': 'retained_previous_storage',
        },
      );
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '当前会话写入失败',
          category: AppLogCategory.authentication,
        ),
      );
      return false;
    }
  }

  Future<bool> _commitCredentialMutation({
    required SessionCredentialSnapshot previous,
    required SessionCredentialSnapshot next,
    required String operation,
  }) async {
    final mutationRevision = _credentialRevision;
    final persistence = _queueCredentialPersistence(
      () => _persistCredentialSnapshot(next),
    );
    _notifyChanged();
    try {
      await persistence;
      _durableCredentialSnapshot = next;
      _hasDurableCredentialSnapshot = true;
      _credentialStorageLoaded = true;
      return true;
    } on Object catch (error, stackTrace) {
      // AtomicSessionKeyValueStore guarantees that the durable bytes are still
      // the last successful snapshot when the new snapshot fails. If a newer
      // mutation already claimed the revision, do not let this older failure
      // clobber the newer in-memory session.
      final isLatestMutation = _credentialRevision == mutationRevision;
      if (isLatestMutation) {
        _applyCredentialSnapshot(
          _hasDurableCredentialSnapshot ? _durableCredentialSnapshot : previous,
        );
        _credentialRevision += 1;
        _clearPendingAccountCleanup();
      }
      _recordAuthenticationLog(
        isLatestMutation ? '凭据变更写入失败，已回滚到上一个会话' : '旧凭据变更写入失败，保留更新后的会话',
        level: AppLogLevel.error,
        details: {
          'operation': operation,
          'error_type': error.runtimeType.toString(),
          'action': isLatestMutation
              ? 'rolled_back'
              : 'newer_mutation_retained',
        },
      );
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '凭据变更写入失败',
          category: AppLogCategory.authentication,
        ),
      );
      if (isLatestMutation) _notifyChanged();
      return false;
    }
  }

  void _clearPendingAccountCleanup() {
    _pendingAccountCleanup = null;
    _lastDismissedCleanupRevision = -1;
    _lastDismissedCleanupAt = null;
  }

  void _recordAuthenticationLog(
    String message, {
    AppLogLevel level = AppLogLevel.info,
    Map<String, Object?> details = const {},
  }) {
    unawaited(
      AppLogStore.instance.record(
        category: AppLogCategory.authentication,
        level: level,
        message: message,
        details: details,
      ),
    );
  }

  Future<void> load() async {
    if (kIsWeb || zhIsFlutterTest) {
      // The widget-test VM has no secure-storage host registrar.  Treat it as
      // an empty in-memory session instead of starting a platform-channel
      // Future that can remain pending until a timeout timer fires.
      _storageUnavailable = true;
      _credentialStorageUnavailable = true;
      _resetValues();
      _durableCredentialSnapshot = SessionCredentialSnapshot.empty;
      _hasDurableCredentialSnapshot = true;
      _credentialStorageLoaded = true;
      notifyListeners();
      return;
    }
    // Read one consistent private-database snapshot and decode all account and
    // UI values from it. This also prevents a transient database error from
    // being mistaken for an empty account.
    Map<String, String> stored;
    try {
      stored = await _storage.readAll().timeout(const Duration(seconds: 5));
      _storageUnavailable = false;
      _credentialStorageUnavailable = false;
      if (_storage case final PrivateAppStorage privateStorage
          when privateStorage.consumeMigrationNotice()) {
        _recordAuthenticationLog(
          '已将旧版登录信息迁移到应用私有凭据数据库',
          details: const {
            'source': 'legacy_secure_storage',
            'destination': 'private_app_database',
          },
        );
      }
      if (_storage case final CredentialRecoveryStore recoveryStore) {
        _hasRecoverableAccountSession = await recoveryStore
            .hasCredentialRecovery();
      }
    } on Object catch (error) {
      _storageUnavailable = true;
      _credentialStorageUnavailable = true;
      _credentialStorageLoaded = false;
      // Never translate a storage read failure into an empty credential set.
      // The in-memory values are left untouched and the private database keeps
      // its original bytes for a later retry/recovery.
      _recordAuthenticationLog(
        '本地登录数据库读取失败，保留现有会话且未清理凭据',
        level: AppLogLevel.error,
        details: {
          'storage': 'private_app_database',
          'error_type': error.runtimeType.toString(),
          'action': 'retained',
        },
      );
      notifyListeners();
      return;
    }
    String? read(String key) => stored[key];

    authorization = read(_authorizationKey) ?? '';
    udid = read(_udidKey) ?? '';
    final rawCookie = read(_cookieKey) ?? '';
    cookie = zhihu_api.ZhihuApiClient.cookieHeaderFromValue(rawCookie);
    final cookieNeedsMigration = rawCookie.trim() != cookie;
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
    authenticationLoggingEnabled = _decodeBool(
      read(_authenticationLoggingEnabledKey),
      fallback: true,
    );
    final loadedCredentialSnapshot = _credentialSnapshot();
    _durableCredentialSnapshot = loadedCredentialSnapshot;
    _hasDurableCredentialSnapshot = true;
    _credentialStorageLoaded = true;
    if (cookieNeedsMigration && cookie.isNotEmpty) {
      // Older releases stored a bare z_c0 or accidentally nested z_c0 value.
      // Migrate the complete, normalized header atomically without changing
      // the active session or asking the user to log in again.
      try {
        await _queueCredentialPersistence(
          () => _persistCredentialSnapshot(loadedCredentialSnapshot),
        );
        _durableCredentialSnapshot = loadedCredentialSnapshot;
        _recordAuthenticationLog(
          '已规范化旧版移动登录 Cookie 上下文',
          details: const {
            'source': 'private_app_database',
            'action': 'migrated',
            'credential_values_logged': false,
          },
        );
      } on Object catch (error, stackTrace) {
        // A migration failure must not look like logout. The in-memory
        // session remains usable and the next successful write can retry it.
        _recordAuthenticationLog(
          '旧版移动登录 Cookie 规范化写入失败，保留当前会话',
          level: AppLogLevel.warning,
          details: {
            'source': 'private_app_database',
            'action': 'retained',
            'error_type': error.runtimeType.toString(),
          },
        );
        unawaited(
          AppLogStore.instance.recordError(
            error,
            stackTrace,
            message: '旧版 Cookie 规范化写入失败',
            category: AppLogCategory.authentication,
          ),
        );
      }
    }
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

  SessionCredentialSnapshot _credentialSnapshot() => SessionCredentialSnapshot(
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

  void _applyCredentialSnapshot(SessionCredentialSnapshot snapshot) {
    authorization = snapshot.authorization;
    udid = snapshot.udid;
    cookie = snapshot.cookie;
    msId = snapshot.msId;
    xZse96 = snapshot.xZse96;
    xZse96Target = snapshot.xZse96Target;
    extraHeadersJson = snapshot.extraHeadersJson;
    sessionKind = snapshot.sessionKind;
    refreshToken = snapshot.refreshToken;
    accessTokenExpiry = snapshot.accessTokenExpiry;
    accessTokenRefreshAt = snapshot.accessTokenRefreshAt;
    accountUid = snapshot.accountUid;
    accountUserId = snapshot.accountUserId;
    accountScope = snapshot.accountScope;
    accountUnlockTicket = snapshot.accountUnlockTicket;
    accountLockInSeconds = snapshot.accountLockInSeconds;
  }

  Future<void> _persistCredentialSnapshot(
    SessionCredentialSnapshot snapshot,
  ) async {
    if (zhIsFlutterTest && !_persistInFlutterTests) return;
    final values = snapshot.toStoredValues();
    try {
      final atomic = _storage;
      if (atomic case final AtomicSessionKeyValueStore storage) {
        await storage.replaceValues(
          values: values,
          keysToDelete: _credentialStorageKeys,
        );
      } else {
        // The secure-storage test adapter predates the atomic boundary. Keep
        // it usable for old tests; all production platforms use the atomic
        // PrivateAppStorage implementation above. Direct calls here preserve
        // failure reporting instead of using the best-effort preference path.
        for (final key in _credentialStorageKeys) {
          final value = values[key];
          if (value == null || value.isEmpty) {
            await _storage.delete(key: key);
          } else {
            await _storage.write(key: key, value: value);
          }
        }
      }
      _storageUnavailable = false;
      _credentialStorageUnavailable = false;
    } on Object catch (error, stackTrace) {
      _storageUnavailable = true;
      _credentialStorageUnavailable = true;
      _recordAuthenticationLog(
        '本地登录数据库原子写入失败，旧凭据仍保留',
        level: AppLogLevel.error,
        details: {
          'operation': 'atomic_credential_snapshot',
          'error_type': error.runtimeType.toString(),
          'action': 'retained',
        },
      );
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '本地登录数据库原子写入失败',
          category: AppLogCategory.authentication,
        ),
      );
      rethrow;
    }
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
    if (zhIsFlutterTest && !_persistInFlutterTests) {
      return;
    }
    try {
      await _storage
          .write(key: key, value: value)
          .timeout(const Duration(seconds: 3));
      _storageUnavailable = false;
    } on Object catch (error) {
      final firstFailure = !_storageUnavailable;
      _storageUnavailable = true;
      if (firstFailure) {
        _recordAuthenticationLog(
          '本地登录数据库写入失败，将在下次凭据变更时重试',
          level: AppLogLevel.error,
          details: {
            'operation': 'write',
            'key': key,
            'error_type': error.runtimeType.toString(),
            'action': 'retained',
          },
        );
      }
    }
  }

  Future<void> _safeDelete(String key) async {
    if (zhIsFlutterTest && !_persistInFlutterTests) {
      return;
    }
    try {
      await _storage.delete(key: key).timeout(const Duration(seconds: 3));
      _storageUnavailable = false;
    } on Object catch (error) {
      final firstFailure = !_storageUnavailable;
      _storageUnavailable = true;
      if (firstFailure) {
        _recordAuthenticationLog(
          '本地登录数据库删除失败，将在下次凭据变更时重试',
          level: AppLogLevel.error,
          details: {
            'operation': 'delete',
            'key': key,
            'error_type': error.runtimeType.toString(),
            'action': 'retained',
          },
        );
      }
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
    implements
        zhihu_api.ApiSession,
        zhihu_api.ApiSessionCookieStore,
        zhihu_api.ApiSessionCleanupDelegate {
  SessionStore({super.storage}) : super(persistInFlutterTests: false);

  @visibleForTesting
  SessionStore.withFlutterTestPersistence(FlutterSecureStorage storage)
    : super(storage: storage, persistInFlutterTests: true);

  @visibleForTesting
  SessionStore.withStorage(SessionKeyValueStore storage)
    : super(keyValueStore: storage, persistInFlutterTests: true);

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

class SessionCredentialSnapshot {
  static const empty = SessionCredentialSnapshot(
    authorization: '',
    udid: '',
    cookie: '',
    msId: '',
    xZse96: '',
    xZse96Target: '',
    extraHeadersJson: '',
    sessionKind: '',
    refreshToken: '',
    accessTokenExpiry: null,
    accessTokenRefreshAt: null,
    accountUid: '',
    accountUserId: '',
    accountScope: '',
    accountUnlockTicket: '',
    accountLockInSeconds: 0,
  );

  const SessionCredentialSnapshot({
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

  bool get isEmpty =>
      authorization.isEmpty &&
      udid.isEmpty &&
      cookie.isEmpty &&
      sessionKind.isEmpty &&
      refreshToken.isEmpty;

  bool get isUsable {
    if (sessionKind == 'account') {
      return _isBearerAuthorization(authorization) &&
          udid.trim().isNotEmpty &&
          refreshToken.trim().isNotEmpty;
    }
    if (sessionKind == 'qr') {
      return authorization.trim().isNotEmpty &&
          udid.trim().isNotEmpty &&
          cookie.split(';').any((part) {
            final separator = part.indexOf('=');
            return separator > 0 &&
                part.substring(0, separator).trim().toLowerCase() == 'z_c0' &&
                part.substring(separator + 1).trim().isNotEmpty;
          });
    }
    if (sessionKind == 'imported') {
      return authorization.trim().isNotEmpty && udid.trim().isNotEmpty;
    }
    return false;
  }

  /// True for every locally persisted login context, including manually
  /// imported contexts which do not participate in token refresh.
  bool get isRecoverableSession => isUsable;

  bool get isAccountSession {
    if (sessionKind == 'account') {
      return _isBearerAuthorization(authorization) &&
          udid.trim().isNotEmpty &&
          refreshToken.trim().isNotEmpty;
    }
    if (sessionKind != 'qr' || authorization.trim().isEmpty || udid.isEmpty) {
      return false;
    }
    return cookie.split(';').any((part) {
      final separator = part.indexOf('=');
      return separator > 0 &&
          part.substring(0, separator).trim().toLowerCase() == 'z_c0' &&
          part.substring(separator + 1).trim().isNotEmpty;
    });
  }

  Map<String, String> toStoredValues() => {
    if (authorization.isNotEmpty)
      _SessionStoreCore._authorizationKey: authorization,
    if (udid.isNotEmpty) _SessionStoreCore._udidKey: udid,
    if (cookie.isNotEmpty) _SessionStoreCore._cookieKey: cookie,
    if (msId.isNotEmpty) _SessionStoreCore._msIdKey: msId,
    if (xZse96.isNotEmpty) _SessionStoreCore._zse96Key: xZse96,
    if (xZse96Target.isNotEmpty)
      _SessionStoreCore._zse96TargetKey: xZse96Target,
    if (extraHeadersJson.isNotEmpty)
      _SessionStoreCore._extraHeadersKey: extraHeadersJson,
    if (sessionKind.isNotEmpty) _SessionStoreCore._sessionKindKey: sessionKind,
    if (refreshToken.isNotEmpty)
      _SessionStoreCore._refreshTokenKey: refreshToken,
    if (accessTokenExpiry != null)
      _SessionStoreCore._accessTokenExpiryKey: accessTokenExpiry!
          .toIso8601String(),
    if (accessTokenRefreshAt != null)
      _SessionStoreCore._accessTokenRefreshAtKey: accessTokenRefreshAt!
          .toIso8601String(),
    if (accountUid.isNotEmpty) _SessionStoreCore._accountUidKey: accountUid,
    if (accountUserId.isNotEmpty)
      _SessionStoreCore._accountUserIdKey: accountUserId,
    if (accountScope.isNotEmpty)
      _SessionStoreCore._accountScopeKey: accountScope,
    if (accountUnlockTicket.isNotEmpty)
      _SessionStoreCore._accountUnlockTicketKey: accountUnlockTicket,
    if (accountLockInSeconds > 0)
      _SessionStoreCore._accountLockInSecondsKey: accountLockInSeconds
          .toString(),
  };

  static SessionCredentialSnapshot? fromStoredValues(
    Map<String, String> values,
  ) {
    final snapshot = SessionCredentialSnapshot(
      authorization: values[_SessionStoreCore._authorizationKey] ?? '',
      udid: values[_SessionStoreCore._udidKey] ?? '',
      cookie: values[_SessionStoreCore._cookieKey] ?? '',
      msId: values[_SessionStoreCore._msIdKey] ?? '',
      xZse96: values[_SessionStoreCore._zse96Key] ?? '',
      xZse96Target: values[_SessionStoreCore._zse96TargetKey] ?? '',
      extraHeadersJson: values[_SessionStoreCore._extraHeadersKey] ?? '',
      sessionKind: values[_SessionStoreCore._sessionKindKey] ?? '',
      refreshToken: values[_SessionStoreCore._refreshTokenKey] ?? '',
      accessTokenExpiry: DateTime.tryParse(
        values[_SessionStoreCore._accessTokenExpiryKey] ?? '',
      ),
      accessTokenRefreshAt: DateTime.tryParse(
        values[_SessionStoreCore._accessTokenRefreshAtKey] ?? '',
      ),
      accountUid: values[_SessionStoreCore._accountUidKey] ?? '',
      accountUserId: values[_SessionStoreCore._accountUserIdKey] ?? '',
      accountScope: values[_SessionStoreCore._accountScopeKey] ?? '',
      accountUnlockTicket:
          values[_SessionStoreCore._accountUnlockTicketKey] ?? '',
      accountLockInSeconds:
          int.tryParse(
            values[_SessionStoreCore._accountLockInSecondsKey] ?? '',
          ) ??
          0,
    );
    return snapshot.isRecoverableSession ? snapshot : null;
  }
}
