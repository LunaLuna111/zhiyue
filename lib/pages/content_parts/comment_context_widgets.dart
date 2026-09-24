part of '../content_pages.dart';

class _SentenceCommentQuote extends StatelessWidget {
  const _SentenceCommentQuote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('sentence-comment-quote'),
    width: double.infinity,
    color: ZhPalette.softSurface,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: ZhPalette.accent, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ZhPalette.quoteText,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ),
    ),
  );
}

class CommentContextHeader extends StatelessWidget {
  const CommentContextHeader({
    super.key,
    required this.response,
    required this.loading,
    required this.onAuthor,
    this.error,
    this.following = false,
    this.followBusy = false,
    this.onFollow,
  });

  final Map<String, dynamic>? response;
  final bool loading;
  final Object? error;
  final VoidCallback onAuthor;
  final bool following;
  final bool followBusy;
  final VoidCallback? onFollow;

  @override
  Widget build(BuildContext context) {
    final author = commentContentAuthorOf(response);
    final authorName = author == null ? '' : titleOf(author);
    final avatar = plainText(author?['avatar_url']);
    final headline = plainText(author?['headline']);
    final wrapper = commentContentAuthorWrapperOf(response);
    final badge = _commentHeaderTag(
      wrapper?['author_tag'] ?? author?['author_tag'],
    );
    final isSelf = author?['is_self'] == true || author?['is_me'] == true;
    if (error != null || loading || author == null) {
      return const SizedBox.shrink();
    }
    final showFollow = !following && !isSelf && onFollow != null;
    return SizedBox(
      key: const Key('comment-context-header'),
      height: 76,
      child: ColoredBox(
        color: ZhPalette.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 60,
              child: InkWell(
                onTap: onAuthor,
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 12,
                      child: _AuthorAvatar(
                        imageUrl: avatar,
                        fallback: authorName.isEmpty
                            ? '知'
                            : authorName.characters.first,
                        size: 30,
                      ),
                    ),
                    Positioned(
                      left: 56,
                      right: showFollow ? 102 : 16,
                      top: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  authorName.isEmpty ? '知乎用户' : authorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ZhPalette.ink,
                                    fontSize: 14,
                                    height: 1.25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (badge.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                _CommentContextBadge(label: badge),
                              ],
                            ],
                          ),
                          if (headline.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              headline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ZhPalette.subtleInk,
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showFollow)
                      Positioned(
                        top: 15,
                        right: 16,
                        child: _OfficialFollowButton(
                          busy: followBusy,
                          onPressed: onFollow!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 8,
              child: ColoredBox(color: ZhPalette.softSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentContextBadge extends StatelessWidget {
  const _CommentContextBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 14,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      border: Border.all(color: ZhPalette.softBorder, width: .8),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      maxLines: 1,
      style: TextStyle(
        color: ZhPalette.disabledInk,
        fontSize: 10,
        height: 1,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class _OfficialFollowButton extends StatelessWidget {
  const _OfficialFollowButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 70,
    height: 30,
    child: TextButton(
      key: const Key('comment-content-author-follow'),
      onPressed: busy ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: ZhPalette.link,
        backgroundColor: ZhPalette.accentSurface,
        disabledForegroundColor: ZhPalette.disabledInk,
        padding: EdgeInsets.zero,
        shape: const StadiumBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: busy
          ? const SizedBox.square(
              dimension: 13,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            )
          : const Text(
              '+ 关注',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
    ),
  );
}

Widget? commentListSummaryHeader(
  BuildContext context,
  Map<String, dynamic> response, {
  int? fallbackTotal,
  String selectedType = '',
  String selectedOrder = 'score',
  ValueChanged<String>? onTypeChanged,
  ValueChanged<String>? onOrderChanged,
}) {
  int? intValue(Object? value) {
    if (value is num) return value.round();
    return int.tryParse(plainText(value));
  }

  final counts = _contentMap(response['counts']);
  final total = intValue(counts?['total_counts']) ?? fallbackTotal;
  final sortOptions = <(String, String)>[];
  void addSorters(Object? sorter) {
    if (sorter is! List) return;
    for (final item in sorter) {
      final map = _contentMap(item);
      final rawType = plainText(map?['type']).toLowerCase();
      // Public comment-v5 sends `ts` for the official "latest" tab. Normalize
      // legacy aliases to that exact wire value instead of translating it to
      // `time`, which the endpoint accepts but treats like the default order.
      final type = switch (rawType) {
        'time' || 'created' || 'newest' => 'ts',
        'hot' || 'default' => 'score',
        _ => rawType,
      };
      final text = plainText(map?['text']);
      if (type.isEmpty || text.isEmpty) continue;
      if (!sortOptions.any((option) => option.$1 == type)) {
        sortOptions.add((type, text));
      }
    }
  }

  addSorters(response['sorter']);
  if (sortOptions.isEmpty && total == null && response.isEmpty) return null;
  return Container(
    key: const Key('comment-summary-controls'),
    height: 48,
    color: ZhPalette.background,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            total == null
                ? context.zhL10n.commentAll
                : context.zhL10n.commentCount(compactCount(total)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ZhPalette.ink,
              fontSize: 15,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (sortOptions.isNotEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: ZhPalette.softSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < sortOptions.length; index++) ...[
                    if (index > 0)
                      SizedBox(
                        width: 1,
                        height: 12,
                        child: ColoredBox(color: ZhPalette.softBorder),
                      ),
                    _OfficialSortChoice(
                      semanticKey: 'comment-sort-${sortOptions[index].$1}',
                      label: _officialSortLabel(
                        context.zhL10n,
                        sortOptions[index],
                      ),
                      selected: sortOptions[index].$1 == selectedOrder,
                      onTap: onOrderChanged == null
                          ? null
                          : () => onOrderChanged(sortOptions[index].$1),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

String _officialSortLabel(AppLocalizations l10n, (String, String) option) {
  if (option.$1 == 'score') return l10n.commentDefault;
  if (option.$1 == 'time' || option.$1 == 'ts') return l10n.commentLatest;
  final characters = option.$2.characters;
  return characters.length <= 3 ? option.$2 : characters.take(3).toString();
}

class _OfficialSortChoice extends StatelessWidget {
  const _OfficialSortChoice({
    required this.semanticKey,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String semanticKey;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    key: ValueKey(semanticKey),
    button: onTap != null,
    selected: selected,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? ZhPalette.background : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: selected ? ZhPalette.ink : ZhPalette.disabledInk,
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}
