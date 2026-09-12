import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/api_client.dart';
import 'core/api_contract.dart';
import 'core/app_log.dart';
import 'core/json_tools.dart';
import 'core/session_store.dart';
import 'pages/account_page.dart';
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
import 'ui/zh_theme.dart';
import 'widgets/app_drawer.dart';
import 'widgets/desktop_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = SessionStore();
  await session.load();
  await AppLogStore.instance.initialize(session: session);
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
  runApp(ZhiyueApp(session: session, contract: contract));
}

class ZhiyueApp extends StatefulWidget {
  const ZhiyueApp({super.key, required this.session, required this.contract});

  final SessionStore session;
  final ApiContract contract;

  @override
  State<ZhiyueApp> createState() => _ZhiyueAppState();
}

class _ZhiyueAppState extends State<ZhiyueApp> {
  late final ZhihuApiClient _api = ZhihuApiClient(widget.session);
  late int _presentationFingerprint;

  int get _currentPresentationFingerprint => Object.hash(
    widget.session.readingTextSize,
    widget.session.followSystemTextScale,
    widget.session.reduceMotion,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadTheme(
      data: ZhTheme.shad,
      child: MaterialApp(
        title: '知阅',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ZhTheme.material,
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
        home: AppUpdatePromptGate(
          child: HomeShell(
            api: _api,
            session: widget.session,
            contract: widget.contract,
          ),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.api,
    required this.session,
    required this.contract,
  });

  final ZhihuApiClient api;
  final SessionStore session;
  final ApiContract contract;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _drawerController = ZhPushDrawerController();
  final _feedController = HomeFeedController();
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
    SearchPage(api: widget.api),
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
  }

  @override
  void dispose() {
    _feedController.removeListener(_feedSelectionChanged);
    _feedController.dispose();
    _drawerController.dispose();
    super.dispose();
  }

  void _feedSelectionChanged() {
    if (mounted) setState(() {});
  }

  void _selectNavigation(int value) {
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
            builder: (_) =>
                AppSettingsPage(session: widget.session, api: widget.api),
          ),
        );
      }),
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
    final response = await widget.api.get('/people/self');
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('登录知乎后可以查看自己的收藏')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PagedListPage(
          title: '我的收藏',
          api: widget.api,
          loadInitial: () => widget.api.getUri(
            widget.api.userCollectionsInitialUri(memberId),
            headers: const {'x-api-version': '3.0.94'},
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
                  title: titleOf(value).isEmpty ? '收藏集' : titleOf(value),
                  api: widget.api,
                  loadInitial: () => widget.api.getUri(
                    widget.api.collectionContentsInitialUri(collectionId),
                  ),
                  onObjectTap: (context, item) =>
                      openDetectedObject(context, widget.api, item),
                  emptyMessage: '这个收藏集暂时没有内容',
                ),
              ),
            );
          },
          emptyMessage: '还没有创建或收藏内容',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawer = ZhAppDrawer(
      session: widget.session,
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
      drawerEnableOpenDragGesture: _index == 0,
      // Wide enough to acquire reliably without reaching the center-only home
      // channel swipe zone.
      drawerEdgeDragWidth: 72,
      drawerScrimColor: ZhPalette.ink.withValues(alpha: .2),
      drawer: drawer,
      desktopSidebar: desktopSidebar,
      pages: _pages,
      selectedIndex: _index,
      onSelectedIndex: _selectNavigation,
      onOpenDrawer: _drawerController.open,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '推荐',
        ),
        NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: '书架',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: '我',
        ),
      ],
    );
  }
}

int startupNavigationIndex(AppStartupPage page) => switch (page) {
  AppStartupPage.recommend => 0,
  AppStartupPage.bookshelf => 2,
};
