import 'package:universal_reader/universal_reader.dart';
import 'package:zhihu_api/zhihu_api_salt.dart';

/// Converts the Zhihu/Salt response models into the generic reader input.
///
/// This is deliberately kept in the client.  The reusable reader package only
/// knows about books, catalogs, chapters, and content formats; it does not
/// know about Salt endpoints or their response fields.
ReaderBookInfo saltReaderBookInfo({
  required String businessId,
  required SaltManuscriptEnvelope manuscript,
}) {
  final title = _firstNonEmpty([
    manuscript.parentTitle,
    manuscript.title,
    businessId,
  ]);
  final coverUrl = _firstNonEmpty([
    manuscript.parentArtwork,
    manuscript.artwork,
  ]);
  final metadata = <String, Object?>{
    'work_id': manuscript.workId,
    'manuscript_id': manuscript.manuscriptId,
    'is_long': manuscript.isLong,
    'is_story': manuscript.isStory,
    'is_vip_resource': manuscript.isVipResource,
    'is_finished': manuscript.isFinished,
    'is_on_shelf': manuscript.isOnShelf,
    'property_type': manuscript.propertyType,
    'status_text': manuscript.statusText,
    'update_text': manuscript.updateText,
    'like_count': manuscript.likeCount,
    'comment_count': manuscript.commentCount,
    'view_count': manuscript.viewCount,
    'favorite_count': manuscript.favoriteCount,
    'has_tts': manuscript.hasTts,
    'author_headline': manuscript.authorHeadline,
    'author_bio': manuscript.authorBio,
  };
  return ReaderBookInfo(
    id: businessId,
    title: title,
    author: manuscript.authorName,
    description: manuscript.parentIntroduction,
    coverUrl: coverUrl,
    totalChapterCount:
        manuscript.sectionCount ?? manuscript.updatedSectionCount,
    tags: manuscript.labels,
    updatedAt: _dateFromEpoch(manuscript.createdAt),
    metadata: metadata,
  );
}

/// Converts the catalog window returned by the API into a generic catalog.
/// The catalog may be a window rather than the whole server-side directory;
/// callers can replace it with a later merged snapshot without changing the
/// reader API.
ReaderCatalog? saltReaderCatalog({
  required String bookId,
  required String currentChapterId,
  required SaltCatalogNavigation? navigation,
}) {
  if (navigation == null) return null;
  final chapters = navigation.sections
      .map(
        (section) => ReaderChapterOutline(
          id: section.id,
          title: section.title,
          index: section.index,
        ),
      )
      .toList(growable: false);
  return ReaderCatalog(
    bookId: bookId,
    chapters: chapters,
    currentChapterId: currentChapterId,
    metadata: {
      'total': navigation.total,
      'current_index': navigation.currentIndex,
    },
  );
}

String _firstNonEmpty(Iterable<String> values) {
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isNotEmpty) return normalized;
  }
  return '';
}

DateTime? _dateFromEpoch(int? value) {
  if (value == null || value <= 0) return null;
  final milliseconds = value < 100000000000 ? value * 1000 : value;
  return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
}
