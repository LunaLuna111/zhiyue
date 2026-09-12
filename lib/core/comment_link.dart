import 'dart:async';

import 'api_client.dart';
import 'json_tools.dart';

/// Title metadata returned by Zhihu's URL parser.  Keeping the original URL
/// alongside the display title is important: the title is presentation only,
/// while navigation must always use the canonical target URL.
class CommentLinkPreview {
  const CommentLinkPreview({
    required this.url,
    this.title = '',
    this.titleInPin = '',
    this.iconName = '',
  });

  final String url;
  final String title;
  final String titleInPin;
  final String iconName;

  String get displayTitle {
    // `title` is the display text returned for the editor/comment span.
    // `title_in_pin` is a pin-specific fallback and must not win here; using
    // it for every comment made ordinary links show the wrong (pin) label.
    final candidate = title.trim().isNotEmpty
        ? title.trim()
        : titleInPin.trim();
    return candidate;
  }
}

/// `link_tag` is a separate object in comment responses.  It is not part of
/// the HTML content, so treating it as ordinary text loses the native
/// answer/article/story jump cards completely.
class CommentLinkTag {
  const CommentLinkTag({
    required this.url,
    required this.text,
    this.title = '',
    this.iconUrl = '',
    this.groupTitle = '',
    this.groupIconUrl = '',
  });

  final String url;
  final String text;
  final String title;
  final String iconUrl;
  final String groupTitle;
  final String groupIconUrl;

  String get displayText {
    final prefix = title.trim();
    final body = text.trim();
    if (prefix.isEmpty) return body;
    if (body.isEmpty || body == prefix) return prefix;
    return '$prefix｜$body';
  }
}

String normalizeCommentLink(Object? value) {
  var result = plainText(value).trim();
  if (result.isEmpty) return '';
  result = result
      .replaceAll(r'\/', '/')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#x2F;', '/')
      .replaceAll('&#47;', '/')
      .replaceAll(r'\u002F', '/');

  // Match the native editor's normalisation contract: explicit schemes are
  // kept intact, while a host pasted without a scheme is sent to the parser
  // with a secure HTTP scheme.  This covers ordinary external domains as
  // well as Zhihu's app/deep-link schemes.
  if (result.startsWith('//')) return 'https:$result';
  if (RegExp(r'^[a-z][a-z0-9+.-]*://', caseSensitive: false).hasMatch(result)) {
    return result;
  }
  if (result.toLowerCase().startsWith('www.')) {
    return 'https://$result';
  }
  if (RegExp(
    r'^(?=.*[A-Za-z])[\w-]+(?:\.[\w-]+)*\.[A-Za-z]{2,}(?:[:/#?].*)?$',
    caseSensitive: false,
  ).hasMatch(result)) {
    return 'https://$result';
  }
  return result;
}

/// This follows the native `LinkDetectionResult` matcher.  The native client
/// intentionally accepts both fully-qualified URLs and bare domains, because
/// users frequently paste `example.com/path` into a comment.
final RegExp commentUrlPattern = RegExp(
  r'''(?:(?:https?://)?(?=.*[A-Za-z])[\w-]+(?:\.[\w-]+)*\.[A-Za-z]{2,}[/#?]?.*?)(?=\s|$)''',
  caseSensitive: false,
);

String trimCommentLink(String raw) {
  var value = raw.trim();
  final boundary = RegExp(r'[，。！？；：、）》】」』“”‘’]').firstMatch(value);
  if (boundary != null) value = value.substring(0, boundary.start);
  while (value.isNotEmpty &&
      '，。！？；：、）》】」』.,!?;:)]}'.contains(value[value.length - 1])) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}

String _commentLinkCacheKey(String value) {
  final uri = Uri.tryParse(normalizeCommentLink(value));
  if (uri == null || uri.host.isEmpty) return normalizeCommentLink(value);
  final path = uri.path.isEmpty ? '/' : uri.path;
  final query = uri.hasQuery ? '?${uri.query}' : '';
  return '${uri.host.toLowerCase()}$path$query';
}

/// Extracts URLs from the visible portion of a comment.  The expression is
/// intentionally host-based (rather than matching arbitrary `[]` tokens), so
/// bracketed emoji and ordinary Chinese text never become link requests.
List<String> extractCommentLinkUrls(String value) {
  final source = value.replaceAll(RegExp(r'<[^>]+>'), ' ');
  final result = <String>[];
  for (final match in commentUrlPattern.allMatches(source)) {
    final raw = trimCommentLink(match.group(0) ?? '');
    var url = normalizeCommentLink(raw);
    if (url.isEmpty) continue;
    if (url.isEmpty || result.contains(url)) continue;
    result.add(url);
  }
  return List.unmodifiable(result);
}

List<CommentLinkTag> commentLinkTagsOf(Map<String, dynamic> source) {
  final object = unwrapObject(source);
  final raw = object['link_tag'] ?? object['linkTag'];
  if (raw is List) {
    return _commentLinkTagsFromValues(raw);
  }
  final root = raw is Map
      ? raw.map((key, value) => MapEntry(key.toString(), value))
      : null;
  if (root == null) return const [];
  final rawTags =
      root['tags'] ??
      root['tag_list'] ??
      root['tagList'] ??
      root['link_tags'] ??
      root['linkTags'] ??
      root['items'] ??
      root['data'];
  // The Android model always renders LinkTagBean.tags. A direct target on
  // the wrapper is accepted only as a tolerant fallback for older payloads.
  final values = rawTags is List
      ? rawTags
      : _hasCommentLinkTarget(root)
      ? [root]
      : const <Object?>[];
  return _commentLinkTagsFromValues(
    values,
    wrapperTitle: rawTags is List ? '' : plainText(root['title']),
    wrapperIcon: rawTags is List
        ? ''
        : normalizeCommentLink(root['icon_url'] ?? root['iconUrl']),
    groupTitle: plainText(root['title']),
    groupIcon: normalizeCommentLink(root['icon_url'] ?? root['iconUrl']),
  );
}

bool _hasCommentLinkTarget(Map<String, dynamic> value) {
  return plainText(
    value['target_url'] ?? value['targetUrl'] ?? value['url'] ?? value['link'],
  ).isNotEmpty;
}

List<CommentLinkTag> _commentLinkTagsFromValues(
  Iterable<Object?> values, {
  String wrapperTitle = '',
  String wrapperIcon = '',
  String groupTitle = '',
  String groupIcon = '',
}) {
  final result = <CommentLinkTag>[];
  for (final value in values) {
    if (value is! Map) continue;
    final tag = value.map((key, child) => MapEntry(key.toString(), child));
    final url = normalizeCommentLink(
      tag['target_url'] ?? tag['targetUrl'] ?? tag['url'] ?? tag['link'],
    );
    if (url.isEmpty) continue;
    final text = plainText(tag['text'] ?? tag['name'] ?? tag['label']);
    final title = plainText(tag['title']).isNotEmpty
        ? plainText(tag['title'])
        : wrapperTitle;
    final icon = normalizeCommentLink(
      tag['icon_url'] ?? tag['iconUrl'] ?? wrapperIcon,
    );
    result.add(
      CommentLinkTag(
        url: url,
        text: text,
        title: title,
        iconUrl: icon,
        groupTitle: groupTitle,
        groupIconUrl: groupIcon,
      ),
    );
  }
  return List.unmodifiable(result);
}

/// A small process-wide cache prevents a comment sheet from requesting the
/// same URL repeatedly as rows are rebuilt or the sort order changes.
class CommentLinkResolver {
  CommentLinkResolver._();

  static final Map<String, CommentLinkPreview> _cache = {};
  static final Map<String, Future<Map<String, CommentLinkPreview>>> _pending =
      {};

  static Future<Map<String, CommentLinkPreview>> resolve(
    ZhihuApiClient api,
    Iterable<String> urls, {
    String scene = 'editor',
  }) async {
    final normalized = <String>[];
    for (final raw in urls) {
      final value = normalizeCommentLink(raw);
      if (value.isEmpty || normalized.contains(value)) continue;
      normalized.add(value);
    }
    if (normalized.isEmpty) return const {};
    final result = <String, CommentLinkPreview>{};
    final missing = <String>[];
    for (final url in normalized) {
      final cached = _cache[url];
      if (cached != null) {
        result[url] = cached;
      } else {
        missing.add(url);
      }
    }
    if (missing.isEmpty) return result;

    // Keep batches small enough for the signed query while allowing several
    // comments to resolve concurrently, matching the native pre-parser.
    for (var offset = 0; offset < missing.length; offset += 20) {
      final batch = missing.skip(offset).take(20).toList(growable: false);
      final unresolved = <String>[];
      final futures = <Future<Map<String, CommentLinkPreview>>>[];
      for (final url in batch) {
        final existing = _pending[url];
        if (existing != null) {
          futures.add(existing);
        } else {
          unresolved.add(url);
        }
      }
      if (unresolved.isNotEmpty) {
        final future = _resolveBatch(api, unresolved, scene: scene);
        for (final url in unresolved) {
          _pending[url] = future;
        }
        futures.add(future);
      }
      final resolved = await Future.wait(futures);
      for (final map in resolved) {
        result.addAll(map);
      }
      // Some gateway versions key the response by the pasted (bare) URL,
      // while others key it by the normalized URL. Always expose the cache
      // under the URL the widget is actually holding.
      for (final url in batch) {
        final cached = _cache[url];
        if (cached != null) result[url] = cached;
      }
      for (final url in batch) {
        _pending.remove(url);
      }
    }
    return result;
  }

  static Future<Map<String, CommentLinkPreview>> _resolveBatch(
    ZhihuApiClient api,
    List<String> urls, {
    required String scene,
  }) async {
    try {
      final response = await api.getUri(
        api.commentLinkParseUri(url: urls.join(','), scene: scene),
      );
      if (!response.isSuccess || response.jsonMap == null) return const {};
      Object? raw = response.jsonMap!['data'];
      if (raw is Map && raw['data'] is Map) raw = raw['data'];
      if (raw is! Map) return const {};
      final result = <String, CommentLinkPreview>{};
      for (final entry in raw.entries) {
        final key = normalizeCommentLink(entry.key);
        final info = entry.value is Map
            ? entry.value.map((k, v) => MapEntry(k.toString(), v))
            : const <String, dynamic>{};
        final url = normalizeCommentLink(info['url']).isNotEmpty
            ? normalizeCommentLink(info['url'])
            : key;
        if (url.isEmpty) continue;
        final preview = CommentLinkPreview(
          url: url,
          title: plainText(info['title']),
          titleInPin: plainText(info['title_in_pin'] ?? info['titleInPin']),
          iconName: plainText(info['icon_name'] ?? info['iconName']),
        );
        if (preview.displayTitle.isEmpty) continue;
        _cache[url] = preview;
        if (key.isNotEmpty) _cache[key] = preview;
        final responseKey = _commentLinkCacheKey(url);
        for (final requested in urls) {
          if (_commentLinkCacheKey(requested) == responseKey) {
            _cache[requested] = preview;
          }
        }
        result[key.isEmpty ? url : key] = preview;
      }
      return result;
    } catch (_) {
      // A failed resolver must never hide a comment.  The widget retains the
      // original URL and can still open it directly.
      return const {};
    }
  }
}
