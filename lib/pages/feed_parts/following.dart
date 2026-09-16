part of '../feed_page.dart';

class _FollowingPeopleStrip extends StatefulWidget {
  const _FollowingPeopleStrip({
    super.key,
    required this.api,
    required this.onPersonTap,
    required this.onDiscoverTap,
  });
  final ZhihuApiClient api;
  final ValueChanged<Map<String, dynamic>> onPersonTap;
  final VoidCallback onDiscoverTap;
  @override
  State<_FollowingPeopleStrip> createState() => _FollowingPeopleStripState();
}

class _FollowingPeopleStripState extends State<_FollowingPeopleStrip> {
  List<Map<String, dynamic>> _people = const [];
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    // The native header uses the private “most visits” feed, while some
    // server variants expose extra followed creators only through the public
    // recommendation endpoint. Start both together and paint each batch as
    // soon as it arrives instead of making the rail wait for the slower one.
    unawaited(_loadMostVisited());
    unawaited(_loadRecommendations());
  }

  Future<void> _loadMostVisited() async {
    try {
      // This is the native Follow page contract. Each row is a
      // MomentsMostVisitsActor containing an `actor` People object.
      final response = await widget.api.getUri(
        widget.api.followingMostVisitedInitialUri(),
      );
      if (response.isSuccess) {
        _appendPeople(_normalizeMostVisited(response.json));
      }
    } catch (_) {
      // The rail is an optional enhancement. The feed remains usable when
      // this account-scoped request is unavailable.
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      // Some anonymous/server variants do not expose /moments/recent yet.
      // Keep the rail useful by also reading the public recommendation
      // contract; its actor wrapper is normalized to the same shape.
      final fallback = await widget.api.publicWebGet(
        '/api/v4/moments/recommend_follow_people',
        query: const {'rec_type': 'follow_tab'},
      );
      if (fallback.isSuccess) {
        _appendPeople(_normalizeRecommendationPeople(fallback.json));
      }
    } catch (_) {
      // Public recommendations can be denied for an anonymous session.
    }
  }

  void _appendPeople(Iterable<Map<String, dynamic>> incoming) {
    if (!mounted || incoming.isEmpty) return;
    final merged = [..._people];
    final seen = <String>{for (final person in merged) _personKey(person)};
    for (final person in incoming) {
      final key = _personKey(person);
      if (key.isEmpty || !seen.add(key)) continue;
      merged.add(person);
      if (merged.length >= 12) break;
    }
    if (merged.length != _people.length) {
      setState(() => _people = List.unmodifiable(merged));
    }
  }

  String _personKey(Map<String, dynamic> value) {
    final id = plainText(
      value['member_id'] ??
          value['url_token'] ??
          value['id'] ??
          value['user_id'],
    );
    return id.isNotEmpty ? 'id:$id' : 'name:${titleOf(value)}';
  }

  List<Map<String, dynamic>> _normalizeMostVisited(Object? value) {
    final result = <Map<String, dynamic>>[];
    for (final row in extractRows(value)) {
      // MostVisitsActor is already the wire object we need. Calling the
      // generic content un-wrapper here would follow its `target` field and
      // accidentally hide the sibling `actor` People object.
      final wrapper = row;
      final actor = wrapper['actor'];
      if (actor is! Map) continue;
      final person = Map<String, dynamic>.from(actor);
      person['_following_unread_count'] = wrapper['unread_count'];
      person['_following_actor_type'] = wrapper['type'];
      person['_following_style_type'] = wrapper['style_type'];
      person['_following_brief'] = wrapper['brief'];
      person['_following_target'] = wrapper['target'];
      if (_isPerson(person)) result.add(person);
    }
    return result.take(12).toList(growable: false);
  }

  List<Map<String, dynamic>> _normalizeRecommendationPeople(Object? value) {
    final result = <Map<String, dynamic>>[];
    for (final row in extractRows(value)) {
      final wrapper = row;
      final actor = wrapper['actor'];
      final person = actor is Map
          ? Map<String, dynamic>.from(actor)
          : Map<String, dynamic>.from(wrapper);
      person['_following_unread_count'] =
          wrapper['unread_count'] ?? wrapper['unread_count_text'];
      person['_following_reason'] = wrapper['reason'];
      person['_following_attached_info'] = wrapper['attached_info'];
      if (_isPerson(person)) result.add(person);
    }
    return result.take(12).toList(growable: false);
  }

  bool _isPerson(Map<String, dynamic> value) {
    final name = titleOf(value);
    final avatar = _avatarOf(value);
    final id = plainText(
      value['member_id'] ??
          value['id'] ??
          value['url_token'] ??
          value['user_id'],
    );
    return name.isNotEmpty && (avatar.isNotEmpty || id.isNotEmpty);
  }

  String _avatarOf(Map<String, dynamic> value) {
    final raw = plainText(
      value['avatar_url'] ??
          value['avatar_url_template'] ??
          value['avatarUrl'] ??
          value['avatar'],
    );
    if (raw.startsWith('//')) return 'https:$raw';
    return raw;
  }

  int _unreadCount(Map<String, dynamic> value) {
    final raw = value['_following_unread_count'];
    if (raw is num) return raw.toInt();
    return int.tryParse(plainText(raw)) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ZhPalette.border, width: .7)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _people.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FollowingQuickAction(onTap: widget.onDiscoverTap);
          }
          final person = _people[index - 1];
          final name = titleOf(person).isEmpty ? '知乎用户' : titleOf(person);
          final avatar = _avatarOf(person);
          final validAvatar = Uri.tryParse(avatar)?.scheme == 'https';
          final unread =
              _unreadCount(person) > 0 ||
              person['_following_unread_count'] == null;
          return Semantics(
            button: true,
            label: '查看$name最近发布的内容',
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () => widget.onPersonTap(person),
              child: SizedBox(
                width: 60,
                child: Column(
                  children: [
                    _FollowingAvatar(
                      name: name,
                      avatar: validAvatar ? avatar : '',
                      unread: unread,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ZhPalette.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FollowingQuickAction extends StatelessWidget {
  const _FollowingQuickAction({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '发现好友',
    child: InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4EA7E8),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: Colors.white,
                    size: 31,
                  ),
                ),
                const _FollowingUnreadDot(),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '发现好友',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: const Color(0xFF4E86B9)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FollowingAvatar extends StatelessWidget {
  const _FollowingAvatar({
    required this.name,
    required this.avatar,
    required this.unread,
  });
  final String name;
  final String avatar;
  final bool unread;
  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      ClipOval(
        child: avatar.isNotEmpty
            ? ZhihuImage.network(
                avatar,
                headers: zhihuImageRequestHeaders,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                cacheWidth: 168,
                cacheHeight: 168,
                errorBuilder: (_, _, _) => _FollowingPersonFallback(name: name),
              )
            : _FollowingPersonFallback(name: name, size: 56),
      ),
      if (unread) const _FollowingUnreadDot(),
    ],
  );
}

class _FollowingUnreadDot extends StatelessWidget {
  const _FollowingUnreadDot();
  @override
  Widget build(BuildContext context) => Positioned(
    right: -1,
    top: -1,
    child: Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFD95A5A),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 1.4,
        ),
      ),
    ),
  );
}

class _FollowingFilterBar extends StatelessWidget {
  const _FollowingFilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) {
    final selectedIndex = filters.indexOf(selected);
    return SizedBox(
      height: 68,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 11, 18, 11),
        child: ZhLiquidGlassSegmentedTabs(
          key: const ValueKey('following-filter-glass-tabs'),
          labels: filters,
          selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
          semanticPrefix: '关注页',
          onSelected: (index) => onSelected(filters[index]),
          height: 46,
        ),
      ),
    );
  }
}

class _FollowingPersonFallback extends StatelessWidget {
  const _FollowingPersonFallback({required this.name, this.size = 48});
  final String name;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: ZhPalette.canvas,
      shape: BoxShape.circle,
    ),
    child: Text(
      name.isEmpty ? '知' : name.characters.first,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _FollowingServiceCard extends StatelessWidget {
  const _FollowingServiceCard({super.key, required this.value});
  final Map<String, dynamic> value;
  String _text(Map<String, dynamic> object, List<String> keys) {
    for (final key in keys) {
      final text = plainText(object[key]);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final object = unwrapObject(value);
    final title = _text(object, const ['title', 'name', 'text']).isEmpty
        ? '知乎盐选会员 为你严选好内容'
        : _text(object, const ['title', 'name', 'text']);
    final subtitle = _text(object, const [
      'subtitle',
      'sub_title',
      'description',
      'brief',
    ]);
    return Material(
      color: ZhPalette.background,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ZhPalette.border, width: .7),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3D6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                color: Color(0xFFB87C12),
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ZhPalette.mutedInk,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: ZhPalette.subtleInk),
          ],
        ),
      ),
    );
  }
}

class FollowingPersonRecentPage extends StatelessWidget {
  const FollowingPersonRecentPage({
    super.key,
    required this.api,
    required this.memberId,
    required this.name,
  });
  final ZhihuApiClient api;
  final String memberId;
  final String name;
  Future<ApiResponse> _load() async {
    final recent = await api.getUri(
      api.userRecentActivitiesInitialUri(memberId),
    );
    if (recent.isSuccess) return recent;
    // Some accounts expose only the profile activity route. Preserve the
    // direct recent-content intent while keeping that official fallback.
    return api.getUri(api.userActivitiesInitialUri(memberId));
  }

  @override
  Widget build(BuildContext context) => PagedListPage(
    title: '$name的最近动态',
    api: api,
    loadInitial: _load,
    rowBuilder: (context, value, onTap) => ObjectCard(
      value: value,
      feedMode: true,
      compact: false,
      showImages: true,
      showMetrics: true,
      presentation: FeedCardPresentation.following,
      onTap: onTap,
      onAuthorTap: authorIdOf(value).isEmpty
          ? null
          : () => openContentAuthor(context, api, value),
    ),
    onObjectTap: (context, value) => openDetectedObject(context, api, value),
    emptyMessage: '还没有公开的最近内容',
  );
}
