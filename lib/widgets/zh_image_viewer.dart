import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_log.dart';
import '../core/image_export_service.dart';
import '../core/json_tools.dart';
import '../ui/zh_glass.dart';
import '../ui/zh_theme.dart';

/// Opens the common full-screen image viewer used by answer and comment media.
///
/// The viewer deliberately receives labels and save feedback from its caller.
/// That keeps this presentation component independent from answer/comment
/// wording while ensuring both entry points use the same glass toolbar and
/// system-ui treatment.
Future<void> showZhImageViewer(
  BuildContext context, {
  required String url,
  String? originalUrl,
  required String keyPrefix,
  required String closeLabel,
  required String saveLabel,
  required String originalLabel,
  required String shareLabel,
  required String filePrefix,
  required String Function(String? location) savedMessage,
  required String saveFailedMessage,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (dialogContext) => _ZhImageViewer(
      url: url,
      originalUrl: originalUrl,
      keyPrefix: keyPrefix,
      closeLabel: closeLabel,
      saveLabel: saveLabel,
      originalLabel: originalLabel,
      shareLabel: shareLabel,
      filePrefix: filePrefix,
      savedMessage: savedMessage,
      saveFailedMessage: saveFailedMessage,
    ),
  );
}

class _ZhImageViewer extends StatefulWidget {
  const _ZhImageViewer({
    required this.url,
    required this.originalUrl,
    required this.keyPrefix,
    required this.closeLabel,
    required this.saveLabel,
    required this.originalLabel,
    required this.shareLabel,
    required this.filePrefix,
    required this.savedMessage,
    required this.saveFailedMessage,
  });

  final String url;
  final String? originalUrl;
  final String keyPrefix;
  final String closeLabel;
  final String saveLabel;
  final String originalLabel;
  final String shareLabel;
  final String filePrefix;
  final String Function(String? location) savedMessage;
  final String saveFailedMessage;

  @override
  State<_ZhImageViewer> createState() => _ZhImageViewerState();
}

class _ZhImageViewerState extends State<_ZhImageViewer> {
  late String _displayUrl;
  late final String? _originalUrl;
  var _saving = false;
  var _sharing = false;

  bool get _hasOriginal => _originalUrl != null;

  @override
  void initState() {
    super.initState();
    _displayUrl = widget.url;
    _originalUrl = _usableOriginalUrl(widget.originalUrl, widget.url);
  }

  String get _closeKey => '${widget.keyPrefix}-close';
  String get _saveKey => '${widget.keyPrefix}-save';
  String get _originalKey => '${widget.keyPrefix}-original';
  String get _shareKey => '${widget.keyPrefix}-share';

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        // UIKit interprets this field in the opposite direction from the
        // Android icon-brightness fields above.
        statusBarBrightness: Brightness.dark,
      ),
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              boundaryMargin: const EdgeInsets.all(48),
              child: SizedBox.expand(
                key: ValueKey(
                  '${widget.keyPrefix}-frame-$_displayUrl',
                ),
                child: ZhihuImage.network(
                  _displayUrl,
                  headers: zhihuImageRequestHeaders,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white70,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: padding.top + 10,
              left: 12,
              right: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ZhImageViewerGlassIconButton(
                    key: Key(_closeKey),
                    icon: const Icon(Icons.close_rounded, color: Colors.black),
                    semanticLabel: widget.closeLabel,
                    onPressed: () => Navigator.of(context).pop(),
                    size: 48,
                    iconSize: 24,
                  ),
                  const Spacer(),
                  _ZhImageViewerGlassActionGroup(
                    key: ValueKey('${widget.keyPrefix}-actions'),
                    actions: [
                      if (_hasOriginal)
                        _ZhImageViewerAction(
                          key: Key(_originalKey),
                          icon: Icon(
                            Icons.high_quality_outlined,
                            color: _saving || _sharing
                                ? ZhPalette.subtleInk
                                : Colors.black,
                          ),
                          semanticLabel: widget.originalLabel,
                          onPressed: _saving || _sharing
                              ? null
                              : _showOriginal,
                        ),
                      _ZhImageViewerAction(
                        key: Key(_saveKey),
                        icon: Icon(
                          Icons.download_rounded,
                          color: _saving ? ZhPalette.subtleInk : Colors.black,
                        ),
                        semanticLabel: widget.saveLabel,
                        onPressed: _saving ? null : _save,
                      ),
                      _ZhImageViewerAction(
                        key: Key(_shareKey),
                        icon: Icon(
                          Icons.ios_share_rounded,
                          color: _sharing ? ZhPalette.subtleInk : Colors.black,
                        ),
                        semanticLabel: widget.shareLabel,
                        onPressed: _sharing ? null : _share,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOriginal() {
    final original = _originalUrl;
    if (original == null || original == _displayUrl) return;
    setState(() => _displayUrl = original);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final location = await ImageExportService.saveNetworkImage(
        _displayUrl,
        headers: zhihuImageRequestHeaders,
        filePrefix: widget.filePrefix,
      );
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(widget.savedMessage(location))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(widget.saveFailedMessage)),
      );
      AppLogStore.instance.record(
        category: AppLogCategory.app,
        level: AppLogLevel.warning,
        message: '图片保存失败',
        details: {'error': error.toString()},
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final bytes = await ZhihuImageBytesCache.instance.load(
        _displayUrl,
        headers: zhihuImageRequestHeaders,
      );
      final extension = _imageExtension(_displayUrl);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: _imageMimeType(extension),
              name: 'zhiyue-image.$extension',
            ),
          ],
          fileNameOverrides: ['zhiyue-image.$extension'],
        ),
      );
    } catch (error) {
      AppLogStore.instance.record(
        category: AppLogCategory.app,
        level: AppLogLevel.warning,
        message: '图片分享失败',
        details: {'error': error.toString()},
      );
      // Sharing the URL remains useful if the CDN image has expired before
      // the share operation can read the encoded bytes from the cache.
      try {
        await SharePlus.instance.share(
          ShareParams(uri: Uri.parse(_displayUrl)),
        );
      } catch (_) {
        // The system share sheet is optional on some desktop/web targets.
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

String _imageExtension(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
  if (path.endsWith('.png')) return 'png';
  if (path.endsWith('.webp')) return 'webp';
  if (path.endsWith('.gif')) return 'gif';
  if (path.endsWith('.avif')) return 'avif';
  return 'jpg';
}

String _imageMimeType(String extension) => switch (extension) {
  'png' => 'image/png',
  'webp' => 'image/webp',
  'gif' => 'image/gif',
  'avif' => 'image/avif',
  _ => 'image/jpeg',
};

class _ZhImageViewerAction {
  const _ZhImageViewerAction({
    required this.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final Key key;
  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
}

class _ZhImageViewerGlassIconButton extends StatelessWidget {
  const _ZhImageViewerGlassIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    required this.size,
    required this.iconSize,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final child = Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: IconTheme(
              data: IconThemeData(size: iconSize),
              child: icon,
            ),
          ),
        ),
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: _ZhImageViewerGlassSurface(
        shape: const LiquidOval(),
        width: size,
        height: size,
        child: child,
      ),
    );
  }
}

class _ZhImageViewerGlassActionGroup extends StatelessWidget {
  const _ZhImageViewerGlassActionGroup({super.key, required this.actions});

  final List<_ZhImageViewerAction> actions;

  @override
  Widget build(BuildContext context) => _ZhImageViewerGlassSurface(
    shape: const LiquidRoundedRectangle(borderRadius: 999),
    clipBehavior: Clip.antiAlias,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final action in actions)
          Semantics(
            button: true,
            enabled: action.onPressed != null,
            label: action.semanticLabel,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                key: action.key,
                onTap: action.onPressed,
                child: SizedBox(
                  width: 48,
                  height: 52,
                  child: Center(child: action.icon),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ZhImageViewerGlassSurface extends StatelessWidget {
  const _ZhImageViewerGlassSurface({
    required this.shape,
    required this.child,
    this.width,
    this.height,
    this.clipBehavior = Clip.none,
  });

  static LiquidGlassSettings get _settings => LiquidGlassSettings(
    thickness: 28,
    blur: 12,
    chromaticAberration: .12,
    lightIntensity: .52,
    refractiveIndex: 1.48,
    saturation: .9,
    ambientStrength: .72,
    glassColor: const Color(0xDDF6F7F9),
  );

  final LiquidShape shape;
  final Widget child;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    if (!ZhGlassScope.enabledOf(context)) {
      return DecoratedBox(
        decoration: ShapeDecoration(
          color: const Color(0xF2F4F4F6),
          shape: shape,
        ),
        child: SizedBox(width: width, height: height, child: child),
      );
    }
    return GlassContainer(
      width: width,
      height: height,
      shape: shape,
      settings: _settings,
      useOwnLayer: true,
      quality: GlassQuality.standard,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

String? _usableOriginalUrl(String? candidate, String previewUrl) {
  final raw = candidate?.trim() ?? '';
  if (raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null || uri.scheme.toLowerCase() != 'https' || uri.host.isEmpty) {
    return null;
  }
  final normalized = uri.replace(fragment: '').toString();
  final preview = Uri.tryParse(previewUrl);
  final normalizedPreview = preview?.replace(fragment: '').toString();
  return normalized == normalizedPreview ? null : normalized;
}
