part of '../content_pages.dart';

class ContentDetailPage extends StatefulWidget {
  const ContentDetailPage({
    super.key,
    required this.api,
    required this.contentType,
    required this.contentId,
    this.initialValue,
    this.previousAnswer,
    this.answerHistory = const [],
    this.prefetchedDetail,
  });

  final ZhihuApiClient api;
  final String contentType;
  final String contentId;
  final Map<String, dynamic>? initialValue;
  final Map<String, dynamic>? previousAnswer;
  final List<Map<String, dynamic>> answerHistory;

  /// A detail request started by the previous answer page.
  ///
  /// The next page consumes this same future instead of issuing a second
  /// request. The compact [initialValue] is still rendered immediately while
  /// the future is pending.
  final Future<Map<String, dynamic>?>? prefetchedDetail;

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class AnswerDetailAppBarTitle extends StatelessWidget {
  const AnswerDetailAppBarTitle({
    super.key,
    required this.title,
    required this.questionId,
    required this.onTap,
    this.metrics = const ContentMetrics(),
  });

  final String title;
  final String questionId;
  final VoidCallback onTap;
  final ContentMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final metadata = [
      context.zhL10n.brandZhihu,
      if (metrics.answerCount case final count?)
        context.zhL10n.detailQuestionAnswerCount(compactCount(count)),
      if (metrics.followerCount case final count?)
        context.zhL10n.detailQuestionFollowerCount(compactCount(count)),
    ].join(' · ');
    return Semantics(
      button: true,
      label: context.zhL10n.detailQuestionAnswersSemantic,
      child: InkWell(
        key: const ValueKey('answer-detail-question-title'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty
                    ? context.zhL10n.detailQuestionFallback(questionId)
                    : title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    metadata,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ZhPalette.subtleInk,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: ZhPalette.subtleInk,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentDetailAppBarTitle extends StatelessWidget {
  const ContentDetailAppBarTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 19,
          height: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// The title of an article or idea rendered as the first item in the body.
///
/// It deliberately lives inside the detail scroll view instead of the app
/// bar's bottom slot. That keeps the top chrome limited to the action row and
/// lets the title scroll away together with the article content.
class ContentDetailBodyTitle extends StatelessWidget {
  const ContentDetailBodyTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    key: const ValueKey('content-detail-body-title'),
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(
      title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontSize: 21,
        height: 1.25,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _QuestionInvitePage extends StatelessWidget {
  const _QuestionInvitePage({required this.api, required this.questionId});

  final ZhihuApiClient api;
  final String questionId;

  @override
  Widget build(BuildContext context) => PagedListPage(
    title: context.zhL10n.questionInviteTitle,
    api: api,
    loadInitial: () =>
        api.getUri(api.questionInviteCandidatesInitialUri(questionId)),
    rowBuilder: (context, value, _) =>
        _QuestionInviteeRow(api: api, questionId: questionId, value: value),
    emptyMessage: context.zhL10n.questionInviteEmpty,
  );
}

class _QuestionInviteeRow extends StatefulWidget {
  const _QuestionInviteeRow({
    required this.api,
    required this.questionId,
    required this.value,
  });

  final ZhihuApiClient api;
  final String questionId;
  final Map<String, dynamic> value;

  @override
  State<_QuestionInviteeRow> createState() => _QuestionInviteeRowState();
}

class _QuestionInviteeRowState extends State<_QuestionInviteeRow> {
  bool? _invited;
  var _busy = false;

  Map<String, dynamic>? _map(Object? value) {
    if (value is! Map) return null;
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  bool _looksLikePerson(Map<String, dynamic> value) => const [
    'name',
    'nickname',
    'avatar_url',
    'avatar_url_template',
    'avatar',
    'avatar_info',
    'url_token',
    'member_id',
    'id',
  ].any((key) => plainText(value[key]).isNotEmpty || value[key] is Map);

  Map<String, dynamic> get _person {
    // The recommendation endpoint has shipped both `people` and `person`
    // wrappers.  Newer responses sometimes nest the actual member under
    // `user`, `invitee`, or `target`; falling back to the outer row makes the
    // UI silently render the generic black avatar instead of the real one.
    final object = unwrapObject(widget.value);
    final candidates = <Object?>[
      widget.value['people'],
      widget.value['person'],
      widget.value['user'],
      widget.value['invitee'],
      widget.value['author'],
      widget.value['target'],
      widget.value['member'],
      widget.value['profile'],
      object['people'],
      object['person'],
      object['user'],
      object['invitee'],
      object['author'],
      object['target'],
      object['member'],
      object['profile'],
    ];
    for (final candidate in candidates) {
      final map = _map(candidate);
      if (map == null) continue;
      final nested =
          _map(map['user']) ??
          _map(map['person']) ??
          _map(map['invitee']) ??
          _map(map['author']) ??
          _map(map['member']) ??
          _map(map['profile']);
      if (nested != null && _looksLikePerson(nested)) return nested;
      if (_looksLikePerson(map)) return map;
    }
    return object;
  }

  String _avatarUrl(Map<String, dynamic> person) {
    Object? raw;
    for (final key in const [
      'avatar_url',
      'avatar_url_template',
      'avatarUrl',
      'avatar',
      'avatar_info',
      'image_url',
      'image',
    ]) {
      final value = person[key];
      if (value is Map) {
        final nested = _map(value);
        raw =
            nested?['url'] ??
            nested?['src'] ??
            nested?['image_url'] ??
            nested?['large'] ??
            nested?['medium'] ??
            nested?['small'];
      } else {
        raw = value;
      }
      if (plainText(raw).isNotEmpty) break;
    }
    var value = plainText(raw).replaceAll('&amp;', '&');
    if (value.startsWith('//')) value = 'https:$value';
    if (value.startsWith('http://')) value = 'https://${value.substring(7)}';
    if (value.contains('{size}')) value = value.replaceAll('{size}', 's');
    return value;
  }

  Future<void> _toggle() async {
    if (_busy) return;
    if (!widget.api.canWrite) {
      _showWriteSessionRequired(context);
      return;
    }
    final person = _person;
    final memberId = [
      person['url_token'],
      person['id'],
      person['member_id'],
      person['uid'],
    ].map(plainText).firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (memberId.isEmpty) return;
    final invited = _invited ?? widget.value['is_invited'] == true;
    setState(() => _busy = true);
    try {
      final response = await widget.api.setQuestionInvitee(
        questionId: widget.questionId,
        memberId: memberId,
        invited: !invited,
        source: plainText(
          widget.value['invite_type'] ?? widget.value['source'],
        ),
      );
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      setState(() {
        _invited = !invited;
        widget.value['is_invited'] = !invited;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiFailure.from(error).userMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openPerson() {
    final person = _person;
    final id = [
      person['url_token'],
      person['id'],
      person['member_id'],
      person['uid'],
    ].map(plainText).firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileDetailPage(api: widget.api, memberId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final person = _person;
    final nameValue = plainText(
      person['name'] ?? person['nickname'] ?? person['display_name'],
    );
    final name = nameValue.isEmpty ? context.zhL10n.commonZhihuUser : nameValue;
    final avatar = _avatarUrl(person);
    final reason = plainText(widget.value['reason']);
    final headline = reason.isNotEmpty ? reason : plainText(person['headline']);
    final invited = _invited ?? widget.value['is_invited'] == true;
    final validAvatar = Uri.tryParse(avatar)?.scheme == 'https';
    return Material(
      color: ZhPalette.background,
      child: InkWell(
        onTap: _openPerson,
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.fromLTRB(18, 13, 16, 13),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ZhPalette.border, width: .7),
            ),
          ),
          child: Row(
            children: [
              ClipOval(
                child: validAvatar
                    ? ZhihuImage.network(
                        avatar,
                        headers: zhihuImageRequestHeaders,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        cacheWidth: 156,
                        cacheHeight: 156,
                        errorBuilder: (_, _, _) => _AuthorAvatar(
                          imageUrl: '',
                          fallback: name.characters.first,
                          size: 52,
                        ),
                      )
                    : _AuthorAvatar(
                        imageUrl: '',
                        fallback: name.characters.first,
                        size: 52,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (headline.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ZhPalette.subtleInk,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 82,
                height: 36,
                child: FilledButton(
                  onPressed: _busy ? null : _toggle,
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    backgroundColor: invited
                        ? ZhPalette.canvas
                        : ZhPalette.accentSurface,
                    foregroundColor: invited
                        ? ZhPalette.mutedInk
                        : ZhPalette.link,
                    shape: const StadiumBorder(),
                  ),
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          invited
                              ? context.zhL10n.questionInviteInvited
                              : context.zhL10n.questionInviteAction,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DetailMoreAction {
  write,
  refresh,
  readAloud,
  exportTxt,
  exportMarkdown,
  exportHtml,
  exportPdf,
  search,
  copy,
  followAuthor,
  clearCache,
}
