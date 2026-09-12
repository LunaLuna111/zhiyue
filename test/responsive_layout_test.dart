import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zhiyue_client/ui/zh_components.dart';
import 'package:zhiyue_client/ui/zh_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('responsive frame keeps desktop content centered and finite', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpWidget(
      MaterialApp(
        theme: ZhTheme.material,
        home: ZhResponsiveFrame(
          key: const ValueKey('desktop-frame'),
          maxWidth: 1180,
          desktopGutter: 24,
          child: ColoredBox(
            key: const ValueKey('desktop-frame-child'),
            color: ZhPalette.canvas,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pump();

    final child = tester.getSize(
      find.byKey(const ValueKey('desktop-frame-child')),
    );
    expect(child.width, 1132);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two pane layout downgrades to one column on narrow windows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    await tester.pumpWidget(
      MaterialApp(
        theme: ZhTheme.material,
        home: ZhResponsiveTwoPane(
          primary: const SizedBox(key: ValueKey('primary-pane')),
          secondary: const SizedBox(key: ValueKey('secondary-pane')),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('primary-pane')), findsOneWidget);
    expect(find.byKey(const ValueKey('secondary-pane')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two pane layout exposes the rail on a wide window', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(
      MaterialApp(
        theme: ZhTheme.material,
        home: ZhResponsiveTwoPane(
          primary: const SizedBox(key: ValueKey('primary-pane')),
          secondary: const SizedBox(key: ValueKey('secondary-pane')),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('primary-pane')), findsOneWidget);
    expect(find.byKey(const ValueKey('secondary-pane')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('secondary-pane'))).width,
      292,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('two pane layout gives a page view a bounded height', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(
      MaterialApp(
        theme: ZhTheme.material,
        home: ZhResponsiveTwoPane(
          primary: PageView(
            children: const [
              Center(child: Text('结果')),
              Center(child: Text('更多结果')),
            ],
          ),
          secondary: const SingleChildScrollView(child: Text('侧栏')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('结果'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clickable surfaces expose pointer hover feedback', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(700, 500));
    await tester.pumpWidget(
      ShadTheme(
        data: ZhTheme.shad,
        child: MaterialApp(
          theme: ZhTheme.material,
          home: Center(
            child: ZhSurface(
              key: const ValueKey('hover-surface'),
              onTap: () {},
              child: const SizedBox(width: 260, height: 80),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(
      tester.getCenter(find.byKey(const ValueKey('hover-surface'))),
    );
    await tester.pump(const Duration(milliseconds: 160));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MouseRegion && widget.cursor == SystemMouseCursors.click,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await gesture.removePointer();
  });

  testWidgets('shared panel and icon tile keep common interaction geometry', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ZhTheme.material,
        home: Center(
          child: ZhPanel(
            key: const ValueKey('shared-panel'),
            onTap: () => taps++,
            padding: EdgeInsets.zero,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZhIconTile(
                  key: ValueKey('shared-icon-tile'),
                  icon: Icons.history,
                ),
                SizedBox(width: 8),
                Text('公共面板'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('shared-panel')));
    await tester.pump();

    expect(taps, 1);
    expect(
      tester.getSize(find.byKey(const ValueKey('shared-icon-tile'))),
      const Size(44, 44),
    );
    expect(tester.takeException(), isNull);
  });
}
