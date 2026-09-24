part of '../salt_page.dart';

extension _SaltReaderActions on _SaltReaderPageState {
  Future<void> _addToBookshelf(SaltManuscriptEnvelope manuscript) async {
    final l10n = context.zhL10n;
    _updateState(() => _bookshelfSaving = true);
    try {
      final propertyType = manuscript.propertyType.isNotEmpty
          ? manuscript.propertyType
          : 'short_story';
      await _bookshelf.add(
        _localBookshelfEntry(
          businessId: widget.businessId,
          propertyType: propertyType,
          fallbackTitle: l10n.saltWorkFallback,
          title: manuscript.parentTitle.isNotEmpty
              ? manuscript.parentTitle
              : manuscript.title,
          artwork: manuscript.parentArtwork.isNotEmpty
              ? manuscript.parentArtwork
              : manuscript.artwork,
          sectionId: widget.sectionId,
        ),
      );
      if (!mounted) return;
      _updateState(() => _addedToBookshelf = true);
      var synced = false;
      var syncFailed = false;
      if (widget.api.canWrite) {
        try {
          final response = await widget.api.addSaltToBookshelf(
            bookListId: widget.businessId,
            propertyType: propertyType,
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
                ? '${l10n.saltAdded} · ${l10n.saltAccountSyncFailed}'
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
      if (mounted) _updateState(() => _bookshelfSaving = false);
    }
  }

  Future<void> _showReaderMoreMenu(
    SaltManuscriptEnvelope? manuscript,
    SaltTextChapter? chapter,
  ) async {
    final l10n = context.zhL10n;
    final isLong =
        manuscript != null &&
        (manuscript.isLong == true ||
            manuscript.propertyType == 'long_story' ||
            (_effectiveSectionCount(manuscript) ?? 0) > 1);
    final action = await showModalBottomSheet<_SaltReaderChapterMoreAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .82,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Column(
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
                  ).pop(_SaltReaderChapterMoreAction.refresh),
                ),
                ListTile(
                  key: const ValueKey('salt-reader-tts-action'),
                  enabled: chapter != null,
                  leading: Icon(
                    TtsService.instance.isPlaying
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_outlined,
                  ),
                  title: Text(
                    TtsService.instance.isPlaying
                        ? l10n.saltStopReading
                        : l10n.saltReadAloud,
                  ),
                  subtitle: Text(l10n.saltReadAloudSubtitle),
                  onTap: chapter == null
                      ? null
                      : () => Navigator.of(
                          sheetContext,
                        ).pop(_SaltReaderChapterMoreAction.readAloud),
                ),
                for (final format in ContentExportFormat.values)
                  ListTile(
                    key: ValueKey('salt-reader-export-${format.name}'),
                    enabled: chapter != null,
                    leading: Icon(switch (format) {
                      ContentExportFormat.markdown => Icons.code_rounded,
                      ContentExportFormat.html => Icons.language_rounded,
                      ContentExportFormat.pdf => Icons.picture_as_pdf_outlined,
                    }),
                    title: Text(l10n.saltExportChapter(format.label)),
                    onTap: chapter == null
                        ? null
                        : () => Navigator.of(sheetContext).pop(switch (format) {
                            ContentExportFormat.markdown =>
                              _SaltReaderChapterMoreAction.exportMarkdown,
                            ContentExportFormat.html =>
                              _SaltReaderChapterMoreAction.exportHtml,
                            ContentExportFormat.pdf =>
                              _SaltReaderChapterMoreAction.exportPdf,
                          }),
                  ),
                ListTile(
                  enabled: chapter != null,
                  leading: const Icon(Icons.text_snippet_outlined),
                  title: Text(l10n.saltExportTxt),
                  onTap: chapter == null
                      ? null
                      : () => Navigator.of(
                          sheetContext,
                        ).pop(_SaltReaderChapterMoreAction.exportTxt),
                ),
                ListTile(
                  enabled: chapter != null,
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.saltExportDocx),
                  onTap: chapter == null
                      ? null
                      : () => Navigator.of(
                          sheetContext,
                        ).pop(_SaltReaderChapterMoreAction.exportDocx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _SaltReaderChapterMoreAction.refresh:
        await _read(bypassCache: true);
        break;
      case _SaltReaderChapterMoreAction.readAloud:
        await _toggleReaderTts(manuscript, chapter);
        break;
      case _SaltReaderChapterMoreAction.exportMarkdown:
        if (manuscript != null && chapter != null) {
          await _exportCurrentChapterDocument(
            manuscript,
            chapter,
            ContentExportFormat.markdown,
          );
        }
        break;
      case _SaltReaderChapterMoreAction.exportHtml:
        if (manuscript != null && chapter != null) {
          await _exportCurrentChapterDocument(
            manuscript,
            chapter,
            ContentExportFormat.html,
          );
        }
        break;
      case _SaltReaderChapterMoreAction.exportPdf:
        if (manuscript != null && chapter != null) {
          await _exportCurrentChapterDocument(
            manuscript,
            chapter,
            ContentExportFormat.pdf,
          );
        }
        break;
      case _SaltReaderChapterMoreAction.exportTxt:
        if (isLong) {
          await _exportLongWork(manuscript, SaltChapterExportFormat.txt);
        } else {
          await _exportChapter(
            manuscript!,
            chapter!,
            SaltChapterExportFormat.txt,
          );
        }
        break;
      case _SaltReaderChapterMoreAction.exportDocx:
        if (isLong) {
          await _exportLongWork(manuscript, SaltChapterExportFormat.docx);
        } else {
          await _exportChapter(
            manuscript!,
            chapter!,
            SaltChapterExportFormat.docx,
          );
        }
        break;
    }
  }

  Future<void> _toggleReaderTts(
    SaltManuscriptEnvelope? manuscript,
    SaltTextChapter? chapter,
  ) async {
    final l10n = context.zhL10n;
    final tts = TtsService.instance;
    if (tts.isPlaying) {
      await tts.stop();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saltStopReading)));
      }
      return;
    }
    if (chapter == null) return;
    final title = manuscript == null
        ? l10n.saltUntitledChapter
        : _readerSectionLabel(manuscript, l10n.saltUntitledChapter);
    final started = await tts.speak(chapter.plainText, title: title);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          started
              ? l10n.saltReadingStarted(title.isEmpty ? '' : '：$title')
              : l10n.saltSpeechUnavailable,
        ),
      ),
    );
  }

  Future<void> _exportCurrentChapterDocument(
    SaltManuscriptEnvelope manuscript,
    SaltTextChapter chapter,
    ContentExportFormat format,
  ) async {
    final l10n = context.zhL10n;
    _updateState(() => _exporting = true);
    try {
      final title = manuscript.parentTitle.isNotEmpty
          ? manuscript.parentTitle
          : manuscript.title;
      final location = await ContentExportService.saveSections(
        title: title.isEmpty ? l10n.saltUntitledChapter : title,
        sectionId: widget.sectionId,
        sections: [
          SaltChapterExportSection(
            title: manuscript.title,
            paragraphs: chapter.paragraphs,
          ),
        ],
        format: format,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saltExportedAs(format.label, location))),
      );
    } catch (error) {
      assert(() {
        debugPrint('[zhihu-salt] contentExportFailure=$error');
        return true;
      }());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saltExportFailed)));
      }
    } finally {
      if (mounted) _updateState(() => _exporting = false);
    }
  }

  Future<void> _exportChapter(
    SaltManuscriptEnvelope manuscript,
    SaltTextChapter chapter,
    SaltChapterExportFormat format,
  ) async {
    final l10n = context.zhL10n;
    _updateState(() => _exporting = true);
    try {
      final workTitle = manuscript.parentTitle.isNotEmpty
          ? manuscript.parentTitle
          : manuscript.title;
      final sectionTitle = _readerSectionLabel(manuscript, workTitle);
      final exportTitle = sectionTitle.isEmpty || sectionTitle == workTitle
          ? workTitle
          : '$workTitle - $sectionTitle';
      final file = buildSaltChapterExport(
        title: exportTitle,
        sectionId: widget.sectionId,
        sections: [
          SaltChapterExportSection(
            title: manuscript.title,
            paragraphs: chapter.paragraphs,
          ),
        ],
        format: format,
      );
      final location = await const SaltChapterFileSaver().save(file);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saltExportedTo(location))));
    } catch (error) {
      assert(() {
        debugPrint('[zhihu-salt] chapterExportFailure=$error');
        return true;
      }());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saltExportFailed)));
    } finally {
      if (mounted) _updateState(() => _exporting = false);
    }
  }

  Future<void> _exportLongWork(
    SaltManuscriptEnvelope manuscript,
    SaltChapterExportFormat format,
  ) async {
    final l10n = context.zhL10n;
    final location = await showSaltLongExportSheet(
      context: context,
      api: widget.api,
      businessId: widget.businessId,
      workTitle: manuscript.parentTitle.isNotEmpty
          ? manuscript.parentTitle
          : manuscript.title,
      currentSectionId: widget.sectionId,
      keyProvider: widget.keyProvider,
      format: format,
    );
    if (!mounted || location == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.saltExportedTo(location))));
  }
}
