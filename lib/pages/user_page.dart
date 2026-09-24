import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/follow_item_group.dart';
import '../core/json_tools.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import '../widgets/api_views.dart';
import '../widgets/follow_item_group_card.dart';
import 'content_pages.dart';
import 'notifications_page.dart';
import 'paged_list_page.dart';

part 'user_parts/user_profile_page.dart';
part 'user_parts/user_profile_logic.dart';
part 'user_parts/user_profile_widgets.dart';

String userMemberIdOfProfile(Map<String, dynamic> profile, String fallback) {
  // Profile endpoints and relationship endpoints expose different identity
  // fields.  Keep the profile's canonical numeric/member id for profile tabs
  // and list routes; relationship writes use `personMemberIdOf` below so a
  // url token is never confused with a content/card id.
  for (final key in const ['id', 'member_id', 'memberId', 'uid']) {
    final value = plainText(profile[key]);
    if (value.isNotEmpty) return value;
  }
  return fallback.trim();
}

String userUrlTokenOfProfile(Map<String, dynamic> profile, String fallback) {
  final value = plainText(profile['url_token']);
  return value.isEmpty ? fallback.trim() : value;
}

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.api, this.initialMemberId = ''});

  final ZhihuApiClient api;
  final String initialMemberId;

  @override
  State<UserPage> createState() => _UserPageState();
}

class ResolvedUserListPage extends StatefulWidget {
  const ResolvedUserListPage({
    super.key,
    required this.api,
    required this.title,
    required this.inputIdentifier,
    required this.initialUri,
    this.useUrlToken = false,
    this.headers = const {},
  });

  final ZhihuApiClient api;
  final String title;
  final String inputIdentifier;
  final Uri Function(String resolvedId) initialUri;
  final bool useUrlToken;
  final Map<String, String> headers;

  @override
  State<ResolvedUserListPage> createState() => _ResolvedUserListPageState();
}

class UserRelationshipListPage extends StatelessWidget {
  const UserRelationshipListPage({
    super.key,
    required this.api,
    required this.title,
    required this.loadInitial,
  });

  final ZhihuApiClient api;
  final String title;
  final Future<ApiResponse> Function() loadInitial;

  @override
  Widget build(BuildContext context) => PagedListPage(
    title: title,
    api: api,
    loadInitial: loadInitial,
    rowBuilder: (context, value, onTap) =>
        UserRelationshipRow(api: api, value: value, onTap: onTap),
    onObjectTap: (context, value) => openDetectedObject(context, api, value),
    emptyMessage: '这里还没有用户',
  );
}

class UserRelationshipRow extends StatefulWidget {
  const UserRelationshipRow({
    super.key,
    required this.api,
    required this.value,
    this.onTap,
  });

  final ZhihuApiClient api;
  final Map<String, dynamic> value;
  final VoidCallback? onTap;

  @override
  State<UserRelationshipRow> createState() => _UserRelationshipRowState();
}

class _UserRelationshipRowState extends State<UserRelationshipRow> {
  bool? _following;
  var _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    if (!widget.api.canWrite) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('登录后可关注用户')));
      return;
    }
    final person = unwrapObject(widget.value);
    final memberId = personMemberIdOf(person);
    if (memberId.isEmpty) return;
    final wasFollowing = _following ?? person['is_following'] == true;
    setState(() => _busy = true);
    try {
      final response = await widget.api.setUserFollowing(
        memberId,
        following: !wasFollowing,
      );
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      setState(() {
        _following = !wasFollowing;
        person['is_following'] = !wasFollowing;
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

  @override
  Widget build(BuildContext context) {
    final person = unwrapObject(widget.value);
    final name = titleOf(person).isEmpty ? '知乎用户' : titleOf(person);
    final headline = plainText(person['headline'] ?? person['description']);
    final avatar = plainText(
      person['avatar_url'] ?? person['avatar_url_template'],
    );
    final following = _following ?? person['is_following'] == true;
    final isSelf = person['is_self'] == true;
    final validAvatar = Uri.tryParse(avatar)?.scheme == 'https';
    return Material(
      color: ZhPalette.background,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
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
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        cacheWidth: 162,
                        cacheHeight: 162,
                        errorBuilder: (_, _, _) => _RelationshipAvatarFallback(
                          text: name.characters.first,
                        ),
                      )
                    : _RelationshipAvatarFallback(text: name.characters.first),
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
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (headline.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ZhPalette.subtleInk,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isSelf) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  height: 38,
                  child: FilledButton(
                    onPressed: _busy ? null : _toggle,
                    style: FilledButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      backgroundColor: ZhPalette.accentSurface,
                      foregroundColor: ZhPalette.link,
                      disabledBackgroundColor: ZhPalette.accentSurface,
                      disabledForegroundColor: ZhPalette.disabledInk,
                      shape: const StadiumBorder(),
                    ),
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            following ? '已关注' : '＋ 关注',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RelationshipAvatarFallback extends StatelessWidget {
  const _RelationshipAvatarFallback({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: 54,
    height: 54,
    color: ZhPalette.canvas,
    alignment: Alignment.center,
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _ProfileContentSearchPage extends StatefulWidget {
  const _ProfileContentSearchPage({
    required this.api,
    required this.memberId,
    required this.memberName,
  });

  final ZhihuApiClient api;
  final String memberId;
  final String memberName;

  @override
  State<_ProfileContentSearchPage> createState() =>
      _ProfileContentSearchPageState();
}

class _ProfileContentSearchPageState extends State<_ProfileContentSearchPage> {
  late final TextEditingController _query;
  var _submitted = '';

  @override
  void initState() {
    super.initState();
    _query = TextEditingController();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _submitted = query);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: ZhTopBar(
      title: Container(
        height: 42,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: ZhPalette.canvas,
          borderRadius: BorderRadius.circular(22),
        ),
        child: TextField(
          key: const ValueKey('profile-content-search-field'),
          controller: _query,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '搜索 ${widget.memberName} 发布的内容',
            prefixIcon: const Icon(Icons.search_rounded, size: 21),
            suffixIcon: _query.text.isEmpty
                ? null
                : IconButton(
                    tooltip: '清空',
                    onPressed: () {
                      _query.clear();
                      setState(() => _submitted = '');
                    },
                    icon: const Icon(Icons.close_rounded, size: 19),
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    ),
    body: _submitted.isEmpty
        ? Center(
            child: Text(
              '搜索 TA 发布过的回答、文章和想法',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ZhPalette.subtleInk),
            ),
          )
        : PagedListPage(
            key: ValueKey('profile-content-search:$_submitted'),
            title: '',
            api: widget.api,
            embedded: true,
            loadInitial: () => widget.api.getUri(
              widget.api.profileContentSearchInitialUri(
                keyword: _submitted,
                memberHashId: widget.memberId,
              ),
              headers: const {'x-api-version': '3.0.65'},
            ),
            rowBuilder: (context, value, onTap) => _UserProfileFeedRow(
              api: widget.api,
              value: value,
              kind: _UserProfileTabKind.creations,
              onTap: onTap,
            ),
            onObjectTap: (context, value) =>
                openDetectedObject(context, widget.api, value),
            emptyMessage: '没有找到相关内容',
          ),
  );
}

class _ResolvedUserListPageState extends State<ResolvedUserListPage> {
  Object? _state;
  String? _resolvedId;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    setState(() {
      _state = null;
      _resolvedId = null;
    });
    try {
      final response = await widget.api.getUri(
        widget.api.userProfileInitialUri(widget.inputIdentifier),
      );
      if (!mounted) return;
      if (!response.isSuccess || response.jsonMap == null) {
        setState(() => _state = response);
        return;
      }
      final profile = unwrapObject(response.jsonMap!);
      final resolved = widget.useUrlToken
          ? userUrlTokenOfProfile(profile, widget.inputIdentifier)
          : userMemberIdOfProfile(profile, widget.inputIdentifier);
      if (resolved.isEmpty) {
        setState(() => _state = const ApiTransportException('暂时无法打开用户资料'));
        return;
      }
      setState(() => _resolvedId = resolved);
    } catch (error) {
      if (mounted) setState(() => _state = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedId = _resolvedId;
    if (resolvedId != null) {
      final relationshipList = widget.title == '关注者' || widget.title == '关注的人';
      return PagedListPage(
        key: ValueKey('${widget.title}:$resolvedId'),
        title: widget.title,
        api: widget.api,
        loadInitial: () => widget.api.getUri(
          widget.initialUri(resolvedId),
          headers: widget.headers,
        ),
        onObjectTap: (context, value) =>
            openDetectedObject(context, widget.api, value),
        rowBuilder: relationshipList
            ? (context, value, onTap) => UserRelationshipRow(
                api: widget.api,
                value: value,
                onTap: onTap,
              )
            : null,
      );
    }
    final state = _state;
    return Scaffold(
      appBar: ZhTopBar(title: Text(widget.title)),
      body: ZhResponsiveFrame(
        maxWidth: 1040,
        desktopGutter: 24,
        child: state == null
            ? const Center(child: CircularProgressIndicator())
            : ApiErrorView(error: state, onRetry: _resolve),
      ),
    );
  }
}

class _UserPageState extends State<UserPage> {
  late final TextEditingController _member;

  @override
  void initState() {
    super.initState();
    _member = TextEditingController(text: widget.initialMemberId);
  }

  @override
  void dispose() {
    _member.dispose();
    super.dispose();
  }

  String? _id() {
    final value = _member.text.trim();
    if (value.isEmpty || value.length > 256) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入用户 ID')));
      return null;
    }
    return value;
  }

  void _openPage(Widget Function(String id) builder) {
    final id = _id();
    if (id == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder(id)));
  }

  ResolvedUserListPage _list({
    required String title,
    required String id,
    required Uri Function(String resolvedId) initialUri,
    bool useUrlToken = false,
    Map<String, String> headers = const {},
  }) => ResolvedUserListPage(
    title: title,
    api: widget.api,
    inputIdentifier: id,
    initialUri: initialUri,
    useUrlToken: useUrlToken,
    headers: headers,
  );

  @override
  Widget build(BuildContext context) {
    final actions = <_UserAction>[
      _UserAction(
        '用户信息',
        Icons.badge_outlined,
        (id) => UserProfileDetailPage(api: widget.api, memberId: id),
      ),
      _UserAction(
        '关注者',
        Icons.groups_outlined,
        (id) => _list(
          title: '关注者',
          id: id,
          initialUri: widget.api.userFollowersInitialUri,
        ),
      ),
      _UserAction(
        '关注的人',
        Icons.person_search_outlined,
        (id) => _list(
          title: '关注的人',
          id: id,
          initialUri: widget.api.userFolloweesInitialUri,
        ),
      ),
      _UserAction(
        '回答',
        Icons.question_answer_outlined,
        (id) => _list(
          title: '用户回答',
          id: id,
          initialUri: widget.api.userAnswersInitialUri,
        ),
      ),
      _UserAction(
        '文章',
        Icons.article_outlined,
        (id) => _list(
          title: '用户文章',
          id: id,
          initialUri: widget.api.userArticlesInitialUri,
        ),
      ),
      _UserAction(
        '创作文章 Feed',
        Icons.dynamic_feed_outlined,
        (id) => _list(
          title: '用户创作文章',
          id: id,
          initialUri: widget.api.userCreatedArticleFeedInitialUri,
          useUrlToken: true,
        ),
      ),
      _UserAction(
        '贡献文章',
        Icons.library_add_check_outlined,
        (id) => _list(
          title: '用户贡献文章',
          id: id,
          initialUri: widget.api.userIncludedArticlesInitialUri,
        ),
      ),
      _UserAction(
        '创建的专栏',
        Icons.view_column_outlined,
        (id) => _list(
          title: '用户专栏',
          id: id,
          initialUri: widget.api.userColumnsInitialUri,
        ),
      ),
      _UserAction(
        '关注专栏',
        Icons.bookmarks_outlined,
        (id) => _list(
          title: '关注专栏',
          id: id,
          initialUri: widget.api.userFollowingColumnsInitialUri,
        ),
      ),
      _UserAction(
        '关注问题',
        Icons.help_center_outlined,
        (id) => _list(
          title: '关注问题',
          id: id,
          initialUri: widget.api.userFollowingQuestionsInitialUri,
        ),
      ),
      _UserAction(
        '关注收藏集',
        Icons.collections_bookmark_outlined,
        (id) => _list(
          title: '关注收藏集',
          id: id,
          initialUri: widget.api.userFollowingCollectionsInitialUri,
          headers: const {'x-api-version': '3.0.94'},
        ),
      ),
      _UserAction(
        '关注话题',
        Icons.tag_outlined,
        (id) => _list(
          title: '关注话题',
          id: id,
          initialUri: widget.api.userFollowingTopicsInitialUri,
        ),
      ),
    ];
    return Scaffold(
      appBar: widget.initialMemberId.isEmpty
          ? ZhTopBar(title: const Text('用户'))
          : ZhTopBar(title: const Text('用户资料')),
      body: ZhResponsiveFrame(
        maxWidth: 1040,
        desktopGutter: 24,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            ZhSpace.md,
            ZhSpace.sm,
            ZhSpace.md,
            ZhSpace.xl,
          ),
          children: [
            Text('查找用户', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: ZhSpace.xs),
            Text(
              '输入资料链接中的用户 token，查看公开资料与内容列表',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
            ),
            const SizedBox(height: ZhSpace.lg),
            ShadInput(
              controller: _member,
              autocorrect: false,
              placeholder: const Text('用户 ID'),
              constraints: const BoxConstraints(minHeight: 58),
              leading: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.alternate_email_rounded, size: 21),
              ),
              trailing: IconButton(
                tooltip: '查看资料',
                onPressed: () => _openPage(actions.first.builder),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              onSubmitted: (_) => _openPage(actions.first.builder),
            ),
            const SizedBox(height: ZhSpace.md),
            ZhPrimaryButton(
              onPressed: () => _openPage(actions.first.builder),
              icon: Icons.person_search_rounded,
              label: '查看用户资料',
              expand: true,
            ),
            const SizedBox(height: ZhSpace.lg),
            const ZhSectionHeader(title: '内容与关系'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 190,
                childAspectRatio: 2.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _UserActionTile(
                  icon: action.icon,
                  label: action.label,
                  onTap: () => _openPage(action.builder),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
