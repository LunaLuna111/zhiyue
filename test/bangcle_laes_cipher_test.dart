import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiyue_client/core/bangcle_laes_cipher.dart';
import 'package:zhiyue_client/core/mobile_login_body_encoder.dart';
import 'package:zhiyue_client/core/x_zse_signer.dart';

void main() {
  test('X-Zse key recovery is deterministic for this APK sample', () {
    final key = XZseSigner.decodedEncryptKey();
    expect(key.length, 360);
    expect(sha256.convert(ascii.encode(key)).toString(), XZseSigner.keySha256);
  });

  test('pure Dart X-Zse LAES matches the official JNI wrapper', () async {
    final encrypted = await DartXZseCipher().encryptMd5Hex(
      md5Lower: XZseSigner.selfTestMd5Lower,
      key: XZseSigner.decodedEncryptKey(),
      iv: Uint8List.fromList(ascii.encode(XZseSigner.ivAscii)),
    );
    expect(
      _bytesHex(encrypted),
      '3118acf4d8927a7aaa32a5a53c7b0a51'
      '5523556ef32961261c3c51b8b28ec9db'
      'e3ab55819b8063e27c6161ac215f2980',
    );
  });

  test('pure Dart login LAES preserves official padding behavior', () async {
    final cipher = DartMobileLoginBodyCipher();
    final key = XZseSigner.decodedEncryptKey();
    final iv = Uint8List.fromList(ascii.encode(XZseSigner.ivAscii));
    const expected = <int, String>{
      0: '020603b40990f4371601d207a8c032b0',
      1: '58577859afdcc755bed10684ba89c114',
      15: '69f3228f7536ab6277fc7aeb8be6f604',
      16:
          '72a94dc87e2926ab5575bcb71eed91f8'
          '6400be311d016ae77757a0dc5d8c7bda',
      17:
          '72a94dc87e2926ab5575bcb71eed91f8'
          '9c662a173db410a868a830c9a70679d7',
      32:
          '72a94dc87e2926ab5575bcb71eed91f8'
          '95c266cda4e57d4b9d887cbe44ba4c5f'
          '3c9d41d759f1d65c498dd5f1009b491e',
      43:
          '72a94dc87e2926ab5575bcb71eed91f8'
          '95c266cda4e57d4b9d887cbe44ba4c5f'
          '22eb9082a3c50f34fa7c57b3aaa0179a',
    };
    for (final vector in expected.entries) {
      final encrypted = await cipher.encryptBytes(
        input: Uint8List.fromList(List.generate(vector.key, (index) => index)),
        key: key,
        iv: iv,
      );
      expect(
        _bytesHex(encrypted),
        vector.value,
        reason: 'official LAES wrapper input length ${vector.key}',
      );
    }
  });

  test('pure Dart LAES matches broad official JNI vectors', () async {
    final cipher = DartMobileLoginBodyCipher();
    final key = XZseSigner.decodedEncryptKey();
    final fixedIv = Uint8List.fromList(ascii.encode(XZseSigner.ivAscii));

    Uint8List pattern(int length) => Uint8List.fromList(
      List.generate(length, (index) => (index * 73 + 19) & 0xff),
    );

    const exact = <int, String>{
      2: '8d295df4d15e8e96e5da83d0bb2cda71',
      14: 'e2d4e44bbac2130a945aa416596c19fd',
      31:
          '3949e3bad1655be71f4e462299733101'
          'f488c500fb7b0ecb9d165434c31f8684',
      33:
          '3949e3bad1655be71f4e462299733101'
          '37b91c4e6639c83561fd7369ce82bb10'
          '41f6658683c8de26ed92b5b9d06d9f94',
    };
    for (final vector in exact.entries) {
      final encrypted = await cipher.encryptBytes(
        input: pattern(vector.key),
        key: key,
        iv: fixedIv,
      );
      expect(
        _bytesHex(encrypted),
        vector.value,
        reason: 'official patterned input length ${vector.key}',
      );
    }

    final pattern64 = await cipher.encryptBytes(
      input: pattern(64),
      key: key,
      iv: fixedIv,
    );
    expect(pattern64, hasLength(80));
    expect(
      sha256.convert(pattern64).toString(),
      'fc96b3ad98cbcba029718576774929fa2da2d238f351f91225fe25ee5f306a2f',
    );

    final range255 = await cipher.encryptBytes(
      input: Uint8List.fromList(List.generate(255, (index) => index)),
      key: key,
      iv: fixedIv,
    );
    expect(range255, hasLength(256));
    expect(
      sha256.convert(range255).toString(),
      '6ae6b83f5f6f535c9bd5c4414b9584c43587220a1443ecd72b683414e2530f0f',
    );

    final alternateIv = await cipher.encryptBytes(
      input: Uint8List.fromList(List.generate(17, (index) => index)),
      key: key,
      iv: Uint8List.fromList(List.generate(16, (index) => index)),
    );
    expect(
      _bytesHex(alternateIv),
      '479a1d7d78e236bb5a92a37d7fe3b63d'
      'f1ef281e821b818c2bf01791290ee9d4',
    );
  });

  test('pure Dart LAES validates input shape and isolates schedule cache', () {
    final key = XZseSigner.decodedEncryptKey();
    final iv = Uint8List.fromList(ascii.encode(XZseSigner.ivAscii));
    final input = Uint8List.fromList(List.generate(17, (index) => index));
    final originalInput = Uint8List.fromList(input);
    final originalIv = Uint8List.fromList(iv);
    final official = BangcleLaesCipher.encrypt(
      input,
      encodedScheduleHex: key,
      iv: iv,
    );
    final replacement = key[8] == '0' ? '1' : '0';
    final alternateKey = key.replaceRange(8, 9, replacement);
    final alternate = BangcleLaesCipher.encrypt(
      input,
      encodedScheduleHex: alternateKey,
      iv: iv,
    );
    final restored = BangcleLaesCipher.encrypt(
      input,
      encodedScheduleHex: key,
      iv: iv,
    );

    expect(alternate, isNot(equals(official)));
    expect(restored, equals(official));
    expect(input, equals(originalInput));
    expect(iv, equals(originalIv));
    expect(
      () => BangcleLaesCipher.encrypt(
        input,
        encodedScheduleHex: key.substring(0, key.length - 2),
        iv: iv,
      ),
      throwsFormatException,
    );
    expect(
      () => BangcleLaesCipher.encrypt(
        input,
        encodedScheduleHex: key.replaceRange(8, 10, '+0'),
        iv: iv,
      ),
      throwsFormatException,
    );
    expect(
      () => BangcleLaesCipher.encrypt(
        input,
        encodedScheduleHex: key,
        iv: Uint8List(15),
      ),
      throwsArgumentError,
    );
  });
}

String _bytesHex(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
