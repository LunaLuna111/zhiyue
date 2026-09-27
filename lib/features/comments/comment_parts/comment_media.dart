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
      label: context.zhL10n.commentImagesCount(visible.length),
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
      label: context.zhL10n.commentViewImage,
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
                frameBuilder: (_, child, frame, _) => frame == null
                    ? const Center(
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : child,
                errorBuilder: (_, _, _) => Center(
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
  final l10n = context.zhL10n;
  return showZhImageViewer(
    context,
    url: url,
    keyPrefix: 'comment-image-preview',
    closeLabel: l10n.commentCloseImage,
    saveLabel: l10n.commentSaveImage,
    originalLabel: l10n.detailViewImage,
    shareLabel: l10n.commonShare,
    filePrefix: 'zhiyue',
    savedMessage: (location) =>
        l10n.commentSavedTo(location ?? l10n.commonSave),
    saveFailedMessage: l10n.commentSaveFailed,
  );
}
