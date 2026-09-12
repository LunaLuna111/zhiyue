import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'platform_cache.dart';

class SaltBookshelfEntry {
  const SaltBookshelfEntry({
    required this.businessId,
    required this.propertyType,
    required this.title,
    required this.artwork,
    required this.sectionId,
    required this.rawJson,
    required this.addedAt,
  });

  final String businessId;
  final String propertyType;
  final String title;
  final String artwork;
  final String sectionId;
  final Map<String, dynamic> rawJson;
  final DateTime addedAt;

  String get displayTitle =>
      isSaltBookshelfPlaceholderTitle(title) ? '盐选作品' : title.trim();

  Map<String, dynamic> get cardJson => <String, dynamic>{
    ...rawJson,
    'business_id': businessId,
    'property_type': propertyType,
    'title': displayTitle,
    if (artwork.isNotEmpty) 'artwork': artwork,
    if (sectionId.isNotEmpty) 'section_id': sectionId,
  };

  Map<String, Object?> toRow() => <String, Object?>{
    'business_id': businessId,
    'property_type': propertyType,
    'title': title,
    'artwork': artwork,
    'section_id': sectionId,
    'raw_json': jsonEncode(rawJson),
    'added_at': addedAt.toUtc().toIso8601String(),
  };

  factory SaltBookshelfEntry.fromRow(Map<String, Object?> row) {
    Map<String, dynamic> rawJson = const <String, dynamic>{};
    try {
      final decoded = jsonDecode(row['raw_json']?.toString() ?? '');
      if (decoded is Map) {
        rawJson = decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      // Corrupt optional card metadata must not hide the local shelf entry.
    }
    return SaltBookshelfEntry(
      businessId: row['business_id']?.toString() ?? '',
      propertyType: row['property_type']?.toString() ?? 'paid_column',
      title: row['title']?.toString() ?? '',
      artwork: row['artwork']?.toString() ?? '',
      sectionId: row['section_id']?.toString() ?? '',
      rawJson: rawJson,
      addedAt:
          DateTime.tryParse(row['added_at']?.toString() ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

bool isSaltBookshelfPlaceholderTitle(String value) {
  final normalized = value.trim();
  return normalized.isEmpty || normalized == '作品目录' || normalized == '盐选作品';
}

class SaltBookshelfStore extends ChangeNotifier {
  SaltBookshelfStore._();

  static final SaltBookshelfStore instance = SaltBookshelfStore._();

  static const _fallbackKey = 'zhiyue.salt.bookshelf.v1';

  final _platformCache = ZhPlatformCache.instance;
  Database? _database;
  Future<Database>? _opening;
  Future<void>? _loadFuture;
  List<SaltBookshelfEntry> _entries = const <SaltBookshelfEntry>[];
  Set<String> _hiddenIds = <String>{};
  bool _sqliteDisabled = false;

  bool get _useSqlite => zhUsesSqliteCache && !_sqliteDisabled;

  List<SaltBookshelfEntry> get entries => _entries;

  bool contains(String businessId) =>
      _entries.any((entry) => entry.businessId == businessId.trim());

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
    final databasesPath = await getDatabasesPath();
    return openDatabase(
      '$databasesPath/salt_bookshelf.db',
      version: 3,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE salt_bookshelf (
            business_id TEXT PRIMARY KEY,
            property_type TEXT NOT NULL,
            title TEXT NOT NULL,
            artwork TEXT NOT NULL,
            section_id TEXT NOT NULL,
            raw_json TEXT NOT NULL,
            added_at TEXT NOT NULL
          )
        ''');
        await _createHiddenTable(db);
        await _createBookshelfIndexes(db);
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) await _createHiddenTable(db);
        if (oldVersion < 3) await _createBookshelfIndexes(db);
      },
    );
  }

  Future<void> load({bool force = false}) {
    final existing = _loadFuture;
    if (!force && existing != null) return existing;
    final future = _readAll();
    _loadFuture = future;
    return future;
  }

  Future<void> _readAll() async {
    if (!_useSqlite) {
      await _readFallback();
      return;
    }
    try {
      final db = await _open();
      final rows = await db.query('salt_bookshelf', orderBy: 'added_at DESC');
      _entries = rows
          .map(SaltBookshelfEntry.fromRow)
          .where((entry) => RegExp(r'^\d+$').hasMatch(entry.businessId))
          .toList(growable: false);
      notifyListeners();
    } on Object {
      _sqliteDisabled = true;
      await _readFallback();
    }
  }

  Future<void> add(SaltBookshelfEntry entry) async {
    if (!RegExp(r'^\d+$').hasMatch(entry.businessId)) {
      throw const FormatException('盐选作品 ID 必须是数字');
    }
    if (!RegExp(r'^[a-z][a-z0-9_]{0,39}$').hasMatch(entry.propertyType)) {
      throw const FormatException('盐选作品类型无效');
    }
    if (!_useSqlite) {
      await _addFallback(entry);
      return;
    }
    try {
      final db = await _open();
      await db.transaction((txn) async {
        await txn.delete(
          'salt_bookshelf_hidden',
          where: 'business_id = ?',
          whereArgs: <Object>[entry.businessId],
        );
        await txn.insert(
          'salt_bookshelf',
          entry.toRow(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    } on Object {
      _sqliteDisabled = true;
      await _addFallback(entry);
      return;
    }
    _entries = <SaltBookshelfEntry>[
      entry,
      ..._entries.where((item) => item.businessId != entry.businessId),
    ];
    notifyListeners();
  }

  Future<void> addAll(Iterable<SaltBookshelfEntry> entries) async {
    final normalized = entries
        .where((entry) => RegExp(r'^\d+$').hasMatch(entry.businessId))
        .toList(growable: false);
    if (normalized.isEmpty) return;
    if (!_useSqlite) {
      await _addAllFallback(normalized);
      return;
    }
    try {
      final db = await _open();
      await db.transaction((txn) async {
        final hiddenRows = await txn.query(
          'salt_bookshelf_hidden',
          columns: const ['business_id'],
        );
        final hidden = hiddenRows
            .map((row) => row['business_id']?.toString() ?? '')
            .toSet();
        final batch = txn.batch();
        for (final entry in normalized) {
          if (hidden.contains(entry.businessId)) continue;
          batch.insert(
            'salt_bookshelf',
            entry.toRow(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      });
    } on Object {
      _sqliteDisabled = true;
      await _addAllFallback(normalized);
      return;
    }
    await _readAll();
  }

  Future<void> remove(String businessId) async {
    final normalized = businessId.trim();
    if (!_useSqlite) {
      await _removeFallback(normalized);
      return;
    }
    try {
      final db = await _open();
      await db.transaction((txn) async {
        await txn.insert('salt_bookshelf_hidden', <String, Object?>{
          'business_id': normalized,
          'hidden_at': DateTime.now().toUtc().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        await txn.delete(
          'salt_bookshelf',
          where: 'business_id = ?',
          whereArgs: <Object>[normalized],
        );
      });
    } on Object {
      _sqliteDisabled = true;
      await _removeFallback(normalized);
      return;
    }
    _entries = _entries
        .where((entry) => entry.businessId != normalized)
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _readFallback() async {
    final encoded = await _platformCache.read(_fallbackKey);
    if (encoded == null || encoded.isEmpty) {
      _entries = const <SaltBookshelfEntry>[];
      _hiddenIds = <String>{};
      notifyListeners();
      return;
    }
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) throw const FormatException('书架缓存格式无效');
      final rows = decoded['entries'];
      _entries = rows is List
          ? rows
                .whereType<Map>()
                .map(
                  (row) => SaltBookshelfEntry.fromRow(
                    row.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .where((entry) => RegExp(r'^\d+$').hasMatch(entry.businessId))
                .toList(growable: false)
          : const <SaltBookshelfEntry>[];
      final hidden = decoded['hidden'];
      _hiddenIds = hidden is List
          ? hidden.whereType<String>().where((id) => id.isNotEmpty).toSet()
          : <String>{};
    } on FormatException {
      _entries = const <SaltBookshelfEntry>[];
      _hiddenIds = <String>{};
    }
    notifyListeners();
  }

  Future<void> _writeFallback() async {
    try {
      await _platformCache.write(
        _fallbackKey,
        jsonEncode({
          'entries': _entries.map((entry) => entry.toRow()).toList(),
          'hidden': _hiddenIds.toList(growable: false),
        }),
      );
    } catch (_) {
      // Persistence is best effort on browser/desktop fallback platforms.
    }
  }

  Future<void> _addFallback(SaltBookshelfEntry entry) async {
    _hiddenIds.remove(entry.businessId);
    _entries = <SaltBookshelfEntry>[
      entry,
      ..._entries.where((item) => item.businessId != entry.businessId),
    ];
    await _writeFallback();
    notifyListeners();
  }

  Future<void> _addAllFallback(List<SaltBookshelfEntry> normalized) async {
    final visible = normalized
        .where((entry) => !_hiddenIds.contains(entry.businessId))
        .toList(growable: false);
    if (visible.isEmpty) return;
    final byId = <String, SaltBookshelfEntry>{
      for (final entry in _entries) entry.businessId: entry,
    };
    for (final entry in visible) {
      byId[entry.businessId] = entry;
    }
    final sorted = byId.values.toList()
      ..sort((left, right) => right.addedAt.compareTo(left.addedAt));
    _entries = List<SaltBookshelfEntry>.unmodifiable(sorted);
    await _writeFallback();
    notifyListeners();
  }

  Future<void> _removeFallback(String businessId) async {
    _hiddenIds.add(businessId);
    _entries = _entries
        .where((entry) => entry.businessId != businessId)
        .toList(growable: false);
    await _writeFallback();
    notifyListeners();
  }
}

Future<void> _createHiddenTable(DatabaseExecutor db) => db.execute('''
  CREATE TABLE IF NOT EXISTS salt_bookshelf_hidden (
    business_id TEXT PRIMARY KEY,
    hidden_at TEXT NOT NULL
  )
''');

Future<void> _createBookshelfIndexes(DatabaseExecutor db) => db.execute(
  'CREATE INDEX IF NOT EXISTS salt_bookshelf_added_idx '
  'ON salt_bookshelf (added_at DESC)',
);
