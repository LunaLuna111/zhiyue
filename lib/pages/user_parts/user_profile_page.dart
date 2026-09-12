part of '../user_page.dart';

class UserProfileDetailPage extends StatefulWidget {
  const UserProfileDetailPage({
    super.key,
    required this.api,
    required this.memberId,
  });
  final ZhihuApiClient api;
  final String memberId;
  @override
  State<UserProfileDetailPage> createState() => _UserProfileDetailPageState();
}

class _UserProfileDetailPageState extends State<UserProfileDetailPage> {
  Object? _state;
  List<_UserProfileTabSpec> _serverTabs = const [];
  bool _relationshipBusy = false;

  void _updateProfileState(VoidCallback callback) {
    if (mounted) setState(callback);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _state = null;
      _serverTabs = const [];
    });
    try {
      final response = await widget.api.getUri(
        widget.api.userProfileInitialUri(widget.memberId),
      );
      if (!mounted) return;
      if (!response.isSuccess || response.jsonMap == null) {
        setState(() => _state = response);
        return;
      }
      final profile = unwrapObject(response.jsonMap!);
      final resolvedId = userMemberIdOfProfile(profile, widget.memberId);
      List<_UserProfileTabSpec> serverTabs = const [];
      try {
        final tabsResponse = await widget.api.getUri(
          widget.api.userProfileTabsInitialUri(resolvedId),
        );
        if (tabsResponse.isSuccess && tabsResponse.jsonMap != null) {
          serverTabs = _parseProfileTabs(tabsResponse.jsonMap!);
        }
      } catch (_) {
        // Profile data remains useful when a member exposes no tab contract.
      }
      if (!mounted) return;
      setState(() {
        _state = response;
        _serverTabs = serverTabs;
      });
    } catch (error) {
      if (mounted) setState(() => _state = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state is! ApiResponse || !state.isSuccess || state.jsonMap == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('用户主页')),
        body: ApiErrorView(error: state, onRetry: _load),
      );
    }
    final profile = unwrapObject(state.jsonMap!);
    final name = titleOf(profile).isEmpty ? '知乎用户' : titleOf(profile);
    final profileId = userMemberIdOfProfile(profile, widget.memberId);
    final isSelf =
        profile['is_self'] == true ||
        (widget.api.session.accountUid.isNotEmpty &&
            profileId == widget.api.session.accountUid);
    final tabs = _tabs(profile);
    return DefaultTabController(
      key: ValueKey('user-profile:${widget.memberId}:${tabs.length}'),
      length: tabs.length,
      child: Scaffold(
        key: const ValueKey('user-profile-home'),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final accessibilityExtra =
                    ((textScale - 1).clamp(0.0, 1.0) * 84).toDouble();
                return SliverAppBar(
                  pinned: true,
                  expandedHeight: 368 + accessibilityExtra,
                  backgroundColor: const Color(0xFF326A66),
                  foregroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(
                      _UserProfileTabsSurface.height,
                    ),
                    child: _UserProfileTabsSurface(tabs),
                  ),
                  title: AnimatedOpacity(
                    opacity: constraints.scrollOffset >= 218 ? 1 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: Text(name),
                  ),
                  actions: [
                    if (!isSelf)
                      IconButton(
                        key: const ValueKey('user-profile-content-search'),
                        tooltip: '搜索 TA 的内容',
                        onPressed: () => _openProfileContentSearch(profile),
                        icon: const Icon(Icons.search_rounded),
                      ),
                    IconButton(
                      tooltip: '复制主页链接',
                      onPressed: () => _copyProfileLink(profile),
                      icon: const Icon(Icons.share_outlined),
                    ),
                    const SizedBox(width: 6),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _UserProfileCover(
                          imageUrl: plainText(profile['cover_url']),
                        ),
                        ColoredBox(color: Colors.black.withValues(alpha: .34)),
                        _profileHeader(profile),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          body: TabBarView(
            children: [for (final tab in tabs) _tabBody(profile, tab)],
          ),
        ),
      ),
    );
  }
}
