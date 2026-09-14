import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small storage boundary used by [SessionStore]. The production
/// implementation is an app-private credential database; this adapter keeps
/// the existing Flutter test seam available without changing test fixtures.
abstract interface class SessionKeyValueStore {
  Future<Map<String, String>> readAll();

  Future<void> write({required String key, required String value});

  Future<void> delete({required String key});
}

/// Atomic replacement boundary for a group of session keys.
///
/// The production app-private database implements this with one SQLite
/// transaction (or one temporary-file replacement on desktop fallbacks). Test
/// adapters may omit this interface and use the legacy key-by-key fallback.
abstract interface class AtomicSessionKeyValueStore {
  Future<void> replaceValues({
    required Map<String, String> values,
    required Iterable<String> keysToDelete,
  });
}

class FlutterSecureKeyValueStore implements SessionKeyValueStore {
  const FlutterSecureKeyValueStore(this.storage);

  final FlutterSecureStorage storage;

  @override
  Future<Map<String, String>> readAll() => storage.readAll();

  @override
  Future<void> write({required String key, required String value}) async {
    await storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) async {
    await storage.delete(key: key);
  }
}

/// Recovery archive boundary. Only the app-private database implements this
/// interface; the legacy secure-storage test adapter intentionally has no
/// recovery side effects.
abstract interface class CredentialRecoveryStore {
  Future<void> archiveCredentialSnapshot({
    required Map<String, String> values,
    required String reason,
    required DateTime detectedAt,
  });

  Future<Map<String, String>?> readLatestCredentialSnapshot();

  Future<bool> hasCredentialRecovery();

  Future<void> removeLatestCredentialSnapshot();

  Future<void> clearCredentialRecovery();
}
