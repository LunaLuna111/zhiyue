import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Request-key generation for the 11.4.0 Salt reader.

class SaltManuscriptRequestKey {
  const SaltManuscriptRequestKey({
    required this.rawKey,
    required this.transKey,
  });

  /// Per-request 16-character key. Test builds can persist it in the private
  /// diagnostic export when credential capture is explicitly enabled.
  final String rawKey;

  /// RSA-wrapped request value sent as `trans_key`.
  final String transKey;
}

abstract class SaltManuscriptKeyProvider {
  Future<SaltManuscriptRequestKey> generate();
}

SaltManuscriptKeyProvider defaultSaltManuscriptKeyProvider() {
  const debugRawKey = String.fromEnvironment('ZH_DEBUG_SALT_RAW_KEY');
  const debugTransKey = String.fromEnvironment('ZH_DEBUG_SALT_TRANS_KEY');
  if (kDebugMode && debugRawKey.isNotEmpty && debugTransKey.isNotEmpty) {
    return FixedSaltManuscriptKeyProvider(
      rawKey: debugRawKey,
      transKey: debugTransKey,
    );
  }
  if (kDebugMode && debugRawKey.isNotEmpty) {
    return OfficialSaltManuscriptKeyProvider(fixedRawKey: debugRawKey);
  }
  return OfficialSaltManuscriptKeyProvider();
}

class FixedSaltManuscriptKeyProvider implements SaltManuscriptKeyProvider {
  const FixedSaltManuscriptKeyProvider({
    required this.rawKey,
    required this.transKey,
  });

  final String rawKey;
  final String transKey;

  @override
  Future<SaltManuscriptRequestKey> generate() async {
    if (rawKey.length != 16 || transKey.isEmpty) {
      throw StateError('The fixed Salt request key is invalid.');
    }
    return SaltManuscriptRequestKey(rawKey: rawKey, transKey: transKey);
  }
}

class OfficialSaltManuscriptKeyProvider implements SaltManuscriptKeyProvider {
  OfficialSaltManuscriptKeyProvider({
    PureDartSaltManuscriptKeyProvider? fallback,
    this.fixedRawKey,
  }) : _fallback = fallback ?? PureDartSaltManuscriptKeyProvider();

  static const _channel = MethodChannel(
    'com.zhiyue.client/salt_manuscript_key',
  );

  final PureDartSaltManuscriptKeyProvider _fallback;
  final String? fixedRawKey;

  @override
  Future<SaltManuscriptRequestKey> generate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return _fallback.generate();
    }
    final result = await _channel.invokeMapMethod<String, String>('generate', {
      if (fixedRawKey != null) 'rawKey': fixedRawKey,
    });
    final rawKey = result?['rawKey'] ?? '';
    final transKey = result?['transKey'] ?? '';
    if (rawKey.length != 16 || transKey.isEmpty) {
      throw StateError('Android returned an invalid Salt request key.');
    }
    return SaltManuscriptRequestKey(rawKey: rawKey, transKey: transKey);
  }
}

class PureDartSaltManuscriptKeyProvider implements SaltManuscriptKeyProvider {
  PureDartSaltManuscriptKeyProvider({Random? random})
    : _random = random ?? Random.secure();

  static const _alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  // RSA-1024 public modulus exposed by IManuscriptKeyProvider in the
  // designated Android 11.4.0 sample. The leading DER sign byte is omitted.
  static final BigInt _modulus = BigInt.parse(
    'd04f1c10920d4cc202e85268bf9841c132ed478ad062b069725b49a9fa5dc077'
    '9cd7eb981b1d8c04eae45023d2b87433825c84372d2ad1728e4dc1d1db97e301'
    '3c554e97ec79ac73394fca8feb6a4545ffb809fc78fa7eeddb30ada6bceca314'
    '6dbf68aab4eaf043d410a1d779161531f4bd62554aab2a02819470399ae42add',
    radix: 16,
  );
  static final BigInt _exponent = BigInt.from(65537);
  static const _modulusBytes = 128;

  final Random _random;

  @override
  Future<SaltManuscriptRequestKey> generate() async {
    final rawKey = String.fromCharCodes(
      List.generate(
        16,
        (_) => _alphabet.codeUnitAt(_random.nextInt(_alphabet.length)),
        growable: false,
      ),
    );
    final transKey = base64Encode(_rsaRawEncrypt(utf8.encode(rawKey)));
    return SaltManuscriptRequestKey(rawKey: rawKey, transKey: transKey);
  }

  List<int> _rsaRawEncrypt(List<int> message) {
    // Official 11.4.0 calls Cipher.getInstance("RSA") on Android's BC
    // provider. On the tested device that is deterministic raw RSA, not
    // RSAES-PKCS1-v1_5. The 16-byte request key is interpreted as a big-endian
    // integer and the ciphertext is left padded to the 1024-bit modulus size.
    if (message.length > _modulusBytes) {
      throw ArgumentError.value(message.length, 'message.length');
    }
    final encrypted = _bytesToBigInt(message).modPow(_exponent, _modulus);
    return _bigIntToFixedBytes(encrypted, _modulusBytes);
  }

  static BigInt _bytesToBigInt(List<int> bytes) {
    var value = BigInt.zero;
    for (final byte in bytes) {
      value = (value << 8) | BigInt.from(byte);
    }
    return value;
  }

  static List<int> _bigIntToFixedBytes(BigInt value, int length) {
    final result = List<int>.filled(length, 0, growable: false);
    var remaining = value;
    for (var index = length - 1; index >= 0; index--) {
      result[index] = (remaining & BigInt.from(0xff)).toInt();
      remaining >>= 8;
    }
    if (remaining != BigInt.zero) throw StateError('RSA output overflow.');
    return result;
  }
}
