part of '../core_test.dart';

void registerDetailCommentTests() {
  test('video-answer identity remains an answer, not a standalone zvideo', () {
    expect(
      contentIdentityMatches(
        candidate: const {'type': 'videoanswer', 'id': '771'},
        contentType: 'answer',
        contentId: '771',
      ),
      isTrue,
    );
    expect(
      contentIdentityMatches(
        candidate: const {'type': 'video_answer', 'id': '772'},
        contentType: 'answer',
        contentId: '772',
      ),
      isTrue,
    );
  });

  testWidgets('zvideo result opens the native player detail contract', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-video'
      ..udid = 'video-udid'
      ..sessionKind = 'account';
    final transport = _RecordingTransport()
      ..responses.add(
        _response(
          '/zvideos/8848',
          json: const {
            'type': 'zvideo',
            'id': '8848',
            'title': '完整视频标题',
            'description': '<p>视频简介</p>',
            'play_count': 9876,
            'voteup_count': 54,
            'comment_count': 8,
            'author': {
              'name': '视频作者',
              'url_token': 'video-author',
              'avatar_url': 'https://picx.zhimg.com/author.jpg',
            },
            'video': {
              'video_id': 'lens-video-8848',
              'thumbnail': 'https://picx.zhimg.com/video-8848.jpg',
              'duration': 66,
              'width': 1920,
              'height': 1080,
              'playlist': {
                'hd': {'url': 'https://vdn.vzuu.com/video-8848.mp4'},
              },
            },
          },
        ),
      );
    final api = ZhihuApiClient(session, transport: transport);
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: TextButton(
            onPressed: () => openDetectedObject(
              tester.element(find.byType(TextButton)),
              api,
              const {
                'type': 'zvideo',
                'id': '8848',
                'title': '列表视频标题',
                'video': {
                  'id': 'lens-video-8848',
                  'duration_in_seconds': 66,
                  'thumbnail': {
                    'image_url': 'https://picx.zhimg.com/video-8848.jpg',
                    'width': 1920,
                    'height': 1080,
                  },
                },
              },
            ),
            child: const Text('打开视频'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开视频'));
    await tester.pumpAndSettle();

    expect(find.byType(ZVideoDetailPage), findsOneWidget);
    expect(find.byType(ObjectInspectorPage), findsNothing);
    expect(find.byType(InlineAnswerVideo), findsOneWidget);
    final videoAppBarTitle = tester.widget<Text>(find.text('视频'));
    expect(videoAppBarTitle.style?.color, Colors.white);
    expect(find.text('完整视频标题'), findsOneWidget);
    expect(find.text('视频作者'), findsOneWidget);
    expect(find.text('9876 次播放'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -220));
    await tester.pump();
    expect(find.text('视频简介'), findsOneWidget);
    expect(transport.calls, hasLength(1));
    expect(transport.calls.single.uri.path, '/zvideos/8848');
    expect(
      transport.calls.single.uri.queryParameters['include'],
      'contribute,interactive_plugin,creation_relationship',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('id-less video search result opens its attached playlist', (
    tester,
  ) async {
    final transport = _RecordingTransport();
    final api = ZhihuApiClient(SessionStore(), transport: transport);
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => openDetectedObject(context, api, const {
                'type': 'zvideo',
                'title': {'plain_text': '无外层 ID 的搜索视频'},
                'video_info': {
                  'sub_video_id': 'lens-search-only',
                  'thumbnail': 'https://picx.zhimg.com/search-video.jpg',
                  'playlist': {
                    'hd': {'url': 'https://vdn.vzuu.com/search-video.mp4'},
                  },
                },
              }),
              child: const Text('打开搜索视频'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开搜索视频'));
    await tester.pumpAndSettle();

    expect(find.byType(ZVideoDetailPage), findsOneWidget);
    expect(find.byType(ObjectInspectorPage), findsNothing);
    expect(find.byType(InlineAnswerVideo), findsOneWidget);
    expect(find.text('无外层 ID 的搜索视频'), findsOneWidget);
    expect(transport.calls, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'inline answer video keeps DOM order and stays tap-to-play in tests',
    (tester) async {
      final transport = _RecordingTransport();
      final api = ZhihuApiClient(SessionStore(), transport: transport);
      addTearDown(api.close);
      final videos = contentVideosOf({
        'video_info': {
          'videos': [
            {
              'video_id': 'lens-widget',
              'title': '正文视频',
              'thumbnail': 'https://picx.zhimg.com/video-cover.jpg',
              'duration': 65,
              'playlist': {
                'hd': {'url': 'https://vdn.vzuu.com/video.mp4'},
              },
            },
          ],
        },
      });

      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 360,
                child: InlineRichContent(
                  html:
                      '<p>视频前</p>'
                      '<a class="video-box" data-lens-id="lens-widget" '
                      'data-poster="https://picx.zhimg.com/video-cover.jpg">'
                      '</a><p>视频后</p>'
                      '<img src="https://picx.zhimg.com/body.jpg">',
                  videos: videos,
                  videoApi: api,
                  fallbackImages: const [
                    'https://picx.zhimg.com/video-cover.jpg',
                    'https://picx.zhimg.com/fallback.jpg',
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(InlineAnswerVideo), findsOneWidget);
      expect(find.byType(VideoPlayer), findsNothing);
      expect(find.text('正文视频'), findsOneWidget);
      expect(find.text('1:05'), findsOneWidget);
      final aspect = tester.widget<AspectRatio>(
        find.descendant(
          of: find.byType(InlineAnswerVideo),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(aspect.aspectRatio, closeTo(16 / 9, 0.0001));

      final beforeY = tester.getTopLeft(find.text('视频前')).dy;
      final videoY = tester.getTopLeft(find.byType(InlineAnswerVideo)).dy;
      final afterY = tester.getTopLeft(find.text('视频后')).dy;
      expect(beforeY, lessThan(videoY));
      expect(videoY, lessThan(afterY));

      final networkUrls = tester
          .widgetList<Image>(find.byType(Image, skipOffstage: false))
          .map((image) => _imageProviderUrl(image.image))
          .where((url) => url.isNotEmpty)
          .toList();
      expect(
        find.byKey(const ValueKey('video-poster-lens-widget')),
        findsOneWidget,
      );
      expect(
        networkUrls
            .where((url) => url == 'https://picx.zhimg.com/video-cover.jpg')
            .length,
        1,
        reason: 'rendered network images: $networkUrls',
      );
      expect(networkUrls, contains('https://picx.zhimg.com/body.jpg'));
      expect(networkUrls, contains('https://picx.zhimg.com/fallback.jpg'));
      expect(transport.calls, isEmpty);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == '播放视频：正文视频',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find
            .descendant(
              of: find.byType(InlineAnswerVideo),
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pump();
      expect(find.byType(VideoPlayer), findsNothing);
      expect(transport.calls, isEmpty);
      expect(tester.takeException(), isNull);

      final paidVideos = contentVideosOf({
        'video_info': {
          'videos': [
            {
              'video_id': 'lens-widget',
              'title': '正文视频',
              'thumbnail': 'https://picx.zhimg.com/video-cover.jpg',
              'is_paid': true,
              'is_trial': false,
              'playlist': {
                'hd': {'url': 'https://vdn.vzuu.com/video.mp4'},
              },
            },
          ],
        },
      });
      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 360,
                child: InlineRichContent(
                  html:
                      '<p>视频前</p>'
                      '<a class="video-box" data-lens-id="lens-widget" '
                      'data-poster="https://picx.zhimg.com/video-cover.jpg">'
                      '</a><p>视频后</p>',
                  videos: paidVideos,
                  videoApi: api,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == '播放视频：正文视频',
        ),
        findsOneWidget,
      );
      final paidSurface = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(InlineAnswerVideo),
          matching: find.byType(InkWell),
        ),
      );
      expect(paidSurface.onTap, isNotNull);
      expect(transport.calls, isEmpty);

      final disabledVideos = contentVideosOf({
        'video_info': {
          'videos': [
            {
              'video_id': 'lens-widget',
              'title': '正文视频',
              'thumbnail': 'https://picx.zhimg.com/video-cover.jpg',
              'is_paid': true,
              'is_trial': false,
              'is_disabled_play': true,
              'playlist': {
                'hd': {'url': 'https://vdn.vzuu.com/video.mp4'},
              },
            },
          ],
        },
      });
      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: InlineAnswerVideo(video: disabledVideos.single, api: api),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == '付费视频 · 当前账号无观看权限',
        ),
        findsOneWidget,
      );
      final disabledSurface = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(InlineAnswerVideo),
          matching: find.byType(InkWell),
        ),
      );
      expect(disabledSurface.onTap, isNull);
    },
  );

  testWidgets('answer body images stack full width and open the original', (
    tester,
  ) async {
    const first = 'https://picx.zhimg.com/answer-first.jpg';
    const second = 'https://picx.zhimg.com/answer-second.jpg';
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: InlineRichContent(
                html: '<img src="$first"><img src="$second">',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final firstTile = find.byKey(const ValueKey('answer-image-$first'));
    final secondTile = find.byKey(const ValueKey('answer-image-$second'));
    expect(firstTile, findsOneWidget);
    expect(secondTile, findsOneWidget);
    expect(tester.getSize(firstTile).width, closeTo(360, 0.001));
    expect(
      tester.getTopLeft(firstTile).dy,
      lessThan(tester.getTopLeft(secondTile).dy),
    );

    await tester.tap(firstTile);
    await tester.pump();
    final viewer = find.byType(InteractiveViewer);
    final previewFrame = find.byKey(
      const ValueKey('answer-image-preview-frame-$first'),
    );
    expect(viewer, findsOneWidget);
    expect(previewFrame, findsOneWidget);
    expect(tester.getSize(previewFrame), tester.getSize(viewer));
    expect(tester.widget<InteractiveViewer>(viewer).minScale, 1);
    expect(find.byKey(const Key('answer-image-preview-close')), findsOneWidget);
    await tester.tap(find.byKey(const Key('answer-image-preview-close')));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('answer app bar question opens the full answer list', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          appBar: AppBar(
            toolbarHeight: 64,
            titleSpacing: 0,
            title: AnswerDetailAppBarTitle(
              title: '示例问题',
              questionId: '7',
              metrics: const ContentMetrics(
                answerCount: 1358,
                followerCount: 4537,
              ),
              onTap: () => opened = true,
            ),
          ),
        ),
      ),
    );
    expect(find.text('示例问题'), findsOneWidget);
    expect(find.text('知乎 · 1358 个回答 · 4537 人关注'), findsOneWidget);
    expect(find.text('全部回答'), findsNothing);
    await tester.tap(find.text('示例问题'));
    expect(opened, isTrue);
  });

  testWidgets(
    'comment list prefetches before the bottom without a load button',
    (tester) async {
      final transport = _RecordingTransport()
        ..responses.add(
          _response(
            '/next-comments',
            json: const {
              'data': [
                {
                  'id': 'next',
                  'content': '预取的下一页评论',
                  'author': {'name': '下一页用户'},
                },
              ],
              'paging': {'is_end': true},
            },
          ),
        );
      final api = ZhihuApiClient(
        SessionStore(),
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);
      final initialRows = List.generate(
        10,
        (index) => {
          'id': '$index',
          'content': '评论 $index',
          'author': {'name': '用户 $index'},
        },
      );

      await tester.pumpWidget(
        _testApp(
          PagedListPage(
            title: '评论',
            api: api,
            commentListMode: true,
            loadInitial: () async => _response(
              '/comments',
              json: {
                'data': initialRows,
                'paging': const {
                  'is_end': false,
                  'next': 'https://api.zhihu.com/next-comments',
                },
              },
            ),
            rowBuilder: (_, value, _) =>
                SizedBox(height: 220, child: Text(plainText(value['content']))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(transport.calls, isEmpty);
      expect(find.text('继续加载'), findsNothing);
      await tester.scrollUntilVisible(find.text('评论 7'), 360);
      await tester.pumpAndSettle();

      expect(transport.calls, hasLength(1));
      expect(transport.calls.single.uri.path, '/next-comments');
      expect(find.text('继续加载'), findsNothing);
    },
  );

  testWidgets('question answer list is borderless with horizontal metrics', (
    tester,
  ) async {
    final transport = _RecordingTransport()
      ..responses.add(
        _response(
          '/questions/7/feeds',
          json: const {
            'data': [
              {
                'target': {
                  'type': 'answer',
                  'id': '42',
                  'excerpt': '回答列表中的紧凑摘要。',
                  'voteup_count': 566,
                  'favorite_count': 182,
                  'comment_count': 64,
                  'author': {'name': '回答作者', 'headline': '作者简介'},
                  'question': {
                    'id': '7',
                    'title': '需要紧凑展示的问题',
                    'answer_count': 86,
                  },
                },
              },
            ],
            'paging': {'is_end': true},
          },
        ),
      );
    final api = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(QuestionAnswersPage(api: api, questionId: '7')),
    );
    await tester.pumpAndSettle();

    final answerCall = transport.calls.singleWhere(
      (call) => call.uri.path == '/v4/questions/7/answers',
    );
    expect(answerCall.uri.queryParameters['sort_by'], 'default');
    expect(
      transport.calls.map((call) => call.uri.path),
      contains('/questions/7'),
    );
    expect(find.text('需要紧凑展示的问题'), findsOneWidget);
    expect(find.text('回答作者'), findsOneWidget);
    expect(find.text('回答列表中的紧凑摘要。'), findsOneWidget);
    expect(
      find.byKey(const Key('question-answer-compose-action')),
      findsOneWidget,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).bottomNavigationBar,
      isNull,
    );
    await tester.tap(find.byKey(const Key('question-answer-compose-action')));
    await tester.pump();
    expect(find.text('请先在“我”中登录。'), findsOneWidget);
    final votePosition = tester.getTopLeft(find.text('566'));
    final favoritePosition = tester.getTopLeft(find.text('182'));
    final commentPosition = tester.getTopLeft(find.text('64'));
    expect(votePosition.dy, favoritePosition.dy);
    expect(votePosition.dy, commentPosition.dy);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'question answer list header loads detail text and ordered media',
    (tester) async {
      const questionBody = '近日，这是问题的完整补充正文，用于解释事件背景、条件和问题本身。';
      const questionImage = 'https://picx.zhimg.com/question-body.jpg';
      final transport = _QuestionAnswersHeaderTransport();
      final api = ZhihuApiClient(
        SessionStore(),
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);
      await tester.binding.setSurfaceSize(const Size(430, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _testApp(QuestionAnswersPage(api: api, questionId: '7')),
      );
      await tester.pumpAndSettle();

      expect(
        transport.uris.map((uri) => uri.path).toSet(),
        containsAll(<String>{'/v4/questions/7/answers', '/questions/7'}),
      );
      final answerRequest = transport.uris.singleWhere(
        (uri) => uri.path == '/v4/questions/7/answers',
      );
      expect(answerRequest.queryParameters['sort_by'], 'default');
      final detailText = tester.widget<Text>(find.text(questionBody));
      expect(detailText.maxLines, 3);
      expect(detailText.overflow, TextOverflow.ellipsis);
      expect(find.byKey(const Key('question-header-author')), findsOneWidget);
      expect(find.text('问题发起人'), findsOneWidget);
      expect(find.text('提问者'), findsOneWidget);
      expect(find.byType(InlineAnswerVideo), findsOneWidget);
      expect(
        find.byKey(const ValueKey('question-header-image-$questionImage')),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.byType(InlineAnswerVideo)).dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(
                  const ValueKey('question-header-image-$questionImage'),
                ),
              )
              .dy,
        ),
      );
      expect(
        tester
            .getTopLeft(
              find.byKey(
                const ValueKey('question-header-image-$questionImage'),
              ),
            )
            .dy,
        lessThan(tester.getTopLeft(find.text('回答作者')).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('answer detail bar matches official interaction hierarchy', (
    tester,
  ) async {
    final readOnlyActions = <String>[];
    var commentsOpened = false;
    var jumpedToTop = false;
    var jumpedToBottom = false;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          bottomNavigationBar: DetailEngagementBar(
            metrics: const ContentMetrics(
              voteupCount: 2926,
              favoriteCount: 844,
              commentCount: 172,
            ),
            relationship: const AnswerRelationship(
              voting: 'up',
              isThanked: false,
              isFavorited: true,
              isAuthor: false,
              isFollowingAuthor: false,
            ),
            onComments: () => commentsOpened = true,
            onAction: readOnlyActions.add,
            onJumpToTop: () => jumpedToTop = true,
            onJumpToBottom: () => jumpedToBottom = true,
          ),
        ),
      ),
    );

    expect(find.text('+关注'), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.bySemanticsLabel('更多功能'), findsOneWidget);
    // The package renders the selected lens as a second paint layer. Assert
    // the stable semantic actions instead of counting duplicated visual text.
    expect(find.bySemanticsLabel('赞同 2926'), findsOneWidget);
    expect(find.bySemanticsLabel('反对'), findsOneWidget);
    expect(find.bySemanticsLabel('收藏 844'), findsOneWidget);
    expect(find.bySemanticsLabel('查看 172 条评论'), findsOneWidget);
    expect(find.byIcon(Icons.change_history_outlined), findsAtLeastNWidgets(2));
    expect(
      tester
          .widgetList<RotatedBox>(find.byType(RotatedBox))
          .any((widget) => widget.quarterTurns == 2),
      isTrue,
    );
    expect(tester.takeException(), isNull);

    final voteX = tester.getCenter(find.bySemanticsLabel('赞同 2926')).dx;
    final downvoteX = tester.getCenter(find.bySemanticsLabel('反对')).dx;
    final commentX = tester.getCenter(find.bySemanticsLabel('查看 172 条评论')).dx;
    final favoriteX = tester.getCenter(find.bySemanticsLabel('收藏 844')).dx;
    expect(voteX, lessThan(downvoteX));
    expect(downvoteX, lessThan(commentX));
    expect(commentX, lessThan(favoriteX));

    await tester.tap(find.bySemanticsLabel('赞同 2926'));
    await tester.tap(find.bySemanticsLabel('反对'));
    await tester.tap(find.bySemanticsLabel('查看 172 条评论'));
    await tester.tap(find.bySemanticsLabel('收藏 844'));

    expect(readOnlyActions, ['赞同', '反对', '收藏']);
    expect(commentsOpened, isTrue);
    expect(
      tester
          .widgetList<Icon>(find.byType(Icon))
          .where((icon) => icon.color == const Color(0xFF1677FF)),
      hasLength(greaterThanOrEqualTo(2)),
    );

    await tester.tap(find.bySemanticsLabel('更多功能'));
    await tester.pump();
    expect(find.bySemanticsLabel('收起更多功能'), findsOneWidget);
    expect(find.bySemanticsLabel('查看知乎用户的个人主页'), findsOneWidget);
    expect(find.bySemanticsLabel('关注作者'), findsOneWidget);
    expect(find.bySemanticsLabel('回到帖子顶部'), findsOneWidget);
    expect(find.bySemanticsLabel('跳到帖子底部'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('回到帖子顶部'));
    await tester.tap(find.bySemanticsLabel('跳到帖子底部'));
    expect(jumpedToTop, isTrue);
    expect(jumpedToBottom, isTrue);
    await tester.tap(find.bySemanticsLabel('收起更多功能'));
    await tester.pump();
    expect(find.bySemanticsLabel('更多功能'), findsOneWidget);
    expect(find.bySemanticsLabel('赞同 2926'), findsOneWidget);
  });

  testWidgets('answer author follow control writes and updates in place', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const answer = {
      'type': 'answer',
      'id': '42',
      'content': '<p>回答正文</p>',
      'created_time': 1700000000,
      'author': {
        'name': '可关注作者',
        'url_token': 'author-token',
        'headline': '这是用于验证窄屏作者卡布局的较长简介，内容较多时也应充分利用第二行空间并稳定省略',
        'followers_count': 10,
        'is_following': false,
      },
      'question': {'id': '7', 'title': '关注按钮测试问题'},
    };
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accountUid = 'self-id';
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response('/answers/v2/42', json: answer),
        _response('/v4/answers/42', json: answer),
        _response('/people/author-token/followers'),
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
        ContentDetailPage(
          api: api,
          contentType: 'answer',
          contentId: '42',
          initialValue: answer,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('可关注作者'), findsOneWidget);
    expect(find.bySemanticsLabel('查看可关注作者的个人主页'), findsOneWidget);
    final followFinder = find.bySemanticsLabel('关注作者');
    expect(followFinder, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(followFinder);
    await tester.pumpAndSettle();

    expect(transport.calls.last.method, 'POST');
    expect(transport.calls.last.uri.path, '/people/author-token/followers');
    expect(find.bySemanticsLabel('取消关注作者'), findsOneWidget);
    expect(find.bySemanticsLabel('关注作者'), findsNothing);
    expect(find.byType(UserProfileDetailPage), findsNothing);
  });

  testWidgets(
    'next answer reuses the shared prefetch without showing a second detail request',
    (tester) async {
      final prefetch = Completer<Map<String, dynamic>?>();
      const initial = {
        'type': 'answer',
        'id': 'prefetch-answer-158',
        'excerpt': '列表摘要应在详情到达前立即显示',
        'author': {'name': '预加载作者'},
        'question': {'id': '158', 'title': '预加载测试问题'},
      };
      const detail = {
        'type': 'answer',
        'id': 'prefetch-answer-158',
        'content': '<p>完整的预加载回答正文</p>',
        'author': {'name': '预加载作者'},
        'question': {'id': '158', 'title': '预加载测试问题'},
      };
      final transport = _RecordingTransport();
      final api = ZhihuApiClient(SessionStore(), transport: transport);
      addTearDown(api.close);

      await tester.pumpWidget(
        _testApp(
          ContentDetailPage(
            api: api,
            contentType: 'answer',
            contentId: 'prefetch-answer-158',
            initialValue: initial,
            prefetchedDetail: prefetch.future,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('列表摘要应在详情到达前立即显示'), findsOneWidget);
      expect(
        transport.calls.any(
          (call) => call.uri.path == '/answers/v2/prefetch-answer-158',
        ),
        isFalse,
      );

      prefetch.complete(detail);
      await tester.pumpAndSettle();
      expect(find.text('完整的预加载回答正文'), findsOneWidget);
      expect(
        transport.calls.any(
          (call) => call.uri.path == '/answers/v2/prefetch-answer-158',
        ),
        isFalse,
      );
      expect(
        transport.calls.any(
          (call) => call.uri.path == '/v4/answers/prefetch-answer-158',
        ),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('embedded list keeps rows while pull refresh is pending', (
    tester,
  ) async {
    final refresh = Completer<ApiResponse>();
    var calls = 0;
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: PagedListPage(
            title: '',
            api: api,
            embedded: true,
            loadInitial: () {
              calls++;
              if (calls > 1) return refresh.future;
              return Future.value(
                _response(
                  '/test',
                  json: const {
                    'data': [
                      {'type': 'article', 'id': '1', 'title': '保留的内容'},
                    ],
                    'paging': {'is_end': true},
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.text('保留的内容'), const Offset(0, 320));
    await tester.pump();
    expect(find.text('保留的内容'), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    refresh.complete(
      _response(
        '/test',
        json: const {
          'data': [
            {'type': 'article', 'id': '2', 'title': '刷新后的内容'},
          ],
          'paging': {'is_end': true},
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('刷新后的内容'), findsOneWidget);
  });

  testWidgets('embedded initial load renders only one progress ring', (
    tester,
  ) async {
    final initial = Completer<ApiResponse>();
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: PagedListPage(
            title: '',
            api: api,
            embedded: true,
            loadInitial: () => initial.future,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    initial.complete(
      _response(
        '/test',
        json: const {
          'data': <Object>[],
          'paging': {'is_end': true},
        },
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('structured pin likes toggle through its outer identity', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'device-udid'
      ..sessionKind = 'account';
    final transport = _RecordingTransport()
      ..responses.add(_response('/pins/33/reactions'))
      ..responses.add(_response('/pins/33/reactions'));
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
    );
    addTearDown(api.close);
    final source = <String, dynamic>{
      'type': 'feed',
      'target': {
        'type': 'pin',
        'id': '33',
        'content': {'type': 'text', 'voteup_count': 10},
      },
    };
    expect(api.canWrite, isTrue);
    expect(interactiveContentIdentityOf(source), (type: 'pin', id: '33'));
    late StateSetter rebuild;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              final relationship = AnswerRelationship.from(source);
              final count = ContentMetrics.from(source).voteupCount ?? 0;
              return TextButton(
                onPressed: () async {
                  final changed = await performContentCardAction(
                    context,
                    api,
                    source,
                    ContentCardAction.vote,
                  );
                  if (changed) rebuild(() {});
                },
                child: Text('${relationship.isUpvoted}:$count'),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('false:10'), findsOneWidget);
    final context = tester.element(find.byType(TextButton));
    expect(
      await performContentCardAction(
        context,
        api,
        source,
        ContentCardAction.vote,
      ),
      isTrue,
    );
    rebuild(() {});
    await tester.pump();
    expect(transport.calls.single.method, 'POST');
    expect(transport.calls.single.uri.path, '/pins/33/reactions');
    expect(find.text('true:11'), findsOneWidget);

    expect(
      await performContentCardAction(
        context,
        api,
        source,
        ContentCardAction.vote,
      ),
      isTrue,
    );
    rebuild(() {});
    await tester.pump();
    expect(find.text('false:10'), findsOneWidget);
    expect(transport.calls.last.method, 'DELETE');
  });

  testWidgets('pin detail keeps object content and renders its document body', (
    tester,
  ) async {
    const pin = <String, dynamic>{
      'type': 'pin',
      'id': '33',
      'title': '想法标题',
      'author': {'name': '想法作者', 'url_token': 'pin-author'},
      'content': {
        'blocks': [
          {
            'type': 'paragraph',
            'children': [
              {'text': '想法正文第一段'},
            ],
          },
          {
            'type': 'image',
            'image': {'url': 'https://example.com/pin-image.jpg'},
          },
          {
            'type': 'paragraph',
            'children': [
              {'text': '想法正文第二段'},
            ],
          },
        ],
      },
      'voteup_count': 5,
      'favlists_count': 2,
      'comment_count': 1,
    };
    final transport = _RecordingTransport()
      ..responses.add(_response('/pins/v2/33', json: pin));
    final api = ZhihuApiClient(SessionStore(), transport: transport);
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        ContentDetailPage(
          api: api,
          contentType: 'pin',
          contentId: '33',
          initialValue: pin,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('想法标题'), findsOneWidget);
    expect(find.bySemanticsLabel('查看想法作者的个人主页'), findsOneWidget);
    expect(find.textContaining('想法正文第一段'), findsOneWidget);
    expect(find.textContaining('想法正文第二段'), findsOneWidget);
    expect(find.byKey(const Key('detail-author-card')), findsNothing);
    expect(transport.calls.single.uri.path, '/pins/v2/33');
    expect(tester.takeException(), isNull);
  });

  testWidgets('pin detail recovers the feed title for structured v2 content', (
    tester,
  ) async {
    const preview = <String, dynamic>{
      'type': 'pin',
      'id': '34',
      'title': '来自列表的想法标题',
      'excerpt': '列表摘要可能比正文更长，但不应阻止详情正文替换它。',
      'author': {'name': '结构化作者', 'url_token': 'structured-author'},
    };
    const detail = <String, dynamic>{
      'type': 'pin',
      'id': '34',
      'author': {'name': '结构化作者', 'url_token': 'structured-author'},
      'structured_content': {
        'paging': {},
        'segments': [
          {
            'id': '1',
            'type': 'paragraph',
            'paragraph': {
              'marks': [],
              'max_collapse_row': 0,
              'text': '来自 v2 的想法正文',
            },
          },
        ],
      },
      'voteup_count': 3,
      'favlists_count': 1,
      'comment_count': 0,
    };
    final transport = _RecordingTransport()
      ..responses.add(_response('/pins/v2/34', json: detail));
    final api = ZhihuApiClient(SessionStore(), transport: transport);
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        ContentDetailPage(
          api: api,
          contentType: 'pin',
          contentId: '34',
          initialValue: preview,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('结构化作者'), findsWidgets);
    expect(find.text('来自列表的想法标题'), findsOneWidget);
    expect(find.textContaining('来自 v2 的想法正文'), findsOneWidget);
    expect(find.byKey(const Key('detail-author-card')), findsNothing);
    expect(transport.calls.single.uri.path, '/pins/v2/34');
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown object fallback is semantic and never raw JSON', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const ObjectInspectorPage(
          value: {
            'type': 'collection',
            'id': 'collection-7',
            'title': '公开收藏集',
            'description': '列表响应中可读的收藏集简介',
            'item_count': 28,
            'follower_count': 340,
            'author': {'name': '收藏集作者', 'headline': '公开简介'},
          },
        ),
      ),
    );

    expect(find.text('公开收藏集'), findsWidgets);
    expect(find.text('收藏集'), findsOneWidget);
    expect(find.text('#collection-7'), findsNothing);
    expect(find.text('收藏集作者'), findsOneWidget);
    expect(find.text('28 条内容'), findsOneWidget);
    expect(find.text('340 关注者'), findsOneWidget);
    expect(find.text('列表响应中可读的收藏集简介'), findsOneWidget);
    expect(find.textContaining('{"type"'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('topic header maps official profile fields and child routes', (
    tester,
  ) async {
    var followersOpened = false;
    var unansweredOpened = false;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: SingleChildScrollView(
            child: TopicHeaderCard(
              topic: const {
                'type': 'topic',
                'id': '19550517',
                'name': '人工智能',
                'introduction': '研究智能系统、机器学习与现实应用。',
                'followers_count': 12345,
                'questions_count': 230,
                'answer_count': 4567,
                'discussion_totals': 890,
              },
              onFollowers: () => followersOpened = true,
              onUnanswered: () => unansweredOpened = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('话题'), findsOneWidget);
    expect(find.text('人工智能'), findsOneWidget);
    expect(find.text('研究智能系统、机器学习与现实应用。'), findsOneWidget);
    expect(find.text('1.2万 关注者 · 230 问题 · 4567 回答 · 890 讨论'), findsOneWidget);
    expect(find.text('关注者'), findsOneWidget);
    expect(find.text('待回答'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('关注者'));
    await tester.tap(find.text('待回答'));
    expect(followersOpened, isTrue);
    expect(unansweredOpened, isTrue);
  });

  testWidgets('column header maps verified detail response and routes', (
    tester,
  ) async {
    final column = columnMetadataOf({
      'data': [
        {
          'type': 'article',
          'column': {
            'id': 'design-weekly',
            'title': '设计周刊',
            'intro': '关注产品、交互与视觉设计。',
            'articles_count': 88,
            'followers': 12345,
            'contributions_count': 7,
            'voteup_count': '4567',
            'author': {'name': '专栏作者', 'url_token': 'author-token'},
          },
        },
      ],
    });
    expect(column, isNotNull);
    var followersOpened = false;
    var authorOpened = false;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: SingleChildScrollView(
            child: ColumnHeaderCard(
              column: column!,
              onFollowers: () => followersOpened = true,
              onAuthor: () => authorOpened = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('设计周刊'), findsOneWidget);
    expect(find.text('关注产品、交互与视觉设计。'), findsOneWidget);
    expect(
      find.text('作者 专栏作者 · 88 篇文章 · 1.2万 关注者 · 7 篇投稿 · 4567 获赞'),
      findsOneWidget,
    );
    await tester.tap(find.text('关注者'));
    await tester.tap(find.text('作者资料'));
    expect(followersOpened, isTrue);
    expect(authorOpened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('comment side header renders official content author context', (
    tester,
  ) async {
    var authorOpened = false;
    const response = {
      'content_author': {
        'content_author': {
          'name': '内容作者甲',
          'headline': '作者公开签名',
          'url_token': 'author-a',
        },
        'is_following': false,
        'author_tag': {'text': '作者', 'type': 'content_author'},
      },
      'continuous_consumption_module': {
        'hint': '继续浏览相关讨论',
        'link': {'text': '查看更多'},
      },
    };
    expect(commentContentAuthorOf(response)?['url_token'], 'author-a');
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: CommentContextHeader(
            response: response,
            loading: false,
            onAuthor: () => authorOpened = true,
            onFollow: () {},
          ),
        ),
      ),
    );

    expect(find.text('内容作者甲'), findsOneWidget);
    expect(find.text('作者'), findsOneWidget);
    expect(find.text('作者公开签名'), findsOneWidget);
    expect(find.text('继续浏览相关讨论'), findsNothing);
    expect(find.text('查看更多'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('comment-context-header'))).height,
      76,
    );
    expect(
      find.byKey(const Key('comment-content-author-follow')),
      findsOneWidget,
    );
    await tester.tap(find.text('内容作者甲'));
    expect(authorOpened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'comment replies pin the server root and preserve official identity tags',
    (tester) async {
      final transport = _RecordingTransport()
        ..responses.add(
          _response(
            '/comment_v5/comment/10/child_comment',
            json: const {
              'root': {
                'id': '10',
                'content': '服务端返回的原评论',
                'author': {'id': 'root-user', 'name': '原评论用户'},
                'child_comment_count': 2,
              },
              'data': [
                {
                  'id': '10',
                  'content': '不应重复出现的根评论',
                  'author': {'id': 'root-user', 'name': '原评论用户'},
                },
                {
                  'id': '11',
                  'content': '回答作者的回复',
                  'author': {'id': 'answer-owner', 'name': '回答作者'},
                  'author_tag': [
                    {'text': '作者', 'type': 'content_author'},
                  ],
                  'reply_to_author': {'id': 'root-user', 'name': '原评论用户'},
                  'reply_author_tag': [
                    {'text': '原评论作者'},
                  ],
                },
                {
                  'id': '12',
                  'content': '提问者的回复',
                  'author': {'id': 'question-owner', 'name': '问题发起人'},
                },
              ],
              'paging': {'is_end': true},
            },
          ),
        );
      final api = ZhihuApiClient(
        SessionStore(),
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      );
      addTearDown(api.close);

      await tester.pumpWidget(
        _testApp(
          CommentRepliesPage(
            api: api,
            commentId: '10',
            rootComment: const {
              'id': '10',
              'content': '列表里的旧原评论',
              'author': {'id': 'root-user', 'name': '原评论用户'},
            },
            contentAuthorIds: const {'answer-owner'},
            questionAuthorIds: const {'question-owner'},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('comment-replies-root')), findsOneWidget);
      expect(find.text('服务端返回的原评论'), findsOneWidget);
      expect(find.text('列表里的旧原评论'), findsNothing);
      expect(find.text('不应重复出现的根评论'), findsNothing);
      expect(
        tester.getTopLeft(find.text('服务端返回的原评论')).dy,
        lessThan(tester.getTopLeft(find.text('回答作者的回复')).dy),
      );
      expect(
        find.byKey(const ValueKey('comment-author-identity-作者')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('comment-author-identity-题主')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('comment-author-identity-层主')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('comment-reply-identity-原评论作者')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('comment-reply-identity-层主')),
        findsNothing,
      );
      expect(find.text('回复 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('comment root metadata renders total, sorter and categories', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: Builder(
            builder: (context) => commentListSummaryHeader(context, const {
              'counts': {
                'total_counts': 172,
                'collapsed_counts': 2,
                'reviewing_counts': 1,
              },
              'sorter': [
                {'type': 'score', 'text': '默认排序'},
              ],
              'header': [
                {'type': 'all', 'text': '全部评论', 'count': 172},
              ],
            })!,
          ),
        ),
      ),
    );

    expect(find.text('默认'), findsOneWidget);
    expect(find.text('最新'), findsNothing);
    expect(find.text('评论 172'), findsOneWidget);
    expect(find.text('折叠 2'), findsNothing);
    expect(find.text('审核中 1'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('comment-summary-controls'))).height,
      48,
    );
    expect(find.byType(SegmentedButton<String>), findsNothing);
    expect(find.byType(VerticalDivider), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('segment comment alias uses the sentence wire filter', (
    tester,
  ) async {
    final requestedTypes = <String>[];
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        CommentThreadView(
          api: api,
          title: '评论',
          contentType: 'answer',
          contentId: '7',
          initialCommentType: 'segment',
          loadInitial: (order, type) async {
            requestedTypes.add(type);
            return _response(
              '/comment_v5/answers/7/root_comment',
              json: const {
                'counts': {'total_counts': 0},
                'data': <Object>[],
                'paging': {'is_end': true},
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(requestedTypes, ['sentence']);
    expect(find.text('句子评论'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'comment latest sorter reloads the root page and stays selected',
    (tester) async {
      final orders = <String>[];
      final api = ZhihuApiClient(SessionStore());
      addTearDown(api.close);

      Future<ApiResponse> load(String order, String _) async {
        orders.add(order);
        return _response(
          '/comment_v5/answers/7/root_comment',
          json: {
            'counts': {'total_counts': 2},
            'sorter': const [
              {'type': 'score', 'text': '默认'},
              {'type': 'ts', 'text': '最新'},
            ],
            'data': [
              {
                'id': order == 'ts' ? '2' : '1',
                'content': order == 'ts' ? '最新结果' : '默认结果',
                'author': {'name': '评论用户'},
                'child_comment_count': 0,
              },
            ],
            'paging': {'is_end': true},
          },
        );
      }

      await tester.pumpWidget(
        _testApp(
          CommentThreadView(
            api: api,
            title: '评论',
            contentType: 'answer',
            contentId: '7',
            loadInitial: load,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(orders, ['score']);
      expect(find.text('默认结果'), findsOneWidget);
      expect(find.text('全部评论'), findsOneWidget);
      expect(find.text('评论 2'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('comment-sort-ts')));
      await tester.pumpAndSettle();

      expect(orders, ['score', 'ts']);
      expect(find.text('默认结果'), findsNothing);
      expect(find.text('最新结果'), findsOneWidget);
      final selected = tester.widget<Semantics>(
        find.byKey(const ValueKey('comment-sort-ts')),
      );
      expect(selected.properties.selected, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'comment media keeps HTTPS images and removes sticker fallback text',
    () {
      const photo = 'https://pic.example/photo.png?size=large&amp;v=1';
      const sticker = 'https://pic.example/sticker.gif';
      const value = <String, dynamic>{
        'id': '9',
        'content':
            '正文<img data-original="$photo">'
            '<a data-sticker-id="s1" class="comment_sticker vip" '
            'href="$sticker">[贴纸名称]</a>'
            '<a href="https://example.com/page">普通链接</a>'
            '<img src="http://insecure.example/rejected.png">',
      };

      expect(commentContentOf(value), '正文 普通链接');
      expect(contentImageUrlsOf(value, limit: 6), [
        'https://pic.example/photo.png?size=large&v=1',
        sticker,
      ]);

      expect(
        contentImageUrlsOf({
          'id': '10',
          'content': '<a href="https://pic.example/inline.jpg">[图片]</a>',
        }),
        ['https://pic.example/inline.jpg'],
      );
    },
  );

  test('comment DOM parser separates media and protects version text', () {
    final document = parseCommentContent(
      'ERNIE 5.0 / Qwen3.5 4.5B '
      '<a class="comment_img" href="https://pic.example/no-extension">[图片]</a>'
      '，继续看 example.com/story。'
      '<a class="comment_sticker" href="https://pic.example/sticker">[赞同]</a>',
    );

    expect(document.mediaUrls, ['https://pic.example/no-extension']);
    expect(document.nodes.where((node) => node.isSticker), hasLength(1));
    expect(
      document.nodes.where((node) => node.isSticker).single.url,
      'https://pic.example/sticker',
    );
    expect(
      document.nodes.where((node) => node.isLink).map((node) => node.url),
      ['https://example.com/story'],
    );
    final visible = document.nodes
        .where((node) => node.isText)
        .map((node) => node.text)
        .join();
    expect(visible, contains('ERNIE 5.0 / Qwen3.5 4.5B'));
    expect(visible, isNot(contains('[图片]')));
    expect(visible, isNot(contains('[赞同]')));
  });

  test('comment DOM parser rejects version-like hrefs as links', () {
    final document = parseCommentContent(
      '<a href="https://5.0">https://5.0 Thinking Preview</a> | '
      '<a href="https://Qwen3.5">https://Qwen3.5 4B</a> | '
      '<a href="https://www.zhihu.com/question/2">正常知乎链接</a>',
    );

    expect(
      document.nodes.where((node) => node.isLink).map((node) => node.url),
      ['https://www.zhihu.com/question/2'],
    );
    final visible = document.nodes
        .where((node) => node.isText)
        .map((node) => node.text)
        .join();
    expect(visible, contains('https://5.0 Thinking Preview'));
    expect(visible, contains('https://Qwen3.5 4B'));
  });

  test(
    'comment DOM parser keeps stickers inline and images in media output',
    () {
      final document = parseCommentContent(
        '前缀'
        '<a data-sticker-id="s1" class="comment_sticker vip" '
        'href="https://pic.example/sticker.png">[贴纸名称]</a>'
        '<a class="comment_img" href="https://pic.example/photo.png">[图片]</a>',
      );

      expect(document.nodes.where((node) => node.isSticker), hasLength(1));
      expect(
        document.nodes.where((node) => node.isSticker).single.url,
        'https://pic.example/sticker.png',
      );
      expect(
        document.nodes.where((node) => node.isSticker).single.id,
        'comment-sticker-s1',
      );
      expect(document.mediaUrls, ['https://pic.example/photo.png']);
    },
  );

  test('comment links match native host detection and link-tag fields', () {
    expect(
      extractCommentLinkUrls(
        '回答见 example.com/question/1，也见 https://www.zhihu.com/question/2。',
      ),
      ['https://example.com/question/1', 'https://www.zhihu.com/question/2'],
    );
    expect(
      normalizeCommentLink('www.example.com/a'),
      'https://www.example.com/a',
    );
    expect(normalizeCommentLink('Qwen3.5'), 'Qwen3.5');
    expect(extractCommentLinkUrls('Qwen3.5 4.5B MiniCPM-V'), isEmpty);
    expect(normalizeCommentLink('zhihu://question/2'), 'zhihu://question/2');
    expect(contentIdentityFromUrl('https://www.zhihu.com/comment/42'), (
      'comment',
      '42',
    ));
    expect(contentIdentityFromUrl('https://example.com/answer/42'), ('', ''));

    final tags = commentLinkTagsOf({
      'link_tag': {
        'title': '不应覆盖标签标题',
        'icon_url': 'https://pic.example/root.png',
        'tags': [
          {
            'title': '回答',
            'text': '问题标题',
            'target_url': 'https://www.zhihu.com/question/2',
            'icon_url': 'https://pic.example/question.png',
          },
        ],
      },
    });
    expect(tags.single.displayText, '回答｜问题标题');
    expect(tags.single.iconUrl, 'https://pic.example/question.png');
  });

  testWidgets('comment rich text preserves punctuation after bare links', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: CommentRichText(text: '请看 example.com/story，也继续阅读。'),
        ),
      ),
    );
    await tester.pump();
    final richText = tester.widget<RichText>(find.byType(RichText).last);
    expect(richText.text.toPlainText(), '请看 example.com/story，也继续阅读。');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'comment bracket keywords render bundled emoticons and preserve unknown text',
    (tester) async {
      await loadBundledCommentEmoticonLookup();
      await tester.pumpWidget(
        _testApp(
          const Scaffold(
            body: CommentEmoticonText(text: '前[赞同]后[未收录] [这是一个超过十个字的未知关键字]'),
          ),
        ),
      );
      await tester.pump();

      final renderer = find.byType(CommentEmoticonText);
      expect(renderer, findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('comment-inline-emoticon-emoticon_emoji_02-0'),
        ),
        findsOneWidget,
      );
      final richText = tester.widget<RichText>(
        find.descendant(of: renderer, matching: find.byType(RichText)),
      );
      final plain = richText.text.toPlainText();
      expect(plain, isNot(contains('[赞同]')));
      expect(plain, contains('[未收录]'));
      expect(plain, contains('[这是一个超过十个字的未知关键字]'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'rich comments publish bundled emoticons before optional remote catalog',
    (tester) async {
      await loadBundledCommentEmoticonLookup();
      final api = ZhihuApiClient(
        SessionStore(),
        transport: _RecordingTransport(),
      );
      addTearDown(api.close);

      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: CommentRichText(text: '前[捂脸][思考]后', api: api),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('comment-rich-emoticon-emoticon_emoji_10-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('comment-rich-emoticon-emoticon_emoji_06-1')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('comment sticker anchors render through the media gallery', (
    tester,
  ) async {
    const image = 'https://pic.example/sticker.webp';
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: CommentCard(
            compact: true,
            value: {
              'id': 'sticker-comment',
              'content': '前<a href="$image" class="comment_sticker">[新表情]</a>后',
              'author': {'name': '表情评论用户'},
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('comment-image-$image')), findsOneWidget);
    expect(find.text('[新表情]'), findsNothing);
    final richText = tester.widget<RichText>(find.byType(RichText).last);
    expect(richText.text.toPlainText(), contains('前后'));
  });

  testWidgets('comment images render inline and open a safe native preview', (
    tester,
  ) async {
    const image = 'https://pic.example/comment.png';
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: CommentCard(
            compact: true,
            value: {
              'id': '10',
              'content': '<img src="$image">',
              'author': {'name': '图片评论用户'},
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final imageTile = find.byKey(
      const ValueKey('comment-image-https://pic.example/comment.png'),
    );
    expect(imageTile, findsOneWidget);
    expect(find.text('该评论没有可显示的文字内容'), findsNothing);
    await tester.tap(imageTile);
    await tester.pump();
    final viewer = find.byType(InteractiveViewer);
    final previewFrame = find.byKey(
      const ValueKey(
        'comment-image-preview-frame-https://pic.example/comment.png',
      ),
    );
    expect(viewer, findsOneWidget);
    expect(previewFrame, findsOneWidget);
    expect(tester.getSize(previewFrame), tester.getSize(viewer));
    expect(tester.widget<InteractiveViewer>(viewer).minScale, 1);
    expect(
      find.byKey(const Key('comment-image-preview-close')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('comment-image-preview-close')));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('technical API failure details are hidden from the interface', (
    tester,
  ) async {
    final response = ApiResponse(
      uri: Uri.parse('https://api.zhihu.com/questions/7/feeds'),
      statusCode: 403,
      bodyBytes: 64,
      json: {
        'error': {'code': 40353, 'need_login': true},
      },
      headers: {},
    );
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: ApiErrorView(error: response, onRetry: _noop),
        ),
      ),
    );
    expect(find.text('暂时无法加载'), findsOneWidget);
    expect(find.text('请稍后重试。'), findsOneWidget);
    expect(find.textContaining('HTTP'), findsNothing);
    expect(find.textContaining('业务码'), findsNothing);
    expect(find.textContaining('会话'), findsNothing);
  });

  testWidgets('endpoint authorization evidence can override generic 40353', (
    tester,
  ) async {
    final response = ApiResponse(
      uri: Uri.parse('https://api.zhihu.com/search_v3'),
      statusCode: 403,
      bodyBytes: 64,
      json: {
        'error': {'code': 40353, 'need_login': true},
      },
      headers: {},
    );
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: ApiErrorView(
            error: response,
            onRetry: _noop,
            titleOverride: '请先登录',
            detailOverride: '登录后即可搜索。',
          ),
        ),
      ),
    );
    expect(find.text('请先登录'), findsOneWidget);
    expect(find.text('登录后即可搜索。'), findsOneWidget);
    expect(find.textContaining('HTTP'), findsNothing);
    expect(find.textContaining('业务码'), findsNothing);
  });

  test('API errors normalize nested numeric business fields', () {
    final response = ApiResponse(
      uri: Uri.parse('https://api.zhihu.com/questions/7/feeds'),
      statusCode: 403,
      bodyBytes: 96,
      json: const {
        'error': {
          'code': 40353,
          'name': 'ERR_GUEST_CONTEXT',
          'message': 'guest context rejected',
          'need_login': 1,
        },
      },
      headers: const {},
    );

    expect(response.businessCode, '40353');
    expect(response.errorName, 'ERR_GUEST_CONTEXT');
    expect(response.serverMessage, 'guest context rejected');
    expect(response.needLogin, isTrue);
    expect(response.statusLabel, 'HTTP 403 · 业务码 40353');
    expect(response.failure.kind, ApiFailureKind.guestContext);
    expect(response.failure.retryable, isTrue);
  });

  test('API errors normalize root aliases and nested data envelopes', () {
    final root = ApiResponse(
      uri: Uri.parse('https://api.zhihu.com/search_v3'),
      statusCode: 429,
      bodyBytes: 64,
      json: const {'error_code': 'RATE_LIMITED', 'toast_message': '稍后再试'},
      headers: const {},
    );
    final nested = ApiResponse(
      uri: Uri.parse('https://api.zhihu.com/topstory/recommend'),
      statusCode: 403,
      bodyBytes: 64,
      json: const {
        'data': {
          'error': {'errorCode': '10003', 'errorMessage': '签名失效'},
        },
      },
      headers: const {},
    );

    expect(root.businessCode, 'RATE_LIMITED');
    expect(root.serverMessage, '稍后再试');
    expect(root.failure.kind, ApiFailureKind.rateLimited);
    expect(nested.businessCode, '10003');
    expect(nested.serverMessage, '签名失效');
    expect(nested.failure.kind, ApiFailureKind.guestContext);
  });

  test('API failure categories preserve HTTP and authorization semantics', () {
    ApiFailure failure(int status, {Object? json}) => ApiResponse(
      uri: Uri.parse('https://api.zhihu.com/test'),
      statusCode: status,
      bodyBytes: 0,
      json: json,
      headers: const {},
    ).failure;

    expect(failure(401).kind, ApiFailureKind.authentication);
    expect(
      failure(
        400,
        json: const {
          'error': {'code': 101},
        },
      ).kind,
      ApiFailureKind.authentication,
    );
    expect(failure(403).kind, ApiFailureKind.permission);
    expect(failure(404).kind, ApiFailureKind.notFound);
    expect(failure(500).kind, ApiFailureKind.server);
    expect(failure(500).retryable, isTrue);
    expect(
      ApiFailure.from(const ApiTransportException('offline')).kind,
      ApiFailureKind.transport,
    );
  });
}

class _QuestionAnswersHeaderTransport extends ApiTransport {
  final List<Uri> uris = [];

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    uris.add(uri);
    if (uri.path == '/v4/questions/7/answers') {
      return _response(
        uri.path,
        json: const {
          'data': [
            {
              'target': {
                'type': 'answer',
                'id': '42',
                'excerpt': '回答列表中的紧凑摘要。',
                'author': {'name': '回答作者', 'headline': '作者简介'},
                'question': {
                  'id': '7',
                  'title': '需要展示完整信息的问题',
                  'answer_count': 86,
                  'follower_count': 321,
                },
              },
            },
          ],
          'paging': {'is_end': true},
        },
      );
    }
    if (uri.path == '/questions/7') {
      return _response(
        uri.path,
        json: const {
          'type': 'question',
          'id': '7',
          'title': '需要展示完整信息的问题',
          'answer_count': 86,
          'follower_count': 321,
          'author': {
            'id': 'question-author-id',
            'url_token': 'question-author-token',
            'name': '问题发起人',
            'headline': '发起人的公开签名',
          },
          'detail':
              '<p>近日，这是问题的完整补充正文，用于解释事件背景、条件和问题本身。</p>'
              '<a class="video-box" data-lens-id="question-header-video" '
              'data-poster="https://picx.zhimg.com/question-video.jpg">'
              '</a>'
              '<img src="https://picx.zhimg.com/question-body.jpg">',
          'thumbnails_v2': [
            {
              'type': 'video',
              'video_id': 'question-header-video',
              'duration': 65,
              'width': 1280,
              'height': 720,
              'cover_info': {
                'thumbnail': 'https://picx.zhimg.com/question-video.jpg',
              },
              'playlist': {
                'hd': {'url': 'https://vdn.vzuu.com/question-video.mp4'},
              },
            },
          ],
        },
      );
    }
    return _response(uri.path, statusCode: 404);
  }
}
