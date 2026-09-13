part of '../content_pages.dart';

/// Native counterpart of the official answer ZRich renderer. The v2 answer
/// endpoint already returns semantic segments and UTF-16 mark ranges, so this
/// path keeps the author's typography and sentence reactions instead of
/// flattening the body to plain text.
class StructuredAnswerContent extends StatelessWidget {
  const StructuredAnswerContent({
    super.key,
    required this.segments,
    this.videos = const [],
    this.videoApi,
    this.onSentenceComments,
    this.onCommentSelection,
    this.onLink,
    this.contentType = '',
    this.contentId = '',
  });

  final List<Map<String, dynamic>> segments;
  final List<RichContentVideo> videos;
  final ZhihuApiClient? videoApi;
  final void Function(List<String> sentenceIds, String quote)?
  onSentenceComments;
  final ValueChanged<ContentSelection>? onCommentSelection;
  final void Function(String url, String title)? onLink;
  final String contentType;
  final String contentId;

  String _imageUrl(Map<String, dynamic> segment) {
    final image = _contentMap(segment['image']);
    if (image == null) return '';
    for (final candidate in [
      image['urls'],
      image['original_urls'],
      image['url'],
      image['original_url'],
    ]) {
      final values = candidate is List ? candidate : [candidate];
      for (final value in values) {
        var raw = value?.toString().trim() ?? '';
        if (raw.startsWith('//')) raw = 'https:$raw';
        final uri = Uri.tryParse(raw);
        if (uri != null && uri.scheme == 'https' && uri.host.isNotEmpty) {
          return uri.toString();
        }
      }
    }
    return '';
  }

  Map<String, dynamic>? _textNode(Map<String, dynamic> segment, String type) {
    for (final key in [type, 'paragraph', 'heading', 'blockquote', 'quote']) {
      final node = _contentMap(segment[key]);
      if (node != null) return node;
    }
    if (segment['text'] != null || segment['content'] != null) return segment;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final imageSources = <_DetailImageSource>[];
    var videoCursor = 0;
    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      final type = plainText(segment['type']).toLowerCase();
      Widget? child;
      if (type == 'image') {
        final url = _imageUrl(segment);
        if (url.isNotEmpty) {
          final image = _contentMap(segment['image']);
          final source = _detailImageSource(url, metadata: image);
          imageSources.add(source);
          final caption = plainText(image?['description']);
          child = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailImageTile(source: source),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 7),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF9196A1),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          );
        }
      } else if (type == 'video') {
        if (videoCursor < videos.length) {
          child = InlineAnswerVideo(
            video: videos[videoCursor++],
            api: videoApi,
          );
        }
      } else if (type == 'hr' || type == 'divider') {
        child = const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, color: Color(0xFFEBECED)),
        );
      } else {
        final node = _textNode(segment, type);
        final rawText = node?['text'] ?? node?['content'];
        var text = rawText is String ? rawText : plainText(rawText);
        if (text.isEmpty &&
            const {'list', 'ordered_list', 'bullet_list'}.contains(type)) {
          final items = segment['items'];
          if (items is List) {
            final ordered = type == 'ordered_list';
            text = List.generate(items.length, (itemIndex) {
              final item = _contentMap(items[itemIndex]);
              final value = plainText(
                item?['text'] ?? item?['content'] ?? items[itemIndex],
              );
              return value.isEmpty
                  ? ''
                  : '${ordered ? '${itemIndex + 1}.' : '•'} $value';
            }).where((value) => value.isNotEmpty).join('\n');
          }
        }
        if (text.isNotEmpty) {
          final marks =
              (node?['marks'] as List?)
                  ?.whereType<Map>()
                  .map(
                    (value) => value.map(
                      (key, value) => MapEntry(key.toString(), value),
                    ),
                  )
                  .toList(growable: false) ??
              const <Map<String, dynamic>>[];
          final level = node?['level'] is num
              ? (node!['level'] as num).round()
              : 0;
          final nodeValue = node ?? segment;
          child = _StructuredTextBlock(
            key: ValueKey(
              // Keep the public test/semantics key compatible with the
              // renderer's original segment order. The selection payload
              // itself uses the semantic node/paragraph IDs below, so a
              // refresh cannot lose its server target even when a segment has
              // no explicit ID.
              'answer-structured-text-$index',
            ),
            text: text,
            marks: marks,
            kind: type,
            headingLevel: level,
            onSentenceComments: onSentenceComments,
            onCommentSelection: onCommentSelection,
            onLink: onLink,
            selectionContext: ContentSelectionContext(
              contentType: contentType,
              contentId: contentId,
              nodeId: contentNodeIdOf(nodeValue, index),
              paragraphId: contentParagraphIdOf(nodeValue),
              source: 'structured',
            ),
          );
        }
      }
      if (child == null) continue;
      if (children.isNotEmpty) {
        children.add(
          SizedBox(height: type == 'heading' || type == 'image' ? 20 : 17),
        );
      }
      children.add(child);
    }
    while (videoCursor < videos.length) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 17));
      children.add(
        InlineAnswerVideo(video: videos[videoCursor++], api: videoApi),
      );
    }
    return _DetailImageWarmup(
      sources: imageSources,
      child: Column(
        key: const Key('structured-answer-content'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _StructuredTextBlock extends StatefulWidget {
  const _StructuredTextBlock({
    super.key,
    required this.text,
    required this.marks,
    required this.kind,
    required this.headingLevel,
    this.onSentenceComments,
    this.onCommentSelection,
    this.onLink,
    this.selectionContext = const ContentSelectionContext(),
  });

  final String text;
  final List<Map<String, dynamic>> marks;
  final String kind;
  final int headingLevel;
  final void Function(List<String> sentenceIds, String quote)?
  onSentenceComments;
  final ValueChanged<ContentSelection>? onCommentSelection;
  final void Function(String url, String title)? onLink;
  final ContentSelectionContext selectionContext;

  @override
  State<_StructuredTextBlock> createState() => _StructuredTextBlockState();
}

class _StructuredTextBlockState extends State<_StructuredTextBlock> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  int _index(Object? value, int fallback) {
    final parsed = value is num
        ? value.round()
        : int.tryParse(value?.toString() ?? '');
    return (parsed ?? fallback).clamp(0, widget.text.length);
  }

  List<String> _segmentIdsForRange(int start, int end) {
    final ids = <String>[];
    for (final mark in widget.marks) {
      final markStart = _index(mark['start_index'] ?? mark['start'], 0);
      final markEnd = _index(
        mark['end_index'] ?? mark['end'],
        widget.text.length,
      );
      if (markEnd <= start || markStart >= end) continue;
      final type = plainText(mark['type']).toLowerCase();
      if (type != 'seg_like') continue;
      final reaction = _contentMap(mark['seg_like']) ?? mark;
      final raw = reaction['seg_ids'] ?? reaction['seg_id'];
      final values = raw is List ? raw : [raw];
      for (final value in values) {
        for (final id in plainText(value).split(',')) {
          final normalized = id.trim();
          if (normalized.isNotEmpty && !ids.contains(normalized)) {
            ids.add(normalized);
          }
        }
      }
    }
    return List.unmodifiable(ids);
  }

  @override
  Widget build(BuildContext context) {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    final isHeading = widget.kind == 'heading';
    final isQuote = const {'blockquote', 'quote'}.contains(widget.kind);
    final isCode = const {'pre', 'code', 'code_block'}.contains(widget.kind);
    final isList = widget.kind.contains('list') || widget.kind == 'list_item';
    final baseStyle = TextStyle(
      color: isQuote ? const Color(0xFF646873) : const Color(0xFF191B1F),
      fontSize: isHeading
          ? widget.headingLevel <= 1
                ? 23
                : widget.headingLevel == 2
                ? 21
                : 19
          : isCode
          ? 15
          : 17,
      height: isHeading ? 1.4 : 1.78,
      fontWeight: isHeading ? FontWeight.w700 : FontWeight.w400,
      fontFamily: isCode ? 'monospace' : null,
      backgroundColor: isCode ? const Color(0xFFF6F6F8) : null,
    );
    final boundaries = <int>{0, widget.text.length};
    for (final mark in widget.marks) {
      boundaries
        ..add(_index(mark['start_index'] ?? mark['start'], 0))
        ..add(_index(mark['end_index'] ?? mark['end'], widget.text.length));
    }
    final ordered = boundaries.toList()..sort();
    final spans = <InlineSpan>[];
    for (var index = 0; index + 1 < ordered.length; index++) {
      final start = ordered[index];
      final end = ordered[index + 1];
      if (end <= start) continue;
      final active = widget.marks
          .where((mark) {
            final markStart = _index(mark['start_index'] ?? mark['start'], 0);
            final markEnd = _index(
              mark['end_index'] ?? mark['end'],
              widget.text.length,
            );
            return markStart <= start && markEnd >= end;
          })
          .toList(growable: false);
      var style = const TextStyle();
      TapGestureRecognizer? recognizer;
      var semantics = '';
      for (final mark in active) {
        final type = plainText(mark['type']).toLowerCase();
        if (type == 'bold' || type == 'strong') {
          style = style.merge(const TextStyle(fontWeight: FontWeight.w700));
        } else if (type == 'italic' || type == 'em') {
          style = style.merge(const TextStyle(fontStyle: FontStyle.italic));
        } else if (type == 'underline') {
          style = style.merge(
            const TextStyle(decoration: TextDecoration.underline),
          );
        } else if (type == 'strike' || type == 'strikethrough') {
          style = style.merge(
            const TextStyle(decoration: TextDecoration.lineThrough),
          );
        } else if (type == 'code') {
          style = style.merge(
            const TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Color(0xFFF1F2F4),
            ),
          );
        } else if (type == 'link' || type == 'entity_word') {
          style = style.merge(const TextStyle(color: Color(0xFF175199)));
          final link = _contentMap(mark[type]);
          final url = plainText(
            mark['url'] ?? mark['href'] ?? link?['url'] ?? link?['href'],
          );
          if (url.isNotEmpty && widget.onLink != null) {
            recognizer = TapGestureRecognizer()
              ..onTap = () =>
                  widget.onLink!(url, widget.text.substring(start, end));
            _recognizers.add(recognizer);
          }
        } else if (type == 'seg_like') {
          final reaction = _contentMap(mark['seg_like']);
          final rawIds = reaction?['seg_ids'];
          final ids = rawIds is List
              ? rawIds
                    .map(plainText)
                    .where((value) => value.isNotEmpty)
                    .toList()
              : <String>[];
          final countValue = reaction?['comment_count'];
          final count = countValue is num
              ? countValue.round()
              : int.tryParse(plainText(countValue)) ?? 0;
          style = style.merge(
            const TextStyle(
              color: Color(0xFF175199),
              backgroundColor: Color(0xFFEAF3FF),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF1772F6),
            ),
          );
          semantics = count > 0 ? '$count 条句子评论' : '查看句子评论';
          if (ids.isNotEmpty && widget.onSentenceComments != null) {
            final markStart = _index(mark['start_index'] ?? mark['start'], 0);
            final markEnd = _index(
              mark['end_index'] ?? mark['end'],
              widget.text.length,
            );
            recognizer = TapGestureRecognizer()
              ..onTap = () => widget.onSentenceComments!(
                ids,
                widget.text.substring(markStart, markEnd),
              );
            _recognizers.add(recognizer);
          }
        }
      }
      spans.add(
        TextSpan(
          text: widget.text.substring(start, end),
          style: style,
          recognizer: recognizer,
          semanticsLabel: semantics.isEmpty ? null : semantics,
        ),
      );
    }
    final richText = SelectableText.rich(
      TextSpan(style: baseStyle, children: spans),
      textAlign: TextAlign.start,
      contextMenuBuilder: (context, editableTextState) =>
          _ZhihuSelectionToolbar(
            state: editableTextState,
            onCommentSelection: widget.onCommentSelection,
            selectionContext: widget.selectionContext,
            segmentIdsForRange: _segmentIdsForRange,
          ),
    );
    if (isQuote) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F7F8),
          border: Border(left: BorderSide(color: Color(0xFFC9CCD3), width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 10, 12, 10),
          child: richText,
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: isList ? 16 : 0),
      child: richText,
    );
  }
}

class InlineRichContent extends StatelessWidget {
  const InlineRichContent({
    super.key,
    required this.html,
    this.fallbackImages = const [],
    this.videos = const [],
    this.videoApi,
    this.onCommentSelection,
    this.onLink,
    this.contentType = '',
    this.contentId = '',
  });

  final String html;
  final List<String> fallbackImages;
  final List<RichContentVideo> videos;
  final ZhihuApiClient? videoApi;
  final ValueChanged<ContentSelection>? onCommentSelection;
  final void Function(String url, String title)? onLink;
  final String contentType;
  final String contentId;

  String _imageKey(String value) {
    final uri = Uri.tryParse(value);
    return uri == null
        ? value
        : uri.replace(query: '', fragment: '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final blocks = richContentBlocks(html, videos: videos);
    final htmlDimensions = _detailHtmlImageDimensions(html);
    final sourcesByUrl = <String, _DetailImageSource>{};
    _DetailImageSource sourceFor(String url) => sourcesByUrl.putIfAbsent(
      url,
      () => _detailImageSource(url, htmlDimensions: htmlDimensions),
    );
    final inlineKeys = blocks
        .expand(
          (block) => [
            if (block.isImage) block.imageUrl,
            if ((block.video?.posterUrl ?? '').isNotEmpty)
              block.video!.posterUrl,
          ],
        )
        .map(_imageKey)
        .toSet();
    final remainingImages = fallbackImages
        .where((url) => !inlineKeys.contains(_imageKey(url)))
        .toList(growable: false);
    final imageSources = <_DetailImageSource>[
      for (final block in blocks)
        if (block.isImage) sourceFor(block.imageUrl),
      for (final url in remainingImages) sourceFor(url),
    ];
    return _DetailImageWarmup(
      sources: imageSources,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < blocks.length; index++) ...[
            if (blocks[index].isVideo)
              InlineAnswerVideo(
                key: ValueKey(
                  'answer-video-'
                  '${blocks[index].video!.videoId.isNotEmpty
                      ? blocks[index].video!.videoId
                      : blocks[index].video!.sourceUrls.isNotEmpty
                      ? blocks[index].video!.sourceUrls.first
                      : 'anonymous'}-$index',
                ),
                video: blocks[index].video!,
                api: videoApi,
              )
            else if (blocks[index].isImage)
              _DetailImageTile(source: sourceFor(blocks[index].imageUrl))
            else
              _ZhihuSelectableText(
                key: ValueKey(
                  'answer-content-node-${blocks[index].node.id.isNotEmpty ? blocks[index].node.id : index}',
                ),
                blocks[index].text,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.78),
                linkUrl: blocks[index].linkUrl,
                onLink: onLink,
                onCommentSelection: onCommentSelection,
                selectionContext: ContentSelectionContext(
                  contentType: contentType,
                  contentId: contentId,
                  nodeId: blocks[index].node.id,
                  source: 'html',
                ),
              ),
            if (index != blocks.length - 1) const SizedBox(height: 16),
          ],
          if (remainingImages.isNotEmpty) ...[
            if (blocks.isNotEmpty) const SizedBox(height: ZhSpace.md),
            _DetailImageGallery(
              sources: remainingImages.map(sourceFor).toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}
