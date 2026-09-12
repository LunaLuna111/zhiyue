part of '../core_test.dart';

void registerSecondPriorityTests() {
  group('second priority content strategies', () {
    test('local recommendation keeps stable order for equal affinity', () {
      final rows = <Map<String, dynamic>>[
        {'type': 'answer', 'id': '1', 'title': 'Flutter 编程实践'},
        {'type': 'answer', 'id': '2', 'title': '旅行摄影记录'},
        {'type': 'answer', 'id': '3', 'title': 'Flutter 性能优化'},
      ];
      final ranked = rankHomeFeedRows(
        rows,
        mode: RecommendationMode.local,
        localSignals: const ['Flutter 开发'],
      );
      expect(ranked.map((row) => row['id']), ['1', '3', '2']);
      expect(
        rankHomeFeedRows(
          rows,
          mode: RecommendationMode.server,
          localSignals: const ['Flutter'],
        ),
        equals(rows),
      );
    });

    test('content filter stats preserves reasons and bounded counters', () {
      var stats = const ContentFilterStats();
      stats = stats.record(
        reason: '不喜欢该内容',
        action: 'zhihu://uninterest_feed',
        removed: true,
      );
      stats = stats.record(reason: '内容质量不佳', action: 'quality', removed: false);
      final restored = ContentFilterStats.fromJson(stats.toJson());
      expect(restored.totalActions, 2);
      expect(restored.removedItems, 1);
      expect(restored.reasonCounts['不喜欢该内容'], 1);
      expect(restored.lastReason, '内容质量不佳');
      expect(restored.orderedReasons.first.key, '不喜欢该内容');
    });
  });
}
