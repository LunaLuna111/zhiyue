part of '../content_pages.dart';

extension _ContentDetailBody on _ContentDetailPageState {
  Widget _body() {
    if (_loading && _document == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
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
    final authorName = authorNameOf(object);
    final authorHeadline = authorHeadlineOf(object);
    final authorBadges = authorBadgeLabelsOf(object);
    final authorAvatar = authorAvatarOf(object);
    final rawAuthor = object['author'];
    final author = rawAuthor is Map
        ? rawAuthor.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};
    final authorMemberId = personMemberIdOf(author);
    final authorPageId = plainText(author['url_token']).isNotEmpty
        ? plainText(author['url_token'])
        : authorMemberId;
    final metrics = ContentMetrics.from(object);
    final authorSummary = [
      ...authorBadges.take(2),
      if (authorHeadline.isNotEmpty) authorHeadline,
      if (metrics.authorFollowerCount case final count?)
        '${compactCount(count)} 位关注者',
    ].join(' · ');
    final relationship = AnswerRelationship.from(object);
    final authorFollowing =
        _authorFollowingOverride ?? relationship.isFollowingAuthor == true;
    final images = contentImageUrlsOf(object, limit: 20);
    final videos = contentVideosOf(object);
    final dateLabel = contentDateLabel(metrics);
    final contentEndLabel = contentEndInfoLabel(object, fallback: dateLabel);
    final sourceNeedsWarning =
        _source.isNotEmpty && (truncated || listCompletenessUnknown);
    final contentList = ListView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(18),
      children: [
        if (sourceNeedsWarning)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: const ZhPill(label: '内容可能不完整', compact: true),
          ),
        ZhSurface(
          key: const ValueKey('detail-author-card'),
          onTap: authorPageId.isEmpty
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserProfileDetailPage(
                      api: widget.api,
                      memberId: authorPageId,
                    ),
                  ),
                ),
          margin: const EdgeInsets.only(bottom: ZhSpace.sm),
          radius: ZhRadius.input,
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AuthorAvatar(
                imageUrl: authorAvatar,
                fallback: authorName.isEmpty
                    ? '知'
                    : authorName.characters.first,
                size: 42,
              ),
              const SizedBox(width: ZhSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            authorName.isEmpty ? '知乎用户' : authorName,
                            key: const ValueKey('detail-author-name'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        if (authorMemberId.isNotEmpty &&
                            relationship.isAuthor != true)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 72,
                              height: 32,
                              child: FilledButton(
                                key: const ValueKey('answer-author-follow'),
                                onPressed: _authorFollowBusy
                                    ? null
                                    : () => _toggleAuthorFollowing(
                                        object,
                                        authorMemberId,
                                      ),
                                style: FilledButton.styleFrom(
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: authorFollowing
                                      ? ZhPalette.canvas
                                      : ZhPalette.ink,
                                  foregroundColor: authorFollowing
                                      ? ZhPalette.mutedInk
                                      : Colors.white,
                                  disabledBackgroundColor: authorFollowing
                                      ? ZhPalette.canvas
                                      : ZhPalette.ink,
                                  shape: const StadiumBorder(),
                                ),
                                child: _authorFollowBusy
                                    ? const SizedBox.square(
                                        dimension: 15,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        authorFollowing ? '已关注' : '+ 关注',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        if (authorPageId.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              size: 19,
                              color: ZhPalette.mutedInk,
                            ),
                          ),
                      ],
                    ),
                    if (authorSummary.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        authorSummary,
                        key: const ValueKey('detail-author-summary'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.mutedInk,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _DetailMetadata(
          metrics: metrics,
          relationship: relationship,
          // The official answer places publication/IP information after the
          // body. Keep the author metrics here and render the end metadata at
          // the natural end of the answer below.
          dateLabel: '',
          contentLabel: widget.contentType == 'article' ? '文章' : '回答',
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ZhPalette.mutedInk,
                      ),
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
            _DetailImageGallery(urls: images),
          ],
        ],
        if (contentEndLabel.isNotEmpty)
          _AnswerContentEndInfo(label: contentEndLabel),
        if (_relatedLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        if (_relatedError != null && !_relatedLoading)
          Center(
            child: TextButton(
              onPressed: _loadRelatedAnswers,
              child: const Text('加载其它回答失败，点击重试'),
            ),
          ),
        const SizedBox(height: ZhSpace.sm),
      ],
    );
    return ValueListenableBuilder<double>(
      valueListenable: _answerOverscrollNotifier,
      builder: (context, overscroll, _) {
        final next = _nextAnswerPreview;
        final showingPreview = next != null && overscroll < 0;
        final progress = showingPreview
            ? (-overscroll / answerSwitchTriggerDistance)
                  .clamp(0, 1.5)
                  .toDouble()
            : 0.0;
        return NotificationListener<ScrollNotification>(
          key: const ValueKey('answer-switch-viewport'),
          onNotification: _handleAnswerScrollNotification,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (next != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: !showingPreview,
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
