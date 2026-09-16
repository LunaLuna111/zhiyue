import 'package:flutter/material.dart';

import '../core/content_filter_stats.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';

class ContentFilterStatsPage extends StatefulWidget {
  const ContentFilterStatsPage({super.key});

  @override
  State<ContentFilterStatsPage> createState() => _ContentFilterStatsPageState();
}

class _ContentFilterStatsPageState extends State<ContentFilterStatsPage> {
  final _store = ContentFilterStatsStore.instance;
  late final Future<ContentFilterStats> _load = _store.load();

  Future<void> _clear() async {
    if (_store.stats.totalActions == 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空过滤统计？'),
        content: const Text('只会删除本机记录，不会改变知乎账号和服务端反馈设置。'),
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
    );
    if (confirmed != true) return;
    await _store.clear();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('内容过滤统计已清空')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZhTopBar(
        title: const Text('内容过滤统计'),
        actions: [
          IconButton(
            key: const ValueKey('content-filter-stats-clear'),
            tooltip: '清空统计',
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: FutureBuilder<ContentFilterStats>(
        future: _load,
        builder: (context, snapshot) => AnimatedBuilder(
          animation: _store,
          builder: (context, _) => _body(context, _store.stats),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ContentFilterStats stats) => Semantics(
    key: const ValueKey('content-filter-stats-page'),
    container: true,
    label: '内容过滤统计',
    child: ZhPageWidth(
      maxWidth: 680,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          ZhSpace.md,
          ZhSpace.sm,
          ZhSpace.md,
          ZhSpace.xl,
        ),
        children: [
          ZhSurface(
            padding: const EdgeInsets.all(ZhSpace.md),
            child: Row(
              children: [
                Expanded(
                  child: _StatValue(
                    key: const ValueKey('content-filter-total'),
                    label: '反馈操作',
                    value: stats.totalActions.toString(),
                  ),
                ),
                Container(width: 1, height: 48, color: ZhPalette.border),
                Expanded(
                  child: _StatValue(
                    key: const ValueKey('content-filter-removed'),
                    label: '已隐藏内容',
                    value: stats.removedItems.toString(),
                  ),
                ),
              ],
            ),
          ),
          const _StatsHeading('过滤原因'),
          if (stats.orderedReasons.isEmpty)
            ZhSurface(
              padding: const EdgeInsets.all(ZhSpace.md),
              child: Text(
                '在首页卡片中选择“减少此类内容”后，这里会按原因累计统计。',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
              ),
            )
          else
            ZhSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < stats.orderedReasons.length;
                    index++
                  ) ...[
                    if (index > 0) const Divider(height: 1),
                    ListTile(
                      key: ValueKey(
                        'content-filter-reason-${stats.orderedReasons[index].key}',
                      ),
                      leading: const Icon(Icons.filter_alt_outlined),
                      title: Text(stats.orderedReasons[index].key),
                      trailing: Text(
                        '${stats.orderedReasons[index].value} 次',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const _StatsHeading('最近一次'),
          ZhSurface(
            padding: const EdgeInsets.all(ZhSpace.md),
            child: stats.lastReason.isEmpty
                ? Text(
                    '暂无记录',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.lastReason,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (stats.lastAction.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          stats.lastAction,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ZhPalette.mutedInk),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

class _StatsHeading extends StatelessWidget {
  const _StatsHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
    child: Text(label, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _StatValue extends StatelessWidget {
  const _StatValue({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
