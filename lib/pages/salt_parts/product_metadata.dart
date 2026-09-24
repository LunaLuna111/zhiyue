part of '../salt_page.dart';

/// Returns the human-readable text carried by a Salt catalog metadata value.
/// The web gateway has emitted both strings and small `{text/content/value}`
/// objects over time; list values are the native description-fragment shape.
@visibleForTesting
String saltProductValueText(Object? value) {
  if (value == null) return '';
  if (value is List) {
    return value
        .map(saltProductValueText)
        .where((item) => item.isNotEmpty)
        .join('\n');
  }
  if (value is Map) {
    for (final key in const [
      'text',
      'content',
      'value',
      'name',
      'title',
      'description',
      'summary',
      'url',
    ]) {
      final text = saltProductValueText(value[key]);
      if (text.isNotEmpty) return text;
    }
    return '';
  }
  return plainText(value);
}

/// Normalizes the work introduction across the catalog and discovery-card
/// contracts.  Native `/catalog/{well_id}` uses `parent.introduction`, while
/// older cached cards may only expose `description`, `summary`, or fragments.
@visibleForTesting
String saltProductIntroduction(Object? value) {
  final map = _saltMap(value);
  if (map == null) return saltProductValueText(value);
  for (final key in const [
    'introduction',
    'description',
    'summary',
    'synopsis',
    'brief',
    'excerpt',
    'description_list',
    'intro',
    'content_abstract',
  ]) {
    final text = saltProductValueText(map[key]);
    if (text.isNotEmpty) return text;
  }
  for (final key in const [
    'parent',
    'details',
    'work',
    'product',
    'content',
    'metadata',
    'data',
  ]) {
    final text = saltProductIntroduction(map[key]);
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _saltMetadataText(Map<String, dynamic>? value, List<String> keys) {
  if (value == null) return '';
  for (final key in keys) {
    final text = saltProductValueText(value[key]);
    if (text.isNotEmpty) return text;
  }
  return '';
}

List<String> _saltMetadataLabels(
  Map<String, dynamic>? value,
  List<String> keys,
) {
  if (value == null) return const [];
  final labels = <String>[];
  for (final key in keys) {
    final raw = value[key];
    if (raw is! List) {
      final text = saltProductValueText(raw);
      if (text.isNotEmpty && !labels.contains(text)) labels.add(text);
      continue;
    }
    for (final item in raw) {
      final map = _saltMap(item);
      final text = saltProductValueText(
        map?['value'] ?? map?['text'] ?? map?['name'] ?? map?['title'] ?? item,
      );
      if (text.isNotEmpty && !labels.contains(text)) labels.add(text);
      if (labels.length >= 4) return labels;
    }
  }
  return labels;
}

String _saltPersonField(Object? value, List<String> keys, [int depth = 0]) {
  if (depth > 5) return '';
  if (value is List) {
    for (final item in value) {
      final text = _saltPersonField(item, keys, depth + 1);
      if (text.isNotEmpty) return text;
    }
    return '';
  }
  final map = _saltMap(value);
  if (map == null) return '';
  for (final key in keys) {
    final text = saltProductValueText(map[key]);
    if (text.isNotEmpty) return text;
  }
  for (final key in const [
    'user',
    'profile',
    'author',
    'author_info',
    'user_info',
    'user_profile',
    'creator',
    'creator_info',
    'owner',
    'producer',
    'producer_info',
    'data',
  ]) {
    final text = _saltPersonField(map[key], keys, depth + 1);
    if (text.isNotEmpty) return text;
  }
  return '';
}

Map<String, dynamic>? _saltMergePersonMaps(Iterable<Object?> values) {
  final merged = <String, dynamic>{};
  void visit(Object? value, int depth) {
    if (value == null || depth > 4) return;
    if (value is List) {
      for (final item in value) {
        visit(item, depth + 1);
      }
      return;
    }
    final map = _saltMap(value);
    if (map == null) return;
    for (final entry in map.entries) {
      if (saltProductValueText(merged[entry.key]).isEmpty &&
          saltProductValueText(entry.value).isNotEmpty) {
        merged[entry.key] = entry.value;
      }
    }
    for (final key in const [
      'user',
      'profile',
      'author',
      'author_info',
      'user_info',
      'user_profile',
      'creator',
      'creator_info',
      'owner',
      'producer',
      'producer_info',
    ]) {
      visit(map[key], depth + 1);
    }
  }

  for (final value in values) {
    visit(value, 0);
  }
  return merged.isEmpty ? null : merged;
}

int? _saltMetadataInt(Map<String, dynamic>? value, List<String> keys) {
  if (value == null) return null;
  for (final key in keys) {
    final raw = value[key];
    if (raw is num) return raw.round();
    final parsed = int.tryParse(saltProductValueText(raw).replaceAll(',', ''));
    if (parsed != null) return parsed;
  }
  return null;
}

int? _saltPositiveMetadataInt(Map<String, dynamic>? value, List<String> keys) {
  final result = _saltMetadataInt(value, keys);
  return result != null && result > 0 ? result : null;
}

int? _saltCountFromText(String value) {
  final match = RegExp(r'(?:共|总计|total)\s*([0-9][0-9,]*)').firstMatch(value);
  if (match == null) return null;
  return int.tryParse(match.group(1)!.replaceAll(',', ''));
}

String _saltMetricValue(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return '';
  return normalized.replaceFirst(RegExp(r'^(?:点赞|收藏|评论|浏览)\s*'), '').trim();
}

String _saltProductProgressText({
  required String explicit,
  required String completion,
  required int? updatedTo,
  required int? total,
  AppLocalizations? l10n,
}) {
  final direct = explicit.trim();
  if (direct.isNotEmpty) return direct;
  if ((completion == '已完结' || completion == l10n?.storyFinished) &&
      total != null) {
    return l10n?.saltFinishedWithCount(total) ?? '已完结，共 $total 节';
  }
  if (updatedTo != null) {
    return l10n?.saltUpdatedTo(updatedTo) ?? '已更新至第 $updatedTo 节';
  }
  if (completion.isNotEmpty) return completion;
  if (total != null) return l10n?.saltChapterCount(total) ?? '共 $total 节';
  return '';
}

bool? _saltMetadataBool(Map<String, dynamic>? value, List<String> keys) {
  if (value == null) return null;
  for (final key in keys) {
    final raw = value[key];
    if (raw is bool) return raw;
    final normalized = plainText(raw).toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

String _saltCompletionLabel(
  Map<String, dynamic>? parent, [
  AppLocalizations? l10n,
]) {
  final explicit = _saltMetadataText(parent, const [
    'completion_text',
    'finish_status_text',
    'status_text',
    'status',
    'content_status',
  ]);
  if (explicit.isNotEmpty) return explicit;
  final finished = _saltMetadataBool(parent, const [
    'is_finished',
    'is_finish',
    'finished',
    'completed',
  ]);
  if (finished == true) return l10n?.storyFinished ?? '已完结';
  if (finished == false) return l10n?.storyOngoing ?? '连载中';
  return '';
}

String _saltTypeLabel(Map<String, dynamic>? parent, [AppLocalizations? l10n]) {
  final explicit = _saltMetadataText(parent, const [
    'type_name',
    'property_type_name',
  ]);
  if (explicit.isNotEmpty) return explicit;
  if (_saltMetadataBool(parent, const ['is_long', 'is_long_story']) == true) {
    return l10n?.storyLong ?? '长篇';
  }
  final propertyType = _saltMetadataText(parent, const [
    'property_type',
    'business_type',
    'content_type',
    'type_en',
  ]).toLowerCase();
  return switch (propertyType) {
    'long_story' || 'mid_long' || 'mid_long_story' => l10n?.storyLong ?? '长篇',
    'short_story' => l10n?.storyShort ?? '短篇',
    'audio_story' => l10n?.storyAudioBook ?? '有声书',
    _ => '',
  };
}
