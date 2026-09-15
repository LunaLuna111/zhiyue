import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'platform_cache.dart';
import 'session_store.dart';

const diagnosticLogAppVersion = String.fromEnvironment(
  'ZH_APP_VERSION',
  defaultValue: '0.3.9+162',
);

enum AppLogLevel { debug, info, warning, error }

enum AppLogCategory { app, network, performance, error, authentication }

extension AppLogLevelLabel on AppLogLevel {
  String get label => switch (this) {
    AppLogLevel.debug => '调试',
    AppLogLevel.info => '信息',
    AppLogLevel.warning => '警告',
    AppLogLevel.error => '错误',
  };
}

extension AppLogCategoryLabel on AppLogCategory {
  String get label => switch (this) {
    AppLogCategory.app => '应用',
    AppLogCategory.network => '网络',
    AppLogCategory.performance => '性能',
    AppLogCategory.error => '错误',
    AppLogCategory.authentication => '认证',
  };
}

class AppLogEntry {
  const AppLogEntry({
    required this.id,
    required this.occurredAt,
    required this.level,
    required this.category,
    required this.message,
    required this.details,
  });

  final String id;
  final DateTime occurredAt;
  final AppLogLevel level;
  final AppLogCategory category;
  final String message;
  final Map<String, Object?> details;

  Map<String, Object?> toJson() => {
    'id': id,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
    'level': level.name,
    'category': category.name,
    'message': message,
    if (details.isNotEmpty) 'details': details,
  };

  factory AppLogEntry.fromJson(Object? source) {
    if (source is! Map) throw const FormatException('日志项不是对象');
    final map = source.map((key, value) => MapEntry(key.toString(), value));
    final timestamp = DateTime.tryParse(map['occurred_at']?.toString() ?? '');
    if (timestamp == null) throw const FormatException('日志时间无效');
    final level = AppLogLevel.values.firstWhere(
      (value) => value.name == map['level'],
      orElse: () => AppLogLevel.info,
    );
    final category = AppLogCategory.values.firstWhere(
      (value) => value.name == map['category'],
      orElse: () => AppLogCategory.app,
    );
    final rawDetails = map['details'];
    final details = rawDetails is Map
        ? _sanitizeMap(rawDetails, maxDepth: 3)
        : const <String, Object?>{};
    final rawId = _boundedText(map['id']?.toString() ?? '', 80);
    // Entries written by older builds used a timestamp/random suffix.  Keep
    // them uploadable, but migrate their IDs to the same 32-char MD5 format
    // used by new events so the server can deduplicate every event uniformly.
    final id = _isMd5(rawId)
        ? rawId.toLowerCase()
        : _eventMd5(
            installId: 'legacy',
            occurredAt: timestamp,
            level: level,
            category: category,
            message: _boundedText(map['message']?.toString() ?? '', 320),
            details: details,
            legacyId: rawId,
          );
    return AppLogEntry(
      id: id,
      occurredAt: timestamp.toLocal(),
      level: level,
      category: category,
      message: _boundedText(map['message']?.toString() ?? '', 320),
      details: details,
    );
  }
}

/// Small, redacted and bounded diagnostic store.  Mobile builds persist the
/// event rows in SQLite so each write stays incremental; unsupported hosts use
/// the bounded key/value fallback. It never receives credentials, cookies,
/// request bodies or response bodies.
class AppLogStore extends ChangeNotifier {
  AppLogStore._();

  static final instance = AppLogStore._();

  static const _cacheKey = 'zh_diagnostic_logs_v1';
  static const _installIdKey = 'zh_diagnostic_install_id';
  static const _maxEntries = 600;
  static const _maxPersistedBytes = 512 * 1024;
  static final _random = Random.secure();

  final _cache = ZhPlatformCache.instance;
  final _entries = <AppLogEntry>[];
  final _pendingWrites = <String, AppLogEntry>{};
  Future<void> _writeQueue = Future<void>.value();
  Timer? _persistTimer;
  Timer? _notifyTimer;
  SessionStore? _session;
  Database? _database;
  Future<Database>? _opening;
  String _installId = 'unknown';
  bool _initialized = false;
  bool _sqliteDisabled = false;
  String _lastErrorFingerprint = '';
  DateTime? _lastErrorAt;

  List<AppLogEntry> get entries => List.unmodifiable(_entries);
  String get installId => _installId;
  bool get initialized => _initialized;
  bool get _useSqlite => zhUsesSqliteCache && !_sqliteDisabled;

  Future<void> initialize({required SessionStore session}) async {
    _session = session;
    final savedInstallId = await _cache.read(_installIdKey);
    if (savedInstallId != null &&
        RegExp(r'^[a-f0-9]{24,64}$').hasMatch(savedInstallId)) {
      _installId = savedInstallId;
    } else {
      _installId = List.generate(
        32,
        (_) => _random.nextInt(16).toRadixString(16),
      ).join();
      await _cache.write(_installIdKey, _installId);
    }
    final raw = await _cache.read(_cacheKey);
    if (_useSqlite) {
      try {
        await _loadSqlite(raw);
      } on Object {
        _sqliteDisabled = true;
        await _loadLegacy(raw);
      }
    } else {
      await _loadLegacy(raw);
    }
    _initialized = true;
    _notifySoon();
  }

  bool _isEnabled(AppLogCategory category) {
    final session = _session;
    if (category == AppLogCategory.authentication) {
      // Authentication failures and cleanup decisions are enabled by default
      // so a lost session can be diagnosed. The user can explicitly disable
      // only this category without enabling the other diagnostic streams.
      return session?.authenticationLoggingEnabled ?? true;
    }
    if (session == null || !session.appLoggingEnabled) return false;
    return switch (category) {
      AppLogCategory.network => session.networkLoggingEnabled,
      AppLogCategory.performance => session.performanceLoggingEnabled,
      _ => true,
    };
  }

  Future<void> record({
    required AppLogCategory category,
    required AppLogLevel level,
    required String message,
    Map<String, Object?> details = const {},
  }) {
    if (!_isEnabled(category)) return Future<void>.value();
    final occurredAt = DateTime.now();
    final safeMessage = _boundedText(message.trim(), 320);
    final safeDetails = _sanitizeMap(details, maxDepth: 3);
    final entry = AppLogEntry(
      id: _eventMd5(
        installId: _installId,
        occurredAt: occurredAt,
        level: level,
        category: category,
        message: safeMessage,
        details: safeDetails,
      ),
      occurredAt: occurredAt,
      level: level,
      category: category,
      message: safeMessage,
      details: safeDetails,
    );
    _entries.insert(0, entry);
    if (_useSqlite) _pendingWrites[entry.id] = entry;
    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
    _notifySoon();
    // Persistence is debounced and queued below.  Return an already-complete
    // future so existing fire-and-forget call sites never wait for disk I/O.
    // Tests and very early startup can record an event before the store has
    // loaded its persistent backend. Keep the bounded in-memory entry, but do
    // not create a delayed disk timer until initialization has completed.
    if (_initialized) _persistQueued();
    return Future<void>.value();
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String message = '未处理异常',
    AppLogCategory category = AppLogCategory.error,
  }) {
    final now = DateTime.now();
    final fingerprint = '${error.runtimeType}|$error|${stackTrace.toString()}';
    final previousAt = _lastErrorAt;
    if (_lastErrorFingerprint == fingerprint &&
        previousAt != null &&
        now.difference(previousAt) < const Duration(seconds: 2)) {
      return Future<void>.value();
    }
    _lastErrorFingerprint = fingerprint;
    _lastErrorAt = now;
    return record(
      category: category,
      level: AppLogLevel.error,
      message: message,
      details: {
        'error_type': error.runtimeType.toString(),
        'error': error.toString(),
        'stack': stackTrace.toString(),
      },
    );
  }

  Future<void> recordNetwork({
    required String method,
    required Uri uri,
    required String profile,
    int? statusCode,
    String? statusLabel,
    String? businessCode,
    int? bodyBytes,
    int? durationMs,
    String? errorType,
  }) => record(
    category: AppLogCategory.network,
    level: statusCode != null && statusCode >= 500
        ? AppLogLevel.error
        : errorType != null
        ? AppLogLevel.error
        : statusCode != null && statusCode >= 400
        ? AppLogLevel.warning
        : AppLogLevel.info,
    message: errorType == null ? '网络请求完成' : '网络请求失败',
    details: {
      'method': method,
      'url': sanitizeUri(uri),
      'profile': profile,
      'status_code': ?statusCode,
      if (statusLabel case final value? when value.isNotEmpty) 'status': value,
      if (businessCode case final value? when value.isNotEmpty)
        'business_code': value,
      'response_bytes': ?bodyBytes,
      'duration_ms': ?durationMs,
      'error_type': ?errorType,
    },
  );

  Future<void> clear() async {
    _persistTimer?.cancel();
    _persistTimer = null;
    await _writeQueue;
    _entries.clear();
    _pendingWrites.clear();
    _notifySoon();
    if (_useSqlite) {
      try {
        final database = await _openDatabase();
        await database.delete('diagnostic_logs');
      } on Object {
        _sqliteDisabled = true;
      }
    }
    await _cache.remove(_cacheKey);
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert({
    'schema_version': 2,
    'exported_at': DateTime.now().toUtc().toIso8601String(),
    'app_version': diagnosticLogAppVersion,
    'install_id': _installId,
    'events': _entries.map((entry) => entry.toJson()).toList(),
  });

  Future<void> _persistQueued() {
    // Network logging is intentionally cheap on the request path.  Coalesce
    // bursts of events into one bounded preference write instead of writing a
    // growing JSON document for every response.
    _persistTimer ??= Timer(const Duration(milliseconds: 350), () {
      _persistTimer = null;
      _writeQueue = _writeQueue.then<void>((_) async {
        try {
          await _persistNow();
        } on Object catch (error, stackTrace) {
          // A cache failure must never become an unhandled future (or recurse
          // back into the logger).  The next event will retry the write.
          debugPrint('diagnostic log persistence failed: $error\n$stackTrace');
        }
      });
    });
    return Future<void>.value();
  }

  Future<void> _persistNow() async {
    if (_useSqlite) {
      await _persistSqlite();
    } else {
      await _persistLegacy();
    }
  }

  Future<void> _persistLegacy() async {
    var encoded = jsonEncode(_entries.map((entry) => entry.toJson()).toList());
    if (utf8.encode(encoded).length > _maxPersistedBytes) {
      while (_entries.length > 20 &&
          utf8.encode(encoded).length > _maxPersistedBytes) {
        _entries.removeLast();
        encoded = jsonEncode(_entries.map((entry) => entry.toJson()).toList());
      }
    }
    await _cache.write(_cacheKey, encoded);
    _pendingWrites.clear();
  }

  Future<void> _persistSqlite() async {
    if (_pendingWrites.isEmpty) return;
    final pending = Map<String, AppLogEntry>.from(_pendingWrites);
    try {
      final database = await _openDatabase();
      await database.transaction((transaction) async {
        final batch = transaction.batch();
        for (final entry in pending.values) {
          batch.insert('diagnostic_logs', {
            'id': entry.id,
            'occurred_at': entry.occurredAt.toUtc().millisecondsSinceEpoch,
            'level': entry.level.name,
            'category': entry.category.name,
            'message': entry.message,
            'details_json': jsonEncode(entry.details),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
        await transaction.rawDelete(
          'DELETE FROM diagnostic_logs WHERE id IN ('
          'SELECT id FROM diagnostic_logs '
          'ORDER BY occurred_at DESC LIMIT -1 OFFSET ?'
          ')',
          [_maxEntries],
        );
      });
      for (final entry in pending.entries) {
        if (identical(_pendingWrites[entry.key], entry.value)) {
          _pendingWrites.remove(entry.key);
        }
      }
    } on Object {
      _sqliteDisabled = true;
      // A host SQLite failure must not lose diagnostics.  Fall back to the
      // bounded key/value snapshot for this run and future writes.
      await _persistLegacy();
      for (final entry in pending.entries) {
        if (identical(_pendingWrites[entry.key], entry.value)) {
          _pendingWrites.remove(entry.key);
        }
      }
    }
  }

  Future<void> _loadLegacy(String? raw) async {
    _entries.clear();
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _entries.addAll(
          decoded
              .map((item) {
                try {
                  return AppLogEntry.fromJson(item);
                } on Object {
                  return null;
                }
              })
              .whereType<AppLogEntry>()
              .take(_maxEntries),
        );
      }
    } on Object {
      await _cache.remove(_cacheKey);
    }
  }

  Future<void> _loadSqlite(String? legacyRaw) async {
    final database = await _openDatabase();
    final rows = await database.query(
      'diagnostic_logs',
      orderBy: 'occurred_at DESC',
      limit: _maxEntries,
    );
    _entries
      ..clear()
      ..addAll(rows.map(_entryFromRow).whereType<AppLogEntry>());
    if (_entries.isNotEmpty || legacyRaw == null || legacyRaw.isEmpty) return;

    // Migrate the bounded SharedPreferences list written by older builds.
    await _loadLegacy(legacyRaw);
    if (_entries.isEmpty) return;
    final batch = database.batch();
    for (final entry in _entries) {
      batch.insert('diagnostic_logs', {
        'id': entry.id,
        'occurred_at': entry.occurredAt.toUtc().millisecondsSinceEpoch,
        'level': entry.level.name,
        'category': entry.category.name,
        'message': entry.message,
        'details_json': jsonEncode(entry.details),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    // The SQLite copy is now authoritative. Removing the old snapshot avoids
    // retaining the same log payload twice in SharedPreferences.
    await _cache.remove(_cacheKey);
  }

  AppLogEntry? _entryFromRow(Map<String, Object?> row) {
    try {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        row['occurred_at'] as int? ?? 0,
        isUtc: true,
      );
      final rawDetails = jsonDecode(row['details_json']?.toString() ?? '{}');
      return AppLogEntry.fromJson({
        'id': row['id'],
        'occurred_at': timestamp.toIso8601String(),
        'level': row['level'],
        'category': row['category'],
        'message': row['message'],
        'details': rawDetails,
      });
    } on Object {
      return null;
    }
  }

  Future<Database> _openDatabase() async {
    final existing = _database;
    if (existing != null) return existing;
    final pending = _opening;
    if (pending != null) return pending;
    final root = await getDatabasesPath();
    final opening = openDatabase(
      '$root/zh_diagnostic_logs.db',
      version: 1,
      onCreate: (database, _) async {
        await database.execute(
          'CREATE TABLE diagnostic_logs ('
          'id TEXT PRIMARY KEY, '
          'occurred_at INTEGER NOT NULL, '
          'level TEXT NOT NULL, '
          'category TEXT NOT NULL, '
          'message TEXT NOT NULL, '
          "details_json TEXT NOT NULL DEFAULT '{}'"
          ')',
        );
        await database.execute(
          'CREATE INDEX diagnostic_logs_occurred_idx '
          'ON diagnostic_logs (occurred_at DESC)',
        );
        await database.execute(
          'CREATE INDEX diagnostic_logs_category_level_idx '
          'ON diagnostic_logs (category, level, occurred_at DESC)',
        );
      },
    );
    _opening = opening;
    try {
      final database = await opening;
      _database = database;
      return database;
    } finally {
      _opening = null;
    }
  }

  void _notifySoon() {
    if (_notifyTimer != null) return;
    _notifyTimer = Timer(Duration.zero, () {
      _notifyTimer = null;
      notifyListeners();
    });
  }
}

String sanitizeUri(Uri uri) {
  final safeKeys = const {
    'offset',
    'limit',
    'page',
    'order',
    'type',
    'sort_by',
    'show_detail',
    'window_width',
  };
  final query = <String, String>{};
  for (final entry in uri.queryParameters.entries) {
    query[entry.key] = safeKeys.contains(entry.key)
        ? entry.value
        : '[redacted]';
  }
  return uri.replace(queryParameters: query).toString();
}

Map<String, Object?> _sanitizeMap(Object? source, {required int maxDepth}) {
  if (maxDepth <= 0 || source is! Map) return const <String, Object?>{};
  final result = <String, Object?>{};
  for (final entry in source.entries.take(40)) {
    final key = entry.key.toString().trim().toLowerCase();
    if (key.isEmpty) continue;
    if (RegExp(
      r'authorization|cookie|token|password|secret|body|content|html',
    ).hasMatch(key)) {
      result[key] = '[redacted]';
      continue;
    }
    final value = entry.value;
    if (value is Map) {
      result[key] = _sanitizeMap(value, maxDepth: maxDepth - 1);
    } else if (value is Iterable) {
      result[key] = value
          .take(12)
          .map((item) {
            if (item is Map) return _sanitizeMap(item, maxDepth: maxDepth - 1);
            return _sanitizeScalar(item);
          })
          .toList(growable: false);
    } else {
      result[key] = _sanitizeScalar(value);
    }
  }
  return result;
}

Object? _sanitizeScalar(Object? value) {
  if (value == null || value is num || value is bool) return value;
  return _boundedText(value.toString(), 800);
}

String _boundedText(String value, int maxLength) =>
    value.length <= maxLength ? value : '${value.substring(0, maxLength)}…';

bool _isMd5(String value) =>
    RegExp(r'^[a-f0-9]{32}$', caseSensitive: false).hasMatch(value);

String _eventMd5({
  required String installId,
  required DateTime occurredAt,
  required AppLogLevel level,
  required AppLogCategory category,
  required String message,
  required Map<String, Object?> details,
  String? legacyId,
}) {
  final canonical = <String, Object?>{
    'install_id': installId,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
    'level': level.name,
    'category': category.name,
    'message': message,
    'details': details,
    ...?(legacyId == null ? null : {'legacy_id': legacyId}),
  };
  return md5
      .convert(utf8.encode(jsonEncode(_canonicalize(canonical))))
      .toString();
}

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _canonicalize(value[key]),
    };
  }
  if (value is Iterable) {
    return value.map(_canonicalize).toList(growable: false);
  }
  if (value == null || value is num || value is bool || value is String) {
    return value;
  }
  return value.toString();
}
