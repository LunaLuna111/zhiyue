part of '../content_pages.dart';

class ObjectInspectorPage extends StatelessWidget {
  const ObjectInspectorPage({super.key, required this.value});

  final Map<String, dynamic> value;

  @override
  Widget build(BuildContext context) {
    final object = unwrapObject(value);
    final title = titleOf(value);
    final type = typeOf(value);
    final authorName = authorNameOf(value);
    final authorHeadline = authorHeadlineOf(value);
    final avatar = authorAvatarOf(value);
    final metrics = ContentMetrics.from(value);
    final date = contentDateLabel(metrics);
    final html = htmlContent(object);
    final structured = structuredContentText(object);
    final summary = html != null
        ? plainText(html)
        : structured.isNotEmpty
        ? structured
        : subtitleOf(value);
    final l10n = context.zhL10n;
    final images = contentImageUrlsOf(value);
    final metricItems = <(IconData, String)>[
      if (metrics.voteupCount case final count?)
        (Icons.change_history_outlined, l10n.metricVoteup(compactCount(count))),
      if (metrics.favoriteCount case final count?)
        (Icons.star_border_rounded, l10n.metricFavorite(compactCount(count))),
      if (metrics.commentCount case final count?)
        (
          Icons.chat_bubble_outline_rounded,
          l10n.metricComment(compactCount(count)),
        ),
      if (metrics.followerCount case final count?)
        (Icons.groups_outlined, l10n.metricFollowers(compactCount(count))),
      if (metrics.answerCount case final count?)
        (
          Icons.question_answer_outlined,
          l10n.metricAnswers(compactCount(count)),
        ),
      if (metrics.articleCount case final count?)
        (Icons.article_outlined, l10n.metricArticles(compactCount(count))),
      if (metrics.itemCount case final count?)
        (
          Icons.collections_bookmark_outlined,
          l10n.metricItems(compactCount(count)),
        ),
      if (date.isNotEmpty) (Icons.schedule_rounded, date),
    ];
    return Scaffold(
      appBar: ZhTopBar(
        title: Text(title.isEmpty ? l10n.objectDetailTitle : title),
      ),
      body: ZhResponsiveFrame(
        maxWidth: 1120,
        desktopGutter: 24,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            ZhSpace.md,
            ZhSpace.sm,
            ZhSpace.md,
            ZhSpace.xl,
          ),
          children: [
            ZhSurface(
              radius: ZhRadius.hero,
              padding: const EdgeInsets.all(ZhSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (type.isNotEmpty)
                        ZhPill(
                          label: _genericTypeLabel(type, l10n),
                          compact: true,
                        ),
                    ],
                  ),
                  if (type.isNotEmpty) const SizedBox(height: 10),
                  Text(
                    title.isEmpty ? l10n.commonUntitledContent : title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (authorName.isNotEmpty || authorHeadline.isNotEmpty) ...[
                    const SizedBox(height: ZhSpace.md),
                    Row(
                      children: [
                        _AuthorAvatar(
                          imageUrl: avatar,
                          fallback: authorName.isEmpty
                              ? l10n.commonZhihuUser.characters.first
                              : authorName.characters.first,
                          size: 38,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName.isEmpty
                                    ? l10n.commonZhihuUser
                                    : authorName,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              if (authorHeadline.isNotEmpty)
                                Text(
                                  authorHeadline,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (metricItems.isNotEmpty) ...[
                    const SizedBox(height: ZhSpace.md),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final metric in metricItems)
                          _GenericMetric(icon: metric.$1, label: metric.$2),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (images.isNotEmpty) ...[
              ZhSectionHeader(title: l10n.objectImages),
              SizedBox(height: 126, child: _GenericImageGallery(urls: images)),
            ],
            if (summary.isNotEmpty) ...[
              ZhSectionHeader(title: l10n.objectContent),
              ZhSurface(
                child: SelectableText(
                  summary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _genericTypeLabel(String type, AppLocalizations l10n) =>
      switch (type.replaceAll('search_', '').toLowerCase()) {
        'answer' => l10n.contentTypeAnswer,
        'article' => l10n.contentTypeArticle,
        'question' => l10n.contentTypeQuestion,
        'people' || 'member' => l10n.contentTypePeople,
        'topic' => l10n.contentTypeTopic,
        'column' => l10n.contentTypeColumn,
        'collection' || 'favlist' => l10n.contentTypeCollection,
        'pin' => l10n.contentTypeIdea,
        'comment' => l10n.contentTypeComment,
        final value => value.toUpperCase(),
      };
}

class _GenericMetric extends StatelessWidget {
  const _GenericMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: ZhPalette.canvas,
      borderRadius: BorderRadius.circular(ZhRadius.pill),
      border: Border.all(color: ZhPalette.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: ZhPalette.mutedInk),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class _GenericImageGallery extends StatelessWidget {
  const _GenericImageGallery({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) => ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: urls.length,
    separatorBuilder: (_, _) => const SizedBox(width: 8),
    itemBuilder: (context, index) => ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ZhihuImage.network(
        urls[index],
        headers: zhihuImageRequestHeaders,
        width: 178,
        height: 126,
        fit: BoxFit.cover,
        cacheWidth: 534,
        cacheHeight: 378,
        filterQuality: FilterQuality.low,
        frameBuilder: (_, child, frame, _) =>
            frame == null ? ColoredBox(color: ZhPalette.canvas) : child,
        errorBuilder: (_, _, _) => Container(
          width: 178,
          color: ZhPalette.canvas,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      ),
    ),
  );
}
