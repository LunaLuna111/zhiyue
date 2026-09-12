part of '../content_pages.dart';

class _DetailMetadata extends StatelessWidget {
  const _DetailMetadata({
    required this.metrics,
    required this.relationship,
    required this.dateLabel,
    required this.contentLabel,
  });

  final ContentMetrics metrics;
  final AnswerRelationship relationship;
  final String dateLabel;
  final String contentLabel;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (metrics.voteupCount != null)
        _DetailMetaItem(
          icon: Icons.change_history_outlined,
          label: '${compactCount(metrics.voteupCount!)} 人赞同该$contentLabel',
        ),
      if (metrics.favoriteCount != null)
        _DetailMetaItem(
          icon: Icons.star_border_rounded,
          label: '${compactCount(metrics.favoriteCount!)} 收藏',
        ),
      if (metrics.commentCount != null)
        _DetailMetaItem(
          icon: Icons.chat_bubble_outline_rounded,
          label: '${compactCount(metrics.commentCount!)} 评论',
        ),
      if (metrics.thanksCount != null)
        _DetailMetaItem(
          icon: Icons.volunteer_activism_outlined,
          label: '${compactCount(metrics.thanksCount!)} 感谢',
        ),
      if (metrics.viewCount != null)
        _DetailMetaItem(
          icon: Icons.visibility_outlined,
          label: '${compactCount(metrics.viewCount!)} 浏览',
        ),
      if (relationship.isThanked == true)
        const _DetailMetaItem(
          icon: Icons.volunteer_activism_rounded,
          label: '已感谢',
        ),
      if (relationship.isFavorited == true)
        const _DetailMetaItem(icon: Icons.star_rounded, label: '已收藏'),
      if (relationship.isAuthor == true)
        const _DetailMetaItem(icon: Icons.person_outline, label: '我的回答'),
    ];
    if (items.isEmpty && dateLabel.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: ZhSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    if (index > 0) const SizedBox(width: 14),
                    items[index],
                  ],
                ],
              ),
            ),
          if (dateLabel.isNotEmpty) ...[
            if (items.isNotEmpty) const SizedBox(height: 7),
            Text(
              dateLabel,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: ZhPalette.subtleInk),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailMetaItem extends StatelessWidget {
  const _DetailMetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: ZhPalette.mutedInk),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _DetailImageGallery extends StatelessWidget {
  const _DetailImageGallery({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${urls.length} 张正文图片',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < urls.length; index++) ...[
            _DetailImageTile(url: urls[index]),
            if (index != urls.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _DetailImageTile extends StatelessWidget {
  const _DetailImageTile({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '查看正文图片原图',
    child: InkWell(
      key: ValueKey('answer-image-$url'),
      onTap: () => _showDetailImagePreview(context, url),
      borderRadius: BorderRadius.circular(ZhRadius.card),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ZhRadius.card),
        child: ColoredBox(
          color: ZhPalette.canvas,
          child: ZhihuImage.network(
            url,
            headers: zhihuImageRequestHeaders,
            width: double.infinity,
            // The intrinsic dimensions preserve the complete aspect ratio.
            fit: BoxFit.contain,
            alignment: Alignment.center,
            cacheWidth: 1440,
            filterQuality: FilterQuality.medium,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const SizedBox(
                    height: 96,
                    child: Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
            errorBuilder: (_, _, _) => const SizedBox(
              height: 96,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: ZhPalette.subtleInk,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _showDetailImagePreview(BuildContext context, String url) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: SizedBox.expand(
                  key: ValueKey('answer-image-preview-frame-$url'),
                  child: ZhihuImage.network(
                    url,
                    headers: zhihuImageRequestHeaders,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white70,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton.filled(
                key: const Key('answer-image-preview-close'),
                tooltip: '关闭图片',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton.filled(
                key: const Key('answer-image-preview-save'),
                tooltip: '保存到相册',
                onPressed: () => _saveDetailImage(context, url),
                icon: const Icon(Icons.download_rounded),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _saveDetailImage(BuildContext context, String url) async {
  try {
    final location = await ImageExportService.saveNetworkImage(
      url,
      headers: zhihuImageRequestHeaders,
      filePrefix: 'zhihu',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(location == null ? '图片已保存' : '已保存到相册')),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('图片保存失败，请稍后重试')));
    AppLogStore.instance.record(
      category: AppLogCategory.app,
      level: AppLogLevel.warning,
      message: '正文图片保存失败',
      details: {'error': error.toString()},
    );
  }
}
