part of '../account_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({
    super.key,
    required this.api,
    required this.session,
    this.onMenuPressed,
  });

  final ZhihuApiClient api;
  final SessionStore session;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: session,
    builder: (context, _) {
      // Wide windows already expose the persistent shell sidebar.  Passing a
      // null menu callback keeps the profile/login app bars from duplicating
      // that navigation affordance while retaining it on compact windows.
      final effectiveMenu = ZhViewport.isDesktop(context)
          ? null
          : onMenuPressed;
      if (!session.hasAccountSession) {
        return NativeLoginPage(
          key: const ValueKey('my-page-login'),
          session: session,
          embedded: true,
          onMenuPressed: effectiveMenu,
        );
      }
      return _AccountProfileHome(
        key: ValueKey('my-page-profile:${session.accountUid}'),
        api: api,
        session: session,
        onMenuPressed: effectiveMenu,
      );
    },
  );
}

class _AccountProfileHome extends StatefulWidget {
  const _AccountProfileHome({
    super.key,
    required this.api,
    required this.session,
    this.onMenuPressed,
  });

  final ZhihuApiClient api;
  final SessionStore session;
  final VoidCallback? onMenuPressed;

  @override
  State<_AccountProfileHome> createState() => _AccountProfileHomeState();
}

class _AccountProfileHomeState extends State<_AccountProfileHome> {
  Map<String, dynamic>? _profile;
  Object? _error;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final selfResponse = await widget.api.get('/people/self');
      if (!widget.session.hasAccountSession) {
        return;
      }
      if (!selfResponse.isSuccess || selfResponse.jsonMap == null) {
        throw selfResponse;
      }
      final self = unwrapObject(selfResponse.jsonMap!);
      final memberId = plainText(self['id']).isEmpty
          ? widget.session.accountUid
          : plainText(self['id']);
      Map<String, dynamic>? publicProfile;
      Map<String, dynamic>? detailProfile;
      if (memberId.isNotEmpty) {
        final response = await widget.api.getUri(
          widget.api.userProfileInitialUri(memberId),
        );
        if (response.isSuccess && response.jsonMap != null) {
          publicProfile = unwrapObject(response.jsonMap!);
        }
        final detailResponse = await widget.api.getUri(
          widget.api.userProfileDetailUri(memberId),
        );
        if (detailResponse.isSuccess && detailResponse.jsonMap != null) {
          detailProfile = unwrapObject(detailResponse.jsonMap!);
        }
      }
      if (!mounted) return;
      setState(() {
        _profile = mergeAccountProfilePayloads(self, {
          ...?publicProfile,
          ...?detailProfile,
        });
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copyProfileLink(
    BuildContext context,
    Map<String, dynamic> profile,
    String memberId,
  ) async {
    final token = plainText(profile['url_token']).isEmpty
        ? memberId
        : plainText(profile['url_token']);
    await Clipboard.setData(
      ClipboardData(text: 'https://www.zhihu.com/people/$token'),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('主页链接已复制')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    if (_loading && profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          leading: widget.onMenuPressed == null
              ? null
              : IconButton(
                  tooltip: '打开侧边栏',
                  onPressed: widget.onMenuPressed,
                  style: IconButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: Colors.transparent,
                    enableFeedback: false,
                  ),
                  icon: const Icon(Icons.menu_rounded),
                ),
          title: const Text('我的主页'),
        ),
        body: ApiErrorView(
          error: _error!,
          onRetry: _load,
          titleOverride: '个人资料加载失败',
          detailOverride: '请检查网络后重试',
        ),
      );
    }
    final memberId = plainText(profile['id']).isEmpty
        ? widget.session.accountUid
        : plainText(profile['id']);
    final name = plainText(profile['name']).isEmpty
        ? '知乎用户'
        : plainText(profile['name']);
    final cover = plainText(profile['cover_url']);
    final urlToken = plainText(profile['url_token']).isEmpty
        ? memberId
        : plainText(profile['url_token']);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: const ValueKey('account-profile-home'),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final accessibilityExtra =
                    ((textScale - 1).clamp(0.0, 1.0) * 72).toDouble();
                return SliverAppBar(
                  pinned: true,
                  expandedHeight: 338 + accessibilityExtra,
                  backgroundColor: const Color(0xFF326A66),
                  foregroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(_ProfileTabsSurface.height),
                    child: _ProfileTabsSurface(),
                  ),
                  title: AnimatedOpacity(
                    opacity: constraints.scrollOffset >= 190 ? 1 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: Text(name),
                  ),
                  leading: widget.onMenuPressed == null
                      ? null
                      : IconButton(
                          tooltip: '打开侧边栏',
                          onPressed: widget.onMenuPressed,
                          style: IconButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: Colors.transparent,
                            enableFeedback: false,
                          ),
                          icon: const Icon(Icons.menu_rounded),
                        ),
                  actions: [
                    IconButton(
                      tooltip: '查找用户',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserPage(api: widget.api),
                        ),
                      ),
                      icon: const Icon(Icons.search_rounded),
                    ),
                    IconButton(
                      tooltip: '复制主页链接',
                      onPressed: () =>
                          _copyProfileLink(context, profile, memberId),
                      icon: const Icon(Icons.share_outlined),
                    ),
                    const SizedBox(width: 6),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _ProfileCover(imageUrl: cover),
                        ColoredBox(color: Colors.black.withValues(alpha: .32)),
                        _ProfileHeader(
                          api: widget.api,
                          profile: profile,
                          memberId: memberId,
                          onRefresh: _load,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          body: TabBarView(
            children: [
              _ProfileOverview(
                api: widget.api,
                profile: profile,
                memberId: memberId,
              ),
              _CreationTab(
                api: widget.api,
                memberId: memberId,
                urlToken: urlToken,
                profile: profile,
              ),
              _ProfileFeedTab(
                key: ValueKey('profile-activities:$memberId'),
                api: widget.api,
                loadInitial: () => widget.api.getUri(
                  widget.api.userActivitiesInitialUri(memberId),
                ),
                emptyMessage: '还没有公开动态',
                activityMenu: true,
              ),
              _ProfileFeedTab(
                key: ValueKey('profile-voteups:$memberId'),
                api: widget.api,
                loadInitial: () => widget.api.getUri(
                  widget.api.userVoteupsInitialUri(memberId),
                ),
                emptyMessage: '还没有公开赞同',
                activityMenu: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTabsSurface extends StatelessWidget {
  const _ProfileTabsSurface();

  static const height = 52.0;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: height,
    child: DecoratedBox(
      key: ValueKey('profile-tabs-surface'),
      decoration: BoxDecoration(
        color: ZhPalette.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: '灵感'),
          Tab(text: '创作'),
          Tab(text: '动态'),
          Tab(text: '赞同'),
        ],
      ),
    ),
  );
}
