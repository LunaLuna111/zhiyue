import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/app_log.dart';
import '../core/comment_emoticon_assets.dart';
import '../core/json_tools.dart';
import '../ui/zh_theme.dart';

part '../features/comments/comment_composer_parts/composer_surface.dart';

class CommentComposerValue {
  const CommentComposerValue({
    required this.text,
    this.sticker,
    this.replyTarget,
  });

  final String text;
  final CommentEmoticon? sticker;
  final CommentReplyTarget? replyTarget;
}

class CommentComposerSheet extends StatefulWidget {
  const CommentComposerSheet({
    super.key,
    required this.api,
    required this.title,
    required this.onSubmit,
    this.maxLength = 5000,
    this.initialText = '',
    this.initialEmoticonGroups,
    this.initialShowEmoticons = false,
    this.replyTarget,
  });

  final ZhihuApiClient api;
  final String title;
  final int maxLength;
  final String initialText;
  final List<CommentEmoticonGroup>? initialEmoticonGroups;
  final bool initialShowEmoticons;
  final CommentReplyTarget? replyTarget;
  final Future<String?> Function(CommentComposerValue value) onSubmit;

  @override
  State<CommentComposerSheet> createState() => _CommentComposerSheetState();
}

class _CommentComposerSheetState extends State<CommentComposerSheet>
    with WidgetsBindingObserver {
  static final Expando<List<CommentEmoticonGroup>> _catalogCache = Expando();
  static final Expando<Future<List<CommentEmoticonGroup>>> _catalogLoads =
      Expando();

  final _controller = _CommentEditingController();
  final _focusNode = FocusNode();
  List<CommentEmoticonGroup> _groups = const [];
  CommentEmoticon? _selectedSticker;
  int _selectedGroup = 0;
  bool _showEmoticons = false;
  bool _pendingEmoticons = false;
  int _surfaceTransition = 0;
  Timer? _imeTransitionTimer;
  Timer? _tipTimer;
  OverlayEntry? _tipOverlay;
  DateTime? _emoticonTransitionStartedAt;
  bool _emoticonFrameScheduled = false;
  bool _loadingCatalog = true;
  bool _catalogRequested = false;
  bool _sending = false;
  bool _hasText = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialText.isNotEmpty) {
      _controller.value = TextEditingValue(
        text: widget.initialText,
        selection: TextSelection.collapsed(offset: widget.initialText.length),
      );
      _hasText = widget.initialText.trim().isNotEmpty;
    }
    _controller.addListener(_refresh);
    final initial = widget.initialEmoticonGroups;
    if (initial != null) {
      _catalogRequested = true;
      _setCatalog(initial);
    }
    if (widget.initialShowEmoticons) {
      _showEmoticons = true;
      unawaited(_loadCatalog());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.unfocus();
      });
    }
  }

  Future<void> _loadCatalog() async {
    if (_catalogRequested) return;
    _catalogRequested = true;
    final cached = _catalogCache[widget.api];
    if (cached != null) {
      if (mounted) setState(() => _setCatalog(cached));
      return;
    }
    final pending = _catalogLoads[widget.api] ??= _loadCompleteCatalog();
    try {
      final loaded = await pending;
      final resolved = loaded
          .where((group) => group.emoticons.isNotEmpty)
          .toList();
      final catalog = resolved.isEmpty
          ? <CommentEmoticonGroup>[CommentEmoticonGroup.fallback()]
          : resolved;
      _catalogCache[widget.api] = catalog;
      if (mounted) setState(() => _setCatalog(catalog));
    } catch (_) {
      _catalogLoads[widget.api] = null;
      final fallback = <CommentEmoticonGroup>[CommentEmoticonGroup.fallback()];
      if (mounted) setState(() => _setCatalog(fallback));
    }
  }

  Future<List<CommentEmoticonGroup>> _loadCompleteCatalog() async {
    final bundledFuture = loadBundledCommentEmoticonGroups();
    final remoteFuture = widget.api.loadCommentEmoticonGroups().then(
      (groups) => groups,
      onError: (_) => <CommentEmoticonGroup>[],
    );
    final bundled = await bundledFuture;
    if (mounted && bundled.isNotEmpty) {
      setState(() => _setCatalog(bundled));
    }
    final remote = await remoteFuture;
    final result = <CommentEmoticonGroup>[...bundled];
    for (final group in remote) {
      final duplicatesBundled = bundled.any(
        (value) =>
            value.id == group.id ||
            ((group.type == 'official' || group.type == 'vip') &&
                value.type == group.type),
      );
      if (!duplicatesBundled && group.emoticons.isNotEmpty) result.add(group);
    }
    return result;
  }

  void _setCatalog(List<CommentEmoticonGroup> value) {
    _groups = value;
    final inline = <String, CommentEmoticon>{};
    for (final emoticon in value.expand((group) => group.emoticons)) {
      if (!emoticon.isInlineEmoji) continue;
      for (final key in commentEmoticonLookupKeys(emoticon.title)) {
        inline.putIfAbsent(key, () => emoticon);
      }
    }
    _controller.setInlineEmoticons(inline);
    _loadingCatalog = false;
    if (_selectedGroup >= value.length) _selectedGroup = 0;
  }

  void _refresh() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (mounted && hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _imeTransitionTimer?.cancel();
    _tipTimer?.cancel();
    _tipOverlay?.remove();
    _controller
      ..removeListener(_refresh)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSubmit => !_sending && (_hasText || _selectedSticker != null);

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (!widget.api.canWrite) {
      unawaited(
        AppLogStore.instance.record(
          category: AppLogCategory.app,
          level: AppLogLevel.info,
          message: '未登录评论仅保留本地编辑，未发送接口请求',
          details: {
            'has_text': _hasText,
            'has_sticker': _selectedSticker != null,
          },
        ),
      );
      _showTip('请先登录后再发布');
      return;
    }
    setState(() {
      _sending = true;
      _error = '';
    });
    try {
      final error = await widget.onSubmit(
        CommentComposerValue(
          text: _controller.text,
          sticker: _selectedSticker,
          replyTarget: widget.replyTarget,
        ),
      );
      if (!mounted) return;
      if (error == null) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _error = error);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = ApiFailure.from(error).userMessage);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showTip(String message) {
    _tipTimer?.cancel();
    _tipOverlay?.remove();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: const Alignment(0, 0.38),
            child: Material(
              color: const Color(0xE61F2329),
              borderRadius: BorderRadius.circular(8),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    _tipOverlay = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
    _tipTimer = Timer(const Duration(seconds: 2), () {
      if (identical(_tipOverlay, entry)) _tipOverlay = null;
      entry.remove();
    });
  }

  void _toggleEmoticons() {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    unawaited(_recordComposerTransition('点击表情按钮', inset));
    if (_showEmoticons || _pendingEmoticons) {
      _surfaceTransition++;
      _imeTransitionTimer?.cancel();
      _emoticonTransitionStartedAt = null;
      _emoticonFrameScheduled = false;
      setState(() {
        _showEmoticons = false;
        _pendingEmoticons = false;
        _error = '';
      });
      _focusNode.requestFocus();
      return;
    }
    unawaited(_loadCatalog());
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (!keyboardVisible) {
      setState(() {
        _showEmoticons = true;
        _error = '';
      });
      _focusNode.unfocus();
      return;
    }
    // The original editor waits for its global-layout callback after the IME
    // has fully disappeared, then makes EmoticonPanel visible. Keeping these
    // as two distinct phases prevents Android's inset animation from dropping
    // the panel-opening state.
    setState(() {
      _pendingEmoticons = true;
      _error = '';
    });
    _emoticonTransitionStartedAt = DateTime.now();
    _focusNode.unfocus();
    final transition = ++_surfaceTransition;
    _imeTransitionTimer?.cancel();
    _imeTransitionTimer = Timer(const Duration(milliseconds: 180), () {
      if (mounted && _pendingEmoticons && transition == _surfaceTransition) {
        _showPendingEmoticons(transition);
      }
    });
  }

  void _showPendingEmoticons(int transition) {
    if (!mounted || !_pendingEmoticons || transition != _surfaceTransition) {
      return;
    }
    _imeTransitionTimer?.cancel();
    final startedAt = _emoticonTransitionStartedAt;
    _emoticonTransitionStartedAt = null;
    _emoticonFrameScheduled = false;
    setState(() {
      _pendingEmoticons = false;
      _showEmoticons = true;
    });
    _focusNode.unfocus();
    final elapsed = startedAt == null
        ? null
        : DateTime.now().difference(startedAt).inMilliseconds;
    unawaited(_recordComposerTransition('表情面板已替代输入法', 0, elapsedMs: elapsed));
  }

  @override
  void didChangeMetrics() {
    if (!_pendingEmoticons || !mounted) return;
    final view = View.maybeOf(context);
    final physicalInset = view?.viewInsets.bottom ?? -1;
    unawaited(
      _recordComposerTransition('等待输入法收起', physicalInset, physical: true),
    );
    if (view == null || physicalInset > 0) return;
    if (_emoticonFrameScheduled) return;
    _emoticonFrameScheduled = true;
    final transition = _surfaceTransition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingEmoticons(transition);
    });
  }

  Future<void> _recordComposerTransition(
    String message,
    double inset, {
    bool physical = false,
    int? elapsedMs,
  }) => AppLogStore.instance.record(
    category: AppLogCategory.app,
    level: AppLogLevel.info,
    message: message,
    details: {
      'inset': inset.round(),
      'inset_unit': physical ? 'physical_px' : 'logical_px',
      'focused': _focusNode.hasFocus,
      'pending_emoticons': _pendingEmoticons,
      'show_emoticons': _showEmoticons,
      'surface_transition': _surfaceTransition,
      'elapsed_ms': ?elapsedMs,
    },
  );

  void _insertText(String value) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final next = text.replaceRange(start, end, value);
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }

  void _selectEmoticon(CommentEmoticon value) {
    if (value.isInlineEmoji) {
      _insertText(value.title);
      return;
    }
    setState(() => _selectedSticker = value);
  }

  void _backspace() {
    final text = _controller.text;
    final selection = _controller.selection;
    if (!selection.isValid || selection.start <= 0) return;
    if (!selection.isCollapsed) {
      _controller.value = TextEditingValue(
        text: text.replaceRange(selection.start, selection.end, ''),
        selection: TextSelection.collapsed(offset: selection.start),
      );
      return;
    }
    final before = text.substring(0, selection.start);
    final titles =
        _groups
            .expand((group) => group.emoticons)
            .where((value) => value.isInlineEmoji && value.title.isNotEmpty)
            .map((value) => value.title)
            .where(before.endsWith)
            .toList()
          ..sort((a, b) => b.length.compareTo(a.length));
    final length = titles.isNotEmpty
        ? titles.first.length
        : String.fromCharCode(before.runes.last).length;
    final start = selection.start - length;
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, selection.start, ''),
      selection: TextSelection.collapsed(offset: start),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Subscribe only to stable metrics here. Reading MediaQuery.of(context)
    // made the complete editor (including the emoji grid) rebuild for every
    // intermediate IME inset during keyboard animation.
    final maxHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewPaddingOf(context).top -
        ZhSpace.sm;
    // The official editor uses a compact 164dp bottom surface and grows only
    // when its own emoticon panel is visible. It is not a second titled page.
    final collapsedHeight =
        164.0 + (_selectedSticker == null ? 0 : 48) + (_error.isEmpty ? 0 : 36);
    final targetHeight = _showEmoticons
        ? maxHeight.clamp(390.0, 520.0)
        : collapsedHeight.clamp(164.0, maxHeight);
    final replyHint = widget.title.startsWith('回复') ? widget.title : '';
    return _KeyboardInsetLift(
      // Once selected, the emoticon panel owns the keyboard area. Do not
      // translate it with the retiring IME inset or it can disappear below
      // the bottom-sheet gesture surface during Android's animation.
      enabled: !_showEmoticons,
      child: Material(
        key: const Key('comment-composer-surface'),
        color: ZhPalette.background,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Container(
          height: targetHeight,
          padding: const EdgeInsets.only(bottom: ZhSpace.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 104,
                child: TextField(
                  key: const Key('comment-composer-field'),
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: !_showEmoticons && !_pendingEmoticons,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  maxLength: widget.maxLength,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    color: Color(0xFF191B1F),
                    fontSize: 15,
                    height: 1.45,
                  ),
                  onTapOutside: (_) {},
                  onTap: () {
                    _pendingEmoticons = false;
                    if (_showEmoticons) {
                      setState(() => _showEmoticons = false);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _focusNode.requestFocus();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: replyHint.isEmpty ? '理性发言，友善互动' : replyHint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9196A1),
                      fontSize: 15,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(16, 14, 49, 8),
                  ),
                ),
              ),
              if (_selectedSticker != null)
                _SelectedSticker(
                  value: _selectedSticker!,
                  onRemove: () => setState(() => _selectedSticker = null),
                ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: ZhSpace.xs),
                  child: Text(
                    _error,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _ComposerToolbar(
                  showEmoticons: _showEmoticons,
                  canSubmit: _canSubmit,
                  sending: _sending,
                  onEmoticons: _toggleEmoticons,
                  onMention: () {
                    _insertText('@');
                    if (_showEmoticons) setState(() => _showEmoticons = false);
                    _focusNode.requestFocus();
                  },
                  onSubmit: _submit,
                ),
              ),
              if (_showEmoticons)
                Expanded(
                  child: _EmoticonPanel(
                    loading: _loadingCatalog,
                    groups: _groups,
                    selectedGroup: _selectedGroup,
                    onGroup: (index) => setState(() => _selectedGroup = index),
                    onEmoticon: _selectEmoticon,
                    onBackspace: _backspace,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentEditingController extends TextEditingController {
  Map<String, CommentEmoticon> _inlineEmoticons = const {};

  void setInlineEmoticons(Map<String, CommentEmoticon> value) {
    _inlineEmoticons = Map.unmodifiable(value);
    notifyListeners();
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
    final pattern = RegExp(r'\[[^\]\n]{1,24}\]');
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
        headers: zhihuImageRequestHeaders,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        cacheWidth: 66,
        cacheHeight: 66,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback(),
        errorBuilder: (_, _, _) => fallback(),
      );
    }
    return fallback();
  }
}
