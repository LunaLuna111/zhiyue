import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'private_key_value_store.dart';

/// App-private credential database used on Android, iOS and macOS.
///
/// The old secure-storage plugin is read only during the first migration, with
/// reset-on-error disabled. New credentials, account slots and recovery
/// snapshots are written to this database under the application's private
/// data directory. Windows/Linux use the private-file fallback in this class
/// because the project's sqflite plugin has no native implementation there.
class PrivateAppStorage
    implements
        SessionKeyValueStore,
        AtomicSessionKeyValueStore,
        CredentialRecoveryStore {
  PrivateAppStorage._();

  static final instance = PrivateAppStorage._();

  static const _databaseName = 'zhiyue_credentials.db';
  static const _fallbackName = 'zhiyue_credentials_store.json';
  static const _fallbackBackupName = 'zhiyue_credentials_store.json.bak';
  static const _maxRecoveryRows = 5;

  // This object is migration-only. In particular, read failures cannot cause
  // the plugin to delete the old data before the private database is written.
  static const _legacyStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: false,
      migrateOnAlgorithmChange: true,
      migrateWithBackup: true,
    ),
  );

  Database? _database;
  Future<Database>? _openingDatabase;
  Future<void>? _initializing;
  Future<void> _writeQueue = Future<void>.value();
  bool _ready = false;
  bool _migratedFromLegacy = false;
  Map<String, String> _fallbackValues = <String, String>{};
  List<_FallbackRecovery> _fallbackRecovery = <_FallbackRecovery>[];
  File? _fallbackFile;

  bool get _useSqlite => switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    _ => false,
  };

  /// Returns true once per process after a successful legacy migration so the
  /// caller can write a normal authentication diagnostic without credentials.
  bool consumeMigrationNotice() {
    final value = _migratedFromLegacy;
    _migratedFromLegacy = false;
    return value;
  }

  @override
  Future<Map<String, String>> readAll() async {
    await _ensureReady();
    if (_useSqlite) {
      final rows = await _database!.query(
        'session_values',
        columns: const ['key', 'value'],
      );
      return <String, String>{
        for (final row in rows)
          row['key']!.toString(): row['value']!.toString(),
      };
    }
    return Map<String, String>.from(_fallbackValues);
  }

  Future<String?> read(String key) async {
    final values = await readAll();
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) {
    return _enqueueWrite(() async {
      await _ensureReady();
      if (_useSqlite) {
        await _database!.insert('session_values', {
          'key': key,
          'value': value,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        _fallbackValues[key] = value;
        await _writeFallback();
      }
    });
  }

  @override
  Future<void> delete({required String key}) {
    return _enqueueWrite(() async {
      await _ensureReady();
      if (_useSqlite) {
        await _database!.delete(
          'session_values',
          where: 'key = ?',
          whereArgs: [key],
        );
      } else {
        _fallbackValues.remove(key);
        await _writeFallback();
      }
    });
  }

  @override
  Future<void> replaceValues({
    required Map<String, String> values,
    required Iterable<String> keysToDelete,
  }) {
    return _enqueueWrite(() async {
      await _ensureReady();
      final replacement = Map<String, String>.from(values);
      final deleteKeys = keysToDelete.toSet();
      deleteKeys.removeAll(replacement.keys);
      if (_useSqlite) {
        await _database!.transaction((transaction) async {
          for (final key in deleteKeys) {
            await transaction.delete(
              'session_values',
              where: 'key = ?',
              whereArgs: [key],
            );
          }
          final batch = transaction.batch();
          for (final entry in replacement.entries) {
            batch.insert('session_values', {
              'key': entry.key,
              'value': entry.value,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          await batch.commit(noResult: true);
        });
        return;
      }
      for (final key in deleteKeys) {
        _fallbackValues.remove(key);
      }
      _fallbackValues.addAll(replacement);
      await _writeFallback();
    });
  }

  @override
  Future<void> archiveCredentialSnapshot({
    required Map<String, String> values,
    required String reason,
    required DateTime detectedAt,
  }) {
    return _enqueueWrite(() async {
      await _ensureReady();
      final payload = jsonEncode(values);
      final boundedReason = _bounded(reason, 240);
      if (_useSqlite) {
        await _database!.insert('credential_recovery', {
          'created_at': detectedAt.toUtc().millisecondsSinceEpoch,
          'reason': boundedReason,
          'payload': payload,
        });
        final rows = await _database!.query(
          'credential_recovery',
          columns: const ['id'],
          orderBy: 'id DESC',
          limit: 100,
        );
        for (final row in rows.skip(_maxRecoveryRows)) {
          await _database!.delete(
            'credential_recovery',
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
      } else {
        _fallbackRecovery.insert(
          0,
          _FallbackRecovery(
            id: DateTime.now().microsecondsSinceEpoch,
            createdAt: detectedAt.toUtc(),
            reason: boundedReason,
            values: Map<String, String>.from(values),
          ),
        );
        if (_fallbackRecovery.length > _maxRecoveryRows) {
          _fallbackRecovery = _fallbackRecovery
              .take(_maxRecoveryRows)
              .toList(growable: false);
        }
        await _writeFallback();
      }
    });
  }

  @override
  Future<Map<String, String>?> readLatestCredentialSnapshot() async {
    await _ensureReady();
    if (_useSqlite) {
      final rows = await _database!.query(
        'credential_recovery',
        columns: const ['payload'],
        orderBy: 'id DESC',
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _decodeValues(rows.single['payload']?.toString());
    }
    if (_fallbackRecovery.isEmpty) return null;
    return Map<String, String>.from(_fallbackRecovery.first.values);
  }

  @override
  Future<bool> hasCredentialRecovery() async {
    await _ensureReady();
    if (_useSqlite) {
      final rows = await _database!.rawQuery(
        'SELECT id FROM credential_recovery ORDER BY id DESC LIMIT 1',
      );
      return rows.isNotEmpty;
    }
    return _fallbackRecovery.isNotEmpty;
  }

  @override
  Future<void> removeLatestCredentialSnapshot() {
    return _enqueueWrite(() async {
      await _ensureReady();
      if (_useSqlite) {
        final rows = await _database!.query(
          'credential_recovery',
          columns: const ['id'],
          orderBy: 'id DESC',
          limit: 1,
        );
        if (rows.isNotEmpty) {
          await _database!.delete(
            'credential_recovery',
            where: 'id = ?',
            whereArgs: [rows.single['id']],
          );
        }
      } else if (_fallbackRecovery.isNotEmpty) {
        _fallbackRecovery = _fallbackRecovery.sublist(1);
        await _writeFallback();
      }
    });
  }

  @override
  Future<void> clearCredentialRecovery() {
    return _enqueueWrite(() async {
      await _ensureReady();
      if (_useSqlite) {
        await _database!.delete('credential_recovery');
      } else {
        _fallbackRecovery = <_FallbackRecovery>[];
        await _writeFallback();
      }
    });
  }

  Future<void> _enqueueWrite(Future<void> Function() operation) {
    final queued = _writeQueue.then((_) => operation());
    _writeQueue = queued.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return queued;
  }

  Future<void> _ensureReady() {
    if (_ready) return Future<void>.value();
    final existing = _initializing;
    if (existing != null) return existing;
    final opening = _initialize();
    _initializing = opening;
    return opening.whenComplete(() {
      if (identical(_initializing, opening)) _initializing = null;
    });
  }

  Future<void> _initialize() async {
    if (_useSqlite) {
      final database = await _openDatabase();
      final migrationMarker = await database.query(
        'storage_meta',
        columns: const ['value'],
        where: 'key = ?',
        whereArgs: const ['legacy_migration_v1'],
        limit: 1,
      );
      if (migrationMarker.isEmpty) {
        await _migrateLegacyIntoDatabase(database);
      }
    } else {
      await _initializeFallback();
    }
    _ready = true;
  }

  Future<Database> _openDatabase() async {
    final existing = _database;
    if (existing != null) return existing;
    final pending = _openingDatabase;
    if (pending != null) return pending;
    final root = await getDatabasesPath();
    final opening = openDatabase(
      '$root/$_databaseName',
      version: 2,
      onCreate: (database, _) async {
        await database.execute(
          'CREATE TABLE storage_meta ('
          'key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE session_values ('
          'key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE credential_recovery ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'created_at INTEGER NOT NULL, '
          'reason TEXT NOT NULL, '
          'payload TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE INDEX credential_recovery_created_idx '
          'ON credential_recovery (created_at DESC)',
        );
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute(
            'CREATE TABLE IF NOT EXISTS storage_meta ('
            'key TEXT PRIMARY KEY, value TEXT NOT NULL)',
          );
        }
      },
    );
    _openingDatabase = opening;
    try {
      final database = await opening;
      _database = database;
      return database;
    } finally {
      _openingDatabase = null;
    }
  }

  Future<void> _migrateLegacyIntoDatabase(Database database) async {
    final legacy = await _legacyStorage.readAll().timeout(
      const Duration(seconds: 3),
    );
    await database.transaction((transaction) async {
      if (legacy.isNotEmpty) {
        final batch = transaction.batch();
        for (final entry in legacy.entries) {
          batch.insert('session_values', {
            'key': entry.key,
            'value': entry.value,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      }
      await transaction.insert('storage_meta', {
        'key': 'legacy_migration_v1',
        'value': 'complete',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    _migratedFromLegacy = legacy.isNotEmpty;
    try {
      await _legacyStorage.deleteAll().timeout(const Duration(seconds: 3));
    } catch (_) {
      // The private copy is already authoritative; a legacy delete failure is
      // retained in the authentication log by the caller on the next read.
    }
  }

  Future<void> _initializeFallback() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    _fallbackFile = File(
      '${directory.path}${Platform.pathSeparator}$_fallbackName',
    );
    final file = _fallbackFile!;
    if (await file.exists()) {
      try {
        await _decodeFallback(await file.readAsString());
        return;
      } on Object {
        final backup = File(
          '${directory.path}${Platform.pathSeparator}$_fallbackBackupName',
        );
        if (await backup.exists()) {
          await _decodeFallback(await backup.readAsString());
          return;
        }
        rethrow;
      }
    }
    final legacy = await _legacyStorage.readAll().timeout(
      const Duration(seconds: 3),
    );
    _fallbackValues = Map<String, String>.from(legacy);
    await _writeFallback();
    if (legacy.isNotEmpty) {
      _migratedFromLegacy = true;
      try {
        await _legacyStorage.deleteAll().timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
  }

  Future<void> _decodeFallback(String raw) async {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw const FormatException('私有凭据数据库不是对象');
    final values = decoded['values'];
    if (values is Map) {
      _fallbackValues = {
        for (final entry in values.entries)
          entry.key.toString(): entry.value.toString(),
      };
    } else {
      _fallbackValues = <String, String>{};
    }
    final recovery = decoded['recovery'];
    _fallbackRecovery = <_FallbackRecovery>[];
    if (recovery is List) {
      for (final item in recovery) {
        final parsed = _FallbackRecovery.fromJson(item);
        if (parsed != null) _fallbackRecovery.add(parsed);
      }
    }
  }

  Future<void> _writeFallback() async {
    final file = _fallbackFile;
    if (file == null) return;
    final backup = File('${file.path}.bak');
    final temporary = File('${file.path}.tmp');
    final encoded = jsonEncode({
      'schema_version': 1,
      'values': _fallbackValues,
      'recovery': _fallbackRecovery.map((item) => item.toJson()).toList(),
    });
    if (await file.exists()) {
      try {
        await file.copy(backup.path);
      } catch (_) {}
    }
    await temporary.writeAsString(encoded, flush: true);
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);
  }

  static Map<String, String>? _decodeValues(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return {
        for (final entry in decoded.entries)
          entry.key.toString(): entry.value.toString(),
      };
    } on Object {
      return null;
    }
  }

  static String _bounded(String value, int maximum) =>
      value.length <= maximum ? value : value.substring(0, maximum);
}

class _FallbackRecovery {
  const _FallbackRecovery({
    required this.id,
    required this.createdAt,
    required this.reason,
    required this.values,
  });

  final int id;
  final DateTime createdAt;
  final String reason;
  final Map<String, String> values;

  Map<String, Object?> toJson() => {
    'id': id,
    'created_at': createdAt.toUtc().toIso8601String(),
    'reason': reason,
    'values': values,
  };

  static _FallbackRecovery? fromJson(Object? source) {
    if (source is! Map) return null;
    final createdAt = DateTime.tryParse(source['created_at']?.toString() ?? '');
    final values = source['values'];
    if (createdAt == null || values is! Map) return null;
    return _FallbackRecovery(
      id: int.tryParse(source['id']?.toString() ?? '') ?? 0,
      createdAt: createdAt,
      reason: source['reason']?.toString() ?? '',
      values: {
        for (final entry in values.entries)
          entry.key.toString(): entry.value.toString(),
      },
    );
  }
}
