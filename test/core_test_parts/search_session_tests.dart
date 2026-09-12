part of '../core_test.dart';

void registerSearchSessionTests() {
  testWidgets('modern UI theme is light, monochrome, and shad-backed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: Center(
            child: ApiErrorView(error: 'offline', onRetry: _noop),
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(Scaffold));
    final material = Theme.of(context);
    final shad = ShadTheme.of(context);
    expect(material.brightness, Brightness.light);
    expect(material.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
    expect(material.colorScheme.primary, const Color(0xFF111111));
    expect(shad.colorScheme.primary, const Color(0xFF111111));
    expect(shad.radius.topLeft.x, 14);
    expect(material.navigationBarTheme.height, 62);
    expect(material.navigationBarTheme.iconTheme?.resolve({})?.size, 20);
    expect(
      material.navigationBarTheme.iconTheme?.resolve({
        WidgetState.selected,
      })?.size,
      21,
    );
  });

  testWidgets(
    'network challenge exposes the original manual verification route',
    (tester) async {
      var verificationTaps = 0;
      final response = ApiResponse(
        uri: Uri.parse('https://api.zhihu.com/topstory/recommend'),
        statusCode: 403,
        bodyBytes: 128,
        json: const {
          'error': {'code': 40352, 'message': '系统监测到您的网络环境存在异常，请完成验证。'},
        },
        headers: const {},
      );

      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: ApiErrorView(
              error: ApiFailure.forAnonymousRead(response),
              onRetry: _noop,
              onOpenNetworkVerification: () => verificationTaps += 1,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('open-network-verification')),
        findsOneWidget,
      );
      expect(find.text('打开知乎验证'), findsOneWidget);
      expect(
        zhihuSafetyVerificationUrl,
        'https://www.zhihu.com/account/unhuman?type=unhuman',
      );
      expect(isAllowedOfficialNavigation(zhihuSafetyVerificationUrl), isTrue);

      await tester.tap(find.byKey(const Key('open-network-verification')));
      await tester.pump();
      expect(verificationTaps, 1);
    },
  );

  testWidgets('search page aligns official tabs and hides direct ID tools', (
    tester,
  ) async {
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);
    await tester.pumpWidget(_testApp(SearchPage(api: api)));

    expect(find.text('搜索知乎内容'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('综合'), findsOneWidget);
    expect(find.text('实时'), findsOneWidget);
    expect(find.text('用户'), findsOneWidget);
    expect(find.text('小说'), findsOneWidget);
    expect(find.text('输入内容 ID'), findsNothing);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).resizeToAvoidBottomInset,
      isFalse,
    );

    await tester.tap(find.byTooltip('通过 ID 直接打开'));
    await tester.pumpAndSettle();
    expect(find.byType(ShadInput), findsNWidgets(3));
    expect(find.text('输入内容 ID'), findsOneWidget);
    expect(find.text('回答、文章、想法或视频'), findsOneWidget);
  });

  testWidgets('search scope choices grow with large accessibility text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2),
          ),
          child: SearchPage(api: api),
        ),
      ),
    );
    await tester.pump();

    final label = find.text('综合');
    final target = find.ancestor(of: label, matching: find.byType(InkWell));
    final targetRect = tester.getRect(target);
    final labelRect = tester.getRect(label);
    expect(targetRect.height, greaterThanOrEqualTo(48));
    expect(labelRect.top, greaterThanOrEqualTo(targetRect.top));
    expect(labelRect.bottom, lessThanOrEqualTo(targetRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('search results offer keyword suggestions in the top field', (
    tester,
  ) async {
    final transport = _SearchSuggestionTransport();
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(SearchResultsPage(api: api, initialQuery: 'Flutter')),
    );
    await tester.pumpAndSettle();

    final input = find.byKey(const ValueKey('search-input'));
    await tester.enterText(input, 'Flu');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('search-suggestion-panel')),
      findsOneWidget,
    );
    expect(find.text('Flutter 4.1'), findsOneWidget);
    expect(
      transport.calls.where(
        (call) => call.uri.path == '/api/v4/search/suggest',
      ),
      hasLength(1),
    );

    // A longer query can reuse the already returned ordered list when it is
    // still a real prefix of those items. This keeps IME input responsive and
    // avoids one request per keystroke.
    await tester.enterText(input, 'Flutt');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Flutter 4.1'), findsOneWidget);
    expect(
      transport.calls.where(
        (call) => call.uri.path == '/api/v4/search/suggest',
      ),
      hasLength(1),
    );

    await tester.tap(
      find.byKey(const ValueKey('search-suggestion:Flutter 4.1')),
    );
    await tester.pumpAndSettle();

    expect(
      transport.calls
          .where((call) => call.uri.path == '/search_v3')
          .map((call) => call.uri.queryParameters['q']),
      contains('Flutter 4.1'),
    );
  });

  testWidgets(
    'search page rebuilds history and dismisses suggestions with focus',
    (tester) async {
      final transport = _SearchSuggestionTransport();
      final api = ZhihuApiClient(
        SessionStore(),
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);

      await tester.pumpWidget(_testApp(SearchPage(api: api)));
      await tester.pumpAndSettle();
      expect(find.text('历史搜索'), findsOneWidget);
      expect(find.text('热搜'), findsOneWidget);
      expect(find.text('Flutter 热门话题'), findsOneWidget);

      final input = find.byKey(const ValueKey('search-input'));
      await tester.tap(input);
      await tester.showKeyboard(input);
      expect(tester.widget<TextField>(input).focusNode!.hasFocus, isTrue);
      await tester.enterText(input, 'Flu');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('历史搜索'), findsNothing);
      expect(
        find.byKey(const ValueKey('search-suggestion-panel')),
        findsOneWidget,
      );

      tester.widget<TextField>(input).focusNode!.unfocus();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('search-suggestion-panel')),
        findsNothing,
      );

      await tester.enterText(input, '');
      await tester.pump();
      expect(find.text('历史搜索'), findsOneWidget);
    },
  );

  test('search hot items accept current and reference payload shapes', () {
    final current = parseSearchHotItems({
      'top_search': {
        'words': [
          {
            'query': 'DeepSeek',
            'display_query': 'DeepSeek 热点',
            'heat_score': 12000,
            'hot_show': '12 万热度',
          },
          {'query': 'deepseek'},
        ],
      },
    });
    expect(current, hasLength(1));
    expect(current.single.displayQuery, 'DeepSeek 热点');
    expect(current.single.heatScore, 12000);
    expect(current.single.hotShow, '12 万热度');

    final reference = parseSearchHotItems({
      'hot_search_queries': [
        {'query': 'Flutter', 'hot_show': '9999'},
      ],
    });
    expect(reference.single.query, 'Flutter');
  });

  test('official search tabs preserve APK database request types', () {
    expect({
      for (final tab in officialSearchTabs) tab.label: tab.type,
    }, containsPair('综合', 'general'));
    expect({
      for (final tab in officialSearchTabs) tab.label: tab.type,
    }, containsPair('实时', 'recent'));
    expect({
      for (final tab in officialSearchTabs) tab.label: tab.type,
    }, containsPair('小说', 'km_general'));
    expect({
      for (final tab in officialSearchTabs) tab.label: tab.type,
    }, containsPair('知识', 'publication'));
    expect({
      for (final tab in officialSearchTabs) tab.label: tab.type,
    }, containsPair('论文', 'scholar'));
    expect({
      for (final tab in officialSearchTabs) tab.label: tab.type,
    }, containsPair('视频', 'zvideo'));
  });

  test('search date accepts published aliases and omits zero timestamps', () {
    expect(
      contentDateLabel(
        ContentMetrics.from(const {'publish_timestamp': 1704153600}),
      ),
      '发布于 2024-01-02',
    );
    expect(
      contentDateLabel(ContentMetrics.from(const {'created_time': 0})),
      isEmpty,
    );
  });

  testWidgets('recent search uses general real-time wire mode and renders', (
    tester,
  ) async {
    final transport = _RecentSearchTransport();
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        SearchResultsPage(
          api: api,
          initialQuery: 'Flutter',
          initialType: 'recent',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('实时搜索结果'), findsOneWidget);
    final call = transport.calls.firstWhere(
      (entry) =>
          entry.uri.path == '/search_v3' &&
          entry.uri.queryParameters['is_real_time'] == '1',
    );
    expect(call.uri.queryParameters['t'], 'general');
    expect(call.headers['x-api-version'], '3.0.91');
    expect(call.headers['x-search-id'], matches(RegExp(r'^[0-9a-f]{32}$')));
  });

  testWidgets(
    'publication search skips a filtered empty page and renders market card',
    (tester) async {
      final transport = _PublicationSearchTransport();
      final api = ZhihuApiClient(
        SessionStore(),
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);

      await tester.pumpWidget(
        _testApp(
          SearchResultsPage(
            api: api,
            initialQuery: 'Flutter',
            initialType: 'publication',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter 电子书'), findsOneWidget);
      expect(find.text('书籍作者'), findsOneWidget);
      expect(find.text('普通广告'), findsNothing);
      expect(find.text('没有找到相关内容'), findsNothing);
      final calls = transport.calls
          .where((entry) => entry.uri.path == '/search_v3')
          .toList(growable: false);
      expect(calls, hasLength(2));
      expect(calls.first.uri.queryParameters['t'], 'publication');
      expect(calls.first.uri.queryParameters['is_real_time'], '0');
      expect(calls.map((entry) => entry.uri.queryParameters['offset']), [
        '0',
        '20',
      ]);

      // Page two points to itself. Reaching the end of this short list must
      // not request the same cursor again.
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(
        transport.calls.where((entry) => entry.uri.path == '/search_v3'),
        hasLength(2),
      );
    },
  );

  testWidgets('distant search tab switch skips intermediate requests', (
    tester,
  ) async {
    final transport = _RecentSearchTransport();
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(SearchResultsPage(api: api, initialQuery: 'Flutter')),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).resizeToAvoidBottomInset,
      isFalse,
    );

    await tester.tap(find.text('视频'));
    await tester.pumpAndSettle();

    final requestedTypes = transport.calls
        .where((call) => call.uri.path == '/search_v3')
        .map((call) => call.uri.queryParameters['t'])
        .toList();
    expect(requestedTypes, containsAllInOrder(const ['general', 'zvideo']));
    expect(requestedTypes, isNot(contains('people')));
    expect(requestedTypes, isNot(contains('km_general')));
    expect(requestedTypes, isNot(contains('scholar')));
  });

  test('search filters preserve the public customize contract', () {
    final groups = parseSearchFilterGroups({
      'data': [
        [
          {'group': 'vertical', 'title': '不限类型', 'link_name': ''},
          {'group': 'vertical', 'title': '只看回答', 'link_name': 'answer'},
        ],
        [
          {'group': 'sort', 'title': '综合排序', 'link_name': ''},
          {'group': 'sort', 'title': '最多赞同', 'link_name': 'upvoted_count'},
        ],
        [
          {'group': 'time_interval', 'title': '不限时间', 'link_name': ''},
          {'group': 'time_interval', 'title': '一天内', 'link_name': 'a_day'},
        ],
      ],
    });

    expect(groups, hasLength(3));
    expect(groups[0][1].linkName, 'answer');
    expect(groups[1][1].linkName, 'upvoted_count');
    expect(groups[2][1].linkName, 'a_day');
  });

  test(
    'search content card keeps title excerpt statistics and answer route',
    () {
      final card = <String, dynamic>{
        'type': 'search_content_card',
        'resource': 'question',
        'title': {
          'name': '<em>Flutter</em> 是什么？',
          'url': 'https://www.zhihu.com/question/123',
        },
        'content': {
          'excerpt': '这是回答摘要',
          'url': 'https://www.zhihu.com/question/123/answer/456',
        },
        'statistics': [
          {'count': 12, 'description': '回答'},
          {'count': 34, 'description': '关注'},
        ],
      };

      expect(typeOf(card), 'answer');
      expect(idOf(card), '456');
      expect(titleOf(card), 'Flutter 是什么？');
      expect(subtitleOf(card), '这是回答摘要');
      expect(searchStatisticsOf(card), [('回答', 12), ('关注', 34)]);
    },
  );

  test('search rows unwrap content groups and omit advertisements', () {
    final rows = extractSearchRows({
      'data': [
        {'type': 'hot_timing', 'id': 'internal'},
        {'type': 'knowledge_result'},
        {'type': 'knowledge_ad'},
        {
          'type': 'knowledge_result',
          'highlight': {'title': '<em>盐选</em>故事结果'},
          'object': {
            'type': 'answer',
            'id': '88',
            'excerpt': '故事摘要',
            'author': {'name': '作者甲'},
            'is_story': true,
          },
        },
        {
          'type': 'knowledge_result',
          'object': {
            'type': 'hot_timing',
            'icon_title': '近期内容',
            'has_more': true,
            'content_items': [
              {
                'sub_contents': [
                  {
                    'object': {
                      'type': 'answer',
                      'id': '99',
                      'question': {'name': '近期回答问题'},
                    },
                  },
                ],
              },
            ],
          },
        },
        {
          'type': 'relevant_query',
          'id': 'opaque',
          'display_query': 'Flutter 桌面开发',
          'real_query': 'flutter desktop',
        },
        {'type': 'answer', 'id': '42', 'title': '正常搜索结果'},
      ],
    });

    expect(rows.map(typeOf), [
      'answer',
      'hot_timing',
      'relevant_query',
      'answer',
    ]);
    expect(titleOf(rows.first), '盐选故事结果');
    expect(contentKindLabelOf(rows.first), '盐选故事');
    expect(searchHotTimingTitleOf(rows[1]), '近期内容');
    expect(searchHotTimingHasMore(rows[1]), isTrue);
    expect(searchHotTimingItemsOf(rows[1]), hasLength(1));
    expect(titleOf(searchHotTimingItemsOf(rows[1]).single), '近期回答问题');
    expect(searchQueryOf(rows[2]), 'Flutter 桌面开发');
    expect(contentKindLabelOf(rows[2]), '相关搜索');
    expect(titleOf(rows.last), '正常搜索结果');
  });

  test('search repairs sibling question stubs and omits orphan identities', () {
    final rows = extractSearchRows({
      'data': [
        {
          'type': 'knowledge_result',
          'object': {'type': 'question', 'id': '660855482'},
        },
        {
          'type': 'knowledge_result',
          'object': {
            'type': 'answer',
            'id': '88',
            'question': {
              'type': 'question',
              'id': '660855482',
              'title': '什么才是真正的爱情？',
            },
            'excerpt': '回答摘要',
          },
        },
        {
          'type': 'knowledge_result',
          'object': {'type': 'question', 'id': '673318003'},
        },
        {
          'type': 'knowledge_result',
          'object': {'type': 'question', 'id': '101', 'title': 'question #101'},
        },
        {'type': 'question'},
        {'id': '909'},
        {'type': 'education', 'id': 'transport-only'},
        {'type': 'opaque_boundary', 'id': 'opaque-only'},
        {'type': 'future_result', 'id': 'future-visible', 'title': '未来类型的有效结果'},
      ],
    });

    expect(rows, hasLength(4));
    expect(typeOf(rows.first), 'question');
    expect(titleOf(rows.first), '什么才是真正的爱情？');
    expect(typeOf(rows[1]), 'answer');
    expect(titleOf(rows[2]), 'question #101');
    expect(titleOf(rows.last), '未来类型的有效结果');
    expect(
      rows.map(titleOf),
      isNot(contains(anyOf('question #660855482', 'question #673318003'))),
    );
    expect(
      rows.map(typeOf),
      isNot(contains(anyOf('education', 'opaque_boundary'))),
    );
  });

  testWidgets('search list never renders a bare question identity card', (
    tester,
  ) async {
    final api = ZhihuApiClient(
      SessionStore(),
      transport: _IncompleteQuestionSearchTransport(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(SearchResultsPage(api: api, initialQuery: 'love')),
    );
    await tester.pumpAndSettle();

    expect(find.text('question #660855482'), findsNothing);
    expect(find.text('question #673318003'), findsNothing);
    expect(find.text('什么才是真正的爱情？'), findsNWidgets(2));
    expect(find.text('回答摘要'), findsOneWidget);
    const imageUrl = 'https://picx.zhimg.com/search-answer.jpg';
    final frame = find.byKey(
      const ValueKey('content-preview-frame-single-$imageUrl'),
    );
    expect(frame, findsOneWidget);
    expect(tester.getSize(frame).height, SingleContentCardImage.previewHeight);
    expect(
      tester
          .widget<Image>(
            find.byKey(const ValueKey('content-preview-image-$imageUrl')),
          )
          .fit,
      BoxFit.cover,
    );
  });

  test('novel tab converts paid-column cards but still omits normal ads', () {
    const payload = {
      'data': [
        {
          'type': 'knowledge_ad',
          'object': {
            'commodity_id': '456',
            'commodity_type': 'paid_column_chapter',
            'sku_id': '123',
            'url': 'https://www.zhihu.com/market/paid_column/123/section/456',
            'body': {
              'title': '小说章节标题',
              'description': '小说章节摘要',
              'authors': [
                {'name': '小说作者'},
              ],
              'images': ['https://picx.zhimg.com/novel.jpg'],
              'publish_at': 1704153600,
            },
          },
        },
        {
          'type': 'knowledge_ad',
          'object': {
            'commodity_type': 'display_ad',
            'body': {'title': '普通广告'},
          },
        },
      ],
    };

    expect(extractSearchRows(payload), isEmpty);
    final rows = extractSearchRows(payload, includeNovelMarketCards: true);
    expect(rows, hasLength(1));
    expect(typeOf(rows.single), 'publication');
    expect(titleOf(rows.single), '小说章节标题');
    expect(subtitleOf(rows.single), '小说章节摘要');
    expect(authorNameOf(rows.single), '小说作者');
    expect(contentKindLabelOf(rows.single), '盐选故事');
    expect(contentImageUrlsOf(rows.single), [
      'https://picx.zhimg.com/novel.jpg',
    ]);
    expect(parseSaltStoryNavigation(rows.single)?.sectionId, '456');
  });

  test(
    'search sections retain official entity groups and omit section ads',
    () {
      final rows = extractSearchRows({
        'data': [
          {
            'type': 'search_section',
            'section_type': 'people',
            'has_more': true,
            'data_list': [
              {
                'highlight': {'title': '<em>海绵</em>小裤衩'},
                'object': {
                  'type': 'people',
                  'id': 'member-1',
                  'name': '原始名称',
                  'headline': '小说作者',
                },
              },
              {
                'type': 'knowledge_ad',
                'object': {'type': 'people', 'id': 'advertiser'},
              },
            ],
          },
          {
            'type': 'search_advert',
            'object': {'type': 'answer', 'id': 'ad-answer'},
          },
        ],
      });

      expect(rows, hasLength(1));
      expect(isSearchSectionRow(rows.single), isTrue);
      expect(searchSectionTitleOf(rows.single), '相关用户');
      expect(searchSectionTargetTypeOf(rows.single), 'people');
      expect(searchSectionHasMore(rows.single), isTrue);
      final items = searchSectionItemsOf(rows.single);
      expect(items, hasLength(1));
      expect(titleOf(items.single), '海绵小裤衩');
      expect(typeOf(items.single), 'people');
    },
  );

  test('ring search unwraps ring_box entities and drops empty containers', () {
    final rows = extractSearchRows({
      'data': [
        {
          'type': 'ring_box',
          'data': {
            'rings': [
              {
                'object': {
                  'type': 'ring_info',
                  'ring_info': {
                    'ring_id': '1871220585780101120',
                    'ring_name': '<em>前端</em>工程师那点事',
                    'ring_desc': '讨论前端开发与工程实践',
                    'avatar': {'url': 'https://picx.zhimg.com/ring.png'},
                    'action_url': 'zhihu://ring/host/1871220585780101120',
                    'member_count': 1200,
                    'post_count': 86,
                  },
                },
              },
            ],
          },
        },
        {
          'type': 'knowledge_result',
          'object': {
            'type': 'ring_box',
            'items': [
              {
                'target': {
                  'id': '2001009660925334090',
                  'name': '独立开发者',
                  'description': '交流产品与技术',
                  'url': 'https://www.zhihu.com/ring/host/2001009660925334090',
                },
              },
            ],
          },
        },
        {
          'type': 'ring_box',
          'title': 'ring_box',
          'data': {'items': <Object>[]},
        },
      ],
    });

    expect(rows, hasLength(2));
    expect(rows.map(typeOf), everyElement('ring'));
    expect(titleOf(rows.first), '前端工程师那点事');
    expect(subtitleOf(rows.first), '讨论前端开发与工程实践');
    expect(
      unwrapObject(rows.first)['avatar_url'],
      'https://picx.zhimg.com/ring.png',
    );
    expect(
      unwrapObject(rows.first)['url'],
      'https://www.zhihu.com/ring/host/1871220585780101120',
    );
    expect(titleOf(rows.last), '独立开发者');
    expect(rows.map(titleOf), isNot(contains('ring_box')));
  });

  test('HTML plain text removes script and tags', () {
    expect(plainText('<p>你好 <b>世界</b></p><script>bad()</script>'), '你好 世界');
  });

  test('structured v2 answer segments become readable paragraphs', () {
    expect(
      structuredContentText({
        'structured_content': {
          'segments': [
            {
              'paragraph': {'text': '第一段'},
            },
            {
              'paragraph': {'text': '<b>第二段</b>'},
            },
          ],
        },
      }),
      '第一段\n\n第二段',
    );
  });

  test('purchased answer prefers unlocked VIP structured body and media', () {
    final answer = <String, dynamic>{
      'paid_info': {'has_purchased': true},
      'structured_content': {
        'segments': [
          {
            'paragraph': {'text': '免费试读'},
          },
          {
            'card': {'card_type': 'kvip-paid-answer-tail-truncate'},
          },
        ],
      },
      'structured_content_vip': jsonEncode({
        'segments': [
          {
            'heading': {'text': '会员正文'},
          },
          {
            'paragraph': {'text': '这是已解锁的完整内容。'},
          },
          {
            'image': {'url': 'https://pic.example.com/vip-body.jpg'},
          },
        ],
      }),
    };

    expect(structuredContentText(answer), '会员正文\n\n这是已解锁的完整内容。');
    expect(hasUnlockedVipStructuredContent(answer), isTrue);
    expect(isPaidStructuredContent(answer), isTrue);
    expect(isPaidStructuredContentLocked(answer), isFalse);
    expect(
      contentImageUrlsOf(answer),
      contains('https://pic.example.com/vip-body.jpg'),
    );

    final incompletePurchasedResponse = <String, dynamic>{
      'paid_info': {'has_purchased': true},
      'structured_content': {
        'segments': [
          {
            'paragraph': {'text': '仍然只有试读'},
          },
        ],
      },
    };
    expect(
      hasUnlockedVipStructuredContent(incompletePurchasedResponse),
      isFalse,
    );
    expect(isPaidStructuredContentLocked(incompletePurchasedResponse), isTrue);
  });

  test('answer detail query mirrors original single-content contract', () {
    expect(
      contentDetailRequestParameters({
        'utm_id': 'feed-card-7',
        'object': {
          'dynamic_title_info': '{"style":"compact"}',
          'bizEncodedParams': 'encoded-business-context',
          'unrelated': 'must-not-be-forwarded',
        },
      }),
      {
        'single_content': '1',
        'utm_id': 'feed-card-7',
        'dynamic_title_info': '{"style":"compact"}',
        'bizEncodedParams': 'encoded-business-context',
      },
    );
  });

  test('JSON shape summary exposes types but not scalar values', () {
    final summary = jsonShapeSummary({
      'data': {'content': 'secret'},
      'enabled': true,
      'items': [1, 2],
    });
    expect(summary, contains('data:object{content}'));
    expect(summary, contains('items:list(2)'));
    expect(summary, isNot(contains('secret')));
  });

  test('extra headers are strict and forbid transport overrides', () {
    expect(SessionStore.parseExtraHeaders('{"X-PAGE-ID":"abc"}'), {
      'X-PAGE-ID': 'abc',
    });
    expect(
      () => SessionStore.parseExtraHeaders('{"Host":"evil"}'),
      throwsFormatException,
    );
    expect(
      () => SessionStore.parseExtraHeaders('{"X-Test":"a\\nb"}'),
      throwsFormatException,
    );
    expect(
      () => SessionStore.parseExtraHeaders('{"X-Zse-96":"unsafe"}'),
      throwsFormatException,
    );
    expect(
      () => SessionStore.parseExtraHeaders('{"X-MS-ID":"unsafe"}'),
      throwsFormatException,
    );
    expect(
      () => SessionStore.parseExtraHeaders('{"x-zSe-93":"stale"}'),
      throwsFormatException,
    );
  });

  test('mobile login contract matches APK form fields and HMAC preimage', () {
    expect(
      MobileLoginContract.clientId,
      CloudIdSigner.oauthAuthorization.substring(6),
    );
    expect(MobileLoginContract.apiVersion, '3.0.93');
    expect(MobileLoginContract.encryptVersion, '101_1_1.0');
    expect(MobileLoginContract.encryptVersion, XZseSigner.encryptVersion);
    expect(
      MobileLoginContract.observedRequestHeaderNames,
      isNot(contains('x-zse-96')),
    );
    expect(
      MobileLoginContract.buildRequestDigitsFields(
        username: '+86 138-0013-8000',
        clientId: 'client',
      ),
      {'username': '+8613800138000', 'sms_type': 'text', 'client_id': 'client'},
    );
    final fields = MobileLoginContract.buildSignInFields(
      grant: MobileLoginGrant.digits,
      username: '+8613800138000',
      credential: '123456',
      clientId: 'client',
      clientSecret: 'secret',
      epochSeconds: 1700000000,
    );
    expect(fields.keys.toSet(), {
      ...MobileLoginContract.signInBaseFields,
      'username',
      'digits',
    });
    expect(fields['grant_type'], 'digits');
    expect(fields['source'], 'com.zhihu.android');
    expect(fields['signature'], hasLength(40));
    expect(
      fields['signature'],
      Hmac(sha1, utf8.encode('secret'))
          .convert(utf8.encode('digitsclientcom.zhihu.android1700000000'))
          .toString(),
    );
  });

  test('mobile login contract rejects malformed account inputs', () {
    expect(
      () => MobileLoginContract.normalizeUsername('../account'),
      throwsFormatException,
    );
    expect(
      () => MobileLoginContract.normalizeDigits('12ab'),
      throwsFormatException,
    );
    expect(
      () => MobileLoginContract.normalizeDigits('12345'),
      throwsFormatException,
    );
    expect(
      () => MobileLoginContract.buildRequestDigitsFields(
        username: '+8613800138000',
        clientId: 'client',
        smsType: 'email',
      ),
      throwsFormatException,
    );
  });

  test(
    'mobile login wire encoder replaces the entire form with LAES Base64',
    () async {
      final cipher = _LengthMatchingLoginCipher();
      final encoder = MobileLoginBodyEncoder(cipher: cipher);
      final digitsFields = MobileLoginContract.buildRequestDigitsFields(
        username: '+8613800138000',
        clientId: MobileLoginContract.clientId,
      );
      expect(
        MobileLoginBodyEncoder.formEncode(digitsFields),
        'username=%2B8613800138000&sms_type=text&client_id='
        '${MobileLoginContract.clientId}',
      );
      final wireBody = await encoder.encode(digitsFields);
      expect(cipher.lastPlaintextBytes, 80);
      expect(wireBody, hasLength(108));
      expect(ascii.decode(wireBody), isNot(contains('username')));
    },
  );

  test(
    'mobile login client sends captcha then X-Zse-93-only encrypted form',
    () async {
      final session = SessionStore()
        ..authorization = 'Bearer guest-token'
        ..udid = 'guest-udid'
        ..cookie = 'z_c0=guest-cookie'
        ..sessionKind = 'guest';
      final transport = _RecordingTransport()
        ..responses.addAll([
          _response(
            '/captcha',
            json: const {
              'show_captcha': false,
              'cookie': 'captcha_session=test-cookie',
            },
            headers: const {
              'set-cookie':
                  'captcha_aux=test; Path=/\n'
                  'captcha_second=two; Expires=Wed, 21 Oct 2037 07:28:00 GMT',
            },
          ),
          _response(
            MobileLoginContract.requestDigitsPath,
            json: const {'success': true},
          ),
        ]);
      final client = ZhihuApiClient(
        session,
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
        cloudIdSigner: _StaticCloudIdSigner(),
        mobileLoginBodyEncoder: MobileLoginBodyEncoder(
          cipher: _LengthMatchingLoginCipher(),
        ),
      );
      addTearDown(client.close);

      final result = await client.requestLoginDigits(
        username: '+8613800138000',
      );

      expect(result.sent, isTrue);
      expect(transport.calls.map((call) => call.uri.path), [
        '/captcha',
        MobileLoginContract.requestDigitsPath,
      ]);
      final post = transport.calls.last;
      expect(post.method, 'POST');
      expect(post.body, hasLength(108));
      expect(post.headers['X-Zse-93'], '101_1_1.0');
      expect(
        post.headers.keys.where((key) => key.toLowerCase() == 'x-zse-93'),
        hasLength(1),
      );
      expect(post.headers, isNot(contains('X-Zse-96')));
      expect(post.headers['content-type'], 'application/x-www-form-urlencoded');
      expect(post.headers['Cookie'], contains('captcha_session=test-cookie'));
      expect(post.headers['Cookie'], contains('captcha_aux=test'));
      expect(post.headers['Cookie'], contains('captcha_second=two'));
      expect(post.headers['x-b3-traceid'], matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(post.headers['x-client-ri'], matches(RegExp(r'^\d{10}$')));
    },
  );

  test(
    'digit sign-in uses 320-byte encrypted wire body and preserves guest on error',
    () async {
      final session = SessionStore()
        ..authorization = 'Bearer guest-token'
        ..udid = 'guest-udid'
        ..sessionKind = 'guest';
      final transport = _RecordingTransport()
        ..responses.add(
          _response(
            MobileLoginContract.signInPath,
            statusCode: 400,
            json: const {
              'error': {
                'code': 100085,
                'name': 'ERR_INCORRECT_DIGITS_CNT',
                'message': 'invalid digits count',
              },
            },
          ),
        );
      final client = ZhihuApiClient(
        session,
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
        cloudIdSigner: _StaticCloudIdSigner(),
        mobileLoginBodyEncoder: MobileLoginBodyEncoder(
          cipher: _LengthMatchingLoginCipher(),
        ),
      );
      addTearDown(client.close);

      final result = await client.signInWithDigits(
        username: '+8613800138000',
        digits: '123456',
        now: DateTime.fromMillisecondsSinceEpoch(1787157080000),
      );

      expect(result.signedIn, isFalse);
      expect(result.errorCode, '100085');
      expect(result.errorName, 'ERR_INCORRECT_DIGITS_CNT');
      expect(transport.calls.single.body, hasLength(320));
      expect(transport.calls.single.headers, isNot(contains('X-Zse-96')));
      expect(session.hasGuestSession, isTrue);
    },
  );

  test(
    'successful digit sign-in validates people self and preserves unlock metadata',
    () async {
      final session = _MemorySessionStore()
        ..authorization = 'Bearer guest-token'
        ..udid = 'guest-udid'
        ..sessionKind = 'guest';
      final transport = _RecordingTransport()
        ..responses.addAll([
          _response(
            MobileLoginContract.signInPath,
            json: const {
              'access_token': 'account-access',
              'refresh_token': 'account-refresh',
              'expires_in': 3600,
              'token_type': 'Bearer',
              'cookie': {'z_c0': 'account-cookie'},
              'uid': 'member-id',
              'user_id': 9988,
              'lock_in': 3600,
              'unlock_ticket': 'account-unlock-ticket',
              'verification': null,
            },
          ),
          _response(
            '/people/self',
            json: const {'id': 'member-id', 'uid': 9988, 'name': 'test'},
          ),
        ]);
      final client = ZhihuApiClient(
        session,
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
        cloudIdSigner: _StaticCloudIdSigner(),
        mobileLoginBodyEncoder: MobileLoginBodyEncoder(
          cipher: _LengthMatchingLoginCipher(),
        ),
      );
      addTearDown(client.close);

      final result = await client.signInWithDigits(
        username: '+8613800138000',
        digits: '123456',
        now: DateTime.fromMillisecondsSinceEpoch(1787157080000),
      );

      expect(result.signedIn, isTrue);
      expect(result.requiresVerification, isFalse);
      expect(transport.calls.map((call) => call.uri.path), [
        MobileLoginContract.signInPath,
        '/people/self',
      ]);
      expect(
        transport.calls.last.headers['Authorization'],
        'Bearer account-access',
      );
      expect(session.hasAccountSession, isTrue);
      expect(session.authorization, 'Bearer account-access');
      expect(session.refreshToken, 'account-refresh');
      expect(session.cookie, 'z_c0=account-cookie');
      expect(session.savedExpiresIn, const Duration(seconds: 3600));
      expect(session.accountUid, 'member-id');
      expect(session.accountUserId, '9988');
      expect(session.accountUnlockTicket, 'account-unlock-ticket');
      expect(session.accountLockInSeconds, 3600);
    },
  );

  test(
    'digit sign-in rejects token when people self identity mismatches',
    () async {
      final session = _MemorySessionStore()
        ..authorization = 'Bearer guest-token'
        ..udid = 'guest-udid'
        ..sessionKind = 'guest';
      final transport = _RecordingTransport()
        ..responses.addAll([
          _response(
            MobileLoginContract.signInPath,
            json: const {
              'access_token': 'account-access',
              'refresh_token': 'account-refresh',
              'expires_in': 3600,
              'token_type': 'Bearer',
              'uid': 'expected-member',
              'user_id': 9988,
            },
          ),
          _response(
            '/people/self',
            json: const {'id': 'different-member', 'uid': 9988},
          ),
        ]);
      final client = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
        mobileLoginBodyEncoder: MobileLoginBodyEncoder(
          cipher: _LengthMatchingLoginCipher(),
        ),
      );
      addTearDown(client.close);

      final result = await client.signInWithDigits(
        username: '+8613800138000',
        digits: '123456',
      );

      expect(result.signedIn, isFalse);
      expect(result.message, contains('身份不一致'));
      expect(session.hasGuestSession, isTrue);
    },
  );

  test(
    'due account token refresh preserves headers and Set-Cookie z_c0',
    () async {
      final session = _MemorySessionStore()
        ..authorization = 'Bearer old-access'
        ..refreshToken = 'old-refresh'
        ..udid = 'account-udid'
        ..sessionKind = 'account'
        ..accessTokenExpiry = DateTime.now().toUtc().add(
          const Duration(hours: 1),
        )
        ..accessTokenRefreshAt = DateTime.now().toUtc().subtract(
          const Duration(seconds: 1),
        );
      final transport = _RecordingTransport()
        ..responses.addAll([
          _response(
            MobileLoginContract.signInPath,
            json: const {
              'access_token': 'new-access',
              'refresh_token': 'new-refresh',
              'expires_in': 3600,
              'token_type': 'Bearer',
            },
            headers: const {
              'set-cookie': 'z_c0=account-cookie-from-header; Path=/; HttpOnly',
            },
          ),
          _response('/guest/self'),
        ]);
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
        mobileLoginBodyEncoder: MobileLoginBodyEncoder(
          cipher: _LengthMatchingLoginCipher(),
        ),
      );
      addTearDown(api.close);

      final response = await api.get('/guest/self');

      expect(response.isSuccess, isTrue);
      expect(transport.calls.map((call) => call.uri.path), [
        MobileLoginContract.signInPath,
        '/guest/self',
      ]);
      expect(session.authorization, 'Bearer new-access');
      expect(session.refreshToken, 'new-refresh');
      expect(session.cookie, 'z_c0=account-cookie-from-header');
      expect(
        transport.calls.last.headers['Authorization'],
        'Bearer new-access',
      );
      expect(
        transport.calls.last.headers['Cookie'],
        'z_c0=account-cookie-from-header',
      );
      expect(session.accessTokenRefreshAt, isNotNull);
      expect(session.shouldRefreshAccountToken, isFalse);
    },
  );

  test('logout supersedes an in-flight due account refresh', () async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer old-access'
      ..refreshToken = 'old-refresh'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accessTokenExpiry = DateTime.now().toUtc().add(const Duration(hours: 1))
      ..accessTokenRefreshAt = DateTime.now().toUtc().subtract(
        const Duration(seconds: 1),
      );
    final transport = _HoldingAccountRefreshTransport();
    final api = ZhihuApiClient(
      session,
      transport: transport,
      cloudIdSigner: _StaticCloudIdSigner(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      mobileLoginBodyEncoder: MobileLoginBodyEncoder(
        cipher: _LengthMatchingLoginCipher(),
      ),
    );
    addTearDown(api.close);

    final request = api.get('/people/self');
    await transport.refreshStarted.future;
    final revisionBeforeLogout = session.credentialRevision;

    final logout = session.clear();

    expect(session.credentialRevision, greaterThan(revisionBeforeLogout));
    expect(session.authorization, isEmpty);
    transport.completeRefresh();
    await logout;
    final response = await request;

    expect(response.isSuccess, isTrue);
    expect(session.authorization, isEmpty);
    expect(session.refreshToken, isEmpty);
    expect(session.cookie, isEmpty);
    expect(session.sessionKind, isEmpty);
    expect(transport.calls.map((call) => call.uri.path), [
      MobileLoginContract.signInPath,
      '/people/self',
    ]);
    expect(
      transport.calls.last.headers['Authorization'],
      CloudIdSigner.oauthAuthorization,
    );
    expect(
      transport.calls.any(
        (call) => call.headers['Authorization'] == 'Bearer late-access',
      ),
      isFalse,
    );
  });

  test('passive account refresh retries one GET with the new token', () async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer old-access'
      ..refreshToken = 'old-refresh'
      ..udid = 'account-udid'
      ..sessionKind = 'account';
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response(
          '/people/self',
          statusCode: 401,
          json: const {
            'error': {'code': 100, 'message': 'access token expired'},
          },
        ),
        _response(
          MobileLoginContract.signInPath,
          json: const {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
            'expires_in': 3600,
            'token_type': 'Bearer',
          },
        ),
        _response('/people/self', json: const {'id': 'member-id'}),
      ]);
    final api = ZhihuApiClient(
      session,
      transport: transport,
      cloudIdSigner: _StaticCloudIdSigner(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      mobileLoginBodyEncoder: MobileLoginBodyEncoder(
        cipher: _LengthMatchingLoginCipher(),
      ),
    );
    addTearDown(api.close);

    final response = await api.get('/people/self');

    expect(response.isSuccess, isTrue);
    expect(response.jsonMap?['id'], 'member-id');
    expect(transport.calls.map((call) => call.uri.path), [
      '/people/self',
      MobileLoginContract.signInPath,
      '/people/self',
    ]);
    expect(transport.calls.first.headers['Authorization'], 'Bearer old-access');
    expect(transport.calls.last.headers['Authorization'], 'Bearer new-access');
    expect(session.authorization, 'Bearer new-access');
  });

  test('logout supersedes an in-flight passive account refresh', () async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer old-access'
      ..refreshToken = 'old-refresh'
      ..udid = 'account-udid'
      ..sessionKind = 'account';
    final transport = _HoldingAccountRefreshTransport(
      rejectInitialRequest: true,
    );
    final api = ZhihuApiClient(
      session,
      transport: transport,
      cloudIdSigner: _StaticCloudIdSigner(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      mobileLoginBodyEncoder: MobileLoginBodyEncoder(
        cipher: _LengthMatchingLoginCipher(),
      ),
    );
    addTearDown(api.close);

    final request = api.get('/people/self');
    await transport.refreshStarted.future;

    await session.clear();
    transport.completeRefresh();
    final response = await request;

    expect(response.statusCode, 401);
    expect(session.authorization, isEmpty);
    expect(session.refreshToken, isEmpty);
    expect(session.cookie, isEmpty);
    expect(session.sessionKind, isEmpty);
    expect(transport.calls.map((call) => call.uri.path), [
      '/people/self',
      MobileLoginContract.signInPath,
    ]);
    expect(
      transport.calls.any(
        (call) => call.headers['Authorization'] == 'Bearer late-access',
      ),
      isFalse,
    );
  });

  test(
    'terminal refresh failure preserves a newer same-token account',
    () async {
      final session = _MemorySessionStore()
        ..authorization = 'Bearer shared-access'
        ..refreshToken = 'old-refresh'
        ..udid = 'old-udid'
        ..sessionKind = 'account';
      final transport = _HoldingAccountRefreshTransport(
        rejectInitialRequest: true,
      );
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
        mobileLoginBodyEncoder: MobileLoginBodyEncoder(
          cipher: _LengthMatchingLoginCipher(),
        ),
      );
      addTearDown(api.close);

      final request = api.get('/people/self');
      await transport.refreshStarted.future;

      expect(
        await session.saveAccountSession(
          accessToken: 'shared-access',
          refreshToken: 'replacement-refresh',
          udid: 'replacement-udid',
          expiresIn: const Duration(hours: 1),
        ),
        isTrue,
      );
      transport.completeRefresh(rejected: true);
      final response = await request;

      expect(response.statusCode, 401);
      expect(session.authorization, 'Bearer shared-access');
      expect(session.refreshToken, 'replacement-refresh');
      expect(session.udid, 'replacement-udid');
      expect(session.hasAccountSession, isTrue);
      expect(session.clearCalls, 0);
    },
  );

  test('credential persistence serializes save before a later clear', () async {
    final storage = _HoldingSecureStorage();
    final session = SessionStore.withFlutterTestPersistence(storage);

    final saving = session.saveAccountSession(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      udid: 'account-udid',
      expiresIn: const Duration(hours: 1),
      zCookie: 'old-cookie',
      uid: 'old-uid',
    );
    await storage.firstMutationStarted.future;

    final clearing = session.clear();

    expect(session.authorization, isEmpty);
    expect(session.refreshToken, isEmpty);
    expect(session.sessionKind, isEmpty);
    storage.releaseFirstMutation();
    expect(await saving, isTrue);
    await clearing;

    expect(storage.values, isEmpty);
  });

  test(
    'credential replacements synchronously invalidate an older commit',
    () async {
      Future<SessionStore> accountSession() async {
        final session = SessionStore();
        expect(
          await session.saveAccountSession(
            accessToken: 'old-access',
            refreshToken: 'old-refresh',
            udid: 'old-udid',
            expiresIn: const Duration(hours: 1),
          ),
          isTrue,
        );
        return session;
      }

      Future<bool> tryOldCommit(SessionStore session, int revision) =>
          session.saveAccountSession(
            accessToken: 'late-access',
            refreshToken: 'late-refresh',
            udid: 'old-udid',
            expiresIn: const Duration(hours: 1),
            expectedCredentialRevision: revision,
          );

      final imported = await accountSession();
      final beforeImport = imported.credentialRevision;
      final importing = imported.save(
        authorization: 'Bearer imported-access',
        udid: 'imported-udid',
        cookie: '',
        msId: '',
        xZse96: '',
        xZse96Target: '',
        extraHeadersJson: '',
      );
      expect(imported.credentialRevision, greaterThan(beforeImport));
      expect(await tryOldCommit(imported, beforeImport), isFalse);
      await importing;
      expect(imported.sessionKind, 'imported');
      expect(imported.authorization, 'Bearer imported-access');

      final guest = await accountSession();
      final beforeGuest = guest.credentialRevision;
      final savingGuest = guest.saveGuestSession(
        accessToken: 'guest-access',
        udid: 'guest-udid',
      );
      expect(guest.credentialRevision, greaterThan(beforeGuest));
      expect(await tryOldCommit(guest, beforeGuest), isFalse);
      await savingGuest;
      expect(guest.sessionKind, 'guest');
      expect(guest.authorization, 'Bearer guest-access');

      final account = await accountSession();
      final beforeAccount = account.credentialRevision;
      final savingAccount = account.saveAccountSession(
        accessToken: 'replacement-access',
        refreshToken: 'replacement-refresh',
        udid: 'replacement-udid',
        expiresIn: const Duration(hours: 1),
      );
      expect(account.credentialRevision, greaterThan(beforeAccount));
      expect(await tryOldCommit(account, beforeAccount), isFalse);
      expect(await savingAccount, isTrue);
      expect(account.authorization, 'Bearer replacement-access');
      expect(account.refreshToken, 'replacement-refresh');
    },
  );

  test(
    'rejected guest context refreshes credentials without clearing device state',
    () async {
      final session = SessionStore()
        ..authorization = 'Bearer rejected-guest'
        ..udid = 'rejected-udid'
        ..cookie = 'z_c0=rejected-cookie'
        ..msId = 'install-ms-id'
        ..sessionKind = 'guest';
      final transport = _RecordingTransport()
        ..responses.addAll([
          _response(
            '/questions/7',
            statusCode: 403,
            json: const {
              'error': {'code': 40353, 'message': 'guest context rejected'},
            },
          ),
          _response(
            '/api/account/prod/init/new_flow_check',
            json: const {'split_udid_guest_api': false},
          ),
          _response(
            '/api/account/prod/init/udid_guest',
            json: const {'udid': 'replacement-udid'},
          ),
          _response(
            '/api/account/prod/guests/token',
            json: const {
              'access_token': 'replacement-guest',
              'cookie': {'z_c0': 'replacement-cookie'},
            },
          ),
          _response('/guest/self'),
          _response('/questions/7', json: const {'id': 7}),
        ]);
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _CountingCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);

      final response = await api.get('/questions/7');

      expect(response.isSuccess, isTrue);
      expect(response.jsonMap?['id'], 7);
      expect(transport.calls.map((call) => call.uri.path), [
        '/questions/7',
        '/api/account/prod/init/new_flow_check',
        '/api/account/prod/init/udid_guest',
        '/api/account/prod/guests/token',
        '/guest/self',
        '/questions/7',
      ]);
      final initHeaders = transport.calls[1].headers.keys
          .where((name) => name.toLowerCase() == 'user-agent')
          .toList();
      expect(initHeaders, hasLength(1));
      expect(
        transport.calls.first.headers['Authorization'],
        'Bearer rejected-guest',
      );
      expect(
        transport.calls.last.headers['Authorization'],
        'Bearer replacement-guest',
      );
      expect(session.authorization, 'Bearer replacement-guest');
      expect(session.udid, 'replacement-udid');
      expect(session.cookie, 'z_c0=replacement-cookie');
      expect(session.msId, 'install-ms-id');
      expect(session.hasGuestSession, isTrue);
    },
  );

  test('40350 drops the guest channel and retries with OAuth only', () async {
    final session = SessionStore()
      ..authorization = 'Bearer rejected-guest'
      ..udid = 'rejected-udid'
      ..cookie = 'z_c0=rejected-cookie'
      ..msId = 'provider-ms-id'
      ..sessionKind = 'guest';
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response(
          '/topstory/recommend',
          statusCode: 403,
          json: const {
            'error': {'code': 40350, 'message': 'guest channel rejected'},
          },
        ),
        _response('/topstory/recommend', json: const {'data': []}),
      ]);
    final api = ZhihuApiClient(
      session,
      transport: transport,
      cloudIdSigner: _CountingCloudIdSigner(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    final response = await api.getUri(api.recommendationFeedInitialUri());

    expect(response.isSuccess, isTrue);
    expect(transport.calls, hasLength(2));
    expect(
      transport.calls.first.headers['Authorization'],
      'Bearer rejected-guest',
    );
    expect(
      transport.calls.last.headers['Authorization'],
      CloudIdSigner.oauthAuthorization,
    );
    expect(transport.calls.last.headers.containsKey('x-udid'), isFalse);
    expect(session.authorization, isEmpty);
    expect(session.udid, isEmpty);
    expect(session.cookie, isEmpty);
    expect(session.sessionKind, isEmpty);
    expect(session.msId, 'provider-ms-id');
  });

  test('account-only 401 does not rotate a valid anonymous context', () async {
    final session = SessionStore()
      ..authorization = 'Bearer guest-access'
      ..udid = 'guest-udid'
      ..sessionKind = 'guest';
    final transport = _RecordingTransport()
      ..responses.add(
        _response(
          '/people/self/followers',
          statusCode: 401,
          json: const {
            'error': {'code': 101, 'message': 'login required'},
          },
        ),
      );
    final api = ZhihuApiClient(
      session,
      transport: transport,
      cloudIdSigner: _CountingCloudIdSigner(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    final response = await api.get('/people/self/followers');

    expect(response.statusCode, 401);
    expect(transport.calls, hasLength(1));
    expect(session.authorization, 'Bearer guest-access');
    expect(session.udid, 'guest-udid');
    expect(session.hasGuestSession, isTrue);
  });

  test('passive refresh transport response failure clears account', () async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer old-access'
      ..refreshToken = 'old-refresh'
      ..udid = 'account-udid'
      ..sessionKind = 'account';
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response(
          '/people/self',
          statusCode: 401,
          json: const {
            'error': {'code': 100, 'message': 'access token expired'},
          },
        ),
        _response(
          MobileLoginContract.signInPath,
          statusCode: 503,
          json: const {
            'error': {'code': 500, 'message': 'refresh rejected'},
          },
        ),
      ]);
    final api = ZhihuApiClient(
      session,
      transport: transport,
      cloudIdSigner: _StaticCloudIdSigner(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      mobileLoginBodyEncoder: MobileLoginBodyEncoder(
        cipher: _LengthMatchingLoginCipher(),
      ),
    );
    addTearDown(api.close);

    final response = await api.get('/people/self');

    expect(response.statusCode, 401);
    expect(session.hasAccountSession, isFalse);
  });

  test(
    'concurrent passive rejections share refresh and account clear',
    () async {
      final session = _MemorySessionStore()
        ..authorization = 'Bearer old-access'
        ..refreshToken = 'old-refresh'
        ..udid = 'account-udid'
        ..sessionKind = 'account';
      final rejection = const {
        'error': {'code': 100, 'message': 'access token expired'},
      };
      final transport = _RecordingTransport()
        ..responses.addAll([
          _response('/first', statusCode: 401, json: rejection),
          _response('/second', statusCode: 401, json: rejection),
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
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
        mobileLoginBodyEncoder: MobileLoginBodyEncoder(
          cipher: _LengthMatchingLoginCipher(),
        ),
      );
      addTearDown(api.close);

      final responses = await Future.wait([
        api.get('/first'),
        api.get('/second'),
      ]);

      expect(responses.map((response) => response.statusCode), [401, 401]);
      expect(
        transport.calls.where(
          (call) => call.uri.path == MobileLoginContract.signInPath,
        ),
        hasLength(1),
      );
      expect(session.clearCalls, 1);
      expect(session.hasAccountSession, isFalse);
    },
  );

  test('session summary distinguishes guest, imported and account state', () {
    final session = SessionStore();
    expect(session.sessionLabel, '未登录');
    session
      ..authorization = 'Bearer guest'
      ..udid = 'udid'
      ..sessionKind = 'guest';
    expect(session.hasGuestSession, isTrue);
    expect(session.hasAccountSession, isFalse);
    expect(session.sessionLabel, '未登录');
    session.sessionKind = 'account';
    expect(session.hasAccountSession, isTrue);
    expect(session.sessionLabel, '已登录');
    session.accessTokenExpiry = DateTime.now().subtract(
      const Duration(seconds: 1),
    );
    expect(session.isAccessTokenExpired, isTrue);
    expect(session.sessionLabel, '登录已过期');
  });
}

class _IncompleteQuestionSearchTransport extends ApiTransport {
  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async => ApiResponse(
    uri: uri,
    statusCode: 200,
    bodyBytes: 2,
    json: uri.path == '/search_v3'
        ? const {
            'data': [
              {
                'type': 'knowledge_result',
                'object': {'type': 'question', 'id': '660855482'},
              },
              {
                'type': 'knowledge_result',
                'object': {
                  'type': 'answer',
                  'id': '88',
                  'question': {
                    'type': 'question',
                    'id': '660855482',
                    'title': '什么才是真正的爱情？',
                  },
                  'excerpt': '回答摘要',
                  'images': ['https://picx.zhimg.com/search-answer.jpg'],
                },
              },
              {
                'type': 'knowledge_result',
                'object': {'type': 'question', 'id': '673318003'},
              },
            ],
            'paging': {'is_end': true},
          }
        : const {
            'data': <Object>[],
            'paging': {'is_end': true},
          },
    headers: const {},
  );
}

class _SearchSuggestionTransport extends ApiTransport {
  final List<_RecordedCall> calls = [];

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    calls.add(
      _RecordedCall(
        method: method,
        uri: uri,
        headers: Map<String, String>.from(headers),
        body: body == null ? null : List<int>.from(body),
      ),
    );
    if (uri.path == '/api/v4/search/suggest') {
      return ApiResponse(
        uri: uri,
        statusCode: 200,
        bodyBytes: 64,
        json: const {
          'suggest': [
            {'query': 'Flutter 4.1'},
          ],
        },
        headers: const {},
      );
    }
    if (uri.path == '/api/v4/search/hot_search') {
      return ApiResponse(
        uri: uri,
        statusCode: 200,
        bodyBytes: 64,
        json: const {
          'hot_search_queries': [
            {'query': 'Flutter 热门话题', 'hot_show': '1.2 万'},
          ],
        },
        headers: const {},
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

class _PublicationSearchTransport extends ApiTransport {
  final calls = <_RecordedCall>[];

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    calls.add(
      _RecordedCall(
        method: method,
        uri: uri,
        headers: Map<String, String>.from(headers),
        body: body == null ? null : List<int>.from(body),
      ),
    );
    if (uri.path == '/search_v3' && uri.queryParameters['offset'] == '0') {
      return ApiResponse(
        uri: uri,
        statusCode: 200,
        bodyBytes: 128,
        json: const {
          'data': [
            {
              'type': 'knowledge_ad',
              'object': {
                'commodity_type': 'display_ad',
                'body': {'title': '普通广告'},
              },
            },
          ],
          'paging': {
            'is_end': false,
            'next':
                'https://api.zhihu.com/search_v3?q=Flutter&t=publication&offset=20',
          },
        },
        headers: const {},
      );
    }
    if (uri.path == '/search_v3' && uri.queryParameters['offset'] == '20') {
      return ApiResponse(
        uri: uri,
        statusCode: 200,
        bodyBytes: 128,
        json: const {
          'data': [
            {
              'type': 'knowledge_ad',
              'object': {
                'commodity_id': 'book-42',
                'commodity_type': 'ebook',
                'url': 'https://www.zhihu.com/pub/book-42',
                'body': {
                  'title': 'Flutter 电子书',
                  'description': '知识分区搜索结果',
                  'authors': [
                    {'name': '书籍作者'},
                  ],
                },
              },
            },
          ],
          'paging': {
            'is_end': false,
            'next':
                'https://api.zhihu.com/search_v3?q=Flutter&t=publication&offset=20',
          },
        },
        headers: const {},
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
