part of '../api_views.dart';

/// Returns the compact image set used by feed and search cards.
///
/// The shared parser handles the normal answer/article contracts. Some mobile
/// recommendation responses, however, keep the media list inside a nested
/// ComponentCard payload or expose a content image node without the usual
/// `content_*` marker. Keep that narrow fallback at the UI projection edge so
/// the reusable API parser remains free of Flutter card-presentation rules.
List<String> contentPreviewImageUrlsOf(
  Map<String, dynamic> source, {
  int limit = 3,
}) {
  if (limit <= 0) return const [];
  final object = unwrapObject(source);
  final authorAvatar = authorAvatarOf(object);
  final urls = <String>[];
  final seen = <String>{};

  void add(Object? raw) {
    final url = httpsImageUrl(raw);
    if (url == null || url == authorAvatar) return;
    final uri = Uri.tryParse(url);
    final key = uri == null
        ? url
        : uri.replace(query: '', fragment: '').toString();
    if (seen.add(key)) urls.add(url);
  }

  for (final url in contentImageUrlsOf(source, limit: limit)) {
    add(url);
    if (urls.length >= limit) return urls;
  }

  final visitedNested = <Map<String, dynamic>>{};

  void addNestedMap(Object? raw) {
    if (urls.length >= limit) return;
    if (raw is List) {
      for (final item in raw) {
        addNestedMap(item);
        if (urls.length >= limit) return;
      }
      return;
    }
    if (raw is String) {
      for (final url in contentImageUrlsOf({'content': raw}, limit: limit)) {
        add(url);
        if (urls.length >= limit) return;
      }
      return;
    }
    final map = stringMap(raw);
    if (map == null || !visitedNested.add(map)) return;
    for (final url in contentImageUrlsOf(map, limit: limit)) {
      add(url);
      if (urls.length >= limit) return;
    }
    for (final key in const [
      'images',
      'image_list',
      'media_detail',
      'media_info',
      'media_infos',
      'content',
      'content_data',
      'body',
      'ori_content',
      'blocks',
      'nodes',
      'children',
      'elements',
      'paragraphs',
      'rich_text',
      'richText',
      'source',
      'original',
      'thumbnail',
      'image',
    ]) {
      addNestedMap(map[key]);
      if (urls.length >= limit) return;
    }
  }

  // These are all image-bearing containers used by the feed/search wire
  // formats. Do not recursively inspect arbitrary `url` fields: those are
  // often article links rather than bitmap URLs.
  for (final key in const [
    'image_url',
    'imageUrl',
    'title_image',
    'thumbnail',
    'thumbnail_url',
    'cover',
    'cover_url',
    'cover_image',
    'artwork',
    'image',
    'images',
    'image_list',
    'thumbnails',
    'thumbnails_v2',
    'media_detail',
    'media_info',
    'media_infos',
    'image_content',
    'imageContent',
  ]) {
    add(object[key]);
    addNestedMap(object[key]);
    if (urls.length >= limit) return urls;
  }

  // The canonical parser already covers ordinary answer/article/search
  // objects. The deeper walk below is only needed for SDUI ComponentCards;
  // keeping it out of normal rows avoids extra tree traversal while scrolling.
  if (object['component_card'] != true) return urls;

  final extra = stringMap(object['extra']);
  final business = stringMap(extra?['business_ext_map']);
  final contentInfo = stringMap(business?['content_info']);
  final passthrough = stringMap(business?['passthrough_info']);
  for (final nested in [
    business,
    contentInfo,
    stringMap(contentInfo?['detail']),
    passthrough,
    stringMap(passthrough?['content']),
    object['media_detail'],
    object['ori_content'],
    object['content'],
    object['content_data'],
    object['body'],
  ]) {
    addNestedMap(nested);
    if (urls.length >= limit) return urls;
  }

  // A few ComponentCard versions only expose the image as a child node. The
  // marker filter avoids turning author avatars, badges, close buttons, or
  // action links into content previews.
  for (final node in walkVisibleMaps(object['children'])) {
    final marker = [
      node['type'],
      node['style'],
      node['test_id'],
      node['id'],
    ].whereType<Object>().join(' ').toLowerCase();
    if (marker.isEmpty ||
        const [
          'avatar',
          'author',
          'user',
          'badge',
          'icon',
          'tail',
          'close',
          'action',
        ].any(marker.contains)) {
      continue;
    }
    final imageNode =
        marker.contains('image') ||
        marker.contains('cover') ||
        marker.contains('thumbnail') ||
        marker.contains('media') ||
        marker.contains('content') ||
        plainText(node['type']).toLowerCase() == 'image';
    if (!imageNode) continue;
    for (final key in const [
      'image_url',
      'imageUrl',
      'image',
      'source',
      'original',
      'thumbnail',
      'url_template',
    ]) {
      add(node[key]);
      if (urls.length >= limit) return urls;
    }
  }
  return urls;
}

final _contentCardStaticDataCache = Expando<_ContentCardStaticData>(
  'content-card-static-data',
);

class _ContentCardStaticData {
  _ContentCardStaticData._({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.authorName,
    required this.authorHeadline,
    required this.authorBadges,
    required this.image,
    required this.contentImages,
    required this.showsObjectSummary,
    required this.usesAvatar,
  });

  factory _ContentCardStaticData.from(Map<String, dynamic> value) {
    final object = unwrapObject(value);
    final type = typeOf(value);
    return _ContentCardStaticData._(
      type: type,
      title: titleOf(value),
      subtitle: subtitleOf(value),
      authorName: authorNameOf(value),
      authorHeadline: authorHeadlineOf(value),
      authorBadges: authorBadgeLabelsOf(value),
      image: ObjectCard._imageOf(object),
      contentImages: contentPreviewImageUrlsOf(value, limit: 12),
      showsObjectSummary:
          type == 'people' ||
          type == 'member' ||
          type == 'topic' ||
          type == 'question' ||
          type == 'column' ||
          type == 'collection' ||
          type == 'favlist',
      usesAvatar:
          type == 'answer' ||
          type == 'people' ||
          type == 'member' ||
          object['component_card'] == true,
    );
  }

  final String type;
  final String title;
  final String subtitle;
  final String authorName;
  final String authorHeadline;
  final List<String> authorBadges;
  final String? image;
  final List<String> contentImages;
  final bool showsObjectSummary;
  final bool usesAvatar;
}

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

  List<String> get images =>
      _images ??= contentPreviewImageUrlsOf(source, limit: 12);
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
    this.onTapAt,
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

  /// Pointer position from the card's successful tap, used by optional
  /// source-aware transitions. Keyboard and semantic activation still use
  /// [onTap] directly.
  final ValueChanged<Offset>? onTapAt;
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
        onTapAt: onTapAt,
        onLongPress: onLongPress,
        onAction: onAction,
        onAuthorTap: onAuthorTap,
        compact: compact,
        showImages: showImages,
        showMetrics: showMetrics,
        presentation: presentation,
      );
    }
    final data = _contentCardStaticDataCache[value] ??=
        _ContentCardStaticData.from(value);
    final title = data.title;
    final subtitle = data.subtitle;
    final type = data.type;
    if (plainText(
          value['type'],
        ).toLowerCase().contains('aggregate_notification') &&
        type.contains('aggregate_notification')) {
      debugPrint(
        '[zhihu-ui] aggregate-unresolved ${aggregateRoutingSummary(value)}',
      );
    }
    final authorName = data.authorName;
    final authorHeadline = data.authorHeadline;
    final authorBadges = data.authorBadges;
    final interactive = const {'answer', 'article', 'pin'}.contains(type);
    final image = data.image;
    final metrics = ContentMetrics.from(value);
    // Rows without engagement metrics never paint a selected interaction
    // state. Avoid walking relationship/reaction wrappers for those common
    // summary rows while preserving the full state for interactive cards.
    final relationship = metrics.hasEngagement
        ? AnswerRelationship.from(value)
        : const AnswerRelationship(
            voting: '',
            isThanked: null,
            isFavorited: null,
            isAuthor: null,
            isFollowingAuthor: null,
          );
    final dateLabel = contentDateLabel(metrics);
    final contentImages = data.contentImages;
    final showsObjectSummary = data.showsObjectSummary;
    final usesAvatar = data.usesAvatar;
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
            authorName: authorName,
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
                      filterQuality: FilterQuality.low,
                      frameBuilder: (_, child, frame, _) => frame == null
                          ? _TypeIcon(
                              type: type,
                              size: leadingSize,
                              circular: usesAvatar,
                            )
                          : child,
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
                      ZhPill(
                        label: _typeLabel(context.zhL10n, type),
                        compact: true,
                      ),
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
                  primaryText.isEmpty
                      ? context.zhL10n.commonUntitledObject
                      : primaryText,
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
                          semanticLabel: context.zhL10n.metricVoteup(
                            compactCount(count),
                          ),
                          selected: relationship.isUpvoted,
                          onTap: interactive && onAction != null
                              ? () => onAction!(ContentCardAction.vote)
                              : null,
                        ),
                      if (metrics.favoriteCount case final count?)
                        _CardMetric(
                          icon: Icons.star_border_rounded,
                          label: compactCount(count),
                          semanticLabel: context.zhL10n.metricFavorite(
                            compactCount(count),
                          ),
                          selected: relationship.isFavorited == true,
                          onTap: interactive && onAction != null
                              ? () => onAction!(ContentCardAction.favorite)
                              : null,
                        ),
                      if (metrics.commentCount case final count?)
                        _CardMetric(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: compactCount(count),
                          semanticLabel: context.zhL10n.metricComment(
                            compactCount(count),
                          ),
                          onTap: onAction == null
                              ? null
                              : () => onAction!(ContentCardAction.comments),
                        ),
                      if (type == 'answer' && metrics.thanksCount != null)
                        _CardMetric(
                          icon: Icons.volunteer_activism_outlined,
                          label: compactCount(metrics.thanksCount!),
                          semanticLabel: context.zhL10n.metricThanks(
                            compactCount(metrics.thanksCount!),
                          ),
                        ),
                      if (type == 'answer' && metrics.viewCount != null)
                        _CardMetric(
                          icon: Icons.visibility_outlined,
                          label: compactCount(metrics.viewCount!),
                          semanticLabel: context.zhL10n.metricViews(
                            compactCount(metrics.viewCount!),
                          ),
                        ),
                      if (type == 'answer' && relationship.isThanked == true)
                        _CardMetric(
                          icon: Icons.volunteer_activism_rounded,
                          label: context.zhL10n.metricThanked,
                          semanticLabel: context.zhL10n.metricThanked,
                        ),
                      if (type == 'answer' && relationship.isFavorited == true)
                        _CardMetric(
                          icon: Icons.star_rounded,
                          label: context.zhL10n.metricFavorited,
                          semanticLabel: context.zhL10n.metricFavorited,
                        ),
                      if ((type == 'people' ||
                              type == 'member' ||
                              type == 'topic' ||
                              type == 'question' ||
                              type == 'column') &&
                          metrics.followerCount != null)
                        _CardMetric(
                          icon: Icons.groups_outlined,
                          label: context.zhL10n.metricFollowers(
                            compactCount(metrics.followerCount!),
                          ),
                          semanticLabel: context.zhL10n.metricFollowers(
                            compactCount(metrics.followerCount!),
                          ),
                        ),
                      if ((type == 'people' ||
                              type == 'member' ||
                              type == 'question') &&
                          metrics.answerCount != null)
                        _CardMetric(
                          icon: Icons.question_answer_outlined,
                          label: context.zhL10n.metricAnswers(
                            compactCount(metrics.answerCount!),
                          ),
                          semanticLabel: context.zhL10n.metricAnswers(
                            compactCount(metrics.answerCount!),
                          ),
                        ),
                      if ((type == 'people' ||
                              type == 'member' ||
                              type == 'column') &&
                          metrics.articleCount != null)
                        _CardMetric(
                          icon: Icons.article_outlined,
                          label: context.zhL10n.metricArticles(
                            compactCount(metrics.articleCount!),
                          ),
                          semanticLabel: context.zhL10n.metricArticles(
                            compactCount(metrics.articleCount!),
                          ),
                        ),
                      if ((type == 'collection' || type == 'favlist') &&
                          metrics.itemCount != null)
                        _CardMetric(
                          icon: Icons.collections_bookmark_outlined,
                          label: context.zhL10n.metricItems(
                            compactCount(metrics.itemCount!),
                          ),
                          semanticLabel: context.zhL10n.metricItems(
                            compactCount(metrics.itemCount!),
                          ),
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
                    decoration: BoxDecoration(
                      color: ZhPalette.canvas,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, size: 15),
                  ),
                if (onDelete != null) ...[
                  const SizedBox(height: 4),
                  IconButton(
                    tooltip: context.zhL10n.commonDelete,
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

  String _typeLabel(AppLocalizations l10n, String type) => switch (type) {
    'answer' => l10n.contentTypeAnswer,
    'article' => l10n.contentTypeArticle,
    'people' || 'member' => l10n.contentTypePeople,
    'question' => l10n.contentTypeQuestion,
    'column' => l10n.contentTypeColumn,
    'topic' => l10n.contentTypeTopic,
    'pin' => l10n.contentTypeIdea,
    'comment' => l10n.contentTypeComment,
    _ => type.toUpperCase(),
  };

  static String? _imageOf(Map<String, dynamic> value) {
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
