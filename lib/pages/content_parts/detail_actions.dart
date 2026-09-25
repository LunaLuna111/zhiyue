part of '../content_pages.dart';

extension _ContentDetailActions on _ContentDetailPageState {
  void _openAuthorPage(String authorId) {
    final id = authorId.trim();
    if (id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileDetailPage(api: widget.api, memberId: id),
      ),
    );
  }

  void _openQuestionAnswers(String questionId, String questionTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestionAnswersPage(
          api: widget.api,
          questionId: questionId,
          title: questionTitle,
        ),
      ),
    );
  }

  Future<void> _openComments() async {
    final document = _document;
    final object = document == null
        ? const <String, dynamic>{}
        : unwrapObject(document);
    final question = _contentMap(object['question']);
    await showOfficialCommentsSheet(
      context,
      api: widget.api,
      contentType: widget.contentType,
      contentId: widget.contentId,
      contentAuthorIds: personIdentityKeys(object['author']),
      questionAuthorIds: personIdentityKeys(question?['author']),
      fallbackCount: document == null
          ? null
          : ContentMetrics.from(document).commentCount,
      onCommentCountChanged: (delta) {
        final current = _document;
        if (!mounted || current == null) return;
        final count = ContentMetrics.from(current).commentCount ?? 0;
        _updateDetailState(
          () => current['comment_count'] = math.max(0, count + delta),
        );
      },
    );
  }

  Future<void> _openSentenceComments(
    List<String> sentenceIds,
    String quote,
  ) async {
    if (sentenceIds.isEmpty) return;
    final object = _document == null
        ? const <String, dynamic>{}
        : unwrapObject(_document!);
    final question = _contentMap(object['question']);
    await showOfficialCommentsSheet(
      context,
      api: widget.api,
      contentType: widget.contentType,
      contentId: widget.contentId,
      contentAuthorIds: personIdentityKeys(object['author']),
      questionAuthorIds: personIdentityKeys(question?['author']),
      initialCommentType: 'segment',
      segmentId: sentenceIds.join(','),
      contextQuote: quote,
    );
  }

  Future<void> _commentSelectedText(ContentSelection selection) async {
    final selected = selection.normalizedQuote;
    if (selected.runes.length < 5) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.zhL10n.detailSelectionTooShort(5))),
        );
      return;
    }
    final initialText = '「$selected」\n';
    final created = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      requestFocus: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentComposerSheet(
        api: widget.api,
        title: context.zhL10n.detailCommentSelection,
        initialText: initialText,
        onSubmit: (value) async {
          if (value.text.trim() == initialText.trim()) {
            return context.zhL10n.detailCommentHint;
          }
          final response = selection.hasSegmentTarget
              ? await widget.api.createSegmentComment(
                  contentType: widget.contentType,
                  contentId: widget.contentId,
                  content: value.text,
                  selection: selection,
                  sticker: value.sticker,
                  imageUrl: value.image?.url,
                )
              : await widget.api.createComment(
                  contentType: widget.contentType,
                  contentId: widget.contentId,
                  content: value.text,
                  sticker: value.sticker,
                  imageUrl: value.image?.url,
                );
          return response.isSuccess ? null : _mutationError(response);
        },
      ),
    );
    if (!mounted || created != true) return;
    final current = _document;
    if (current != null) {
      final count = ContentMetrics.from(current).commentCount ?? 0;
      _updateDetailState(() => current['comment_count'] = count + 1);
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.zhL10n.commentPublished)));
  }

  void _openBodyLink(String url, String title) {
    openCommentLink(context, widget.api, url, title: title);
  }

  void _showReadOnlyAction(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.zhL10n.detailActionUnavailable(action)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showDetailMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _toggleAuthorFollowing(
    Map<String, dynamic> object,
    String authorId,
  ) async {
    if (_authorFollowBusy || authorId.isEmpty) return;
    if (!widget.api.canWrite) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.zhL10n.detailSignInRequired)),
        );
      return;
    }
    final relationship = AnswerRelationship.from(object);
    final wasFollowing =
        _authorFollowingOverride ?? relationship.isFollowingAuthor == true;
    if (wasFollowing) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.zhL10n.detailUnfollowTitle),
          content: Text(
            context.zhL10n.detailUnfollowMessage(authorNameOf(object)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.zhL10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.zhL10n.detailUnfollowAction),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    _updateDetailState(() => _authorFollowBusy = true);
    try {
      final response = await widget.api.setUserFollowing(
        authorId,
        following: !wasFollowing,
      );
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      final target = _document ?? object;
      final rawAuthor = target['author'];
      final author = rawAuthor is Map
          ? rawAuthor.map((key, value) => MapEntry(key.toString(), value))
          : <String, dynamic>{};
      final followerCount = ContentMetrics.from(target).authorFollowerCount;
      author['is_following'] = !wasFollowing;
      if (followerCount != null) {
        author['followers_count'] = wasFollowing
            ? math.max(0, followerCount - 1)
            : followerCount + 1;
      }
      _updateDetailState(() {
        target['author'] = author;
        _authorFollowingOverride = !wasFollowing;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(ApiFailure.from(error).userMessage)),
          );
      }
    } finally {
      if (mounted) _updateDetailState(() => _authorFollowBusy = false);
    }
  }

  Future<void> _handleDetailAction(String action) async {
    final document = _document;
    if (document == null || _busyAction.isNotEmpty) return;
    final cardAction = switch (action) {
      'vote' => ContentCardAction.vote,
      'downvote' => ContentCardAction.downvote,
      'favorite' => ContentCardAction.favorite,
      _ => null,
    };
    if (cardAction == null) {
      _showReadOnlyAction(action);
      return;
    }
    _updateDetailState(() => _busyAction = action);
    try {
      final changed = await performContentCardAction(
        context,
        widget.api,
        document,
        cardAction,
      );
      if (changed && mounted) _updateDetailState(() {});
    } finally {
      if (mounted) _updateDetailState(() => _busyAction = '');
    }
  }

  Future<void> _handleDetailMoreAction(
    _DetailMoreAction action, {
    required String questionId,
    required String questionTitle,
    required Map<String, dynamic> detailObject,
    required String authorActionId,
  }) async {
    switch (action) {
      case _DetailMoreAction.write:
        await _writeQuestionAnswer(questionId, questionTitle);
        break;
      case _DetailMoreAction.refresh:
        await _load(forceRefresh: true);
        break;
      case _DetailMoreAction.readAloud:
        await _toggleDetailTts();
        break;
      case _DetailMoreAction.exportTxt:
        await _exportCurrentText();
        break;
      case _DetailMoreAction.exportMarkdown:
        await _exportCurrentDocument(ContentExportFormat.markdown);
        break;
      case _DetailMoreAction.exportHtml:
        await _exportCurrentDocument(ContentExportFormat.html);
        break;
      case _DetailMoreAction.exportPdf:
        await _exportCurrentDocument(ContentExportFormat.pdf);
        break;
      case _DetailMoreAction.search:
        await _searchAnswerText();
        break;
      case _DetailMoreAction.copy:
        await _copyCurrentText();
        break;
      case _DetailMoreAction.followAuthor:
        await _toggleAuthorFollowing(detailObject, authorActionId);
        break;
      case _DetailMoreAction.clearCache:
        await AnswerDetailCache.instance.remove(
          contentType: widget.contentType,
          contentId: widget.contentId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.zhL10n.detailCacheCleared)),
          );
        }
        break;
    }
  }

  String _currentPlainText() {
    final object = _document ?? _initialSemantic ?? const <String, dynamic>{};
    final structured = structuredContentText(object);
    if (structured.isNotEmpty) return structured;
    final html = htmlContent(object);
    if (html != null && html.trim().isNotEmpty) {
      final blocks = richContentBlocks(html);
      final lines = <String>[];
      for (final block in blocks) {
        if (block.isImage) {
          lines.add(context.zhL10n.detailImagePlaceholder);
        } else if (block.isVideo) {
          lines.add(context.zhL10n.detailVideoPlaceholder);
        } else if (block.text.trim().isNotEmpty) {
          lines.add(block.text.trim());
        }
      }
      if (lines.isNotEmpty) return lines.join('\n\n');
      return plainText(html);
    }
    return plainText(object['excerpt'] ?? object['summary'] ?? '');
  }

  String _exportText() {
    final object = _document ?? _initialSemantic ?? const <String, dynamic>{};
    final title = titleOf(object).trim();
    final author = authorNameOf(object).trim();
    final body = _currentPlainText().trim();
    final lines = <String>[
      if (title.isNotEmpty) title,
      if (author.isNotEmpty) context.zhL10n.detailAuthorPrefix(author),
      if (title.isNotEmpty || author.isNotEmpty) '',
      if (body.isNotEmpty) body,
    ];
    return lines.join('\n');
  }

  Future<void> _exportCurrentText() async {
    final text = _exportText();
    if (text.trim().isEmpty) {
      _showDetailMessage(context.zhL10n.detailNoExportableBody);
      return;
    }
    try {
      final title = titleOf(
        _document ?? _initialSemantic ?? const <String, dynamic>{},
      );
      final file = buildSaltChapterExport(
        title: title.isEmpty ? context.zhL10n.detailAnswerDetails : title,
        sectionId: widget.contentId,
        sections: [
          SaltChapterExportSection(
            title: '',
            paragraphs: text.split(RegExp(r'\n\s*\n')),
          ),
        ],
        format: SaltChapterExportFormat.txt,
      );
      final location = await const SaltChapterFileSaver().save(file);
      unawaited(
        AppLogStore.instance.record(
          category: AppLogCategory.app,
          level: AppLogLevel.info,
          message: '回答正文导出完成',
          details: {'content_type': widget.contentType},
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.zhL10n.detailExportedTo(location))),
        );
      }
    } catch (error, stackTrace) {
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '回答正文导出失败',
          category: AppLogCategory.error,
        ),
      );
      if (mounted) _showDetailMessage(context.zhL10n.detailExportFailed);
    }
  }

  Future<void> _exportCurrentDocument(ContentExportFormat format) async {
    final object = _document ?? _initialSemantic ?? const <String, dynamic>{};
    if (_currentPlainText().trim().isEmpty) {
      _showDetailMessage(context.zhL10n.detailNoExportableBody);
      return;
    }
    try {
      final location = await ContentExportService.saveObject(
        object: object,
        format: format,
        fallbackTitle: context.zhL10n.detailAnswerDetails,
      );
      unawaited(
        AppLogStore.instance.record(
          category: AppLogCategory.app,
          level: AppLogLevel.info,
          message: '回答文档导出完成',
          details: {'format': format.name, 'content_type': widget.contentType},
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.zhL10n.detailDocumentExported(format.label, location),
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '回答文档导出失败',
          category: AppLogCategory.error,
        ),
      );
      if (mounted) _showDetailMessage(context.zhL10n.detailExportFailed);
    }
  }

  Future<void> _toggleDetailTts() async {
    final tts = TtsService.instance;
    if (tts.isPlaying) {
      await tts.stop();
      if (mounted) _showDetailMessage(context.zhL10n.detailStoppedReading);
      return;
    }
    final text = _currentPlainText();
    if (text.trim().isEmpty) {
      _showDetailMessage(context.zhL10n.detailNoReadableBody);
      return;
    }
    final started = await tts.speak(
      text,
      title: titleOf(
        _document ?? _initialSemantic ?? const <String, dynamic>{},
      ),
    );
    if (mounted) {
      _showDetailMessage(
        started
            ? context.zhL10n.detailReading
            : context.zhL10n.detailTtsUnavailable,
      );
    }
  }

  Future<void> _copyCurrentText() async {
    final text = _exportText();
    if (text.trim().isEmpty) {
      _showDetailMessage(context.zhL10n.detailNoCopyableText);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.zhL10n.detailCopied)));
    }
  }

  Future<void> _searchAnswerText() async {
    final controller = TextEditingController();
    final keyword = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.zhL10n.detailSearchBodyTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.zhL10n.detailKeywordHint,
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.zhL10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(context.zhL10n.detailLocate),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || keyword == null || keyword.trim().isEmpty) return;
    final body = _currentPlainText();
    final index = body.toLowerCase().indexOf(keyword.trim().toLowerCase());
    if (index < 0) {
      _showDetailMessage(context.zhL10n.detailBodyNotFound(keyword.trim()));
      return;
    }
    if (!_scrollController.hasClients || body.isEmpty) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final target = (maxScroll * (index / body.length)).clamp(0.0, maxScroll);
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.zhL10n.detailLocated(keyword.trim()))),
      );
    }
  }

  void _openInviteAnswer(String questionId) {
    if (!widget.api.canWrite) {
      _showWriteSessionRequired(context);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _QuestionInvitePage(api: widget.api, questionId: questionId),
      ),
    );
  }

  Future<void> _writeQuestionAnswer(String questionId, String title) async {
    if (!widget.api.canWrite) {
      _showWriteSessionRequired(context);
      return;
    }
    final published = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      requestFocus: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentComposerSheet(
        api: widget.api,
        title: context.zhL10n.detailWriteAnswer,
        maxLength: 100000,
        enableImage: false,
        enableGift: false,
        onSubmit: (value) async {
          if (value.text.trim().isEmpty) {
            return context.zhL10n.detailAnswerRequired;
          }
          final response = await widget.api.publishAnswer(
            questionId: questionId,
            questionTitle: title,
            content: value.text,
          );
          return response.isSuccess ? null : _mutationError(response);
        },
      ),
    );
    if (mounted && published == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.zhL10n.detailAnswerPublished)),
      );
    }
  }
}
