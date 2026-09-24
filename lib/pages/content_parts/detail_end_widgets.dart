part of '../content_pages.dart';

String contentEndInfoLabel(
  Map<String, dynamic> object, {
  String fallback = '',
}) {
  final raw = object['content_end_info'];
  final info = raw is Map
      ? raw.map((key, value) => MapEntry(key.toString(), value))
      : const <String, dynamic>{};
  final created = plainText(info['create_time_text']).trim();
  final updated = plainText(info['update_time_text']).trim();
  final ip = plainText(info['ip_info']).trim();
  final dates = <String>[
    if (created.isNotEmpty) created else if (fallback.isNotEmpty) fallback,
    if (updated.isNotEmpty && updated != created) updated,
  ];
  return [...dates, if (ip.isNotEmpty) ip].join(' · ');
}

class _AnswerContentEndInfo extends StatelessWidget {
  const _AnswerContentEndInfo({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 22, 0, 8),
    child: Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: ZhPalette.subtleInk, height: 1.35),
    ),
  );
}

/// Contextual metadata stays visible beside long-form content on desktop.
/// The mobile action bar remains the single source of truth for mutations and
/// is intentionally left unchanged below the page body.
class _DetailDesktopRail extends StatelessWidget {
  const _DetailDesktopRail({
    required this.contentType,
    required this.metrics,
    required this.relationship,
    required this.dateLabel,
    required this.onComments,
  });
  final String contentType;
  final ContentMetrics metrics;
  final AnswerRelationship relationship;
  final String dateLabel;
  final VoidCallback onComments;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(0, 18, 18, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ZhSurface(
          padding: const EdgeInsets.all(ZhSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.zhL10n.detailContentInfo,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ZhSpace.sm),
              _DetailMetadata(
                metrics: metrics,
                relationship: relationship,
                dateLabel: dateLabel,
                contentLabel: contentType == 'article'
                    ? context.zhL10n.contentTypeArticle
                    : context.zhL10n.contentTypeAnswer,
              ),
              ZhOutlineButton(
                onPressed: onComments,
                icon: Icons.forum_outlined,
                label: context.zhL10n.detailViewComments,
                expand: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: ZhSpace.md),
        ZhSurface(
          padding: const EdgeInsets.all(ZhSpace.md),
          backgroundColor: ZhPalette.canvas,
          child: Text(
            context.zhL10n.detailReadingHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}
