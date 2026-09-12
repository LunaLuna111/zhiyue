import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'chapter_export_platform.dart'
    if (dart.library.io) 'chapter_export_platform_io.dart'
    if (dart.library.js_interop) 'chapter_export_platform_web.dart';

enum SaltChapterExportFormat { txt, docx, markdown, html }

class SaltChapterExportFile {
  const SaltChapterExportFile({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;
}

class SaltChapterExportSection {
  const SaltChapterExportSection({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;
}

SaltChapterExportFile buildSaltChapterExport({
  required String title,
  required String sectionId,
  required List<SaltChapterExportSection> sections,
  required SaltChapterExportFormat format,
}) {
  final normalizedTitle = title.trim().isEmpty ? '盐选章节' : title.trim();
  final safeTitle = _safeExportFileName(normalizedTitle);
  final safeSection = RegExp(r'^\d+$').hasMatch(sectionId.trim())
      ? sectionId.trim()
      : 'chapter';
  switch (format) {
    case SaltChapterExportFormat.txt:
      final buffer = StringBuffer('$normalizedTitle\n');
      for (final section in sections) {
        if (section.title.trim().isNotEmpty &&
            section.title != normalizedTitle) {
          buffer.write('\n${section.title.trim()}\n');
        }
        if (section.paragraphs.isNotEmpty) {
          buffer.write('\n${section.paragraphs.join('\n\n')}\n');
        }
      }
      return SaltChapterExportFile(
        fileName: '${safeTitle}_$safeSection.txt',
        mimeType: 'text/plain',
        bytes: Uint8List.fromList(utf8.encode(buffer.toString())),
      );
    case SaltChapterExportFormat.docx:
      return SaltChapterExportFile(
        fileName: '${safeTitle}_$safeSection.docx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        bytes: Uint8List.fromList(_docxBytes(normalizedTitle, sections)),
      );
    case SaltChapterExportFormat.markdown:
      final buffer = StringBuffer('# $normalizedTitle\n');
      for (final section in sections) {
        final sectionTitle = section.title.trim();
        if (sectionTitle.isNotEmpty && sectionTitle != normalizedTitle) {
          buffer.write('\n## ${_markdownText(sectionTitle)}\n');
        }
        for (final paragraph in section.paragraphs) {
          final text = paragraph.trim();
          if (text.isNotEmpty) buffer.write('\n${_markdownText(text)}\n');
        }
      }
      return SaltChapterExportFile(
        fileName: '${safeTitle}_$safeSection.md',
        mimeType: 'text/markdown',
        bytes: Uint8List.fromList(utf8.encode(buffer.toString())),
      );
    case SaltChapterExportFormat.html:
      final buffer = StringBuffer(
        '<!doctype html><html lang="zh-CN"><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        '<title>${_htmlText(normalizedTitle)}</title></head><body>'
        '<main><h1>${_htmlText(normalizedTitle)}</h1>',
      );
      for (final section in sections) {
        final sectionTitle = section.title.trim();
        if (sectionTitle.isNotEmpty && sectionTitle != normalizedTitle) {
          buffer.write('<h2>${_htmlText(sectionTitle)}</h2>');
        }
        for (final paragraph in section.paragraphs) {
          final text = paragraph.trim();
          if (text.isNotEmpty) buffer.write('<p>${_htmlText(text)}</p>');
        }
      }
      buffer.write('</main></body></html>');
      return SaltChapterExportFile(
        fileName: '${safeTitle}_$safeSection.html',
        mimeType: 'text/html',
        bytes: Uint8List.fromList(utf8.encode(buffer.toString())),
      );
  }
}

class SaltChapterFileSaver {
  const SaltChapterFileSaver();

  static const _maximumBytes = 32 * 1024 * 1024;
  static const _mimeTypes = <String, String>{
    'txt': 'text/plain',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'md': 'text/markdown',
    'html': 'text/html',
  };

  Future<String> save(SaltChapterExportFile file) async {
    _validate(file);
    return saveChapterExportPlatform(
      fileName: file.fileName,
      mimeType: file.mimeType,
      bytes: file.bytes,
    );
  }

  static void _validate(SaltChapterExportFile file) {
    final name = file.fileName;
    if (name.isEmpty ||
        name != name.trim() ||
        name.length > 120 ||
        RegExp(r'[\\/:*?"<>|\x00-\x1f]').hasMatch(name)) {
      throw const FormatException('导出文件名无效');
    }
    final separator = name.lastIndexOf('.');
    final extension = separator < 0
        ? ''
        : name.substring(separator + 1).toLowerCase();
    if (_mimeTypes[extension] != file.mimeType) {
      throw const FormatException('导出文件类型无效');
    }
    if (file.bytes.isEmpty || file.bytes.length > _maximumBytes) {
      throw ArgumentError.value(file.bytes.length, 'bytes', '导出文件大小无效');
    }
  }
}

String _safeExportFileName(String value) {
  final normalized = value
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (normalized.isEmpty) return '盐选章节';
  return normalized.length <= 80 ? normalized : normalized.substring(0, 80);
}

String _markdownText(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll(RegExp(r'^([#>*+-])'), r'\\$1')
    .replaceAll(RegExp(r'\r?\n'), '\n');

String _htmlText(String value) => const HtmlEscape(
  HtmlEscapeMode.element,
).convert(value.replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f]'), ''));

List<int> _docxBytes(String title, List<SaltChapterExportSection> sections) {
  final archive = Archive()
    ..add(
      ArchiveFile.string(
        '[Content_Types].xml',
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            '<Default Extension="xml" ContentType="application/xml"/>'
            '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
            '</Types>',
      ),
    )
    ..add(
      ArchiveFile.string(
        '_rels/.rels',
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
            '</Relationships>',
      ),
    )
    ..add(
      ArchiveFile.string('word/document.xml', _documentXml(title, sections)),
    );
  return ZipEncoder().encode(archive);
}

String _documentXml(String title, List<SaltChapterExportSection> sections) {
  final buffer = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
    '<w:body>',
  );
  buffer.write(
    '<w:p><w:pPr><w:spacing w:after="280"/></w:pPr>'
    '<w:r><w:rPr><w:rFonts w:eastAsia="宋体"/><w:b/><w:sz w:val="32"/></w:rPr>'
    '<w:t xml:space="preserve">${_xmlText(title)}</w:t></w:r></w:p>',
  );
  for (final section in sections) {
    if (section.title.trim().isNotEmpty && section.title != title) {
      buffer.write(
        '<w:p><w:pPr><w:spacing w:before="240" w:after="180"/></w:pPr>'
        '<w:r><w:rPr><w:rFonts w:eastAsia="宋体"/><w:b/><w:sz w:val="28"/></w:rPr>'
        '<w:t xml:space="preserve">${_xmlText(section.title.trim())}</w:t></w:r></w:p>',
      );
    }
    for (final paragraph in section.paragraphs) {
      buffer.write(
        '<w:p><w:pPr><w:spacing w:after="180" w:line="420" w:lineRule="auto"/></w:pPr>'
        '<w:r><w:rPr><w:rFonts w:eastAsia="宋体"/><w:sz w:val="24"/></w:rPr>'
        '<w:t xml:space="preserve">${_xmlText(paragraph)}</w:t></w:r></w:p>',
      );
    }
  }
  buffer.write(
    '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/>'
    '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr>'
    '</w:body></w:document>',
  );
  return buffer.toString();
}

String _xmlText(String value) => const HtmlEscape(
  HtmlEscapeMode.element,
).convert(value.replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f]'), ''));
