part of '../content_pages.dart';

const _detailBottomOverlayInset = 104.0;

class _DetailBodyProjection {
  const _DetailBodyProjection({
    required this.structuredSegments,
    required this.structuredText,
    required this.images,
    required this.videos,
    required this.inlineBlocks,
  });

  factory _DetailBodyProjection.from(Map<String, dynamic> object) {
    final structuredSegments = structuredContentSegments(object);
    final content = htmlContent(object);
    final videos = contentVideosOf(object);
    final canUseInlineBlocks =
        structuredSegments.isEmpty &&
        (content != null || videos.isNotEmpty) &&
        !(isPaidStructuredContent(object) &&
            hasUnlockedVipStructuredContent(object));
    return _DetailBodyProjection(
      structuredSegments: structuredSegments,
      // The text helper derives the same segment tree. Only use it for the
      // fallback representation, and keep its result with the document so a
      // metadata-only rebuild does not parse the body again.
      structuredText: structuredSegments.isEmpty
          ? structuredContentText(object)
          : '',
      images: contentImageUrlsOf(object, limit: 20),
      videos: videos,
      inlineBlocks: canUseInlineBlocks
          ? richContentBlocks(content ?? '', videos: videos)
          : null,
    );
  }

  final List<Map<String, dynamic>> structuredSegments;
  final String structuredText;
  final List<String> images;
  final List<RichContentVideo> videos;
  final List<RichContentBlock>? inlineBlocks;
}

extension _ContentDetailBody on _ContentDetailPageState {
  _DetailBodyProjection _bodyProjectionFor(Map<String, dynamic> object) {
    final cached = _bodyProjection;
    if (cached != null && identical(_bodyProjectionSource, object)) {
      return cached;
    }
    final next = _DetailBodyProjection.from(object);
    _bodyProjectionSource = object;
    _bodyProjection = next;
    return next;
  }

  Widget _body({double topInset = 0, Widget? answerQuestionHeader}) {
    final l10n = context.zhL10n;
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
    final bodyProjection = _bodyProjectionFor(object);
    final content = htmlContent(object);
    final structuredSegments = bodyProjection.structuredSegments;
    final structured = bodyProjection.structuredText;
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
    final images = bodyProjection.images;
    final fallbackImageSources = [
      for (final url in images) _DetailImageSource(url: url),
    ];
    final videos = bodyProjection.videos;
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
          child: ZhPill(label: l10n.detailContentIncomplete, compact: true),
        ),
      _DetailMetadata(
        metrics: metrics,
        relationship: relationship,
        // The official answer places publication/IP information after the
        // body. Keep the author metrics here and render the end metadata at
        // the natural end of the answer below.
        dateLabel: '',
        contentLabel: switch (widget.contentType) {
          'article' => l10n.contentTypeArticle,
          'pin' => l10n.contentTypeIdea,
          _ => l10n.contentTypeAnswer,
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
                        ? l10n.detailPaidUnlocked
                        : l10n.detailPaidLocked,
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
          fallbackImages: images,
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
          precomputedBlocks: bodyProjection.inlineBlocks,
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
            child: Text(l10n.detailRelatedLoadFailed),
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
      label: context.zhL10n.detailViewCommentsButton,
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
                const ZhProgressiveGlassBackdrop(),
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
