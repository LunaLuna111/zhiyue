import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'salt_laes_tables.dart';
import 'salt_transport_diagnostics.dart';

export 'salt_transport_diagnostics.dart'
    show SaltTransportDecodeException, SaltTransportDiagnostics;

/// Decodes the authenticated Salt manuscript transport used by the designated
/// Android 11.4.0 sample. The implementation is deliberately self-contained:
/// it neither loads the APK's native libraries nor adds a general-purpose
/// cryptography package to the Flutter application.
abstract final class SaltTransportDecoder {
  static final Uint8List _initial = _table(SaltLaesTables.initial, 256);
  static final Uint8List _roundXor = _table(SaltLaesTables.roundXor, 256);
  static final Uint8List _finalSubstitution = _table(
    SaltLaesTables.finalSubstitution,
    256,
  );
  static final Uint8List _finalXor = _table(SaltLaesTables.finalXor, 256);
  static final Uint8List _table0 = _table(SaltLaesTables.table0, 1024);
  static final Uint8List _table1 = _table(SaltLaesTables.table1, 1024);
  static final Uint8List _table2 = _table(SaltLaesTables.table2, 1024);
  static final Uint8List _table3 = _table(SaltLaesTables.table3, 1024);
  static final Uint8List _schedule = _decodeSchedule();

  /// Returns reader HTML/XML from the three authenticated response values and
  /// the per-request raw key. None of these values is retained by this class.
  static String decode({
    required String script,
    required String articleCode,
    required String strategy,
    required String rawKey,
  }) {
    final requestIv = deriveRequestIv(rawKey: rawKey, strategy: strategy);
    late final Uint8List contentKey;
    try {
      contentKey = unwrapArticleKey(
        articleCode: articleCode,
        requestIv: requestIv,
      );
    } on SaltTransportDecodeException catch (error) {
      if (error.code == 'invalid_padding') {
        throw SaltTransportDecodeException(
          'invalid_article_key_padding',
          '章节密钥校验失败，请重试。',
          cause: error,
        );
      }
      rethrow;
    }
    if (contentKey.length != 16 &&
        contentKey.length != 24 &&
        contentKey.length != 32) {
      throw SaltTransportDecodeException(
        'unsupported_content_key',
        '正文密钥长度不是 AES 支持的长度。',
      );
    }

    final payload = _decodeBase64(script, field: 'script');
    if (payload.length < 32 || (payload.length - 16) % 16 != 0) {
      throw SaltTransportDecodeException(
        'invalid_script_length',
        '正文密文长度不符合 AES-CBC 格式。',
      );
    }
    late final Uint8List plaintext;
    try {
      plaintext = decryptManuscriptAesCbc(
        Uint8List.sublistView(payload, 16),
        key: contentKey,
        iv: Uint8List.sublistView(payload, 0, 16),
      );
    } on SaltTransportDecodeException catch (error) {
      if (error.code == 'invalid_padding') {
        throw SaltTransportDecodeException(
          'invalid_manuscript_padding',
          '章节正文校验失败，请重试。',
          cause: error,
        );
      }
      rethrow;
    }
    // XMLReader::tryDecryptData in the designated native library does not
    // accept arbitrary decrypted bytes. For payloads longer than one block it
    // requires at least one of the ASCII structural markers below before the
    // bytes are handed to the XML parser. Keep the same boundary here: it
    // distinguishes a valid non-UTF-8 document from a wrong key/IV without
    // logging or retaining any protected prose.
    final diagnostics = SaltTransportDiagnostics.fromBytes(plaintext);
    if (!diagnostics.hasReaderMarkup) {
      throw SaltTransportDecodeException(
        'invalid_plaintext_structure',
        '正文解密结果未通过阅读器结构校验。',
        cause: diagnostics,
      );
    }
    try {
      var result = utf8.decode(plaintext, allowMalformed: false);
      if (result.startsWith('\ufeff')) result = result.substring(1);
      return result;
    } on FormatException catch (error) {
      throw SaltTransportDecodeException(
        'invalid_plaintext_utf8',
        '正文解密结果不是有效 UTF-8。',
        cause: diagnostics.withUtf8Error(error),
      );
    }
  }

  /// Derives the per-request LAES CBC IV selected by `code.log`.
  static Uint8List deriveRequestIv({
    required String rawKey,
    required String strategy,
  }) {
    final input = Uint8List.fromList(utf8.encode(rawKey));
    if (input.length != 16) {
      throw SaltTransportDecodeException(
        'invalid_raw_key',
        '请求随机 key 必须是 16 个 UTF-8 字节。',
      );
    }
    final strategyLength = utf8.encode(strategy).length;
    // XMLReader divides std::string::size() by three. In libc++ short-string
    // storage the first byte holds size * 2, but the native division sequence
    // compensates for that representation; the semantic result is still the
    // UTF-8 byte length divided by three.
    final selector = strategyLength ~/ 3;
    late final List<int> digestBytes;
    switch (selector) {
      case 0:
        final transformed = [
          for (final byte in input) ((byte + 5) ^ 0x7c) & 0xff,
        ];
        digestBytes = sha1.convert(transformed).bytes;
        break;
      case 1:
        final transformed = [
          for (final byte in input)
            () {
              final value = byte ^ 0x6b;
              return value > 2 ? value - 3 : value;
            }(),
        ];
        digestBytes = sha256.convert(transformed).bytes;
        break;
      case 2:
        final reversed = input.reversed.toList(growable: false);
        // The native `tst byte, 1` selects the adjustment from the byte's
        // parity, not from its position in the reversed array.
        final transformed = <int>[
          for (final byte in reversed)
            byte.isEven ? (byte + 5) & 0xff : (byte - 1) & 0xff,
        ];
        digestBytes = Hmac(sha256, transformed).convert(transformed).bytes;
        break;
      default:
        throw SaltTransportDecodeException(
          'unsupported_strategy',
          '当前 code.log 对应的密钥策略不受 11.4.0 阅读器支持。',
        );
    }
    return Uint8List.fromList(digestBytes.take(16).toList(growable: false));
  }

  /// Decrypts the Base64 `code.article_code` into the AES content key.
  static Uint8List unwrapArticleKey({
    required String articleCode,
    required Uint8List requestIv,
  }) {
    final encodedKey = _decodeBase64(articleCode, field: 'article_code');
    if (encodedKey.length != 32 || requestIv.length != 16) {
      throw SaltTransportDecodeException(
        'invalid_article_code',
        'article_code 或请求 IV 长度不符合 11.4.0 协议。',
      );
    }
    // Reader_LAES_cbc_decrypt enables its own trailing-length adjustment.
    // XMLReader passes that adjusted output length to Crypto++ SetKeyWithIV.
    // The 32-byte envelope therefore yields the transported 16-byte AES key.
    final decoded = decryptLaesCbc(encodedKey, iv: requestIv, unpad: false);
    return _removeNativeLaesPadding(decoded);
  }

  /// Pure Dart implementation of Reader_LAES_cbc_decrypt.
  static Uint8List decryptLaesCbc(
    Uint8List ciphertext, {
    required Uint8List iv,
    bool unpad = true,
  }) {
    if (iv.length != 16 || ciphertext.isEmpty || ciphertext.length % 16 != 0) {
      throw SaltTransportDecodeException(
        'invalid_laes_input',
        'LAES-CBC 输入长度无效。',
      );
    }
    final output = Uint8List(ciphertext.length);
    var previous = Uint8List.fromList(iv);
    for (var offset = 0; offset < ciphertext.length; offset += 16) {
      final block = Uint8List.sublistView(ciphertext, offset, offset + 16);
      final decoded = decryptLaesBlock(block);
      for (var i = 0; i < 16; i++) {
        output[offset + i] = decoded[i] ^ previous[i];
      }
      previous = Uint8List.fromList(block);
    }
    return unpad ? _removePkcs7(output, blockSize: 16) : output;
  }

  /// Fixed LAES block primitive reconstructed from the official reader.
  static Uint8List decryptLaesBlock(Uint8List input) {
    if (input.length != 16) {
      throw SaltTransportDecodeException(
        'invalid_laes_block',
        'LAES 数据块必须是 16 字节。',
      );
    }
    var state = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      state[i] = _combine(_initial, input[i], _schedule[i]);
    }

    const groups = <List<int>>[
      [0, 13, 10, 7],
      [4, 1, 14, 11],
      [8, 5, 2, 15],
      [12, 9, 6, 3],
    ];
    for (var round = 1; round <= 9; round++) {
      final next = Uint8List(16);
      for (var column = 0; column < 4; column++) {
        final group = groups[column];
        for (var byte = 0; byte < 4; byte++) {
          final wordByte = 3 - byte;
          final value01 = _combine(
            _roundXor,
            _table0[state[group[0]] * 4 + wordByte],
            _table1[state[group[1]] * 4 + wordByte],
          );
          final value23 = _combine(
            _roundXor,
            _table2[state[group[2]] * 4 + wordByte],
            _table3[state[group[3]] * 4 + wordByte],
          );
          final position = column * 4 + byte;
          next[position] = _combine(
            _roundXor,
            _combine(_roundXor, value01, value23),
            _schedule[round * 16 + position],
          );
        }
      }
      state = next;
    }

    const permutation = [0, 13, 10, 7, 4, 1, 14, 11, 8, 5, 2, 15, 12, 9, 6, 3];
    final output = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      output[i] = _combine(
        _finalXor,
        _finalSubstitution[state[permutation[i]]],
        _schedule[160 + i],
      );
    }
    return output;
  }

  /// Minimal AES CBC decryptor used for the manuscript payload.
  ///
  /// The official manuscript path currently supplies the 16-byte key returned
  /// by [unwrapArticleKey]. AES-192/256 remain supported so this primitive can
  /// be checked against standard conformance vectors without another package.
  static Uint8List decryptAesCbc(
    Uint8List ciphertext, {
    required Uint8List key,
    required Uint8List iv,
    bool unpad = true,
  }) {
    if ((key.length != 16 && key.length != 24 && key.length != 32) ||
        iv.length != 16 ||
        ciphertext.isEmpty ||
        ciphertext.length % 16 != 0) {
      throw SaltTransportDecodeException(
        'invalid_aes_input',
        'AES-CBC 输入长度无效。',
      );
    }
    final rounds = key.length ~/ 4 + 6;
    final expandedKey = _expandAesKey(key, rounds: rounds);
    final output = Uint8List(ciphertext.length);
    var previous = Uint8List.fromList(iv);
    for (var offset = 0; offset < ciphertext.length; offset += 16) {
      final block = Uint8List.sublistView(ciphertext, offset, offset + 16);
      final decoded = _decryptAesBlock(block, expandedKey, rounds: rounds);
      for (var i = 0; i < 16; i++) {
        output[offset + i] = decoded[i] ^ previous[i];
      }
      previous = Uint8List.fromList(block);
    }
    return unpad ? _removePkcs7(output, blockSize: 16) : output;
  }

  /// Decrypts the reader manuscript with Crypto++ `PKCS_PADDING` semantics.
  ///
  /// Strict PKCS#7 validation rejects malformed zero-padded content.
  static Uint8List decryptManuscriptAesCbc(
    Uint8List ciphertext, {
    required Uint8List key,
    required Uint8List iv,
  }) {
    return decryptAesCbc(ciphertext, key: key, iv: iv);
  }

  /// Compatibility entry point retained for the existing AES-128 contract.
  static Uint8List decryptAes128Cbc(
    Uint8List ciphertext, {
    required Uint8List key,
    required Uint8List iv,
    bool unpad = true,
  }) {
    if (key.length != 16) {
      throw SaltTransportDecodeException(
        'invalid_aes_input',
        'AES-128-CBC 输入长度无效。',
      );
    }
    return decryptAesCbc(ciphertext, key: key, iv: iv, unpad: unpad);
  }

  static Uint8List _decryptAesBlock(
    Uint8List input,
    Uint8List expandedKey, {
    required int rounds,
  }) {
    var state = Uint8List.fromList(input);
    _addRoundKey(state, expandedKey, rounds);
    for (var round = rounds - 1; round >= 1; round--) {
      state = _inverseShiftRows(state);
      for (var i = 0; i < 16; i++) {
        state[i] = _aesInverseSbox[state[i]];
      }
      _addRoundKey(state, expandedKey, round);
      _inverseMixColumns(state);
    }
    state = _inverseShiftRows(state);
    for (var i = 0; i < 16; i++) {
      state[i] = _aesInverseSbox[state[i]];
    }
    _addRoundKey(state, expandedKey, 0);
    return state;
  }

  static Uint8List _expandAesKey(Uint8List key, {required int rounds}) {
    final forwardSbox = Uint8List(256);
    for (var i = 0; i < 256; i++) {
      forwardSbox[_aesInverseSbox[i]] = i;
    }
    final expanded = Uint8List(16 * (rounds + 1))..setRange(0, key.length, key);
    const rcon = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36];
    var generated = key.length;
    var rconIndex = 0;
    final temporary = Uint8List(4);
    while (generated < expanded.length) {
      temporary.setRange(0, 4, expanded, generated - 4);
      if (generated % key.length == 0) {
        final first = temporary[0];
        temporary[0] = forwardSbox[temporary[1]] ^ rcon[rconIndex++];
        temporary[1] = forwardSbox[temporary[2]];
        temporary[2] = forwardSbox[temporary[3]];
        temporary[3] = forwardSbox[first];
      } else if (key.length == 32 && generated % key.length == 16) {
        for (var i = 0; i < 4; i++) {
          temporary[i] = forwardSbox[temporary[i]];
        }
      }
      for (var i = 0; i < 4; i++) {
        expanded[generated] = expanded[generated - key.length] ^ temporary[i];
        generated++;
      }
    }
    return expanded;
  }

  static Uint8List _inverseShiftRows(Uint8List state) => Uint8List.fromList([
    state[0],
    state[13],
    state[10],
    state[7],
    state[4],
    state[1],
    state[14],
    state[11],
    state[8],
    state[5],
    state[2],
    state[15],
    state[12],
    state[9],
    state[6],
    state[3],
  ]);

  static void _inverseMixColumns(Uint8List state) {
    for (var column = 0; column < 4; column++) {
      final offset = column * 4;
      final a = state.sublist(offset, offset + 4);
      state[offset] =
          _multiply(a[0], 14) ^
          _multiply(a[1], 11) ^
          _multiply(a[2], 13) ^
          _multiply(a[3], 9);
      state[offset + 1] =
          _multiply(a[0], 9) ^
          _multiply(a[1], 14) ^
          _multiply(a[2], 11) ^
          _multiply(a[3], 13);
      state[offset + 2] =
          _multiply(a[0], 13) ^
          _multiply(a[1], 9) ^
          _multiply(a[2], 14) ^
          _multiply(a[3], 11);
      state[offset + 3] =
          _multiply(a[0], 11) ^
          _multiply(a[1], 13) ^
          _multiply(a[2], 9) ^
          _multiply(a[3], 14);
    }
  }

  static int _multiply(int value, int factor) {
    var a = value;
    var b = factor;
    var result = 0;
    while (b != 0) {
      if (b.isOdd) result ^= a;
      final high = a & 0x80;
      a = (a << 1) & 0xff;
      if (high != 0) a ^= 0x1b;
      b >>= 1;
    }
    return result;
  }

  static void _addRoundKey(Uint8List state, Uint8List expandedKey, int round) {
    final offset = round * 16;
    for (var i = 0; i < 16; i++) {
      state[i] ^= expandedKey[offset + i];
    }
  }

  static Uint8List _removePkcs7(Uint8List value, {required int blockSize}) {
    if (value.isEmpty) {
      throw SaltTransportDecodeException('invalid_padding', '解密结果为空。');
    }
    final padding = value.last;
    if (padding == 0 || padding > blockSize || padding > value.length) {
      throw SaltTransportDecodeException('invalid_padding', '解密填充无效。');
    }
    for (var i = value.length - padding; i < value.length; i++) {
      if (value[i] != padding) {
        throw SaltTransportDecodeException('invalid_padding', '解密填充无效。');
      }
    }
    return Uint8List.sublistView(value, 0, value.length - padding);
  }

  /// Mirrors the trailing-length handling enabled by
  /// `Reader_LAES_cbc_decrypt` in the APK.
  ///
  /// The wrapper does not validate every byte in the final padding block: it
  /// only subtracts the unsigned value of the last byte. The transported key
  /// is 16 bytes inside a fixed 32-byte envelope, so the compatible final
  /// length must still be exactly 16. Keeping this separate from [_removePkcs7]
  /// preserves strict PKCS#7 validation for the manuscript AES-CBC layer.
  static Uint8List _removeNativeLaesPadding(Uint8List value) {
    if (value.length != 32) {
      throw SaltTransportDecodeException('invalid_padding', '解密填充无效。');
    }
    final outputLength = value.length - value.last;
    if (outputLength != 16) {
      throw SaltTransportDecodeException('invalid_padding', '解密填充无效。');
    }
    return Uint8List.sublistView(value, 0, outputLength);
  }

  static Uint8List _decodeBase64(String value, {required String field}) {
    var normalized = value.replaceAll(RegExp(r'\s+'), '');
    normalized = normalized.replaceAll('-', '+').replaceAll('_', '/');
    final remainder = normalized.length % 4;
    if (remainder != 0) normalized += '=' * (4 - remainder);
    try {
      return Uint8List.fromList(base64Decode(normalized));
    } on FormatException catch (error) {
      throw SaltTransportDecodeException(
        'invalid_base64',
        '$field 不是有效 Base64。',
        cause: error,
      );
    }
  }

  static int _combine(Uint8List table, int first, int second) =>
      (table[(first & 0xf0) | (second >> 4)] & 0xf0) |
      (table[((first << 4) & 0xf0) ^ (second & 0x0f)] >> 4);

  static Uint8List _table(String value, int expectedLength) {
    final result = Uint8List.fromList(base64Decode(value));
    if (result.length != expectedLength) {
      throw StateError('Invalid embedded LAES table length.');
    }
    return result;
  }

  static Uint8List _decodeSchedule() {
    final encoded = Uint8List(180);
    final source = SaltLaesTables.encodedScheduleHex;
    if (source.length != 360) throw StateError('Invalid LAES schedule.');
    for (var i = 0; i < encoded.length; i++) {
      encoded[i] = int.parse(source.substring(i * 2, i * 2 + 2), radix: 16);
    }
    final decoded = Uint8List(176);
    for (var i = 4; i < encoded.length; i++) {
      decoded[i - 4] = encoded[i] ^ encoded[i % 3];
    }
    return decoded;
  }

  static const _aesInverseSbox = <int>[
    0x52,
    0x09,
    0x6a,
    0xd5,
    0x30,
    0x36,
    0xa5,
    0x38,
    0xbf,
    0x40,
    0xa3,
    0x9e,
    0x81,
    0xf3,
    0xd7,
    0xfb,
    0x7c,
    0xe3,
    0x39,
    0x82,
    0x9b,
    0x2f,
    0xff,
    0x87,
    0x34,
    0x8e,
    0x43,
    0x44,
    0xc4,
    0xde,
    0xe9,
    0xcb,
    0x54,
    0x7b,
    0x94,
    0x32,
    0xa6,
    0xc2,
    0x23,
    0x3d,
    0xee,
    0x4c,
    0x95,
    0x0b,
    0x42,
    0xfa,
    0xc3,
    0x4e,
    0x08,
    0x2e,
    0xa1,
    0x66,
    0x28,
    0xd9,
    0x24,
    0xb2,
    0x76,
    0x5b,
    0xa2,
    0x49,
    0x6d,
    0x8b,
    0xd1,
    0x25,
    0x72,
    0xf8,
    0xf6,
    0x64,
    0x86,
    0x68,
    0x98,
    0x16,
    0xd4,
    0xa4,
    0x5c,
    0xcc,
    0x5d,
    0x65,
    0xb6,
    0x92,
    0x6c,
    0x70,
    0x48,
    0x50,
    0xfd,
    0xed,
    0xb9,
    0xda,
    0x5e,
    0x15,
    0x46,
    0x57,
    0xa7,
    0x8d,
    0x9d,
    0x84,
    0x90,
    0xd8,
    0xab,
    0x00,
    0x8c,
    0xbc,
    0xd3,
    0x0a,
    0xf7,
    0xe4,
    0x58,
    0x05,
    0xb8,
    0xb3,
    0x45,
    0x06,
    0xd0,
    0x2c,
    0x1e,
    0x8f,
    0xca,
    0x3f,
    0x0f,
    0x02,
    0xc1,
    0xaf,
    0xbd,
    0x03,
    0x01,
    0x13,
    0x8a,
    0x6b,
    0x3a,
    0x91,
    0x11,
    0x41,
    0x4f,
    0x67,
    0xdc,
    0xea,
    0x97,
    0xf2,
    0xcf,
    0xce,
    0xf0,
    0xb4,
    0xe6,
    0x73,
    0x96,
    0xac,
    0x74,
    0x22,
    0xe7,
    0xad,
    0x35,
    0x85,
    0xe2,
    0xf9,
    0x37,
    0xe8,
    0x1c,
    0x75,
    0xdf,
    0x6e,
    0x47,
    0xf1,
    0x1a,
    0x71,
    0x1d,
    0x29,
    0xc5,
    0x89,
    0x6f,
    0xb7,
    0x62,
    0x0e,
    0xaa,
    0x18,
    0xbe,
    0x1b,
    0xfc,
    0x56,
    0x3e,
    0x4b,
    0xc6,
    0xd2,
    0x79,
    0x20,
    0x9a,
    0xdb,
    0xc0,
    0xfe,
    0x78,
    0xcd,
    0x5a,
    0xf4,
    0x1f,
    0xdd,
    0xa8,
    0x33,
    0x88,
    0x07,
    0xc7,
    0x31,
    0xb1,
    0x12,
    0x10,
    0x59,
    0x27,
    0x80,
    0xec,
    0x5f,
    0x60,
    0x51,
    0x7f,
    0xa9,
    0x19,
    0xb5,
    0x4a,
    0x0d,
    0x2d,
    0xe5,
    0x7a,
    0x9f,
    0x93,
    0xc9,
    0x9c,
    0xef,
    0xa0,
    0xe0,
    0x3b,
    0x4d,
    0xae,
    0x2a,
    0xf5,
    0xb0,
    0xc8,
    0xeb,
    0xbb,
    0x3c,
    0x83,
    0x53,
    0x99,
    0x61,
    0x17,
    0x2b,
    0x04,
    0x7e,
    0xba,
    0x77,
    0xd6,
    0x26,
    0xe1,
    0x69,
    0x14,
    0x63,
    0x55,
    0x21,
    0x0c,
    0x7d,
  ];
}

/// Non-content diagnostics for the native reader's final plaintext boundary.
///
/// It intentionally stores only lengths, counts and marker booleans. It never
/// stores a plaintext prefix, key, article code or a reversible digest.
