part of '../salt_page.dart';

extension _SaltReaderContent on _SaltReaderPageState {
  Widget _readerLoading(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(height: 14),
        Text(
          context.zhL10n.commonLoading,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
        ),
      ],
    ),
  );

  Widget _textReader(
    BuildContext context,
    SaltManuscriptEnvelope manuscript,
    SaltTextChapter chapter, {
    required String title,
    required bool hasCatalog,
    required SaltManuscriptEnvelope? commentMetadata,
  }) => Stack(
    children: [
      Positioned.fill(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SaltChapterView(
                  key: ValueKey('${chapter.contentId}-${_readerFlow.name}'),
                  chapter: chapter,
                  flow: _readerFlow,
                  settings: _readerSettings,
                  annotations: _paragraphAnnotations,
                  onReaderTap: () =>
                      _updateState(() => _controlsVisible = !_controlsVisible),
                  onScrollDirection: _readerScrollDirectionChanged,
                  showPageIndicator: _controlsVisible,
                  onAnnotationTap: (annotation) =>
                      _showAnnotationComments(manuscript, annotation),
                ),
              ),
            ),
          ),
        ),
      ),
      _readerChapterHint(manuscript, title),
      _readerTopToolbar(manuscript, title, chapter: chapter),
      _readerBottomToolbar(
        manuscript,
        hasCatalog: hasCatalog,
        commentMetadata: commentMetadata,
      ),
    ],
  );

  Widget _readerChapterHint(SaltManuscriptEnvelope manuscript, String title) =>
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          bottom: false,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: _controlsVisible ? 0 : 1,
              child: SizedBox(
                height: 38,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _readerSectionLabel(manuscript, title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ZhPalette.mutedInk,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _readerTopToolbar(
    SaltManuscriptEnvelope manuscript,
    String title, {
    required SaltTextChapter chapter,
  }) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: IgnorePointer(
      ignoring: !_controlsVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: _controlsVisible ? Offset.zero : const Offset(0, -1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 140),
          opacity: _controlsVisible ? 1 : 0,
          child: Semantics(
            key: const ValueKey('salt-reader-top-toolbar'),
            container: true,
            label: context.zhL10n.saltReaderTopBar,
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 1,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        tooltip: context.zhL10n.commonBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _readerToolbarSubtitle(manuscript),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: ZhPalette.mutedInk),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _bookshelfSaving || _addedToBookshelf
                            ? null
                            : () => _addToBookshelf(manuscript),
                        style: TextButton.styleFrom(
                          foregroundColor: ZhPalette.accent,
                          disabledForegroundColor: _addedToBookshelf
                              ? ZhPalette.accent
                              : ZhPalette.subtleInk,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_bookshelfSaving)
                              const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Icon(
                                _addedToBookshelf
                                    ? Icons.bookmark_added_rounded
                                    : Icons.bookmark_add_outlined,
                                size: 21,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              _addedToBookshelf
                                  ? context.zhL10n.saltAdded
                                  : context.zhL10n.saltAddToBookshelf,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _exporting
                            ? null
                            : () => _showReaderMoreMenu(manuscript, chapter),
                        tooltip: context.zhL10n.saltMore,
                        icon: const Icon(Icons.more_vert_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
