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

class _SaltReaderPageState extends State<SaltReaderPage>
    with WidgetsBindingObserver {
  static const _useOfficialWebReader = bool.fromEnvironment(
    'ZH_USE_OFFICIAL_WEB_READER',
  );
  static const _readerPreferencesKey = 'zhiyue.salt.reader.preferences.v1';

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
  Future<void> _readerPreferencesWrite = Future<void>.value();
  int _readerJumpRequest = 0;
  int? _readerJumpParagraphIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _readerSettings = widget.layoutSettings;
    _readerFlow = widget.readerFlow;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyReaderSystemUi();
    });
    unawaited(_loadBookshelfState());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_loadReaderPreferences());
      unawaited(_read());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _applyReaderSystemUi();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _applyReaderSystemUi() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  }

  Widget _readerSystemUi(Widget child) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
      ),
      child: child,
    );
  }

  Future<void> _loadReaderPreferences() async {
    try {
      final raw = await ZhPlatformCache.instance.read(_readerPreferencesKey);
      if (!mounted || raw == null || raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final encodedSettings = decoded['settings'];
      if (encodedSettings is! Map) return;
      final values = <String, Object?>{
        for (final entry in encodedSettings.entries)
          entry.key.toString(): entry.value,
      };
      final persistedFlow = SaltReaderFlow.values
          .where((value) => value.name == decoded['flow'])
          .firstOrNull;
      final settings = ReaderSettingsCodec.decode(values);
      _updateState(() {
        _readerSettings = settings;
        if (persistedFlow != null) _readerFlow = persistedFlow;
      });
    } catch (_) {
      // Malformed optional preferences must not prevent a chapter from loading.
    }
  }

  void _scheduleReaderPreferencesPersistence() {
    final payload = jsonEncode({
      'version': 1,
      'settings': ReaderSettingsCodec.encode(_readerSettings),
      'flow': _readerFlow.name,
    });
    _readerPreferencesWrite = _readerPreferencesWrite.then((_) async {
      try {
        await ZhPlatformCache.instance.write(_readerPreferencesKey, payload);
      } catch (_) {
        // Reader preferences are best-effort and must not affect reading.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    if (_useOfficialWebReader) {
      final response = _state;
      final manuscript = response is ApiResponse && response.isSuccess
          ? SaltManuscriptEnvelope.fromJson(response.json)
          : null;
      final title = manuscript?.title.isNotEmpty == true
          ? manuscript!.title
          : manuscript?.parentTitle.isNotEmpty == true
          ? manuscript!.parentTitle
          : l10n.saltReadingTitle;
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
        : l10n.saltReadingTitle;
    final textChapter = _textChapter;
    final shortSections =
        textChapter?.shortSections ?? const <SaltTextSection>[];
    final hasCatalog =
        manuscript != null &&
        (manuscript.isLong == true ||
            (_effectiveSectionCount(manuscript) ?? 0) > 1 ||
            shortSections.length > 1);
    final commentMetadata = manuscript == null
        ? _workDetails
        : _commentTarget(manuscript) != null
        ? manuscript
        : _workDetails;
    if (textChapter != null && manuscript != null) {
      return _readerSystemUi(
        Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: _textReader(
            context,
            manuscript,
            textChapter,
            title: readerTitle,
            hasCatalog: hasCatalog,
            commentMetadata: commentMetadata,
          ),
        ),
      );
    }
    return _readerSystemUi(
      Scaffold(
        appBar: ZhTopBar(
          title: Text(
            readerTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            ZhLiquidGlassIconButton(
              onPressed: () => _showReaderMoreMenu(manuscript, textChapter),
              semanticLabel: l10n.saltMore,
              icon: const Icon(Icons.more_vert_rounded),
              size: 44,
              iconSize: 22,
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
      ),
    );
  }

  void _updateState(VoidCallback callback) => setState(callback);

  void _readerScrollDirectionChanged(bool showControls) {
    if (!mounted || _controlsVisible == showControls) return;
    _updateState(() => _controlsVisible = showControls);
  }

  void _jumpToShortSection(int paragraphIndex) {
    if (!mounted) return;
    _updateState(() {
      _readerJumpParagraphIndex = paragraphIndex;
      _readerJumpRequest++;
      _controlsVisible = false;
    });
  }
}
