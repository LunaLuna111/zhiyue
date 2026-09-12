part of '../user_page.dart';

extension _UserProfileDetailActions on _UserProfileDetailPageState {
  List<_UserProfileTabSpec> _parseProfileTabs(Map<String, dynamic> payload) {
    final root = unwrapObject(payload);
    final rawTabs = root['tabs_v3'] ?? payload['tabs_v3'];
    if (rawTabs is! List) return const [];
    final tabs = <_UserProfileTabSpec>[];
    for (final raw in rawTabs) {
      if (raw is! Map) continue;
      final tab = raw.map((key, value) => MapEntry(key.toString(), value));
      final name = plainText(tab['name']);
      if (name.isEmpty) continue;
      final subTabs = <_UserProfileSubTab>[];
      final rawSubTabs = tab['sub_tab'] ?? tab['sub_tabs'];
      if (rawSubTabs is List) {
        for (final rawSubTab in rawSubTabs) {
          if (rawSubTab is! Map) continue;
          final subTab = rawSubTab.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          final request = _profileTabUri(subTab['url']);
          if (request == null) continue;
          final subName = plainText(subTab['name']);
          final number = _count(subTab, const ['number']);
          subTabs.add(
            _UserProfileSubTab(
              label: _tabLabel(subName.isEmpty ? name : subName, number),
              uri: request,
            ),
          );
        }
      }
      final directRequest = _profileTabUri(tab['url']);
      if (subTabs.isEmpty && directRequest != null) {
        subTabs.add(_UserProfileSubTab(label: name, uri: directRequest));
      }
      if (subTabs.isEmpty) continue;
      tabs.add(
        _UserProfileTabSpec.remote(
          label: name,
          kind: switch (name) {
            '动态' => _UserProfileTabKind.activities,
            '赞同' => _UserProfileTabKind.voteups,
            _ => _UserProfileTabKind.creations,
          },
          subTabs: subTabs,
        ),
      );
    }
    return tabs.take(5).toList(growable: false);
  }

  String _tabLabel(String name, int? number) =>
      number == null || number <= 0 ? name : '$name ${compactCount(number)}';
  Uri? _profileTabUri(Object? value) {
    final text = plainText(value);
    if (text.isEmpty) return null;
    final parsed = Uri.tryParse(text);
    if (parsed == null) return null;
    if (parsed.hasScheme) {
      if (parsed.scheme != 'https' || parsed.host != ZhihuApiClient.apiHost) {
        return null;
      }
      return parsed;
    }
    if (!text.startsWith('/')) return null;
    return Uri.parse('https://${ZhihuApiClient.apiHost}$text');
  }

  List<_UserProfileTabSpec> _tabs(Map<String, dynamic> profile) {
    final tabs = <_UserProfileTabSpec>[
      const _UserProfileTabSpec.local('主页', _UserProfileTabKind.overview),
    ];
    for (final tab in _serverTabs) {
      final normalized = tab.label.replaceAll(RegExp(r'\s+[0-9.万]+$'), '');
      if (normalized == '主页' || normalized == '首页') continue;
      tabs.add(tab);
    }
    // The native profile always keeps these three public surfaces available.
    // A private/older account can return only one or two entries in tabs_v3;
    // append the missing local contracts instead of leaving a visibly
    // incomplete tab bar.
    final present = tabs.map((tab) => tab.kind).toSet();
    for (final fallback in const [
      _UserProfileTabSpec.local('创作', _UserProfileTabKind.creations),
      _UserProfileTabSpec.local('动态', _UserProfileTabKind.activities),
      _UserProfileTabSpec.local('赞同', _UserProfileTabKind.voteups),
    ]) {
      if (present.add(fallback.kind)) tabs.add(fallback);
    }
    return tabs;
  }

  void _openList(String title, Future<ApiResponse> Function() loader) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => title == '关注他的人' || title == '他关注的人'
            ? UserRelationshipListPage(
                title: title,
                api: widget.api,
                loadInitial: loader,
              )
            : PagedListPage(
                title: title,
                api: widget.api,
                loadInitial: loader,
                onObjectTap: (context, value) =>
                    openDetectedObject(context, widget.api, value),
              ),
      ),
    );
  }

  void _showLoginRequired() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('登录后可使用此功能')));
  }

  Future<void> _toggleFollowing(Map<String, dynamic> profile) async {
    if (_relationshipBusy) return;
    if (!widget.api.canWrite) {
      _showLoginRequired();
      return;
    }
    final memberId = personMemberIdOf(profile, widget.memberId);
    final wasFollowing = profile['is_following'] == true;
    if (wasFollowing) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('取消关注？'),
          content: Text('将不再关注 ${titleOf(profile)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('取消关注'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    _updateProfileState(() => _relationshipBusy = true);
    try {
      final response = await widget.api.setUserFollowing(
        memberId,
        following: !wasFollowing,
      );
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      final current = _count(profile, const ['follower_count']) ?? 0;
      _updateProfileState(() {
        profile['is_following'] = !wasFollowing;
        profile['follower_count'] = wasFollowing
            ? (current - 1).clamp(0, 1 << 62)
            : current + 1;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiFailure.from(error).userMessage)),
        );
      }
    } finally {
      _updateProfileState(() => _relationshipBusy = false);
    }
  }

  void _openMessages(Map<String, dynamic> profile) {
    if (!widget.api.canWrite) {
      _showLoginRequired();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageConversationPage(
          api: widget.api,
          senderId: userMemberIdOfProfile(profile, widget.memberId),
          title: titleOf(profile),
          avatarUrl: plainText(profile['avatar_url']),
        ),
      ),
    );
  }

  Future<void> _copyProfileLink(Map<String, dynamic> profile) async {
    final token = userUrlTokenOfProfile(profile, widget.memberId);
    await Clipboard.setData(
      ClipboardData(text: 'https://www.zhihu.com/people/$token'),
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('主页链接已复制')));
    }
  }

  void _openProfileContentSearch(Map<String, dynamic> profile) {
    final memberId = userMemberIdOfProfile(profile, widget.memberId);
    if (memberId.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ProfileContentSearchPage(
          api: widget.api,
          memberId: memberId,
          memberName: titleOf(profile).isEmpty ? 'TA' : titleOf(profile),
        ),
      ),
    );
  }

  int? _count(Map<String, dynamic> profile, List<String> keys) {
    for (final key in keys) {
      final value = profile[key];
      if (value is num) return value.round();
      final parsed = int.tryParse(plainText(value).replaceAll(',', ''));
      if (parsed != null) return parsed;
    }
    return null;
  }

  String _profileDetail(Map<String, dynamic> profile) {
    final parts = <String>[];
    void add(Object? value) {
      final text = plainText(value);
      if (text.isNotEmpty && !parts.contains(text)) parts.add(text);
    }

    final locations = profile['locations'];
    if (locations is List && locations.isNotEmpty && locations.first is Map) {
      add((locations.first as Map)['name']);
    }
    final business = profile['business'];
    if (business is Map) add(business['name']);
    final employments = profile['employments'];
    if (employments is List && employments.isNotEmpty) {
      final employment = employments.first;
      if (employment is Map) {
        final company = employment['company'];
        final job = employment['job'];
        if (company is Map) add(company['name']);
        if (job is Map) add(job['name']);
      }
    }
    return parts.take(3).join(' · ');
  }

  String _profileIp(Map<String, dynamic> profile) {
    final value = profile['ip_info'];
    if (value is Map) {
      final location = plainText(
        value['location'] ?? value['province'] ?? value['ip_location'],
      );
      return location.isEmpty ? '' : 'IP 属地 $location';
    }
    final text = plainText(value);
    if (text.isEmpty) return '';
    return text.startsWith('IP') ? text : 'IP 属地 $text';
  }

  bool _isVerified(Map<String, dynamic> profile) {
    final badges = profile['badge'];
    if (badges is List && badges.isNotEmpty) return true;
    final badge = profile['badge_v2'];
    if (badge is! Map) return false;
    final details = badge['detail_badges'];
    return (details is List && details.isNotEmpty) ||
        plainText(badge['title']).isNotEmpty;
  }

  List<_ProfileShortcut> _shortcuts(Map<String, dynamic> profile) {
    final id = userMemberIdOfProfile(profile, widget.memberId);
    final urlToken = userUrlTokenOfProfile(profile, widget.memberId);
    return [
      _ProfileShortcut(
        '关注者',
        Icons.groups_outlined,
        () => _openList(
          '关注他的人',
          () => widget.api.getUri(widget.api.userFollowersInitialUri(id)),
        ),
      ),
      _ProfileShortcut(
        '关注的人',
        Icons.person_search_outlined,
        () => _openList(
          '他关注的人',
          () => widget.api.getUri(widget.api.userFolloweesInitialUri(id)),
        ),
      ),
      _ProfileShortcut(
        '回答',
        Icons.question_answer_outlined,
        () => _openList(
          '用户回答',
          () => widget.api.getUri(widget.api.userAnswersInitialUri(id)),
        ),
      ),
      _ProfileShortcut(
        '文章',
        Icons.article_outlined,
        () => _openList(
          '用户文章',
          () => widget.api.getUri(widget.api.userArticlesInitialUri(id)),
        ),
      ),
      _ProfileShortcut(
        '创作文章',
        Icons.dynamic_feed_outlined,
        () => _openList(
          '用户创作文章',
          () => widget.api.getUri(
            widget.api.userCreatedArticleFeedInitialUri(urlToken),
          ),
        ),
      ),
      _ProfileShortcut(
        '贡献文章',
        Icons.library_add_check_outlined,
        () => _openList(
          '用户贡献文章',
          () =>
              widget.api.getUri(widget.api.userIncludedArticlesInitialUri(id)),
        ),
      ),
      _ProfileShortcut(
        '创建的专栏',
        Icons.view_column_outlined,
        () => _openList(
          '用户专栏',
          () => widget.api.getUri(widget.api.userColumnsInitialUri(id)),
        ),
      ),
      _ProfileShortcut(
        '关注专栏',
        Icons.bookmarks_outlined,
        () => _openList(
          '关注专栏',
          () =>
              widget.api.getUri(widget.api.userFollowingColumnsInitialUri(id)),
        ),
      ),
      _ProfileShortcut(
        '关注问题',
        Icons.help_center_outlined,
        () => _openList(
          '关注问题',
          () => widget.api.getUri(
            widget.api.userFollowingQuestionsInitialUri(id),
          ),
        ),
      ),
      _ProfileShortcut(
        '关注收藏集',
        Icons.collections_bookmark_outlined,
        () => _openList(
          '关注收藏集',
          () => widget.api.getUri(
            widget.api.userFollowingCollectionsInitialUri(id),
            headers: const {'x-api-version': '3.0.94'},
          ),
        ),
      ),
      _ProfileShortcut(
        '关注话题',
        Icons.tag_outlined,
        () => _openList(
          '关注话题',
          () => widget.api.getUri(widget.api.userFollowingTopicsInitialUri(id)),
        ),
      ),
    ];
  }

  Widget _profileBody(Map<String, dynamic> profile) {
    final description = plainText(profile['description']);
    final detail = _profileDetail(profile);
    final ip = _profileIp(profile);
    final achievements = <(String, int?)>[
      ('获赞', _count(profile, const ['voteup_count', 'get_praise_count'])),
      ('获感谢', _count(profile, const ['thanked_count'])),
      ('获收藏', _count(profile, const ['favorited_count'])),
    ].where((entry) => entry.$2 != null).toList();
    final shortcuts = _shortcuts(profile);
    final creationShortcuts = shortcuts
        .where(
          (item) => const {'回答', '文章', '创作文章', '创建的专栏'}.contains(item.label),
        )
        .toList(growable: false);
    final relationshipShortcuts = shortcuts
        .where(
          (item) =>
              const {'关注专栏', '关注问题', '关注收藏集', '关注话题'}.contains(item.label),
        )
        .toList(growable: false);
    return ListView(
      key: const ValueKey('user-profile-overview'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      children: [
        if (description.isNotEmpty || detail.isNotEmpty || ip.isNotEmpty) ...[
          Text('个人资料', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 9),
          ZhSurface(
            radius: ZhRadius.card,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.55),
                  ),
                if (description.isNotEmpty &&
                    (detail.isNotEmpty || ip.isNotEmpty))
                  const SizedBox(height: 9),
                if (detail.isNotEmpty)
                  _ProfileInfoLine(icon: Icons.badge_outlined, text: detail),
                if (ip.isNotEmpty) ...[
                  if (detail.isNotEmpty) const SizedBox(height: 6),
                  _ProfileInfoLine(icon: Icons.public_rounded, text: ip),
                ],
              ],
            ),
          ),
          const SizedBox(height: 17),
        ],
        if (achievements.isNotEmpty) ...[
          Text('个人成就', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 9),
          ZhSurface(
            radius: ZhRadius.card,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                for (var index = 0; index < achievements.length; index++) ...[
                  if (index > 0)
                    const SizedBox(
                      height: 30,
                      child: VerticalDivider(width: 1),
                    ),
                  Expanded(
                    child: _ProfileHeaderStat(
                      value: achievements[index].$2,
                      label: achievements[index].$1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 17),
        ],
        Text('公开创作', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        for (final shortcut in creationShortcuts)
          ListTile(
            minTileHeight: 54,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Icon(shortcut.icon),
            title: Text(shortcut.label),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: shortcut.onTap,
          ),
        if (relationshipShortcuts.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('关注与收藏', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final shortcut in relationshipShortcuts)
            ListTile(
              minTileHeight: 54,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(shortcut.icon),
              title: Text(shortcut.label),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: shortcut.onTap,
            ),
        ],
      ],
    );
  }

  Widget _profileHeader(Map<String, dynamic> profile) {
    final name = titleOf(profile).isEmpty ? '知乎用户' : titleOf(profile);
    final id = userMemberIdOfProfile(profile, widget.memberId);
    final avatar = plainText(
      profile['avatar_url'] ?? profile['avatar_url_template'],
    );
    final headline = plainText(profile['headline_render']).isEmpty
        ? plainText(profile['headline'])
        : plainText(profile['headline_render']);
    final detail = _profileDetail(profile);
    final ip = _profileIp(profile);
    final isSelf = {
      widget.api.session.accountUid,
      widget.api.session.accountUserId,
    }.where((value) => value.isNotEmpty).contains(id);
    final following = profile['is_following'] == true;
    final followed = profile['is_followed'] == true;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 52, 20, 66),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProfileAvatar(imageUrl: avatar, fallback: name),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ProfileHeaderStat(
                          value: _count(profile, const [
                            'voteup_count',
                            'get_praise_count',
                          ]),
                          label: '获赞',
                          light: true,
                        ),
                      ),
                      const _ProfileHeaderDivider(),
                      Expanded(
                        child: _ProfileHeaderStat(
                          value: _count(profile, const [
                            'follower_count',
                            'followers_count',
                          ]),
                          label: '关注者',
                          light: true,
                          onTap: () => _openList(
                            '关注他的人',
                            () => widget.api.getUri(
                              widget.api.userFollowersInitialUri(id),
                            ),
                          ),
                        ),
                      ),
                      const _ProfileHeaderDivider(),
                      Expanded(
                        child: _ProfileHeaderStat(
                          value: _count(profile, const [
                            'following_count',
                            'followees_count',
                          ]),
                          label: '关注',
                          light: true,
                          onTap: () {
                            if (profile['hidden_following_members_by_user'] ==
                                true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('对方已隐藏关注列表')),
                              );
                              return;
                            }
                            _openList(
                              '他关注的人',
                              () => widget.api.getUri(
                                widget.api.userFolloweesInitialUri(id),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_isVerified(profile)) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    size: 18,
                    color: Color(0xFFF3C86A),
                  ),
                ],
                if (followed && !isSelf) ...[
                  const SizedBox(width: 10),
                  Text(
                    '关注了你',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ],
            ),
            if (headline.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
            if (detail.isNotEmpty || ip.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                [detail, ip].where((value) => value.isNotEmpty).join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
            if (!isSelf) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('user-profile-follow'),
                      style: FilledButton.styleFrom(
                        backgroundColor: following
                            ? Colors.white.withValues(alpha: .2)
                            : Colors.white,
                        foregroundColor: following
                            ? Colors.white
                            : ZhPalette.ink,
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: _relationshipBusy
                          ? null
                          : () => _toggleFollowing(profile),
                      icon: _relationshipBusy
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              following
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              size: 18,
                            ),
                      label: Text(
                        following ? (followed ? '互相关注' : '已关注') : '关注',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('user-profile-message'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () => _openMessages(profile),
                      icon: const Icon(Icons.mail_outline_rounded, size: 18),
                      label: const Text('私信'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabBody(Map<String, dynamic> profile, _UserProfileTabSpec tab) {
    final id = userMemberIdOfProfile(profile, widget.memberId);
    if (tab.subTabs.isNotEmpty) {
      return _RemoteUserProfileTab(
        key: ValueKey('user-profile-remote:${tab.label}:$id'),
        api: widget.api,
        kind: tab.kind,
        tabs: tab.subTabs,
      );
    }
    final loader = switch (tab.kind) {
      _UserProfileTabKind.creations => () => widget.api.getUri(
        widget.api.userCreatedAllInitialUri(id),
      ),
      _UserProfileTabKind.activities => () => widget.api.getUri(
        widget.api.userActivitiesInitialUri(id),
      ),
      _UserProfileTabKind.voteups => () => widget.api.getUri(
        widget.api.userVoteupsInitialUri(id),
      ),
      _UserProfileTabKind.overview => null,
    };
    if (loader == null) {
      return ZhResponsiveFrame(
        maxWidth: 760,
        desktopGutter: 24,
        child: _profileBody(profile),
      );
    }
    return ZhResponsiveFrame(
      maxWidth: 1120,
      desktopGutter: 24,
      child: PagedListPage(
        key: ValueKey('user-profile-${tab.kind.name}:$id'),
        title: '',
        api: widget.api,
        embedded: true,
        loadInitial: loader,
        rowBuilder: (context, value, onTap) => _UserProfileFeedRow(
          api: widget.api,
          value: value,
          kind: tab.kind,
          onTap: onTap,
        ),
        onObjectTap: (context, value) =>
            openDetectedObject(context, widget.api, value),
        emptyMessage: '还没有公开内容',
      ),
    );
  }
}
