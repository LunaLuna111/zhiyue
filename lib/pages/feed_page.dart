import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/content_filter_stats.dart';
import '../core/follow_item_group.dart';
import '../core/json_tools.dart';
import '../core/negative_feedback.dart';
import '../core/recommendation_behavior.dart';
import '../core/recommendation_engine.dart';
import '../core/session_store.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import '../widgets/api_views.dart';
import '../widgets/follow_item_group_card.dart';
import '../widgets/negative_feedback_sheet.dart';
import 'content_pages.dart';
import 'paged_list_page.dart';
import 'salt_page.dart';
import 'search_page.dart';
import 'web_page.dart';
part 'feed_parts/feed_stream.dart';
part 'feed_parts/following.dart';
part 'feed_parts/story_category_page.dart';
part 'feed_parts/story_category_widgets.dart';
part 'feed_parts/story_filters.dart';
part 'feed_parts/story_category_cards.dart';

class HomeFeedController extends ChangeNotifier {
  HomeFeedChannel _channel = HomeFeedChannel.recommend;
  int _refreshRevision = 0;

  HomeFeedChannel get channel => _channel;
  int get refreshRevision => _refreshRevision;

  void select(HomeFeedChannel value) {
    if (_channel == value) return;
    _channel = value;
    notifyListeners();
  }

  void updateFromPage(HomeFeedChannel value) {
    if (_channel == value) return;
    _channel = value;
    notifyListeners();
  }

  void returnToTopAndRefresh() {
    _refreshRevision += 1;
    notifyListeners();
  }
}

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    required this.api,
    this.controller,
    this.onMenuPressed,
  });

  final ZhihuApiClient api;
  final HomeFeedController? controller;
  final VoidCallback? onMenuPressed;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  late List<HomeFeedChannel> _channels;
  late PageController _pageController;
  late HomeFeedChannel _channel;
  late final _HomeFeedPreloadPool _preloadPool;
  late String _requestScope;
  int _requestScopeEpoch = 0;
  late int _displayPreferencesFingerprint;
  late int _handledRefreshRevision;
  late final Map<HomeFeedChannel, ValueNotifier<int>> _refreshSignals = {
    for (final channel in HomeFeedChannel.values) channel: ValueNotifier(0),
  };
  Timer? _hiddenPreloadTimer;
  int _preloadGeneration = 0;
  bool _channelDragActive = false;
  int _channelDragStartIndex = 0;
  int? _channelDragTargetIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _channel = widget.controller?.channel ?? HomeFeedChannel.recommend;
    _channels = List<HomeFeedChannel>.from(widget.api.session.homeFeedOrder);
    _pageController = PageController(initialPage: _channels.indexOf(_channel));
    _preloadPool = _HomeFeedPreloadPool(widget.api);
    _requestScope = _sessionRequestScope();
    _displayPreferencesFingerprint = _currentDisplayPreferencesFingerprint;
    _handledRefreshRevision = widget.controller?.refreshRevision ?? 0;
    _preloadVisibleChannels();
    widget.api.session.addListener(_sessionChanged);
    widget.controller?.addListener(_controllerChanged);
  }

  @override
  void dispose() {
    widget.api.session.removeListener(_sessionChanged);
    widget.controller?.removeListener(_controllerChanged);
    _hiddenPreloadTimer?.cancel();
    _pageController.dispose();
    for (final signal in _refreshSignals.values) {
      signal.dispose();
    }
    super.dispose();
  }

  void _controllerChanged() {
    if (!mounted) return;
    final controller = widget.controller;
    if (controller == null) return;
    if (controller.refreshRevision != _handledRefreshRevision) {
      _handledRefreshRevision = controller.refreshRevision;
      _preloadPool.invalidate(_channel);
      final signal = _refreshSignals[_channel]!;
      signal.value += 1;
    }
    if (controller.channel != _channel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _selectChannel(controller.channel);
      });
    }
  }

  void _sessionChanged() {
    if (!mounted) return;
    final requestScope = _sessionRequestScope();
    final requestScopeChanged = requestScope != _requestScope;
    final next = widget.api.session.homeFeedOrder;
    final channelsChanged = !listEquals(_channels, next);
    final displayPreferencesFingerprint = _currentDisplayPreferencesFingerprint;
    final displayPreferencesChanged =
        displayPreferencesFingerprint != _displayPreferencesFingerprint;

    // SessionStore also reports local search/browsing-history writes. Those
    // changes do not affect this page and must not rebuild a covered feed: the
    // resulting repaint looks like the parent refreshed when a detail route
    // is popped.
    if (!requestScopeChanged &&
        !channelsChanged &&
        !displayPreferencesChanged) {
      return;
    }
    _displayPreferencesFingerprint = displayPreferencesFingerprint;
    if (requestScopeChanged) {
      _requestScope = requestScope;
      _requestScopeEpoch += 1;
      // A completed response cannot be cancelled. Dropping every cached
      // Future and changing the subtree epoch ensures a late private response
      // from the previous account only resumes a disposed tab. Guest token
      // rotation intentionally remains in the anonymous scope below.
      _preloadPool.clear();
    }
    _preloadVisibleChannels();
    if (!channelsChanged) {
      setState(() {});
      return;
    }
    final previousController = _pageController;
    setState(() {
      _channels = List<HomeFeedChannel>.from(next);
      _pageController = PageController(
        initialPage: _channels.indexOf(_channel),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      previousController.dispose();
    });
  }

  void _preloadVisibleChannels() {
    final hasFollowingAccess =
        widget.api.session.hasAccountSession ||
        widget.api.session.sessionKind == 'imported';
    final generation = ++_preloadGeneration;
    _hiddenPreloadTimer?.cancel();

    // The selected page is the only request that can improve the first
    // frame. Starting every other section in the same isolate turn makes
    // response parsing and image metadata work compete with the first scroll.
    final eligibleChannels = HomeFeedChannel.values
        .where(
          // The official follow feed is account-scoped. Avoid a guaranteed
          // 403 during anonymous startup, but still load it on demand if
          // selected.
          (channel) =>
              channel != HomeFeedChannel.following || hasFollowingAccess,
        )
        .toList(growable: false);
    if (eligibleChannels.contains(_channel)) {
      _preloadPool.warm(_channel).ignore();
    }

    final hiddenChannels = eligibleChannels
        .where((channel) => channel != _channel)
        .toList(growable: false);
    if (hiddenChannels.isEmpty) return;

    // Keep the first interaction window free. Hidden sections are warmed one
    // at a time after the current page has had a chance to settle, so a tab
    // tap can reuse a response without creating a four-request burst.
    _hiddenPreloadTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted || generation != _preloadGeneration) return;
      unawaited(_warmHiddenChannels(hiddenChannels, generation));
    });
  }

  void _cancelHiddenPreloadForInteraction() {
    _hiddenPreloadTimer?.cancel();
    _hiddenPreloadTimer = null;
    // An already-running hidden request cannot be cancelled at the transport
    // layer, but it can be prevented from starting the next section as soon
    // as the user begins a real channel interaction.
    _preloadGeneration++;
  }

  Future<void> _warmHiddenChannels(
    List<HomeFeedChannel> channels,
    int generation,
  ) async {
    for (var index = 0; index < channels.length; index++) {
      if (!mounted || generation != _preloadGeneration) return;
      try {
        await _preloadPool.warm(channels[index]);
      } catch (_) {
        // The selected page owns user-visible error handling. A background
        // section failure should not interrupt the remaining warm-up queue.
      }
      if (index + 1 < channels.length) {
        await Future<void>.delayed(const Duration(milliseconds: 220));
      }
    }
  }

  String _sessionRequestScope() {
    final session = widget.api.session;
    if (session.sessionKind == 'account') {
      final account = session.accountUserId.isNotEmpty
          ? session.accountUserId
          : session.accountUid;
      return account.isNotEmpty
          ? 'account:$account'
          : 'account:${Object.hash(session.authorization, session.udid)}';
    }
    if (session.sessionKind == 'imported') {
      // Imported credentials have no stable public principal ID. Their
      // SessionStore generation changes for an actual import/replacement, but
      // deliberately not for installation-scoped MS-ID discovery.
      return 'imported:${session.credentialRevision}';
    }
    return 'anonymous';
  }

  int get _currentDisplayPreferencesFingerprint => Object.hash(
    widget.api.session.feedDensity,
    widget.api.session.showFeedImages,
    widget.api.session.showFeedMetrics,
    widget.api.session.recommendationMode,
  );

  void _selectChannel(HomeFeedChannel channel) {
    if (_channel == channel) return;
    final index = _channels.indexOf(channel);
    if (index < 0 || !_pageController.hasClients) return;
    _cancelHiddenPreloadForInteraction();
    // A tab tap is an explicit destination change. Jumping directly avoids
    // compositing two image-heavy feed pages for 260ms; center swipe gestures
    // still retain the physical drag and settle animation below.
    _preloadPool.warm(channel).ignore();
    setState(() => _channel = channel);
    _pageController.jumpToPage(index);
  }

  void _pageChanged(int index) {
    final next = _channels[index];
    if (_channel != next) setState(() => _channel = next);
    widget.controller?.updateFromPage(next);
  }

  double _channelGestureInset(double width) =>
      (width * .18).clamp(72.0, 120.0).toDouble();

  bool _isFollowingHeaderGestureRegion(double y) {
    if (_channel != HomeFeedChannel.following) return false;
    // The people rail and its filter chips own horizontal drags. Keeping the
    // tab pager out of this band prevents a sideways swipe on the rail from
    // switching the whole home section (or starting a drawer-edge gesture).
    final top = MediaQuery.viewPaddingOf(context).top;
    final bottom = top + 122 + 68;
    return y >= top && y <= bottom;
  }

  void _channelDragStart(DragStartDetails details, double width) {
    final inset = _channelGestureInset(width);
    _channelDragTargetIndex = null;
    _channelDragActive =
        !_isFollowingHeaderGestureRegion(details.localPosition.dy) &&
        details.localPosition.dx >= inset &&
        details.localPosition.dx <= width - inset &&
        _pageController.hasClients &&
        _pageController.position.hasContentDimensions;
    if (_channelDragActive) _cancelHiddenPreloadForInteraction();
    _channelDragStartIndex = _channels.indexOf(_channel);
  }

  void _channelDragUpdate(DragUpdateDetails details) {
    if (!_channelDragActive || !_pageController.hasClients) return;
    final position = _pageController.position;
    if (!position.hasContentDimensions) return;
    final direction = details.delta.dx < 0
        ? 1
        : details.delta.dx > 0
        ? -1
        : 0;
    if (direction != 0) {
      final targetIndex = (_channelDragStartIndex + direction)
          .clamp(0, _channels.length - 1)
          .toInt();
      final nextTargetIndex = targetIndex == _channelDragStartIndex
          ? null
          : targetIndex;
      if (_channelDragTargetIndex != nextTargetIndex) {
        _channelDragTargetIndex = nextTargetIndex;
        if (nextTargetIndex != null) {
          _preloadPool.warm(_channels[nextTargetIndex]).ignore();
        }
        setState(() {});
      }
    }
    final target = (position.pixels - details.delta.dx).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _pageController.jumpTo(target);
  }

  void _channelDragEnd(DragEndDetails details) {
    if (!_channelDragActive || !_pageController.hasClients) return;
    _channelDragActive = false;
    final page = _pageController.page ?? _channelDragStartIndex.toDouble();
    final velocity = details.primaryVelocity ?? 0;
    var target = _channelDragStartIndex;
    if (velocity.abs() >= 450) {
      target += velocity < 0 ? 1 : -1;
    } else if ((page - _channelDragStartIndex).abs() >= .22) {
      target += page > _channelDragStartIndex ? 1 : -1;
    }
    target = target.clamp(0, _channels.length - 1);
    if (target != _channelDragStartIndex) {
      _channelDragTargetIndex = target;
      _preloadPool.warm(_channels[target]).ignore();
    }
    if (mounted) setState(() {});
    _settleChannelDrag(target);
  }

  void _channelDragCancel() {
    if (!_channelDragActive || !_pageController.hasClients) return;
    _channelDragActive = false;
    _settleChannelDrag(
      _channelDragStartIndex,
      duration: const Duration(milliseconds: 220),
    );
  }

  void _settleChannelDrag(
    int target, {
    Duration duration = const Duration(milliseconds: 240),
  }) {
    final settlingTarget = _channelDragTargetIndex;
    unawaited(
      _pageController
          .animateToPage(target, duration: duration, curve: Curves.easeOutCubic)
          .whenComplete(() {
            if (!mounted || settlingTarget != _channelDragTargetIndex) {
              return;
            }
            setState(() => _channelDragTargetIndex = null);
          }),
    );
  }

  Widget _pageAt(int index) {
    final channel = _channels[index];
    final isActive = _isChannelActive(channel);
    // The home body is already hosted by the shell's edge-to-edge glass
    // scaffold. Its scroll views contribute the system safe-area padding;
    // reserving it a second time here creates the blank band seen below the
    // channel tabs. Keep only the floating tab track's height in the page
    // contract so every channel starts at the same visual edge.
    final contentTopInset = ZhLiquidGlassTopNavigation.barHeight * .75;
    final refreshSignal = _refreshSignals[channel]!;
    final requestScopeEpoch = _requestScopeEpoch;
    bool isRequestScopeCurrent() =>
        mounted && requestScopeEpoch == _requestScopeEpoch;
    if (channel == HomeFeedChannel.story) {
      return ZhResponsiveFrame(
        key: ValueKey('home-${channel.name}-scope-$_requestScopeEpoch'),
        maxWidth: 1120,
        desktopGutter: 24,
        child: SaltStoryHome(
          key: const ValueKey('home-story-feed'),
          api: widget.api,
          isActive: isActive,
          // The story feed shares the same floating channel chrome as the
          // ordinary feeds. Do not reserve the track twice.
          topInset: contentTopInset + 48,
          initialResponse: isActive ? _preloadPool.warm(channel) : null,
          isRequestScopeCurrent: isRequestScopeCurrent,
          refreshSignal: refreshSignal,
          onOpenCard: _openStoryCard,
          onOpenShortcut: _openStoryShortcut,
        ),
      );
    }
    return ZhResponsiveFrame(
      key: ValueKey('home-${channel.name}-scope-$_requestScopeEpoch'),
      maxWidth: 1120,
      desktopGutter: 24,
      child: _FeedStreamTab(
        key: ValueKey('home-${channel.name}-feed'),
        api: widget.api,
        channel: channel,
        isActive: isActive,
        initialResponse: isActive ? _preloadPool.warm(channel) : null,
        isRequestScopeCurrent: isRequestScopeCurrent,
        refreshSignal: refreshSignal,
        topInset: contentTopInset,
        compact: widget.api.session.feedDensity == FeedDensity.compact,
        showImages: widget.api.session.showFeedImages,
        showMetrics: widget.api.session.showFeedMetrics,
        recommendationMode: channel == HomeFeedChannel.recommend
            ? widget.api.session.recommendationMode
            : RecommendationMode.server,
      ),
    );
  }

  bool _isChannelActive(HomeFeedChannel channel) {
    if (_channel == channel) return true;
    final targetIndex = _channelDragTargetIndex;
    return targetIndex != null &&
        targetIndex >= 0 &&
        targetIndex < _channels.length &&
        _channels[targetIndex] == channel;
  }

  void _openStoryShortcut(Map<String, dynamic> value) {
    final type = plainText(value['card_type']).toLowerCase();
    if (type == 'bookshelf') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => SaltPage(api: widget.api)));
      return;
    }
    if (type == 'category') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SaltStoryCategoryPage(api: widget.api),
        ),
      );
      return;
    }
    if (type == 'well' || type == 'long_story' || type == 'longstory') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              SaltStoryLongFormPage(api: widget.api, shortcut: value),
        ),
      );
      return;
    }
    _openStoryCard(value);
  }

  void _openStoryCard(Map<String, dynamic> value) {
    final object = unwrapObject(value);
    final navigation = parseSaltStoryNavigation(object);
    final businessId = navigation?.businessId ?? idOf(object);
    if (!_saltStoryIdUsable(businessId)) {
      openDetectedObject(context, widget.api, value);
      return;
    }
    final page = navigation?.opensReader == true
        ? SaltReaderPage(
            api: widget.api,
            businessId: businessId,
            sectionId: navigation!.sectionId!,
          )
        : SaltProductPage(
            api: widget.api,
            businessId: businessId,
            businessType: 'paid_column',
            title: titleOf(value),
            initialMetadata: object,
          );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // The iOS-style top chrome owns the status-bar inset and floats over
      // the feed. Removing only the layout padding lets the first card/image
      // continue underneath the glass instead of leaving a blank white strip.
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              key: const ValueKey('home-feed-middle-swipe'),
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (details) =>
                  _channelDragStart(details, constraints.maxWidth),
              onHorizontalDragUpdate: _channelDragUpdate,
              onHorizontalDragEnd: _channelDragEnd,
              onHorizontalDragCancel: _channelDragCancel,
              child: PageView.builder(
                key: ValueKey(
                  'home-feed-${_channels.map((item) => item.name).join('-')}',
                ),
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _channels.length,
                onPageChanged: _pageChanged,
                itemBuilder: (_, index) => _pageAt(index),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ZhLiquidGlassTopNavigation(
              labels: [for (final channel in _channels) channel.label],
              selectedIndex: _channels.indexOf(_channel),
              onTabSelected: (index) => _selectChannel(_channels[index]),
              onMenuPressed: widget.onMenuPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFeedPreloadPool {
  _HomeFeedPreloadPool(this.api);

  final ZhihuApiClient api;
  final Map<HomeFeedChannel, Future<ApiResponse>> _initial = {};

  Future<ApiResponse> warm(HomeFeedChannel channel) {
    final cached = _initial[channel];
    if (cached != null) return cached;
    late final Future<ApiResponse> request;
    request = _request(channel).then(
      (response) {
        if (!response.isSuccess && identical(_initial[channel], request)) {
          _initial.remove(channel);
        }
        return response;
      },
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_initial[channel], request)) _initial.remove(channel);
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
    _initial[channel] = request;
    return request;
  }

  void invalidate(HomeFeedChannel channel) => _initial.remove(channel);

  void clear() => _initial.clear();

  Future<ApiResponse> _request(HomeFeedChannel channel) => switch (channel) {
    HomeFeedChannel.following => api.getUri(
      api.followingFeedInitialUri(
        feedType: _followingFeedTypeForLabel(_followingChoice),
      ),
      headers: _homeFeedRequestHeaders(channel),
    ),
    HomeFeedChannel.hot => api.getUri(
      api.hotListInitialUri(),
      headers: _homeFeedRequestHeaders(channel),
    ),
    HomeFeedChannel.story => api.getSaltUri(api.saltStoryHomeUri()),
    HomeFeedChannel.recommend => api.getUri(api.recommendationFeedInitialUri()),
  };
}

Map<String, String> _homeFeedRequestHeaders(HomeFeedChannel channel) =>
    switch (channel) {
      HomeFeedChannel.following => const {
        'x-api-version': '3.0.93',
        'need_debug': '0',
      },
      HomeFeedChannel.hot => const {
        'x-api-version': '3.1.8',
        'x-ad-styles': '',
        'isPreload': 'false',
      },
      _ => const {},
    };

bool isHomeFeedServiceRow(Map<String, dynamic> row) {
  final object = unwrapObject(row);
  for (final candidate in [row, object]) {
    for (final key in const ['type', 'card_type', 'cardType', 'style_type']) {
      final marker = plainText(
        candidate[key],
      ).toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');
      if (marker == 'businesscard') return true;
    }
  }
  return false;
}

List<Map<String, dynamic>> extractHomeFeedRows(
  Object? value, {
  bool includeServiceRows = false,
}) => extractRows(value)
    .where((row) {
      if (isHomeFeedServiceRow(row)) return includeServiceRows;
      if (isFollowItemGroupRow(row)) {
        return followItemGroupChildren(row).isNotEmpty;
      }
      return true;
    })
    .toList(growable: false);
