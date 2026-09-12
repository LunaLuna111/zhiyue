import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'api_client.dart';
import 'api_response.dart';
import 'json_tools.dart';
import 'platform_cache.dart';

class SaltCatalogSnapshot {
  const SaltCatalogSnapshot({
    required this.businessId,
    required this.root,
    required this.fetchedAt,
  });

  final String businessId;
  final Map<String, dynamic> root;
  final DateTime fetchedAt;

  List<Map<String, dynamic>> get rows => saltCatalogRows(root);

  int? get total {
    final paging = _stringMap(saltCatalogResponseRoot(root)['paging']);
    return _catalogInt(paging?['total'] ?? paging?['totals']);
  }

  bool isFreshAt(DateTime now) =>
      now.toUtc().difference(fetchedAt.toUtc()) < SaltCatalogStore.cacheTtl;
}

class SaltCatalogWorkMetadata {
  const SaltCatalogWorkMetadata({
    required this.title,
    required this.artwork,
    required this.propertyType,
  });

  final String title;
  final String artwork;
  final String propertyType;
}

/// Normalizes catalog responses that arrive either as the official root
/// object or wrapped once more under `data` by the authenticated gateway.
/// This keeps author/header metadata available to both fresh and cached pages.
Map<String, dynamic> saltCatalogResponseRoot(Object? value) {
  var root = _stringMap(value) ?? const <String, dynamic>{};
  for (var depth = 0; depth < 4; depth++) {
    final nested = _stringMap(root['data']);
    if (nested == null) break;
    final isCatalogEnvelope =
        nested.containsKey('parent') ||
        nested.containsKey('author') ||
        nested.containsKey('paging') ||
        nested.containsKey('free_limit_list_url') ||
        nested.containsKey('section_list') ||
        nested.containsKey('sectionList') ||
        nested.containsKey('chapter_list') ||
        nested.containsKey('chapterList');
    if (!isCatalogEnvelope) break;
    root = <String, dynamic>{...root, ...nested};
  }
  return root;
}

/// Normalizes the lightweight `work/{work_id}/section_list` response to the
/// same catalog shape consumed by the reader and product page.  The native
/// client uses this endpoint as a fallback for works that have not yet been
/// indexed by `catalog/{well_id}`; keeping the normalization here prevents a
/// valid long-story card from ending in an empty/error directory screen.
@visibleForTesting
Map<String, dynamic> saltCatalogRootFromWorkSectionList(Object? value) {
  final source = saltCatalogResponseRoot(value);
  final rows = extractRows(source)
      .map((row) {
        final normalized = <String, dynamic>{...row};
        if (_catalogId(normalized).isEmpty) return null;
        return normalized;
      })
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
  for (var index = 0; index < rows.length; index++) {
    final row = rows[index];
    final current = _catalogInt(row['global_idx'] ?? row['idx']);
    if (current == null) row['global_idx'] = index;
  }
  final existingPaging = _stringMap(source['paging']);
  final paging = <String, dynamic>{
    ...?existingPaging,
    'is_first': true,
    'is_end': true,
    'offset': 0,
    'total': rows.length,
    'totals': rows.length,
    'next': '',
    'previous': '',
  };
  return <String, dynamic>{...source, 'data': rows, 'paging': paging};
}

SaltCatalogWorkMetadata saltCatalogWorkMetadata(Object? value) {
  final root = _stringMap(value);
  final parent = _catalogWorkMap(root) ?? const <String, dynamic>{};
  return SaltCatalogWorkMetadata(
    title: _catalogText(parent, const ['title', 'name']),
    artwork: _catalogArtwork(
      parent['artwork'] ?? parent['tab_artwork'] ?? parent['cover_url'],
    ),
    propertyType: plainText(
      parent['property_type'] ??
          parent['business_type'] ??
          parent['content_type'] ??
          parent['type'],
    ),
  );
}

@visibleForTesting
List<Map<String, dynamic>> saltCatalogRows(Object? value) {
  final rows = <Map<String, dynamic>>[];
  for (final row in extractRows(value)) {
    final id = _catalogId(row);
    if (id.isNotEmpty && id != '0') rows.add(row);
  }
  rows.sort((left, right) {
    final byIndex = _catalogIndex(left).compareTo(_catalogIndex(right));
    return byIndex == 0
        ? _catalogId(left).compareTo(_catalogId(right))
        : byIndex;
  });
  return rows;
}

/// Builds the remaining official catalog URLs without rebuilding their query
/// strings. The request signature covers the raw target, so only the numeric
/// `offset` value is replaced and the original parameter order is retained.
@visibleForTesting
List<Uri> saltCatalogRemainingPageUris(Object? firstResponse) {
  final root = _stringMap(firstResponse);
  final paging = _stringMap(root?['paging']);
  if (paging == null || paging['is_end'] == true) return const [];
  final total = _catalogInt(paging['total'] ?? paging['totals']);
  final nextText = plainText(paging['next']);
  final nextUri = Uri.tryParse(nextText);
  final limit =
      _catalogInt(paging['limit']) ??
      _catalogInt(nextUri?.queryParameters['limit']);
  final offsetPattern = RegExp(r'([?&]offset=)(\d+)');
  final match = offsetPattern.firstMatch(nextText);
  final nextOffset = match == null ? null : int.tryParse(match.group(2)!);
  if (total == null || total <= 0 || limit == null || limit <= 0) {
    return const [];
  }
  if (nextOffset == null || nextOffset <= 0 || nextOffset >= total) {
    return const [];
  }
  return [
    for (var offset = nextOffset; offset < total; offset += limit)
      Uri.parse(
        nextText.replaceFirstMapped(
          offsetPattern,
          (match) => '${match.group(1)}$offset',
        ),
      ),
  ];
}

class SaltCatalogStore {
  SaltCatalogStore._();

  static final instance = SaltCatalogStore._();
  static const cacheTtl = Duration(hours: 1);
  static const _maxPages = 100;
  static const _concurrentBatchSize = 8;
  static const _fallbackPrefix = 'zhiyue.salt.catalog.v1.';

  final _refreshes = <String, Future<SaltCatalogSnapshot>>{};
  final _platformCache = ZhPlatformCache.instance;
  Database? _database;
  Future<Database>? _opening;
  bool _sqliteDisabled = false;

  bool get _useSqlite => zhUsesSqliteCache && !_sqliteDisabled;

  Future<SaltCatalogSnapshot?> read(String businessId) async {
    if (!_useSqlite) return _readFallback(businessId);
    try {
      final database = await _open();
      final rows = await database.query(
        'salt_catalogs',
        where: 'business_id = ?',
        whereArgs: [businessId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      try {
        final decoded = jsonDecode(rows.single['response_json']!.toString());
        final root = saltCatalogResponseRoot(decoded);
        if (root.isEmpty) return null;
        return SaltCatalogSnapshot(
          businessId: businessId,
          root: root,
          fetchedAt: DateTime.fromMillisecondsSinceEpoch(
            rows.single['fetched_at'] as int? ?? 0,
            isUtc: true,
          ),
        );
      } on FormatException {
        return null;
      }
    } on Object {
      _sqliteDisabled = true;
      return _readFallback(businessId);
    }
  }

  /// Persists a metadata-enriched catalog without discarding the chapter
  /// rows already stored locally.  The product page uses this after the
  /// lightweight catalog request is followed by the official manuscript
  /// header request (the latter carries the author object).
  Future<SaltCatalogSnapshot> replaceRoot({
    required String businessId,
    required Map<String, dynamic> root,
  }) => _persistSnapshot(businessId: businessId, root: root);

  Future<SaltCatalogSnapshot> load({
    required ZhihuApiClient api,
    required String businessId,
    bool forceRefresh = false,
  }) async {
    SaltCatalogSnapshot? cached;
    try {
      cached = await read(businessId);
    } catch (_) {
      // A catalog request must remain usable in widget tests and on platforms
      // where sqflite has not initialized yet.
    }
    if (!forceRefresh &&
        cached != null &&
        cached.isFreshAt(DateTime.now().toUtc())) {
      return cached;
    }
    try {
      final refreshed = await _refreshes.putIfAbsent(
        businessId,
        () => _refresh(api: api, businessId: businessId),
      );
      // A transiently empty catalog must never erase a usable local directory
      // (this happens during server-side indexing and after an expired guest
      // session). Keep the complete cached snapshot until a real row set is
      // available again.
      if (cached != null && cached.rows.isNotEmpty && refreshed.rows.isEmpty) {
        return cached;
      }
      return refreshed;
    } catch (_) {
      if (cached != null) return cached;
      rethrow;
    } finally {
      _refreshes.remove(businessId);
    }
  }

  Future<int> clear() async {
    if (!_useSqlite) {
      return _platformCache.removePrefix(_fallbackPrefix);
    }
    try {
      final database = await _open();
      return database.delete('salt_catalogs');
    } on Object {
      _sqliteDisabled = true;
      return _platformCache.removePrefix(_fallbackPrefix);
    }
  }

  Future<void> markLastRead({
    required String businessId,
    required String sectionId,
  }) async {
    try {
      final snapshot = await read(businessId);
      if (snapshot == null) return;
      var found = false;
      final rows = snapshot.rows
          .map((row) {
            final updated = Map<String, dynamic>.from(row);
            final selected = _catalogId(row) == sectionId;
            if (selected) found = true;
            updated['last_read'] = selected;
            return updated;
          })
          .toList(growable: false);
      if (!found) return;
      final root = Map<String, dynamic>.from(snapshot.root)..['data'] = rows;
      if (!_useSqlite) {
        await _writeFallback(
          SaltCatalogSnapshot(
            businessId: businessId,
            root: root,
            fetchedAt: snapshot.fetchedAt,
          ),
        );
        return;
      }
      final database = await _open();
      await database.insert('salt_catalogs', {
        'business_id': businessId,
        'response_json': jsonEncode(root),
        'fetched_at': snapshot.fetchedAt.millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      if (zhUsesSqliteCache) _sqliteDisabled = true;
      // Reading must not fail only because local progress persistence failed.
    }
  }

  Future<SaltCatalogSnapshot> _refresh({
    required ZhihuApiClient api,
    required String businessId,
  }) async {
    ApiResponse? first;
    Object? firstError;
    try {
      first = await api.getSaltUri(
        api.saltCatalogInitialUri(wellId: businessId),
      );
    } catch (error) {
      firstError = error;
    }

    // Some native discovery cards point at a work that is readable through
    // `section_list` but has no `/catalog` index yet.  Try the official
    // fallback before surfacing the generic “目录载入失败” screen.
    if (first == null ||
        !first.isSuccess ||
        saltCatalogRows(first.json).isEmpty) {
      try {
        final fallback = await api.getSaltUri(
          api.saltWorkSectionListUri(businessId),
        );
        if (fallback.isSuccess && saltCatalogRows(fallback.json).isNotEmpty) {
          return _persistSnapshot(
            businessId: businessId,
            root: saltCatalogRootFromWorkSectionList(fallback.json),
          );
        }
        if (first == null || !first.isSuccess) {
          if (firstError != null) throw firstError;
          throw fallback;
        }
      } catch (_) {
        if (first == null || !first.isSuccess) {
          if (firstError != null) throw firstError;
          rethrow;
        }
        // A successful but empty catalog is still a valid server response;
        // retain the original behavior when the optional fallback is absent.
      }
    }

    final usableFirst = first;
    if (!usableFirst.isSuccess) throw usableFirst;
    final responses = <ApiResponse>[usableFirst];
    final remaining = saltCatalogRemainingPageUris(usableFirst.json);
    if (remaining.isNotEmpty) {
      for (
        var start = 0;
        start < remaining.length && start < _maxPages - 1;
        start += _concurrentBatchSize
      ) {
        final end = (start + _concurrentBatchSize).clamp(0, remaining.length);
        final batch = await Future.wait(
          remaining
              .sublist(start, end)
              .map((uri) => api.getSaltUri(api.validatePagingUri('$uri'))),
        );
        for (final response in batch) {
          if (!response.isSuccess) throw response;
        }
        responses.addAll(batch);
      }
    } else {
      await _loadSequentialPages(api, responses);
    }
    return _persistSnapshot(
      businessId: businessId,
      root: _mergeResponses(responses),
    );
  }

  Future<SaltCatalogSnapshot> _persistSnapshot({
    required String businessId,
    required Map<String, dynamic> root,
  }) async {
    final fetchedAt = DateTime.now().toUtc();
    final snapshot = SaltCatalogSnapshot(
      businessId: businessId,
      root: saltCatalogResponseRoot(root),
      fetchedAt: fetchedAt,
    );
    if (!_useSqlite) {
      await _writeFallback(snapshot);
      return snapshot;
    }
    try {
      final database = await _open();
      await database.insert('salt_catalogs', {
        'business_id': businessId,
        'response_json': jsonEncode(snapshot.root),
        'fetched_at': fetchedAt.millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      _sqliteDisabled = true;
      await _writeFallback(snapshot);
      // Network data remains readable even if persistence is unavailable.
    }
    return snapshot;
  }

  Future<void> _loadSequentialPages(
    ZhihuApiClient api,
    List<ApiResponse> responses,
  ) async {
    final visited = <String>{responses.first.uri.toString()};
    var next = pagingNext(responses.first.json);
    while (next != null && responses.length < _maxPages && visited.add(next)) {
      final response = await api.getSaltUri(api.validatePagingUri(next));
      if (!response.isSuccess) throw response;
      responses.add(response);
      next = pagingNext(response.json);
    }
  }

  Map<String, dynamic> _mergeResponses(List<ApiResponse> responses) {
    final normalizedRoots = responses
        .map(
          (response) => saltCatalogResponseRoot(
            response.jsonMap ?? const <String, dynamic>{},
          ),
        )
        .toList(growable: false);
    final root = Map<String, dynamic>.from(normalizedRoots.first);
    for (final supplement in normalizedRoots.skip(1)) {
      _mergeCatalogHeader(root, supplement);
    }
    final rowsById = <String, Map<String, dynamic>>{};
    var serverTotal = 0;
    for (final response in responses) {
      final paging = _stringMap(
        saltCatalogResponseRoot(response.jsonMap)['paging'],
      );
      final total = _catalogInt(paging?['total'] ?? paging?['totals']);
      if (total != null && total > serverTotal) serverTotal = total;
      for (final row in saltCatalogRows(response.json)) {
        rowsById[_catalogId(row)] = row;
      }
    }
    final rows = saltCatalogRows({'data': rowsById.values.toList()});
    final paging =
        Map<String, dynamic>.from(
            _stringMap(root['paging']) ?? const <String, dynamic>{},
          )
          ..['is_first'] = true
          ..['is_end'] = true
          ..['offset'] = 0
          ..['next'] = ''
          ..['previous'] = ''
          ..['total'] = serverTotal > 0 ? serverTotal : rows.length
          ..['totals'] = serverTotal > 0 ? serverTotal : rows.length;
    root
      ..['data'] = rows
      ..['paging'] = paging;
    return root;
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
    final path = '$root/salt_catalog_cache.db';
    return openDatabase(
      path,
      version: 2,
      onCreate: (database, _) async {
        await database.execute(
          'CREATE TABLE salt_catalogs ('
          'business_id TEXT PRIMARY KEY, '
          'response_json TEXT NOT NULL, '
          'fetched_at INTEGER NOT NULL'
          ')',
        );
        await _createCatalogIndexes(database);
      },
      onUpgrade: (database, oldVersion, _) async {
        if (oldVersion < 2) await _createCatalogIndexes(database);
      },
    );
  }

  String _fallbackKey(String businessId) =>
      '$_fallbackPrefix${Uri.encodeComponent(businessId.trim())}';

  Future<SaltCatalogSnapshot?> _readFallback(String businessId) async {
    final encoded = await _platformCache.read(_fallbackKey(businessId));
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final value = jsonDecode(encoded);
      if (value is! Map) return null;
      final root = _stringMap(value['root']);
      final fetchedAt = _catalogInt(value['fetched_at']);
      if (root == null || fetchedAt == null || fetchedAt <= 0) return null;
      return SaltCatalogSnapshot(
        businessId: businessId,
        root: root,
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(fetchedAt, isUtc: true),
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> _writeFallback(SaltCatalogSnapshot snapshot) async {
    try {
      await _platformCache.write(
        _fallbackKey(snapshot.businessId),
        jsonEncode({
          'root': snapshot.root,
          'fetched_at': snapshot.fetchedAt.millisecondsSinceEpoch,
        }),
      );
    } catch (_) {
      // A browser quota or unavailable desktop plugin must not hide network
      // catalog data from the reader.
    }
  }
}

Future<void> _createCatalogIndexes(DatabaseExecutor database) async {
  // Catalog reads are keyed by business_id.  Keep a timestamp index for
  // inexpensive future expiry/cleanup without changing the hot primary-key
  // lookup path.
  await database.execute(
    'CREATE INDEX IF NOT EXISTS salt_catalogs_fetched_idx '
    'ON salt_catalogs (fetched_at DESC)',
  );
}

bool _catalogValueMissing(Object? value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  if (value is Map) return value.isEmpty;
  if (value is List) return value.isEmpty;
  return false;
}

Map<String, dynamic> _mergeCatalogMaps(
  Map<String, dynamic> base,
  Map<String, dynamic> supplement,
) {
  final merged = <String, dynamic>{...base};
  for (final entry in supplement.entries) {
    final existing = merged[entry.key];
    final incomingMap = _stringMap(entry.value);
    final existingMap = _stringMap(existing);
    if (incomingMap != null && existingMap != null) {
      merged[entry.key] = _mergeCatalogMaps(existingMap, incomingMap);
    } else if (_catalogValueMissing(existing) &&
        !_catalogValueMissing(entry.value)) {
      merged[entry.key] = entry.value;
    }
  }
  return merged;
}

void _mergeCatalogHeader(
  Map<String, dynamic> target,
  Map<String, dynamic> supplement,
) {
  for (final key in const [
    'parent',
    'author',
    'author_info',
    'xxxxx_author_info',
    'extra',
    'free_limit_list_url',
  ]) {
    final incoming = supplement[key];
    if (_catalogValueMissing(incoming)) continue;
    final existing = target[key];
    final incomingMap = _stringMap(incoming);
    final existingMap = _stringMap(existing);
    if (incomingMap != null) {
      target[key] = _mergeCatalogMaps(existingMap ?? const {}, incomingMap);
    } else if (_catalogValueMissing(existing)) {
      target[key] = incoming;
    }
  }
}

bool _catalogHasWorkValue(Map<String, dynamic> value) => const [
  'title',
  'name',
  'artwork',
  'tab_artwork',
  'cover_url',
  'property_type',
  'business_type',
  'content_type',
].any((key) => !_catalogValueMissing(value[key]));

Map<String, dynamic>? _catalogWorkMap(
  Map<String, dynamic>? root, [
  int depth = 0,
]) {
  if (root == null || depth > 4) return null;
  final parent = _stringMap(root['parent']);
  if (parent != null && _catalogHasWorkValue(parent)) return parent;
  if (_catalogHasWorkValue(root)) return root;
  for (final key in const ['work', 'product', 'details', 'metadata', 'data']) {
    final nested = _catalogWorkMap(_stringMap(root[key]), depth + 1);
    if (nested != null) return nested;
  }
  return parent;
}

String _catalogText(Map<String, dynamic>? value, List<String> keys) {
  if (value == null) return '';
  String read(Object? raw) {
    if (raw is List) {
      return raw.map(read).where((item) => item.isNotEmpty).join('\n');
    }
    final map = _stringMap(raw);
    if (map != null) {
      for (final key in const [
        'plain_text',
        'text',
        'content',
        'value',
        'name',
        'title',
        'url',
      ]) {
        final text = read(map[key]);
        if (text.isNotEmpty) return text;
      }
      return '';
    }
    return plainText(raw);
  }

  for (final key in keys) {
    final text = read(value[key]);
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _catalogArtwork(Object? value) {
  if (value is List) {
    for (final item in value) {
      final url = _catalogArtwork(item);
      if (url.isNotEmpty) return url;
    }
    return '';
  }
  final map = _stringMap(value);
  if (map != null) {
    for (final key in const [
      'url',
      'src',
      'image_url',
      'cover_url',
      'original_url',
      'large',
      'medium',
      'small',
      'data',
    ]) {
      final url = _catalogArtwork(map[key]);
      if (url.isNotEmpty) return url;
    }
    return '';
  }
  final text = plainText(value);
  return Uri.tryParse(text)?.scheme == 'https' ? text : '';
}

Map<String, dynamic>? _stringMap(Object? value) {
  if (value is! Map) return null;
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String _catalogId(Map<String, dynamic> value) {
  final object = unwrapObject(value);
  return plainText(
    object['section_id'] ??
        object['sectionId'] ??
        object['chapter_id'] ??
        object['chapterId'] ??
        object['id'],
  );
}

int _catalogIndex(Map<String, dynamic> value) {
  final object = unwrapObject(value);
  final index = _stringMap(object['index']);
  return _catalogInt(
        object['global_idx'] ??
            object['idx'] ??
            object['globalIndex'] ??
            index?['value'] ??
            index?['index'] ??
            object['index'],
      ) ??
      (1 << 30);
}

int? _catalogInt(Object? value) {
  if (value is num) return value.round();
  return int.tryParse(plainText(value).replaceAll(',', ''));
}
