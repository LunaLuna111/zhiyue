import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/app_log.dart';
import '../core/comment_emoticon_assets.dart';
import '../core/json_tools.dart';
import '../core/native_image_picker.dart';
import '../ui/zh_theme.dart';

part '../features/comments/comment_composer_parts/composer_surface.dart';
part '../features/comments/comment_composer_parts/editing_controller.dart';

class CommentImageAttachment {
  const CommentImageAttachment({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    this.url = '',
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final String url;

  CommentImageAttachment copyWith({String? url}) => CommentImageAttachment(
    bytes: bytes,
    fileName: fileName,
    mimeType: mimeType,
    url: url ?? this.url,
  );
}

class CommentComposerValue {
  const CommentComposerValue({
    required this.text,
    this.sticker,
    this.replyTarget,
    this.image,
  });

  final String text;
  final CommentEmoticon? sticker;
  final CommentReplyTarget? replyTarget;
  final CommentImageAttachment? image;
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
    this.enableImage = true,
    this.enableGift = true,
  });

  final ZhihuApiClient api;
  final String title;
  final int maxLength;
  final String initialText;
  final List<CommentEmoticonGroup>? initialEmoticonGroups;
  final bool initialShowEmoticons;
  final CommentReplyTarget? replyTarget;
  final bool enableImage;
  final bool enableGift;
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
  bool _expandedComposer = true;
  bool _pendingEmoticons = false;
  int _surfaceTransition = 0;
  Timer? _imeTransitionTimer;
  Timer? _tipTimer;
  OverlayEntry? _tipOverlay;
  CommentImageAttachment? _image;
  Future<void>? _imageUploadFuture;
  bool _imageUploading = false;
  bool _giftPanelPending = false;
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
    _imageUploadFuture = null;
    _controller
      ..removeListener(_refresh)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_sending &&
      !_imageUploading &&
      (_hasText || _selectedSticker != null || _image != null);

  bool get _compactComposer => widget.maxLength <= 5000;

  String get _composerTitle {
    if (widget.title.startsWith('回复')) return '发布你的回复';
    if (widget.title == '写评论' || widget.title == '评论这段话') {
      return '发布你的评论';
    }
    return widget.title;
  }

  String get _submitLabel => widget.title.startsWith('回复') ? '回复' : '发布';

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
            'has_image': _image != null,
          },
        ),
      );
      _showTip('请先登录后再发布');
      return;
    }
    if (_image != null && _image!.url.isEmpty) {
      try {
        await _ensureImageUploaded();
      } catch (error) {
        if (mounted) {
          setState(() => _error = ApiFailure.from(error).userMessage);
        }
        return;
      }
      if (!mounted || _image?.url.isEmpty == true) return;
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
          image: _image,
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
    _schedulePendingEmoticonPoll(transition);
  }

  static const _imePollInterval = Duration(milliseconds: 60);
  static const _imeTransitionTimeout = Duration(milliseconds: 1400);

  void _schedulePendingEmoticonPoll(int transition) {
    _imeTransitionTimer?.cancel();
    _imeTransitionTimer = Timer(_imePollInterval, () {
      if (!mounted || !_pendingEmoticons || transition != _surfaceTransition) {
        return;
      }
      final startedAt = _emoticonTransitionStartedAt;
      final elapsed = startedAt == null
          ? Duration.zero
          : DateTime.now().difference(startedAt);
      final timedOut = elapsed >= _imeTransitionTimeout;
      if (_imeIsVisible && !timedOut) {
        _schedulePendingEmoticonPoll(transition);
        return;
      }
      _showPendingEmoticons(transition, allowVisibleIme: timedOut);
    });
  }

  bool get _imeIsVisible {
    final view = View.maybeOf(context);
    if (view != null) return view.viewInsets.bottom > 0.5;
    return MediaQuery.viewInsetsOf(context).bottom > 0.5;
  }

  void _showPendingEmoticons(int transition, {bool allowVisibleIme = false}) {
    if (!mounted || !_pendingEmoticons || transition != _surfaceTransition) {
      return;
    }
    // A metric callback can arrive one frame before the IME surface has
    // actually left the window. Do not let that transient zero/positive
    // sequence lay out the panel underneath the keyboard; the poll above
    // will retry until the insets are stable, with a bounded timeout.
    if (_imeIsVisible && !allowVisibleIme) {
      _schedulePendingEmoticonPoll(transition);
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

  void _mention() {
    if (_showEmoticons) {
      setState(() => _showEmoticons = false);
    }
    final targetName = widget.replyTarget?.targetUserName.trim() ?? '';
    if (targetName.isEmpty) {
      _insertText('@');
      _showTip('请输入用户名完成提及');
    } else {
      _insertText('@$targetName ');
      _showTip('已提及 $targetName');
    }
    _focusNode.requestFocus();
  }

  int? get _giftGroupIndex {
    for (var index = 0; index < _groups.length; index++) {
      if (_groups[index].emoticons.any((value) => !value.isInlineEmoji)) {
        return index;
      }
    }
    for (var index = 0; index < _groups.length; index++) {
      if (_groups[index].type.trim().toLowerCase() == 'vip') return index;
    }
    return _groups.isEmpty ? null : 0;
  }

  void _openGiftPanel() {
    final index = _giftGroupIndex;
    if (index == null) {
      if (_loadingCatalog) {
        if (_giftPanelPending) return;
        _giftPanelPending = true;
        _showTip('正在加载礼物');
        unawaited(
          _loadCatalog().whenComplete(() {
            if (!mounted || !_giftPanelPending) return;
            _giftPanelPending = false;
            _openGiftPanel();
          }),
        );
      } else {
        _showTip('暂无可用礼物');
      }
      return;
    }
    _giftPanelPending = false;
    if (_showEmoticons) {
      setState(() => _selectedGroup = index);
      return;
    }
    _selectedGroup = index;
    _toggleEmoticons();
  }

  Future<void> _pickImage() async {
    if (_imageUploading || _sending) return;
    try {
      final picked = await NativeImagePicker.pickSingleImage();
      if (!mounted || picked == null) return;
      final attachment = CommentImageAttachment(
        bytes: picked.bytes,
        fileName: picked.fileName,
        mimeType: picked.mimeType,
      );
      setState(() {
        _image = attachment;
        _showEmoticons = false;
        _pendingEmoticons = false;
        _error = '';
      });
      if (widget.api.canWrite) {
        await _ensureImageUploaded();
      } else {
        _showTip('图片已添加，登录后可发布');
      }
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = ApiFailure.from(error).userMessage);
      }
    }
  }

  Future<void> _ensureImageUploaded() {
    final current = _image;
    if (current == null || current.url.isNotEmpty) return Future.value();
    final pending = _imageUploadFuture;
    if (pending != null) return pending;
    final future = _uploadImage(current);
    _imageUploadFuture = future;
    return future.whenComplete(() {
      if (identical(_imageUploadFuture, future)) _imageUploadFuture = null;
    });
  }

  Future<void> _uploadImage(CommentImageAttachment attachment) async {
    if (!widget.api.canWrite) {
      throw const ApiTransportException('请先登录后再发布图片');
    }
    if (mounted) setState(() => _imageUploading = true);
    try {
      final response = await widget.api.uploadCommentImage(
        bytes: attachment.bytes,
        fileName: attachment.fileName,
        mimeType: attachment.mimeType,
      );
      if (!response.isSuccess) throw response;
      final url = _uploadedImageUrl(response.json);
      if (url.isEmpty) {
        throw const ApiTransportException('图片上传未返回地址');
      }
      if (mounted && identical(_image, attachment)) {
        setState(() => _image = attachment.copyWith(url: url));
      }
    } finally {
      if (mounted) setState(() => _imageUploading = false);
    }
  }

  String _uploadedImageUrl(Object? value, [int depth = 0]) {
    if (depth > 5) return '';
    if (value is Map) {
      for (final key in const [
        'url',
        'src',
        'original_src',
        'original_url',
        'image_url',
      ]) {
        final candidate = value[key]?.toString().trim() ?? '';
        final uri = Uri.tryParse(candidate);
        if (uri != null &&
            uri.scheme == 'https' &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty) {
          return candidate;
        }
      }
      for (final key in const ['data', 'image', 'images', 'result']) {
        final found = _uploadedImageUrl(value[key], depth + 1);
        if (found.isNotEmpty) return found;
      }
      for (final child in value.values) {
        final found = _uploadedImageUrl(child, depth + 1);
        if (found.isNotEmpty) return found;
      }
    } else if (value is List) {
      for (final child in value) {
        final found = _uploadedImageUrl(child, depth + 1);
        if (found.isNotEmpty) return found;
      }
    }
    return '';
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
        (_compactComposer ? (_expandedComposer ? 200.0 : 168.0) : 164.0) +
        (_selectedSticker == null ? 0 : 48) +
        (_image == null ? 0 : 64) +
        (_error.isEmpty ? 0 : 36);
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
          padding: const EdgeInsets.fromLTRB(12, 8, 12, ZhSpace.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_compactComposer)
                _ComposerHeader(
                  title: _composerTitle,
                  expanded: _expandedComposer,
                  onToggleExpanded: () =>
                      setState(() => _expandedComposer = !_expandedComposer),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6E8EC)),
                ),
                child: SizedBox(
                  height: _compactComposer
                      ? (_expandedComposer ? 84.0 : 52.0)
                      : 104.0,
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
                      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    ),
                  ),
                ),
              ),
              if (_selectedSticker != null)
                _SelectedSticker(
                  value: _selectedSticker!,
                  onRemove: () => setState(() => _selectedSticker = null),
                ),
              if (_image != null)
                _SelectedImage(
                  value: _image!,
                  uploading: _imageUploading,
                  onRemove: () => setState(() => _image = null),
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
                  submitLabel: _submitLabel,
                  onEmoticons: _toggleEmoticons,
                  onMention: _mention,
                  onImage: widget.enableImage ? _pickImage : null,
                  onGift: widget.enableGift ? _openGiftPanel : null,
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
