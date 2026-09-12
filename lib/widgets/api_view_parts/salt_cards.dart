part of '../api_views.dart';

const int saltStoryCoverCacheWidth = 426;

class SaltCatalogCard extends StatelessWidget {
  const SaltCatalogCard({
    super.key,
    required this.value,
    this.onTap,
    this.coverWidth = 56,
    this.coverHeight = 78,
  });

  final Map<String, dynamic> value;
  final VoidCallback? onTap;
  final double coverWidth;
  final double coverHeight;

  @override
  Widget build(BuildContext context) {
    final object = unwrapObject(value);
    final title = _saltText(object, const [
      'title',
      'content_title',
      'question_title',
      'name',
    ]);
    var excerpt = _saltText(object, const [
      'description',
      'content',
      'subtitle',
      'sub_title',
      'sub_content',
    ]);
    if (excerpt.isEmpty && object['description_list'] is List) {
      excerpt = (object['description_list'] as List)
          .map(plainText)
          .where((item) => item.isNotEmpty)
          .take(2)
          .join(' · ');
    }
    final artwork = _saltText(object, const ['artwork', 'image_url']);
    final recommendReason = _saltText(object, const ['recommend_reason']);
    final progress = _saltText(object, const ['progress_text']);
    final likeText = _saltText(object, const ['like_text']);
    final likeCountText = _sectionCountText(object['like_count']);
    final commentCountText = _sectionCountText(object['comment_count']);
    final wordCount = _saltText(object, const ['word_count_text']);
    final rawWordCount = _sectionCountText(object['word_count']);
    final contentCount = _saltText(object, const [
      'content_count_text',
      'content_count',
    ]);
    final bottomRightText = _saltText(object, const ['bottom_right_text']);
    final producerName = _saltText(object, const [
      'producer_name',
      'producer',
      'author_name',
    ]);
    final capacityText = _saltText(object, const ['sku_cap_text']);
    final labels = object['labels'] is List
        ? (object['labels'] as List)
              .map(_saltLabel)
              .where((label) => label.isNotEmpty)
              .take(2)
              .toList()
        : const <String>[];
    final sellLabels = object['sell_labels'] is List
        ? (object['sell_labels'] as List)
              .map(_saltLabel)
              .where((label) => label.isNotEmpty)
              .take(2)
              .toList()
        : const <String>[];
    final moduleTitle = plainText(object['_salt_module_title']);
    final groupTitle = plainText(object['_salt_group_title']);
    final showGroupHeader = object['_salt_group_first'] == true;
    final isLimitFree = object['is_limit_free'] == true;
    final hasTts = object['has_tts'] == true;
    final statusText = _saltText(object, const ['status_text']);
    final updateText = _saltText(object, const ['update_text']);
    final viewCountText = _sectionCountText(object['view_count']);
    final favoriteCountText = _sectionCountText(object['favorite_count']);
    final downloadedCount =
        _sectionInt(object['_downloaded_section_count']) ?? 0;
    final totalSectionCount =
        _sectionInt(object['_total_section_count']) ??
        _sectionInt(object['section_count']) ??
        _sectionInt(object['content_count']);
    final downloadText = downloadedCount > 0
        ? totalSectionCount != null && totalSectionCount > 0
              ? '$downloadedCount/$totalSectionCount 已下载'
              : '$downloadedCount 节已下载'
        : '';
    final validArtwork = Uri.tryParse(artwork)?.scheme == 'https';
    final businessType = _saltText(object, const [
      'business_type',
      'content_type',
    ]).toLowerCase();
    final kindLabel = businessType.contains('audio')
        ? '盐选音频'
        : businessType.contains('video')
        ? '盐选视频'
        : '盐选故事';
    final card = ZhSurface(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: ZhSpace.md, vertical: 6),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: validArtwork
                ? ZhihuImage.network(
                    artwork,
                    headers: zhihuImageRequestHeaders,
                    width: coverWidth,
                    height: coverHeight,
                    fit: BoxFit.cover,
                    cacheWidth: saltStoryCoverCacheWidth,
                    filterQuality: FilterQuality.medium,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : _SaltCoverPlaceholder(
                            width: coverWidth,
                            height: coverHeight,
                          ),
                    errorBuilder: (_, _, _) => _SaltCoverPlaceholder(
                      width: coverWidth,
                      height: coverHeight,
                    ),
                  )
                : _SaltCoverPlaceholder(width: coverWidth, height: coverHeight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    ZhPill(label: kindLabel, compact: true),
                    if (isLimitFree) const ZhPill(label: '限时免费', compact: true),
                    for (final label in labels)
                      ZhPill(label: label, compact: true),
                    for (final label in sellLabels)
                      if (!labels.contains(label))
                        ZhPill(label: label, compact: true),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  title.isEmpty ? '未命名盐选内容' : title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (producerName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    producerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: ZhPalette.mutedInk,
                    ),
                  ),
                ],
                if (excerpt.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    excerpt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ZhPalette.mutedInk,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (recommendReason.isNotEmpty ||
                    progress.isNotEmpty ||
                    likeText.isNotEmpty ||
                    likeCountText.isNotEmpty ||
                    commentCountText.isNotEmpty ||
                    wordCount.isNotEmpty ||
                    rawWordCount.isNotEmpty ||
                    statusText.isNotEmpty ||
                    updateText.isNotEmpty ||
                    viewCountText.isNotEmpty ||
                    favoriteCountText.isNotEmpty ||
                    downloadText.isNotEmpty ||
                    capacityText.isNotEmpty ||
                    contentCount.isNotEmpty ||
                    bottomRightText.isNotEmpty ||
                    hasTts) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 5,
                    children: [
                      if (recommendReason.isNotEmpty)
                        _CardMetric(
                          icon: Icons.auto_awesome_outlined,
                          label: recommendReason,
                          semanticLabel: recommendReason,
                        ),
                      if (likeText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.change_history_outlined,
                          label: likeText,
                          semanticLabel: likeText,
                        ),
                      if (likeText.isEmpty && likeCountText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.change_history_outlined,
                          label: likeCountText,
                          semanticLabel: '点赞 $likeCountText',
                        ),
                      if (commentCountText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: commentCountText,
                          semanticLabel: '评论 $commentCountText',
                        ),
                      if (wordCount.isNotEmpty)
                        _CardMetric(
                          icon: Icons.subject_rounded,
                          label: wordCount,
                          semanticLabel: wordCount,
                        ),
                      if (wordCount.isEmpty && rawWordCount.isNotEmpty)
                        _CardMetric(
                          icon: Icons.subject_rounded,
                          label: '$rawWordCount 字',
                          semanticLabel: '$rawWordCount 字',
                        ),
                      if (statusText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.pending_outlined,
                          label: statusText,
                          semanticLabel: statusText,
                        ),
                      if (updateText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.update_rounded,
                          label: updateText,
                          semanticLabel: updateText,
                        ),
                      if (viewCountText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.visibility_outlined,
                          label: viewCountText,
                          semanticLabel: '阅读 $viewCountText',
                        ),
                      if (favoriteCountText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.bookmark_border_rounded,
                          label: favoriteCountText,
                          semanticLabel: '收藏 $favoriteCountText',
                        ),
                      if (downloadText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.download_done_rounded,
                          label: downloadText,
                          semanticLabel: downloadText,
                        ),
                      if (capacityText.isNotEmpty && capacityText != wordCount)
                        _CardMetric(
                          icon: Icons.menu_book_outlined,
                          label: capacityText,
                          semanticLabel: capacityText,
                        ),
                      if (contentCount.isNotEmpty)
                        _CardMetric(
                          icon: Icons.format_list_numbered_rounded,
                          label: contentCount,
                          semanticLabel: contentCount,
                        ),
                      if (bottomRightText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.info_outline_rounded,
                          label: bottomRightText,
                          semanticLabel: bottomRightText,
                        ),
                      if (progress.isNotEmpty)
                        _CardMetric(
                          icon: Icons.timelapse_rounded,
                          label: progress,
                          semanticLabel: progress,
                        ),
                      if (hasTts)
                        const _CardMetric(
                          icon: Icons.headphones_outlined,
                          label: '可听',
                          semanticLabel: '支持听书',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.arrow_forward_rounded, size: 19),
            ),
          ],
        ],
      ),
    );
    if (!showGroupHeader || (moduleTitle.isEmpty && groupTitle.isEmpty)) {
      return card;
    }
    final heading = groupTitle.isNotEmpty ? groupTitle : moduleTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ZhSectionHeader(
          title: heading,
          description: groupTitle.isNotEmpty && moduleTitle.isNotEmpty
              ? moduleTitle
              : null,
        ),
        card,
      ],
    );
  }

  String _saltText(Map<String, dynamic> object, List<String> keys) {
    for (final key in keys) {
      final raw = object[key];
      final value = raw is Map
          ? plainText(
              raw['url'] ??
                  raw['text'] ??
                  raw['name'] ??
                  raw['title'] ??
                  raw['content'],
            )
          : plainText(raw);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _saltLabel(Object? value) {
    final map = _cardMap(value);
    return plainText(map?['name'] ?? map?['title'] ?? map?['text'] ?? value);
  }
}

class _SaltCoverPlaceholder extends StatelessWidget {
  const _SaltCoverPlaceholder({this.width = 56, this.height = 78});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    color: ZhPalette.canvas,
    alignment: Alignment.center,
    child: const Icon(Icons.auto_stories_outlined, size: 26),
  );
}

class SaltSectionCard extends StatelessWidget {
  const SaltSectionCard({super.key, required this.value, this.onTap});

  final Map<String, dynamic> value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final object = unwrapObject(value);
    final chapter = _cardMap(object['chapter']);
    final index = _cardMap(object['index']);
    final artwork = _cardMap(object['artwork']);
    final resource = _cardMap(object['resource']);
    final resourceData = _cardMap(resource?['data']);
    final comment = _cardMap(object['comment']);
    final reaction = _cardMap(object['reaction_count']);
    final progress = _cardMap(
      _cardMap(object['cli_progress'])?['unit_progress'],
    );
    final title = plainText(object['title']);
    final chapterTitle = plainText(chapter?['title']);
    final serial = plainText(
      object['serial_number_text'] ??
          index?['serial_number_txt'] ??
          chapter?['serial_number_txt'],
    );
    final abstract = plainText(resourceData?['content_abstract']);
    final meta = _saltMetaLabels(object);
    final artworkUrl = plainText(artwork?['url'] ?? object['artwork']);
    final validArtwork = Uri.tryParse(artworkUrl)?.scheme == 'https';
    final ownership = plainText(
      object['ownership_type'] ?? object['section_ownership_type'],
    ).toLowerCase();
    final locked = object['is_lock'] == true || object['is_locked'] == true;
    final vip = object['vip_tag'] == true;
    final directProgressText = plainText(object['progress_text']);
    final progressText = directProgressText.isNotEmpty
        ? directProgressText
        : _sectionProgressText(progress);
    final likeCount = _sectionInt(reaction?['like_count']);
    final commentCount = _sectionInt(comment?['count']);
    final likeText = plainText(object['like_text']);
    final wordCountValue = _sectionInt(object['word_count']);
    final directWordCount = plainText(object['word_count_text']);
    final wordCountText = directWordCount.isNotEmpty
        ? directWordCount
        : wordCountValue == null || wordCountValue <= 0
        ? ''
        : '${compactCount(wordCountValue)} 字';
    final isLimitFree = object['is_limit_free'] == true;
    final hasTts = object['has_tts'] == true;
    final lastRead = object['last_read'] == true;
    final readFinished = object['read_finished'] == true;
    final metaText = meta.join(' ');
    final metaHasLikes = metaText.contains('点赞') || metaText.contains('赞');
    final metaHasComments = metaText.contains('评论');
    final type = plainText(resource?['type']);

    return ZhSurface(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: ZhSpace.sm, vertical: 4),
      padding: const EdgeInsets.all(ZhSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (validArtwork)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ZhihuImage.network(
                artworkUrl,
                headers: zhihuImageRequestHeaders,
                width: 52,
                height: 64,
                fit: BoxFit.cover,
                cacheWidth: 156,
                cacheHeight: 192,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => _SectionIndexTile(serial: serial),
              ),
            )
          else
            _SectionIndexTile(serial: serial),
          const SizedBox(width: ZhSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (chapterTitle.isNotEmpty)
                      ZhPill(label: chapterTitle, compact: true),
                    if (ownership == 'free')
                      const ZhPill(label: '免费', compact: true),
                    if (ownership == 'try')
                      const ZhPill(label: '试读', compact: true),
                    if (isLimitFree) const ZhPill(label: '限时免费', compact: true),
                    if (vip) const ZhPill(label: '盐选会员', compact: true),
                    if (locked) const ZhPill(label: '需权益', compact: true),
                    if (lastRead) const ZhPill(label: '上次读到', compact: true),
                    if (readFinished) const ZhPill(label: '已读完', compact: true),
                  ],
                ),
                if (chapterTitle.isNotEmpty ||
                    ownership.isNotEmpty ||
                    isLimitFree ||
                    vip ||
                    locked ||
                    lastRead ||
                    readFinished)
                  const SizedBox(height: 7),
                Text(
                  title.isEmpty ? '未命名章节' : title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (abstract.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    abstract,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ZhPalette.mutedInk,
                      height: 1.42,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    meta.join(' · '),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: ZhPalette.subtleInk),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (progressText.isNotEmpty ||
                    (likeCount != null && !metaHasLikes) ||
                    likeText.isNotEmpty ||
                    (commentCount != null && !metaHasComments) ||
                    wordCountText.isNotEmpty ||
                    hasTts ||
                    type.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 13,
                    runSpacing: 5,
                    children: [
                      if (progressText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.timelapse_rounded,
                          label: progressText,
                          semanticLabel: progressText,
                        ),
                      if (likeCount != null && !metaHasLikes)
                        _CardMetric(
                          icon: Icons.change_history_outlined,
                          label: compactCount(likeCount),
                          semanticLabel: '点赞 ${compactCount(likeCount)}',
                        ),
                      if (likeCount == null && likeText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.change_history_outlined,
                          label: likeText,
                          semanticLabel: likeText,
                        ),
                      if (commentCount != null && !metaHasComments)
                        _CardMetric(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: compactCount(commentCount),
                          semanticLabel: '评论 ${compactCount(commentCount)}',
                        ),
                      if (wordCountText.isNotEmpty)
                        _CardMetric(
                          icon: Icons.subject_rounded,
                          label: wordCountText,
                          semanticLabel: wordCountText,
                        ),
                      if (hasTts)
                        const _CardMetric(
                          icon: Icons.headphones_outlined,
                          label: '可听',
                          semanticLabel: '支持听书',
                        ),
                      if (type.isNotEmpty)
                        _CardMetric(
                          icon: type.toLowerCase().contains('audio')
                              ? Icons.headphones_outlined
                              : Icons.menu_book_outlined,
                          label: _saltResourceLabel(type),
                          semanticLabel: _saltResourceLabel(type),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(
              locked ? Icons.lock_outline_rounded : Icons.arrow_forward_rounded,
              size: 19,
              color: locked ? ZhPalette.subtleInk : ZhPalette.ink,
            ),
          ],
        ],
      ),
    );
  }

  static String _saltResourceLabel(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('audio')) return '音频';
    if (normalized.contains('video')) return '视频';
    if (normalized.contains('slide')) return '课件';
    return '图文';
  }
}

class _SectionIndexTile extends StatelessWidget {
  const _SectionIndexTile({required this.serial});

  final String serial;

  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 64,
    decoration: BoxDecoration(
      color: ZhPalette.canvas,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: ZhPalette.border),
    ),
    alignment: Alignment.center,
    child: serial.isEmpty
        ? const Icon(Icons.menu_book_outlined, size: 23)
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              serial,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
  );
}

Map<String, dynamic>? _cardMap(Object? value) {
  if (value is! Map) return null;
  return value.map((key, value) => MapEntry(key.toString(), value));
}

List<String> _saltMetaLabels(Map<String, dynamic> object) {
  final labels = <String>[];
  for (final key in const ['meta_v3', 'meta_v2']) {
    final value = object[key];
    if (value is! List) continue;
    for (final item in value) {
      final text = plainText(_cardMap(item)?['content'] ?? item);
      if (text.isNotEmpty && !labels.contains(text)) labels.add(text);
      if (labels.length >= 3) return labels;
    }
  }
  return labels;
}

int? _sectionInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(plainText(value));
}

String _sectionCountText(Object? value) {
  final raw = plainText(value);
  if (raw.isEmpty) return '';
  final parsed = int.tryParse(raw);
  return parsed == null ? raw : compactCount(parsed);
}

String _sectionProgressText(Map<String, dynamic>? progress) {
  if (progress == null) return '';
  if (progress['is_finished'] == true) return '已读完';
  final current = progress['progress'];
  final maximum = progress['max_progress'];
  if (current is num && maximum is num && maximum > 0 && current > 0) {
    final percent = (current / maximum * 100).clamp(0, 100).round();
    return '已读 $percent%';
  }
  return '';
}
