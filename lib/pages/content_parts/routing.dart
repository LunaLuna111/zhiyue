part of '../content_pages.dart';

String? _commentPersonTokenFromUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  final segments = uri.scheme == 'zhihu' && host == 'people'
      ? <String>['people', ...uri.pathSegments]
      : uri.pathSegments;
  final isZhihuHost =
      host == 'www.zhihu.com' || host == 'zhihu.com' || host == 'api.zhihu.com';
  final index = segments.indexOf('people');
  if ((!isZhihuHost && uri.scheme != 'zhihu') ||
      index < 0 ||
      index + 1 >= segments.length) {
    return null;
  }
  final token = Uri.decodeComponent(segments[index + 1]).trim();
  return RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]*$').hasMatch(token) ? token : null;
}

String? _commentColumnTokenFromUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  if (uri.host.toLowerCase() != 'zhuanlan.zhihu.com') return null;
  final index = uri.pathSegments.indexOf('column');
  if (index < 0 || index + 1 >= uri.pathSegments.length) return null;
  final token = Uri.decodeComponent(uri.pathSegments[index + 1]).trim();
  return RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]*$').hasMatch(token) ? token : null;
}

String? _commentRedirectTarget(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.toLowerCase() != 'link.zhihu.com') return null;
  final target = uri.queryParameters['target'] ?? uri.queryParameters['url'];
  final normalized = normalizeCommentLink(target);
  return normalized.isEmpty || normalized == value ? null : normalized;
}

@visibleForTesting
bool isZhihuOfficialLink(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || !const {'http', 'https'}.contains(uri.scheme)) {
    return false;
  }
  final host = uri.host.toLowerCase();
  return host == 'zhihu.com' || host.endsWith('.zhihu.com');
}

/// Opens the same native destinations used by a comment link span.  Zhihu
/// answer/article/question/pin URLs stay in the API-backed pages; Salt Story
/// links use the native catalogue/reader instead of falling through to a web
/// view that can expose the raw anti-bot JSON response.
void openCommentLink(
  BuildContext context,
  ZhihuApiClient api,
  String rawUrl, {
  String title = '',
}) {
  final url = normalizeCommentLink(rawUrl);
  if (url.isEmpty || !isCommentNavigableLink(url)) return;
  final redirectTarget = _commentRedirectTarget(url);
  if (redirectTarget != null) {
    openCommentLink(context, api, redirectTarget, title: title);
    return;
  }
  final story = parseSaltStoryNavigation({'url': url});
  if (story != null) {
    final page = story.sectionId == null
        ? SaltProductPage(
            api: api,
            businessId: story.businessId,
            businessType: 'long_story',
            title: title.trim().isEmpty
                ? context.zhL10n.saltStory
                : title.trim(),
          )
        : SaltReaderPage(
            api: api,
            businessId: story.businessId,
            sectionId: story.sectionId!,
          );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    return;
  }
  final personToken = _commentPersonTokenFromUrl(url);
  if (personToken != null) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileDetailPage(api: api, memberId: personToken),
      ),
    );
    return;
  }
  final columnToken = _commentColumnTokenFromUrl(url);
  if (columnToken != null) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ColumnArticlesPage(
          api: api,
          columnToken: columnToken,
          title: title.trim().isEmpty
              ? context.zhL10n.columnTitle
              : title.trim(),
        ),
      ),
    );
    return;
  }
  final identity = contentIdentityFromUrl(url);
  if (identity.$1.isNotEmpty && identity.$2.isNotEmpty) {
    openDetectedObject(context, api, <String, dynamic>{
      'type': identity.$1,
      'id': identity.$2,
      'title': title,
      'url': url,
    });
    return;
  }
  if (url.startsWith('https://') || url.startsWith('http://')) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isZhihuOfficialLink(url)
            ? OfficialWebPage(
                title: title.trim().isEmpty
                    ? context.zhL10n.brandZhihu
                    : title.trim(),
                url: url,
              )
            : _ExternalLinkSafetyPage(url: url, title: title),
      ),
    );
  }
}

class _ExternalLinkSafetyPage extends StatelessWidget {
  const _ExternalLinkSafetyPage({required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? '';
    return Scaffold(
      key: const Key('external-link-safety-page'),
      backgroundColor: ZhPalette.canvas,
      appBar: ZhTopBar(
        title: Text(context.zhL10n.routingSafetyTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.shield_outlined, size: 52, color: ZhPalette.accent),
              const SizedBox(height: 22),
              Text(
                context.zhL10n.routingLeaveZhihu,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ZhPalette.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.zhL10n.routingExternalWarning,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ZhPalette.quoteText,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ZhPalette.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ZhPalette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      host,
                      key: const Key('external-link-host'),
                      style: TextStyle(
                        color: ZhPalette.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      url,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ZhPalette.subtleInk,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                key: const Key('external-link-confirm'),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => OfficialWebPage(
                      title: title.trim().isEmpty ? host : title.trim(),
                      url: url,
                      allowExternalNavigation: true,
                    ),
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(context.zhL10n.routingConfirmVisit),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.zhL10n.commonCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openContentAuthor(
  BuildContext context,
  ZhihuApiClient api,
  Map<String, dynamic> source,
) {
  final memberId = authorIdOf(source);
  if (memberId.isEmpty) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => UserProfileDetailPage(api: api, memberId: memberId),
    ),
  );
}

bool isDetectedTopic(Map<String, dynamic> source) {
  return typeOf(source).replaceAll('search_', '').contains('topic') &&
      idOf(source).isNotEmpty;
}

String questionIdOf(Map<String, dynamic> source) {
  final object = unwrapObject(source);
  final question = object['question'];
  if (question is! Map) return '';
  final normalized = question.map(
    (key, value) => MapEntry(key.toString(), value),
  );
  return idOf(normalized);
}

bool contentIdentityMatches({
  required Map<String, dynamic> candidate,
  required String contentType,
  required String contentId,
  String expectedQuestionId = '',
}) {
  final normalized = unwrapObject(candidate);
  if (idOf(normalized) != contentId) return false;
  String canonicalType(String value) {
    final type = value.replaceAll('search_', '').toLowerCase();
    // A video answer is still an Answer (the original client renders it with
    // VideoAnswerFragment and uses the answer ID). Only standalone video
    // entities use the /zvideos/{id} identity and detail route.
    if (type == 'videoanswer' || type == 'video_answer') return 'answer';
    if (type == 'video') return 'zvideo';
    return type;
  }

  final candidateType = canonicalType(typeOf(normalized));
  if (candidateType.isNotEmpty && candidateType != canonicalType(contentType)) {
    return false;
  }
  if (contentType == 'answer' && expectedQuestionId.isNotEmpty) {
    return questionIdOf(normalized) == expectedQuestionId;
  }
  return true;
}

void openDetectedObject(
  BuildContext context,
  ZhihuApiClient api,
  Map<String, dynamic> source, {
  Rect? sourceRect,
}) {
  final object = unwrapObject(source);
  final type = typeOf(source).replaceAll('search_', '').toLowerCase();
  var id = idOf(source);
  final questionUrlId = saltQuestionIdFromUrl(
    object['url'] ?? object['link_url'] ?? object['target_url'],
  );
  if ((type == 'zvideo' || type == 'video') && id.isEmpty) {
    final video = object['video'];
    final videoMap = video is Map
        ? video.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};
    id = plainText(
      object['zvideo_id'] ??
          object['content_id'] ??
          videoMap['zvideo_id'] ??
          videoMap['parent_video_id'],
    );
    if (id.isEmpty) {
      final identity = contentIdentityFromUrl(
        plainText(object['url'] ?? object['link_url']),
      );
      if (identity.$1 == 'zvideo') id = identity.$2;
    }
  }
  final attachedVideos = contentVideosOf(source);
  Widget? page;
  if (isDetectedTopic(source)) {
    page = TopicFeedsPage(api: api, topicId: id, title: titleOf(source));
  } else if ((type.contains('question') || questionUrlId != null) &&
      (id.isNotEmpty || questionUrlId != null)) {
    page = QuestionAnswersPage(
      api: api,
      questionId: id.isNotEmpty ? id : questionUrlId!,
      title: titleOf(source),
    );
  } else if ((type.contains('answer') || object['answer_type'] != null) &&
      id.isNotEmpty) {
    page = ContentDetailPage(
      api: api,
      contentType: 'answer',
      contentId: id,
      initialValue: source,
    );
  } else if ((type.contains('article') || object['article_type'] != null) &&
      id.isNotEmpty) {
    page = ContentDetailPage(
      api: api,
      contentType: 'article',
      contentId: id,
      initialValue: source,
    );
  } else if ((type == 'zvideo' || type == 'video') &&
      (id.isNotEmpty || attachedVideos.isNotEmpty)) {
    page = ZVideoDetailPage(api: api, videoId: id, initialValue: source);
  } else if (type.contains('pin') && id.isNotEmpty) {
    page = ContentDetailPage(
      api: api,
      contentType: 'pin',
      contentId: id,
      initialValue: source,
    );
  } else if ((type.contains('people') ||
          type.contains('member') ||
          object['url_token'] != null) &&
      id.isNotEmpty) {
    page = UserProfileDetailPage(api: api, memberId: id);
  } else if (type.contains('column')) {
    final token = (object['url_token'] ?? object['id'])?.toString() ?? '';
    if (token.isNotEmpty) {
      page = ColumnArticlesPage(
        api: api,
        columnToken: token,
        title: titleOf(source),
      );
    }
  } else if (type.contains('comment') && id.isNotEmpty) {
    page = CommentRepliesPage(api: api, commentId: id);
  }
  page ??= ObjectInspectorPage(value: source);
  if (page is ObjectInspectorPage) {
    debugPrint(
      '[zhihu-ui] semantic-fallback type=${typeOf(source)} '
      'shape=${jsonShapeSummary(source)}',
    );
  } else {
    unawaited(RecommendationBehaviorStore.instance.recordOpened(source));
    final question = object['question'];
    final questionMap = question is Map
        ? question.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};
    final historyId = type.contains('column')
        ? ((object['url_token'] ?? object['id'])?.toString() ?? id)
        : id;
    unawaited(
      api.session.rememberBrowsing(
        type: type,
        id: historyId,
        title: titleOf(source),
        excerpt: subtitleOf(source),
        author: authorNameOf(source),
        questionId: idOf(questionMap),
        questionTitle: titleOf(questionMap),
      ),
    );
  }
  final canMorphIntoContent =
      sourceRect != null &&
      (page is ContentDetailPage || page is QuestionAnswersPage) &&
      ZhGlassScope.enabledOf(context) &&
      !MediaQuery.disableAnimationsOf(context);
  if (canMorphIntoContent) {
    // GlassModalSheet's native morph is designed for a sheet detent. A post
    // detail or a hot-list question is a full-screen page, so keep the
    // source-aware geometry here to avoid the sheet's bottom-up handoff and
    // preserve a clean reverse frame.
    unawaited(
      Navigator.of(
        context,
      ).push<void>(_SourceMorphPageRoute(page: page, sourceRect: sourceRect)),
    );
  } else {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page!));
  }
}

/// Source-aware fallback for renderers without the shader blend used by the
/// package's metaball morph. It keeps the same interaction contract: the
/// detail page grows from the tapped point and reverses into that point when
/// dismissed, instead of silently falling back to a bottom sheet.
class _SourceMorphPageRoute<T> extends PageRouteBuilder<T> {
  _SourceMorphPageRoute({required Widget page, required this.sourceRect})
    : super(
        opaque: false,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 430),
        reverseTransitionDuration: const Duration(milliseconds: 330),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _SourceMorphTransition(
              animation: animation,
              sourceRect: sourceRect,
              child: child,
            ),
      );

  final Rect sourceRect;
}

class _SourceMorphTransition extends StatelessWidget {
  const _SourceMorphTransition({
    required this.animation,
    required this.sourceRect,
    required this.child,
  });

  final Animation<double> animation;
  final Rect sourceRect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final center = Offset(
      sourceRect.center.dx.clamp(0.0, size.width),
      sourceRect.center.dy.clamp(0.0, size.height),
    );
    final maxRadius = math.max(
      math.max(center.distance, (Offset(size.width, 0) - center).distance),
      math.max(
        (Offset(0, size.height) - center).distance,
        (Offset(size.width, size.height) - center).distance,
      ),
    );
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final t = curved.value.clamp(0.0, 1.0);
        final radius = 26.0 + (maxRadius - 26.0) * t;
        final morphRect = Rect.fromCircle(center: center, radius: radius);
        final contentOpacity = ((t - 0.22) / 0.68).clamp(0.0, 1.0);
        final glassOpacity = ((1.0 - t) / 0.78).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.18 * t),
              ),
            ),
            ClipPath(
              clipper: _RadialMorphClipper(center: center, radius: radius),
              clipBehavior: Clip.antiAlias,
              child: Opacity(opacity: contentOpacity, child: child),
            ),
            if (glassOpacity > 0.0)
              Positioned.fromRect(
                rect: morphRect,
                child: Opacity(
                  opacity: glassOpacity,
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: 18 * (1 - t),
                        sigmaY: 18 * (1 - t),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: ZhPalette.background.withValues(alpha: .64),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .86),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RadialMorphClipper extends CustomClipper<Path> {
  const _RadialMorphClipper({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant _RadialMorphClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}

({String type, String id}) interactiveContentIdentityOf(
  Map<String, dynamic> source,
) {
  String normalizeType(Object? value) {
    final marker = plainText(
      value,
    ).replaceAll('search_', '').replaceAll('-', '_').toLowerCase();
    if (marker.contains('answer')) return 'answer';
    if (marker.contains('article')) return 'article';
    if (marker.contains('pin') ||
        marker.contains('moment') ||
        marker == 'idea') {
      return 'pin';
    }
    return '';
  }

  String identifierOf(Map<String, dynamic> node) {
    for (final key in const [
      'content_id',
      'target_id',
      'object_id',
      'resource_id',
      'id',
    ]) {
      final id = plainText(node[key]);
      if (RegExp(r'^\d+$').hasMatch(id)) return id;
    }
    return '';
  }

  final nodes = <Map<String, dynamic>>[];
  final visited = <int>{};
  void collect(Object? value, int depth) {
    if (depth > 6 || value is! Map) return;
    final identity = identityHashCode(value);
    if (!visited.add(identity)) return;
    final node = Map<String, dynamic>.from(value);
    nodes.add(node);
    for (final nested in node.values) {
      if (nested is Map) {
        collect(nested, depth + 1);
      } else if (nested is List) {
        for (final item in nested.take(24)) {
          if (item is Map) collect(item, depth + 1);
        }
      }
    }
  }

  collect(source, 0);
  final normalized = unwrapObject(source);
  nodes.insert(0, normalized);
  for (final node in nodes) {
    var type = '';
    for (final key in const [
      'content_type',
      'target_type',
      'object_type',
      'resource_type',
      'type',
    ]) {
      type = normalizeType(node[key]);
      if (type.isNotEmpty) break;
    }
    if (type.isEmpty) {
      if (node['answer_type'] != null) type = 'answer';
      if (node['article_type'] != null) type = 'article';
    }
    final id = identifierOf(node);
    if (type.isNotEmpty && id.isNotEmpty) return (type: type, id: id);
  }
  return (type: '', id: '');
}

void _writeVotingState(Map<String, dynamic> object, String voting) {
  object['voting'] = voting;
  final relationship = object['relationship'];
  if (relationship is Map) relationship['voting'] = voting;
  final reaction = object['reaction'];
  if (reaction is Map) {
    final relation = reaction['relation'] ?? reaction['relationship'];
    if (relation is Map) relation['vote'] = voting.toUpperCase();
  }
}

void _syncInteractionState(
  Map<String, dynamic> source,
  Map<String, dynamic> state,
) {
  void apply(Map target) {
    for (final key in const [
      'voting',
      'is_like',
      'is_favorited',
      'voteup_count',
      'favorite_count',
      'comment_count',
    ]) {
      if (state.containsKey(key)) target[key] = state[key];
    }
    final stateRelationship = state['relationship'];
    final targetRelationship = target['relationship'];
    if (stateRelationship is Map && targetRelationship is Map) {
      for (final key in const ['voting', 'is_favorited']) {
        if (stateRelationship.containsKey(key)) {
          targetRelationship[key] = stateRelationship[key];
        }
      }
    }
  }

  void visit(Map target, int depth) {
    apply(target);
    if (depth >= 4) return;
    for (final key in const ['target', 'object', 'data', 'content']) {
      final nested = target[key];
      if (nested is Map) visit(nested, depth + 1);
    }
  }

  visit(source, 0);
}

/// Handles the interaction affordances shared by feeds and detail pages. The
/// write targets mirror the 11.4.0 Retrofit declarations for answers, articles
/// and pins. The supplied object is updated only after a successful response.
Future<bool> performContentCardAction(
  BuildContext context,
  ZhihuApiClient api,
  Map<String, dynamic> source,
  ContentCardAction action,
) async {
  final l10n = context.zhL10n;
  final object = unwrapObject(source);
  final identity = interactiveContentIdentityOf(source);
  final type = identity.type;
  final id = identity.id;
  if (id.isEmpty) {
    _showActionMessage(context, l10n.routingCannotOpen);
    return false;
  }
  if (action == ContentCardAction.comments) {
    if (type.isEmpty) {
      _showActionMessage(context, l10n.routingCannotViewComments);
      return false;
    }
    var commentDelta = 0;
    await showOfficialCommentsSheet(
      context,
      api: api,
      contentType: type,
      contentId: id,
      contentAuthorIds: personIdentityKeys(object['author']),
      questionAuthorIds: personIdentityKeys(
        _contentMap(object['question'])?['author'],
      ),
      fallbackCount: ContentMetrics.from(source).commentCount,
      onCommentCountChanged: (delta) => commentDelta += delta,
    );
    if (commentDelta == 0) return false;
    final metrics = ContentMetrics.from(source);
    object['comment_count'] = math.max(
      0,
      (metrics.commentCount ?? 0) + commentDelta,
    );
    _syncInteractionState(source, object);
    return true;
  }
  if (type.isEmpty) {
    _showActionMessage(context, l10n.routingUnsupportedAction);
    return false;
  }
  if (!api.canWrite) {
    _showWriteSessionRequired(context);
    return false;
  }
  final relationship = AnswerRelationship.from(source);
  final metrics = ContentMetrics.from(source);
  try {
    final ApiResponse response;
    String successMessage;
    if (action == ContentCardAction.vote ||
        action == ContentCardAction.downvote) {
      final downvote = action == ContentCardAction.downvote;
      final wasUp = relationship.isUpvoted;
      final wasDown = relationship.isDownvoted;
      if (type == 'pin') {
        if (downvote) {
          _showActionMessage(context, l10n.routingPinDownvoteUnavailable);
          return false;
        }
        response = await api.setPinLiked(id, liked: !wasUp);
      } else {
        response = await api.voteContent(
          contentType: type,
          contentId: id,
          voting: downvote ? (wasDown ? 0 : -1) : (wasUp ? 0 : 1),
          voteupCount: metrics.voteupCount ?? 0,
        );
      }
      successMessage = downvote
          ? (wasDown ? l10n.routingDownvoteCancelled : l10n.routingDownvoted)
          : (wasUp ? l10n.routingVoteCancelled : l10n.routingVoted);
      if (response.isSuccess) {
        final voting = downvote ? (wasDown ? '' : 'down') : (wasUp ? '' : 'up');
        _writeVotingState(object, voting);
        object['is_like'] = voting == 'up';
        final voteDelta = downvote ? (wasUp ? -1 : 0) : (wasUp ? -1 : 1);
        object['voteup_count'] = math.max(
          0,
          (metrics.voteupCount ?? 0) + voteDelta,
        );
      }
    } else {
      final wasFavorited = relationship.isFavorited == true;
      response = wasFavorited
          ? await api.unfavoriteContent(contentType: type, contentId: id)
          : await api.favoriteContent(contentType: type, contentId: id);
      successMessage = wasFavorited
          ? l10n.routingFavoriteRemoved
          : l10n.routingFavorited;
      if (response.isSuccess) {
        object['is_favorited'] = !wasFavorited;
        final relationshipObject = object['relationship'];
        if (relationshipObject is Map) {
          relationshipObject['is_favorited'] = !wasFavorited;
        }
        object['favorite_count'] = math.max(
          0,
          (metrics.favoriteCount ?? 0) + (wasFavorited ? -1 : 1),
        );
      }
    }
    if (!context.mounted) return false;
    if (!response.isSuccess) {
      _showActionMessage(context, response.failure.userMessage);
      return false;
    }
    _syncInteractionState(source, object);
    _showActionMessage(context, successMessage);
    return true;
  } catch (error) {
    if (context.mounted) {
      _showActionMessage(context, ApiFailure.from(error).userMessage);
    }
    return false;
  }
}

void _showActionMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}
