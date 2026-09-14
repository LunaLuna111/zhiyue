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
    final previous = _credentialSnapshot();
    _credentialRevision += 1;
    _clearPendingAccountCleanup();
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
    final committed = await _commitCredentialMutation(
      previous: previous,
      next: _credentialSnapshot(),
      operation: 'import_session',
    );
    if (!committed) throw StateError('本地登录数据库不可用，导入会话已回滚');
  }

  Future<void> saveMsId(String value) async {
    if (kIsWeb) return;
    final normalized = value.trim();
    _SessionStoreCore._validateHeaderValue('X-MS-ID', normalized);
    if (normalized == msId) return;
    final previous = _credentialSnapshot();
    _credentialRevision += 1;
    _clearPendingAccountCleanup();
    msId = normalized;
    final committed = await _commitCredentialMutation(
      previous: previous,
      next: _credentialSnapshot(),
      operation: 'save_ms_id',
    );
    if (!committed) throw StateError('本地登录数据库不可用，MS-ID 修改已回滚');
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
    final previous = _credentialSnapshot();
    _credentialRevision += 1;
    _clearPendingAccountCleanup();
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
    extraHeadersJson = '';
    final committed = await _commitCredentialMutation(
      previous: previous,
      next: _credentialSnapshot(),
      operation: 'save_guest_session',
    );
    if (!committed) throw StateError('本地登录数据库不可用，访客会话已回滚');
  }

  /// Clears only the anonymous API credentials after the server explicitly
  /// rejects that guest context. The synthetic device profile lives in the
  /// Android app's private preferences and is deliberately left untouched, as
  /// are local UI settings and the installation-scoped MS-ID.
  Future<void> clearGuestSession() async {
    if (sessionKind != 'guest') return;
    final previous = _credentialSnapshot();
    _credentialRevision += 1;
    _clearPendingAccountCleanup();
    authorization = '';
    udid = '';
    cookie = '';
    xZse96 = '';
    xZse96Target = '';
    extraHeadersJson = '';
    sessionKind = '';
    refreshToken = '';
    accessTokenExpiry = null;
    accessTokenRefreshAt = null;
    _clearAccountMetadataValues();
    final committed = await _commitCredentialMutation(
      previous: previous,
      next: _credentialSnapshot(),
      operation: 'clear_guest_session',
    );
    if (!committed) throw StateError('本地登录数据库不可用，访客会话清理已回滚');
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
    final previous = _credentialSnapshot();
    _credentialRevision += 1;
    _clearPendingAccountCleanup();
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
    extraHeadersJson = '';
    return _commitCredentialMutation(
      previous: previous,
      next: _credentialSnapshot(),
      operation: 'save_account_session',
    );
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
    final previous = _credentialSnapshot();
    _credentialRevision += 1;
    _clearPendingAccountCleanup();
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
    extraHeadersJson = '';
    return _commitCredentialMutation(
      previous: previous,
      next: _credentialSnapshot(),
      operation: 'save_qr_session',
    );
  }

  Future<bool> requestAccountSessionCleanup(
    zhihu_api.ApiSessionCleanupRequest request,
  ) async {
    if (!hasRefreshableAccountSession ||
        request.credentialRevision != _credentialRevision) {
      _recordAuthenticationLog(
        '忽略过期的账号清理请求，当前会话已经变化',
        level: AppLogLevel.warning,
        details: {
          'source': request.source,
          'request_revision': request.credentialRevision,
          'current_revision': _credentialRevision,
          'action': 'retained',
        },
      );
      return false;
    }
    final existing = _pendingAccountCleanup;
    if (existing != null &&
        existing.credentialRevision == request.credentialRevision) {
      return true;
    }
    final dismissedAt = _lastDismissedCleanupAt;
    if (_lastDismissedCleanupRevision == request.credentialRevision &&
        dismissedAt != null &&
        DateTime.now().difference(dismissedAt) < const Duration(minutes: 10)) {
      return false;
    }
    _pendingAccountCleanup = request;
    _recordAuthenticationLog(
      '检测到账号会话可能失效，等待用户确认是否清理',
      level: AppLogLevel.warning,
      details: {
        'source': request.source,
        'status_code': ?request.statusCode,
        'business_code': ?request.businessCode,
        'credential_revision': request.credentialRevision,
        'action': 'confirmation_required',
      },
    );
    _notifyChanged();
    return true;
  }

  /// Confirms a pending server-side logout signal. The credentials are first
  /// copied to the recovery table, then removed from the active session.
  Future<bool> confirmPendingAccountCleanup() async {
    final request = _pendingAccountCleanup;
    if (request == null) return false;
    if (!hasRefreshableAccountSession ||
        request.credentialRevision != _credentialRevision) {
      _pendingAccountCleanup = null;
      _recordAuthenticationLog(
        '账号清理确认已失效，保留当前会话',
        level: AppLogLevel.warning,
        details: const {'action': 'retained', 'reason': 'session_changed'},
      );
      _notifyChanged();
      return false;
    }
    final cleared = await _clearCredentials(
      reason: 'confirmed_server_logout',
      expectedCredentialRevision: request.credentialRevision,
    );
    if (cleared) {
      _recordAuthenticationLog(
        '用户确认清理账号会话，凭据已进入可恢复区',
        details: {'source': request.source, 'action': 'archived_and_cleared'},
      );
    }
    return cleared;
  }

  Future<void> dismissPendingAccountCleanup() async {
    final request = _pendingAccountCleanup;
    if (request == null) return;
    _pendingAccountCleanup = null;
    _lastDismissedCleanupRevision = request.credentialRevision;
    _lastDismissedCleanupAt = DateTime.now();
    _recordAuthenticationLog(
      '用户保留账号会话，取消本次自动清理',
      details: {
        'source': request.source,
        'credential_revision': request.credentialRevision,
        'action': 'retained',
      },
    );
    _notifyChanged();
  }

  Future<bool> restoreLastClearedAccountSession() async {
    final recovery = _storage is CredentialRecoveryStore
        ? _storage as CredentialRecoveryStore
        : null;
    if (recovery == null) return false;
    Map<String, String>? values;
    try {
      values = await recovery.readLatestCredentialSnapshot();
    } on Object catch (error, stackTrace) {
      _recordAuthenticationLog(
        '读取账号恢复副本失败，未修改当前会话',
        level: AppLogLevel.error,
        details: {
          'operation': 'read_recovery_snapshot',
          'error_type': error.runtimeType.toString(),
          'action': 'retained',
        },
      );
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '读取账号恢复副本失败',
          category: AppLogCategory.authentication,
        ),
      );
      return false;
    }
    final snapshot = values == null
        ? null
        : SessionCredentialSnapshot.fromStoredValues(values);
    if (snapshot == null || !snapshot.isRecoverableSession) {
      _recordAuthenticationLog(
        '恢复区没有可用的账号会话',
        level: AppLogLevel.warning,
        details: const {'action': 'restore_failed'},
      );
      return false;
    }
    final previous = _credentialSnapshot();
    _credentialRevision += 1;
    _clearPendingAccountCleanup();
    _applyCredentialSnapshot(snapshot);
    final committed = await _commitCredentialMutation(
      previous: previous,
      next: snapshot,
      operation: 'restore_credential_snapshot',
    );
    if (!committed) return false;
    try {
      await recovery.removeLatestCredentialSnapshot();
    } on Object catch (error, stackTrace) {
      // The restored session is already durable. Keep the recovery copy if
      // deleting it fails so the user can retry instead of losing recovery.
      _recordAuthenticationLog(
        '恢复副本删除失败，已保留恢复副本并完成会话恢复',
        level: AppLogLevel.warning,
        details: {
          'operation': 'remove_recovery_snapshot',
          'error_type': error.runtimeType.toString(),
          'action': 'retained',
        },
      );
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '恢复副本删除失败',
          category: AppLogCategory.authentication,
        ),
      );
    }
    try {
      _hasRecoverableAccountSession = await recovery.hasCredentialRecovery();
    } on Object catch (error, stackTrace) {
      // The active session is already durable. Keep the recovery indicator
      // visible if the follow-up status read is unavailable.
      _hasRecoverableAccountSession = true;
      _recordAuthenticationLog(
        '恢复成功但无法确认恢复副本状态，保留恢复入口',
        level: AppLogLevel.warning,
        details: {
          'operation': 'check_recovery_snapshot',
          'error_type': error.runtimeType.toString(),
          'action': 'retained',
        },
      );
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '确认恢复副本状态失败',
          category: AppLogCategory.authentication,
        ),
      );
    }
    _recordAuthenticationLog(
      '已从恢复区恢复账号会话',
      details: const {'action': 'restored'},
    );
    _notifyChanged();
    return true;
  }

  Future<bool> permanentlyClearRecoveredAccountSessions() async {
    final recovery = _storage is CredentialRecoveryStore
        ? _storage as CredentialRecoveryStore
        : null;
    if (recovery == null) return false;
    try {
      await recovery.clearCredentialRecovery();
      _hasRecoverableAccountSession = false;
      _recordAuthenticationLog(
        '用户彻底清理恢复区中的账号凭据',
        details: const {'action': 'permanently_deleted'},
      );
      _notifyChanged();
      return true;
    } on Object catch (error, stackTrace) {
      _recordAuthenticationLog(
        '恢复区彻底清理失败，凭据仍保留',
        level: AppLogLevel.error,
        details: {
          'operation': 'clear_recovery_store',
          'error_type': error.runtimeType.toString(),
          'action': 'retained',
        },
      );
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: '恢复区彻底清理失败',
          category: AppLogCategory.authentication,
        ),
      );
      return false;
    }
  }

  Future<void> clear() async {
    await clearAndReport();
  }

  Future<bool> clearAndReport() => _clearCredentials(reason: 'manual_logout');

  Future<bool> clearAccountCredentialsAndReport() =>
      _clearCredentials(reason: 'account_slot_removed');

  Future<bool> _clearCredentials({
    required String reason,
    int? expectedCredentialRevision,
  }) async {
    final revisionAtStart = _credentialRevision;
    if (expectedCredentialRevision != null &&
        expectedCredentialRevision != revisionAtStart) {
      return false;
    }
    final snapshot = _credentialSnapshot();
    final recovery = _storage is CredentialRecoveryStore
        ? _storage as CredentialRecoveryStore
        : null;
    // Flutter widget tests intentionally use an in-memory/session adapter and
    // do not have a registered path-provider host. Production mobile/desktop
    // builds always archive into the private recovery table before clearing.
    if (snapshot.isRecoverableSession &&
        recovery != null &&
        (!zhIsFlutterTest || _persistInFlutterTests)) {
      try {
        await recovery.archiveCredentialSnapshot(
          values: snapshot.toStoredValues(),
          reason: reason,
          detectedAt: DateTime.now().toUtc(),
        );
        _hasRecoverableAccountSession = true;
      } on Object catch (error) {
        _recordAuthenticationLog(
          '账号凭据备份到恢复区失败，已取消清理',
          level: AppLogLevel.error,
          details: {
            'action': 'retained',
            'error_type': error.runtimeType.toString(),
          },
        );
        return false;
      }
    }
    if (revisionAtStart != _credentialRevision ||
        (expectedCredentialRevision != null &&
            expectedCredentialRevision != _credentialRevision)) {
      return false;
    }
    final previous = snapshot;
    _credentialRevision += 1;
    _clearPendingAccountCleanup();
    _resetValues();
    if (kIsWeb) {
      _recordAuthenticationLog(
        '账号会话已清理',
        details: {'reason': reason, 'action': 'cleared'},
      );
      _notifyChanged();
      return true;
    }
    _recordAuthenticationLog(
      reason == 'manual_logout' ? '用户退出登录' : '账号会话已清理',
      details: {'reason': reason, 'action': 'cleared'},
    );
    return _commitCredentialMutation(
      previous: previous,
      next: _credentialSnapshot(),
      operation: 'clear_credentials',
    );
  }
}
