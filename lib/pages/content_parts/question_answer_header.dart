part of '../content_pages.dart';

class _QuestionTopic {
  const _QuestionTopic({required this.label, required this.object});

  final String label;
  final Map<String, dynamic> object;

  String get id => idOf(object);
}

List<_QuestionTopic> _questionTopics(Map<String, dynamic>? question) {
  if (question == null) return const [];
  final candidates = _questionCandidates(question);
  final topics = <_QuestionTopic>[];
  final seen = <String>{};
  for (final candidate in candidates) {
    for (final key in const ['topics', 'topic', 'tags', 'topic_list']) {
      final raw = candidate[key];
      final items = _topicItems(raw);
      for (final item in items) {
        final object = item is Map
            ? item.map((key, value) => MapEntry(key.toString(), value))
            : <String, dynamic>{'name': plainText(item)};
        final label = plainText(
          object['name'] ??
              object['title'] ??
              object['text'] ??
              object['label'],
        );
        if (label.isEmpty) continue;
        final id = idOf(object);
        final identity = id.isEmpty ? 'label:$label' : 'id:$id';
        if (!seen.add(identity)) continue;
        final target = <String, dynamic>{...object, 'type': 'topic'};
        if (id.isNotEmpty) target['id'] = id;
        topics.add(_QuestionTopic(label: label, object: target));
        if (topics.length == 8) return List.unmodifiable(topics);
      }
    }
  }
  return List.unmodifiable(topics);
}

Iterable<Object?> _topicItems(Object? raw) {
  if (raw is List) return raw;
  if (raw is Map) {
    for (final key in const ['data', 'items', 'list', 'topics', 'tags']) {
      final nested = raw[key];
      if (nested is List) return nested;
    }
    return [raw];
  }
  return raw == null ? const [] : [raw];
}

Map<String, dynamic>? _questionMap(Object? value) {
  if (value is! Map) return null;
  return value.map((key, value) => MapEntry(key.toString(), value));
}

List<Map<String, dynamic>> _questionCandidates(Map<String, dynamic> question) {
  final candidates = <Map<String, dynamic>>[question];
  for (final key in const ['question', 'detail', 'data']) {
    final nested = _questionMap(question[key]);
    if (nested != null) candidates.add(nested);
  }
  return candidates;
}

String _questionRichText(Map<String, dynamic> question) {
  final candidates = _questionCandidates(question);
  const keys = [
    'detail',
    'description',
    'content',
    'body',
    'question_text',
    'detail_text',
    'content_html',
    'html',
    'excerpt',
  ];
  for (final candidate in candidates) {
    for (final key in keys) {
      final raw = candidate[key];
      if (raw is String && raw.trim().isNotEmpty) return raw.trim();
      final nested = _questionMap(raw);
      if (nested != null) {
        for (final nestedKey in const [
          'plain_text',
          'text',
          'html',
          'content',
        ]) {
          final text = plainText(nested[nestedKey]);
          if (text.isNotEmpty) return nested[nestedKey].toString();
        }
      }
    }
  }
  return '';
}

class _ExpandableQuestionSummary extends StatefulWidget {
  const _ExpandableQuestionSummary({required this.summary});

  final String summary;

  @override
  State<_ExpandableQuestionSummary> createState() =>
      _ExpandableQuestionSummaryState();
}

class _ExpandableQuestionSummaryState
    extends State<_ExpandableQuestionSummary> {
  static const _collapsedCharacterLimit = 150;
  var _expanded = false;

  bool get _canExpand {
    final summary = widget.summary;
    return summary.runes.length > _collapsedCharacterLimit ||
        summary.split('\n').length > 3;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: ZhPalette.mutedInk,
      fontSize: 14,
      height: 1.55,
    );
    return Semantics(
      button: _canExpand,
      expanded: _expanded,
      label: _canExpand ? (_expanded ? '收起问题详情' : '展开问题详情') : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const Key('question-header-summary-tap-target'),
            onTap: _canExpand
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(6),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: Text(
                widget.summary,
                key: const ValueKey('question-header-summary'),
                maxLines: _expanded ? null : 3,
                overflow: _expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
          ),
          if (_canExpand)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('question-header-summary-toggle'),
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: const Color(0xFF1677FF),
                ),
                child: Text(_expanded ? '收起' : '展开全文'),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestionTopicChip extends StatelessWidget {
  const _QuestionTopicChip({required this.topic, this.onTap});

  final _QuestionTopic topic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        border: Border.all(color: const Color(0xFFE3E5E8)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        topic.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: ZhPalette.mutedInk,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      label: '打开话题 ${topic.label}',
      child: InkWell(
        key: ValueKey('question-topic-${topic.label}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: chip,
      ),
    );
  }
}

class _QuestionAnswerSortBar extends StatelessWidget {
  const _QuestionAnswerSortBar({
    required this.sort,
    required this.onChanged,
    this.answerCount,
  });

  final _QuestionAnswerSort sort;
  final ValueChanged<_QuestionAnswerSort> onChanged;
  final int? answerCount;

  @override
  Widget build(BuildContext context) {
    final answerLabel = answerCount == null
        ? '全部回答'
        : '全部内容 ${compactCount(answerCount!)}';
    return Container(
      key: const ValueKey('question-answer-sort-bar'),
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: ZhPalette.border, width: .7),
          bottom: BorderSide(color: ZhPalette.border, width: .7),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            height: 42,
            child: ZhLiquidGlassSegmentedTabs(
              key: const ValueKey('question-answer-sort-control'),
              labels: const ['默认', '最新'],
              selectedIndex: sort == _QuestionAnswerSort.latest ? 1 : 0,
              onSelected: (index) => onChanged(
                index == 1
                    ? _QuestionAnswerSort.latest
                    : _QuestionAnswerSort.defaultOrder,
              ),
              semanticPrefix: '回答排序：',
              height: 40,
              labelFontSize: 14,
              plainSelection: true,
              shadowElevation: 0,
            ),
          ),
          const Spacer(),
          Text(
            answerLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ZhPalette.subtleInk,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionHeaderAuthor extends StatelessWidget {
  const _QuestionHeaderAuthor({required this.question, required this.api});

  final Map<String, dynamic> question;
  final ZhihuApiClient api;

  @override
  Widget build(BuildContext context) {
    final name = authorNameOf(question);
    final headline = authorHeadlineOf(question);
    final avatar = authorAvatarOf(question);
    final memberId = authorIdOf(question);
    final fallback = name.isEmpty ? '知' : name.characters.first;
    void openAuthor() {
      if (memberId.isEmpty) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UserProfileDetailPage(api: api, memberId: memberId),
        ),
      );
    }

    return Semantics(
      button: memberId.isNotEmpty,
      label: '提问者 $name',
      child: InkWell(
        key: const Key('question-header-author'),
        onTap: memberId.isEmpty ? null : openAuthor,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              _AuthorAvatar(imageUrl: avatar, fallback: fallback, size: 32),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (headline.isNotEmpty)
                      Text(
                        headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const ZhPill(label: '提问者', compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionHeaderPresentation {
  const _QuestionHeaderPresentation({
    required this.summary,
    required this.media,
  });

  factory _QuestionHeaderPresentation.from(Map<String, dynamic> question) {
    final videos = contentVideosOf(question);
    final detail = _questionRichText(question);
    final blocks = detail.isEmpty
        ? const <RichContentBlock>[]
        : richContentBlocks(detail, videos: videos);
    var summary = blocks
        .where((block) => !block.isImage && !block.isVideo)
        .map((block) => block.text)
        .where((text) => text.isNotEmpty)
        .join('\n\n');
    if (summary.isEmpty) summary = subtitleOf(question);
    if (summary.isEmpty && detail.isNotEmpty) summary = plainText(detail);

    RichContentBlock? firstImage;
    RichContentBlock? firstVideo;
    var imageOrder = -1;
    var videoOrder = -1;
    for (var index = 0; index < blocks.length; index++) {
      final block = blocks[index];
      if (firstImage == null && block.isImage) {
        firstImage = block;
        imageOrder = index;
      }
      if (firstVideo == null && block.isVideo) {
        firstVideo = block;
        videoOrder = index;
      }
      if (firstImage != null && firstVideo != null) break;
    }
    firstVideo ??= videos.isEmpty ? null : RichContentBlock.video(videos.first);
    if (firstImage == null) {
      final images = contentImageUrlsOf(question, limit: 1);
      if (images.isNotEmpty &&
          (firstVideo?.video?.posterUrl.isEmpty != false ||
              images.first != firstVideo?.video?.posterUrl)) {
        firstImage = RichContentBlock.image(images.first);
      }
    }

    final media = <RichContentBlock>[];
    if (firstImage != null && firstVideo != null) {
      if (videoOrder >= 0 && (imageOrder < 0 || videoOrder < imageOrder)) {
        media.addAll([firstVideo, firstImage]);
      } else {
        media.addAll([firstImage, firstVideo]);
      }
    } else if (firstImage != null) {
      media.add(firstImage);
    } else if (firstVideo != null) {
      media.add(firstVideo);
    }
    return _QuestionHeaderPresentation(
      summary: summary.isEmpty ? null : summary,
      media: List.unmodifiable(media),
    );
  }

  final String? summary;
  final List<RichContentBlock> media;

  bool get hasContent => summary != null || media.isNotEmpty;
}

class _QuestionHeaderImage extends StatelessWidget {
  const _QuestionHeaderImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '查看问题图片原图',
    child: InkWell(
      key: ValueKey('question-header-image-$url'),
      onTap: () => _showDetailImagePreview(context, url),
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ZhihuImage.network(
            url,
            headers: zhihuImageRequestHeaders,
            fit: BoxFit.cover,
            cacheWidth: 960,
            cacheHeight: 540,
            filterQuality: FilterQuality.low,
            frameBuilder: (_, child, frame, _) => frame == null
                ? const ColoredBox(color: ZhPalette.canvas)
                : child,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: ZhPalette.canvas,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: ZhPalette.subtleInk,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

String _shortAnswerDate(String value) {
  final match = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
  if (match == null) return value;
  return '${match.group(2)}-${match.group(3)}';
}

String _answerListExcerpt(Map<String, dynamic> value) {
  final direct = subtitleOf(value);
  if (direct.isNotEmpty) return direct;

  // The answer feed has used both `excerpt` and the full rich `content`
  // payload over time. Keep the list useful when the compact excerpt is not
  // present by extracting only text from the rich blocks; images/videos are
  // rendered separately below.
  for (final key in const [
    'detail',
    'body',
    'answer_text',
    'content_html',
    'html',
    'content',
  ]) {
    final raw = value[key];
    final html = raw is String ? raw.trim() : '';
    if (html.isEmpty) continue;
    final blocks = richContentBlocks(html);
    final text = blocks
        .where((block) => !block.isImage && !block.isVideo)
        .map((block) => block.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n\n');
    final plain = text.isNotEmpty ? text : plainText(html);
    if (plain.isNotEmpty) {
      return plain.length > 180 ? '${plain.substring(0, 180)}…' : plain;
    }
  }
  return '';
}
