import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'answer_detail_cache.dart';
import 'app_log.dart';
import 'salt_bookshelf_store.dart';
import 'salt_chapter_cache.dart';
import 'session_store.dart';
import 'webdav_client.dart';
import 'webdav_models.dart';
import 'webdav_settings_store.dart';

typedef WebDavClientFactory = WebDavClient Function(WebDavSettings settings);

/// Synchronizes user-selected, non-credential content through a WebDAV
/// server. The server sees search/history data and cached public content, but
/// never sees the Zhihu session, device identifiers, or WebDAV settings.
class WebDavSyncService extends ChangeNotifier {
  WebDavSyncService({
    required this.session,
    WebDavSettingsStore? settingsStore,
    SaltChapterCache? chapterCache,
    SaltBookshelfStore? bookshelf,
    AnswerDetailCache? answerCache,
    WebDavClientFactory? clientFactory,
  }) : _settingsStore = settingsStore ?? WebDavSettingsStore.instance,
       _chapterCache = chapterCache ?? SaltChapterCache.instance,
       _bookshelf = bookshelf ?? SaltBookshelfStore.instance,
       _answerCache = answerCache ?? AnswerDetailCache.instance,
       _clientFactory =
           clientFactory ?? ((settings) => WebDavClient(settings: settings));

  final SessionStore session;
  final WebDavSettingsStore _settingsStore;
  final SaltChapterCache _chapterCache;
  final SaltBookshelfStore _bookshelf;
  final AnswerDetailCache _answerCache;
  final WebDavClientFactory _clientFactory;

  WebDavSettings? _settings;
  Future<WebDavSettings>? _loadingSettings;
  Future<WebDavSyncResult>? _syncing;
  WebDavSyncStatus _status = const WebDavSyncStatus.initial();
  bool _disposed = false;

  WebDavSettings? get settings => _settings;
  WebDavSyncStatus get status => _status;
  bool get isConfigured => _settings?.isConfigured == true;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<WebDavSettings> loadSettings() {
    final current = _settings;
    if (current != null) return Future<WebDavSettings>.value(current);
    final pending = _loadingSettings;
    if (pending != null) return pending;
    _setStatus(
      const WebDavSyncStatus(
        phase: WebDavSyncPhase.loading,
        message: '正在读取 WebDAV 设置',
        lastSyncedAt: null,
        uploaded: 0,
        downloaded: 0,
      ),
    );
    final future = _settingsStore.load();
    _loadingSettings = future;
    return future
        .then((value) {
          _settings = value;
          if (_status.phase == WebDavSyncPhase.loading) {
            _setStatus(
              WebDavSyncStatus(
                phase: WebDavSyncPhase.idle,
                message: value.isConfigured ? 'WebDAV 已配置' : '尚未配置 WebDAV',
                lastSyncedAt: _status.lastSyncedAt,
                uploaded: 0,
                downloaded: 0,
              ),
            );
          }
          return value;
        })
        .whenComplete(() {
          if (identical(_loadingSettings, future)) _loadingSettings = null;
        });
  }

  Future<void> saveSettings(WebDavSettings value) async {
    final error = value.validate();
    if (error != null) throw FormatException(error);
    await _settingsStore.save(value);
    _settings = value;
    _setStatus(
      WebDavSyncStatus(
        phase: WebDavSyncPhase.idle,
        message: value.isConfigured ? 'WebDAV 设置已保存' : 'WebDAV 已关闭',
        lastSyncedAt: _status.lastSyncedAt,
        uploaded: 0,
        downloaded: 0,
      ),
    );
  }

  Future<void> clearSettings() async {
    await _settingsStore.clear();
    _settings = const WebDavSettings.disabled();
    _setStatus(const WebDavSyncStatus.initial());
  }

  Future<void> syncOnStartup() async {
    final value = await loadSettings();
    if (!value.isConfigured || !value.syncOnStartup) return;
    try {
      await sync();
    } on Object {
      // Startup sync is best effort. The settings page exposes the error and
      // a manual retry without delaying the first content frame.
    }
  }

  Future<WebDavSyncResult> testConnection() async {
    final value = await loadSettings();
    final validationError = _configurationError(value);
    if (validationError != null) {
      final error = FormatException(validationError);
      _setFailure(error, 'WebDAV 配置无效');
      throw error;
    }
    _setStatus(
      WebDavSyncStatus(
        phase: WebDavSyncPhase.testing,
        message: '正在测试 WebDAV 连接',
        lastSyncedAt: _status.lastSyncedAt,
        uploaded: 0,
        downloaded: 0,
      ),
    );
    final client = _clientFactory(value);
    try {
      await client.testConnection();
      const result = WebDavSyncResult(
        uploaded: 0,
        downloaded: 0,
        skipped: 0,
        message: 'WebDAV 连接成功',
      );
      _setStatus(
        WebDavSyncStatus(
          phase: WebDavSyncPhase.success,
          message: result.message,
          lastSyncedAt: _status.lastSyncedAt,
          uploaded: 0,
          downloaded: 0,
        ),
      );
      return result;
    } catch (error) {
      _setFailure(error, 'WebDAV 连接失败');
      rethrow;
    } finally {
      await client.close();
    }
  }

  Future<WebDavSyncResult> sync() {
    final pending = _syncing;
    if (pending != null) return pending;
    final future = _syncOnce();
    _syncing = future;
    return future.whenComplete(() {
      if (identical(_syncing, future)) _syncing = null;
    });
  }

  Future<WebDavSyncResult> _syncOnce() async {
    final value = await loadSettings();
    final validationError = _configurationError(value);
    if (validationError != null) {
      final error = FormatException(validationError);
      _setFailure(error, 'WebDAV 配置无效');
      throw error;
    }
    _setStatus(
      WebDavSyncStatus(
        phase: WebDavSyncPhase.syncing,
        message: '正在同步搜索、历史、小说和回答缓存',
        lastSyncedAt: _status.lastSyncedAt,
        uploaded: 0,
        downloaded: 0,
      ),
    );
    final client = _clientFactory(value);
    try {
      await client.ensureDirectory('v1');
      await client.ensureDirectory('v1/answers');
      await client.ensureDirectory('v1/chapters');
      final remote = await _readRemote(client);
      final local = await _exportLocal();

      final mergedSearch = session.rememberSearchHistory
          ? _mergeSearch(local.searchHistory, remote.searchHistory)
          : remote.searchHistory;
      final mergedBrowsing = session.rememberBrowsingHistory
          ? _mergeBrowsing(local.browsingHistory, remote.browsingHistory)
          : remote.browsingHistory;
      final mergedBookshelf = _mergeBookshelf(
        local.bookshelf,
        remote.bookshelf,
      );
      final mergedAnswers = _mergeAnswers(local.answers, remote.answers);
      final mergedChapters = _mergeChapters(local.chapters, remote.chapters);

      if (session.rememberSearchHistory) {
        await session.mergeSearchHistory(remote.searchHistory);
      }
      if (session.rememberBrowsingHistory) {
        await session.mergeBrowsingHistory(remote.browsingHistory);
      }
      await _bookshelf.load();
      await _bookshelf.addAll(mergedBookshelf);

      final answersToImport = _newerRemoteAnswers(
        local.answers,
        remote.answers,
      );
      final chaptersToImport = _newerRemoteChapters(
        local.chapters,
        remote.chapters,
      );
      final downloaded = await _answerCache.importEntries(
        answersToImport,
        // Keep the original timestamp so the same remote row is not imported
        // on every sync. A manual detail refresh always bypasses this cache;
        // restored answers therefore never prevent a current API update.
        markStale: false,
      );
      final downloadedChapters = await _chapterCache.importEntries(
        chaptersToImport,
      );

      var uploaded = 0;
      await client.putJson('v1/search-history.json', {
        'schema_version': 1,
        'items': mergedSearch,
      });
      uploaded += 1;
      await client.putJson('v1/browsing-history.json', {
        'schema_version': 1,
        'items': mergedBrowsing.map((item) => item.toJson()).toList(),
      });
      uploaded += 1;
      await client.putJson('v1/bookshelf.json', {
        'schema_version': 1,
        'items': mergedBookshelf.map((item) => item.toRow()).toList(),
      });
      uploaded += 1;

      final remoteAnswers = _indexByAnswerKey(remote.answers);
      for (final answer in mergedAnswers) {
        final path = _answerPath(answer.cacheKey);
        final remoteReference = remoteAnswers[answer.cacheKey];
        if (remoteReference != null &&
            remoteReference.cachedAt == answer.cachedAt) {
          continue;
        }
        await client.putJson(path, answer.toJson());
        uploaded += 1;
      }

      final remoteChapters = _indexByChapterKey(remote.chapters);
      final chapterDirectories = <String>{};
      for (final chapter in mergedChapters) {
        final directory = _chapterDirectory(chapter);
        if (chapterDirectories.add(directory)) {
          await client.ensureDirectory(directory);
        }
        final path = _chapterPath(chapter);
        final key = _chapterKey(chapter);
        final remoteReference = remoteChapters[key];
        if (remoteReference != null &&
            remoteReference.cachedAt == chapter.cachedAt) {
          continue;
        }
        await client.putJson(path, chapter.toJson());
        uploaded += 1;
      }

      await client.putJson('v1/index.json', {
        'schema_version': 1,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'answer_cache': [
          for (final answer in mergedAnswers)
            {
              'cache_key': answer.cacheKey,
              'cached_at': answer.cachedAt.toUtc().toIso8601String(),
              'path': _answerPath(answer.cacheKey),
            },
        ],
        'salt_chapters': [
          for (final chapter in mergedChapters)
            {
              'business_id': chapter.businessId,
              'section_id': chapter.sectionId,
              'cached_at': chapter.cachedAt.toUtc().toIso8601String(),
              'path': _chapterPath(chapter),
            },
        ],
      });
      uploaded += 1;
      final totalDownloaded = downloaded + downloadedChapters;
      final result = WebDavSyncResult(
        uploaded: uploaded,
        downloaded: totalDownloaded,
        skipped:
            mergedAnswers.length -
            answersToImport.length +
            mergedChapters.length -
            chaptersToImport.length,
        message: '同步完成：上传 $uploaded 项，恢复 $totalDownloaded 项',
      );
      _setStatus(
        WebDavSyncStatus(
          phase: WebDavSyncPhase.success,
          message: result.message,
          lastSyncedAt: DateTime.now(),
          uploaded: uploaded,
          downloaded: totalDownloaded,
        ),
      );
      unawaited(
        AppLogStore.instance.record(
          category: AppLogCategory.app,
          level: AppLogLevel.info,
          message: 'WebDAV 同步完成',
          details: {
            'provider': value.provider.name,
            'uploaded': uploaded,
            'downloaded': totalDownloaded,
            'search_count': mergedSearch.length,
            'browsing_count': mergedBrowsing.length,
            'answer_count': mergedAnswers.length,
            'chapter_count': mergedChapters.length,
          },
        ),
      );
      return result;
    } catch (error) {
      _setFailure(error, 'WebDAV 同步失败');
      rethrow;
    } finally {
      await client.close();
    }
  }

  Future<_LocalSyncSnapshot> _exportLocal() async {
    await _bookshelf.load();
    return _LocalSyncSnapshot(
      searchHistory: session.rememberSearchHistory
          ? List<String>.from(session.searchHistory)
          : const [],
      browsingHistory: session.rememberBrowsingHistory
          ? List<BrowsingHistoryEntry>.from(session.browsingHistory)
          : const [],
      bookshelf: List<SaltBookshelfEntry>.from(_bookshelf.entries),
      answers: await _answerCache.exportEntries(),
      chapters: await _chapterCache.exportEntries(),
    );
  }

  Future<_RemoteSyncSnapshot> _readRemote(WebDavClient client) async {
    Map<String, dynamic>? index;
    try {
      index = await client.getJson('v1/index.json');
    } on FormatException catch (error) {
      _recordRemoteReadFailure('v1/index.json', error);
      return const _RemoteSyncSnapshot.empty();
    }
    if (index == null) return const _RemoteSyncSnapshot.empty();
    final schema = int.tryParse(index['schema_version']?.toString() ?? '');
    if (schema != 1) throw const FormatException('WebDAV 同步版本不兼容');
    final search = await _readStringList(client, 'v1/search-history.json');
    final browsing = await _readBrowsing(client);
    final bookshelf = await _readBookshelf(client);
    final answers = await _readAnswerEntries(client, index['answer_cache']);
    final chapters = await _readChapterEntries(client, index['salt_chapters']);
    return _RemoteSyncSnapshot(
      searchHistory: search,
      browsingHistory: browsing,
      bookshelf: bookshelf,
      answers: answers,
      chapters: chapters,
    );
  }

  Future<List<String>> _readStringList(WebDavClient client, String path) async {
    final source = await _readOptionalJson(client, path);
    final items = source?['items'];
    if (items is! List) return const [];
    return items
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty && item.length <= 512)
        .take(20)
        .toList(growable: false);
  }

  Future<List<BrowsingHistoryEntry>> _readBrowsing(WebDavClient client) async {
    final source = await _readOptionalJson(client, 'v1/browsing-history.json');
    final items = source?['items'];
    if (items is! List) return const [];
    return items
        .map(BrowsingHistoryEntry.fromJson)
        .whereType<BrowsingHistoryEntry>()
        .take(80)
        .toList(growable: false);
  }

  Future<List<SaltBookshelfEntry>> _readBookshelf(WebDavClient client) async {
    final source = await _readOptionalJson(client, 'v1/bookshelf.json');
    final items = source?['items'];
    if (items is! List) return const [];
    final result = <SaltBookshelfEntry>[];
    for (final item in items) {
      if (item is! Map) continue;
      final row = <String, Object?>{
        for (final entry in item.entries) entry.key.toString(): entry.value,
      };
      try {
        final parsed = SaltBookshelfEntry.fromRow(row);
        if (RegExp(r'^\d+$').hasMatch(parsed.businessId)) result.add(parsed);
      } on Object {
        // Skip malformed optional shelf metadata.
      }
    }
    return result.take(400).toList(growable: false);
  }

  Future<List<AnswerDetailCacheSnapshot>> _readAnswerEntries(
    WebDavClient client,
    Object? rawReferences,
  ) async {
    final references = _readReferences(rawReferences, kind: 'answer');
    return _parallelRead(references, (reference) async {
      final source = await client.getJson(reference.path);
      return AnswerDetailCacheSnapshot.fromJson(source);
    });
  }

  Future<List<SaltCachedChapter>> _readChapterEntries(
    WebDavClient client,
    Object? rawReferences,
  ) async {
    final references = _readReferences(rawReferences, kind: 'chapter');
    return _parallelRead(references, (reference) async {
      final source = await client.getJson(reference.path);
      return SaltCachedChapter.fromJson(source);
    });
  }

  Future<List<T>> _parallelRead<T>(
    List<_RemoteReference> references,
    Future<T?> Function(_RemoteReference reference) read,
  ) async {
    final results = List<T?>.filled(references.length, null);
    var next = 0;
    Future<void> worker() async {
      while (true) {
        final index = next;
        next += 1;
        if (index >= references.length) return;
        try {
          results[index] = await read(references[index]);
        } on Object catch (error) {
          _recordRemoteReadFailure(references[index].path, error);
        }
      }
    }

    final workers = references.length < 3 ? references.length : 3;
    await Future.wait([for (var i = 0; i < workers; i++) worker()]);
    return results.whereType<T>().toList(growable: false);
  }

  Future<Map<String, dynamic>?> _readOptionalJson(
    WebDavClient client,
    String path,
  ) async {
    try {
      return await client.getJson(path);
    } on Object catch (error) {
      _recordRemoteReadFailure(path, error);
      return null;
    }
  }

  void _recordRemoteReadFailure(String path, Object error) {
    unawaited(
      AppLogStore.instance.record(
        category: AppLogCategory.app,
        level: AppLogLevel.warning,
        message: 'WebDAV 远端可选数据读取失败，已跳过',
        details: {'path': path, 'error_type': error.runtimeType.toString()},
      ),
    );
  }

  List<_RemoteReference> _readReferences(Object? raw, {required String kind}) {
    if (raw is! List) return const [];
    final result = <_RemoteReference>[];
    for (final item in raw.take(kind == 'answer' ? 80 : 4000)) {
      if (item is! Map) continue;
      final map = item.map((key, value) => MapEntry(key.toString(), value));
      final path = map['path']?.toString() ?? '';
      final cachedAt = DateTime.tryParse(map['cached_at']?.toString() ?? '');
      if (cachedAt == null || !_isSafeRemotePath(path, kind)) continue;
      result.add(_RemoteReference(path: path, cachedAt: cachedAt.toLocal()));
    }
    return result;
  }

  static bool _isSafeRemotePath(String path, String kind) {
    final prefix = kind == 'answer' ? 'v1/answers/' : 'v1/chapters/';
    return path.startsWith(prefix) &&
        !path.contains('..') &&
        path.length <= 512;
  }

  static List<String> _mergeSearch(List<String> local, List<String> remote) {
    final result = <String>[];
    final seen = <String>{};
    for (final item in [...local, ...remote]) {
      final normalized = item.trim();
      if (normalized.isEmpty ||
          normalized.length > 512 ||
          !seen.add(normalized.toLowerCase())) {
        continue;
      }
      result.add(normalized);
      if (result.length == 20) break;
    }
    return result;
  }

  static List<BrowsingHistoryEntry> _mergeBrowsing(
    List<BrowsingHistoryEntry> local,
    List<BrowsingHistoryEntry> remote,
  ) {
    final byIdentity = <String, BrowsingHistoryEntry>{};
    for (final item in [...local, ...remote]) {
      final current = byIdentity[item.identity];
      if (current == null || item.visitedAt.isAfter(current.visitedAt)) {
        byIdentity[item.identity] = item;
      }
    }
    final result = byIdentity.values.toList()
      ..sort((left, right) => right.visitedAt.compareTo(left.visitedAt));
    return result.take(80).toList(growable: false);
  }

  static List<SaltBookshelfEntry> _mergeBookshelf(
    List<SaltBookshelfEntry> local,
    List<SaltBookshelfEntry> remote,
  ) {
    final byId = <String, SaltBookshelfEntry>{
      for (final item in local) item.businessId: item,
    };
    for (final item in remote) {
      final current = byId[item.businessId];
      if (current == null || item.addedAt.isAfter(current.addedAt)) {
        byId[item.businessId] = item;
      }
    }
    final result = byId.values.toList()
      ..sort((left, right) => right.addedAt.compareTo(left.addedAt));
    return result.take(400).toList(growable: false);
  }

  static List<AnswerDetailCacheSnapshot> _mergeAnswers(
    List<AnswerDetailCacheSnapshot> local,
    List<AnswerDetailCacheSnapshot> remote,
  ) {
    final byKey = <String, AnswerDetailCacheSnapshot>{
      for (final item in local) item.cacheKey: item,
    };
    for (final item in remote) {
      final current = byKey[item.cacheKey];
      if (current == null || item.cachedAt.isAfter(current.cachedAt)) {
        byKey[item.cacheKey] = item;
      }
    }
    final result = byKey.values.toList()
      ..sort((left, right) => right.cachedAt.compareTo(left.cachedAt));
    return result.take(80).toList(growable: false);
  }

  static List<SaltCachedChapter> _mergeChapters(
    List<SaltCachedChapter> local,
    List<SaltCachedChapter> remote,
  ) {
    final byKey = <String, SaltCachedChapter>{
      for (final item in local) _chapterKey(item): item,
    };
    for (final item in remote) {
      final key = _chapterKey(item);
      final current = byKey[key];
      if (current == null || item.cachedAt.isAfter(current.cachedAt)) {
        byKey[key] = item;
      }
    }
    final result = byKey.values.toList()
      ..sort((left, right) => right.cachedAt.compareTo(left.cachedAt));
    return result.take(4000).toList(growable: false);
  }

  static List<AnswerDetailCacheSnapshot> _newerRemoteAnswers(
    List<AnswerDetailCacheSnapshot> local,
    List<AnswerDetailCacheSnapshot> remote,
  ) {
    final localByKey = {for (final item in local) item.cacheKey: item};
    return remote
        .where((item) {
          final current = localByKey[item.cacheKey];
          return current == null || item.cachedAt.isAfter(current.cachedAt);
        })
        .toList(growable: false);
  }

  static List<SaltCachedChapter> _newerRemoteChapters(
    List<SaltCachedChapter> local,
    List<SaltCachedChapter> remote,
  ) {
    final localByKey = {for (final item in local) _chapterKey(item): item};
    return remote
        .where((item) {
          final current = localByKey[_chapterKey(item)];
          return current == null || item.cachedAt.isAfter(current.cachedAt);
        })
        .toList(growable: false);
  }

  static Map<String, _RemoteReference> _indexByAnswerKey(
    List<AnswerDetailCacheSnapshot> entries,
  ) => {
    for (final item in entries)
      item.cacheKey: _RemoteReference(
        path: _answerPath(item.cacheKey),
        cachedAt: item.cachedAt,
      ),
  };

  static Map<String, _RemoteReference> _indexByChapterKey(
    List<SaltCachedChapter> entries,
  ) => {
    for (final item in entries)
      _chapterKey(item): _RemoteReference(
        path: _chapterPath(item),
        cachedAt: item.cachedAt,
      ),
  };

  static String _answerPath(String key) =>
      'v1/answers/${_safeSegment(key)}.json';

  static String _chapterDirectory(SaltCachedChapter chapter) =>
      'v1/chapters/${_safeSegment(chapter.businessId)}';

  static String _chapterPath(SaltCachedChapter chapter) =>
      '${_chapterDirectory(chapter)}/${_safeSegment(chapter.sectionId)}.json';

  static String _chapterKey(SaltCachedChapter chapter) =>
      '${chapter.businessId}:${chapter.sectionId}';

  static String _safeSegment(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');

  void _setFailure(Object error, String message) {
    _setStatus(
      WebDavSyncStatus(
        phase: WebDavSyncPhase.failure,
        message: '$message：${_shortError(error)}',
        lastSyncedAt: _status.lastSyncedAt,
        uploaded: 0,
        downloaded: 0,
      ),
    );
    unawaited(
      AppLogStore.instance.recordError(
        error,
        StackTrace.current,
        message: message,
        category: AppLogCategory.app,
      ),
    );
  }

  static String? _configurationError(WebDavSettings value) {
    if (!value.enabled) return 'WebDAV 同步未启用';
    return value.validate();
  }

  static String _shortError(Object error) {
    final value = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (value.length <= 180) return value;
    return '${value.substring(0, 180)}…';
  }

  void _setStatus(WebDavSyncStatus value) {
    if (_disposed) return;
    _status = value;
    notifyListeners();
  }
}

class _LocalSyncSnapshot {
  const _LocalSyncSnapshot({
    required this.searchHistory,
    required this.browsingHistory,
    required this.bookshelf,
    required this.answers,
    required this.chapters,
  });

  final List<String> searchHistory;
  final List<BrowsingHistoryEntry> browsingHistory;
  final List<SaltBookshelfEntry> bookshelf;
  final List<AnswerDetailCacheSnapshot> answers;
  final List<SaltCachedChapter> chapters;
}

class _RemoteSyncSnapshot {
  const _RemoteSyncSnapshot({
    required this.searchHistory,
    required this.browsingHistory,
    required this.bookshelf,
    required this.answers,
    required this.chapters,
  });

  const _RemoteSyncSnapshot.empty()
    : searchHistory = const [],
      browsingHistory = const [],
      bookshelf = const [],
      answers = const [],
      chapters = const [];

  final List<String> searchHistory;
  final List<BrowsingHistoryEntry> browsingHistory;
  final List<SaltBookshelfEntry> bookshelf;
  final List<AnswerDetailCacheSnapshot> answers;
  final List<SaltCachedChapter> chapters;
}

class _RemoteReference {
  const _RemoteReference({required this.path, required this.cachedAt});

  final String path;
  final DateTime cachedAt;
}
