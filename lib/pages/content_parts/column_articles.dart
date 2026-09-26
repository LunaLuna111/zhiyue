part of '../content_pages.dart';

class ColumnArticlesPage extends StatelessWidget {
  const ColumnArticlesPage({
    super.key,
    required this.api,
    required this.columnToken,
    this.title = '',
  });

  final ZhihuApiClient api;
  final String columnToken;
  final String title;

  @override
  Widget build(BuildContext context) => PagedListPage(
    title: title.isEmpty
        ? context.zhL10n.columnFallbackTitle(columnToken)
        : title,
    api: api,
    loadInitial: () => api.getUri(api.columnArticlesUri(columnToken)),
    header: ColumnMetadataHeader(api: api, columnToken: columnToken),
    onObjectTap: (context, value) => openDetectedObject(context, api, value),
  );
}

Map<String, dynamic>? columnMetadataOf(Map<String, dynamic> response) {
  final direct = _contentMap(response['column']);
  if (direct != null) return direct;
  for (final row in extractRows(response)) {
    final object = unwrapObject(row);
    final column = _contentMap(object['column']);
    if (column != null) return column;
    final detail = _contentMap(object['detail']);
    final nested = _contentMap(detail?['column']);
    if (nested != null) return nested;
  }
  return null;
}

class ColumnMetadataHeader extends StatefulWidget {
  const ColumnMetadataHeader({
    super.key,
    required this.api,
    required this.columnToken,
  });

  final ZhihuApiClient api;
  final String columnToken;

  @override
  State<ColumnMetadataHeader> createState() => _ColumnMetadataHeaderState();
}

class _ColumnMetadataHeaderState extends State<ColumnMetadataHeader> {
  Object? _state;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = null);
    try {
      final response = await widget.api.getUri(
        widget.api.columnDetailUri(widget.columnToken),
      );
      if (mounted) setState(() => _state = response);
    } catch (error) {
      if (mounted) setState(() => _state = error);
    }
  }

  void _openFollowers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PagedListPage(
          title: context.zhL10n.columnFollowersTitle,
          api: widget.api,
          loadInitial: () => widget.api.getUri(
            widget.api.columnFollowersUri(widget.columnToken),
          ),
          onObjectTap: (context, value) =>
              openDetectedObject(context, widget.api, value),
        ),
      ),
    );
  }

  void _openAuthor(Map<String, dynamic> column) {
    final author = _contentMap(column['author']);
    final authorId = personMemberIdOf(author);
    if (authorId.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            UserProfileDetailPage(api: widget.api, memberId: authorId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }
    if (state is ApiResponse && state.isSuccess && state.jsonMap != null) {
      final column = unwrapObject(state.jsonMap!);
      final author = _contentMap(column['author']);
      final authorId = personMemberIdOf(author);
      return ColumnHeaderCard(
        column: column,
        onFollowers: _openFollowers,
        onAuthor: authorId.isEmpty ? null : () => _openAuthor(column),
      );
    }
    return ZhSurface(
      margin: const EdgeInsets.fromLTRB(
        ZhSpace.sm,
        ZhSpace.xs,
        ZhSpace.sm,
        ZhSpace.sm,
      ),
      padding: const EdgeInsets.all(ZhSpace.md),
      child: Row(
        children: [
          const Icon(Icons.view_column_outlined, size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              context.zhL10n.columnLoadFailed,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            tooltip: context.zhL10n.columnRetry,
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class ColumnHeaderCard extends StatelessWidget {
  const ColumnHeaderCard({
    super.key,
    required this.column,
    required this.onFollowers,
    this.onAuthor,
  });

  final Map<String, dynamic> column;
  final VoidCallback onFollowers;
  final VoidCallback? onAuthor;

  int? _count(List<String> keys) {
    for (final key in keys) {
      final value = column[key];
      if (value is num) return value.round();
      final parsed = int.tryParse(plainText(value).replaceAll(',', ''));
      if (parsed != null) return parsed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final name = titleOf(column).isEmpty ? l10n.columnTitle : titleOf(column);
    final avatar = plainText(column['avatar_url'] ?? column['image_url']);
    final description = plainText(column['intro'] ?? column['description']);
    final author = _contentMap(column['author']);
    final authorName = author == null ? '' : titleOf(author);
    final metrics = <String>[
      if (_count(const ['articles_count', 'items_count']) case final value?)
        l10n.columnArticleCount(compactCount(value)),
      if (_count(const ['followers', 'followers_count']) case final value?)
        l10n.columnFollowerCount(compactCount(value)),
      if (_count(const ['contributions_count']) case final value?)
        l10n.columnContributionCount(compactCount(value)),
      if (_count(const ['voteup_count']) case final value?)
        l10n.columnVoteupCount(compactCount(value)),
    ];
    final validAvatar = Uri.tryParse(avatar)?.scheme == 'https';
    final placeholder = Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: ZhPalette.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.view_column_outlined,
        color: ZhPalette.background,
        size: 28,
      ),
    );
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
                borderRadius: BorderRadius.circular(18),
                child: validAvatar
                    ? ZhihuImage.network(
                        avatar,
                        headers: zhihuImageRequestHeaders,
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        cacheWidth: 186,
                        cacheHeight: 186,
                        filterQuality: FilterQuality.low,
                        frameBuilder: (_, child, frame, _) =>
                            frame == null ? placeholder : child,
                        errorBuilder: (_, _, _) => placeholder,
                      )
                    : placeholder,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ZhPill(label: l10n.contentTypeColumn, compact: true),
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
          if (authorName.isNotEmpty || metrics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              [
                if (authorName.isNotEmpty) l10n.columnAuthorPrefix(authorName),
                ...metrics,
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ZhPalette.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ZhOutlineButton(
                  onPressed: onFollowers,
                  icon: Icons.groups_outlined,
                  label: l10n.columnFollowers,
                  expand: true,
                ),
              ),
              if (onAuthor != null) ...[
                const SizedBox(width: 9),
                Expanded(
                  child: ZhOutlineButton(
                    onPressed: onAuthor,
                    icon: Icons.person_outline_rounded,
                    label: l10n.columnAuthorProfile,
                    expand: true,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
