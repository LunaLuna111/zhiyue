import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/session_store.dart';
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
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('清空历史记录？'),
            content: const Text('这只会删除知阅保存在本机的浏览记录。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('清空'),
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
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            key: const ValueKey('clear-browsing-history'),
            tooltip: '清空历史记录',
            onPressed: session.browsingHistory.isEmpty
                ? null
                : () => _clear(context),
            icon: const Icon(Icons.delete_outline_rounded),
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
                    child: const Icon(
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
                  _historyTypeLabel(entry.type),
                  _historyTime(entry.visitedAt),
                ].join(' · '),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: ZhPalette.subtleInk),
              ),
            ],
          ),
        ),
        const Padding(
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
          Text('还没有浏览记录', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(
            '打开回答、文章、问题或话题后会显示在这里',
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

String _historyTypeLabel(String type) {
  if (type.contains('answer')) return '回答';
  if (type.contains('article')) return '文章';
  if (type.contains('question')) return '问题';
  if (type.contains('topic')) return '话题';
  if (type.contains('column')) return '专栏';
  if (type.contains('people') || type.contains('member')) return '用户';
  return '内容';
}

String _historyTime(DateTime value) {
  final local = value.toLocal();
  final now = DateTime.now();
  final sameDay =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  if (sameDay) return '今天 $hour:$minute';
  return '${local.month}月${local.day}日 $hour:$minute';
}
