import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'platform_cache.dart';

/// A compact, privacy-preserving local summary of completed content-filter
/// actions.  It stores labels and counters only; article bodies and account
/// credentials never enter this cache.
class ContentFilterStats {
  const ContentFilterStats({
    this.totalActions = 0,
    this.removedItems = 0,
    this.reasonCounts = const <String, int>{},
    this.actionCounts = const <String, int>{},
    this.lastReason = '',
    this.lastAction = '',
    this.lastAt,
  });

  final int totalActions;
  final int removedItems;
  final Map<String, int> reasonCounts;
  final Map<String, int> actionCounts;
  final String lastReason;
  final String lastAction;
  final DateTime? lastAt;

  int get distinctReasons => reasonCounts.length;

  List<MapEntry<String, int>> get orderedReasons {
    final entries = reasonCounts.entries.toList(growable: false);
    entries.sort((left, right) {
      final count = right.value.compareTo(left.value);
      return count == 0 ? left.key.compareTo(right.key) : count;
    });
    return entries;
  }

  ContentFilterStats record({
    required String reason,
    required String action,
    required bool removed,
    DateTime? at,
  }) {
    final normalizedReason = _bounded(reason, 80);
    final normalizedAction = _bounded(action, 120);
    final nextReasons = <String, int>{...reasonCounts};
    final nextActions = <String, int>{...actionCounts};
    if (normalizedReason.isNotEmpty) {
      nextReasons[normalizedReason] = (nextReasons[normalizedReason] ?? 0) + 1;
    }
    if (normalizedAction.isNotEmpty) {
      nextActions[normalizedAction] = (nextActions[normalizedAction] ?? 0) + 1;
    }
    return ContentFilterStats(
      totalActions: (totalActions + 1).clamp(0, 10000).toInt(),
      removedItems: (removedItems + (removed ? 1 : 0)).clamp(0, 10000).toInt(),
      reasonCounts: _boundedCounts(nextReasons),
      actionCounts: _boundedCounts(nextActions),
      lastReason: normalizedReason,
      lastAction: normalizedAction,
      lastAt: at ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_actions': totalActions,
    'removed_items': removedItems,
    'reason_counts': reasonCounts,
    'action_counts': actionCounts,
    'last_reason': lastReason,
    'last_action': lastAction,
    if (lastAt != null) 'last_at': lastAt!.toUtc().toIso8601String(),
  };

  static ContentFilterStats fromJson(Object? value) {
    if (value is! Map) return const ContentFilterStats();
    final map = value.map((key, value) => MapEntry(key.toString(), value));
    return ContentFilterStats(
      totalActions: _boundedInt(map['total_actions']),
      removedItems: _boundedInt(map['removed_items']),
      reasonCounts: _readCounts(map['reason_counts']),
      actionCounts: _readCounts(map['action_counts']),
      lastReason: _bounded(_text(map['last_reason']), 80),
      lastAction: _bounded(_text(map['last_action']), 120),
      lastAt: DateTime.tryParse(_text(map['last_at']))?.toLocal(),
    );
  }
}

class ContentFilterStatsStore extends ChangeNotifier {
  ContentFilterStatsStore._();

  static final instance = ContentFilterStatsStore._();
  static const _cacheKey = 'zh_content_filter_stats_v1';

  ContentFilterStats _stats = const ContentFilterStats();
  Future<ContentFilterStats>? _loading;
  Future<void> _mutation = Future<void>.value();
  bool _loaded = false;

  ContentFilterStats get stats => _stats;
  bool get isLoaded => _loaded;

  Future<ContentFilterStats> load() {
    if (_loaded) return Future<ContentFilterStats>.value(_stats);
    final existing = _loading;
    if (existing != null) return existing;
    final request = ZhPlatformCache.instance.read(_cacheKey).then((encoded) {
      if (encoded != null && encoded.isNotEmpty) {
        try {
          _stats = ContentFilterStats.fromJson(jsonDecode(encoded));
        } catch (_) {
          _stats = const ContentFilterStats();
        }
      }
      _loaded = true;
      notifyListeners();
      return _stats;
    });
    _loading = request;
    return request.whenComplete(() => _loading = null);
  }

  Future<void> record({
    required String reason,
    required String action,
    required bool removed,
  }) {
    final operation = _mutation.then((_) async {
      await load();
      _stats = _stats.record(reason: reason, action: action, removed: removed);
      notifyListeners();
      await ZhPlatformCache.instance.write(
        _cacheKey,
        jsonEncode(_stats.toJson()),
      );
    });
    _mutation = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> clear() {
    final operation = _mutation.then((_) async {
      _stats = const ContentFilterStats();
      _loaded = true;
      notifyListeners();
      await ZhPlatformCache.instance.remove(_cacheKey);
    });
    _mutation = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }
}

Map<String, int> _readCounts(Object? value) {
  if (value is! Map) return const <String, int>{};
  final counts = <String, int>{};
  for (final entry in value.entries) {
    final key = _bounded(entry.key.toString().trim(), 120);
    final count = _boundedInt(entry.value);
    if (key.isNotEmpty && count > 0) counts[key] = count;
  }
  return _boundedCounts(counts);
}

Map<String, int> _boundedCounts(Map<String, int> source) {
  final entries = source.entries.toList(growable: false)
    ..sort((left, right) => right.value.compareTo(left.value));
  return Map.unmodifiable({
    for (final entry in entries.take(40))
      entry.key: entry.value.clamp(1, 10000).toInt(),
  });
}

int _boundedInt(Object? value) {
  final parsed = value is num
      ? value.round()
      : int.tryParse(value?.toString() ?? '') ?? 0;
  return parsed.clamp(0, 10000).toInt();
}

String _text(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text == 'null' ? '' : text;
}

String _bounded(String value, int length) =>
    value.length <= length ? value : value.substring(0, length);
