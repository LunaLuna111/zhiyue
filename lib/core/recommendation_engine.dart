import 'json_tools.dart';

/// The recommendation source is deliberately a strategy, not a different
/// network contract.  This lets the app keep the server response as a safe
/// candidate pool while changing only the ordering policy locally.
enum RecommendationMode { server, local, hybrid }

extension RecommendationModeValue on RecommendationMode {
  String get label => switch (this) {
    RecommendationMode.server => '服务器',
    RecommendationMode.local => '本地',
    RecommendationMode.hybrid => '混合',
  };

  String get description => switch (this) {
    RecommendationMode.server => '保持知乎服务端返回顺序',
    RecommendationMode.local => '按本机浏览记录对候选内容排序',
    RecommendationMode.hybrid => '融合服务端顺序与本机兴趣排序',
  };
}

/// Applies a deterministic local ranking to a server-provided candidate pool.
///
/// The reference client keeps a local candidate database.  This Flutter
/// client already has a bounded browsing history but intentionally does not
/// crawl content in the background.  Ranking the fresh server pool gives the
/// same user-visible strategy without adding an unbounded crawler or changing
/// the existing API/cache contract.
List<Map<String, dynamic>> rankHomeFeedRows(
  Iterable<Map<String, dynamic>> source, {
  required RecommendationMode mode,
  Iterable<String> localSignals = const <String>[],
}) {
  final rows = source.toList(growable: false);
  if (mode == RecommendationMode.server || rows.length < 2) return rows;

  final profile = <String, int>{};
  for (final signal in localSignals) {
    for (final token in _recommendationTokens(signal)) {
      profile[token] = (profile[token] ?? 0) + 1;
    }
  }
  if (profile.isEmpty) return rows;

  final scored = <_ScoredFeedRow>[];
  for (var index = 0; index < rows.length; index++) {
    final row = rows[index];
    final tokens = _recommendationTokens(_rowSearchText(row));
    var affinity = 0;
    for (final token in tokens) {
      affinity += profile[token] ?? 0;
    }
    scored.add(_ScoredFeedRow(row: row, index: index, affinity: affinity));
  }
  scored.sort((left, right) {
    final score = right.affinity.compareTo(left.affinity);
    return score == 0 ? left.index.compareTo(right.index) : score;
  });
  final local = scored.map((item) => item.row).toList(growable: false);
  if (mode == RecommendationMode.local) return local;

  // Hybrid mode keeps the server's diversity visible: two locally relevant
  // candidates are followed by one original-order candidate, with identity
  // de-duplication for rows that occur in both streams.
  final result = <Map<String, dynamic>>[];
  final seen = <String>{};
  var localCursor = 0;
  var serverCursor = 0;
  while (result.length < rows.length) {
    for (var count = 0; count < 2 && localCursor < local.length; count++) {
      _appendUnique(result, seen, local[localCursor++]);
    }
    while (serverCursor < rows.length) {
      final candidate = rows[serverCursor++];
      if (_appendUnique(result, seen, candidate)) break;
    }
    while (localCursor < local.length && result.length < rows.length) {
      _appendUnique(result, seen, local[localCursor++]);
    }
    if (serverCursor >= rows.length && localCursor >= local.length) break;
  }
  return List.unmodifiable(result);
}

bool _appendUnique(
  List<Map<String, dynamic>> target,
  Set<String> seen,
  Map<String, dynamic> row,
) {
  final identity = _feedIdentity(row);
  if (!seen.add(identity)) return false;
  target.add(row);
  return true;
}

String _feedIdentity(Map<String, dynamic> row) {
  final type = typeOf(row);
  final id = idOf(row);
  if (type.isNotEmpty || id.isNotEmpty) return '$type:$id';
  return 'row:${row.hashCode}';
}

String _rowSearchText(Map<String, dynamic> row) {
  final object = unwrapObject(row);
  return [
    titleOf(row),
    subtitleOf(row),
    authorNameOf(row),
    plainText(row['excerpt']),
    plainText(row['content']),
    titleOf(object),
    subtitleOf(object),
    authorNameOf(object),
  ].where((value) => value.trim().isNotEmpty).join(' ');
}

Iterable<String> _recommendationTokens(String value) sync* {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return;
  final matches = RegExp(
    r'[\u4e00-\u9fff]|[a-z0-9]{2,}',
  ).allMatches(normalized);
  for (final match in matches) {
    final token = match.group(0);
    if (token != null && token.isNotEmpty) yield token;
  }
}

class _ScoredFeedRow {
  const _ScoredFeedRow({
    required this.row,
    required this.index,
    required this.affinity,
  });

  final Map<String, dynamic> row;
  final int index;
  final int affinity;
}
