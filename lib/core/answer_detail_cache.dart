import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'platform_cache.dart';

/// A small persistent cache for public answer/article detail documents.
///
/// Detail responses are deliberately kept separate from the general feed
/// cache.  A user opening the same answer repeatedly should see the exact
/// rich document immediately, while a stale entry is still allowed to be
/// replaced by the next verified API response.
class AnswerDetailCacheEntry {
  const AnswerDetailCacheEntry({
    required this.cachedAt,
    required this.document,
  });

  final DateTime cachedAt;
  final Map<String, dynamic> document;

  bool isFresh(DateTime now, {Duration ttl = AnswerDetailCache.ttl}) =>
      now.difference(cachedAt).abs() <= ttl && now.isAfter(cachedAt);
}

/// Serializable projection used by the optional WebDAV backup. It contains
/// only a cached public document and its cache key; session credentials and
/// request headers are never part of an answer cache row.
class AnswerDetailCacheSnapshot {
  const AnswerDetailCacheSnapshot({
    required this.cacheKey,
    required this.cachedAt,
    required this.document,
  });

  final String cacheKey;
  final DateTime cachedAt;
  final Map<String, dynamic> document;

  Map<String, Object?> toJson() => {
    'cache_key': cacheKey,
    'cached_at': cachedAt.toUtc().toIso8601String(),
    'document': document,
  };

  static AnswerDetailCacheSnapshot? fromJson(Object? source) {
    if (source is! Map) return null;
    final map = source.map((key, value) => MapEntry(key.toString(), value));
    final key = map['cache_key']?.toString() ?? '';
    final cachedAt = DateTime.tryParse(map['cached_at']?.toString() ?? '');
    final document = map['document'];
    if (key.isEmpty || cachedAt == null || document is! Map) return null;
    return AnswerDetailCacheSnapshot(
      cacheKey: key,
      cachedAt: cachedAt.toLocal(),
      document: document.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}

class AnswerDetailCache {
  AnswerDetailCache._();

  static final instance = AnswerDetailCache._();
  static const ttl = Duration(minutes: 30);
  static const _prefix = 'zh_answer_detail_cache_v1_';
  // SharedPreferences values are not intended for unbounded response bodies.
  // Keeping this below 4 MiB leaves room for the platform implementation and
  // avoids making a single unusually large answer block future cache reads.
  static const _maxBytes = 4 * 1024 * 1024;
  static const _maxMemoryEntries = 12;
  static const _maxRows = 80;

  final _cache = ZhPlatformCache.instance;
  final _memory = <String, AnswerDetailCacheEntry>{};
  Database? _database;
  Future<Database>? _opening;
  bool _sqliteDisabled = false;

  bool get _useSqlite => zhUsesSqliteCache && !_sqliteDisabled;

  String _key(String contentType, String contentId) {
    final type = contentType.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final id = contentId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final boundedId = id.length <= 160 ? id : id.substring(0, 160);
    return '$_prefix${type}_$boundedId';
  }

  Future<AnswerDetailCacheEntry?> read({
    required String contentType,
    required String contentId,
  }) async {
    if (contentType.trim().isEmpty || contentId.trim().isEmpty) return null;
    final key = _key(contentType, contentId);
    final inMemory = _memory[key];
    if (inMemory != null) {
      _touch(key, inMemory);
      return inMemory;
    }
    if (_useSqlite) {
      try {
        final database = await _openDatabase();
        final rows = await database.query(
          'answer_detail_cache',
          where: 'cache_key = ?',
          whereArgs: [key],
          limit: 1,
        );
        if (rows.isNotEmpty) {
          final entry = _entryFromRow(rows.single);
          if (entry != null) {
            _remember(key, entry);
            return entry;
          }
        }
      } on Object {
        _sqliteDisabled = true;
      }
    }
    final raw = await _cache.read(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final timestamp = DateTime.tryParse(
        decoded['cached_at']?.toString() ?? '',
      );
      final document = decoded['document'];
      if (timestamp == null || document is! Map) return null;
      final entry = AnswerDetailCacheEntry(
        cachedAt: timestamp.toLocal(),
        document: document.map((key, value) => MapEntry(key.toString(), value)),
      );
      _remember(key, entry);
      if (_useSqlite) unawaited(_migrateLegacyEntry(key, entry));
      return entry;
    } on Object {
      await remove(contentType: contentType, contentId: contentId);
      return null;
    }
  }

  Future<bool> write({
    required String contentType,
    required String contentId,
    required Map<String, dynamic> document,
  }) async {
    if (contentType.trim().isEmpty || contentId.trim().isEmpty) return false;
    try {
      final key = _key(contentType, contentId);
      final encoded = jsonEncode({
        'cached_at': DateTime.now().toUtc().toIso8601String(),
        'document': document,
      });
      if (utf8.encode(encoded).length > _maxBytes) return false;
      _remember(
        key,
        AnswerDetailCacheEntry(
          cachedAt: DateTime.now(),
          document: Map<String, dynamic>.from(document),
        ),
      );
      if (_useSqlite) {
        try {
          await _writeSqlite(key, _memory[key]!);
          return true;
        } on Object {
          _sqliteDisabled = true;
        }
      }
      return _cache.write(key, encoded);
    } on Object {
      return false;
    }
  }

  Future<bool> remove({
    required String contentType,
    required String contentId,
  }) {
    final key = _key(contentType, contentId);
    _memory.remove(key);
    return _remove(key);
  }

  /// Exports the durable answer cache rows for WebDAV synchronization.
  /// SQLite is queried directly so entries evicted from the in-memory LRU are
  /// still included.
  Future<List<AnswerDetailCacheSnapshot>> exportEntries() async {
    if (_useSqlite) {
      try {
        final database = await _openDatabase();
        final rows = await database.query(
          'answer_detail_cache',
          orderBy: 'cached_at DESC',
          limit: _maxRows,
        );
        return rows
            .map(_snapshotFromRow)
            .whereType<AnswerDetailCacheSnapshot>()
            .toList(growable: false);
      } on Object {
        _sqliteDisabled = true;
      }
    }
    final snapshots = <AnswerDetailCacheSnapshot>[];
    final keys = await _cache.keys();
    for (final key in keys.where((item) => item.startsWith(_prefix))) {
      final raw = await _cache.read(key);
      if (raw == null || raw.isEmpty) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) continue;
        final cachedAt = DateTime.tryParse(
          decoded['cached_at']?.toString() ?? '',
        );
        final document = decoded['document'];
        if (cachedAt == null || document is! Map) continue;
        snapshots.add(
          AnswerDetailCacheSnapshot(
            cacheKey: key,
            cachedAt: cachedAt.toLocal(),
            document: document.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          ),
        );
      } on Object {
        // One malformed optional cache row must not prevent other rows from
        // being synchronized.
      }
      if (snapshots.length >= _maxRows) break;
    }
    snapshots.sort((left, right) => right.cachedAt.compareTo(left.cachedAt));
    return snapshots;
  }

  /// Restores remote rows. By default they are marked stale so the next
  /// detail load requests current content; WebDAV startup sync can preserve
  /// the timestamp to reuse a recent cloud cache until the user refreshes.
  Future<int> importEntries(
    Iterable<AnswerDetailCacheSnapshot> entries, {
    bool markStale = true,
  }) async {
    var imported = 0;
    for (final snapshot in entries) {
      if (!snapshot.cacheKey.startsWith(_prefix) ||
          snapshot.cacheKey.length > 256 ||
          snapshot.document.isEmpty) {
        continue;
      }
      final cachedAt = markStale
          ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
          : snapshot.cachedAt.toUtc();
      final entry = AnswerDetailCacheEntry(
        cachedAt: cachedAt.toLocal(),
        document: Map<String, dynamic>.from(snapshot.document),
      );
      final encoded = jsonEncode({
        'cached_at': entry.cachedAt.toUtc().toIso8601String(),
        'document': entry.document,
      });
      if (utf8.encode(encoded).length > _maxBytes) continue;
      _remember(snapshot.cacheKey, entry);
      try {
        if (_useSqlite) {
          await _writeSqlite(snapshot.cacheKey, entry);
        } else {
          await _writeFallback(snapshot.cacheKey, entry);
        }
        imported += 1;
      } on Object {
        _sqliteDisabled = true;
        try {
          await _writeFallback(snapshot.cacheKey, entry);
          imported += 1;
        } on Object {
          // The memory layer remains usable for this process.
        }
      }
    }
    return imported;
  }

  Future<bool> _remove(String key) async {
    var removed = false;
    if (_useSqlite) {
      try {
        final database = await _openDatabase();
        removed =
            (await database.delete(
              'answer_detail_cache',
              where: 'cache_key = ?',
              whereArgs: [key],
            )) >
            0;
      } on Object {
        _sqliteDisabled = true;
      }
    }
    return (await _cache.remove(key)) || removed;
  }

  Future<void> _writeSqlite(String key, AnswerDetailCacheEntry entry) async {
    final database = await _openDatabase();
    await database.insert('answer_detail_cache', {
      'cache_key': key,
      'cached_at': entry.cachedAt.toUtc().millisecondsSinceEpoch,
      'document_json': jsonEncode(entry.document),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    unawaited(_pruneSqlite(database));
  }

  Future<void> _writeFallback(String key, AnswerDetailCacheEntry entry) async {
    final encoded = jsonEncode({
      'cached_at': entry.cachedAt.toUtc().toIso8601String(),
      'document': entry.document,
    });
    if (utf8.encode(encoded).length > _maxBytes) {
      throw const FormatException('回答缓存超过大小限制');
    }
    await _cache.write(key, encoded);
  }

  Future<void> _migrateLegacyEntry(
    String key,
    AnswerDetailCacheEntry entry,
  ) async {
    try {
      await _writeSqlite(key, entry);
      // Do not keep a second copy of a potentially multi-megabyte document in
      // SharedPreferences after it has reached the durable SQLite store.
      await _cache.remove(key);
    } on Object {
      // A legacy hit is already usable for this frame.  If SQLite is
      // unavailable, retain the fallback so the next read remains safe.
    }
  }

  Future<void> _pruneSqlite(Database database) async {
    try {
      await database.rawDelete(
        'DELETE FROM answer_detail_cache WHERE cache_key IN ('
        'SELECT cache_key FROM answer_detail_cache '
        'ORDER BY cached_at DESC LIMIT -1 OFFSET ?'
        ')',
        [_maxRows],
      );
    } on Object {
      // Cache pruning is best effort and must never affect a detail read.
    }
  }

  AnswerDetailCacheEntry? _entryFromRow(Map<String, Object?> row) {
    try {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        row['cached_at'] as int? ?? 0,
        isUtc: true,
      );
      final decoded = jsonDecode(row['document_json']?.toString() ?? '{}');
      if (decoded is! Map) return null;
      return AnswerDetailCacheEntry(
        cachedAt: timestamp.toLocal(),
        document: decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    } on Object {
      return null;
    }
  }

  AnswerDetailCacheSnapshot? _snapshotFromRow(Map<String, Object?> row) {
    final entry = _entryFromRow(row);
    final key = row['cache_key']?.toString() ?? '';
    if (entry == null || key.isEmpty) return null;
    return AnswerDetailCacheSnapshot(
      cacheKey: key,
      cachedAt: entry.cachedAt,
      document: entry.document,
    );
  }

  Future<Database> _openDatabase() async {
    final existing = _database;
    if (existing != null) return existing;
    final pending = _opening;
    if (pending != null) return pending;
    final root = await getDatabasesPath();
    final opening = openDatabase(
      '$root/zh_content_detail_cache.db',
      version: 1,
      onCreate: (database, _) async {
        await database.execute(
          'CREATE TABLE answer_detail_cache ('
          'cache_key TEXT PRIMARY KEY, '
          'cached_at INTEGER NOT NULL, '
          'document_json TEXT NOT NULL'
          ')',
        );
        await database.execute(
          'CREATE INDEX answer_detail_cache_time_idx '
          'ON answer_detail_cache (cached_at DESC)',
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

  void _remember(String key, AnswerDetailCacheEntry entry) {
    _memory
      ..remove(key)
      ..[key] = entry;
    while (_memory.length > _maxMemoryEntries) {
      _memory.remove(_memory.keys.first);
    }
  }

  void _touch(String key, AnswerDetailCacheEntry entry) =>
      _remember(key, entry);
}
