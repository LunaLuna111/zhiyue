import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/session_store.dart';
import '../l10n/zh_localization.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import 'content_pages.dart';

class BrowsingHistoryPage extends StatelessWidget {
  const BrowsingHistoryPage({
    super.key,
    required this.api,
    required this.session,
  });

  final ZhihuApiClient api;
  final SessionStore session;

  Future<void> _clear(BuildContext context) async {
    if (session.browsingHistory.isEmpty) return;
    final l10n = context.zhL10n;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.browsingHistoryClearTitle),
            content: Text(l10n.browsingHistoryClearMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.commonClear),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) await session.clearBrowsingHistory();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: session.browsingHistoryChanges,
    builder: (context, _) => Scaffold(
      appBar: ZhTopBar(
        title: Text(context.zhL10n.browsingHistoryTitle),
        actions: [
          ZhLiquidGlassIconButton(
            key: const ValueKey('clear-browsing-history'),
            semanticLabel: context.zhL10n.browsingHistoryClear,
            onPressed: session.browsingHistory.isEmpty
                ? null
                : () => _clear(context),
            icon: const Icon(Icons.delete_outline_rounded),
            size: 44,
            iconSize: 22,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final entries = session.browsingHistory;
          if (entries.isEmpty) {
            return const _EmptyHistory();
          }
          return ZhResponsiveFrame(
            maxWidth: 720,
            desktopGutter: 24,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Dismissible(
                  key: ValueKey('history-${entry.identity}'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) =>
                      session.removeBrowsingHistory(entry.identity),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 22),
                    color: ZhPalette.ink,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: ZhPalette.background,
                    ),
                  ),
                  child: _HistoryRow(
                    entry: entry,
                    onTap: () =>
                        openDetectedObject(context, api, _historySource(entry)),
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}

Map<String, dynamic> _historySource(BrowsingHistoryEntry entry) => {
  'type': entry.type,
  'id': entry.id,
  'title': entry.title,
  'excerpt': entry.excerpt,
  if (entry.author.isNotEmpty) 'author': {'name': entry.author},
  if (entry.questionId.isNotEmpty)
    'question': {'id': entry.questionId, 'title': entry.questionTitle},
  if (entry.type.contains('column')) 'url_token': entry.id,
};

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.onTap});

  final BrowsingHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ZhPanel(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 3),
    radius: 0,
    borderColor: null,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZhIconTile(icon: _historyIcon(entry.type)),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (entry.excerpt.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  entry.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ZhPalette.mutedInk,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 7),
              Text(
                [
                  if (entry.author.isNotEmpty) entry.author,
                  _historyTypeLabel(entry.type, context.zhL10n),
                  _historyTime(entry.visitedAt, context.zhL10n),
                ].join(' · '),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: ZhPalette.subtleInk),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 9),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: ZhPalette.subtleInk,
          ),
        ),
      ],
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ZhIconTile(
            icon: Icons.history_rounded,
            size: 64,
            iconSize: 28,
            circle: true,
          ),
          const SizedBox(height: 16),
          Text(
            context.zhL10n.browsingHistoryEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            context.zhL10n.browsingHistoryEmptyMessage,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ZhPalette.mutedInk),
          ),
        ],
      ),
    ),
  );
}

IconData _historyIcon(String type) {
  if (type.contains('answer')) return Icons.question_answer_outlined;
  if (type.contains('article')) return Icons.article_outlined;
  if (type.contains('question')) return Icons.help_outline_rounded;
  if (type.contains('topic')) return Icons.tag_rounded;
  if (type.contains('column')) return Icons.view_column_outlined;
  if (type.contains('people') || type.contains('member')) {
    return Icons.person_outline_rounded;
  }
  return Icons.description_outlined;
}

String _historyTypeLabel(String type, AppLocalizations l10n) {
  if (type.contains('answer')) return l10n.contentTypeAnswer;
  if (type.contains('article')) return l10n.contentTypeArticle;
  if (type.contains('question')) return l10n.contentTypeQuestion;
  if (type.contains('topic')) return l10n.contentTypeTopic;
  if (type.contains('column')) return l10n.contentTypeColumn;
  if (type.contains('people') || type.contains('member')) {
    return l10n.contentTypePeople;
  }
  return l10n.contentTypeContent;
}

String _historyTime(DateTime value, AppLocalizations l10n) {
  final local = value.toLocal();
  final now = DateTime.now();
  final sameDay =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final time = '$hour:$minute';
  if (sameDay) return l10n.browsingHistoryToday(time);
  return l10n.browsingHistoryDate(local.month, local.day, time);
}
