part of '../core_test.dart';

void registerNegativeFeedbackTests() {
  const fixture = <String, dynamic>{
    'data': {
      'style': 'bottom_sheet',
      'items': [
        {
          'raw_button': {
            'text': {'panel_text': '不喜欢该内容', 'toast_text': '将减少推荐'},
            'action': {'intent_url': 'zhihu://uninterest_feed'},
          },
        },
        {
          'raw_button': {
            'text': {'panel_text': '不再推荐作者：云狐'},
            'action': {
              'backend_url': '/negative-feedback/author',
              'method': 'POST',
            },
          },
        },
        {
          'raw_button': {
            'text': {'panel_text': '设置屏蔽关键词'},
            'right_icon': {'name': 'arrow_right'},
            'action': {'intent_url': 'zhihu://block_keywords?scene=recommend'},
          },
        },
        {
          'raw_button': {
            'text': {'panel_text': '太多重复或相似内容'},
            'action': {
              'backend_url': 'https://api.zhihu.com/negative-feedback/repeat',
              'method': 'PUT',
              'param': {'reason': 'repeat'},
            },
          },
        },
        {
          'raw_button': {
            'text': {'panel_text': '内容极端或引战'},
            'action': {
              'backend_url': '/negative-feedback/extreme',
              'method': 'DELETE',
            },
          },
        },
        {
          'alternative_button': {
            'current_button': {
              'text': {'panel_text': '内容质量差'},
              'action': {
                'backend_url': '/negative-feedback/quality',
                'method': 'GET',
              },
            },
          },
        },
        {
          'raw_button': {
            'text': {'panel_text': '举报'},
            'right_icon': {'name': 'arrow_right'},
            'action': {'intent_url': 'https://www.zhihu.com/report?id=42'},
          },
        },
      ],
    },
  };

  test('negative feedback identity matches official Answer panel query', () {
    final source = <String, dynamic>{
      'type': 'ComponentCard',
      'extra': {
        'content_type': 'answer',
        'content_id': '2064413623645165148',
        'business_ext_map': {
          'passthrough_info': {
            'author': {'name': '云狐'},
          },
        },
      },
      'brief': '{"type":"answer","id":2064413623645165148}',
    };
    final identity = NegativeFeedbackIdentity.fromFeed(source);
    expect(identity.sceneCode, 'recommend');
    expect(identity.contentType, 'Answer');
    expect(identity.contentToken, '2064413623645165148');
    expect(identity.authorName, '云狐');
    expect(identity.itemBrief, '{"type":"answer","id":2064413623645165148}');
    expect(identity.isUsable, isTrue);
  });

  test('negative feedback parser preserves server order and action fields', () {
    final menu = NegativeFeedbackMenu.fromJson(fixture);
    expect(menu.items.map((item) => item.label), [
      '不喜欢该内容',
      '不再推荐作者：云狐',
      '设置屏蔽关键词',
      '太多重复或相似内容',
      '内容极端或引战',
      '内容质量差',
      '举报',
    ]);
    expect(menu.items.first.action.isUninterest, isTrue);
    expect(menu.items.first.isRawButton, isTrue);
    expect(menu.items[5].isRawButton, isFalse);
    expect(menu.items[2].action.isBlockKeywords, isTrue);
    expect(menu.items[3].action.method, 'PUT');
    expect(menu.items[3].action.parameters, {'reason': 'repeat'});
    expect(menu.items.last.action.isReport, isTrue);
  });

  test(
    'negative feedback panel and generic action use official routes',
    () async {
      final transport = _RecordingTransport();
      final session = _MemorySessionStore()
        ..authorization = 'Bearer account-token'
        ..udid = '0123456789abcdef0123456789abcdef'
        ..sessionKind = 'imported';
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      const identity = NegativeFeedbackIdentity(
        sceneCode: 'recommend',
        contentType: 'Answer',
        contentToken: '42',
        authorName: '作者',
        itemBrief: '{"type":"answer","id":42}',
      );
      await api.getNegativeFeedbackPanel(identity);
      expect(transport.calls.single.method, 'GET');
      expect(transport.calls.single.uri.path, '/negative-feedback/panel');
      expect(transport.calls.single.uri.queryParameters, {
        'scene_code': 'recommend',
        'content_type': 'Answer',
        'content_token': '42',
      });

      await api.executeNegativeFeedbackAction(
        const NegativeFeedbackAction(
          backendUrl: '/negative-feedback/reason',
          method: 'PUT',
          parameters: {'reason': 'duplicate'},
        ),
      );
      expect(transport.calls.last.method, 'PUT');
      expect(transport.calls.last.uri.path, '/negative-feedback/reason');
      expect(utf8.decode(transport.calls.last.body!), 'reason=duplicate');

      await api.uninterestFeed(identity);
      expect(transport.calls.last.method, 'POST');
      expect(transport.calls.last.uri.path, '/topstory/uninterestv2');
      expect(transport.calls.last.headers['x-api-version'], '3.1.8');
      expect(
        utf8.decode(transport.calls.last.body!),
        'item_brief=%7B%22type%22%3A%22answer%22%2C%22id%22%3A42%7D',
      );
    },
  );

  test('negative feedback rejects external backend and unknown method', () {
    final api = ZhihuApiClient(
      _MemorySessionStore(),
      transport: _RecordingTransport(),
    );
    expect(
      () => api.executeNegativeFeedbackAction(
        const NegativeFeedbackAction(
          backendUrl: 'https://example.com/delete',
          method: 'DELETE',
        ),
      ),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => api.executeNegativeFeedbackAction(
        const NegativeFeedbackAction(
          backendUrl: '/negative-feedback/reason',
          method: 'PATCH',
        ),
      ),
      throwsA(isA<ApiTransportException>()),
    );
  });

  test(
    'feed block keyword contract preserves content identity and limits',
    () async {
      final transport = _RecordingTransport();
      final session = _MemorySessionStore()
        ..authorization = 'Bearer account-token'
        ..udid = '0123456789abcdef0123456789abcdef'
        ..sessionKind = 'imported';
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      const identity = NegativeFeedbackIdentity(
        sceneCode: 'recommend',
        contentType: 'Answer',
        contentToken: '42',
        authorName: '作者',
      );
      await api.addBlockedKeyword(identity: identity, keyword: '剧透');
      expect(transport.calls.single.method, 'POST');
      expect(transport.calls.single.uri.path, '/feed-root/block');
      expect(
        utf8.decode(transport.calls.single.body!),
        'scene_code=recommend&keyword=%E5%89%A7%E9%80%8F&content_token=42&content_type=Answer',
      );
      final deleteUri = api.deleteBlockedKeywordUri('剧透');
      expect(deleteUri.path, '/feed-root/block');
      expect(deleteUri.queryParameters, {
        'scene_code': 'recommend',
        'keyword': '剧透',
      });
      final config = BlockKeywordsConfig.fromJson(const {
        'is_vip': true,
        'data': ['剧透'],
        'kw_min_length': 2,
        'kw_max_length': 15,
        'kw_max_count': 10,
      });
      expect(config.keywords, ['剧透']);
      expect(config.isVip, isTrue);
      expect(config.maxCount, 10);
    },
  );

  testWidgets(
    'negative feedback sheet renders server labels without fallback',
    (tester) async {
      final transport = _RecordingTransport()
        ..responses.add(_response('/negative-feedback/panel', json: fixture));
      final session = _MemorySessionStore()
        ..authorization = 'Bearer account-token'
        ..udid = '0123456789abcdef0123456789abcdef'
        ..sessionKind = 'imported';
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: NegativeFeedbackSheet(
              api: api,
              identity: const NegativeFeedbackIdentity(
                sceneCode: 'recommend',
                contentType: 'Answer',
                contentToken: '42',
                authorName: '云狐',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('不喜欢该内容'), findsOneWidget);
      expect(find.text('不再推荐作者：云狐'), findsOneWidget);
      expect(find.text('举报'), findsOneWidget);
    },
  );

  testWidgets('negative feedback sheet reuses a preloaded panel request', (
    tester,
  ) async {
    final transport = _RecordingTransport()
      ..responses.add(_response('/negative-feedback/panel', json: fixture));
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = '0123456789abcdef0123456789abcdef'
      ..sessionKind = 'imported';
    final api = ZhihuApiClient(
      session,
      transport: transport,
      cloudIdSigner: _StaticCloudIdSigner(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    const identity = NegativeFeedbackIdentity(
      sceneCode: 'recommend',
      contentType: 'Answer',
      contentToken: '42',
      authorName: '云狐',
    );
    final preloaded = api.getNegativeFeedbackPanel(identity);
    await preloaded;
    expect(transport.calls, hasLength(1));

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: NegativeFeedbackSheet(
            api: api,
            identity: identity,
            initialResponse: preloaded,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('不喜欢该内容'), findsOneWidget);
    expect(transport.calls, hasLength(1));
  });

  testWidgets(
    'long press shows usable feedback before held panel response appends options',
    (tester) async {
      final heldResponse = Completer<ApiResponse>();
      var loaderCalls = 0;
      final session = _MemorySessionStore()
        ..authorization = 'Bearer account-token'
        ..udid = '0123456789abcdef0123456789abcdef'
        ..sessionKind = 'imported';
      final api = ZhihuApiClient(
        session,
        transport: _RecordingTransport(),
        cloudIdSigner: _StaticCloudIdSigner(),
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      const identity = NegativeFeedbackIdentity(
        sceneCode: 'recommend',
        contentType: 'Answer',
        contentToken: '42',
        authorName: '云狐',
        itemBrief: '{"type":"answer","id":42}',
      );

      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (context) => Scaffold(
              body: ObjectCard(
                value: const {
                  'type': 'answer',
                  'id': '42',
                  'question': {'title': '慢请求回答'},
                  'author': {'name': '云狐'},
                },
                feedMode: true,
                onLongPress: () {
                  unawaited(
                    showNegativeFeedbackSheet(
                      context: context,
                      api: api,
                      identity: identity,
                      initialResponseLoader: () {
                        loaderCalls += 1;
                        return heldResponse.future;
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('慢请求回答'));
      await tester.pump();

      final sheet = find.byKey(const Key('negative-feedback-sheet'));
      expect(sheet, findsOneWidget);
      expect(loaderCalls, 1);
      expect(heldResponse.isCompleted, isFalse);
      expect(find.text('减少此类内容'), findsOneWidget);
      expect(find.text('不喜欢该内容'), findsOneWidget);
      final immediateItem = tester.widget<ListTile>(
        find.byKey(const Key('negative-feedback-item-0-不喜欢该内容')),
      );
      expect(immediateItem.onTap, isNotNull);
      expect(
        find.byKey(const Key('negative-feedback-loading')),
        findsOneWidget,
      );
      expect(find.text('不再推荐作者：云狐'), findsNothing);
      final pendingSize = tester.getSize(sheet);

      heldResponse.complete(
        _response('/negative-feedback/panel', json: fixture),
      );
      await tester.pumpAndSettle();

      expect(find.text('不喜欢该内容'), findsOneWidget);
      expect(find.text('不再推荐作者：云狐'), findsOneWidget);
      expect(find.text('举报'), findsOneWidget);
      expect(find.byKey(const Key('negative-feedback-loading')), findsNothing);
      expect(tester.getSize(sheet), pendingSize);
    },
  );

  testWidgets('account feed bounds visible feedback panel preloads', (
    tester,
  ) async {
    final transport = _NegativeFeedbackPrefetchTransport(fixture);
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = '0123456789abcdef0123456789abcdef'
      ..sessionKind = 'imported';
    final api = ZhihuApiClient(
      session,
      transport: transport,
      cloudIdSigner: _StaticCloudIdSigner(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(FeedPage(api: api)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(transport.panelRequests, hasLength(6));
    transport.completePanels();
    await tester.pumpAndSettle();

    await tester.longPress(find.text('并发预取回答一'));
    await tester.pumpAndSettle();
    expect(find.text('不喜欢该内容'), findsOneWidget);
    expect(transport.panelRequests, hasLength(6));
  });

  testWidgets('feed answer exposes a long-press feedback trigger', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: ObjectCard(
            value: const {
              'type': 'answer',
              'id': '42',
              'question': {'title': '可长按的回答'},
              'author': {'name': '作者'},
            },
            feedMode: true,
            onLongPress: () => presses += 1,
          ),
        ),
      ),
    );
    await tester.longPress(find.text('可长按的回答'));
    expect(presses, 1);
  });
}

class _NegativeFeedbackPrefetchTransport extends ApiTransport {
  _NegativeFeedbackPrefetchTransport(this.panelJson);

  final Object panelJson;
  final List<Completer<ApiResponse>> panelRequests = [];

  void completePanels() {
    for (final request in panelRequests) {
      if (request.isCompleted) continue;
      request.complete(_response('/negative-feedback/panel', json: panelJson));
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
    if (uri.path == '/negative-feedback/panel') {
      final request = Completer<ApiResponse>();
      panelRequests.add(request);
      return request.future;
    }
    if (uri.path == '/topstory/recommend') {
      return Future.value(
        ApiResponse(
          uri: uri,
          statusCode: 200,
          bodyBytes: 0,
          json: {
            'data': [
              for (var index = 0; index < 9; index++)
                {
                  'target': {
                    'type': 'answer',
                    'id': '${41 + index}',
                    'question': {
                      'title': index == 0 ? '并发预取回答一' : '预取回答 $index',
                    },
                    'author': {'name': '作者 $index'},
                  },
                },
            ],
            'paging': {'is_end': true},
          },
          headers: const {},
        ),
      );
    }
    return Future.value(
      ApiResponse(
        uri: uri,
        statusCode: 200,
        bodyBytes: 0,
        json: const {
          'data': <Object>[],
          'paging': {'is_end': true},
        },
        headers: const {},
      ),
    );
  }
}
