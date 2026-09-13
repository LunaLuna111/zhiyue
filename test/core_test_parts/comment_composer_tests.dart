part of '../core_test.dart';

void registerCommentComposerTests() {
  testWidgets('comment page uses the official bottom composer entry', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accessTokenExpiry = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
    final api = ZhihuApiClient(
      session,
      transport: _RecordingTransport(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(CommentsPage(api: api, contentType: 'answers', contentId: '7')),
    );
    await tester.pump();

    final action = find.byKey(const Key('comment-editor-entry'));
    expect(action, findsOneWidget);
    expect(find.widgetWithText(ZhPrimaryButton, '写评论'), findsNothing);
    await tester.tap(action);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('comment-composer-surface')), findsOneWidget);
    final field = tester.widget<TextField>(
      find.byKey(const Key('comment-composer-field')),
    );
    expect(field.decoration?.hintText, '理性发言，友善互动');
    expect(tester.takeException(), isNull);
  });

  test('comment emoticon bundled catalogs preserve all APK entries', () async {
    final groups = await loadBundledCommentEmoticonGroups();
    expect(groups, hasLength(2));
    expect(groups[0].emoticons, hasLength(58));
    expect(groups[1].emoticons, hasLength(23));
    expect(groups[0].emoticons.any((value) => value.title == '[赞同]'), isTrue);
    expect(
      groups[0].emoticons.any(
        (value) => value.id == 'emoticon_emoji_02' && value.title == '[赞同]',
      ),
      isTrue,
    );
    expect(groups[1].emoticons.any((value) => value.title == '[旺柴]'), isTrue);

    final lookup = await loadBundledCommentEmoticonLookup();
    expect(lookup['[赞同]']?.assetImagePath, 'assets/emoji/default/emoji_2.webp');
    expect(lookup['[旺柴]']?.assetImagePath, 'assets/emoji/vip/emoji_21.webp');
    // The original resolver checks the default catalog before VIP when a
    // title occurs in both catalogs.
    expect(lookup['[感谢]']?.id, 'emoticon_emoji_56');
  });

  test('comment emoticon catalog loads group details concurrently', () async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accessTokenExpiry = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
    final transport = _CommentEmoticonTransport();
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
    );
    addTearDown(api.close);

    final loading = api.loadCommentEmoticonGroups();
    await transport.allDetailsStarted.future;
    expect(transport.detailPaths.toSet(), {
      '/sticker-groups/official',
      '/sticker-groups/stickers',
    });
    transport.completeDetails();

    final groups = await loading;
    expect(groups, hasLength(2));
    expect(groups.first.emoticons.single.title, '[赞同]');
    expect(groups.last.emoticons.single.title, '猫猫');
  });

  test('comment sticker body follows official anchor contract', () {
    const sticker = CommentEmoticon(
      id: '88',
      title: '猫猫',
      groupId: 'animals',
      groupType: 'normal',
      staticImageUrl: 'https://pic.example/cat.png',
      dynamicImageUrl: '',
      stickerType: 1,
      status: 1,
    );
    final body = ZhihuApiClient.buildCommentBody(
      content: '正文',
      sticker: sticker,
    );

    expect(
      body['content'],
      '正文<a href="https://pic.example/cat.png" class="comment_sticker" '
      'data-width="0" data-height="0" data-sticker-id="88">[猫猫]</a>',
    );
    expect(body['sticker_type'], ['normal']);
  });

  test('selected comment body follows native sentence payload contract', () {
    const selection = ContentSelection(
      quote: '被选中的句子',
      startOffset: 2,
      endOffset: 8,
      paragraphId: 'paragraph-17',
      segmentIds: ['segment-a', 'segment-b'],
      source: 'structured',
    );
    final body = ZhihuApiClient.buildCommentBody(
      content: '补充说明',
      selection: selection,
    );

    expect(body['segment'], {
      'segment_id': 'segment-a,segment-b',
      'content': '被选中的句子',
      'position': {
        'start': {'offset': 2, 'paragraph_id': 'paragraph-17'},
        'end': {'offset': 8, 'paragraph_id': 'paragraph-17'},
      },
    });
  });

  testWidgets('comment composer inserts official emoji and mention at cursor', (
    tester,
  ) async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account'
      ..accessTokenExpiry = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
    final api = ZhihuApiClient(
      session,
      transport: _RecordingTransport(),
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
    );
    addTearDown(api.close);
    CommentComposerValue? submitted;

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: CommentComposerSheet(
            api: api,
            title: '回复 @测试用户',
            replyTarget: const CommentReplyTarget(
              contentType: 'answers',
              contentId: '7',
              replyCommentId: '8',
              targetUserName: '测试用户',
            ),
            initialEmoticonGroups: const [
              CommentEmoticonGroup(
                id: 'EMOJI_GROUP_ID',
                title: '默认',
                type: 'official',
                iconUrl: '',
                selectedIconUrl: '',
                version: 3,
                emoticons: [
                  CommentEmoticon(
                    id: 'emoticon_emoji_02',
                    title: '[赞同]',
                    groupId: 'EMOJI_GROUP_ID',
                    groupType: 'official',
                    staticImageUrl: '',
                    dynamicImageUrl: '',
                    stickerType: 1,
                    status: 1,
                    assetImagePath: 'assets/emoji/default/emoji_2.webp',
                  ),
                ],
              ),
            ],
            onSubmit: (value) async {
              submitted = value;
              return '保持编辑器打开';
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final surfaceFinder = find.byKey(const Key('comment-composer-surface'));
    final fieldFinder = find.byKey(const Key('comment-composer-field'));
    final surface = tester.widget<Material>(surfaceFinder);
    final shape = surface.shape! as RoundedRectangleBorder;
    final borderRadius = shape.borderRadius.resolve(TextDirection.ltr);
    expect(borderRadius.topLeft.x, 16);
    expect(borderRadius.topRight.x, 16);
    expect(
      tester.getTopLeft(fieldFinder).dy - tester.getTopLeft(surfaceFinder).dy,
      lessThanOrEqualTo(60),
    );
    final surfaceTop = tester.getTopLeft(surfaceFinder).dy;
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    final logicalInset = MediaQuery.viewInsetsOf(
      tester.element(surfaceFinder),
    ).bottom;
    expect(logicalInset, greaterThan(0));
    // The modal route already keeps its child above the IME. The composer
    // now uses normal layout padding instead of a negative Transform, so its
    // render box remains at the same logical origin in this direct Scaffold
    // harness while its real bottom-sheet hit rectangle stays stable.
    expect(tester.getTopLeft(surfaceFinder).dy, closeTo(surfaceTop, .1));
    await tester.tap(find.byKey(const Key('comment-composer-emoticons')));
    // Mirror Android's global-layout callback after the retiring IME reports
    // a zero inset. Only then should the original-style panel become visible.
    tester.view.resetViewInsets();
    await tester.pump(const Duration(milliseconds: 220));
    final approveEmoji = find.bySemanticsLabel('[赞同]');
    expect(approveEmoji, findsOneWidget);
    await tester.tap(approveEmoji);
    await tester.tap(find.byKey(const Key('comment-composer-mention')));
    await tester.pump();

    final field = tester.widget<TextField>(fieldFinder);
    expect(field.controller!.text, '[赞同]@测试用户 ');
    await tester.tap(find.byKey(const Key('comment-composer-submit')));
    await tester.pump();
    expect(submitted?.text, '[赞同]@测试用户 ');
    expect(tester.takeException(), isNull);
  });

  testWidgets('platform backspace removes an inline emoji as one token', (
    tester,
  ) async {
    final api = ZhihuApiClient(
      _MemorySessionStore(),
      transport: _RecordingTransport(),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: CommentComposerSheet(
            api: api,
            title: '写评论',
            initialEmoticonGroups: const [
              CommentEmoticonGroup(
                id: 'EMOJI_GROUP_ID',
                title: '默认',
                type: 'official',
                iconUrl: '',
                selectedIconUrl: '',
                version: 3,
                emoticons: [
                  CommentEmoticon(
                    id: 'emoticon_emoji_02',
                    title: '[赞同]',
                    groupId: 'EMOJI_GROUP_ID',
                    groupType: 'official',
                    staticImageUrl: '',
                    dynamicImageUrl: '',
                    stickerType: 1,
                    status: 1,
                    assetImagePath: 'assets/emoji/default/emoji_2.webp',
                  ),
                ],
              ),
            ],
            onSubmit: (_) async => null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('comment-composer-field'));
    await tester.tap(field);
    tester.testTextInput.enterText('[赞同]');
    await tester.pump();
    expect(tester.widget<TextField>(field).controller?.text, '[赞同]');

    // Android sends the final bracket as a separate deletion. The editor
    // must repair that partial update back to a complete token deletion.
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '[赞同',
        selection: TextSelection.collapsed(offset: 3),
      ),
    );
    await tester.pump();

    expect(tester.widget<TextField>(field).controller?.text, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor paints longer official emoji tokens as images', (
    tester,
  ) async {
    final api = ZhihuApiClient(
      _MemorySessionStore(),
      transport: _RecordingTransport(),
    );
    addTearDown(api.close);
    const token = '[aaaaaaaaaaaaaaaaaaaaaaaaa]';

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: CommentComposerSheet(
            api: api,
            title: '写评论',
            initialEmoticonGroups: const [
              CommentEmoticonGroup(
                id: 'long-token-group',
                title: '默认',
                type: 'official',
                iconUrl: '',
                selectedIconUrl: '',
                version: 1,
                emoticons: [
                  CommentEmoticon(
                    id: 'long-token',
                    title: token,
                    groupId: 'long-token-group',
                    groupType: 'official',
                    staticImageUrl: '',
                    dynamicImageUrl: '',
                    stickerType: 1,
                    status: 1,
                    assetImagePath: 'assets/emoji/default/emoji_2.webp',
                  ),
                ],
              ),
            ],
            onSubmit: (_) async => null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final field = find.byKey(const Key('comment-composer-field'));
    await tester.tap(field);
    tester.testTextInput.enterText(token);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('comment-editor-emoticon-$token')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('guest can edit comments but submit never reaches transport', (
    tester,
  ) async {
    final session = _MemorySessionStore();
    final transport = _RecordingTransport();
    final api = ZhihuApiClient(session, transport: transport);
    addTearDown(api.close);

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: CommentComposerSheet(
            api: api,
            title: '写评论',
            initialEmoticonGroups: const [],
            onSubmit: (_) async {
              fail('guest submit callback must not run');
            },
          ),
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('comment-composer-field')),
      '本地测试内容',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('comment-composer-submit')));
    await tester.pump();

    expect(find.textContaining('请先登录后再发布'), findsOneWidget);
    expect(transport.calls, isEmpty);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('comment-composer-field')))
          .controller
          ?.text,
      '本地测试内容',
    );
  });
}

class _CommentEmoticonTransport extends ApiTransport {
  final allDetailsStarted = Completer<void>();
  final detailPaths = <String>[];
  final _details = <String, Completer<ApiResponse>>{};

  void completeDetails() {
    for (final entry in _details.entries) {
      final official = entry.key.endsWith('/official');
      entry.value.complete(
        _response(
          entry.key,
          json: {
            'data': {
              'stickers': [
                {
                  'id': official ? 'up' : 'cat',
                  'title': official ? '[赞同]' : '猫猫',
                  'group_id': official ? 'official' : 'stickers',
                  'status': 1,
                  if (!official)
                    'static_image_url': 'https://pic.example/cat.png',
                },
              ],
            },
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
    if (uri.path == '/people/self/sticker-groups/v2') {
      return Future.value(
        _response(
          uri.path,
          json: const {
            'data': [
              {'id': 'official', 'title': '知乎表情', 'type': 'official'},
              {'id': 'stickers', 'title': '贴纸', 'type': 'normal'},
            ],
          },
        ),
      );
    }
    if (uri.path.startsWith('/sticker-groups/')) {
      detailPaths.add(uri.path);
      final completer = _details.putIfAbsent(uri.path, Completer.new);
      if (detailPaths.length == 2 && !allDetailsStarted.isCompleted) {
        allDetailsStarted.complete();
      }
      return completer.future;
    }
    return Future.value(_response(uri.path));
  }
}
