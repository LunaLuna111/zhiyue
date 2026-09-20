part of '../content_pages.dart';

class _ContentDetailPageState extends State<ContentDetailPage>
    with SingleTickerProviderStateMixin {
  static final _relatedFirstPageCache = <String, Future<ApiResponse>>{};
  static final _relatedDetailPrefetches =
      <String, Future<Map<String, dynamic>?>>{};
  final _scrollController = ScrollController();
  final _answerOverscrollNotifier = ValueNotifier<double>(0);
  late final AnimationController _answerOverscrollResetAnimation;
  final _relatedAnswers = <Map<String, dynamic>>[];
  Map<String, dynamic>? _document;
  Map<String, dynamic>? _initialSemantic;
  Map<String, dynamic>? _previousAnswerPreview;
  Object? _error;
  Object? _relatedError;
  String _source = '';
  bool _loading = false;
  bool _relatedLoading = false;
  bool _relatedStarted = false;
  bool _relatedCurrentSeen = false;
  String? _relatedNext;
  double _answerOverscrollRaw = 0;
  bool _answerSwitchBusy = false;
  bool _answerJumpInProgress = false;
  String _busyAction = '';
  bool _authorFollowBusy = false;
  bool? _authorFollowingOverride;
  String get _expectedQuestionId {
    final initial = widget.initialValue;
    return initial == null ? '' : questionIdOf(initial);
  }

  @override
  void initState() {
    super.initState();
    _answerOverscrollResetAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scrollController.addListener(_maybeLoadRelatedAnswers);
    final initial = widget.initialValue;
    if (initial != null) {
      final object = unwrapObject(initial);
      _initialSemantic = object;
      if (_readableLength(object) > 0 || _hasUsablePreview(object)) {
        _document = object;
        _source = '推荐/列表响应随附内容';
      }
    }
    _previousAnswerPreview = widget.previousAnswer;
    // Start the question feed as soon as an answer is opened. The request is
    // deliberately detached from the detail request so the bottom section is
    // already available by the time the reader reaches it. The first page is
    // shared by every answer opened for the same question.
    if (widget.contentType == 'answer' && _expectedQuestionId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadRelatedAnswers());
      });
    }
    _load();
  }

  @override
  void dispose() {
    _answerOverscrollResetAnimation.dispose();
    _answerOverscrollNotifier.dispose();
    _scrollController
      ..removeListener(_maybeLoadRelatedAnswers)
      ..dispose();
    super.dispose();
  }

  String get _path => switch (widget.contentType) {
    'answer' => '/answers/v2/${Uri.encodeComponent(widget.contentId)}',
    'article' => '/articles/v2/${Uri.encodeComponent(widget.contentId)}',
    'pin' => '/pins/v2/${Uri.encodeComponent(widget.contentId)}',
    _ => throw StateError('unsupported content type'),
  };

  bool _hasUsablePreview(Map<String, dynamic> value) {
    final hasBodyPreview =
        htmlContent(value)?.trim().isNotEmpty == true ||
        structuredContentText(value).isNotEmpty ||
        contentImageUrlsOf(value, limit: 20).isNotEmpty ||
        contentVideosOf(value).isNotEmpty;
    if (hasBodyPreview) return true;
    return widget.contentType == 'answer' &&
        (subtitleOf(value).isNotEmpty ||
            (authorNameOf(value).isNotEmpty && titleOf(value).isNotEmpty));
  }

  void _startRelatedAnswerPreload() {
    if (widget.contentType != 'answer' ||
        _relatedStarted ||
        _relatedLoading ||
        !mounted) {
      return;
    }
    final object = unwrapObject(_document ?? _initialSemantic ?? const {});
    if (questionIdOf(object).isEmpty && _expectedQuestionId.isEmpty) return;
    unawaited(_loadRelatedAnswers());
  }

  void _recordAnswerPreload(
    String message, {
    AppLogLevel level = AppLogLevel.debug,
    Map<String, Object?> details = const {},
  }) {
    unawaited(
      AppLogStore.instance.record(
        category: AppLogCategory.performance,
        level: level,
        message: message,
        details: details,
      ),
    );
  }

  Future<Map<String, dynamic>?> _awaitPrefetchedDetail() async {
    final request = widget.prefetchedDetail;
    if (request == null) return null;
    try {
      final detail = await request.timeout(const Duration(seconds: 8));
      if (detail == null) {
        _recordAnswerPreload(
          '回答详情预加载无结果，回退正常请求',
          level: AppLogLevel.warning,
          details: {'content_id': widget.contentId},
        );
      } else {
        _recordAnswerPreload(
          '回答详情复用预加载请求',
          details: {'content_id': widget.contentId},
        );
      }
      return detail;
    } on Object catch (error, stackTrace) {
      _recordAnswerPreload(
        '回答详情预加载等待超时或失败，回退正常请求',
        level: AppLogLevel.warning,
        details: {'content_id': widget.contentId},
      );
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '回答详情预加载等待失败',
          category: AppLogCategory.performance,
        ),
      );
      return null;
    }
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    var networkSucceeded = false;
    try {
      var useCachedDocument = false;
      if (!forceRefresh) {
        try {
          final cached = await AnswerDetailCache.instance.read(
            contentType: widget.contentType,
            contentId: widget.contentId,
          );
          if (mounted && cached != null) {
            final cacheIsFresh = cached.isFresh(DateTime.now());
            final cacheHasBody = _hasReadableBody(cached.document);
            if (cacheHasBody) {
              _adopt(
                cached.document,
                cacheIsFresh ? '本地缓存（30 分钟内）' : '本地缓存（已过期，正在更新）',
              );
            }
            // A previous failed/partial response must never become a fresh
            // blank detail. Keep the list preview visible, then let the
            // dedicated endpoint repair the cache on the same open.
            useCachedDocument = cacheIsFresh && cacheHasBody;
            unawaited(
              AppLogStore.instance.record(
                category: AppLogCategory.performance,
                level: cacheHasBody ? AppLogLevel.info : AppLogLevel.warning,
                message: !cacheHasBody
                    ? '回答详情缓存缺少正文，正在重新请求'
                    : useCachedDocument
                    ? '回答详情命中缓存'
                    : '回答详情缓存已过期',
                details: {
                  'content_type': widget.contentType,
                  'content_id': widget.contentId,
                  'cache_age_ms': DateTime.now()
                      .difference(cached.cachedAt)
                      .inMilliseconds,
                },
              ),
            );
          }
        } on Object catch (error, stackTrace) {
          unawaited(
            AppLogStore.instance.recordError(
              error,
              stackTrace,
              message: '回答详情读取缓存失败',
              category: AppLogCategory.performance,
            ),
          );
        }
      }
      if (!forceRefresh && !useCachedDocument) {
        final prefetched = await _awaitPrefetchedDetail();
        if (!mounted) return;
        if (prefetched != null) {
          final normalized = mergeListMetadata(prefetched, _initialSemantic);
          if (contentIdentityMatches(
            candidate: normalized,
            contentType: widget.contentType,
            contentId: widget.contentId,
            expectedQuestionId: _expectedQuestionId,
          )) {
            networkSucceeded = true;
            _adopt(normalized, '回答详情预加载');
            useCachedDocument = true;
          }
        }
      }
      if (!useCachedDocument) {
        final detailQuery = contentDetailRequestParameters(widget.initialValue);
        final response = await widget.api.get(
          _path,
          query: widget.contentType == 'pin'
              ? {...detailQuery, 'scene': ''}
              : detailQuery,
        );
        if (!mounted) return;
        if (response.isSuccess && response.jsonMap != null) {
          networkSucceeded = true;
          _adopt(response.jsonMap!, '官方 App v2 移动接口');
          // Do not wait for the detail metadata chain before warming the next
          // answer. The question feed and the current answer metadata are
          // independent requests, so starting here removes the most visible
          // source of a loading ring during vertical continuation.
          _startRelatedAnswerPreload();
          if (widget.contentType == 'answer') {
            final metadata = await widget.api.get(
              '/v4/answers/${Uri.encodeComponent(widget.contentId)}',
            );
            if (!mounted) return;
            if (metadata.isSuccess && metadata.jsonMap != null) {
              _mergeVerifiedMetadata(metadata.jsonMap!);
            }
            final current = _document;
            final needsVideoMetadata =
                current != null &&
                contentVideosOf(current).any(
                  (video) =>
                      video.videoId.isNotEmpty && video.sourceUrls.isEmpty,
                );
            if (current == null ||
                ContentMetrics.from(current).createdTime == null ||
                needsVideoMetadata) {
              final publicMetadata = await widget.api.publicWebGet(
                '/api/v4/answers/${Uri.encodeComponent(widget.contentId)}',
                query: const {
                  'include':
                      'author,question,attachment,video_info,thumbnail_extra_info',
                },
              );
              if (!mounted) return;
              if (publicMetadata.isSuccess && publicMetadata.jsonMap != null) {
                _mergeVerifiedMetadata(publicMetadata.jsonMap!);
              }
            }
          }
        } else {
          if (widget.contentType == 'answer') {
            final fallback = await widget.api.publicWebGet(
              '/api/v4/answers/${Uri.encodeComponent(widget.contentId)}',
              query: const {
                'include':
                    'content,excerpt,author,question,attachment,video_info,'
                    'thumbnail_extra_info',
              },
            );
            if (!mounted) return;
            if (fallback.isSuccess && fallback.jsonMap != null) {
              networkSucceeded = true;
              _adopt(fallback.jsonMap!, '匿名 www API v4 回退');
              _startRelatedAnswerPreload();
            } else if (_document == null) {
              setState(() => _error = response);
            }
          } else if (_document == null) {
            setState(() => _error = response);
          }
        }
      }
    } catch (error) {
      if (mounted && _document == null) setState(() => _error = error);
    } finally {
      if (mounted) {
        if (networkSucceeded && _document != null) {
          unawaited(_persistAnswerCache(_document!));
        }
        setState(() => _loading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _maybeLoadRelatedAnswers();
        });
      }
    }
  }

  Future<void> _persistAnswerCache(Map<String, dynamic> document) async {
    final saved = await AnswerDetailCache.instance.write(
      contentType: widget.contentType,
      contentId: widget.contentId,
      document: document,
    );
    unawaited(
      AppLogStore.instance.record(
        category: AppLogCategory.performance,
        level: saved ? AppLogLevel.debug : AppLogLevel.warning,
        message: saved ? '回答详情写入缓存' : '回答详情缓存未写入',
        details: {
          'content_type': widget.contentType,
          'content_id': widget.contentId,
          'readable_length': _readableLength(document),
        },
      ),
    );
  }

  void _maybeLoadRelatedAnswers() {
    if (!mounted || widget.contentType != 'answer' || _relatedLoading) return;
    if (!_relatedStarted && _document == null) return;
    // The first page is prefetched when the answer route opens. Only later
    // pages wait for the reader to approach the end of the current content.
    if (_relatedStarted && _relatedError == null && _relatedNext == null) {
      return;
    }
    if (_relatedStarted &&
        _scrollController.hasClients &&
        _scrollController.position.extentAfter > 720) {
      return;
    }
    unawaited(_loadRelatedAnswers());
  }

  Future<void> _loadRelatedAnswers() async {
    if (_relatedLoading || widget.contentType != 'answer') return;
    final object = unwrapObject(_document ?? _initialSemantic ?? const {});
    final questionId = questionIdOf(object).isNotEmpty
        ? questionIdOf(object)
        : _expectedQuestionId;
    if (questionId.isEmpty) return;
    if (_relatedStarted && _relatedNext == null && _relatedError == null) {
      return;
    }
    final firstPage =
        !_relatedStarted || (_relatedError != null && _relatedNext == null);
    setState(() {
      _relatedLoading = true;
      _relatedError = null;
      _relatedStarted = true;
    });
    try {
      final response = firstPage
          ? await _loadRelatedFirstPage(questionId)
          : await widget.api.getUri(
              widget.api.validatePagingUri(_relatedNext!),
            );
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      final currentId = widget.contentId;
      final existing = <String>{
        currentId,
        for (final answer in _relatedAnswers) idOf(answer),
      };
      final rows = extractRows(response.json);
      if (firstPage &&
          !_relatedCurrentSeen &&
          !rows.any((row) => idOf(unwrapObject(row)) == currentId)) {
        // Some anonymous feeds omit the currently opened answer. In that
        // case there is no reliable position marker, so keep the returned
        // order usable rather than waiting through every page forever.
        _relatedCurrentSeen = true;
      }
      final incoming = <Map<String, dynamic>>[];
      for (final row in rows) {
        final answer = unwrapObject(row);
        final id = idOf(answer);
        if (id.isEmpty) continue;
        if (id == currentId) {
          _relatedCurrentSeen = true;
          continue;
        }
        // Keep the server's forward order. Once the current answer is found,
        // rows before it belong to the previous-answer side of the native
        // navigator and must not become the next preview after a replacement
        // route is opened.
        if (!_relatedCurrentSeen || !existing.add(id)) continue;
        incoming.add(answer);
      }
      setState(() {
        _relatedAnswers.addAll(incoming);
        _relatedNext = pagingNext(response.json);
      });
      _prefetchNextAnswerDetail();
      if (firstPage &&
          widget.api.session.prefetchImages &&
          incoming.isNotEmpty) {
        prefetchObjectImages(
          context,
          incoming,
          limit: 8,
          concurrency: 2,
          avatarCacheSize: 108,
          cacheFeedPresentation: true,
        );
      }
      // A first page can contain only the answer currently open. Continue to
      // the next server page so the user still gets the other answers without
      // a manual retry or a dead-end loading state.
      if (incoming.isEmpty && _relatedNext != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_loadRelatedAnswers());
        });
      }
    } catch (error) {
      if (mounted) setState(() => _relatedError = error);
    } finally {
      if (mounted) setState(() => _relatedLoading = false);
    }
  }

  Map<String, dynamic>? get _nextAnswerPreview =>
      _relatedAnswers.isEmpty ? null : _relatedAnswers.first;

  void _prefetchNextAnswerDetail() {
    final answer = _nextAnswerPreview;
    if (answer == null) return;
    final answerId = idOf(answer);
    if (answerId.isEmpty) return;
    final key = 'answer:$answerId';
    final request = _relatedDetailPrefetches[key] ??= _fetchRelatedAnswerDetail(
      answerId,
      answer,
    );
    _recordAnswerPreload('开始预加载下一个回答详情', details: {'content_id': answerId});
    unawaited(() async {
      final detail = await request;
      if (detail == null) {
        if (identical(request, _relatedDetailPrefetches[key])) {
          _relatedDetailPrefetches.remove(key);
        }
        return;
      }
      if (!mounted) return;
      final index = _relatedAnswers.indexWhere(
        (candidate) => idOf(candidate) == answerId,
      );
      if (index < 0) return;
      final current = _relatedAnswers[index];
      final merged = mergeListMetadata(detail, current);
      if (_readableLength(merged) <= _readableLength(current)) return;
      setState(() => _relatedAnswers[index] = merged);
      if (widget.api.session.prefetchImages) {
        prefetchObjectImages(
          context,
          [merged],
          limit: 4,
          concurrency: 2,
          avatarCacheSize: 108,
          cacheFeedPresentation: true,
        );
      }
    }());
  }

  Future<Map<String, dynamic>?> _fetchRelatedAnswerDetail(
    String answerId,
    Map<String, dynamic> source,
  ) async {
    try {
      final cached = await AnswerDetailCache.instance.read(
        contentType: 'answer',
        contentId: answerId,
      );
      if (cached != null && cached.isFresh(DateTime.now())) {
        _recordAnswerPreload('下一个回答详情命中缓存', details: {'content_id': answerId});
        return cached.document;
      }
      final stopwatch = Stopwatch()..start();
      final response = await widget.api.get(
        '/answers/v2/${Uri.encodeComponent(answerId)}',
        query: contentDetailRequestParameters(source),
      );
      if (!response.isSuccess || response.jsonMap == null) {
        _recordAnswerPreload(
          '下一个回答详情预加载失败',
          level: AppLogLevel.warning,
          details: {
            'content_id': answerId,
            'status_code': response.statusCode,
            'duration_ms': stopwatch.elapsedMilliseconds,
          },
        );
        return null;
      }
      final normalized = mergeListMetadata(response.jsonMap!, source);
      if (!contentIdentityMatches(
        candidate: normalized,
        contentType: 'answer',
        contentId: answerId,
        expectedQuestionId: questionIdOf(source),
      )) {
        _recordAnswerPreload(
          '下一个回答详情预加载身份校验失败',
          level: AppLogLevel.warning,
          details: {'content_id': answerId},
        );
        return null;
      }
      await AnswerDetailCache.instance.write(
        contentType: 'answer',
        contentId: answerId,
        document: normalized,
      );
      _recordAnswerPreload(
        '下一个回答详情预加载完成',
        details: {
          'content_id': answerId,
          'duration_ms': stopwatch.elapsedMilliseconds,
          'readable_length': _readableLength(normalized),
        },
      );
      return normalized;
    } catch (error, stackTrace) {
      _recordAnswerPreload(
        '下一个回答详情预加载异常',
        level: AppLogLevel.warning,
        details: {'content_id': answerId},
      );
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '下一个回答详情预加载异常',
          category: AppLogCategory.performance,
        ),
      );
      return null;
    }
  }

  Future<ApiResponse> _loadRelatedFirstPage(String questionId) {
    final cached = _relatedFirstPageCache[questionId];
    if (cached != null) return cached;
    late final Future<ApiResponse> request;
    request = widget.api
        .getUri(widget.api.questionAnswersInitialUri(questionId))
        .then(
          (response) {
            if (!response.isSuccess &&
                identical(_relatedFirstPageCache[questionId], request)) {
              _relatedFirstPageCache.remove(questionId);
            }
            return response;
          },
          onError: (Object error, StackTrace stackTrace) {
            if (identical(_relatedFirstPageCache[questionId], request)) {
              _relatedFirstPageCache.remove(questionId);
            }
            Error.throwWithStackTrace(error, stackTrace);
          },
        );
    _relatedFirstPageCache[questionId] = request;
    return request;
  }

  int _readableLength(Map<String, dynamic> value) {
    final html = htmlContent(value);
    final structured = structuredContentText(value);
    final inlineVideoCount = html == null
        ? 0
        : richContentBlocks(html).where((block) => block.isVideo).length;
    // A standalone video answer can legitimately have no readable text.
    return plainText(html).length +
        structured.length +
        contentVideosOf(value).length +
        inlineVideoCount +
        contentImageUrlsOf(value, limit: 20).length * 20;
  }

  bool _hasReadableBody(Map<String, dynamic> value) {
    return htmlContent(value)?.trim().isNotEmpty == true ||
        structuredContentText(value).isNotEmpty ||
        contentImageUrlsOf(value, limit: 20).isNotEmpty ||
        contentVideosOf(value).isNotEmpty;
  }

  String _explicitContentTitle(Map<String, dynamic>? value) {
    if (value == null) return '';
    final object = unwrapObject(value);
    for (final key in const [
      'title',
      'name',
      'excerpt_title',
      'headline',
      'display_title',
    ]) {
      final raw = object[key];
      final map = stringMap(raw);
      final text = plainText(
        map?['plain_text'] ?? map?['text'] ?? map?['name'] ?? raw,
      ).trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  void _adopt(Map<String, dynamic> candidate, String source) {
    final normalized = mergeListMetadata(candidate, _initialSemantic);
    if (!contentIdentityMatches(
      candidate: normalized,
      contentType: widget.contentType,
      contentId: widget.contentId,
      expectedQuestionId: _expectedQuestionId,
    )) {
      return;
    }
    final currentLength = _document == null ? -1 : _readableLength(_document!);
    final candidateLength = _readableLength(normalized);
    // For articles and pins the dedicated detail endpoint is the authority
    // for the body. A compact feed card can contain a longer excerpt than a
    // short post's actual body, so comparing only character counts would keep
    // the feed projection forever and can hide a valid object/tree response.
    final preferVerifiedNonAnswerBody =
        widget.contentType != 'answer' &&
        source == '官方 App v2 移动接口' &&
        _hasReadableBody(normalized);
    setState(() {
      if (_document == null ||
          candidateLength >= currentLength ||
          preferVerifiedNonAnswerBody) {
        _document = normalized;
        _source = source;
      } else {
        // A list/recommendation payload may carry a longer readable body while
        // the dedicated detail response carries richer counters and dates.
        // Keep the longer body, but merge every missing semantic metadata field
        // from the identity-verified detail response.
        _document = mergeListMetadata(_document!, normalized);
      }
      _error = null;
    });
  }

  void _mergeVerifiedMetadata(Map<String, dynamic> candidate) {
    final normalized = mergeListMetadata(candidate, _initialSemantic);
    if (!contentIdentityMatches(
      candidate: normalized,
      contentType: widget.contentType,
      contentId: widget.contentId,
      expectedQuestionId: _expectedQuestionId,
    )) {
      return;
    }
    setState(() {
      if (_document == null) {
        _document = normalized;
      } else {
        final merged = mergeListMetadata(_document!, normalized);
        if (contentVideosOf(normalized).isNotEmpty) {
          // This response came from a dedicated, identity-verified answer
          // endpoint. Its current playback/entitlement fields supersede a
          // possibly stale recommendation card while the longer body stays.
          for (final key in const [
            'thumbnail_extra_info',
            'attachment',
            'video_info',
            'video',
          ]) {
            if (normalized[key] != null) merged[key] = normalized[key];
          }
        }
        _document = merged;
      }
      _error = null;
    });
  }

  void _updateDetailState(VoidCallback callback) {
    if (mounted) setState(callback);
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;
    final semantic = document ?? _initialSemantic ?? const <String, dynamic>{};
    final question = semantic['question'];
    final questionMap = question is Map
        ? question.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};
    final questionId = questionIdOf(semantic).isNotEmpty
        ? questionIdOf(semantic)
        : _expectedQuestionId;
    final questionTitle = plainText(
      questionMap['title'] ?? questionMap['name'],
    );
    final showQuestionInAppBar =
        widget.contentType == 'answer' && questionId.isNotEmpty;
    final semanticObject = unwrapObject(semantic);
    final author =
        stringMap(semanticObject['author']) ?? const <String, dynamic>{};
    final authorName = authorNameOf(semantic).trim();
    final authorDisplayName = authorName.isEmpty ? '知乎用户' : authorName;
    final authorAvatar = authorAvatarOf(semantic);
    final authorMemberId = personMemberIdOf(author);
    final authorPageId = [
      author['url_token'],
      author['urlToken'],
      authorMemberId,
    ].map(plainText).firstWhere((value) => value.isNotEmpty, orElse: () => '');
    final documentMetrics = document == null
        ? null
        : ContentMetrics.from(document);
    final documentRelationship = document == null
        ? null
        : AnswerRelationship.from(document);
    final authorFollowing =
        _authorFollowingOverride ??
        documentRelationship?.isFollowingAuthor == true;
    final detailObject = document ?? semantic;
    final answerToolbar = widget.contentType == 'answer';
    final authorActionId = authorMemberId.isNotEmpty
        ? authorMemberId
        : authorPageId;
    final desktop = MediaQuery.sizeOf(context).width >= ZhViewport.wide;
    final Widget? answerQuestionHeader = showQuestionInAppBar
        ? AnswerDetailAppBarTitle(
            title: questionTitle,
            questionId: questionId,
            metrics: ContentMetrics.from(semantic),
            onTap: () => _openQuestionAnswers(questionId, questionTitle),
          )
        : null;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: ZhTopBar(
        toolbarHeight: 56,
        leading: ZhLiquidGlassIconButton(
          key: const ValueKey('content-detail-back'),
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          semanticLabel: '返回',
          size: 46,
          iconSize: 24,
        ),
        actions: [
          ZhLiquidGlassCapsuleActionGroup(
            key: const ValueKey('content-detail-actions'),
            actions: answerToolbar
                ? [
                    ZhLiquidGlassCapsuleAction(
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      semanticLabel: '邀请回答',
                      onPressed: questionId.isEmpty
                          ? null
                          : () => _openInviteAnswer(questionId),
                    ),
                    ZhLiquidGlassCapsuleAction(
                      icon: const Icon(Icons.copy_rounded),
                      semanticLabel: '复制回答内容',
                      onPressed: () => unawaited(_copyCurrentText()),
                    ),
                    ZhLiquidGlassCapsuleAction(
                      icon: const Icon(Icons.more_horiz_rounded),
                      semanticLabel: '更多操作',
                      onPressed: _showDetailActions,
                    ),
                  ]
                : [
                    ZhLiquidGlassCapsuleAction(
                      icon: _AuthorAvatar(
                        imageUrl: authorAvatar,
                        fallback: authorDisplayName.characters.first,
                        size: 22,
                      ),
                      semanticLabel: '查看$authorDisplayName的个人主页',
                      onPressed: authorPageId.isEmpty
                          ? null
                          : () => _openAuthorPage(authorPageId),
                    ),
                    ZhLiquidGlassCapsuleAction(
                      icon: Icon(
                        authorFollowing
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                      ),
                      semanticLabel: authorFollowing ? '取消关注作者' : '关注作者',
                      onPressed:
                          authorActionId.isEmpty ||
                              documentRelationship?.isAuthor == true ||
                              _authorFollowBusy
                          ? null
                          : () => _toggleAuthorFollowing(
                              detailObject,
                              authorActionId,
                            ),
                    ),
                    ZhLiquidGlassCapsuleAction(
                      icon: const Icon(Icons.more_horiz_rounded),
                      semanticLabel: '更多操作',
                      onPressed: _showDetailActions,
                    ),
                  ],
          ),
        ],
        title: ContentDetailAppBarTitle(title: authorDisplayName),
      ),
      body: Builder(
        builder: (bodyContext) {
          // With extendBodyBehindAppBar, Scaffold exposes the app bar's
          // occupied height as the body's top MediaQuery padding. Put that
          // inset inside the scrollable content instead of around the whole
          // body, so later content can continue underneath the translucent
          // top chrome and be progressively blurred while scrolling.
          final topInset = MediaQuery.paddingOf(bodyContext).top;
          final body = desktop && document != null
              ? ZhResponsiveTwoPane(
                  primary: _body(
                    topInset: topInset,
                    answerQuestionHeader: answerQuestionHeader,
                  ),
                  secondary: _DetailDesktopRail(
                    contentType: widget.contentType,
                    metrics: documentMetrics!,
                    relationship: documentRelationship!,
                    dateLabel: contentDateLabel(documentMetrics),
                    onComments: _openComments,
                  ),
                )
              : ZhResponsiveFrame(
                  maxWidth: 920,
                  child: _body(
                    topInset: topInset,
                    answerQuestionHeader: answerQuestionHeader,
                  ),
                );
          return body;
        },
      ),
      bottomNavigationBar: document == null
          ? null
          : DetailEngagementBar(
              metrics: documentMetrics!,
              relationship: documentRelationship!,
              busyAction: _busyAction,
              onComments: _openComments,
              onAction: _handleDetailAction,
              onJumpToTop: _jumpAnswerToTop,
              onJumpToBottom: _jumpAnswerToBottom,
              authorName: authorDisplayName,
              authorAvatar: authorAvatar,
              authorFollowing: authorFollowing,
              authorFollowBusy: _authorFollowBusy,
              onAuthor: authorPageId.isEmpty
                  ? null
                  : () => _openAuthorPage(authorPageId),
              onToggleAuthorFollowing:
                  authorActionId.isEmpty ||
                      documentRelationship.isAuthor == true ||
                      _authorFollowBusy
                  ? null
                  : () => _toggleAuthorFollowing(detailObject, authorActionId),
            ),
    );
  }
}
