part of '../content_pages.dart';

/// The official mobile client keeps the first selection affordance focused on
/// the two actions people use most often.  The platform menu remains available
/// behind “更多”, which also preserves Android's share/read-aloud extensions
/// without letting those actions crowd the initial toolbar.
class _ZhihuSelectionToolbar extends StatefulWidget {
  const _ZhihuSelectionToolbar({
    required this.state,
    this.onCommentSelection,
    this.selectionContext = const ContentSelectionContext(),
    this.segmentIdsForRange,
  });

  final EditableTextState state;
  final ValueChanged<ContentSelection>? onCommentSelection;
  final ContentSelectionContext selectionContext;
  final List<String> Function(int start, int end)? segmentIdsForRange;

  @override
  State<_ZhihuSelectionToolbar> createState() => _ZhihuSelectionToolbarState();
}

class _ZhihuSelectionToolbarState extends State<_ZhihuSelectionToolbar> {
  var _showPlatformActions = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final selection = state.textEditingValue.selection;
    final selectedText = selection.isValid && !selection.isCollapsed
        ? selection.textInside(state.textEditingValue.text)
        : '';
    final items = _showPlatformActions
        ? state.contextMenuButtonItems
        : <ContextMenuButtonItem>[
            ContextMenuButtonItem(
              type: ContextMenuButtonType.custom,
              label: '复制',
              onPressed: () =>
                  state.copySelection(SelectionChangedCause.toolbar),
            ),
            if (widget.onCommentSelection != null)
              ContextMenuButtonItem(
                type: ContextMenuButtonType.custom,
                label: '评论这段话',
                onPressed: () {
                  final context = widget.selectionContext.withSegmentIds(
                    widget.segmentIdsForRange?.call(
                          selection.start,
                          selection.end,
                        ) ??
                        const <String>[],
                  );
                  ContextMenuController.removeAny();
                  state.hideToolbar();
                  widget.onCommentSelection!(
                    context.create(
                      quote: selectedText,
                      startOffset: selection.start,
                      endOffset: selection.end,
                    ),
                  );
                },
              ),
            ContextMenuButtonItem(
              type: ContextMenuButtonType.custom,
              label: '全选',
              onPressed: () => state.selectAll(SelectionChangedCause.toolbar),
            ),
            ContextMenuButtonItem(
              type: ContextMenuButtonType.custom,
              label: '更多',
              onPressed: () => setState(() => _showPlatformActions = true),
            ),
          ];
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: state.contextMenuAnchors,
      buttonItems: items,
    );
  }
}

class _ZhihuSelectableText extends StatefulWidget {
  const _ZhihuSelectableText(
    this.data, {
    super.key,
    this.style,
    this.linkUrl = '',
    this.onLink,
    this.onCommentSelection,
    this.selectionContext = const ContentSelectionContext(),
  });

  final String data;
  final TextStyle? style;
  final String linkUrl;
  final void Function(String url, String title)? onLink;
  final ValueChanged<ContentSelection>? onCommentSelection;
  final ContentSelectionContext selectionContext;

  @override
  State<_ZhihuSelectableText> createState() => _ZhihuSelectableTextState();
}

class _ZhihuSelectableTextState extends State<_ZhihuSelectableText> {
  TapGestureRecognizer? _recognizer;

  @override
  void dispose() {
    _recognizer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _recognizer?.dispose();
    _recognizer = widget.linkUrl.isEmpty || widget.onLink == null
        ? null
        : (TapGestureRecognizer()
            ..onTap = () => widget.onLink!(widget.linkUrl, widget.data));
    return SelectableText.rich(
      TextSpan(
        text: widget.data,
        style: widget.style?.merge(
          widget.linkUrl.isEmpty
              ? null
              : const TextStyle(color: Color(0xFF175199)),
        ),
        recognizer: _recognizer,
      ),
      contextMenuBuilder: (context, editableTextState) =>
          _ZhihuSelectionToolbar(
            state: editableTextState,
            onCommentSelection: widget.onCommentSelection,
            selectionContext: widget.selectionContext,
          ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({
    required this.imageUrl,
    required this.fallback,
    this.size = 46,
  });

  final String imageUrl;
  final String fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = CircleAvatar(
      radius: size / 2,
      backgroundColor: ZhPalette.ink,
      foregroundColor: ZhPalette.background,
      child: Text(
        fallback,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
    if (imageUrl.isEmpty) return placeholder;
    return ClipOval(
      child: ZhihuImage.network(
        imageUrl,
        headers: zhihuImageRequestHeaders,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 3).round(),
        cacheHeight: (size * 3).round(),
        frameBuilder: (_, child, frame, _) =>
            frame == null ? placeholder : child,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

class DetailEngagementBar extends StatefulWidget {
  const DetailEngagementBar({
    super.key,
    required this.metrics,
    required this.onComments,
    required this.onAction,
    this.onJumpToTop,
    this.onJumpToBottom,
    this.authorName = '',
    this.authorAvatar = '',
    this.authorFollowing = false,
    this.authorFollowBusy = false,
    this.onAuthor,
    this.onToggleAuthorFollowing,
    this.relationship = const AnswerRelationship(
      voting: '',
      isThanked: null,
      isFavorited: null,
      isAuthor: null,
      isFollowingAuthor: null,
    ),
    this.busyAction = '',
  });

  final ContentMetrics metrics;
  final VoidCallback onComments;
  final ValueChanged<String> onAction;
  final VoidCallback? onJumpToTop;
  final VoidCallback? onJumpToBottom;
  final String authorName;
  final String authorAvatar;
  final bool authorFollowing;
  final bool authorFollowBusy;
  final VoidCallback? onAuthor;
  final VoidCallback? onToggleAuthorFollowing;
  final AnswerRelationship relationship;
  final String busyAction;

  @override
  State<DetailEngagementBar> createState() => _DetailEngagementBarState();
}

class _DetailEngagementBarState extends State<DetailEngagementBar> {
  var _showMoreActions = false;

  void _toggleMoreActions() {
    if (!mounted) return;
    setState(() => _showMoreActions = !_showMoreActions);
  }

  List<ZhLiquidGlassActionItem> _engagementItems() => [
    ZhLiquidGlassActionItem(
      icon: Icon(
        Icons.change_history_outlined,
        color: widget.relationship.isUpvoted
            ? const Color(0xFF1677FF)
            : ZhPalette.ink,
      ),
      label: widget.metrics.voteupCount == null
          ? '赞同'
          : compactCount(widget.metrics.voteupCount!),
      semanticLabel: widget.metrics.voteupCount == null
          ? '赞同'
          : '赞同 ${compactCount(widget.metrics.voteupCount!)}',
      onPressed: widget.busyAction.isEmpty ? () => widget.onAction('赞同') : null,
    ),
    ZhLiquidGlassActionItem(
      icon: RotatedBox(
        quarterTurns: 2,
        child: Icon(
          Icons.change_history_outlined,
          color: widget.relationship.isDownvoted
              ? const Color(0xFF1677FF)
              : ZhPalette.ink,
        ),
      ),
      label: '反对',
      semanticLabel: widget.relationship.isDownvoted ? '已反对' : '反对',
      onPressed: widget.busyAction.isEmpty ? () => widget.onAction('反对') : null,
    ),
    ZhLiquidGlassActionItem(
      icon: const Icon(Icons.chat_bubble_outline_rounded),
      label: widget.metrics.commentCount == null
          ? '评论'
          : compactCount(widget.metrics.commentCount!),
      semanticLabel: widget.metrics.commentCount == null
          ? '查看评论'
          : '查看 ${compactCount(widget.metrics.commentCount!)} 条评论',
      onPressed: widget.onComments,
    ),
    ZhLiquidGlassActionItem(
      icon: Icon(
        Icons.star_border_rounded,
        color: widget.relationship.isFavorited == true
            ? const Color(0xFF1677FF)
            : ZhPalette.ink,
      ),
      label: widget.metrics.favoriteCount == null
          ? '收藏'
          : compactCount(widget.metrics.favoriteCount!),
      semanticLabel: widget.metrics.favoriteCount == null
          ? '收藏'
          : '收藏 ${compactCount(widget.metrics.favoriteCount!)}',
      onPressed: widget.busyAction.isEmpty ? () => widget.onAction('收藏') : null,
    ),
  ];

  List<ZhLiquidGlassActionItem> _moreItems() {
    final displayName = widget.authorName.trim().isEmpty
        ? '知乎用户'
        : widget.authorName.trim();
    final fallback = displayName.characters.first;
    return [
      ZhLiquidGlassActionItem(
        icon: _AuthorAvatar(
          imageUrl: widget.authorAvatar,
          fallback: fallback,
          size: 22,
        ),
        label: '作者',
        semanticLabel: '查看$displayName的个人主页',
        onPressed: widget.onAuthor,
      ),
      ZhLiquidGlassActionItem(
        icon: Icon(
          widget.authorFollowing ? Icons.check_rounded : Icons.add_rounded,
        ),
        label: widget.authorFollowing ? '已关注' : '关注',
        semanticLabel: widget.authorFollowing ? '取消关注作者' : '关注作者',
        onPressed: widget.authorFollowBusy
            ? null
            : widget.onToggleAuthorFollowing,
      ),
      ZhLiquidGlassActionItem(
        icon: const Icon(Icons.vertical_align_top_rounded),
        label: '顶部',
        semanticLabel: '回到帖子顶部',
        onPressed: widget.onJumpToTop,
      ),
      ZhLiquidGlassActionItem(
        icon: const Icon(Icons.vertical_align_bottom_rounded),
        label: '底部',
        semanticLabel: '跳到帖子底部',
        onPressed: widget.onJumpToBottom,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => ZhLiquidGlassFloatingActionBar(
    key: widget.key,
    items: _showMoreActions ? _moreItems() : _engagementItems(),
    transitionKey: _showMoreActions ? 'more' : 'engagement',
    trailing: ZhLiquidGlassIconButton(
      key: const ValueKey('content-detail-more-toggle'),
      icon: Icon(
        _showMoreActions ? Icons.close_rounded : Icons.more_vert_rounded,
      ),
      onPressed: _toggleMoreActions,
      semanticLabel: _showMoreActions ? '收起更多功能' : '更多功能',
      size: 64,
      iconSize: 26,
    ),
  );
}

String _mutationError(ApiResponse response) {
  return response.failure.userMessage;
}

bool _objectAllowsDelete(Map<String, dynamic> value) {
  final object = unwrapObject(value);
  return object['can_delete'] == true || object['canDelete'] == true;
}

void _showWriteSessionRequired(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('请先在“我”中登录。'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
