part of '../notifications_page.dart';

Map<String, dynamic> _stringMap(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

List<Map<String, dynamic>> notificationRows(Object? value) {
  final root = _stringMap(value);
  final data = root['data'];
  if (data is! List) return const [];
  return [
    for (final row in data)
      if (row is Map) _stringMap(row),
  ];
}

String notificationEntryNameOf(Map<String, dynamic> row) {
  for (final candidate in [row['noti_subtype'], row['id']]) {
    final value = plainText(candidate).replaceFirst('entry_', '');
    if (ZhihuApiClient.notificationEntryNames.contains(value)) return value;
  }
  final link = notificationTargetLink(row);
  final match = RegExp(r'/entry/([a-z_]+)').firstMatch(link);
  final value = match?.group(1) ?? '';
  return ZhihuApiClient.notificationEntryNames.contains(value) ? value : '';
}

List<Map<String, dynamic>> notificationHeaderEntries(
  Object? value, [
  AppLocalizations? l10n,
]) {
  final strings = l10n ?? AppLocalizationsZh();
  final root = _stringMap(value);
  final byName = <String, Map<String, dynamic>>{};
  final head = root['head'];
  if (head is List) {
    for (final item in head) {
      final row = _stringMap(item);
      final name = notificationEntryNameOf(row);
      if (name.isNotEmpty) byName[name] = row;
    }
  }
  final labels = {
    'comment': strings.notificationCommentCategory,
    'like': strings.notificationLikeCategory,
    'favorite': strings.notificationFavoriteCategory,
    'follow': strings.notificationFollowCategory,
  };
  return [
    for (final name in const ['comment', 'like', 'favorite', 'follow'])
      byName[name] ??
          <String, dynamic>{
            'id': 'entry_$name',
            'noti_subtype': 'entry_$name',
            'content': {'title': labels[name]},
            'unread_count': 0,
            'is_read': true,
          },
  ];
}

Map<String, dynamic>? notificationInviteEntry(
  Object? value, [
  AppLocalizations? l10n,
]) {
  final strings = l10n ?? AppLocalizationsZh();
  final fallback = <String, dynamic>{
    'id': 'entry_invite',
    'noti_subtype': 'entry_invite',
    'content': {'title': strings.notificationInvite},
    'unread_count': 0,
    'is_read': true,
  };
  final root = _stringMap(value);
  final head = root['head'];
  if (head is! List) return fallback;
  for (final item in head) {
    final row = _stringMap(item);
    if (notificationEntryNameOf(row) == 'invite') return row;
  }
  return fallback;
}

String notificationTargetLink(Map<String, dynamic> row) {
  for (final source in [row['content'], row['target_source'], row['head']]) {
    final link = plainText(_stringMap(source)['target_link']);
    if (link.isNotEmpty) return link;
  }
  return '';
}

String notificationMessageSenderId(Map<String, dynamic> row) {
  if (plainText(row['noti_type']) != 'message') return '';
  final link = notificationTargetLink(row);
  final match = RegExp(r'/inbox/([A-Za-z0-9._-]+)').firstMatch(link);
  if (match != null) return match.group(1) ?? '';
  return plainText(_stringMap(_stringMap(row['head'])['author'])['id']);
}

Map<String, dynamic>? notificationTargetObject(Map<String, dynamic> row) {
  for (final candidate in [
    row['target'],
    _stringMap(row['extra_action'])['data'],
  ]) {
    final value = _stringMap(candidate);
    if (value.isNotEmpty && idOf(value).isNotEmpty) return value;
  }
  final link = notificationTargetLink(row);
  final answer = RegExp(r'/answer/(\d+)').firstMatch(link);
  if (answer != null) return {'type': 'answer', 'id': answer.group(1)};
  final question = RegExp(r'/question/(\d+)').firstMatch(link);
  if (question != null) {
    return {
      'type': 'question',
      'id': question.group(1),
      'title': notificationText(row),
    };
  }
  final article = RegExp(r'(?:zhuanlan\.zhihu\.com)?/p/(\d+)').firstMatch(link);
  if (article != null) return {'type': 'article', 'id': article.group(1)};
  final people = RegExp(r'/people/([A-Za-z0-9._-]+)').firstMatch(link);
  if (people != null) {
    return {
      'type': 'people',
      'id': people.group(1),
      'url_token': people.group(1),
    };
  }
  return null;
}

String notificationTitle(Map<String, dynamic> row) {
  final content = _stringMap(row['content']);
  return plainText(content['title']).isNotEmpty
      ? plainText(content['title'])
      : plainText(row['detail_title']);
}

String notificationText(Map<String, dynamic> row) {
  final content = _stringMap(row['content']);
  for (final value in [
    content['text'],
    content['abstract_text'],
    _stringMap(row['target_source'])['text'],
  ]) {
    final text = plainText(value).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

String notificationAvatarUrl(Map<String, dynamic> row) {
  final head = _stringMap(row['head']);
  final direct = plainText(head['avatar_url']);
  if (direct.isNotEmpty) return direct;
  final urls = head['avatar_urls'];
  if (urls is List && urls.isNotEmpty) return plainText(urls.first);
  return plainText(_stringMap(head['author'])['avatar_url']);
}

int _intValue(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  _ => int.tryParse(plainText(value)) ?? 0,
};

String _timestampLabel(Object? value) {
  final seconds = _intValue(value);
  if (seconds <= 0) return '';
  final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  final now = DateTime.now();
  String two(int number) => number.toString().padLeft(2, '0');
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return '${two(date.hour)}:${two(date.minute)}';
  }
  if (date.year == now.year) return '${two(date.month)}-${two(date.day)}';
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

bool _hasAccountContext(ZhihuApiClient api) =>
    api.session.hasAuthorization && api.session.sessionKind != 'guest';
