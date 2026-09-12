part of '../content_pages.dart';

/// Native counterpart of the original client's VideoEntity detail screen.
///
/// The audited 11.4.0 implementation obtains a `VideoEntity` from
/// `/zvideos/{id}`, places its `video` node in a dedicated player container,
/// and keeps the title/author/interaction document below it. Keeping this as a
/// separate page avoids treating a video cover as an ordinary image gallery.
class ZVideoDetailPage extends StatefulWidget {
  const ZVideoDetailPage({
    super.key,
    required this.api,
    required this.videoId,
    this.initialValue,
  });

  final ZhihuApiClient api;
  final String videoId;
  final Map<String, dynamic>? initialValue;

  @override
  State<ZVideoDetailPage> createState() => _ZVideoDetailPageState();
}

class _ZVideoDetailPageState extends State<ZVideoDetailPage> {
  Map<String, dynamic>? _document;
  Object? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    if (initial != null) {
      _document = Map<String, dynamic>.from(unwrapObject(initial));
    }
    // A search result can include a complete playlist but omit the outer
    // VideoEntity ID. It is still directly playable; only skip the optional
    // /zvideos/{id} metadata refresh in that case.
    if (widget.videoId.isNotEmpty) _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await widget.api.get(
        '/zvideos/${Uri.encodeComponent(widget.videoId)}',
        query: const {
          'include': 'contribute,interactive_plugin,creation_relationship',
        },
      );
      if (!mounted) return;
      final candidate = response.isSuccess ? response.jsonMap : null;
      if (candidate != null &&
          contentIdentityMatches(
            candidate: candidate,
            contentType: 'zvideo',
            contentId: widget.videoId,
          )) {
        setState(() {
          _document = mergeListMetadata(candidate, _document);
          _error = null;
        });
      } else if (_document == null) {
        setState(() => _error = response);
      }
    } catch (error) {
      if (mounted && _document == null) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  RichContentVideo? _videoOf(Map<String, dynamic>? value) {
    if (value == null) return null;
    final videos = contentVideosOf(value);
    if (videos.isEmpty) return null;
    return videos.reduce((best, candidate) {
      int score(RichContentVideo video) =>
          video.sourceUrls.length * 10 +
          (video.videoId.isNotEmpty ? 4 : 0) +
          (video.posterUrl.isNotEmpty ? 2 : 0) +
          (video.width != null && video.height != null ? 1 : 0);
      return score(candidate) > score(best) ? candidate : best;
    });
  }

  Future<void> _openComments() async {
    if (widget.videoId.isEmpty) {
      _showUnavailable('评论');
      return;
    }
    final document = _document;
    final object = document == null
        ? const <String, dynamic>{}
        : unwrapObject(document);
    await showOfficialCommentsSheet(
      context,
      api: widget.api,
      contentType: 'zvideo',
      contentId: widget.videoId,
      contentAuthorIds: personIdentityKeys(object['author']),
      fallbackCount: document == null
          ? null
          : ContentMetrics.from(document).commentCount,
      onCommentCountChanged: (delta) {
        final document = _document;
        if (!mounted || document == null) return;
        final count = ContentMetrics.from(document).commentCount ?? 0;
        setState(() => document['comment_count'] = math.max(0, count + delta));
      },
    );
  }

  void _showUnavailable(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$action功能暂不可用'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;
    final video = _videoOf(document);
    final metrics = document == null
        ? const ContentMetrics()
        : ContentMetrics.from(document);
    final relationship = document == null
        ? const AnswerRelationship(
            voting: '',
            isThanked: null,
            isFavorited: null,
            isAuthor: null,
            isFollowingAuthor: null,
          )
        : AnswerRelationship.from(document);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.black,
        title: const Text(
          '视频',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          if (_loading && document != null)
            const LinearProgressIndicator(minHeight: 2),
          if (video != null)
            ZhResponsiveFrame(
              maxWidth: 920,
              child: InlineAnswerVideo(
                key: ValueKey('zvideo-player-${video.videoId}'),
                video: video,
                api: widget.api,
                autoplay: true,
                immersive: true,
                showCaption: false,
              ),
            )
          else if (document != null)
            const _ZVideoMissingPlayer(),
          Expanded(child: _buildDocument(document)),
        ],
      ),
      bottomNavigationBar: document == null
          ? null
          : _ZVideoEngagementBar(
              metrics: metrics,
              relationship: relationship,
              onComments: _openComments,
              onUnavailable: _showUnavailable,
            ),
    );
  }

  Widget _buildDocument(Map<String, dynamic>? document) {
    if (_loading && document == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (document == null) {
      return ApiErrorView(error: _error ?? '视频暂时无法加载', onRetry: _load);
    }
    final title = titleOf(document);
    final description = plainText(
      document['description'] ?? document['excerpt'] ?? document['brief'],
    );
    final authorName = authorNameOf(document);
    final authorHeadline = authorHeadlineOf(document);
    final authorAvatar = authorAvatarOf(document);
    final authorId = authorIdOf(document);
    final metrics = ContentMetrics.from(document);
    final date = contentDateLabel(metrics);
    final topics = _topicLabels(document);
    return ZhResponsiveFrame(
      maxWidth: 920,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 17, 18, 28),
        children: [
          Text(
            title.isEmpty ? '视频 #${widget.videoId}' : title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 21,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 13),
          if (authorName.isNotEmpty || authorId.isNotEmpty)
            InkWell(
              onTap: authorId.isEmpty
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserProfileDetailPage(
                          api: widget.api,
                          memberId: authorId,
                        ),
                      ),
                    ),
              borderRadius: BorderRadius.circular(ZhRadius.input),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _AuthorAvatar(
                      imageUrl: authorAvatar,
                      fallback: authorName.isEmpty
                          ? '知'
                          : authorName.characters.first,
                      size: 42,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName.isEmpty ? '知乎用户' : authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (authorHeadline.isNotEmpty)
                            Text(
                              authorHeadline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: ZhPalette.mutedInk),
                            ),
                        ],
                      ),
                    ),
                    if (authorId.isNotEmpty)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: ZhPalette.mutedInk,
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          _ZVideoMetadata(metrics: metrics, dateLabel: date),
          if (description.isNotEmpty) ...[
            const Divider(height: 28),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.65),
            ),
          ],
          if (topics.isNotEmpty) ...[
            const SizedBox(height: 17),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final topic in topics) ZhPill(label: topic, compact: true),
              ],
            ),
          ],
          const SizedBox(height: 20),
          ZhOutlineButton(
            onPressed: _openComments,
            icon: Icons.chat_bubble_outline_rounded,
            label: metrics.commentCount == null
                ? '查看评论'
                : '查看 ${compactCount(metrics.commentCount!)} 条评论',
            expand: true,
          ),
        ],
      ),
    );
  }

  List<String> _topicLabels(Map<String, dynamic> document) {
    final labels = <String>[];
    void add(Object? raw) {
      final values = raw is List ? raw : [raw];
      for (final value in values) {
        final map = value is Map
            ? value.map((key, value) => MapEntry(key.toString(), value))
            : null;
        final label = plainText(map?['name'] ?? map?['title']);
        if (label.isNotEmpty && !labels.contains(label)) labels.add(label);
        if (labels.length == 4) return;
      }
    }

    add(document['topics']);
    add(document['topic_tag']);
    return List.unmodifiable(labels);
  }
}

class _ZVideoMissingPlayer extends StatelessWidget {
  const _ZVideoMissingPlayer();

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: ColoredBox(
      color: Colors.black,
      child: Center(
        child: Text(
          '没有取得可播放的视频信息',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
      ),
    ),
  );
}

class _ZVideoMetadata extends StatelessWidget {
  const _ZVideoMetadata({required this.metrics, required this.dateLabel});

  final ContentMetrics metrics;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (metrics.viewCount case final value?) '${compactCount(value)} 次播放',
      if (metrics.voteupCount case final value?) '${compactCount(value)} 赞同',
      if (metrics.commentCount case final value?) '${compactCount(value)} 评论',
      if (dateLabel.isNotEmpty) dateLabel,
    ];
    return Wrap(
      spacing: 13,
      runSpacing: 6,
      children: [
        for (final label in labels)
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ZhPalette.subtleInk),
          ),
      ],
    );
  }
}

class _ZVideoEngagementBar extends StatelessWidget {
  const _ZVideoEngagementBar({
    required this.metrics,
    required this.relationship,
    required this.onComments,
    required this.onUnavailable,
  });

  final ContentMetrics metrics;
  final AnswerRelationship relationship;
  final VoidCallback onComments;
  final ValueChanged<String> onUnavailable;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: ZhPalette.background,
      border: Border(top: BorderSide(color: ZhPalette.border)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: _DetailAction(
                icon: Icons.thumb_up_alt_outlined,
                label: metrics.voteupCount == null
                    ? '赞同'
                    : compactCount(metrics.voteupCount!),
                semanticLabel: '赞同视频',
                selected: relationship.isUpvoted,
                onTap: () => onUnavailable('赞同'),
              ),
            ),
            Expanded(
              child: _DetailAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: metrics.commentCount == null
                    ? '评论'
                    : compactCount(metrics.commentCount!),
                semanticLabel: '查看视频评论',
                onTap: onComments,
              ),
            ),
            Expanded(
              child: _DetailAction(
                icon: Icons.star_border_rounded,
                label: metrics.favoriteCount == null
                    ? '收藏'
                    : compactCount(metrics.favoriteCount!),
                semanticLabel: '收藏视频',
                selected: relationship.isFavorited == true,
                onTap: () => onUnavailable('收藏'),
              ),
            ),
            Expanded(
              child: _DetailAction(
                icon: Icons.ios_share_rounded,
                label: '分享',
                semanticLabel: '分享视频',
                onTap: () => onUnavailable('分享'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
