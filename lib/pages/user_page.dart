import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/follow_item_group.dart';
import '../core/json_tools.dart';
import '../l10n/zh_localization.dart';
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
  Widget build(BuildContext context) {
    return PagedListPage(
      title: title,
      api: api,
      loadInitial: loadInitial,
      rowBuilder: (context, value, onTap) =>
          UserRelationshipRow(api: api, value: value, onTap: onTap),
      onObjectTap: (context, value) => openDetectedObject(context, api, value),
      emptyMessage: context.zhL10n.userEmpty,
    );
  }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.zhL10n.userSignInToFollow)),
      );
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
    final l10n = context.zhL10n;
    final person = unwrapObject(widget.value);
    final name = titleOf(person).isEmpty
        ? l10n.commonZhihuUser
        : titleOf(person);
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
                            following ? l10n.userFollowed : l10n.userFollow,
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
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    return Scaffold(
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
              hintText: l10n.userSearchHint(widget.memberName),
              prefixIcon: const Icon(Icons.search_rounded, size: 21),
              suffixIcon: _query.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.commonClear,
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
                l10n.userSearchPrompt(widget.memberName),
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
                headers: widget.api.profileContentSearchHeaders(),
              ),
              rowBuilder: (context, value, onTap) => _UserProfileFeedRow(
                api: widget.api,
                value: value,
                kind: _UserProfileTabKind.creations,
                onTap: onTap,
              ),
              onObjectTap: (context, value) =>
                  openDetectedObject(context, widget.api, value),
              emptyMessage: l10n.userNoResults,
            ),
    );
  }
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
        setState(
          () => _state = ApiTransportException(context.zhL10n.userLoadFailed),
        );
        return;
      }
      setState(() => _resolvedId = resolved);
    } catch (error) {
      if (mounted) setState(() => _state = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final resolvedId = _resolvedId;
    if (resolvedId != null) {
      final relationshipList =
          widget.title == l10n.userFollowers ||
          widget.title == l10n.userFollowingPeople;
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
            ? const ZhListLoadingSkeleton(topInset: 0, showImages: true)
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
      ).showSnackBar(SnackBar(content: Text(context.zhL10n.userIdRequired)));
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
    final l10n = context.zhL10n;
    final actions = <_UserAction>[
      _UserAction(
        l10n.userInfo,
        Icons.badge_outlined,
        (id) => UserProfileDetailPage(api: widget.api, memberId: id),
      ),
      _UserAction(
        l10n.userFollowers,
        Icons.groups_outlined,
        (id) => _list(
          title: l10n.userFollowers,
          id: id,
          initialUri: widget.api.userFollowersInitialUri,
        ),
      ),
      _UserAction(
        l10n.userFollowingPeople,
        Icons.person_search_outlined,
        (id) => _list(
          title: l10n.userFollowingPeople,
          id: id,
          initialUri: widget.api.userFolloweesInitialUri,
        ),
      ),
      _UserAction(
        l10n.userAnswers,
        Icons.question_answer_outlined,
        (id) => _list(
          title: l10n.userAnswers,
          id: id,
          initialUri: widget.api.userAnswersInitialUri,
        ),
      ),
      _UserAction(
        l10n.userArticles,
        Icons.article_outlined,
        (id) => _list(
          title: l10n.userArticles,
          id: id,
          initialUri: widget.api.userArticlesInitialUri,
        ),
      ),
      _UserAction(
        l10n.userCreatedArticles,
        Icons.dynamic_feed_outlined,
        (id) => _list(
          title: l10n.userCreatedArticles,
          id: id,
          initialUri: widget.api.userCreatedArticleFeedInitialUri,
          useUrlToken: true,
        ),
      ),
      _UserAction(
        l10n.userContributedArticles,
        Icons.library_add_check_outlined,
        (id) => _list(
          title: l10n.userContributedArticles,
          id: id,
          initialUri: widget.api.userIncludedArticlesInitialUri,
        ),
      ),
      _UserAction(
        l10n.userColumns,
        Icons.view_column_outlined,
        (id) => _list(
          title: l10n.userColumns,
          id: id,
          initialUri: widget.api.userColumnsInitialUri,
        ),
      ),
      _UserAction(
        l10n.userFollowingColumns,
        Icons.bookmarks_outlined,
        (id) => _list(
          title: l10n.userFollowingColumns,
          id: id,
          initialUri: widget.api.userFollowingColumnsInitialUri,
        ),
      ),
      _UserAction(
        l10n.userFollowingQuestions,
        Icons.help_center_outlined,
        (id) => _list(
          title: l10n.userFollowingQuestions,
          id: id,
          initialUri: widget.api.userFollowingQuestionsInitialUri,
        ),
      ),
      _UserAction(
        l10n.userFollowingCollections,
        Icons.collections_bookmark_outlined,
        (id) => _list(
          title: l10n.userFollowingCollections,
          id: id,
          initialUri: widget.api.userFollowingCollectionsInitialUri,
        ),
      ),
      _UserAction(
        l10n.userFollowingTopics,
        Icons.tag_outlined,
        (id) => _list(
          title: l10n.userFollowingTopics,
          id: id,
          initialUri: widget.api.userFollowingTopicsInitialUri,
        ),
      ),
    ];
    return Scaffold(
      appBar: widget.initialMemberId.isEmpty
          ? ZhTopBar(title: Text(l10n.userTitle))
          : ZhTopBar(title: Text(l10n.userProfileTitle)),
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
            Text(
              l10n.userFindTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: ZhSpace.xs),
            Text(
              l10n.userFindSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
            ),
            const SizedBox(height: ZhSpace.lg),
            ShadInput(
              controller: _member,
              autocorrect: false,
              placeholder: Text(l10n.userIdHint),
              constraints: const BoxConstraints(minHeight: 58),
              leading: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.alternate_email_rounded, size: 21),
              ),
              trailing: IconButton(
                tooltip: l10n.userViewProfile,
                onPressed: () => _openPage(actions.first.builder),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              onSubmitted: (_) => _openPage(actions.first.builder),
            ),
            const SizedBox(height: ZhSpace.md),
            ZhPrimaryButton(
              onPressed: () => _openPage(actions.first.builder),
              icon: Icons.person_search_rounded,
              label: l10n.userViewProfile,
              expand: true,
            ),
            const SizedBox(height: ZhSpace.lg),
            ZhSectionHeader(title: l10n.userContentRelations),
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
