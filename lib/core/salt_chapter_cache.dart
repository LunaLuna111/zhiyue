import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'platform_cache.dart';
import 'salt_text_chapter.dart';

class SaltCachedChapter {
  const SaltCachedChapter({
    required this.businessId,
    required this.sectionId,
    required this.title,
    required this.sectionIndex,
    required this.responseJson,
    required this.xhtml,
    required this.cachedAt,
  });

  final String businessId;
  final String sectionId;
  final String title;
  final int? sectionIndex;
  final Object? responseJson;
  final String xhtml;
  final DateTime cachedAt;

  SaltTextChapter toTextChapter() =>
      SaltTextChapter.fromXhtml(chapterId: sectionId, xhtml: xhtml);

  Map<String, Object?> toJson() => {
    'business_id': businessId,
    'section_id': sectionId,
    'title': title,
    'section_index': sectionIndex,
    'response_json': responseJson,
    'xhtml': xhtml,
    'cached_at': cachedAt.toUtc().toIso8601String(),
  };

  static SaltCachedChapter? fromJson(Object? source) {
    if (source is! Map) return null;
    final map = source.map((key, value) => MapEntry(key.toString(), value));
    final businessId = map['business_id']?.toString().trim() ?? '';
    final sectionId = map['section_id']?.toString().trim() ?? '';
    final rawCachedAt = map['cached_at'];
    final cachedAt = rawCachedAt is num
        ? DateTime.fromMillisecondsSinceEpoch(rawCachedAt.toInt(), isUtc: true)
        : DateTime.tryParse(rawCachedAt?.toString() ?? '');
    if (businessId.isEmpty || sectionId.isEmpty || cachedAt == null) {
      return null;
    }
    final index = map['section_index'];
    return SaltCachedChapter(
      businessId: businessId,
      sectionId: sectionId,
      title: map['title']?.toString() ?? '',
      sectionIndex: index is int
          ? index
          : int.tryParse(index?.toString() ?? ''),
      responseJson: map['response_json'],
      xhtml: map['xhtml']?.toString() ?? '',
      cachedAt: cachedAt.toLocal(),
    );
  }
}

class SaltChapterCache {
  SaltChapterCache._();

  static final instance = SaltChapterCache._();

  static const _fallbackPrefix = 'zhiyue.salt.chapter.v1.';
  static const _maxCachedChaptersPerBusiness = 800;
  static const _maxImportedEntryBytes = 8 * 1024 * 1024;

  final _platformCache = ZhPlatformCache.instance;
  Database? _database;
  Future<Database>? _opening;
  bool _sqliteDisabled = false;

  bool get _useSqlite => zhUsesSqliteCache && !_sqliteDisabled;

  Future<SaltCachedChapter?> read({
    required String businessId,
    required String sectionId,
  }) async {
    if (!_useSqlite) {
      return _readFallback(businessId: businessId, sectionId: sectionId);
    }
    try {
      final database = await _open();
      final rows = await database.query(
        'salt_chapters',
        where: 'business_id = ? AND section_id = ?',
        whereArgs: [businessId, sectionId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _fromRow(rows.single);
    } on Object {
      _sqliteDisabled = true;
      return _readFallback(businessId: businessId, sectionId: sectionId);
    }
  }

  Future<Set<String>> cachedSectionIds(String businessId) async {
    if (!_useSqlite) {
      final prefix = _fallbackBusinessPrefix(businessId);
      final keys = await _platformCache.keys();
      return keys
          .where((key) => key.startsWith(prefix))
          .map((key) => Uri.decodeComponent(key.substring(prefix.length)))
          .where((id) => id.isNotEmpty)
          .toSet();
    }
    try {
      final database = await _open();
      final rows = await database.query(
        'salt_chapters',
        columns: const ['section_id'],
        where: 'business_id = ?',
        whereArgs: [businessId],
      );
      return rows
          .map((row) => row['section_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    } on Object {
      _sqliteDisabled = true;
      final prefix = _fallbackBusinessPrefix(businessId);
      final keys = await _platformCache.keys();
      return keys
          .where((key) => key.startsWith(prefix))
          .map((key) => Uri.decodeComponent(key.substring(prefix.length)))
          .where((id) => id.isNotEmpty)
          .toSet();
    }
  }

  /// Exports cached chapters, including rows that are no longer in the
  /// in-memory reader state. Only offline chapter content is included.
  Future<List<SaltCachedChapter>> exportEntries({String? businessId}) async {
    final normalizedBusinessId = businessId?.trim();
    if (_useSqlite) {
      try {
        final database = await _open();
        final rows = await database.query(
          'salt_chapters',
          where: normalizedBusinessId == null || normalizedBusinessId.isEmpty
              ? null
              : 'business_id = ?',
          whereArgs:
              normalizedBusinessId == null || normalizedBusinessId.isEmpty
              ? null
              : [normalizedBusinessId],
          orderBy: 'cached_at DESC',
          limit: normalizedBusinessId == null || normalizedBusinessId.isEmpty
              ? null
              : _maxCachedChaptersPerBusiness,
        );
        return rows.map(_fromRow).toList(growable: false);
      } on Object {
        _sqliteDisabled = true;
      }
    }
    final keys = await _platformCache.keys();
    final prefix = normalizedBusinessId == null || normalizedBusinessId.isEmpty
        ? _fallbackPrefix
        : _fallbackBusinessPrefix(normalizedBusinessId);
    final entries = <SaltCachedChapter>[];
    for (final key in keys.where((item) => item.startsWith(prefix))) {
      final raw = await _platformCache.read(key);
      if (raw == null || raw.isEmpty) continue;
      try {
        final entry = SaltCachedChapter.fromJson(jsonDecode(raw));
        if (entry != null) entries.add(entry);
      } on Object {
        // Skip one malformed optional offline row.
      }
    }
    entries.sort((left, right) => right.cachedAt.compareTo(left.cachedAt));
    final maximum = normalizedBusinessId == null || normalizedBusinessId.isEmpty
        ? 4000
        : _maxCachedChaptersPerBusiness;
    return entries.take(maximum).toList(growable: false);
  }

  Future<SaltCachedChapter> write({
    required String businessId,
    required String sectionId,
    required String title,
    required int? sectionIndex,
    required Object? responseJson,
    required String xhtml,
  }) async {
    final now = DateTime.now().toUtc();
    final cached = SaltCachedChapter(
      businessId: businessId,
      sectionId: sectionId,
      title: title,
      sectionIndex: sectionIndex,
      responseJson: responseJson,
      xhtml: xhtml,
      cachedAt: now,
    );
    await _writeEntry(cached);
    return cached;
  }

  /// Imports chapters from a remote snapshot while preserving their original
  /// chapter timestamps and ordering metadata.
  Future<int> importEntries(Iterable<SaltCachedChapter> entries) async {
    var imported = 0;
    for (final entry in entries) {
      if (entry.businessId.trim().isEmpty ||
          entry.sectionId.trim().isEmpty ||
          entry.xhtml.isEmpty) {
        continue;
      }
      try {
        if (utf8.encode(jsonEncode(entry.toJson())).length >
            _maxImportedEntryBytes) {
          continue;
        }
        await _writeEntry(entry);
        imported += 1;
      } on Object {
        // One corrupt or unsupported chapter must not block other chapters.
      }
    }
    return imported;
  }

  Future<void> _writeEntry(SaltCachedChapter cached) async {
    if (!_useSqlite) {
      await _writeFallback(cached);
      return;
    }
    try {
      final database = await _open();
      await database.insert('salt_chapters', {
        'business_id': cached.businessId,
        'section_id': cached.sectionId,
        'title': cached.title,
        'section_index': cached.sectionIndex,
        'response_json': jsonEncode(cached.responseJson),
        'xhtml': cached.xhtml,
        'cached_at': cached.cachedAt.toUtc().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      // Cleanup is deliberately fire-and-forget.  A chapter read/write must
      // return as soon as its row is durable; pruning old offline chapters is
      // maintenance work and must not add latency to opening a chapter.
      unawaited(_pruneBusiness(database, cached.businessId));
    } on Object {
      _sqliteDisabled = true;
      await _writeFallback(cached);
    }
  }

  Future<int> clear() async {
    if (!_useSqlite) {
      return _platformCache.removePrefix(_fallbackPrefix);
    }
    try {
      final database = await _open();
      return database.delete('salt_chapters');
    } on Object {
      _sqliteDisabled = true;
      return _platformCache.removePrefix(_fallbackPrefix);
    }
  }

  Future<Database> _open() async {
    final existing = _database;
    if (existing != null) return existing;
    final pending = _opening;
    if (pending != null) return pending;
    final opening = _openDatabase();
    _opening = opening;
    try {
      final database = await opening;
      _database = database;
      return database;
    } finally {
      _opening = null;
    }
  }

  Future<Database> _openDatabase() async {
    final root = await getDatabasesPath();
    final path = '$root/salt_chapter_cache.db';
    return openDatabase(
      path,
      version: 2,
      onCreate: (database, _) async {
        await database.execute(
          'CREATE TABLE salt_chapters ('
          'business_id TEXT NOT NULL, '
          'section_id TEXT NOT NULL, '
          'title TEXT NOT NULL, '
          'section_index INTEGER, '
          'response_json TEXT NOT NULL, '
          'xhtml TEXT NOT NULL, '
          'cached_at INTEGER NOT NULL, '
          'PRIMARY KEY (business_id, section_id)'
          ')',
        );
        await _createChapterIndexes(database);
      },
      onUpgrade: (database, oldVersion, _) async {
        if (oldVersion < 2) await _createChapterIndexes(database);
      },
    );
  }

  Future<void> _pruneBusiness(Database database, String businessId) async {
    try {
      final count = Sqflite.firstIntValue(
        await database.rawQuery(
          'SELECT COUNT(*) FROM salt_chapters WHERE business_id = ?',
          [businessId],
        ),
      );
      if (count == null || count <= _maxCachedChaptersPerBusiness) return;
      final excess = count - _maxCachedChaptersPerBusiness;
      await database.rawDelete(
        'DELETE FROM salt_chapters '
        'WHERE business_id = ? AND section_id IN ('
        'SELECT section_id FROM salt_chapters '
        'WHERE business_id = ? '
        'ORDER BY cached_at ASC, section_index ASC LIMIT ?'
        ')',
        [businessId, businessId, excess],
      );
    } on Object {
      // Cache maintenance is best effort.  A failure must never invalidate a
      // readable chapter or disable the SQLite store.
    }
  }

  SaltCachedChapter _fromRow(Map<String, Object?> row) {
    final rawJson = row['response_json']?.toString() ?? '{}';
    return SaltCachedChapter(
      businessId: row['business_id']?.toString() ?? '',
      sectionId: row['section_id']?.toString() ?? '',
      title: row['title']?.toString() ?? '',
      sectionIndex: row['section_index'] as int?,
      responseJson: jsonDecode(rawJson),
      xhtml: row['xhtml']?.toString() ?? '',
      cachedAt: DateTime.fromMillisecondsSinceEpoch(
        row['cached_at'] as int? ?? 0,
        isUtc: true,
      ),
    );
  }

  String _fallbackBusinessPrefix(String businessId) =>
      '$_fallbackPrefix${Uri.encodeComponent(businessId.trim())}.';

  String _fallbackKey({
    required String businessId,
    required String sectionId,
  }) =>
      '${_fallbackBusinessPrefix(businessId)}${Uri.encodeComponent(sectionId.trim())}';

  Future<SaltCachedChapter?> _readFallback({
    required String businessId,
    required String sectionId,
  }) async {
    final encoded = await _platformCache.read(
      _fallbackKey(businessId: businessId, sectionId: sectionId),
    );
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final value = jsonDecode(encoded);
      if (value is! Map) return null;
      final responseJson = value['response_json'];
      final cachedAt = int.tryParse(value['cached_at']?.toString() ?? '');
      if (cachedAt == null || cachedAt <= 0) return null;
      return SaltCachedChapter(
        businessId: value['business_id']?.toString() ?? businessId,
        sectionId: value['section_id']?.toString() ?? sectionId,
        title: value['title']?.toString() ?? '',
        sectionIndex: value['section_index'] is num
            ? (value['section_index'] as num).round()
            : int.tryParse(value['section_index']?.toString() ?? ''),
        responseJson: responseJson,
        xhtml: value['xhtml']?.toString() ?? '',
        cachedAt: DateTime.fromMillisecondsSinceEpoch(cachedAt, isUtc: true),
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> _writeFallback(SaltCachedChapter chapter) async {
    try {
      await _platformCache.write(
        _fallbackKey(
          businessId: chapter.businessId,
          sectionId: chapter.sectionId,
        ),
        jsonEncode({
          'business_id': chapter.businessId,
          'section_id': chapter.sectionId,
          'title': chapter.title,
          'section_index': chapter.sectionIndex,
          'response_json': chapter.responseJson,
          'xhtml': chapter.xhtml,
          'cached_at': chapter.cachedAt.millisecondsSinceEpoch,
        }),
      );
    } catch (_) {
      // Browser storage quotas are finite; the in-memory layer still serves
      // the current run and the reader can always refetch from the network.
    }
  }
}

Future<void> _createChapterIndexes(DatabaseExecutor database) async {
  await database.execute(
    'CREATE INDEX IF NOT EXISTS salt_chapters_business_order_idx '
    'ON salt_chapters (business_id, section_index, section_id)',
  );
  await database.execute(
    'CREATE INDEX IF NOT EXISTS salt_chapters_cached_at_idx '
    'ON salt_chapters (cached_at DESC)',
  );
}
