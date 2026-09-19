import 'package:flutter/material.dart';

import '../core/recommendation_behavior.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空本地推荐画像？'),
        content: const Text('只会删除本机记录，不会影响知乎账号和服务器推荐。'),
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
      ).showSnackBar(const SnackBar(content: Text('本地推荐画像已清空')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: ZhTopBar(
      title: const Text('本地推荐行为'),
      actions: [
        ZhLiquidGlassIconButton(
          key: const ValueKey('recommendation-behavior-clear'),
          semanticLabel: '清空本地画像',
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
                      profile.isEmpty ? '暂时还没有本地行为' : '本地推荐画像',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.isEmpty
                          ? '打开推荐内容或使用“不感兴趣”后，知阅会在本机记录有限的兴趣信号。'
                          : '已记录 ${profile.totalEvents} 条信号 · 打开 ${profile.openedCount} · 反馈 ${profile.feedbackCount}',
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
                const Text(
                  '常见兴趣词',
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
                const Text(
                  '常见作者',
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
                '数据仅保存在本机，用于本地或混合推荐排序；不会上传行为明细。',
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
