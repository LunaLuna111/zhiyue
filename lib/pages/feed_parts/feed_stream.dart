part of '../feed_page.dart';

const _followingChoice = '精选';
const _followingLatest = '最新';
const _followingIdeas = '想法';
const _followingFilters = <String>[
  _followingChoice,
  _followingLatest,
  _followingIdeas,
];

// The tab label is presentation-only.  FollowSubFragment passes the native
// feed type to /moments_v3, so never send the Chinese label as the query value.
const _followingFeedTypes = <String, String>{
  _followingChoice: 'recommend',
  _followingLatest: 'latest',
  _followingIdeas: 'pin',
};

String _followingFeedTypeForLabel(String label) =>
    _followingFeedTypes[label] ?? 'recommend';

class _FeedStreamTab extends StatefulWidget {
  const _FeedStreamTab({
    super.key,
    required this.api,
    required this.channel,
    required this.isActive,
    required this.topInset,
    required this.compact,
    required this.showImages,
    required this.showMetrics,
    required this.recommendationMode,
    required this.refreshSignal,
    required this.isRequestScopeCurrent,
    this.initialResponse,
  });
  final ZhihuApiClient api;
  final HomeFeedChannel channel;
  final bool isActive;
  final double topInset;
  final bool compact;
  final bool showImages;
  final bool showMetrics;
  final RecommendationMode recommendationMode;
  final ValueListenable<int> refreshSignal;
  final bool Function() isRequestScopeCurrent;
  final Future<ApiResponse>? initialResponse;
  @override
  State<_FeedStreamTab> createState() => _FeedStreamTabState();
}

class _FeedStreamTabState extends State<_FeedStreamTab>
    with AutomaticKeepAliveClientMixin {
  static const _feedbackCacheLimit = 24;
  final _rows = <Map<String, dynamic>>[];
  final _seenRows = <String>{};
  final _rowKeys = Map<Map<String, dynamic>, String>.identity();
  final _expandedFollowGroups = <String>{};
  final _negativeFeedbackPreloads = <String, Future<ApiResponse>>{};
  final _scrollController = ScrollController();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Object? _error;
  bool _loading = false;
  bool _refreshing = false;
  bool _programmaticRefreshing = false;
  VoidCallback? _cancelImageWarmup;
  String? _next;
  bool _consumedInitialResponse = false;
  String _followingFilter = _followingChoice;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    widget.refreshSignal.addListener(_refreshRequested);
    RecommendationBehaviorStore.instance.addListener(_behaviorChanged);
    unawaited(RecommendationBehaviorStore.instance.load());
    if (widget.isActive) _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant _FeedStreamTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.refreshSignal, widget.refreshSignal)) {
      oldWidget.refreshSignal.removeListener(_refreshRequested);
      widget.refreshSignal.addListener(_refreshRequested);
    }
    final becameActive = !oldWidget.isActive && widget.isActive;
    if (becameActive && _rows.isEmpty && !_loading) {
      _consumedInitialResponse = false;
      _load(reset: true);
    } else if (!identical(oldWidget.initialResponse, widget.initialResponse) &&
        _rows.isEmpty &&
        !_loading) {
      _consumedInitialResponse = false;
      _load(reset: true);
    }
    if (oldWidget.recommendationMode != widget.recommendationMode &&
        _rows.length > 1) {
      final ranked = rankHomeFeedRows(
        _rows,
        mode: widget.recommendationMode,
        localSignals: _localRecommendationSignals,
      );
      setState(() {
        _rows
          ..clear()
          ..addAll(ranked);
      });
    }
  }

  Iterable<String> get _localRecommendationSignals => widget
      .api
      .session
      .browsingHistory
      .expand((entry) => [entry.title, entry.excerpt, entry.author])
      .followedBy(RecommendationBehaviorStore.instance.profile.signalDocuments);

  @override
  void dispose() {
    _cancelImageWarmup?.call();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    widget.refreshSignal.removeListener(_refreshRequested);
    RecommendationBehaviorStore.instance.removeListener(_behaviorChanged);
    super.dispose();
  }

  void _behaviorChanged() {
    if (!mounted ||
        _rows.length < 2 ||
        widget.channel != HomeFeedChannel.recommend) {
      return;
    }
    final ranked = rankHomeFeedRows(
      _rows,
      mode: widget.recommendationMode,
      localSignals: _localRecommendationSignals,
    );
    setState(() {
      _rows
        ..clear()
        ..addAll(ranked);
    });
  }

  void _refreshRequested() {
    if (!_loading) unawaited(_returnToTopAndRefresh());
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_loading || _programmaticRefreshing || _next == null) return;
    if (_scrollController.position.extentAfter < 620) _load(reset: false);
  }

  void _warmRowBeforeOpen(Map<String, dynamic> row) {
    if (!widget.showImages || !widget.api.session.prefetchImages) return;
    // The card is still on screen while the detail route is pushed. Retain its
    // decoded frame before that route starts decoding large body images, so a
    // later pop can reuse the exact feed-sized bitmap without a blank flash.
    _cancelImageWarmup = prefetchObjectImages(
      context,
      [row],
      limit: 4,
      concurrency: 1,
      cacheFeedPresentation: true,
      includeAvatars: false,
      deferUntilPostFrame: false,
      warmupDelay: Duration.zero,
      retainDecodedFrames: true,
    );
  }

  Future<void> _returnToTopAndRefresh() async {
    if (_loading) return;
    final isRequestScopeCurrent = widget.isRequestScopeCurrent;
    setState(() => _programmaticRefreshing = true);
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      // A reselect is an explicit "back to top" action. Jumping avoids
      // building every intermediate feed row on a long list before the
      // refresh indicator can appear.
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
    try {
      // Reuse the actual RefreshIndicator state instead of painting a custom
      // spinner. This gives a selected-tab refresh the same position, curve,
      // and settle animation as a pull-to-refresh gesture.
      final indicator = _refreshIndicatorKey.currentState;
      if (indicator == null) {
        await _load(reset: true, refreshing: true);
      } else {
        await indicator.show(atTop: true);
      }
    } finally {
      if (mounted && isRequestScopeCurrent()) {
        setState(() => _programmaticRefreshing = false);
      }
    }
  }

  Map<String, String> get _requestHeaders =>
      _homeFeedRequestHeaders(widget.channel);
  Future<ApiResponse> _initialRequest() => switch (widget.channel) {
    HomeFeedChannel.following => widget.api.getUri(
      widget.api.followingFeedInitialUri(
        feedType: _followingFeedTypeForLabel(_followingFilter),
      ),
      headers: _requestHeaders,
    ),
    HomeFeedChannel.hot => widget.api.getUri(
      widget.api.hotListInitialUri(),
      headers: _requestHeaders,
    ),
    _ => widget.api.getUri(widget.api.recommendationFeedInitialUri()),
  };
  Future<ApiResponse> _initialOrPreloadedRequest() {
    final initialResponse = widget.initialResponse;
    if (widget.channel == HomeFeedChannel.following &&
        _followingFilter != _followingChoice) {
      return _initialRequest();
    }
    if (!_consumedInitialResponse && initialResponse != null) {
      _consumedInitialResponse = true;
      return initialResponse;
    }
    return _initialRequest();
  }

  void _selectFollowingFilter(String filter) {
    if (widget.channel != HomeFeedChannel.following ||
        !_followingFilters.contains(filter) ||
        filter == _followingFilter ||
        _loading) {
      return;
    }
    setState(() => _followingFilter = filter);
    // A preloaded response is only valid for the default 精选 tab. Do not
    // consume it when the user switches to 最新/想法. Keep the currently
    // visible rows while the new filter is fetched; clearing them here makes
    // the whole page flash to a blank loading state on every filter tap.
    _consumedInitialResponse = true;
    if (!_loading) unawaited(_load(reset: true, refreshing: true));
  }

  String _rowKey(Map<String, dynamic> row) {
    return _rowKeys.putIfAbsent(row, () {
      final type = typeOf(row);
      final id = idOf(row);
      if (type.isNotEmpty && id.isNotEmpty) return '$type:$id';
      return '${plainText(row['type'])}:${plainText(row['id'])}:${titleOf(row)}';
    });
  }

  Future<void> _load({required bool reset, bool refreshing = false}) async {
    if (_loading) return;
    // Capture the validator belonging to the Future being started. The parent
    // invalidates it synchronously when the account scope changes, before the
    // keyed subtree is disposed on the next frame.
    final isRequestScopeCurrent = widget.isRequestScopeCurrent;
    bool canCommit() => mounted && isRequestScopeCurrent();
    setState(() {
      _loading = true;
      _refreshing = refreshing;
      _error = null;
      if (reset) _negativeFeedbackPreloads.clear();
      if (reset && !refreshing) {
        _rows.clear();
        _seenRows.clear();
        _rowKeys.clear();
        _expandedFollowGroups.clear();
        _next = null;
      }
    });
    try {
      final response = reset
          ? await (refreshing
                ? _initialRequest()
                : _initialOrPreloadedRequest())
          : await widget.api.getUri(
              widget.api.validatePagingUri(_next!),
              headers: _requestHeaders,
            );
      if (!mounted || !isRequestScopeCurrent()) return;
      if (!response.isSuccess) {
        setState(() {
          _error = widget.channel == HomeFeedChannel.following
              ? response
              : ApiFailure.forAnonymousRead(response);
          _loading = false;
          _refreshing = false;
        });
      } else {
        final incoming = rankHomeFeedRows(
          extractHomeFeedRows(
            response.json,
            includeServiceRows: widget.channel == HomeFeedChannel.following,
          ),
          mode: widget.recommendationMode,
          localSignals: _localRecommendationSignals,
        );
        if (widget.api.session.prefetchImages && widget.showImages) {
          _cancelImageWarmup = prefetchObjectImages(
            context,
            incoming,
            // Warming dozens of 960px decodes competes directly with the
            // first fling. Warm content thumbnails after the first
            // interaction window with one worker; the lazy list owns the
            // rest as it approaches the viewport.
            limit: 8,
            concurrency: 1,
            avatarCacheSize: 72,
            cacheFeedPresentation: true,
            includeAvatars: false,
            warmupDelay: const Duration(milliseconds: 600),
            retainDecodedFrames: true,
          );
        }
        // A refresh returns a new first page, but the rows already on screen
        // are still useful history. Keep them after the fresh rows so a
        // refresh does not make older recommendations disappear from the
        // scrollable feed.
        final previousRows = reset && refreshing
            ? List<Map<String, dynamic>>.of(_rows)
            : const <Map<String, dynamic>>[];
        setState(() {
          if (reset) {
            _rows.clear();
            _seenRows.clear();
            _rowKeys.clear();
            _next = null;
          }
          for (final row in incoming) {
            if (_seenRows.add(_rowKey(row))) _rows.add(row);
          }
          if (reset && refreshing) {
            for (final row in previousRows) {
              if (_seenRows.add(_rowKey(row))) _rows.add(row);
            }
          }
          final candidate = pagingNext(response.json);
          _next = reset && refreshing
              ? candidate
              : candidate == _next
              ? null
              : candidate;
          _loading = false;
          _refreshing = false;
        });
      }
    } catch (error) {
      if (canCommit()) {
        setState(() {
          _error = error;
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  void _openNetworkVerification() {
    unawaited(_openNetworkVerificationAndReload());
  }

  Future<void> _openNetworkVerificationAndReload() async {
    await openZhihuSafetyVerification(context);
    if (!mounted || !widget.isRequestScopeCurrent()) return;
    await _load(reset: true);
  }

  String _emptyMessage(AppLocalizations l10n) => switch (widget.channel) {
    HomeFeedChannel.following => l10n.feedEmptyFollowing,
    HomeFeedChannel.hot => l10n.feedEmptyHot,
    _ => l10n.feedEmptyRecommend,
  };
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        RefreshIndicator(
          key: _refreshIndicatorKey,
          // The feed body is edge-to-edge under the floating four-channel
          // track. Keep the pull-to-refresh affordance below that track so it
          // is visible instead of being painted behind the selected tab.
          edgeOffset: widget.topInset + ZhLiquidGlassTopNavigation.barHeight,
          displacement: 24,
          onRefresh: () => _load(reset: true, refreshing: true),
          child: _buildList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    final l10n = context.zhL10n;
    if (!widget.isActive && _rows.isEmpty && !_loading) {
      // PageView keeps a neighboring child mounted for a smooth settle. Do
      // not initialize a second feed just because it was laid out; it will
      // become active on the first drag/tap that actually targets it.
      return const SizedBox.expand();
    }
    final followingHeader = widget.channel == HomeFeedChannel.following;
    final headerCount = followingHeader ? 2 : 0;
    if (_loading && _rows.isEmpty && !_refreshing) {
      return ZhListLoadingSkeleton(
        key: ValueKey('home-${widget.channel.name}-scroll'),
        // The following page has a second people/filter header skeleton. Give
        // that top shimmer below the floating channel bar and its refractive
        // backdrop. Account for the device status inset so it stays clear on
        // both the phone emulator and devices with a taller status area.
        topInset:
            widget.topInset +
            (followingHeader ? MediaQuery.viewPaddingOf(context).top + 24 : 0),
        showImages: widget.showImages,
        headerHeight: followingHeader ? 96 : 0,
      );
    }
    if (_error != null && _rows.isEmpty) {
      return ListView(
        key: ValueKey('home-${widget.channel.name}-scroll'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: widget.topInset),
          SizedBox(
            height: 500,
            child: ApiErrorView(
              error: _error!,
              onRetry: () => _load(reset: true),
              onOpenNetworkVerification: _openNetworkVerification,
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      key: ValueKey('home-${widget.channel.name}-scroll'),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      // Keep roughly one image-bearing card ready on either side without
      // letting PageView's neighboring feed build a large second cache.
      scrollCacheExtent: const ScrollCacheExtent.pixels(320),
      itemCount: _rows.length + headerCount + 2,
      itemBuilder: (context, index) {
        if (index == 0) return SizedBox(height: widget.topInset);
        var cursor = index - 1;
        if (followingHeader && cursor == 0) {
          return _FollowingPeopleStrip(
            key: const ValueKey('following-people-strip'),
            api: widget.api,
            onPersonTap: (person) => _openFollowingPersonRecent(person),
            onDiscoverTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      SearchPage(api: widget.api, focusOnOpen: true),
                ),
              );
            },
          );
        }
        if (followingHeader && cursor == 1) {
          return _FollowingFilterBar(
            key: const ValueKey('following-filter-bar'),
            filters: _followingFilters,
            selected: _followingFilter,
            onSelected: _selectFollowingFilter,
          );
        }
        if (followingHeader) cursor -= 2;
        if (cursor >= 0 && cursor < _rows.length) {
          final row = _rows[cursor];
          if (isFollowItemGroupRow(row)) {
            final groupKey = _rowKey(row);
            return FollowItemGroupCard(
              key: ValueKey('home-${widget.channel.name}-row-$groupKey'),
              value: row,
              expanded: _expandedFollowGroups.contains(groupKey),
              compact: widget.compact,
              showImages: widget.showImages,
              showMetrics: widget.showMetrics,
              onExpand: () {
                setState(() => _expandedFollowGroups.add(groupKey));
              },
              onChildTap: (child) {
                _warmRowBeforeOpen(child);
                openDetectedObject(context, widget.api, child);
              },
              onChildAuthorTap: (child) =>
                  openContentAuthor(context, widget.api, child),
            );
          }
          if (widget.channel == HomeFeedChannel.following &&
              isHomeFeedServiceRow(row)) {
            return _FollowingServiceCard(
              key: ValueKey(
                'home-${widget.channel.name}-service-${_rowKey(row)}',
              ),
              value: row,
            );
          }
          return ObjectCard(
            key: ValueKey('home-${widget.channel.name}-row-${_rowKey(row)}'),
            value: row,
            feedMode: true,
            compact: widget.compact,
            showImages: widget.showImages,
            showMetrics: widget.showMetrics,
            presentation: switch (widget.channel) {
              HomeFeedChannel.following => FeedCardPresentation.following,
              HomeFeedChannel.hot => FeedCardPresentation.hot,
              _ => FeedCardPresentation.generic,
            },
            onTap: () {
              _warmRowBeforeOpen(row);
              openDetectedObject(context, widget.api, row);
            },
            onTapAt: (position) {
              _warmRowBeforeOpen(row);
              openDetectedObject(
                context,
                widget.api,
                row,
                sourceRect: Rect.fromCenter(
                  center: position,
                  width: 52,
                  height: 52,
                ),
              );
            },
            onAuthorTap: authorIdOf(row).isEmpty
                ? null
                : () => openContentAuthor(context, widget.api, row),
            onLongPress: () => _showNegativeFeedback(row),
            onAction: (action) => _handleCardAction(row, action),
          );
        }
        if (_loading && !_refreshing) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (_error != null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            child: ZhOutlineButton(
              onPressed: () => _load(reset: false),
              icon: Icons.refresh_rounded,
              label: l10n.feedNextLoadFailed,
              expand: true,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
          child: Center(
            child: Text(
              _rows.isEmpty
                  ? _emptyMessage(l10n)
                  : _next == null
                  ? l10n.feedAllShown
                  : l10n.feedLoadMore,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }

  void _openFollowingPersonRecent(Map<String, dynamic> person) {
    final object = unwrapObject(person);
    final memberId = plainText(
      object['member_id'] ??
          object['id'] ??
          object['url_token'] ??
          object['user_id'],
    );
    if (memberId.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FollowingPersonRecentPage(
          api: widget.api,
          memberId: memberId,
          name: titleOf(object).isEmpty
              ? context.zhL10n.feedFollowingPeople
              : titleOf(object),
        ),
      ),
    );
  }

  Future<void> _handleCardAction(
    Map<String, dynamic> row,
    ContentCardAction action,
  ) async {
    final changed = await performContentCardAction(
      context,
      widget.api,
      row,
      action,
    );
    if (changed && mounted) setState(() {});
  }

  Future<void> _showNegativeFeedback(Map<String, dynamic> row) async {
    final identity = negativeFeedbackIdentityFromFeed(row);
    if (!identity.isUsable) return;
    final removed = await showNegativeFeedbackSheet(
      context: context,
      api: widget.api,
      identity: identity,
      initialResponseLoader: () => _negativeFeedbackPanel(identity),
      onAction: (item) => unawaited(() async {
        await ContentFilterStatsStore.instance.record(
          reason: item.label,
          action: item.action.intentUrl.isEmpty
              ? item.label
              : item.action.intentUrl,
          removed: item.removesFeedItem,
        );
        await RecommendationBehaviorStore.instance.recordFeedback(
          row,
          reason: item.label,
        );
      }()),
    );
    if (!removed || !mounted) return;
    setState(() {
      _rows.removeWhere((candidate) => identical(candidate, row));
      _rowKeys.remove(row);
    });
  }

  Future<ApiResponse> _negativeFeedbackPanel(
    NegativeFeedbackIdentity identity,
  ) {
    final key =
        '${identity.sceneCode}:${identity.contentType}:'
        '${identity.contentToken}';
    final existing = _negativeFeedbackPreloads[key];
    if (existing != null) return existing;
    if (_negativeFeedbackPreloads.length >= _feedbackCacheLimit) {
      _negativeFeedbackPreloads.remove(_negativeFeedbackPreloads.keys.first);
    }
    late final Future<ApiResponse> request;
    request = widget.api
        .getNegativeFeedbackPanel(identity)
        .then(
          (response) {
            if (!response.isSuccess &&
                identical(_negativeFeedbackPreloads[key], request)) {
              _negativeFeedbackPreloads.remove(key);
            }
            return response;
          },
          onError: (Object error, StackTrace stackTrace) {
            if (identical(_negativeFeedbackPreloads[key], request)) {
              _negativeFeedbackPreloads.remove(key);
            }
            Error.throwWithStackTrace(error, stackTrace);
          },
        );
    _negativeFeedbackPreloads[key] = request;
    return request;
  }
}
