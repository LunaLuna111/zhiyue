part of '../search_page.dart';

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.value,
    required this.onTap,
    this.onAuthorTap,
  });

  final Map<String, dynamic> value;
  final VoidCallback onTap;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final rawType = typeOf(value).toLowerCase();
    final relatedQuery = searchQueryOf(value);
    if ((rawType == 'relevant_query' || rawType == 'search_query_correction') &&
        relatedQuery.isNotEmpty) {
      return Material(
        color: ZhPalette.background,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 13, 10, 13),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ZhPalette.border, width: .7),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 21,
                  color: ZhPalette.mutedInk,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contentKindLabelOf(value),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: ZhPalette.subtleInk),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        relatedQuery,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: ZhPalette.subtleInk,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (value['_search_novel_card'] == true) {
      return _SearchNovelResultCard(value: value, onTap: onTap);
    }
    final title = titleOf(value);
    final excerpt = subtitleOf(value);
    final type = typeOf(value).replaceAll('search_', '');
    if (type == 'zvideo' ||
        type == 'video' ||
        type == 'videoanswer' ||
        type == 'video_answer') {
      return _SearchVideoResultCard(
        value: value,
        onTap: onTap,
        onAuthorTap: onAuthorTap,
      );
    }
    if (_isSearchEntityType(type)) {
      return _SearchEntityResultRow(value: value, onTap: onTap);
    }
    final author = authorNameOf(value);
    final avatar = authorAvatarOf(value);
    final images = contentImageUrlsOf(value, limit: 3);
    final statistics = searchStatisticsOf(value);
    final metrics = ContentMetrics.from(value);
    final date = contentDateLabel(metrics);
    final typeLabel = contentKindLabelOf(value);
    return Material(
      color: ZhPalette.background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ZhPalette.border, width: .7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title.isEmpty ? '未命名内容' : title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 54,
                    child: Text(
                      typeLabel.isNotEmpty ? typeLabel : _typeLabel(type),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: ZhPalette.subtleInk,
                      ),
                    ),
                  ),
                ],
              ),
              if (author.isNotEmpty) ...[
                const SizedBox(height: 9),
                Row(
                  children: [
                    if (Uri.tryParse(avatar)?.scheme == 'https') ...[
                      Semantics(
                        button: onAuthorTap != null,
                        label: onAuthorTap == null ? null : '查看$author的个人主页',
                        child: InkResponse(
                          key: onAuthorTap == null
                              ? null
                              : ValueKey(
                                  'search-result-author-avatar-'
                                  '${authorIdOf(value)}',
                                ),
                          onTap: onAuthorTap,
                          radius: 24,
                          customBorder: const CircleBorder(),
                          child: ClipOval(
                            child: ZhihuImage.network(
                              avatar,
                              headers: zhihuImageRequestHeaders,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              cacheWidth: 72,
                              cacheHeight: 72,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                    Expanded(
                      child: Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.mutedInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (excerpt.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  excerpt,
                  maxLines: images.isEmpty ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ZhPalette.mutedInk,
                    height: 1.48,
                  ),
                ),
              ],
              if (images.isNotEmpty) ...[
                const SizedBox(height: 10),
                if (images.length == 1)
                  SingleContentCardImage(url: images.first)
                else
                  ContentImageStrip(urls: images),
              ],
              if (statistics.isNotEmpty ||
                  metrics.hasEngagement ||
                  date.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 5,
                  children: [
                    for (final statistic in statistics)
                      Text(
                        '${compactCount(statistic.$2)} ${statistic.$1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
                        ),
                      ),
                    if (statistics.isEmpty && metrics.voteupCount != null)
                      Text(
                        '${compactCount(metrics.voteupCount!)} 赞同',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
                        ),
                      ),
                    if (statistics.isEmpty && metrics.commentCount != null)
                      Text(
                        '${compactCount(metrics.commentCount!)} 评论',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
                        ),
                      ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
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

  String _typeLabel(String type) => switch (type) {
    'answer' => '回答',
    'article' => '文章',
    'question' => '问题',
    'people' || 'member' => '用户',
    'topic' => '话题',
    'column' => '专栏',
    'pin' => '想法',
    'zvideo' || 'video' || 'videoanswer' => '视频',
    'search_content' => '内容',
    _ => '',
  };
}

/// Native novel/盐选 search cards keep the same information hierarchy as the
/// official search vertical: cover, work title, author/summary, then the
/// small engagement line.  They are deliberately not rendered as a generic
/// publication entity, otherwise the cover and the chapter route disappear.
class _SearchNovelResultCard extends StatelessWidget {
  const _SearchNovelResultCard({required this.value, required this.onTap});

  final Map<String, dynamic> value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final images = contentImageUrlsOf(value, limit: 1);
    final cover = images.isEmpty ? _searchEntityImageOf(value) : images.first;
    final title = titleOf(value).isEmpty ? '未命名小说' : titleOf(value);
    final author = authorNameOf(value);
    final excerpt = subtitleOf(value);
    final metrics = ContentMetrics.from(value);
    final date = contentDateLabel(metrics);
    final metadata = <String>[
      if (author.isNotEmpty) author,
      if (metrics.voteupCount case final count?) '${compactCount(count)} 赞同',
      if (metrics.commentCount case final count?) '${compactCount(count)} 评论',
      if (date.isNotEmpty) date,
    ];
    return Material(
      color: ZhPalette.background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ZhPalette.border, width: .7),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cover.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ZhihuImage.network(
                    cover,
                    headers: zhihuImageRequestHeaders,
                    width: 92,
                    height: 124,
                    fit: BoxFit.cover,
                    cacheWidth: 276,
                    cacheHeight: 372,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 13),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '小说',
                          style: TextStyle(color: ZhPalette.subtleInk),
                        ),
                      ],
                    ),
                    if (metadata.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        metadata.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.mutedInk,
                        ),
                      ),
                    ],
                    if (excerpt.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        excerpt,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ZhPalette.mutedInk,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: ZhPalette.subtleInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchVideoResultCard extends StatelessWidget {
  const _SearchVideoResultCard({
    required this.value,
    required this.onTap,
    this.onAuthorTap,
  });

  final Map<String, dynamic> value;
  final VoidCallback onTap;
  final VoidCallback? onAuthorTap;

  String _durationLabel(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) return '';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final title = titleOf(value);
    final excerpt = subtitleOf(value);
    final author = authorNameOf(value);
    final avatar = authorAvatarOf(value);
    final videos = contentVideosOf(value);
    final video = videos.isEmpty ? null : videos.first;
    final fallbackImages = contentImageUrlsOf(value, limit: 1);
    final poster = video?.posterUrl.isNotEmpty == true
        ? video!.posterUrl
        : fallbackImages.isEmpty
        ? ''
        : fallbackImages.first;
    final duration = _durationLabel(video?.durationSeconds);
    final metrics = ContentMetrics.from(value);
    final date = contentDateLabel(metrics);
    final statistics = searchStatisticsOf(value);
    final meta = <String>[
      for (final statistic in statistics.take(3))
        '${compactCount(statistic.$2)} ${statistic.$1}',
      if (statistics.isEmpty && metrics.viewCount != null)
        '${compactCount(metrics.viewCount!)} 次播放',
      if (statistics.isEmpty && metrics.voteupCount != null)
        '${compactCount(metrics.voteupCount!)} 赞同',
      if (statistics.isEmpty && metrics.commentCount != null)
        '${compactCount(metrics.commentCount!)} 评论',
      if (date.isNotEmpty) date,
    ];
    return Material(
      key: ValueKey('search-video-card-${idOf(value)}'),
      color: ZhPalette.background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ZhPalette.border, width: .7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty ? '未命名视频' : title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 17,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (poster.isNotEmpty) ...[
                const SizedBox(height: 11),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ZhihuImage.network(
                          poster,
                          headers: zhihuImageRequestHeaders,
                          fit: BoxFit.cover,
                          cacheWidth: 1080,
                          errorBuilder: (_, _, _) =>
                              const ColoredBox(color: ZhPalette.canvas),
                        ),
                        ColoredBox(color: Colors.black.withValues(alpha: .12)),
                        const Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xC9000000),
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(11),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        if (duration.isNotEmpty)
                          Positioned(
                            right: 8,
                            bottom: 7,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xB8000000),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  duration,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              if (excerpt.isNotEmpty && excerpt != title) ...[
                const SizedBox(height: 9),
                Text(
                  excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ZhPalette.mutedInk,
                    height: 1.45,
                  ),
                ),
              ],
              if (author.isNotEmpty || meta.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (Uri.tryParse(avatar)?.scheme == 'https') ...[
                      Semantics(
                        button: onAuthorTap != null,
                        label: onAuthorTap == null ? null : '查看$author的个人主页',
                        child: InkResponse(
                          key: onAuthorTap == null
                              ? null
                              : ValueKey(
                                  'search-result-author-avatar-'
                                  '${authorIdOf(value)}',
                                ),
                          onTap: onAuthorTap,
                          radius: 24,
                          customBorder: const CircleBorder(),
                          child: ClipOval(
                            child: ZhihuImage.network(
                              avatar,
                              headers: zhihuImageRequestHeaders,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              cacheWidth: 72,
                              cacheHeight: 72,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                    if (author.isNotEmpty)
                      Flexible(
                        child: Text(
                          author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: ZhPalette.mutedInk,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    if (author.isNotEmpty && meta.isNotEmpty) const Spacer(),
                    if (meta.isNotEmpty)
                      Flexible(
                        flex: 2,
                        child: Text(
                          meta.join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ZhPalette.subtleInk),
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
