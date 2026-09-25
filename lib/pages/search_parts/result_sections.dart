part of '../search_page.dart';

final _searchHotTimingItemStaticDataCache =
    Expando<_SearchHotTimingItemStaticData>(
      'search-hot-timing-item-static-data',
    );

class _SearchHotTimingItemStaticData {
  const _SearchHotTimingItemStaticData({
    required this.title,
    required this.author,
    required this.excerpt,
    required this.metrics,
    required this.date,
    required this.image,
  });

  factory _SearchHotTimingItemStaticData.from(Map<String, dynamic> value) {
    final metrics = ContentMetrics.from(value);
    final images = contentPreviewImageUrlsOf(value, limit: 1);
    return _SearchHotTimingItemStaticData(
      title: titleOf(value),
      author: authorNameOf(value),
      excerpt: subtitleOf(value),
      metrics: metrics,
      date: contentDateLabel(metrics),
      image: images.isEmpty ? null : images.first,
    );
  }

  final String title;
  final String author;
  final String excerpt;
  final ContentMetrics metrics;
  final String date;
  final String? image;
}

class _SearchHotTimingCard extends StatelessWidget {
  const _SearchHotTimingCard({
    required this.value,
    required this.onItemTap,
    this.onMore,
  });

  final Map<String, dynamic> value;
  final void Function(Map<String, dynamic>, [Offset?]) onItemTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final title = searchHotTimingTitleOf(value);
    final items = searchHotTimingItemsOf(value);
    return ColoredBox(
      color: ZhPalette.canvas,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Material(
          color: ZhPalette.background,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 19,
                      color: ZhPalette.ink,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        title.isEmpty
                            ? context.zhL10n.searchRecentContent
                            : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (onMore != null)
                      TextButton(
                        key: const ValueKey('search-hot-timing-more'),
                        onPressed: onMore,
                        style: TextButton.styleFrom(
                          foregroundColor: ZhPalette.mutedInk,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: const Size(48, 34),
                        ),
                        child: Text(context.zhL10n.commonMore),
                      ),
                  ],
                ),
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) const Divider(height: 1),
                  _SearchHotTimingItem(
                    value: items[index],
                    onTap: ([position]) => onItemTap(items[index], position),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchSectionCard extends StatelessWidget {
  const _SearchSectionCard({
    required this.value,
    required this.onItemTap,
    this.onMore,
  });

  final Map<String, dynamic> value;
  final void Function(Map<String, dynamic>, [Offset?]) onItemTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final items = searchSectionItemsOf(value);
    return ColoredBox(
      color: ZhPalette.canvas,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Material(
          color: ZhPalette.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 11, 9, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        searchSectionTitleOf(value),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (onMore != null)
                      TextButton(
                        onPressed: onMore,
                        style: TextButton.styleFrom(
                          foregroundColor: ZhPalette.mutedInk,
                          minimumSize: const Size(56, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.zhL10n.commonMore),
                            SizedBox(width: 1),
                            Icon(Icons.chevron_right_rounded, size: 18),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              for (var index = 0; index < items.length; index++) ...[
                if (index > 0)
                  const Padding(
                    padding: EdgeInsets.only(left: 78),
                    child: Divider(height: 1),
                  ),
                _SearchEntityResultRow(
                  value: items[index],
                  onTap: () => onItemTap(items[index]),
                  onTapAt: (position) => onItemTap(items[index], position),
                  compact: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchHotTimingItem extends StatelessWidget {
  const _SearchHotTimingItem({required this.value, required this.onTap});

  final Map<String, dynamic> value;
  final void Function([Offset?]) onTap;

  @override
  Widget build(BuildContext context) {
    final data = _searchHotTimingItemStaticDataCache[value] ??=
        _SearchHotTimingItemStaticData.from(value);
    final title = data.title;
    final author = data.author;
    final excerpt = data.excerpt;
    final metrics = data.metrics;
    final date = data.date;
    final image = data.image;
    Offset? tapOrigin;
    void handleTap() {
      onTap(tapOrigin);
    }

    return InkWell(
      onTap: handleTap,
      onTapDown: (details) => tapOrigin = details.globalPosition,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty
                        ? context.zhL10n.commonUntitledContent
                        : title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  if (author.isNotEmpty || excerpt.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      [if (author.isNotEmpty) '$author：', excerpt].join(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ZhPalette.mutedInk,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (metrics.hasEngagement || date.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children:
                          [
                                if (metrics.voteupCount != null)
                                  Text(
                                    context.zhL10n.metricVoteup(
                                      compactCount(metrics.voteupCount!),
                                    ),
                                  ),
                                if (metrics.commentCount != null)
                                  Text(
                                    context.zhL10n.metricComment(
                                      compactCount(metrics.commentCount!),
                                    ),
                                  ),
                                if (date.isNotEmpty) Text(date),
                              ]
                              .map((item) {
                                return DefaultTextStyle.merge(
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: ZhPalette.subtleInk),
                                  child: item,
                                );
                              })
                              .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
            if (image != null) ...[
              const SizedBox(width: 11),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: ZhihuImage.network(
                  image,
                  headers: zhihuImageRequestHeaders,
                  width: 95,
                  height: 66,
                  fit: BoxFit.cover,
                  cacheWidth: 285,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
