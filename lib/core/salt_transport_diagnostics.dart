import 'dart:convert';
import 'dart:typed_data';

class SaltTransportDiagnostics {
  const SaltTransportDiagnostics({
    required this.byteLength,
    required this.asciiByteCount,
    required this.highByteCount,
    required this.trailingZeroCount,
    required this.hasParagraphStart,
    required this.hasParagraphEnd,
    required this.hasImageStart,
    this.utf8ErrorOffset,
  });

  factory SaltTransportDiagnostics.fromBytes(Uint8List bytes) {
    var ascii = 0;
    var high = 0;
    for (final byte in bytes) {
      if (byte < 0x80) {
        ascii++;
      } else {
        high++;
      }
    }
    var trailingZeros = 0;
    for (
      var index = bytes.length - 1;
      index >= 0 && bytes[index] == 0;
      index--
    ) {
      trailingZeros++;
    }
    return SaltTransportDiagnostics(
      byteLength: bytes.length,
      asciiByteCount: ascii,
      highByteCount: high,
      trailingZeroCount: trailingZeros,
      hasParagraphStart: _containsAscii(bytes, '<p'),
      hasParagraphEnd: _containsAscii(bytes, '</p>'),
      hasImageStart: _containsAscii(bytes, '<img'),
    );
  }

  final int byteLength;
  final int asciiByteCount;
  final int highByteCount;
  final int trailingZeroCount;
  final bool hasParagraphStart;
  final bool hasParagraphEnd;
  final bool hasImageStart;
  final int? utf8ErrorOffset;

  bool get hasReaderMarkup =>
      hasParagraphStart || hasParagraphEnd || hasImageStart;

  SaltTransportDiagnostics withUtf8Error(FormatException error) =>
      SaltTransportDiagnostics(
        byteLength: byteLength,
        asciiByteCount: asciiByteCount,
        highByteCount: highByteCount,
        trailingZeroCount: trailingZeroCount,
        hasParagraphStart: hasParagraphStart,
        hasParagraphEnd: hasParagraphEnd,
        hasImageStart: hasImageStart,
        utf8ErrorOffset: error.offset,
      );

  @override
  String toString() =>
      'SaltTransportDiagnostics(bytes=$byteLength,ascii=$asciiByteCount,'
      'high=$highByteCount,zeroTail=$trailingZeroCount,'
      'pStart=$hasParagraphStart,pEnd=$hasParagraphEnd,'
      'img=$hasImageStart,utf8Offset=${utf8ErrorOffset ?? -1})';

  static bool _containsAscii(Uint8List bytes, String marker) {
    final pattern = ascii.encode(marker);
    if (pattern.isEmpty || pattern.length > bytes.length) return false;
    for (var offset = 0; offset <= bytes.length - pattern.length; offset++) {
      var matches = true;
      for (var index = 0; index < pattern.length; index++) {
        if (bytes[offset + index] != pattern[index]) {
          matches = false;
          break;
        }
      }
      if (matches) return true;
    }
    return false;
  }
}

class SaltTransportDecodeException implements Exception {
  const SaltTransportDecodeException(this.code, this.message, {this.cause});

  final String code;
  final String message;
  final Object? cause;

  @override
  String toString() => 'SaltTransportDecodeException($code): $message';
}
