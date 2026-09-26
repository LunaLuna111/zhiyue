import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/app_log.dart';
import '../core/comment_emoticon_assets.dart';
import '../core/json_tools.dart';
import '../core/native_image_picker.dart';
import '../l10n/zh_localization.dart';
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
    this.initialSticker,
    this.initialImage,
    this.initialEmoticonGroups,
    this.initialShowEmoticons = false,
    this.replyTarget,
    this.enableImage = true,
    this.fullEditor = false,
    this.onDraftChanged,
  });

  final ZhihuApiClient api;
  final String title;
  final int maxLength;
  final String initialText;
  final CommentEmoticon? initialSticker;
  final CommentImageAttachment? initialImage;
  final List<CommentEmoticonGroup>? initialEmoticonGroups;
  final bool initialShowEmoticons;
  final CommentReplyTarget? replyTarget;
  final bool enableImage;
  final bool fullEditor;
  final ValueChanged<CommentComposerValue>? onDraftChanged;
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
  CommentImageAttachment? _image;
  Future<void>? _imageUploadFuture;
  bool _imageUploading = false;
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
    _selectedSticker = widget.initialSticker;
    _image = widget.initialImage;
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
    widget.onDraftChanged?.call(_draftValue());
  }

  CommentComposerValue _draftValue() => CommentComposerValue(
    text: _controller.text,
    sticker: _selectedSticker,
    replyTarget: widget.replyTarget,
    image: _image,
  );

  void _notifyDraftChanged() => widget.onDraftChanged?.call(_draftValue());

  Future<void> _toggleFullEditor() async {
    if (widget.fullEditor) {
      Navigator.of(context).maybePop();
      return;
    }
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          backgroundColor: ZhPalette.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: CommentComposerSheet(
              api: widget.api,
              title: widget.title,
              maxLength: widget.maxLength,
              initialText: _controller.text,
              initialSticker: _selectedSticker,
              initialImage: _image,
              initialEmoticonGroups: _groups.isEmpty ? null : _groups,
              initialShowEmoticons: _showEmoticons,
              replyTarget: widget.replyTarget,
              enableImage: widget.enableImage,
              fullEditor: true,
              onDraftChanged: (draft) {
                if (!mounted) return;
                if (_controller.text != draft.text) {
                  _controller.value = TextEditingValue(
                    text: draft.text,
                    selection: TextSelection.collapsed(
                      offset: draft.text.length,
                    ),
                  );
                }
                if (_selectedSticker != draft.sticker ||
                    _image != draft.image) {
                  setState(() {
                    _selectedSticker = draft.sticker;
                    _image = draft.image;
                  });
                }
              },
              onSubmit: widget.onSubmit,
            ),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: .97, end: 1.0).animate(curved),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
      ),
    );
    if (mounted && result == true) Navigator.of(context).pop(true);
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

  String _submitLabel(BuildContext context) =>
      widget.replyTarget?.isReply == true
      ? context.zhL10n.commonReply
      : context.zhL10n.commonPublish;

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
      _showTip(context.zhL10n.commentSignInRequired);
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
    _notifyDraftChanged();
  }

  void _mention() {
    if (_showEmoticons) {
      setState(() => _showEmoticons = false);
    }
    final targetName = widget.replyTarget?.targetUserName.trim() ?? '';
    if (targetName.isEmpty) {
      _insertText('@');
      _showTip(context.zhL10n.commentUsernameRequired);
    } else {
      _insertText('@$targetName ');
      _showTip(context.zhL10n.commentMentioned(targetName));
    }
    _focusNode.requestFocus();
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
      _notifyDraftChanged();
      if (widget.api.canWrite) {
        await _ensureImageUploaded();
      } else {
        _showTip(context.zhL10n.commentImageAddedPending);
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
      throw ApiTransportException(context.zhL10n.commentUploadSignInRequired);
    }
    if (mounted) setState(() => _imageUploading = true);
    final imageUploadNoUrl = context.zhL10n.commentImageUploadNoUrl;
    try {
      final response = await widget.api.uploadCommentImage(
        bytes: attachment.bytes,
        fileName: attachment.fileName,
        mimeType: attachment.mimeType,
      );
      if (!response.isSuccess) throw response;
      final url = _uploadedImageUrl(response.json);
      if (url.isEmpty) {
        throw ApiTransportException(imageUploadNoUrl);
      }
      if (mounted && identical(_image, attachment)) {
        setState(() => _image = attachment.copyWith(url: url));
        _notifyDraftChanged();
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
    if (widget.fullEditor) {
      return _buildSurface(context, fullscreen: true);
    }
    return _KeyboardInsetLift(
      // Once selected, the emoticon panel owns the keyboard area. Do not
      // translate it with the retiring IME inset or it can disappear below
      // the bottom-sheet gesture surface during Android's animation.
      enabled: !_showEmoticons,
      child: _buildSurface(context, fullscreen: false),
    );
  }

  Widget _buildSurface(BuildContext context, {required bool fullscreen}) {
    if (fullscreen) {
      return SizedBox.expand(child: _buildSurfaceContent(context, true));
    }
    return _buildSurfaceContent(context, false);
  }

  Widget _buildSurfaceContent(BuildContext context, bool fullscreen) {
    // Subscribe only to stable metrics here. Reading MediaQuery.of(context)
    // made the complete editor (including the emoji grid) rebuild for every
    // intermediate IME inset during keyboard animation.
    final maxHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewPaddingOf(context).top -
        ZhSpace.sm;
    // The compact editor keeps the field and toolbar close together. The
    // full editor takes the page's available height and has no title band.
    final compactHeight =
        (_compactComposer ? 140.0 : 164.0) +
        (_selectedSticker == null ? 0 : 48) +
        (_image == null ? 0 : 64) +
        (_error.isEmpty ? 0 : 36);
    final targetHeight = _showEmoticons
        ? maxHeight.clamp(390.0, 520.0)
        : compactHeight.clamp(140.0, maxHeight);
    final replyHint = widget.replyTarget?.isReply == true
        ? (widget.replyTarget!.targetUserName.trim().isEmpty
              ? context.zhL10n.commentReply
              : context.zhL10n.commentReplyTo(
                  widget.replyTarget!.targetUserName.trim(),
                ))
        : '';
    return Material(
      key: const Key('comment-composer-surface'),
      color: Colors.transparent,
      clipBehavior: Clip.none,
      shape: fullscreen
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
      child: Container(
        height: fullscreen ? double.infinity : targetHeight,
        margin: fullscreen ? EdgeInsets.zero : const EdgeInsets.only(bottom: 2),
        padding: fullscreen
            ? EdgeInsets.fromLTRB(
                16,
                4,
                16,
                MediaQuery.viewPaddingOf(context).bottom,
              )
            : const EdgeInsets.fromLTRB(12, 4, 12, ZhSpace.xs),
        decoration: fullscreen
            ? BoxDecoration(color: ZhPalette.background)
            : BoxDecoration(
                color: ZhPalette.background,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ZhPalette.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
        clipBehavior: fullscreen ? Clip.none : Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (fullscreen)
              Expanded(
                child: _buildTextEditor(
                  context,
                  replyHint: replyHint,
                  fullscreen: true,
                ),
              )
            else
              SizedBox(
                height: _compactComposer ? 72.0 : 104.0,
                child: _buildTextEditor(
                  context,
                  replyHint: replyHint,
                  fullscreen: false,
                ),
              ),
            if (_selectedSticker != null)
              _SelectedSticker(
                value: _selectedSticker!,
                onRemove: () {
                  setState(() => _selectedSticker = null);
                  _notifyDraftChanged();
                },
              ),
            if (_image != null)
              _SelectedImage(
                value: _image!,
                uploading: _imageUploading,
                onRemove: () {
                  setState(() => _image = null);
                  _notifyDraftChanged();
                },
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
              padding: EdgeInsets.symmetric(horizontal: fullscreen ? 0 : 4),
              child: _ComposerToolbar(
                canSubmit: _canSubmit,
                sending: _sending,
                submitLabel: _submitLabel(context),
                onEmoticons: _toggleEmoticons,
                onMention: _mention,
                onImage: widget.enableImage ? _pickImage : null,
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
    );
  }

  Widget _buildTextEditor(
    BuildContext context, {
    required String replyHint,
    required bool fullscreen,
  }) => Stack(
    fit: StackFit.expand,
    children: [
      Padding(
        padding: EdgeInsets.only(right: fullscreen ? 44 : 42),
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
          style: TextStyle(
            color: ZhPalette.ink,
            fontSize: fullscreen ? 17 : 15,
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
            filled: true,
            fillColor: Colors.transparent,
            hintText: replyHint.isEmpty
                ? context.zhL10n.commentInputPlaceholder
                : replyHint,
            hintStyle: TextStyle(
              color: ZhPalette.subtleInk,
              fontSize: fullscreen ? 18 : 17,
            ),
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.fromLTRB(4, fullscreen ? 12 : 8, 4, 4),
          ),
        ),
      ),
      Positioned(
        top: -4,
        right: -8,
        child: Semantics(
          button: true,
          label: fullscreen
              ? context.zhL10n.commentCollapse
              : context.zhL10n.commentExpand,
          child: IconButton(
            key: const Key('comment-composer-expand'),
            tooltip: fullscreen
                ? context.zhL10n.commentCollapse
                : context.zhL10n.commentExpand,
            onPressed: _toggleFullEditor,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              fullscreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.open_in_full_rounded,
              color: ZhPalette.mutedInk,
              size: 22,
            ),
          ),
        ),
      ),
    ],
  );
}
