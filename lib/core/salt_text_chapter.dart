import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:universal_reader/universal_reader.dart';

import 'salt_transport_decoder.dart';

class SaltTextChapterException implements Exception {
  const SaltTextChapterException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Backwards-compatible client name for the generic reader's layout model.
typedef SaltReaderSettings = ReaderSettings;

enum SaltTextParagraphKind { body, sectionTitle }

class SaltTextParagraph {
  const SaltTextParagraph({
    required this.text,
    required this.index,
    required this.kind,
    this.blockKey = '',
  });

  final String text;
  final int index;
  final SaltTextParagraphKind kind;
  final String blockKey;

  bool get isSectionTitle => kind == SaltTextParagraphKind.sectionTitle;
}

/// A numbered subsection embedded in a short-story chapter.
///
/// Salt's short stories are sometimes returned as one server chapter even
/// though the body contains an internal directory such as `01`, `02`, `03`.
/// Keeping the paragraph index here lets the reader expose those entries
/// without pretending that they are separate server chapters.
class SaltTextSection {
  const SaltTextSection({required this.title, required this.paragraphIndex});

  final String title;
  final int paragraphIndex;
}

class SaltTextChapter {
  const SaltTextChapter._({
    required this.chapterId,
    required this.contentId,
    required this.xhtml,
    required this.document,
    required this.textParagraphs,
    required this.paragraphs,
    required this.plainText,
    required this.shortSections,
  });

  final String chapterId;
  final String contentId;
  final String xhtml;
  final ReaderDocument document;
  final List<SaltTextParagraph> textParagraphs;
  final List<String> paragraphs;
  final String plainText;
  final List<SaltTextSection> shortSections;

  factory SaltTextChapter.fromXhtml({
    required String chapterId,
    required String xhtml,
    ReaderBookInfo? book,
    ReaderCatalog? catalog,
    String? title,
    int? index,
  }) {
    final outline = _outlineFor(catalog, chapterId);
    final effectiveTitle = _nonEmpty(title) ?? outline?.title ?? chapterId;
    final effectiveIndex = index ?? outline?.index ?? 0;
    final effectiveBook =
        book ??
        ReaderBookInfo(id: catalog?.bookId ?? chapterId, title: effectiveTitle);
    final readerChapter = ReaderChapter(
      id: chapterId,
      title: effectiveTitle,
      index: effectiveIndex,
      content: xhtml,
      format: ReaderContentFormat.html,
    );
    late final ReaderDocument document;
    try {
      document = ReaderParser.parse(
        book: effectiveBook,
        chapter: readerChapter,
        catalog: catalog,
      );
    } on Object catch (error, stackTrace) {
      throw SaltTextChapterException(
        '章节正文结构解析失败。',
        cause: '$error\n$stackTrace',
      );
    }
    final textParagraphs = _saltParagraphs(
      document,
      sectionTitleTexts: _sectionTitleTexts(xhtml),
    );
    if (textParagraphs.isEmpty) {
      throw const SaltTextChapterException('章节正文中没有可显示的文本段落。');
    }
    final paragraphs = textParagraphs
        .map((paragraph) => paragraph.text)
        .toList(growable: false);
    final shortSections = _shortSections(textParagraphs);
    return SaltTextChapter._(
      chapterId: chapterId,
      contentId: '$chapterId-${xhtml.length}-${paragraphs.length}',
      xhtml: xhtml,
      document: document,
      textParagraphs: List.unmodifiable(textParagraphs),
      paragraphs: List.unmodifiable(paragraphs),
      plainText: paragraphs.join('\n\n'),
      shortSections: shortSections,
    );
  }

  static SaltTextChapter decode({
    required String chapterId,
    required String script,
    required String articleCode,
    required String strategy,
    required String rawKey,
    ReaderBookInfo? book,
    ReaderCatalog? catalog,
    String? title,
    int? index,
  }) {
    final xhtml = SaltTransportDecoder.decode(
      script: script,
      articleCode: articleCode,
      strategy: strategy,
      rawKey: rawKey,
    );
    return SaltTextChapter.fromXhtml(
      chapterId: chapterId,
      xhtml: xhtml,
      book: book,
      catalog: catalog,
      title: title,
      index: index,
    );
  }

  static List<String> extractParagraphs(String xhtml) {
    return extractTextParagraphs(
      xhtml,
    ).map((paragraph) => paragraph.text).toList(growable: false);
  }

  static List<SaltTextParagraph> extractTextParagraphs(String xhtml) {
    final document = ReaderParser.parse(
      book: const ReaderBookInfo(id: 'chapter', title: 'chapter'),
      chapter: ReaderChapter(
        id: 'chapter',
        title: 'chapter',
        index: 0,
        content: xhtml,
        format: ReaderContentFormat.html,
      ),
    );
    return List.unmodifiable(
      _saltParagraphs(document, sectionTitleTexts: _sectionTitleTexts(xhtml)),
    );
  }

  static List<SaltTextParagraph> _saltParagraphs(
    ReaderDocument document, {
    Iterable<String> sectionTitleTexts = const <String>[],
  }) => _saltParagraphsWithSequentialIndexes(
    document,
    sectionTitleTexts: sectionTitleTexts,
  );

  static List<SaltTextParagraph> _saltParagraphsWithSequentialIndexes(
    ReaderDocument document, {
    Iterable<String> sectionTitleTexts = const <String>[],
  }) {
    final paragraphs = <SaltTextParagraph>[];
    final titles = sectionTitleTexts
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final numberedTitleCount = document.textNodes
        .map((node) => node.text.trim())
        .where(_isShortSectionTitle)
        .length;
    var titleIndex = 0;
    for (final node in document.textNodes) {
      final text = node.text.trim();
      if (text.isEmpty) continue;
      var isSectionTitle =
          node.kind == ReaderNodeKind.heading ||
          node.blockKey == 'paragraphTitle';
      if (!isSectionTitle &&
          numberedTitleCount > 1 &&
          _isShortSectionTitle(text)) {
        isSectionTitle = true;
      }
      // universal_reader deliberately preserves data-block-key over CSS
      // classes. Salt XHTML often combines both attributes, so retain the
      // public block key while recovering the paragraphTitle semantic from
      // the source class list as a compatibility fallback.
      if (!isSectionTitle &&
          titleIndex < titles.length &&
          text == titles[titleIndex]) {
        isSectionTitle = true;
        titleIndex++;
      }
      paragraphs.add(
        SaltTextParagraph(
          text: text,
          index: paragraphs.length,
          kind: isSectionTitle
              ? SaltTextParagraphKind.sectionTitle
              : SaltTextParagraphKind.body,
          blockKey: node.blockKey,
        ),
      );
    }
    return List.unmodifiable(paragraphs);
  }

  static List<SaltTextSection> _shortSections(
    List<SaltTextParagraph> paragraphs,
  ) {
    final sections = paragraphs
        .where(
          (paragraph) =>
              paragraph.isSectionTitle && _isShortSectionTitle(paragraph.text),
        )
        .map(
          (paragraph) => SaltTextSection(
            title: paragraph.text,
            paragraphIndex: paragraph.index,
          ),
        )
        .toList(growable: false);
    // A lone numeric paragraph is more likely to be ordinary content than a
    // usable directory.  The catalog button must stay disabled in that case.
    return sections.length > 1 ? List.unmodifiable(sections) : const [];
  }

  static bool _isShortSectionTitle(String value) {
    final normalized = value.trim().replaceAll('０', '0');
    final ascii = normalized.replaceAllMapped(
      RegExp('[１２３４５６７８９]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xfee0),
    );
    return RegExp(r'^\d{1,3}$').hasMatch(ascii);
  }

  static List<String> _sectionTitleTexts(String xhtml) {
    try {
      final fragment = html_parser.parseFragment(xhtml);
      return List.unmodifiable(
        fragment
            .querySelectorAll('.paragraphTitle')
            .map((element) => _elementText(element))
            .where((value) => value.isNotEmpty),
      );
    } on Object {
      return const <String>[];
    }
  }

  static String _elementText(dom.Element element) =>
      element.text.replaceAll(RegExp(r'[ \t\r\n]+'), ' ').trim();

  /// Rebuilds only the generic document context after the asynchronous
  /// catalog request completes.  The decoded XHTML and compatibility fields
  /// stay unchanged, so the visible reader does not lose its cached content
  /// or reset its scroll position.
  SaltTextChapter withReaderContext({
    required ReaderBookInfo book,
    ReaderCatalog? catalog,
    String? title,
    int? index,
  }) => SaltTextChapter.fromXhtml(
    chapterId: chapterId,
    xhtml: xhtml,
    book: book,
    catalog: catalog,
    title: title ?? document.chapter.title,
    index: index ?? document.chapter.index,
  );

  static ReaderChapterOutline? _outlineFor(
    ReaderCatalog? catalog,
    String chapterId,
  ) {
    if (catalog == null) return null;
    for (final chapter in catalog.chapters) {
      if (chapter.id == chapterId) return chapter;
    }
    return null;
  }

  static String? _nonEmpty(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
