part of '../content_pages.dart';

enum _QuestionAnswerSort { defaultOrder, latest }

class QuestionAnswersPage extends StatefulWidget {
  const QuestionAnswersPage({
    super.key,
    required this.api,
    required this.questionId,
    this.title = '',
  });

  final ZhihuApiClient api;
  final String questionId;
  final String title;

  @override
  State<QuestionAnswersPage> createState() => _QuestionAnswersPageState();
}

class _QuestionAnswersPageState extends State<QuestionAnswersPage> {
  int _revision = 0;
  int _loadGeneration = 0;
  var _sort = _QuestionAnswerSort.defaultOrder;
  var _followBusy = false;
  bool? _followingQuestionOverride;
  Map<String, dynamic>? _embeddedQuestion;
  Map<String, dynamic>? _questionDetail;

  String get _effectiveQuestionId {
    final direct = widget.questionId.trim();
    if (RegExp(r'^\d+$').hasMatch(direct)) return direct;
    final resolved = _resolvedQuestion;
    final embeddedId = resolved == null ? '' : idOf(resolved);
    if (RegExp(r'^\d+$').hasMatch(embeddedId)) return embeddedId;
    return direct;
  }

  bool _hasUsefulQuestionValue(Object? value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  Map<String, dynamic>? get _resolvedQuestion {
    if (_embeddedQuestion == null && _questionDetail == null) return null;
    final resolved = <String, dynamic>{...?_embeddedQuestion};
    final detail = _questionDetail;
    if (detail != null) {
      for (final entry in detail.entries) {
        if (_hasUsefulQuestionValue(entry.value) ||
            !resolved.containsKey(entry.key)) {
          resolved[entry.key] = entry.value;
        }
      }
    }
    return resolved;
  }

  bool? _questionFollowing(Map<String, dynamic>? question) {
    if (question == null) return null;
    final relationship = question['relationship'] ?? question['relation'];
    final candidates = <Object?>[question, relationship];
    for (final candidate in candidates) {
      if (candidate is! Map) continue;
      for (final key in const [
        'is_following',
        'is_followed',
        'following',
        'followed',
      ]) {
        final value = candidate[key];
        if (value is bool) return value;
      }
    }
    return null;
  }

  void _setSort(_QuestionAnswerSort sort) {
    if (sort == _sort) return;
    setState(() {
      _sort = sort;
      _revision++;
    });
  }

  Future<void> _toggleQuestionFollowing() async {
    if (_followBusy) return;
    if (!widget.api.canWrite) {
      _showWriteSessionRequired(context);
      return;
    }
    final question = _resolvedQuestion;
    final questionId = _effectiveQuestionId;
    if (!RegExp(r'^\d+$').hasMatch(questionId)) {
      _showActionMessage(context, '暂时无法识别问题 ID，请刷新后重试');
      return;
    }
    final wasFollowing =
        _followingQuestionOverride ?? _questionFollowing(question) ?? false;
    setState(() => _followBusy = true);
    try {
      final response = await widget.api.setQuestionFollowing(
        questionId,
        following: !wasFollowing,
      );
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      final target = _questionDetail ?? _embeddedQuestion;
      if (target != null) {
        target['is_following'] = !wasFollowing;
        final relationship = target['relationship'];
        if (relationship is Map) relationship['is_following'] = !wasFollowing;
        final followerCount = ContentMetrics.from(target).followerCount;
        if (followerCount != null) {
          target['follower_count'] = wasFollowing
              ? math.max(0, followerCount - 1)
              : followerCount + 1;
        }
      }
      setState(() => _followingQuestionOverride = !wasFollowing);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!wasFollowing ? '已关注问题' : '已取消关注问题'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiFailure.from(error).userMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  void _openQuestionSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchPage(api: widget.api, focusOnOpen: true),
      ),
    );
  }

  void _openInviteAnswer() {
    if (!widget.api.canWrite) {
      _showWriteSessionRequired(context);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _QuestionInvitePage(
          api: widget.api,
          questionId: _effectiveQuestionId,
        ),
      ),
    );
  }

  Future<void> _showQuestionMenu(String action) async {
    switch (action) {
      case 'write':
        await _writeAnswer();
      case 'invite':
        _openInviteAnswer();
      case 'follow':
        await _toggleQuestionFollowing();
      case 'refresh':
        if (mounted) setState(() => _revision++);
    }
  }

  Map<String, dynamic>? _questionFromAnswers(Object? value) {
    Map<String, dynamic>? fallback;
    for (final row in extractRows(value)) {
      final raw = unwrapObject(row)['question'];
      if (raw is! Map) continue;
      final question = raw.map((key, value) => MapEntry(key.toString(), value));
      final id = idOf(question);
      if (id == widget.questionId) return question;
      // The answer feed sometimes returns a canonical numeric question ID
      // while the navigation payload contains a stale/aliased value. Keep
      // that candidate so follow/invite actions do not target the answer ID
      // and get the misleading “内容已被删除” response.
      if (fallback == null && RegExp(r'^\d+$').hasMatch(id)) {
        fallback = question;
      }
    }
    return fallback;
  }

  Future<void> _consumeQuestionDetail(
    Future<ApiResponse> request,
    int generation,
  ) async {
    try {
      final response = await request;
      if (!mounted || generation != _loadGeneration) return;
      final root = response.isSuccess ? response.jsonMap : null;
      if (root == null) return;
      final detail = Map<String, dynamic>.from(unwrapObject(root));
      final detailId = idOf(detail);
      if (detailId.isNotEmpty && detailId != widget.questionId) return;
      setState(() => _questionDetail = detail);
    } catch (_) {
      // The answer list remains useful on its own. A detail failure silently
      // falls back to the compact question embedded in the first answer.
    }
  }

  Future<ApiResponse> _loadInitial() async {
    final generation = ++_loadGeneration;
    final questionId = _effectiveQuestionId;
    final answersRequest = widget.api.getUri(
      widget.api.questionAnswersInitialUri(
        questionId,
        order: _sort == _QuestionAnswerSort.latest ? 'latest' : 'default',
      ),
    );
    final detailRequest = widget.api.getUri(
      widget.api.questionDetailUri(questionId),
    );
    unawaited(_consumeQuestionDetail(detailRequest, generation));
    final response = await answersRequest;
    if (mounted && generation == _loadGeneration && response.isSuccess) {
      final question = _questionFromAnswers(response.json);
      if (question != null) setState(() => _embeddedQuestion = question);
    }
    return response;
  }

  Future<void> _handleCardAction(
    Map<String, dynamic> value,
    ContentCardAction action,
  ) async {
    final changed = await performContentCardAction(
      context,
      widget.api,
      value,
      action,
    );
    if (changed && mounted) setState(() {});
  }

  Future<void> _writeAnswer() async {
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
          final resolvedQuestion = _resolvedQuestion;
          final resolvedTitle = resolvedQuestion == null
              ? ''
              : plainText(resolvedQuestion['title']);
          final response = await widget.api.publishAnswer(
            questionId: _effectiveQuestionId,
            questionTitle: resolvedTitle.isNotEmpty
                ? resolvedTitle
                : widget.title,
            content: value.text,
          );
          return response.isSuccess ? null : _mutationError(response);
        },
      ),
    );
    if (!mounted || published != true) return;
    setState(() => _revision++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('回答已发布，列表正在刷新。'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteAnswer(Map<String, dynamic> value) async {
    final answerId = idOf(value);
    if (answerId.isEmpty || !widget.api.canWrite) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除回答？'),
        content: const Text('删除后不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final response = await widget.api.deleteAnswer(answerId);
      if (!mounted) return;
      if (!response.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_mutationError(response))));
        return;
      }
      setState(() => _revision++);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('回答已删除。')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiFailure.from(error).userMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _resolvedQuestion;
    return PagedListPage(
      key: ValueKey('question-answers-${widget.questionId}-$_revision'),
      title: '全部回答',
      api: widget.api,
      actions: [
        IconButton(
          key: const Key('question-answer-search-action'),
          tooltip: '搜索回答',
          onPressed: _openQuestionSearch,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          icon: const Icon(Icons.search_rounded, size: 23),
        ),
        PopupMenuButton<String>(
          key: const Key('question-answer-more-action'),
          tooltip: '更多',
          icon: const Icon(Icons.more_vert_rounded),
          padding: EdgeInsets.zero,
          position: PopupMenuPosition.under,
          offset: const Offset(0, 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(minWidth: 176),
          onSelected: _showQuestionMenu,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'write',
              child: Text(widget.api.canWrite ? '写回答' : '登录后写回答'),
            ),
            const PopupMenuItem(value: 'invite', child: Text('邀请回答')),
            PopupMenuItem(
              value: 'follow',
              child: Text(
                (_followingQuestionOverride ?? _questionFollowing(question)) ==
                        true
                    ? '取消关注问题'
                    : '关注问题',
              ),
            ),
            const PopupMenuItem(value: 'refresh', child: Text('刷新回答')),
          ],
        ),
      ],
      loadInitial: _loadInitial,
      header: _questionAnswersHeader(
        context,
        question,
        widget.title,
        widget.api,
        sort: _sort,
        onSortChanged: _setSort,
        following:
            _followingQuestionOverride ?? _questionFollowing(question) ?? false,
        followBusy: _followBusy,
        onFollow: _toggleQuestionFollowing,
      ),
      answerListMode: true,
      rowBuilder: (context, value, onTap) => _QuestionAnswerRow(
        value: value,
        onTap: onTap,
        onAuthorTap: authorIdOf(value).isEmpty
            ? null
            : () => openContentAuthor(context, widget.api, value),
        onAction: (action) => _handleCardAction(value, action),
        onDelete: widget.api.canWrite && _objectAllowsDelete(value)
            ? () => _deleteAnswer(value)
            : null,
      ),
      onObjectTap: (context, value) =>
          openDetectedObject(context, widget.api, value),
      bottomNavigationBar: _QuestionAnswersBottomActions(
        canWrite: widget.api.canWrite,
        following:
            _followingQuestionOverride ?? _questionFollowing(question) ?? false,
        followBusy: _followBusy,
        onWrite: _writeAnswer,
        onInvite: _openInviteAnswer,
        onFollow: _toggleQuestionFollowing,
      ),
    );
  }
}

Widget? _questionAnswersHeader(
  BuildContext context,
  Map<String, dynamic>? question,
  String fallbackTitle,
  ZhihuApiClient api, {
  required _QuestionAnswerSort sort,
  required ValueChanged<_QuestionAnswerSort> onSortChanged,
  required bool following,
  required bool followBusy,
  required VoidCallback onFollow,
}) {
  final title = question == null ? '' : titleOf(question);
  final metrics = question == null
      ? const ContentMetrics()
      : ContentMetrics.from(question);
  final presentation = question == null
      ? null
      : _QuestionHeaderPresentation.from(question);
  final topics = _questionTopics(question);
  final resolvedTitle = title.isNotEmpty ? title : fallbackTitle;
  final metricLabels = <String>[];
  if (metrics.followerCount case final count?) {
    metricLabels.add('${compactCount(count)} 关注');
  }
  if (metrics.commentCount case final count?) {
    metricLabels.add('${compactCount(count)} 评论');
  }
  if (metrics.viewCount case final count?) {
    metricLabels.add('${compactCount(count)} 浏览');
  }
  if (resolvedTitle.isEmpty &&
      !metrics.hasObjectSummary &&
      presentation?.hasContent != true &&
      topics.isEmpty) {
    return null;
  }
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resolvedTitle.isNotEmpty)
          Text(
            resolvedTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.38,
              letterSpacing: 0,
            ),
          ),
        if (question != null && authorNameOf(question).isNotEmpty) ...[
          const SizedBox(height: 11),
          _QuestionHeaderAuthor(question: question, api: api),
        ],
        if (presentation?.summary case final summary?) ...[
          const SizedBox(height: 10),
          _ExpandableQuestionSummary(summary: summary),
        ],
        if (topics.isNotEmpty) ...[
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final topic in topics)
                _QuestionTopicChip(
                  topic: topic,
                  onTap: topic.id.isEmpty
                      ? null
                      : () => openDetectedObject(context, api, topic.object),
                ),
            ],
          ),
        ],
        if (presentation != null && presentation.media.isNotEmpty) ...[
          const SizedBox(height: 11),
          for (var index = 0; index < presentation.media.length; index++) ...[
            if (presentation.media[index].isVideo)
              InlineAnswerVideo(
                key: ValueKey(
                  'question-header-video-'
                  '${presentation.media[index].video!.videoId.isNotEmpty ? presentation.media[index].video!.videoId : index}',
                ),
                video: presentation.media[index].video!,
                api: api,
                showCaption: false,
              )
            else
              _QuestionHeaderImage(url: presentation.media[index].imageUrl),
            if (index != presentation.media.length - 1)
              const SizedBox(height: 9),
          ],
        ],
        if (metricLabels.isNotEmpty || question != null) ...[
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      for (var index = 0; index < metricLabels.length; index++)
                        _QuestionHeaderMetric(
                          label:
                              '${index == 0 ? '' : '· '}${metricLabels[index]}',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _QuestionFollowButton(
                following: following,
                busy: followBusy,
                onPressed: onFollow,
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        const SizedBox(
          height: 8,
          width: double.infinity,
          child: ColoredBox(color: Color(0xFFF6F7F8)),
        ),
        const SizedBox(height: 2),
        _QuestionAnswerSortBar(
          sort: sort,
          answerCount: metrics.answerCount,
          onChanged: onSortChanged,
        ),
      ],
    ),
  );
}
