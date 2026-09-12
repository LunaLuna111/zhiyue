part of '../core_test.dart';

void registerContentFeedTests() {
  test('relationship normalizes answer votes and pin likes', () {
    expect(
      AnswerRelationship.from({
        'type': 'answer',
        'reaction': {
          'relation': {'vote': 'DOWN'},
        },
      }).isDownvoted,
      isTrue,
    );
    expect(
      AnswerRelationship.from({'type': 'pin', 'is_like': true}).isUpvoted,
      isTrue,
    );
    expect(
      AnswerRelationship.from({
        'type': 'pin',
        'reaction': {
          'relation': {'like': true},
        },
      }).isUpvoted,
      isTrue,
    );
    final wrapped = <String, dynamic>{
      'type': 'feed',
      'target': {
        'type': 'answer',
        'id': 17,
        'relationship': {'voting': 'up', 'is_favorited': true},
        'voteup_count': 42,
        'favorite_count': 3,
        'content': {'type': 'text', 'text': '正文'},
      },
    };
    expect(AnswerRelationship.from(wrapped).isUpvoted, isTrue);
    expect(AnswerRelationship.from(wrapped).isFavorited, isTrue);
    expect(ContentMetrics.from(wrapped).voteupCount, 42);
    expect(ContentMetrics.from(wrapped).favoriteCount, 3);
  });

  test(
    'recommend ComponentCard resolves semantic answer identity and copy',
    () {
      final card = <String, dynamic>{
        'id': '1919415961875870742',
        'type': 'ComponentCard',
        'children': [
          {
            'type': 'Text',
            'style': 'text_recommend_title',
            'test_id': 'answer.2064413623645165148.title',
            'text': '真实推荐问题',
            'visible': true,
          },
          {
            'type': 'Text',
            'style': 'text_recommend_content',
            'text': '这是回答摘要',
            'visible': true,
          },
          {
            'type': 'Reaction',
            'style': 'reaction_feed_v7',
            'test_id': 'answer.2064413623645165148.vote',
            'count': 2735,
          },
          {
            'type': 'Reaction',
            'style': 'reaction_feed_v7',
            'test_id': 'answer.2064413623645165148.collect',
            'count': 1158,
          },
          {
            'type': 'Reaction',
            'style': 'reaction_feed_v7',
            'test_id': 'answer.2064413623645165148.comment',
            'count': 21,
          },
          {
            'type': 'Image',
            'style': 'recommend_content_cover',
            'image_url': 'https://pic.example.test/content.jpg',
          },
        ],
        'extra': {
          'content_id': '2064413623645165148',
          'content_type': 'answer',
          'business_ext_map': {
            'passthrough_info': {
              'author': {'name': '示例作者'},
              'content': {'title': '真实推荐问题', 'summary': '这是回答摘要'},
            },
          },
        },
      };

      expect(typeOf(card), 'answer');
      expect(idOf(card), '2064413623645165148');
      expect(titleOf(card), '真实推荐问题');
      expect(subtitleOf(card), '这是回答摘要');
      expect(unwrapObject(card)['component_card'], isTrue);
      final metrics = ContentMetrics.from(card);
      expect(metrics.voteupCount, 2735);
      expect(metrics.favoriteCount, 1158);
      expect(metrics.commentCount, 21);
      expect(contentImageUrlsOf(card), [
        'https://pic.example.test/content.jpg',
      ]);
    },
  );

  test('recommend ComponentCard can recover identity from child test id', () {
    final card = <String, dynamic>{
      'id': 'template-card-id',
      'type': 'ComponentCard',
      'children': [
        {
          'type': 'Text',
          'style': 'text_recommend_title',
          'test_id': 'answer.42.title',
          'text': '通过 test id 恢复',
        },
      ],
    };
    expect(typeOf(card), 'answer');
    expect(idOf(card), '42');
    expect(titleOf(card), '通过 test id 恢复');
  });

  test('column SDUI ComponentCard reads official nested detail model', () {
    final card = <String, dynamic>{
      'id': 'template-card-id',
      'type': 'ComponentCard',
      'children': const [],
      'extra': {
        'content_id': '1994423521271637277',
        'content_type': 'article',
        'business_ext_map': {
          'content_info': {
            'content_id': '1994423521271637277',
            'content_type': 'article',
            'detail': {'title': '专栏文章真实标题', 'summary': '专栏文章真实摘要'},
            'media_detail': {
              'images': [
                {'url': 'https://pic.example.test/column.jpg'},
              ],
            },
          },
          'author': {
            'meta': {'id': 'member-id'},
            'profile': {
              'full_name': '专栏作者',
              'headline': '作者简介',
              'avatar': {'url': 'https://pic.example.test/avatar.jpg'},
            },
          },
          'statistics': {
            'up_vote_count': 321,
            'collect_count': 45,
            'comment_count': 6,
          },
        },
      },
    };
    expect(typeOf(card), 'article');
    expect(idOf(card), '1994423521271637277');
    expect(titleOf(card), '专栏文章真实标题');
    expect(subtitleOf(card), '专栏文章真实摘要');
    expect(authorNameOf(card), '专栏作者');
    expect(authorHeadlineOf(card), '作者简介');
    expect(authorAvatarOf(card), 'https://pic.example.test/avatar.jpg');
    final metrics = ContentMetrics.from(card);
    expect(metrics.voteupCount, 321);
    expect(metrics.favoriteCount, 45);
    expect(metrics.commentCount, 6);
    expect(contentImageUrlsOf(card), ['https://pic.example.test/column.jpg']);
  });

  test('content gallery collapses resize variants of one SDUI image', () {
    final card = <String, dynamic>{
      'type': 'article',
      'id': '42',
      'media_detail': {
        'images': [
          {'url': 'https://pic.example.test/cover.jpg?source=column_feed'},
          {'url': 'https://pic.example.test/cover.jpg?source=column_detail'},
          {'url': 'https://pic.example.test/second.jpg?source=column_feed'},
        ],
      },
    };
    expect(contentImageUrlsOf(card), [
      'https://pic.example.test/cover.jpg?source=column_feed',
      'https://pic.example.test/second.jpg?source=column_feed',
    ]);
  });

  test(
    'content gallery reads official nested image models but skips avatar',
    () {
      final card = <String, dynamic>{
        'type': 'ComponentCard',
        'children': [
          {
            'type': 'Image',
            'style': 'author_avatar_round',
            'image': {'url': 'https://pic.example.test/avatar.jpg'},
          },
          {
            'type': 'Image',
            'style': 'content_image_16_9',
            'image': {
              'source': {
                'variants': [
                  {
                    'url_template':
                        'https://pic.example.test/answer-{size}.{format}',
                  },
                ],
              },
            },
          },
        ],
        'extra': {
          'content_id': '42',
          'content_type': 'answer',
          'business_ext_map': {
            'userInfo': {'avatarUrl': 'https://pic.example.test/avatar.jpg'},
          },
        },
      };
      expect(contentImageUrlsOf(card), [
        'https://pic.example.test/answer-r.jpg',
      ]);
    },
  );

  test(
    'recommend gallery trusts business images and ignores SDUI controls',
    () {
      final card = <String, dynamic>{
        'type': 'ComponentCard',
        'children': [
          {
            'type': 'Image',
            'style': 'leading_badge',
            'icon': {'url': 'https://pic.example.test/badge.png'},
          },
          {
            'type': 'Container',
            'style': 'bottom_actions',
            'tail_element': {
              'elements': [
                {'url': 'https://pic.example.test/close.png'},
              ],
            },
          },
        ],
        'extra': {
          'content_id': '42',
          'content_type': 'answer',
          'business_ext_map': {
            'images': [
              {'url': 'https://pic.example.test/body.jpg'},
              {'url': 'https://pic.example.test/body-2.jpg'},
            ],
          },
        },
      };
      expect(contentImageUrlsOf(card), [
        'https://pic.example.test/body.jpg',
        'https://pic.example.test/body-2.jpg',
      ]);
    },
  );

  test('content gallery warms Salt artwork covers', () {
    expect(
      contentImageUrlsOf({
        'business_id': '42',
        'business_type': 'PaidColumn',
        'artwork': 'https://pic.example.test/salt-cover.jpg',
      }),
      ['https://pic.example.test/salt-cover.jpg'],
    );
  });

  test('hot rank SDUI normalizes to navigable semantic content', () {
    final source = <String, dynamic>{
      'type': 'hot_list_feed',
      'id': 'rank-card-1',
      'seq_num': 1,
      'target': {
        'title_area': {'text': '热榜问题标题'},
        'excerpt_area': {'text': '热榜摘要'},
        'image_area': {'url': 'https://pic.example.test/hot.jpg'},
        'metrics_area': {'text': '1234 万热度'},
        'link': {'url': 'zhihu://question/123456'},
      },
    };

    expect(typeOf(source), 'question');
    expect(idOf(source), '123456');
    expect(titleOf(source), '热榜问题标题');
    expect(subtitleOf(source), '热榜摘要');
    expect(contentKindLabelOf(source), '热榜');
    expect(contentImageUrlsOf(source), ['https://pic.example.test/hot.jpg']);
  });

  test('feed kind labels distinguish answers, stories and novels', () {
    expect(contentKindLabelOf(const {'type': 'answer'}), '回答');
    expect(
      contentKindLabelOf(const {
        'type': 'answer',
        'is_story': true,
        'business_type': 'PaidColumn',
      }),
      '盐选故事',
    );
    expect(
      contentKindLabelOf(const {
        'type': 'answer',
        'is_story': true,
        'is_long': true,
        'url': 'https://www.zhihu.com/market/manuscript?business_id=1',
      }),
      '小说',
    );
  });

  test('answer HTML gallery reads lazy-loaded official image attributes', () {
    expect(
      contentImageUrlsOf({
        'type': 'answer',
        'content':
            '<p>正文</p><img data-actualsrc="https://pic.example.test/body.jpg">',
      }),
      ['https://pic.example.test/body.jpg'],
    );
  });

  test('answer rich body preserves paragraph and image order', () {
    final blocks = richContentBlocks(
      '<p>第一段</p><img data-actualsrc="//pic.example.test/one.jpg">'
      '<p>第二段<br>续行</p>'
      '<script>alert(1)</script>'
      '<img src="https://pic.example.test/two.jpg">',
    );
    expect(blocks, hasLength(4));
    expect(blocks[0].text, '第一段');
    expect(blocks[1].imageUrl, 'https://pic.example.test/one.jpg');
    expect(blocks[2].text, '第二段\n续行');
    expect(blocks[3].imageUrl, 'https://pic.example.test/two.jpg');
    expect(blocks.map((block) => block.text).join(), isNot(contains('alert')));
  });

  test('answer rich body preserves ordinary link destinations', () {
    final blocks = richContentBlocks(
      '<p>前文</p><a href="https://www.zhihu.com/question/42">知乎问题</a>'
      '<a href="https://example.com/safe">站外链接</a>',
    );
    expect(blocks.map((block) => block.text), ['前文', '知乎问题', '站外链接']);
    expect(blocks[1].linkUrl, 'https://www.zhihu.com/question/42');
    expect(blocks[2].linkUrl, 'https://example.com/safe');
  });

  test('official link matching rejects lookalike and non-web hosts', () {
    expect(isZhihuOfficialLink('https://www.zhihu.com/question/42'), isTrue);
    expect(isZhihuOfficialLink('https://evilzhihu.com/question/42'), isFalse);
    expect(isZhihuOfficialLink('javascript:alert(1)'), isFalse);
  });

  testWidgets(
    'structured answer keeps heading, bold text and sentence comment actions',
    (tester) async {
      List<String>? tappedIds;
      String? tappedQuote;
      await tester.pumpWidget(
        _testApp(
          Scaffold(
            body: StructuredAnswerContent(
              segments: const [
                {
                  'id': '0',
                  'type': 'heading',
                  'heading': {
                    'level': 2,
                    'text': '正文标题',
                    'marks': [
                      {'type': 'bold', 'start_index': 0, 'end_index': 4},
                    ],
                  },
                },
                {
                  'id': '1',
                  'type': 'paragraph',
                  'paragraph': {
                    'pid': 'p1',
                    'text': '普通文字可评论文字',
                    'marks': [
                      {
                        'type': 'seg_like',
                        'start_index': 4,
                        'end_index': 9,
                        'seg_like': {
                          'comment_count': 2,
                          'seg_ids': ['segment-1'],
                        },
                      },
                    ],
                  },
                },
              ],
              onSentenceComments: (ids, quote) {
                tappedIds = ids;
                tappedQuote = quote;
              },
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('structured-answer-content')),
        findsOneWidget,
      );
      final paragraph = tester.widget<SelectableText>(
        find.descendant(
          of: find.byKey(const ValueKey('answer-structured-text-1')),
          matching: find.byType(SelectableText),
        ),
      );
      final markedSpan = paragraph.textSpan!.children!
          .whereType<TextSpan>()
          .firstWhere((span) => span.recognizer != null);
      expect(markedSpan.style?.fontWeight, isNull);
      expect(markedSpan.style?.backgroundColor, const Color(0xFFEAF3FF));
      (markedSpan.recognizer! as TapGestureRecognizer).onTap!();
      expect(tappedIds, ['segment-1']);
      expect(tappedQuote, '可评论文字');
      expect(tester.takeException(), isNull);
    },
  );

  test('answer video metadata follows original fields and source quality', () {
    final videos = contentVideosOf({
      'thumbnail_extra_info': {
        'video_id': 'lens-1',
        'url': 'https://pic.example.test/cover.jpg',
        'duration': 19.6,
        'width': 1920,
        'height': 1080,
        'is_paid': true,
        'playlist': {
          'fhd': {'url': 'https://video.example.test/fhd.mp4'},
          'ld': {'url': 'https://video.example.test/ld.mp4'},
          'sd': {'play_url': 'https://video.example.test/sd.mp4'},
          'hd': {'url': 'https://video.example.test/hd.mp4', 'format': 'm3u8'},
        },
        'playlist_v2': {
          'hd': {
            'url': 'http://video.example.test/rejected.mp4',
            'play_url': 'https://video.example.test/h265-hd.mp4',
          },
        },
      },
      'video_info': {
        'videos': [
          {
            'video_id': 'lens-1',
            'title': '目录标题',
            'thumbnail': 'https://pic.example.test/later-cover.jpg',
            'is_trial': true,
          },
        ],
      },
    });

    expect(videos, hasLength(1));
    expect(videos.single.videoId, 'lens-1');
    expect(videos.single.title, '目录标题');
    expect(videos.single.posterUrl, 'https://pic.example.test/cover.jpg');
    expect(videos.single.durationSeconds, 20);
    expect(videos.single.width, 1920);
    expect(videos.single.height, 1080);
    expect(videos.single.isPaid, isTrue);
    expect(videos.single.isTrial, isTrue);
    expect(videos.single.sourceUrls, [
      'https://video.example.test/hd.mp4',
      'https://video.example.test/sd.mp4',
      'https://video.example.test/fhd.mp4',
      'https://video.example.test/ld.mp4',
      'https://video.example.test/h265-hd.mp4',
    ]);
    expect(
      videos.single.sourceFormats['https://video.example.test/hd.mp4'],
      'm3u8',
    );
    expect(
      () => videos.single.sourceUrls.add('https://video.example.test/x.mp4'),
      throwsUnsupportedError,
    );
  });

  test('zvideo entity and video-tab fields produce a playable video', () {
    final value = <String, dynamic>{
      'type': 'zvideo',
      'id': '8848',
      'title': {'plain_text': '原版视频标题'},
      'play_count': 9012,
      'paid_info': {'is_trial': true, 'sku_id': 'sku-1'},
      'video': {
        'id': 'lens-tab-id',
        'duration_in_seconds': 125,
        'thumbnail': {
          'image_url': 'https://picx.zhimg.com/zvideo-cover.jpg',
          'width': 1080,
          'height': 1440,
        },
        'playlist': {
          'hd': {'url': 'https://vdn.vzuu.com/zvideo-hd.mp4'},
        },
        'playlist_v2': {
          'sd': {'play_url': 'https://vdn.vzuu.com/zvideo-h265.mp4'},
        },
      },
      'relate': {'upvote_count': 71, 'comment_count': 12, 'play_count': 9012},
    };

    final video = contentVideosOf(value).single;
    expect(titleOf(value), '原版视频标题');
    expect(video.videoId, 'lens-tab-id');
    expect(video.title, '原版视频标题');
    expect(video.posterUrl, 'https://picx.zhimg.com/zvideo-cover.jpg');
    expect(video.durationSeconds, 125);
    expect(video.width, 1080);
    expect(video.height, 1440);
    expect(video.isPaid, isTrue);
    expect(video.isTrial, isTrue);
    expect(video.sourceUrls, [
      'https://vdn.vzuu.com/zvideo-hd.mp4',
      'https://vdn.vzuu.com/zvideo-h265.mp4',
    ]);
    final metrics = ContentMetrics.from(value);
    expect(metrics.viewCount, 9012);
    expect(metrics.voteupCount, 71);
    expect(metrics.commentCount, 12);
  });

  test('short-content direct video_info produces a playable video', () {
    final videos = contentVideosOf({
      'type': 'zvideo',
      'title': {'plain_text': '搜索视频'},
      'video_info': {
        'sub_video_id': 'lens-short-1',
        'duration': 47,
        'thumbnail': 'https://picx.zhimg.com/short-cover.jpg',
        'playlist_v2': {
          'hd': {'play_url': 'https://vdn.vzuu.com/short-video.mp4'},
        },
      },
    });

    expect(videos, hasLength(1));
    expect(videos.single.videoId, 'lens-short-1');
    expect(videos.single.title, '搜索视频');
    expect(videos.single.durationSeconds, 47);
    expect(videos.single.posterUrl, 'https://picx.zhimg.com/short-cover.jpg');
    expect(videos.single.sourceUrls, ['https://vdn.vzuu.com/short-video.mp4']);
    expect(videos.single.isStandalone, isTrue);
  });

  test('answer video rejects insecure credentialed and custom-port URLs', () {
    final videos = contentVideosOf({
      'id': 'lens-safe',
      'cover_url': 'https://user@pic.example.test/cover.jpg',
      'thumbnail': 'http://pic.example.test/cover.jpg',
      'playlist': {
        'hd': {'url': 'http://video.example.test/hd.mp4'},
        'sd': {'url': 'https://video.example.test:444/sd.mp4'},
        'ld': {'url': 'https://user@video.example.test/ld.mp4'},
        'fhd': {'play_url': 'https://video.example.test:443/fhd.mp4'},
      },
    });

    expect(videos, hasLength(1));
    expect(videos.single.posterUrl, isEmpty);
    expect(videos.single.sourceUrls, ['https://video.example.test/fhd.mp4']);
  });

  test(
    'answer video reads compact attachment and playlist-v2-only Lens data',
    () {
      final compact = contentVideosOf({
        'attachment': {
          'zvideo': {
            'video_id': 'compact-id',
            'thumbnail': 'https://pic.example.test/compact.jpg',
            'duration': 31,
            'width': 1280,
            'height': 720,
          },
        },
      });
      expect(compact, hasLength(1));
      expect(compact.single.videoId, 'compact-id');
      expect(compact.single.posterUrl, 'https://pic.example.test/compact.jpg');
      expect(compact.single.sourceUrls, isEmpty);
      expect(compact.single.isStandalone, isTrue);

      final lens = contentVideosOf({
        'id': 'lens-v2-only',
        'cover_url': 'https://pic.example.test/lens-v2.jpg',
        'playlist_v2': {
          'hd': {'play_url': 'https://video.example.test/lens-v2.mp4'},
        },
      });
      expect(lens, hasLength(1));
      expect(lens.single.videoId, 'lens-v2-only');
      expect(lens.single.sourceUrls, [
        'https://video.example.test/lens-v2.mp4',
      ]);
    },
  );

  test('answer video honors original cover contracts and explicit format', () {
    final thumbnail = contentVideosOf({
      'thumbnail_extra_info': {
        'video_id': 'cover-contract',
        'url': 'https://pic.example.test/fallback.jpg',
        'cover_info': {'thumbnail': 'https://pic.example.test/cover-info.jpg'},
        'playlist': {
          'hd': {'url': 'https://video.example.test/opaque', 'format': 'hls'},
        },
      },
    }).single;
    expect(thumbnail.posterUrl, 'https://pic.example.test/cover-info.jpg');
    expect(thumbnail.sourceFormats['https://video.example.test/opaque'], 'hls');

    final lens = contentVideosOf({
      'id': 'lens-cover',
      'thumbnail': 'https://pic.example.test/legacy.jpg',
      'cover_url': 'https://pic.example.test/lens-cover.jpg',
      'playlist': {
        'hd': {'play_url': 'https://video.example.test/lens.mp4'},
      },
    }).single;
    expect(lens.posterUrl, 'https://pic.example.test/lens-cover.jpg');

    final disabled = contentVideosOf({
      'thumbnail_extra_info': {
        'video_id': 'disabled-cover',
        'is_disabled_play': true,
        'begin_frame': {
          'fhd': 'https://pic.example.test/private-first-frame.jpg',
        },
      },
    }).single;
    expect(disabled.posterUrl, isEmpty);
  });

  test('answer video HTML preserves text image and video DOM order', () {
    final catalog = contentVideosOf({
      'video_info': {
        'videos': [
          {
            'video_id': 'lens-ordered',
            'title': '接口标题',
            'thumbnail': 'https://pic.example.test/api-cover.jpg',
            'playlist': {
              'hd': {'url': 'https://video.example.test/ordered.mp4'},
            },
          },
        ],
      },
    });
    final blocks = richContentBlocks(
      '<p>前文</p>'
      '<a class="video-box content" data-lens-id="lens-ordered" '
      'data-name="正文&amp;标题" '
      'data-poster="https://pic.example.test/html-cover.jpg?a=1&amp;b=2" '
      'data-duration="42"><img src="https://pic.example.test/inside.jpg"></a>'
      '<p>中间</p><img src="https://pic.example.test/body.jpg">'
      '<video poster="https://pic.example.test/native.jpg">'
      '<source src="https://video.example.test/native.mp4" '
      'type="application/x-mpegURL"></video>'
      '<p>结尾</p>',
      videos: catalog,
    );

    expect(blocks, hasLength(6));
    expect(blocks[0].text, '前文');
    expect(blocks[1].isVideo, isTrue);
    expect(blocks[1].video!.videoId, 'lens-ordered');
    expect(blocks[1].video!.title, '正文&标题');
    expect(
      blocks[1].video!.posterUrl,
      'https://pic.example.test/html-cover.jpg?a=1&b=2',
    );
    expect(blocks[1].video!.durationSeconds, 42);
    expect(blocks[1].video!.sourceUrls, [
      'https://video.example.test/ordered.mp4',
    ]);
    expect(blocks[2].text, '中间');
    expect(blocks[3].imageUrl, 'https://pic.example.test/body.jpg');
    expect(blocks[4].isVideo, isTrue);
    expect(blocks[4].video!.sourceUrls, [
      'https://video.example.test/native.mp4',
    ]);
    expect(
      blocks[4].video!.sourceFormats['https://video.example.test/native.mp4'],
      'application/x-mpegURL',
    );
    expect(blocks[5].text, '结尾');
  });

  test(
    'answer video does not turn ordinary external video card into media',
    () {
      final blocks = richContentBlocks(
        '<p>正文</p><a class="video-box" '
        'href="https://outside.example.test/watch.mp4">外部视频'
        '<img src="https://pic.example.test/link-cover.jpg?a=1&amp;b=2"></a>',
      );

      expect(blocks.where((block) => block.isVideo), isEmpty);
      expect(blocks.map((block) => block.text).join(' '), contains('外部视频'));
      expect(
        blocks.where((block) => block.isImage).single.imageUrl,
        'https://pic.example.test/link-cover.jpg?a=1&b=2',
      );
    },
  );

  test(
    'answer video catalog is prepended when HTML has no matching anchor',
    () {
      final catalog = contentVideosOf({
        'attachment': {
          'video': {
            'sub_video_id': 'standalone-id',
            'title': '独立视频回答',
            'video_info': {
              'thumbnail': 'https://pic.example.test/standalone.jpg',
              'playlist': {
                'hd': {'url': 'https://video.example.test/standalone.mp4'},
              },
            },
          },
        },
      });
      final blocks = richContentBlocks('<p>独立回答正文</p>', videos: catalog);

      expect(blocks, hasLength(2));
      expect(blocks.first.isVideo, isTrue);
      expect(blocks.first.video!.videoId, 'standalone-id');
      expect(blocks.last.text, '独立回答正文');
    },
  );

  test('ordinary inline video catalog is not invented outside the HTML', () {
    final catalog = contentVideosOf({
      'video_info': {
        'videos': [
          {
            'video_id': 'stale-inline',
            'thumbnail': 'https://pic.example.test/stale.jpg',
            'playlist': {
              'hd': {'url': 'https://video.example.test/stale.mp4'},
            },
          },
        ],
      },
    });
    final blocks = richContentBlocks('<p>只有正文</p>', videos: catalog);

    expect(blocks, hasLength(1));
    expect(blocks.single.text, '只有正文');
  });

  test('detail metadata merge preserves recommendation body images', () {
    final detail = <String, dynamic>{
      'type': 'answer',
      'id': '42',
      'content': '<p>更完整的详情正文</p>',
    };
    final recommendation = <String, dynamic>{
      'type': 'ComponentCard',
      'extra': {
        'content_id': '42',
        'content_type': 'answer',
        'business_ext_map': {
          'images': [
            {'url': 'https://pic.example.test/body-one.jpg'},
            {'url': 'https://pic.example.test/body-two.jpg'},
          ],
        },
      },
    };

    expect(contentImageUrlsOf(mergeListMetadata(detail, recommendation)), [
      'https://pic.example.test/body-one.jpg',
      'https://pic.example.test/body-two.jpg',
    ]);
  });

  test('salt story modules preserve official home hierarchy', () {
    final modules = extractSaltStoryModules({
      'data': [
        {
          'module_type': 'vip_card',
          'module_data': {
            'data': {'title': '我的盐选会员'},
          },
        },
        {
          'module_type': 'billboard',
          'module_data': {
            'data': {
              'data': [
                {
                  'head': {'title': '推荐榜'},
                  'content_list': [
                    {'title': '榜单作品'},
                  ],
                },
              ],
            },
          },
        },
      ],
    });
    expect(modules, hasLength(2));
    expect(modules.first['module_type'], 'vip_card');
    expect(modules.last['module_type'], 'billboard');
  });

  test('answer detail keeps richer author metadata from recommend card', () {
    final merged = mergeListMetadata(
      {
        'type': 'answer',
        'id': '42',
        'question': {'id': '7', 'title': '示例问题'},
        'author': {'type': 'people', 'id': 'hash-only'},
      },
      {
        'type': 'answer',
        'id': '42',
        'voteup_count': 99,
        'favorite_count': 8,
        'author': {
          'name': '推荐页作者',
          'headline': '这是作者简介',
          'followers_count': 1234,
        },
      },
    );
    expect(authorNameOf(merged), '推荐页作者');
    expect(authorHeadlineOf(merged), '这是作者简介');
    expect(ContentMetrics.from(merged).voteupCount, 99);
    expect(ContentMetrics.from(merged).favoriteCount, 8);
    expect(ContentMetrics.from(merged).authorFollowerCount, 1234);
    expect(titleOf(merged), '示例问题');
  });

  test('long list body can retain verified detail metadata', () {
    final longListBody = {
      'type': 'answer',
      'id': '42',
      'content': '<p>${'正文' * 20}</p>',
      'author': {'name': '作者'},
    };
    final shortDetail = {
      'type': 'answer',
      'id': '42',
      'created_time': 1700000000,
      'voteup_count': 88,
      'author': {'followers_count': 123},
    };
    final enriched = mergeListMetadata(longListBody, shortDetail);
    expect(plainText(enriched['content']), contains('正文正文'));
    expect(ContentMetrics.from(enriched).createdTime, 1700000000);
    expect(ContentMetrics.from(enriched).voteupCount, 88);
    expect(ContentMetrics.from(enriched).authorFollowerCount, 123);
  });

  test('answer metadata exposes dates and official interaction counts', () {
    final created = DateTime(2024, 1, 2).millisecondsSinceEpoch ~/ 1000;
    final updated = DateTime(2024, 2, 3).millisecondsSinceEpoch ~/ 1000;
    final metrics = ContentMetrics.from({
      'type': 'answer',
      'voteup_count': 12345,
      'favorite_count': 844,
      'comment_count': 172,
      'thanks_count': 18,
      'visited_count': 54000,
      'created_time': created,
      'updated_time': updated,
      'question': {'answer_count': 1358, 'follower_count': 4537},
      'author': {'followers_count': 22000},
    });
    expect(compactCount(metrics.voteupCount!), '1.2万');
    expect(metrics.favoriteCount, 844);
    expect(metrics.commentCount, 172);
    expect(metrics.answerCount, 1358);
    expect(metrics.followerCount, 4537);
    expect(metrics.authorFollowerCount, 22000);
    expect(contentDateLabel(metrics), '发布于 2024-01-02 · 编辑于 2024-02-03');
    expect(
      authorIdOf({
        'author': {'url_token': 'profile-token', 'id': 'hash-id'},
      }),
      'profile-token',
    );
  });

  testWidgets('content card renders actual engagement metrics and date', (
    tester,
  ) async {
    final created = DateTime(2024, 1, 2).millisecondsSinceEpoch ~/ 1000;
    final actions = <ContentCardAction>[];
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: ObjectCard(
            value: {
              'type': 'answer',
              'id': '42',
              'excerpt': '回答摘要',
              'question': {'title': '示例问题'},
              'author': {'name': '示例作者'},
              'voteup_count': 12345,
              'favorite_count': 844,
              'comment_count': 172,
              'created_time': created,
            },
            onAction: actions.add,
          ),
        ),
      ),
    );
    expect(find.text('1.2万'), findsOneWidget);
    expect(find.text('844'), findsOneWidget);
    expect(find.text('172'), findsOneWidget);
    expect(find.text('发布于 2024-01-02'), findsOneWidget);
    final vote = find.byIcon(Icons.change_history_outlined);
    final favorite = find.byIcon(Icons.star_border_rounded);
    final comments = find.byIcon(Icons.chat_bubble_outline_rounded);
    expect(tester.widget<Icon>(vote).size, 17);
    expect(tester.widget<Icon>(favorite).size, 17);
    expect(tester.widget<Icon>(comments).size, 17);
    await tester.tap(vote);
    await tester.tap(favorite);
    await tester.tap(comments);
    expect(actions, const [
      ContentCardAction.vote,
      ContentCardAction.favorite,
      ContentCardAction.comments,
    ]);
  });

  testWidgets('feed rows are borderless and keep type labels right-aligned', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: Column(
            children: [
              ObjectCard(
                feedMode: true,
                value: {
                  'type': 'answer',
                  'id': '1',
                  'title': '第一条',
                  'author': {'name': '短作者'},
                },
              ),
              ObjectCard(
                feedMode: true,
                value: {
                  'type': 'answer',
                  'id': '2',
                  'title': '第二条',
                  'author': {'name': '一个非常非常长的作者名字'},
                },
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(ShadCard), findsNothing);
    final labels = find.text('回答');
    expect(labels, findsNWidgets(2));
    final firstRight = tester.getTopRight(labels.at(0)).dx;
    final secondRight = tester.getTopRight(labels.at(1)).dx;
    expect((firstRight - secondRight).abs(), lessThan(0.01));
  });

  testWidgets('answer avatar handles profile tap without opening its card', (
    tester,
  ) async {
    var authorTaps = 0;
    var cardTaps = 0;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: ObjectCard(
            feedMode: true,
            value: const {
              'type': 'answer',
              'id': '42',
              'title': '可点击作者头像的回答',
              'author': {
                'name': '作者甲',
                'url_token': 'author-a',
                'avatar_url': 'https://pic.example.test/author-a.jpg',
              },
            },
            onTap: () => cardTaps++,
            onAuthorTap: () => authorTaps++,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('content-author-avatar-42')));
    await tester.pump();
    expect(authorTaps, 1);
    expect(cardTaps, 0);
  });

  testWidgets('feed display settings hide images and metrics', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: ObjectCard(
            feedMode: true,
            compact: true,
            showImages: false,
            showMetrics: false,
            value: {
              'type': 'answer',
              'id': '42',
              'title': '可定制推荐',
              'excerpt': '紧凑内容摘要',
              'voteup_count': 77,
              'extra': {
                'business_ext_map': {
                  'images': [
                    {'url': 'https://pic.example.test/feed.jpg'},
                  ],
                },
              },
            },
          ),
        ),
      ),
    );
    expect(find.text('可定制推荐'), findsOneWidget);
    expect(find.text('77'), findsNothing);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets(
    'content previews use taller fixed crop frames without decode stretching',
    (tester) async {
      const single = 'https://pic.example.test/single-tall.jpg';
      const compactSingle = 'https://pic.example.test/compact-single-wide.jpg';
      const regularMulti = [
        'https://pic.example.test/regular-multi-1.jpg',
        'https://pic.example.test/regular-multi-2.jpg',
        'https://pic.example.test/regular-multi-3.jpg',
      ];
      const compactMulti = [
        'https://pic.example.test/compact-multi-1.jpg',
        'https://pic.example.test/compact-multi-2.jpg',
      ];

      await tester.pumpWidget(
        _testApp(
          const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ContentImageStrip(urls: [single]),
                    ContentImageStrip(urls: [compactSingle], compact: true),
                    ContentImageStrip(urls: regularMulti),
                    ContentImageStrip(urls: compactMulti, compact: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      for (final url in const [single, compactSingle]) {
        final frame = find.byKey(ValueKey('content-preview-frame-single-$url'));
        final imageFinder = find.byKey(ValueKey('content-preview-image-$url'));
        expect(frame, findsOneWidget);
        expect(tester.getSize(frame), const Size(360, 128));

        final image = tester.widget<Image>(imageFinder);
        expect(image.fit, BoxFit.cover);
        expect(image.alignment, Alignment.center);
        expect(image.image, isA<ResizeImage>());
        final resized = image.image as ResizeImage;
        expect(resized.width, 960);
        expect(
          resized.height,
          isNull,
          reason: 'width-only decoding must preserve the source aspect ratio',
        );
      }

      for (final urls in [regularMulti, compactMulti]) {
        final visibleColumns = min(urls.length, 3);
        final expectedWidth = (360 - 7 * (visibleColumns - 1)) / visibleColumns;
        final frames = [
          for (final url in urls)
            find.byKey(ValueKey('content-preview-frame-multi-$url')),
        ];
        for (final frame in frames) {
          expect(tester.getSize(frame), Size(expectedWidth, 128));
        }
      }
      for (final url in [...regularMulti, ...compactMulti]) {
        final image = tester.widget<Image>(_networkImageFinder(url));
        expect(image.fit, BoxFit.cover);
        expect(image.image, isA<ResizeImage>());
        final resized = image.image as ResizeImage;
        expect(resized.width, 384);
        expect(resized.height, isNull);
      }
    },
  );

  testWidgets('home feed renders the persisted channel order', (tester) async {
    final session = SessionStore()
      ..homeFeedOrder = const [
        HomeFeedChannel.hot,
        HomeFeedChannel.recommend,
        HomeFeedChannel.following,
        HomeFeedChannel.story,
      ];
    final transport = _RecordingTransport()
      ..responses.add(
        _response(
          '/topstory/recommend',
          json: const {
            'data': <Object>[],
            'paging': {'is_end': true},
          },
        ),
      );
    final api = ZhihuApiClient(
      session,
      transport: transport,
      xZseSigner: XZseSigner(cipher: _FakeXZseCipher()),
    );
    addTearDown(api.close);

    await tester.pumpWidget(_testApp(FeedPage(api: api)));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(find.text('热榜')).dx,
      lessThan(tester.getCenter(find.text('推荐')).dx),
    );
    expect(
      tester.getCenter(find.text('推荐')).dx,
      lessThan(tester.getCenter(find.text('关注')).dx),
    );
    expect(
      tester.getCenter(find.text('关注')).dx,
      lessThan(tester.getCenter(find.text('故事')).dx),
    );
  });
}
