import 'dart:convert';

import 'private_app_storage.dart';
import 'platform_environment.dart'
    if (dart.library.io) 'platform_environment_io.dart';
import 'webdav_models.dart';

class WebDavSettingsStore {
  WebDavSettingsStore({SessionKeyValueStore? storage})
    : _storage =
          storage ??
          (zhIsFlutterTest ? _TestWebDavStorage() : PrivateAppStorage.instance);

  static final instance = WebDavSettingsStore();
  static const _key = 'zh_webdav_settings_v1';

  final SessionKeyValueStore _storage;

  Future<WebDavSettings> load() async {
    final values = await _storage.readAll();
    return WebDavSettings.tryDecode(values[_key]) ??
        const WebDavSettings.disabled();
  }

  Future<void> save(WebDavSettings settings) async {
    final error = settings.validate();
    if (error != null) throw FormatException(error);
    await _storage.write(key: _key, value: jsonEncode(settings.toJson()));
  }

  Future<void> clear() => _storage.delete(key: _key);
}

/// Native credential storage has no host registrar in the Flutter test VM.
/// Keeping this fallback private to the settings store prevents widget tests
/// from trying to open the production SQLite database.
class _TestWebDavStorage implements SessionKeyValueStore {
  final _values = <String, String>{};

  @override
  Future<Map<String, String>> readAll() async =>
      Map<String, String>.from(_values);

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }
}
