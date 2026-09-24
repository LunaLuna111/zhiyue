part of '../../../widgets/api_views.dart';

List<String> _commentIdentityLabels(Object? value) {
  final labels = <String>[];

  void add(Object? item) {
    if (item == null || labels.length >= 3) return;
    if (item is Iterable) {
      for (final child in item) {
        add(child);
        if (labels.length >= 3) break;
      }
      return;
    }
    final map = item is Map
        ? item.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final label = plainText(map?['text'] ?? map?['name'] ?? item);
    if (label.isNotEmpty && !labels.contains(label)) labels.add(label);
  }

  add(value);
  return List.unmodifiable(labels);
}

List<String> _mergeCommentIdentityLabels(
  List<String> serverLabels,
  List<String> contextualLabels,
) {
  // Server labels carry the exact role wording. Contextual roles are a
  // fallback for older endpoints that omit the labels.
  if (serverLabels.isNotEmpty) {
    return List.unmodifiable(serverLabels.take(3));
  }
  return List.unmodifiable(contextualLabels.take(3));
}

List<String> _localizedCommentIdentityLabels(
  BuildContext context,
  List<String> labels,
) => [
  for (final label in labels)
    switch (label) {
      '作者' => context.zhL10n.commentAuthorBadge,
      '题主' => context.zhL10n.commentQuestionAuthor,
      _ => label,
    },
];

List<String> _commentFooterLabels(Object? value) =>
    _commentIdentityLabels(value);

String _compactCommentDateLabel(ContentMetrics metrics) {
  final timestamp = metrics.createdTime ?? metrics.updatedTime;
  if (timestamp == null || timestamp <= 0) return '';
  final milliseconds = timestamp > 100000000000 ? timestamp : timestamp * 1000;
  final value = DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal();
  final now = DateTime.now();
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return value.year == now.year ? '$month-$day' : '${value.year}-$month-$day';
}

class _CommentAuthorIdentityLine extends StatelessWidget {
  const _CommentAuthorIdentityLine({
    required this.authorName,
    required this.labels,
    this.onTap,
    this.semanticKey,
  });

  final String authorName;
  final List<String> labels;
  final VoidCallback? onTap;
  final Key? semanticKey;

  @override
  Widget build(BuildContext context) {
    final name = authorName.isEmpty
        ? context.zhL10n.commonZhihuUser
        : authorName;
    final localizedLabels = _localizedCommentIdentityLabels(context, labels);
    final nameText = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
    final callback = onTap;
    final author = callback == null
        ? nameText
        : Semantics(
            key: semanticKey,
            button: true,
            label: context.zhL10n.commentAuthorSemantics(name),
            child: InkWell(
              onTap: callback,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: nameText,
              ),
            ),
          );
    return Wrap(
      spacing: 5,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        author,
        for (final label in localizedLabels)
          _CommentIdentityBadge(scope: 'author', label: label),
      ],
    );
  }
}

class _CommentReplyIdentityLine extends StatelessWidget {
  const _CommentReplyIdentityLine({
    required this.replyTarget,
    required this.labels,
  });

  final String replyTarget;
  final List<String> labels;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 5,
    runSpacing: 2,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        context.zhL10n.commentReplyTo(replyTarget),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: ZhPalette.subtleInk),
      ),
      for (final label in _localizedCommentIdentityLabels(context, labels))
        _CommentIdentityBadge(scope: 'reply', label: label),
    ],
  );
}

class _CompactCommentIdentityLine extends StatelessWidget {
  const _CompactCommentIdentityLine({
    required this.authorName,
    required this.authorLabels,
    required this.replyTarget,
    required this.replyAuthorLabels,
    this.onTap,
    this.semanticKey,
  });

  final String authorName;
  final List<String> authorLabels;
  final String replyTarget;
  final List<String> replyAuthorLabels;
  final VoidCallback? onTap;
  final Key? semanticKey;

  @override
  Widget build(BuildContext context) {
    final name = authorName.isEmpty
        ? context.zhL10n.commonZhihuUser
        : authorName;
    final nameText = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: ZhPalette.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
    );
    final callback = onTap;
    final author = callback == null
        ? nameText
        : Semantics(
            key: semanticKey,
            button: true,
            label: context.zhL10n.commentAuthorSemantics(name),
            child: InkWell(
              onTap: callback,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: nameText,
              ),
            ),
          );
    return Wrap(
      spacing: 4,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        author,
        for (final label in _localizedCommentIdentityLabels(
          context,
          authorLabels,
        ))
          _CommentIdentityBadge(scope: 'author', label: label),
        if (replyTarget.isNotEmpty) ...[
          Icon(Icons.arrow_right_rounded, size: 14, color: ZhPalette.subtleInk),
          Text(
            replyTarget,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ZhPalette.ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          for (final label in _localizedCommentIdentityLabels(
            context,
            replyAuthorLabels,
          ))
            _CommentIdentityBadge(scope: 'reply', label: label),
        ],
      ],
    );
  }
}

class _CommentIdentityBadge extends StatelessWidget {
  const _CommentIdentityBadge({required this.scope, required this.label});

  final String scope;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('comment-$scope-identity-$label'),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(
      color: ZhPalette.canvas,
      border: Border.all(color: ZhPalette.border, width: 0.8),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: ZhPalette.subtleInk,
        fontSize: 10,
        height: 1.15,
      ),
    ),
  );
}

enum _CompactCommentMenuAction { reply, delete, report }

class _CompactCommentMenu extends StatelessWidget {
  const _CompactCommentMenu({this.onReply, this.onDelete});

  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) =>
      ZhPopupMenuButton<_CompactCommentMenuAction>(
        tooltip: context.zhL10n.commonMore,
        padding: EdgeInsets.zero,
        iconSize: 20,
        style: IconButton.styleFrom(
          minimumSize: const Size.square(28),
          maximumSize: const Size.square(28),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        color: ZhPalette.background,
        icon: Icon(Icons.more_horiz_rounded, color: ZhPalette.subtleInk),
        onSelected: (action) {
          switch (action) {
            case _CompactCommentMenuAction.reply:
              onReply?.call();
              break;
            case _CompactCommentMenuAction.delete:
              onDelete?.call();
              break;
            case _CompactCommentMenuAction.report:
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                SnackBar(
                  content: Text(context.zhL10n.commentReportUnavailable),
                ),
              );
              break;
          }
        },
        itemBuilder: (context) => [
          if (onReply != null)
            ZhMenuItem(
              value: _CompactCommentMenuAction.reply,
              label: context.zhL10n.commonReply,
            ),
          if (onDelete != null)
            ZhMenuItem(
              value: _CompactCommentMenuAction.delete,
              label: context.zhL10n.commonDelete,
            ),
          ZhMenuItem(
            value: _CompactCommentMenuAction.report,
            label: context.zhL10n.commonReport,
          ),
        ],
      );
}

class _CompactCommentMetadata extends StatelessWidget {
  const _CompactCommentMetadata({
    required this.dateLabel,
    required this.labels,
    this.onReply,
  });

  final String dateLabel;
  final List<String> labels;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      if (dateLabel.isNotEmpty) dateLabel,
      ...labels.where((label) => label.isNotEmpty),
    ];
    return Wrap(
      spacing: 5,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (metadata.isNotEmpty)
          Text(
            metadata.join(' · '),
            style: TextStyle(
              color: ZhPalette.subtleInk,
              fontSize: 12,
              height: 1.25,
            ),
          ),
        if (onReply != null)
          Semantics(
            button: true,
            label: context.zhL10n.commentReply,
            child: InkWell(
              borderRadius: BorderRadius.circular(3),
              onTap: onReply,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                child: Text(
                  context.zhL10n.commonReply,
                  style: TextStyle(
                    color: ZhPalette.subtleInk,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompactCommentReaction extends StatelessWidget {
  const _CompactCommentReaction({
    required this.icon,
    required this.semanticLabel,
    this.label = '',
    this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 19,
            color: selected ? ZhPalette.link : ZhPalette.subtleInk,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? ZhPalette.link : ZhPalette.disabledInk,
                fontSize: 12,
                height: 1.15,
              ),
            ),
          ],
        ],
      ),
    );
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      excludeSemantics: true,
      child: onTap == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: content,
            ),
    );
  }
}
