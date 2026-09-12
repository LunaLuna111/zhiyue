import 'dart:io';

/// `flutter test` sets this environment variable for the test VM.  Native
/// plugins such as sqflite and secure storage do not have a host registrant in
/// that VM, so callers should use their in-memory/key-value fallbacks instead
/// of waiting on an unhandled platform channel.
bool get zhIsFlutterTest {
  final value = Platform.environment['FLUTTER_TEST'];
  return value != null && value != 'false';
}
