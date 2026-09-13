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
      if (_readableLength(object) > 0) {
        _document = object;
        _source = '推荐/列表响应随附内容';
      }
    }
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
            _adopt(
              cached.document,
              cached.isFresh(DateTime.now())
                  ? '本地缓存（30 分钟内）'
                  : '本地缓存（已过期，正在更新）',
            );
            useCachedDocument = cached.isFresh(DateTime.now());
            unawaited(
              AppLogStore.instance.record(
                category: AppLogCategory.performance,
                level: AppLogLevel.info,
                message: useCachedDocument ? '回答详情命中缓存' : '回答详情缓存已过期',
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
        return cached.document;
      }
      final response = await widget.api.get(
        '/answers/v2/${Uri.encodeComponent(answerId)}',
        query: contentDetailRequestParameters(source),
      );
      if (!response.isSuccess || response.jsonMap == null) return null;
      final normalized = mergeListMetadata(response.jsonMap!, source);
      if (!contentIdentityMatches(
        candidate: normalized,
        contentType: 'answer',
        contentId: answerId,
        expectedQuestionId: questionIdOf(source),
      )) {
        return null;
      }
      await AnswerDetailCache.instance.write(
        contentType: 'answer',
        contentId: answerId,
        document: normalized,
      );
      return normalized;
    } catch (_) {
      return null;
    }
  }

  bool _handleAnswerScrollNotification(ScrollNotification notification) {
    if (widget.contentType != 'answer') return false;
    if (notification is ScrollStartNotification) {
      _answerOverscrollRaw = 0;
      _answerOverscrollResetAnimation.stop();
      _setAnswerOverscroll(0);
      return false;
    }
    if (notification is OverscrollNotification &&
        !_answerSwitchBusy &&
        _nextAnswerPreview != null &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 1 &&
        notification.overscroll > 0) {
      _answerOverscrollRaw = (_answerOverscrollRaw + notification.overscroll)
          .clamp(0, 10000)
          .toDouble();
      _setAnswerOverscroll(-dampedAnswerOverscroll(_answerOverscrollRaw));
      return false;
    }
    if (notification is ScrollEndNotification && !_answerSwitchBusy) {
      final next = _nextAnswerPreview;
      if (next != null && _answerOverscrollRaw >= answerSwitchTriggerDistance) {
        unawaited(_switchToNextAnswer(next));
      } else if (_answerOverscrollRaw != 0) {
        _answerOverscrollRaw = 0;
        _animateAnswerOverscrollBack();
      }
    }
    return false;
  }

  void _setAnswerOverscroll(double value) {
    if (!mounted) return;
    final clamped = value.clamp(-answerSwitchMaxDistance, 0).toDouble();
    if ((_answerOverscrollNotifier.value - clamped).abs() < .5) return;
    _answerOverscrollNotifier.value = clamped;
  }

  void _animateAnswerOverscrollBack() {
    final begin = _answerOverscrollNotifier.value;
    if (begin == 0) return;
    _answerOverscrollResetAnimation
      ..stop()
      ..reset();
    void listener() {
      _answerOverscrollNotifier.value =
          begin * (1 - _answerOverscrollResetAnimation.value);
    }

    _answerOverscrollResetAnimation.addListener(listener);
    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _answerOverscrollResetAnimation.removeListener(listener);
        _answerOverscrollResetAnimation.removeStatusListener(statusListener);
        if (mounted) _answerOverscrollNotifier.value = 0;
      }
    }

    _answerOverscrollResetAnimation.addStatusListener(statusListener);
    unawaited(_answerOverscrollResetAnimation.forward());
  }

  Future<void> _switchToNextAnswer(Map<String, dynamic> answer) async {
    if (_answerSwitchBusy) return;
    final answerId = idOf(answer);
    if (answerId.isEmpty) return;
    _answerSwitchBusy = true;
    _answerOverscrollRaw = answerSwitchTriggerDistance;
    _setAnswerOverscroll(-answerSwitchMaxDistance);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    final source = Map<String, dynamic>.from(answer)
      ..putIfAbsent('type', () => 'answer');
    await Navigator.of(context).pushReplacement(
      _nextAnswerRoute(
        api: widget.api,
        answerId: answerId,
        initialValue: source,
      ),
    );
  }

  PageRoute<void> _nextAnswerRoute({
    required ZhihuApiClient api,
    required String answerId,
    required Map<String, dynamic> initialValue,
  }) => PageRouteBuilder<void>(
    settings: RouteSettings(name: '/answer/$answerId'),
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, _, _) => ContentDetailPage(
      api: api,
      contentType: 'answer',
      contentId: answerId,
      initialValue: initialValue,
    ),
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .12),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );

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
        inlineVideoCount;
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
    setState(() {
      if (_document == null || candidateLength >= currentLength) {
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
    final pageTitle = switch (widget.contentType) {
      'answer' => '回答详情',
      'article' => '文章详情',
      'pin' => '想法详情',
      _ => '内容详情',
    };
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
    final documentMetrics = document == null
        ? null
        : ContentMetrics.from(document);
    final documentRelationship = document == null
        ? null
        : AnswerRelationship.from(document);
    final contentTitle = titleOf(semantic);
    final contentAuthor = authorNameOf(semantic);
    final contentDate = document == null
        ? ''
        : contentDateLabel(ContentMetrics.from(document));
    final desktop = MediaQuery.sizeOf(context).width >= ZhViewport.wide;
    final body = desktop && document != null
        ? ZhResponsiveTwoPane(
            primary: _body(),
            secondary: _DetailDesktopRail(
              contentType: widget.contentType,
              metrics: documentMetrics!,
              relationship: documentRelationship!,
              dateLabel: contentDateLabel(documentMetrics),
              onComments: _openComments,
            ),
          )
        : ZhResponsiveFrame(maxWidth: 920, child: _body());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: showQuestionInAppBar
            ? 50
            : contentTitle.isNotEmpty
            ? 64
            : null,
        titleSpacing: showQuestionInAppBar ? 0 : null,
        actions: showQuestionInAppBar
            ? [
                TextButton.icon(
                  onPressed: () => _openInviteAnswer(questionId),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: const Text('邀请回答'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0F7BFF),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _writeQuestionAnswer(questionId, questionTitle),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('写回答'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0F7BFF),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                ),
                IconButton(
                  tooltip: '搜索',
                  onPressed: _openSearch,
                  icon: const Icon(Icons.search_rounded),
                ),
              ]
            : null,
        bottom: showQuestionInAppBar
            ? PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Column(
                  children: [
                    AnswerDetailAppBarTitle(
                      title: questionTitle,
                      questionId: questionId,
                      metrics: ContentMetrics.from(semantic),
                      onTap: () =>
                          _openQuestionAnswers(questionId, questionTitle),
                    ),
                    const Divider(height: 1, thickness: .7),
                  ],
                ),
              )
            : const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, thickness: .7),
              ),
        title: showQuestionInAppBar
            ? const SizedBox.shrink()
            : contentTitle.isNotEmpty
            ? ContentDetailAppBarTitle(
                title: contentTitle,
                contentType: widget.contentType,
                author: contentAuthor,
                date: contentDate,
              )
            : Text(pageTitle),
      ),
      body: body,
      bottomNavigationBar: document == null
          ? null
          : DetailEngagementBar(
              metrics: documentMetrics!,
              relationship: documentRelationship!,
              busyAction: _busyAction,
              onComments: _openComments,
              onAction: _handleDetailAction,
              onMore: _showDetailActions,
            ),
    );
  }
}
