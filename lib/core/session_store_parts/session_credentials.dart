part of '../session_store.dart';

mixin _SessionStoreCredentialsMixin on _SessionStoreCore {
  Future<void> save({
    required String authorization,
    required String udid,
    required String cookie,
    required String msId,
    required String xZse96,
    required String xZse96Target,
    required String extraHeadersJson,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('桌面浏览器预览不接收或存储 API 会话材料');
    }
    _SessionStoreCore.parseExtraHeaders(extraHeadersJson);
    _SessionStoreCore._validateHeaderValue('Authorization', authorization);
    _SessionStoreCore._validateHeaderValue('x-udid', udid);
    _SessionStoreCore._validateHeaderValue('Cookie', cookie);
    _SessionStoreCore._validateHeaderValue('X-MS-ID', msId);
    _SessionStoreCore._validateHeaderValue('X-Zse-96', xZse96);
    final normalizedTarget = _SessionStoreCore.normalizeSignatureTarget(
      xZse96Target,
    );
    if (xZse96.trim().isEmpty != normalizedTarget.isEmpty) {
      throw const FormatException('X-Zse-96 与精确请求目标必须同时填写或同时留空');
    }
    final normalizedAuthorization = authorization.trim();
    final normalizedUdid = udid.trim();
    final normalizedCookie = cookie.trim();
    final normalizedMsId = msId.trim();
    final normalizedZse96 = xZse96.trim();
    final normalizedExtraHeaders = extraHeadersJson.trim();
    _credentialRevision += 1;
    this.authorization = normalizedAuthorization;
    this.udid = normalizedUdid;
    this.cookie = normalizedCookie;
    this.msId = normalizedMsId;
    this.xZse96 = normalizedZse96;
    this.xZse96Target = normalizedTarget;
    this.extraHeadersJson = normalizedExtraHeaders;
    sessionKind = this.authorization.isEmpty ? '' : 'imported';
    refreshToken = '';
    accessTokenExpiry = null;
    accessTokenRefreshAt = null;
    _clearAccountMetadataValues();
    final snapshot = _credentialSnapshot();
    final persistence = _queueCredentialPersistence(
      () => _persistCredentialSnapshot(snapshot),
    );
    _notifyChanged();
    await persistence;
  }

  Future<void> saveMsId(String value) async {
    if (kIsWeb) return;
    final normalized = value.trim();
    _SessionStoreCore._validateHeaderValue('X-MS-ID', normalized);
    if (normalized == msId) return;
    msId = normalized;
    final snapshot = _credentialSnapshot();
    final persistence = _queueCredentialPersistence(
      () => _persistCredentialSnapshot(snapshot),
    );
    _notifyChanged();
    await persistence;
  }

  Future<void> saveGuestSession({
    required String accessToken,
    required String udid,
    String zCookie = '',
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('桌面浏览器预览不接收或存储 API 会话材料');
    }
    final normalizedAccessToken = accessToken.trim();
    final normalizedUdid = udid.trim();
    if (normalizedAccessToken.isEmpty || normalizedUdid.isEmpty) {
      throw const FormatException('guest access_token 和 udid 不能为空');
    }
    final normalizedCookie = zCookie.trim().isEmpty
        ? ''
        : 'z_c0=${zCookie.trim()}';
    _SessionStoreCore._validateHeaderValue(
      'Authorization',
      normalizedAccessToken,
    );
    _SessionStoreCore._validateHeaderValue('x-udid', normalizedUdid);
    _SessionStoreCore._validateHeaderValue('Cookie', normalizedCookie);
    _credentialRevision += 1;
    authorization = 'Bearer $normalizedAccessToken';
    this.udid = normalizedUdid;
    cookie = normalizedCookie;
    sessionKind = 'guest';
    refreshToken = '';
    accessTokenExpiry = null;
    accessTokenRefreshAt = null;
    _clearAccountMetadataValues();
    xZse96 = '';
    xZse96Target = '';
    final snapshot = _credentialSnapshot();
    final persistence = _queueCredentialPersistence(
      () => _persistCredentialSnapshot(snapshot),
    );
    _notifyChanged();
    await persistence;
  }

  /// Clears only the anonymous API credentials after the server explicitly
  /// rejects that guest context. The synthetic device profile lives in the
  /// Android app's private preferences and is deliberately left untouched, as
  /// are local UI settings and the installation-scoped MS-ID.
  Future<void> clearGuestSession() async {
    if (sessionKind != 'guest') return;
    _credentialRevision += 1;
    authorization = '';
    udid = '';
    cookie = '';
    xZse96 = '';
    xZse96Target = '';
    sessionKind = '';
    refreshToken = '';
    accessTokenExpiry = null;
    accessTokenRefreshAt = null;
    _clearAccountMetadataValues();
    final snapshot = _credentialSnapshot();
    final persistence = _queueCredentialPersistence(
      () => _persistCredentialSnapshot(snapshot),
    );
    _notifyChanged();
    await persistence;
  }

  /// Saves an account response unless another credential mutation superseded
  /// the operation that produced it.
  ///
  /// [expectedCredentialRevision] is used by token refresh. The comparison
  /// and revision claim happen synchronously on the isolate, making the
  /// conditional commit atomic with respect to logout/import/guest changes.
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
    if (kIsWeb) {
      throw UnsupportedError('桌面浏览器预览不接收或存储 API 会话材料');
    }
    // A superseded network result is no longer relevant, including when a
    // logout already cleared the udid that the caller would otherwise pass
    // below. Reject it before validating any now-stale response material.
    // This method has no await before the revision claim, so the comparison,
    // validation and increment remain one atomic isolate turn.
    if (expectedCredentialRevision != null &&
        expectedCredentialRevision != _credentialRevision) {
      return false;
    }
    final normalizedAccessToken = accessToken.trim();
    final normalizedRefreshToken = refreshToken.trim();
    final normalizedUdid = udid.trim();
    final normalizedType = tokenType.trim();
    if (normalizedAccessToken.isEmpty ||
        normalizedRefreshToken.isEmpty ||
        normalizedUdid.isEmpty ||
        expiresIn <= Duration.zero) {
      throw const FormatException('账号 access/refresh token、udid 和有效期不能为空');
    }
    if (normalizedType.toLowerCase() != 'bearer') {
      throw const FormatException('当前只接受 Bearer token_type');
    }
    if (lockInSeconds != null && lockInSeconds < 0) {
      throw const FormatException('lock_in 不能为负数');
    }
    final normalizedCookie = zCookie.trim().isEmpty
        ? ''
        : 'z_c0=${zCookie.trim()}';
    _SessionStoreCore._validateHeaderValue(
      'access_token',
      normalizedAccessToken,
    );
    _SessionStoreCore._validateHeaderValue(
      'refresh_token',
      normalizedRefreshToken,
    );
    _SessionStoreCore._validateHeaderValue('x-udid', normalizedUdid);
    _SessionStoreCore._validateHeaderValue('Cookie', normalizedCookie);
    final normalizedAccountUid = uid?.trim() ?? accountUid;
    final normalizedAccountUserId = userId?.trim() ?? accountUserId;
    final normalizedAccountScope = scope?.trim() ?? accountScope;
    final normalizedUnlockTicket = unlockTicket?.trim() ?? accountUnlockTicket;
    final normalizedLockInSeconds = lockInSeconds ?? accountLockInSeconds;
    _SessionStoreCore._validateHeaderValue('account uid', normalizedAccountUid);
    _SessionStoreCore._validateHeaderValue(
      'account user_id',
      normalizedAccountUserId,
    );
    _SessionStoreCore._validateHeaderValue(
      'account scope',
      normalizedAccountScope,
    );
    _SessionStoreCore._validateHeaderValue(
      'account unlock_ticket',
      normalizedUnlockTicket,
    );
    _credentialRevision += 1;
    authorization = 'Bearer $normalizedAccessToken';
    this.refreshToken = normalizedRefreshToken;
    this.udid = normalizedUdid;
    cookie = normalizedCookie;
    sessionKind = 'account';
    final issuedAt = DateTime.now().toUtc();
    accessTokenExpiry = issuedAt.add(expiresIn);
    // Official 11.4.0 schedules account refresh at expires_in * 21 / 30.
    accessTokenRefreshAt = issuedAt.add(
      Duration(milliseconds: expiresIn.inMilliseconds * 21 ~/ 30),
    );
    accountUid = normalizedAccountUid;
    accountUserId = normalizedAccountUserId;
    accountScope = normalizedAccountScope;
    accountUnlockTicket = normalizedUnlockTicket;
    accountLockInSeconds = normalizedLockInSeconds;
    xZse96 = '';
    xZse96Target = '';
    final snapshot = _credentialSnapshot();
    final persistence = _queueCredentialPersistence(
      () => _persistCredentialSnapshot(snapshot),
    );
    _notifyChanged();
    await persistence;
    return true;
  }

  /// Stores a verified web/QR session without manufacturing a refresh token.
  /// QR sessions keep the same device context but are never sent through the
  /// mobile token-refresh recovery path.
  Future<bool> saveQrSession({
    required String cookie,
    required String udid,
    String? uid,
    String? userId,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('桌面浏览器预览不接收或存储 API 会话材料');
    }
    final normalizedCookie = cookie.trim();
    final normalizedUdid = udid.trim();
    if (normalizedUdid.isEmpty || normalizedCookie.isEmpty) {
      throw const FormatException('扫码登录 Cookie 和 udid 不能为空');
    }
    if (!normalizedCookie.split(';').any((part) {
      final separator = part.indexOf('=');
      return separator > 0 &&
          part.substring(0, separator).trim().toLowerCase() == 'z_c0' &&
          part.substring(separator + 1).trim().isNotEmpty;
    })) {
      throw const FormatException('扫码登录响应缺少 z_c0 Cookie');
    }
    _SessionStoreCore._validateHeaderValue('Cookie', normalizedCookie);
    _SessionStoreCore._validateHeaderValue('x-udid', normalizedUdid);
    final normalizedUid = uid?.trim() ?? '';
    final normalizedUserId = userId?.trim() ?? '';
    _SessionStoreCore._validateHeaderValue('account uid', normalizedUid);
    _SessionStoreCore._validateHeaderValue('account user_id', normalizedUserId);
    _credentialRevision += 1;
    authorization = CloudIdSigner.oauthAuthorization;
    this.udid = normalizedUdid;
    this.cookie = normalizedCookie;
    sessionKind = 'qr';
    refreshToken = '';
    accessTokenExpiry = null;
    accessTokenRefreshAt = null;
    accountUid = normalizedUid;
    accountUserId = normalizedUserId;
    accountScope = '';
    accountUnlockTicket = '';
    accountLockInSeconds = 0;
    xZse96 = '';
    xZse96Target = '';
    final snapshot = _credentialSnapshot();
    final persistence = _queueCredentialPersistence(
      () => _persistCredentialSnapshot(snapshot),
    );
    _notifyChanged();
    await persistence;
    return true;
  }

  Future<void> clear() async {
    _credentialRevision += 1;
    _resetValues();
    if (kIsWeb) {
      _notifyChanged();
      return;
    }
    final snapshot = _credentialSnapshot();
    final persistence = _queueCredentialPersistence(
      () => _persistCredentialSnapshot(snapshot),
    );
    _notifyChanged();
    await persistence;
  }
}
