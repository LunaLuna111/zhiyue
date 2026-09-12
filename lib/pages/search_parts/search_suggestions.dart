part of '../search_page.dart';

class _SearchSuggestionCacheEntry {
  const _SearchSuggestionCacheEntry({
    required this.items,
    required this.expiresAt,
  });

  final List<zhihu_api.SearchSuggestion> items;
  final DateTime expiresAt;
}

extension _SearchSuggestionPanel on _SearchPageState {
  Widget _buildSearchSuggestionPanel(BuildContext context) {
    final query = _suggestionsForQuery;
    if (query.isEmpty || (!_suggestionsLoading && _suggestions.isEmpty)) {
      return const SizedBox.shrink();
    }
    return _SearchSuggestionList(
      query: query,
      items: _suggestions,
      loading: _suggestionsLoading,
      onSelected: _submit,
    );
  }
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
