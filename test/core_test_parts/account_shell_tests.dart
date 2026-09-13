part of '../core_test.dart';

void registerAccountShellTests() {
  testWidgets('my page shows embedded native login when account is absent', (
    tester,
  ) async {
    final session = SessionStore();
    final api = ZhihuApiClient(session);
    addTearDown(api.close);
    await tester.pumpWidget(_testApp(MyPage(api: api, session: session)));

    expect(find.byType(NativeLoginPage), findsOneWidget);
    expect(find.byKey(const ValueKey('embedded-native-login')), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
  });

  testWidgets(
    'settings page exposes startup, feed order and content controls',
    (tester) async {
      final session = _PreferenceSessionStore();
      final api = ZhihuApiClient(session);
      addTearDown(api.close);
      await tester.pumpWidget(_testApp(AppSettingsPage(session: session)));

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('home-feed-order-setting')),
        360,
      );
      expect(find.text('启动页面'), findsOneWidget);
      expect(find.text('内容密度'), findsOneWidget);
      expect(find.text('显示推荐图片'), findsOneWidget);
      expect(find.text('显示互动数据'), findsOneWidget);
      expect(find.text('重复点击首页时刷新'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('home-reselect-refresh-setting')),
      );
      await tester.pump();
      expect(session.refreshHomeOnReselect, isFalse);
      await tester.tap(find.byKey(const ValueKey('home-feed-order-setting')));
      await tester.pumpAndSettle();

      expect(find.text('首页分区排序'), findsWidgets);
      expect(find.byIcon(Icons.drag_handle_rounded), findsNWidgets(4));
      expect(find.text('保存排序'), findsOneWidget);

      await tester.drag(
        find.byIcon(Icons.drag_handle_rounded).last,
        const Offset(0, -190),
      );
      await tester.pumpAndSettle();
      final storyTop = tester.getTopLeft(find.text('故事').last).dy;
      final hotTop = tester.getTopLeft(find.text('热榜').last).dy;
      expect(storyTop, lessThan(hotTop));
      await tester.tap(find.text('保存排序'));
      await tester.pumpAndSettle();
      expect(session.homeFeedOrder, [
        HomeFeedChannel.following,
        HomeFeedChannel.story,
        HomeFeedChannel.recommend,
        HomeFeedChannel.hot,
      ]);
    },
  );

  testWidgets('signed-in my page renders real profile fields and tabs', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accountUid = 'member-id';
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response(
          '/people/self',
          json: const {
            'id': 'member-id',
            'url_token': 'member-token',
            'name': '测试用户',
            'headline': '个人简介',
            'gender': 0,
            'voteup_count': 18000,
            'follower_count': 8,
            'following_count': 11,
            'answer_count': 2,
            'articles_count': 3,
            'pins_count': 4,
            'locations': [
              {'name': '河南'},
            ],
          },
        ),
        _response(
          '/people/member-id/profile',
          json: const {'cover_url': '', 'description': '完整资料'},
        ),
        _response(
          '/people/member-id/profile/detail',
          json: const {'zhi_age': '6 个月 12 天'},
        ),
      ]);
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(MyPage(api: api, session: session)));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('account-profile-home')), findsOneWidget);
    expect(find.text('测试用户'), findsNWidgets(2));
    expect(find.text('1.8万'), findsOneWidget);
    expect(find.text('被关注'), findsOneWidget);
    expect(find.text('关注'), findsWidgets);
    expect(find.text('灵感'), findsOneWidget);
    expect(find.text('创作'), findsOneWidget);
    expect(find.text('动态'), findsOneWidget);
    expect(find.text('赞同'), findsOneWidget);
    expect(find.text('河南'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-tabs-surface')), findsOneWidget);
    expect(
      tester.widget<SliverAppBar>(find.byType(SliverAppBar)).expandedHeight,
      338,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('profile-tabs-surface'))).height,
      52,
    );
    final profileTabs = tester.widget<TabBar>(find.byType(TabBar));
    expect(profileTabs.dividerColor, Colors.transparent);
    expect(transport.calls.map((call) => call.uri.path), [
      '/people/self',
      '/people/member-id/profile',
      '/people/member-id/profile/detail',
    ]);

    transport.responses.add(
      _response(
        '/moments/member-id/origin',
        json: const {
          'data': <Object>[],
          'paging': {'is_end': true},
        },
      ),
    );
    await tester.tap(find.text('创作'));
    await tester.pumpAndSettle();

    expect(find.text('全部'), findsOneWidget);
    expect(find.text('回答 2'), findsOneWidget);
    expect(find.text('想法 4'), findsOneWidget);
    expect(find.text('文章 3'), findsOneWidget);
    expect(transport.calls.last.uri.toString(), contains('/origin?limit=20'));

    for (var index = 0; index < 3; index++) {
      await tester.drag(
        find.byKey(const ValueKey('profile-creation-categories')),
        const Offset(-260, 0),
      );
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('profile-creation-more')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('profile-creation-more-list')),
      findsOneWidget,
    );
    expect(find.text('我的收藏'), findsOneWidget);
    expect(find.text('我的划线'), findsOneWidget);
    expect(find.text('订阅的专栏'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('profile-creation-more-list')),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();
    expect(find.text('关注的话题'), findsOneWidget);
    expect(find.text('关注的收藏夹'), findsOneWidget);
    expect(find.text('关注的问题'), findsOneWidget);
  });

  testWidgets('other user profile aligns header actions and server tabs', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accountUid = 'self-id';
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response(
          '/people/target-id/profile',
          json: const {
            'id': 'target-id',
            'url_token': 'target-token',
            'name': '目标用户',
            'headline': '公开签名',
            'description': '公开个人简介',
            'cover_url': '',
            'voteup_count': 12000,
            'follower_count': 32,
            'following_count': 5,
            'is_following': false,
            'is_followed': true,
            'answer_count': 8,
            'articles_count': 2,
            'locations': [
              {'name': '上海'},
            ],
          },
        ),
        _response(
          '/people/target-id/profile/tab',
          json: const {
            'tabs_v3': [
              {
                'name': '动态',
                'number': 3,
                'url': '/moments/target-id/activities?limit=20',
              },
            ],
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
      _testApp(UserProfileDetailPage(api: api, memberId: 'target-id')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('user-profile-home')), findsOneWidget);
    expect(find.text('目标用户'), findsWidgets);
    expect(find.text('1.2万'), findsWidgets);
    expect(find.text('关注了你'), findsOneWidget);
    expect(find.byKey(const ValueKey('user-profile-follow')), findsOneWidget);
    expect(find.byKey(const ValueKey('user-profile-message')), findsOneWidget);
    expect(find.text('主页'), findsOneWidget);
    expect(find.text('动态'), findsOneWidget);
    expect(
      tester.widget<SliverAppBar>(find.byType(SliverAppBar)).expandedHeight,
      368,
    );
    final tabsSurface = find.byKey(const ValueKey('user-profile-tabs-surface'));
    expect(tester.getSize(tabsSurface).height, 52);
    final tabsDecoration = tester.widget<DecoratedBox>(tabsSurface).decoration;
    expect(
      (tabsDecoration as BoxDecoration).borderRadius,
      const BorderRadius.vertical(top: Radius.circular(24)),
    );
    expect(transport.calls.map((call) => call.uri.path), [
      '/people/target-id/profile',
      '/people/target-id/profile/tab',
    ]);

    transport.responses.add(
      _response(
        '/messages',
        json: const {
          'data': <Object>[],
          'paging': {'is_end': true},
        },
      ),
    );
    await tester.tap(find.byKey(const ValueKey('user-profile-message')));
    await tester.pumpAndSettle();

    expect(find.byType(MessageConversationPage), findsOneWidget);
    expect(find.byKey(const ValueKey('message-composer')), findsOneWidget);
  });

  testWidgets('my page retains rejected account session for confirmation', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer rejected-token'
      ..refreshToken = 'rejected-refresh-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accountUid = 'member-id';
    session.authenticationLoggingEnabled = false;
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response(
          '/people/self',
          statusCode: 401,
          json: const {
            'error': {'code': 101, 'message': 'account signed out'},
          },
        ),
        _response(
          MobileLoginContract.signInPath,
          statusCode: 400,
          json: const {
            'error': {'code': 100008, 'message': 'refresh token invalid'},
          },
        ),
      ]);
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
      mobileLoginBodyEncoder: MobileLoginBodyEncoder(
        cipher: _LengthMatchingLoginCipher(),
      ),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(MyPage(api: api, session: session)));
    await tester.pumpAndSettle();

    expect(find.byType(NativeLoginPage), findsNothing);
    expect(find.byKey(const ValueKey('embedded-native-login')), findsNothing);
    expect(find.text('个人资料加载失败'), findsOneWidget);
    expect(session.hasAccountSession, isTrue);
    expect(session.hasPendingAccountCleanup, isTrue);
  });

  testWidgets('my page retains account for unclassified 401 response', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer retained-token'
      ..refreshToken = 'retained-refresh-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accountUid = 'member-id';
    final transport = _RecordingTransport()
      ..responses.add(
        _response(
          '/people/self',
          statusCode: 401,
          json: const {
            'error': {'code': 999999, 'message': 'unclassified rejection'},
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

    await tester.pumpWidget(_testApp(MyPage(api: api, session: session)));
    await tester.pumpAndSettle();

    expect(find.byType(NativeLoginPage), findsNothing);
    expect(find.text('个人资料加载失败'), findsOneWidget);
    expect(session.hasAccountSession, isTrue);
  });

  test('optional shelf rejection cannot erase a verified account', () async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer verified-token'
      ..refreshToken = 'verified-refresh-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accountUid = 'member-id';
    final transport = _RecordingTransport()
      ..responses.add(
        _response(
          '/pluton/shelves',
          statusCode: 401,
          json: const {
            'error': {'code': 101, 'message': 'route requires another scope'},
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

    final response = await api.get('/pluton/shelves');

    expect(response.statusCode, 401);
    expect(session.hasAccountSession, isTrue);
    expect(session.authorization, 'Bearer verified-token');
  });

  test(
    'local browsing history deduplicates and keeps the newest visit',
    () async {
      final session = SessionStore();
      var generalSessionChanges = 0;
      var browsingHistoryChanges = 0;
      session.addListener(() => generalSessionChanges++);
      session.browsingHistoryChanges.addListener(
        () => browsingHistoryChanges++,
      );
      await session.rememberBrowsing(
        type: 'answer',
        id: '42',
        title: '第一次标题',
        excerpt: '第一次摘要',
      );
      await session.rememberBrowsing(
        type: 'answer',
        id: '42',
        title: '更新后的标题',
        author: '作者',
      );
      expect(session.browsingHistory, hasLength(1));
      expect(session.browsingHistory.single.title, '更新后的标题');
      expect(session.browsingHistory.single.author, '作者');
      await session.removeBrowsingHistory('answer:42');
      expect(session.browsingHistory, isEmpty);
      expect(browsingHistoryChanges, 3);
      expect(generalSessionChanges, 0, reason: '浏览记录更新不应该重建与它无关的页面');
    },
  );

  testWidgets('browsing history renders semantic rows and supports deletion', (
    tester,
  ) async {
    final session = SessionStore()
      ..browsingHistory = [
        BrowsingHistoryEntry(
          type: 'answer',
          id: '42',
          title: '浏览过的回答',
          excerpt: '只保存用于列表展示的简短摘要',
          author: '测试作者',
          visitedAt: DateTime.now(),
          questionId: '7',
          questionTitle: '所属问题',
        ),
      ];
    final api = ZhihuApiClient(session);
    addTearDown(api.close);
    await tester.pumpWidget(
      _testApp(BrowsingHistoryPage(api: api, session: session)),
    );

    expect(find.text('浏览过的回答'), findsOneWidget);
    expect(find.textContaining('测试作者 · 回答'), findsOneWidget);
    await tester.fling(
      find.byKey(const ValueKey('history-answer:42')),
      const Offset(-700, 0),
      1400,
    );
    await tester.pumpAndSettle();
    expect(session.browsingHistory, isEmpty);
    expect(find.text('还没有浏览记录'), findsOneWidget);
  });

  testWidgets('home menu button and edge swipe open the functional drawer', (
    tester,
  ) async {
    final session = SessionStore();
    final scaffoldKey = GlobalKey<ScaffoldState>();
    var hotTopicsSelected = false;
    var settingsSelected = false;
    final transport = _RecordingTransport();
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
    );
    addTearDown(api.close);
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          key: scaffoldKey,
          drawerEnableOpenDragGesture: true,
          drawerEdgeDragWidth: 30,
          drawer: ZhAppDrawer(
            session: session,
            selectedNavigationIndex: 0,
            onColumns: _noop,
            onTopicCategories: _noop,
            onHotTopics: () {
              hotTopicsSelected = true;
              scaffoldKey.currentState?.closeDrawer();
            },
            onHistory: _noop,
            onNotifications: _noop,
            onCollections: _noop,
            onBookshelf: _noop,
            onUsers: _noop,
            onSettings: () {
              settingsSelected = true;
              scaffoldKey.currentState?.closeDrawer();
            },
          ),
          body: FeedPage(
            api: api,
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byKey(const ValueKey('home-drawer-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(scaffoldKey.currentState?.isDrawerOpen, isTrue);
    expect(find.byKey(const ValueKey('app-side-drawer')), findsOneWidget);
    expect(find.text('历史记录'), findsOneWidget);
    expect(find.text('专栏推荐'), findsOneWidget);
    expect(find.text('话题分类'), findsOneWidget);
    expect(find.text('热门话题'), findsOneWidget);
    expect(find.text('消息'), findsOneWidget);
    expect(find.text('收藏'), findsOneWidget);
    expect(find.textContaining('移动 API 会话'), findsNothing);
    expect(find.textContaining('移动会话'), findsNothing);
    expect(find.textContaining('匿名访客会话'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('drawer-hot-topics')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(hotTopicsSelected, isTrue);
    expect(find.byKey(const ValueKey('app-side-drawer')), findsNothing);

    await tester.dragFrom(const Offset(1, 240), const Offset(330, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('app-side-drawer')), findsOneWidget);
    final drawerList = find.descendant(
      of: find.byKey(const ValueKey('app-side-drawer')),
      matching: find.byType(ListView),
    );
    await tester.drag(drawerList, const Offset(0, -220));
    await tester.pumpAndSettle();
    expect(find.text('查找用户'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('drawer-settings')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(settingsSelected, isTrue);
  });

  test('bundled contract contains all reviewed Flutter roles', () async {
    final contract = await ApiContract.load();
    expect(contract.endpoints, hasLength(42));
    expect(contract['home-following-feed'].path, '/moments_v3');
    expect(contract['home-hot-list'].path, '/topstory/hot-lists/total');
    expect(contract['search-initial'].path, '/search_v3');
    expect(
      contract['question-answer-feeds'].path,
      contains('/questions/{question_id}/feeds'),
    );
    expect(contract['column-articles'].origin, 'runtime-discovered');
    expect(contract['column-detail'].path, '/columns/{column_token}');
    expect(contract['column-detail'].origin, 'runtime-discovered');
    expect(
      contract['topic-essence-feeds'].path,
      '/topics/{topic_id}/essence_feeds',
    );
    expect(
      contract['comment-list-headers'].path,
      '/comment_v5/{object_type}/{object_id}/list-headers',
    );
  });

  test('notification routes match official 11.4.0 contracts', () {
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);

    expect(
      api.notificationsMessageInitialUri().toString(),
      'https://api.zhihu.com/notifications/v3/message/v3'
      '?limit=30&invite_style_ab=1',
    );
    expect(api.notificationsUnreadUri().path, '/notifications/v3/count/v3');
    expect(
      api.notificationEntryInitialUri('comment').toString(),
      'https://api.zhihu.com/notifications/v3/timeline/entry/comment'
      '?limit=20&adr_com=5',
    );
    expect(
      api.notificationEntryInitialUri('invite').toString(),
      'https://api.zhihu.com/notifications/v3/timeline/entry/invite'
      '?invite_with_time_slice=1&limit=20',
    );
    expect(
      api.messagesInitialUri('member-id').toString(),
      'https://api.zhihu.com/messages?limit=20&sender_id=member-id',
    );
    expect(
      () => api.notificationEntryInitialUri('../people/self'),
      throwsA(isA<ApiTransportException>()),
    );
  });

  test('notification parsing preserves rows and official header order', () {
    final payload = <String, dynamic>{
      'head': [
        {
          'id': 'entry_invite',
          'noti_subtype': 'entry_invite',
          'unread_count': 8,
          'content': {'title': '邀请回答'},
        },
        {
          'id': 'entry_like',
          'noti_subtype': 'entry_like',
          'content': {'title': '赞同与喜欢'},
        },
        {
          'id': 'entry_comment',
          'noti_subtype': 'entry_comment',
          'content': {'title': '评论转发@'},
        },
      ],
      'data': [
        {
          'id': 'message-1',
          'noti_type': 'message',
          'content': {
            'title': '知乎小管家',
            'text': '<b>消息正文</b>',
            'target_link': 'https://www.zhihu.com/inbox/member-id?title=test',
          },
        },
      ],
    };

    expect(notificationRows(payload), hasLength(1));
    expect(notificationText(notificationRows(payload).single), '消息正文');
    expect(
      notificationMessageSenderId(notificationRows(payload).single),
      'member-id',
    );
    expect(
      notificationEntryNameOf(notificationInviteEntry(payload)!),
      'invite',
    );
    final entries = notificationHeaderEntries(payload);
    expect(entries.map(notificationEntryNameOf), [
      'comment',
      'like',
      'favorite',
      'follow',
    ]);
    expect(notificationTitle(entries[2]), '收藏了我');
  });

  testWidgets('notification page renders server data and fallback category', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accountUid = 'self-id';
    final transport = _RecordingTransport()
      ..responses.add(
        _response(
          '/notifications/v3/message/v3',
          json: const {
            'head': [
              {
                'id': 'entry_invite',
                'noti_subtype': 'entry_invite',
                'unread_count': 3,
                'content': {'title': '邀请回答'},
              },
              {
                'id': 'entry_comment',
                'noti_subtype': 'entry_comment',
                'content': {'title': '评论转发@'},
              },
              {
                'id': 'entry_like',
                'noti_subtype': 'entry_like',
                'content': {'title': '赞同与喜欢'},
              },
              {
                'id': 'entry_follow',
                'noti_subtype': 'entry_follow',
                'content': {'title': '关注'},
              },
            ],
            'data': [
              {
                'id': 'entry_system',
                'noti_subtype': 'entry_system',
                'content': {'title': '系统消息', 'text': '协议修订通知'},
              },
            ],
            'paging': {'is_end': true},
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

    await tester.pumpWidget(_testApp(NotificationsPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notifications-list')), findsOneWidget);
    expect(find.text('评论转发@'), findsOneWidget);
    expect(find.text('赞同与喜欢'), findsOneWidget);
    expect(find.text('收藏了我'), findsOneWidget);
    expect(find.text('关注'), findsOneWidget);
    expect(find.text('邀请回答'), findsOneWidget);
    expect(find.text('系统消息'), findsOneWidget);
    expect(find.text('协议修订通知'), findsOneWidget);
  });

  test('row extraction and object unwrapping handle feed payloads', () {
    final rows = extractRows({
      'data': [
        {
          'target': {
            'type': 'answer',
            'id': 42,
            'question': {'title': '示例问题'},
          },
        },
      ],
      'paging': {'is_end': true},
    });
    expect(rows, hasLength(1));
    expect(typeOf(rows.single), 'answer');
    expect(idOf(rows.single), '42');
    expect(titleOf(rows.single), '示例问题');
  });

  test('creation aggregate notification normalizes to its article', () {
    final row = <String, dynamic>{
      'id': '1',
      'type': 'AGGREGATE_NOTIFICATION',
      'noti_subtype': 'publish',
      'created': 1700000000,
      'head': {
        'author': {
          'id': 'member-id',
          'url_token': 'author-token',
          'name': '作者',
        },
      },
      'content': {
        'title': '文章标题',
        'abstract_text': '文章摘要',
        'target_link': 'zhihu://articles/987654321',
        'url_token': '1',
      },
      'target_source': {
        'object_id': '987654321',
        'target_link': 'zhihu://articles/987654321',
      },
    };

    final article = unwrapObject(row);
    expect(typeOf(row), 'article');
    expect(idOf(row), '987654321');
    expect(titleOf(row), '文章标题');
    expect(subtitleOf(row), '文章摘要');
    expect(authorNameOf(row), '作者');
    expect(article['url'], 'zhihu://articles/987654321');
    expect(article['created_time'], 1700000000);
  });

  test('user child routes resolve member id separately from url token', () {
    final profile = <String, dynamic>{
      'id': 'internal-member-hash',
      'url_token': 'public-profile-token',
    };
    expect(
      userMemberIdOfProfile(profile, 'input-token'),
      'internal-member-hash',
    );
    expect(
      userUrlTokenOfProfile(profile, 'input-token'),
      'public-profile-token',
    );
    expect(userMemberIdOfProfile(const {}, ' input-token '), 'input-token');
    expect(userUrlTokenOfProfile(const {}, ' input-token '), 'input-token');
  });
}
