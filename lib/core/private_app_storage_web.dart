import 'private_key_value_store.dart';

/// Browser fallback. The mobile and desktop builds use an application-private
/// database/file; this keeps the package analyzable for Flutter Web without
/// attempting to persist credentials in browser storage.
class PrivateAppStorage
    implements SessionKeyValueStore, CredentialRecoveryStore {
  PrivateAppStorage._();

  static final instance = PrivateAppStorage._();

  final _values = <String, String>{};
  final _recovery = <Map<String, String>>[];

  bool consumeMigrationNotice() => false;

  @override
  Future<Map<String, String>> readAll() async => Map.from(_values);

  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<void> archiveCredentialSnapshot({
    required Map<String, String> values,
    required String reason,
    required DateTime detectedAt,
  }) async {
    _recovery.insert(0, Map<String, String>.from(values));
    if (_recovery.length > 5) _recovery.removeLast();
  }

  @override
  Future<Map<String, String>?> readLatestCredentialSnapshot() async =>
      _recovery.isEmpty ? null : Map.from(_recovery.first);

  @override
  Future<bool> hasCredentialRecovery() async => _recovery.isNotEmpty;

  @override
  Future<void> removeLatestCredentialSnapshot() async {
    if (_recovery.isNotEmpty) _recovery.removeAt(0);
  }

  @override
  Future<void> clearCredentialRecovery() async => _recovery.clear();
}
