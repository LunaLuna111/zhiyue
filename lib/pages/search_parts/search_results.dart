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

class _SearchFilterCacheEntry {
  List<List<SearchFilterOption>> groups = const [];
  DateTime expiresAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime emptyUntil = DateTime.fromMillisecondsSinceEpoch(0);
  Future<List<List<SearchFilterOption>>>? request;
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  static final Expando<_SearchFilterCacheEntry> _filterCaches =
      Expando<_SearchFilterCacheEntry>();

  late final TextEditingController _query;
  late final FocusNode _queryFocus;
  late final PageController _pages;
  late final _SearchSuggestionController _suggestions;
  final _selectedFilters = <String, String>{};
  final _headerKey = GlobalKey();
  List<List<SearchFilterOption>> _filterGroups = officialSearchFilterGroups;
  late int _index;
  late String _submittedQuery;
  bool _showFilters = false;
  int _filterCatalogGeneration = 0;
  double _resultHeaderHeight = 0;

  @override
  void initState() {
    super.initState();
    _submittedQuery = widget.initialQuery.trim();
    _query = TextEditingController(text: _submittedQuery);
    _queryFocus = FocusNode()..addListener(_onQueryFocusChanged);
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
    _queryFocus.removeListener(_onQueryFocusChanged);
    _suggestions.dispose();
    _query.dispose();
    _queryFocus.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _suggestions.onQueryChanged(value);
    if (mounted) setState(() {});
  }

  void _onQueryFocusChanged() {
    if (!_queryFocus.hasFocus) _suggestions.dismiss();
  }

  void _submit(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    _query.text = normalized;
    _suggestions.dismiss();
    widget.api.session.rememberSearch(normalized);
    FocusManager.instance.primaryFocus?.unfocus();
    if (normalized == _submittedQuery &&
        _index == 0 &&
        _selectedFilters.isEmpty) {
      return;
    }
    setState(() {
      _submittedQuery = normalized;
      _selectedFilters.clear();
      _showFilters = false;
      _index = 0;
    });
    // A new query is a new search session. Re-enter the default result tab so
    // filters and a tab-specific result stream from the previous query cannot
    // leak into the newly submitted completion.
    if (_pages.hasClients) _pages.jumpToPage(0);
  }

  void _clearQuery() {
    if (_query.text.isEmpty) return;
    _query.clear();
    _onQueryChanged('');
    _queryFocus.requestFocus();
  }

  Widget _searchActions() {
    final actions = <ZhLiquidGlassCapsuleAction>[
      ZhLiquidGlassCapsuleAction(
        icon: const Tooltip(
          message: '搜索',
          child: Icon(
            Icons.arrow_forward_rounded,
            key: ValueKey('search-submit'),
          ),
        ),
        semanticLabel: '搜索',
        onPressed: () => _submit(_query.text),
      ),
    ];
    if (_query.text.trim().isNotEmpty) {
      actions.add(
        ZhLiquidGlassCapsuleAction(
          icon: const Icon(Icons.clear_rounded, key: ValueKey('search-clear')),
          semanticLabel: '清除搜索内容',
          onPressed: _clearQuery,
        ),
      );
    }
    if (_index == 0) {
      final selectedCount = _selectedFilters.length;
      final active = _showFilters || selectedCount > 0;
      final semanticLabel = selectedCount == 0
          ? '筛选'
          : '筛选，已选择 $selectedCount 项';
      actions.add(
        ZhLiquidGlassCapsuleAction(
          icon: KeyedSubtree(
            key: const ValueKey('search-filter-toggle'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  active ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
                  color: active ? const Color(0xFF1769E0) : ZhPalette.ink,
                ),
                if (selectedCount > 0)
                  Positioned(
                    top: -4,
                    right: -5,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFF1769E0),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            '$selectedCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          semanticLabel: semanticLabel,
          onPressed: _toggleFilters,
        ),
      );
    }
    return ZhLiquidGlassCapsuleActionGroup(
      key: const ValueKey('search-results-actions'),
      actions: actions,
    );
  }

  Future<List<List<SearchFilterOption>>> _requestFilterCatalog() async {
    final response = await widget.api.getUri(
      widget.api.searchCustomizeUri(),
      headers: const {'x-api-version': '3.0.91'},
    );
    if (!response.isSuccess) throw response.failure;
    return parseSearchFilterGroups(response.json);
  }

  Future<void> _loadFilterCatalog({bool force = false}) async {
    final generation = ++_filterCatalogGeneration;
    final cache = _filterCaches[widget.api] ??= _SearchFilterCacheEntry();
    final now = DateTime.now();
    if (!force && cache.groups.isNotEmpty && cache.expiresAt.isAfter(now)) {
      if (mounted && generation == _filterCatalogGeneration) {
        setState(() => _filterGroups = cache.groups);
      }
      return;
    }
    if (!force && cache.emptyUntil.isAfter(now)) return;

    final request = cache.request ??= _requestFilterCatalog();
    try {
      final groups = await request;
      if (groups.isNotEmpty) {
        cache.groups = List.unmodifiable(
          groups.map(List<SearchFilterOption>.unmodifiable),
        );
        cache.expiresAt = DateTime.now().add(const Duration(minutes: 5));
        cache.emptyUntil = DateTime.fromMillisecondsSinceEpoch(0);
      } else {
        // Keep a previously valid server catalog visible when the edge sends
        // an empty configuration during a transient refresh.
        cache.emptyUntil = DateTime.now().add(const Duration(seconds: 8));
      }
      if (!mounted || generation != _filterCatalogGeneration) return;
      if (groups.isNotEmpty) setState(() => _filterGroups = cache.groups);
    } catch (_) {
      cache.emptyUntil = DateTime.now().add(const Duration(seconds: 8));
      // The built-in contract snapshot remains available offline. A failed
      // configuration read must never remove already-rendered filters.
    } finally {
      if (identical(cache.request, request)) cache.request = null;
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

  void _syncResultHeaderHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final measured = _headerKey.currentContext?.size?.height;
      if (!mounted || measured == null) return;
      if ((measured - _resultHeaderHeight).abs() < .5) return;
      setState(() => _resultHeaderHeight = measured);
    });
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= ZhViewport.wide;
    const toolbarHeight = 64.0;
    final topInset = ZhTopBar.bodyTopInset(
      context,
      toolbarHeight: toolbarHeight,
    );
    _syncResultHeaderHeight();
    final resultHeaderHeight = _resultHeaderHeight > 0
        ? _resultHeaderHeight
        : topInset + 114;
    return Scaffold(
      // The query field stays visible at the top. Avoid shrinking and laying
      // out a potentially image-heavy result list on every keyboard frame.
      resizeToAvoidBottomInset: false,
      backgroundColor: ZhPalette.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: desktop
                ? ZhResponsiveTwoPane(
                    primary: _buildPageView(
                      contentTopPadding: resultHeaderHeight,
                    ),
                    secondary: _SearchDesktopRail(
                      query: _submittedQuery,
                      tab: officialSearchTabs[_index],
                      selectedFilters: _selectedFilters,
                    ),
                  )
                : _buildPageView(contentTopPadding: resultHeaderHeight),
          ),
          // Keep the page-level fade above the fixed search header. The
          // toolbar itself is transparent, so this layer is the visible
          // blue-to-clear transition instead of a white rectangle painted by
          // the route background.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, .28, .68, 1],
                    colors: [
                      Color(0xD8D7E8FF),
                      Color(0x70EAF6FF),
                      Color(0x20F7FCFF),
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: KeyedSubtree(
                key: _headerKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: topInset),
                    ZhResponsiveFrame(
                      maxWidth: 1200,
                      desktopGutter: 24,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SearchField(
                              controller: _query,
                              focusNode: _queryFocus,
                              hintText: '搜索知乎内容',
                              compact: true,
                              inlineActions: false,
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
                    ),
                    ZhResponsiveFrame(
                      maxWidth: 1200,
                      desktopGutter: 24,
                      child: Padding(
                        // Keep the scope switcher as its own floating glass surface.
                        // It must not inherit a solid toolbar/background container.
                        padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                        child: SizedBox(
                          height: 46,
                          child: ZhLiquidGlassSegmentedTabs(
                            key: const ValueKey('search-scope-glass-tabs'),
                            labels: [
                              for (final tab in officialSearchTabs) tab.label,
                            ],
                            selectedIndex: _index,
                            semanticPrefix: '搜索范围 ',
                            scrollable: true,
                            onSelected: _switchToTab,
                            height: 46,
                          ),
                        ),
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
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
          // Keep the transparent navigation chrome in the same compositing
          // scene as the page. A Scaffold appBar is painted in a separate
          // slot, which prevents its backdrop from sampling this page's
          // scrolling surface on Android.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ZhTopBar(
              toolbarHeight: toolbarHeight,
              automaticallyImplyLeading: false,
              leading: ZhLiquidGlassIconButton(
                key: const ValueKey('search-results-back'),
                semanticLabel: '返回',
                onPressed: Navigator.of(context).pop,
                icon: const Icon(Icons.arrow_back_rounded),
                size: 44,
                iconSize: 22,
              ),
              actions: [_searchActions()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView({double contentTopPadding = 0}) => PageView.builder(
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
      contentTopPadding: contentTopPadding,
      filters: index == 0 ? Map.unmodifiable(_selectedFilters) : const {},
      onOpenRecent: _openRecentResults,
      onOpenType: _openResultType,
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
          Semantics(
            container: true,
            label: '${_groupLabel(group)}筛选',
            child: SizedBox(
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
                  final optionKey = option.linkName.isEmpty
                      ? 'all'
                      : option.linkName;
                  return Center(
                    child: Semantics(
                      button: true,
                      selected: active,
                      label: active ? '${option.title}，已选择' : option.title,
                      child: Material(
                        color: active ? ZhPalette.canvas : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        child: InkWell(
                          key: ValueKey(
                            'search-filter:${option.group}:$optionKey',
                          ),
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
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    ),
  );

  static String _groupLabel(List<SearchFilterOption> group) =>
      switch (group.firstOrNull?.group) {
        'vertical' => '内容类型',
        'sort' => '排序',
        'time_interval' => '时间范围',
        _ => '搜索',
      };
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
