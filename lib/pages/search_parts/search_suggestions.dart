part of '../search_page.dart';

class _SearchSuggestionCacheEntry {
  const _SearchSuggestionCacheEntry({
    required this.items,
    required this.expiresAt,
  });

  final List<zhihu_api.SearchSuggestion> items;
  final DateTime expiresAt;
}

class _SearchSuggestionController extends ChangeNotifier {
  _SearchSuggestionController(this.api);

  static const maxQueryLength = 128;

  final ZhihuApiClient api;
  final Map<String, _SearchSuggestionCacheEntry> _cache = {};
  final Map<String, Future<List<zhihu_api.SearchSuggestion>>> _requests = {};
  Timer? _debounce;
  List<zhihu_api.SearchSuggestion> _items = const [];
  String _query = '';
  bool _loading = false;
  int _generation = 0;
  bool _disposed = false;

  List<zhihu_api.SearchSuggestion> get items => _items;
  String get query => _query;
  bool get loading => _loading;

  void onQueryChanged(String value) {
    if (_disposed) return;
    _debounce?.cancel();
    final generation = ++_generation;
    final query = value.trim();
    if (query.isEmpty) {
      _query = '';
      _items = const [];
      _loading = false;
      _notify();
      return;
    }

    if (query.length > maxQueryLength) {
      _query = query;
      _items = const [];
      _loading = false;
      _notify();
      return;
    }

    final cacheKey = _cacheKey(query);
    final cached = _validCache(cacheKey);
    if (cached != null) {
      _query = query;
      _items = cached.items;
      _loading = false;
      _notify();
      return;
    }

    // The official endpoint returns ordered completion phrases. Reuse a
    // still-fresh shorter-query response when every retained item still
    // matches the new prefix; this avoids a network round-trip for each IME
    // keystroke without showing unrelated suggestions.
    final prefixItems = _cachedPrefixItems(query);
    if (prefixItems != null) {
      _query = query;
      _items = prefixItems;
      _loading = false;
      _notify();
      return;
    }

    _query = query;
    final retainedItems = _matchingItems(_items, query);
    _items = retainedItems;
    _loading = true;
    _notify();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      _load(query, generation, fallback: retainedItems);
    });
  }

  void dismiss() {
    if (_disposed) return;
    _debounce?.cancel();
    _generation++;
    if (_query.isEmpty && _items.isEmpty && !_loading) return;
    _query = '';
    _items = const [];
    _loading = false;
    _notify();
  }

  Future<void> _load(
    String query,
    int generation, {
    required List<zhihu_api.SearchSuggestion> fallback,
  }) async {
    final requestKey = _cacheKey(query);
    final request = _requests.putIfAbsent(
      requestKey,
      () => api.fetchSearchSuggestions(keyword: query),
    );
    try {
      final items = List<zhihu_api.SearchSuggestion>.unmodifiable(
        await request,
      );
      _remember(requestKey, items, const Duration(minutes: 5));
      if (_disposed || generation != _generation) return;
      _query = query;
      _items = items;
      _loading = false;
      _notify();
    } catch (_) {
      _remember(
        requestKey,
        const <zhihu_api.SearchSuggestion>[],
        const Duration(seconds: 8),
      );
      if (_disposed || generation != _generation) return;
      _query = query;
      _items = fallback;
      _loading = false;
      _notify();
    } finally {
      if (identical(_requests[requestKey], request)) {
        _requests.remove(requestKey);
      }
    }
  }

  void _remember(
    String cacheKey,
    List<zhihu_api.SearchSuggestion> items,
    Duration ttl,
  ) {
    // Reinsert the key so a frequently used query is not evicted merely
    // because it was created earlier than the rest of the small LRU window.
    _cache.remove(cacheKey);
    _cache[cacheKey] = _SearchSuggestionCacheEntry(
      items: items,
      expiresAt: DateTime.now().add(ttl),
    );
    while (_cache.length > 24) {
      _cache.remove(_cache.keys.first);
    }
  }

  _SearchSuggestionCacheEntry? _validCache(String cacheKey) {
    final cached = _cache[cacheKey];
    if (cached == null) return null;
    if (cached.expiresAt.isBefore(DateTime.now())) {
      _cache.remove(cacheKey);
      return null;
    }
    // Promote exact hits so active searches remain in the bounded cache.
    _cache.remove(cacheKey);
    _cache[cacheKey] = cached;
    return cached;
  }

  List<zhihu_api.SearchSuggestion>? _cachedPrefixItems(String query) {
    final queryKey = _cacheKey(query);
    String? bestKey;
    List<zhihu_api.SearchSuggestion>? bestItems;
    final now = DateTime.now();
    for (final entry in List<MapEntry<String, _SearchSuggestionCacheEntry>>.of(
      _cache.entries,
    )) {
      final sourceKey = entry.key;
      final cached = entry.value;
      if (cached.expiresAt.isBefore(now)) {
        _cache.remove(sourceKey);
        continue;
      }
      if (sourceKey.isEmpty || sourceKey.length >= queryKey.length) continue;
      if (!queryKey.startsWith(sourceKey)) continue;
      final filtered = _matchingItems(cached.items, query);
      if (filtered.isEmpty) continue;
      if (bestKey == null || sourceKey.length > bestKey.length) {
        bestKey = sourceKey;
        bestItems = filtered;
      }
    }
    if (bestKey == null || bestItems == null) return null;
    final cached = _cache.remove(bestKey);
    if (cached != null) _cache[bestKey] = cached;
    return bestItems;
  }

  static String _cacheKey(String query) => query.trim().toLowerCase();

  static List<zhihu_api.SearchSuggestion> _matchingItems(
    Iterable<zhihu_api.SearchSuggestion> items,
    String query,
  ) {
    final queryKey = _cacheKey(query);
    if (queryKey.isEmpty) return const [];
    final seen = <String>{};
    return List.unmodifiable(
      items.where((item) {
        final itemKey = _cacheKey(item.query);
        return itemKey.startsWith(queryKey) && seen.add(itemKey);
      }),
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _generation++;
    super.dispose();
  }
}

class _SearchSuggestionPanel extends StatelessWidget {
  const _SearchSuggestionPanel({
    required this.controller,
    required this.onSelected,
  });

  final _SearchSuggestionController controller;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      if (controller.query.isEmpty ||
          (!controller.loading && controller.items.isEmpty)) {
        return const SizedBox.shrink();
      }
      return _SearchSuggestionList(
        query: controller.query,
        items: controller.items,
        loading: controller.loading,
        onSelected: onSelected,
      );
    },
  );
}

class _SearchSuggestionList extends StatelessWidget {
  const _SearchSuggestionList({
    required this.query,
    required this.items,
    required this.loading,
    required this.onSelected,
  });

  final String query;
  final List<zhihu_api.SearchSuggestion> items;
  final bool loading;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '搜索补全',
    child: Container(
      key: const ValueKey('search-suggestion-panel'),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: ZhPalette.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZhPalette.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (loading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
            ),
          if (items.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 52, endIndent: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Semantics(
                    button: true,
                    label: '搜索建议 ${item.query}',
                    child: InkWell(
                      key: ValueKey('search-suggestion:${item.query}'),
                      onTap: () => onSelected(item.query),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: ZhPalette.subtleInk,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.query,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            if (item.label == 'hot') ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.local_fire_department_outlined,
                                size: 18,
                                color: ZhPalette.subtleInk,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '正在查找“$query”',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: ZhPalette.subtleInk),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
