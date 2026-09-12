part of '../content_pages.dart';

Widget _buildInlineVideoViewport(_InlineAnswerVideoState state, Widget child) {
  if (!state.widget.immersive) {
    return AspectRatio(aspectRatio: 16 / 9, child: child);
  }
  final width = state.widget.video.width ?? state._refreshedVideo?.width;
  final height = state.widget.video.height ?? state._refreshedVideo?.height;
  final rawAspect = width != null && height != null && height > 0
      ? width / height
      : 16 / 9;
  final preferredAspect = rawAspect >= 16 / 9
      ? 16 / 9
      : rawAspect.clamp(.72, 16 / 9).toDouble();
  return LayoutBuilder(
    builder: (context, constraints) {
      final availableWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final maxHeight = MediaQuery.sizeOf(context).height * .58;
      final desiredHeight = availableWidth / preferredAspect;
      return SizedBox(
        width: double.infinity,
        height: math.min(desiredHeight, maxHeight),
        child: child,
      );
    },
  );
}

Widget _buildInlineVideoPoster(_InlineAnswerVideoState state, String duration) {
  return Stack(
    fit: StackFit.expand,
    children: [
      if (state._posterUrl.isNotEmpty)
        ZhihuImage.network(
          key: ValueKey(
            'video-poster-${state.widget.video.videoId.isEmpty ? state._posterUrl : state.widget.video.videoId}',
          ),
          state._posterUrl,
          headers: zhihuImageRequestHeaders,
          fit: state.widget.immersive ? BoxFit.contain : BoxFit.cover,
          cacheWidth: 1080,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ColoredBox(color: Colors.black.withValues(alpha: 0.18)),
      Center(
        child: state._initializing
            ? const SizedBox.square(
                dimension: 38,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xD9000000),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Icon(
                    state._isLocked
                        ? Icons.lock_outline_rounded
                        : state._platformUnavailable
                        ? Icons.videocam_off_outlined
                        : state._error.isNotEmpty
                        ? Icons.refresh_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
      ),
      if (duration.isNotEmpty)
        Positioned(
          right: 10,
          bottom: 9,
          child: _buildInlineVideoBadge(state, duration),
        ),
    ],
  );
}

Widget _buildInlineActivePlayer(
  _InlineAnswerVideoState state,
  VideoPlayerController controller,
) {
  return ValueListenableBuilder<VideoPlayerValue>(
    valueListenable: controller,
    builder: (context, value, _) => Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
            child: VideoPlayer(controller),
          ),
        ),
        if (!value.isPlaying)
          const Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xB8000000),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ColoredBox(
            color: const Color(0xA6000000),
            child: Row(
              children: [
                IconButton(
                  onPressed: state._togglePlayback,
                  color: Colors.white,
                  icon: Icon(
                    value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Color(0x88FFFFFF),
                      backgroundColor: Color(0x55FFFFFF),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '全屏',
                  onPressed: state._openFullscreen,
                  color: Colors.white,
                  icon: const Icon(Icons.fullscreen_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInlineVideoBadge(_InlineAnswerVideoState state, String label) =>
    DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB8000000),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: Theme.of(
            state.context,
          ).textTheme.labelSmall?.copyWith(color: Colors.white),
        ),
      ),
    );

class _InlineVideoFullscreenPage extends StatelessWidget {
  const _InlineVideoFullscreenPage({
    required this.controllerListenable,
    required this.title,
  });

  final ValueListenable<VideoPlayerController?> controllerListenable;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerController?>(
      valueListenable: controllerListenable,
      builder: (context, controller, _) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (controller != null && controller.value.isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio > 0
                        ? controller.value.aspectRatio
                        : 16 / 9,
                    child: VideoPlayer(controller),
                  ),
                )
              else
                const Center(
                  child: Text(
                    '视频已停止或正在切换线路',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              Positioned(
                left: 8,
                right: 8,
                top: 4,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '返回',
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.white,
                      icon: const Icon(Icons.close_rounded),
                    ),
                    if (title.isNotEmpty)
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              if (controller != null && controller.value.isInitialized)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 18,
                  child: ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: controller,
                    builder: (context, value, _) => Row(
                      children: [
                        IconButton(
                          onPressed: () => value.isPlaying
                              ? controller.pause()
                              : controller.play(),
                          color: Colors.white,
                          icon: Icon(
                            value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        ),
                        Expanded(
                          child: VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.white,
                              bufferedColor: Color(0x88FFFFFF),
                              backgroundColor: Color(0x55FFFFFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
