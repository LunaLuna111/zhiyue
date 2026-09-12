part of '../api_views.dart';

// Feed rows are immutable apart from interaction counters/relationship state.
// Keep the expensive SDUI text/image projection next to the row identity so a
// pagination setState or a scroll away/back does not repeatedly walk the same
// deeply nested ComponentCard tree. Dynamic metrics stay outside this cache.
final _feedCardStaticDataCache = Expando<_FeedCardStaticData>(
  'feed-card-static-data',
);

/// Presentation contract for the two home-feed surfaces which have a
/// different official hierarchy from a generic object list. Keeping this on
/// the card, rather than duplicating an entire feed row, lets pagination and
/// image prefetch continue to use the same object model.
enum FeedCardPresentation { generic, following, hot }

class _FeedCardStaticData {
  _FeedCardStaticData._({
    required this.source,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.headline,
    required this.badges,
    required this.avatar,
    required this.kindLabel,
  });

  factory _FeedCardStaticData.from(Map<String, dynamic> value) {
    final object = unwrapObject(value);
    // A normalized ComponentCard contains all original children but skips the
    // repeated normalization pass in the static helper calls below.
    final source = object['component_card'] == true ? object : value;
    final author = authorNameOf(source);
    return _FeedCardStaticData._(
      source: source,
      title: titleOf(source),
      excerpt: subtitleOf(source),
      author: author,
      headline: authorHeadlineOf(source),
      badges: authorBadgeLabelsOf(source),
      avatar: _feedAvatarOf(object),
      kindLabel: contentKindLabelOf(source),
    );
  }

  final Map<String, dynamic> source;
  final String title;
  final String excerpt;
  final String author;
  final String headline;
  final List<String> badges;
  final String? avatar;
  final String kindLabel;
  List<String>? _images;

  List<String> get images => _images ??= contentImageUrlsOf(source, limit: 12);
}

String? _feedAvatarOf(Map<String, dynamic> object) {
  final author = object['author'];
  if (author is Map) {
    final url = author['avatar_url']?.toString() ?? '';
    if (Uri.tryParse(url)?.scheme == 'https') return url;
  }
  final url = object['avatar_url']?.toString() ?? '';
  return Uri.tryParse(url)?.scheme == 'https' ? url : null;
}

class ObjectCard extends StatelessWidget {
  const ObjectCard({
    super.key,
    required this.value,
    this.onTap,
    this.onLongPress,
    this.answerListMode = false,
    this.feedMode = false,
    this.compact = false,
    this.showImages = true,
    this.showMetrics = true,
    this.presentation = FeedCardPresentation.generic,
    this.onDelete,
    this.onAction,
    this.onAuthorTap,
  });

  final Map<String, dynamic> value;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool answerListMode;
  final bool feedMode;
  final bool compact;
  final bool showImages;
  final bool showMetrics;
  final FeedCardPresentation presentation;
  final VoidCallback? onDelete;
  final ValueChanged<ContentCardAction>? onAction;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    if (feedMode) {
      return _FeedObjectCard(
        value: value,
        onTap: onTap,
        onLongPress: onLongPress,
        onAction: onAction,
        onAuthorTap: onAuthorTap,
        compact: compact,
        showImages: showImages,
        showMetrics: showMetrics,
        presentation: presentation,
      );
    }
    final object = unwrapObject(value);
    final title = titleOf(value);
    final subtitle = subtitleOf(value);
    final type = typeOf(value);
    if (plainText(
          value['type'],
        ).toLowerCase().contains('aggregate_notification') &&
        type.contains('aggregate_notification')) {
      debugPrint(
        '[zhihu-ui] aggregate-unresolved ${aggregateRoutingSummary(value)}',
      );
    }
    final authorName = authorNameOf(value);
    final authorHeadline = authorHeadlineOf(value);
    final authorBadges = authorBadgeLabelsOf(value);
    final relationship = AnswerRelationship.from(value);
    final interactive = const {'answer', 'article', 'pin'}.contains(type);
    final image = _imageOf(object);
    final metrics = ContentMetrics.from(value);
    final dateLabel = contentDateLabel(metrics);
    final contentImages = contentImageUrlsOf(value, limit: 12);
    final showsObjectSummary =
        type == 'people' ||
        type == 'member' ||
        type == 'topic' ||
        type == 'question' ||
        type == 'column' ||
        type == 'collection' ||
        type == 'favlist';
    final usesAvatar =
        type == 'answer' ||
        type == 'people' ||
        type == 'member' ||
        object['component_card'] == true;
    final leadingSize = usesAvatar ? 44.0 : 52.0;
    final primaryText =
        answerListMode && type == 'answer' && subtitle.isNotEmpty
        ? subtitle
        : title;
    final secondaryText = answerListMode && type == 'answer' ? '' : subtitle;
    return ZhSurface(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: ZhSpace.sm, vertical: 4),
      padding: const EdgeInsets.all(ZhSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContentAuthorTapTarget(
            value: value,
            onTap: type == 'answer' ? onAuthorTap : null,
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(
                      usesAvatar ? leadingSize / 2 : 10,
                    ),
                    child: ZhihuImage.network(
                      image,
                      headers: zhihuImageRequestHeaders,
                      width: leadingSize,
                      height: leadingSize,
                      fit: BoxFit.cover,
                      cacheWidth: (leadingSize * 3).round(),
                      cacheHeight: (leadingSize * 3).round(),
                      filterQuality: FilterQuality.medium,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : _TypeIcon(
                              type: type,
                              size: leadingSize,
                              circular: usesAvatar,
                            ),
                      errorBuilder: (_, _, _) => _TypeIcon(
                        type: type,
                        size: leadingSize,
                        circular: usesAvatar,
                      ),
                    ),
                  )
                : _TypeIcon(
                    type: type,
                    size: leadingSize,
                    circular: usesAvatar,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (type.isNotEmpty)
                      ZhPill(label: _typeLabel(type), compact: true),
                    if (authorName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authorName,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (type == 'answer' &&
                    (authorHeadline.isNotEmpty || authorBadges.isNotEmpty)) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (authorBadges.isNotEmpty) ...[
                        const Icon(Icons.verified_outlined, size: 13),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            authorBadges.first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                      if (authorBadges.isNotEmpty && authorHeadline.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text('·'),
                        ),
                      if (authorHeadline.isNotEmpty)
                        Flexible(
                          flex: 2,
                          child: Text(
                            authorHeadline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  primaryText.isEmpty ? '未命名对象' : primaryText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: answerListMode ? 14.5 : 16,
                    height: answerListMode ? 1.38 : 1.28,
                    fontWeight: answerListMode
                        ? FontWeight.w600
                        : FontWeight.w700,
                  ),
                  maxLines: answerListMode ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondaryText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    secondaryText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ZhPalette.mutedInk,
                      fontSize: 13,
                      height: 1.42,
                    ),
                  ),
                ],
                if (contentImages.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  ContentImageStrip(urls: contentImages),
                ],
                if (metrics.hasEngagement ||
                    (showsObjectSummary && metrics.hasObjectSummary) ||
                    dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 13,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (metrics.voteupCount case final count?)
                        _CardMetric(
                          icon: Icons.change_history_outlined,
                          label: compactCount(count),
                          semanticLabel: '赞同 ${compactCount(count)}',
                          selected: relationship.isUpvoted,
                          onTap: interactive && onAction != null
                              ? () => onAction!(ContentCardAction.vote)
                              : null,
                        ),
                      if (metrics.favoriteCount case final count?)
                        _CardMetric(
                          icon: Icons.star_border_rounded,
                          label: compactCount(count),
                          semanticLabel: '收藏 ${compactCount(count)}',
                          selected: relationship.isFavorited == true,
                          onTap: interactive && onAction != null
                              ? () => onAction!(ContentCardAction.favorite)
                              : null,
                        ),
                      if (metrics.commentCount case final count?)
                        _CardMetric(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: compactCount(count),
                          semanticLabel: '评论 ${compactCount(count)}',
                          onTap: onAction == null
                              ? null
                              : () => onAction!(ContentCardAction.comments),
                        ),
                      if (type == 'answer' && metrics.thanksCount != null)
                        _CardMetric(
                          icon: Icons.volunteer_activism_outlined,
                          label: compactCount(metrics.thanksCount!),
                          semanticLabel:
                              '感谢 ${compactCount(metrics.thanksCount!)}',
                        ),
                      if (type == 'answer' && metrics.viewCount != null)
                        _CardMetric(
                          icon: Icons.visibility_outlined,
                          label: compactCount(metrics.viewCount!),
                          semanticLabel:
                              '浏览 ${compactCount(metrics.viewCount!)}',
                        ),
                      if (type == 'answer' && relationship.isThanked == true)
                        const _CardMetric(
                          icon: Icons.volunteer_activism_rounded,
                          label: '已感谢',
                          semanticLabel: '已感谢该回答',
                        ),
                      if (type == 'answer' && relationship.isFavorited == true)
                        const _CardMetric(
                          icon: Icons.star_rounded,
                          label: '已收藏',
                          semanticLabel: '已收藏该回答',
                        ),
                      if ((type == 'people' ||
                              type == 'member' ||
                              type == 'topic' ||
                              type == 'question' ||
                              type == 'column') &&
                          metrics.followerCount != null)
                        _CardMetric(
                          icon: Icons.groups_outlined,
                          label: '${compactCount(metrics.followerCount!)} 关注者',
                          semanticLabel:
                              '${compactCount(metrics.followerCount!)} 位关注者',
                        ),
                      if ((type == 'people' ||
                              type == 'member' ||
                              type == 'question') &&
                          metrics.answerCount != null)
                        _CardMetric(
                          icon: Icons.question_answer_outlined,
                          label: '${compactCount(metrics.answerCount!)} 回答',
                          semanticLabel:
                              '${compactCount(metrics.answerCount!)} 个回答',
                        ),
                      if ((type == 'people' ||
                              type == 'member' ||
                              type == 'column') &&
                          metrics.articleCount != null)
                        _CardMetric(
                          icon: Icons.article_outlined,
                          label: '${compactCount(metrics.articleCount!)} 文章',
                          semanticLabel:
                              '${compactCount(metrics.articleCount!)} 篇文章',
                        ),
                      if ((type == 'collection' || type == 'favlist') &&
                          metrics.itemCount != null)
                        _CardMetric(
                          icon: Icons.collections_bookmark_outlined,
                          label: '${compactCount(metrics.itemCount!)} 条内容',
                          semanticLabel:
                              '${compactCount(metrics.itemCount!)} 条内容',
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
              ],
            ),
          ),
          if (onTap != null || onDelete != null) ...[
            const SizedBox(width: 6),
            Column(
              children: [
                if (onTap != null)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: ZhPalette.canvas,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, size: 15),
                  ),
                if (onDelete != null) ...[
                  const SizedBox(height: 4),
                  IconButton(
                    tooltip: '删除',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 19),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
    'answer' => '回答',
    'article' => '文章',
    'people' || 'member' => '用户',
    'question' => '问题',
    'column' => '专栏',
    'topic' => '话题',
    'pin' => '想法',
    'comment' => '评论',
    _ => type.toUpperCase(),
  };

  String? _imageOf(Map<String, dynamic> value) {
    for (final key in const [
      'image_url',
      'title_image',
      'avatar_url',
      'thumbnail',
      'icon_url',
      'activity_icon_url',
    ]) {
      final candidate = value[key]?.toString();
      if (candidate != null && Uri.tryParse(candidate)?.scheme == 'https') {
        return candidate;
      }
    }
    final author = value['author'];
    if (author is Map<String, dynamic>) {
      final candidate = author['avatar_url']?.toString();
      if (candidate != null && Uri.tryParse(candidate)?.scheme == 'https') {
        return candidate;
      }
    }
    return null;
  }
}
