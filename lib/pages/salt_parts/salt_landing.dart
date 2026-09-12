part of '../salt_page.dart';

class SaltPage extends StatefulWidget {
  const SaltPage({super.key, required this.api});

  final ZhihuApiClient api;

  @override
  State<SaltPage> createState() => _SaltPageState();
}

class _SaltPageState extends State<SaltPage>
    with AutomaticKeepAliveClientMixin {
  final _bookshelf = SaltBookshelfStore.instance;
  final _catalogStore = SaltCatalogStore.instance;
  bool _bookshelfLoading = false;
  Object? _bookshelfSyncError;
  int _shelfTabIndex = 0;
  bool _shelfManageMode = false;
  bool _shelfControlsVisible = true;
  bool _shelfBatchBusy = false;
  final _selectedShelfIds = <String>{};
  bool _shelfDownloadedOnly = false;
  final _shelfDownloadCounts = <String, int>{};
  String _shelfPropertyFilter = '';
  final _shelfRows = <int, List<Map<String, dynamic>>>{};
  final _shelfErrors = <int, Object?>{};
  final _shelfLoadingTabs = <int>{};

  static const _shelfTabs = ['书架', '赞过', '弹评', '历史记录', '书单'];

  @override
  void initState() {
    super.initState();
    _bookshelf.addListener(_bookshelfChanged);
    unawaited(_loadBookshelf());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _bookshelf.removeListener(_bookshelfChanged);
    super.dispose();
  }

  void _bookshelfChanged() {
    if (mounted) setState(() {});
  }

  Future<ApiResponse?> _safeSaltGet(Uri uri) async {
    try {
      return await widget.api.getSaltUri(uri);
    } catch (_) {
      // One unavailable shelf generation must not prevent the other native
      // shelf contracts (or the cached local shelf) from rendering.
      return null;
    }
  }

  Future<void> _loadBookshelf({bool refresh = false}) async {
    if (_bookshelfLoading) return;
    setState(() {
      _bookshelfLoading = true;
      _bookshelfSyncError = null;
    });
    try {
      await _bookshelf.load(force: refresh);
      if (widget.api.session.hasAccountSession) {
        // Warm all native cloud-shelf variants concurrently.  Accounts on
        // different server generations expose either `/pluton/shelves` or
        // the VIP `view_data` envelope; merging both is idempotent in the
        // local store and avoids a visible empty shelf while one endpoint is
        // still being populated.
        final responses = await Future.wait<ApiResponse?>([
          _safeSaltGet(widget.api.saltCloudShelfUri()),
          _safeSaltGet(widget.api.saltShelfHomeUri()),
          _safeSaltGet(widget.api.saltBookshelfUri(limit: 20)),
        ]);
        var received = false;
        for (final response in responses) {
          if (response == null || !response.isSuccess) continue;
          final rows = extractSaltShelfRows(response.json);
          final fallback = rows.isEmpty ? extractRows(response.json) : rows;
          final entries = fallback
              .map(_bookshelfEntryFromRemote)
              .where((entry) => entry.businessId.isNotEmpty);
          await _bookshelf.addAll(entries);
          received = received || fallback.isNotEmpty;
        }
        if (!received &&
            responses.every(
              (response) => response == null || !response.isSuccess,
            )) {
          _bookshelfSyncError = const ApiTransportException('云书架暂时无法同步');
        }
      }
      await _enrichBookshelfEntries();
      await _loadShelfDownloadCounts();
      if (widget.api.session.hasAccountSession) {
        await _loadShelfTab(_shelfTabIndex, refresh: refresh);
      }
    } catch (error) {
      _bookshelfSyncError = error;
    } finally {
      if (mounted) setState(() => _bookshelfLoading = false);
    }
  }

  Future<void> _enrichBookshelfEntries() async {
    final pending = _bookshelf.entries
        .where((entry) => entry.rawJson['_catalog_enriched_v2'] != true)
        .toList(growable: false);
    for (var start = 0; start < pending.length; start += 4) {
      final end = math.min(start + 4, pending.length);
      await Future.wait(pending.sublist(start, end).map(_enrichBookshelfEntry));
    }
  }

  Future<void> _enrichBookshelfEntry(SaltBookshelfEntry entry) async {
    try {
      final catalog = await _catalogStore.load(
        api: widget.api,
        businessId: entry.businessId,
      );
      final metadata = saltCatalogWorkMetadata(catalog.root);
      final root = saltCatalogResponseRoot(catalog.root);
      final parent = _saltMap(root['parent']) ?? const <String, dynamic>{};
      final author = _saltMergePersonMaps([
        root['author'],
        root['author_info'],
        parent['author'],
        parent['author_info'],
        parent['producer'],
      ]);
      final totalSections =
          _saltMetadataInt(parent, const [
            'section_count',
            'chapter_count',
            'total_section_count',
            'content_count',
          ]) ??
          catalog.total ??
          catalog.rows.length;
      String authorText(List<String> keys) {
        if (author == null) return '';
        for (final key in keys) {
          final text = saltProductValueText(author[key]);
          if (text.isNotEmpty) return text;
        }
        return '';
      }

      final normalized = <String, dynamic>{
        ...entry.rawJson,
        'parent': parent,
        '_catalog_enriched_v2': true,
        'author': ?author,
        if (authorText(const ['name', 'nickname', 'display_name']).isNotEmpty)
          'producer_name': authorText(const [
            'name',
            'nickname',
            'display_name',
          ]),
        if (saltProductValueText(parent['introduction']).isNotEmpty)
          'description': saltProductValueText(parent['introduction']),
        if (parent['labels'] != null) 'labels': parent['labels'],
        if (parent['sell_labels'] != null) 'sell_labels': parent['sell_labels'],
        if (parent['like_count'] != null) 'like_count': parent['like_count'],
        if (parent['comment_count'] != null)
          'comment_count': parent['comment_count'],
        if (parent['word_count'] != null) 'word_count': parent['word_count'],
        if (parent['view_count'] != null) 'view_count': parent['view_count'],
        if (parent['favorite_count'] != null)
          'favorite_count': parent['favorite_count'],
        if (parent['status_text'] != null) 'status_text': parent['status_text'],
        if (parent['update_text'] != null) 'update_text': parent['update_text'],
        if (parent['has_tts'] != null) 'has_tts': parent['has_tts'],
        if (totalSections > 0) '_total_section_count': totalSections,
      };
      await _bookshelf.add(
        SaltBookshelfEntry(
          businessId: entry.businessId,
          propertyType: metadata.propertyType.isEmpty
              ? entry.propertyType
              : _normalizedSaltBusinessType(metadata.propertyType),
          title: metadata.title.isEmpty ? entry.title : metadata.title,
          artwork: metadata.artwork.isEmpty ? entry.artwork : metadata.artwork,
          sectionId: entry.sectionId,
          rawJson: normalized,
          addedAt: entry.addedAt,
        ),
      );
    } catch (_) {
      // Offline placeholder entries remain navigable and use displayTitle.
    }
  }

  Future<void> _loadShelfDownloadCounts() async {
    final counts = <String, int>{};
    await Future.wait(
      _bookshelf.entries.map((entry) async {
        counts[entry.businessId] =
            (await SaltChapterCache.instance.cachedSectionIds(
              entry.businessId,
            )).length;
      }),
    );
    if (!mounted) return;
    setState(() {
      _shelfDownloadCounts
        ..clear()
        ..addAll(counts);
    });
  }

  SaltBookshelfEntry _bookshelfEntryFromRemote(Map<String, dynamic> row) {
    final object = unwrapObject(row);
    final navigation = parseSaltStoryNavigation(object);
    final businessId =
        navigation?.businessId ??
        _findString(object, const [
          'business_id',
          'well_id',
          'book_list_id',
          'sku_id',
          'f95768id',
          'id',
        ]) ??
        '';
    final propertyType = _normalizedSaltBusinessType(
      _findString(object, const ['property_type', 'business_type', 'type']) ??
          'paid_column',
    );
    return SaltBookshelfEntry(
      businessId: businessId,
      propertyType: propertyType,
      title: titleOf(row).isEmpty ? '盐选作品' : titleOf(row),
      artwork:
          _findString(object, const [
            'artwork',
            'image_url',
            'cover_url',
            'tab_artwork',
          ]) ??
          (object['image'] is List && (object['image'] as List).isNotEmpty
              ? plainText((object['image'] as List).first)
              : ''),
      sectionId:
          navigation?.sectionId ??
          _findString(object, const ['section_id']) ??
          '',
      rawJson: object,
      addedAt: DateTime.now(),
    );
  }

  Future<void> _loadShelfTab(int tab, {bool refresh = false}) async {
    if (tab == 0 ||
        _shelfLoadingTabs.contains(tab) ||
        (!refresh && _shelfRows.containsKey(tab))) {
      return;
    }
    if (!widget.api.session.hasAccountSession) return;
    _shelfLoadingTabs.add(tab);
    if (mounted) setState(() {});
    try {
      final uri = switch (tab) {
        1 => widget.api.saltBookshelfUri(offset: 0, limit: 20),
        2 => widget.api.saltShelfAnnotationsUri(),
        3 => widget.api.saltShelfHistoryUri(),
        4 => widget.api.saltShelfBookListsUri(),
        _ => widget.api.saltCloudShelfUri(),
      };
      final response = await widget.api.getSaltUri(uri);
      if (!response.isSuccess) {
        _shelfErrors[tab] = response;
      } else {
        final rows = extractSaltShelfRows(response.json);
        _shelfRows[tab] = rows.isNotEmpty ? rows : extractRows(response.json);
        _shelfErrors.remove(tab);
      }
    } catch (error) {
      _shelfErrors[tab] = error;
    } finally {
      _shelfLoadingTabs.remove(tab);
      if (mounted) setState(() {});
    }
  }

  void _selectShelfTab(int index) {
    if (_shelfTabIndex == index) return;
    setState(() {
      _shelfTabIndex = index;
      _shelfManageMode = false;
      _selectedShelfIds.clear();
      _shelfControlsVisible = true;
    });
    unawaited(_loadShelfTab(index));
  }

  void _toggleShelfManageMode() {
    setState(() {
      _shelfManageMode = !_shelfManageMode;
      _selectedShelfIds.clear();
      _shelfControlsVisible = true;
    });
  }

  void _toggleShelfSelection(String businessId) {
    setState(() {
      if (!_selectedShelfIds.remove(businessId)) {
        _selectedShelfIds.add(businessId);
      }
    });
  }

  List<SaltBookshelfEntry> get _selectedShelfEntries => _bookshelf.entries
      .where((entry) => _selectedShelfIds.contains(entry.businessId))
      .toList(growable: false);

  void _toggleSelectAll() {
    final ids = _bookshelf.entries.map((entry) => entry.businessId).toSet();
    setState(() {
      if (_selectedShelfIds.length == ids.length &&
          _selectedShelfIds.containsAll(ids)) {
        _selectedShelfIds.clear();
      } else {
        _selectedShelfIds
          ..clear()
          ..addAll(ids);
      }
    });
  }

  Future<void> _deleteSelectedShelfEntries() async {
    final selected = _selectedShelfEntries;
    if (selected.isEmpty || _shelfBatchBusy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除 ${selected.length} 本作品？'),
        content: const Text('将从本地书架移除所选作品。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _shelfBatchBusy = true);
    for (final entry in selected) {
      await _bookshelf.remove(entry.businessId);
    }
    if (!mounted) return;
    setState(() {
      _selectedShelfIds.clear();
      _shelfBatchBusy = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已删除 ${selected.length} 本作品')));
  }

  Future<void> _downloadSelectedShelfEntries() async {
    final selected = _selectedShelfEntries;
    if (selected.isEmpty || _shelfBatchBusy) return;
    setState(() => _shelfBatchBusy = true);
    final windowWidth = MediaQuery.sizeOf(context).width.round();
    var completed = 0;
    for (final entry in selected) {
      try {
        var sectionId = entry.sectionId;
        var sectionTitle = entry.displayTitle;
        var sectionIndex = 0;
        if (sectionId.isEmpty) {
          final catalog = await _catalogStore.load(
            api: widget.api,
            businessId: entry.businessId,
          );
          final navigation = saltCatalogNavigationOf([
            catalog.root,
          ], currentSectionId: '');
          if (navigation.sections.isEmpty) continue;
          final section = navigation.sections.first;
          sectionId = section.id;
          sectionTitle = section.title.isEmpty ? sectionTitle : section.title;
          sectionIndex = section.index;
        }
        await _downloadSaltChapterForCache(
          api: widget.api,
          businessId: entry.businessId,
          sectionId: sectionId,
          title: sectionTitle,
          sectionIndex: sectionIndex,
          windowWidth: windowWidth,
        );
        completed++;
      } catch (_) {
        // Continue with the remaining selected works, matching the original
        // batch shelf action instead of aborting the whole queue.
      }
    }
    if (!mounted) return;
    await _loadShelfDownloadCounts();
    if (!mounted) return;
    setState(() => _shelfBatchBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已下载 $completed/${selected.length} 本作品的当前章节')),
    );
  }

  bool _handleShelfScroll(UserScrollNotification notification) {
    if (_shelfManageMode || notification.direction == ScrollDirection.idle) {
      return false;
    }
    final visible = notification.direction == ScrollDirection.forward;
    if (visible != _shelfControlsVisible) {
      setState(() => _shelfControlsVisible = visible);
    }
    return false;
  }

  List<Map<String, dynamic>> _visibleShelfRows() {
    final rows = _shelfRows[_shelfTabIndex] ?? const <Map<String, dynamic>>[];
    return rows
        .where((row) {
          if (_shelfPropertyFilter.isNotEmpty) {
            final object = unwrapObject(row);
            final type = plainText(
              object['property_type'] ?? object['producer'] ?? object['type'],
            );
            if (type.isNotEmpty && type != _shelfPropertyFilter) return false;
          }
          if (_shelfDownloadedOnly) {
            final object = unwrapObject(row);
            final downloaded =
                object['offline'] == true ||
                object['is_download'] == true ||
                object['isDownload'] == true;
            if (!downloaded) return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  Future<void> _showShelfFilter() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in const [
              ('', '全部内容'),
              ('paid_column', '知识专栏'),
              ('ebook', '电子书'),
              ('ebook_audio', '有声书'),
              ('assessment', '测评'),
            ])
              ListTile(
                title: Text(option.$2),
                trailing: option.$1 == _shelfPropertyFilter
                    ? const Icon(Icons.check_rounded, color: Colors.blue)
                    : null,
                onTap: () => Navigator.pop(sheetContext, option.$1),
              ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _shelfPropertyFilter = selected);
  }

  void _openSaltCard(Map<String, dynamic> value) {
    final object = unwrapObject(value);
    final navigation = parseSaltStoryNavigation(object);
    final id =
        navigation?.businessId ??
        _findString(object, const ['business_id', 'well_id', 'id']);
    if (id == null) {
      final route = Uri.tryParse(plainText(object['url']));
      if (route != null &&
          route.scheme == 'https' &&
          route.host == 'www.zhihu.com') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OfficialWebPage(
              title: titleOf(value).isEmpty ? '盐选' : titleOf(value),
              url: route.toString(),
            ),
          ),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ObjectInspectorPage(value: value)),
      );
      return;
    }
    if (navigation?.opensReader == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SaltReaderPage(
            api: widget.api,
            businessId: id,
            sectionId: navigation!.sectionId!,
            contract: SaltReaderContract.automatic,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaltProductPage(
          api: widget.api,
          businessId: id,
          businessType: _normalizedSaltBusinessType(
            _findString(object, const ['business_type', 'type']) ??
                'paid_column',
          ),
          title: titleOf(value),
          initialMetadata: object,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final entries = _bookshelf.entries;
    final remoteRows = _visibleShelfRows();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildShelfTabs(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: '分类',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 42, height: 42),
              icon: const Icon(Icons.menu_book_outlined, size: 23),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SaltStoryCategoryPage(api: widget.api),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ZhResponsiveFrame(
        maxWidth: 1120,
        desktopGutter: 24,
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: _shelfControlsVisible || _shelfManageMode
                  ? _buildShelfControls()
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: _handleShelfScroll,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadBookshelf(refresh: true);
                    if (_shelfTabIndex != 0) {
                      await _loadShelfTab(_shelfTabIndex, refresh: true);
                    }
                  },
                  child: SaltShelfContent(
                    tabIndex: _shelfTabIndex,
                    entries: entries,
                    remoteRows: remoteRows,
                    propertyFilter: _shelfPropertyFilter,
                    downloadedOnly: _shelfDownloadedOnly,
                    downloadCounts: _shelfDownloadCounts,
                    manageMode: _shelfManageMode,
                    selectedIds: _selectedShelfIds,
                    loading: _bookshelfLoading,
                    syncError: _bookshelfSyncError,
                    loadingTabs: _shelfLoadingTabs,
                    errors: _shelfErrors,
                    onLoadTab: _loadShelfTab,
                    onOpenCard: _openSaltCard,
                    onToggleSelection: _toggleShelfSelection,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShelfTabs() => Material(
    color: Colors.transparent,
    child: SizedBox(
      height: kToolbarHeight,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 18, right: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _shelfTabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final selected = index == _shelfTabIndex;
          return InkWell(
            onTap: () => _selectShelfTab(index),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _shelfTabs[index],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: selected ? ZhPalette.ink : ZhPalette.mutedInk,
                      ),
                    ),
                    const SizedBox(height: 7),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 3,
                      width: selected ? 24 : 0,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _buildShelfControls() => Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.grey.shade200),
        bottom: BorderSide(color: Colors.grey.shade200),
      ),
    ),
    padding: const EdgeInsets.fromLTRB(18, 9, 18, 9),
    child: Row(
      children: [
        if (_shelfManageMode) ...[
          TextButton(
            onPressed: _shelfBatchBusy ? null : _toggleSelectAll,
            child: const Text('全选'),
          ),
          TextButton.icon(
            onPressed: _selectedShelfIds.isEmpty || _shelfBatchBusy
                ? null
                : _downloadSelectedShelfEntries,
            icon: const Icon(Icons.download_outlined, size: 19),
            label: const Text('下载'),
          ),
          TextButton.icon(
            onPressed: _selectedShelfIds.isEmpty || _shelfBatchBusy
                ? null
                : _deleteSelectedShelfEntries,
            icon: const Icon(Icons.delete_outline_rounded, size: 19),
            label: const Text('删除'),
            style: TextButton.styleFrom(foregroundColor: ZhPalette.danger),
          ),
          const Spacer(),
          Text('已选 ${_selectedShelfIds.length}'),
          TextButton(
            onPressed: _toggleShelfManageMode,
            child: const Text('完成'),
          ),
        ] else ...[
          TextButton.icon(
            onPressed: _showShelfFilter,
            icon: const Icon(Icons.tune_rounded, size: 19),
            label: const Text('筛选'),
            style: TextButton.styleFrom(foregroundColor: ZhPalette.mutedInk),
          ),
          TextButton(
            onPressed: _shelfTabIndex == 0 ? _toggleShelfManageMode : null,
            child: const Text('管理'),
          ),
          const Spacer(),
          FilterChip(
            label: const Text('已下载'),
            selected: _shelfDownloadedOnly,
            onSelected: (value) => setState(() => _shelfDownloadedOnly = value),
            visualDensity: VisualDensity.compact,
            labelStyle: const TextStyle(fontSize: 13),
          ),
        ],
      ],
    ),
  );

}
