part of '../core_test.dart';

void registerLoginSignatureTests() {
  testWidgets('native login starts with a full-width animated phone step', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(NativeLoginPage(session: SessionStore())));
    expect(find.text('登录知乎'), findsOneWidget);
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
    expect(find.byType(ZhBrandMark), findsOneWidget);
    expect(find.byKey(const ValueKey('login-phone-step')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-code-step')), findsNothing);
    expect(find.text('原生手机号登录'), findsNothing);
    expect(find.text('ANDROID 11.4.0'), findsNothing);
    expect(find.text('已核对的移动契约'), findsNothing);
    expect(find.textContaining('/api/account/prod/'), findsNothing);
    expect(find.text('网页登录'), findsNothing);
  });

  testWidgets('native login asks for agreement before requesting digits', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(NativeLoginPage(session: SessionStore())));
    await tester.enterText(
      find.byKey(const ValueKey('login-phone-input')),
      '+8613812345678',
    );
    await tester.tap(find.text('获取验证码'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('login-agreement-dialog')),
      findsOneWidget,
    );
    expect(find.text('登录前请确认'), findsOneWidget);
    expect(find.text('暂不同意'), findsOneWidget);
    expect(find.text('同意并继续'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login-agreement-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('login-agreement-dialog')), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(find.byKey(const ValueKey('login-busy')), findsNothing);
  });

  testWidgets('native login code step uses the compact pill input', (
    tester,
  ) async {
    final session = SessionStore()
      ..authorization = 'Bearer guest-token'
      ..udid = 'guest-udid'
      ..sessionKind = 'guest';
    final transport = _RecordingTransport()
      ..responses.addAll([
        _response('/captcha', json: const {'show_captcha': false}),
        _response(
          MobileLoginContract.requestDigitsPath,
          json: const {'success': true},
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
    await tester.pumpWidget(
      _testApp(NativeLoginPage(session: session, api: api)),
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-phone-input')),
      '+8613812345678',
    );
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('获取验证码'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-code-step')), findsOneWidget);
    expect(find.textContaining('验证码已发送至'), findsOneWidget);
    expect(find.text('输入 6 位验证码'), findsOneWidget);
    expect(find.text('更换手机号'), findsOneWidget);
    expect(find.text('继续登录'), findsOneWidget);
    expect(transport.calls, hasLength(2));
  });

  test('login phone masking preserves the useful edges', () {
    expect(maskLoginPhone('+86 138-1234-5678'), '+86138****5678');
    expect(maskLoginPhone('123456'), '123456');
  });

  test('request signature is sent only to its exact method path and query', () {
    final session = SessionStore()
      ..authorization = 'Bearer test'
      ..msId = 'msid-test'
      ..xZse96 = '2.0_test'
      ..xZse96Target = 'GET /search_v3?q=flutter&offset=0';
    final matching = session.requestHeaders(
      method: 'GET',
      uri: Uri.parse('https://api.zhihu.com/search_v3?q=flutter&offset=0'),
    );
    expect(matching['Authorization'], 'Bearer test');
    expect(matching['X-MS-ID'], 'msid-test');
    expect(matching['X-Zse-96'], '2.0_test');
    expect(
      session.requestHeaders(
        method: 'GET',
        uri: Uri.parse('https://api.zhihu.com/search_v3?offset=0&q=flutter'),
      ),
      isNot(contains('X-Zse-96')),
    );
    expect(
      session.requestHeaders(
        method: 'POST',
        uri: Uri.parse('https://api.zhihu.com/search_v3?q=flutter&offset=0'),
      ),
      isNot(contains('X-Zse-96')),
    );
  });

  test('X-Zse preimage preserves encoded target and field order', () {
    final uri = Uri.parse('https://api.zhihu.com/a%20b?b=1&a=2');
    expect(XZseSigner.encodedRequestTarget(uri), '/a%20b?b=1&a=2');
    final preimage = XZseSigner.buildPreimage(
      uri: uri,
      headers: {
        'X-Zse-93': '101_1_1.0',
        'x-api-version': '3.0.89',
        'x-app-version': '11.4.0',
        'Authorization': 'Bearer token',
        'x-udid': 'udid',
      },
      body: utf8.encode('{"x":1}'),
    );
    expect(
      preimage,
      '101_1_1.0+/a%20b?b=1&a=2+11.4.0+Bearer token+udid+{"x":1}',
    );
  });

  test('CloudID form body is sorted and skips empty string values', () {
    expect(
      CloudIdSigner.formEncode({
        'zx_zid': '',
        'ph_md': 'Pixel 6',
        'app_build': 40408,
        'additional_oaid': null,
        'android_id': 'a+b',
      }),
      'android_id=a%2Bb&app_build=40408&ph_md=Pixel+6',
    );
  });

  test('CloudID signing reproduces the APK HMAC-SHA1 contract', () async {
    final signer = CloudIdSigner();

    expect(
      await signer.sign(body: 'a=1', requestTimestamp: '1700000000'),
      '4f8179de3b9a2746c6012fcef8b06be455b39b40',
    );
    expect(
      await signer.sign(
        body: 'a=1',
        requestTimestamp: '1700000000',
        udid: 'udid-xyz',
      ),
      '020fd27728b7f704156701275599edd5a31bb21f',
    );
  });

  test('anonymous GET uses OAuth and X-Zse before guest bootstrap', () async {
    final transport = _RecordingTransport();
    final cloudId = _CountingCloudIdSigner();
    final client = ZhihuApiClient(
      SessionStore(),
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
      cloudIdSigner: cloudId,
    );
    addTearDown(client.close);

    final response = await client.get('/root/tab/v2');

    expect(response.statusCode, 200);
    expect(transport.requests, hasLength(1));
    final headers = transport.requests.single;
    expect(headers['Authorization'], CloudIdSigner.oauthAuthorization);
    expect(headers, isNot(contains('x-udid')));
    expect(headers['x-b3-traceid'], matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(headers['X-Zse-96'], hasLength(68));
    expect(cloudId.deviceInfoCalls, 0);
    expect(cloudId.signCalls, 0);
  });

  test('OAuth-only debug probe ignores an imported guest session', () async {
    final session = SessionStore()
      ..authorization = 'Bearer stale-guest'
      ..udid = 'stale-udid'
      ..cookie = 'z_c0=stale';
    final transport = _RecordingTransport();
    final client = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(client.close);

    final response = await client.debugGetUriWithOauthOnly(
      client.apiUri('/questions/7/feeds?offset=0'),
      headers: const {'x-api-version': '3.0.89', 'x-ad-styles': ''},
    );

    expect(response.statusCode, 200);
    final sent = transport.requests.single;
    expect(sent['Authorization'], CloudIdSigner.oauthAuthorization);
    expect(sent, isNot(contains('x-udid')));
    expect(sent, isNot(contains('Cookie')));
    expect(sent['X-Zse-96'], hasLength(68));
  });

  test('dynamic X-Zse signing overwrites stale manual signature', () async {
    final cipher = _FakeXZseCipher();
    final signer = XZseSigner(cipher: cipher);
    final uri = Uri.parse('https://api.zhihu.com/questions/7/feeds?offset=0');
    final signed = await signer.signHeaders(
      uri: uri,
      headers: {
        'x-zse-93': 'stale-version',
        'X-Zse-96': '1.0_stale',
        'x-api-version': '3.0.89',
        'x-app-version': '11.4.0',
        'Authorization': 'Bearer token',
        'x-udid': 'udid',
      },
    );
    final expectedPreimage =
        '101_1_1.0+/questions/7/feeds?offset=0+11.4.0+Bearer token+udid';
    expect(
      cipher.lastMd5Lower,
      md5.convert(utf8.encode(expectedPreimage)).toString(),
    );
    expect(signed['X-Zse-93'], '101_1_1.0');
    expect(
      signed.keys.where((key) => key.toLowerCase() == 'x-zse-93'),
      hasLength(1),
    );
    expect(signed['X-Zse-96'], startsWith('1.0_'));
    expect(signed['X-Zse-96'], isNot('1.0_stale'));
    expect(signed['X-Zse-96']!.length, 68);
  });

  test('signature target validation preserves exact query ordering', () {
    expect(
      SessionStore.normalizeSignatureTarget('get /a?b=1&a=2'),
      'GET /a?b=1&a=2',
    );
    expect(
      () => SessionStore.normalizeSignatureTarget('GET https://evil.test/a'),
      throwsFormatException,
    );
  });

  test('paging URL is restricted to HTTPS api.zhihu.com', () {
    final client = ZhihuApiClient(SessionStore());
    addTearDown(client.close);
    expect(
      client
          .validatePagingUri('https://api.zhihu.com/search_v3?offset=10')
          .host,
      ZhihuApiClient.apiHost,
    );
    expect(
      () => client.validatePagingUri('https://example.com/search_v3'),
      throwsA(isA<Exception>()),
    );
    expect(
      () => client.validatePagingUri('http://api.zhihu.com/search_v3'),
      throwsA(isA<Exception>()),
    );
  });

  test('home channel URLs preserve APK and capture contracts', () {
    final client = ZhihuApiClient(SessionStore());
    addTearDown(client.close);
    expect(
      client.followingFeedInitialUri().toString(),
      'https://api.zhihu.com/moments_v3?feed_type=all',
    );
    expect(
      client.hotListInitialUri().toString(),
      'https://api.zhihu.com/topstory/hot-lists/total'
      '?limit=10&is_browse_model=0&new_hot_list=false',
    );
    expect(
      client.recommendationFeedInitialUri().toString(),
      'https://api.zhihu.com/topstory/recommend?'
      'tsp_ad_cardredesign=0&feed_card_exp=card_corner%7C1&v_serial=1&'
      'isDoubleFlow=0&action=down&refresh_scene=0&scroll=&limit=10&'
      'start_type=cold&device=android&short_container_setting_value=0&'
      'include_guide_relation=false&interest_tags=&is_feed_first_request=1',
    );
    expect(
      () => client.followingFeedInitialUri(feedType: '../all'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      client.followingFeedInitialUri(feedType: '精选').toString(),
      'https://api.zhihu.com/moments_v3?feed_type=%E7%B2%BE%E9%80%89',
    );
    expect(
      client.followingMostVisitedInitialUri().toString(),
      'https://api.zhihu.com/moments/recent?type=raw',
    );
  });

  test('route profiles preserve official headers across paging URLs', () {
    final client = ZhihuApiClient(SessionStore());
    addTearDown(client.close);

    expect(
      client.officialRouteHeaders(
        Uri.parse('https://api.zhihu.com/questions/7/feeds?offset=20'),
      ),
      const {'x-api-version': '3.0.89', 'x-ad-styles': ''},
    );
    expect(
      client.officialRouteHeaders(
        Uri.parse(
          'https://api.zhihu.com/people/abc/following_collections?offset=20',
        ),
      ),
      const {'x-api-version': '3.0.94'},
    );
    expect(
      client.officialRouteHeaders(
        Uri.parse('https://api.zhihu.com/search_v3?offset=20'),
      ),
      const {'x-api-version': '3.0.91'},
    );
    expect(
      client.officialRouteHeaders(
        Uri.parse('https://api.zhihu.com/topstory/recommend?page_number=2'),
      ),
      const {
        'x-api-version': '3.1.8',
        'x-close-recommend': '0',
        'x-ad-styles': '',
        'x-feed-prefetch': '0',
      },
    );
    expect(
      client.officialRouteHeaders(Uri.parse('https://api.zhihu.com/topics/7')),
      isEmpty,
    );
  });

  test('question feeds initial URL matches official 11.4.0 runtime contract', () {
    final client = ZhihuApiClient(SessionStore());
    addTearDown(client.close);
    final uri = client.questionFeedsInitialUri('7');
    expect(
      uri.query,
      'include=big_card_summary,media_detail,reaction_instruction,is_author,is_thanked,voting,is_favorited,label_info,content_text_length,reactions&order=default&show_detail=1',
    );
    expect(uri.queryParameters.keys, ['include', 'order', 'show_detail']);
    expect(
      () => client.questionFeedsInitialUri('../7'),
      throwsA(isA<ApiTransportException>()),
    );

    expect(
      client.questionAnswersInitialUri('7').toString(),
      'https://api.zhihu.com/v4/questions/7/answers?'
      'sort_by=default&show_detail=1',
    );
    final accountClient = ZhihuApiClient(
      _MemorySessionStore()
        ..authorization = 'Bearer account-token'
        ..udid = 'account-udid'
        ..sessionKind = 'account',
    );
    addTearDown(accountClient.close);
    expect(accountClient.questionAnswersInitialUri('7'), uri);
  });

  test('salt reader URLs match authorized official 11.4.0 contracts', () {
    final client = ZhihuApiClient(SessionStore());
    addTearDown(client.close);

    expect(
      client.saltStoryHomeUri().toString(),
      'https://api.zhihu.com/km-vip-zhihu-web/vip_tab/svip_story',
    );
    expect(
      client.saltBookshelfUri(offset: 20, limit: 20).toString(),
      'https://api.zhihu.com/km-vip-zhihu-web/vip_tab/member/like_list?'
      'type=vip_pin&offset=20&limit=20',
    );
    expect(
      client.saltStoryCategoriesUri().toString(),
      'https://api.zhihu.com/pluton/category/story/header',
    );
    expect(
      client.saltCatalogInitialUri(wellId: '123').toString(),
      'https://api.zhihu.com/km-indep-home-comm/catalog/123?after_id=0&'
      'include_search_id=1&need_boundary=1&limit=20&scene=manuscript',
    );
    expect(
      client.saltCatalogBoundaryUri(wellId: '123', beforeId: '456').toString(),
      'https://api.zhihu.com/km-indep-home-comm/catalog/123?before_id=456&'
      'include_search_id=1&need_boundary=1&limit=20&scene=manuscript',
    );
    expect(
      client.saltWorkSectionListUri('123').toString(),
      'https://api.zhihu.com/km-indep-home-comm/work/123/section_list',
    );
    expect(
      client.saltProgressUri('123').toString(),
      'https://api.zhihu.com/km-indep-home-comm/progress/123?scene=manuscript',
    );
    expect(
      client.saltManuCacheUri(businessId: '123', sectionId: '456').toString(),
      'https://api.zhihu.com/remix-pre-web/manuscript/123/456/manu_cache?'
      'is_mid_long=true',
    );
    expect(
      client.saltManuCoreUri(businessId: '123', sectionId: '456').toString(),
      'https://api.zhihu.com/remix-pre-web/manuscript/123/456/manu_core?'
      'transmission=&window_width=411&zs_page_turn=0&is_mid_long=true',
    );
    expect(
      client.saltArticleCodeUri().toString(),
      'https://api.zhihu.com/remix-pre-web/manuscript/code',
    );
    expect(
      client.saltAnnotationsUri(sectionId: '456').toString(),
      'https://api.zhihu.com/remix-pre-web/manuscript/annotations?section_id=456',
    );
    expect(
      client
          .saltCommentsInitialUri(
            objectType: ZhihuApiClient.saltParagraphCommentObjectType,
            objectId: '789',
          )
          .toString(),
      'https://api.zhihu.com/comment_v5/doc_sections/789/'
      'root_comment?order_by=score&type=',
    );
    expect(
      client
          .saltCommentsInitialUri(
            objectType: 'manuscript',
            objectId: '789',
            orderBy: 'ts',
          )
          .toString(),
      'https://api.zhihu.com/comment_v5/manuscript/789/'
      'root_comment?order_by=ts&type=',
    );
    expect(
      client
          .saltCommentsInitialUri(
            objectType: 'paid_column_section_manuscript',
            objectId: '789',
            orderBy: 'hot',
          )
          .toString(),
      'https://api.zhihu.com/km-indep-home-vip-comment/'
      'paid_column_section_manuscripts/789/root_comment?'
      'order_by=voteup_count&limit=20&offset=&source=',
    );
    expect(
      () => client.saltAnnotationsUri(sectionId: '../456'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => client.saltCommentsInitialUri(
        objectType: '../manuscript',
        objectId: '789',
      ),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => client.saltCatalogInitialUri(wellId: '../123'),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => client.saltCatalogBoundaryUri(
        wellId: '123',
        afterId: '456',
        beforeId: '789',
      ),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => client.saltBookshelfUri(offset: -1),
      throwsA(isA<ApiTransportException>()),
    );
    expect(
      () => client.saltBookshelfUri(limit: 101),
      throwsA(isA<ApiTransportException>()),
    );
  });

  test('debug Salt relay proxy is restricted to audited API prefixes', () {
    expect(
      ApiTransport.isApprovedSaltRelayTarget(
        Uri.parse('https://api.zhihu.com/km-indep-home-comm/catalog/123'),
      ),
      isTrue,
    );
    expect(
      ApiTransport.isApprovedSaltRelayTarget(
        Uri.parse(
          'https://api.zhihu.com/remix-pre-web/manuscript/1/2/manu_core',
        ),
      ),
      isTrue,
    );
    expect(
      ApiTransport.isApprovedSaltRelayTarget(
        Uri.parse(
          'https://api.zhihu.com/km-indep-home-vip-comment/'
          'paid_column_section_manuscripts/1/root_comment',
        ),
      ),
      isTrue,
    );
    expect(
      ApiTransport.isApprovedSaltRelayTarget(
        Uri.parse('https://api.zhihu.com/questions/1/feeds'),
      ),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedSaltRelayTarget(
        Uri.parse('https://example.com/km-indep-home-comm/catalog/123'),
      ),
      isFalse,
    );
    final contentUri = Uri.parse(
      'https://api.zhihu.com/remix-pre-web/manuscript/123/456/content'
      '?window_width=411',
    );
    expect(
      ApiTransport.isApprovedSaltRelayRequest('POST', contentUri, [1]),
      isTrue,
    );
    expect(
      ApiTransport.isApprovedSaltRelayRequest('POST', contentUri, null),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedSaltRelayRequest(
        'POST',
        Uri.parse(
          'https://api.zhihu.com/remix-pre-web/manuscript/123/456/manu_core',
        ),
        [1],
      ),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedSaltRelayRequest('DELETE', contentUri, null),
      isFalse,
    );
  });

  test('debug login capture proxy is restricted to Zhihu mobile HTTPS', () {
    final signIn = Uri.parse('https://api.zhihu.com/api/account/prod/sign_in');
    expect(ApiTransport.isApprovedLoginCaptureTarget(signIn), isTrue);
    expect(
      ApiTransport.isApprovedLoginCaptureRequest('POST', signIn, [1, 2, 3]),
      isTrue,
    );
    expect(
      ApiTransport.isApprovedLoginCaptureRequest('POST', signIn, null),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedLoginCaptureRequest('DELETE', signIn, null),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedLoginCaptureTarget(
        Uri.parse('https://api.zhihu.com/people/self'),
      ),
      isTrue,
    );
    expect(
      ApiTransport.isApprovedLoginCaptureTarget(
        Uri.parse('https://www.zhihu.com/api/v4/people/self'),
      ),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedLoginCaptureTarget(
        Uri.parse('http://api.zhihu.com/api/account/prod/sign_in'),
      ),
      isFalse,
    );
  });

  test('Android native HTTP transport is restricted to audited HTTPS', () {
    final nativeApi = Uri.parse('https://api.zhihu.com/questions/7');
    final nativeCloud = Uri.parse('https://appcloud.zhihu.com/v1/device');
    final nativeWeb = Uri.parse('https://www.zhihu.com/api/v4/questions/7');
    final nativeLens = Uri.parse(
      'https://lens.zhihu.com/api/v4/videos/v0200_test-7',
    );
    expect(ApiTransport.isApprovedNativeHttpTarget(nativeApi), isTrue);
    expect(ApiTransport.isApprovedNativeHttpTarget(nativeCloud), isTrue);
    expect(ApiTransport.isApprovedNativeHttpTarget(nativeWeb), isTrue);
    expect(ApiTransport.isApprovedNativeHttpTarget(nativeLens), isTrue);
    expect(
      ApiTransport.isApprovedNativeHttpTarget(
        Uri.parse('https://www.zhihu.com/signin'),
      ),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedNativeHttpTarget(
        Uri.parse('https://api.zhihu.com.evil.test/questions/7'),
      ),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedNativeHttpRequest('GET', nativeApi, null),
      isTrue,
    );
    expect(
      ApiTransport.isApprovedNativeHttpRequest('GET', nativeApi, [1]),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedNativeHttpRequest('TRACE', nativeApi, null),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedNativeHttpRequest('GET', nativeLens, null),
      isTrue,
    );
    expect(
      ApiTransport.isApprovedNativeHttpRequest('POST', nativeLens, [1]),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedNativeHttpTarget(
        Uri.parse('https://lens.zhihu.com/api/v4/videos/../account'),
      ),
      isFalse,
    );
    expect(
      ApiTransport.isApprovedNativeHttpTarget(
        Uri.parse('https://lens.zhihu.com/api/v4/upload_token'),
      ),
      isFalse,
    );
  });

  test(
    'search initial URL matches official 11.4.0 anonymous runtime query',
    () {
      final api = ZhihuApiClient(SessionStore());
      addTearDown(api.close);
      final uri = api.searchInitialUri(keyword: 'flutter sdk', type: 'general');

      expect(
        uri.toString(),
        'https://api.zhihu.com/search_v3?gk_version=gz-gaokao&'
        'q=flutter%20sdk&t=general&search_source=Normal&is_real_time=0&'
        'correction=1&advert_count=&show_all_topics=0&pin_flow=false&'
        'restricted_scene=&restricted_field=&restricted_value=&entry=main&'
        'offset=0&limit=20&lc_idx=0&zhida_source=ai_search_general',
      );
      expect(ZhihuApiClient.newSearchId(), matches(RegExp(r'^[0-9a-f]{32}$')));

      final recent = api.searchInitialUri(
        keyword: 'flutter sdk',
        type: 'recent',
      );
      expect(recent.queryParameters['t'], 'general');
      expect(recent.queryParameters['is_real_time'], '1');
    },
  );

  test('search filters append official group names in stable order', () {
    final api = ZhihuApiClient(SessionStore());
    addTearDown(api.close);
    final uri = api.searchInitialUri(
      keyword: 'flutter',
      type: 'general',
      filters: const {
        'time_interval': 'a_month',
        'sort': 'upvoted_count',
        'vertical': 'answer',
      },
    );

    expect(uri.toString(), contains('&search_source=Filter&'));
    expect(
      uri.toString(),
      endsWith(
        '&lc_idx=0&vertical=answer&sort=upvoted_count&'
        'time_interval=a_month&zhida_source=ai_search_general',
      ),
    );
    expect(api.searchCustomizeUri().path, '/search/customize');
  });
}
