part of '../../../widgets/api_views.dart';

class _CommentMediaGallery extends StatelessWidget {
  const _CommentMediaGallery({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final visible = urls.take(6).toList(growable: false);
    final single = visible.length == 1;
    return Semantics(
      container: true,
      label: '${visible.length} 张评论图片',
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final url in visible)
            _CommentMediaTile(url: url, single: single),
        ],
      ),
    );
  }
}

class _CommentMediaTile extends StatelessWidget {
  const _CommentMediaTile({required this.url, required this.single});

  final String url;
  final bool single;

  @override
  Widget build(BuildContext context) {
    final width = single ? 184.0 : 92.0;
    final height = single ? 142.0 : 92.0;
    return Semantics(
      button: true,
      label: '查看评论图片',
      child: InkWell(
        key: ValueKey('comment-image-$url'),
        onTap: () => _showCommentImagePreview(context, url),
        borderRadius: BorderRadius.circular(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: width,
            height: height,
            child: ColoredBox(
              color: ZhPalette.canvas,
              child: ZhihuImage.network(
                url,
                headers: zhihuImageRequestHeaders,
                fit: single ? BoxFit.contain : BoxFit.cover,
                cacheWidth: 576,
                filterQuality: FilterQuality.medium,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                errorBuilder: (_, _, _) => const Center(
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
}

Future<void> _showCommentImagePreview(BuildContext context, String url) {
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
                  key: ValueKey('comment-image-preview-frame-$url'),
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
                key: const Key('comment-image-preview-close'),
                tooltip: '关闭图片',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton.filled(
                key: const Key('comment-image-preview-save'),
                tooltip: '保存到相册',
                onPressed: () => _saveCommentImage(context, url),
                icon: const Icon(Icons.download_rounded),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _saveCommentImage(BuildContext context, String url) async {
  try {
    final location = await ImageExportService.saveNetworkImage(
      url,
      headers: zhihuImageRequestHeaders,
      filePrefix: 'zhiyue',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已保存到${location ?? '相册'}')));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('图片保存失败，请稍后重试')));
  }
}
