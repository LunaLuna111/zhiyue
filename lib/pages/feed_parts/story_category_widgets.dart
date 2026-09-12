part of '../feed_page.dart';

class _SaltStoryCategoryTabs extends StatefulWidget {
  const _SaltStoryCategoryTabs({
    required this.api,
    required this.tags,
    required this.conditionItems,
    required this.headerItems,
    required this.onOpen,
    required this.onRefresh,
  });
  final ZhihuApiClient api;
  final List<_SaltStoryConditionTag> tags;
  final List<Map<String, dynamic>> conditionItems;
  final List<Map<String, dynamic>> headerItems;
  final ValueChanged<Map<String, dynamic>> onOpen;
  final RefreshCallback onRefresh;
  @override
  State<_SaltStoryCategoryTabs> createState() => _SaltStoryCategoryTabsState();
}

class _SaltStoryCategoryTabsState extends State<_SaltStoryCategoryTabs> {
  static const _tabTypes = ['story', 'book', 'assessment'];
  static const _tabTitles = ['故事', '电子书', '测评'];
  static const _defaultHotTags = ['言情', '虐恋', '娱乐圈', '追妻火葬场', '惊悚', '家庭'];
  int _tabIndex = 0;
  String _storyLength = 'long';
  String _sort = 'hottest';
  Map<String, String> _selectedFilters = <String, String>{};
  String get _tagType => _tabTypes[_tabIndex];
  List<Map<String, dynamic>> get _tabItems => widget.conditionItems
      .where((item) => plainText(item['_salt_tag_type']) == _tagType)
      .toList(growable: false);
  List<Map<String, dynamic>> get _categoryItems => _tabItems
      .where(
        (item) =>
            plainText(item['_salt_condition_role']) != 'filter' &&
            plainText(item['_salt_condition_role']) != 'sort' &&
            plainText(item['_salt_condition_role']) != 'quick',
      )
      .toList(growable: false);
  List<Map<String, dynamic>> get _hotTags {
    final output = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final item in _categoryItems) {
      final parent = plainText(item['_salt_parent_title']);
      final title = plainText(item['title']);
      final label = parent.isNotEmpty && title == '全部' ? parent : title;
      if (label.isEmpty || label == '全部' || !seen.add(label)) continue;
      output.add(item);
      if (output.length == 6) break;
    }
    if (output.isNotEmpty) return output;
    return [
      for (final label in _defaultHotTags)
        <String, dynamic>{'title': label, '_salt_tag_type': _tagType},
    ];
  }

  Map<String, String> get _requestFilters {
    final filters = <String, String>{'sort_type': _sort, ..._selectedFilters};
    if (_tagType == 'story') {
      if (_storyLength == 'short') {
        filters['sku_type'] = 'content_short';
        filters['short_content_type'] = 'section';
      } else if (_storyLength == 'audio') {
        filters['sku_type'] = 'ebook_audio';
      } else {
        filters['sku_type'] = 'paid_column';
      }
    } else if (_tagType == 'book') {
      filters['sku_type'] = 'ebook';
    }
    return filters;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabTitles.length,
      initialIndex: _tabIndex,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              indicatorColor: ZhPalette.ink,
              labelColor: ZhPalette.ink,
              unselectedLabelColor: ZhPalette.mutedInk,
              tabs: [for (final title in _tabTitles) Tab(text: title)],
              onTap: (index) {
                if (_tabIndex == index) return;
                setState(() {
                  _tabIndex = index;
                  _selectedFilters = <String, String>{};
                  _sort = 'hottest';
                  _storyLength = 'long';
                });
              },
            ),
          ),
          _buildControls(context),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) => Material(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Column(
      children: [
        if (_tabIndex == 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _SaltStoryTypeButton(
                  label: '长篇',
                  icon: Icons.description_outlined,
                  selected: _storyLength == 'long',
                  onTap: () => _setLength('long'),
                ),
                const SizedBox(width: 24),
                _SaltStoryTypeButton(
                  label: '短篇',
                  icon: Icons.insert_drive_file_outlined,
                  selected: _storyLength == 'short',
                  onTap: () => _setLength('short'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showSortSheet,
                  icon: const Icon(Icons.swap_vert_rounded, size: 18),
                  label: Text(_sortLabel),
                  style: TextButton.styleFrom(
                    foregroundColor: ZhPalette.mutedInk,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('筛选'),
                  style: TextButton.styleFrom(
                    foregroundColor: ZhPalette.ink,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _showSortSheet,
                  icon: const Icon(Icons.swap_vert_rounded, size: 18),
                  label: Text(_sortLabel),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('筛选'),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 52,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            scrollDirection: Axis.horizontal,
            children: [
              for (final item in _hotTags)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _SaltCategoryChip(
                    label: _categoryLabel(item),
                    selected: _matchesCategory(item),
                    onTap: () => _selectCategory(item),
                  ),
                ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showAllCategories,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Icon(Icons.menu_rounded, size: 27),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    ),
  );
  String get _sortLabel => switch (_sort) {
    'score' => '好评',
    'newest' => '上新',
    _ => '热度',
  };
  String _categoryLabel(Map<String, dynamic> item) {
    final parent = plainText(item['_salt_parent_title']);
    final title = plainText(item['title']);
    return parent.isNotEmpty && title == '全部' ? parent : title;
  }

  bool _matchesCategory(Map<String, dynamic> item) {
    final key = plainText(item['_salt_filter_key']);
    final value = plainText(item['_salt_filter_value']);
    return key.isNotEmpty && _selectedFilters[key] == value;
  }

  void _setLength(String value) {
    if (_storyLength == value) return;
    setState(() {
      _storyLength = value;
      _selectedFilters = <String, String>{};
    });
  }

  void _selectCategory(Map<String, dynamic> item) {
    final raw = item['_salt_filter_query'];
    if (raw is! Map) return;
    final query = <String, String>{};
    raw.forEach((key, value) {
      final k = plainText(key);
      final v = plainText(value);
      if (k.isNotEmpty && v.isNotEmpty) query[k] = v;
    });
    if (query.isEmpty) return;
    setState(() => _selectedFilters = query);
  }

  Widget _buildResults() {
    final filters = _requestFilters;
    return PagedListPage(
      key: ValueKey('$_tagType|${filters.entries.join(',')}'),
      embedded: true,
      title: '',
      api: widget.api,
      loadInitial: () => _loadCategoryPage(tagType: _tagType, filters: filters),
      rowsExtractor: extractSaltLongStoryRows,
      rowBuilder: (context, value, onTap) {
        if (_tabIndex == 0 && _storyLength == 'short') {
          return _SaltShortStoryCard(value: value, onTap: onTap);
        }
        return SaltCatalogCard(
          value: value,
          onTap: onTap,
          coverWidth: 118,
          coverHeight: 166,
        );
      },
      onObjectTap: (context, value) => widget.onOpen(value),
      emptyMessage: '暂时没有符合条件的内容',
    );
  }

  Future<ApiResponse> _loadCategoryPage({
    required String tagType,
    required Map<String, String> filters,
  }) async {
    // Match the native m98383t initial request: it does not carry paging
    // parameters.  The old implementation sent limit/offset on the first
    // request, which the current book/assessment gateway rejects.
    final initial = await widget.api.getSaltUri(
      widget.api.saltBookCitySectionInitialUri(
        tagType: tagType,
        filters: filters,
      ),
    );
    if (initial.isSuccess) return initial;
    // A few server revisions still expose the same cards through sku_list.
    // Keep section as the primary contract and only use this compatibility
    // path after a real HTTP/business failure, never after an empty success.
    try {
      final fallback = await widget.api.getSaltUri(
        widget.api.saltBookCitySkuListUri(tagType: tagType, filters: filters),
      );
      if (fallback.isSuccess) return fallback;
    } catch (_) {
      // Preserve the native section error for the common error view.
    }
    return initial;
  }

  Future<void> _showSortSheet() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in const [
              ('hottest', '热度'),
              ('score', '好评'),
              ('newest', '上新'),
            ])
              ListTile(
                title: Text(option.$2),
                trailing: option.$1 == _sort
                    ? const Icon(Icons.check_rounded, color: Colors.blue)
                    : null,
                onTap: () => Navigator.pop(context, option.$1),
              ),
          ],
        ),
      ),
    );
    if (value != null && mounted) setState(() => _sort = value);
  }

  Future<void> _showFilterSheet() async {
    final value = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SaltStoryFilterSheet(
        storyLength: _storyLength,
        filters: _selectedFilters,
        conditionItems: _tabItems,
      ),
    );
    if (value == null || !mounted) return;
    setState(() {
      _storyLength = value.remove('__length') ?? _storyLength;
      _selectedFilters = value;
    });
  }

  Future<void> _showAllCategories() async {
    final value = await showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SaltAllCategorySheet(
        items: _categoryItems,
        selectedFilters: _selectedFilters,
      ),
    );
    if (value == null || !mounted) return;
    final query = <String, String>{};
    for (final item in value) {
      final raw = item['_salt_filter_query'];
      if (raw is Map) {
        raw.forEach((key, value) {
          final k = plainText(key);
          final v = plainText(value);
          if (k.isNotEmpty && v.isNotEmpty) query[k] = v;
        });
      }
    }
    setState(() => _selectedFilters = query);
  }
}

class _SaltStoryTypeButton extends StatelessWidget {
  const _SaltStoryTypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 19,
            color: selected ? Colors.blue.shade700 : ZhPalette.mutedInk,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.blue.shade700 : ZhPalette.ink,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SaltCategoryChip extends StatelessWidget {
  const _SaltCategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFEAF2FF) : const Color(0xFFF8F8FA),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.blue.shade700 : ZhPalette.mutedInk,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}

class _SaltShortStoryCard extends StatelessWidget {
  const _SaltShortStoryCard({required this.value, this.onTap});
  final Map<String, dynamic> value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final object = unwrapObject(value);
    final title = plainText(
      object['title'] ?? object['content_title'] ?? object['name'],
    );
    final excerpt = plainText(
      object['description'] ??
          object['content'] ??
          object['subtitle'] ??
          object['sub_title'],
    );
    final artwork = plainText(object['artwork'] ?? object['image_url']);
    final validArtwork = Uri.tryParse(artwork)?.scheme == 'https';
    final labels = object['labels'] is List
        ? (object['labels'] as List)
              .map(
                (item) => plainText(
                  item is Map ? item['title'] ?? item['name'] : item,
                ),
              )
              .where((item) => item.isNotEmpty)
              .take(3)
              .toList()
        : const <String>[];
    final like = plainText(object['like_count'] ?? object['like_text']);
    return ZhSurface(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
      radius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '未命名故事' : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                if (excerpt.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    excerpt,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ZhPalette.mutedInk,
                      height: 1.45,
                    ),
                  ),
                ],
                if (labels.isNotEmpty || like.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    runSpacing: 5,
                    children: [
                      for (final label in labels)
                        Text(
                          label,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ZhPalette.subtleInk),
                        ),
                      if (like.isNotEmpty)
                        Text(
                          '$like 赞',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ZhPalette.subtleInk),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (validArtwork) ...[
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: ZhihuImage.network(
                artwork,
                headers: zhihuImageRequestHeaders,
                width: 128,
                height: 88,
                fit: BoxFit.cover,
                cacheWidth: 384,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
