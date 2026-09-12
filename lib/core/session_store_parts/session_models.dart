part of '../session_store.dart';

enum ReadingTextSize { compact, standard, large }

extension ReadingTextSizeValue on ReadingTextSize {
  double get scale => switch (this) {
    ReadingTextSize.compact => 0.92,
    ReadingTextSize.standard => 1,
    ReadingTextSize.large => 1.12,
  };
}

enum AppStartupPage { recommend, bookshelf }

enum HomeFeedChannel { following, recommend, hot, story }

extension HomeFeedChannelValue on HomeFeedChannel {
  String get label => switch (this) {
    HomeFeedChannel.following => '关注',
    HomeFeedChannel.recommend => '推荐',
    HomeFeedChannel.hot => '热榜',
    HomeFeedChannel.story => '故事',
  };
}

enum FeedDensity { comfortable, compact }

class BrowsingHistoryEntry {
  const BrowsingHistoryEntry({
    required this.type,
    required this.id,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.visitedAt,
    this.questionId = '',
    this.questionTitle = '',
  });

  final String type;
  final String id;
  final String title;
  final String excerpt;
  final String author;
  final DateTime visitedAt;
  final String questionId;
  final String questionTitle;

  String get identity => '$type:$id';

  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'title': title,
    'excerpt': excerpt,
    'author': author,
    'visited_at': visitedAt.toUtc().toIso8601String(),
    if (questionId.isNotEmpty)
      'question': {'id': questionId, 'title': questionTitle},
  };

  static BrowsingHistoryEntry? fromJson(Object? source) {
    if (source is! Map) return null;
    final value = source.map((key, value) => MapEntry(key.toString(), value));
    String text(String key, {int maxLength = 512}) {
      final result = value[key]?.toString().trim() ?? '';
      return result.length <= maxLength
          ? result
          : result.substring(0, maxLength);
    }

    final type = text('type', maxLength: 48);
    final id = text('id', maxLength: 256);
    final title = text('title');
    final visitedAt = DateTime.tryParse(text('visited_at', maxLength: 64));
    if (type.isEmpty || id.isEmpty || title.isEmpty || visitedAt == null) {
      return null;
    }
    var questionId = '';
    var questionTitle = '';
    final question = value['question'];
    if (question is Map) {
      questionId = question['id']?.toString().trim() ?? '';
      questionTitle = question['title']?.toString().trim() ?? '';
    }
    return BrowsingHistoryEntry(
      type: type,
      id: id,
      title: title,
      excerpt: text('excerpt', maxLength: 900),
      author: text('author', maxLength: 160),
      visitedAt: visitedAt.toLocal(),
      questionId: questionId,
      questionTitle: questionTitle,
    );
  }
}

enum ImageCachePreset { economy, standard, roomy }

extension ImageCachePresetValue on ImageCachePreset {
  int get maximumEntries => switch (this) {
    ImageCachePreset.economy => 120,
    ImageCachePreset.standard => 512,
    ImageCachePreset.roomy => 768,
  };

  int get maximumBytes => switch (this) {
    ImageCachePreset.economy => 48 * 1024 * 1024,
    ImageCachePreset.standard => 160 * 1024 * 1024,
    ImageCachePreset.roomy => 240 * 1024 * 1024,
  };
}
