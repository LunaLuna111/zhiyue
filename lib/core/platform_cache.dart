import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'platform_environment.dart'
    if (dart.library.io) 'platform_environment_io.dart';

/// Whether the SQLite-backed stores can use the platform implementation.
///
/// `sqflite` intentionally supports Android, iOS and macOS only.  Windows,
/// Linux and the browser use the small key/value fallback below instead of
/// invoking an unregistered plugin channel.
bool get zhUsesSqliteCache {
  if (kIsWeb || zhIsFlutterTest) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    _ => false,
  };
}

/// A best-effort cross-platform key/value cache used by desktop and Web.
///
/// The memory layer is deliberately updated before the plugin call.  This
/// keeps the app usable in widget tests and in a desktop build where a host
/// key/value plugin may be unavailable, while `shared_preferences` provides
/// persistence whenever the platform implementation is registered.  Values
/// are non-sensitive UI/content cache data only; session credentials remain in
/// the dedicated app-private credential database and are never routed through
/// this helper.
class ZhPlatformCache {
  ZhPlatformCache._();

  static final instance = ZhPlatformCache._();

  final _memory = <String, String>{};
  Future<SharedPreferences>? _opening;
  bool _pluginUnavailable = false;

  Future<SharedPreferences?> _preferences() async {
    // The Flutter test VM has no host preferences registrar.  Returning the
    // already-updated memory layer keeps widget tests deterministic and, more
    // importantly, avoids leaving a platform-channel Future pending forever.
    if (zhIsFlutterTest || _pluginUnavailable) return null;
    final existing = _opening;
    if (existing != null) {
      try {
        return await existing;
      } catch (_) {
        return null;
      }
    }
    // A host implementation should answer immediately.  The timeout keeps a
    // broken desktop/browser embedding from holding the first content frame
    // forever; writes still remain available through `_memory`.
    final opening = SharedPreferences.getInstance().timeout(
      const Duration(seconds: 3),
    );
    _opening = opening;
    try {
      return await opening;
    } catch (_) {
      _pluginUnavailable = true;
      return null;
    } finally {
      _opening = null;
    }
  }

  Future<String?> read(String key) async {
    final inMemory = _memory[key];
    if (inMemory != null) return inMemory;
    final preferences = await _preferences();
    final value = preferences?.getString(key);
    if (value != null) _memory[key] = value;
    return value;
  }

  Future<bool> write(String key, String value) async {
    _memory[key] = value;
    final preferences = await _preferences();
    if (preferences == null) return false;
    try {
      return await preferences.setString(key, value);
    } catch (_) {
      _pluginUnavailable = true;
      return false;
    }
  }

  Future<bool> remove(String key) async {
    final existed = _memory.remove(key) != null;
    final preferences = await _preferences();
    if (preferences == null) return existed;
    try {
      return (await preferences.remove(key)) || existed;
    } catch (_) {
      _pluginUnavailable = true;
      return existed;
    }
  }

  Future<Set<String>> keys() async {
    final result = <String>{..._memory.keys};
    final preferences = await _preferences();
    if (preferences != null) result.addAll(preferences.getKeys());
    return result;
  }

  Future<int> removePrefix(String prefix) async {
    final matching = (await keys())
        .where((key) => key.startsWith(prefix))
        .toList(growable: false);
    for (final key in matching) {
      await remove(key);
    }
    return matching.length;
  }
}
