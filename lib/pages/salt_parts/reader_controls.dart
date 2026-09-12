part of '../salt_page.dart';

extension _SaltReaderControls on _SaltReaderPageState {
  Widget _readerBottomToolbar(
    SaltManuscriptEnvelope manuscript, {
    required bool hasCatalog,
    required SaltManuscriptEnvelope? commentMetadata,
  }) {
    final sectionCount = _effectiveSectionCount(manuscript);
    final sectionIndex = _effectiveSectionIndex(manuscript);
    final previous = _previousCatalogSection(manuscript);
    final next = _nextCatalogSection(manuscript);
    final progress =
        sectionCount != null && sectionCount > 0 && sectionIndex != null
        ? ((sectionIndex + 1) / sectionCount).clamp(0.0, 1.0)
        : null;
    final commentCount = commentMetadata?.commentCount;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: !_controlsVisible,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          offset: _controlsVisible ? Offset.zero : const Offset(0, 1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 140),
            opacity: _controlsVisible ? 1 : 0,
            child: Semantics(
              key: const ValueKey('salt-reader-bottom-toolbar'),
              container: true,
              label: '阅读底部栏',
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 4,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: previous == null
                                  ? null
                                  : () => _openSection(previous.id),
                              child: const Text('上一节'),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(2),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: next == null
                                  ? null
                                  : () => _openSection(next.id),
                              child: const Text('下一节'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SizedBox(
                        height: 68,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SaltReaderToolbarAction(
                              icon: Icons.format_list_numbered_rounded,
                              label: '目录',
                              onTap: hasCatalog
                                  ? () => _showCatalog(manuscript)
                                  : null,
                            ),
                            _SaltReaderToolbarAction(
                              icon: Icons.text_fields_rounded,
                              label: '设置',
                              onTap: _showReaderSettings,
                            ),
                            _SaltReaderToolbarAction(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: commentCount == null
                                  ? '评论'
                                  : compactCount(commentCount),
                              onTap: () =>
                                  _showChapterComments(commentMetadata),
                            ),
                            _SaltReaderToolbarAction(
                              icon: _readerFlow == SaltReaderFlow.vertical
                                  ? Icons.view_carousel_outlined
                                  : Icons.view_day_outlined,
                              label: _readerFlow == SaltReaderFlow.vertical
                                  ? '左右'
                                  : '上下',
                              onTap: () => _updateState(() {
                                _readerFlow =
                                    _readerFlow == SaltReaderFlow.vertical
                                    ? SaltReaderFlow.paginated
                                    : SaltReaderFlow.vertical;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _readerSectionLabel(SaltManuscriptEnvelope manuscript, String title) {
    final index = _effectiveSectionIndex(manuscript);
    final count = _effectiveSectionCount(manuscript);
    final chapterTitle = (manuscript.title.isEmpty ? title : manuscript.title)
        .replaceFirst(RegExp(r'^第\s*\d+\s*节\s*'), '')
        .trim();
    if (index == null) return chapterTitle;
    return count == null
        ? '第 ${index + 1} 节  $chapterTitle'
        : '第 ${index + 1}/$count 节  $chapterTitle';
  }

  String _readerToolbarSubtitle(SaltManuscriptEnvelope manuscript) {
    final parts = <String>[];
    final index = _effectiveSectionIndex(manuscript);
    final count = _effectiveSectionCount(manuscript);
    if (index != null) {
      parts.add(count == null ? '第 ${index + 1} 节' : '${index + 1}/$count');
    }
    if (_catalogLoading) {
      parts.add('正在同步目录');
    } else if (_catalogError != null) {
      parts.add('目录导航待重试');
    }
    if (_annotationsLoading) {
      parts.add('正在载入弹评');
    } else if (_annotationsError != null) {
      parts.add('弹评载入失败');
    } else if (_paragraphAnnotations.isNotEmpty) {
      parts.add('${_paragraphAnnotations.length} 处弹评');
    }
    return parts.isEmpty ? '盐选阅读' : parts.join(' · ');
  }

  Future<void> _showCatalog(SaltManuscriptEnvelope manuscript) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.92,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: _SaltCatalogSheet(
            api: widget.api,
            businessId: widget.businessId,
            currentSectionId: widget.sectionId,
            currentSectionIndex: _effectiveSectionIndex(manuscript),
            sectionCount: _effectiveSectionCount(manuscript),
            title: manuscript.parentTitle.isNotEmpty
                ? manuscript.parentTitle
                : manuscript.title,
            onOpenSection: (sectionId) {
              Navigator.of(sheetContext).pop();
              if (sectionId != widget.sectionId) _openSection(sectionId);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAnnotationComments(
    SaltManuscriptEnvelope manuscript,
    SaltParagraphAnnotation annotation,
  ) async {
    await _showCommentSheet(
      objectType: ZhihuApiClient.saltParagraphCommentObjectType,
      objectId: annotation.commentId,
      title: '${annotation.commentCount} 条弹评',
      count: annotation.commentCount,
      showSort: false,
    );
  }

  Future<void> _showChapterComments(SaltManuscriptEnvelope? metadata) async {
    final target = metadata == null
        ? ('paid_column_section_manuscripts', widget.sectionId)
        : _commentTarget(metadata) ??
              ('paid_column_section_manuscripts', widget.sectionId);
    await _showCommentSheet(
      objectType: target.$1,
      objectId: target.$2,
      title: '全部评论',
      count: metadata?.commentCount,
      showSort: true,
    );
  }

  Future<void> _showCommentSheet({
    required String objectType,
    required String objectId,
    required String title,
    required int? count,
    required bool showSort,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.92,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: _SaltCommentsSheet(
          api: widget.api,
          objectType: objectType,
          objectId: objectId,
          title: title,
          count: count,
          showSort: showSort,
        ),
      ),
    ),
  );
}
