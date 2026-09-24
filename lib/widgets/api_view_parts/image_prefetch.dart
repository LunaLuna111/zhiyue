part of '../api_views.dart';

enum ContentCardAction { vote, downvote, favorite, comments }

/// Starts a bounded first-screen image warm-up without blocking JSON layout.
/// Matching the card's decode dimensions lets Flutter reuse the warmed image
/// instead of decoding the original asset and then a resized copy. A small
/// worker pool avoids both serial loading and a 20+ request burst.
VoidCallback prefetchObjectImages(
  BuildContext context,
  Iterable<Map<String, dynamic>> rows, {
  int limit = 12,
  int concurrency = 4,
  int avatarCacheSize = 132,
  int contentCacheWidth = 960,
  int? contentCacheHeight,
  int contentThumbnailCacheWidth = 384,
  int? contentThumbnailCacheHeight,
  bool cacheFeedPresentation = false,
  bool includeAvatars = true,
  bool deferUntilPostFrame = true,
  Duration warmupDelay = const Duration(milliseconds: 300),
  bool retainDecodedFrames = false,
}) {
  // A refresh or account-scope change can schedule a newer warm-up before the
  // previous delay expires. Keep only the latest queue for a page context so
  // stale candidates cannot decode during the next fling.
  _scheduledImageWarmups[context]?.cancel();
  final job = _ImageWarmupJob();
  _scheduledImageWarmups[context] = job;
  void cancel() {
    job.cancel();
    if (identical(_scheduledImageWarmups[context], job)) {
      _scheduledImageWarmups[context] = null;
    }
  }

  final candidates = <String, _ImageWarmupCandidate>{};
  void addCandidate(_ImageWarmupCandidate candidate) {
    candidates.putIfAbsent(candidate.url, () => candidate);
  }

  // Content thumbnails are the expensive part of a feed card. Put them ahead
  // of avatars in the queue so a first fling warms the images the user is
  // actually about to see instead of spending the small budget on several
  // 24px portraits. The map still de-duplicates URLs shared by rows.
  for (final row in rows) {
    if (candidates.length >= limit) break;
    final feedData = cacheFeedPresentation
        ? (_feedCardStaticDataCache[row] ??= _FeedCardStaticData.from(row))
        : null;
    final contentUrls =
        feedData?.images.take(3).toList(growable: false) ??
        contentImageUrlsOf(row, limit: 3);
    final usesThumbnailStrip = contentUrls.length > 1;
    for (final url in contentUrls) {
      if (candidates.length >= limit) break;
      addCandidate(
        _ImageWarmupCandidate(
          url: url,
          cacheWidth: usesThumbnailStrip
              ? contentThumbnailCacheWidth
              : contentCacheWidth,
          cacheHeight: usesThumbnailStrip
              ? contentThumbnailCacheHeight
              : contentCacheHeight,
        ),
      );
    }
  }
  if (includeAvatars) {
    for (final row in rows) {
      if (candidates.length >= limit) break;
      final feedData = cacheFeedPresentation
          ? (_feedCardStaticDataCache[row] ??= _FeedCardStaticData.from(row))
          : null;
      final avatar = feedData?.avatar ?? authorAvatarOf(row);
      if (Uri.tryParse(avatar)?.scheme == 'https') {
        addCandidate(
          _ImageWarmupCandidate(
            url: avatar,
            cacheWidth: avatarCacheSize,
            cacheHeight: avatarCacheSize,
          ),
        );
      }
    }
  }
  if (candidates.isEmpty) return cancel;
  void startWarmup() {
    if (job.cancelled || !context.mounted) return;
    _warmImages(
      context,
      candidates.values.take(limit).toList(growable: false),
      concurrency: concurrency,
      retainDecodedFrames: retainDecodedFrames,
    ).ignore();
  }

  void scheduleWarmup() {
    if (job.cancelled || !context.mounted) return;
    if (warmupDelay <= Duration.zero) {
      startWarmup();
    } else {
      // Let the first layout and gesture frame win. Image decode is
      // asynchronous, but completion still schedules raster work; starting
      // it on the same frame as a first fling causes a visible hitch.
      job.timer = Timer(warmupDelay, () {
        if (identical(_scheduledImageWarmups[context], job)) {
          _scheduledImageWarmups[context] = null;
        }
        startWarmup();
      });
    }
  }

  if (deferUntilPostFrame) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!job.cancelled) scheduleWarmup();
    });
  } else {
    scheduleWarmup();
  }
  return cancel;
}

class _ImageWarmupJob {
  Timer? timer;
  bool cancelled = false;

  void cancel() {
    cancelled = true;
    timer?.cancel();
    timer = null;
  }
}

final _scheduledImageWarmups = Expando<_ImageWarmupJob>(
  'scheduled-image-warmups',
);
final _activeImageWarmups = <String>{};
final _retainedImageFrames = <_RetainedImageFrame>[];

class _RetainedImageFrame {
  const _RetainedImageFrame(this.key, this.handle);

  final String key;
  final ImageStreamCompleterHandle handle;
}

void _retainDecodedImageFrame(String key, ImageStreamCompleter? completer) {
  if (completer == null ||
      _retainedImageFrames.any((entry) => entry.key == key)) {
    return;
  }
  _retainedImageFrames.add(_RetainedImageFrame(key, completer.keepAlive()));
  // The feed only needs a small return window. Keeping this bounded prevents
  // visiting many detail pages from turning the image warm-up into an
  // unbounded decoded-frame cache.
  while (_retainedImageFrames.length > 24) {
    _retainedImageFrames.removeAt(0).handle.dispose();
  }
}

class _ImageWarmupGate {
  static const _maxActive = 2;

  var _active = 0;
  final _waiters = <Completer<void>>[];

  Future<void> acquire() {
    if (_active < _maxActive) {
      _active++;
      return Future<void>.value();
    }
    final waiter = Completer<void>();
    _waiters.add(waiter);
    return waiter.future;
  }

  void release() {
    final next = _waiters.isEmpty ? null : _waiters.removeAt(0);
    if (next != null) {
      next.complete();
    } else {
      _active--;
    }
  }
}

final _imageWarmupGate = _ImageWarmupGate();

class _ImageWarmupCandidate {
  const _ImageWarmupCandidate({
    required this.url,
    required this.cacheWidth,
    this.cacheHeight,
  });

  final String url;
  final int cacheWidth;
  final int? cacheHeight;
}

Future<void> _warmImages(
  BuildContext context,
  List<_ImageWarmupCandidate> candidates, {
  required int concurrency,
  required bool retainDecodedFrames,
}) async {
  if (candidates.isEmpty || !context.mounted) return;
  // Capture inherited image settings while the owning element is known to be
  // alive. Each worker may await cache I/O before it reaches the next image.
  final configuration = createLocalImageConfiguration(context);
  var next = 0;
  final workerCount = concurrency.clamp(1, candidates.length);

  Future<void> worker() async {
    while (context.mounted && next < candidates.length) {
      final index = next++;
      final candidate = candidates[index];
      final warmupKey =
          '${candidate.url}|${candidate.cacheWidth}x'
          '${candidate.cacheHeight ?? 0}';
      if (!_activeImageWarmups.add(warmupKey)) continue;
      await _imageWarmupGate.acquire();
      try {
        if (!context.mounted) return;
        final provider = ResizeImage.resizeIfNeeded(
          candidate.cacheWidth,
          candidate.cacheHeight,
          ZhihuCachedNetworkImageProvider(
            candidate.url,
            headers: zhihuImageRequestHeaders,
          ),
        );
        final status = await provider.obtainCacheStatus(
          configuration: configuration,
        );
        if (status?.pending != true &&
            status?.keepAlive != true &&
            status?.live != true) {
          if (!context.mounted) return;
          await precacheImage(provider, context);
        }
        if (retainDecodedFrames && context.mounted) {
          _retainDecodedImageFrame(
            warmupKey,
            provider.resolve(configuration).completer,
          );
        }
      } catch (_) {
        // The card's errorBuilder owns user-visible failure state. A failed
        // warm-up must not cancel the rest of the bounded queue.
      } finally {
        _imageWarmupGate.release();
        _activeImageWarmups.remove(warmupKey);
      }
    }
  }

  await Future.wait(List.generate(workerCount, (_) => worker()));
}

class ApiErrorView extends StatelessWidget {
  const ApiErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.compact = false,
    this.titleOverride,
    this.detailOverride,
    this.onOpenNetworkVerification,
  });

  final Object error;
  final VoidCallback onRetry;
  final bool compact;
  final String? titleOverride;
  final String? detailOverride;
  final VoidCallback? onOpenNetworkVerification;

  @override
  Widget build(BuildContext context) {
    final failure = ApiFailure.from(error);
    final icon = switch (failure.kind) {
      ApiFailureKind.transport => Icons.wifi_off_rounded,
      ApiFailureKind.guestContext => Icons.phonelink_lock_outlined,
      ApiFailureKind.networkChallenge => Icons.verified_user_outlined,
      ApiFailureKind.authentication => Icons.login_rounded,
      ApiFailureKind.permission => Icons.lock_outline_rounded,
      ApiFailureKind.notFound => Icons.search_off_rounded,
      ApiFailureKind.rateLimited => Icons.hourglass_top_rounded,
      ApiFailureKind.server => Icons.cloud_off_outlined,
      ApiFailureKind.request => Icons.error_outline_rounded,
      ApiFailureKind.invalidResponse => Icons.data_object_rounded,
      ApiFailureKind.unknown => Icons.help_outline_rounded,
    };
    final title = titleOverride ?? failure.title;
    final detail = detailOverride ?? failure.detail;
    final canOpenNetworkVerification =
        failure.kind == ApiFailureKind.networkChallenge &&
        onOpenNetworkVerification != null;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: compact ? 38 : 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(detail, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (canOpenNetworkVerification) ...[
                ZhPrimaryButton(
                  key: const ValueKey('open-network-verification'),
                  onPressed: onOpenNetworkVerification,
                  icon: Icons.verified_user_outlined,
                  label: context.zhL10n.routingOpenVerification,
                  expand: true,
                ),
                const SizedBox(height: 8),
              ],
              ZhOutlineButton(
                key: const ValueKey('api-error-retry'),
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                label: context.zhL10n.commonRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
