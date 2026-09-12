part of '../core_test.dart';

Widget _testApp(Widget home) => ShadTheme(
  data: ZhTheme.shad,
  child: MaterialApp(theme: ZhTheme.material, home: home),
);

Finder _networkImageFinder(String url) => find.byWidgetPredicate((widget) {
  if (widget is! Image) return false;
  final provider = widget.image;
  final unwrapped = provider is ResizeImage ? provider.imageProvider : provider;
  return unwrapped is NetworkImage && unwrapped.url == url;
});

void _noop() {}

class _FakeXZseCipher implements XZseCipher {
  String lastMd5Lower = '';

  @override
  Future<Uint8List> encryptMd5Hex({
    required String md5Lower,
    required String key,
    required Uint8List iv,
  }) async {
    lastMd5Lower = md5Lower;
    expectSync(key.length, 360);
    expectSync(ascii.decode(iv), XZseSigner.ivAscii);
    return Uint8List.fromList(List<int>.generate(48, (index) => index));
  }
}

class _LengthMatchingLoginCipher implements MobileLoginBodyCipher {
  int lastPlaintextBytes = 0;

  @override
  Future<Uint8List> encryptBytes({
    required Uint8List input,
    required String key,
    required Uint8List iv,
  }) async {
    lastPlaintextBytes = input.length;
    expect(key.length, 360);
    expect(ascii.decode(iv), XZseSigner.ivAscii);
    final encryptedLength = switch (input.length) {
      80 => 80,
      195 => 240,
      _ => input.length,
    };
    return Uint8List.fromList(
      List<int>.generate(encryptedLength, (index) => index & 0xff),
    );
  }
}

class _RecordedCall {
  const _RecordedCall({
    required this.method,
    required this.uri,
    required this.headers,
    required this.body,
  });

  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final List<int>? body;
}

class _HoldingSecureStorage extends FlutterSecureStorage {
  final values = <String, String>{};
  final firstMutationStarted = Completer<void>();
  final _releaseFirstMutation = Completer<void>();
  var _holdNextMutation = true;

  void releaseFirstMutation() {
    if (!_releaseFirstMutation.isCompleted) {
      _releaseFirstMutation.complete();
    }
  }

  Future<void> _waitIfFirstMutation() async {
    if (!_holdNextMutation) return;
    _holdNextMutation = false;
    firstMutationStarted.complete();
    await _releaseFirstMutation.future;
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    await _waitIfFirstMutation();
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    await _waitIfFirstMutation();
    values.remove(key);
  }
}

class _HoldingAccountRefreshTransport extends ApiTransport {
  _HoldingAccountRefreshTransport({this.rejectInitialRequest = false});

  final bool rejectInitialRequest;
  final calls = <_RecordedCall>[];
  final refreshStarted = Completer<void>();
  final _refreshResponse = Completer<ApiResponse>();
  var _targetCalls = 0;

  void completeRefresh({bool rejected = false}) {
    if (_refreshResponse.isCompleted) return;
    _refreshResponse.complete(
      rejected
          ? _response(
              MobileLoginContract.signInPath,
              statusCode: 400,
              json: const {
                'error': {'code': 100008, 'message': 'refresh token invalid'},
              },
            )
          : _response(
              MobileLoginContract.signInPath,
              json: const {
                'access_token': 'late-access',
                'refresh_token': 'late-refresh',
                'expires_in': 3600,
                'token_type': 'Bearer',
              },
              headers: const {
                'set-cookie': 'z_c0=late-cookie; Path=/; HttpOnly',
              },
            ),
    );
  }

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) {
    calls.add(
      _RecordedCall(
        method: method,
        uri: uri,
        headers: Map<String, String>.from(headers),
        body: body == null ? null : List<int>.from(body),
      ),
    );
    if (uri.path == MobileLoginContract.signInPath) {
      if (!refreshStarted.isCompleted) refreshStarted.complete();
      return _refreshResponse.future;
    }
    _targetCalls += 1;
    if (rejectInitialRequest && _targetCalls == 1) {
      return Future.value(
        _response(
          uri.path,
          statusCode: 401,
          json: const {
            'error': {'code': 100, 'message': 'access token expired'},
          },
        ),
      );
    }
    return Future.value(_response(uri.path, json: const {'id': 'member-id'}));
  }
}

class _RefreshHoldingTransport extends ApiTransport {
  final _refresh = Completer<ApiResponse>();
  var _recommendCalls = 0;

  void completeRefresh() {
    _refresh.complete(
      _response(
        '/topstory/recommend',
        json: const {
          'data': [
            {
              'target': {
                'type': 'answer',
                'id': 'after',
                'question': {'title': '刷新后内容'},
              },
            },
          ],
          'paging': {'is_end': true},
        },
      ),
    );
  }

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) {
    if (uri.path == '/topstory/recommend') {
      _recommendCalls += 1;
      if (_recommendCalls > 1) return _refresh.future;
      return Future.value(
        _response(
          '/topstory/recommend',
          json: const {
            'data': [
              {
                'target': {
                  'type': 'answer',
                  'id': 'before',
                  'question': {'title': '刷新前内容'},
                },
              },
            ],
            'paging': {'is_end': true},
          },
        ),
      );
    }
    return Future.value(
      ApiResponse(
        uri: uri,
        statusCode: 200,
        bodyBytes: 2,
        json: const {
          'data': <Object>[],
          'paging': {'is_end': true},
        },
        headers: const {},
      ),
    );
  }
}

class _RecordingTransport extends ApiTransport {
  final List<Map<String, String>> requests = [];
  final List<_RecordedCall> calls = [];
  final List<ApiResponse> responses = [];

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    requests.add(Map<String, String>.from(headers));
    calls.add(
      _RecordedCall(
        method: method,
        uri: uri,
        headers: Map<String, String>.from(headers),
        body: body == null ? null : List<int>.from(body),
      ),
    );
    if (responses.isNotEmpty) return responses.removeAt(0);
    return ApiResponse(
      uri: uri,
      statusCode: 200,
      bodyBytes: 2,
      json: const <String, dynamic>{},
      headers: const {},
    );
  }
}

class _RecentSearchTransport extends ApiTransport {
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
    if (uri.path == '/search_v3') {
      return ApiResponse(
        uri: uri,
        statusCode: 200,
        bodyBytes: 128,
        json: const {
          'data': [
            {
              'type': 'knowledge_result',
              'object': {
                'type': 'answer',
                'id': 'recent-answer',
                'question': {'title': '实时搜索结果'},
                'excerpt': '刚刚发布的内容',
              },
            },
          ],
          'paging': {'is_end': true},
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

class _HomeReselectTransport extends ApiTransport {
  _HomeReselectTransport({this.holdRefresh = false});

  final bool holdRefresh;
  final _heldRefresh = Completer<ApiResponse>();
  int recommendationCalls = 0;

  void completeRefresh() {
    if (!_heldRefresh.isCompleted) {
      _heldRefresh.complete(_recommendationResponse(isRefresh: true));
    }
  }

  ApiResponse _recommendationResponse({required bool isRefresh}) => ApiResponse(
    uri: Uri.parse('https://api.zhihu.com/topstory/recommend'),
    statusCode: 200,
    bodyBytes: 256,
    json: {
      'data': !isRefresh
          ? [
              for (var index = 0; index < 18; index++)
                {
                  'target': {
                    'type': 'answer',
                    'id': 'before-$index',
                    'question': {'title': '刷新前内容 $index'},
                    'excerpt': '用于验证回顶的推荐摘要 $index',
                  },
                },
            ]
          : [
              {
                'target': {
                  'type': 'answer',
                  'id': 'after',
                  'question': {'title': '刷新后内容'},
                },
              },
            ],
      'paging': {'is_end': true},
    },
    headers: const {},
  );

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required List<int>? body,
    required int maxResponseBytes,
  }) async {
    if (uri.path == '/topstory/recommend') {
      recommendationCalls += 1;
      if (recommendationCalls > 1 && holdRefresh) return _heldRefresh.future;
      return _recommendationResponse(isRefresh: recommendationCalls > 1);
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

ApiResponse _response(
  String path, {
  int statusCode = 200,
  Object? json = const <String, dynamic>{},
  Map<String, String> headers = const {},
}) => ApiResponse(
  uri: Uri.parse('https://api.zhihu.com$path'),
  statusCode: statusCode,
  bodyBytes: 0,
  json: json,
  headers: headers,
);

class _StaticCloudIdSigner extends CloudIdSigner {
  @override
  Future<String> appInfo() async => 'os=Android&version=15';
}

class _MemorySessionStore extends SessionStore {
  Duration? savedExpiresIn;
  int clearCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls += 1;
    await super.clear();
  }

  @override
  Future<bool> saveAccountSession({
    required String accessToken,
    required String refreshToken,
    required String udid,
    required Duration expiresIn,
    String tokenType = 'Bearer',
    String zCookie = '',
    String? uid,
    String? userId,
    String? scope,
    String? unlockTicket,
    int? lockInSeconds,
    int? expectedCredentialRevision,
  }) async {
    final committed = await super.saveAccountSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      udid: udid,
      expiresIn: expiresIn,
      tokenType: tokenType,
      zCookie: zCookie,
      uid: uid,
      userId: userId,
      scope: scope,
      unlockTicket: unlockTicket,
      lockInSeconds: lockInSeconds,
      expectedCredentialRevision: expectedCredentialRevision,
    );
    if (committed) savedExpiresIn = expiresIn;
    return committed;
  }
}

class _PreferenceSessionStore extends SessionStore {
  @override
  Future<void> setHomeFeedOrder(List<HomeFeedChannel> value) async {
    homeFeedOrder = List<HomeFeedChannel>.unmodifiable(value);
    notifyListeners();
  }
}

class _CountingCloudIdSigner extends CloudIdSigner {
  int deviceInfoCalls = 0;
  int signCalls = 0;

  @override
  Future<Map<String, Object?>> deviceInfo() async {
    deviceInfoCalls += 1;
    return const {};
  }

  @override
  Future<String> sign({
    required String body,
    required String requestTimestamp,
    String udid = '',
    String fallbackUdid = '',
  }) async {
    signCalls += 1;
    return 'unused';
  }
}

class _SaltRawKeyRandom implements Random {
  _SaltRawKeyRandom(String rawKey)
    : _indices = [
        for (final unit in rawKey.codeUnits)
          _alphabet.indexOf(String.fromCharCode(unit)),
      ];

  static const _alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  final List<int> _indices;
  var _index = 0;

  @override
  bool nextBool() => throw UnsupportedError('nextBool');

  @override
  double nextDouble() => throw UnsupportedError('nextDouble');

  @override
  int nextInt(int max) {
    if (max != _alphabet.length || _index >= _indices.length) {
      throw StateError('Unexpected salt raw-key random request.');
    }
    return _indices[_index++];
  }
}

Uint8List _hexBytes(String value) => Uint8List.fromList([
  for (var index = 0; index < value.length; index += 2)
    int.parse(value.substring(index, index + 2), radix: 16),
]);

String _bytesHex(Iterable<int> value) =>
    value.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
