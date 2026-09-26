import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/api_client.dart';
import 'core/api_contract.dart';
import 'core/account_session_store.dart';
import 'core/app_log.dart';
import 'core/json_tools.dart';
import 'core/session_store.dart';
import 'core/webdav_sync_service.dart';
import 'pages/account_page.dart';
import 'pages/account_sessions_page.dart';
import 'pages/app_update_page.dart';
import 'pages/browsing_history_page.dart';
import 'pages/discover_page.dart';
import 'pages/feed_page.dart';
import 'pages/my_page.dart';
import 'pages/notifications_page.dart';
import 'pages/paged_list_page.dart';
import 'pages/salt_page.dart';
import 'pages/search_page.dart';
import 'pages/content_pages.dart';
import 'pages/user_page.dart';
import 'ui/zh_scroll_behavior.dart';
import 'ui/zh_components.dart';
import 'ui/zh_glass.dart';
import 'ui/zh_theme.dart';
import 'l10n/zh_localization.dart';
import 'widgets/app_drawer.dart';
import 'widgets/account_session_cleanup_prompt.dart';
import 'widgets/desktop_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The app loads its private SQLite-backed session before the first frame.
  // Register federated Dart plugins explicitly so sqflite and the other
  // platform stores are ready on every Android/iOS entry path.
  DartPluginRegistrant.ensureInitialized();
  await LiquidGlassWidgets.initialize(enablePerformanceMonitor: false);
  final session = SessionStore();
  // Initialize diagnostics before loading the credential database so a
  // migration/read failure is persisted instead of being recorded only in a
  // pre-initialization in-memory buffer.
  await AppLogStore.instance.initialize(session: session);
  await session.load();
  final accountSessions = AccountSessionStore.instance;
  await accountSessions.load();
  // Reconcile the active slot only after both private stores loaded
  // successfully. A failed read therefore cannot be mistaken for logout or
  // overwrite the durable account list.
  await accountSessions.syncCurrentSession(session);
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      AppLogStore.instance.recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        message: 'Flutter 未处理异常',
      ),
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      AppLogStore.instance.recordError(error, stack, message: '平台未处理异常'),
    );
    return false;
  };
  final contract = await ApiContract.load();
  final drawerController = ZhPushDrawerController();
  runApp(
    ZhiyueApp(
      session: session,
      contract: contract,
      drawerController: drawerController,
    ),
  );
}

class ZhiyueApp extends StatefulWidget {
  const ZhiyueApp({
    super.key,
    required this.session,
    required this.contract,
    required this.drawerController,
  });

  final SessionStore session;
  final ApiContract contract;
  final ZhPushDrawerController drawerController;

  @override
  State<ZhiyueApp> createState() => _ZhiyueAppState();
}

class _ZhiyueAppState extends State<ZhiyueApp> {
  late final ZhihuApiClient _api = ZhihuApiClient(widget.session);
  late int _presentationFingerprint;

  int get _currentPresentationFingerprint => Object.hash(
    widget.session.readingTextSize,
    widget.session.locale,
    widget.session.darkModeEnabled,
    widget.session.followSystemTextScale,
    widget.session.reduceMotion,
    widget.session.glassEffectsEnabled,
  );

  void _applyImageCachePolicy() {
    final cache = PaintingBinding.instance.imageCache;
    final preset = widget.session.imageCachePreset;
    cache.maximumSize = preset.maximumEntries;
    cache.maximumSizeBytes = preset.maximumBytes;
  }

  void _sessionChanged() {
    _applyImageCachePolicy();
    final nextPresentationFingerprint = _currentPresentationFingerprint;
    if (nextPresentationFingerprint == _presentationFingerprint) return;
    _presentationFingerprint = nextPresentationFingerprint;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _presentationFingerprint = _currentPresentationFingerprint;
    _applyImageCachePolicy();
    widget.session.addListener(_sessionChanged);
  }

  @override
  void dispose() {
    widget.session.removeListener(_sessionChanged);
    _api.close();
    widget.drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.session.darkModeEnabled;
    ZhPalette.isDark = isDark;
    final app = ShadTheme(
      data: ZhTheme.shadFor(isDark ? Brightness.dark : Brightness.light),
      child: MaterialApp(
        onGenerateTitle: (context) => context.zhL10n.appTitle,
        debugShowCheckedModeBanner: false,
        locale: widget.session.locale.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ZhTheme.materialFor(Brightness.light),
        darkTheme: ZhTheme.materialFor(Brightness.dark),
        scrollBehavior: const ZhScrollBehavior(),
        builder: (context, child) {
          final media = MediaQuery.of(context);
          final systemScale = widget.session.followSystemTextScale
              ? media.textScaler.scale(1)
              : 1.0;
          final combinedScale = (systemScale * widget.session.textScaleFactor)
              .clamp(0.8, 1.5)
              .toDouble();
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(combinedScale),
              disableAnimations: widget.session.reduceMotion,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: AccountSessionCleanupPrompt(
          session: widget.session,
          child: AppUpdatePromptGate(
            child: HomeShell(
              api: _api,
              session: widget.session,
              contract: widget.contract,
              drawerController: widget.drawerController,
            ),
          ),
        ),
      ),
    );
    final scopedApp = ZhGlassScope(
      enabled: widget.session.glassEffectsEnabled,
      child: app,
    );
    final glassApp = widget.session.glassEffectsEnabled
        ? LiquidGlassWidgets.wrap(
            child: scopedApp,
            brightnessResolver: Theme.maybeBrightnessOf,
            // Keep the normal glass language, but let the library fall back
            // to its lightweight tier when raster frames exceed budget.
            adaptiveQuality: true,
            adaptiveConfig: const GlassAdaptiveScopeConfig(
              minQuality: GlassQuality.minimal,
              maxQuality: GlassQuality.standard,
              initialQuality: GlassQuality.standard,
              allowStepUp: false,
            ),
          )
        : scopedApp;
    return ZhMobileViewportSurface(
      drawerProgress: widget.drawerController.animationProgress,
      child: glassApp,
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.api,
    required this.session,
    required this.contract,
    required this.drawerController,
  });

  final ZhihuApiClient api;
  final SessionStore session;
  final ApiContract contract;
  final ZhPushDrawerController drawerController;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZhPushDrawerController get _drawerController => widget.drawerController;
  final _feedController = HomeFeedController();
  final _searchController = SearchPageController();
  final _accountStore = AccountSessionStore.instance;
  late final WebDavSyncService _webDav = WebDavSyncService(
    session: widget.session,
  );
  late int _index;
  late final List<Widget> _pages = [
    Builder(
      builder: (context) => FeedPage(
        api: widget.api,
        controller: _feedController,
        // The persistent desktop sidebar replaces the transient hamburger;
        // retain it for compact windows and mobile gesture navigation.
        onMenuPressed:
            ZhShellBreakpoints.isDesktop(MediaQuery.sizeOf(context).width)
            ? null
            : _drawerController.open,
      ),
    ),
    SearchPage(
      api: widget.api,
      controller: _searchController,
      onBack: () => _selectNavigation(0),
    ),
    SaltPage(api: widget.api),
    MyPage(
      api: widget.api,
      session: widget.session,
      onMenuPressed: _drawerController.open,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _index = startupNavigationIndex(widget.session.startupPage);
    _feedController.addListener(_feedSelectionChanged);
    widget.session.addListener(_sessionChanged);
    unawaited(_webDav.syncOnStartup());
  }

  @override
  void dispose() {
    _feedController.removeListener(_feedSelectionChanged);
    widget.session.removeListener(_sessionChanged);
    _feedController.dispose();
    _searchController.dispose();
    _webDav.dispose();
    super.dispose();
  }

  void _feedSelectionChanged() {
    if (mounted) setState(() {});
  }

  void _sessionChanged() {
    unawaited(_accountStore.syncCurrentSession(widget.session));
  }

  void _selectNavigation(int value) {
    if (value == 1) _searchController.activate();
    if (value == _index) {
      if (value == 0 && widget.session.refreshHomeOnReselect) {
        _feedController.returnToTopAndRefresh();
      }
      return;
    }
    setState(() => _index = value);
  }

  void _closeDrawer() {
    unawaited(_drawerController.close());
  }

  Future<void> _runAfterDrawerClosed(VoidCallback action) async {
    final closed = await _drawerController.close();
    if (closed && mounted) action();
  }

  void _openHistory() {
    unawaited(
      _runAfterDrawerClosed(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                BrowsingHistoryPage(api: widget.api, session: widget.session),
          ),
        );
      }),
    );
  }

  void _openBookshelf() {
    // Swapping the image-rich IndexedStack while its surface is still being
    // translated defeats the drawer's repaint boundary and makes the close
    // animation hitch.  Match the other drawer destinations by changing tabs
    // only after the transition has settled.
    unawaited(
      _runAfterDrawerClosed(() {
        if (_index != 2) setState(() => _index = 2);
      }),
    );
  }

  void _openDrawerPage(Widget Function() pageBuilder) {
    unawaited(
      _runAfterDrawerClosed(() {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => pageBuilder()));
      }),
    );
  }

  void _openSettings() {
    unawaited(
      _runAfterDrawerClosed(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AppSettingsPage(
              session: widget.session,
              api: widget.api,
              webDav: _webDav,
            ),
          ),
        );
      }),
    );
  }

  Future<void> _switchAccount(String id) async {
    final closed = await _drawerController.close();
    if (!closed || !mounted) return;
    final account = _accountStore.accounts
        .where((item) => item.id == id)
        .firstOrNull;
    var switched = false;
    try {
      switched = await _accountStore.activate(
        id,
        widget.session,
        verify: account == null ? null : () => _verifyAccount(account),
      );
    } on Object catch (error, stackTrace) {
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '侧边栏账号切换失败',
          category: AppLogCategory.authentication,
        ),
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            switched
                ? context.zhL10n.accountSwitchedTo(
                    account == null
                        ? context.zhL10n.drawerAccount
                        : localizedAccountDisplayName(context.zhL10n, account),
                  )
                : context.zhL10n.accountSessionRestoreFailed,
          ),
        ),
      );
  }

  Future<bool> _verifyAccount(StoredAccountSession account) async {
    final response = await widget.api.getUri(widget.api.accountSelfProfileUri());
    if (!response.isSuccess) return false;
    if (response.jsonMap == null) return false;
    final profile = unwrapObject(response.jsonMap!);
    final profileId = profile['id']?.toString().trim() ?? '';
    final profileUid = profile['uid']?.toString().trim() ?? '';
    if (account.accountUid.isNotEmpty &&
        profileId.isNotEmpty &&
        account.accountUid != profileId) {
      return false;
    }
    if (account.accountUserId.isNotEmpty &&
        profileUid.isNotEmpty &&
        account.accountUserId != profileUid) {
      return false;
    }
    return true;
  }

  void _openAccountManager() {
    _openDrawerPage(
      () => AccountSessionsPage(api: widget.api, session: widget.session),
    );
  }

  void _openUserSearch() {
    unawaited(
      _runAfterDrawerClosed(() {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => UserPage(api: widget.api)));
      }),
    );
  }

  Future<String?> _currentMemberId() async {
    final saved = widget.session.accountUid.trim();
    if (saved.isNotEmpty) return saved;
    if (!widget.session.hasAuthorization) return null;
    final response = await widget.api.getUri(widget.api.accountSelfProfileUri());
    if (!response.isSuccess || response.jsonMap == null) return null;
    final profile = unwrapObject(response.jsonMap!);
    final id = plainText(profile['id']);
    return id.isEmpty ? null : id;
  }

  Future<void> _openCollections() async {
    final closed = await _drawerController.close();
    if (!closed || !mounted) return;
    final memberId = await _currentMemberId();
    if (!mounted) return;
    if (memberId == null) {
      setState(() => _index = 3);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.zhL10n.collectionsLoginRequired)),
      );
      return;
    }
    final l10n = context.zhL10n;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PagedListPage(
          title: l10n.collectionsTitle,
          api: widget.api,
          loadInitial: () => widget.api.getUri(
            widget.api.userCollectionsInitialUri(memberId),
          ),
          onObjectTap: (context, value) {
            final collectionId = idOf(value);
            if (collectionId.isEmpty) {
              openDetectedObject(context, widget.api, value);
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PagedListPage(
                  title: titleOf(value).isEmpty
                      ? l10n.collectionTitle
                      : titleOf(value),
                  api: widget.api,
                  loadInitial: () => widget.api.getUri(
                    widget.api.collectionContentsInitialUri(collectionId),
                  ),
                  onObjectTap: (context, item) =>
                      openDetectedObject(context, widget.api, item),
                  emptyMessage: l10n.collectionEmpty,
                ),
              ),
            );
          },
          emptyMessage: l10n.collectionsEmpty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawer = ZhAppDrawer(
      session: widget.session,
      accountStore: _accountStore,
      selectedNavigationIndex: _index,
      onColumns: () => _openDrawerPage(() => discoverColumnsPage(widget.api)),
      onTopicCategories: () =>
          _openDrawerPage(() => discoverTopicCategoriesPage(widget.api)),
      onHotTopics: () =>
          _openDrawerPage(() => discoverHotTopicsPage(widget.api)),
      onHistory: _openHistory,
      onNotifications: () =>
          _openDrawerPage(() => NotificationsPage(api: widget.api)),
      onCollections: _openCollections,
      onBookshelf: _openBookshelf,
      onUsers: _openUserSearch,
      onSettings: _openSettings,
      onAccountSelected: _switchAccount,
      onManageAccounts: _openAccountManager,
      onClose: _closeDrawer,
    );
    final desktopSidebar = ZhDesktopSidebar(
      session: widget.session,
      selectedNavigationIndex: _index,
      onNavigationSelected: _selectNavigation,
      onColumns: () => _openDrawerPage(() => discoverColumnsPage(widget.api)),
      onTopicCategories: () =>
          _openDrawerPage(() => discoverTopicCategoriesPage(widget.api)),
      onHotTopics: () =>
          _openDrawerPage(() => discoverHotTopicsPage(widget.api)),
      onHistory: _openHistory,
      onNotifications: () =>
          _openDrawerPage(() => NotificationsPage(api: widget.api)),
      onCollections: _openCollections,
      onUsers: _openUserSearch,
      onSettings: _openSettings,
    );
    return ZhAdaptiveHomeShell(
      scaffoldKey: _scaffoldKey,
      pushDrawerController: _drawerController,
      drawerEnableOpenDragGesture: true,
      // Keep the gesture confined to the leading edge to avoid taking over
      // ordinary horizontal paging swipes across the rest of the app.
      drawerEdgeDragWidth: 72,
      drawerScrimColor: ZhPalette.ink.withValues(alpha: .2),
      drawer: drawer,
      desktopSidebar: desktopSidebar,
      pages: _pages,
      selectedIndex: _index,
      onSelectedIndex: _selectNavigation,
      onOpenDrawer: _drawerController.open,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: context.zhL10n.navRecommend,
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          label: context.zhL10n.navSearch,
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: context.zhL10n.navBookshelf,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: context.zhL10n.navMe,
        ),
      ],
    );
  }
}

int startupNavigationIndex(AppStartupPage page) => switch (page) {
  AppStartupPage.recommend => 0,
  AppStartupPage.bookshelf => 2,
};
