part of '../search_page.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.api,
    required this.initialQuery,
    this.initialType = 'general',
  });

  final ZhihuApiClient api;
  final String initialQuery;
  final String initialType;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final TextEditingController _query;
  late final PageController _pages;
  late final _SearchSuggestionController _suggestions;
  final _selectedFilters = <String, String>{};
  List<List<SearchFilterOption>> _filterGroups = officialSearchFilterGroups;
  late int _index;
  late String _submittedQuery;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _submittedQuery = widget.initialQuery.trim();
    _query = TextEditingController(text: _submittedQuery);
    _suggestions = _SearchSuggestionController(widget.api);
    _index = officialSearchTabs.indexWhere(
      (tab) => tab.type == widget.initialType,
    );
    if (_index < 0) _index = 0;
    _pages = PageController(initialPage: _index);
    _loadFilterCatalog();
  }

  @override
  void dispose() {
    _suggestions.dispose();
    _query.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) => _suggestions.onQueryChanged(value);

  void _submit(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    _query.text = normalized;
    _suggestions.dismiss();
    widget.api.session.rememberSearch(normalized);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _submittedQuery = normalized);
  }

  Future<void> _loadFilterCatalog() async {
    try {
      final response = await widget.api.getUri(
        widget.api.searchCustomizeUri(),
        headers: const {'x-api-version': '3.0.91'},
      );
      final groups = parseSearchFilterGroups(response.json);
      if (!mounted || !response.isSuccess || groups.isEmpty) return;
      setState(() => _filterGroups = groups);
    } catch (_) {
      // The verified contract snapshot remains available offline.
    }
  }

  void _switchToTab(int index) {
    if (index < 0 || index >= officialSearchTabs.length || index == _index) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _index = index;
      if (index != 0) _showFilters = false;
    });
    // A long animateToPage jump creates every intermediate result tab. Each
    // tab immediately starts its own API request and image warm-up, which can
    // block frames when changing from 综合 to a distant category such as 视频.
    _pages.jumpToPage(index);
  }

  void _toggleFilters() {
    if (_index != 0) {
      _switchToTab(0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showFilters = true);
      });
      return;
    }
    setState(() => _showFilters = !_showFilters);
  }

  void _selectFilter(SearchFilterOption option) {
    setState(() {
      if (option.linkName.isEmpty) {
        _selectedFilters.remove(option.group);
      } else {
        _selectedFilters[option.group] = option.linkName;
      }
    });
  }

  String get _filterSignature => const [
    'vertical',
    'sort',
    'time_interval',
  ].map((group) => '$group=${_selectedFilters[group] ?? ''}').join('&');

  void _openRecentResults() {
    final recentIndex = officialSearchTabs.indexWhere(
      (tab) => tab.type == 'recent',
    );
    if (recentIndex < 0) return;
    _switchToTab(recentIndex);
  }

  void _openResultType(String type) {
    final index = officialSearchTabs.indexWhere((tab) => tab.type == type);
    if (index < 0) return;
    _switchToTab(index);
  }

  void _pageChanged(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_index == index && (index == 0 || !_showFilters)) return;
    setState(() {
      _index = index;
      if (index != 0) _showFilters = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= ZhViewport.wide;
    return Scaffold(
      // The query field stays visible at the top. Avoid shrinking and laying
      // out a potentially image-heavy result list on every keyboard frame.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            ZhResponsiveFrame(
              maxWidth: 1200,
              desktopGutter: 24,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 12, 5),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '返回',
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SearchField(
                            controller: _query,
                            hintText: '搜索知乎内容',
                            compact: true,
                            onChanged: _onQueryChanged,
                            onSubmitted: _submit,
                          ),
                          _SearchSuggestionPanel(
                            controller: _suggestions,
                            onSelected: _submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ZhResponsiveFrame(
              maxWidth: 1200,
              desktopGutter: 24,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: 10),
                        itemCount: officialSearchTabs.length,
                        itemBuilder: (context, index) {
                          final tab = officialSearchTabs[index];
                          final selected = index == _index;
                          return InkWell(
                            onTap: () => _switchToTab(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    tab.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: selected
                                              ? ZhPalette.ink
                                              : ZhPalette.mutedInk,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    width: selected ? 20 : 0,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: ZhPalette.ink,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _SearchFilterToggle(
                    active: _showFilters,
                    selectedCount: _selectedFilters.length,
                    onTap: _toggleFilters,
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: _showFilters
                  ? ZhResponsiveFrame(
                      maxWidth: 1200,
                      desktopGutter: 24,
                      child: _SearchFilterPanel(
                        groups: _filterGroups,
                        selected: _selectedFilters,
                        onSelected: _selectFilter,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const Divider(height: 1),
            Expanded(
              child: desktop
                  ? ZhResponsiveTwoPane(
                      primary: _buildPageView(),
                      secondary: _SearchDesktopRail(
                        query: _submittedQuery,
                        tab: officialSearchTabs[_index],
                        selectedFilters: _selectedFilters,
                      ),
                    )
                  : _buildPageView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() => PageView.builder(
    controller: _pages,
    itemCount: officialSearchTabs.length,
    onPageChanged: _pageChanged,
    itemBuilder: (context, index) => _SearchResultTab(
      key: ValueKey(
        '${officialSearchTabs[index].type}:$_submittedQuery:'
        '${index == 0 ? _filterSignature : ''}',
      ),
      api: widget.api,
      query: _submittedQuery,
      type: officialSearchTabs[index].type,
      filters: index == 0 ? Map.unmodifiable(_selectedFilters) : const {},
      onOpenRecent: _openRecentResults,
      onOpenType: _openResultType,
    ),
  );
}

class _SearchFilterToggle extends StatelessWidget {
  const _SearchFilterToggle({
    required this.active,
    required this.selectedCount,
    required this.onTap,
  });

  final bool active;
  final int selectedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: selectedCount == 0 ? 82 : 96,
    height: 45,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: ZhPalette.background,
        border: Border(left: BorderSide(color: ZhPalette.border, width: .7)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('search-filter-toggle'),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active
                        ? Icons.filter_alt_rounded
                        : Icons.filter_alt_outlined,
                    size: 19,
                    color: ZhPalette.ink,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    selectedCount == 0 ? '筛选' : '筛选 $selectedCount',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ZhPalette.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SearchFilterPanel extends StatelessWidget {
  const _SearchFilterPanel({
    required this.groups,
    required this.selected,
    required this.onSelected,
  });

  final List<List<SearchFilterOption>> groups;
  final Map<String, String> selected;
  final ValueChanged<SearchFilterOption> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    color: ZhPalette.background,
    padding: const EdgeInsets.fromLTRB(14, 5, 0, 8),
    child: Column(
      children: [
        for (final group in groups)
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: group.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final option = group[index];
                final active =
                    (selected[option.group] ?? '') == option.linkName;
                return Center(
                  child: Material(
                    color: active ? ZhPalette.canvas : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    child: InkWell(
                      onTap: () => onSelected(option),
                      borderRadius: BorderRadius.circular(9),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        child: Text(
                          option.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: active
                                    ? ZhPalette.ink
                                    : ZhPalette.mutedInk,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}

class _SearchDesktopRail extends StatelessWidget {
  const _SearchDesktopRail({
    required this.query,
    required this.tab,
    required this.selectedFilters,
  });

  final String query;
  final SearchTabSpec tab;
  final Map<String, String> selectedFilters;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(0, 18, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ZhSurface(
          padding: const EdgeInsets.all(ZhSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.search_rounded, size: 24),
              const SizedBox(height: ZhSpace.sm),
              Text('搜索概览', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: ZhSpace.xs),
              Text(
                query.isEmpty ? '输入关键词开始搜索' : '“$query”',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
              ),
              const SizedBox(height: ZhSpace.md),
              const Divider(height: 1),
              const SizedBox(height: ZhSpace.md),
              Text('当前范围', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                tab.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
              ),
              if (selectedFilters.isNotEmpty) ...[
                const SizedBox(height: ZhSpace.md),
                Text('已启用筛选', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: ZhSpace.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final entry in selectedFilters.entries)
                      ZhPill(label: _filterLabel(entry.key, entry.value)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: ZhSpace.md),
        ZhSurface(
          padding: const EdgeInsets.all(ZhSpace.md),
          backgroundColor: ZhPalette.canvas,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mouse_outlined, size: 19),
              const SizedBox(width: ZhSpace.sm),
              Expanded(
                child: Text(
                  '滚动结果列表加载更多，点击卡片查看详情。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  String _filterLabel(String group, String value) => switch (group) {
    'vertical' => '类型：$value',
    'sort' => '排序：$value',
    'time_interval' => '时间：$value',
    _ => value,
  };
}
