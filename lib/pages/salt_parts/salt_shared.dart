part of '../salt_page.dart';

String _decodeSaltTransport(Map<String, String> values) =>
    SaltTransportDecoder.decode(
      script: values['script']!,
      articleCode: values['articleCode']!,
      strategy: values['strategy']!,
      rawKey: values['rawKey']!,
    );

SaltTextChapter _decodeSaltTextChapter(Map<String, String> values) =>
    SaltTextChapter.decode(
      chapterId: values['chapterId']!,
      script: values['script']!,
      articleCode: values['articleCode']!,
      strategy: values['strategy']!,
      rawKey: values['rawKey']!,
    );

/// Development-only probe for the three strategy branches used by 11.4.0. It
/// returns only outcome codes and never
/// returns, prints or persists a request key or protected manuscript bytes.
Future<String> _diagnoseSaltStrategyBranches(Map<String, String> values) async {
  final outcomes = <String>[];
  // XMLReader selects SHA-1/SHA-256/HMAC from UTF-8 byte lengths 0/3/6.
  const selectors = <String>['', '   ', '      '];
  for (var index = 0; index < selectors.length; index++) {
    try {
      await compute(_decodeSaltTransport, {
        ...values,
        'strategy': selectors[index],
      });
      outcomes.add('$index:success');
    } on SaltTransportDecodeException catch (error) {
      outcomes.add('$index:${error.code}');
    } catch (error) {
      outcomes.add('$index:${error.runtimeType}');
    }
  }
  return outcomes.join(',');
}

String _saltDebugFingerprint(String value) =>
    sha256.convert(utf8.encode(value)).toString().substring(0, 12);

String _saltDebugHeader(Map<String, String> headers, String name) {
  final normalized = name.toLowerCase();
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == normalized) return entry.value;
  }
  return '';
}

Map<String, dynamic> _saltCode(Object? root) {
  if (root is! Map) return const <String, dynamic>{};
  final normalized = <String, dynamic>{
    for (final entry in root.entries) entry.key.toString(): entry.value,
  };
  final data = normalized['data'];
  if (data is Map) {
    final wrapped = <String, dynamic>{
      for (final entry in data.entries) entry.key.toString(): entry.value,
    };
    final code = wrapped['code'];
    if (code is Map) {
      return <String, dynamic>{
        for (final entry in code.entries) entry.key.toString(): entry.value,
      };
    }
  }
  final code = normalized['code'];
  if (code is Map) {
    return <String, dynamic>{
      for (final entry in code.entries) entry.key.toString(): entry.value,
    };
  }
  return const <String, dynamic>{};
}

List<String> _saltDebugResponseFields(Object? root) {
  final result = <String>[];

  void visit(Object? value, String path) {
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString();
        final childPath = '$path.$key';
        final child = entry.value;
        if ((key == 'article_code' || key == 'log' || key == 'random') &&
            child is String) {
          result.add(
            '$childPath(chars=${child.length},sha256=${_saltDebugFingerprint(child)})',
          );
        }
        visit(child, childPath);
      }
    } else if (value is List) {
      for (var index = 0; index < value.length; index++) {
        visit(value[index], '$path[$index]');
      }
    }
  }

  visit(root, r'$');
  return result;
}

List<String> _saltDebugTransportFields(Object? root) {
  final result = <String>[];

  void visit(Object? value, String path) {
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString();
        final childPath = '$path.$key';
        final child = entry.value;
        if (const {
          'script',
          'script_type',
          'article_code',
          'log',
        }.contains(key)) {
          if (child is String) {
            result.add(
              '$childPath(chars=${child.length},'
              'sha256=${_saltDebugFingerprint(child)})',
            );
          } else {
            result.add('$childPath(type=${child.runtimeType})');
          }
        }
        visit(child, childPath);
      }
      return;
    }
    if (value is List) {
      for (var index = 0; index < value.length; index++) {
        visit(value[index], '$path[$index]');
      }
    }
  }

  visit(root, r'$');
  return result;
}
