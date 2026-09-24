part of '../account_page.dart';

enum _CreationKind {
  all,
  answers,
  pins,
  articles,
  columns,
  questions,
  videos,
  more,
}

class _CreationTab extends StatefulWidget {
  const _CreationTab({
    required this.api,
    required this.memberId,
    required this.urlToken,
    required this.profile,
  });

  final ZhihuApiClient api;
  final String memberId;
  final String urlToken;
  final Map<String, dynamic> profile;

  @override
  State<_CreationTab> createState() => _CreationTabState();
}

class _CreationTabState extends State<_CreationTab> {
  var _selected = _CreationKind.all;

  Uri _initialUri() => switch (_selected) {
    _CreationKind.all => widget.api.userCreatedAllInitialUri(widget.memberId),
    _CreationKind.answers => widget.api.userCreatedAnswersInitialUri(
      widget.memberId,
    ),
    _CreationKind.pins => widget.api.userCreatedPinsInitialUri(widget.memberId),
    _CreationKind.articles => widget.api.userCreatedArticlesInitialUri(
      widget.memberId,
    ),
    _CreationKind.columns => widget.api.userCreatedColumnsInitialUri(
      widget.memberId,
    ),
    _CreationKind.questions => widget.api.userCreatedQuestionsInitialUri(
      widget.memberId,
    ),
    _CreationKind.videos => widget.api.userCreatedVideosInitialUri(
      widget.memberId,
    ),
    _CreationKind.more => throw StateError('更多分类不加载内容流'),
  };

  String _count(List<String> keys) {
    final value = accountProfileMetric(widget.profile, keys) ?? 0;
    return formatAccountProfileMetric(value);
  }

  List<(_CreationKind, String)> get _categories => [
    (_CreationKind.all, '全部'),
    (_CreationKind.answers, '回答 ${_count(const ['answer_count'])}'),
    (_CreationKind.pins, '想法 ${_count(const ['pins_count', 'pin_count'])}'),
    (
      _CreationKind.articles,
      '文章 ${_count(const ['articles_count', 'article_count'])}',
    ),
    (
      _CreationKind.columns,
      '专栏 ${_count(const ['columns_count', 'column_count'])}',
    ),
    (
      _CreationKind.questions,
      '提问 ${_count(const ['question_count', 'questions_count'])}',
    ),
    (
      _CreationKind.videos,
      '视频 ${_count(const ['zvideo_count', 'video_count', 'videos_count'])}',
    ),
    (_CreationKind.more, '更多'),
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 66,
        child: ListView.separated(
          key: const ValueKey('profile-creation-categories'),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final selected = _selected == category.$1;
            return ChoiceChip(
              key: ValueKey('profile-creation-${category.$1.name}'),
              label: Text(category.$2),
              selected: selected,
              showCheckmark: false,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              backgroundColor: ZhPalette.canvas,
              selectedColor: ZhPalette.pressed,
              labelStyle: TextStyle(
                color: selected ? ZhPalette.ink : ZhPalette.mutedInk,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) => setState(() => _selected = category.$1),
            );
          },
        ),
      ),
      Expanded(
        child: ZhResponsiveFrame(
          maxWidth: 1120,
          desktopGutter: 24,
          child: _selected == _CreationKind.more
              ? _CreationMoreList(
                  api: widget.api,
                  memberId: widget.memberId,
                  urlToken: widget.urlToken,
                  profile: widget.profile,
                )
              : PagedListPage(
                  key: ValueKey('profile-creation:${_selected.name}'),
                  title: '',
                  api: widget.api,
                  embedded: true,
                  loadInitial: () => widget.api.getUri(_initialUri()),
                  onObjectTap: (context, value) =>
                      openDetectedObject(context, widget.api, value),
                  emptyMessage: '还没有发布内容',
                ),
        ),
      ),
    ],
  );
}

class _CreationMoreList extends StatelessWidget {
  const _CreationMoreList({
    required this.api,
    required this.memberId,
    required this.urlToken,
    required this.profile,
  });

  final ZhihuApiClient api;
  final String memberId;
  final String urlToken;
  final Map<String, dynamic> profile;

  void _open(
    BuildContext context,
    String title,
    Uri uri, {
    Map<String, String>? headers,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PagedListPage(
          title: title,
          api: api,
          loadInitial: () => headers == null
              ? api.getUri(uri)
              : api.getUri(uri, headers: headers),
          onObjectTap: (context, value) =>
              openDetectedObject(context, api, value),
        ),
      ),
    );
  }

  String _count(List<String> keys) {
    final value = accountProfileMetric(profile, keys) ?? 0;
    return formatAccountProfileMetric(value);
  }

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, Uri, Map<String, String>?)>[
      (
        '我的收藏',
        _count(const ['favorite_count', 'collection_count']),
        api.userCollectionsInitialUri(memberId),
        const {'x-api-version': '3.0.94'},
      ),
      (
        '我的划线',
        _count(const ['marked_answer_count', 'marked_answers_count']),
        api.userMarkedAnswersInitialUri(urlToken),
        null,
      ),
      (
        '订阅的专栏',
        _count(const ['following_column_count', 'following_columns_count']),
        api.userFollowingColumnsInitialUri(memberId),
        null,
      ),
      (
        '关注的话题',
        _count(const ['following_topic_count', 'following_topics_count']),
        api.userFollowingTopicsInitialUri(memberId),
        null,
      ),
      (
        '关注的收藏夹',
        _count(const [
          'following_collection_count',
          'following_collections_count',
        ]),
        api.userFollowingCollectionsInitialUri(memberId),
        const {'x-api-version': '3.0.94'},
      ),
      (
        '关注的问题',
        _count(const ['following_question_count', 'following_questions_count']),
        api.userFollowingQuestionsInitialUri(memberId),
        null,
      ),
    ];
    return ListView.separated(
      key: const ValueKey('profile-creation-more-list'),
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        return ListTile(
          minTileHeight: 58,
          contentPadding: const EdgeInsets.symmetric(horizontal: 28),
          title: Text(row.$1),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(row.$2, style: TextStyle(color: ZhPalette.subtleInk)),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, color: ZhPalette.subtleInk),
            ],
          ),
          onTap: () => _open(context, row.$1, row.$3, headers: row.$4),
        );
      },
    );
  }
}

class _ProfileFeedTab extends StatelessWidget {
  const _ProfileFeedTab({
    super.key,
    required this.api,
    required this.loadInitial,
    required this.emptyMessage,
    this.activityMenu = false,
  });

  final ZhihuApiClient api;
  final Future<ApiResponse> Function() loadInitial;
  final String emptyMessage;
  final bool activityMenu;

  Future<bool> _showActivityMenu(
    BuildContext context,
    Map<String, dynamic> value,
  ) async {
    final brief = accountActivityBriefOf(value);
    final canDelete =
        api.canWrite && accountActivityCanDelete(value) && brief.isNotEmpty;
    final action = await showModalBottomSheet<_ActivityMenuAction>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              minTileHeight: 58,
              leading: const Icon(Icons.share_outlined),
              title: const Text('分享'),
              onTap: () => Navigator.of(context).pop(_ActivityMenuAction.share),
            ),
            if (canDelete) ...[
              const Divider(height: 1, indent: 20, endIndent: 20),
              ListTile(
                minTileHeight: 58,
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('删除此条动态'),
                onTap: () =>
                    Navigator.of(context).pop(_ActivityMenuAction.delete),
              ),
            ],
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return false;
    if (action == _ActivityMenuAction.share) {
      await Clipboard.setData(
        ClipboardData(text: accountActivityShareUrlOf(value)),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('链接已复制')));
      }
      return false;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除此条动态？'),
        content: const Text('删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return false;
    try {
      final response = await api.deleteActivity(brief);
      if (!context.mounted) return false;
      if (!response.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.failure.userMessage)));
        return false;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('动态已删除')));
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiFailure.from(error).userMessage)),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => ZhResponsiveFrame(
    maxWidth: 1120,
    desktopGutter: 24,
    child: PagedListPage(
      title: '',
      api: api,
      embedded: true,
      loadInitial: loadInitial,
      rowsExtractor: extractAccountProfileFeedRows,
      rowBuilder: (context, value, onTap) => ObjectCard(
        value: value,
        onTap: onTap,
        onAuthorTap: authorIdOf(value).isEmpty
            ? null
            : () => openContentAuthor(context, api, value),
        feedMode: true,
        compact: true,
        showImages: true,
        showMetrics: true,
      ),
      onObjectTap: (context, value) => openDetectedObject(context, api, value),
      onObjectLongPress: activityMenu ? _showActivityMenu : null,
      emptyMessage: emptyMessage,
    ),
  );
}
