part of '../core_test.dart';

void registerSaltModelTests() {
  test('salt catalog prefetch derives every remaining official offset', () {
    final uris = saltCatalogRemainingPageUris(const {
      'paging': {
        'is_end': false,
        'total': 75,
        'limit': 20,
        'next':
            'https://api.zhihu.com/km-indep-home-comm/catalog/123?after_id=0&include_search_id=1&limit=20&need_boundary=1&offset=20&scene=manuscript',
      },
    });
    expect(uris, hasLength(3));
    expect(uris.map((uri) => uri.queryParameters['offset']), [
      '20',
      '40',
      '60',
    ]);
    expect(uris.first.query, contains('after_id=0&include_search_id=1'));
    expect(uris.first.query, contains('offset=20&scene=manuscript'));
  });

  test('salt catalog snapshot expires after one hour', () {
    final fetchedAt = DateTime.utc(2026, 8, 23, 10);
    final snapshot = SaltCatalogSnapshot(
      businessId: '123',
      root: const {
        'data': <Object>[],
        'paging': {'total': 0},
      },
      fetchedAt: fetchedAt,
    );
    expect(
      snapshot.isFreshAt(fetchedAt.add(const Duration(minutes: 59))),
      isTrue,
    );
    expect(
      snapshot.isFreshAt(fetchedAt.add(const Duration(hours: 1))),
      isFalse,
    );
  });

  test('salt catalog unwraps nested gateway metadata envelope', () {
    final root = saltCatalogResponseRoot(const {
      'data': {
        'author': {'head': 'https://img.example/a.jpg', 'nickname': '作者'},
        'parent': {'title': '嵌套作品'},
        'data': [
          {'section_id': '1', 'title': '第一节'},
        ],
        'paging': {'total': 1},
      },
    });
    expect(root['parent'], containsPair('title', '嵌套作品'));
    expect(root['author'], containsPair('nickname', '作者'));
    expect(saltCatalogRows(root), hasLength(1));
  });

  test('salt catalog cache rows omit details and preserve chapter order', () {
    final rows = saltCatalogRows(const {
      'data': [
        {'section_id': '300', 'global_idx': 2},
        {'section_id': '0', 'global_idx': 0, 'title': '详情'},
        {'section_id': '100', 'global_idx': 0},
        {'section_id': '200', 'global_idx': 1},
      ],
    });
    expect(rows.map((row) => row['section_id']), ['100', '200', '300']);
  });

  test('salt work section-list fallback becomes a readable catalog', () {
    final root = saltCatalogRootFromWorkSectionList({
      'data': [
        {'section_id': '900', 'work_id': '123', 'title': '后续', 'is_lock': true},
        {'section_id': '800', 'work_id': '123', 'title': '开篇'},
      ],
      'is_finished': true,
    });
    expect(root['paging'], containsPair('total', 2));
    expect(saltCatalogRows(root).map((row) => row['section_id']), [
      '900',
      '800',
    ]);
    expect(saltCatalogRows(root).first['is_lock'], isTrue);
  });

  testWidgets('long Salt detail exposes bookshelf and chapter export menu', (
    tester,
  ) async {
    final transport = _RecordingTransport()
      ..responses.add(
        _response(
          '/km-indep-home-comm/catalog/123',
          json: const {
            'author': {
              'head': 'https://img.example/author.jpg',
              'nickname': '作者甲',
            },
            'parent': {
              'title': '长篇测试',
              'artwork': 'https://img.example/cover.jpg',
              'sub_title': '已完结，共 1 节',
              'introduction': '这是一段作品简介',
              'type_name': '长篇',
              'is_long': true,
              'xxxxxxxx_total': 1,
            },
            'data': [
              {
                'section_id': '456',
                'title': '第一节',
                'serial_number_text': '第 1 节',
                'has_tts': true,
              },
            ],
            'paging': {'is_end': true},
          },
        ),
      )
      ..responses.add(
        _response(
          '/km-indep-home-comm/catalog/123',
          json: const {
            'author': {
              'head': 'https://img.example/author.jpg',
              'nickname': '作者甲',
            },
            'parent': {
              'title': '长篇测试',
              'artwork': 'https://img.example/cover.jpg',
              'sub_title': '已完结，共 1 节',
              'introduction': '这是一段作品简介',
              'type_name': '长篇',
              'is_long': true,
              'xxxxxxxx_total': 1,
            },
            'data': [
              {
                'section_id': '456',
                'title': '第一节',
                'serial_number_text': '第 1 节',
                'has_tts': true,
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
        SaltProductPage(
          api: api,
          businessId: '123',
          businessType: 'paid_column',
          title: '长篇测试',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('加入书架'), findsOneWidget);
    expect(find.text('开始阅读'), findsOneWidget);
    expect(find.text('作者甲'), findsOneWidget);
    expect(find.text('这是一段作品简介'), findsOneWidget);
    expect(find.text('可听'), findsNothing);
    await tester.tap(find.byTooltip('更多'));
    await tester.pumpAndSettle();
    expect(find.text('下载 / 导出 TXT'), findsOneWidget);
    expect(find.text('下载 / 导出 DOCX'), findsOneWidget);
    await tester.tap(find.text('下载 / 导出 TXT'));
    await tester.pumpAndSettle();
    expect(find.text('目录'), findsWidgets);
    expect(find.text('正序'), findsNWidgets(2));
    expect(find.text('倒序'), findsNWidgets(2));
    expect(find.text('已选 0/1'), findsOneWidget);
    await tester.tap(find.text('全选'));
    await tester.pump();
    expect(find.text('已选 1/1'), findsOneWidget);
    expect(find.text('导出 TXT · 1 章'), findsOneWidget);
  });

  test('salt story home flattens all live 11.4.0 module shapes', () {
    final rows = extractSaltStoryRows({
      'data': [
        {
          'card_type': 'tab_nav',
          'module_type': 'tab_nav',
          'module_data': {
            'data': {
              'title': '快捷入口',
              'items': [
                {
                  'card_type': 'bookshelf',
                  'title': '书架',
                  'url': 'zhihu://market/bookshelf',
                },
              ],
            },
          },
        },
        {
          'card_type': 'must_see',
          'module_type': 'must_see',
          'module_data': {
            'data': {
              'content_list': [
                {
                  'business_id': 'work-1',
                  'business_type': 'PaidColumn',
                  'title': '作品一',
                  'description': '作品简介',
                  'like_count': 12,
                },
              ],
            },
          },
        },
        {
          'card_type': 'billboard',
          'module_type': 'billboard',
          'module_data': {
            'data': {
              'data': [
                {
                  'head': {'title': '热榜', 'type': 'hot'},
                  'content_list': [
                    {
                      'business_id': 'work-2',
                      'business_type': 'PaidColumn',
                      'title': '作品二',
                    },
                  ],
                },
              ],
            },
          },
        },
      ],
    });

    expect(rows, hasLength(3));
    expect(rows[0]['_salt_module_type'], 'tab_nav');
    expect(rows[0]['_salt_module_title'], '快捷入口');
    expect(rows[1]['business_id'], 'work-1');
    expect(rows[1]['description'], '作品简介');
    expect(rows[2]['_salt_group_title'], '热榜');
    expect(rows[2]['_salt_group_first'], isTrue);
  });

  test('salt story question links stay on the native question route', () {
    expect(
      saltQuestionIdFromUrl(
        'https://www.zhihu.com/question/519375757/answer/123456789',
      ),
      '519375757',
    );
    expect(saltQuestionIdFromUrl('zhihu://question/519375757'), '519375757');
    expect(
      saltQuestionIdFromUrl('https://www.zhihu.com/question/not-a-number'),
      isNull,
    );
    expect(
      saltQuestionIdFromUrl('https://www.zhihu.com/market/manuscript/1'),
      isNull,
    );
  });

  test(
    'salt story categories keep PageItem fields instead of becoming empty',
    () {
      final rows = extractSaltStoryCategoryItems({
        'data': [
          {
            'category_cn': '言情',
            'category_name': 'romance',
            'background': 'https://img.example/romance.jpg',
            'banner': 'https://img.example/romance-banner.jpg',
            'url': 'https://www.zhihu.com/appview/category/romance',
          },
        ],
      });
      expect(rows, hasLength(1));
      expect(rows.single['title'], '言情');
      expect(rows.single['subtitle'], 'romance');
      expect(rows.single['url'], contains('/category/romance'));
    },
  );

  test('salt story categories unwrap nested object-list envelopes', () {
    final rows = extractSaltStoryCategoryItems({
      'data': {
        'items': [
          {
            'category_cn': '悬疑',
            'category_name': 'mystery',
            'url': 'https://www.zhihu.com/appview/category/mystery',
          },
        ],
      },
    });
    expect(rows, hasLength(1));
    expect(rows.single['title'], '悬疑');
    expect(rows.single['subtitle'], 'mystery');
  });

  test('salt book-city conditions flatten nested category choices', () {
    final rows = extractSaltBookCityCategoryItems({
      'data': {
        'tags': [
          {
            'tag_type': 'romance',
            'tag_title': '题材',
            'categories': [
              {'title': '现代言情', 'value': 'modern'},
              {'title': '古代言情', 'value': 'ancient'},
            ],
          },
        ],
      },
    });
    expect(rows.map((row) => row['title']), ['现代言情', '古代言情']);
    expect(rows.map((row) => row['_salt_tag_type']), ['romance', 'romance']);
  });

  test(
    'salt book-city conditions flatten real category groups and filters',
    () {
      final rows = extractSaltBookCityCategoryItems({
        'tags': [
          {
            'tag_type': 'story',
            'tag_title': '题材',
            'categories': [
              {
                'key': 'category',
                'value': 'all',
                'title': '分类',
                'data': [
                  {'key': 'romance', 'value': 'modern', 'show_text': '现代言情'},
                ],
              },
            ],
          },
        ],
      });
      expect(rows, hasLength(1));
      expect(rows.single['title'], '现代言情');
      expect(rows.single['_salt_tag_type'], 'story');
      expect(rows.single['_salt_parent_key'], 'category');
      expect(rows.single['_salt_filter_query'], {
        'category': 'all',
        'romance': 'modern',
      });
    },
  );

  test('salt book-city conditions preserve quick filters and sorts', () {
    final rows = extractSaltBookCityCategoryItems({
      'tags': [
        {
          'tag_type': 'story',
          'tag_title': '故事',
          'quick_filters': [
            {'key': 'is_free', 'value': '1', 'title': '免费'},
          ],
          'sorts': [
            {'key': 'sort', 'value': 'latest', 'title': '最新'},
          ],
        },
      ],
    });
    expect(rows.map((row) => row['title']), ['免费', '最新']);
    expect(rows.map((row) => row['_salt_condition_role']), ['quick', 'sort']);
    expect(rows.first['_salt_filter_query'], {'is_free': '1'});
    expect(rows.last['_salt_filter_query'], {'sort': 'latest'});
  });

  test('salt long-story discovery unwraps Pin and EveryoneWatch payloads', () {
    final rows = extractSaltLongStoryRows({
      'data': [
        {
          'module_type': 'pin',
          'card_type': 'pin_stagger',
          'module_data': {
            'data': {
              'data': {
                'business_id': 'work-1',
                'business_type': 'PaidColumn',
                'title': '长篇作品',
                'artwork': 'https://img.example/work.jpg',
                'like_count': '1.2万',
                'url':
                    'https://www.zhihu.com/market/manuscript?business_id=work-1',
              },
            },
          },
        },
        {
          'module_data': {
            'data': {
              'data': {
                'business_id': 'work-2',
                'title': '大家在看',
                'artwork': 'https://img.example/watch.jpg',
                'description': '作品简介',
                'producer': '作者',
                'labels': ['悬疑'],
                'like_count': '325',
              },
            },
          },
        },
      ],
      'paging': {'is_end': true},
    });
    expect(rows, hasLength(2));
    expect(rows.first['business_id'], 'work-1');
    expect(rows.first['like_count'], '1.2万');
    expect(rows.last['description'], '作品简介');
    expect(rows.last['producer_name'], '作者');
    expect(rows.last['labels'], ['悬疑']);
  });

  test('salt story navigation distinguishes short and long works', () {
    final short = parseSaltStoryNavigation({
      'url': 'https://www.zhihu.com/market/paid_column/123456/section/789012',
    });
    expect(short?.businessId, '123456');
    expect(short?.sectionId, '789012');
    expect(short?.opensReader, isTrue);

    final long = parseSaltStoryNavigation({
      'url':
          'https://www.zhihu.com/market/manuscript?business_id=345678'
          '&is_mid_long=true&sku_type=paid_column',
    });
    expect(long?.businessId, '345678');
    expect(long?.sectionId, isNull);
    expect(long?.opensReader, isFalse);
    expect(
      officialSaltSectionUrl(businessId: '123456', sectionId: '789012'),
      'https://www.zhihu.com/market/paid_column/123456/section/789012',
    );
    expect(
      () => officialSaltSectionUrl(businessId: 'abc', sectionId: '789012'),
      throwsArgumentError,
    );
  });

  test('salt story navigation reads native discovery identifiers', () {
    final navigation = parseSaltStoryNavigation({
      'business_id': '123456',
      'section_id': '789012',
      'title': '章节卡片',
    });
    expect(navigation?.businessId, '123456');
    expect(navigation?.sectionId, '789012');
    expect(navigation?.opensReader, isTrue);
  });

  test('salt story navigation accepts work aliases and redirect query links', () {
    expect(
      parseSaltStoryNavigation({'work_id': '456789'})?.businessId,
      '456789',
    );
    final redirect = parseSaltStoryNavigation({
      'redirect_url':
          'https://www.zhihu.com/market/manuscript?well_id=456789&section_id=987654',
    });
    expect(redirect?.businessId, '456789');
    expect(redirect?.sectionId, '987654');
  });

  test('salt manuscript model marks script_type 1 for Dart decoding', () {
    final response = {
      'invalid': 1,
      'code': {
        'random': 'ABCDEFGHIJKLMNOP',
        'article_code': 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'log': '0',
      },
      'manuscript_sum': {
        'manuscript_content': {
          'data': {'script': 'QUJDRA==', 'script_type': 1},
        },
        'manuscript_info': {
          'title': '第一节 真正标题',
          'authentication_result': true,
          'is_lock': false,
          'is_vip_resource': true,
          'is_story': true,
          'is_long': true,
          'property_type': 'long_story',
          'window_width': 411,
          'section_index': 1,
          'has_tts': true,
          'authors': [
            {
              'name': '盐选作者',
              'avatar_url': 'https://pic.example/a.jpg',
              'headline': '长期创作科普故事',
              'bio': '作者简介',
            },
          ],
          'labels': ['悬疑', '长篇'],
          'parent': {
            'title': '作品标题',
            'section_count': 9,
            'updated_section_count': 8,
            'artwork': 'https://pic.example/work.jpg',
          },
          'like': {'like_count': 321, 'is_like': true},
          'comment': {
            'comment_count': 18,
            'comment_type': 'manuscript',
            'comment_content_id': '7788',
          },
          'annotation': {
            'count': 73,
            'annotation_comment_type': 'annotation_vip_story',
            'extra_objects': [
              {'object_type': 'annotation_paid_column', 'object_id': '9911'},
              {'object_type': '../invalid', 'object_id': 'not-an-id'},
            ],
          },
          'next_section': {'id': '2', 'title': '第二节'},
        },
      },
      'render_list': [
        {'type': 'native'},
        {'type': 'render'},
      ],
    };

    final manuscript = SaltManuscriptEnvelope.fromJson(response);
    expect(manuscript.invalid, 1);
    expect(manuscript.authenticationResult, isTrue);
    expect(manuscript.isLocked, isFalse);
    expect(manuscript.isVipResource, isTrue);
    expect(manuscript.scriptType, 1);
    expect(manuscript.isTransportEncoded, isTrue);
    expect(manuscript.requiresNativeRenderer, isFalse);
    expect(manuscript.canDecodeTransport, isTrue);
    expect(manuscript.articleCode, hasLength(44));
    expect(manuscript.strategy, '0');
    expect(manuscript.directHtml, isNull);
    expect(manuscript.renderTypes, ['native', 'render']);
    expect(manuscript.title, '第一节 真正标题');
    expect(manuscript.authorName, '盐选作者');
    expect(manuscript.authorHeadline, '长期创作科普故事');
    expect(manuscript.authorBio, '作者简介');
    expect(manuscript.parentTitle, '作品标题');
    expect(manuscript.sectionCount, 9);
    expect(manuscript.updatedSectionCount, 8);
    expect(manuscript.likeCount, 321);
    expect(manuscript.commentCount, 18);
    expect(manuscript.commentType, 'manuscript');
    expect(manuscript.commentContentId, '7788');
    expect(manuscript.annotationCount, 73);
    expect(manuscript.annotationCommentType, 'annotation_vip_story');
    expect(manuscript.annotationExtraObjects, hasLength(1));
    expect(
      manuscript.annotationExtraObjects.single.objectType,
      'annotation_paid_column',
    );
    expect(manuscript.annotationExtraObjects.single.objectId, '9911');
    expect(manuscript.nextSectionId, '2');
    expect(manuscript.labels, ['悬疑', '长篇']);
    expect(htmlContent(response), isNull);
  });

  test('salt chapter fetch status separates payload from readable text', () {
    final rendererPayload = {
      'code': {
        'article_code': 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'log': '0',
      },
      'manuscript_sum': {
        'manuscript_content': {
          'data': {'script': 'QUJDRA==', 'script_type': 1},
        },
        'manuscript_info': {
          'title': '第一节',
          'authentication_result': true,
          'is_lock': false,
        },
      },
    };
    final rendererStatus = SaltChapterFetchStatus.fromJson(rendererPayload);
    expect(rendererStatus.fetched, isTrue);
    expect(rendererStatus.hasBoundPayload, isTrue);
    expect(rendererStatus.hasReadableContent, isFalse);
    expect(rendererStatus.requiresNativeRenderer, isFalse);
    expect(rendererStatus.primaryLabel, '章节载荷已获取');
    expect(rendererStatus.articleCodeChars, 44);

    final htmlStatus = SaltChapterFetchStatus.fromJson({
      'content': '<p>可以直接展示的章节</p>',
    });
    expect(htmlStatus.hasReadableContent, isTrue);
    expect(htmlStatus.requiresNativeRenderer, isFalse);
    expect(htmlStatus.primaryLabel, '章节正文已加载');

    final lockedStatus = SaltChapterFetchStatus.fromJson({
      'manuscript_sum': {
        'manuscript_info': {'authentication_result': false, 'is_lock': true},
      },
    });
    expect(lockedStatus.isLocked, isTrue);
    expect(lockedStatus.primaryLabel, '章节未解锁');
  });

  test('salt manuscript model unwraps native recommend list envelope', () {
    final manuscript = SaltManuscriptEnvelope.fromJson({
      'data': [
        {
          'invalid': 0,
          'manuscript_sum': {
            'manuscript_info': {
              'title': '列表中的章节',
              'authentication_result': true,
            },
          },
          'render_list': [
            {'type': 'render'},
          ],
        },
      ],
    });
    expect(manuscript.title, '列表中的章节');
    expect(manuscript.authenticationResult, isTrue);
    expect(manuscript.renderTypes, ['render']);
  });

  test('salt manuscript model reads root manu_cache entitlement', () {
    final manuscript = SaltManuscriptEnvelope.fromJson({
      'authentication_result': true,
      'auto_buy': false,
      'is_fold': false,
      'off_line': false,
    });
    expect(manuscript.authenticationResult, isTrue);
    expect(manuscript.hasScript, isFalse);
    expect(manuscript.directHtml, isNull);
  });

  test(
    'salt article code model matches the authenticated response envelope',
    () {
      final code = SaltArticleCodeEnvelope.fromJson({
        'random': 'ABCDEFGHIJKLMNOP',
        'article_code': List.filled(44, 'A').join(),
        'log': ' \n',
      });
      expect(code.random, 'ABCDEFGHIJKLMNOP');
      expect(code.articleCode, hasLength(44));
      expect(code.log, ' \n');
    },
  );

  testWidgets('salt section card renders official catalog metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: SaltSectionCard(
            value: const {
              'id': 'section-1',
              'title': '第一节 真正的章节标题',
              'ownership_type': 'try',
              'vip_tag': true,
              'is_lock': true,
              'is_limit_free': true,
              'has_tts': true,
              'last_read': true,
              'serial_number_text': '第 1 节',
              'word_count': 12500,
              'chapter': {'title': '第一章', 'serial_number_txt': '01'},
              'index': {'serial_number_txt': '1'},
              'resource': {
                'type': 'manuscript',
                'data': {'content_abstract': '这是章节摘要'},
              },
              'meta_v3': [
                {'content': '约 12 分钟'},
              ],
              'reaction_count': {'like_count': 321},
              'comment': {'count': 18},
              'cli_progress': {
                'unit_progress': {'progress': 25, 'max_progress': 100},
              },
            },
          ),
        ),
      ),
    );
    expect(find.text('第一节 真正的章节标题'), findsOneWidget);
    expect(find.text('第一章'), findsOneWidget);
    expect(find.text('试读'), findsOneWidget);
    expect(find.text('盐选会员'), findsOneWidget);
    expect(find.text('需权益'), findsOneWidget);
    expect(find.text('限时免费'), findsOneWidget);
    expect(find.text('上次读到'), findsOneWidget);
    expect(find.text('这是章节摘要'), findsOneWidget);
    expect(find.text('约 12 分钟'), findsOneWidget);
    expect(find.text('已读 25%'), findsOneWidget);
    expect(find.text('321'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('1.3万 字'), findsOneWidget);
    expect(find.text('可听'), findsOneWidget);
  });

  test('salt product directory excludes the non-readable details sentinel', () {
    final sections = saltReadableSections({
      'data': [
        {
          'title': '详情',
          'section_id': '0',
          'url': 'https://story.zhihu.com/zhihu_vip/paid_column/123/0',
        },
        {'title': '第一节', 'section_id': '456', 'serial_number_text': '第 1 节'},
        {'title': '无效行'},
      ],
    });
    expect(sections, hasLength(1));
    expect(sections.single['section_id'], '456');
  });

  test('salt catalog windows derive real total and adjacent chapters', () {
    final navigation = saltCatalogNavigationOf(const [
      {
        'data': [
          {'section_id': '100', 'title': '第一节', 'global_idx': 0},
        ],
        'paging': {'total': 73, 'is_first': true},
      },
      {
        'data': [
          {'section_id': '0', 'title': '详情', 'global_idx': 0},
          {'section_id': '200', 'title': '第二节', 'global_idx': 1},
          {'section_id': '300', 'title': '第三节', 'global_idx': 2},
        ],
        'paging': {'total': 73, 'is_end': false},
      },
    ], currentSectionId: '200');
    expect(navigation.total, 73);
    expect(navigation.currentIndex, 1);
    expect(navigation.sections.map((section) => section.id), [
      '100',
      '200',
      '300',
    ]);
    expect(navigation.previous?.id, '100');
    expect(navigation.next?.id, '300');
  });

  test('salt catalog ordering and reading progress match reader semantics', () {
    final rows = <Map<String, dynamic>>[
      {'section_id': '300', 'global_idx': 2, 'title': '第三节'},
      {
        'section_id': '100',
        'global_idx': 0,
        'title': '第一节',
        'progress_text': '已读 8%',
      },
      {
        'section_id': '200',
        'global_idx': 1,
        'title': '第二节',
        'cli_progress': {
          'unit_progress': {'progress': 25, 'max_progress': 100},
        },
      },
    ];
    expect(
      sortSaltCatalogSections(
        rows,
        descending: false,
      ).map((row) => row['section_id']),
      ['100', '200', '300'],
    );
    expect(
      sortSaltCatalogSections(
        rows,
        descending: true,
      ).map((row) => row['section_id']),
      ['300', '200', '100'],
    );
    expect(
      saltCatalogProgressText(
        rows[1],
        selected: false,
        currentSectionIndex: 0,
        sectionCount: 73,
      ),
      '已读 8%',
    );
    expect(
      saltCatalogProgressText(
        rows[2],
        selected: true,
        currentSectionIndex: 1,
        sectionCount: 73,
      ),
      '已读 25%',
    );
    expect(
      saltCatalogProgressText(
        rows.first,
        selected: true,
        currentSectionIndex: 1,
        sectionCount: 73,
      ),
      '已读 1%',
    );
  });

  test('explicit topic type wins even when payload also contains question', () {
    expect(
      isDetectedTopic({
        'type': 'topic',
        'id': '19550429',
        'question': {'id': 'not-an-answer'},
      }),
      isTrue,
    );
    expect(
      isDetectedTopic({
        'type': 'answer',
        'id': '767994359',
        'question': {'id': '310186247'},
      }),
      isFalse,
    );
  });

  test('hot topic model shape is inferred as a topic', () {
    final topic = {
      'token': '19550429',
      'name': '示例话题',
      'matrix_text': '12 万人正在讨论',
      'router': 'zhihu://topic/19550429',
    };
    expect(typeOf(topic), 'topic');
    expect(idOf(topic), '19550429');
    expect(isDetectedTopic(topic), isTrue);
  });

  test(
    'answer detail candidate must preserve answer and question identity',
    () {
      final matching = {
        'type': 'answer',
        'id': '42',
        'question': {'id': '7', 'title': '同一个问题'},
      };
      expect(questionIdOf(matching), '7');
      expect(
        contentIdentityMatches(
          candidate: matching,
          contentType: 'answer',
          contentId: '42',
          expectedQuestionId: '7',
        ),
        isTrue,
      );
      expect(
        contentIdentityMatches(
          candidate: {...matching, 'id': '43'},
          contentType: 'answer',
          contentId: '42',
          expectedQuestionId: '7',
        ),
        isFalse,
      );
      expect(
        contentIdentityMatches(
          candidate: {
            ...matching,
            'question': {'id': '8'},
          },
          contentType: 'answer',
          contentId: '42',
          expectedQuestionId: '7',
        ),
        isFalse,
      );
    },
  );
}
