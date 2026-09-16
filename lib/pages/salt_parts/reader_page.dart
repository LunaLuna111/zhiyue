part of '../salt_page.dart';

enum SaltReaderContract { automatic, shortContent, longManuCore }

enum _SaltReaderMoreAction { refresh, exportTxt, exportDocx }

enum _SaltReaderChapterMoreAction {
  refresh,
  readAloud,
  exportMarkdown,
  exportHtml,
  exportPdf,
  exportTxt,
  exportDocx,
}

class SaltReaderPage extends StatefulWidget {
  const SaltReaderPage({
    super.key,
    required this.api,
    required this.businessId,
    required this.sectionId,
    this.keyProvider,
    this.contract = SaltReaderContract.automatic,
    this.layoutSettings = const SaltReaderSettings(),
    this.readerFlow = SaltReaderFlow.vertical,
  });

  final ZhihuApiClient api;
  final String businessId;
  final String sectionId;
  final SaltManuscriptKeyProvider? keyProvider;
  final SaltReaderContract contract;
  final SaltReaderSettings layoutSettings;
  final SaltReaderFlow readerFlow;

  @override
  State<SaltReaderPage> createState() => _SaltReaderPageState();
}

class _SaltReaderPageState extends State<SaltReaderPage> {
  static const _useOfficialWebReader = bool.fromEnvironment(
    'ZH_USE_OFFICIAL_WEB_READER',
  );

  Object? _state;
  String? _decodedContent;
  String? _decodeError;
  SaltTextChapter? _textChapter;
  bool _loading = false;
  Map<int, SaltParagraphAnnotation> _paragraphAnnotations = const {};
  Object? _annotationsError;
  bool _annotationsLoading = false;
  SaltManuscriptEnvelope? _workDetails;
  SaltCatalogNavigation? _catalogNavigation;
  Object? _catalogError;
  bool _catalogLoading = false;
  late SaltReaderSettings _readerSettings;
  late SaltReaderFlow _readerFlow;
  bool _controlsVisible = false;
  final _bookshelf = SaltBookshelfStore.instance;
  bool _bookshelfSaving = false;
  bool _addedToBookshelf = false;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _readerSettings = widget.layoutSettings;
    _readerFlow = widget.readerFlow;
    unawaited(_loadBookshelfState());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _read();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_useOfficialWebReader) {
      final response = _state;
      final manuscript = response is ApiResponse && response.isSuccess
          ? SaltManuscriptEnvelope.fromJson(response.json)
          : null;
      final title = manuscript?.title.isNotEmpty == true
          ? manuscript!.title
          : manuscript?.parentTitle.isNotEmpty == true
          ? manuscript!.parentTitle
          : '盐选阅读';
      final previousId = manuscript?.previousSectionId ?? '';
      final nextId = manuscript?.nextSectionId ?? '';
      return OfficialWebPage(
        key: ValueKey('salt-web-${widget.businessId}-${widget.sectionId}'),
        title: title,
        url: officialSaltSectionUrl(
          businessId: widget.businessId,
          sectionId: widget.sectionId,
        ),
        cookieHeader: widget.api.session.cookie,
        requiresSessionCookie: true,
        previousUrl: previousId.isEmpty
            ? null
            : officialSaltSectionUrl(
                businessId: widget.businessId,
                sectionId: previousId,
              ),
        nextUrl: nextId.isEmpty
            ? null
            : officialSaltSectionUrl(
                businessId: widget.businessId,
                sectionId: nextId,
              ),
        onChapterNavigation: (url) {
          final navigation = parseSaltStoryNavigation({'url': url});
          final sectionId = navigation?.sectionId;
          if (sectionId != null) _openSection(sectionId);
        },
      );
    }
    final response = _state;
    final manuscript = response is ApiResponse && response.isSuccess
        ? SaltManuscriptEnvelope.fromJson(response.json)
        : null;
    final readerTitle = manuscript?.parentTitle.isNotEmpty == true
        ? manuscript!.parentTitle
        : manuscript?.title.isNotEmpty == true
        ? manuscript!.title
        : '盐选阅读';
    final textChapter = _textChapter;
    final hasCatalog =
        manuscript != null &&
        (manuscript.isLong == true ||
            (_effectiveSectionCount(manuscript) ?? 0) > 1);
    final commentMetadata = manuscript == null
        ? _workDetails
        : _commentTarget(manuscript) != null
        ? manuscript
        : _workDetails;
    if (textChapter != null && manuscript != null) {
      return Scaffold(
        body: _textReader(
          context,
          manuscript,
          textChapter,
          title: readerTitle,
          hasCatalog: hasCatalog,
          commentMetadata: commentMetadata,
        ),
      );
    }
    return Scaffold(
      appBar: ZhTopBar(
        title: Text(readerTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () => _showReaderMoreMenu(manuscript, textChapter),
            tooltip: '更多',
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: _loading
          ? _readerLoading(context)
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                ZhSpace.md,
                ZhSpace.sm,
                ZhSpace.md,
                ZhSpace.xl,
              ),
              children: [_result(context)],
            ),
    );
  }

  void _updateState(VoidCallback callback) => setState(callback);

  void _readerScrollDirectionChanged(bool showControls) {
    if (!mounted || _controlsVisible == showControls) return;
    _updateState(() => _controlsVisible = showControls);
  }
}
