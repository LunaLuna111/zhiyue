import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'app_log.dart';
import 'private_app_storage.dart';
import 'session_store.dart';

/// A local account slot, kept in the app-private credential database and never rendered with token
/// values. Multiple slots let a user switch between accounts or QR sessions
/// without logging out of every device/session.
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
  });

  factory StoredAccountSession.fromJson(Object? value) {
    if (value is! Map) throw const FormatException('账号槽位不是对象');
    final map = value.map((key, value) => MapEntry(key.toString(), value));
    final updatedAt = DateTime.tryParse(map['updated_at']?.toString() ?? '');
    if (updatedAt == null) throw const FormatException('账号槽位时间无效');
    return StoredAccountSession(
      id: _bounded(map['id']?.toString() ?? '', 160),
      displayName: _bounded(map['display_name']?.toString() ?? '', 120),
      authorization: _bounded(map['authorization']?.toString() ?? '', 512),
      refreshToken: _bounded(map['refresh_token']?.toString() ?? '', 512),
      udid: _bounded(map['udid']?.toString() ?? '', 512),
      cookie: _bounded(map['cookie']?.toString() ?? '', 8192),
      sessionKind: _bounded(map['session_kind']?.toString() ?? '', 24),
      accessTokenExpiry: DateTime.tryParse(
        map['access_token_expiry']?.toString() ?? '',
      ),
      accountUid: _bounded(map['account_uid']?.toString() ?? '', 160),
      accountUserId: _bounded(map['account_user_id']?.toString() ?? '', 160),
      updatedAt: updatedAt,
    );
  }

  final String id;
  final String displayName;
  final String authorization;
  final String refreshToken;
  final String udid;
  final String cookie;
  final String sessionKind;
  final DateTime? accessTokenExpiry;
  final String accountUid;
  final String accountUserId;
  final DateTime updatedAt;

  bool get isQr => sessionKind == 'qr';

  bool get isExpired =>
      accessTokenExpiry != null && !DateTime.now().isBefore(accessTokenExpiry!);

  Map<String, Object?> toJson() => {
    'id': id,
    'display_name': displayName,
    'authorization': authorization,
    'refresh_token': refreshToken,
    'udid': udid,
    'cookie': cookie,
    'session_kind': sessionKind,
    if (accessTokenExpiry != null)
      'access_token_expiry': accessTokenExpiry!.toUtc().toIso8601String(),
    'account_uid': accountUid,
    'account_user_id': accountUserId,
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
    accountUid: accountUid,
    accountUserId: accountUserId,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static String _bounded(String value, int maximum) =>
      value.length <= maximum ? value : value.substring(0, maximum);
}

class AccountSessionStore extends ChangeNotifier {
  AccountSessionStore._();

  static final instance = AccountSessionStore._();
  static const _storageKey = 'zh_account_sessions_v1';
  static const _maximumAccounts = 5;

  final PrivateAppStorage _storage = PrivateAppStorage.instance;
  final _accounts = <StoredAccountSession>[];
  Future<void>? _loading;
  Future<void> _writing = Future<void>.value();
  String _activeId = '';
  bool _loaded = false;

  List<StoredAccountSession> get accounts => List.unmodifiable(_accounts);
  String get activeId => _activeId;

  Future<void> load() {
    if (_loaded) return Future<void>.value();
    final existing = _loading;
    if (existing != null) return existing;
    final future = _loadOnce();
    _loading = future;
    return future.whenComplete(() {
      if (identical(_loading, future)) _loading = null;
    });
  }

  Future<void> _loadOnce() async {
    try {
      final raw = await _storage
          .read(_storageKey)
          .timeout(const Duration(seconds: 5));
      final loadedAccounts = <StoredAccountSession>[];
      var loadedActiveId = '';
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) throw const FormatException('账号槽位不是对象');
        loadedActiveId = decoded['active_id']?.toString() ?? '';
        final values = decoded['accounts'];
        if (values is List) {
          for (final value in values) {
            try {
              final entry = StoredAccountSession.fromJson(value);
              if (entry.id.isNotEmpty &&
                  !loadedAccounts.any((item) => item.id == entry.id)) {
                loadedAccounts.add(entry);
              }
            } on Object {
              // One malformed legacy slot must not hide the other accounts.
            }
          }
        }
      }
      _accounts
        ..clear()
        ..addAll(loadedAccounts);
      _activeId = _accounts.any((item) => item.id == loadedActiveId)
          ? loadedActiveId
          : '';
      _loaded = true;
    } on Object catch (error, stackTrace) {
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '账号槽位读取失败，保留已有列表并等待重试',
          category: AppLogCategory.authentication,
        ),
      );
    } finally {
      notifyListeners();
    }
  }

  Future<bool> rememberCurrent(
    SessionStore session, {
    String displayName = '',
  }) async {
    if (!session.hasAccountSession) return false;
    await load();
    final id = _identityFor(session);
    final existing = _accounts.where((item) => item.id == id).firstOrNull;
    final entry = StoredAccountSession(
      id: id,
      displayName: displayName.trim().isEmpty
          ? (session.accountUid.isNotEmpty
                ? '账号 ${session.accountUid}'
                : '知乎账号')
          : displayName.trim(),
      authorization: session.authorization,
      refreshToken: session.refreshToken,
      udid: session.udid,
      cookie: session.cookie,
      sessionKind: session.sessionKind,
      accessTokenExpiry: session.accessTokenExpiry,
      accountUid: session.accountUid,
      accountUserId: session.accountUserId,
      updatedAt: DateTime.now().toUtc(),
    );
    if (existing == null) {
      _accounts.add(entry);
    } else {
      final index = _accounts.indexOf(existing);
      _accounts[index] = entry;
    }
    _activeId = id;
    _trim();
    notifyListeners();
    await _persist();
    return true;
  }

  Future<bool> activate(String id, SessionStore session) async {
    await load();
    final entry = _accounts.where((item) => item.id == id).firstOrNull;
    if (entry == null || (entry.isExpired && !entry.isQr)) return false;
    final authorization = entry.authorization.trim();
    if (entry.isQr) {
      await session.saveQrSession(
        cookie: entry.cookie,
        udid: entry.udid,
        uid: entry.accountUid,
        userId: entry.accountUserId,
      );
    } else {
      if (!authorization.startsWith('Bearer ')) return false;
      final token = authorization.substring('Bearer '.length).trim();
      final expiry = entry.accessTokenExpiry;
      final expiresIn = expiry == null
          ? const Duration(days: 30)
          : expiry.difference(DateTime.now());
      if (token.isEmpty || expiresIn <= Duration.zero) return false;
      await session.saveAccountSession(
        accessToken: token,
        refreshToken: entry.refreshToken,
        udid: entry.udid,
        expiresIn: expiresIn,
        zCookie: _cookieValue(entry.cookie, 'z_c0'),
        uid: entry.accountUid,
        userId: entry.accountUserId,
      );
    }
    _activeId = entry.id;
    final index = _accounts.indexOf(entry);
    _accounts[index] = entry.copyWith(updatedAt: DateTime.now().toUtc());
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> remove(String id) async {
    await load();
    _accounts.removeWhere((entry) => entry.id == id);
    if (_activeId == id) _activeId = _accounts.firstOrNull?.id ?? '';
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    _writing = _writing.then((_) async {
      try {
        await _storage.write(
          key: _storageKey,
          value: jsonEncode({
            'active_id': _activeId,
            'accounts': _accounts.map((item) => item.toJson()).toList(),
          }),
        );
      } on Object catch (error, stackTrace) {
        unawaited(
          AppLogStore.instance.recordError(
            error,
            stackTrace,
            message: '账号槽位保存失败',
            category: AppLogCategory.app,
          ),
        );
      }
    });
    await _writing;
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

  static String _identityFor(SessionStore session) {
    final primary = session.accountUid.trim().isNotEmpty
        ? session.accountUid.trim()
        : session.accountUserId.trim();
    if (primary.isNotEmpty) return primary;
    final digest = sha1.convert(utf8.encode(session.cookie)).toString();
    return 'cookie-${digest.substring(0, 16)}';
  }

  static String _cookieValue(String cookie, String name) {
    for (final part in cookie.split(';')) {
      final separator = part.indexOf('=');
      if (separator > 0 && part.substring(0, separator).trim() == name) {
        return part.substring(separator + 1).trim();
      }
    }
    return '';
  }
}
