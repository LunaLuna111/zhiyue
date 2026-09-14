import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zhiyue_client/core/account_session_store.dart';
import 'package:zhiyue_client/core/private_app_storage.dart';
import 'package:zhiyue_client/core/session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'failed account verification rolls back the candidate session',
    () async {
      final slotStorage = _MemoryStorage();
      final store = AccountSessionStore.withStorage(slotStorage);
      final first = await _importedSession(
        _MemoryStorage(),
        uid: 'account-a',
        access: 'access-a',
        device: 'device-a',
        extraHeaders: '{"x-a":"1"}',
      );
      final second = await _importedSession(
        _MemoryStorage(),
        uid: 'account-b',
        access: 'access-b',
        device: 'device-b',
        extraHeaders: '{"x-b":"1"}',
      );

      expect(await store.rememberCurrent(first), isTrue);
      expect(await store.rememberCurrent(second), isTrue);
      expect(store.activeId, 'account-b');

      expect(
        await store.activate('account-a', second, verify: () async => false),
        isFalse,
      );
      expect(second.accountUid, 'account-b');
      expect(second.authorization, 'Bearer access-b');
      expect(second.extraHeadersJson, '{"x-b":"1"}');
      expect(store.activeId, 'account-b');

      expect(
        await store.activate(
          'account-a',
          second,
          verify: () async => second.accountUid == 'account-a',
        ),
        isTrue,
      );
      expect(second.accountUid, 'account-a');
      expect(second.authorization, 'Bearer access-a');
      expect(second.udid, 'device-a');
      expect(second.extraHeadersJson, '{"x-a":"1"}');
      expect(store.activeId, 'account-a');
    },
  );

  test('account list read failure blocks every mutating operation', () async {
    final storage = _MemoryStorage()..failRead = true;
    final store = AccountSessionStore.withStorage(storage);
    final session = await _importedSession(
      _MemoryStorage(),
      uid: 'account-a',
      access: 'access-a',
      device: 'device-a',
    );

    expect(await store.load(), isFalse);
    expect(await store.rememberCurrent(session), isFalse);
    expect(await store.activate('account-a', session), isFalse);
    expect(await store.remove('account-a', session: session), isFalse);
    expect(store.accounts, isEmpty);
    expect(store.activeId, isEmpty);
    expect(storage.writeCalls, 0);
  });

  test('slot write failure rolls back memory and reports failure', () async {
    final storage = _MemoryStorage()..failWrite = true;
    final store = AccountSessionStore.withStorage(storage);
    final session = await _importedSession(
      _MemoryStorage(),
      uid: 'account-a',
      access: 'access-a',
      device: 'device-a',
    );

    expect(await store.rememberCurrent(session), isFalse);
    expect(store.accounts, isEmpty);
    expect(store.activeId, isEmpty);
    expect(storage.values, isEmpty);
  });

  test('missing primary slot record is recovered from the backup', () async {
    final entry = _slot('account-a');
    final storage = _MemoryStorage(
      values: {
        'zh_account_sessions_v1_backup': jsonEncode({
          'schema_version': 2,
          'active_id': entry.id,
          'accounts': [entry.toJson()],
        }),
      },
    );
    final store = AccountSessionStore.withStorage(storage);

    expect(await store.load(), isTrue);
    expect(store.accounts.single.id, 'account-a');
    expect(store.activeId, 'account-a');
    expect(storage.values['zh_account_sessions_v1'], isNotNull);
  });

  test(
    'removing the active slot clears locally and keeps recoverable copy',
    () async {
      final sessionStorage = _MemoryStorage();
      final session = await _importedSession(
        sessionStorage,
        uid: 'account-a',
        access: 'access-a',
        device: 'device-a',
      );
      final store = AccountSessionStore.withStorage(_MemoryStorage());
      expect(await store.rememberCurrent(session), isTrue);

      expect(await store.remove('account-a', session: session), isTrue);
      expect(session.hasStoredCredentialSession, isFalse);
      expect(store.accounts, isEmpty);
      expect(store.activeId, isEmpty);
      expect(await sessionStorage.hasCredentialRecovery(), isTrue);

      expect(await session.restoreLastClearedAccountSession(), isTrue);
      expect(session.authorization, 'Bearer access-a');
      expect(session.accountUid, 'account-a');
      expect(await sessionStorage.hasCredentialRecovery(), isFalse);
    },
  );

  test('removing an inactive slot archives its credentials', () async {
    final slotStorage = _MemoryStorage();
    final first = await _importedSession(
      _MemoryStorage(),
      uid: 'account-a',
      access: 'access-a',
      device: 'device-a',
    );
    final second = await _importedSession(
      _MemoryStorage(),
      uid: 'account-b',
      access: 'access-b',
      device: 'device-b',
    );
    final store = AccountSessionStore.withStorage(slotStorage);
    expect(await store.rememberCurrent(first), isTrue);
    expect(await store.rememberCurrent(second), isTrue);

    expect(await store.remove('account-a', session: second), isTrue);
    final recovery = await slotStorage.readLatestCredentialSnapshot();
    expect(recovery?['zh_authorization'], 'Bearer access-a');
    expect(recovery?['zh_udid'], 'device-a');
    expect(store.accounts.single.id, 'account-b');
    expect(store.activeId, 'account-b');
  });
}

Future<SessionStore> _importedSession(
  _MemoryStorage storage, {
  required String uid,
  required String access,
  required String device,
  String extraHeaders = '',
}) async {
  final session = SessionStore.withStorage(storage);
  await session.save(
    authorization: 'Bearer $access',
    udid: device,
    cookie: 'z_c0=$uid-cookie',
    msId: 'ms-$uid',
    xZse96: 'zse-$uid',
    xZse96Target: 'GET /people/self',
    extraHeadersJson: extraHeaders,
  );
  session.accountUid = uid;
  session.accountUserId = 'user-$uid';
  return session;
}

StoredAccountSession _slot(String uid) => StoredAccountSession(
  id: uid,
  displayName: '测试账号',
  authorization: 'Bearer access-$uid',
  refreshToken: 'refresh-$uid',
  udid: 'device-$uid',
  cookie: 'z_c0=$uid-cookie',
  sessionKind: 'account',
  accessTokenExpiry: DateTime.now().toUtc().add(const Duration(hours: 1)),
  accountUid: uid,
  accountUserId: 'user-$uid',
  updatedAt: DateTime.now().toUtc(),
);

class _MemoryStorage
    implements
        SessionKeyValueStore,
        AtomicSessionKeyValueStore,
        CredentialRecoveryStore {
  _MemoryStorage({Map<String, String>? values})
    : values = Map<String, String>.from(values ?? const {});

  final Map<String, String> values;
  final recovery = <Map<String, String>>[];
  var failRead = false;
  var failWrite = false;
  var failReplace = false;
  var writeCalls = 0;

  @override
  Future<Map<String, String>> readAll() async {
    if (failRead) throw StateError('read failure');
    return Map<String, String>.from(values);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    writeCalls += 1;
    if (failWrite) throw StateError('write failure');
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    if (failWrite) throw StateError('delete failure');
    values.remove(key);
  }

  @override
  Future<void> replaceValues({
    required Map<String, String> values,
    required Iterable<String> keysToDelete,
  }) async {
    if (failReplace) throw StateError('replace failure');
    final deleteKeys = keysToDelete.toSet()..removeAll(values.keys);
    for (final key in deleteKeys) {
      this.values.remove(key);
    }
    this.values.addAll(values);
  }

  @override
  Future<void> archiveCredentialSnapshot({
    required Map<String, String> values,
    required String reason,
    required DateTime detectedAt,
  }) async {
    recovery.insert(0, Map<String, String>.from(values));
  }

  @override
  Future<Map<String, String>?> readLatestCredentialSnapshot() async =>
      recovery.isEmpty ? null : Map<String, String>.from(recovery.first);

  @override
  Future<bool> hasCredentialRecovery() async => recovery.isNotEmpty;

  @override
  Future<void> removeLatestCredentialSnapshot() async {
    if (recovery.isNotEmpty) recovery.removeAt(0);
  }

  @override
  Future<void> clearCredentialRecovery() async => recovery.clear();
}
