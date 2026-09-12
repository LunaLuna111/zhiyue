part of '../api_views.dart';

typedef CommentLikeCallback = Future<bool> Function(bool liked);

class CommentIdentityContext {
  const CommentIdentityContext({
    this.contentAuthorIds = const <String>{},
    this.questionAuthorIds = const <String>{},
    this.rootCommentAuthorIds = const <String>{},
  });

  final Set<String> contentAuthorIds;
  final Set<String> questionAuthorIds;
  final Set<String> rootCommentAuthorIds;

  List<String> authorLabelsOf(Map<String, dynamic> value) {
    final object = unwrapObject(value);
    return _labelsFor(personIdentityKeys(object['author']));
  }

  List<String> replyAuthorLabelsOf(Map<String, dynamic> value) {
    final object = unwrapObject(value);
    return _labelsFor(
      personIdentityKeys(
        object['reply_to_author'] ??
            object['reply_author'] ??
            object['replyToAuthor'],
      ),
    );
  }

  List<String> _labelsFor(Set<String> identities) {
    if (identities.isEmpty) return const <String>[];
    final labels = <String>[];
    if (_overlaps(identities, contentAuthorIds)) labels.add('作者');
    if (_overlaps(identities, questionAuthorIds)) labels.add('题主');
    return List.unmodifiable(labels);
  }

  bool _overlaps(Set<String> left, Set<String> right) {
    if (left.isEmpty || right.isEmpty) return false;
    return left.any(right.contains);
  }
}

class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.value,
    this.api,
    this.onLink,
    this.onTap,
    this.onReply,
    this.onDelete,
    this.onLike,
    this.onAuthor,
    this.identityContext = const CommentIdentityContext(),
    this.inlineReplyAction = false,
    this.compact = false,
  });

  final Map<String, dynamic> value;
  final ZhihuApiClient? api;
  final CommentLinkTapCallback? onLink;
  final VoidCallback? onTap;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final CommentLikeCallback? onLike;
  final VoidCallback? onAuthor;
  final CommentIdentityContext identityContext;
  final bool inlineReplyAction;
  final bool compact;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late bool _liked;
  late int _likeCount;
  bool _likeBusy = false;

  @override
  void initState() {
    super.initState();
    _readReaction();
  }

  @override
  void didUpdateWidget(covariant CommentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (idOf(oldWidget.value) != idOf(widget.value)) _readReaction();
  }

  void _readReaction() {
    _liked = AnswerRelationship.from(widget.value).isUpvoted;
    _likeCount = ContentMetrics.from(widget.value).voteupCount ?? 0;
  }

  Future<void> _toggleLike() async {
    final callback = widget.onLike;
    if (callback == null || _likeBusy) return;
    final target = !_liked;
    setState(() => _likeBusy = true);
    var success = false;
    try {
      success = await callback(target);
    } catch (_) {
      success = false;
    }
    if (!mounted) return;
    setState(() {
      _likeBusy = false;
      if (!success) return;
      _liked = target;
      _likeCount = math.max(0, _likeCount + (target ? 1 : -1));
    });
    if (!success) {
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(const SnackBar(content: Text('评论操作失败，请稍后重试')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorName = authorNameOf(widget.value);
    final authorAvatar = authorAvatarOf(widget.value);
    final replyTarget = commentReplyTargetNameOf(widget.value);
    final content = commentContentOf(widget.value);
    final rawContent = commentRawContentOf(widget.value);
    final mediaUrls = contentImageUrlsOf(widget.value, limit: 6);
    final linkTags = commentLinkTagsOf(widget.value);
    final metrics = ContentMetrics.from(widget.value);
    final dateLabel = contentDateLabel(metrics);
    final object = unwrapObject(widget.value);
    final authorLabels = _mergeCommentIdentityLabels(
      _commentIdentityLabels(object['author_tag'] ?? object['authorTag']),
      widget.identityContext.authorLabelsOf(widget.value),
    );
    final replyAuthorLabels = _mergeCommentIdentityLabels(
      _commentIdentityLabels(
        object['reply_author_tag'] ?? object['replyAuthorTag'],
      ),
      widget.identityContext.replyAuthorLabelsOf(widget.value),
    );
    final commentTags = _commentFooterLabels(
      object['comment_tag'] ?? object['commentTag'],
    );
    final disliked = object['disliked'] == true;
    final avatarFallback = authorName.isEmpty
        ? '知'
        : authorName.characters.first;
    final canOpenReplies =
        widget.onTap != null && (metrics.replyCount ?? 0) > 0;
    final stableId = idOf(widget.value).trim().isNotEmpty
        ? idOf(widget.value).trim()
        : '${authorName.trim()}-${content.trim()}';
    if (widget.compact) {
      return KeyedSubtree(
        key: ValueKey('comment-card-$stableId'),
        child: _CompactCommentRow(
          authorName: authorName,
          authorAvatar: authorAvatar,
          avatarFallback: avatarFallback,
          authorLabels: authorLabels,
          replyTarget: replyTarget,
          replyAuthorLabels: replyAuthorLabels,
          content: content,
          rawContent: rawContent,
          mediaUrls: mediaUrls,
          linkTags: linkTags,
          api: widget.api,
          onLink: widget.onLink,
          metrics: metrics,
          likeCount: _likeCount,
          liked: _liked,
          likeBusy: _likeBusy,
          dateLabel: _compactCommentDateLabel(metrics),
          commentTags: commentTags,
          disliked: disliked,
          canOpenReplies: canOpenReplies,
          onTap: widget.onTap,
          onReply: widget.onReply,
          onDelete: widget.onDelete,
          onLike: widget.onLike == null ? null : _toggleLike,
          onAuthor: widget.onAuthor,
        ),
      );
    }
    return KeyedSubtree(
      key: ValueKey('comment-card-$stableId'),
      child: ZhSurface(
        onTap: canOpenReplies ? widget.onTap : null,
        margin: const EdgeInsets.symmetric(horizontal: ZhSpace.sm, vertical: 4),
        padding: const EdgeInsets.all(ZhSpace.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CommentAvatarTapTarget(
              authorName: authorName,
              onTap: widget.onAuthor,
              child: _CommentAvatar(
                imageUrl: authorAvatar,
                fallback: avatarFallback,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _CommentAuthorIdentityLine(
                          authorName: authorName,
                          labels: authorLabels,
                        ),
                      ),
                      if (widget.inlineReplyAction && widget.onReply != null)
                        _InlineReplyButton(onPressed: widget.onReply!),
                      if (canOpenReplies)
                        const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                  if (replyTarget.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    _CommentReplyIdentityLine(
                      replyTarget: replyTarget,
                      labels: replyAuthorLabels,
                    ),
                  ],
                  const SizedBox(height: 7),
                  if (content.isNotEmpty || mediaUrls.isEmpty)
                    _commentBodyText(
                      context,
                      content: content,
                      rawContent: rawContent,
                      api: widget.api,
                      onLink: widget.onLink,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: ZhPalette.ink,
                      ),
                    ),
                  if (linkTags.isNotEmpty) ...[
                    if (content.isNotEmpty || mediaUrls.isNotEmpty)
                      const SizedBox(height: 8),
                    CommentLinkTagList(tags: linkTags, onLink: widget.onLink),
                  ],
                  if (mediaUrls.isNotEmpty) ...[
                    if (content.isNotEmpty) const SizedBox(height: 8),
                    _CommentMediaGallery(urls: mediaUrls),
                  ],
                  if (metrics.hasEngagement ||
                      widget.onLike != null ||
                      dateLabel.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 14,
                      runSpacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (metrics.voteupCount != null ||
                            widget.onLike != null)
                          _CardMetric(
                            icon: Icons.change_history_outlined,
                            label: compactCount(_likeCount),
                            semanticLabel: _liked
                                ? '取消赞同 ${compactCount(_likeCount)}'
                                : '赞同 ${compactCount(_likeCount)}',
                            selected: _liked,
                            onTap: _likeBusy ? null : _toggleLike,
                          ),
                        if ((metrics.replyCount ?? 0) > 0)
                          _CardMetric(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: '${metrics.replyCount} 条回复',
                            semanticLabel: '${metrics.replyCount} 条回复',
                          ),
                        if (dateLabel.isNotEmpty)
                          _CardMetric(
                            icon: Icons.schedule_rounded,
                            label: dateLabel,
                            semanticLabel: dateLabel,
                          ),
                      ],
                    ),
                  ],
                  if ((!widget.inlineReplyAction && widget.onReply != null) ||
                      widget.onDelete != null) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        if (!widget.inlineReplyAction && widget.onReply != null)
                          TextButton.icon(
                            onPressed: widget.onReply,
                            icon: const Icon(Icons.reply_rounded, size: 17),
                            label: const Text('回复'),
                          ),
                        if (widget.onDelete != null)
                          TextButton.icon(
                            onPressed: widget.onDelete,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 17,
                            ),
                            label: const Text('删除'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCommentRow extends StatelessWidget {
  const _CompactCommentRow({
    required this.authorName,
    required this.authorAvatar,
    required this.avatarFallback,
    required this.authorLabels,
    required this.replyTarget,
    required this.replyAuthorLabels,
    required this.content,
    required this.rawContent,
    required this.mediaUrls,
    required this.linkTags,
    required this.api,
    required this.onLink,
    required this.metrics,
    required this.likeCount,
    required this.liked,
    required this.likeBusy,
    required this.dateLabel,
    required this.commentTags,
    required this.disliked,
    required this.canOpenReplies,
    required this.onTap,
    required this.onReply,
    required this.onDelete,
    required this.onLike,
    required this.onAuthor,
  });

  final String authorName;
  final String authorAvatar;
  final String avatarFallback;
  final List<String> authorLabels;
  final String replyTarget;
  final List<String> replyAuthorLabels;
  final String content;
  final String rawContent;
  final List<String> mediaUrls;
  final List<CommentLinkTag> linkTags;
  final ZhihuApiClient? api;
  final CommentLinkTapCallback? onLink;
  final ContentMetrics metrics;
  final int likeCount;
  final bool liked;
  final bool likeBusy;
  final String dateLabel;
  final List<String> commentTags;
  final bool disliked;
  final bool canOpenReplies;
  final VoidCallback? onTap;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onLike;
  final VoidCallback? onAuthor;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: canOpenReplies ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CommentAvatarTapTarget(
              authorName: authorName,
              onTap: onAuthor,
              child: _CommentAvatar(
                imageUrl: authorAvatar,
                fallback: avatarFallback,
                radius: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CompactCommentIdentityLine(
                          authorName: authorName,
                          authorLabels: authorLabels,
                          replyTarget: replyTarget,
                          replyAuthorLabels: replyAuthorLabels,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CompactCommentMenu(onReply: onReply, onDelete: onDelete),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (content.isNotEmpty || mediaUrls.isEmpty)
                    _commentBodyText(
                      context,
                      content: content,
                      rawContent: rawContent,
                      api: api,
                      onLink: onLink,
                      style: const TextStyle(
                        color: Color(0xFF191B1F),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  if (linkTags.isNotEmpty) ...[
                    if (content.isNotEmpty || mediaUrls.isNotEmpty)
                      const SizedBox(height: 7),
                    CommentLinkTagList(tags: linkTags, onLink: onLink),
                  ],
                  if (mediaUrls.isNotEmpty) ...[
                    if (content.isNotEmpty) const SizedBox(height: 7),
                    _CommentMediaGallery(urls: mediaUrls),
                  ],
                  if (dateLabel.isNotEmpty ||
                      commentTags.isNotEmpty ||
                      onReply != null ||
                      metrics.voteupCount != null ||
                      onLike != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _CompactCommentMetadata(
                            dateLabel: dateLabel,
                            labels: commentTags,
                            onReply: onReply,
                          ),
                        ),
                        if (metrics.voteupCount != null || onLike != null) ...[
                          _CompactCommentReaction(
                            icon: liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            label: likeCount > 0 ? compactCount(likeCount) : '',
                            semanticLabel: liked
                                ? '取消点赞 ${compactCount(likeCount)}'
                                : '点赞 ${compactCount(likeCount)}',
                            selected: liked,
                            onTap: likeBusy ? null : onLike,
                          ),
                          const SizedBox(width: 16),
                        ],
                        _CompactCommentReaction(
                          icon: disliked
                              ? Icons.heart_broken_rounded
                              : Icons.heart_broken_outlined,
                          semanticLabel: '踩',
                          selected: disliked,
                        ),
                      ],
                    ),
                  ],
                  if ((metrics.replyCount ?? 0) > 0 && canOpenReplies) ...[
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          '查看全部 ${compactCount(metrics.replyCount!)} 条回复',
                          style: const TextStyle(
                            color: Color(0xFF175199),
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _commentBodyText(
  BuildContext context, {
  required String content,
  required String rawContent,
  required ZhihuApiClient? api,
  required CommentLinkTapCallback? onLink,
  required TextStyle? style,
}) {
  final fallback = content.isEmpty ? '该评论没有可显示的文字内容' : content;
  final rich =
      rawContent.contains('<a') ||
      extractCommentLinkUrls(rawContent).isNotEmpty;
  // A plain `[表情]` token still needs the remote catalog when the API is
  // available. The old branch bypassed that catalog and made the same row
  // alternate between an image and literal bracket text after refresh.
  if (!rich && api == null) {
    return CommentEmoticonText(text: fallback, style: style);
  }
  return CommentRichText(
    text: rawContent.isEmpty ? fallback : rawContent,
    api: api,
    onLink: onLink,
    style: style,
  );
}

/// Native comments render `link_tag` as a compact horizontal card below the
/// text. It is deliberately separate from the inline URL span because the
/// endpoint may return a title/icon even when the comment body has no URL.
class CommentLinkTagList extends StatelessWidget {
  const CommentLinkTagList({super.key, required this.tags, this.onLink});

  final List<CommentLinkTag> tags;
  final CommentLinkTapCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final groupTitle = tags.first.groupTitle.trim();
    final groupIcon = tags.first.groupIconUrl.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groupTitle.isNotEmpty || groupIcon.isNotEmpty) ...[
          SizedBox(
            height: 24,
            child: Row(
              children: [
                if (groupIcon.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: ZhihuImage.network(
                      groupIcon,
                      headers: zhihuImageRequestHeaders,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      cacheWidth: 80,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (groupTitle.isNotEmpty)
                  Flexible(
                    child: Text(
                      groupTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF44474D),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tags.length,
            separatorBuilder: (_, _) => const SizedBox(width: 7),
            itemBuilder: (context, index) {
              final tag = tags[index];
              final child = Container(
                constraints: const BoxConstraints(maxWidth: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F8),
                  border: Border.all(color: const Color(0xFFE5E7EA)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tag.iconUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: ZhihuImage.network(
                          tag.iconUrl,
                          headers: zhihuImageRequestHeaders,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          cacheWidth: 80,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        tag.displayText.isEmpty ? '打开链接' : tag.displayText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF175199),
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 17,
                      color: Color(0xFF9196A1),
                    ),
                  ],
                ),
              );
              return Semantics(
                button: onLink != null,
                label: tag.displayText,
                child: onLink == null
                    ? child
                    : InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => onLink!(tag.url, tag.displayText),
                        child: child,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InlineReplyButton extends StatelessWidget {
  const _InlineReplyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      minimumSize: const Size(44, 30),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: const Text('回复'),
  );
}

class _CommentAvatarTapTarget extends StatelessWidget {
  const _CommentAvatarTapTarget({
    required this.authorName,
    required this.onTap,
    required this.child,
  });

  final String authorName;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final callback = onTap;
    if (callback == null) return child;
    return Semantics(
      button: true,
      label: '查看${authorName.isEmpty ? '知乎用户' : authorName}的主页',
      child: InkResponse(
        onTap: callback,
        radius: 20,
        customBorder: const CircleBorder(),
        child: child,
      ),
    );
  }
}

class _CommentAvatar extends StatelessWidget {
  const _CommentAvatar({
    required this.imageUrl,
    required this.fallback,
    this.radius = 20,
  });

  final String imageUrl;
  final String fallback;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = CircleAvatar(
      radius: radius,
      backgroundColor: ZhPalette.ink,
      foregroundColor: ZhPalette.background,
      child: Text(
        fallback,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
    if (imageUrl.isEmpty) return placeholder;
    return ClipOval(
      child: ZhihuImage.network(
        imageUrl,
        headers: zhihuImageRequestHeaders,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        cacheWidth: 120,
        cacheHeight: 120,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}
