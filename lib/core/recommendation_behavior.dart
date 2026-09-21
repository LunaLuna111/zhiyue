import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'app_log.dart';
import 'json_tools.dart';
import 'platform_cache.dart';

/// A bounded, on-device record of signals used by local recommendation.
/// Only a small card projection is persisted; full API responses and account
/// material never enter this store.
enum RecommendationBehaviorKind { opened, feedback }

class RecommendationBehaviorEvent {
  const RecommendationBehaviorEvent({
    required this.kind,
    required this.occurredAt,
    required this.type,
    required this.id,
    required this.title,
    required this.excerpt,
    required this.author,
    this.reason = '',
  });

  factory RecommendationBehaviorEvent.fromJson(Object? value) {
    if (value is! Map) throw const FormatException('推荐行为不是对象');
    final map = value.map((key, value) => MapEntry(key.toString(), value));
    final occurredAt = DateTime.tryParse(map['occurred_at']?.toString() ?? '');
    if (occurredAt == null) throw const FormatException('推荐行为时间无效');
    final kind = RecommendationBehaviorKind.values.firstWhere(
      (candidate) => candidate.name == map['kind'],
      orElse: () => RecommendationBehaviorKind.opened,
    );
    return RecommendationBehaviorEvent(
      kind: kind,
      occurredAt: occurredAt,
      type: _bounded(map['type']?.toString() ?? '', 40),
      id: _bounded(map['id']?.toString() ?? '', 160),
      title: _bounded(map['title']?.toString() ?? '', 240),
      excerpt: _bounded(map['excerpt']?.toString() ?? '', 600),
      author: _bounded(map['author']?.toString() ?? '', 120),
      reason: _bounded(map['reason']?.toString() ?? '', 120),
    );
  }

  final RecommendationBehaviorKind kind;
  final DateTime occurredAt;
  final String type;
  final String id;
  final String title;
  final String excerpt;
  final String author;
  final String reason;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
    'type': type,
    'id': id,
    'title': title,
    'excerpt': excerpt,
    'author': author,
    if (reason.isNotEmpty) 'reason': reason,
  };

  String get searchText => [title, excerpt, author].join(' ');

  static String _bounded(String value, int maximum) =>
      value.length <= maximum ? value : value.substring(0, maximum);
}

class RecommendationBehaviorProfile {
  const RecommendationBehaviorProfile({
    required this.totalEvents,
    required this.openedCount,
    required this.feedbackCount,
    required this.topTopics,
    required this.topAuthors,
    required this.signalDocuments,
  });

  const RecommendationBehaviorProfile.empty()
    : totalEvents = 0,
      openedCount = 0,
      feedbackCount = 0,
      topTopics = const <MapEntry<String, int>>[],
      topAuthors = const <MapEntry<String, int>>[],
      signalDocuments = const <String>[];

  final int totalEvents;
  final int openedCount;
  final int feedbackCount;
  final List<MapEntry<String, int>> topTopics;
  final List<MapEntry<String, int>> topAuthors;
  final List<String> signalDocuments;

  bool get isEmpty => totalEvents == 0;

  /// Explains only an actual token overlap with a previously opened card.
  String explanationFor(Map<String, dynamic> row) {
    final rowTokens = _behaviorTokens(_rowText(row));
    if (rowTokens.isEmpty) return '';
    for (final document in signalDocuments) {
      if (rowTokens.intersection(_behaviorTokens(document)).isEmpty) continue;
      final sample = document
          .trim()
          .split(RegExp(r'\s+'))
          .firstWhere((part) => part.trim().isNotEmpty, orElse: () => '');
      final label = sample.length > 18 ? '${sample.substring(0, 18)}…' : sample;
      return label.isEmpty ? '本地推荐' : '本地推荐 · 你看过 $label';
    }
    return '';
  }

  static String _rowText(Map<String, dynamic> row) {
    final object = unwrapObject(row);
    return [
      titleOf(row),
      subtitleOf(row),
      authorNameOf(row),
      plainText(row['excerpt']),
      titleOf(object),
      subtitleOf(object),
      authorNameOf(object),
    ].where((value) => value.trim().isNotEmpty).join(' ');
  }
}

/// Idempotent, serialized local behavior storage used by local/hybrid feeds.
class RecommendationBehaviorStore extends ChangeNotifier {
  RecommendationBehaviorStore._();

  static final instance = RecommendationBehaviorStore._();
  static const _cacheKey = 'zh_recommendation_behavior_v1';
  static const _maximumEvents = 240;

  final _cache = ZhPlatformCache.instance;
  final _events = <RecommendationBehaviorEvent>[];
  Future<void>? _loading;
  Future<void> _writing = Future<void>.value();
  bool _loaded = false;
  RecommendationBehaviorProfile? _profileCache;

  RecommendationBehaviorProfile get profile {
    final cached = _profileCache;
    if (cached != null) return cached;
    if (_events.isEmpty) {
      return _profileCache = const RecommendationBehaviorProfile.empty();
    }
    final topics = <String, int>{};
    final authors = <String, int>{};
    final documents = <String>[];
    var opened = 0;
    var feedback = 0;
    for (final event in _events) {
      final weight = event.kind == RecommendationBehaviorKind.opened ? 1 : 2;
      if (event.kind == RecommendationBehaviorKind.opened) {
        opened += 1;
      } else {
        feedback += 1;
      }
      for (final token in _behaviorTokens(event.title)) {
        topics[token] = (topics[token] ?? 0) + weight;
      }
      for (final token in _behaviorTokens(event.excerpt)) {
        topics[token] = (topics[token] ?? 0) + weight;
      }
      final author = event.author.trim();
      if (author.isNotEmpty) authors[author] = (authors[author] ?? 0) + weight;
      if (event.searchText.trim().isNotEmpty) documents.add(event.searchText);
    }
    final sortedTopics = topics.entries.toList()
      ..sort((left, right) {
        final score = right.value.compareTo(left.value);
        return score == 0 ? left.key.compareTo(right.key) : score;
      });
    final sortedAuthors = authors.entries.toList()
      ..sort((left, right) {
        final score = right.value.compareTo(left.value);
        return score == 0 ? left.key.compareTo(right.key) : score;
      });
    return _profileCache = RecommendationBehaviorProfile(
      totalEvents: _events.length,
      openedCount: opened,
      feedbackCount: feedback,
      topTopics: List.unmodifiable(sortedTopics.take(12)),
      topAuthors: List.unmodifiable(sortedAuthors.take(8)),
      signalDocuments: List.unmodifiable(documents.reversed.take(80)),
    );
  }

  Future<void> load() {
    if (_loaded) return Future<void>.value();
    final existing = _loading;
    if (existing != null) return existing;
    final future = _loadOnce();
    _loading = future;
    return future.whenComplete(() {
      if (identical(_loading, future)) _loading = null;
    });
  }

  Future<void> _loadOnce() async {
    try {
      final encoded = await _cache.read(_cacheKey);
      if (encoded != null && encoded.isNotEmpty) {
        final decoded = jsonDecode(encoded);
        if (decoded is List) {
          for (final item in decoded) {
            try {
              _events.add(RecommendationBehaviorEvent.fromJson(item));
            } on Object {
              // Retain valid rows when an older build contains one bad row.
            }
          }
          if (_events.length > _maximumEvents) {
            _events.removeRange(0, _events.length - _maximumEvents);
          }
        }
      }
    } on Object catch (error, stackTrace) {
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '本地推荐行为读取失败，使用空画像',
          category: AppLogCategory.app,
        ),
      );
    } finally {
      _profileCache = null;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> recordOpened(Map<String, dynamic> row) => _record(
    RecommendationBehaviorEvent(
      kind: RecommendationBehaviorKind.opened,
      occurredAt: DateTime.now().toUtc(),
      type: _bounded(typeOf(row), 40),
      id: _bounded(idOf(row), 160),
      title: _bounded(titleOf(row), 240),
      excerpt: _bounded(subtitleOf(row), 600),
      author: _bounded(authorNameOf(row), 120),
    ),
  );

  Future<void> recordFeedback(
    Map<String, dynamic> row, {
    required String reason,
  }) => _record(
    RecommendationBehaviorEvent(
      kind: RecommendationBehaviorKind.feedback,
      occurredAt: DateTime.now().toUtc(),
      type: _bounded(typeOf(row), 40),
      id: _bounded(idOf(row), 160),
      title: _bounded(titleOf(row), 240),
      excerpt: _bounded(subtitleOf(row), 600),
      author: _bounded(authorNameOf(row), 120),
      reason: _bounded(reason, 120),
    ),
  );

  Future<void> _record(RecommendationBehaviorEvent event) async {
    await load();
    _events.add(event);
    while (_events.length > _maximumEvents) {
      _events.removeAt(0);
    }
    _profileCache = null;
    notifyListeners();
    _writing = _writing.then((_) async {
      try {
        await _cache.write(
          _cacheKey,
          jsonEncode(_events.map((item) => item.toJson()).toList()),
        );
      } on Object catch (error, stackTrace) {
        unawaited(
          AppLogStore.instance.recordError(
            error,
            stackTrace,
            message: '本地推荐行为保存失败',
            category: AppLogCategory.app,
          ),
        );
      }
    });
    await _writing;
  }

  Future<void> clear() async {
    await load();
    _events.clear();
    _profileCache = null;
    notifyListeners();
    await _cache.remove(_cacheKey);
  }

  static String _bounded(String value, int maximum) =>
      value.length <= maximum ? value : value.substring(0, maximum);
}

Set<String> _behaviorTokens(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return const <String>{};
  return {
    for (final match in RegExp(
      r'[\u4e00-\u9fff]|[a-z0-9]{2,}',
    ).allMatches(normalized))
      match.group(0)!,
  };
}
