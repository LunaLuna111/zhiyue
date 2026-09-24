part of '../content_pages.dart';

class TopicFeedsPage extends StatefulWidget {
  const TopicFeedsPage({
    super.key,
    required this.api,
    required this.topicId,
    this.title = '',
  });

  final ZhihuApiClient api;
  final String topicId;
  final String title;

  @override
  State<TopicFeedsPage> createState() => _TopicFeedsPageState();
}

class _TopicFeedsPageState extends State<TopicFeedsPage> {
  Map<String, dynamic>? _topic;
  Object? _topicError;

  @override
  void initState() {
    super.initState();
    _loadBasic();
  }

  Future<void> _loadBasic() async {
    setState(() => _topicError = null);
    try {
      final response = await widget.api.get(
        '/topics/${Uri.encodeComponent(widget.topicId)}/basic',
      );
      if (!mounted) return;
      setState(() {
        if (response.isSuccess && response.jsonMap != null) {
          _topic = unwrapObject(response.jsonMap!);
        } else {
          _topicError = response;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _topicError = error);
    }
  }

  void _openFollowers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PagedListPage(
          title: context.zhL10n.topicFollowersTitle,
          api: widget.api,
          loadInitial: () => widget.api.get(
            '/topics/${Uri.encodeComponent(widget.topicId)}/followers',
            query: const {'offset': 0},
          ),
          onObjectTap: (context, value) =>
              openDetectedObject(context, widget.api, value),
        ),
      ),
    );
  }

  void _openUnanswered() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PagedListPage(
          title: context.zhL10n.topicUnansweredTitle,
          api: widget.api,
          loadInitial: () => widget.api.get(
            '/topics/${Uri.encodeComponent(widget.topicId)}/unanswered_questions',
            query: const {'offset': 0, 'limit': 10},
          ),
          onObjectTap: (context, value) =>
              openDetectedObject(context, widget.api, value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final topic = _topic;
    final resolvedTitle = topic == null ? '' : titleOf(topic);
    return PagedListPage(
      title: resolvedTitle.isNotEmpty
          ? resolvedTitle
          : widget.title.isEmpty
          ? l10n.topicFallbackTitle(widget.topicId)
          : widget.title,
      api: widget.api,
      actions: [
        ZhLiquidGlassIconButton(
          semanticLabel: l10n.topicRefresh,
          onPressed: _loadBasic,
          icon: const Icon(Icons.refresh_rounded),
          size: 44,
          iconSize: 22,
        ),
      ],
      header: TopicHeaderCard(
        topic:
            topic ??
            {'type': 'topic', 'id': widget.topicId, 'name': widget.title},
        loading: topic == null && _topicError == null,
        basicError: _topicError,
        onFollowers: _openFollowers,
        onUnanswered: _openUnanswered,
      ),
      loadInitial: () => widget.api.get(
        '/topics/${Uri.encodeComponent(widget.topicId)}/essence_feeds',
        query: const {'offset': 0, 'limit': 10},
      ),
      onObjectTap: (context, value) =>
          openDetectedObject(context, widget.api, value),
    );
  }
}

class TopicHeaderCard extends StatelessWidget {
  const TopicHeaderCard({
    super.key,
    required this.topic,
    required this.onFollowers,
    required this.onUnanswered,
    this.loading = false,
    this.basicError,
  });

  final Map<String, dynamic> topic;
  final VoidCallback onFollowers;
  final VoidCallback onUnanswered;
  final bool loading;
  final Object? basicError;

  int? _count(List<String> keys) {
    for (final key in keys) {
      final value = topic[key];
      if (value is num) return value.round();
      final parsed = int.tryParse(plainText(value).replaceAll(',', ''));
      if (parsed != null) return parsed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final name = titleOf(topic).isEmpty ? l10n.topicLabel : titleOf(topic);
    final avatar = plainText(
      topic['avatar_url'] ?? topic['icon'] ?? topic['meta_avatar_url'],
    );
    final validAvatar = Uri.tryParse(avatar)?.scheme == 'https';
    final description = plainText(
      topic['introduction'] ?? topic['excerpt'] ?? topic['content'],
    );
    final metrics = <String>[
      if (_count(const ['followers_count', 'follower_count']) case final value?)
        l10n.topicFollowers(compactCount(value)),
      if (_count(const ['questions_count', 'question_count']) case final value?)
        l10n.topicQuestions(compactCount(value)),
      if (_count(const ['answer_count']) case final value?)
        l10n.topicAnswers(compactCount(value)),
      if (_count(const ['discussion_totals']) case final value?)
        l10n.topicDiscussions(compactCount(value)),
    ];
    return ZhSurface(
      margin: const EdgeInsets.fromLTRB(
        ZhSpace.sm,
        ZhSpace.xs,
        ZhSpace.sm,
        ZhSpace.sm,
      ),
      radius: ZhRadius.hero,
      padding: const EdgeInsets.all(ZhSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: validAvatar
                    ? ZhihuImage.network(
                        avatar,
                        headers: zhihuImageRequestHeaders,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        cacheWidth: 174,
                        cacheHeight: 174,
                        filterQuality: FilterQuality.low,
                        frameBuilder: (_, child, frame, _) =>
                            frame == null ? const _TopicPlaceholder() : child,
                        errorBuilder: (_, _, _) => const _TopicPlaceholder(),
                      )
                    : const _TopicPlaceholder(),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ZhPill(label: l10n.topicLabel, compact: true),
                    const SizedBox(height: 7),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              metrics.join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ZhPalette.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (loading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ] else if (basicError != null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.topicBasicUnavailable,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ZhOutlineButton(
                  onPressed: onFollowers,
                  icon: Icons.groups_outlined,
                  label: l10n.topicFollowersButton,
                  expand: true,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: ZhOutlineButton(
                  onPressed: onUnanswered,
                  icon: Icons.help_outline_rounded,
                  label: l10n.topicUnansweredButton,
                  expand: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopicPlaceholder extends StatelessWidget {
  const _TopicPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
    width: 58,
    height: 58,
    color: ZhPalette.canvas,
    alignment: Alignment.center,
    child: const Icon(Icons.tag_rounded, size: 27),
  );
}
