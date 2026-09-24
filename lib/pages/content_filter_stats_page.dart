import 'package:flutter/material.dart';

import '../core/content_filter_stats.dart';
import '../l10n/zh_localization.dart';
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
    final l10n = context.zhL10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contentFilterClearTitle),
        content: Text(l10n.contentFilterClearMessage),
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
    );
    if (confirmed != true) return;
    await _store.clear();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.contentFilterCleared)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZhTopBar(
        title: Text(context.zhL10n.contentFilterStatsTitle),
        actions: [
          ZhLiquidGlassIconButton(
            key: const ValueKey('content-filter-stats-clear'),
            semanticLabel: context.zhL10n.contentFilterClearStats,
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline_rounded),
            size: 44,
            iconSize: 22,
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
    label: context.zhL10n.contentFilterStatsLabel,
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
                    label: context.zhL10n.contentFilterActions,
                    value: stats.totalActions.toString(),
                  ),
                ),
                Container(width: 1, height: 48, color: ZhPalette.border),
                Expanded(
                  child: _StatValue(
                    key: const ValueKey('content-filter-removed'),
                    label: context.zhL10n.contentFilterHidden,
                    value: stats.removedItems.toString(),
                  ),
                ),
              ],
            ),
          ),
          _StatsHeading(context.zhL10n.contentFilterReasons),
          if (stats.orderedReasons.isEmpty)
            ZhSurface(
              padding: const EdgeInsets.all(ZhSpace.md),
              child: Text(
                context.zhL10n.contentFilterHint,
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
                        context.zhL10n.contentFilterCount(
                          stats.orderedReasons[index].value.toString(),
                        ),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          _StatsHeading(context.zhL10n.contentFilterLatest),
          ZhSurface(
            padding: const EdgeInsets.all(ZhSpace.md),
            child: stats.lastReason.isEmpty
                ? Text(
                    context.zhL10n.contentFilterEmpty,
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
