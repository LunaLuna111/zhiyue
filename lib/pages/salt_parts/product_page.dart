part of '../salt_page.dart';

class SaltProductPage extends StatefulWidget {
  const SaltProductPage({
    super.key,
    required this.api,
    required this.businessId,
    required this.businessType,
    required this.title,
    this.initialMetadata,
  });

  final ZhihuApiClient api;
  final String businessId;
  final String businessType;
  final String title;

  /// Metadata from the discovery card.  Some works expose a valid
  /// `section_list` but no `/catalog` parent object; retaining this source
  /// card keeps the cover, summary and like count visible in that case.
  final Map<String, dynamic>? initialMetadata;

  @override
  State<SaltProductPage> createState() => _SaltProductPageState();
}

class _SaltProductPageState extends State<SaltProductPage> {
  static final _fallbackMetadataSource = Object();
  final _bookshelf = SaltBookshelfStore.instance;
  final _catalogStore = SaltCatalogStore.instance;
  bool _bookshelfSaving = false;
  bool _addedToBookshelf = false;
  SaltCatalogSnapshot? _catalog;
  Object? _catalogError;
  bool _catalogLoading = false;
  bool _catalogDescending = false;
  int _catalogLoadGeneration = 0;
  SaltCatalogSnapshot? _sortedCatalogSource;
  List<Map<String, dynamic>>? _sortedCatalogRows;
  bool _sortedCatalogDescending = false;
  Object? _metadataSourceCache;
  Map<String, dynamic>? _metadataParentCache;
  SaltCatalogWorkMetadata? _workMetadataCache;
  final _metadataEnrichmentInFlight = <String, Future<void>>{};
  final _metadataEnrichmentAttemptedAt = <String, DateTime>{};
  static const _metadataRetryDelay = Duration(minutes: 2);

  Map<String, dynamic> get _fallbackParent {
    final source = widget.initialMetadata;
    if (source == null) return const <String, dynamic>{};
    final artwork = _saltMap(source['artwork']);
    final likeCount = source['like_count'];
    final description = saltProductIntroduction(source);
    return <String, dynamic>{
      ...source,
      if (plainText(source['introduction']).isEmpty && description.isNotEmpty)
        'introduction': description,
      if (source['sub_title'] == null && source['subtitle'] != null)
        'sub_title': source['subtitle'],
      if (source['like_text'] == null && likeCount != null)
        'like_text': plainText(likeCount),
      ...?artwork == null ? null : <String, dynamic>{'artwork': artwork},
    };
  }

  Map<String, dynamic> _effectiveRoot(Map<String, dynamic> root) {
    final normalizedRoot = saltCatalogResponseRoot(root);
    final parent = _saltMap(normalizedRoot['parent']);
    final fallback = _fallbackParent;
    if (parent == null || parent.isEmpty) {
      return fallback.isEmpty
          ? normalizedRoot
          : <String, dynamic>{...normalizedRoot, 'parent': fallback};
    }
    if (fallback.isEmpty) return normalizedRoot;
    final parentValues = <String, dynamic>{...fallback, ...parent};
    // The catalog endpoint normally supplies `introduction`, but older and
    // partially cached responses can carry the same text under `description`,
    // `summary`, or a list of description fragments.  Do not let an empty
    // catalog value mask the richer discovery-card metadata.
    for (final key in const [
      'title',
      'artwork',
      'sub_title',
      'introduction',
      'description',
      'summary',
      'synopsis',
      'brief',
      'excerpt',
      'description_list',
      'type_name',
      'type_en',
      'labels',
      'author',
      'author_info',
      'xxxxx_author_info',
      'producer',
      'producer_info',
      'producer_name',
      'author_name',
      'meta_info',
      'bottom_meta',
      'word_count',
      'chapter_count',
      'total_section_count',
      'total',
      'comment_count',
      'view_count',
      'brand_label',
      'label_text',
      'like_text',
      'like_count',
      'section_count',
      'updated_section_count',
      'xxxxxxxx_total',
      'is_long',
      'is_finished',
      'has_interested',
      'is_like',
      'is_vip_resource',
      'has_tts',
      'word_count_text',
      'sku_cap_text',
      'online_time_text',
      'update_text',
    ]) {
      if (saltProductValueText(parent[key]).isEmpty &&
          saltProductValueText(fallback[key]).isNotEmpty) {
        parentValues[key] = fallback[key];
      }
    }
    if (saltProductValueText(parentValues['introduction']).isEmpty) {
      final introduction = saltProductIntroduction(parentValues);
      if (introduction.isNotEmpty) {
        parentValues['introduction'] = introduction;
      }
    }
    return <String, dynamic>{...normalizedRoot, 'parent': parentValues};
  }

  SaltCatalogWorkMetadata get _workMetadata {
    final source = _metadataSource;
    final cached = _workMetadataCache;
    if (cached != null && identical(_metadataSourceCache, source)) {
      return cached;
    }
    final root = _catalog?.root;
    final metadataRoot = root == null
        ? <String, dynamic>{'parent': _fallbackParent}
        : _effectiveRoot(root);
    final metadata = saltCatalogWorkMetadata(metadataRoot);
    _metadataSourceCache = source;
    _metadataParentCache = _saltMap(metadataRoot['parent']) ?? _fallbackParent;
    return _workMetadataCache = metadata;
  }

  Object get _metadataSource =>
      _catalog ?? widget.initialMetadata ?? _fallbackMetadataSource;

  Map<String, dynamic> get _workMetadataRoot {
    _workMetadata;
    return _metadataParentCache ?? _fallbackParent;
  }

  String _displayTitle([AppLocalizations? l10n]) {
    final catalogTitle = _workMetadata.title.trim();
    if (catalogTitle.isNotEmpty) return catalogTitle;
    return isSaltBookshelfPlaceholderTitle(widget.title)
        ? (l10n?.saltWorkFallback ?? widget.title.trim())
        : widget.title.trim();
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadBookshelfState());
    unawaited(_loadCatalog());
  }

  @override
  void didUpdateWidget(covariant SaltProductPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.businessId == widget.businessId) return;
    _catalogLoadGeneration++;
    _catalog = null;
    _catalogError = null;
    _catalogLoading = false;
    _metadataEnrichmentAttemptedAt.remove(oldWidget.businessId);
    unawaited(_loadCatalog());
  }

  Future<void> _loadCatalog({bool forceRefresh = false}) async {
    if (_catalogLoading) return;
    final businessId = widget.businessId;
    final generation = ++_catalogLoadGeneration;
    if (forceRefresh) _metadataEnrichmentAttemptedAt.remove(businessId);
    setState(() {
      _catalogLoading = true;
      _catalogError = null;
    });
    if (!forceRefresh) {
      try {
        final cached = await _catalogStore.read(businessId);
        if (cached != null && _isCurrentCatalogLoad(businessId, generation)) {
          setState(() => _catalog = cached);
          unawaited(_enrichHeaderMetadata(cached));
        }
      } catch (_) {
        // Network loading below still works if the database is unavailable.
      }
    }
    try {
      final catalog = await _catalogStore.load(
        api: widget.api,
        businessId: businessId,
        forceRefresh: forceRefresh,
      );
      if (_isCurrentCatalogLoad(businessId, generation)) {
        setState(() {
          _catalog = catalog;
          _catalogLoading = false;
        });
        unawaited(_enrichHeaderMetadata(catalog));
      }
    } catch (error) {
      if (_isCurrentCatalogLoad(businessId, generation)) {
        setState(() {
          if (_catalog == null) _catalogError = error;
          _catalogLoading = false;
        });
      }
    } finally {
      // Success and current-request errors commit the loading flag together
      // with their payload. Keep this fallback for a cancelled/early return
      // so a stale catalog request cannot leave the page spinning forever.
      if (_isCurrentCatalogLoad(businessId, generation) && _catalogLoading) {
        setState(() => _catalogLoading = false);
      }
    }
  }

  bool _isCurrentCatalogLoad(String businessId, int generation) =>
      mounted &&
      widget.businessId == businessId &&
      _catalogLoadGeneration == generation;

  List<Map<String, dynamic>> _catalogRowsFor(SaltCatalogSnapshot? catalog) {
    if (catalog == null) return const <Map<String, dynamic>>[];
    final cached = _sortedCatalogRows;
    if (cached != null &&
        identical(_sortedCatalogSource, catalog) &&
        _sortedCatalogDescending == _catalogDescending) {
      return cached;
    }
    final sorted = sortSaltCatalogSections(
      catalog.rows,
      descending: _catalogDescending,
    );
    _sortedCatalogSource = catalog;
    _sortedCatalogDescending = _catalogDescending;
    _sortedCatalogRows = sorted;
    return sorted;
  }

  /// The catalog endpoint intentionally keeps the first response small and
  /// may return `author: null`.  The official reader then fetches
  /// `manu_core` for the first section; its `manuscript_info.authors` carries
  /// the complete author/avatar and work header.  Mirror that side-chain so a
  /// product page is not stuck with only a cover and chapter list.
  Future<void> _enrichHeaderMetadata(SaltCatalogSnapshot catalog) {
    final businessId = catalog.businessId;
    final root = saltCatalogResponseRoot(catalog.root);
    if (!_catalogNeedsHeaderMetadata(root)) return Future<void>.value();
    final current = _metadataEnrichmentInFlight[businessId];
    if (current != null) return current;
    final attemptedAt = _metadataEnrichmentAttemptedAt[businessId];
    final now = DateTime.now().toUtc();
    if (attemptedAt != null &&
        now.difference(attemptedAt) < _metadataRetryDelay) {
      return Future<void>.value();
    }
    _metadataEnrichmentAttemptedAt[businessId] = now;
    final request = _performHeaderMetadataEnrichment(catalog, businessId);
    _metadataEnrichmentInFlight[businessId] = request;
    return request.whenComplete(() {
      if (identical(_metadataEnrichmentInFlight[businessId], request)) {
        _metadataEnrichmentInFlight.remove(businessId);
      }
    });
  }

  Future<void> _performHeaderMetadataEnrichment(
    SaltCatalogSnapshot catalog,
    String businessId,
  ) async {
    final l10n = context.zhL10n;
    try {
      final currentCatalog = _catalog?.businessId == businessId
          ? _catalog
          : null;
      final rows = currentCatalog?.rows ?? catalog.rows;
      final section = rows.firstWhere((row) {
        final sectionId = plainText(
          row['section_id'] ??
              row['sectionId'] ??
              row['chapter_id'] ??
              row['id'],
        );
        // The catalog's synthetic "详情" row uses id 0 and has no
        // manuscript metadata; use the first real chapter instead.
        return sectionId.isNotEmpty && sectionId != '0';
      }, orElse: () => const <String, dynamic>{});
      final sectionId = plainText(
        section['section_id'] ??
            section['sectionId'] ??
            section['chapter_id'] ??
            section['id'],
      );
      if (sectionId.isEmpty) return;
      final response = await widget.api.getSaltUri(
        widget.api.saltManuCoreUri(
          businessId: businessId,
          sectionId: sectionId,
        ),
      );
      if (!response.isSuccess) return;
      final manuscript = SaltManuscriptEnvelope.fromJson(response.json);
      final authorName = manuscript.authorName.trim();
      final authorAvatar = manuscript.authorAvatar.trim();
      final authorHeadline = manuscript.authorHeadline.trim();
      final authorBio = manuscript.authorBio.trim();
      final latestCatalog = _catalog?.businessId == businessId
          ? _catalog
          : null;
      final baseCatalog = latestCatalog ?? catalog;
      final baseRoot = saltCatalogResponseRoot(baseCatalog.root);
      if (!_catalogNeedsHeaderMetadata(baseRoot)) return;
      final parent = _saltMap(baseRoot['parent']) ?? const <String, dynamic>{};
      final updatedParent = <String, dynamic>{...parent};
      var changed = false;
      void putText(String field, String value) {
        if (value.isEmpty ||
            saltProductValueText(updatedParent[field]).isNotEmpty) {
          return;
        }
        updatedParent[field] = value;
        changed = true;
      }

      putText('title', manuscript.parentTitle.trim());
      putText('artwork', manuscript.parentArtwork.trim());
      putText('property_type', manuscript.propertyType.trim());
      putText('introduction', manuscript.parentIntroduction.trim());
      putText('status_text', manuscript.statusText.trim());
      putText('update_text', manuscript.updateText.trim());
      if (manuscript.isLong == true ||
          manuscript.propertyType == 'long_story') {
        putText('brand_label', l10n.storyLong);
      }
      void putBool(String field, bool? value) {
        if (value == null ||
            _saltMetadataBool(updatedParent, [field]) != null) {
          return;
        }
        updatedParent[field] = value;
        changed = true;
      }

      void putInt(String field, int? value) {
        if (value == null ||
            value <= 0 ||
            _saltMetadataInt(updatedParent, [field]) != null) {
          return;
        }
        updatedParent[field] = value;
        changed = true;
      }

      putBool('is_long', manuscript.isLong);
      putBool('is_finished', manuscript.isFinished);
      putBool('is_vip_resource', manuscript.isVipResource);
      putBool('has_tts', manuscript.hasTts);
      putBool('is_like', manuscript.isLiked);
      putInt('like_count', manuscript.likeCount);
      putInt('comment_count', manuscript.commentCount);
      putInt('section_count', manuscript.sectionCount);
      putInt('updated_section_count', manuscript.updatedSectionCount);
      putInt('word_count', manuscript.wordCount);
      putInt('view_count', manuscript.viewCount);
      putInt('favorite_count', manuscript.favoriteCount);
      putBool('has_interested', manuscript.isOnShelf);
      if (manuscript.commentScore.isNotEmpty) {
        putText('comment_score', manuscript.commentScore);
      }
      if (manuscript.labels.isNotEmpty &&
          saltProductValueText(updatedParent['labels']).isEmpty) {
        updatedParent['labels'] = manuscript.labels;
        changed = true;
      }
      final existingAuthor = _saltMergePersonMaps([
        baseRoot['author'],
        baseRoot['author_info'],
        parent['author'],
        parent['author_info'],
      ]);
      final author = <String, dynamic>{...?existingAuthor};
      if (authorName.isNotEmpty) {
        if (saltProductValueText(author['nickname']).isEmpty) {
          author['nickname'] = authorName;
          changed = true;
        }
        if (saltProductValueText(author['name']).isEmpty) {
          author['name'] = authorName;
          changed = true;
        }
      }
      if (authorAvatar.isNotEmpty) {
        if (saltProductValueText(author['head']).isEmpty) {
          author['head'] = authorAvatar;
          changed = true;
        }
        if (saltProductValueText(author['avatar_url']).isEmpty) {
          author['avatar_url'] = authorAvatar;
          changed = true;
        }
      }
      if (authorHeadline.isNotEmpty &&
          saltProductValueText(author['headline']).isEmpty) {
        author['headline'] = authorHeadline;
        changed = true;
      }
      if (authorBio.isNotEmpty && saltProductValueText(author['bio']).isEmpty) {
        author['bio'] = authorBio;
        changed = true;
      }
      if (!changed) return;
      final enrichedRoot = <String, dynamic>{
        ...baseRoot,
        'parent': updatedParent,
        if (author.isNotEmpty) 'author': author,
      };
      final enriched = await _catalogStore.replaceRoot(
        businessId: businessId,
        root: enrichedRoot,
      );
      if (!mounted || widget.businessId != businessId) return;
      setState(() => _catalog = enriched);
    } catch (_) {
      // Header enrichment is best-effort; the cached catalog remains usable.
    }
  }

  bool _catalogNeedsHeaderMetadata(Map<String, dynamic> root) {
    final parent = _saltMap(root['parent']);
    final author = _saltMergePersonMaps([
      root['author'],
      root['author_info'],
      root['xxxxx_author_info'],
      parent?['author'],
      parent?['author_info'],
      parent?['producer'],
    ]);
    final name = _saltPersonField(author, const [
      'nickname',
      'nick_name',
      'name',
      'full_name',
      'display_name',
      'author_name',
      'authorName',
      'username',
      'user_name',
      'screen_name',
    ]);
    final avatar = _saltPersonField(author, const [
      'head',
      'avatar',
      'avatar_url',
      'avatarUrl',
      'image',
      'image_url',
    ]);
    final profile = _saltPersonField(author, const [
      'headline',
      'headline_render',
      'description',
      'bio',
      'intro',
    ]);
    return name.isEmpty || avatar.isEmpty || profile.isEmpty;
  }

  Future<void> _loadBookshelfState() async {
    try {
      await _bookshelf.load();
      if (mounted) {
        setState(
          () => _addedToBookshelf = _bookshelf.contains(widget.businessId),
        );
      }
    } catch (_) {
      // The page remains readable if the local database is unavailable.
    }
  }

  Future<void> _addToBookshelf() async {
    final l10n = context.zhL10n;
    setState(() => _bookshelfSaving = true);
    try {
      await _bookshelf.add(
        _localBookshelfEntry(
          businessId: widget.businessId,
          propertyType: _workMetadata.propertyType.isEmpty
              ? 'long_story'
              : _normalizedSaltBusinessType(_workMetadata.propertyType),
          fallbackTitle: l10n.saltWorkFallback,
          title: _displayTitle(l10n),
          artwork: _workMetadata.artwork,
          rawJson: _workMetadataRoot,
        ),
      );
      if (!mounted) return;
      setState(() => _addedToBookshelf = true);
      var synced = false;
      var syncFailed = false;
      if (widget.api.canWrite) {
        try {
          final response = await widget.api.addSaltToBookshelf(
            bookListId: widget.businessId,
            propertyType: 'long_story',
          );
          synced = response.isSuccess;
          syncFailed = !synced;
        } catch (_) {
          syncFailed = true;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            synced
                ? l10n.saltAddToBookshelf
                : syncFailed
                ? '${l10n.saltAdded} · ${l10n.saltCloudShelfUnavailable}'
                : l10n.saltAdded,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final failure = ApiFailure.from(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${failure.title}：${failure.detail}')),
      );
    } finally {
      if (mounted) setState(() => _bookshelfSaving = false);
    }
  }

  Future<void> _showMoreMenu() async {
    final l10n = context.zhL10n;
    final action = await showModalBottomSheet<_SaltReaderMoreAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                child: Text(
                  l10n.saltMoreActions,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: Text(l10n.commonRefresh),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_SaltReaderMoreAction.refresh),
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined),
                title: Text(l10n.saltExportTxt),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_SaltReaderMoreAction.exportTxt),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.saltExportDocx),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_SaltReaderMoreAction.exportDocx),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _SaltReaderMoreAction.refresh:
        await _loadCatalog(forceRefresh: true);
        break;
      case _SaltReaderMoreAction.exportTxt:
        await _openLongExport(SaltChapterExportFormat.txt);
        break;
      case _SaltReaderMoreAction.exportDocx:
        await _openLongExport(SaltChapterExportFormat.docx);
        break;
    }
  }

  Future<void> _openLongExport(SaltChapterExportFormat format) async {
    final l10n = context.zhL10n;
    final location = await showSaltLongExportSheet(
      context: context,
      api: widget.api,
      businessId: widget.businessId,
      workTitle: _displayTitle(l10n),
      format: format,
    );
    if (!mounted || location == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.saltExportedTo(location))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final topInset = ZhTopBar.bodyTopInset(context, toolbarHeight: 72);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ZhTopBar(
        toolbarHeight: 72,
        leading: ZhLiquidGlassIconButton(
          key: const ValueKey('salt-product-back'),
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
          semanticLabel: l10n.commonBack,
          size: 48,
          iconSize: 24,
        ),
        title: Text(
          _displayTitle(l10n),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          ZhLiquidGlassIconButton(
            key: const ValueKey('salt-product-more'),
            onPressed: _showMoreMenu,
            semanticLabel: l10n.saltMore,
            icon: const Icon(Icons.more_vert_rounded),
            size: 48,
            iconSize: 24,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ZhResponsiveFrame(
        maxWidth: 1120,
        desktopGutter: 24,
        child: RefreshIndicator(
          onRefresh: () => _loadCatalog(forceRefresh: true),
          child: _catalogBody(topInset: topInset),
        ),
      ),
    );
  }

  Widget _catalogBody({double topInset = 0}) {
    final l10n = context.zhL10n;
    final catalog = _catalog;
    final fallbackHeader = _saltProductHeader(context, <String, dynamic>{
      'parent': _fallbackParent,
    });
    if (catalog == null && _catalogLoading) {
      return ListView(
        padding: EdgeInsets.only(top: topInset),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ...?fallbackHeader == null ? null : <Widget>[fallbackHeader],
          const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    if (catalog == null && _catalogError != null) {
      return ListView(
        padding: EdgeInsets.only(top: topInset),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ...?fallbackHeader == null ? null : <Widget>[fallbackHeader],
          SizedBox(
            height: 430,
            child: ApiErrorView(
              error: _catalogError!,
              onRetry: () => _loadCatalog(forceRefresh: true),
              titleOverride: l10n.saltDirectoryLoadFailed,
              detailOverride: l10n.saltNetworkRetry,
            ),
          ),
        ],
      );
    }
    final sourceRows = catalog?.rows ?? const <Map<String, dynamic>>[];
    final rows = _catalogRowsFor(catalog);
    final catalogRoot = catalog == null
        ? const <String, dynamic>{}
        : _effectiveRoot(catalog.root);
    final remoteAddedToBookshelf =
        catalog != null &&
        _saltMetadataBool(_saltMap(catalogRoot['parent']), const [
              'has_interested',
              'on_shelves',
              'on_shelf',
            ]) ==
            true;
    final readingTarget = _readingTarget(sourceRows);
    final hasReadingProgress =
        readingTarget != null && _hasReadingProgress(readingTarget);
    final header = catalog == null
        ? null
        : _saltProductHeader(context, _effectiveRoot(catalog.root));
    return ListView.builder(
      padding: EdgeInsets.only(top: topInset),
      physics: const AlwaysScrollableScrollPhysics(),
      // The catalog rows sit below an image-heavy product header. Keep one
      // short row-sized buffer ready without constructing a large hidden
      // section batch during a fast fling.
      scrollCacheExtent: const ScrollCacheExtent.pixels(320),
      itemCount: rows.length + (header == null ? 0 : 1) + 2,
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header;
        final controlsIndex = header == null ? 0 : 1;
        if (index == controlsIndex) {
          return _SaltProductCatalogControls(
            descending: _catalogDescending,
            canRead: readingTarget != null,
            continueReading: hasReadingProgress,
            bookshelfSaving: _bookshelfSaving,
            addedToBookshelf: _addedToBookshelf || remoteAddedToBookshelf,
            onOrderChanged: (descending) {
              setState(() => _catalogDescending = descending);
            },
            onRead: readingTarget == null
                ? null
                : () => _openSection(readingTarget),
            onAddToBookshelf:
                _bookshelfSaving || _addedToBookshelf || remoteAddedToBookshelf
                ? null
                : _addToBookshelf,
          );
        }
        final rowIndex = index - controlsIndex - 1;
        if (rowIndex < rows.length) {
          final value = rows[rowIndex];
          return _SaltProductSectionRow(
            value: value,
            onTap: () => _openSection(value),
          );
        }
        if (rows.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text(l10n.saltDirectoryEmpty)),
          );
        }
        return const SizedBox(height: 24);
      },
    );
  }

  Future<void> _openSection(Map<String, dynamic> value) async {
    final sectionId = _findString(value, const ['section_id', 'id']);
    if (sectionId == null) return;
    await _catalogStore.markLastRead(
      businessId: widget.businessId,
      sectionId: sectionId,
    );
    if (!mounted) return;
    _markLastReadLocally(sectionId);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaltReaderPage(
          api: widget.api,
          businessId: widget.businessId,
          sectionId: sectionId,
          contract: SaltReaderContract.automatic,
        ),
      ),
    );
  }

  void _markLastReadLocally(String sectionId) {
    final catalog = _catalog;
    if (catalog == null) return;
    var changed = false;
    final rows = catalog.rows
        .map((row) {
          final selected =
              _findString(row, const ['section_id', 'id']) == sectionId;
          if (row['last_read'] == selected) return row;
          changed = true;
          return <String, dynamic>{...row, 'last_read': selected};
        })
        .toList(growable: false);
    if (!changed) return;
    final root = <String, dynamic>{...catalog.root, 'data': rows};
    setState(
      () => _catalog = SaltCatalogSnapshot(
        businessId: catalog.businessId,
        root: root,
        fetchedAt: catalog.fetchedAt,
      ),
    );
  }

  Map<String, dynamic>? _readingTarget(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return null;
    for (final row in rows) {
      if (row['last_read'] == true) return row;
    }
    for (final row in rows.reversed) {
      if (_hasReadingProgress(row)) return row;
    }
    return rows.first;
  }

  bool _hasReadingProgress(Map<String, dynamic> row) =>
      row['last_read'] == true ||
      saltCatalogProgressText(row, selected: false).isNotEmpty;
}
