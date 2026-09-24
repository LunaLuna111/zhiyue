part of '../search_page.dart';

class SearchTabSpec {
  const SearchTabSpec(this.type, this.label);

  final String type;
  final String label;
}

enum _SearchMenuAction {
  clearHistory,
  toggleHotSearch,
  refreshHotSearch,
  toggleSearchHistory,
}

/// Search scope labels and their corresponding request `t` values.
const officialSearchTabs = <SearchTabSpec>[
  SearchTabSpec('general', '综合'),
  SearchTabSpec('recent', '实时'),
  SearchTabSpec('people', '用户'),
  SearchTabSpec('km_general', '小说'),
  SearchTabSpec('scholar', '论文'),
  SearchTabSpec('zvideo', '视频'),
  SearchTabSpec('topic', '话题'),
  SearchTabSpec('column', '专栏'),
  SearchTabSpec('publication', '知识'),
  SearchTabSpec('pin', '想法'),
  SearchTabSpec('ring', '圈子'),
  SearchTabSpec('podcast', '播客'),
];

class SearchFilterOption {
  const SearchFilterOption({
    required this.group,
    required this.title,
    required this.linkName,
  });

  final String group;
  final String title;
  final String linkName;
}

class _SearchHotCacheEntry {
  List<SearchHotItem> items = const [];
  DateTime expiresAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime emptyUntil = DateTime.fromMillisecondsSinceEpoch(0);
  Future<List<SearchHotItem>>? request;
}

/// Built-in fallback for the public `GET /search/customize` response. The
/// live response remains the source of truth when the configuration request
/// succeeds.
const officialSearchFilterGroups = <List<SearchFilterOption>>[
  [
    SearchFilterOption(group: 'vertical', title: '不限类型', linkName: ''),
    SearchFilterOption(group: 'vertical', title: '只看回答', linkName: 'answer'),
    SearchFilterOption(group: 'vertical', title: '只看文章', linkName: 'article'),
    SearchFilterOption(group: 'vertical', title: '只看视频', linkName: 'zvideo'),
  ],
  [
    SearchFilterOption(group: 'sort', title: '综合排序', linkName: ''),
    SearchFilterOption(group: 'sort', title: '最多赞同', linkName: 'upvoted_count'),
    SearchFilterOption(group: 'sort', title: '最新发布', linkName: 'created_time'),
  ],
  [
    SearchFilterOption(group: 'time_interval', title: '不限时间', linkName: ''),
    SearchFilterOption(group: 'time_interval', title: '一天内', linkName: 'a_day'),
    SearchFilterOption(
      group: 'time_interval',
      title: '一周内',
      linkName: 'a_week',
    ),
    SearchFilterOption(
      group: 'time_interval',
      title: '一月内',
      linkName: 'a_month',
    ),
    SearchFilterOption(
      group: 'time_interval',
      title: '三月内',
      linkName: 'three_months',
    ),
    SearchFilterOption(
      group: 'time_interval',
      title: '半年内',
      linkName: 'half_a_year',
    ),
    SearchFilterOption(
      group: 'time_interval',
      title: '一年内',
      linkName: 'a_year',
    ),
  ],
];

List<List<SearchFilterOption>> parseSearchFilterGroups(Object? value) {
  final data = value is Map<String, dynamic> ? value['data'] : null;
  if (data is! List) return const [];
  final groups = <List<SearchFilterOption>>[];
  for (final rawGroup in data) {
    if (rawGroup is! List) continue;
    final options = <SearchFilterOption>[];
    for (final rawOption in rawGroup) {
      if (rawOption is! Map) continue;
      final option = rawOption.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final group = plainText(option['group']);
      final title = plainText(option['title']);
      final linkName = plainText(option['link_name']);
      if (!const {'vertical', 'sort', 'time_interval'}.contains(group) ||
          title.isEmpty ||
          (linkName.isNotEmpty && !RegExp(r'^[a-z_]+$').hasMatch(linkName))) {
        continue;
      }
      options.add(
        SearchFilterOption(group: group, title: title, linkName: linkName),
      );
    }
    if (options.length >= 2 &&
        options.every((item) => item.group == options.first.group)) {
      groups.add(List.unmodifiable(options));
    }
  }
  return List.unmodifiable(groups);
}

// Keep the native tuple when the installed API package does not add it yet;
// newer package releases are detected and left untouched.
const _searchVerticalInfo = '0,0,0,0,0,0,0,0,0,0,0,0';

Uri ensureSearchVerticalInfo(Uri uri, Map<String, String> filters) {
  final vertical = filters['vertical']?.trim() ?? '';
  if (vertical.isEmpty || uri.queryParameters.containsKey('vertical_info')) {
    return uri;
  }
  final encodedVertical = Uri.encodeComponent(vertical);
  final encodedInfo = Uri.encodeComponent(_searchVerticalInfo);
  final raw = uri.toString();
  for (final marker in [
    '&vertical=$encodedVertical',
    '?vertical=$encodedVertical',
  ]) {
    final start = raw.indexOf(marker);
    if (start < 0) continue;
    final end = start + marker.length;
    return Uri.parse(
      '${raw.substring(0, end)}&vertical_info=$encodedInfo${raw.substring(end)}',
    );
  }
  return Uri.parse('$raw&vertical_info=$encodedInfo');
}

class SearchHotItem {
  const SearchHotItem({
    required this.query,
    required this.displayQuery,
    required this.heatScore,
    this.hotShow = '',
  });

  final String query;
  final String displayQuery;
  final int heatScore;
  final String hotShow;
}

/// Supports both the current `top_search.words` payload and the older
/// `hot_search_queries` list used by the reference client.
List<SearchHotItem> parseSearchHotItems(Object? value, {int limit = 15}) {
  if (limit <= 0 || value is! Map) return const [];
  final root = value.map((key, item) => MapEntry(key.toString(), item));
  final topSearch = root['top_search'] ?? root['topSearch'];
  final words = topSearch is Map
      ? topSearch['words'] ?? topSearch['items']
      : null;
  final data = root['data'];
  final nestedDataItems = data is Map
      ? data['words'] ?? data['hot_search_queries'] ?? data['items']
      : null;
  final rawItems = words is List
      ? words
      : root['hot_search_queries'] is List
      ? root['hot_search_queries'] as List
      : nestedDataItems is List
      ? nestedDataItems
      : root['data'] is List
      ? root['data'] as List
      : const <Object?>[];
  final result = <SearchHotItem>[];
  final seen = <String>{};
  for (final raw in rawItems) {
    if (raw is! Map) continue;
    final item = raw.map((key, item) => MapEntry(key.toString(), item));
    final query = plainText(item['query'] ?? item['display_query']);
    if (query.isEmpty || !seen.add(query.toLowerCase())) continue;
    final displayQuery = plainText(item['display_query'] ?? query);
    final hotShow = plainText(
      item['hot_show'] ?? item['hotShow'] ?? item['display_hot'],
    );
    final scoreValue =
        item['heat_score'] ?? item['heatScore'] ?? item['hot_score'];
    final heatScore = scoreValue is num
        ? scoreValue.toInt()
        : int.tryParse(plainText(scoreValue)) ?? 0;
    result.add(
      SearchHotItem(
        query: query,
        displayQuery: displayQuery.isEmpty ? query : displayQuery,
        heatScore: heatScore < 0 ? 0 : heatScore,
        hotShow: hotShow,
      ),
    );
    if (result.length >= limit) break;
  }
  return List.unmodifiable(result);
}

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.api,
    this.focusOnOpen = false,
    this.controller,
    this.onBack,
  });

  final ZhihuApiClient api;
  final bool focusOnOpen;
  final SearchPageController? controller;
  final VoidCallback? onBack;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  static final Expando<_SearchHotCacheEntry> _hotCaches =
      Expando<_SearchHotCacheEntry>();

  final _query = TextEditingController();
  final _queryFocus = FocusNode();
  late final _SearchSuggestionController _suggestions;
  final _hotSearchItems = <SearchHotItem>[];
  bool _hotSearchLoading = true;
  int _hotSearchGeneration = 0;
  String _type = 'general';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _suggestions = _SearchSuggestionController(widget.api);
    _queryFocus.addListener(_onQueryFocusChanged);
    widget.controller?.addListener(_onControllerActivated);
    widget.api.session.addListener(_onSessionChanged);
    if (widget.api.session.showSearchHotSearch) {
      unawaited(_loadHotSearch());
    } else {
      _hotSearchLoading = false;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerActivated);
    widget.api.session.removeListener(_onSessionChanged);
    _queryFocus.removeListener(_onQueryFocusChanged);
    _suggestions.dispose();
    _query.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  void _onControllerActivated() {
    if (!mounted ||
        !widget.api.session.focusSearchOnOpen ||
        _query.text.trim().isNotEmpty) {
      return;
    }
    // The search page is kept alive inside the home IndexedStack. Wait for
    // the navigation selection to settle before requesting focus so the IME
    // does not animate while the old page is still being hit-tested.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !widget.api.session.focusSearchOnOpen ||
          _query.text.trim().isNotEmpty) {
        return;
      }
      _queryFocus.requestFocus();
    });
  }

  void _onQueryChanged(String value) {
    _suggestions.onQueryChanged(value);
    // The history section is part of this state object rather than the
    // TextField. Rebuild it with the field so it disappears as soon as the
    // user starts composing a query and returns when the query is cleared.
    if (mounted) setState(() {});
  }

  void _onQueryFocusChanged() {
    if (!_queryFocus.hasFocus) _suggestions.dismiss();
  }

  void _onSessionChanged() {
    if (!mounted) return;
    if (!widget.api.session.showSearchHotSearch) {
      // A request may still be in flight after the user hides hot search.
      // Advance the generation so its response cannot repopulate a hidden
      // section or turn the loading indicator back on.
      _hotSearchGeneration++;
      _hotSearchLoading = false;
    } else if (widget.api.session.showSearchHotSearch &&
        !_hotSearchLoading &&
        _hotSearchItems.isEmpty) {
      unawaited(_loadHotSearch());
    }
    setState(() {});
  }

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.maybePop();
      return;
    }
    widget.onBack?.call();
  }

  Future<void> _handleSearchMenuAction(_SearchMenuAction action) async {
    final session = widget.api.session;
    switch (action) {
      case _SearchMenuAction.clearHistory:
        await session.clearSearchHistory();
      case _SearchMenuAction.toggleHotSearch:
        await session.setShowSearchHotSearch(!session.showSearchHotSearch);
      case _SearchMenuAction.refreshHotSearch:
        if (session.showSearchHotSearch) _refreshHotSearch();
      case _SearchMenuAction.toggleSearchHistory:
        await session.setRememberSearchHistory(!session.rememberSearchHistory);
    }
  }

  void _clearQuery() {
    if (_query.text.isEmpty) return;
    _query.clear();
    _onQueryChanged('');
    _queryFocus.requestFocus();
  }

  Widget _searchActions() {
    final session = widget.api.session;
    return ZhLiquidGlassCapsuleMenuActionGroup<_SearchMenuAction>(
      key: const ValueKey('search-menu'),
      primaryAction: ZhLiquidGlassCapsuleAction(
        icon: const Tooltip(
          message: '搜索',
          child: Icon(
            Icons.arrow_forward_rounded,
            key: ValueKey('search-submit'),
          ),
        ),
        semanticLabel: '搜索',
        onPressed: () => _submit(),
      ),
      additionalActions: _query.text.trim().isEmpty
          ? const <ZhLiquidGlassCapsuleAction>[]
          : [
              ZhLiquidGlassCapsuleAction(
                icon: const Icon(
                  Icons.clear_rounded,
                  key: ValueKey('search-clear'),
                ),
                semanticLabel: '清除搜索内容',
                onPressed: _clearQuery,
              ),
            ],
      menuIcon: const Icon(Icons.more_vert_rounded),
      menuSemanticLabel: '搜索选项',
      onSelected: (action) => unawaited(_handleSearchMenuAction(action)),
      menuItems: [
        ZhLiquidGlassMenuItem<_SearchMenuAction>(
          value: _SearchMenuAction.clearHistory,
          label: '清空历史记录',
          icon: const Icon(Icons.delete_sweep_outlined),
          enabled: session.searchHistory.isNotEmpty,
        ),
        ZhLiquidGlassMenuItem<_SearchMenuAction>(
          value: _SearchMenuAction.toggleHotSearch,
          label: session.showSearchHotSearch ? '关闭热搜显示' : '开启热搜显示',
          icon: Icon(
            session.showSearchHotSearch
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        ZhLiquidGlassMenuItem<_SearchMenuAction>(
          value: _SearchMenuAction.refreshHotSearch,
          label: '刷新热搜',
          icon: const Icon(Icons.refresh_rounded),
          enabled: session.showSearchHotSearch,
        ),
        ZhLiquidGlassMenuItem<_SearchMenuAction>(
          value: _SearchMenuAction.toggleSearchHistory,
          label: session.rememberSearchHistory ? '关闭历史搜索记录' : '开启历史搜索记录',
          icon: Icon(
            session.rememberSearchHistory
                ? Icons.history_toggle_off_rounded
                : Icons.history_rounded,
          ),
        ),
      ],
    );
  }

  Future<List<SearchHotItem>> _requestHotSearch() async {
    final response = await widget.api.publicWebGet('/api/v4/search/hot_search');
    if (!response.isSuccess) throw response.failure;
    return parseSearchHotItems(response.json);
  }

  Future<void> _loadHotSearch({bool force = false}) async {
    final generation = ++_hotSearchGeneration;
    final cache = _hotCaches[widget.api] ??= _SearchHotCacheEntry();
    final now = DateTime.now();
    if (!force && cache.items.isNotEmpty && cache.expiresAt.isAfter(now)) {
      if (!mounted || generation != _hotSearchGeneration) return;
      setState(() {
        _hotSearchItems
          ..clear()
          ..addAll(cache.items);
        _hotSearchLoading = false;
      });
      return;
    }
    if (!force && cache.emptyUntil.isAfter(now)) {
      if (mounted && generation == _hotSearchGeneration) {
        setState(() {
          _hotSearchItems
            ..clear()
            ..addAll(cache.items);
          _hotSearchLoading = false;
        });
      }
      return;
    }
    if (mounted && !_hotSearchLoading) {
      setState(() => _hotSearchLoading = true);
    }
    final request = cache.request ??= _requestHotSearch();
    try {
      final items = await request;
      if (items.isNotEmpty) {
        cache.items = List.unmodifiable(items);
        cache.expiresAt = DateTime.now().add(const Duration(minutes: 5));
        cache.emptyUntil = DateTime.fromMillisecondsSinceEpoch(0);
      } else {
        cache.emptyUntil = DateTime.now().add(const Duration(seconds: 8));
      }
      if (!mounted || generation != _hotSearchGeneration) return;
      setState(() {
        // A temporary empty/invalid response must not erase useful stale
        // hot-search rows already visible in the page.
        final visible = items.isNotEmpty ? items : cache.items;
        _hotSearchItems
          ..clear()
          ..addAll(visible);
        _hotSearchLoading = false;
      });
    } catch (_) {
      cache.emptyUntil = DateTime.now().add(const Duration(seconds: 8));
      if (mounted && generation == _hotSearchGeneration) {
        // Keep the previous list on refresh failure; the page remains useful
        // and the refresh button provides a bounded retry path.
        setState(() => _hotSearchLoading = false);
      }
    } finally {
      if (identical(cache.request, request)) cache.request = null;
    }
  }

  void _refreshHotSearch() {
    if (_hotSearchLoading) return;
    setState(() => _hotSearchLoading = true);
    unawaited(_loadHotSearch(force: true));
  }

  void _submit([String? query]) {
    final text = (query ?? _query.text).trim();
    if (text.isEmpty) {
      _queryFocus.requestFocus();
      return;
    }
    _query.text = text;
    _suggestions.dismiss();
    _queryFocus.unfocus();
    widget.api.session.rememberSearch(text);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          api: widget.api,
          initialQuery: text,
          initialType: _type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final topInset = ZhTopBar.bodyTopInset(context, toolbarHeight: 72);
    final queryEmpty = _query.text.trim().isEmpty;
    final historyVisible =
        queryEmpty && widget.api.session.rememberSearchHistory;
    final hotVisible =
        queryEmpty &&
        widget.api.session.showSearchHotSearch &&
        (_hotSearchLoading || _hotSearchItems.isNotEmpty);
    return Scaffold(
      // Let the keyboard cover the lower history area instead of repeatedly
      // relaying out the entire search surface during the IME animation.
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: ZhTopBar(
        leading: ZhLiquidGlassIconButton(
          key: const ValueKey('search-back'),
          semanticLabel: '返回',
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back_rounded),
          size: 46,
          iconSize: 24,
        ),
        title: Text(
          '搜索',
          style: TextStyle(
            color: ZhPalette.ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        actions: [_searchActions()],
        toolbarHeight: 72,
      ),
      body: ZhResponsiveFrame(
        maxWidth: 1040,
        desktopGutter: 24,
        child: AnimatedBuilder(
          animation: widget.api.session,
          builder: (context, _) => ListView(
            padding: EdgeInsets.fromLTRB(
              ZhSpace.md,
              topInset + ZhSpace.xs,
              ZhSpace.md,
              112,
            ),
            children: [
              _SearchField(
                controller: _query,
                focusNode: _queryFocus,
                autofocus:
                    widget.focusOnOpen && widget.api.session.focusSearchOnOpen,
                hintText: '搜索知乎内容',
                inlineActions: false,
                onChanged: _onQueryChanged,
                onSubmitted: _submit,
              ),
              _SearchSuggestionPanel(
                controller: _suggestions,
                onSelected: _submit,
              ),
              if (!queryEmpty) ...[
                const SizedBox(height: 20),
                _SectionHeading(title: '搜索范围', trailing: '左右滑动查看更多'),
                const SizedBox(height: 10),
                SizedBox(
                  height: _SearchChoice.rowHeight(context),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 12),
                    itemCount: officialSearchTabs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tab = officialSearchTabs[index];
                      return _SearchChoice(
                        label: tab.label,
                        selected: tab.type == _type,
                        onTap: () => setState(() => _type = tab.type),
                      );
                    },
                  ),
                ),
              ],
              if (historyVisible) ...[
                const SizedBox(height: 26),
                const _SectionHeading(title: '历史搜索'),
                const SizedBox(height: ZhSpace.sm),
                if (widget.api.session.searchHistory.isEmpty)
                  const _EmptyHistory()
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in widget.api.session.searchHistory)
                        ActionChip(
                          label: Text(item),
                          onPressed: () => _submit(item),
                          backgroundColor: ZhPalette.canvas,
                          side: BorderSide(color: ZhPalette.border),
                          shape: const StadiumBorder(),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          labelStyle: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
              ],
              if (hotVisible) ...[
                const SizedBox(height: 26),
                _SearchHotSection(
                  items: _hotSearchItems,
                  loading: _hotSearchLoading,
                  onSelected: _submit,
                ),
              ],
              if (queryEmpty && !historyVisible && !hotVisible) ...[
                const SizedBox(height: 26),
                const _EmptySearchPrompt(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
