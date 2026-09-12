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
    ].take(10).toList(growable: false);
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
}
