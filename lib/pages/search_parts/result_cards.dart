part of '../search_page.dart';

String searchResultIdentityKey(Map<String, dynamic> row) {
  final type = typeOf(row).trim().toLowerCase();
  final object = unwrapObject(row);
  final objectId = idOf(object).trim();
  final rowId = idOf(row).trim();
  final id = objectId.isNotEmpty ? objectId : rowId;
  if (id.isNotEmpty) return 'id:$type:$id';

  final objectUrl = plainText(object['url']).trim();
  final rowUrl = plainText(row['url']).trim();
  final url = objectUrl.isNotEmpty ? objectUrl : rowUrl;
  if (url.isNotEmpty) return 'url:$type:$url';

  final objectTitle = plainText(object['title'] ?? object['name']).trim();
  final rowTitle = plainText(row['title'] ?? row['name']).trim();
  final title = (objectTitle.isNotEmpty ? objectTitle : rowTitle).toLowerCase();
  if (title.isNotEmpty) return 'title:$type:$title';
  return '';
}

List<Map<String, dynamic>> orderSearchRowsByResponseIndex(
  Iterable<Map<String, dynamic>> rows,
) {
  final indexed = rows.toList(growable: false).asMap().entries.toList();
  indexed.sort((left, right) {
    int responseIndex(Map<String, dynamic> row, int fallback) {
      final parsed = int.tryParse(plainText(row['index']));
      return parsed ?? fallback;
    }

    final order = responseIndex(
      left.value,
      left.key,
    ).compareTo(responseIndex(right.value, right.key));
    return order == 0 ? left.key.compareTo(right.key) : order;
  });
  return List.unmodifiable(indexed.map((entry) => entry.value));
}

List<Map<String, dynamic>> uniqueNewSearchRows(
  Iterable<Map<String, dynamic>> existing,
  Iterable<Map<String, dynamic>> candidates,
) {
  final seen = <String>{};
  for (final row in existing) {
    final key = searchResultIdentityKey(row);
    if (key.isNotEmpty) seen.add(key);
  }
  final result = <Map<String, dynamic>>[];
  for (final row in candidates) {
    final key = searchResultIdentityKey(row);
    if (key.isNotEmpty && !seen.add(key)) continue;
    result.add(row);
  }
  return List.unmodifiable(result);
}

class _SearchResultTab extends StatefulWidget {
  const _SearchResultTab({
    super.key,
    required this.api,
    required this.query,
    required this.type,
    required this.contentTopPadding,
    required this.onOpenRecent,
    required this.onOpenType,
    this.isActive = true,
    this.filters = const {},
  });

  final ZhihuApiClient api;
  final String query;
  final String type;
  final double contentTopPadding;
  final VoidCallback onOpenRecent;
  final ValueChanged<String> onOpenType;
  final bool isActive;
  final Map<String, String> filters;

  @override
  State<_SearchResultTab> createState() => _SearchResultTabState();
}

class _SearchResultTabState extends State<_SearchResultTab> {
  static const _maxPageRequestsPerLoad = 3;

  final _rows = <Map<String, dynamic>>[];
  final _loadedPageUris = <String>{};
  final _scroll = ScrollController();
  late String _searchId;
  Object? _error;
  String? _next;
  bool _loading = false;
  VoidCallback? _cancelImageWarmup;

  @override
  void initState() {
    super.initState();
    _searchId = ZhihuApiClient.newSearchId();
    _scroll.addListener(_maybeLoadMore);
    if (widget.isActive) _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant _SearchResultTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive && _rows.isEmpty && !_loading) {
      _load(reset: true);
    }
  }

  @override
  void dispose() {
    _cancelImageWarmup?.call();
    _scroll
      ..removeListener(_maybeLoadMore)
      ..dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_loading || _next == null || !_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 520) {
      _load(reset: false);
    }
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _rows.clear();
        _loadedPageUris.clear();
        _next = null;
        _searchId = ZhihuApiClient.newSearchId();
      }
    });
    var loadStateCommitted = false;
    try {
      var uri = reset
          ? widget.api.searchInitialUri(
              keyword: widget.query,
              type: widget.type,
              filters: widget.filters,
            )
          : widget.api.validatePagingUri(_next!);
      if (reset) uri = ensureSearchVerticalInfo(uri, widget.filters);
      final incoming = <Map<String, dynamic>>[];
      String? resolvedNext;
      for (
        var pageRequest = 0;
        pageRequest < _maxPageRequestsPerLoad;
        pageRequest++
      ) {
        final requestKey = uri.toString();
        if (_loadedPageUris.contains(requestKey)) {
          resolvedNext = null;
          break;
        }
        final response = await widget.api.getUri(
          uri,
          headers: {'x-api-version': '3.0.91', 'x-search-id': _searchId},
        );
        if (!mounted) return;
        if (!response.isSuccess) {
          setState(() {
            _next = requestKey;
            _loading = false;
            // Search is a public read route. A stale/missing mobile context
            // must remain retryable and must not be presented as an account
            // requirement; preserve real network challenges separately.
            _error = zhihu_api.ApiFailure.forAnonymousRead(response);
          });
          loadStateCommitted = true;
          return;
        }
        _loadedPageUris.add(requestKey);
        final pageRows = orderSearchRowsByResponseIndex(
          extractSearchRows(
            response.json,
            includeNovelMarketCards: widget.type == 'km_general',
            includePublicationMarketCards: widget.type == 'publication',
          ),
        );
        incoming.addAll(uniqueNewSearchRows([..._rows, ...incoming], pageRows));
        if (pageRows.isEmpty && widget.type == 'km_general') {
          // Structural only: useful when the hybrid novel tab changes its
          // container shape, without logging queries, IDs, text, or URLs.
          final root = response.jsonMap;
          final rawData = root?['data'];
          final itemShapes = rawData is List
              ? rawData
                    .take(2)
                    .map((raw) {
                      final item = raw is Map
                          ? raw.map(
                              (key, value) => MapEntry(key.toString(), value),
                            )
                          : const <String, dynamic>{};
                      final object = item['object'];
                      final objectMap = object is Map
                          ? object.map(
                              (key, value) => MapEntry(key.toString(), value),
                            )
                          : const <String, dynamic>{};
                      return 'wire=${plainText(item['type'])}; '
                          'card=${plainText(objectMap['card_type'])}; '
                          'tab=${plainText(objectMap['tab_type'])}; '
                          'commodity=${plainText(objectMap['commodity_type'])}; '
                          'header=${jsonShapeSummary(objectMap['header'])}; '
                          'body=${jsonShapeSummary(objectMap['body'])}; '
                          'footer=${jsonShapeSummary(objectMap['footer'])}';
                    })
                    .join(' || ')
              : '';
          debugPrint(
            '[zhihu-ui] empty-novel-search '
            'shape=${jsonShapeSummary(response.json)} items=$itemShapes',
          );
        }
        resolvedNext = pagingNext(response.json);
        if (resolvedNext == null) break;
        Uri nextUri;
        try {
          nextUri = widget.api.validatePagingUri(resolvedNext);
        } catch (_) {
          // A server-provided invalid next URL is not a content error. Keep
          // the successfully decoded rows and stop following that chain.
          resolvedNext = null;
          break;
        }
        if (_loadedPageUris.contains(nextUri.toString())) {
          resolvedNext = null;
          break;
        }
        if (incoming.isNotEmpty) break;
        uri = nextUri;
      }
      if (widget.api.session.prefetchImages) {
        // Search tabs can change rapidly. Warm only the first visible images
        // with a small worker pool so decoding cannot compete with IME or tab
        // transition frames.
        _cancelImageWarmup = prefetchObjectImages(
          context,
          incoming,
          limit: 6,
          concurrency: 2,
          includeAvatars: false,
          warmupDelay: const Duration(milliseconds: 600),
        );
      }
      if (!mounted) return;
      setState(() {
        _rows.addAll(incoming);
        _next = resolvedNext;
        _loading = false;
      });
      loadStateCommitted = true;
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loading = false;
        });
        loadStateCommitted = true;
      }
    } finally {
      if (mounted && !loadStateCommitted) {
        setState(() => _loading = false);
      }
    }
  }

  String _novelBusinessType(Map<String, dynamic> object) {
    final marker = [
      plainText(object['commodity_type']),
      plainText(object['business_type']),
      plainText(object['property_type']),
      plainText(object['url']),
    ].join(' ').toLowerCase();
    if (object['is_long'] == true ||
        object['is_mid_long'] == true ||
        marker.contains('novel') ||
        marker.contains('manuscript') ||
        marker.contains('long_story') ||
        marker.contains('mid_long')) {
      return 'long_story';
    }
    if (marker.contains('paid_column')) return 'paid_column';
    return 'long_story';
  }

  String? _novelBusinessId(Map<String, dynamic> object) {
    for (final key in const [
      'business_id',
      'well_id',
      'book_list_id',
      'work_id',
      'book_id',
      'sku_id',
    ]) {
      final value = plainText(object[key]);
      if (RegExp(r'^\d+$').hasMatch(value)) return value;
    }
    return null;
  }

  SaltStoryNavigation? _novelNavigation(Map<String, dynamic> object) {
    final direct = parseSaltStoryNavigation(object);
    if (direct != null) return direct;
    for (final key in const ['url', 'redirect_url', 'target_url', 'link']) {
      final candidate = parseSaltStoryNavigation({'url': object[key]});
      if (candidate != null) return candidate;
    }
    final id = _novelBusinessId(object);
    return id == null ? null : SaltStoryNavigation(businessId: id);
  }

  void _openResult(Map<String, dynamic> value) {
    if (value['_search_novel_card'] != true) {
      if (typeOf(value).replaceAll('search_', '').toLowerCase() == 'ring') {
        final object = unwrapObject(value);
        final uri = Uri.tryParse(plainText(object['url']));
        if (uri != null &&
            uri.scheme == 'https' &&
            uri.userInfo.isEmpty &&
            !uri.hasPort &&
            (uri.host == 'zhihu.com' || uri.host.endsWith('.zhihu.com')) &&
            uri.pathSegments.contains('ring')) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OfficialWebPage(
                title: titleOf(value),
                url: uri.toString(),
                cookieHeader: widget.api.session.cookie,
                requiresSessionCookie: true,
              ),
            ),
          );
          return;
        }
      }
      openDetectedObject(context, widget.api, value);
      return;
    }
    final object = unwrapObject(value);
    final navigation = _novelNavigation(object);
    if (navigation?.opensReader == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SaltReaderPage(
            api: widget.api,
            businessId: navigation!.businessId,
            sectionId: navigation.sectionId!,
          ),
        ),
      );
      return;
    }
    if (navigation != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SaltProductPage(
            api: widget.api,
            businessId: navigation.businessId,
            businessType: _novelBusinessType(object),
            title: titleOf(value).isEmpty ? '小说' : titleOf(value),
            initialMetadata: object,
          ),
        ),
      );
      return;
    }
    openDetectedObject(context, widget.api, value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _rows.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          padding: EdgeInsets.only(top: widget.contentTopPadding),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .65,
              child: ApiErrorView(
                error: _error!,
                onRetry: () => _load(reset: true),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.builder(
        controller: _scroll,
        padding: EdgeInsets.only(top: widget.contentTopPadding),
        physics: const AlwaysScrollableScrollPhysics(),
        // Search result rows also carry avatars and content thumbnails. Keep
        // one short screen ready for a fling without building a large hidden
        // batch while the result page is still settling.
        scrollCacheExtent: const ScrollCacheExtent.pixels(320),
        itemCount: _rows.length + 1,
        itemBuilder: (context, index) {
          if (index < _rows.length) {
            final row = _rows[index];
            if (isSearchSectionRow(row)) {
              final targetType = searchSectionTargetTypeOf(row);
              final hasTargetTab = officialSearchTabs.any(
                (tab) => tab.type == targetType,
              );
              return _SearchSectionCard(
                value: row,
                onItemTap: _openResult,
                onMore: searchSectionHasMore(row) && hasTargetTab
                    ? () => widget.onOpenType(targetType)
                    : null,
              );
            }
            if (isSearchHotTimingRow(row)) {
              return _SearchHotTimingCard(
                value: row,
                onItemTap: _openResult,
                onMore: searchHotTimingHasMore(row)
                    ? widget.onOpenRecent
                    : null,
              );
            }
            final rowType = typeOf(row).toLowerCase();
            final relatedQuery = searchQueryOf(row);
            final isQueryCard =
                rowType == 'relevant_query' ||
                rowType == 'search_query_correction';
            final contentType = typeOf(
              row,
            ).replaceAll('search_', '').toLowerCase();
            final hasAnswerAuthor =
                const {
                  'answer',
                  'videoanswer',
                  'video_answer',
                }.contains(contentType) &&
                authorIdOf(row).isNotEmpty;
            return _SearchResultCard(
              value: row,
              onAuthorTap: hasAnswerAuthor
                  ? () => openContentAuthor(context, widget.api, row)
                  : null,
              onTap: () {
                if (isQueryCard && relatedQuery.isNotEmpty) {
                  widget.api.session.rememberSearch(relatedQuery);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchResultsPage(
                        api: widget.api,
                        initialQuery: relatedQuery,
                      ),
                    ),
                  );
                  return;
                }
                _openResult(row);
              },
            );
          }
          if (_error != null) {
            return ApiErrorView(
              error: _error!,
              compact: true,
              onRetry: () => _load(reset: false),
            );
          }
          if (_rows.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('没有找到相关内容'),
                    if (_next != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        key: const ValueKey('search-empty-load-more'),
                        onPressed: _loading ? null : () => _load(reset: false),
                        child: const Text('继续查找'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          if (_next != null) {
            return ZhPagingIndicator(loading: _loading, height: 60);
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: const Center(child: Text('已经到底了')),
          );
        },
      ),
    );
  }
}
