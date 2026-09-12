part of '../account_page.dart';

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.api,
    required this.profile,
    required this.memberId,
    required this.onRefresh,
  });

  final ZhihuApiClient api;
  final Map<String, dynamic> profile;
  final String memberId;
  final VoidCallback onRefresh;

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _editProfile(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AccountProfileEditPage(api: api, profile: profile),
      ),
    );
    if (changed == true) onRefresh();
  }

  void _openList(
    BuildContext context,
    String title,
    Future<ApiResponse> Function() loader,
  ) {
    _open(
      context,
      title == '关注我的人' || title == '我关注的人'
          ? UserRelationshipListPage(
              title: title,
              api: api,
              loadInitial: loader,
            )
          : PagedListPage(
              title: title,
              api: api,
              loadInitial: loader,
              onObjectTap: (context, value) =>
                  openDetectedObject(context, api, value),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = plainText(profile['name']).isEmpty
        ? '知乎用户'
        : plainText(profile['name']);
    final avatar = plainText(
      profile['avatar_url'] ?? profile['avatar_url_template'],
    );
    final headline = plainText(profile['headline']);
    final description = plainText(profile['description']);
    final location = accountProfileLocation(profile);
    final gender = accountProfileGender(profile);
    final ip = _profileIp(profile);
    final vip = _profileVipLabel(profile);
    final voteups = accountProfileMetric(profile, const [
      'voteup_count',
      'get_praise_count',
    ]);
    final followers = accountProfileMetric(profile, const ['follower_count']);
    final following = accountProfileMetric(profile, const [
      'following_count',
      'total_following_count',
    ]);

    final lightText = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: Colors.white);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 66),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProfileAvatar(imageUrl: avatar, fallback: name, size: 84),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ProfileStat(
                          value: voteups,
                          label: '获赞',
                          light: true,
                        ),
                      ),
                      const _ProfileStatDivider(light: true),
                      Expanded(
                        child: _ProfileStat(
                          value: followers,
                          label: '被关注',
                          light: true,
                          onTap: memberId.isEmpty
                              ? null
                              : () => _openList(
                                  context,
                                  '关注我的人',
                                  () => api.getUri(
                                    api.userFollowersInitialUri(memberId),
                                  ),
                                ),
                        ),
                      ),
                      const _ProfileStatDivider(light: true),
                      Expanded(
                        child: _ProfileStat(
                          value: following,
                          label: '关注',
                          light: true,
                          onTap: memberId.isEmpty
                              ? null
                              : () => _openList(
                                  context,
                                  '我关注的人',
                                  () => api.getUri(
                                    api.userFolloweesInitialUri(memberId),
                                  ),
                                ),
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
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
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
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: .18),
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _editProfile(context),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('编辑资料', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            if (headline.isNotEmpty || description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                headline.isNotEmpty ? headline : description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: lightText,
              ),
            ],
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      if (gender.isNotEmpty)
                        _ProfileMeta(
                          icon: Icons.person_outline,
                          text: gender,
                          light: true,
                        ),
                      if (location.isNotEmpty)
                        _ProfileMeta(
                          icon: Icons.location_on_outlined,
                          text: location,
                          light: true,
                        ),
                      if (ip.isNotEmpty)
                        _ProfileMeta(
                          icon: Icons.public_rounded,
                          text: ip,
                          light: true,
                        ),
                      if (vip.isNotEmpty)
                        _ProfileMeta(
                          icon: Icons.workspace_premium_outlined,
                          text: vip,
                          emphasized: true,
                          light: true,
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () => _open(
                    context,
                    AccountProfileDetailsPage(profile: profile),
                  ),
                  icon: const Icon(Icons.person_search_outlined, size: 17),
                  label: const Text('全部资料'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview({
    required this.api,
    required this.profile,
    required this.memberId,
  });

  final ZhihuApiClient api;
  final Map<String, dynamic> profile;
  final String memberId;

  void _openList(
    BuildContext context,
    String title,
    Future<ApiResponse> Function() loader,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PagedListPage(
          title: title,
          api: api,
          loadInitial: loader,
          onObjectTap: (context, value) =>
              openDetectedObject(context, api, value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, IconData, VoidCallback)>[
      (
        '回答',
        _metricSummary(profile, const ['answer_count']),
        Icons.question_answer_outlined,
        () => _openList(
          context,
          '我的回答',
          () => api.getUri(api.userCreatedAnswersInitialUri(memberId)),
        ),
      ),
      (
        '文章',
        _metricSummary(profile, const ['articles_count', 'article_count']),
        Icons.article_outlined,
        () => _openList(
          context,
          '我的文章',
          () => api.getUri(api.userCreatedArticlesInitialUri(memberId)),
        ),
      ),
      (
        '想法',
        _metricSummary(profile, const ['pins_count', 'pin_count']),
        Icons.lightbulb_outline_rounded,
        () => _openList(
          context,
          '我的想法',
          () => api.getUri(api.userCreatedPinsInitialUri(memberId)),
        ),
      ),
      (
        '收藏',
        _metricSummary(profile, const ['favorite_count']),
        Icons.star_border_rounded,
        () => _openList(
          context,
          '我的收藏',
          () => api.getUri(
            api.userCollectionsInitialUri(memberId),
            headers: const {'x-api-version': '3.0.94'},
          ),
        ),
      ),
    ];
    return ZhResponsiveFrame(
      maxWidth: 760,
      desktopGutter: 24,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        itemCount: rows.length + 1,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 11),
              child: Text(
                '我的内容',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          final row = rows[index - 1];
          return ListTile(
            minTileHeight: 56,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Icon(row.$3),
            title: Text(row.$1),
            subtitle: row.$2.isEmpty ? null : Text(row.$2),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: row.$4,
          );
        },
      ),
    );
  }
}
