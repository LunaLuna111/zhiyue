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
        ..showSnackBar(const SnackBar(content: Text('至少选择 5 个字')));
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
        title: '评论这段话',
        initialText: initialText,
        onSubmit: (value) async {
          if (value.text.trim() == initialText.trim()) return '请输入你的评论';
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
    ).showSnackBar(const SnackBar(content: Text('评论已发布。')));
  }

  void _openBodyLink(String url, String title) {
    openCommentLink(context, widget.api, url, title: title);
  }

  void _showReadOnlyAction(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$action功能暂不可用'),
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
        ..showSnackBar(const SnackBar(content: Text('登录后可使用此功能')));
      return;
    }
    final relationship = AnswerRelationship.from(object);
    final wasFollowing =
        _authorFollowingOverride ?? relationship.isFollowingAuthor == true;
    if (wasFollowing) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('取消关注？'),
          content: Text('将不再关注 ${authorNameOf(object)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('取消关注'),
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
      '赞同' => ContentCardAction.vote,
      '反对' => ContentCardAction.downvote,
      '收藏' => ContentCardAction.favorite,
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

  Future<void> _showDetailActions() async {
    final object = _document ?? _initialSemantic ?? const <String, dynamic>{};
    final question = _contentMap(unwrapObject(object)['question']);
    final questionId = questionIdOf(object).isNotEmpty
        ? questionIdOf(object)
        : _expectedQuestionId;
    final questionTitle = plainText(question?['title'] ?? question?['name']);
    final action = await showModalBottomSheet<_DetailMoreAction>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: ZhPalette.background,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .82,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                  child: Text(
                    '更多操作',
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                ),
                if (widget.contentType == 'answer' &&
                    questionId.isNotEmpty) ...[
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('写回答'),
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_DetailMoreAction.write),
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.refresh_rounded),
                  title: const Text('刷新回答'),
                  subtitle: const Text('忽略 30 分钟缓存并重新获取最新内容'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_DetailMoreAction.refresh),
                ),
                ListTile(
                  leading: const Icon(Icons.search_rounded),
                  title: const Text('搜索正文'),
                  subtitle: const Text('输入关键词快速定位到回答内容'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_DetailMoreAction.search),
                ),
                ListTile(
                  key: const ValueKey('answer-read-aloud-action'),
                  leading: Icon(
                    TtsService.instance.isPlaying
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_outlined,
                  ),
                  title: Text(TtsService.instance.isPlaying ? '停止朗读' : '朗读正文'),
                  subtitle: const Text('使用系统中文语音朗读当前回答'),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(_DetailMoreAction.readAloud),
                ),
                ListTile(
                  leading: const Icon(Icons.text_snippet_outlined),
                  title: const Text('导出为 TXT'),
                  subtitle: const Text('保存当前标题、作者和正文'),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(_DetailMoreAction.exportTxt),
                ),
                for (final format in ContentExportFormat.values)
                  ListTile(
                    key: ValueKey('answer-export-${format.name}'),
                    leading: Icon(switch (format) {
                      ContentExportFormat.markdown => Icons.code_rounded,
                      ContentExportFormat.html => Icons.language_rounded,
                      ContentExportFormat.pdf => Icons.picture_as_pdf_outlined,
                    }),
                    title: Text('导出为 ${format.label}'),
                    subtitle: Text(
                      format == ContentExportFormat.pdf
                          ? '生成适合分享和打印的文档'
                          : '保留标题、作者、段落和正文图片链接',
                    ),
                    onTap: () => Navigator.of(sheetContext).pop(
                      switch (format) {
                        ContentExportFormat.markdown =>
                          _DetailMoreAction.exportMarkdown,
                        ContentExportFormat.html =>
                          _DetailMoreAction.exportHtml,
                        ContentExportFormat.pdf => _DetailMoreAction.exportPdf,
                      },
                    ),
                  ),
                if (widget.contentType != 'answer')
                  ListTile(
                    leading: const Icon(Icons.copy_all_outlined),
                    title: const Text('复制全文'),
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_DetailMoreAction.copy),
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: const Text('清除本条缓存'),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(_DetailMoreAction.clearCache),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
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
      case _DetailMoreAction.clearCache:
        await AnswerDetailCache.instance.remove(
          contentType: widget.contentType,
          contentId: widget.contentId,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('已清除本条回答缓存')));
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
          lines.add('[图片]');
        } else if (block.isVideo) {
          lines.add('[视频]');
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
      if (author.isNotEmpty) '作者：$author',
      if (title.isNotEmpty || author.isNotEmpty) '',
      if (body.isNotEmpty) body,
    ];
    return lines.join('\n');
  }

  Future<void> _exportCurrentText() async {
    final text = _exportText();
    if (text.trim().isEmpty) {
      _showDetailMessage('当前回答没有可导出的正文');
      return;
    }
    try {
      final title = titleOf(
        _document ?? _initialSemantic ?? const <String, dynamic>{},
      );
      final file = buildSaltChapterExport(
        title: title.isEmpty ? '回答详情' : title,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已导出到 $location')));
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
      if (mounted) _showDetailMessage('导出失败，请重试');
    }
  }

  Future<void> _exportCurrentDocument(ContentExportFormat format) async {
    final object = _document ?? _initialSemantic ?? const <String, dynamic>{};
    if (_currentPlainText().trim().isEmpty) {
      _showDetailMessage('当前回答没有可导出的正文');
      return;
    }
    try {
      final location = await ContentExportService.saveObject(
        object: object,
        format: format,
        fallbackTitle: '回答详情',
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
          SnackBar(content: Text('已导出为 ${format.label}：$location')),
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
      if (mounted) _showDetailMessage('导出失败，请重试');
    }
  }

  Future<void> _toggleDetailTts() async {
    final tts = TtsService.instance;
    if (tts.isPlaying) {
      await tts.stop();
      if (mounted) _showDetailMessage('已停止朗读');
      return;
    }
    final text = _currentPlainText();
    if (text.trim().isEmpty) {
      _showDetailMessage('当前回答没有可朗读的正文');
      return;
    }
    final started = await tts.speak(
      text,
      title: titleOf(
        _document ?? _initialSemantic ?? const <String, dynamic>{},
      ),
    );
    if (mounted) {
      _showDetailMessage(started ? '正在朗读正文' : '系统语音不可用，请安装中文语音包');
    }
  }

  Future<void> _copyCurrentText() async {
    final text = _exportText();
    if (text.trim().isEmpty) {
      _showDetailMessage('当前回答没有可复制的正文');
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已复制全文')));
    }
  }

  Future<void> _searchAnswerText() async {
    final controller = TextEditingController();
    final keyword = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('搜索正文'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(hintText: '输入关键词'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('定位'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || keyword == null || keyword.trim().isEmpty) return;
    final body = _currentPlainText();
    final index = body.toLowerCase().indexOf(keyword.trim().toLowerCase());
    if (index < 0) {
      _showDetailMessage('正文中没有找到“${keyword.trim()}”');
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已定位到“${keyword.trim()}”')));
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
        title: '写回答',
        maxLength: 100000,
        enableImage: false,
        enableGift: false,
        onSubmit: (value) async {
          if (value.text.trim().isEmpty) return '回答内容不能为空';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('回答已发布')));
    }
  }
}
