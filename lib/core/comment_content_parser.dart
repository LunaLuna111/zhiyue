import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'comment_link.dart';
import 'content_interaction_models.dart';

/// The visible nodes and media extracted from one comment payload.
///
/// Comment media is deliberately kept outside [nodes].  The native client
/// renders media below the selectable text, while bracket tokens in ordinary
/// text are resolved by the emoticon renderer.
class CommentContentDocument {
  CommentContentDocument({
    Iterable<ContentNode> nodes = const <ContentNode>[],
    Iterable<String> mediaUrls = const <String>[],
  }) : nodes = List.unmodifiable(nodes),
       mediaUrls = List.unmodifiable(mediaUrls);

  final List<ContentNode> nodes;
  final List<String> mediaUrls;
}

/// Parses the HTML form returned by comment endpoints into stable content
/// nodes.  The parser tolerates malformed markup and keeps a plain-text
/// fallback so a bad payload never removes an otherwise visible comment.
CommentContentDocument parseCommentContent(String raw) {
  if (raw.isEmpty) return CommentContentDocument();
  try {
    final parser = _CommentContentParser();
    final fragment = html_parser.parseFragment(raw);
    for (final node in fragment.nodes) {
      parser.visit(node);
    }
    return parser.finish();
  } catch (_) {
    final parser = _CommentContentParser()..appendText(raw);
    return parser.finish();
  }
}

class _CommentContentParser {
  static const _mediaClasses = <String>{
    'comment_img',
    'comment_image',
    'comment_gif',
    'comment_inline_image',
  };
  static const _imageAttributes = <String>[
    'data-original',
    'data-original-src',
    'data-original-url',
    'data-actualsrc',
    'data-src',
    'src',
    'href',
  ];
  static final _imageExtensions = RegExp(
    r'\.(?:avif|gif|jpe?g|png|webp)(?:$|[?#])',
    caseSensitive: false,
  );

  final _nodes = <ContentNode>[];
  final _mediaUrls = <String>[];
  final _mediaKeys = <String>{};

  void visit(dom.Node node) {
    if (node is dom.Text) {
      appendText(node.data);
      return;
    }
    if (node is! dom.Element) return;

    final tag = (node.localName ?? '').toLowerCase();
    if (tag == 'br') {
      appendText('\n');
      return;
    }
    if (tag == 'script' || tag == 'style' || tag == 'noscript') return;

    if (tag == 'img') {
      addMedia(_mediaUrl(node));
      return;
    }

    if (tag == 'a') {
      final href = normalizeCommentLink(node.attributes['href']);
      final label = _visibleText(node);
      if (_isStickerAnchor(node)) {
        if (label.isNotEmpty && isCommentNavigableLink(href)) {
          final rawStickerId = node.attributes['data-sticker-id']?.trim() ?? '';
          final stickerId =
              RegExp(r'^[A-Za-z0-9._:-]{1,160}$').hasMatch(rawStickerId)
              ? rawStickerId
              : 'index-${_nodes.length}';
          _nodes.add(
            ContentNode.sticker(
              label,
              url: href,
              id: 'comment-sticker-$stickerId',
              title: label,
            ),
          );
        } else if (label.isNotEmpty) {
          appendText(label);
        } else {
          addMedia(_mediaUrl(node));
        }
        return;
      }
      if (_isMediaAnchor(node, href, label)) {
        addMedia(_mediaUrl(node));
        return;
      }
      if (isCommentNavigableLink(href) && label.isNotEmpty) {
        _nodes.add(
          ContentNode.link(
            label,
            url: href,
            id: 'comment-link-${_nodes.length}',
            title: label,
          ),
        );
        return;
      }
      if (label.isNotEmpty) appendText(label);
      return;
    }

    for (final child in node.nodes) {
      visit(child);
    }
  }

  void appendText(String value) {
    if (value.isEmpty) return;
    var cursor = 0;
    for (final match in commentUrlPattern.allMatches(value)) {
      if (match.start > cursor) {
        _addText(value.substring(cursor, match.start));
      }
      final consumed = match.group(0) ?? '';
      final rawUrl = trimCommentLink(consumed);
      final url = normalizeCommentLink(rawUrl);
      if (rawUrl.isEmpty || url.isEmpty) {
        _addText(consumed);
      } else {
        _nodes.add(
          ContentNode.link(
            rawUrl,
            url: url,
            id: 'comment-link-${_nodes.length}',
          ),
        );
        final trailing = consumed.substring(rawUrl.length);
        if (trailing.isNotEmpty) _addText(trailing);
      }
      cursor = match.end;
    }
    if (cursor < value.length) _addText(value.substring(cursor));
  }

  CommentContentDocument finish() =>
      CommentContentDocument(nodes: _nodes, mediaUrls: _mediaUrls);

  bool _isMediaAnchor(dom.Element element, String href, String label) {
    final classes = element.classes.map((value) => value.toLowerCase());
    if (classes.any(_mediaClasses.contains)) return true;
    if (element.querySelector('img') != null) return true;
    if (!_isImageTarget(href)) return false;
    final compactLabel = label.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    return const {'[图片]', '图片', '[照片]', '照片'}.contains(compactLabel);
  }

  bool _isStickerAnchor(dom.Element element) {
    if (element.classes.any(
      (value) => value.toLowerCase() == 'comment_sticker',
    )) {
      return true;
    }
    return element.attributes['data-sticker-id']?.trim().isNotEmpty == true;
  }

  String _visibleText(dom.Node node) {
    final buffer = StringBuffer();
    void collect(dom.Node current) {
      if (current is dom.Text) {
        buffer.write(current.data);
        return;
      }
      if (current is! dom.Element) return;
      final tag = (current.localName ?? '').toLowerCase();
      if (tag == 'br') {
        buffer.write('\n');
        return;
      }
      if (tag == 'img' || tag == 'script' || tag == 'style') return;
      for (final child in current.nodes) {
        collect(child);
      }
    }

    for (final child in node.nodes) {
      collect(child);
    }
    return buffer.toString();
  }

  String _mediaUrl(dom.Element element) {
    final candidates = <String>[];
    for (final key in _imageAttributes) {
      final value = element.attributes[key];
      if (value != null) candidates.add(value);
    }
    final image = element.querySelector('img');
    if (image != null) {
      for (final key in _imageAttributes) {
        final value = image.attributes[key];
        if (value != null) candidates.add(value);
      }
    }
    for (final candidate in candidates) {
      final normalized = normalizeCommentLink(candidate);
      final uri = Uri.tryParse(normalized);
      if (uri != null &&
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          uri.host.isNotEmpty) {
        return normalized;
      }
    }
    return '';
  }

  bool _isImageTarget(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return false;
    return uri.host.toLowerCase().contains('zhimg.com') ||
        _imageExtensions.hasMatch(
          uri.path + (uri.hasQuery ? '?${uri.query}' : ''),
        );
  }

  void addMedia(String value) {
    if (value.isEmpty) return;
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return;
    final key = uri.replace(fragment: '').toString();
    if (_mediaKeys.add(key)) _mediaUrls.add(value);
  }

  void _addText(String value) {
    if (value.isEmpty) return;
    if (_nodes.isNotEmpty && _nodes.last.isText) {
      final previous = _nodes.removeLast();
      _nodes.add(
        ContentNode.text(
          '${previous.text}$value',
          id: previous.id,
          startOffset: previous.startOffset,
          endOffset: previous.endOffset,
        ),
      );
      return;
    }
    _nodes.add(ContentNode.text(value, id: 'comment-text-${_nodes.length}'));
  }
}
