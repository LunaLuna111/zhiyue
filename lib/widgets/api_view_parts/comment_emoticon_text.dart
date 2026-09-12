part of '../api_views.dart';

/// Comment text renderer matching the original client's bundled emoticons.
///
/// Only tokens from the two APK catalogs are replaced. Unknown bracket text
/// stays visible, and the replacement uses local assets only—rendering a
/// comment never creates an additional network request.
class CommentEmoticonText extends StatefulWidget {
  const CommentEmoticonText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  State<CommentEmoticonText> createState() => _CommentEmoticonTextState();
}

class _CommentEmoticonTextState extends State<CommentEmoticonText> {
  // Several official tags are longer than the old ten-character guard (for
  // example `[暗中学习]` and `[百分百赞]`).  The old expression left those
  // tags as literal text in the comment list.
  static final RegExp _tokenPattern = RegExp(r'\[[^\s\[\]\r\n]{1,32}\]');

  late Map<String, CommentEmoticon> _lookup;

  @override
  void initState() {
    super.initState();
    _lookup = bundledCommentEmoticonLookup;
    if (_lookup.isEmpty) {
      loadBundledCommentEmoticonLookup().then((value) {
        if (mounted) setState(() => _lookup = value);
      }, onError: (_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _normalizeText(widget.text);
    if (_lookup.isEmpty) {
      return Text(text, style: widget.style, textAlign: widget.textAlign);
    }

    final effectiveStyle = DefaultTextStyle.of(
      context,
    ).style.merge(widget.style);
    final textScaler = MediaQuery.textScalerOf(context);
    final scaledFontSize = textScaler.scale(effectiveStyle.fontSize ?? 14);
    // Android's original span uses the current font-metric height plus 5 px.
    // 1.2 em is a close Flutter equivalent for the metric box.
    final extent = (scaledFontSize * 1.2 + 5).clamp(20.0, 40.0);
    final spans = <InlineSpan>[];
    var cursor = 0;
    var occurrence = 0;
    for (final match in _tokenPattern.allMatches(text)) {
      final token = match.group(0) ?? '';
      final emoticon = _lookup[token];
      if (emoticon == null) continue;
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Image.asset(
            emoticon.assetImagePath,
            key: ValueKey(
              'comment-inline-emoticon-${emoticon.id}-${occurrence++}',
            ),
            width: extent,
            height: extent,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            semanticLabel: token,
            errorBuilder: (_, _, _) => SizedBox.square(
              dimension: extent,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(token, style: effectiveStyle),
              ),
            ),
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor == 0) {
      return Text(text, style: widget.style, textAlign: widget.textAlign);
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return RichText(
      text: TextSpan(style: effectiveStyle, children: spans),
      textAlign: widget.textAlign,
      textScaler: textScaler,
    );
  }

  String _normalizeText(String value) => normalizeCommentEmoticonToken(value);
}

typedef CommentLinkTapCallback = void Function(String url, String title);

/// Rich comment renderer used by both the sheet and the full reply page.
///
/// The Android client parses comment HTML before it reaches the TextView. In
/// particular, an `<a>` is rendered as its resolved title rather than its raw
/// URL and remains tappable. This widget keeps that behavior while retaining
/// the local bundled-emoticon path used by [CommentEmoticonText].
class CommentRichText extends StatefulWidget {
  const CommentRichText({
    super.key,
    required this.text,
    this.api,
    this.onLink,
    this.style,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final ZhihuApiClient? api;
  final CommentLinkTapCallback? onLink;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  State<CommentRichText> createState() => _CommentRichTextState();
}

class _CommentRichTextState extends State<CommentRichText> {
  static final Expando<Future<List<CommentEmoticonGroup>>> _remoteCatalogs =
      Expando();
  static final RegExp _tokenPattern = RegExp(r'\[[^\s\[\]\r\n]{1,32}\]');
  static final RegExp _anchorPattern = RegExp(
    r'''<a\b([^>]*)>([\s\S]*?)</a\s*>''',
    caseSensitive: false,
  );
  static final RegExp _hrefPattern = RegExp(
    r'''\bhref\s*=\s*["']([^"']+)["']''',
    caseSensitive: false,
  );
  static final RegExp _classPattern = RegExp(
    r'''\bclass\s*=\s*["']([^"']*)["']''',
    caseSensitive: false,
  );
  // Keep the renderer and the native editor/parser on one URL grammar. This
  // also recognizes bare domains such as `example.com/story`, not just
  // Zhihu-hosted links.
  static final RegExp _urlPattern = commentUrlPattern;

  late Map<String, CommentEmoticon> _lookup;
  late List<ContentNode> _segments;
  Map<String, CommentLinkPreview> _previews = const {};
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _lookup = bundledCommentEmoticonLookup;
    _segments = _parseSegments(widget.text);
    _loadLookup();
    _resolveLinks();
  }

  @override
  void didUpdateWidget(covariant CommentRichText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.api != widget.api) {
      _segments = _parseSegments(widget.text);
      _previews = const {};
      _resolveLinks();
    }
  }

  Future<void> _loadLookup() async {
    try {
      final bundled = await loadBundledCommentEmoticonLookup();
      final remoteGroups = widget.api == null
          ? const <CommentEmoticonGroup>[]
          : await (_remoteCatalogs[widget.api!] ??= widget.api!
                .loadCommentEmoticonGroups());
      final merged = <String, CommentEmoticon>{...bundled};
      for (final group in remoteGroups) {
        for (final emoticon in group.emoticons) {
          for (final token in commentEmoticonLookupKeys(emoticon.title)) {
            if (token.isNotEmpty && !merged.containsKey(token)) {
              merged[token] = emoticon;
            }
          }
        }
      }
      if (mounted && merged.isNotEmpty) setState(() => _lookup = merged);
    } catch (_) {
      // Plain text remains a correct fallback when the asset catalog is not
      // available (for example in a restricted widget test environment).
    }
  }

  void _resolveLinks() {
    final api = widget.api;
    if (api == null) return;
    final urls = _segments.where((item) => item.isLink).map((item) => item.url);
    final future = CommentLinkResolver.resolve(api, urls);
    unawaited(
      future.then((value) {
        if (mounted && value.isNotEmpty) setState(() => _previews = value);
      }),
    );
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    final effectiveStyle = DefaultTextStyle.of(
      context,
    ).style.merge(widget.style);
    final textScaler = MediaQuery.textScalerOf(context);
    final scaledFontSize = textScaler.scale(effectiveStyle.fontSize ?? 14);
    final extent = (scaledFontSize * 1.2 + 5).clamp(20.0, 40.0);
    final spans = <InlineSpan>[];
    for (final segment in _segments) {
      if (segment.text.isEmpty) continue;
      if (segment.isSticker) {
        spans.add(_remoteEmoticonSpan(segment, effectiveStyle, extent));
        continue;
      }
      if (!segment.isLink) {
        spans.addAll(_emoticonSpans(segment.text, effectiveStyle, extent));
        continue;
      }
      final preview = _previews[segment.url];
      final title = preview?.displayTitle ?? '';
      final anchorText = segment.title.trim();
      final isRawAnchor =
          anchorText.isEmpty ||
          normalizeCommentLink(anchorText) == segment.url ||
          segment.text.trim() == segment.url;
      // The native HTML parser keeps an explicit anchor label. Resolved API
      // titles replace only a raw URL span, otherwise author-provided link
      // text would unexpectedly change after the async request completes.
      final display = title.isNotEmpty && isRawAnchor ? title : segment.text;
      final recognizer = TapGestureRecognizer()
        ..onTap = () => widget.onLink?.call(segment.url, display);
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: display,
          style: effectiveStyle.copyWith(
            color: const Color(0xFF175199),
            decoration: TextDecoration.none,
          ),
          recognizer: recognizer,
        ),
      );
    }
    if (spans.isEmpty) {
      return Text('', style: widget.style, textAlign: widget.textAlign);
    }
    return RichText(
      text: TextSpan(style: effectiveStyle, children: spans),
      textAlign: widget.textAlign,
      textScaler: textScaler,
    );
  }

  InlineSpan _remoteEmoticonSpan(
    ContentNode segment,
    TextStyle style,
    double extent,
  ) {
    CommentEmoticon? local;
    for (final key in commentEmoticonLookupKeys(segment.text)) {
      final candidate = _lookup[key];
      if (candidate != null) {
        local = candidate;
        break;
      }
    }
    Widget fallback() => local == null || local.assetImagePath.isEmpty
        ? FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(segment.text, style: style),
          )
        : Image.asset(
            local.assetImagePath,
            width: extent,
            height: extent,
            fit: BoxFit.contain,
            gaplessPlayback: true,
          );
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: SizedBox.square(
        dimension: extent,
        child: ZhihuImage.network(
          segment.url,
          key: ValueKey('comment-remote-emoticon-${segment.id}'),
          headers: zhihuImageRequestHeaders,
          width: extent,
          height: extent,
          fit: BoxFit.contain,
          cacheWidth: (extent * 3).round(),
          cacheHeight: (extent * 3).round(),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : fallback(),
          errorBuilder: (_, _, _) => fallback(),
        ),
      ),
    );
  }

  List<InlineSpan> _emoticonSpans(
    String value,
    TextStyle style,
    double extent,
  ) {
    final text = _normalizeText(value);
    if (_lookup.isEmpty) return [TextSpan(text: text)];
    final spans = <InlineSpan>[];
    var cursor = 0;
    var occurrence = 0;
    for (final match in _tokenPattern.allMatches(text)) {
      final token = match.group(0) ?? '';
      final emoticon = _lookup[token];
      if (emoticon == null) continue;
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final occurrenceKey = occurrence++;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _emoticonWidget(
            emoticon,
            token: token,
            style: style,
            extent: extent,
            key: ValueKey(
              'comment-rich-emoticon-${emoticon.id}-$occurrenceKey',
            ),
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor == 0) return [TextSpan(text: text)];
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return spans;
  }

  Widget _emoticonWidget(
    CommentEmoticon emoticon, {
    required String token,
    required TextStyle style,
    required double extent,
    required Key key,
  }) {
    Widget fallback() => SizedBox.square(
      dimension: extent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(token, style: style),
      ),
    );
    if (emoticon.assetImagePath.isNotEmpty) {
      return Image.asset(
        emoticon.assetImagePath,
        key: key,
        width: extent,
        height: extent,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        semanticLabel: token,
        errorBuilder: (_, _, _) => fallback(),
      );
    }
    if (emoticon.imageUrl.isNotEmpty) {
      return ZhihuImage.network(
        emoticon.imageUrl,
        key: key,
        headers: zhihuImageRequestHeaders,
        width: extent,
        height: extent,
        fit: BoxFit.contain,
        cacheWidth: (extent * 3).round(),
        cacheHeight: (extent * 3).round(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback(),
        errorBuilder: (_, _, _) => fallback(),
      );
    }
    return fallback();
  }

  List<ContentNode> _parseSegments(String raw) {
    if (raw.trim().isEmpty) return const [];
    final result = <ContentNode>[];
    var cursor = 0;
    for (final match in _anchorPattern.allMatches(raw)) {
      _appendPlainSegments(raw.substring(cursor, match.start), result);
      final attributes = match.group(1) ?? '';
      final classes = _classPattern.firstMatch(attributes)?.group(1) ?? '';
      final href = normalizeCommentLink(
        _hrefPattern.firstMatch(attributes)?.group(1),
      );
      final innerRaw = match.group(2) ?? '';
      final inner = plainText(innerRaw);
      final isSticker = RegExp(
        r'(^|\s)comment_sticker(\s|$)',
        caseSensitive: false,
      ).hasMatch(classes);
      final isMedia =
          RegExp(
            r'(^|\s)comment_(?:img|image|gif|inline_image)(\s|$)',
            caseSensitive: false,
          ).hasMatch(classes) ||
          RegExp(r'<img\b', caseSensitive: false).hasMatch(innerRaw) ||
          _isImagePlaceholder(inner, href);
      if (isSticker) {
        if (inner.isNotEmpty && href.isNotEmpty) {
          result.add(
            ContentNode.sticker(
              inner,
              url: href,
              id: 'comment-sticker-${result.length}',
              title: inner,
            ),
          );
        } else if (inner.isNotEmpty) {
          _appendPlainSegments(inner, result);
        }
      } else if (isMedia) {
        // Image comments are rendered by _CommentMediaGallery. Rendering the
        // placeholder anchor here produces a blue “[图片]”/URL text node.
      } else if (href.isEmpty) {
        if (inner.isNotEmpty) {
          _appendPlainSegments(inner, result);
        }
      } else {
        result.add(
          ContentNode.link(
            inner.isEmpty ? href : inner,
            url: href,
            id: 'comment-link-${result.length}',
            title: inner,
          ),
        );
      }
      cursor = match.end;
    }
    _appendPlainSegments(raw.substring(cursor), result);
    return List.unmodifiable(result);
  }

  bool _isImagePlaceholder(String text, String href) {
    final label = text.trim().replaceAll(RegExp(r'\s+'), '');
    if (label != '[图片]' && label != '图片' && label != '[照片]') return false;
    final uri = Uri.tryParse(href);
    if (uri == null) return false;
    final path = uri.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif') ||
        uri.host.contains('zhimg.com');
  }

  void _appendPlainSegments(String raw, List<ContentNode> output) {
    final text = plainText(raw);
    if (text.isEmpty) return;
    var cursor = 0;
    for (final match in _urlPattern.allMatches(text)) {
      if (match.start > cursor) {
        output.add(
          ContentNode.text(
            text.substring(cursor, match.start),
            id: 'comment-text-${output.length}',
          ),
        );
      }
      final consumed = match.group(0) ?? '';
      final rawUrl = trimCommentLink(consumed);
      final url = normalizeCommentLink(rawUrl);
      if (url.isEmpty || rawUrl.isEmpty) {
        output.add(
          ContentNode.text(consumed, id: 'comment-text-${output.length}'),
        );
      } else {
        final trailing = consumed.substring(rawUrl.length);
        output.add(
          ContentNode.link(
            rawUrl,
            url: url,
            id: 'comment-link-${output.length}',
          ),
        );
        if (trailing.isNotEmpty) {
          output.add(
            ContentNode.text(trailing, id: 'comment-text-${output.length}'),
          );
        }
      }
      cursor = match.end;
    }
    if (cursor < text.length) {
      output.add(
        ContentNode.text(
          text.substring(cursor),
          id: 'comment-text-${output.length}',
        ),
      );
    }
  }

  String _normalizeText(String value) => normalizeCommentEmoticonToken(value);
}
