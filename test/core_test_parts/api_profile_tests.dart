part of '../core_test.dart';

void registerApiProfileTests() {
  test('network User-Agent exposes only the coherent synthetic profile', () {
    expect(
      ZhihuApiClient.appUserAgent,
      'com.zhihu.android/Futureve/11.4.0 Mozilla/5.0 (Linux; Android 14; '
      'Xiaomi 14 Build/UKQ1.230917.001; wv) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Version/4.0 Chrome/57.0.1000.10 Mobile Safari/537.36',
    );
    expect(ZhihuApiClient.appUserAgent, isNot(contains('sdk_gphone')));
    expect(
      zhihuImageRequestHeaders['User-Agent'],
      PrivacyDeviceProfile.appUserAgent,
    );
    expect(PrivacyDeviceProfile.timezoneOffsetSeconds, 28800);
    expect(PrivacyDeviceProfile.logicalScreenWidth, 411);
  });

  test('legacy fabricated MS-ID is removed without touching imports', () {
    const legacy = '0123456789abcdef0123456789abcdef';
    expect(
      SessionStore.shouldDiscardLegacySyntheticMsId('guest', legacy),
      isTrue,
    );
    expect(
      SessionStore.shouldDiscardLegacySyntheticMsId('account', legacy),
      isTrue,
    );
    expect(
      SessionStore.shouldDiscardLegacySyntheticMsId('imported', legacy),
      isFalse,
    );
    expect(
      SessionStore.shouldDiscardLegacySyntheticMsId(
        'guest',
        'AbCd_opaque-provider-value-that-is-not-the-old-local-shape',
      ),
      isFalse,
    );
  });

  test('WebView fingerprint script converges high-entropy device values', () {
    final script = buildPrivacyWebFingerprintScript();
    expect(script, contains("'hardwareConcurrency', () => 8"));
    expect(script, contains("'deviceMemory', () => 8"));
    expect(script, contains("model: 'Xiaomi 14'"));
    expect(script, contains("const privacyTimeZone = 'Asia/Shanghai'"));
    expect(script, contains("'width', () => 411"));
    expect(script, contains("return 'Adreno (TM) 750'"));
    expect(script, contains('GMT+0800 (China Standard Time)'));
    expect(script, contains('normalizeCanvasPixels'));
    expect(script, contains("'sampleRate', () => 48000"));
  });

  test('comment initial URLs match official 11.4.0 runtime contracts', () {
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);

    expect(
      api
          .commentsInitialUri(contentType: 'answer', contentId: '123')
          .toString(),
      'https://api.zhihu.com/comment_v5/answers/123/root_comment?'
      'order_by=score&limit=20&offset=',
    );
    expect(
      api
          .commentsInitialUri(
            contentType: 'answer',
            contentId: '123',
            orderBy: 'time',
            type: 'sentence',
          )
          .toString(),
      'https://api.zhihu.com/comment_v5/answers/123/root_comment?'
      'order_by=ts&limit=20&offset=&type=sentence',
    );
    expect(
      api.commentRepliesInitialUri('456').toString(),
      'https://api.zhihu.com/comment_v5/comment/456/child_comment',
    );
    expect(
      api
          .commentListHeadersUri(contentType: 'article', contentId: '789')
          .toString(),
      'https://api.zhihu.com/comment_v5/articles/789/list-headers',
    );
    expect(
      () => api.commentsInitialUri(contentType: 'question', contentId: '123'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () =>
          api.commentListHeadersUri(contentType: 'answer', contentId: '../123'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => api.commentRepliesInitialUri('../456'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => api.commentsInitialUri(
        contentType: 'answer',
        contentId: '123',
        orderBy: 'newest',
      ),
      throwsA(isA<ApiTransportException>()),
    );
  });

  test('comment write contract preserves route, field order and reply id', () {
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);

    expect(
      api.commentCreateUri(contentType: 'answer', contentId: '123').toString(),
      'https://api.zhihu.com/comment_v5/answers/123/comment',
    );
    expect(
      api.commentDeleteUri('456').toString(),
      'https://www.zhihu.com/api/v4/comment_v5/comment/456',
    );
    final root = ZhihuApiClient.buildCommentBody(content: ' ... ');
    final reply = ZhihuApiClient.buildCommentBody(
      content: '....',
      replyCommentId: '456',
    );
    expect(root.keys.toList(), [
      'comment_id',
      'content',
      'extra_params',
      'has_img',
      'reply_comment_id',
      'score',
      'selected_settings',
      'segment',
      'sticker_type',
      'unfriendly_check',
    ]);
    expect(root['content'], '...');
    expect(root['reply_comment_id'], '');
    expect(reply['reply_comment_id'], '456');
    expect(
      () => ZhihuApiClient.buildCommentBody(
        content: 'x',
        replyCommentId: '../456',
      ),
      throwsA(isA<ApiTransportException>()),
    );
  });

  test(
    'answer editor payload matches captured plugin field order and HTML',
    () {
      const traceId = '00112233-4455-4677-8899-aabbccddeeff';
      final body = ZhihuApiClient.buildAnswerEditorBody(
        questionId: '123456789',
        questionTitle: '测试问题',
        content: '第一行\n<&>',
        traceId: traceId,
        extraTag: 'captured-entry-tag',
      );
      expect(body.keys.toList(), ['data', 'action', 'template_id']);
      final data = body['data']! as Map<String, Object?>;
      expect(data.keys.toList(), [
        'answerConfig',
        'reprint',
        'subscribe',
        'zvideoCollections',
        'contribute',
        'column',
        'media',
        'title',
        'creationStatement',
        'publishSwitch',
        'hybrid',
        'extra_info',
        'appreciate',
        'originalReprint',
        'draft',
        'publish',
        'anonymity',
        'commentsPermission',
        'thanksInvitation',
      ]);
      final hybrid = data['hybrid']! as Map<String, Object?>;
      expect(hybrid['textLength'], 7);
      expect(hybrid['html'], '<p>第一行</p><p>&lt;&amp;&gt;</p>');
      final extra = data['extra_info']! as Map<String, Object?>;
      expect(extra['key_router_raw_url'], 'zhihu://answer/editor/123456789');
      expect((data['publish']! as Map)['traceId'], traceId);
      expect((data['draft']! as Map)['contentId'], '');
      expect(body['action'], 'answer');
      expect(body['template_id'], '0');
    },
  );

  test(
    'account write methods use captured endpoints and identical answer body',
    () async {
      final session = _MemorySessionStore()
        ..authorization = 'Bearer account-token'
        ..udid = 'account-udid'
        ..sessionKind = 'account'
        ..accessTokenExpiry = DateTime.now().toUtc().add(
          const Duration(hours: 1),
        );
      final transport = _RecordingTransport();
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
      );
      addTearDown(api.close);

      await api.createComment(
        contentType: 'answer',
        contentId: '123',
        content: '...',
      );
      await api.deleteComment('456');
      await api.deleteActivity('{"type":"answer","id":789}');
      await api.publishAnswer(
        questionId: '123456789',
        questionTitle: '测试问题',
        content: '...',
      );
      await api.deleteAnswer('789');
      await api.voteAnswer(answerId: '789', voting: 1, voteupCount: 321);
      await api.favoriteAnswer('789');
      await api.addSaltToBookshelf(
        bookListId: '1934199700015286041',
        propertyType: 'short_story',
      );

      expect(transport.calls.map((call) => call.method).toList(), [
        'POST',
        'DELETE',
        'DELETE',
        'POST',
        'POST',
        'DELETE',
        'POST',
        'PUT',
        'POST',
      ]);
      expect(transport.calls.map((call) => call.uri.path).toList(), [
        '/comment_v5/answers/123/comment',
        '/api/v4/comment_v5/comment/456',
        '/moments/activity',
        '/content/drafts',
        '/content/publish',
        '/answers/789',
        '/answers/789/voters',
        '/answers/789/collections_v2',
        '/km-indep-home-comm/member/book_shelf',
      ]);
      expect(transport.calls[3].body, transport.calls[4].body);
      expect(transport.calls[1].body, isNull);
      expect(transport.calls[2].body, isNull);
      expect(transport.calls[5].body, isNull);
      expect(
        transport.calls[2].uri.queryParameters['item_brief'],
        '{"type":"answer","id":789}',
      );
      expect(jsonDecode(utf8.decode(transport.calls.last.body!)), const {
        'book_list_id': '1934199700015286041',
        'property_type': 'short_story',
      });
      expect(
        utf8.decode(transport.calls[6].body!),
        'voting=1&voteup_count=321',
      );
      expect(
        utf8.decode(transport.calls[7].body!),
        'add_collections=0&remove_collections=',
      );
      expect(
        transport.calls[1].headers['Authorization'],
        'Bearer account-token',
      );
    },
  );

  test(
    'article, pin and favorite toggles use audited mutation routes',
    () async {
      final session = _MemorySessionStore()
        ..authorization = 'Bearer account-token'
        ..udid = 'account-udid'
        ..sessionKind = 'account'
        ..accessTokenExpiry = DateTime.now().toUtc().add(
          const Duration(hours: 1),
        );
      final transport = _RecordingTransport()
        ..responses.addAll([
          _response('/articles/7/voters'),
          _response('/pins/8/reactions'),
          _response('/pins/8/reactions'),
          _response('/reaction/comments/18/like'),
          _response('/reaction/comments/18/like'),
          _response(
            '/answers/9/collections_v2',
            json: const {
              'data': [
                {'id': 73, 'is_favorited': true},
              ],
            },
          ),
          _response('/answers/9/collections_v2'),
        ]);
      final api = ZhihuApiClient(
        session,
        transport: transport,
        cloudIdSigner: _StaticCloudIdSigner(),
      );
      addTearDown(api.close);

      await api.voteContent(
        contentType: 'article',
        contentId: '7',
        voting: -1,
        voteupCount: 12,
      );
      await api.setPinLiked('8', liked: true);
      await api.setPinLiked('8', liked: false);
      await api.setCommentLiked('18', liked: true);
      await api.setCommentLiked('18', liked: false);
      await api.unfavoriteContent(contentType: 'answer', contentId: '9');

      expect(transport.calls.map((call) => call.method), [
        'POST',
        'POST',
        'DELETE',
        'POST',
        'DELETE',
        'GET',
        'PUT',
      ]);
      expect(transport.calls.map((call) => call.uri.path), [
        '/articles/7/voters',
        '/pins/8/reactions',
        '/pins/8/reactions',
        '/reaction/comments/18/like',
        '/reaction/comments/18/like',
        '/answers/9/collections_v2',
        '/answers/9/collections_v2',
      ]);
      expect(
        utf8.decode(transport.calls[0].body!),
        'voting=-1&voteup_count=12',
      );
      expect(utf8.decode(transport.calls[1].body!), 'type=like');
      expect(transport.calls[2].body, isNull);
      expect(transport.calls[3].body, isNull);
      expect(transport.calls[4].body, isNull);
      expect(
        utf8.decode(transport.calls[6].body!),
        'add_collections=&remove_collections=73',
      );
    },
  );

  test('guest session is rejected before every account mutation', () {
    final session = SessionStore()
      ..authorization = 'Bearer guest-token'
      ..udid = 'guest-udid'
      ..sessionKind = 'guest';
    final api = ZhihuApiClient(session);
    addTearDown(api.close);

    expect(
      () => api.createComment(
        contentType: 'answer',
        contentId: '123',
        content: 'x',
      ),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => api.deleteAnswer('456'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => api.deleteActivity('{"type":"answer"}'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => api.voteAnswer(answerId: '456', voting: 1, voteupCount: 0),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => api.favoriteAnswer('456'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => api.addSaltToBookshelf(
        bookListId: '123',
        propertyType: 'short_story',
      ),
      throwsA(isA<ApiTransportException>()),
    );
  });

  test('user initial URLs preserve verified query order and boundaries', () {
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);

    expect(
      api.userProfileInitialUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/profile?profile_new_version=1&'
      'profile_v4=1&has_contacts_permission=false&recommend_ab=1&scene=0',
    );
    expect(
      api.userProfileDetailUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/profile/detail?'
      'profile_new_version=1',
    );
    expect(
      api.userProfileTabsInitialUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/profile/tab',
    );
    expect(
      api.userFollowUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/followers',
    );
    expect(
      api.userUnfollowUri('abc_123', 'self_456').toString(),
      'https://api.zhihu.com/people/abc_123/followers/self_456',
    );
    expect(
      api.userFollowersInitialUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/followers?offset=0',
    );
    expect(
      api.userFolloweesInitialUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/followees?offset=0',
    );
    expect(
      api.userAnswersInitialUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/answers?'
      'order_by=created&offset=0&limit=20',
    );
    expect(
      api.userFollowingCollectionsInitialUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/following_collections?'
      'with_deleted=1&offset=0&sort=followed_at',
    );
    expect(
      api.userCollectionsInitialUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/collections_v2?'
      'with_update=1&with_deleted=1&offset=0&limit=20',
    );
    expect(
      api.collectionContentsInitialUri('123').toString(),
      'https://api.zhihu.com/collections/123/contents?with_deleted=1',
    );
    expect(
      api.userCreatedArticleFeedInitialUri('abc-123').toString(),
      'https://api.zhihu.com/people/abc-123/profile/creations/feed?'
      'type=article&limit=10&offset=0',
    );
    expect(
      api.userCreatedAnswersInitialUri('abc_123').toString(),
      'https://api.zhihu.com/unify-consumption/tabs/abc_123/answers?'
      'limit=20&order_by=created',
    );
    expect(
      api.userCreatedArticlesInitialUri('abc_123').toString(),
      'https://api.zhihu.com/unify-consumption/tabs/abc_123/articles?limit=20',
    );
    expect(
      api.userCreatedPinsInitialUri('abc_123').toString(),
      'https://api.zhihu.com/unify-consumption/tabs/abc_123/pins',
    );
    expect(
      api.userCreatedAllInitialUri('abc_123').toString(),
      'https://api.zhihu.com/moments/abc_123/origin?limit=20&sort=created',
    );
    expect(
      api.userCreatedColumnsInitialUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/columns?offset=0&limit=20',
    );
    expect(
      api.userCreatedQuestionsInitialUri('abc_123').toString(),
      'https://api.zhihu.com/people/abc_123/questions?limit=20',
    );
    expect(
      api.userCreatedVideosInitialUri('abc_123').toString(),
      'https://api.zhihu.com/unify-consumption/tabs/abc_123/zvideos',
    );
    expect(
      api.userMarkedAnswersInitialUri('abc-123').toString(),
      'https://api.zhihu.com/members/abc-123/marked-answers?limit=20',
    );
    expect(
      api.userActivitiesInitialUri('abc_123').toString(),
      'https://api.zhihu.com/moments/abc_123/activities?limit=20',
    );
    expect(
      api.userVoteupsInitialUri('abc_123').toString(),
      'https://api.zhihu.com/moments/abc_123/vote?limit=20',
    );
    expect(
      () => api.userProfileInitialUri('../abc'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => api.userFollowersInitialUri(''),
      throwsA(isA<ApiTransportException>()),
    );
  });

  test(
    'account profile helpers merge self data and normalize identity fields',
    () {
      final merged = mergeAccountProfilePayloads(
        const {
          'name': '本人',
          'gender': 0,
          'cover_url': '',
          'following_count': 11,
          'locations': [
            {'name': '河南'},
          ],
        },
        const {
          'name': '公开资料',
          'cover_url': 'https://pic.example/cover.jpg',
          'follower_count': 8,
        },
      );

      expect(merged['name'], '本人');
      expect(merged['cover_url'], 'https://pic.example/cover.jpg');
      expect(accountProfileGender(merged), '女');
      expect(accountProfileLocation(merged), '河南');
      expect(accountProfileMetric(merged, const ['follower_count']), 8);
      expect(accountProfileMetric(merged, const ['following_count']), 11);
      expect(formatAccountProfileMetric(18000), '1.8万');
    },
  );

  test('account profile detail helpers normalize birthday and account age', () {
    final created = DateTime(2024, 1, 1).millisecondsSinceEpoch ~/ 1000;
    final profile = <String, dynamic>{
      'birthday': {'year': 2000, 'month': 2, 'day': 3},
      'created_at': created,
    };

    expect(profileBirthdayText(profile), '2000-02-03');
    expect(
      profileAccountAgeText(profile, now: DateTime(2024, 7, 13)),
      '6 个月 14 天',
    );
  });

  test('account profile feed removes event and commercial rows', () {
    final rows = extractAccountProfileFeedRows({
      'data': [
        {'type': 'EVENTCARD', 'title': '知乎盐选会员 为你严选好内容'},
        {'type': 'answer', 'id': '1', 'title': '普通回答'},
        {
          'type': 'feed',
          'target': {'card_type': 'commercial'},
        },
      ],
    });

    expect(rows, hasLength(1));
    expect(rows.single['id'], '1');
  });

  test('account activity menu reads nested permission and opaque brief', () {
    final row = <String, dynamic>{
      'data': {
        'moments_biz_data': {
          'brief': '{"type":"answer","id":123}',
          'interaction': {'can_delete': true, 'can_share': true},
        },
        'target': {
          'type': 'answer',
          'id': '123',
          'question': {'id': '456'},
        },
      },
    };

    expect(accountActivityCanDelete(row), isTrue);
    expect(
      accountActivityCanDelete({
        'target': {
          'interaction': {'can_delete': true},
        },
      }),
      isFalse,
    );
    expect(accountActivityBriefOf(row), '{"type":"answer","id":123}');
    expect(
      accountActivityShareUrlOf(row),
      'https://www.zhihu.com/question/456/answer/123',
    );
  });

  test('account profile updates use official form PUT contracts', () async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..sessionKind = 'account';
    final transport = _RecordingTransport();
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: _StaticCloudIdSigner(),
    );
    addTearDown(api.close);

    await api.updateAccountProfile({
      'name': '新一',
      'headline': '',
      'gender': '0',
    });
    await api.updateAccountProfileV2(
      educations: const [
        {
          'school': '学校',
          'major': '专业',
          'entrance_year': '2020',
          'graduation_year': '2024',
          'diploma': '本科',
        },
      ],
      employments: const [],
      locations: const [
        {'address': '河南'},
      ],
    );

    expect(transport.calls, hasLength(2));
    expect(transport.calls[0].method, 'PUT');
    expect(transport.calls[0].uri.path, '/people/self');
    final basicBody = utf8.decode(transport.calls[0].body!);
    expect(basicBody, contains('headline='));
    expect(basicBody, contains('gender=0'));
    expect(Uri.splitQueryString(basicBody)['name'], '新一');
    expect(transport.calls[1].method, 'PUT');
    expect(transport.calls[1].uri.path, '/people/self/profile_v2');
    final advanced = Uri.splitQueryString(
      utf8.decode(transport.calls[1].body!),
    );
    expect(jsonDecode(advanced['locations']!) as List, [
      {'address': '河南'},
    ]);
  });

  test(
    'profile relationship and text message writes match native routes',
    () async {
      // The native FollowService passes People.id to the relationship write
      // route.  url_token is only the public profile route token; preferring
      // it here makes every follow request return HTTP 404.
      expect(
        personMemberIdOf({
          'id': 'canonical-member-id',
          'url_token': 'public-profile-token',
        }),
        'canonical-member-id',
      );
      final session = _MemorySessionStore()
        ..authorization = 'Bearer account-token'
        ..udid = 'account-udid'
        ..sessionKind = 'account'
        ..accountUid = 'self-id';
      final transport = _RecordingTransport();
      final api = ZhihuApiClient(
        session,
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
        cloudIdSigner: _StaticCloudIdSigner(),
      );
      addTearDown(api.close);

      await api.setUserFollowing('target-id', following: true);
      await api.setUserFollowing('target-id', following: false);
      await api.sendTextMessage('target-id', '  你好，测试消息  ');

      expect(transport.calls.map((call) => call.method), [
        'POST',
        'DELETE',
        'POST',
      ]);
      expect(transport.calls[0].uri.path, '/people/target-id/followers');
      expect(
        transport.calls[1].uri.path,
        '/people/target-id/followers/self-id',
      );
      expect(transport.calls[2].uri.path, '/messages');
      final messageBody = Uri.splitQueryString(
        utf8.decode(transport.calls[2].body!),
      );
      expect(messageBody['receiver_id'], 'target-id');
      expect(messageBody['content'], '你好，测试消息');
      expect(messageBody['content_type'], '0');
    },
  );

  test('public Web fallback is restricted to www /api/v4', () {
    final client = ZhihuApiClient(SessionStore());
    addTearDown(client.close);
    expect(
      client.publicWebUri('/api/v4/answers/1').toString(),
      'https://www.zhihu.com/api/v4/answers/1',
    );
    expect(
      () => client.publicWebUri('/signin'),
      throwsA(isA<ApiTransportException>()),
    );
  });

  test('Lens video metadata fallback is exact and credential-free', () async {
    final session = _MemorySessionStore()
      ..authorization = 'Bearer account-token'
      ..udid = 'account-udid'
      ..cookie = 'z_c0=private'
      ..sessionKind = 'account';
    final transport = _RecordingTransport();
    transport.responses.add(
      _response(
        '/api/v4/videos/v0200_test-7',
        statusCode: 401,
        json: const {'error': 'anonymous metadata unavailable'},
      ),
    );
    final client = ZhihuApiClient(session, transport: transport);
    addTearDown(client.close);

    expect(
      client.publicLensVideoUri('v0200_test-7').toString(),
      'https://lens.zhihu.com/api/v4/videos/v0200_test-7',
    );
    expect(
      () => client.publicLensVideoUri('../account'),
      throwsA(isA<ApiTransportException>()),
    );

    await client.publicLensVideoGet('v0200_test-7');
    expect(transport.calls, hasLength(1));
    final call = transport.calls.single;
    expect(call.method, 'GET');
    expect(call.uri.host, 'lens.zhihu.com');
    expect(call.headers.keys.map((key) => key.toLowerCase()), [
      'accept',
      'user-agent',
    ]);
    expect(call.headers.values.join(' '), isNot(contains('account-token')));
    expect(call.headers.values.join(' '), isNot(contains('account-udid')));
    expect(call.headers.values.join(' '), isNot(contains('private')));
    expect(session.authorization, 'Bearer account-token');
    expect(session.clearCalls, 0);
  });

  test('official WebView only accepts normal Zhihu HTTPS origins', () {
    expect(isAllowedOfficialNavigation('https://www.zhihu.com/signin'), isTrue);
    expect(
      isAllowedOfficialNavigation('https://zhuanlan.zhihu.com/p/1'),
      isTrue,
    );
    expect(isAllowedOfficialNavigation('http://www.zhihu.com/signin'), isFalse);
    expect(
      isAllowedOfficialNavigation('https://www.zhihu.com:444/signin'),
      isFalse,
    );
    expect(
      isAllowedOfficialNavigation('https://user@www.zhihu.com/signin'),
      isFalse,
    );
    expect(
      isAllowedOfficialNavigation('https://zhihu.com.evil.test/signin'),
      isFalse,
    );
    expect(
      isOfficialLoginNavigation('https://www.zhihu.com/signin?next=%2F'),
      isTrue,
    );
    expect(
      isOfficialLoginNavigation('https://www.zhihu.com/account/unhuman'),
      isTrue,
    );
    expect(
      isOfficialLoginNavigation('https://www.zhihu.com/account/settings'),
      isFalse,
    );
  });

  test(
    'official WebView cookie parser preserves Zhihu credential wire value',
    () {
      final cookies = parseOfficialCookieHeader(
        'z_c0=2|1:0|10:test|4:z_c0|92:value|signature; '
        '_xsrf=test-value; ignored; z_c0=duplicate',
      );
      expect(cookies.map((cookie) => cookie.name), ['z_c0', '_xsrf']);
      expect(cookies.first.value, '2|1:0|10:test|4:z_c0|92:value|signature');
    },
  );

  test(
    'notification writes use readall and serialized form contracts',
    () async {
      final session = _MemorySessionStore()
        ..authorization = 'Bearer account-token'
        ..udid = 'account-udid'
        ..sessionKind = 'account';
      final transport = _RecordingTransport();
      final api = ZhihuApiClient(
        session,
        transport: transport,
        xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
        cloudIdSigner: _StaticCloudIdSigner(),
      );
      addTearDown(api.close);

      await api.markAllNotificationsRead();
      await api.markNotificationEntryRead('comment');
      await api.updateNotificationSettings({
        'comment_me': {'type': 'noti_setting', 'switch': false, 'scope': 'all'},
        'message_recv': {'switch': true, 'scope': 'all'},
      });

      expect(transport.calls.map((call) => call.method), [
        'POST',
        'POST',
        'PUT',
      ]);
      expect(transport.calls[0].uri.path, '/notifications/v3/message/readall');
      expect(
        transport.calls[1].uri.path,
        '/notifications/v3/timeline/entry/comment/actions/readall',
      );
      expect(transport.calls[2].uri.path, '/settings/new/notification');
      final fields = Uri.splitQueryString(
        utf8.decode(transport.calls[2].body!),
      );
      expect(jsonDecode(fields['comment_me']!), {
        'switch': false,
        'scope': 'all',
      });
      expect(jsonDecode(fields['message_recv']!), {
        'switch': true,
        'scope': 'all',
      });
    },
  );

  test('manual path identifiers cannot inject route separators', () {
    expect(isDecimalContentId('1234567890'), isTrue);
    expect(isDecimalContentId('1/answers'), isFalse);
    expect(isDecimalContentId(''), isFalse);
    expect(isColumnToken('hackers'), isTrue);
    expect(isColumnToken('column_name-1'), isTrue);
    expect(isColumnToken('../people'), isFalse);
  });
}
