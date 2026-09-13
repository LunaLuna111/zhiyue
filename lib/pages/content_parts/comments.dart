part of '../content_pages.dart';

typedef CommentRootLoader =
    Future<ApiResponse> Function(String orderBy, String commentType);
typedef CommentSubmitter =
    Future<ApiResponse> Function(
      CommentComposerValue value,
      CommentReplyTarget target,
    );

CommentReplyTarget _commentReplyTargetForValue({
  required Map<String, dynamic> value,
  required String contentType,
  required String contentId,
  String rootCommentId = '',
}) {
  final object = unwrapObject(value);
  final author = _contentMap(object['author']);
  return CommentReplyTarget(
    contentType: contentType,
    contentId: contentId,
    rootCommentId: rootCommentId.isEmpty ? idOf(value) : rootCommentId,
    replyCommentId: idOf(value),
    targetUserId: personMemberIdOf(author),
    targetUserName: authorNameOf(value),
  );
}

int? _commentTotalCountOf(Object? value) {
  final root = _contentMap(value);
  final counts = _contentMap(root?['counts']);
  final paging = _contentMap(root?['paging']);
  int? headerTotal;
  final headers = root?['header'];
  if (headers is List) {
    for (final item in headers) {
      final header = _contentMap(item);
      final type = plainText(header?['type']).toLowerCase();
      if (!const {'', 'all', 'root'}.contains(type)) continue;
      final count = header?['count'];
      headerTotal = count is num
          ? count.round()
          : int.tryParse(plainText(count));
      if (headerTotal != null) break;
    }
  }
  for (final candidate in [
    counts?['total_counts'],
    counts?['total'],
    root?['total_counts'],
    root?['total'],
    paging?['totals'],
    headerTotal,
  ]) {
    if (candidate is num) return candidate.round();
    final parsed = int.tryParse(plainText(candidate));
    if (parsed != null) return parsed;
  }
  return null;
}

class CommentThreadController {
  _CommentThreadViewState? _state;

  void compose() => _state?._compose();
}

class CommentsPage extends StatelessWidget {
  const CommentsPage({
    super.key,
    required this.api,
    required this.contentType,
    required this.contentId,
    this.contentAuthorIds = const <String>{},
    this.questionAuthorIds = const <String>{},
    this.fallbackCount,
    this.onCommentCountChanged,
    this.sheetMode = false,
    this.initialCommentType = '',
    this.contextQuote = '',
  });

  final ZhihuApiClient api;
  final String contentType;
  final String contentId;
  final Set<String> contentAuthorIds;
  final Set<String> questionAuthorIds;
  final int? fallbackCount;
  final ValueChanged<int>? onCommentCountChanged;
  final bool sheetMode;
  final String initialCommentType;
  final String contextQuote;

  @override
  Widget build(BuildContext context) {
    Widget page() => CommentThreadView(
      api: api,
      title: '评论',
      contentType: contentType,
      contentId: contentId,
      contentAuthorIds: contentAuthorIds,
      questionAuthorIds: questionAuthorIds,
      fallbackCount: fallbackCount,
      sheetMode: sheetMode,
      initialCommentType: initialCommentType,
      contextQuote: contextQuote,
      loadInitial: (orderBy, commentType) => api.getUri(
        api.commentsInitialUri(
          contentType: contentType,
          contentId: contentId,
          orderBy: orderBy,
          type: commentType,
        ),
      ),
      loadContextHeader: () => api.getUri(
        api.commentListHeadersUri(
          contentType: contentType,
          contentId: contentId,
        ),
      ),
      submitComment: (value, target) => api.createComment(
        contentType: contentType,
        contentId: contentId,
        content: value.text,
        replyCommentId: target.replyCommentId,
        sticker: value.sticker,
        imageUrl: value.image?.url,
      ),
      onCommentCountChanged: onCommentCountChanged,
    );
    if (!sheetMode) return page();
    return Navigator(
      onGenerateRoute: (_) => PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => page(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

Future<void> showOfficialCommentsSheet(
  BuildContext context, {
  required ZhihuApiClient api,
  required String contentType,
  required String contentId,
  Set<String> contentAuthorIds = const <String>{},
  Set<String> questionAuthorIds = const <String>{},
  int? fallbackCount,
  ValueChanged<int>? onCommentCountChanged,
  String initialCommentType = '',
  String contextQuote = '',
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: false,
  showDragHandle: false,
  backgroundColor: Colors.transparent,
  barrierColor: const Color(0x88000000),
  builder: (_) => FractionallySizedBox(
    // The official comment panel covers the content card behind it instead of
    // leaving a large recommendation strip exposed above the sheet.
    heightFactor: .84,
    alignment: Alignment.bottomCenter,
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: CommentsPage(
        api: api,
        contentType: contentType,
        contentId: contentId,
        contentAuthorIds: contentAuthorIds,
        questionAuthorIds: questionAuthorIds,
        fallbackCount: fallbackCount,
        onCommentCountChanged: onCommentCountChanged,
        sheetMode: true,
        initialCommentType: initialCommentType,
        contextQuote: contextQuote,
      ),
    ),
  ),
);

class CommentThreadView extends StatefulWidget {
  const CommentThreadView({
    super.key,
    required this.api,
    required this.title,
    required this.contentType,
    required this.contentId,
    required this.loadInitial,
    this.loadContextHeader,
    this.submitComment,
    this.onCommentCountChanged,
    this.controller,
    this.contentAuthorIds = const <String>{},
    this.questionAuthorIds = const <String>{},
    this.embedded = false,
    this.showSort = true,
    this.sheetMode = false,
    this.fallbackCount,
    this.emptyMessage = '还没有评论',
    this.initialCommentType = '',
    this.contextQuote = '',
  });

  final ZhihuApiClient api;
  final String title;
  final String contentType;
  final String contentId;
  final CommentRootLoader loadInitial;
  final Future<ApiResponse> Function()? loadContextHeader;
  final CommentSubmitter? submitComment;
  final ValueChanged<int>? onCommentCountChanged;
  final CommentThreadController? controller;
  final Set<String> contentAuthorIds;
  final Set<String> questionAuthorIds;
  final bool embedded;
  final bool showSort;
  final bool sheetMode;
  final int? fallbackCount;
  final String emptyMessage;
  final String initialCommentType;
  final String contextQuote;

  @override
  State<CommentThreadView> createState() => _CommentThreadViewState();
}

class _CommentThreadViewState extends State<CommentThreadView> {
  Map<String, dynamic>? _listHeaders;
  Object? _listHeadersError;
  String _orderBy = 'score';
  String _commentType = '';
  int _revision = 0;
  int? _totalCount;
  bool? _contentAuthorFollowingOverride;
  bool _contentAuthorFollowBusy = false;

  @override
  void initState() {
    super.initState();
    _commentType = widget.initialCommentType;
    _totalCount = widget.fallbackCount;
    widget.controller?._state = this;
    if (widget.loadContextHeader != null) _loadListHeaders();
  }

  @override
  void didUpdateWidget(covariant CommentThreadView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._state == this) {
        oldWidget.controller?._state = null;
      }
      widget.controller?._state = this;
    }
    if (oldWidget.fallbackCount != widget.fallbackCount &&
        _totalCount == oldWidget.fallbackCount) {
      _totalCount = widget.fallbackCount;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    super.dispose();
  }

  Future<void> _loadListHeaders() async {
    setState(() => _listHeadersError = null);
    try {
      final response = await widget.loadContextHeader!();
      if (!mounted) return;
      setState(() {
        if (response.isSuccess && response.jsonMap != null) {
          _listHeaders = response.jsonMap;
        } else {
          _listHeadersError = response;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _listHeadersError = error);
    }
  }

  void _openContentAuthor() {
    final author = commentContentAuthorOf(_listHeaders);
    if (author == null) return;
    final memberId = personMemberIdOf(author);
    if (memberId.isEmpty) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) =>
            UserProfileDetailPage(api: widget.api, memberId: memberId),
      ),
    );
  }

  void _openCommentLink(String url, String title) {
    openCommentLink(context, widget.api, url, title: title);
  }

  Future<void> _followContentAuthor() async {
    if (_contentAuthorFollowBusy) return;
    final author = commentContentAuthorOf(_listHeaders);
    final wrapper = commentContentAuthorWrapperOf(_listHeaders);
    final memberId = personMemberIdOf(author);
    if (author == null || memberId.isEmpty) return;
    if (!widget.api.canWrite) {
      _showWriteSessionRequired(context);
      return;
    }
    final following =
        _contentAuthorFollowingOverride ??
        wrapper?['is_following'] == true || author['is_following'] == true;
    if (following) return;
    setState(() => _contentAuthorFollowBusy = true);
    try {
      final response = await widget.api.setUserFollowing(
        memberId,
        following: true,
      );
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      setState(() {
        _contentAuthorFollowingOverride = true;
        if (wrapper != null) wrapper['is_following'] = true;
        author['is_following'] = true;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(ApiFailure.from(error).userMessage)),
        );
    } finally {
      if (mounted) setState(() => _contentAuthorFollowBusy = false);
    }
  }

  Future<void> _compose({
    CommentReplyTarget? target,
    String replyCommentId = '',
    String replyName = '',
    String replyUserId = '',
    String rootCommentId = '',
    bool showEmoticons = false,
  }) async {
    if (widget.submitComment == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('暂时无法发表评论')));
      return;
    }
    final resolvedTarget =
        target ??
        CommentReplyTarget(
          contentType: widget.contentType,
          contentId: widget.contentId,
          rootCommentId: rootCommentId.isEmpty ? replyCommentId : rootCommentId,
          replyCommentId: replyCommentId,
          targetUserId: replyUserId,
          targetUserName: replyName,
        );
    final created = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      // The editor switches from the IME to its own emoji panel after the
      // toolbar pointer goes down. If this route remains draggable, the
      // bottom-sheet recognizer interprets the layout movement caused by the
      // retiring IME as a downward drag and dismisses the editor instead of
      // letting the pending panel state finish.
      enableDrag: false,
      // While the IME is being replaced, the editor surface moves with the
      // insets. The original pointer can therefore finish outside the moved
      // surface; a dismissible barrier would treat that finish as an outside
      // tap and pop the editor before the emoji panel is shown. Back still
      // dismisses the route, while toolbar transitions remain stable.
      isDismissible: false,
      showDragHandle: false,
      requestFocus: !showEmoticons,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentComposerSheet(
        api: widget.api,
        replyTarget: resolvedTarget,
        title: resolvedTarget.isReply
            ? '回复${resolvedTarget.targetUserName.isEmpty ? '这条评论' : ' @${resolvedTarget.targetUserName}'}'
            : '写评论',
        initialShowEmoticons: showEmoticons,
        onSubmit: (value) async {
          final response = await widget.submitComment!(value, resolvedTarget);
          return response.isSuccess ? null : _mutationError(response);
        },
      ),
    );
    if (!mounted || created != true) return;
    widget.onCommentCountChanged?.call(1);
    setState(() {
      final current = _totalCount ?? widget.fallbackCount;
      if (current != null) _totalCount = current + 1;
      _revision++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resolvedTarget.isReply ? '回复已发布。' : '评论已发布。'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _delete(Map<String, dynamic> value) async {
    final id = idOf(value);
    if (id.isEmpty || !widget.api.canWrite) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除评论？'),
        content: const Text('该评论及其当前展示关系将从列表中移除。'),
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
    if (confirmed != true || !mounted) return;
    try {
      final response = await widget.api.deleteComment(id);
      if (!mounted) return;
      if (!response.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_mutationError(response))));
        return;
      }
      widget.onCommentCountChanged?.call(-1);
      setState(() {
        final current = _totalCount ?? widget.fallbackCount;
        if (current != null) _totalCount = math.max(0, current - 1);
        _revision++;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('评论已删除。')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiFailure.from(error).userMessage)),
        );
      }
    }
  }

  CommentIdentityContext get _identityContext {
    final contentAuthor = commentContentAuthorOf(_listHeaders);
    return CommentIdentityContext(
      contentAuthorIds: <String>{
        ...widget.contentAuthorIds,
        ...personIdentityKeys(contentAuthor),
      },
      questionAuthorIds: widget.questionAuthorIds,
    );
  }

  Future<ApiResponse> _loadComments() async {
    final response = await widget.loadInitial(_orderBy, _commentType);
    final total = response.isSuccess
        ? _commentTotalCountOf(response.jsonMap)
        : null;
    if (mounted && total != null && total != _totalCount) {
      setState(() => _totalCount = total);
    }
    return response;
  }

  String get _resolvedTitle => widget.initialCommentType == 'segment'
      ? '句子评论'
      : widget.embedded
      ? widget.title
      : '全部评论';

  Widget? get _resolvedTitleWidget {
    if (widget.embedded) return null;
    if (widget.initialCommentType == 'segment') {
      return const Text(
        '句子评论',
        style: TextStyle(
          color: Color(0xFF191B1F),
          fontSize: 17,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    // The discussion recommendation is content metadata, not the title of
    // the comment panel. Keeping it in the toolbar made the sheet look like
    // a second feed header and pushed the author card down unnecessarily.
    return const Text(
      '全部评论',
      style: TextStyle(
        color: Color(0xFF191B1F),
        fontSize: 17,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final identityContext = _identityContext;
    final author = commentContentAuthorOf(_listHeaders);
    final authorWrapper = commentContentAuthorWrapperOf(_listHeaders);
    final authorFollowing =
        _contentAuthorFollowingOverride ??
        authorWrapper?['is_following'] == true ||
            author?['is_following'] == true;
    return PagedListPage(
      key: ValueKey(
        'comments-${widget.contentType}-${widget.contentId}-'
        '$_commentType-$_orderBy-$_revision',
      ),
      title: _resolvedTitle,
      titleWidget: _resolvedTitleWidget,
      centerTitle: true,
      toolbarHeight: 52,
      api: widget.api,
      embedded: widget.embedded,
      actions: widget.sheetMode
          ? [
              IconButton(
                key: const Key('comments-close-action'),
                tooltip: '关闭',
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).maybePop(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: Color(0xFF9196A1),
                ),
              ),
            ]
          : null,
      header: widget.loadContextHeader == null && widget.contextQuote.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.contextQuote.isNotEmpty)
                  _SentenceCommentQuote(text: widget.contextQuote),
                if (widget.loadContextHeader != null)
                  CommentContextHeader(
                    response: _listHeaders,
                    loading: _listHeaders == null && _listHeadersError == null,
                    error: _listHeadersError,
                    onAuthor: _openContentAuthor,
                    following: authorFollowing,
                    followBusy: _contentAuthorFollowBusy,
                    onFollow: _followContentAuthor,
                  ),
              ],
            ),
      responseHeaderBuilder: widget.showSort
          ? (context, response) => commentListSummaryHeader(
              context,
              response,
              fallbackTotal: widget.fallbackCount,
              selectedType: _commentType,
              selectedOrder: _orderBy,
              onTypeChanged: (type) {
                if (type == _commentType) return;
                setState(() {
                  _commentType = type;
                  _orderBy = 'score';
                  _revision++;
                });
              },
              onOrderChanged: (order) {
                if (order == _orderBy) return;
                setState(() {
                  _orderBy = order;
                  _revision++;
                });
              },
            )
          : null,
      pinResponseHeader: widget.showSort,
      bottomNavigationBar: _OfficialCommentEditorBar(
        enabled: true,
        onTap: _compose,
        onEmoticon: () => _compose(showEmoticons: true),
      ),
      loadInitial: _loadComments,
      commentListMode: true,
      emptyMessage: widget.emptyMessage,
      rowBuilder: (context, value, onTap) => CommentCard(
        value: value,
        api: widget.api,
        onLink: _openCommentLink,
        identityContext: identityContext,
        onAuthor: () => _compose(
          target: _commentReplyTargetForValue(
            value: value,
            contentType: widget.contentType,
            contentId: widget.contentId,
          ),
        ),
        onTap: onTap,
        onLike: widget.api.canWrite
            ? (liked) async => (await widget.api.setCommentLiked(
                idOf(value),
                liked: liked,
              )).isSuccess
            : null,
        onReply: () => _compose(
          target: _commentReplyTargetForValue(
            value: value,
            contentType: widget.contentType,
            contentId: widget.contentId,
          ),
        ),
        onDelete: widget.api.canWrite && _objectAllowsDelete(value)
            ? () => _delete(value)
            : null,
        compact: true,
      ),
      onObjectTap: (context, value) {
        final id = idOf(value);
        if (id.isEmpty) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CommentRepliesPage(
              api: widget.api,
              commentId: id,
              contentType: widget.contentType,
              contentId: widget.contentId,
              rootComment: value,
              rootAuthorName: authorNameOf(value),
              contentAuthorIds: identityContext.contentAuthorIds,
              questionAuthorIds: identityContext.questionAuthorIds,
              submitComment: widget.submitComment,
              onCommentCountChanged: widget.onCommentCountChanged,
            ),
          ),
        );
      },
    );
  }
}

Map<String, dynamic>? _contentMap(Object? value) {
  if (value is! Map) return null;
  return value.map((key, value) => MapEntry(key.toString(), value));
}

Map<String, dynamic>? commentContentAuthorOf(Map<String, dynamic>? response) {
  final wrapper = commentContentAuthorWrapperOf(response);
  if (wrapper == null) return null;
  return _contentMap(wrapper['content_author']) ?? wrapper;
}

Map<String, dynamic>? commentContentAuthorWrapperOf(
  Map<String, dynamic>? response,
) {
  if (response == null) return null;
  return _contentMap(response['content_author']);
}

String _commentHeaderTag(Object? value) {
  if (value is Iterable) {
    for (final item in value) {
      final label = _commentHeaderTag(item);
      if (label.isNotEmpty) return label;
    }
    return '';
  }
  final map = _contentMap(value);
  return plainText(map?['text'] ?? map?['name'] ?? value);
}
