import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chapter_export_platform.dart'
    if (dart.library.io) 'chapter_export_platform_io.dart'
    if (dart.library.js_interop) 'chapter_export_platform_web.dart';
import 'json_tools.dart';
import 'salt_chapter_export.dart';

enum ContentExportFormat { markdown, html, pdf }

extension ContentExportFormatLabel on ContentExportFormat {
  String get label => switch (this) {
    ContentExportFormat.markdown => 'Markdown',
    ContentExportFormat.html => 'HTML',
    ContentExportFormat.pdf => 'PDF',
  };
}

/// One export path shared by answer/article details and Salt reader chapters.
/// Markdown and HTML retain paragraph boundaries; PDF is rendered natively on
/// Android so Chinese glyphs use the device's system font.
class ContentExportService {
  ContentExportService._();

  static const _pdfChannel = MethodChannel(
    'com.zhiyue.client/document_export',
  );

  static Future<String> saveObject({
    required Map<String, dynamic> object,
    required ContentExportFormat format,
    String fallbackTitle = '内容详情',
  }) {
    final title = titleOf(object).trim().isEmpty
        ? fallbackTitle
        : titleOf(object).trim();
    final author = authorNameOf(object).trim();
    final body = _bodyParagraphs(object);
    final images = contentImageUrlsOf(object, limit: 24);
    if (format == ContentExportFormat.html) {
      return _saveHtmlObject(
        title: title,
        author: author,
        body: body,
        images: images,
      );
    }
    final sections = <SaltChapterExportSection>[
      SaltChapterExportSection(
        title: author.isEmpty ? '' : '作者：$author',
        paragraphs: [
          ...body,
          if (images.isNotEmpty) ...[
            if (format == ContentExportFormat.markdown)
              ...images.map((url) => '![正文图片]($url)')
            else
              ...images.map((_) => '[正文图片]'),
          ],
        ],
      ),
    ];
    return saveSections(title: title, sections: sections, format: format);
  }

  static Future<String> _saveHtmlObject({
    required String title,
    required String author,
    required List<String> body,
    required List<String> images,
  }) {
    final buffer = StringBuffer(
      '<!doctype html><html lang="zh-CN"><head><meta charset="utf-8">'
      '<meta name="viewport" content="width=device-width,initial-scale=1">'
      '<title>${_htmlEscape(title)}</title><style>'
      'body{font-family:-apple-system,BlinkMacSystemFont,"Noto Sans CJK SC",sans-serif;'
      'line-height:1.75;max-width:800px;margin:0 auto;padding:24px;color:#202124}'
      'img{display:block;max-width:100%;height:auto;margin:16px 0;border-radius:8px}'
      '</style></head><body><main><h1>${_htmlEscape(title)}</h1>',
    );
    if (author.isNotEmpty) buffer.write('<p>作者：${_htmlEscape(author)}</p>');
    for (final paragraph in body) {
      final text = paragraph.trim();
      if (text.isNotEmpty) buffer.write('<p>${_htmlEscape(text)}</p>');
    }
    for (final url in images) {
      buffer.write('<img src="${_htmlEscape(url)}" alt="正文图片" loading="lazy">');
    }
    buffer.write('</main></body></html>');
    final safeTitle = _safeFileName(title);
    return saveChapterExportPlatform(
      fileName: '${safeTitle}_export.html',
      mimeType: 'text/html',
      bytes: Uint8List.fromList(utf8.encode(buffer.toString())),
    );
  }

  static Future<String> saveSections({
    required String title,
    required List<SaltChapterExportSection> sections,
    required ContentExportFormat format,
    String sectionId = 'export',
  }) async {
    final normalizedTitle = title.trim().isEmpty ? '知阅内容' : title.trim();
    if (format != ContentExportFormat.pdf) {
      final file = buildSaltChapterExport(
        title: normalizedTitle,
        sectionId: sectionId,
        sections: sections,
        format: format == ContentExportFormat.markdown
            ? SaltChapterExportFormat.markdown
            : SaltChapterExportFormat.html,
      );
      return const SaltChapterFileSaver().save(file);
    }
    final plain = _plainSections(sections);
    final fileName =
        '${_safeFileName(normalizedTitle)}_${_safeFileName(sectionId)}.pdf';
    if (defaultTargetPlatform == TargetPlatform.android) {
      final result = await _pdfChannel.invokeMapMethod<String, dynamic>(
        'savePdf',
        {'name': fileName, 'title': normalizedTitle, 'content': plain},
      );
      final location = result?['location']?.toString().trim();
      return location == null || location.isEmpty
          ? '下载/知阅/$fileName'
          : location;
    }
    // Keep desktop/Web usable without a platform PDF renderer. This minimal
    // single-font PDF is valid and still provides the exported plain text.
    return saveChapterExportPlatform(
      fileName: fileName,
      mimeType: 'application/pdf',
      bytes: Uint8List.fromList(utf8.encode(_minimalPdf(plain))),
    );
  }

  static List<String> _bodyParagraphs(Map<String, dynamic> object) {
    final structured = structuredContentText(object).trim();
    if (structured.isNotEmpty) return _splitParagraphs(structured);
    final html = htmlContent(object);
    if (html != null && html.trim().isNotEmpty) {
      final blocks = richContentBlocks(html);
      final paragraphs = <String>[];
      for (final block in blocks) {
        if (block.isImage) {
          paragraphs.add('[正文图片]');
        } else if (block.isVideo) {
          paragraphs.add('[视频]');
        } else if (block.text.trim().isNotEmpty) {
          paragraphs.add(block.text.trim());
        }
      }
      if (paragraphs.isNotEmpty) return paragraphs;
      return _splitParagraphs(plainText(html));
    }
    final fallback = plainText(object['excerpt'] ?? object['summary'] ?? '');
    return fallback.isEmpty ? const [] : _splitParagraphs(fallback);
  }

  static List<String> _splitParagraphs(String value) => value
      .split(RegExp(r'\n\s*\n'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);

  static String _plainSections(List<SaltChapterExportSection> sections) =>
      sections
          .expand(
            (section) => [
              if (section.title.trim().isNotEmpty) section.title.trim(),
              ...section.paragraphs,
            ],
          )
          .join('\n\n');

  static String _safeFileName(String value) {
    final normalized = value
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) return '知阅内容';
    return normalized.length > 80 ? normalized.substring(0, 80) : normalized;
  }

  static String _htmlEscape(String value) => const HtmlEscape(
    HtmlEscapeMode.element,
  ).convert(value.replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f]'), ''));

  static String _minimalPdf(String text) {
    final safe = text
        .replaceAll('\\', '\\\\')
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)')
        .replaceAll(RegExp(r'\r?\n'), r'\\n');
    final stream = 'BT /F1 11 Tf 40 780 Td ($safe) Tj ET';
    final objects = [
      '<< /Type /Catalog /Pages 2 0 R >>',
      '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
      '<< /Length ${stream.length} >>\nstream\n$stream\nendstream',
    ];
    final output = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[0];
    for (var index = 0; index < objects.length; index++) {
      offsets.add(output.length);
      output.write('${index + 1} 0 obj\n${objects[index]}\nendobj\n');
    }
    final xref = output.length;
    output.write('xref\n0 ${objects.length + 1}\n0000000000 65535 f \n');
    for (final offset in offsets.skip(1)) {
      output.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }
    output.write(
      'trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n'
      'startxref\n$xref\n%%EOF\n',
    );
    return output.toString();
  }
}
