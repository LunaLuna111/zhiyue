import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiyue_client/core/session_store.dart';
import 'package:zhiyue_client/ui/components/zh_navigation_components.dart';
import 'package:zhiyue_client/ui/zh_theme.dart';
import 'package:zhiyue_client/widgets/app_drawer.dart';
import 'package:zhiyue_client/widgets/desktop_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shell breakpoint is finite and shared with page desktop threshold', () {
    expect(
      ZhShellBreakpoints.isDesktop(ZhShellBreakpoints.desktop - .1),
      isFalse,
    );
    expect(ZhShellBreakpoints.isDesktop(ZhShellBreakpoints.desktop), isTrue);
    expect(ZhShellBreakpoints.isDesktop(double.infinity), isFalse);
  });

  Widget buildHarness({
    required GlobalKey<ScaffoldState> scaffoldKey,
    required ValueChanged<int> onSelected,
    required VoidCallback onOpenDrawer,
    ZhPushDrawerController? pushDrawerController,
    List<Widget>? pages,
    Widget? drawer,
  }) {
    final session = SessionStore();
    final shellPages =
        pages ??
        List<Widget>.generate(4, (index) => Center(child: Text('页面 $index')));
    return MaterialApp(
      theme: ZhTheme.material,
      home: ZhAdaptiveHomeShell(
        scaffoldKey: scaffoldKey,
        pages: shellPages,
        selectedIndex: 0,
        onSelectedIndex: onSelected,
        drawer: drawer ?? const Drawer(child: Text('移动菜单')),
        desktopSidebar: ZhDesktopSidebar(
          session: session,
          selectedNavigationIndex: 0,
          onNavigationSelected: onSelected,
          onColumns: _noop,
          onTopicCategories: _noop,
          onHotTopics: _noop,
          onHistory: _noop,
          onNotifications: _noop,
          onCollections: _noop,
          onUsers: _noop,
          onSettings: _noop,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '推荐'),
          NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
          NavigationDestination(icon: Icon(Icons.book), label: '书架'),
          NavigationDestination(icon: Icon(Icons.person), label: '我'),
        ],
        onOpenDrawer: onOpenDrawer,
        pushDrawerController: pushDrawerController,
      ),
    );
  }

  testWidgets('compact drawer pushes the viewport and supports edge swipe', (
    tester,
  ) async {
    final platformCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        platformCalls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.binding.setSurfaceSize(const Size(400, 800));
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final drawerController = ZhPushDrawerController();
    addTearDown(drawerController.dispose);
    await tester.pumpWidget(
      buildHarness(
        scaffoldKey: scaffoldKey,
        onSelected: (_) {},
        onOpenDrawer: drawerController.open,
        pushDrawerController: drawerController,
      ),
    );

    Transform pushedSurface() => tester.widget<Transform>(
      find.byKey(const ValueKey('push-main-surface')),
    );

    expect(pushedSurface().transform.storage[12], 0);
    final mainSurfaceRenderObject = tester.renderObject(
      find.byKey(const ValueKey('push-main-physical-surface')),
    );
    final opening = drawerController.open();
    await tester.pump(const Duration(milliseconds: 16));
    // The animation must retain the expensive viewport subtree from its very
    // first frame. Replacing the root with a gesture wrapper here discards its
    // RepaintBoundary and causes a visible opening hitch on image-heavy feeds.
    expect(
      tester.renderObject(
        find.byKey(const ValueKey('push-main-physical-surface')),
      ),
      same(mainSurfaceRenderObject),
    );
    await tester.pumpAndSettle();
    await opening;
    expect(pushedSurface().transform.storage[12], closeTo(344, .1));
    final pushedModel = tester.widget<PhysicalModel>(
      find.byKey(const ValueKey('push-main-physical-surface')),
    );
    expect(pushedModel.borderRadius, BorderRadius.zero);

    await tester.tapAt(const Offset(380, 300));
    await tester.pump(const Duration(milliseconds: 16));
    expect(
      tester.renderObject(
        find.byKey(const ValueKey('push-main-physical-surface')),
      ),
      same(mainSurfaceRenderObject),
    );
    await tester.pumpAndSettle();
    expect(drawerController.isOpen, isFalse);
    expect(pushedSurface().transform.storage[12], 0);

    // The 72dp acquisition strip includes this point; the former 52dp strip
    // did not. A full displacement is measured from pointer-down so competing
    // scrollables cannot consume the first part of the swipe.
    await tester.dragFrom(const Offset(68, 300), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(drawerController.isOpen, isTrue);
    expect(
      platformCalls.where(
        (call) =>
            call.method == 'HapticFeedback.vibrate' &&
            call.arguments == 'HapticFeedbackType.selectionClick',
      ),
      hasLength(3),
    );
  });

  testWidgets(
    'superseded drawer transitions resolve without running stale work',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      final scaffoldKey = GlobalKey<ScaffoldState>();
      final drawerController = ZhPushDrawerController();
      addTearDown(drawerController.dispose);
      await tester.pumpWidget(
        buildHarness(
          scaffoldKey: scaffoldKey,
          onSelected: (_) {},
          onOpenDrawer: drawerController.open,
          pushDrawerController: drawerController,
        ),
      );

      final opened = drawerController.open();
      await tester.pumpAndSettle();
      expect(await opened, isTrue);

      final staleClose = drawerController.close();
      await tester.pump(const Duration(milliseconds: 80));
      final reopened = drawerController.open();
      await tester.pumpAndSettle();

      expect(await staleClose, isFalse);
      expect(await reopened, isTrue);
      expect(drawerController.isOpen, isTrue);
    },
  );

  testWidgets('desktop breakpoint clears the transient drawer state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final drawerController = ZhPushDrawerController();
    addTearDown(drawerController.dispose);
    await tester.pumpWidget(
      buildHarness(
        scaffoldKey: scaffoldKey,
        onSelected: (_) {},
        onOpenDrawer: drawerController.open,
        pushDrawerController: drawerController,
      ),
    );
    final opening = drawerController.open();
    await tester.pumpAndSettle();
    expect(await opening, isTrue);

    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpAndSettle();
    expect(drawerController.isOpen, isFalse);
    expect(
      find.byKey(const ValueKey('desktop-side-navigation')),
      findsOneWidget,
    );

    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();
    final mainSurface = tester.widget<Transform>(
      find.byKey(const ValueKey('push-main-surface')),
    );
    expect(mainSurface.transform.storage[12], 0);
  });

  testWidgets('open drawer isolates its semantics from the main page', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(400, 800));
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final drawerController = ZhPushDrawerController();
    addTearDown(drawerController.dispose);
    await tester.pumpWidget(
      buildHarness(
        scaffoldKey: scaffoldKey,
        onSelected: (_) {},
        onOpenDrawer: drawerController.open,
        pushDrawerController: drawerController,
        pages: [
          Semantics(label: '主页面操作', button: true, child: SizedBox.expand()),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
        ],
        drawer: Material(
          child: Semantics(
            label: '侧边栏操作',
            button: true,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(find.semantics.byLabel('主页面操作'), findsOne);
    expect(find.semantics.byLabel('侧边栏操作'), findsNothing);

    final opening = drawerController.open();
    await tester.pumpAndSettle();
    expect(await opening, isTrue);
    expect(find.semantics.byLabel('主页面操作'), findsNothing);
    expect(find.semantics.byLabel('侧边栏操作'), findsOne);

    final closing = drawerController.close();
    await tester.pumpAndSettle();
    expect(await closing, isTrue);
    expect(find.semantics.byLabel('主页面操作'), findsOne);
    expect(find.semantics.byLabel('侧边栏操作'), findsNothing);
    semantics.dispose();
  });

  testWidgets(
    'very narrow windows keep the real drawer close button onscreen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(240, 600));
      final scaffoldKey = GlobalKey<ScaffoldState>();
      final drawerController = ZhPushDrawerController();
      final session = SessionStore();
      addTearDown(drawerController.dispose);
      await tester.pumpWidget(
        buildHarness(
          scaffoldKey: scaffoldKey,
          onSelected: (_) {},
          onOpenDrawer: drawerController.open,
          pushDrawerController: drawerController,
          drawer: ZhAppDrawer(
            session: session,
            selectedNavigationIndex: 0,
            onColumns: _noop,
            onTopicCategories: _noop,
            onHotTopics: _noop,
            onHistory: _noop,
            onNotifications: _noop,
            onCollections: _noop,
            onBookshelf: _noop,
            onUsers: _noop,
            onSettings: _noop,
            onClose: drawerController.close,
          ),
        ),
      );
      final opening = drawerController.open();
      await tester.pumpAndSettle();
      expect(await opening, isTrue);

      expect(
        tester.getRect(find.byKey(const ValueKey('push-drawer-surface'))).right,
        lessThanOrEqualTo(240),
      );
      expect(
        tester.getRect(find.byKey(const ValueKey('app-side-drawer'))).right,
        lessThanOrEqualTo(240),
      );
      expect(
        find.byKey(const ValueKey('close-side-drawer')).hitTestable(),
        findsOneWidget,
      );
    },
  );

  testWidgets('Android root back requires a second gesture to exit', (
    tester,
  ) async {
    final platformCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        platformCalls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.binding.setSurfaceSize(const Size(400, 800));
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      buildHarness(
        scaffoldKey: scaffoldKey,
        onSelected: (_) {},
        onOpenDrawer: _noop,
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('再返回一次退出应用'), findsOneWidget);
    expect(
      platformCalls.where((call) => call.method == 'SystemNavigator.pop'),
      isEmpty,
    );

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(
      platformCalls.where((call) => call.method == 'SystemNavigator.pop'),
      hasLength(1),
    );
  });

  testWidgets(
    'wide windows use persistent sidebar and hide bottom navigation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      final scaffoldKey = GlobalKey<ScaffoldState>();
      var selected = 0;
      await tester.pumpWidget(
        buildHarness(
          scaffoldKey: scaffoldKey,
          onSelected: (value) => selected = value,
          onOpenDrawer: _noop,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('desktop-side-navigation')),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsNothing);
      expect(
        find.byKey(const ValueKey('desktop-nav-recommend')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('desktop-nav-search')));
      expect(selected, 1);
    },
  );

  testWidgets('compact windows retain drawer and bottom navigation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(640, 800));
    final scaffoldKey = GlobalKey<ScaffoldState>();
    var selected = 0;
    await tester.pumpWidget(
      buildHarness(
        scaffoldKey: scaffoldKey,
        onSelected: (value) => selected = value,
        onOpenDrawer: _noop,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('desktop-side-navigation')), findsNothing);
    expect(find.byType(ZhLiquidGlassBottomNavigation), findsOneWidget);
    expect(
      find.byKey(const ValueKey('zh-liquid-glass-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.text('页面 0'), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byKey(scaffoldKey)).resizeToAvoidBottomInset,
      isFalse,
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    final pageContext = tester.element(find.text('页面 0'));
    expect(MediaQuery.viewInsetsOf(pageContext).bottom, 0);
    expect(
      MediaQuery.paddingOf(pageContext).bottom,
      MediaQuery.viewPaddingOf(pageContext).bottom,
    );

    await tester.tap(find.bySemanticsLabel('搜索'));
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets(
    'Ctrl+number selects a section and Ctrl+M invokes drawer action',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      final scaffoldKey = GlobalKey<ScaffoldState>();
      var selected = -1;
      var opened = false;
      await tester.pumpWidget(
        buildHarness(
          scaffoldKey: scaffoldKey,
          onSelected: (value) => selected = value,
          onOpenDrawer: () => opened = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      expect(selected, 2);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      expect(opened, isTrue);
    },
  );
}

void _noop() {}
