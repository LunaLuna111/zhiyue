import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'app_log.dart';
import 'private_app_storage.dart';
import 'session_store.dart';

typedef AccountSessionVerifier = Future<bool> Function();

/// A local account slot, kept in the app-private credential database and never
/// rendered with token values. The slot stores the complete session snapshot so
/// switching accounts cannot borrow metadata from the previously active one.
class StoredAccountSession {
  const StoredAccountSession({
    required this.id,
    required this.displayName,
    required this.authorization,
    required this.refreshToken,
    required this.udid,
    required this.cookie,
    required this.sessionKind,
    required this.accessTokenExpiry,
    required this.accountUid,
    required this.accountUserId,
    required this.updatedAt,
    this.msId = '',
    this.xZse96 = '',
    this.xZse96Target = '',
    this.extraHeadersJson = '',
    this.accessTokenRefreshAt,
    this.accountScope = '',
    this.accountUnlockTicket = '',
    this.accountLockInSeconds = 0,
  });

  factory StoredAccountSession.fromJson(Object? value) {
    if (value is! Map) throw const FormatException('账号槽位不是对象');
    final map = value.map((key, value) => MapEntry(key.toString(), value));
    final id = _bounded(map['id']?.toString() ?? '', 512);
    final accountUid = _bounded(map['account_uid']?.toString() ?? '', 512);
    final accountUserId = _bounded(
      map['account_user_id']?.toString() ?? '',
      512,
    );
    final updatedAt = _dateTime(map['updated_at'], '账号槽位时间');
    final accessTokenExpiry = _optionalDateTime(
      map['access_token_expiry'],
      'Token 有效期',
    );
    final accessTokenRefreshAt = _optionalDateTime(
      map['access_token_refresh_at'],
      'Token 刷新时间',
    );
    return StoredAccountSession(
      id: id,
      displayName: _normalizeDisplayName(
        map['display_name']?.toString() ?? '',
        id: id,
        accountUid: accountUid,
        accountUserId: accountUserId,
      ),
      authorization: _bounded(
        map['authorization']?.toString() ?? '',
        16 * 1024,
      ),
      refreshToken: _bounded(map['refresh_token']?.toString() ?? '', 16 * 1024),
      udid: _bounded(map['udid']?.toString() ?? '', 2048),
      cookie: _bounded(map['cookie']?.toString() ?? '', 64 * 1024),
      sessionKind: _bounded(map['session_kind']?.toString() ?? '', 64),
      accessTokenExpiry: accessTokenExpiry,
      accessTokenRefreshAt: accessTokenRefreshAt,
      accountUid: accountUid,
      accountUserId: accountUserId,
      msId: _bounded(map['ms_id']?.toString() ?? '', 16 * 1024),
      xZse96: _bounded(map['x_zse_96']?.toString() ?? '', 16 * 1024),
      xZse96Target: _bounded(
        map['x_zse_96_target']?.toString() ?? '',
        16 * 1024,
      ),
      extraHeadersJson: _bounded(
        map['extra_headers']?.toString() ?? '',
        64 * 1024,
      ),
      accountScope: _bounded(map['account_scope']?.toString() ?? '', 16 * 1024),
      accountUnlockTicket: _bounded(
        map['account_unlock_ticket']?.toString() ?? '',
        16 * 1024,
      ),
      accountLockInSeconds:
          _nonNegativeInt(map['account_lock_in_seconds']) ?? 0,
      updatedAt: updatedAt,
    );
  }

  factory StoredAccountSession.fromSnapshot({
    required String id,
    required String displayName,
    required SessionCredentialSnapshot snapshot,
    DateTime? updatedAt,
  }) => StoredAccountSession(
    id: id,
    displayName: _normalizeDisplayName(
      displayName,
      id: id,
      accountUid: snapshot.accountUid,
      accountUserId: snapshot.accountUserId,
    ),
    authorization: snapshot.authorization,
    refreshToken: snapshot.refreshToken,
    udid: snapshot.udid,
    cookie: snapshot.cookie,
    sessionKind: snapshot.sessionKind,
    accessTokenExpiry: snapshot.accessTokenExpiry,
    accessTokenRefreshAt: snapshot.accessTokenRefreshAt,
    accountUid: snapshot.accountUid,
    accountUserId: snapshot.accountUserId,
    msId: snapshot.msId,
    xZse96: snapshot.xZse96,
    xZse96Target: snapshot.xZse96Target,
    extraHeadersJson: snapshot.extraHeadersJson,
    accountScope: snapshot.accountScope,
    accountUnlockTicket: snapshot.accountUnlockTicket,
    accountLockInSeconds: snapshot.accountLockInSeconds,
    updatedAt: updatedAt ?? DateTime.now().toUtc(),
  );

  final String id;
  final String displayName;
  final String authorization;
  final String refreshToken;
  final String udid;
  final String cookie;
  final String sessionKind;
  final DateTime? accessTokenExpiry;
  final DateTime? accessTokenRefreshAt;
  final String accountUid;
  final String accountUserId;
  final String msId;
  final String xZse96;
  final String xZse96Target;
  final String extraHeadersJson;
  final String accountScope;
  final String accountUnlockTicket;
  final int accountLockInSeconds;
  final DateTime updatedAt;

  bool get isQr => sessionKind == 'qr';
  bool get isImported => sessionKind == 'imported';

  bool get isExpired =>
      accessTokenExpiry != null &&
      !DateTime.now().toUtc().isBefore(accessTokenExpiry!.toUtc());

  bool get hasRefreshToken => refreshToken.trim().isNotEmpty;

  bool get isUsable => toCredentialSnapshot().isUsable;

  SessionCredentialSnapshot toCredentialSnapshot() => SessionCredentialSnapshot(
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

  bool matchesSnapshot(SessionCredentialSnapshot snapshot) {
    return authorization == snapshot.authorization &&
        refreshToken == snapshot.refreshToken &&
        udid == snapshot.udid &&
        cookie == snapshot.cookie &&
        sessionKind == snapshot.sessionKind &&
        accessTokenExpiry == snapshot.accessTokenExpiry &&
        accessTokenRefreshAt == snapshot.accessTokenRefreshAt &&
        accountUid == snapshot.accountUid &&
        accountUserId == snapshot.accountUserId &&
        msId == snapshot.msId &&
        xZse96 == snapshot.xZse96 &&
        xZse96Target == snapshot.xZse96Target &&
        extraHeadersJson == snapshot.extraHeadersJson &&
        accountScope == snapshot.accountScope &&
        accountUnlockTicket == snapshot.accountUnlockTicket &&
        accountLockInSeconds == snapshot.accountLockInSeconds;
  }

  Map<String, Object?> toJson() => {
    'schema_version': 2,
    'id': id,
    'display_name': displayName,
    'authorization': authorization,
    'refresh_token': refreshToken,
    'udid': udid,
    'cookie': cookie,
    'session_kind': sessionKind,
    if (accessTokenExpiry != null)
      'access_token_expiry': accessTokenExpiry!.toUtc().toIso8601String(),
    if (accessTokenRefreshAt != null)
      'access_token_refresh_at': accessTokenRefreshAt!
          .toUtc()
          .toIso8601String(),
    'account_uid': accountUid,
    'account_user_id': accountUserId,
    'ms_id': msId,
    'x_zse_96': xZse96,
    'x_zse_96_target': xZse96Target,
    'extra_headers': extraHeadersJson,
    'account_scope': accountScope,
    'account_unlock_ticket': accountUnlockTicket,
    'account_lock_in_seconds': accountLockInSeconds,
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  StoredAccountSession copyWith({DateTime? updatedAt}) => StoredAccountSession(
    id: id,
    displayName: displayName,
    authorization: authorization,
    refreshToken: refreshToken,
    udid: udid,
    cookie: cookie,
    sessionKind: sessionKind,
    accessTokenExpiry: accessTokenExpiry,
    accessTokenRefreshAt: accessTokenRefreshAt,
    accountUid: accountUid,
    accountUserId: accountUserId,
    msId: msId,
    xZse96: xZse96,
    xZse96Target: xZse96Target,
    extraHeadersJson: extraHeadersJson,
    accountScope: accountScope,
    accountUnlockTicket: accountUnlockTicket,
    accountLockInSeconds: accountLockInSeconds,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static DateTime _dateTime(Object? value, String label) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) throw FormatException('$label无效');
    return parsed;
  }

  static DateTime? _optionalDateTime(Object? value, String label) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) throw FormatException('$label无效');
    return parsed;
  }

  static int? _nonNegativeInt(Object? value) {
    final parsed = int.tryParse(value?.toString() ?? '');
    return parsed == null || parsed < 0 ? null : parsed;
  }

  static String _bounded(String value, int maximum) {
    if (value.length > maximum) throw const FormatException('账号槽位字段过长');
    return value;
  }

  static String _normalizeDisplayName(
    String value, {
    required String id,
    required String accountUid,
    required String accountUserId,
  }) {
    final normalized = value.trim();
    final fallback = _fallbackDisplayName(
      id: id,
      accountUid: accountUid,
      accountUserId: accountUserId,
    );
    if (normalized.isEmpty) return fallback;
    if ({id, accountUid, accountUserId}.contains(normalized)) return fallback;
    if (normalized.startsWith('账号 ')) {
      final suffix = normalized.substring(3).trim();
      if ({id, accountUid, accountUserId}.contains(suffix)) return fallback;
    }
    return _bounded(normalized, 120);
  }

  static String _fallbackDisplayName({
    required String id,
    required String accountUid,
    required String accountUserId,
  }) {
    final identity = accountUid.isNotEmpty
        ? accountUid
        : accountUserId.isNotEmpty
        ? accountUserId
        : id.startsWith('session-')
        ? id
        : '';
    if (identity.isEmpty) return '知乎账号';
    if (identity.length <= 8) return '账号 ${identity.substring(0, 2)}…';
    return '账号 ${identity.substring(0, 3)}…${identity.substring(identity.length - 3)}';
  }
}

class AccountSessionStore extends ChangeNotifier {
  AccountSessionStore._(this._storage);

  static final instance = AccountSessionStore._(PrivateAppStorage.instance);
  static const _storageKey = 'zh_account_sessions_v1';
  static const _backupStorageKey = 'zh_account_sessions_v1_backup';
  static const _maximumAccounts = 5;

  @visibleForTesting
  AccountSessionStore.withStorage(SessionKeyValueStore storage)
    : this._(storage);

  final SessionKeyValueStore _storage;
  final _accounts = <StoredAccountSession>[];
  Future<bool>? _loading;
  Future<void> _writing = Future<void>.value();
  Future<void> _mutating = Future<void>.value();
  String _activeId = '';
  bool _loaded = false;

  List<StoredAccountSession> get accounts => List.unmodifiable(_accounts);
  String get activeId => _activeId;

  Future<bool> load() {
    if (_loaded) return Future<bool>.value(true);
    final existing = _loading;
    if (existing != null) return existing;
    final future = _loadOnce();
    _loading = future;
    return future.whenComplete(() {
      if (identical(_loading, future)) _loading = null;
    });
  }

  Future<bool> _loadOnce() async {
    try {
      final stored = await _storage.readAll().timeout(
        const Duration(seconds: 5),
      );
      final primary = stored[_storageKey];
      final backup = stored[_backupStorageKey];
      _AccountSlotState state;
      var usedBackup = false;
      final primaryMissing = primary == null || primary.isEmpty;
      if (primaryMissing && backup != null && backup.isNotEmpty) {
        state = _decodeState(backup);
        usedBackup = true;
        _recordAuthenticationLog(
          '账号槽位主记录缺失，已从备份恢复',
          level: AppLogLevel.warning,
          details: const {'action': 'backup_recovered'},
        );
      } else {
        try {
          state = _decodeState(primary);
        } on Object catch (primaryError, primaryStackTrace) {
          if (backup == null || backup.isEmpty) {
            Error.throwWithStackTrace(primaryError, primaryStackTrace);
          }
          state = _decodeState(backup);
          usedBackup = true;
          _recordError(
            '账号槽位主记录损坏，已从备份恢复',
            primaryError,
            primaryStackTrace,
            details: const {'action': 'backup_recovered'},
          );
        }
      }
      _accounts
        ..clear()
        ..addAll(state.accounts);
      _activeId = _accounts.any((item) => item.id == state.activeId)
          ? state.activeId
          : '';
      _loaded = true;
      if (usedBackup || state.needsRewrite) {
        await _persistSnapshot(List.of(_accounts), _activeId);
      }
      return true;
    } on Object catch (error, stackTrace) {
      _recordError(
        '账号槽位读取失败，禁止基于不完整列表写回',
        error,
        stackTrace,
        level: AppLogLevel.error,
        details: const {'action': 'retained_and_retryable'},
      );
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> rememberCurrent(
    SessionStore session, {
    String displayName = '',
  }) => _enqueueMutation(() async {
    if (!session.hasStoredCredentialSession) return false;
    if (!await load()) return false;
    return _rememberCurrentLoaded(session, displayName: displayName);
  });

  Future<bool> syncCurrentSession(SessionStore session) =>
      _enqueueMutation(() async {
        if (!session.isCredentialStorageReady) return false;
        if (!await load()) return false;
        if (!session.hasStoredCredentialSession) {
          if (_activeId.isEmpty) return true;
          final previousActiveId = _activeId;
          _activeId = '';
          final saved = await _persistSnapshot(List.of(_accounts), _activeId);
          if (!saved) _activeId = previousActiveId;
          notifyListeners();
          return saved;
        }
        final snapshot = session.captureCredentialSnapshot();
        final id = _identityForSnapshot(snapshot);
        final existing = _accounts.where((item) => item.id == id).firstOrNull;
        if (existing != null &&
            existing.matchesSnapshot(snapshot) &&
            _activeId == id) {
          return true;
        }
        return _rememberCurrentLoaded(session);
      });

  /// Temporarily installs a candidate, verifies it, and only then persists it
  /// as the active session. A failed verification restores the prior snapshot.
  Future<bool> activate(
    String id,
    SessionStore session, {
    AccountSessionVerifier? verify,
  }) => _enqueueMutation(() async {
    if (!await load()) return false;
    final entry = _accounts.where((item) => item.id == id).firstOrNull;
    if (entry == null || !entry.isUsable) return false;
    if (entry.isExpired && !entry.isQr && verify == null) return false;

    final previousSession = session.captureCredentialSnapshot();
    final previousAccounts = List.of(_accounts);
    final previousActiveId = _activeId;
    final installed = await session.installCredentialSnapshot(
      entry.toCredentialSnapshot(),
      persist: false,
    );
    if (!installed) return false;
    final candidateId = entry.id;
    var verified = true;
    if (verify != null) {
      try {
        verified = await verify();
      } on Object catch (error, stackTrace) {
        verified = false;
        _recordError(
          '账号候选会话验证异常',
          error,
          stackTrace,
          level: AppLogLevel.warning,
          details: const {'action': 'switch_rolled_back'},
        );
      }
    }
    if (!verified || !_sessionMatchesIdentity(session, candidateId)) {
      await _rollbackSession(session, previousSession, candidateId);
      return false;
    }

    final candidateSnapshot = session.captureCredentialSnapshot();
    if (!await session.persistCurrentCredentialSnapshot()) {
      await _rollbackSession(session, previousSession, candidateId);
      return false;
    }
    _activeId = candidateId;
    final index = _accounts.indexOf(entry);
    _accounts[index] = StoredAccountSession.fromSnapshot(
      id: candidateId,
      displayName: entry.displayName,
      snapshot: candidateSnapshot,
    );
    final saved = await _persistSnapshot(List.of(_accounts), _activeId);
    if (!saved) {
      _accounts
        ..clear()
        ..addAll(previousAccounts);
      _activeId = previousActiveId;
      await _rollbackSession(session, previousSession, candidateId);
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  });

  /// Removes a local slot. Removing the currently active slot also clears the
  /// local active credentials (with a recoverable archive) so the deleted slot
  /// cannot be silently recreated on the next startup.
  Future<bool> remove(String id, {SessionStore? session}) =>
      _enqueueMutation(() async {
        if (!await load()) return false;
        final entry = _accounts.where((item) => item.id == id).firstOrNull;
        if (entry == null) return false;
        if (_activeId == id && session == null) {
          _recordAuthenticationLog(
            '拒绝在没有会话边界的情况下删除当前账号槽位',
            level: AppLogLevel.error,
            details: const {'action': 'retained'},
          );
          return false;
        }
        final previousAccounts = List.of(_accounts);
        final previousActiveId = _activeId;
        final currentId = session == null
            ? ''
            : _identityForSnapshot(session.captureCredentialSnapshot());
        final removesCurrentSession =
            session != null &&
            session.hasStoredCredentialSession &&
            (_activeId == id || currentId == id);
        final previousSession = removesCurrentSession
            ? session.captureCredentialSnapshot()
            : null;
        final recovery = _storage is CredentialRecoveryStore
            ? _storage as CredentialRecoveryStore
            : null;
        final shouldArchiveEntry =
            recovery != null &&
            entry.isUsable &&
            (!removesCurrentSession ||
                previousSession == null ||
                !entry.matchesSnapshot(previousSession));
        if (shouldArchiveEntry) {
          try {
            await recovery.archiveCredentialSnapshot(
              values: entry.toCredentialSnapshot().toStoredValues(),
              reason: 'account_slot_removed',
              detectedAt: DateTime.now().toUtc(),
            );
          } on Object catch (error, stackTrace) {
            _recordError(
              '账号槽位删除前备份失败，已取消删除',
              error,
              stackTrace,
              level: AppLogLevel.error,
              details: const {'action': 'retained'},
            );
            return false;
          }
        }
        if (removesCurrentSession &&
            !await session.clearAccountCredentialsAndReport()) {
          return false;
        }
        _accounts.removeWhere((item) => item.id == id);
        if (_activeId == id) _activeId = '';
        final saved = await _persistSnapshot(List.of(_accounts), _activeId);
        if (!saved) {
          _accounts
            ..clear()
            ..addAll(previousAccounts);
          _activeId = previousActiveId;
          if (previousSession != null) {
            await _restoreSessionAfterFailure(session, previousSession);
          }
          notifyListeners();
          return false;
        }
        notifyListeners();
        return true;
      });

  Future<bool> _rememberCurrentLoaded(
    SessionStore session, {
    String displayName = '',
  }) async {
    final previousAccounts = List.of(_accounts);
    final previousActiveId = _activeId;
    final snapshot = session.captureCredentialSnapshot();
    final id = _identityForSnapshot(snapshot);
    final entry = StoredAccountSession.fromSnapshot(
      id: id,
      displayName: displayName,
      snapshot: snapshot,
    );
    final existing = _accounts.where((item) => item.id == id).firstOrNull;
    if (existing == null) {
      _accounts.add(entry);
    } else {
      _accounts[_accounts.indexOf(existing)] = entry;
    }
    _activeId = id;
    _trim();
    final saved = await _persistSnapshot(List.of(_accounts), _activeId);
    if (!saved) {
      _accounts
        ..clear()
        ..addAll(previousAccounts);
      _activeId = previousActiveId;
    }
    notifyListeners();
    return saved;
  }

  Future<bool> _persistSnapshot(
    List<StoredAccountSession> accounts,
    String activeId,
  ) {
    final encoded = jsonEncode({
      'schema_version': 2,
      'active_id': activeId,
      'accounts': accounts.map((item) => item.toJson()).toList(),
    });
    final operation = _writing.then((_) async {
      try {
        // The primary row is authoritative. A backup failure must not turn a
        // successful primary write into an in-memory rollback that can later
        // resurrect stale data.
        await _storage.write(key: _storageKey, value: encoded);
        try {
          await _storage.write(key: _backupStorageKey, value: encoded);
        } on Object catch (error, stackTrace) {
          _recordError(
            '账号槽位备份写入失败，但主记录已保存',
            error,
            stackTrace,
            level: AppLogLevel.warning,
            details: const {'action': 'primary_retained'},
          );
        }
        return true;
      } on Object catch (error, stackTrace) {
        _recordError(
          '账号槽位保存失败，保留旧的持久化列表',
          error,
          stackTrace,
          level: AppLogLevel.error,
          details: const {'action': 'retained'},
        );
        return false;
      }
    });
    _writing = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _rollbackSession(
    SessionStore session,
    SessionCredentialSnapshot previous,
    String candidateId,
  ) async {
    if (!_sessionMatchesIdentity(session, candidateId)) return;
    final restored = await session.installCredentialSnapshot(
      previous,
      persist: true,
      allowEmpty: true,
    );
    if (!restored) {
      _recordAuthenticationLog(
        '账号切换失败后回滚本地会话失败',
        level: AppLogLevel.error,
        details: const {'action': 'manual_recovery_required'},
      );
    }
  }

  Future<void> _restoreSessionAfterFailure(
    SessionStore? session,
    SessionCredentialSnapshot previous,
  ) async {
    if (session == null) return;
    await session.installCredentialSnapshot(
      previous,
      persist: true,
      allowEmpty: true,
    );
  }

  void _trim() {
    _accounts.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    while (_accounts.length > _maximumAccounts) {
      final removed = _accounts.removeLast();
      if (removed.id == _activeId && _accounts.isNotEmpty) {
        _activeId = _accounts.first.id;
      }
    }
  }

  static String _identityForSnapshot(SessionCredentialSnapshot snapshot) {
    final primary = snapshot.accountUid.trim().isNotEmpty
        ? snapshot.accountUid.trim()
        : snapshot.accountUserId.trim();
    if (primary.isNotEmpty) return primary;
    final seed = snapshot.cookie.trim().isNotEmpty
        ? snapshot.cookie
        : snapshot.refreshToken.trim().isNotEmpty
        ? snapshot.refreshToken
        : snapshot.authorization;
    final digest = sha1.convert(utf8.encode(seed)).toString();
    return 'session-${digest.substring(0, 16)}';
  }

  static bool _sessionMatchesIdentity(SessionStore session, String id) {
    final snapshot = session.captureCredentialSnapshot();
    return snapshot.isUsable && _identityForSnapshot(snapshot) == id;
  }

  static _AccountSlotState _decodeState(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const _AccountSlotState(
        accounts: [],
        activeId: '',
        needsRewrite: false,
      );
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw const FormatException('账号槽位不是对象');
    final rawAccounts = decoded['accounts'];
    if (rawAccounts != null && rawAccounts is! List) {
      throw const FormatException('账号槽位列表不是数组');
    }
    final accounts = <StoredAccountSession>[];
    var needsRewrite = (decoded['schema_version']?.toString() ?? '') != '2';
    if (rawAccounts is List) {
      for (final value in rawAccounts) {
        try {
          final entry = StoredAccountSession.fromJson(value);
          if (entry.id.isNotEmpty &&
              !accounts.any((item) => item.id == entry.id)) {
            accounts.add(entry);
          } else {
            needsRewrite = true;
          }
        } on Object {
          // A malformed legacy slot must not hide the other accounts, but the
          // repaired list is persisted after a successful load.
          needsRewrite = true;
        }
      }
    }
    return _AccountSlotState(
      accounts: accounts,
      activeId: decoded['active_id']?.toString() ?? '',
      needsRewrite: needsRewrite,
    );
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

  void _recordError(
    String message,
    Object error,
    StackTrace stackTrace, {
    AppLogLevel level = AppLogLevel.error,
    Map<String, Object?> details = const {},
  }) {
    _recordAuthenticationLog(message, level: level, details: details);
    unawaited(
      AppLogStore.instance.recordError(
        error,
        stackTrace,
        message: message,
        category: AppLogCategory.authentication,
      ),
    );
  }

  Future<T> _enqueueMutation<T>(Future<T> Function() operation) {
    final queued = _mutating.then((_) => operation());
    _mutating = queued.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return queued;
  }
}

class _AccountSlotState {
  const _AccountSlotState({
    required this.accounts,
    required this.activeId,
    required this.needsRewrite,
  });

  final List<StoredAccountSession> accounts;
  final String activeId;
  final bool needsRewrite;
}
