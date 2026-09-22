part of '../search_page.dart';

bool _isSearchEntityType(String type) => const {
  'people',
  'member',
  'topic',
  'column',
  'publication',
  'ebook',
  'km_ebook',
  'live',
  'course',
  'special',
  'ring',
}.contains(type);

String _searchEntityImageOf(Map<String, dynamic> value) {
  final object = unwrapObject(value);
  final speakers = object['speakers'];
  Object? speakerAvatar;
  if (speakers is List && speakers.isNotEmpty && speakers.first is Map) {
    final speaker = speakers.first as Map;
    speakerAvatar = speaker['avatar_url'];
  }
  for (final candidate in [
    object['avatar_url'],
    object['app_image_path'],
    object['cover'],
    object['cover_url'],
    object['image_url'],
    speakerAvatar,
  ]) {
    final url = plainText(candidate);
    final uri = Uri.tryParse(url);
    if (uri != null &&
        uri.scheme == 'https' &&
        uri.userInfo.isEmpty &&
        !uri.hasPort) {
      return url;
    }
  }
  return '';
}

String _searchEntitySubtitleOf(Map<String, dynamic> value) {
  final object = unwrapObject(value);
  final type = typeOf(value).replaceAll('search_', '');
  if (type == 'publication' || type == 'ebook' || type == 'km_ebook') {
    final authors = object['authors'];
    if (authors is List) {
      final names = authors.map(plainText).where((item) => item.isNotEmpty);
      if (names.isNotEmpty) return names.take(3).join('、');
    }
  }
  if (type == 'live' || type == 'course' || type == 'special') {
    final speakers = object['speakers'];
    if (speakers is List) {
      final names = speakers
          .whereType<Map>()
          .map((speaker) => plainText(speaker['name']))
          .where((item) => item.isNotEmpty);
      if (names.isNotEmpty) return names.take(3).join('、');
    }
    final subject = plainText(object['subject']);
    if (subject.isNotEmpty) return subject;
  }
  final author = authorNameOf(value);
  if (author.isNotEmpty) return author;
  return subtitleOf(value);
}

List<String> _searchEntityMetricsOf(Map<String, dynamic> value) {
  final object = unwrapObject(value);
  final items = <String>[];
  int? searchInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(plainText(raw));
  }

  void addCount(List<String> keys, String label) {
    for (final key in keys) {
      final count = searchInt(object[key]);
      if (count != null) {
        items.add('${compactCount(count)} $label');
        return;
      }
    }
  }

  final type = typeOf(value).replaceAll('search_', '');
  switch (type) {
    case 'people':
    case 'member':
      addCount(const ['follower_count', 'followers_count'], '关注者');
      addCount(const ['answer_count', 'answers_count'], '回答');
      break;
    case 'topic':
      addCount(const ['followers_count', 'follower_count'], '关注者');
      addCount(const ['questions_count', 'question_count'], '问题');
      break;
    case 'column':
      addCount(const ['articles_count', 'article_count'], '文章');
      addCount(const ['followers_count', 'follower_count'], '关注者');
      break;
    case 'publication':
    case 'ebook':
    case 'km_ebook':
      addCount(const ['voteup_count', 'vote_count'], '赞同');
      addCount(const ['comment_count'], '评论');
      break;
    case 'live':
    case 'course':
    case 'special':
      addCount(const ['live_count'], '场内容');
      final seats = object['seats'];
      if (seats is Map) {
        final taken = searchInt(seats['taken']);
        if (taken != null) items.add('${compactCount(taken)} 人参与');
      }
      break;
    case 'ring':
      addCount(const ['member_count', 'join_count', 'followers_count'], '成员');
      addCount(const ['post_count', 'club_post_count'], '讨论');
      break;
  }
  return items.take(2).toList(growable: false);
}

final _searchEntityStaticDataCache = Expando<_SearchEntityStaticData>(
  'search-entity-static-data',
);

class _SearchEntityStaticData {
  const _SearchEntityStaticData({
    required this.type,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.metrics,
    required this.date,
    required this.typeLabel,
  });

  factory _SearchEntityStaticData.from(Map<String, dynamic> value) {
    final metrics = ContentMetrics.from(value);
    return _SearchEntityStaticData(
      type: typeOf(value).replaceAll('search_', ''),
      image: _searchEntityImageOf(value),
      title: titleOf(value),
      subtitle: _searchEntitySubtitleOf(value),
      description: subtitleOf(value),
      metrics: _searchEntityMetricsOf(value),
      date: contentDateLabel(metrics),
      typeLabel: contentKindLabelOf(value),
    );
  }

  final String type;
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final List<String> metrics;
  final String date;
  final String typeLabel;
}

class _SearchEntityResultRow extends StatelessWidget {
  const _SearchEntityResultRow({
    required this.value,
    required this.onTap,
    this.compact = false,
  });

  final Map<String, dynamic> value;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final data = _searchEntityStaticDataCache[value] ??=
        _SearchEntityStaticData.from(value);
    final type = data.type;
    final image = data.image;
    final title = data.title;
    final subtitle = data.subtitle;
    final description = data.description;
    final metrics = data.metrics;
    final date = data.date;
    final circular = type == 'people' || type == 'member' || type == 'topic';
    return Material(
      color: ZhPalette.background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            15,
            compact ? 10 : 15,
            12,
            compact ? 10 : 15,
          ),
          decoration: compact
              ? null
              : const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: ZhPalette.border, width: .7),
                  ),
                ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (image.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(circular ? 99 : 7),
                  child: ZhihuImage.network(
                    image,
                    headers: zhihuImageRequestHeaders,
                    width: compact ? 48 : 56,
                    height: compact ? 48 : 56,
                    fit: BoxFit.cover,
                    cacheWidth: 168,
                    cacheHeight: 168,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title.isEmpty ? '未命名内容' : title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data.typeLabel,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: ZhPalette.subtleInk),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: ZhPalette.subtleInk,
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.mutedInk,
                        ),
                      ),
                    ],
                    if (description.isNotEmpty && description != subtitle) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
                        ),
                      ),
                    ],
                    if (metrics.isNotEmpty || date.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        [...metrics, if (date.isNotEmpty) date].join(' · '),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ZhPalette.subtleInk,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
