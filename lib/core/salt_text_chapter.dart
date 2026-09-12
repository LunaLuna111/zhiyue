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

class SaltTextChapter {
  const SaltTextChapter._({
    required this.chapterId,
    required this.contentId,
    required this.xhtml,
    required this.document,
    required this.textParagraphs,
    required this.paragraphs,
    required this.plainText,
  });

  final String chapterId;
  final String contentId;
  final String xhtml;
  final ReaderDocument document;
  final List<SaltTextParagraph> textParagraphs;
  final List<String> paragraphs;
  final String plainText;

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
    final textParagraphs = _saltParagraphs(document);
    if (textParagraphs.isEmpty) {
      throw const SaltTextChapterException('章节正文中没有可显示的文本段落。');
    }
    final paragraphs = textParagraphs
        .map((paragraph) => paragraph.text)
        .toList(growable: false);
    return SaltTextChapter._(
      chapterId: chapterId,
      contentId: '$chapterId-${xhtml.length}-${paragraphs.length}',
      xhtml: xhtml,
      document: document,
      textParagraphs: List.unmodifiable(textParagraphs),
      paragraphs: List.unmodifiable(paragraphs),
      plainText: paragraphs.join('\n\n'),
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
    return List.unmodifiable(_saltParagraphs(document));
  }

  static List<SaltTextParagraph> _saltParagraphs(ReaderDocument document) =>
      _saltParagraphsWithSequentialIndexes(document);

  static List<SaltTextParagraph> _saltParagraphsWithSequentialIndexes(
    ReaderDocument document,
  ) {
    final paragraphs = <SaltTextParagraph>[];
    for (final node in document.textNodes) {
      final text = node.text.trim();
      if (text.isEmpty) continue;
      paragraphs.add(
        SaltTextParagraph(
          text: text,
          index: paragraphs.length,
          kind:
              node.kind == ReaderNodeKind.heading ||
                  node.blockKey == 'paragraphTitle'
              ? SaltTextParagraphKind.sectionTitle
              : SaltTextParagraphKind.body,
          blockKey: node.blockKey,
        ),
      );
    }
    return List.unmodifiable(paragraphs);
  }

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
