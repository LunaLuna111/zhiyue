part of '../salt_page.dart';

class SaltStoryHome extends StatefulWidget {
  const SaltStoryHome({
    super.key,
    required this.api,
    required this.onOpenCard,
    required this.onOpenShortcut,
    this.topInset = 0,
    this.initialResponse,
    this.isRequestScopeCurrent,
    this.refreshSignal,
  });

  final ZhihuApiClient api;
  final ValueChanged<Map<String, dynamic>> onOpenCard;
  final ValueChanged<Map<String, dynamic>> onOpenShortcut;
  final double topInset;
  final Future<ApiResponse>? initialResponse;
  final bool Function()? isRequestScopeCurrent;
  final Listenable? refreshSignal;

  @override
  State<SaltStoryHome> createState() => _SaltStoryHomeState();
}

class _SaltStoryHomeState extends State<SaltStoryHome>
    with AutomaticKeepAliveClientMixin {
  final _modules = <Map<String, dynamic>>[];
  final _scrollController = ScrollController();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Object? _error;
  String? _next;
  bool _loading = false;
  bool _refreshing = false;
  bool _programmaticRefreshing = false;
  bool _consumedInitialResponse = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
    widget.refreshSignal?.addListener(_refreshRequested);
    _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant SaltStoryHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.refreshSignal, widget.refreshSignal)) return;
    oldWidget.refreshSignal?.removeListener(_refreshRequested);
    widget.refreshSignal?.addListener(_refreshRequested);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_maybeLoadMore)
      ..dispose();
    widget.refreshSignal?.removeListener(_refreshRequested);
    super.dispose();
  }

  void _refreshRequested() {
    _consumedInitialResponse = true;
    if (!_loading) unawaited(_returnToTopAndRefresh());
  }

  void _maybeLoadMore() {
    if (_loading ||
        _programmaticRefreshing ||
        _next == null ||
        !_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter < 520) _load(reset: false);
  }

  Future<void> _returnToTopAndRefresh() async {
    if (_loading) return;
    final isRequestScopeCurrent = widget.isRequestScopeCurrent;
    bool canCommit() => mounted && (isRequestScopeCurrent?.call() ?? true);
    setState(() => _programmaticRefreshing = true);
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
    try {
      final indicator = _refreshIndicatorKey.currentState;
      if (indicator == null) {
        await _load(reset: true, refreshing: true);
      } else {
        // Keep the channel button refresh identical to a user pull. This
        // avoids the old floating spinner jumping over the sticky tab bar.
        await indicator.show(atTop: true);
      }
    } finally {
      if (canCommit()) setState(() => _programmaticRefreshing = false);
    }
  }

  Future<void> _load({required bool reset, bool refreshing = false}) async {
    if (_loading) return;
    // A FeedPage scope can change before its keyed Story subtree is disposed.
    // Capture this request's validator so a late private response cannot
    // mutate state or enqueue image work during that microtask window.
    final isRequestScopeCurrent = widget.isRequestScopeCurrent;
    bool canCommit() => mounted && (isRequestScopeCurrent?.call() ?? true);
    setState(() {
      _loading = true;
      _refreshing = refreshing;
      _error = null;
      if (reset && !refreshing) {
        _modules.clear();
        _next = null;
      }
    });
    try {
      final response = reset
          ? await _initialOrFreshResponse()
          : await widget.api.getSaltUri(widget.api.validatePagingUri(_next!));
      if (!mounted || !(isRequestScopeCurrent?.call() ?? true)) return;
      if (!response.isSuccess) {
        setState(() => _error = ApiFailure.forAnonymousRead(response));
      } else {
        final modules = extractSaltStoryModules(response.json);
        if (widget.api.session.prefetchImages &&
            widget.api.session.showFeedImages) {
          prefetchObjectImages(
            context,
            extractSaltStoryRows(response.json),
            limit: 36,
            concurrency: 12,
            contentCacheWidth: saltStoryCoverCacheWidth,
            deferUntilPostFrame: false,
          );
        }
        setState(() {
          if (reset) {
            _modules.clear();
            _next = null;
          }
          _modules.addAll(modules);
          final candidate = pagingNext(response.json);
          _next = candidate == _next ? null : candidate;
        });
      }
    } catch (error) {
      if (canCommit()) setState(() => _error = error);
    } finally {
      if (canCommit()) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  Future<ApiResponse> _initialOrFreshResponse() {
    final initialResponse = widget.initialResponse;
    if (!_consumedInitialResponse && initialResponse != null) {
      _consumedInitialResponse = true;
      return initialResponse;
    }
    return widget.api.getSaltUri(widget.api.saltStoryHomeUri());
  }

  void _openNetworkVerification() {
    unawaited(_openNetworkVerificationAndReload());
  }

  Future<void> _openNetworkVerificationAndReload() async {
    await openZhihuSafetyVerification(context);
    if (!mounted || !(widget.isRequestScopeCurrent?.call() ?? true)) return;
    await _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading && _modules.isEmpty) {
      return _SaltStoryLoading(topInset: widget.topInset);
    }
    if (_error != null && _modules.isEmpty) {
      return RefreshIndicator(
        key: _refreshIndicatorKey,
        edgeOffset: widget.topInset,
        displacement: 24,
        onRefresh: () => _load(reset: true, refreshing: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (widget.topInset > 0) SizedBox(height: widget.topInset),
            SizedBox(
              height: 560,
              child: ApiErrorView(
                error: _error!,
                onRetry: () => _load(reset: true),
                titleOverride: '盐选首页暂时无法加载',
                onOpenNetworkVerification: _openNetworkVerification,
              ),
            ),
          ],
        ),
      );
    }
    final blocks = _saltStoryBlocks(_modules);
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      edgeOffset: widget.topInset,
      displacement: 24,
      onRefresh: () => _load(reset: true, refreshing: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: ZhSpace.xl),
        itemCount: blocks.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SizedBox(height: widget.topInset);
          }
          final blockIndex = index - 1;
          if (blockIndex < blocks.length) {
            final block = blocks[blockIndex];
            if (block.card != null) {
              return SaltCatalogCard(
                value: block.card!,
                coverWidth: 72,
                coverHeight: 100,
                onTap: () => widget.onOpenCard(block.card!),
              );
            }
            if (block.headerOnly) {
              final data = _saltModuleData(block.module);
              if (data == null) return const SizedBox.shrink();
              final type = plainText(
                block.module['module_type'] ?? block.module['card_type'],
              ).toLowerCase();
              final title = _saltModuleTitle(block.module, data);
              final subtitle = plainText(data['sub_title']);
              return ZhSectionHeader(
                title: title.isEmpty ? _saltFallbackTitle(type) : title,
                description: subtitle.isEmpty ? null : subtitle,
              );
            }
            return _SaltModuleView(
              module: block.module,
              onOpenCard: widget.onOpenCard,
              onOpenShortcut: widget.onOpenShortcut,
            );
          }
          if (_loading && !_refreshing) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (_error != null) {
            return ApiErrorView(
              error: _error!,
              compact: true,
              onRetry: () => _load(reset: false),
              onOpenNetworkVerification: _openNetworkVerification,
            );
          }
          if (_next != null) {
            return ZhPagingIndicator(loading: _loading, height: 60);
          }
          // The official page ends on the last card; keep a small breathing
          // space instead of exposing an implementation detail footer.
          return const SizedBox(height: 28);
        },
      ),
    );
  }
}

class _SaltStoryLoading extends StatelessWidget {
  const _SaltStoryLoading({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.fromLTRB(12, topInset + 12, 12, 24),
    children: [
      Row(
        children: [
          for (var index = 0; index < 4; index++) ...[
            Expanded(
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: ZhPalette.canvas,
                  borderRadius: BorderRadius.circular(ZhRadius.card),
                ),
              ),
            ),
            if (index != 3) const SizedBox(width: 8),
          ],
        ],
      ),
      const SizedBox(height: 24),
      for (var index = 0; index < 3; index++) ...[
        Container(
          height: 126,
          decoration: BoxDecoration(
            color: ZhPalette.canvas,
            borderRadius: BorderRadius.circular(ZhRadius.card),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ],
  );
}
