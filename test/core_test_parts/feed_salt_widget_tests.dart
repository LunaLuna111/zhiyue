part of '../core_test.dart';

void registerFeedSaltWidgetTests() {
  test('home feed removes service business cards without hiding content', () {
    final rows = extractHomeFeedRows({
      'data': [
        {'type': 'businesscard', 'title': 'businesscard'},
        {
          'type': 'feed',
          'target': {'type': 'business_card'},
        },
        {
          'target': {
            'type': 'answer',
            'id': '42',
            'question': {'title': '保留的推荐内容'},
          },
        },
      ],
    });

    expect(rows, hasLength(1));
    expect(titleOf(rows.single), '保留的推荐内容');
  });

  testWidgets('home pull refresh keeps rows and renders one progress ring', (
    tester,
  ) async {
    final transport = _RefreshHoldingTransport();
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(FeedPage(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('刷新前内容'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, 360));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('刷新前内容'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is CircularProgressIndicator),
      findsOneWidget,
    );

    transport.completeRefresh();
    await tester.pumpAndSettle();
    expect(find.text('刷新后内容'), findsOneWidget);
    expect(find.text('刷新前内容'), findsNothing);
  });

  testWidgets('recommend feed follows paging next near the scroll end', (
    tester,
  ) async {
    final transport = _RecordingTransport();
    transport.responses.addAll([
      _response(
        '/topstory/recommend',
        json: {
          'data': [
            for (var index = 0; index < 14; index++)
              {
                'target': {
                  'type': 'answer',
                  'id': '$index',
                  'question': {'title': '首页推荐 $index'},
                  'excerpt': '首页摘要 $index',
                },
              },
          ],
          'paging': {
            'is_end': false,
            'next': 'https://api.zhihu.com/topstory/recommend?page_number=2',
          },
        },
      ),
      _response(
        '/topstory/hot-lists/total',
        json: const {
          'data': <Object>[],
          'paging': {'is_end': true},
        },
      ),
      _response(
        '/km-vip-zhihu-web/vip_tab/svip_story',
        json: const {
          'data': <Object>[],
          'paging': {'is_end': true},
        },
      ),
      _response(
        '/topstory/recommend?page_number=2',
        json: {
          'data': [
            {
              'target': {
                'type': 'answer',
                'id': '14',
                'question': {'title': '第二页新推荐'},
                'excerpt': '续页摘要',
              },
            },
          ],
          'paging': {'is_end': true},
        },
      ),
    ]);
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(FeedPage(api: api)));
    await tester.pumpAndSettle();
    expect(transport.calls, hasLength(3));
    expect(
      transport.calls.map((call) => call.uri.path),
      containsAll(const [
        '/topstory/recommend',
        '/topstory/hot-lists/total',
        '/km-vip-zhihu-web/vip_tab/svip_story',
      ]),
    );
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsNothing);
    expect(find.text('匿名推荐 · 实时'), findsNothing);
    expect(find.text('下拉刷新'), findsNothing);
    expect(find.text('推荐'), findsOneWidget);

    final headerTop = tester.getTopLeft(find.text('推荐')).dy;
    expect(find.byType(AnimatedSlide), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.getTopLeft(find.text('推荐')).dy, closeTo(headerTop, 0.01));

    await tester.fling(find.byType(ListView), const Offset(0, -2200), 3200);
    await tester.pumpAndSettle();

    expect(transport.calls, hasLength(4));
    expect(
      transport.calls.last.uri.toString(),
      'https://api.zhihu.com/topstory/recommend?page_number=2',
    );
    await tester.scrollUntilVisible(
      find.text('第二页新推荐'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('第二页新推荐'), findsOneWidget);
  });

  testWidgets('home feed channels preload before swipe and tab click', (
    tester,
  ) async {
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response(
          '/topstory/recommend',
          json: const {
            'data': <Object>[],
            'paging': {'is_end': true},
          },
        ),
        _response(
          '/topstory/hot-lists/total',
          json: const {
            'data': <Object>[],
            'paging': {'is_end': true},
          },
        ),
      ]);
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(FeedPage(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('关注'), findsOneWidget);
    expect(find.text('推荐'), findsOneWidget);
    expect(find.text('热榜'), findsOneWidget);
    expect(find.text('故事'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    expect(transport.calls, hasLength(3));
    expect(
      transport.calls.map((call) => call.uri.path),
      containsAll(const [
        '/topstory/recommend',
        '/topstory/hot-lists/total',
        '/km-vip-zhihu-web/vip_tab/svip_story',
      ]),
    );

    final pageView = find.byType(PageView);
    final pageTopLeft = tester.getTopLeft(pageView);
    final pageSize = tester.getSize(pageView);
    await tester.flingFrom(
      pageTopLeft + Offset(24, pageSize.height / 2),
      const Offset(-420, 0),
      1800,
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.text('推荐')).style?.fontWeight,
      FontWeight.w800,
    );

    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1800);
    await tester.pumpAndSettle();
    expect(transport.calls, hasLength(3));
    expect(
      transport.calls.map((call) => call.uri.toString()),
      contains(
        'https://api.zhihu.com/topstory/hot-lists/total'
        '?limit=10&is_browse_model=0&new_hot_list=false',
      ),
    );
    expect(
      tester.widget<Text>(find.text('热榜')).style?.fontWeight,
      FontWeight.w800,
    );

    await tester.tap(find.text('推荐'));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.fling(find.byType(PageView), const Offset(-260, 0), 1200);
    await tester.pumpAndSettle();
    final settledPage = tester
        .widget<PageView>(find.byType(PageView))
        .controller!
        .page!
        .round();
    final settledLabel = const ['关注', '推荐', '热榜', '故事'][settledPage];
    expect(
      tester.widget<Text>(find.text(settledLabel)).style?.fontWeight,
      FontWeight.w800,
    );
  });

  testWidgets(
    'home starts four data preloads concurrently without building four trees',
    (tester) async {
      final session = SessionStore()
        ..sessionKind = 'imported'
        ..authorization = 'Bearer account-token'
        ..udid = 'account-udid';
      final transport = _ConcurrentHomePreloadTransport();
      addTearDown(transport.releaseAll);
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);

      await tester.pumpWidget(_testApp(FeedPage(api: api)));
      await tester.pump();

      expect(
        transport.paths.toSet(),
        _ConcurrentHomePreloadTransport.expectedPaths,
      );
      expect(transport.inFlight, 4);
      expect(transport.maxInFlight, 4);
      expect(
        find.byKey(const ValueKey('home-recommend-feed'), skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('home-following-feed'), skipOffstage: false),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('home-hot-feed'), skipOffstage: false),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('home-story-feed'), skipOffstage: false),
        findsNothing,
      );

      transport.releaseAll();
      await tester.pumpAndSettle();
      for (final label in const ['热榜', '故事', '关注', '推荐']) {
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        expect(transport.paths, hasLength(4));
      }
      for (final path in _ConcurrentHomePreloadTransport.expectedPaths) {
        expect(
          transport.paths.where((candidate) => candidate == path),
          hasLength(1),
        );
      }
    },
  );

  testWidgets('home reselect returns to top and requests fresh content', (
    tester,
  ) async {
    final transport = _HomeReselectTransport(holdRefresh: true);
    final controller = HomeFeedController();
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _testApp(FeedPage(api: api, controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('刷新前内容 0'), findsOneWidget);
    expect(transport.recommendationCalls, 1);

    final initialList = find.byKey(const ValueKey('home-recommend-scroll'));
    await tester.drag(initialList, const Offset(0, -500));
    await tester.pumpAndSettle();
    final initialScrollable = find.descendant(
      of: initialList,
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(initialScrollable.first).position.pixels,
      greaterThan(0),
    );

    controller.returnToTopAndRefresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      tester.state<ScrollableState>(initialScrollable.first).position.pixels,
      0,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data?.startsWith('刷新前内容') == true,
      ),
      findsWidgets,
    );
    expect(find.text('刷新后内容'), findsNothing);
    expect(
      find.byWidgetPredicate((widget) => widget is CircularProgressIndicator),
      findsOneWidget,
    );
    expect(transport.recommendationCalls, 2);

    transport.completeRefresh();
    await tester.pumpAndSettle();

    expect(find.text('刷新后内容'), findsOneWidget);
    final refreshedScrollable = find.descendant(
      of: find.byKey(const ValueKey('home-recommend-scroll')),
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(refreshedScrollable.first).position.pixels,
      0,
    );
  });

  testWidgets('guest credential rotation does not rebuild the visible feed', (
    tester,
  ) async {
    final session = SessionStore()
      ..sessionKind = 'guest'
      ..authorization = 'Bearer guest-a'
      ..udid = 'guest-udid-a';
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response(
          '/topstory/recommend',
          json: const {
            'data': [
              {
                'target': {
                  'type': 'answer',
                  'id': 'stable',
                  'question': {'title': '稳定的推荐内容'},
                },
              },
            ],
            'paging': {'is_end': true},
          },
        ),
        _response(
          '/topstory/hot-lists/total',
          json: const {
            'data': <Object>[],
            'paging': {'is_end': true},
          },
        ),
        _response(
          '/km-vip-zhihu-web/vip_tab/svip_story',
          json: const {
            'data': <Object>[],
            'paging': {'is_end': true},
          },
        ),
      ]);
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(FeedPage(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('稳定的推荐内容'), findsOneWidget);
    expect(
      transport.calls.where((call) => call.uri.path == '/topstory/recommend'),
      hasLength(1),
    );

    session
      ..authorization = 'Bearer guest-b'
      ..udid = 'guest-udid-b'
      ..notifyListeners();
    await tester.pumpAndSettle();

    expect(find.text('稳定的推荐内容'), findsOneWidget);
    expect(
      transport.calls.where((call) => call.uri.path == '/topstory/recommend'),
      hasLength(1),
    );
  });

  testWidgets('account scope change discards late private feed preloads', (
    tester,
  ) async {
    final session = SessionStore()
      ..sessionKind = 'account'
      ..accountUid = 'account-a-id'
      ..authorization = 'Bearer account-a'
      ..udid = 'account-a-udid';
    final transport = _ScopedHomePreloadTransport();
    addTearDown(transport.releaseAll);
    final api = ZhihuApiClient(
      session,
      transport: transport,
      cloudIdSigner: _StaticCloudIdSigner(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(FeedPage(api: api)));
    await tester.pump();
    expect(
      transport.accountPaths.toSet(),
      _ConcurrentHomePreloadTransport.expectedPaths,
    );

    await session.clear();
    await tester.pump();
    expect(transport.anonymousPaths.toSet(), {
      '/topstory/recommend',
      '/topstory/hot-lists/total',
      '/km-vip-zhihu-web/vip_tab/svip_story',
    });

    transport.releaseAnonymous();
    await tester.pumpAndSettle();
    expect(find.text('新匿名推荐'), findsOneWidget);
    expect(find.text('旧账号私有推荐'), findsNothing);

    transport.releaseAccount();
    await tester.pumpAndSettle();
    expect(find.text('新匿名推荐'), findsOneWidget);
    expect(find.text('旧账号私有推荐'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'stale account feed response cannot dirty mounted tab before scope rebuild',
    (tester) async {
      final session = SessionStore()
        ..sessionKind = 'account'
        ..accountUid = 'account-a-id'
        ..authorization = 'Bearer account-a'
        ..udid = 'account-a-udid';
      final transport = _ScopedHomePreloadTransport();
      addTearDown(transport.releaseAll);
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);

      await tester.pumpWidget(_testApp(FeedPage(api: api)));
      await tester.pump();
      final staleTab = tester.element(
        find.byKey(const ValueKey('home-recommend-feed')),
      );
      expect(staleTab.dirty, isFalse);

      final clearing = session.clear();
      expect(staleTab.mounted, isTrue);
      transport.releaseAccountPath('/topstory/recommend');
      // Flush the response continuation without pumping the scheduled frame.
      // The old keyed subtree is deliberately still mounted here.
      await tester.idle();

      expect(staleTab.mounted, isTrue);
      expect(staleTab.dirty, isFalse);
      await clearing;
    },
  );

  testWidgets(
    'stale account story response cannot dirty mounted tab before scope rebuild',
    (tester) async {
      final session = SessionStore()
        ..sessionKind = 'account'
        ..accountUid = 'account-a-id'
        ..authorization = 'Bearer account-a'
        ..udid = 'account-a-udid';
      final transport = _ScopedHomePreloadTransport();
      addTearDown(transport.releaseAll);
      final controller = HomeFeedController()..select(HomeFeedChannel.story);
      addTearDown(controller.dispose);
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);

      await tester.pumpWidget(
        _testApp(FeedPage(api: api, controller: controller)),
      );
      await tester.pump();
      final staleTab = tester.element(
        find.byKey(const ValueKey('home-story-feed')),
      );
      expect(staleTab.dirty, isFalse);

      final clearing = session.clear();
      expect(staleTab.mounted, isTrue);
      transport.releaseAccountPath('/km-vip-zhihu-web/vip_tab/svip_story');
      await tester.idle();

      expect(staleTab.mounted, isTrue);
      expect(staleTab.dirty, isFalse);
      await clearing;
    },
  );

  testWidgets('hidden home preload transport errors are handled', (
    tester,
  ) async {
    final transport = _HiddenFeedFailureTransport();
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(FeedPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('推荐'), findsOneWidget);
    expect(transport.paths, hasLength(3));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('热榜'));
    await tester.pumpAndSettle();

    expect(
      transport.paths.where((path) => path == '/topstory/hot-lists/total'),
      hasLength(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('account home preload also includes the following feed', (
    tester,
  ) async {
    final session = SessionStore()
      ..sessionKind = 'imported'
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid';
    final transport = _RecordingTransport();
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(FeedPage(api: api)));
    await tester.pumpAndSettle();

    expect(transport.calls, hasLength(4));
    expect(
      transport.calls.map((call) => call.uri.path),
      containsAll(const [
        '/moments_v3',
        '/topstory/recommend',
        '/topstory/hot-lists/total',
        '/km-vip-zhihu-web/vip_tab/svip_story',
      ]),
    );
    final following = transport.calls.singleWhere(
      (call) => call.uri.path == '/moments_v3',
    );
    expect(following.uri.queryParameters['feed_type'], 'all');
    expect(following.headers['need_debug'], '0');
    expect(following.headers['x-api-version'], '3.0.93');
  });

  testWidgets(
    'follow item group renders children and expands without internal id',
    (tester) async {
      final session = SessionStore()
        ..sessionKind = 'imported'
        ..authorization = 'Bearer account-token'
        ..udid = 'account-udid';
      final controller = HomeFeedController()
        ..select(HomeFeedChannel.following);
      final api = ZhihuApiClient(
        session,
        transport: _FollowItemGroupTransport(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);

      await tester.pumpWidget(
        _testApp(FeedPage(api: api, controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('item_group_card'), findsNothing);
      expect(find.textContaining('聚合用户', findRichText: true), findsOneWidget);
      expect(find.textContaining('赞同了回答', findRichText: true), findsOneWidget);
      expect(find.text('第一条真实回答'), findsOneWidget);
      expect(find.text('第二条真实回答'), findsNothing);
      expect(find.text('TA 还赞同了 1 个回答'), findsOneWidget);

      await tester.tap(find.text('TA 还赞同了 1 个回答'));
      await tester.pumpAndSettle();

      expect(find.text('第二条真实回答'), findsOneWidget);
      expect(find.text('TA 还赞同了 1 个回答'), findsNothing);
    },
  );

  test(
    'follow people group unfolds the nested profile instead of wire type',
    () {
      final child = followItemGroupChildren(const {
        'type': 'item_group_card',
        'actor': {'id': 'actor-id', 'name': '知乎用户啊'},
        'action_text': '关注了用户',
        'data': [
          {
            'type': 'people',
            'id': 'transport-shell-id',
            'card_extend_data': {
              'type': 'people',
              'id': 'target-id',
              'url_token': 'target-token',
              'name': '被关注用户',
              'description': '真实用户简介',
              'avatar_url': 'https://pic.example/target.jpg',
            },
          },
        ],
      }).single;

      expect(typeOf(child), 'people');
      expect(idOf(child), 'target-id');
      expect(titleOf(child), '被关注用户');
      expect(subtitleOf(child), '真实用户简介');
      expect(child['url_token'], 'target-token');
      expect(child['avatar_url'], 'https://pic.example/target.jpg');
      expect(titleOf(child), isNot('people'));
    },
  );

  testWidgets('bottom Salt destination is a direct bookshelf page', (
    tester,
  ) async {
    final transport = _RecordingTransport();
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(SaltPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('书架'), findsOneWidget);
    expect(find.textContaining('本地书架'), findsOneWidget);
    expect(transport.calls, isEmpty);
  });

  testWidgets('comment card renders author once with reply metadata', (
    tester,
  ) async {
    final created = DateTime(2024, 1, 2).millisecondsSinceEpoch ~/ 1000;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: CommentCard(
            value: {
              'type': 'comment',
              'id': '9',
              'content': '这是一条评论',
              'author': {'name': '示例作者'},
              'reply_to_author': {'name': '目标用户'},
              'like_count': 88,
              'child_comment_count': 12,
              'created_time': created,
            },
          ),
        ),
      ),
    );
    expect(find.text('示例作者'), findsOneWidget);
    expect(find.text('回复 @目标用户'), findsOneWidget);
    expect(find.text('这是一条评论'), findsOneWidget);
    expect(find.text('88'), findsOneWidget);
    expect(find.text('12 条回复'), findsOneWidget);
    expect(find.text('发布于 2024-01-02'), findsOneWidget);
  });

  testWidgets('compact Salt comment row is flat and keeps reply metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: CommentCard(
            compact: true,
            value: const {
              'type': 'comment',
              'id': '10',
              'content': '紧凑评论正文',
              'author': {'name': '评论作者'},
              'like_count': 7,
              'child_comment_count': 2,
            },
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('评论作者'), findsOneWidget);
    expect(find.text('紧凑评论正文'), findsOneWidget);
    expect(find.text('查看全部 2 条回复'), findsOneWidget);
    expect(find.byType(ZhSurface), findsNothing);
  });

  testWidgets('comment like is reversible and updates its visible count', (
    tester,
  ) async {
    final targets = <bool>[];
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: CommentCard(
            compact: true,
            value: const {
              'type': 'comment',
              'id': '11',
              'content': '可互动评论',
              'author': {'name': '评论者'},
              'like_count': 7,
              'liked': false,
            },
            onLike: (liked) async {
              targets.add(liked);
              return true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('7'));
    await tester.pump();
    expect(find.text('8'), findsOneWidget);

    await tester.tap(find.text('8'));
    await tester.pump();
    expect(find.text('7'), findsOneWidget);
    expect(targets, [true, false]);
  });

  testWidgets('people card renders profile counts with a single name', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: ObjectCard(
            value: {
              'type': 'people',
              'id': 'member-id',
              'name': '用户甲',
              'headline': '公开简介',
              'followers_count': 12345,
              'answer_count': 88,
              'articles_count': 9,
            },
          ),
        ),
      ),
    );
    expect(find.text('用户甲'), findsOneWidget);
    expect(find.text('1.2万 关注者'), findsOneWidget);
    expect(find.text('88 回答'), findsOneWidget);
    expect(find.text('9 文章'), findsOneWidget);
  });

  testWidgets('salt catalog card renders official work metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: SaltCatalogCard(
            value: {
              'title': '示例盐选故事',
              'content': '真实推荐摘要',
              'labels': ['悬疑'],
              'recommend_reason': '近期热门',
              'like_text': '1.7 万',
              'word_count_text': '1.2 万字',
              'producer_name': '盐选作者',
              'sku_cap_text': '全 18 节',
              'has_tts': true,
              '_downloaded_section_count': 44,
              '_total_section_count': 100,
              'status_text': '连载中',
            },
          ),
        ),
      ),
    );
    expect(find.text('盐选故事'), findsOneWidget);
    expect(find.text('示例盐选故事'), findsOneWidget);
    expect(find.text('真实推荐摘要'), findsOneWidget);
    expect(find.text('悬疑'), findsOneWidget);
    expect(find.text('近期热门'), findsOneWidget);
    expect(find.text('1.7 万'), findsOneWidget);
    expect(find.text('1.2 万字'), findsOneWidget);
    expect(find.text('盐选作者'), findsOneWidget);
    expect(find.text('全 18 节'), findsOneWidget);
    expect(find.text('可听'), findsOneWidget);
    expect(find.text('44/100 已下载'), findsOneWidget);
    expect(find.text('连载中'), findsOneWidget);
  });

  testWidgets('salt story feed keeps all official cards as lazy list rows', (
    tester,
  ) async {
    final initialResponse = _response(
      '/km-vip-zhihu-web/vip_tab/svip_story',
      json: {
        'data': [
          {
            'module_type': 'feed_card',
            'module_title': '盐选推荐',
            'module_data': {
              'data': {
                'content_list': [
                  for (var index = 0; index < 24; index++)
                    {
                      'business_id': '${1000 + index}',
                      'business_type': 'PaidColumn',
                      'title': '盐选作品 $index',
                      'description': '作品简介 $index',
                    },
                ],
              },
            },
          },
        ],
        'paging': {'is_end': true},
      },
    );
    final transport = _RecordingTransport();
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: SaltStoryHome(
            api: api,
            initialResponse: Future.value(initialResponse),
            onOpenCard: (_) {},
            onOpenShortcut: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(transport.calls, isEmpty);
    expect(find.text('盐选推荐'), findsOneWidget);
    expect(find.text('盐选作品 0'), findsOneWidget);
    expect(find.text('盐选作品 23'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('盐选作品 23'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('盐选作品 23'), findsOneWidget);
  });

  testWidgets('salt billboard selected category keeps a visible white label', (
    tester,
  ) async {
    final transport = _RecordingTransport();
    final session = SessionStore()..prefetchImages = false;
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);
    final response = _response(
      '/km-vip-zhihu-web/vip_tab/svip_story',
      json: {
        'data': [
          {
            'module_type': 'vip_card',
            'module_data': {
              'data': {
                'title': '开通盐选会员',
                'sub_title': '畅享 10w+ 优质内容',
                'button_text': '最低 0.3 元/天',
              },
            },
          },
          {
            'module_type': 'billboard',
            'module_title': '榜单',
            'module_data': {
              'data': {
                'data': [
                  {
                    'head': {'title': '热度榜'},
                    'content_list': [
                      {
                        'title': '热榜作品',
                        'artwork': 'https://pic.example/hot-cover.jpg',
                      },
                    ],
                  },
                  {
                    'head': {'title': '口碑榜'},
                    'content_list': [
                      {'title': '口碑作品'},
                    ],
                  },
                ],
              },
            },
          },
        ],
        'paging': {'is_end': true},
      },
    );

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: SaltStoryHome(
            api: api,
            initialResponse: Future.value(response),
            onOpenCard: (_) {},
            onOpenShortcut: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('开通盐选会员'), findsNothing);
    expect(find.text('最低 0.3 元/天'), findsNothing);
    final hotCover = tester.widget<Image>(
      _networkImageFinder('https://pic.example/hot-cover.jpg'),
    );
    expect(hotCover.image, isA<ResizeImage>());
    expect((hotCover.image as ResizeImage).width, saltStoryCoverCacheWidth);
    expect((hotCover.image as ResizeImage).height, isNull);
    expect(tester.widget<Text>(find.text('热度榜')).style?.color, Colors.white);
    await tester.tap(find.text('口碑榜'));
    await tester.pump();
    expect(tester.widget<Text>(find.text('口碑榜')).style?.color, Colors.white);
    expect(tester.widget<Text>(find.text('热度榜')).style?.color, ZhPalette.ink);
  });

  testWidgets('short Salt reader exposes bookshelf and export actions', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accessTokenExpiry = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
    final transport = _RecordingTransport()
      ..responses.add(
        _response(
          '/remix-pre-web/manuscript/123/456/content',
          json: {
            'manuscript_sum': {
              'manuscript_content': {
                'data': {'script': '<p>短篇正文</p>', 'script_type': 0},
              },
              'manuscript_info': {
                'id': '456',
                'title': '短篇测试',
                'property_type': 'short_story',
                'is_long': false,
                'section_index': 0,
                'parent': {'title': '短篇测试', 'section_count': 1},
                'comment': {
                  'comment_type': 'paid_column_section_manuscripts',
                  'comment_content_id': '456',
                  'comment_count': 2,
                },
              },
            },
          },
        ),
      );
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        SaltReaderPage(
          api: api,
          businessId: '123',
          sectionId: '456',
          keyProvider: const FixedSaltManuscriptKeyProvider(
            rawKey: 'ABCDEFGHIJKLMNOP',
            transKey: 'test-trans-key',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SaltChapterView));
    await tester.pumpAndSettle();
    expect(find.text('加入书架'), findsOneWidget);
    expect(find.byTooltip('刷新章节'), findsNothing);
    expect(find.byTooltip('更多'), findsOneWidget);
    await tester.tap(find.byTooltip('更多'));
    await tester.pumpAndSettle();
    expect(find.text('刷新'), findsOneWidget);
    expect(find.text('导出 TXT 文件'), findsOneWidget);
    expect(find.text('导出 DOCX 文件'), findsOneWidget);
  });

  testWidgets('Salt comments open when manu core metadata is unavailable', (
    tester,
  ) async {
    // SaltChapterCache is a process-wide store. Keep this flow independent
    // from the preceding reader test, which intentionally writes the same
    // fixture ids to exercise the cache-hit path.
    await SaltChapterCache.instance.clear();
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accessTokenExpiry = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response(
          '/remix-pre-web/manuscript/123/456/content',
          json: {
            'manuscript_sum': {
              'manuscript_content': {
                'data': {'script': '<p>没有评论元数据的正文</p>', 'script_type': 0},
              },
              'manuscript_info': {
                'id': '456',
                'title': '评论回退测试',
                'property_type': 'short_story',
                'is_long': false,
              },
            },
          },
        ),
        _response(
          '/remix-pre-web/manuscript/123/456/manu_core',
          statusCode: 401,
          json: const {'error': {}},
        ),
        _response(
          '/comment_v5/paid_column_section_manuscripts/456/list-headers',
          json: const <String, dynamic>{},
        ),
        _response(
          '/km-indep-home-vip-comment/'
          'paid_column_section_manuscripts/456/root_comment',
          json: const {
            'counts': {'total_counts': 1},
            'sorter': [
              {'type': 'score', 'text': '默认'},
              {'type': 'time', 'text': '最新'},
            ],
            'data': [
              {
                'id': '9001',
                'content': '小说评论甲',
                'author': {'name': '读者甲'},
                'vote_count': 2,
                'child_comment_count': 1,
              },
            ],
            'paging': {'is_end': true},
          },
        ),
        _response(
          '/km-indep-home-vip-comment/'
          'paid_column_section_manuscripts/456/root_comment',
          json: const {
            'counts': {'total_counts': 1},
            'sorter': [
              {'type': 'score', 'text': '默认'},
              {'type': 'time', 'text': '最新'},
            ],
            'data': [
              {
                'id': '9001',
                'content': '小说评论甲',
                'author': {'name': '读者甲'},
                'vote_count': 2,
                'child_comment_count': 1,
              },
            ],
            'paging': {'is_end': true},
          },
        ),
      ]);
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        SaltReaderPage(
          api: api,
          businessId: '123',
          sectionId: '456',
          keyProvider: const FixedSaltManuscriptKeyProvider(
            rawKey: 'ABCDEFGHIJKLMNOP',
            transKey: 'test-trans-key',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(SaltChapterView));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('全部评论'), findsOneWidget);
    expect(find.text('默认'), findsOneWidget);
    expect(find.text('最新'), findsOneWidget);
    expect(find.text('小说评论甲'), findsOneWidget);
    expect(find.byKey(const Key('comment-editor-entry')), findsOneWidget);
    expect(find.text('理性发言，友善互动'), findsOneWidget);
    expect(find.byKey(const Key('salt-comments-close-action')), findsOneWidget);
    expect(find.text('热度'), findsNothing);
    await tester.tap(find.text('最新'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      transport.calls.any(
        (call) =>
            call.uri.path ==
            '/km-indep-home-vip-comment/'
                'paid_column_section_manuscripts/456/root_comment',
      ),
      isTrue,
    );
    expect(
      transport.calls.any(
        (call) =>
            call.uri.path ==
                '/km-indep-home-vip-comment/'
                    'paid_column_section_manuscripts/456/root_comment' &&
            call.uri.queryParameters['order_by'] == 'ts',
      ),
      isTrue,
    );
    expect(
      api
          .saltCommentCreateUri(
            objectType: 'paid_column_section_manuscript',
            objectId: '456',
          )
          .path,
      '/comment_v5/paid_column_section_manuscripts/456/comment',
    );
  });

  testWidgets(
    'Salt paragraph comments keep a 44px target and truthful semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final chapter = SaltTextChapter.fromXhtml(
        chapterId: 'touch-target',
        xhtml: '<p>带有弹评入口的正文</p>',
      );
      const annotation = SaltParagraphAnnotation(
        paragraphIndex: 0,
        commentId: '301',
        commentCount: 7,
        hasOwnComment: false,
      );
      var taps = 0;

      Widget reader({required bool enabled}) => _testApp(
        Scaffold(
          body: SaltChapterView(
            chapter: chapter,
            flow: SaltReaderFlow.vertical,
            settings: const SaltReaderSettings(),
            annotations: const {0: annotation},
            onAnnotationTap: enabled ? (_) => taps += 1 : null,
          ),
        ),
      );

      await tester.pumpWidget(reader(enabled: true));
      final target = find.byKey(const ValueKey('salt-paragraph-comment-0'));
      final size = tester.getSize(target);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(
        tester.getSemantics(target).getSemanticsData().flagsCollection.isButton,
        isTrue,
      );

      // This point is inside the expanded target but outside the centered
      // 26x22 visual badge.
      await tester.tapAt(tester.getTopLeft(target) + const Offset(2, 2));
      await tester.pump();
      expect(taps, 1);

      await tester.pumpWidget(reader(enabled: false));
      expect(
        tester.getSemantics(target).getSemanticsData().flagsCollection.isButton,
        isFalse,
      );
      semantics.dispose();
    },
  );
}

class _FollowItemGroupTransport extends ApiTransport {
  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    if (uri.path == '/moments_v3') {
      return _response(
        '/moments_v3',
        json: const {
          'data': [
            {
              'type': 'item_group_card',
              'id': '1787461327388',
              'actor': {'name': '聚合用户'},
              'action_text': '赞同了回答',
              'action_time': 1787395080,
              'group_text': 'TA 还赞同了 1 个回答',
              'unfold_show_size': 1,
              'data': [
                {
                  'type': 'answer',
                  'id': '101',
                  'title': '第一条真实回答',
                  'digest': '第一条回答摘要',
                  'author': '作者甲',
                },
                {
                  'type': 'answer',
                  'id': '102',
                  'title': '第二条真实回答',
                  'digest': '第二条回答摘要',
                  'author': '作者乙',
                },
              ],
            },
          ],
          'paging': {'is_end': true},
        },
      );
    }
    return ApiResponse(
      uri: uri,
      statusCode: 200,
      bodyBytes: 2,
      json: const {
        'data': <Object>[],
        'paging': {'is_end': true},
      },
      headers: const {},
    );
  }
}

class _HiddenFeedFailureTransport extends ApiTransport {
  final paths = <String>[];

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    paths.add(uri.path);
    if (uri.path == '/topstory/recommend') {
      return ApiResponse(
        uri: uri,
        statusCode: 200,
        bodyBytes: 2,
        json: const {
          'data': <Object>[],
          'paging': {'is_end': true},
        },
        headers: const {},
      );
    }
    throw const ApiTransportException('hidden preload offline');
  }
}

class _ConcurrentHomePreloadTransport extends ApiTransport {
  static const expectedPaths = {
    '/moments_v3',
    '/topstory/recommend',
    '/topstory/hot-lists/total',
    '/km-vip-zhihu-web/vip_tab/svip_story',
  };

  final _responses = {
    for (final path in expectedPaths) path: Completer<ApiResponse>(),
  };
  final List<String> paths = [];
  int inFlight = 0;
  int maxInFlight = 0;

  void releaseAll() {
    for (final entry in _responses.entries) {
      if (entry.value.isCompleted) continue;
      entry.value.complete(
        _response(
          entry.key,
          json: const {
            'data': <Object>[],
            'paging': {'is_end': true},
          },
        ),
      );
    }
  }

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) {
    paths.add(uri.path);
    final response = _responses[uri.path];
    if (response == null) {
      return Future.error(StateError('Unexpected home request: ${uri.path}'));
    }
    inFlight += 1;
    if (inFlight > maxInFlight) maxInFlight = inFlight;
    return response.future.whenComplete(() => inFlight -= 1);
  }
}

class _ScopedHomePreloadTransport extends ApiTransport {
  final _accountResponses = {
    for (final path in _ConcurrentHomePreloadTransport.expectedPaths)
      path: Completer<ApiResponse>(),
  };
  final _anonymousResponses = {
    for (final path in _ConcurrentHomePreloadTransport.expectedPaths)
      if (path != '/moments_v3') path: Completer<ApiResponse>(),
  };
  final accountPaths = <String>[];
  final anonymousPaths = <String>[];

  void releaseAccount() =>
      _release(_accountResponses, recommendationTitle: '旧账号私有推荐');

  void releaseAnonymous() =>
      _release(_anonymousResponses, recommendationTitle: '新匿名推荐');

  void releaseAccountPath(String path) {
    final response = _accountResponses[path];
    if (response == null) {
      throw StateError('Unknown account home path: $path');
    }
    if (response.isCompleted) return;
    response.complete(
      _response(
        path,
        json: const {
          'data': <Object>[],
          'paging': {'is_end': true},
        },
      ),
    );
  }

  void releaseAll() {
    releaseAccount();
    releaseAnonymous();
  }

  void _release(
    Map<String, Completer<ApiResponse>> responses, {
    required String recommendationTitle,
  }) {
    for (final entry in responses.entries) {
      if (entry.value.isCompleted) continue;
      entry.value.complete(
        _response(
          entry.key,
          json: {
            'data': entry.key == '/topstory/recommend'
                ? [
                    {
                      'target': {
                        'type': 'answer',
                        'id': recommendationTitle,
                        'question': {'title': recommendationTitle},
                      },
                    },
                  ]
                : <Object>[],
            'paging': const {'is_end': true},
          },
        ),
      );
    }
  }

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) {
    final isAccount = headers['Authorization'] == 'Bearer account-a';
    final paths = isAccount ? accountPaths : anonymousPaths;
    final responses = isAccount ? _accountResponses : _anonymousResponses;
    paths.add(uri.path);
    final response = responses[uri.path];
    if (response == null) {
      return Future.error(
        StateError('Unexpected scoped home request: ${uri.path}'),
      );
    }
    return response.future;
  }
}
