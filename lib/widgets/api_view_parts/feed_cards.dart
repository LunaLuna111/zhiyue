part of '../api_views.dart';

class _FeedObjectCard extends StatelessWidget {
  const _FeedObjectCard({
    required this.value,
    required this.compact,
    required this.showImages,
    required this.showMetrics,
    required this.presentation,
    this.onTap,
    this.onLongPress,
    this.onAction,
    this.onAuthorTap,
  });

  final Map<String, dynamic> value;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<ContentCardAction>? onAction;
  final VoidCallback? onAuthorTap;
  final bool compact;
  final bool showImages;
  final bool showMetrics;
  final FeedCardPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final data = _feedCardStaticDataCache[value] ??= _FeedCardStaticData.from(
      value,
    );
    final metrics = ContentMetrics.from(data.source);
    final images = showImages ? data.images : const <String>[];
    final dateLabel = contentDateLabel(metrics);
    final relationship = AnswerRelationship.from(data.source);
    final hotMode = presentation == FeedCardPresentation.hot;
    final followingMode = presentation == FeedCardPresentation.following;
    final avatarFallback = data.author.isEmpty
        ? '知'
        : data.author.characters.first;

    return Material(
      color: ZhPalette.background,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            11,
            compact ? 10 : 13,
            11,
            compact ? 9 : 12,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ZhPalette.border, width: 0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title.isEmpty ? '未命名内容' : data.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: hotMode ? 17.5 : (followingMode ? 17.5 : 16.5),
                  height: hotMode ? 1.32 : 1.28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hotMode)
                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '热榜',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: ZhPalette.subtleInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (!hotMode &&
                  (data.author.isNotEmpty ||
                      data.headline.isNotEmpty ||
                      data.badges.isNotEmpty ||
                      data.kindLabel.isNotEmpty)) ...[
                SizedBox(height: compact ? 6 : 9),
                Row(
                  children: [
                    if (data.avatar != null) ...[
                      _ContentAuthorTapTarget(
                        value: data.source,
                        onTap: onAuthorTap,
                        child: ClipOval(
                          child: ZhihuImage.network(
                            data.avatar!,
                            headers: zhihuImageRequestHeaders,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            cacheWidth: 72,
                            cacheHeight: 72,
                            filterQuality: FilterQuality.medium,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : _FeedAvatarPlaceholder(
                                    fallback: avatarFallback,
                                  ),
                            errorBuilder: (_, _, _) => _FeedAvatarPlaceholder(
                              fallback: avatarFallback,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                    Expanded(
                      child: Row(
                        children: [
                          if (data.author.isNotEmpty)
                            Flexible(
                              child: Text(
                                data.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: ZhPalette.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          if (data.badges.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            const Icon(Icons.verified_rounded, size: 14),
                          ],
                          if (data.headline.isNotEmpty) ...[
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                data.headline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: ZhPalette.subtleInk,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (data.kindLabel.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 58,
                        child: Text(
                          data.kindLabel,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: ZhPalette.subtleInk),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (data.excerpt.isNotEmpty) ...[
                SizedBox(height: hotMode ? 7 : (compact ? 5 : 8)),
                Text(
                  data.excerpt,
                  maxLines: hotMode
                      ? 2
                      : (compact ? 2 : (images.isEmpty ? 3 : 2)),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ZhPalette.mutedInk,
                    fontSize: hotMode ? 14 : 13.5,
                    height: hotMode ? 1.48 : 1.45,
                  ),
                ),
              ],
              if (images.isNotEmpty) ...[
                SizedBox(height: hotMode ? 10 : (compact ? 6 : 9)),
                ContentImageStrip(
                  urls: images,
                  compact: compact,
                  singleHeight: hotMode ? 194 : null,
                ),
              ],
              if (showMetrics &&
                  !hotMode &&
                  (metrics.hasEngagement || dateLabel.isNotEmpty)) ...[
                SizedBox(height: compact ? 6 : 9),
                Row(
                  children: [
                    if (metrics.voteupCount case final count?)
                      _CardMetric(
                        icon: Icons.change_history_outlined,
                        label: compactCount(count),
                        semanticLabel: '赞同 ${compactCount(count)}',
                        selected: relationship.isUpvoted,
                        onTap: onAction == null
                            ? null
                            : () => onAction!(ContentCardAction.vote),
                      ),
                    if (metrics.favoriteCount case final count?) ...[
                      const SizedBox(width: 18),
                      _CardMetric(
                        icon: Icons.star_border_rounded,
                        label: compactCount(count),
                        semanticLabel: '收藏 ${compactCount(count)}',
                        selected: relationship.isFavorited == true,
                        onTap: onAction == null
                            ? null
                            : () => onAction!(ContentCardAction.favorite),
                      ),
                    ],
                    if (metrics.commentCount case final count?) ...[
                      const SizedBox(width: 18),
                      _CardMetric(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: compactCount(count),
                        semanticLabel: '评论 ${compactCount(count)}',
                        onTap: onAction == null
                            ? null
                            : () => onAction!(ContentCardAction.comments),
                      ),
                    ],
                    const Spacer(),
                    if (dateLabel.isNotEmpty)
                      Text(
                        dateLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
                          fontSize: 11.5,
                        ),
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
}

class _ContentAuthorTapTarget extends StatelessWidget {
  const _ContentAuthorTapTarget({
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

class _FeedAvatarPlaceholder extends StatelessWidget {
  const _FeedAvatarPlaceholder({required this.fallback});

  final String fallback;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: ZhPalette.canvas,
    child: SizedBox.square(
      dimension: 24,
      child: Center(
        child: Text(
          fallback,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class ContentImageStrip extends StatelessWidget {
  const ContentImageStrip({
    super.key,
    required this.urls,
    this.compact = false,
    this.singleHeight,
  });

  final List<String> urls;
  final bool compact;
  final double? singleHeight;

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return SingleContentCardImage(url: urls.first, height: singleHeight);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 7.0;
        final visibleColumns = math.min(urls.length, 3);
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 360.0;
        final tileWidth =
            (availableWidth - gap * (visibleColumns - 1)) / visibleColumns;
        return SizedBox(
          height: SingleContentCardImage.previewHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: urls.length,
            separatorBuilder: (_, _) => const SizedBox(width: gap),
            itemBuilder: (context, index) => SizedBox(
              key: ValueKey('content-preview-frame-multi-${urls[index]}'),
              width: tileWidth,
              child: _CardContentImage(url: urls[index], cacheWidth: 384),
            ),
          ),
        );
      },
    );
  }
}

class SingleContentCardImage extends StatelessWidget {
  const SingleContentCardImage({super.key, required this.url, this.height});

  final String url;
  final double? height;
  static const previewHeight = 128.0;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: ValueKey('content-preview-frame-single-$url'),
    width: double.infinity,
    height: height ?? previewHeight,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ZhihuImage.network(
        imageKey: ValueKey('content-preview-image-$url'),
        url,
        headers: zhihuImageRequestHeaders,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        // Supplying both decode dimensions forces the bitmap into that exact
        // ratio before BoxFit runs. Width-only decoding preserves its source
        // aspect ratio, after which the fixed frame performs a real crop.
        cacheWidth: 960,
        filterQuality: FilterQuality.low,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const ColoredBox(color: ZhPalette.canvas),
        errorBuilder: (_, _, _) => const ColoredBox(
          color: ZhPalette.canvas,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: ZhPalette.subtleInk,
            ),
          ),
        ),
      ),
    ),
  );
}

class _CardContentImage extends StatelessWidget {
  const _CardContentImage({required this.url, required this.cacheWidth});

  final String url;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: ZhihuImage.network(
      imageKey: ValueKey('content-preview-image-$url'),
      url,
      headers: zhihuImageRequestHeaders,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.low,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : const ColoredBox(color: ZhPalette.canvas),
      errorBuilder: (_, _, _) => const ColoredBox(
        color: ZhPalette.canvas,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: ZhPalette.subtleInk,
          ),
        ),
      ),
    ),
  );
}
