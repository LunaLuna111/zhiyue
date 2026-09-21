part of '../salt_page.dart';

Widget? _saltProductHeader(
  BuildContext context,
  Map<String, dynamic> response,
) {
  final parent = _saltMap(response['parent']);
  final extra = response['extra'];
  final paging = response['paging'];
  var updateText = extra is Map
      ? _saltMetadataText(_saltMap(extra), const [
          'update_text',
          'latest_update_text',
          'last_update_text',
          'online_time_text',
        ])
      : '';
  if (updateText.isEmpty) {
    updateText = _saltMetadataText(parent, const [
      'update_text',
      'latest_update_text',
      'last_update_text',
      'online_time_text',
      'published_text',
    ]);
  }
  final totalValue = paging is Map ? paging['totals'] ?? paging['total'] : null;
  final total =
      _saltPositiveMetadataInt(parent, const [
        'section_count',
        'chapter_count',
        'total_section_count',
        'xxxxxxxx_total',
        'total',
      ]) ??
      (totalValue is num
          ? totalValue.round()
          : int.tryParse(plainText(totalValue).replaceAll(',', ''))) ??
      _saltCountFromText(
        _saltMetadataText(parent, const [
          'sub_title',
          'subtitle',
          'status_text',
          'completion_text',
        ]),
      );
  final updatedTo = _saltPositiveMetadataInt(parent, const [
    'updated_section_count',
    'latest_section_number',
    'latest_section_index',
    'current_section_count',
    'section_count',
    'chapter_count',
  ]);
  final subtitle = _saltMetadataText(parent, const ['sub_title', 'subtitle']);
  final introduction = saltProductIntroduction(parent);
  final typeName = _saltTypeLabel(parent);
  final completion = _saltCompletionLabel(parent);
  final likeMap = _saltMap(parent?['like']);
  var likeText = _saltMetadataText(parent, const [
    'like_text',
    'like_count_text',
    'like_count',
  ]);
  if (likeText.isEmpty) {
    likeText = _saltMetadataText(likeMap, const [
      'like_text',
      'count_text',
      'like_count',
      'count',
    ]);
  }
  Map<String, dynamic>? author = _saltMergePersonMaps([
    response['author'],
    response['author_info'],
    response['xxxxx_author_info'],
    parent?['author'],
    parent?['author_info'],
    parent?['xxxxx_author_info'],
  ]);
  if (author == null && response['data'] is List) {
    for (final row in response['data'] as List) {
      final rowMap = _saltMap(row);
      author = _saltMergePersonMaps([
        rowMap?['author'],
        rowMap?['author_info'],
        rowMap?['xxxxx_author_info'],
      ]);
      if (author != null) break;
    }
  }
  author ??= _saltMergePersonMaps([
    parent?['producer'],
    parent?['producer_info'],
    response['producer'],
    response['producer_info'],
  ]);
  final authorName = _saltPersonField(author, const [
    'nickname',
    'nick_name',
    'name',
    'full_name',
    'display_name',
    'author_name',
    'authorName',
    'username',
    'user_name',
    'screen_name',
    'title',
  ]);
  final authorHeadline = _saltPersonField(author, const [
    'headline',
    'headline_render',
    'description',
    'intro',
    'sub_title',
  ]);
  final authorBio = _saltPersonField(author, const [
    'bio',
    'biography',
    'profile',
    'introduction',
  ]);
  final authorDetails = <String>[];
  for (final detail in [authorHeadline, authorBio]) {
    if (detail.isNotEmpty && !authorDetails.contains(detail)) {
      authorDetails.add(detail);
    }
  }
  final authorAvatar = _saltPersonField(author, const [
    'head',
    'avatar',
    'avatar_url',
    'avatarUrl',
    'image',
    'image_url',
  ]);
  final explicitProducerName =
      _saltMetadataText(parent, const [
        'producer_name',
        'producer',
        'author_name',
      ]).isNotEmpty
      ? _saltMetadataText(parent, const [
          'producer_name',
          'producer',
          'author_name',
        ])
      : _saltMetadataText(response, const [
          'producer_name',
          'producer',
          'author_name',
        ]);
  final producerName = explicitProducerName.isNotEmpty
      ? explicitProducerName
      : authorName;
  final brandLabel =
      _saltMetadataText(parent, const [
        'brand_label',
        'label_text',
        'producer_label',
      ]).isNotEmpty
      ? _saltMetadataText(parent, const [
          'brand_label',
          'label_text',
          'producer_label',
        ])
      : typeName == '长篇'
      ? '长篇'
      : '';
  final typeEnglish = _saltMetadataText(parent, const [
    'type_en',
    'type_name_en',
    'content_type',
  ]);
  final reportType = _saltMetadataText(parent, const ['report_type']);
  final purchaseCard = _saltMap(parent?['vip_purchase_card']);
  final isVip =
      _saltMetadataBool(parent, const ['is_vip_resource', 'is_vip', 'vip']) ==
          true ||
      purchaseCard != null;
  final isOnShelf =
      _saltMetadataBool(parent, const [
        'has_interested',
        'on_shelves',
        'on_shelf',
        'is_on_shelves',
      ]) ==
      true;
  final isLiked =
      _saltMetadataBool(parent, const ['is_like', 'is_liked']) == true;
  final purchaseText = _saltMetadataText(purchaseCard, const [
    'text',
    'button_text',
  ]);
  var wordCountText = _saltMetadataText(parent, const [
    'word_count_text',
    'word_count_label',
    'words_text',
  ]);
  if (wordCountText.isEmpty) {
    final wordCount = _saltPositiveMetadataInt(parent, const ['word_count']);
    if (wordCount != null) wordCountText = '${compactCount(wordCount)} 字';
  }
  final capacityText = _saltMetadataText(parent, const [
    'sku_cap_text',
    'capacity_text',
    'content_capacity_text',
  ]);
  final hasAudio =
      _saltMetadataBool(parent, const ['has_tts', 'has_audio', 'is_audio']) ==
      true;
  final recommendReason = _saltMetadataText(parent, const [
    'recommend_reason',
    'recommend_text',
  ]);
  final progressText = _saltMetadataText(parent, const [
    'progress_text',
    'learn_progress_text',
  ]);
  final onlineTimeText = _saltMetadataText(parent, const [
    'online_time_text',
    'published_text',
  ]);
  final updatedCount = _saltMetadataInt(parent, const [
    'new_section_count',
    'updated_count',
    'update_count',
  ]);
  final commentScore = _saltMetadataText(parent, const [
    'comment_score',
    'score_text',
  ]);
  final commentCount = _saltPositiveMetadataInt(parent, const [
    'comment_count',
    'comments_count',
    'comments',
  ]);
  final viewCount = _saltPositiveMetadataInt(parent, const [
    'view_count',
    'views_count',
    'browse_count',
    'read_count',
  ]);
  final favoriteText = _saltMetadataText(parent, const [
    'favorite_text',
    'favorite_count_text',
    'favorite_count',
  ]);
  final parentMeta = _saltMetadataLabels(parent, const [
    'bottom_meta',
    'meta_info',
  ]).where((item) => item.length <= 24).take(3).toList(growable: false);
  final artworkObject = _saltMap(parent?['artwork']);
  final artwork = plainText(
    artworkObject?['url'] ??
        parent?['artwork'] ??
        parent?['tab_artwork'] ??
        parent?['cover_url'],
  );
  final validArtwork = Uri.tryParse(artwork)?.scheme == 'https';
  final validAuthorAvatar = Uri.tryParse(authorAvatar)?.scheme == 'https';
  final labels = _saltMetadataLabels(parent, const ['labels'])
      .where(
        (label) =>
            label != typeName &&
            label != brandLabel &&
            label != 'VIP' &&
            label != completion,
      )
      .take(4)
      .toList(growable: false);
  if (parent == null && updateText.isEmpty && total == null) return null;
  final summaryLine = _saltProductProgressText(
    explicit: subtitle,
    completion: completion,
    updatedTo: updatedTo,
    total: total,
  );
  final infoPills = <Widget>[
    if (typeName.isNotEmpty) ZhPill(label: typeName, compact: true),
    if (isVip) const ZhPill(label: 'VIP', compact: true),
    if (completion.isNotEmpty && !summaryLine.contains(completion))
      ZhPill(label: completion, compact: true),
    if (hasAudio) const ZhPill(label: '可听', compact: true),
    if (isOnShelf) const ZhPill(label: '已加入书架', compact: true),
    if (isLiked) const ZhPill(label: '已赞', compact: true),
    for (final label in labels) ZhPill(label: label, compact: true),
  ];
  final facts = <String>[
    if (wordCountText.isNotEmpty) wordCountText,
    if (capacityText.isNotEmpty && capacityText != wordCountText) capacityText,
    if (likeText.isNotEmpty) '点赞 ${_saltMetricValue(likeText)}',
    if (favoriteText.isNotEmpty) '收藏 ${_saltMetricValue(favoriteText)}',
    if (commentCount != null) '评论 ${compactCount(commentCount)}',
    if (viewCount != null) '浏览 ${compactCount(viewCount)}',
    if (commentScore.isNotEmpty) '评分 $commentScore',
    if (progressText.isNotEmpty) progressText,
    if (onlineTimeText.isNotEmpty) onlineTimeText,
    if (updatedCount != null && updatedCount > 0) '更新 $updatedCount 节',
    if (typeEnglish.isNotEmpty && typeEnglish != typeName) typeEnglish,
    if (reportType.isNotEmpty) reportType,
    ...parentMeta,
  ];
  return Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ZhPalette.canvas,
            border: Border.all(color: ZhPalette.border),
            borderRadius: BorderRadius.circular(ZhRadius.hero),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: validArtwork
                    ? ZhihuImage.network(
                        artwork,
                        headers: zhihuImageRequestHeaders,
                        width: 112,
                        height: 150,
                        fit: BoxFit.cover,
                        cacheWidth: 336,
                        cacheHeight: 450,
                        filterQuality: FilterQuality.low,
                        frameBuilder: (_, child, frame, _) =>
                            frame == null ? _saltHeaderPlaceholder() : child,
                        errorBuilder: (_, _, _) => _saltHeaderPlaceholder(),
                      )
                    : _saltHeaderPlaceholder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (infoPills.isNotEmpty)
                      Wrap(spacing: 6, runSpacing: 6, children: infoPills),
                    if (summaryLine.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        summaryLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                    if (producerName.isNotEmpty ||
                        authorAvatar.isNotEmpty ||
                        authorDetails.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: ClipOval(
                              child: validAuthorAvatar
                                  ? ZhihuImage.network(
                                      authorAvatar,
                                      headers: zhihuImageRequestHeaders,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      cacheWidth: 96,
                                      cacheHeight: 96,
                                      filterQuality: FilterQuality.low,
                                      frameBuilder: (_, child, frame, _) =>
                                          frame == null
                                          ? _saltAuthorAvatarPlaceholder()
                                          : child,
                                      errorBuilder: (_, _, _) =>
                                          _saltAuthorAvatarPlaceholder(),
                                    )
                                  : _saltAuthorAvatarPlaceholder(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  producerName.isEmpty ? '作者' : producerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (authorDetails.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    authorDetails.join(' · '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: ZhPalette.mutedInk,
                                          height: 1.35,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (brandLabel.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        brandLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.mutedInk,
                        ),
                      ),
                    ],
                    if (purchaseText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        purchaseText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: ZhPalette.mutedInk),
                      ),
                    ],
                    if (facts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          for (final fact in facts)
                            Text(
                              fact,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: ZhPalette.mutedInk),
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
        if (introduction.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: ZhPalette.background,
              border: Border.all(color: ZhPalette.border),
              borderRadius: BorderRadius.circular(ZhRadius.input),
            ),
            child: Text(
              introduction,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ZhPalette.mutedInk,
                height: 1.55,
              ),
            ),
          ),
        ],
        if (recommendReason.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  recommendReason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: ZhPalette.mutedInk),
                ),
              ),
            ],
          ),
        ],
        if (updateText.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.update_rounded, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  updateText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              '目录',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const Spacer(),
            if (total != null)
              Text(
                '共 $total 节',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ZhPalette.mutedInk,
                  letterSpacing: 0,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
