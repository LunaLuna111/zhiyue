part of '../content_pages.dart';

class CommentRepliesPage extends StatefulWidget {
  const CommentRepliesPage({
    super.key,
    required this.api,
    required this.commentId,
    this.contentType = '',
    this.contentId = '',
    this.rootComment,
    this.rootAuthorName = '',
    this.contentAuthorIds = const <String>{},
    this.questionAuthorIds = const <String>{},
    this.submitComment,
    this.onCommentCountChanged,
  });

  final ZhihuApiClient api;
  final String commentId;
  final String contentType;
  final String contentId;
  final Map<String, dynamic>? rootComment;
  final String rootAuthorName;
  final Set<String> contentAuthorIds;
  final Set<String> questionAuthorIds;
  final CommentSubmitter? submitComment;
  final ValueChanged<int>? onCommentCountChanged;

  @override
  State<CommentRepliesPage> createState() => _CommentRepliesPageState();
}

class _CommentRepliesPageState extends State<CommentRepliesPage> {
  int _revision = 0;
  Map<String, dynamic>? _rootComment;

  @override
  void initState() {
    super.initState();
    _rootComment = widget.rootComment;
  }

  @override
  void didUpdateWidget(covariant CommentRepliesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentId != widget.commentId) {
      _rootComment = widget.rootComment;
    }
  }

  CommentIdentityContext get _identityContext => CommentIdentityContext(
    contentAuthorIds: widget.contentAuthorIds,
    questionAuthorIds: widget.questionAuthorIds,
    rootCommentAuthorIds: personIdentityKeys(
      _rootComment == null ? null : unwrapObject(_rootComment!)['author'],
    ),
  );

  Future<ApiResponse> _loadInitial() async {
    final response = await widget.api.getUri(
      widget.api.commentRepliesInitialUri(widget.commentId),
    );
    final root = response.isSuccess
        ? _contentMap(response.jsonMap?['root'])
        : null;
    if (root != null && mounted) setState(() => _rootComment = root);
    return response;
  }

  List<Map<String, dynamic>> _replyRows(Object? value) {
    final rootId = _rootComment == null
        ? widget.commentId
        : idOf(_rootComment!);
    return extractRows(
      value,
    ).where((row) => rootId.isEmpty || idOf(row) != rootId).toList();
  }

  void _openCommentAuthor(Map<String, dynamic> value) {
    final object = unwrapObject(value);
    final author = _contentMap(object['author']);
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

  Future<void> _reply(
    String commentId,
    String authorName, {
    String targetUserId = '',
    String rootCommentId = '',
    CommentReplyTarget? target,
    bool showEmoticons = false,
  }) async {
    final resolvedTarget =
        target ??
        CommentReplyTarget(
          contentType: widget.contentType,
          contentId: widget.contentId,
          rootCommentId: rootCommentId.isEmpty
              ? widget.commentId
              : rootCommentId,
          replyCommentId: commentId,
          targetUserId: targetUserId,
          targetUserName: authorName,
          source: 'comment-replies',
        );
    final created = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      requestFocus: !showEmoticons,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentComposerSheet(
        api: widget.api,
        replyTarget: resolvedTarget,
        title:
            '回复${resolvedTarget.targetUserName.isEmpty ? '这条评论' : ' @${resolvedTarget.targetUserName}'}',
        initialShowEmoticons: showEmoticons,
        onSubmit: (value) async {
          final response = widget.submitComment == null
              ? await widget.api.createComment(
                  contentType: widget.contentType,
                  contentId: widget.contentId,
                  content: value.text,
                  replyCommentId: resolvedTarget.replyCommentId,
                  sticker: value.sticker,
                  imageUrl: value.image?.url,
                )
              : await widget.submitComment!(value, resolvedTarget);
          return response.isSuccess ? null : _mutationError(response);
        },
      ),
    );
    if (!mounted || created != true) return;
    widget.onCommentCountChanged?.call(1);
    setState(() => _revision++);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('回复已发布。')));
  }

  Future<void> _delete(Map<String, dynamic> value) async {
    final id = idOf(value);
    if (id.isEmpty || !widget.api.canWrite) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除回复？'),
        content: const Text('删除后不可恢复。'),
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
      setState(() => _revision++);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('回复已删除。')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiFailure.from(error).userMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final root = _rootComment;
    final identityContext = _identityContext;
    final rootName = root == null ? widget.rootAuthorName : authorNameOf(root);
    return PagedListPage(
      key: ValueKey('comment-replies-${widget.commentId}-$_revision'),
      title: '评论回复',
      titleWidget: Text(
        '评论回复',
        style: TextStyle(
          color: ZhPalette.ink,
          fontSize: 17,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      centerTitle: true,
      toolbarHeight: 52,
      api: widget.api,
      header: root == null
          ? null
          : Container(
              key: const Key('comment-replies-root'),
              color: ZhPalette.background,
              child: Column(
                children: [
                  CommentCard(
                    value: root,
                    api: widget.api,
                    onLink: _openCommentLink,
                    identityContext: identityContext,
                    onAuthor: () => _openCommentAuthor(root),
                    onLike: widget.api.canWrite
                        ? (liked) async => (await widget.api.setCommentLiked(
                            idOf(root),
                            liked: liked,
                          )).isSuccess
                        : null,
                    onReply: () => _reply(
                      idOf(root),
                      authorNameOf(root),
                      target: _commentReplyTargetForValue(
                        value: root,
                        contentType: widget.contentType,
                        contentId: widget.contentId,
                        rootCommentId: widget.commentId,
                      ),
                    ),
                    compact: true,
                  ),
                  SizedBox(
                    height: 10,
                    child: ColoredBox(color: ZhPalette.softSurface),
                  ),
                ],
              ),
            ),
      responseHeaderBuilder: (context, response) => commentReplySummaryHeader(
        response,
        fallbackTotal: root == null
            ? null
            : ContentMetrics.from(root).replyCount,
      ),
      pinResponseHeader: true,
      bottomNavigationBar: _OfficialCommentEditorBar(
        enabled: true,
        title: '发布你的回复',
        onTap: () => _reply(
          widget.commentId,
          rootName,
          target: root == null
              ? CommentReplyTarget(
                  contentType: widget.contentType,
                  contentId: widget.contentId,
                  rootCommentId: widget.commentId,
                  replyCommentId: widget.commentId,
                  targetUserName: rootName,
                  source: 'comment-replies',
                )
              : _commentReplyTargetForValue(
                  value: root,
                  contentType: widget.contentType,
                  contentId: widget.contentId,
                  rootCommentId: widget.commentId,
                ),
        ),
        onEmoticon: () => _reply(
          widget.commentId,
          rootName,
          target: root == null
              ? CommentReplyTarget(
                  contentType: widget.contentType,
                  contentId: widget.contentId,
                  rootCommentId: widget.commentId,
                  replyCommentId: widget.commentId,
                  targetUserName: rootName,
                  source: 'comment-replies',
                )
              : _commentReplyTargetForValue(
                  value: root,
                  contentType: widget.contentType,
                  contentId: widget.contentId,
                  rootCommentId: widget.commentId,
                ),
          showEmoticons: true,
        ),
      ),
      loadInitial: _loadInitial,
      rowsExtractor: _replyRows,
      commentListMode: true,
      emptyMessage: '还没有回复',
      rowBuilder: (context, value, onTap) => CommentCard(
        value: value,
        api: widget.api,
        onLink: _openCommentLink,
        onTap: onTap,
        identityContext: identityContext,
        onAuthor: () => _reply(
          idOf(value),
          authorNameOf(value),
          target: _commentReplyTargetForValue(
            value: value,
            contentType: widget.contentType,
            contentId: widget.contentId,
            rootCommentId: widget.commentId,
          ),
        ),
        onLike: widget.api.canWrite
            ? (liked) async => (await widget.api.setCommentLiked(
                idOf(value),
                liked: liked,
              )).isSuccess
            : null,
        onReply: () => _reply(
          idOf(value),
          authorNameOf(value),
          target: _commentReplyTargetForValue(
            value: value,
            contentType: widget.contentType,
            contentId: widget.contentId,
            rootCommentId: widget.commentId,
          ),
        ),
        onDelete: widget.api.canWrite && _objectAllowsDelete(value)
            ? () => _delete(value)
            : null,
        compact: true,
      ),
    );
  }
}

Widget commentReplySummaryHeader(
  Map<String, dynamic> response, {
  int? fallbackTotal,
}) {
  final total = _commentTotalCountOf(response) ?? fallbackTotal;
  return Container(
    key: const Key('comment-reply-summary'),
    height: 48,
    alignment: Alignment.centerLeft,
    color: ZhPalette.background,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      total == null ? '回复' : '回复 ${compactCount(total)}',
      style: TextStyle(
        color: ZhPalette.ink,
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _OfficialCommentEditorBar extends StatelessWidget {
  const _OfficialCommentEditorBar({
    required this.enabled,
    required this.onTap,
    required this.onEmoticon,
    this.title = '理性发言，友善互动',
  });

  final bool enabled;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onEmoticon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    key: const Key('official-comment-editor-bar'),
    decoration: BoxDecoration(color: ZhPalette.background),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Material(
        color: enabled ? ZhPalette.softSurface : ZhPalette.canvas,
        shape: const StadiumBorder(),
        elevation: 0,
        child: InkWell(
          key: const Key('comment-editor-entry'),
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(32),
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: ZhPalette.softBorder,
                    child: Icon(
                      Icons.person_rounded,
                      size: 23,
                      color: ZhPalette.mutedInk,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      enabled ? title : '暂时无法发表评论',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ZhPalette.mutedInk,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _EditorBarAction(
                    label: '图片',
                    icon: Icons.image_outlined,
                    onTap: enabled ? onTap : null,
                  ),
                  _EditorBarAction(
                    label: 'GIF',
                    gif: true,
                    onTap: enabled ? onEmoticon : null,
                  ),
                  _EditorBarAction(
                    label: '展开编辑器',
                    icon: Icons.open_in_full_rounded,
                    onTap: enabled ? onTap : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _EditorBarAction extends StatelessWidget {
  const _EditorBarAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.gif = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool gif;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    enabled: onTap != null,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 58,
        child: Center(
          child: gif
              ? Container(
                  width: 30,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: ZhPalette.mutedInk, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'GIF',
                    style: TextStyle(
                      color: ZhPalette.mutedInk,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : Icon(icon, size: 26, color: ZhPalette.mutedInk),
        ),
      ),
    ),
  );
}
