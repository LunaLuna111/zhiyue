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
  final _shelfDownloadCounts = <String, int>{};
  final _shelfRows = <int, List<Map<String, dynamic>>>{};
  final _shelfErrors = <int, Object?>{};
  final _shelfLoadingTabs = <int>{};

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
    setState(() => _shelfTabIndex = index);
    unawaited(_loadShelfTab(index));
  }

  List<ReaderShelfTab> get _readerShelfTabs => [
    ReaderShelfTab(
      id: 'bookshelf',
      label: '书架',
      entries: _bookshelf.entries
          .map(_readerShelfEntryFromLocal)
          .toList(growable: false),
      canManage: true,
      isLoading: _bookshelfLoading,
      error: _bookshelfSyncError,
    ),
    for (var index = 1; index < 5; index++)
      ReaderShelfTab(
        id: switch (index) {
          1 => 'liked',
          2 => 'comments',
          3 => 'history',
          _ => 'lists',
        },
        label: switch (index) {
          1 => '赞过',
          2 => '弹评',
          3 => '历史记录',
          _ => '书单',
        },
        entries: (_shelfRows[index] ?? const <Map<String, dynamic>>[])
            .asMap()
            .entries
            .map(
              (entry) => _readerShelfEntryFromRemote(
                tab: index,
                index: entry.key,
                row: entry.value,
              ),
            )
            .toList(growable: false),
        isLoading: _shelfLoadingTabs.contains(index),
        error: _shelfErrors[index],
      ),
  ];

  ReaderShelfEntry _readerShelfEntryFromLocal(SaltBookshelfEntry entry) {
    final object = entry.cardJson;
    final book = _readerBookInfo(
      businessId: entry.businessId,
      fallbackTitle: entry.displayTitle,
      fallbackArtwork: entry.artwork,
      value: object,
    );
    final total = book.totalChapterCount;
    return ReaderShelfEntry(
      id: entry.businessId,
      book: book,
      propertyType: entry.propertyType,
      sectionId: entry.sectionId,
      addedAt: entry.addedAt,
      downloadedChapterCount: _shelfDownloadCounts[entry.businessId] ?? 0,
      totalChapterCount: total,
      isDownloaded: (_shelfDownloadCounts[entry.businessId] ?? 0) > 0,
      metadata: _readerShelfMetadata(object),
      payload: object,
    );
  }

  ReaderShelfEntry _readerShelfEntryFromRemote({
    required int tab,
    required int index,
    required Map<String, dynamic> row,
  }) {
    final entry = _bookshelfEntryFromRemote(row);
    final object = <String, dynamic>{
      ...unwrapObject(row),
      'business_id': entry.businessId,
      'property_type': entry.propertyType,
      'title': entry.displayTitle,
      if (entry.artwork.isNotEmpty) 'artwork': entry.artwork,
      if (entry.sectionId.isNotEmpty) 'section_id': entry.sectionId,
    };
    final book = _readerBookInfo(
      businessId: entry.businessId,
      fallbackTitle: entry.displayTitle,
      fallbackArtwork: entry.artwork,
      value: object,
    );
    final downloaded =
        _readerShelfInt(object, const [
          '_downloaded_section_count',
          'downloaded_section_count',
          'offline_section_count',
        ]) ??
        0;
    final id = entry.businessId.isEmpty
        ? 'remote-$tab-$index'
        : entry.businessId;
    return ReaderShelfEntry(
      id: id,
      book: book,
      propertyType: entry.propertyType,
      sectionId: entry.sectionId,
      addedAt: entry.addedAt,
      downloadedChapterCount: downloaded,
      totalChapterCount: book.totalChapterCount,
      isDownloaded:
          object['offline'] == true ||
          object['is_download'] == true ||
          object['isDownload'] == true,
      metadata: _readerShelfMetadata(object),
      payload: row,
    );
  }

  ReaderBookInfo _readerBookInfo({
    required String businessId,
    required String fallbackTitle,
    required String fallbackArtwork,
    required Map<String, dynamic> value,
  }) {
    final object = unwrapObject(value);
    final parent = _saltMap(object['parent']) ?? const <String, dynamic>{};
    final author = _saltMergePersonMaps([
      object['author'],
      object['author_info'],
      object['producer'],
      object['producer_info'],
      parent['author'],
      parent['author_info'],
      parent['producer'],
    ]);
    String firstText(Iterable<Object?> values) {
      for (final candidate in values) {
        final text = saltProductValueText(candidate).trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    String personText(List<String> keys) {
      if (author == null) return '';
      for (final key in keys) {
        final text = saltProductValueText(author[key]).trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final authorName = firstText([
      object['producer_name'],
      object['author_name'],
      object['producer'],
      object['author'],
      personText(const ['name', 'nickname', 'display_name', 'user_name']),
      _findString(object, const ['author_name', 'producer_name']),
    ]);
    final description = firstText([
      saltProductIntroduction(object),
      saltProductIntroduction(parent),
      object['description'],
      object['summary'],
    ]);
    final artwork = firstText([
      object['artwork'],
      object['tab_artwork'],
      object['cover_url'],
      parent['artwork'],
      parent['tab_artwork'],
      fallbackArtwork,
    ]);
    final title = firstText([
      object['title'],
      object['content_title'],
      parent['title'],
      parent['name'],
      fallbackTitle,
    ]);
    final total =
        _readerShelfInt(object, const [
          '_total_section_count',
          'total_section_count',
          'section_count',
          'chapter_count',
          'content_count',
        ]) ??
        _readerShelfInt(parent, const [
          'total_section_count',
          'section_count',
          'chapter_count',
          'content_count',
        ]);
    final labels = <String>[];
    for (final label in [
      ..._saltMetadataLabels(object, const ['labels', 'sell_labels', 'tags']),
      ..._saltMetadataLabels(parent, const ['labels', 'sell_labels', 'tags']),
    ]) {
      if (label.trim().isNotEmpty && !labels.contains(label)) labels.add(label);
    }
    final metadata = <String, Object?>{
      ..._readerShelfMetadata(object),
      'business_id': businessId,
      if (authorName.isNotEmpty) 'author_name': authorName,
      if (personText(const ['headline', 'slogan']).isNotEmpty)
        'author_headline': personText(const ['headline', 'slogan']),
      if (personText(const ['bio', 'description', 'introduction']).isNotEmpty)
        'author_bio': personText(const ['bio', 'description', 'introduction']),
    };
    return ReaderBookInfo(
      id: businessId,
      title: title.isEmpty ? '盐选作品' : title,
      author: authorName,
      description: description,
      coverUrl: artwork,
      totalChapterCount: total,
      tags: labels,
      updatedAt: _readerShelfDate(object) ?? _readerShelfDate(parent),
      metadata: metadata,
    );
  }

  Map<String, Object?> _readerShelfMetadata(Map<String, dynamic> value) => {
    for (final entry in value.entries) entry.key: entry.value,
  };

  int? _readerShelfInt(Map<String, dynamic> value, List<String> keys) {
    final result = _saltMetadataInt(value, keys);
    if (result != null && result > 0) return result;
    return null;
  }

  DateTime? _readerShelfDate(Map<String, dynamic> value) {
    for (final key in const [
      'updated_at',
      'update_time',
      'updated_timestamp',
      'created_at',
      'ctime',
    ]) {
      final raw = value[key];
      if (raw is DateTime) return raw;
      final number = raw is num ? raw.toInt() : int.tryParse(plainText(raw));
      if (number != null && number > 0) {
        final milliseconds = number < 100000000000 ? number * 1000 : number;
        return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
      }
      final parsed = DateTime.tryParse(plainText(raw));
      if (parsed != null) return parsed;
    }
    return null;
  }

  Map<String, dynamic> _readerShelfCardValue(ReaderShelfEntry entry) {
    final source = entry.payload;
    final value = source is Map
        ? <String, dynamic>{
            for (final item in source.entries) item.key.toString(): item.value,
          }
        : <String, dynamic>{};
    return <String, dynamic>{
      ...value,
      'business_id': entry.book.id,
      'property_type': entry.propertyType,
      'title': entry.book.title,
      if (entry.book.author.isNotEmpty) 'producer_name': entry.book.author,
      if (entry.book.description.isNotEmpty)
        'description': entry.book.description,
      if (entry.book.coverUrl.isNotEmpty) 'artwork': entry.book.coverUrl,
      if (entry.book.tags.isNotEmpty) 'labels': entry.book.tags,
      if (entry.sectionId.isNotEmpty) 'section_id': entry.sectionId,
      '_downloaded_section_count': entry.downloadedCount,
      if (entry.totalCount != null) '_total_section_count': entry.totalCount,
    };
  }

  Widget _buildReaderShelfCard(BuildContext context, ReaderShelfEntry entry) =>
      SaltCatalogCard(
        value: _readerShelfCardValue(entry),
        coverWidth: 76,
        coverHeight: 106,
        onTap: () => _openReaderShelfEntry(entry),
      );

  void _openReaderShelfEntry(ReaderShelfEntry entry) {
    _openSaltCard(_readerShelfCardValue(entry));
  }

  Future<void> _refreshShelf() => _loadBookshelf(refresh: true);

  Future<void> _retryShelfTab(int index) => index == 0
      ? _loadBookshelf(refresh: true)
      : _loadShelfTab(index, refresh: true);

  Future<void> _deleteSelectedShelfEntries(
    List<ReaderShelfEntry> selected,
  ) async {
    for (final entry in selected) {
      final local = _bookshelf.entries
          .where((item) => item.businessId == entry.id)
          .firstOrNull;
      if (local != null) await _bookshelf.remove(local.businessId);
    }
  }

  Future<void> _downloadSelectedShelfEntries(
    List<ReaderShelfEntry> selected,
  ) async {
    final windowWidth = MediaQuery.sizeOf(context).width.round();
    for (final shelfEntry in selected) {
      final entry = _bookshelf.entries
          .where((item) => item.businessId == shelfEntry.id)
          .firstOrNull;
      if (entry == null) continue;
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
      } catch (_) {
        // Continue with the remaining selected works, matching the original
        // batch shelf action instead of aborting the whole queue.
      }
    }
    await _loadShelfDownloadCounts();
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
    return Scaffold(
      appBar: ZhTopBar(
        title: ZhLiquidGlassSegmentedTabs(
          key: const ValueKey('reader-shelf-glass-tabs'),
          labels: [for (final tab in _readerShelfTabs) tab.label],
          selectedIndex: _shelfTabIndex,
          semanticPrefix: '书架',
          scrollable: true,
          onSelected: _selectShelfTab,
          height: 48,
        ),
        actions: [
          ZhLiquidGlassIconButton(
            key: const ValueKey('reader-shelf-category'),
            icon: const Icon(Icons.menu_book_outlined),
            semanticLabel: '分类',
            size: 44,
            iconSize: 23,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SaltStoryCategoryPage(api: widget.api),
              ),
            ),
          ),
        ],
      ),
      body: ZhResponsiveFrame(
        maxWidth: 1120,
        desktopGutter: 24,
        child: ReaderShelfView(
          tabs: _readerShelfTabs,
          activeTabIndex: _shelfTabIndex,
          onTabChanged: _selectShelfTab,
          itemBuilder: _buildReaderShelfCard,
          onOpenEntry: _openReaderShelfEntry,
          onRefresh: _refreshShelf,
          onRetryTab: _retryShelfTab,
          onDeleteSelected: _deleteSelectedShelfEntries,
          onDownloadSelected: _downloadSelectedShelfEntries,
          filterOptions: const [
            ReaderShelfFilterOption(value: 'paid_column', label: '知识专栏'),
            ReaderShelfFilterOption(value: 'ebook', label: '电子书'),
            ReaderShelfFilterOption(value: 'ebook_audio', label: '有声书'),
            ReaderShelfFilterOption(value: 'assessment', label: '测评'),
          ],
          emptyLabel: '本地书架暂无内容',
        ),
      ),
    );
  }
}
