part of '../search_page.dart';

class SearchTabSpec {
  const SearchTabSpec(this.type, this.label);

  final String type;
  final String label;
}

/// Values read from the official 11.4.0 `zhihu_search.room/search_tabs`
/// configuration. These are request `t` values, not UI-only guesses.
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

/// Public `GET /search/customize` response verified on 2026-08-20. The live
/// response remains the source of truth; this snapshot keeps the controls
/// usable if that non-content configuration request temporarily fails.
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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.api});

  final ZhihuApiClient api;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final _query = TextEditingController();
  final _queryFocus = FocusNode();
  final _question = TextEditingController();
  final _content = TextEditingController();
  final _column = TextEditingController();
  final Map<String, _SearchSuggestionCacheEntry> _suggestionCache = {};
  final Map<String, Future<List<zhihu_api.SearchSuggestion>>>
  _suggestionRequests = {};
  Timer? _suggestionDebounce;
  List<zhihu_api.SearchSuggestion> _suggestions = const [];
  String _suggestionsForQuery = '';
  bool _suggestionsLoading = false;
  int _suggestionGeneration = 0;
  String _type = 'general';
  String _contentType = 'answer';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _suggestionDebounce?.cancel();
    _query.dispose();
    _queryFocus.dispose();
    _question.dispose();
    _content.dispose();
    _column.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _suggestionDebounce?.cancel();
    final generation = ++_suggestionGeneration;
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestionsForQuery = '';
        _suggestions = const [];
        _suggestionsLoading = false;
      });
      return;
    }

    final cached = _suggestionCache[query];
    if (cached != null && cached.expiresAt.isAfter(DateTime.now())) {
      setState(() {
        _suggestionsForQuery = query;
        _suggestions = cached.items;
        _suggestionsLoading = false;
      });
      return;
    }
    if (cached != null) _suggestionCache.remove(query);

    setState(() {
      _suggestionsForQuery = query;
      _suggestions = const [];
      _suggestionsLoading = true;
    });
    _suggestionDebounce = Timer(const Duration(milliseconds: 280), () {
      _loadSearchSuggestions(query, generation);
    });
  }

  Future<void> _loadSearchSuggestions(String query, int generation) async {
    final request = _suggestionRequests.putIfAbsent(
      query,
      () => widget.api.fetchSearchSuggestions(keyword: query),
    );
    try {
      final List<zhihu_api.SearchSuggestion> items = List.unmodifiable(
        await request,
      );
      _rememberSearchSuggestions(query, items, const Duration(minutes: 5));
      if (!mounted || generation != _suggestionGeneration) return;
      setState(() {
        _suggestionsForQuery = query;
        _suggestions = items;
        _suggestionsLoading = false;
      });
    } catch (_) {
      // Keep the input usable when the public completion endpoint is blocked
      // or temporarily unavailable. A short empty cache prevents a request
      // on every rebuild while allowing a later retry.
      _rememberSearchSuggestions(
        query,
        const <zhihu_api.SearchSuggestion>[],
        const Duration(seconds: 8),
      );
      if (!mounted || generation != _suggestionGeneration) return;
      setState(() {
        _suggestionsForQuery = query;
        _suggestions = const [];
        _suggestionsLoading = false;
      });
    } finally {
      if (identical(_suggestionRequests[query], request)) {
        _suggestionRequests.remove(query);
      }
    }
  }

  void _rememberSearchSuggestions(
    String query,
    List<zhihu_api.SearchSuggestion> items,
    Duration ttl,
  ) {
    _suggestionCache[query] = _SearchSuggestionCacheEntry(
      items: items,
      expiresAt: DateTime.now().add(ttl),
    );
    while (_suggestionCache.length > 24) {
      _suggestionCache.remove(_suggestionCache.keys.first);
    }
  }

  void _submit([String? query]) {
    final text = (query ?? _query.text).trim();
    if (text.isEmpty) {
      _queryFocus.requestFocus();
      return;
    }
    _query.text = text;
    _suggestionDebounce?.cancel();
    _suggestionGeneration++;
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

  Future<void> _showTools() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    backgroundColor: ZhPalette.background,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            ZhSpace.md,
            0,
            ZhSpace.md,
            MediaQuery.viewInsetsOf(context).bottom + ZhSpace.md,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('直接打开', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  '通过 ID 或专栏 token 定位内容',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
                ),
                const SizedBox(height: ZhSpace.lg),
                _toolPanel(setModalState),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // Let the keyboard cover the lower history area instead of repeatedly
      // relaying out the entire search surface during the IME animation.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('搜索'),
        actions: [
          IconButton(
            tooltip: '通过 ID 直接打开',
            onPressed: _showTools,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: ZhResponsiveFrame(
        maxWidth: 1040,
        desktopGutter: 24,
        child: AnimatedBuilder(
          animation: widget.api.session,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(
              ZhSpace.md,
              ZhSpace.xs,
              ZhSpace.md,
              112,
            ),
            children: [
              _SearchField(
                controller: _query,
                focusNode: _queryFocus,
                autofocus: false,
                hintText: '搜索知乎内容',
                onChanged: _onQueryChanged,
                onSubmitted: _submit,
              ),
              _buildSearchSuggestionPanel(context),
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
              if (_query.text.trim().isEmpty) ...[
                const SizedBox(height: 26),
                _SectionHeading(
                  title: '历史搜索',
                  action: widget.api.session.searchHistory.isEmpty
                      ? null
                      : IconButton(
                          tooltip: '清空历史搜索',
                          visualDensity: VisualDensity.compact,
                          onPressed: widget.api.session.clearSearchHistory,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 21,
                          ),
                        ),
                ),
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
                          side: const BorderSide(color: ZhPalette.border),
                          shape: const StadiumBorder(),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          labelStyle: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolPanel(StateSetter setModalState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _ToolTitle(
        icon: Icons.description_outlined,
        title: '内容详情',
        description: '回答、文章、想法或视频',
      ),
      const SizedBox(height: ZhSpace.sm),
      Wrap(
        spacing: 8,
        children:
            const {'answer': '回答', 'article': '文章', 'pin': '想法', 'zvideo': '视频'}
                .entries
                .map(
                  (entry) => _SearchChoice(
                    label: entry.value,
                    selected: _contentType == entry.key,
                    onTap: () {
                      setState(() => _contentType = entry.key);
                      setModalState(() {});
                    },
                  ),
                )
                .toList(),
      ),
      const SizedBox(height: ZhSpace.sm),
      ShadInput(
        controller: _content,
        placeholder: const Text('输入内容 ID'),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => _openContent(),
        trailing: _InputAction(onPressed: _openContent),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: ZhSpace.md),
        child: Divider(height: 1),
      ),
      const _ToolTitle(
        icon: Icons.question_answer_outlined,
        title: '问题回答',
        description: '打开问题的回答列表',
      ),
      const SizedBox(height: ZhSpace.sm),
      ShadInput(
        controller: _question,
        placeholder: const Text('输入问题 ID'),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => _openQuestion(),
        trailing: _InputAction(onPressed: _openQuestion),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: ZhSpace.md),
        child: Divider(height: 1),
      ),
      const _ToolTitle(
        icon: Icons.view_column_outlined,
        title: '专栏文章',
        description: '通过专栏 token 打开文章列表',
      ),
      const SizedBox(height: ZhSpace.sm),
      ShadInput(
        controller: _column,
        placeholder: const Text('输入专栏 token'),
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => _openColumn(),
        trailing: _InputAction(onPressed: _openColumn),
      ),
    ],
  );

  void _openQuestion() {
    final id = _question.text.trim();
    if (!isDecimalContentId(id)) return _invalid('问题 ID 必须是 1–32 位数字');
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestionAnswersPage(api: widget.api, questionId: id),
      ),
    );
  }

  void _openColumn() {
    final token = _column.text.trim();
    if (!isColumnToken(token)) {
      return _invalid('专栏 token 只允许字母、数字、下划线和连字符');
    }
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ColumnArticlesPage(api: widget.api, columnToken: token),
      ),
    );
  }

  void _openContent() {
    final id = _content.text.trim();
    if (!isDecimalContentId(id)) return _invalid('内容 ID 必须是 1–32 位数字');
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _contentType == 'zvideo'
            ? ZVideoDetailPage(api: widget.api, videoId: id)
            : ContentDetailPage(
                api: widget.api,
                contentType: _contentType,
                contentId: id,
              ),
      ),
    );
  }

  void _invalid(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}
