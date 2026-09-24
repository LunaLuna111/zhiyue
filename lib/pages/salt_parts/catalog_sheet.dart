part of '../salt_page.dart';

enum _SaltCatalogOrder { ascending, descending }

@visibleForTesting
List<Map<String, dynamic>> sortSaltCatalogSections(
  Iterable<Map<String, dynamic>> rows, {
  required bool descending,
}) {
  final sorted = rows.toList();
  sorted.sort((left, right) {
    final leftObject = unwrapObject(left);
    final rightObject = unwrapObject(right);
    final leftIndex = _jsonCatalogIndex(leftObject);
    final rightIndex = _jsonCatalogIndex(rightObject);
    final comparison = leftIndex.compareTo(rightIndex);
    return descending ? -comparison : comparison;
  });
  return sorted;
}

int _jsonCatalogIndex(Map<String, dynamic> value) {
  for (final candidate in [value['global_idx'], value['idx']]) {
    if (candidate is num) return candidate.round();
    final parsed = int.tryParse(plainText(candidate));
    if (parsed != null) return parsed;
  }
  return 1 << 30;
}

@visibleForTesting
String saltCatalogProgressText(
  Map<String, dynamic> value, {
  required bool selected,
  int? currentSectionIndex,
  int? sectionCount,
  AppLocalizations? l10n,
}) {
  final object = unwrapObject(value);
  final progressText = plainText(object['progress_text']);
  if (progressText.isNotEmpty) return progressText;
  final progress = _saltMap(object['cli_progress']);
  final unitProgress = _saltMap(progress?['unit_progress']);
  if (object['read_finished'] == true || unitProgress?['is_finished'] == true) {
    return l10n?.saltReadPercent(100) ?? '已读 100%';
  }
  final current = unitProgress?['progress'];
  final maximum = unitProgress?['max_progress'];
  if (current is num && maximum is num && maximum > 0) {
    final percent = (current / maximum * 100).clamp(0, 100).round();
    if (percent > 0) return l10n?.saltReadPercent(percent) ?? '已读 $percent%';
  }
  if (selected &&
      currentSectionIndex != null &&
      currentSectionIndex >= 0 &&
      sectionCount != null &&
      sectionCount > 0) {
    final completed = (currentSectionIndex / sectionCount * 100).floor();
    final percent = completed.clamp(1, 99);
    return l10n?.saltReadPercent(percent) ?? '已读 $percent%';
  }
  return '';
}

class _SaltCatalogSheet extends StatefulWidget {
  const _SaltCatalogSheet({
    required this.api,
    required this.businessId,
    required this.currentSectionId,
    required this.currentSectionIndex,
    required this.sectionCount,
    required this.title,
    this.onOpenSection,
    this.exportFormat,
    this.keyProvider,
  });

  final ZhihuApiClient api;
  final String businessId;
  final String? currentSectionId;
  final int? currentSectionIndex;
  final int? sectionCount;
  final String title;
  final ValueChanged<String>? onOpenSection;
  final SaltChapterExportFormat? exportFormat;
  final SaltManuscriptKeyProvider? keyProvider;

  @override
  State<_SaltCatalogSheet> createState() => _SaltCatalogSheetState();
}

class _SaltCatalogSheetState extends State<_SaltCatalogSheet> {
  final _rows = <Map<String, dynamic>>[];
  final _selectedIds = <String>{};
  Set<String> _cachedIds = const {};
  _SaltCatalogOrder _order = _SaltCatalogOrder.ascending;
  Object? _error;
  bool _loading = false;
  bool _exporting = false;
  String _exportProgress = '';
  int? _serverTotal;

  bool get _isExportMode => widget.exportFormat != null;

  String _sectionId(Map<String, dynamic> row) =>
      _findString(row, const ['section_id', 'id']) ?? '';

  @override
  void initState() {
    super.initState();
    unawaited(_loadCatalog());
  }

  Future<void> _loadCatalog({bool forceRefresh = false}) async {
    if (_loading || _exporting) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    Set<String> cachedIds = const {};
    if (!forceRefresh) {
      try {
        final cached = await SaltCatalogStore.instance.read(widget.businessId);
        if (cached != null && mounted) _applyCatalog(cached);
      } catch (_) {
        // Continue with the network request when local persistence is absent.
      }
    }
    try {
      final catalog = await SaltCatalogStore.instance.load(
        api: widget.api,
        businessId: widget.businessId,
        forceRefresh: forceRefresh,
      );
      if (mounted) _applyCatalog(catalog);
      if (_isExportMode) {
        try {
          cachedIds = await SaltChapterCache.instance.cachedSectionIds(
            widget.businessId,
          );
        } catch (_) {
          cachedIds = const {};
        }
      }
    } catch (error) {
      if (_rows.isEmpty) _error = error;
    } finally {
      if (mounted) {
        setState(() {
          _cachedIds = cachedIds;
          _loading = false;
        });
      }
    }
  }

  void _applyCatalog(SaltCatalogSnapshot catalog) {
    final rows = catalog.rows;
    setState(() {
      _rows
        ..clear()
        ..addAll(rows);
      _serverTotal = catalog.total;
      final current = widget.currentSectionId;
      if (_isExportMode &&
          _selectedIds.isEmpty &&
          current != null &&
          rows.any((row) => _sectionId(row) == current)) {
        _selectedIds.add(current);
      }
    });
  }

  void _toggleSection(String sectionId) {
    if (sectionId.isEmpty || _exporting) return;
    setState(() {
      if (!_selectedIds.remove(sectionId)) _selectedIds.add(sectionId);
    });
  }

  void _toggleAll() {
    if (_exporting) return;
    final ids = _rows.map(_sectionId).where((id) => id.isNotEmpty).toSet();
    setState(() {
      if (_selectedIds.length == ids.length && _selectedIds.containsAll(ids)) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(ids);
      }
    });
  }

  Future<void> _exportSelected() async {
    final format = widget.exportFormat;
    if (format == null || _selectedIds.isEmpty || _exporting) return;
    final l10n = context.zhL10n;
    setState(() {
      _exporting = true;
      _error = null;
      _exportProgress = '';
    });
    try {
      final selectedRows = sortSaltCatalogSections(
        _rows.where((row) => _selectedIds.contains(_sectionId(row))),
        descending: false,
      );
      final sections = <SaltChapterExportSection>[];
      const width = PrivacyDeviceProfile.logicalScreenWidth;
      for (var index = 0; index < selectedRows.length; index++) {
        final row = selectedRows[index];
        final sectionId = _sectionId(row);
        final rowTitle = titleOf(row).isEmpty
            ? l10n.saltSectionLabel(index + 1)
            : titleOf(row);
        if (mounted) {
          setState(
            () => _exportProgress = l10n.saltProcessing(
              index + 1,
              selectedRows.length,
              rowTitle,
            ),
          );
        }
        SaltCachedChapter? cached;
        try {
          cached = await SaltChapterCache.instance.read(
            businessId: widget.businessId,
            sectionId: sectionId,
          );
        } catch (_) {
          cached = null;
        }
        cached ??= await _downloadSaltChapterForCache(
          api: widget.api,
          businessId: widget.businessId,
          sectionId: sectionId,
          title: rowTitle,
          sectionIndex: _jsonCatalogIndex(unwrapObject(row)),
          windowWidth: width,
          keyProvider: widget.keyProvider,
        );
        sections.add(
          SaltChapterExportSection(
            title: rowTitle,
            paragraphs: cached.toTextChapter().paragraphs,
          ),
        );
        if (mounted) {
          setState(() => _cachedIds = {..._cachedIds, sectionId});
        }
      }
      final file = buildSaltChapterExport(
        title: widget.title,
        sectionId: widget.businessId,
        sections: sections,
        format: format,
      );
      final location = await const SaltChapterFileSaver().save(file);
      if (mounted) Navigator.of(context).pop(location);
    } catch (error) {
      if (!mounted) return;
      final failure = ApiFailure.from(error);
      setState(() {
        _error = error;
        _exportProgress = '${failure.title}：${failure.detail}';
      });
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final total = _serverTotal ?? widget.sectionCount ?? _rows.length;
    final rows = sortSaltCatalogSections(
      _rows,
      descending: _order == _SaltCatalogOrder.descending,
    );
    final allSelected =
        _rows.isNotEmpty &&
        _selectedIds.length == _rows.length &&
        _rows.every((row) => _selectedIds.contains(_sectionId(row)));
    final formatLabel = widget.exportFormat == SaltChapterExportFormat.docx
        ? 'DOCX'
        : 'TXT';
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _SaltSheetHeader(
            title: l10n.saltCatalogTitle,
            subtitle: widget.title.isEmpty ? null : widget.title,
            onClose: _exporting ? null : () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(
              children: [
                Text(
                  total > 0
                      ? l10n.saltChapterCount(total)
                      : l10n.saltChapterDirectory,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ZhPalette.mutedInk,
                    letterSpacing: 0,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 38,
                  child: SegmentedButton<_SaltCatalogOrder>(
                    segments: [
                      ButtonSegment(
                        value: _SaltCatalogOrder.ascending,
                        label: Text(l10n.saltAscending),
                      ),
                      ButtonSegment(
                        value: _SaltCatalogOrder.descending,
                        label: Text(l10n.saltDescending),
                      ),
                    ],
                    selected: {_order},
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                    onSelectionChanged: (selection) {
                      setState(() => _order = selection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_isExportMode && !_loading && _rows.isNotEmpty) ...[
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Checkbox(
                    value: allSelected,
                    onChanged: _exporting ? null : (_) => _toggleAll(),
                  ),
                  TextButton(
                    onPressed: _exporting ? null : _toggleAll,
                    child: Text(
                      allSelected
                          ? l10n.saltCancelSelectAll
                          : l10n.saltSelectAll,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      l10n.saltSelectedCount(_selectedIds.length, total),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ZhPalette.mutedInk,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          Expanded(child: _body(rows, total, l10n)),
          if (_isExportMode && _exportProgress.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                _exportProgress,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _error == null ? ZhPalette.mutedInk : ZhPalette.danger,
                  letterSpacing: 0,
                ),
              ),
            ),
          if (_isExportMode)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _selectedIds.isEmpty || _exporting
                      ? null
                      : _exportSelected,
                  icon: _exporting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(
                    _exporting
                        ? l10n.saltDownloadingChapters
                        : l10n.saltExportChapters(
                            formatLabel,
                            _selectedIds.length,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(
    List<Map<String, dynamic>> rows,
    int total,
    AppLocalizations l10n,
  ) {
    if (_loading && rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && rows.isEmpty) {
      return ApiErrorView(
        error: _error!,
        onRetry: () => _loadCatalog(forceRefresh: true),
        titleOverride: l10n.saltDirectoryLoadFailed,
        detailOverride: l10n.saltNetworkRetry,
      );
    }
    if (rows.isEmpty) {
      return Center(child: Text(l10n.saltDirectoryEmpty));
    }
    return RefreshIndicator(
      onRefresh: () => _loadCatalog(forceRefresh: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final value = rows[index];
          final sectionId = _findString(value, const ['section_id', 'id']);
          final selected = sectionId == widget.currentSectionId;
          return _SaltCatalogRow(
            value: value,
            selected: selected,
            selectable: _isExportMode,
            checked: sectionId != null && _selectedIds.contains(sectionId),
            cached: sectionId != null && _cachedIds.contains(sectionId),
            selectionEnabled: !_exporting,
            progressText: saltCatalogProgressText(
              value,
              selected: selected,
              currentSectionIndex: widget.currentSectionIndex,
              sectionCount: total,
              l10n: l10n,
            ),
            onTap: sectionId == null
                ? null
                : _isExportMode
                ? () => _toggleSection(sectionId)
                : () => widget.onOpenSection?.call(sectionId),
          );
        },
      ),
    );
  }
}

class _SaltCatalogRow extends StatelessWidget {
  const _SaltCatalogRow({
    required this.value,
    required this.selected,
    required this.selectable,
    required this.checked,
    required this.cached,
    required this.selectionEnabled,
    required this.progressText,
    this.onTap,
  });

  final Map<String, dynamic> value;
  final bool selected;
  final bool selectable;
  final bool checked;
  final bool cached;
  final bool selectionEnabled;
  final String progressText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final object = unwrapObject(value);
    final index = _saltMap(object['index']);
    final chapter = _saltMap(object['chapter']);
    final serial = plainText(
      object['serial_number_text'] ??
          index?['serial_number_txt'] ??
          chapter?['serial_number_txt'],
    );
    final title = plainText(object['title']);
    final locked = object['is_lock'] == true || object['is_locked'] == true;
    final lastRead = object['last_read'] == true || selected;
    final label = [
      if (serial.isNotEmpty) serial,
      if (title.isNotEmpty && title != serial) title,
    ].join(' ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.07)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListTile(
        minTileHeight: 58,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        enabled: !selectable || selectionEnabled,
        onTap: selectionEnabled ? onTap : null,
        leading: selectable
            ? Checkbox(
                value: checked,
                onChanged: selectionEnabled ? (_) => onTap?.call() : null,
              )
            : null,
        title: Row(
          children: [
            Expanded(
              child: Text(
                label.isEmpty ? l10n.saltUntitledChapter : label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (lastRead) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.saltLastRead,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progressText.isNotEmpty)
              Text(
                progressText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : ZhPalette.mutedInk,
                  letterSpacing: 0,
                ),
              ),
            if (progressText.isNotEmpty && (cached || locked))
              const SizedBox(width: 8),
            if (locked)
              const Icon(Icons.lock_outline_rounded, size: 20)
            else if (cached)
              Tooltip(
                message: l10n.saltCached,
                child: Icon(
                  Icons.download_done_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            else if (!selectable && selected)
              const Icon(Icons.menu_book_rounded, size: 20)
            else if (!selectable)
              const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
