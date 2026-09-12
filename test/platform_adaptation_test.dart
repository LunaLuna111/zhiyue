import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zhiyue_client/core/platform_cache.dart';
import 'package:zhiyue_client/core/salt_bookshelf_store.dart';
import 'package:zhiyue_client/core/salt_chapter_cache.dart';
import 'package:zhiyue_client/pages/web_page.dart';
import 'package:zhiyue_client/ui/zh_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SQLite boundary excludes unsupported desktop targets', () {
    // The automated test VM has no native sqflite registrar even though
    // Flutter reports Android as its default target platform.  The cache
    // therefore deliberately selects its deterministic fallback here.
    expect(zhUsesSqliteCache, isFalse);
  });

  test(
    'platform cache keeps an in-memory value when host plugin is absent',
    () async {
      final key = 'zhiyue.test.${DateTime.now().microsecondsSinceEpoch}';
      final cache = ZhPlatformCache.instance;
      await cache.write(key, 'desktop-ok');
      expect(await cache.read(key), 'desktop-ok');
      await cache.remove(key);
      expect(await cache.read(key), isNull);
    },
  );

  test('chapter cache falls back outside SQLite targets', () async {
    final previous = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      const businessId = '990001';
      const sectionId = '990002';
      final written = await SaltChapterCache.instance.write(
        businessId: businessId,
        sectionId: sectionId,
        title: '桌面章节',
        sectionIndex: 1,
        responseJson: const {'ok': true},
        xhtml: '<p>桌面正文</p>',
      );
      final restored = await SaltChapterCache.instance.read(
        businessId: businessId,
        sectionId: sectionId,
      );
      expect(restored?.xhtml, written.xhtml);
      expect(
        await SaltChapterCache.instance.cachedSectionIds(businessId),
        contains(sectionId),
      );
      await SaltChapterCache.instance.clear();
    } finally {
      debugDefaultTargetPlatformOverride = previous;
    }
  });

  test('bookshelf keeps desktop add/remove semantics without SQLite', () async {
    final previous = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final store = SaltBookshelfStore.instance;
      await store.load(force: true);
      final entry = SaltBookshelfEntry(
        businessId: '990003',
        propertyType: 'paid_column',
        title: '桌面书架',
        artwork: '',
        sectionId: '990004',
        rawJson: const {},
        addedAt: DateTime.now(),
      );
      await store.add(entry);
      expect(store.contains(entry.businessId), isTrue);
      await store.remove(entry.businessId);
      expect(store.contains(entry.businessId), isFalse);
    } finally {
      debugDefaultTargetPlatformOverride = previous;
    }
  });

  testWidgets('unsupported desktop WebView renders a safe browser fallback', (
    tester,
  ) async {
    final previous = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      await tester.pumpWidget(
        ShadTheme(
          data: ZhTheme.shad,
          child: const MaterialApp(
            home: OfficialWebPage(
              title: '官方页面',
              url: 'https://www.zhihu.com/signin',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('当前桌面平台使用系统浏览器'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = previous;
    }
  });
}
