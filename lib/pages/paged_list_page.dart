import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/json_tools.dart';
import '../ui/zh_components.dart';
import '../widgets/api_views.dart';

typedef InitialLoader = Future<ApiResponse> Function();
typedef RowsExtractor = List<Map<String, dynamic>> Function(Object? value);
typedef ObjectTap =
    void Function(BuildContext context, Map<String, dynamic> value);
typedef ObjectLongPress =
    Future<bool> Function(BuildContext context, Map<String, dynamic> value);
typedef ObjectRowBuilder =
    Widget Function(
      BuildContext context,
      Map<String, dynamic> value,
      VoidCallback? onTap,
    );
typedef ResponseHeaderBuilder =
    Widget? Function(BuildContext context, Map<String, dynamic> response);

class PagedListPage extends StatefulWidget {
  const PagedListPage({
    super.key,
    required this.title,
    required this.api,
    required this.loadInitial,
    this.titleWidget,
    this.centerTitle,
    this.toolbarHeight,
    this.onObjectTap,
    this.onObjectLongPress,
    this.actions,
    this.embedded = false,
    this.errorTitle,
    this.errorDetail,
    this.answerListMode = false,
    this.commentListMode = false,
    this.header,
    this.rowBuilder,
    this.rowsExtractor,
    this.responseHeaderBuilder,
    this.pinResponseHeader = false,
    this.bottomNavigationBar,
    this.emptyMessage = '还没有内容',
  });

  final String title;
  final Widget? titleWidget;
  final bool? centerTitle;
  final double? toolbarHeight;
  final ZhihuApiClient api;
  final InitialLoader loadInitial;
  final ObjectTap? onObjectTap;
  final ObjectLongPress? onObjectLongPress;
  final List<Widget>? actions;
  final bool embedded;
  final String? errorTitle;
  final String? errorDetail;
  final bool answerListMode;
  final bool commentListMode;
  final Widget? header;
  final ObjectRowBuilder? rowBuilder;
  final RowsExtractor? rowsExtractor;
  final ResponseHeaderBuilder? responseHeaderBuilder;
  final bool pinResponseHeader;
  final Widget? bottomNavigationBar;
  final String emptyMessage;

  @override
  State<PagedListPage> createState() => _PagedListPageState();
}

class _PagedListPageState extends State<PagedListPage> {
  final _rows = <Map<String, dynamic>>[];
  final _scrollController = ScrollController();
  Object? _error;
  bool _loading = false;
  bool _initialLoadComplete = false;
  String? _next;
  Map<String, dynamic>? _responseRoot;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_maybeLoadMore)
      ..dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_loading ||
        _error != null ||
        _next == null ||
        !_scrollController.hasClients) {
      return;
    }
    _maybeLoadMoreFrom(_scrollController.position);
  }

  void _maybeLoadMoreFrom(ScrollMetrics metrics) {
    if (_loading || _error != null || _next == null) return;
    final triggerDistance = widget.commentListMode
        ? (metrics.viewportDimension * 1.2).clamp(640.0, 1100.0).toDouble()
        : 360.0;
    if (metrics.extentAfter <= triggerDistance) {
      _load(reset: false);
    }
  }

  bool _handleEmbeddedScroll(ScrollNotification notification) {
    if (notification.depth == 0) _maybeLoadMoreFrom(notification.metrics);
    return false;
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = reset
          ? await widget.loadInitial()
          : await widget.api.getUri(widget.api.validatePagingUri(_next!));
      if (!mounted) return;
      if (!response.isSuccess) {
        setState(() => _error = response);
      } else {
        final incoming =
            widget.rowsExtractor?.call(response.json) ??
            extractRows(response.json);
        if (widget.api.session.prefetchImages) {
          prefetchObjectImages(context, incoming);
        }
        setState(() {
          if (reset) {
            _rows
              ..clear()
              ..addAll(incoming);
          } else {
            _rows.addAll(incoming);
          }
          _next = pagingNext(response.json);
          if (reset) _responseRoot = response.jsonMap;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          if (reset) _initialLoadComplete = true;
        });
        if (_next != null && _error == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _maybeLoadMore();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      final list = !_initialLoadComplete
          ? NotificationListener<ScrollNotification>(
              onNotification: _handleEmbeddedScroll,
              child: _body(),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: _handleEmbeddedScroll,
              child: RefreshIndicator(
                onRefresh: () => _load(reset: true),
                child: _body(),
              ),
            );
      if (widget.bottomNavigationBar == null) return list;
      return Column(
        children: [
          Expanded(child: list),
          SafeArea(top: false, child: widget.bottomNavigationBar!),
        ],
      );
    }
    return Scaffold(
      // Floating action bars should sit above the list instead of making the
      // whole bottom area an opaque sheet. The question-answer actions use
      // this path and paint their own capsule/shadow.
      extendBody: widget.bottomNavigationBar != null,
      appBar: AppBar(
        title: widget.titleWidget ?? Text(widget.title),
        centerTitle: widget.centerTitle,
        toolbarHeight: widget.toolbarHeight,
        actions: widget.actions,
      ),
      body: ZhResponsiveFrame(
        maxWidth: 1120,
        desktopGutter: 24,
        child: RefreshIndicator(
          onRefresh: () => _load(reset: true),
          child: _body(),
        ),
      ),
      bottomNavigationBar: widget.bottomNavigationBar == null
          ? null
          : SafeArea(
              top: false,
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: widget.bottomNavigationBar!,
                ),
              ),
            ),
    );
  }

  Widget _body() {
    if (_loading && _rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _rows.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 430,
            child: ApiErrorView(
              error: _error!,
              onRetry: () => _load(reset: true),
              titleOverride: widget.errorTitle,
              detailOverride: widget.errorDetail,
            ),
          ),
        ],
      );
    }
    final responseHeader =
        widget.responseHeaderBuilder == null || _responseRoot == null
        ? null
        : widget.responseHeaderBuilder!(context, _responseRoot!);
    if (widget.pinResponseHeader && responseHeader != null) {
      return CustomScrollView(
        controller: widget.embedded ? null : _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (widget.header != null) SliverToBoxAdapter(child: widget.header!),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedResponseHeaderDelegate(child: responseHeader),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              _buildContentItem,
              childCount: _rows.length + 2,
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: widget.embedded ? null : _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount:
          _rows.length +
          2 +
          (widget.header == null ? 0 : 1) +
          (responseHeader == null ? 0 : 1),
      itemBuilder: (context, index) {
        var cursor = index;
        if (widget.header != null) {
          if (cursor == 0) return widget.header!;
          cursor--;
        }
        if (responseHeader != null) {
          if (cursor == 0) return responseHeader;
          cursor--;
        }
        if (cursor < _rows.length) {
          final row = _rows[cursor];
          final onTap = widget.onObjectTap == null
              ? null
              : () => widget.onObjectTap!(context, row);
          final child = widget.rowBuilder != null
              ? widget.rowBuilder!(context, row, onTap)
              : widget.commentListMode
              ? CommentCard(value: row, onTap: onTap)
              : ObjectCard(
                  value: row,
                  answerListMode: widget.answerListMode,
                  onTap: onTap,
                );
          final rowId = idOf(row).trim();
          final rowKey = rowId.isNotEmpty
              ? rowId
              : '${titleOf(row)}-${authorNameOf(row)}-$cursor';
          final keyedChild = KeyedSubtree(
            key: ValueKey('paged-row-$rowKey'),
            child: child,
          );
          if (widget.onObjectLongPress == null) return keyedChild;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () async {
              final remove = await widget.onObjectLongPress!(context, row);
              if (!remove || !mounted) return;
              setState(() => _rows.remove(row));
            },
            child: keyedChild,
          );
        }
        if (cursor == _rows.length) {
          if (_rows.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(widget.emptyMessage, textAlign: TextAlign.center),
              ),
            );
          }
          if (_error != null) {
            return ApiErrorView(
              error: _error!,
              compact: true,
              onRetry: () => _load(reset: false),
              titleOverride: widget.errorTitle,
              detailOverride: widget.errorDetail,
            );
          }
          if (_next != null) {
            return ZhPagingIndicator(loading: _loading);
          }
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('已经到底了')),
          );
        }
        return const SizedBox(height: 24);
      },
    );
  }

  Widget _buildContentItem(BuildContext context, int index) {
    if (index < _rows.length) {
      final row = _rows[index];
      final onTap = widget.onObjectTap == null
          ? null
          : () => widget.onObjectTap!(context, row);
      final child = widget.rowBuilder != null
          ? widget.rowBuilder!(context, row, onTap)
          : widget.commentListMode
          ? CommentCard(value: row, onTap: onTap)
          : ObjectCard(
              value: row,
              answerListMode: widget.answerListMode,
              onTap: onTap,
            );
      final rowId = idOf(row).trim();
      final rowKey = rowId.isNotEmpty
          ? rowId
          : '${titleOf(row)}-${authorNameOf(row)}-$index';
      final keyedChild = KeyedSubtree(
        key: ValueKey('paged-row-$rowKey'),
        child: child,
      );
      if (widget.onObjectLongPress == null) return keyedChild;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () async {
          final remove = await widget.onObjectLongPress!(context, row);
          if (!remove || !mounted) return;
          setState(() => _rows.remove(row));
        },
        child: keyedChild,
      );
    }
    if (index == _rows.length) {
      if (_rows.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Text(widget.emptyMessage, textAlign: TextAlign.center),
          ),
        );
      }
      if (_error != null) {
        return ApiErrorView(
          error: _error!,
          compact: true,
          onRetry: () => _load(reset: false),
          titleOverride: widget.errorTitle,
          detailOverride: widget.errorDetail,
        );
      }
      if (_next != null) {
        return ZhPagingIndicator(loading: _loading);
      }
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('已经到底了')),
      );
    }
    return const SizedBox(height: 24);
  }
}

class _PinnedResponseHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedResponseHeaderDelegate({required this.child});

  static const double _height = 48;

  final Widget child;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(covariant _PinnedResponseHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}
