import 'package:flutter/material.dart';

import '../core/recommendation_behavior.dart';
import '../l10n/zh_localization.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';

class RecommendationBehaviorPage extends StatefulWidget {
  const RecommendationBehaviorPage({super.key});

  @override
  State<RecommendationBehaviorPage> createState() =>
      _RecommendationBehaviorPageState();
}

class _RecommendationBehaviorPageState
    extends State<RecommendationBehaviorPage> {
  final _store = RecommendationBehaviorStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  Future<void> _clear() async {
    if (_store.profile.isEmpty) return;
    final l10n = context.zhL10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recommendationClearTitle),
        content: Text(l10n.recommendationClearMessage),
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
      ).showSnackBar(SnackBar(content: Text(l10n.recommendationCleared)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: ZhTopBar(
      title: Text(context.zhL10n.recommendationTitle),
      actions: [
        ZhLiquidGlassIconButton(
          key: const ValueKey('recommendation-behavior-clear'),
          semanticLabel: context.zhL10n.recommendationClearSemantic,
          onPressed: _clear,
          icon: const Icon(Icons.delete_outline_rounded),
          size: 44,
          iconSize: 22,
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final profile = _store.profile;
        return ZhPageWidth(
          maxWidth: 680,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              ZhSpace.md,
              ZhSpace.xs,
              ZhSpace.md,
              ZhSpace.xl,
            ),
            children: [
              ZhSurface(
                key: const ValueKey('recommendation-behavior-summary'),
                padding: const EdgeInsets.all(ZhSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.isEmpty
                          ? context.zhL10n.recommendationEmptyTitle
                          : context.zhL10n.recommendationProfileTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.isEmpty
                          ? context.zhL10n.recommendationEmptyMessage
                          : context.zhL10n.recommendationSummary(
                              profile.totalEvents,
                              profile.openedCount,
                              profile.feedbackCount,
                            ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ZhPalette.mutedInk,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (profile.topTopics.isNotEmpty) ...[
                const SizedBox(height: ZhSpace.md),
                Text(
                  context.zhL10n.recommendationTopics,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in profile.topTopics.take(12))
                      Chip(label: Text('${entry.key}  ${entry.value}')),
                  ],
                ),
              ],
              if (profile.topAuthors.isNotEmpty) ...[
                const SizedBox(height: ZhSpace.lg),
                Text(
                  context.zhL10n.recommendationAuthors,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final entry in profile.topAuthors.take(8))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline_rounded),
                    title: Text(entry.key),
                    trailing: Text('${entry.value}'),
                  ),
              ],
              const SizedBox(height: ZhSpace.lg),
              Text(
                context.zhL10n.recommendationPrivacy,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: ZhPalette.mutedInk),
              ),
            ],
          ),
        );
      },
    ),
  );
}
