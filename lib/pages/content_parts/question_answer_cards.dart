part of '../content_pages.dart';

class _QuestionAnswerRow extends StatelessWidget {
  const _QuestionAnswerRow({
    required this.value,
    this.onTap,
    this.onAuthorTap,
    this.onAction,
    this.onDelete,
  });

  final Map<String, dynamic> value;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final ValueChanged<ContentCardAction>? onAction;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final author = authorNameOf(value);
    final headline = authorHeadlineOf(value);
    final badges = authorBadgeLabelsOf(value);
    final avatar = authorAvatarOf(value);
    final excerpt = _answerListExcerpt(value);
    final images = contentImageUrlsOf(value, limit: 3);
    final metrics = ContentMetrics.from(value);
    final relationship = metrics.hasEngagement
        ? AnswerRelationship.from(value)
        : const AnswerRelationship(
            voting: '',
            isThanked: null,
            isFavorited: null,
            isAuthor: null,
            isFollowingAuthor: null,
          );
    final date = contentDateLabel(metrics);
    final avatarFallback = author.isEmpty ? '知' : author.characters.first;
    return Material(
      color: ZhPalette.background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 13),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ZhPalette.border, width: 0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _QuestionAnswerAuthorTapTarget(
                    value: value,
                    onTap: onAuthorTap,
                    child: _QuestionAnswerAvatar(
                      imageUrl: avatar,
                      fallback: avatarFallback,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                author.isEmpty ? '知乎用户' : author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0,
                                    ),
                              ),
                            ),
                            if (badges.isNotEmpty) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified_outlined,
                                size: 15,
                                color: ZhPalette.mutedInk,
                              ),
                            ],
                          ],
                        ),
                        if (headline.isNotEmpty || badges.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (badges.isNotEmpty) badges.first,
                              if (headline.isNotEmpty) headline,
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: ZhPalette.mutedInk,
                                  letterSpacing: 0,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: '删除回答',
                      visualDensity: VisualDensity.compact,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 19),
                    ),
                ],
              ),
              if (excerpt.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  excerpt,
                  maxLines: images.isEmpty ? 4 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    height: 1.58,
                    letterSpacing: 0,
                  ),
                ),
              ],
              if (images.isNotEmpty) ...[
                const SizedBox(height: 10),
                ContentImageStrip(urls: images),
              ],
              if (metrics.hasEngagement || date.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            if (metrics.voteupCount case final count?)
                              _QuestionAnswerMetric(
                                icon: Icons.change_history_outlined,
                                label: '${compactCount(count)} 赞同',
                                semanticLabel: '赞同 ${compactCount(count)}',
                                selected: relationship.isUpvoted,
                                showIcon: false,
                                onTap: onAction == null
                                    ? null
                                    : () => onAction!(ContentCardAction.vote),
                              ),
                            if (metrics.favoriteCount case final count?)
                              _QuestionAnswerMetric(
                                icon: Icons.star_border_rounded,
                                label: '${compactCount(count)} 收藏',
                                semanticLabel: '收藏 ${compactCount(count)}',
                                selected: relationship.isFavorited == true,
                                showIcon: false,
                                onTap: onAction == null
                                    ? null
                                    : () =>
                                          onAction!(ContentCardAction.favorite),
                              ),
                            if (metrics.commentCount case final count?)
                              _QuestionAnswerMetric(
                                icon: Icons.chat_bubble_outline_rounded,
                                label: '${compactCount(count)} 评论',
                                semanticLabel: '评论 ${compactCount(count)}',
                                showIcon: false,
                                onTap: onAction == null
                                    ? null
                                    : () =>
                                          onAction!(ContentCardAction.comments),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Text(
                        _shortAnswerDate(date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionAnswerAuthorTapTarget extends StatelessWidget {
  const _QuestionAnswerAuthorTapTarget({
    required this.value,
    required this.child,
    this.onTap,
  });

  final Map<String, dynamic> value;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    final author = authorNameOf(value);
    return Semantics(
      button: true,
      label: author.isEmpty ? '查看作者个人主页' : '查看$author的个人主页',
      child: InkResponse(
        key: ValueKey('content-author-avatar-${idOf(value)}'),
        onTap: onTap,
        radius: 24,
        customBorder: const CircleBorder(),
        child: child,
      ),
    );
  }
}

class _QuestionAnswerAvatar extends StatelessWidget {
  const _QuestionAnswerAvatar({required this.imageUrl, required this.fallback});

  final String imageUrl;
  final String fallback;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: SizedBox.square(
      dimension: 34,
      child: imageUrl.isEmpty
          ? _fallback(context)
          : ZhihuImage.network(
              imageUrl,
              headers: zhihuImageRequestHeaders,
              fit: BoxFit.cover,
              cacheWidth: 108,
              cacheHeight: 108,
              errorBuilder: (_, _, _) => _fallback(context),
            ),
    ),
  );

  Widget _fallback(BuildContext context) => ColoredBox(
    color: ZhPalette.canvas,
    child: Center(
      child: Text(fallback, style: Theme.of(context).textTheme.labelMedium),
    ),
  );
}

class _QuestionAnswerMetric extends StatelessWidget {
  const _QuestionAnswerMetric({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    this.onTap,
    this.selected = false,
    this.showIcon = true,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback? onTap;
  final bool selected;
  final bool showIcon;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: semanticLabel,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                icon,
                size: 18,
                color: selected ? const Color(0xFF1677FF) : ZhPalette.mutedInk,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? const Color(0xFF1677FF) : ZhPalette.mutedInk,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _QuestionAnswersBottomActions extends StatelessWidget {
  const _QuestionAnswersBottomActions({
    required this.canWrite,
    required this.following,
    required this.followBusy,
    required this.onWrite,
    required this.onInvite,
    required this.onFollow,
  });

  final bool canWrite;
  final bool following;
  final bool followBusy;
  final VoidCallback onWrite;
  final VoidCallback onInvite;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) => ZhLiquidGlassFloatingActionBar(
    key: const ValueKey('question-answers-bottom-actions'),
    items: [
      ZhLiquidGlassActionItem(
        icon: const KeyedSubtree(
          key: Key('question-answer-compose-action'),
          child: Icon(Icons.edit_outlined),
        ),
        activeIcon: const Icon(Icons.edit_outlined),
        label: canWrite ? '写回答' : '登录后写回答',
        semanticLabel: canWrite ? '写回答' : '登录后写回答',
        onPressed: onWrite,
      ),
      ZhLiquidGlassActionItem(
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: '邀请回答',
        semanticLabel: '邀请回答',
        onPressed: onInvite,
      ),
      ZhLiquidGlassActionItem(
        icon: followBusy
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(following ? Icons.check_rounded : Icons.add_rounded),
        label: following ? '已关注' : '关注问题',
        semanticLabel: following ? '取消关注问题' : '关注问题',
        onPressed: followBusy ? null : onFollow,
      ),
    ],
    transitionKey: following ? 'following' : 'not-following',
  );
}
