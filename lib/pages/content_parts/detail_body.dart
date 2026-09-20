part of '../content_pages.dart';

const _detailBottomOverlayInset = 104.0;

// The question entry sits directly below the transparent detail toolbar. It
// needs blur for the collapsing transition, but the app-bar's blue tint here
// creates a hard coloured seam against the answer body.
const _answerQuestionHeaderGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x24FFFFFF), Color(0x0CFFFFFF), Color(0x00FFFFFF)],
  stops: [0, .38, 1],
);

extension _ContentDetailBody on _ContentDetailPageState {
  Widget _body({double topInset = 0, Widget? answerQuestionHeader}) {
    if (_loading && _document == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        padding: EdgeInsets.only(top: topInset),
        children: [
          SizedBox(
            height: 330,
            child: ApiErrorView(error: _error!, onRetry: _load),
          ),
          _commentsButton(),
        ],
      );
    }
    final object = _document ?? <String, dynamic>{};
    final content = htmlContent(object);
    final structuredSegments = structuredContentSegments(object);
    final structured = structuredContentText(object);
    final contentText = plainText(content);
    final paidContent = isPaidStructuredContent(object);
    final paidContentUnlocked = hasUnlockedVipStructuredContent(object);
    final useVipStructuredBody = paidContentUnlocked && structured.isNotEmpty;
    final summary = useVipStructuredBody
        ? structured
        : contentText.isNotEmpty
        ? contentText
        : structured.isNotEmpty
        ? structured
        : subtitleOf(object);
    final truncated =
        isPaidStructuredContentLocked(object) ||
        (!hasUnlockedVipStructuredContent(object) &&
            (object['content_need_truncated'] == true ||
                object['force_login_when_click_read_more'] == true));
    final listCompletenessUnknown = _source == '推荐/列表响应随附内容';
    final metrics = ContentMetrics.from(object);
    final relationship = AnswerRelationship.from(object);
    final images = contentImageUrlsOf(object, limit: 20);
    final fallbackImageSources = [
      for (final url in images) _DetailImageSource(url: url),
    ];
    final videos = contentVideosOf(object);
    final dateLabel = contentDateLabel(metrics);
    final contentEndLabel = contentEndInfoLabel(object, fallback: dateLabel);
    final sourceNeedsWarning =
        _source.isNotEmpty && (truncated || listCompletenessUnknown);
    final objectTitle = _explicitContentTitle(object);
    final bodyTitle = objectTitle.isNotEmpty
        ? objectTitle
        : _explicitContentTitle(_initialSemantic);
    final contentChildren = <Widget>[
      if (widget.contentType != 'answer' && bodyTitle.isNotEmpty)
        ContentDetailBodyTitle(title: bodyTitle),
      if (sourceNeedsWarning)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: const ZhPill(label: '内容可能不完整', compact: true),
        ),
      _DetailMetadata(
        metrics: metrics,
        relationship: relationship,
        // The official answer places publication/IP information after the
        // body. Keep the author metrics here and render the end metadata at
        // the natural end of the answer below.
        dateLabel: '',
        contentLabel: switch (widget.contentType) {
          'article' => '文章',
          'pin' => '想法',
          _ => '回答',
        },
      ),
      if (paidContent)
        Padding(
          padding: const EdgeInsets.only(bottom: ZhSpace.md),
          child: ZhSurface(
            backgroundColor: ZhPalette.canvas,
            padding: const EdgeInsets.symmetric(
              horizontal: ZhSpace.md,
              vertical: ZhSpace.sm,
            ),
            child: Row(
              children: [
                Icon(
                  paidContentUnlocked
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  size: 19,
                  color: ZhPalette.mutedInk,
                ),
                const SizedBox(width: ZhSpace.sm),
                Expanded(
                  child: Text(
                    paidContentUnlocked
                        ? '盐选会员内容已解锁，以下为当前账号可读的完整正文。'
                        : '这是盐选会员内容，当前账号返回的正文仍处于未解锁状态。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: ZhPalette.mutedInk),
                  ),
                ),
              ],
            ),
          ),
        ),
      if (structuredSegments.isNotEmpty)
        StructuredAnswerContent(
          segments: structuredSegments,
          videos: videos,
          videoApi: widget.api,
          contentType: widget.contentType,
          contentId: widget.contentId,
          onSentenceComments: _openSentenceComments,
          onCommentSelection: _commentSelectedText,
          onLink: _openBodyLink,
        )
      else if (contentText.isEmpty &&
          videos.isNotEmpty &&
          summary.isNotEmpty) ...[
        _ZhihuSelectableText(
          summary,
          style: Theme.of(context).textTheme.bodyLarge,
          onCommentSelection: _commentSelectedText,
          selectionContext: ContentSelectionContext(
            contentType: widget.contentType,
            contentId: widget.contentId,
            source: 'fallback',
          ),
        ),
        const SizedBox(height: ZhSpace.md),
      ],
      if (structuredSegments.isEmpty &&
          !useVipStructuredBody &&
          (content != null || videos.isNotEmpty))
        InlineRichContent(
          html: content ?? '',
          fallbackImages: images,
          videos: videos,
          videoApi: widget.api,
          contentType: widget.contentType,
          contentId: widget.contentId,
          onCommentSelection: _commentSelectedText,
          onLink: _openBodyLink,
        )
      else if (structuredSegments.isEmpty && !useVipStructuredBody) ...[
        if (summary.isNotEmpty)
          _ZhihuSelectableText(
            summary,
            style: Theme.of(context).textTheme.bodyLarge,
            onCommentSelection: _commentSelectedText,
            selectionContext: ContentSelectionContext(
              contentType: widget.contentType,
              contentId: widget.contentId,
              source: 'fallback',
            ),
          ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: ZhSpace.md),
          _DetailImageWarmup(
            sources: fallbackImageSources,
            child: _DetailImageGallery(sources: fallbackImageSources),
          ),
        ],
      ],
      if (contentEndLabel.isNotEmpty)
        _AnswerContentEndInfo(label: contentEndLabel),
      // The related-answer request is a hidden warm-up. Showing its
      // progress ring at the end of a short answer makes the already
      // rendered next-answer detail look like it is still loading. Keep
      // the body stable while the warm-up runs; failures still expose the
      // explicit retry action below.
      if (_relatedError != null && !_relatedLoading)
        Center(
          child: TextButton(
            onPressed: _loadRelatedAnswers,
            child: const Text('加载其它回答失败，点击重试'),
          ),
        ),
      const SizedBox(height: ZhSpace.sm),
    ];
    final contentList = CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        if (answerQuestionHeader != null)
          SliverPersistentHeader(
            floating: true,
            delegate: _CollapsibleAnswerQuestionHeaderDelegate(
              child: answerQuestionHeader,
              topInset: topInset,
            ),
          )
        else
          SliverToBoxAdapter(child: SizedBox(height: topInset)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            _detailBottomOverlayInset,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(contentChildren),
          ),
        ),
      ],
    );
    return ValueListenableBuilder<double>(
      valueListenable: _answerOverscrollNotifier,
      builder: (context, overscroll, _) {
        final next = _nextAnswerPreview;
        final previous = _previousAnswerPreview;
        final showingNextPreview = next != null && overscroll < 0;
        final showingPreviousPreview = previous != null && overscroll > 0;
        final showingPreview = showingNextPreview || showingPreviousPreview;
        final progress = showingPreview
            ? (overscroll.abs() / answerSwitchTriggerDistance)
                  .clamp(0, 1.5)
                  .toDouble()
            : 0.0;
        return NotificationListener<ScrollNotification>(
          key: const ValueKey('answer-switch-viewport'),
          onNotification: _handleAnswerScrollNotification,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (previous != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    ignoring: !showingPreviousPreview,
                    child: _AnswerSwitchPreview(
                      key: ValueKey('answer-switch-previous-${idOf(previous)}'),
                      value: previous,
                      progress: progress,
                      triggered:
                          _answerOverscrollRaw.abs() >=
                          answerSwitchTriggerDistance,
                      previous: true,
                      onTap: _switchToPreviousAnswer,
                    ),
                  ),
                ),
              if (next != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: !showingNextPreview,
                    child: _AnswerSwitchPreview(
                      key: ValueKey('answer-switch-next-${idOf(next)}'),
                      value: next,
                      progress: progress,
                      triggered:
                          _answerOverscrollRaw >= answerSwitchTriggerDistance,
                      onTap: () => _switchToNextAnswer(next),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(0, overscroll),
                // Keep the scroll viewport behind the translucent top bar.
                // The collapsible header reserves the initial safe area
                // itself, so later answer text can scroll under the bar and
                // be softened by its progressive glass backdrop.
                child: contentList,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _commentsButton() => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: ZhOutlineButton(
      onPressed: _openComments,
      icon: Icons.forum_outlined,
      label: '查看评论',
      expand: true,
    ),
  );
}

class _CollapsibleAnswerQuestionHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  const _CollapsibleAnswerQuestionHeaderDelegate({
    required this.child,
    required this.topInset,
  });

  static const double _height = 80;

  final Widget child;
  final double topInset;

  @override
  double get minExtent => topInset;

  @override
  double get maxExtent => topInset + _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final visibleHeight = (maxExtent - shrinkOffset - topInset).clamp(
      0.0,
      _height,
    );
    final reveal = visibleHeight / _height;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: topInset,
          bottom: 0,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ZhProgressiveGlassBackdrop(
                  gradient: _answerQuestionHeaderGradient,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: (reveal * 1.15).clamp(0.0, 1.0),
                    child: SizedBox(height: _height, child: child),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _CollapsibleAnswerQuestionHeaderDelegate old) =>
      old.child != child;
}
