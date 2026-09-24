part of '../content_pages.dart';

/// Privacy-first native renderer for videos embedded in an answer.
///
/// The poster is passive content, while the controller and media connection
/// are created only after an explicit tap. Playlist URLs never receive the
/// API session headers; only the static app User-Agent and public Referer are
/// sent, matching the existing image profile.
class InlineAnswerVideo extends StatefulWidget {
  const InlineAnswerVideo({
    super.key,
    required this.video,
    this.api,
    this.autoplay = false,
    this.immersive = false,
    this.showCaption = true,
  });

  final RichContentVideo video;
  final ZhihuApiClient? api;
  final bool autoplay;
  final bool immersive;
  final bool showCaption;

  @override
  State<InlineAnswerVideo> createState() => _InlineAnswerVideoState();
}

class _InlineAnswerVideoState extends State<InlineAnswerVideo>
    with WidgetsBindingObserver {
  static _InlineAnswerVideoState? _activePlayback;

  VideoPlayerController? _controller;
  VideoPlayerController? _pendingController;
  Uri? _activeSource;
  final ValueNotifier<VideoPlayerController?> _fullscreenController =
      ValueNotifier<VideoPlayerController?>(null);
  RichContentVideo? _refreshedVideo;
  final Set<String> _failedSources = <String>{};
  int _loadGeneration = 0;
  int _automaticRecoveryCount = 0;
  bool _initializing = false;
  bool _lensRefreshAttempted = false;
  bool _handlingRuntimeError = false;
  bool _appIsResumed = true;
  bool _routeIsCurrent = true;
  bool _allowCoveredPlayback = false;
  bool _autoplayRequested = false;
  String _error = '';

  bool get _isLocked {
    final refreshed = _refreshedVideo;
    // In the original player `is_paid` selects the paid-content playback
    // mark, but it does not disable an already entitled playlist. The server's
    // explicit `is_disabled_play` flag is the authoritative hard stop.
    return widget.video.isDisabledPlay || refreshed?.isDisabledPlay == true;
  }

  bool get _platformUnavailable => !_supportsPlayer && !zhIsFlutterTest;

  bool get _supportsPlayer =>
      !zhIsFlutterTest &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  bool get _canContinueLoad =>
      mounted &&
      _appIsResumed &&
      (_routeIsCurrent || _allowCoveredPlayback) &&
      !_isLocked;

  String get _posterUrl {
    for (final value in [
      widget.video.posterUrl,
      _refreshedVideo?.posterUrl ?? '',
    ]) {
      final uri = Uri.tryParse(value);
      if (uri != null && _isApprovedZhihuMediaUri(uri)) return value;
    }
    return '';
  }

  String get _title => widget.video.title.isNotEmpty
      ? widget.video.title
      : _refreshedVideo?.title ?? '';

  int? get _durationSeconds =>
      widget.video.durationSeconds ?? _refreshedVideo?.durationSeconds;

  @override
  void initState() {
    super.initState();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _appIsResumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (_routeIsCurrent && !isCurrent && !_allowCoveredPlayback) {
      _cancelPendingLoad();
      unawaited(_pauseQuietly(_controller));
    }
    _routeIsCurrent = isCurrent;
    if (widget.autoplay && isCurrent && !_autoplayRequested) {
      _autoplayRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_togglePlayback());
      });
    }
  }

  @override
  void didUpdateWidget(covariant InlineAnswerVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final playbackContractChanged =
        oldWidget.video.videoId != widget.video.videoId ||
        !listEquals(oldWidget.video.sourceUrls, widget.video.sourceUrls) ||
        !mapEquals(oldWidget.video.sourceFormats, widget.video.sourceFormats) ||
        oldWidget.video.isPaid != widget.video.isPaid ||
        oldWidget.video.isTrial != widget.video.isTrial ||
        oldWidget.video.isDisabledPlay != widget.video.isDisabledPlay;
    if (playbackContractChanged) {
      _invalidatePlayback();
      _refreshedVideo = null;
      _lensRefreshAttempted = false;
      _error = '';
      _autoplayRequested = false;
      if (widget.autoplay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_autoplayRequested) {
            _autoplayRequested = true;
            unawaited(_togglePlayback());
          }
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsResumed = state == AppLifecycleState.resumed;
    if (state != AppLifecycleState.resumed) {
      _cancelPendingLoad();
      unawaited(_pauseQuietly(_controller));
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _invalidatePlayback();
    _fullscreenController.dispose();
    super.dispose();
  }

  void _cancelPendingLoad() {
    _loadGeneration += 1;
    _initializing = false;
    final pending = _pendingController;
    _pendingController = null;
    if (pending != null) unawaited(_safeDispose(pending));
  }

  void _invalidatePlayback() {
    _cancelPendingLoad();
    final controller = _controller;
    _controller = null;
    _fullscreenController.value = null;
    _activeSource = null;
    _failedSources.clear();
    _automaticRecoveryCount = 0;
    _handlingRuntimeError = false;
    if (identical(_activePlayback, this)) _activePlayback = null;
    if (controller != null) {
      controller.removeListener(_handleControllerValue);
      unawaited(_safeDispose(controller));
    }
  }

  Future<void> _safeDispose(VideoPlayerController controller) async {
    try {
      await controller.dispose();
    } catch (_) {
      // A pending platform create may complete after cancellation. Generation
      // checks prevent it from being attached even if disposal reports late.
    }
  }

  Future<void> _pauseQuietly(VideoPlayerController? controller) async {
    if (controller == null) return;
    try {
      await controller.pause();
    } catch (_) {
      // A competing source/route may have disposed the controller first.
    }
  }

  List<Uri> _approvedSources(Iterable<String> values) {
    final result = <Uri>[];
    for (final value in values) {
      final uri = Uri.tryParse(value);
      if (uri == null || !_isApprovedZhihuMediaUri(uri)) continue;
      if (!result.any((existing) => existing.toString() == uri.toString())) {
        result.add(uri);
      }
    }
    return result;
  }

  bool _isApprovedZhihuMediaUri(Uri uri) {
    if (uri.scheme.toLowerCase() != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.fragment.isNotEmpty ||
        (uri.hasPort && uri.port != 443)) {
      return false;
    }
    final host = uri.host.toLowerCase();
    return host == 'zhihu.com' ||
        host.endsWith('.zhihu.com') ||
        host == 'zhimg.com' ||
        host.endsWith('.zhimg.com') ||
        host == 'vzuu.com' ||
        host.endsWith('.vzuu.com');
  }

  Future<void> _togglePlayback() async {
    if (_isLocked || _initializing || !_appIsResumed || !_routeIsCurrent) {
      return;
    }
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      try {
        if (controller.value.isPlaying) {
          await controller.pause();
        } else {
          _claimPlayback();
          if (controller.value.position >= controller.value.duration) {
            await controller.seekTo(Duration.zero);
          }
          if (_canContinueLoad) await controller.play();
        }
      } catch (_) {
        _handlePlaybackFailure(controller);
      }
      return;
    }
    if (!_supportsPlayer) {
      if (!zhIsFlutterTest && mounted) {
        setState(() => _error = context.zhL10n.inlineVideoPlatformUnsupported);
      }
      return;
    }
    if (_error.isNotEmpty) {
      // The refresh icon represents a new explicit attempt. A transient Lens
      // or CDN failure in the previous attempt must not poison this one.
      _failedSources.clear();
      _lensRefreshAttempted = false;
      _automaticRecoveryCount = 0;
    }
    if (controller != null) {
      controller.removeListener(_handleControllerValue);
      _controller = null;
      _fullscreenController.value = null;
      _activeSource = null;
      await _safeDispose(controller);
    }
    await _initializeAndPlay();
  }

  Future<void> _initializeAndPlay() async {
    if (!_canContinueLoad || _initializing) return;
    final generation = ++_loadGeneration;
    final requestedVideoId = widget.video.videoId;
    final deadline = DateTime.now().add(const Duration(seconds: 45));
    setState(() {
      _initializing = true;
      _error = '';
    });
    final attempted = <String>{..._failedSources};
    try {
      var sources = _approvedSources([
        ...widget.video.sourceUrls,
        ...?_refreshedVideo?.sourceUrls,
      ]);
      if (sources.isNotEmpty && _isLikelyExpired(sources.first)) {
        await _refreshLensMetadata(generation, requestedVideoId);
        if (!_isCurrentLoad(generation, requestedVideoId)) return;
        sources = _approvedSources([
          ...?_refreshedVideo?.sourceUrls,
          ...widget.video.sourceUrls,
        ]);
      }
      if (sources.isEmpty) {
        await _refreshLensMetadata(generation, requestedVideoId);
        if (!_isCurrentLoad(generation, requestedVideoId)) return;
        sources = _approvedSources(_refreshedVideo?.sourceUrls ?? const []);
      }
      if (await _trySources(
        sources,
        attempted,
        generation,
        requestedVideoId,
        deadline,
      )) {
        return;
      }
      if (!_isCurrentLoad(generation, requestedVideoId)) return;

      // Signed playlist URLs may expire. Match the original player's
      // video-ID fallback once, but keep the metadata response in memory only.
      await _refreshLensMetadata(generation, requestedVideoId);
      if (!_isCurrentLoad(generation, requestedVideoId)) return;
      final refreshed =
          _approvedSources(_refreshedVideo?.sourceUrls ?? const [])
              .where((uri) => !attempted.contains(uri.toString()))
              .toList(growable: false);
      if (await _trySources(
        refreshed,
        attempted,
        generation,
        requestedVideoId,
        deadline,
      )) {
        return;
      }
      if (_isCurrentLoad(generation, requestedVideoId)) {
        if (identical(_activePlayback, this) && _controller == null) {
          _activePlayback = null;
        }
        setState(() => _error = context.zhL10n.inlineVideoLoadFailed);
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _initializing = false);
      }
    }
  }

  bool _isCurrentLoad(int generation, String requestedVideoId) =>
      generation == _loadGeneration &&
      widget.video.videoId == requestedVideoId &&
      _canContinueLoad;

  Future<bool> _trySources(
    List<Uri> sources,
    Set<String> attempted,
    int generation,
    String requestedVideoId,
    DateTime deadline,
  ) async {
    final candidates = sources.where(
      (source) => !attempted.contains(source.toString()),
    );
    for (final source in candidates) {
      if (!_isCurrentLoad(generation, requestedVideoId)) return false;
      final sourceKey = source.toString();
      final remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) return false;
      attempted.add(sourceKey);
      final controller = VideoPlayerController.networkUrl(
        source,
        formatHint: _formatHint(source),
        httpHeaders: zhihuImageRequestHeaders,
      );
      _pendingController = controller;
      try {
        final timeout = remaining < const Duration(seconds: 8)
            ? remaining
            : const Duration(seconds: 8);
        await controller.initialize().timeout(timeout);
        if (!_isCurrentLoad(generation, requestedVideoId) ||
            !identical(_pendingController, controller)) {
          if (identical(_pendingController, controller)) {
            _pendingController = null;
          }
          await _safeDispose(controller);
          return false;
        }
        _claimPlayback();
        if (_canContinueLoad) await controller.play();
        if (!_isCurrentLoad(generation, requestedVideoId) ||
            !identical(_pendingController, controller) ||
            !identical(_activePlayback, this)) {
          await controller.pause();
          if (identical(_pendingController, controller)) {
            _pendingController = null;
          }
          await _safeDispose(controller);
          return false;
        }
        if (controller.value.hasError) throw StateError('video playback error');
        _pendingController = null;
        controller.addListener(_handleControllerValue);
        _fullscreenController.value = controller;
        setState(() {
          _controller = controller;
          _activeSource = source;
          _error = '';
        });
        return true;
      } catch (_) {
        if (identical(_pendingController, controller)) {
          _pendingController = null;
        }
        if (_isCurrentLoad(generation, requestedVideoId)) {
          _failedSources.add(sourceKey);
        }
        unawaited(_safeDispose(controller));
        if (!_isCurrentLoad(generation, requestedVideoId)) return false;
      }
    }
    return false;
  }

  VideoFormat? _formatHint(Uri source) {
    final sourceKey = source.toString();
    final format =
        (widget.video.sourceFormats[sourceKey] ??
                _refreshedVideo?.sourceFormats[sourceKey] ??
                source.queryParameters['f'] ??
                '')
            .toLowerCase();
    final path = source.path.toLowerCase();
    if (path.endsWith('.m3u8') ||
        format.contains('m3u8') ||
        format.contains('mpegurl') ||
        format == 'hls') {
      return VideoFormat.hls;
    }
    if (path.endsWith('.mpd') || format.contains('dash')) {
      return VideoFormat.dash;
    }
    if (format.contains('smooth') || format == 'ss') return VideoFormat.ss;
    return null;
  }

  bool _isLikelyExpired(Uri source) {
    for (final key in const ['deadline', 'expires', 'expire', 'exp']) {
      final raw = source.queryParameters[key];
      final parsed = int.tryParse(raw ?? '');
      if (parsed == null || parsed <= 0) continue;
      final seconds = parsed > 100000000000 ? parsed ~/ 1000 : parsed;
      return seconds <= DateTime.now().millisecondsSinceEpoch ~/ 1000 + 15 * 60;
    }
    return false;
  }

  Future<void> _refreshLensMetadata(
    int generation,
    String requestedVideoId,
  ) async {
    if (_lensRefreshAttempted ||
        widget.api == null ||
        requestedVideoId.isEmpty ||
        !_isCurrentLoad(generation, requestedVideoId)) {
      return;
    }
    _lensRefreshAttempted = true;
    try {
      final response = await widget.api!.publicLensVideoGet(requestedVideoId);
      if (!_isCurrentLoad(generation, requestedVideoId)) return;
      final map = response.isSuccess ? response.jsonMap : null;
      if (map == null) return;
      final videos = contentVideosOf(map);
      if (videos.isEmpty || !_isCurrentLoad(generation, requestedVideoId)) {
        return;
      }
      final exact = videos.where((video) => video.videoId == requestedVideoId);
      final idless = videos.where((video) => video.videoId.isEmpty);
      final refreshed = exact.isNotEmpty
          ? exact.first
          : idless.isNotEmpty
          ? idless.first
          : null;
      if (refreshed == null) return;
      setState(() => _refreshedVideo = refreshed);
    } catch (_) {
      // The existing playlist remains usable when an anonymous metadata
      // refresh is unavailable. The final player error is shown only if every
      // candidate source also fails.
    }
  }

  void _claimPlayback() {
    final previous = _activePlayback;
    _activePlayback = this;
    if (previous != null && !identical(previous, this)) {
      previous._cancelPendingLoad();
      unawaited(previous._pauseQuietly(previous._controller));
      if (previous.mounted) previous.setState(() {});
    }
  }

  void _handleControllerValue() {
    final controller = _controller;
    if (controller == null ||
        !controller.value.hasError ||
        _handlingRuntimeError) {
      return;
    }
    _handlePlaybackFailure(controller);
  }

  void _handlePlaybackFailure(VideoPlayerController failedController) {
    if (!identical(_controller, failedController) || _handlingRuntimeError) {
      return;
    }
    _handlingRuntimeError = true;
    final failedSource = _activeSource;
    if (failedSource != null) _failedSources.add(failedSource.toString());
    failedController.removeListener(_handleControllerValue);
    _controller = null;
    _fullscreenController.value = null;
    _activeSource = null;
    if (identical(_activePlayback, this)) _activePlayback = null;
    unawaited(_safeDispose(failedController));
    if (!_canContinueLoad) {
      _handlingRuntimeError = false;
      return;
    }
    if (_automaticRecoveryCount >= 2) {
      _handlingRuntimeError = false;
      setState(() => _error = context.zhL10n.inlineVideoInterruptedRetry);
      return;
    }
    _automaticRecoveryCount += 1;
    _lensRefreshAttempted = false;
    setState(() => _error = context.zhL10n.inlineVideoSwitchingLine);
    unawaited(_recoverAfterPlaybackFailure());
  }

  Future<void> _recoverAfterPlaybackFailure() async {
    try {
      await _initializeAndPlay();
    } finally {
      _handlingRuntimeError = false;
    }
  }

  Future<void> _openFullscreen() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    _allowCoveredPlayback = true;
    try {
      await _enterLandscapeFullscreen();
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => _InlineVideoFullscreenPage(
            controllerListenable: _fullscreenController,
            title: _title,
          ),
        ),
      );
    } finally {
      _allowCoveredPlayback = false;
      await _leaveLandscapeFullscreen();
      if (mounted) {
        _routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
      }
    }
  }

  bool get _supportsLandscapeFullscreen =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _enterLandscapeFullscreen() async {
    if (!_supportsLandscapeFullscreen) return;
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _leaveLandscapeFullscreen() async {
    if (!_supportsLandscapeFullscreen) return;
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  String _durationLabel(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) return '';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final controller = _controller;
    final title = _title;
    final duration = _durationLabel(_durationSeconds);
    final paidContent =
        (widget.video.isPaid && !widget.video.isTrial) ||
        (_refreshedVideo?.isPaid == true && _refreshedVideo?.isTrial == false);
    final status = _isLocked
        ? (paidContent
              ? l10n.inlineVideoPaidNoAccess
              : l10n.inlineVideoUnavailable)
        : _platformUnavailable
        ? l10n.inlineVideoPrivacyUnavailable
        : _error;
    final canTap = !_isLocked && !_platformUnavailable;
    final media = Semantics(
      button: canTap,
      label: !canTap
          ? status
          : title.isEmpty
          ? l10n.inlineVideoPlay
          : l10n.inlineVideoPlayTitle(title),
      child: _videoViewport(
        Material(
          color: Colors.black,
          child: InkWell(
            onTap: canTap ? _togglePlayback : null,
            child: controller != null && controller.value.isInitialized
                ? _activePlayer(controller)
                : _poster(duration),
          ),
        ),
      ),
    );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        media,
        if (widget.showCaption && (title.isNotEmpty || status.isNotEmpty))
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                if (title.isNotEmpty && status.isNotEmpty)
                  const SizedBox(height: 4),
                if (status.isNotEmpty)
                  Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _isLocked ? ZhPalette.subtleInk : ZhPalette.danger,
                    ),
                  ),
              ],
            ),
          )
        else if (!widget.showCaption && status.isNotEmpty)
          ColoredBox(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ),
          ),
      ],
    );
    if (widget.immersive) {
      return ColoredBox(color: Colors.black, child: content);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(ZhRadius.card),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ZhRadius.card),
        child: content,
      ),
    );
  }

  Widget _videoViewport(Widget child) => _buildInlineVideoViewport(this, child);

  Widget _poster(String duration) => _buildInlineVideoPoster(this, duration);

  Widget _activePlayer(VideoPlayerController controller) =>
      _buildInlineActivePlayer(this, controller);
}
