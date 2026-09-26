import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'webdav_models.dart';

/// OAuth credentials never enter the WebDAV settings JSON or remote sync data.
class CloudSyncAuth {
  CloudSyncAuth({FlutterAppAuth? appAuth, FlutterSecureStorage? storage})
    : _appAuth = appAuth ?? const FlutterAppAuth(),
      _storage = storage ?? const FlutterSecureStorage();

  static final instance = CloudSyncAuth();
  static const microsoftClientId = String.fromEnvironment(
    'MICROSOFT_CLIENT_ID',
  );
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const microsoftRedirect = String.fromEnvironment(
    'MICROSOFT_REDIRECT_URI',
    defaultValue: 'zhiyue-oauth://auth',
  );
  static const _googleScope = 'https://www.googleapis.com/auth/drive.appdata';
  static const _microsoftScopes = <String>[
    'offline_access',
    'Files.ReadWrite.AppFolder',
  ];
  static const _microsoftService = AuthorizationServiceConfiguration(
    authorizationEndpoint:
        'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
    tokenEndpoint: 'https://login.microsoftonline.com/common/oauth2/v2.0/token',
  );
  static const _refreshKey = 'zh_cloud_ms_refresh_v1';

  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _storage;
  Future<void>? _googleInitialization;
  GoogleSignInAccount? _googleAccount;
  String? _microsoftAccessToken;
  DateTime? _microsoftExpiresAt;

  bool isAvailable(WebDavProviderKind provider) =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      switch (provider) {
        WebDavProviderKind.googleDrive => googleServerClientId.isNotEmpty,
        WebDavProviderKind.oneDrive => microsoftClientId.isNotEmpty,
        _ => false,
      };

  Future<void> signIn(WebDavProviderKind provider) async {
    if (!isAvailable(provider)) {
      throw StateError('云盘授权尚未配置应用注册信息');
    }
    switch (provider) {
      case WebDavProviderKind.googleDrive:
        await _initializeGoogle();
        final account = await GoogleSignIn.instance.authenticate(
          scopeHint: const [_googleScope],
        );
        await account.authorizationClient.authorizeScopes(const [_googleScope]);
        _googleAccount = account;
      case WebDavProviderKind.oneDrive:
        final response = await _appAuth.authorizeAndExchangeCode(
          AuthorizationTokenRequest(
            microsoftClientId,
            microsoftRedirect,
            serviceConfiguration: _microsoftService,
            scopes: _microsoftScopes,
          ),
        );
        final refresh = response.refreshToken;
        if (refresh == null || refresh.isEmpty) {
          throw StateError('Microsoft 未返回续期凭据，请重新授权');
        }
        await _storage.write(key: _refreshKey, value: refresh);
        _rememberMicrosoftToken(response);
      default:
        throw ArgumentError.value(provider, 'provider');
    }
  }

  Future<String> accessToken(WebDavProviderKind provider) async {
    if (!isAvailable(provider)) {
      throw StateError('云盘授权尚未配置应用注册信息');
    }
    switch (provider) {
      case WebDavProviderKind.googleDrive:
        await _initializeGoogle();
        final account =
            _googleAccount ??
            await GoogleSignIn.instance.attemptLightweightAuthentication();
        if (account == null) throw StateError('请先授权 Google Drive');
        _googleAccount = account;
        final authorization = await account.authorizationClient
            .authorizationForScopes(const [_googleScope]);
        if (authorization == null) throw StateError('Google Drive 授权已过期，请重新授权');
        return authorization.accessToken;
      case WebDavProviderKind.oneDrive:
        final token = _microsoftAccessToken;
        if (token != null &&
            _microsoftExpiresAt?.isAfter(
                  DateTime.now().add(const Duration(minutes: 2)),
                ) ==
                true) {
          return token;
        }
        final refresh = await _storage.read(key: _refreshKey);
        if (refresh == null || refresh.isEmpty) {
          throw StateError('请先授权 Microsoft OneDrive');
        }
        final response = await _appAuth.token(
          TokenRequest(
            microsoftClientId,
            microsoftRedirect,
            serviceConfiguration: _microsoftService,
            scopes: _microsoftScopes,
            refreshToken: refresh,
          ),
        );
        final nextRefresh = response.refreshToken;
        if (nextRefresh != null && nextRefresh.isNotEmpty) {
          await _storage.write(key: _refreshKey, value: nextRefresh);
        }
        _rememberMicrosoftToken(response);
        return _microsoftAccessToken!;
      default:
        throw ArgumentError.value(provider, 'provider');
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _refreshKey);
    _microsoftAccessToken = null;
    _microsoftExpiresAt = null;
    if (_googleInitialization != null) {
      await GoogleSignIn.instance.signOut();
    }
    _googleAccount = null;
  }

  Future<void> _initializeGoogle() => _googleInitialization ??= GoogleSignIn
      .instance
      .initialize(serverClientId: googleServerClientId);

  Future<String> googleAccessToken() =>
      accessToken(WebDavProviderKind.googleDrive);

  void _rememberMicrosoftToken(TokenResponse response) {
    final token = response.accessToken;
    if (token == null || token.isEmpty) throw StateError('Microsoft 未返回访问令牌');
    _microsoftAccessToken = token;
    _microsoftExpiresAt = response.accessTokenExpirationDateTime;
  }
}
