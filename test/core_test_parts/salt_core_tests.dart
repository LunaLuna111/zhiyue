part of '../core_test.dart';

void registerSaltCoreTests() {
  test('Salt text pagination preserves every character across pages', () {
    final paragraphs = <String>[
      List.filled(48, '第一段正文').join(),
      '短段落',
      List.filled(36, '包含表情😀的文本').join(),
    ];
    final pages = paginateSaltParagraphs(
      paragraphs: paragraphs,
      style: const TextStyle(fontSize: 18, height: 1.7),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      maxWidth: 180,
      maxHeight: 220,
      paragraphGap: 9,
    );

    expect(pages.length, greaterThan(2));
    expect(
      pages.expand((page) => page).map((segment) => segment.text).join(),
      paragraphs.join(),
    );
    expect(
      pages.expand((page) => page).every((segment) => segment.text.isNotEmpty),
      isTrue,
    );
    final allSegments = pages.expand((page) => page).toList();
    expect(allSegments.last.isParagraphEnd, isTrue);
    expect(
      allSegments
          .where((segment) => segment.isParagraphEnd)
          .map((segment) => segment.paragraphIndex),
      [0, 1, 2],
    );
  });

  test('Salt XHTML extraction returns decoded paragraph text only', () {
    final paragraphs = SaltTextChapter.extractParagraphs(
      '<p data-block-key="a">正文 &amp; 标点</p>'
      '<p class="paragraphTitle">01</p>'
      '<p>包含 <strong>内联</strong> 文本。</p>',
    );
    expect(paragraphs, ['正文 & 标点', '01', '包含 内联 文本。']);

    final structured = SaltTextChapter.extractTextParagraphs(
      '<p data-block-key="a">正文</p>'
      '<p class="foo paragraphTitle" data-block-key="b">01</p>',
    );
    expect(structured, hasLength(2));
    expect(structured.first.blockKey, 'a');
    expect(structured.first.isSectionTitle, isFalse);
    expect(structured.last.index, 1);
    expect(structured.last.blockKey, 'b');
    expect(structured.last.isSectionTitle, isTrue);

    final pages = paginateSaltParagraphs(
      paragraphs: structured.map((paragraph) => paragraph.text).toList(),
      style: const TextStyle(fontSize: 18, height: 1.7),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      maxWidth: 180,
      maxHeight: 220,
      paragraphGap: 9,
      sectionTitleIndexes: {structured.last.index},
    );
    final titleSegments = pages
        .expand((page) => page)
        .where((segment) => segment.paragraphIndex == 1);
    expect(titleSegments, isNotEmpty);
    expect(titleSegments.every((segment) => segment.isSectionTitle), isTrue);
  });

  test('Salt reader passes book, catalog and chapter into generic parser', () {
    final manuscript = SaltManuscriptEnvelope.fromJson({
      'data': {
        'manuscript_info': {
          'id': 'manuscript-1',
          'parent': {
            'title': '通用阅读作品',
            'section_count': 2,
            'introduction': '作品简介',
          },
          'authors': {'name': '作者', 'headline': '作者简介'},
          'section_index': 1,
          'title': '第二章',
        },
      },
    });
    final navigation = SaltCatalogNavigation(
      sections: const [
        SaltCatalogSectionInfo(id: 's1', title: '第一章', index: 0),
        SaltCatalogSectionInfo(id: 's2', title: '第二章', index: 1),
      ],
      total: 2,
      currentIndex: 1,
      previous: const SaltCatalogSectionInfo(id: 's1', title: '第一章', index: 0),
      next: null,
    );
    final book = saltReaderBookInfo(
      businessId: 'work-1',
      manuscript: manuscript,
    );
    final catalog = saltReaderCatalog(
      bookId: 'work-1',
      currentChapterId: 's2',
      navigation: navigation,
    );
    final chapter = SaltTextChapter.fromXhtml(
      chapterId: 's2',
      xhtml: '<p data-block-key="body">正文</p>',
      book: book,
      catalog: catalog,
      title: '第二章',
      index: 1,
    );

    expect(chapter.document.book.title, '通用阅读作品');
    expect(chapter.document.book.author, '作者');
    expect(chapter.document.book.description, '作品简介');
    expect(chapter.document.catalog?.currentChapterId, 's2');
    expect(chapter.document.catalog?.previousOf('s2')?.id, 's1');
    expect(chapter.document.chapter.title, '第二章');
    expect(chapter.document.chapter.index, 1);
    expect(chapter.document.paragraphs, ['正文']);
  });

  test('Salt TXT and DOCX exports preserve ordered chapter text', () {
    const sections = [
      SaltChapterExportSection(title: '第 1 节 起点', paragraphs: ['甲', '乙']),
      SaltChapterExportSection(title: '第 2 节 后续', paragraphs: ['丙 & 丁']),
    ];
    final txt = buildSaltChapterExport(
      title: '测试/长篇',
      sectionId: '123',
      sections: sections,
      format: SaltChapterExportFormat.txt,
    );
    expect(txt.fileName, '测试_长篇_123.txt');
    expect(utf8.decode(txt.bytes), contains('第 1 节 起点\n\n甲\n\n乙'));
    expect(utf8.decode(txt.bytes), contains('第 2 节 后续\n\n丙 & 丁'));

    final docx = buildSaltChapterExport(
      title: '测试长篇',
      sectionId: '123',
      sections: sections,
      format: SaltChapterExportFormat.docx,
    );
    expect(docx.fileName, '测试长篇_123.docx');
    final archive = ZipDecoder().decodeBytes(docx.bytes);
    expect(archive.findFile('[Content_Types].xml'), isNotNull);
    expect(archive.findFile('_rels/.rels'), isNotNull);
    final document = utf8.decode(
      archive.findFile('word/document.xml')!.readBytes()!,
    );
    expect(document, contains('第 1 节 起点'));
    expect(document, contains('第 2 节 后续'));
    expect(document, contains('丙 &amp; 丁'));
  });

  test('Salt chapter saver rejects unsafe file metadata before dispatch', () {
    const saver = SaltChapterFileSaver();
    expect(
      () => saver.save(
        SaltChapterExportFile(
          fileName: '../chapter.txt',
          mimeType: 'text/plain',
          bytes: Uint8List.fromList(const [1]),
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => saver.save(
        SaltChapterExportFile(
          fileName: 'chapter.txt',
          mimeType: 'application/octet-stream',
          bytes: Uint8List.fromList(const [1]),
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => saver.save(
        SaltChapterExportFile(
          fileName: 'chapter.txt',
          mimeType: 'text/plain',
          bytes: Uint8List(0),
        ),
      ),
      throwsArgumentError,
    );
  });

  test('local Salt bookshelf entry preserves offline navigation metadata', () {
    final addedAt = DateTime.parse('2026-08-22T12:00:00Z');
    final entry = SaltBookshelfEntry(
      businessId: '123',
      propertyType: 'long_story',
      title: '本地长篇',
      artwork: 'https://pic.example/cover.jpg',
      sectionId: '456',
      rawJson: const {
        'url': 'https://www.zhihu.com/market/paid_column/123/section/456',
        'description': '本地保存的作品',
      },
      addedAt: addedAt,
    );

    final restored = SaltBookshelfEntry.fromRow(entry.toRow());

    expect(restored.businessId, '123');
    expect(restored.sectionId, '456');
    expect(restored.addedAt.toUtc(), addedAt);
    expect(restored.cardJson['title'], '本地长篇');
    expect(restored.cardJson['business_id'], '123');
    expect(parseSaltStoryNavigation(restored.cardJson)?.sectionId, '456');
    expect(isSaltBookshelfPlaceholderTitle('作品目录'), isTrue);
    expect(
      SaltBookshelfEntry(
        businessId: '789',
        propertyType: 'long_story',
        title: '作品目录',
        artwork: '',
        sectionId: '',
        rawJson: const {},
        addedAt: addedAt,
      ).cardJson['title'],
      '盐选作品',
    );
  });

  test(
    'Salt catalog parent metadata repairs ID-tool bookshelf placeholders',
    () {
      final metadata = saltCatalogWorkMetadata(const {
        'parent': {
          'title': '真实长篇书名',
          'property_type': 'long_story',
          'artwork': {'url': 'https://pic.example/real-cover.jpg'},
        },
      });
      expect(metadata.title, '真实长篇书名');
      expect(metadata.propertyType, 'long_story');
      expect(metadata.artwork, 'https://pic.example/real-cover.jpg');
    },
  );

  test(
    'Salt long-form header keeps introduction aliases and fallback text',
    () {
      expect(
        saltProductIntroduction(const {
          'description_list': [
            '第一段简介',
            {'text': '第二段简介'},
          ],
        }),
        '第一段简介\n第二段简介',
      );
      expect(
        saltProductIntroduction(const {
          'parent': {'description': '作品简介'},
        }),
        '作品简介',
      );
      expect(saltProductValueText(const {'content': '内容对象'}), '内容对象');
    },
  );

  test('account authentication action matches official response split', () {
    ApiResponse response(int statusCode, Object json) =>
        _response('/people/self', statusCode: statusCode, json: json);

    expect(
      accountAuthenticationAction(
        response(401, const {
          'error': {'code': 100},
        }),
      ),
      AccountAuthenticationAction.refresh,
    );
    expect(
      accountAuthenticationAction(
        response(401, const {
          'error': {'code': 101},
        }),
      ),
      AccountAuthenticationAction.logout,
    );
    expect(
      accountAuthenticationAction(
        response(401, const {
          'error': {'code': 401},
        }),
      ),
      AccountAuthenticationAction.logout,
    );
    expect(
      accountAuthenticationAction(response(401, const {'error': {}})),
      AccountAuthenticationAction.none,
    );
    expect(
      accountAuthenticationAction(
        response(403, const {
          'error': {'code': 403},
        }),
      ),
      AccountAuthenticationAction.none,
    );
  });

  test('Salt paragraph annotation parser keeps usable paragraph bindings', () {
    final annotations = saltParagraphAnnotationsOf({
      'data': {
        'public_notes': {
          'object_id': '9',
          'object_type': 'manuscript',
          'doc_section_list': [
            {
              'doc_section_id': '301',
              'paragraph_index': 8,
              'comment_count': 5,
              'has_not_empty_comment': true,
            },
            {
              'doc_section_id': 300,
              'paragraph_index': '2',
              'comment_count': '9',
              'has_not_empty_comment': false,
            },
            {
              'doc_section_id': '../bad',
              'paragraph_index': 3,
              'comment_count': 4,
            },
            {'doc_section_id': '302', 'paragraph_index': 9, 'comment_count': 0},
          ],
        },
      },
    });

    expect(annotations, hasLength(2));
    expect(annotations.first.paragraphIndex, 2);
    expect(annotations.first.commentId, '300');
    expect(annotations.first.commentCount, 9);
    expect(annotations.first.hasOwnComment, isFalse);
    expect(annotations.last.paragraphIndex, 8);
    expect(annotations.last.hasOwnComment, isTrue);
  });

  test('pure Dart LAES block matches official synthetic vectors', () {
    const expected = <String>[
      'b7c428b5e01ca03f983d82e47498c43e',
      '08a5f968414b6729e9e5f831455c0450',
      '0148e962b14a0d3e13b6456d95157c80',
      '52775ef03a2a48ffc40133a5dc2efd43',
      '5876069493fdfb827457e0a2e6a7515f',
      '693a69579c12b2b9124f056bf5881e97',
      '611b45b5388b32e638abd1ca3fe085d6',
      '7f6974beb40b43258de72a5d62a69191',
      '8e28f6c0a8d1d7e0ed84bd37239c7323',
      '4fa5e5564b7fe8a442462803d8a37600',
      'b011024087f9dd14396cb7332fc90fbf',
      'e152ded5bfabf6ed549e70502fbc2fcb',
      'b9fbddcbe2637761de7065a65187d10b',
      '3c819d658513aae2d484fdde937e74cd',
      'b8e2030c538d822837f4f43186a79b3e',
      '64f7f78d1716c4e3f6a9c689cc05af89',
    ];
    expect(
      _bytesHex(SaltTransportDecoder.decryptLaesBlock(Uint8List(16))),
      '7463e25e0fb87d76c779346cc5b77dce',
    );
    expect(
      _bytesHex(
        SaltTransportDecoder.decryptLaesBlock(
          Uint8List.fromList(List.generate(16, (index) => index)),
        ),
      ),
      '5ab492da3e10a73b084c2d26197af0b1',
    );
    for (var index = 0; index < expected.length; index++) {
      final input = Uint8List(16)..[index] = 1;
      expect(
        _bytesHex(SaltTransportDecoder.decryptLaesBlock(input)),
        expected[index],
        reason: 'official one-byte LAES vector $index',
      );
    }

    for (final vector in officialSyntheticLaesVectors.entries) {
      expect(
        _bytesHex(SaltTransportDecoder.decryptLaesBlock(_hexBytes(vector.key))),
        vector.value,
        reason: 'official broad synthetic LAES vector ${vector.key}',
      );
    }
  });

  test('pure Dart LAES CBC matches official exported implementation', () {
    final input = Uint8List.fromList(List.generate(32, (index) => index));
    expect(
      _bytesHex(
        SaltTransportDecoder.decryptLaesCbc(
          input,
          iv: Uint8List(16),
          unpad: false,
        ),
      ),
      '5ab492da3e10a73b084c2d26197af0b1'
      '14f2784c178c8b25eaafdb5c19d22666',
    );
    expect(
      _bytesHex(
        SaltTransportDecoder.decryptLaesCbc(
          input,
          iv: _hexBytes('f0efeeedecebeae9e8e7e6e5e4e3e2e1'),
          unpad: false,
        ),
      ),
      'aa5b7c37d2fb4dd2e0abcbc3fd991250'
      '14f2784c178c8b25eaafdb5c19d22666',
    );
  });

  test('minimal AES-128 CBC matches the NIST decrypt vector', () {
    final plaintext = SaltTransportDecoder.decryptAes128Cbc(
      _hexBytes('7649abac8119b246cee98e9b12e9197d'),
      key: _hexBytes('2b7e151628aed2a6abf7158809cf4f3c'),
      iv: _hexBytes('000102030405060708090a0b0c0d0e0f'),
      unpad: false,
    );
    expect(_bytesHex(plaintext), '6bc1bee22e409f96e93d7e117393172a');
  });

  test('AES-128 CBC chaining matches all four NIST blocks', () {
    final plaintext = SaltTransportDecoder.decryptAes128Cbc(
      _hexBytes(
        '7649abac8119b246cee98e9b12e9197d'
        '5086cb9b507219ee95db113a917678b2'
        '73bed6b8e3c1743b7116e69e22229516'
        '3ff1caa1681fac09120eca307586e1a7',
      ),
      key: _hexBytes('2b7e151628aed2a6abf7158809cf4f3c'),
      iv: _hexBytes('000102030405060708090a0b0c0d0e0f'),
      unpad: false,
    );
    expect(
      _bytesHex(plaintext),
      '6bc1bee22e409f96e93d7e117393172a'
      'ae2d8a571e03ac9c9eb76fac45af8e51'
      '30c81c46a35ce411e5fbc1191a0a52ef'
      'f69f2445df4f9b17ad2b417be66c3710',
    );
  });

  test('manuscript AES follows official Crypto++ PKCS padding', () {
    final plaintext = SaltTransportDecoder.decryptManuscriptAesCbc(
      _hexBytes(
        'be6d9ac51a7b3bd6a573c02d74c9b2d4'
        'f92d576a01f8c317ac49153821f7f34b',
      ),
      key: _hexBytes('467abdb8c70d4f9bd59bacf053297152'),
      iv: _hexBytes('30313233343536373839414243444546'),
    );
    expect(utf8.decode(plaintext), '<p>synthetic reader oracle</p>');
  });

  test('pure Dart Salt transport matches native XMLReader end to end', () {
    final payload = _hexBytes(
      '30313233343536373839414243444546'
      'be6d9ac51a7b3bd6a573c02d74c9b2d4'
      'f92d576a01f8c317ac49153821f7f34b',
    );
    final articleCode = _hexBytes(
      '08755d024e2df07a81533ead792b0676'
      'dd17fc7a232d14db00abf440d56e88f7',
    );
    expect(
      SaltTransportDecoder.decode(
        script: base64Encode(payload),
        articleCode: base64Encode(articleCode),
        strategy: '',
        rawKey: 'ABCDEFGHIJKLMNOP',
      ),
      '<p>synthetic reader oracle</p>',
    );
  });

  test('article key unwrap applies official trailing-length semantics', () {
    // Official LAES CBC vector 00..1f decrypts to 32 bytes ending in 0x66.
    // XMLReader's wrapper subtracts only that byte, so an invalid transported
    // key envelope must be rejected instead of being treated as AES-256.
    expect(
      () => SaltTransportDecoder.unwrapArticleKey(
        articleCode: base64Encode(
          Uint8List.fromList(List.generate(32, (index) => index)),
        ),
        requestIv: Uint8List(16),
      ),
      throwsA(
        isA<SaltTransportDecodeException>().having(
          (error) => error.code,
          'code',
          'invalid_padding',
        ),
      ),
    );
  });

  test('minimal AES-256 CBC matches the NIST decrypt vector', () {
    final plaintext = SaltTransportDecoder.decryptAesCbc(
      _hexBytes('f58c4c04d6e5f1ba779eabfb5f7bfbd6'),
      key: _hexBytes(
        '603deb1015ca71be2b73aef0857d7781'
        '1f352c073b6108d72d9810a30914dff4',
      ),
      iv: _hexBytes('000102030405060708090a0b0c0d0e0f'),
      unpad: false,
    );
    expect(_bytesHex(plaintext), '6bc1bee22e409f96e93d7e117393172a');
  });

  test('pure Dart salt request key matches official wire shapes', () async {
    final first = await PureDartSaltManuscriptKeyProvider(
      random: Random(40408),
    ).generate();
    final second = await PureDartSaltManuscriptKeyProvider(
      random: Random(40409),
    ).generate();
    expect(first.rawKey, matches(RegExp(r'^[A-Za-z]{16}$')));
    expect(first.transKey, hasLength(172));
    expect(base64Decode(first.transKey), hasLength(128));
    expect(second.rawKey, isNot(first.rawKey));
    expect(second.transKey, isNot(first.transKey));
  });

  test('pure Dart salt request key matches official raw RSA vector', () async {
    final key = await PureDartSaltManuscriptKeyProvider(
      random: _SaltRawKeyRandom('XwMPmJTWWfmUDjJu'),
    ).generate();

    expect(key.rawKey, 'XwMPmJTWWfmUDjJu');
    expect(
      key.transKey,
      'x0GfvTs8xlv5/7nyELvtNc5sqMCVqpYTr5/OXomyo44pyJcymnafjhtoEFPiGLOlU3GE6u3XFcGi9W4XwfJGofKbeAHCNiC8Ru8gYfdb3CA4U7fX/ilH/CQizqoalz0ZIREPmFCnryUkKWMfM+3kRlV01QBgOg/97tuEv4jw0MU=',
    );
  });

  test('pure Dart salt derivation matches official synthetic vectors', () {
    const keys = <String, List<String>>{
      'ABCDEFGHIJKLMNOP': [
        'f24560717efc4c58fa9acde6704b1fcd',
        '13f909c633104d749f0996fe1c4b735a',
        '14b3673cd68d7e25244edc535e4049fc',
      ],
      'abcdefghijklmnop': [
        'bb4df9b91ce48acc22094648ece6de28',
        'd27a0b5aacea270063d78150bea7c072',
        '131c88563869700cea7109d4c4bb5fef',
      ],
      'aB3dE5fG7hI9jK1m': [
        '3e80145dd54ea9e2e8b36d8cb6289ae6',
        '4c0127f6cdf70f7de7fbeb7c155b2032',
        '8eeec894122f8a912419fb8c64f21951',
      ],
    };
    for (final vector in keys.entries) {
      expect(
        _bytesHex(
          SaltTransportDecoder.deriveRequestIv(
            rawKey: vector.key,
            strategy: '',
          ),
        ),
        vector.value[0],
      );
      expect(
        _bytesHex(
          SaltTransportDecoder.deriveRequestIv(
            rawKey: vector.key,
            strategy: '   ',
          ),
        ),
        vector.value[1],
      );
      expect(
        _bytesHex(
          SaltTransportDecoder.deriveRequestIv(
            rawKey: vector.key,
            strategy: '      ',
          ),
        ),
        vector.value[2],
      );
    }
    expect(
      _bytesHex(
        SaltTransportDecoder.deriveRequestIv(
          rawKey: 'ABCDEFGHIJKLMNOP',
          strategy: '一',
        ),
      ),
      keys['ABCDEFGHIJKLMNOP']![1],
      reason: 'one three-byte UTF-8 strategy character selects SHA-256',
    );
  });

  test('software setting presets expose stable runtime values', () async {
    expect(ReadingTextSize.compact.scale, 0.92);
    expect(ReadingTextSize.standard.scale, 1);
    expect(ReadingTextSize.large.scale, 1.12);
    expect(ImageCachePreset.economy.maximumEntries, 120);
    expect(ImageCachePreset.standard.maximumBytes, 100 * 1024 * 1024);
    expect(ImageCachePreset.roomy.maximumEntries, 600);
    expect(SessionStore.defaultHomeFeedOrder, [
      HomeFeedChannel.following,
      HomeFeedChannel.recommend,
      HomeFeedChannel.hot,
      HomeFeedChannel.story,
    ]);
    expect(SessionStore().refreshHomeOnReselect, isTrue);
    expect(app.startupNavigationIndex(AppStartupPage.recommend), 0);
    expect(app.startupNavigationIndex(AppStartupPage.bookshelf), 2);
    await expectLater(
      SessionStore().setHomeFeedOrder(const [
        HomeFeedChannel.recommend,
        HomeFeedChannel.recommend,
        HomeFeedChannel.hot,
        HomeFeedChannel.story,
      ]),
      throwsFormatException,
    );
  });
}
