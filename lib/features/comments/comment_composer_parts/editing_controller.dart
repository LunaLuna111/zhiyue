part of '../../../widgets/comment_composer_sheet.dart';

/// Text controller for the official comment-token representation.
///
/// The request body stores an inline emoji as its official text token, while
/// the editor paints the token as an image. Keeping this controller separate
/// prevents the composer widget from becoming a single large implementation
/// file and gives every platform IME the same deletion behavior.
class _CommentEditingController extends TextEditingController {
  static final RegExp _emoticonPattern = RegExp(r'\[[^\]\n]{1,32}\]');

  Map<String, CommentEmoticon> _inlineEmoticons = const {};

  void setInlineEmoticons(Map<String, CommentEmoticon> value) {
    _inlineEmoticons = Map.unmodifiable(value);
    notifyListeners();
  }

  /// Keeps an inline emoji atomic when the platform IME sends a deletion.
  ///
  /// A normal Android backspace can otherwise remove only the final `]`,
  /// leaving a half token such as `[赞同`. Repairing the edit at the
  /// controller boundary also covers hardware keyboards and pasted edits.
  @override
  set value(TextEditingValue newValue) {
    super.value = _repairAtomicDeletion(super.value, newValue);
  }

  TextEditingValue _repairAtomicDeletion(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_inlineEmoticons.isEmpty ||
        newValue.text.length >= oldValue.text.length ||
        oldValue.text == newValue.text) {
      return newValue;
    }

    final edit = _pureDeletion(oldValue.text, newValue.text);
    if (edit == null) return newValue;

    final ranges = <({int start, int end})>[(start: edit.start, end: edit.end)];
    for (final match in _emoticonPattern.allMatches(oldValue.text)) {
      final token = match.group(0) ?? '';
      if (!_inlineEmoticons.containsKey(token)) continue;
      if (match.start < edit.end && match.end > edit.start) {
        ranges.add((start: match.start, end: match.end));
      }
    }
    final merged = _mergeRanges(ranges);
    final repairedText = _removeRanges(oldValue.text, merged);
    if (repairedText == newValue.text) return newValue;

    final caret = _mapOffset(edit.start, merged);
    return newValue.copyWith(
      text: repairedText,
      selection: TextSelection.collapsed(
        offset: caret,
        affinity: newValue.selection.affinity,
      ),
      composing: TextRange.empty,
    );
  }

  ({int start, int end})? _pureDeletion(String oldText, String newText) {
    var prefix = 0;
    final prefixLimit = oldText.length < newText.length
        ? oldText.length
        : newText.length;
    while (prefix < prefixLimit &&
        oldText.codeUnitAt(prefix) == newText.codeUnitAt(prefix)) {
      prefix++;
    }

    var suffix = 0;
    while (suffix < oldText.length - prefix &&
        suffix < newText.length - prefix &&
        oldText.codeUnitAt(oldText.length - suffix - 1) ==
            newText.codeUnitAt(newText.length - suffix - 1)) {
      suffix++;
    }
    final oldEnd = oldText.length - suffix;
    final newEnd = newText.length - suffix;
    if (newEnd != prefix) return null;
    return (start: prefix, end: oldEnd);
  }

  List<({int start, int end})> _mergeRanges(
    List<({int start, int end})> ranges,
  ) {
    ranges.sort((a, b) {
      final start = a.start.compareTo(b.start);
      return start == 0 ? a.end.compareTo(b.end) : start;
    });
    final merged = <({int start, int end})>[];
    for (final range in ranges) {
      if (range.start >= range.end) continue;
      if (merged.isEmpty || range.start > merged.last.end) {
        merged.add(range);
      } else if (range.end > merged.last.end) {
        final previous = merged.removeLast();
        merged.add((start: previous.start, end: range.end));
      }
    }
    return merged;
  }

  String _removeRanges(String text, List<({int start, int end})> ranges) {
    final buffer = StringBuffer();
    var cursor = 0;
    for (final range in ranges) {
      if (range.start > cursor) {
        buffer.write(text.substring(cursor, range.start));
      }
      cursor = range.end;
    }
    if (cursor < text.length) buffer.write(text.substring(cursor));
    return buffer.toString();
  }

  int _mapOffset(int offset, List<({int start, int end})> ranges) {
    var removed = 0;
    for (final range in ranges) {
      if (offset <= range.start) break;
      if (offset < range.end) return range.start - removed;
      removed += range.end - range.start;
    }
    return (offset - removed).clamp(0, super.value.text.length);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_inlineEmoticons.isEmpty ||
        (withComposing &&
            value.composing.isValid &&
            !value.composing.isCollapsed)) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\[[^\]\n]{1,32}\]');
    var offset = 0;
    for (final match in pattern.allMatches(text)) {
      final emoticon = _inlineEmoticons[match.group(0)];
      if (emoticon == null) continue;
      if (match.start > offset) {
        spans.add(TextSpan(text: text.substring(offset, match.start)));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          baseline: TextBaseline.alphabetic,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: _editorEmoticonImage(emoticon, match.group(0) ?? ''),
          ),
        ),
      );
      offset = match.end;
    }
    if (offset < text.length) spans.add(TextSpan(text: text.substring(offset)));
    return TextSpan(style: style, children: spans);
  }

  Widget _editorEmoticonImage(CommentEmoticon emoticon, String token) {
    Widget fallback() => Text(token);
    if (emoticon.assetImagePath.isNotEmpty) {
      return Image.asset(
        emoticon.assetImagePath,
        key: ValueKey('comment-editor-emoticon-$token'),
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        semanticLabel: token,
        errorBuilder: (_, _, _) => fallback(),
      );
    }
    if (emoticon.imageUrl.isNotEmpty) {
      return ZhihuImage.network(
        emoticon.imageUrl,
        key: ValueKey('comment-editor-emoticon-$token'),
        headers: zhihuImageRequestHeaders,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        cacheWidth: 66,
        cacheHeight: 66,
        frameBuilder: (_, child, frame, _) =>
            frame == null ? fallback() : child,
        errorBuilder: (_, _, _) => fallback(),
      );
    }
    return fallback();
  }
}
