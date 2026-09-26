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

  String _count(List<String> keys, AppLocalizations l10n) {
    final value = accountProfileMetric(widget.profile, keys) ?? 0;
    return formatAccountProfileMetric(value, l10n);
  }

  List<(_CreationKind, String)> _categories(AppLocalizations l10n) => [
    (_CreationKind.all, l10n.creationAll),
    (
      _CreationKind.answers,
      l10n.creationAnswers(_count(const ['answer_count'], l10n)),
    ),
    (
      _CreationKind.pins,
      l10n.creationIdeas(_count(const ['pins_count', 'pin_count'], l10n)),
    ),
    (
      _CreationKind.articles,
      l10n.creationArticles(
        _count(const ['articles_count', 'article_count'], l10n),
      ),
    ),
    (
      _CreationKind.columns,
      l10n.creationColumns(
        _count(const ['columns_count', 'column_count'], l10n),
      ),
    ),
    (
      _CreationKind.questions,
      l10n.creationQuestions(
        _count(const ['question_count', 'questions_count'], l10n),
      ),
    ),
    (
      _CreationKind.videos,
      l10n.creationVideos(
        _count(const ['zvideo_count', 'video_count', 'videos_count'], l10n),
      ),
    ),
    (_CreationKind.more, l10n.creationMore),
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
          itemCount: _categories(context.zhL10n).length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = _categories(context.zhL10n)[index];
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
                  emptyMessage: context.zhL10n.creationEmpty,
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

  String _count(List<String> keys, AppLocalizations l10n) {
    final value = accountProfileMetric(profile, keys) ?? 0;
    return formatAccountProfileMetric(value, l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final rows = <(String, String, Uri, Map<String, String>?)>[
      (
        l10n.creationFavorites,
        _count(const ['favorite_count', 'collection_count'], l10n),
        api.userCollectionsInitialUri(memberId),
        null,
      ),
      (
        l10n.creationHighlights,
        _count(const ['marked_answer_count', 'marked_answers_count'], l10n),
        api.userMarkedAnswersInitialUri(urlToken),
        null,
      ),
      (
        l10n.creationFollowingColumns,
        _count(const [
          'following_column_count',
          'following_columns_count',
        ], l10n),
        api.userFollowingColumnsInitialUri(memberId),
        null,
      ),
      (
        l10n.creationFollowingTopics,
        _count(const ['following_topic_count', 'following_topics_count'], l10n),
        api.userFollowingTopicsInitialUri(memberId),
        null,
      ),
      (
        l10n.creationFollowingCollections,
        _count(const [
          'following_collection_count',
          'following_collections_count',
        ], l10n),
        api.userFollowingCollectionsInitialUri(memberId),
        null,
      ),
      (
        l10n.creationFollowingQuestions,
        _count(const [
          'following_question_count',
          'following_questions_count',
        ], l10n),
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
    final l10n = context.zhL10n;
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
              title: Text(l10n.activityShare),
              onTap: () => Navigator.of(context).pop(_ActivityMenuAction.share),
            ),
            if (canDelete) ...[
              const Divider(height: 1, indent: 20, endIndent: 20),
              ListTile(
                minTileHeight: 58,
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(l10n.activityDelete),
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
        ).showSnackBar(SnackBar(content: Text(l10n.activityLinkCopied)));
      }
      return false;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.activityDeleteTitle),
        content: Text(l10n.activityDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
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
      ).showSnackBar(SnackBar(content: Text(l10n.activityDeleted)));
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
