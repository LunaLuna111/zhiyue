part of '../salt_page.dart';

Future<String?> showSaltLongExportSheet({
  required BuildContext context,
  required ZhihuApiClient api,
  required String businessId,
  required String workTitle,
  required SaltChapterExportFormat format,
  String? currentSectionId,
  SaltManuscriptKeyProvider? keyProvider,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: false,
  backgroundColor: Colors.transparent,
  builder: (_) => FractionallySizedBox(
    heightFactor: 0.92,
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: _SaltCatalogSheet(
        api: api,
        businessId: businessId,
        currentSectionId: currentSectionId,
        currentSectionIndex: null,
        sectionCount: null,
        title: workTitle,
        exportFormat: format,
        keyProvider: keyProvider,
      ),
    ),
  ),
);

Future<SaltCachedChapter> _downloadSaltChapterForCache({
  required ZhihuApiClient api,
  required String businessId,
  required String sectionId,
  required String title,
  required int sectionIndex,
  required int windowWidth,
  SaltManuscriptKeyProvider? keyProvider,
}) async {
  final provider = keyProvider ?? defaultSaltManuscriptKeyProvider();
  var key = await provider.generate();
  var response = await api.postSaltJsonUri(
    api.saltContentUri(
      businessId: businessId,
      sectionId: sectionId,
      windowWidth: windowWidth,
    ),
    jsonBody: {'trans_key': key.transKey, 'window_width': windowWidth},
  );
  if (!response.isSuccess) throw response;

  var manuscript = SaltManuscriptEnvelope.fromJson(response.json);
  var code = SaltArticleCodeEnvelope.fromJson(_saltCode(response.json));
  final hasBoundContent =
      manuscript.hasScript &&
      (code.articleCode.isNotEmpty || manuscript.articleCode.isNotEmpty);
  if (!hasBoundContent) {
    key = await provider.generate();
    final codeResponse = await api.postSaltJsonUri(
      api.saltArticleCodeUri(),
      jsonBody: {'section_id': sectionId, 'trans_key': key.transKey},
    );
    if (!codeResponse.isSuccess) throw codeResponse;
    code = SaltArticleCodeEnvelope.fromJson(codeResponse.json);
    response = await api.getSaltUri(
      api.saltManuCoreUri(
        businessId: businessId,
        sectionId: sectionId,
        windowWidth: windowWidth,
      ),
    );
    if (!response.isSuccess) throw response;
    manuscript = SaltManuscriptEnvelope.fromJson(response.json);
  }

  final articleCode = code.articleCode.isNotEmpty
      ? code.articleCode
      : manuscript.articleCode;
  final strategy = code.log.isNotEmpty ? code.log : manuscript.strategy;
  final rawKey = code.random.isNotEmpty ? code.random : key.rawKey;
  SaltTextChapter chapter;
  if (manuscript.directHtml case final xhtml?) {
    chapter = SaltTextChapter.fromXhtml(chapterId: sectionId, xhtml: xhtml);
  } else {
    if (!manuscript.hasScript || articleCode.isEmpty || rawKey.isEmpty) {
      throw const SaltTextChapterException('章节响应缺少完整解码参数。');
    }
    chapter = await compute(_decodeSaltTextChapter, {
      'chapterId': sectionId,
      'script': manuscript.script!,
      'articleCode': articleCode,
      'strategy': strategy,
      'rawKey': rawKey,
    });
  }
  return SaltChapterCache.instance.write(
    businessId: businessId,
    sectionId: sectionId,
    title: manuscript.title.isEmpty ? title : manuscript.title,
    sectionIndex: sectionIndex >= 0 && sectionIndex < (1 << 30)
        ? sectionIndex
        : manuscript.sectionIndex,
    responseJson: response.json,
    xhtml: chapter.xhtml,
  );
}
