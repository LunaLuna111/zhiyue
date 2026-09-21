import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// A disk-backed image provider for Zhihu's public CDN.
///
/// Flutter's [NetworkImage] cache is memory-only. A detail page can decode a
/// handful of large body images and evict the feed's small avatars before the
/// user navigates back. Keeping the encoded bytes on disk means an evicted
/// image can be restored without another CDN request, while the regular
/// [ImageCache] still owns decoded frames and its normal LRU behaviour.
@immutable
class ZhihuCachedNetworkImageProvider
    extends ImageProvider<ZhihuCachedNetworkImageProvider> {
  const ZhihuCachedNetworkImageProvider(
    this.url, {
    this.scale = 1.0,
    this.headers,
  });

  final String url;
  final double scale;
  final Map<String, String>? headers;

  @override
  Future<ZhihuCachedNetworkImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) => SynchronousFuture<ZhihuCachedNetworkImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    ZhihuCachedNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final chunks = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunks, decode),
      chunkEvents: chunks.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<ImageProvider>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    ZhihuCachedNetworkImageProvider key,
    StreamController<ImageChunkEvent> chunks,
    ImageDecoderCallback decode,
  ) async {
    try {
      final bytes = await ZhihuImageBytesCache.instance.load(
        key.url,
        headers: key.headers,
        onProgress: (loaded, total) {
          chunks.add(
            ImageChunkEvent(
              cumulativeBytesLoaded: loaded,
              expectedTotalBytes: total,
            ),
          );
        },
      );
      if (bytes.isEmpty) {
        throw StateError('Image response is empty: ${key.url}');
      }
      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (error) {
      // Match NetworkImage's retry semantics. A failed request must not stay
      // as a permanently failed entry in Flutter's global ImageCache.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      await chunks.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! ZhihuCachedNetworkImageProvider) return false;
    return _canonicalImageUrl(other.url) == _canonicalImageUrl(url) &&
        other.scale == scale &&
        mapEquals(other.headers, headers);
  }

  @override
  int get hashCode => Object.hash(
    _canonicalImageUrl(url),
    scale,
    headers == null ? null : Object.hashAll(headers!.entries),
  );

  @override
  String toString() =>
      '${objectRuntimeType(this, 'ZhihuCachedNetworkImageProvider')}('
      '"$url", scale: ${scale.toStringAsFixed(1)})';
}

/// `Image.network`-compatible widget that uses [ZhihuCachedNetworkImageProvider].
/// The default gapless behaviour intentionally keeps the previous frame while
/// a URL variant is being resolved, preventing avatar flashes during list
/// rebuilds.
class ZhihuImage extends StatelessWidget {
  const ZhihuImage.network(
    this.src, {
    super.key,
    this.imageKey,
    this.scale = 1.0,
    this.frameBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = true,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.medium,
    this.headers,
    this.cacheWidth,
    this.cacheHeight,
  }) : assert(cacheWidth == null || cacheWidth > 0),
       assert(cacheHeight == null || cacheHeight > 0);

  final String src;

  /// Key forwarded to the concrete [Image] widget.
  ///
  /// [key] belongs to this reusable wrapper. Keeping the two keys separate
  /// avoids exposing the same semantic node twice in the widget tree while
  /// still allowing image-focused tests and accessibility tooling to target
  /// the rendered image.
  final Key? imageKey;
  final double scale;
  final ImageFrameBuilder? frameBuilder;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final double? width;
  final double? height;
  final Color? color;
  final Animation<double>? opacity;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final bool isAntiAlias;
  final FilterQuality filterQuality;
  final Map<String, String>? headers;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) => Image(
    key: imageKey,
    image: ResizeImage.resizeIfNeeded(
      cacheWidth,
      cacheHeight,
      ZhihuCachedNetworkImageProvider(src, scale: scale, headers: headers),
    ),
    frameBuilder: frameBuilder,
    loadingBuilder: loadingBuilder,
    errorBuilder: errorBuilder,
    semanticLabel: semanticLabel,
    excludeFromSemantics: excludeFromSemantics,
    width: width,
    height: height,
    color: color,
    opacity: opacity,
    colorBlendMode: colorBlendMode,
    fit: fit,
    alignment: alignment,
    repeat: repeat,
    centerSlice: centerSlice,
    matchTextDirection: matchTextDirection,
    gaplessPlayback: gaplessPlayback,
    isAntiAlias: isAntiAlias,
    filterQuality: filterQuality,
  );
}

/// Coalesces simultaneous requests and persists encoded image bytes.
class ZhihuImageBytesCache {
  ZhihuImageBytesCache._();

  static final instance = ZhihuImageBytesCache._();
  final _store = _ZhihuImageDiskStore();
  final _inFlight = <String, Future<Uint8List>>{};

  Future<Uint8List> load(
    String url, {
    Map<String, String>? headers,
    void Function(int loaded, int? total)? onProgress,
  }) {
    final canonical = _canonicalImageUrl(url);
    final existing = _inFlight[canonical];
    if (existing != null) return existing;
    final request = _load(
      canonical,
      url,
      headers: headers,
      onProgress: onProgress,
    );
    _inFlight[canonical] = request;
    return request.whenComplete(() => _inFlight.remove(canonical));
  }

  Future<Uint8List> _load(
    String canonical,
    String requestUrl, {
    required Map<String, String>? headers,
    required void Function(int loaded, int? total)? onProgress,
  }) async {
    final cached = await _store.read(canonical);
    if (cached != null && cached.isNotEmpty) return cached;

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(requestUrl));
      if (headers != null) request.headers.addAll(headers);
      final response = await client.send(request);
      if (response.statusCode != 200) {
        await response.stream.drain<void>();
        throw HttpException(
          'Image request failed (${response.statusCode})',
          uri: Uri.tryParse(requestUrl),
        );
      }
      final builder = BytesBuilder(copy: false);
      var loaded = 0;
      final contentLength = response.contentLength;
      final total = contentLength != null && contentLength > 0
          ? contentLength
          : null;
      await for (final chunk in response.stream) {
        builder.add(chunk);
        loaded += chunk.length;
        onProgress?.call(loaded, total);
      }
      final bytes = builder.takeBytes();
      if (bytes.isEmpty) throw StateError('Image response is empty');
      await _store.write(canonical, bytes);
      return bytes;
    } finally {
      client.close();
    }
  }
}

class _ZhihuImageDiskStore {
  static const _maxFileBytes = 12 * 1024 * 1024;
  static const _maxTotalBytes = 192 * 1024 * 1024;
  static const _touchInterval = Duration(minutes: 5);
  static const _maxTouchMarks = 512;

  Directory? _directory;
  Future<Directory?>? _directoryFuture;
  Future<void>? _trimFuture;
  final _touchMarks = <String, DateTime>{};

  Future<Directory?> _getDirectory() {
    final existing = _directoryFuture;
    if (existing != null) return existing;
    final future = () async {
      try {
        final root = await getApplicationSupportDirectory();
        final directory = Directory('${root.path}/zhihu-image-cache');
        await directory.create(recursive: true);
        _directory = directory;
        return directory;
      } catch (_) {
        return null;
      }
    }();
    _directoryFuture = future;
    return future;
  }

  File _file(Directory directory, String key) {
    final digest = crypto.sha256
        .convert(const Utf8Encoder().convert(key))
        .toString();
    return File('${directory.path}/$digest.img');
  }

  Future<Uint8List?> read(String key) async {
    final directory = _directory ?? await _getDirectory();
    if (directory == null) return null;
    try {
      final file = _file(directory, key);
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty || bytes.length > _maxFileBytes) {
        try {
          await file.delete();
        } catch (_) {}
        return null;
      }
      // Do not write mtime metadata on every cache hit. Fast scrolling often
      // revisits the same thumbnails; throttling keeps disk maintenance from
      // competing with image decode while retaining a useful LRU signal.
      final now = DateTime.now();
      final lastTouch = _touchMarks[key];
      if (lastTouch == null || now.difference(lastTouch) >= _touchInterval) {
        _touchMarks.remove(key);
        if (_touchMarks.length >= _maxTouchMarks) {
          _touchMarks.remove(_touchMarks.keys.first);
        }
        _touchMarks[key] = now;
        unawaited(_touch(file));
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _touch(File file) async {
    try {
      await file.setLastModified(DateTime.now());
    } catch (_) {}
  }

  Future<void> write(String key, Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > _maxFileBytes) return;
    final directory = _directory ?? await _getDirectory();
    if (directory == null) return;
    try {
      final target = _file(directory, key);
      final temporary = File('${target.path}.$pid.tmp');
      await temporary.writeAsBytes(bytes, flush: false);
      await temporary.rename(target.path);
      _scheduleTrim(directory);
    } catch (_) {
      // Disk caching is an optimization; a read-only/low-space cache must
      // never turn a successful network image into a visible failure.
    }
  }

  void _scheduleTrim(Directory directory) {
    if (_trimFuture != null) return;
    final trim = _trim(directory);
    _trimFuture = trim;
    // _trim catches filesystem errors internally.  Use a success/error
    // handler so clearing the marker can never create an unhandled future.
    trim.then<void>(
      (_) {
        if (identical(_trimFuture, trim)) _trimFuture = null;
      },
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_trimFuture, trim)) _trimFuture = null;
      },
    );
  }

  Future<void> _trim(Directory directory) async {
    try {
      final files = <FileStatEntry>[];
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! File || !entity.path.endsWith('.img')) continue;
        final stat = await entity.stat();
        files.add(FileStatEntry(entity, stat.size, stat.modified));
      }
      var total = files.fold<int>(0, (sum, item) => sum + item.bytes);
      if (total <= _maxTotalBytes) return;
      files.sort((a, b) => a.modified.compareTo(b.modified));
      for (final item in files) {
        if (total <= _maxTotalBytes) break;
        try {
          await item.file.delete();
        } catch (_) {}
        total -= item.bytes;
      }
    } catch (_) {}
  }
}

class FileStatEntry {
  const FileStatEntry(this.file, this.bytes, this.modified);

  final File file;
  final int bytes;
  final DateTime modified;
}

String _canonicalImageUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasScheme) return value.trim();
  return uri.replace(fragment: '').toString();
}
