import 'package:flutter/material.dart';

import '../l10n/zh_localization.dart';
import '../core/json_tools.dart';
import '../core/salt_text_chapter.dart';

enum SaltReaderFlow { vertical, paginated }

@immutable
class SaltTextPageSegment {
  const SaltTextPageSegment({
    required this.text,
    required this.gapBefore,
    required this.paragraphIndex,
    required this.isParagraphEnd,
    required this.isSectionTitle,
  });

  final String text;
  final bool gapBefore;
  final int paragraphIndex;
  final bool isParagraphEnd;
  final bool isSectionTitle;
}

@visibleForTesting
List<List<SaltTextPageSegment>> paginateSaltParagraphs({
  required List<String> paragraphs,
  required TextStyle style,
  required TextDirection textDirection,
  required TextScaler textScaler,
  required double maxWidth,
  required double maxHeight,
  required double paragraphGap,
  Set<int> sectionTitleIndexes = const {},
}) {
  if (paragraphs.isEmpty || maxWidth <= 0 || maxHeight <= 0) return const [];

  final pages = <List<SaltTextPageSegment>>[];
  var page = <SaltTextPageSegment>[];
  var usedHeight = 0.0;

  double textHeight(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout(maxWidth: maxWidth);
    return painter.height;
  }

  void finishPage() {
    if (page.isEmpty) return;
    pages.add(List.unmodifiable(page));
    page = <SaltTextPageSegment>[];
    usedHeight = 0;
  }

  for (
    var paragraphIndex = 0;
    paragraphIndex < paragraphs.length;
    paragraphIndex++
  ) {
    final paragraph = paragraphs[paragraphIndex];
    if (paragraph.isEmpty) continue;
    var remaining = paragraph;
    var startsParagraph = true;
    while (remaining.isNotEmpty) {
      final gap = startsParagraph && page.isNotEmpty ? paragraphGap : 0.0;
      final available = maxHeight - usedHeight - gap;
      final height = textHeight(remaining);
      if (height <= available + 0.01) {
        page.add(
          SaltTextPageSegment(
            text: remaining,
            gapBefore: gap > 0,
            paragraphIndex: paragraphIndex,
            isParagraphEnd: true,
            isSectionTitle: sectionTitleIndexes.contains(paragraphIndex),
          ),
        );
        usedHeight += gap + height;
        remaining = '';
        continue;
      }

      final prefixLength = _largestFittingPrefix(
        remaining,
        availableHeight: available,
        textHeight: textHeight,
      );
      if (prefixLength <= 0) {
        finishPage();
        continue;
      }
      page.add(
        SaltTextPageSegment(
          text: remaining.substring(0, prefixLength),
          gapBefore: gap > 0,
          paragraphIndex: paragraphIndex,
          isParagraphEnd: false,
          isSectionTitle: sectionTitleIndexes.contains(paragraphIndex),
        ),
      );
      remaining = remaining.substring(prefixLength);
      startsParagraph = false;
      finishPage();
    }
  }
  finishPage();
  return List.unmodifiable(pages);
}

int _largestFittingPrefix(
  String text, {
  required double availableHeight,
  required double Function(String) textHeight,
}) {
  if (availableHeight <= 0) return 0;
  var low = 1;
  var high = text.length;
  var best = 0;
  while (low <= high) {
    final middle = low + ((high - low) >> 1);
    if (textHeight(text.substring(0, middle)) <= availableHeight + 0.01) {
      best = middle;
      low = middle + 1;
    } else {
      high = middle - 1;
    }
  }
  if (best > 0 &&
      best < text.length &&
      _isHighSurrogate(text.codeUnitAt(best - 1)) &&
      _isLowSurrogate(text.codeUnitAt(best))) {
    best--;
  }
  return best;
}

bool _isHighSurrogate(int value) => value >= 0xD800 && value <= 0xDBFF;

bool _isLowSurrogate(int value) => value >= 0xDC00 && value <= 0xDFFF;

class SaltChapterView extends StatefulWidget {
  const SaltChapterView({
    super.key,
    required this.chapter,
    required this.flow,
    required this.settings,
    this.annotations = const {},
    this.onAnnotationTap,
    this.onPageChanged,
    this.onReaderTap,
    this.onPreviousChapter,
    this.onNextChapter,
    this.onScrollDirection,
    this.jumpToParagraphIndex,
    this.jumpRequest = 0,
    this.showPageIndicator = false,
  });

  final SaltTextChapter chapter;
  final SaltReaderFlow flow;
  final SaltReaderSettings settings;
  final Map<int, SaltParagraphAnnotation> annotations;
  final ValueChanged<SaltParagraphAnnotation>? onAnnotationTap;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onReaderTap;
  final VoidCallback? onPreviousChapter;
  final VoidCallback? onNextChapter;

  /// Requests that the reader reveal a paragraph selected from an embedded
  /// short-story directory.  The request counter makes repeated selections of
  /// the same subsection observable by the state object.
  final int? jumpToParagraphIndex;
  final int jumpRequest;

  /// Reports whether the reader controls should be shown. `false` is emitted
  /// when the content scrolls toward later paragraphs, and `true` when the
  /// user scrolls back toward the beginning.
  final ValueChanged<bool>? onScrollDirection;
  final bool showPageIndicator;

  @override
  State<SaltChapterView> createState() => _SaltChapterViewState();
}

class _SaltChapterViewState extends State<SaltChapterView> {
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );
  PageController? _pageController;
  List<List<SaltTextPageSegment>> _pages = const [];
  String? _paginationKey;
  int _page = 0;
  double _lastScrollOffset = 0;
  final _paragraphKeys = <int, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScrollDirection);
    _syncPageController();
    _scheduleParagraphJump();
  }

  @override
  void didUpdateWidget(covariant SaltChapterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flow != widget.flow ||
        oldWidget.chapter.contentId != widget.chapter.contentId ||
        oldWidget.settings != widget.settings) {
      _page = 0;
      _lastScrollOffset = 0;
      _paginationKey = null;
      _paragraphKeys.clear();
      _syncPageController();
    }
    if (oldWidget.jumpRequest != widget.jumpRequest) {
      _scheduleParagraphJump();
    }
  }

  GlobalKey _paragraphKey(int index) =>
      _paragraphKeys.putIfAbsent(index, GlobalKey.new);

  void _scheduleParagraphJump() {
    final paragraphIndex = widget.jumpToParagraphIndex;
    if (paragraphIndex == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _jumpToParagraph(paragraphIndex);
    });
  }

  void _jumpToParagraph(int paragraphIndex) {
    if (paragraphIndex < 0 ||
        paragraphIndex >= widget.chapter.paragraphs.length) {
      return;
    }
    if (widget.flow == SaltReaderFlow.paginated) {
      if (_pages.isEmpty || _pageController == null) return;
      var targetPage = -1;
      for (var pageIndex = 0; pageIndex < _pages.length; pageIndex++) {
        if (_pages[pageIndex].any(
          (segment) => segment.paragraphIndex >= paragraphIndex,
        )) {
          targetPage = pageIndex;
          break;
        }
      }
      if (targetPage < 0) targetPage = _pages.length - 1;
      if (_pageController!.hasClients) {
        _pageController!.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    final targetContext = _paragraphKeys[paragraphIndex]?.currentContext;
    if (targetContext != null) {
      _ensureParagraphVisible(targetContext);
      return;
    }
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final lastIndex = widget.chapter.paragraphs.length - 1;
    final estimate = lastIndex <= 0
        ? 0.0
        : maxScroll * (paragraphIndex / lastIndex);
    _scrollController
        .animateTo(
          estimate,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        )
        .then((_) {
          if (!mounted) return;
          _ensureParagraphVisibleAt(paragraphIndex);
        });
  }

  void _ensureParagraphVisibleAt(int paragraphIndex) {
    final targetContext = _paragraphKeys[paragraphIndex]?.currentContext;
    if (targetContext != null) _ensureParagraphVisible(targetContext);
  }

  void _ensureParagraphVisible(BuildContext context) {
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _syncPageController() {
    _pageController?.dispose();
    _pageController = widget.flow == SaltReaderFlow.paginated
        ? PageController()
        : null;
  }

  void _handleScrollDirection() {
    if (!_scrollController.hasClients ||
        widget.flow != SaltReaderFlow.vertical) {
      return;
    }
    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;
    _lastScrollOffset = offset;
    if (delta.abs() < 1.5) return;
    // Increasing offset means the reader is moving toward later paragraphs;
    // this is the same direction in which the native reader hides its bars.
    widget.onScrollDirection?.call(delta < 0);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScrollDirection)
      ..dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: settings.fontSize,
      height: settings.lineHeight,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    );
    final gap = settings.paragraphSpacing * settings.fontSize;
    if (widget.flow == SaltReaderFlow.vertical) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onReaderTap,
        child: _verticalReader(context, style, gap),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _handlePaginatedTap(
          details,
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width,
        ),
        child: _paginatedReader(context, style, gap),
      ),
    );
  }

  void _handlePaginatedTap(TapUpDetails details, double width) {
    if (width <= 0) {
      widget.onReaderTap?.call();
      return;
    }
    final position = details.localPosition.dx;
    const edgeFraction = 0.3;
    if (position < width * edgeFraction) {
      _movePage(-1);
      return;
    }
    if (position > width * (1 - edgeFraction)) {
      _movePage(1);
      return;
    }
    widget.onReaderTap?.call();
  }

  void _movePage(int delta) {
    final controller = _pageController;
    if (controller == null || _pages.isEmpty) return;
    final currentPage = controller.hasClients ? controller.page : null;
    final current = (currentPage ?? _page)
        .round()
        .clamp(0, _pages.length - 1)
        .toInt();
    final target = current + delta;
    if (target < 0) {
      widget.onPreviousChapter?.call();
      return;
    }
    if (target >= _pages.length) {
      widget.onNextChapter?.call();
      return;
    }
    controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _verticalReader(BuildContext context, TextStyle style, double gap) {
    final settings = widget.settings;
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        settings.horizontalMargin,
        22,
        settings.horizontalMargin,
        40,
      ),
      itemCount: widget.chapter.paragraphs.length,
      separatorBuilder: (_, _) => SizedBox(height: gap),
      itemBuilder: (context, index) => KeyedSubtree(
        key: _paragraphKey(index),
        child: _ReaderParagraph(
          text: widget.chapter.paragraphs[index],
          style: style,
          selectable: false,
          isSectionTitle: widget.chapter.textParagraphs[index].isSectionTitle,
          annotation: widget.annotations[index],
          onAnnotationTap: widget.onAnnotationTap,
        ),
      ),
    );
  }

  Widget _paginatedReader(
    BuildContext context,
    TextStyle style,
    double gap,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      const topPadding = 22.0;
      const bottomPadding = 38.0;
      final contentWidth =
          (constraints.maxWidth - widget.settings.horizontalMargin * 2).clamp(
            1.0,
            double.infinity,
          );
      final contentHeight = (constraints.maxHeight - topPadding - bottomPadding)
          .clamp(1.0, double.infinity);
      final textScaler = MediaQuery.textScalerOf(context);
      final key = <Object>[
        widget.chapter.contentId,
        widget.settings.hashCode,
        contentWidth.round(),
        contentHeight.round(),
        textScaler.scale(100).round(),
      ].join('|');
      if (_paginationKey != key) {
        _paginationKey = key;
        _pages = paginateSaltParagraphs(
          paragraphs: widget.chapter.paragraphs,
          style: style,
          textDirection: Directionality.of(context),
          textScaler: textScaler,
          maxWidth: contentWidth,
          maxHeight: contentHeight,
          paragraphGap: gap,
          sectionTitleIndexes: {
            for (final paragraph in widget.chapter.textParagraphs)
              if (paragraph.isSectionTitle) paragraph.index,
          },
        );
      }
      if (_pages.isEmpty) return const SizedBox.shrink();
      return Stack(
        children: [
          PageView.builder(
            key: ValueKey('salt-pages-$key'),
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (value) {
              setState(() => _page = value);
              widget.onScrollDirection?.call(false);
              widget.onPageChanged?.call(value);
            },
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.fromLTRB(
                widget.settings.horizontalMargin,
                topPadding,
                widget.settings.horizontalMargin,
                bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (
                    var segment = 0;
                    segment < _pages[index].length;
                    segment++
                  ) ...[
                    if (_pages[index][segment].gapBefore) SizedBox(height: gap),
                    _ReaderParagraph(
                      text: _pages[index][segment].text,
                      style: style,
                      selectable: false,
                      isSectionTitle: _pages[index][segment].isSectionTitle,
                      annotation: _pages[index][segment].isParagraphEnd
                          ? widget.annotations[_pages[index][segment]
                                .paragraphIndex]
                          : null,
                      onAnnotationTap: widget.onAnnotationTap,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (widget.showPageIndicator)
            Positioned(
              right: widget.settings.horizontalMargin,
              bottom: 10,
              child: Text(
                '${_page + 1} / ${_pages.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0,
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _ReaderParagraph extends StatelessWidget {
  const _ReaderParagraph({
    required this.text,
    required this.style,
    this.selectable = true,
    this.isSectionTitle = false,
    this.annotation,
    this.onAnnotationTap,
  });

  final String text;
  final TextStyle style;
  final bool selectable;
  final bool isSectionTitle;
  final SaltParagraphAnnotation? annotation;
  final ValueChanged<SaltParagraphAnnotation>? onAnnotationTap;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = isSectionTitle
        ? style.copyWith(
            fontSize: (style.fontSize ?? 18) * 0.9,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )
        : style;
    final alignment = isSectionTitle ? TextAlign.center : TextAlign.start;
    final annotation = this.annotation;
    if (annotation == null) {
      if (selectable) {
        return SelectableText(
          text,
          textAlign: alignment,
          style: effectiveStyle,
        );
      }
      return Text(text, textAlign: alignment, style: effectiveStyle);
    }
    final richText = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text, style: effectiveStyle),
          const TextSpan(text: '  '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _ParagraphCommentBadge(
              annotation: annotation,
              onTap: onAnnotationTap == null
                  ? null
                  : () => onAnnotationTap!(annotation),
            ),
          ),
        ],
      ),
      textAlign: alignment,
    );
    if (selectable) {
      return SelectionArea(child: richText);
    }
    return richText;
  }
}

class _ParagraphCommentBadge extends StatelessWidget {
  const _ParagraphCommentBadge({required this.annotation, this.onTap});

  final SaltParagraphAnnotation annotation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final digits = annotation.commentCount.toString().length;
    final badgeWidth = (26.0 + (digits - 1) * 7).clamp(26.0, 54.0);
    final targetWidth = badgeWidth < 44 ? 44.0 : badgeWidth;
    final interactive = onTap != null;
    return Semantics(
      key: ValueKey('salt-paragraph-comment-${annotation.paragraphIndex}'),
      button: interactive,
      label: context.zhL10n.saltCommentBadge(annotation.commentCount),
      child: SizedBox(
        width: targetWidth,
        height: 44,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: SizedBox(
              width: badgeWidth,
              height: 22,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: annotation.hasOwnComment
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    annotation.commentCount.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  }
}
