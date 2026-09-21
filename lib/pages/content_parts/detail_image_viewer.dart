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

@immutable
class _DetailImageSource {
  const _DetailImageSource({required this.url, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  double get aspectRatio {
    final sourceRatio =
        width != null && height != null && width! > 0 && height! > 0
        ? width! / height!
        : null;
    // Unknown dimensions still get a stable box. The image is rendered with
    // BoxFit.contain inside it, so its first decoded frame cannot reflow the
    // answer column. Extreme server values are bounded to avoid a malformed
    // payload creating an unusably tall placeholder.
    return (sourceRatio ?? 4 / 3).clamp(.28, 3.5).toDouble();
  }

  String get identity {
    final uri = Uri.tryParse(url);
    return uri == null ? url : uri.replace(query: '', fragment: '').toString();
  }
}

class _DetailImageDimensions {
  const _DetailImageDimensions({this.width, this.height});

  final double? width;
  final double? height;
}

double? _positiveImageDimension(Object? value) {
  final raw = value is num
      ? value.toDouble()
      : double.tryParse(
          (value?.toString() ?? '').trim().replaceFirst(
            RegExp(r'px$', caseSensitive: false),
            '',
          ),
        );
  return raw != null && raw.isFinite && raw > 0 ? raw : null;
}

_DetailImageDimensions? _detailImageDimensionsFromMap(
  Object? value, [
  int depth = 0,
]) {
  if (value is! Map || depth > 2) return null;
  final map = value.map((key, value) => MapEntry(key.toString(), value));
  const widthKeys = [
    'width',
    'raw_width',
    'rawWidth',
    'original_width',
    'originalWidth',
    'image_width',
    'imageWidth',
    'data-rawwidth',
    'data_raw_width',
    'natural_width',
    'naturalWidth',
  ];
  const heightKeys = [
    'height',
    'raw_height',
    'rawHeight',
    'original_height',
    'originalHeight',
    'image_height',
    'imageHeight',
    'data-rawheight',
    'data_raw_height',
    'natural_height',
    'naturalHeight',
  ];
  double? read(List<String> keys) {
    for (final key in keys) {
      final dimension = _positiveImageDimension(map[key]);
      if (dimension != null) return dimension;
    }
    return null;
  }

  var width = read(widthKeys);
  var height = read(heightKeys);
  if (width != null && height != null) {
    return _DetailImageDimensions(width: width, height: height);
  }
  for (final key in const [
    'size',
    'dimensions',
    'original',
    'original_size',
    'originalSize',
    'image_size',
    'imageSize',
    'metadata',
  ]) {
    final nested = _detailImageDimensionsFromMap(map[key], depth + 1);
    if (nested == null) continue;
    width ??= nested.width;
    height ??= nested.height;
    if (width != null && height != null) break;
  }
  return width == null && height == null
      ? null
      : _DetailImageDimensions(width: width, height: height);
}

String _detailImageAttribute(String tag, String name) {
  final match = RegExp(
    "\\b${RegExp.escape(name)}\\s*=\\s*(?:\"([^\"]*)\"|'([^']*)')",
    caseSensitive: false,
  ).firstMatch(tag);
  return (match?.group(1) ?? match?.group(2) ?? '').trim();
}

String _detailImageUrl(Object? value) {
  var raw = value?.toString().trim() ?? '';
  if (raw.startsWith('//')) raw = 'https:$raw';
  final uri = Uri.tryParse(raw.replaceAll('&amp;', '&'));
  if (uri == null || uri.scheme.toLowerCase() != 'https' || uri.host.isEmpty) {
    return '';
  }
  return uri.toString();
}

Map<String, _DetailImageDimensions> _detailHtmlImageDimensions(String html) {
  final result = <String, _DetailImageDimensions>{};
  final imageTags = RegExp(r'<img\b[^>]*>', caseSensitive: false);
  for (final match in imageTags.allMatches(html)) {
    final tag = match.group(0) ?? '';
    var url = '';
    for (final attribute in const [
      'data-original',
      'data-original-src',
      'data-original-url',
      'data-actualsrc',
      'data-src',
      'src',
    ]) {
      url = _detailImageUrl(_detailImageAttribute(tag, attribute));
      if (url.isNotEmpty) break;
    }
    if (url.isEmpty) continue;
    final width =
        _positiveImageDimension(_detailImageAttribute(tag, 'data-rawwidth')) ??
        _positiveImageDimension(_detailImageAttribute(tag, 'width'));
    final height =
        _positiveImageDimension(_detailImageAttribute(tag, 'data-rawheight')) ??
        _positiveImageDimension(_detailImageAttribute(tag, 'height'));
    if (width != null || height != null) {
      final uri = Uri.parse(url).replace(query: '', fragment: '').toString();
      result[uri] = _DetailImageDimensions(width: width, height: height);
    }
  }
  return result;
}

_DetailImageSource _detailImageSource(
  String url, {
  Object? metadata,
  Map<String, _DetailImageDimensions>? htmlDimensions,
}) {
  final mapDimensions = _detailImageDimensionsFromMap(metadata);
  final htmlDimension = htmlDimensions == null
      ? null
      : htmlDimensions[(Uri.tryParse(
              url,
            )?.replace(query: '', fragment: '').toString() ??
            url)];
  return _DetailImageSource(
    url: url,
    width: mapDimensions?.width ?? htmlDimension?.width,
    height: mapDimensions?.height ?? htmlDimension?.height,
  );
}

int _detailImageCacheWidth(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final physicalWidth = mediaQuery.size.width * mediaQuery.devicePixelRatio;
  return physicalWidth.round().clamp(480, 1920).toInt();
}

class _DetailImageWarmup extends StatefulWidget {
  const _DetailImageWarmup({required this.sources, required this.child});

  final List<_DetailImageSource> sources;
  final Widget child;

  @override
  State<_DetailImageWarmup> createState() => _DetailImageWarmupState();
}

class _DetailImageWarmupState extends State<_DetailImageWarmup> {
  final _scheduled = <String>{};

  @override
  void initState() {
    super.initState();
    _schedulePending();
  }

  @override
  void didUpdateWidget(covariant _DetailImageWarmup oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedulePending();
  }

  void _schedulePending() {
    final pending = <_DetailImageSource>[];
    for (final source in widget.sources) {
      if (source.url.isEmpty || !_scheduled.add(source.identity)) continue;
      pending.add(source);
    }
    if (pending.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_precacheConcurrently(pending));
    });
  }

  Future<void> _precacheConcurrently(List<_DetailImageSource> sources) async {
    var cursor = 0;
    final workerCount = math.min(3, sources.length);
    Future<void> worker() async {
      while (true) {
        if (!mounted || cursor >= sources.length) return;
        final source = sources[cursor++];
        try {
          final provider = ResizeImage.resizeIfNeeded(
            _detailImageCacheWidth(context),
            null,
            ZhihuCachedNetworkImageProvider(
              source.url,
              headers: zhihuImageRequestHeaders,
            ),
          );
          await precacheImage(provider, context);
        } catch (_) {
          // The visible tile keeps its reserved placeholder and owns the
          // normal ImageProvider retry/eviction behaviour.
        }
      }
    }

    await Future.wait(
      List<Future<void>>.generate(workerCount, (_) => worker()),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _DetailImageGallery extends StatelessWidget {
  const _DetailImageGallery({required this.sources});

  final List<_DetailImageSource> sources;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${sources.length} 张正文图片',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < sources.length; index++) ...[
            _DetailImageTile(source: sources[index]),
            if (index != sources.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _DetailImageTile extends StatelessWidget {
  const _DetailImageTile({required this.source});

  final _DetailImageSource source;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '查看正文图片原图',
    child: InkWell(
      key: ValueKey('answer-image-${source.url}'),
      onTap: () => _showDetailImagePreview(context, source.url),
      borderRadius: BorderRadius.circular(ZhRadius.card),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ZhRadius.card),
        child: AspectRatio(
          aspectRatio: source.aspectRatio,
          child: ZhihuImage.network(
            source.url,
            headers: zhihuImageRequestHeaders,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            cacheWidth: _detailImageCacheWidth(context),
            filterQuality: FilterQuality.medium,
            frameBuilder: (_, child, frame, _) =>
                frame == null ? const _DetailImagePlaceholder() : child,
            errorBuilder: (_, _, _) =>
                const _DetailImagePlaceholder(failed: true),
          ),
        ),
      ),
    ),
  );
}

class _DetailImagePlaceholder extends StatelessWidget {
  const _DetailImagePlaceholder({this.failed = false});

  final bool failed;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFF4F5F6),
    child: Center(
      child: failed
          ? const Icon(
              Icons.image_not_supported_outlined,
              color: ZhPalette.subtleInk,
            )
          : const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
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
