part of '../session_store.dart';

mixin _SessionStoreHistoryMixin on _SessionStoreCore {
  Future<void> rememberSearch(String query) async {
    if (!rememberSearchHistory) return;
    final normalized = query.trim();
    if (normalized.isEmpty || normalized.length > 512) return;
    searchHistory = [
      normalized,
      ...searchHistory.where(
        (item) => item.toLowerCase() != normalized.toLowerCase(),
      ),
    ].take(_SessionStoreCore._maxSearchHistoryItems).toList(growable: false);
    if (!kIsWeb) {
      await _safeWrite(
        key: _SessionStoreCore._searchHistoryKey,
        value: jsonEncode(searchHistory),
      );
    }
    _notifyChanged();
  }

  Future<void> clearSearchHistory() async {
    searchHistory = const [];
    if (!kIsWeb) await _safeDelete(_SessionStoreCore._searchHistoryKey);
    _notifyChanged();
  }

  /// Merges a remote WebDAV snapshot without changing the existing local
  /// history order. Local entries remain first because they represent the most
  /// recent activity on this device; remote entries fill the remaining slots.
  /// Search history is intentionally never sent through the account API.
  Future<void> mergeSearchHistory(Iterable<String> remoteItems) async {
    if (!rememberSearchHistory) return;
    final merged = <String>[];
    final seen = <String>{};
    for (final item in [...searchHistory, ...remoteItems]) {
      final normalized = item.trim();
      final identity = normalized.toLowerCase();
      if (normalized.isEmpty ||
          normalized.length > 512 ||
          !seen.add(identity)) {
        continue;
      }
      merged.add(normalized);
      if (merged.length >= _SessionStoreCore._maxSearchHistoryItems) break;
    }
    if (listEquals(searchHistory, merged)) return;
    searchHistory = List<String>.unmodifiable(merged);
    if (!kIsWeb) {
      await _safeWrite(
        key: _SessionStoreCore._searchHistoryKey,
        value: jsonEncode(searchHistory),
      );
    }
    _notifyChanged();
  }

  Future<void> rememberBrowsing({
    required String type,
    required String id,
    required String title,
    String excerpt = '',
    String author = '',
    String questionId = '',
    String questionTitle = '',
  }) async {
    if (!rememberBrowsingHistory) return;
    final normalizedType = type.trim().toLowerCase();
    final normalizedId = id.trim();
    final normalizedTitle = title.trim();
    if (normalizedType.isEmpty ||
        normalizedType.length > 48 ||
        normalizedId.isEmpty ||
        normalizedId.length > 256 ||
        normalizedTitle.isEmpty) {
      return;
    }
    final entry = BrowsingHistoryEntry(
      type: normalizedType,
      id: normalizedId,
      title: _SessionStoreCore._boundedText(normalizedTitle, 512),
      excerpt: _SessionStoreCore._boundedText(excerpt.trim(), 900),
      author: _SessionStoreCore._boundedText(author.trim(), 160),
      visitedAt: DateTime.now(),
      questionId: _SessionStoreCore._boundedText(questionId.trim(), 256),
      questionTitle: _SessionStoreCore._boundedText(questionTitle.trim(), 512),
    );
    browsingHistory = [
      entry,
      ...browsingHistory.where((item) => item.identity != entry.identity),
    ].take(80).toList(growable: false);
    _browsingHistoryChanges.emit();
    await _persistBrowsingHistory();
  }

  Future<void> removeBrowsingHistory(String identity) async {
    final next = browsingHistory
        .where((item) => item.identity != identity)
        .toList(growable: false);
    if (next.length == browsingHistory.length) return;
    browsingHistory = next;
    _browsingHistoryChanges.emit();
    await _persistBrowsingHistory();
  }

  Future<void> clearBrowsingHistory() async {
    if (browsingHistory.isEmpty) return;
    browsingHistory = const [];
    _browsingHistoryChanges.emit();
    await _persistBrowsingHistory();
  }

  /// Merges browsing records by identity and keeps the newest visit. The
  /// remote snapshot can therefore be restored on a new device without
  /// replacing a newer local visit with an older copy.
  Future<void> mergeBrowsingHistory(
    Iterable<BrowsingHistoryEntry> remoteItems,
  ) async {
    if (!rememberBrowsingHistory) return;
    final byIdentity = <String, BrowsingHistoryEntry>{
      for (final item in browsingHistory) item.identity: item,
    };
    for (final item in remoteItems) {
      final current = byIdentity[item.identity];
      if (current == null || item.visitedAt.isAfter(current.visitedAt)) {
        byIdentity[item.identity] = item;
      }
    }
    final merged = byIdentity.values.toList()
      ..sort((left, right) => right.visitedAt.compareTo(left.visitedAt));
    final bounded = merged.take(80).toList(growable: false);
    if (_sameBrowsingHistory(browsingHistory, bounded)) return;
    browsingHistory = List<BrowsingHistoryEntry>.unmodifiable(bounded);
    _browsingHistoryChanges.emit();
    await _persistBrowsingHistory();
  }

  bool _sameBrowsingHistory(
    List<BrowsingHistoryEntry> left,
    List<BrowsingHistoryEntry> right,
  ) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      final a = left[index];
      final b = right[index];
      if (a.identity != b.identity || a.visitedAt != b.visitedAt) return false;
    }
    return true;
  }
}
