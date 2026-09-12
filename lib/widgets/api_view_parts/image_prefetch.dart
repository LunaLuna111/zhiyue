part of '../api_views.dart';

enum ContentCardAction { vote, downvote, favorite, comments }

/// Starts a bounded first-screen image warm-up without blocking JSON layout.
/// Matching the card's decode dimensions lets Flutter reuse the warmed image
/// instead of decoding the original asset and then a resized copy. A small
/// worker pool avoids both serial loading and a 20+ request burst.
void prefetchObjectImages(
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
  bool deferUntilPostFrame = true,
}) {
  final candidates = <String, _ImageWarmupCandidate>{};
  for (final row in rows) {
    final feedData = cacheFeedPresentation
        ? (_feedCardStaticDataCache[row] ??= _FeedCardStaticData.from(row))
        : null;
    final avatar = feedData?.avatar ?? authorAvatarOf(row);
    if (Uri.tryParse(avatar)?.scheme == 'https') {
      candidates[avatar] = _ImageWarmupCandidate(
        url: avatar,
        cacheWidth: avatarCacheSize,
        cacheHeight: avatarCacheSize,
      );
    }
    final contentUrls =
        feedData?.images.take(3).toList(growable: false) ??
        contentImageUrlsOf(row, limit: 3);
    final usesThumbnailStrip = contentUrls.length > 1;
    for (final url in contentUrls) {
      candidates[url] = _ImageWarmupCandidate(
        url: url,
        cacheWidth: usesThumbnailStrip
            ? contentThumbnailCacheWidth
            : contentCacheWidth,
        cacheHeight: usesThumbnailStrip
            ? contentThumbnailCacheHeight
            : contentCacheHeight,
      );
      if (candidates.length >= limit) break;
    }
    if (candidates.length >= limit) break;
  }
  if (candidates.isEmpty) return;
  void startWarmup() {
    if (!context.mounted) return;
    _warmImages(
      context,
      candidates.values.take(limit).toList(growable: false),
      concurrency: concurrency,
    ).ignore();
  }

  if (deferUntilPostFrame) {
    WidgetsBinding.instance.addPostFrameCallback((_) => startWarmup());
  } else {
    startWarmup();
  }
}

final _activeImageWarmups = <String>{};

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
      try {
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
      } catch (_) {
        // The card's errorBuilder owns user-visible failure state. A failed
        // warm-up must not cancel the rest of the bounded queue.
      } finally {
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
                  label: '打开知乎验证',
                  expand: true,
                ),
                const SizedBox(height: 8),
              ],
              ZhOutlineButton(
                key: const ValueKey('api-error-retry'),
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                label: '重试',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
