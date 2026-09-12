part of '../account_page.dart';

Map<String, dynamic> mergeAccountProfilePayloads(
  Map<String, dynamic> self,
  Map<String, dynamic>? profile,
) {
  final merged = <String, dynamic>{...?profile, ...self};
  final publicCover = plainText(profile?['cover_url']);
  if (plainText(merged['cover_url']).isEmpty && publicCover.isNotEmpty) {
    merged['cover_url'] = publicCover;
  }
  return merged;
}

int? accountProfileMetric(Map<String, dynamic> profile, List<String> keys) {
  for (final key in keys) {
    final value = profile[key];
    if (value is num) return value.round();
    final parsed = int.tryParse(plainText(value).replaceAll(',', ''));
    if (parsed != null) return parsed;
  }
  return null;
}

String accountProfileLocation(Map<String, dynamic> profile) {
  final locations = profile['locations'];
  if (locations is List && locations.isNotEmpty) {
    final first = locations.first;
    if (first is Map) return plainText(first['name']);
    return plainText(first);
  }
  return '';
}

String accountProfileGender(Map<String, dynamic> profile) {
  final value = profile['gender'];
  if (value == 0 || plainText(value).toLowerCase() == 'female') return '女';
  if (value == 1 || plainText(value).toLowerCase() == 'male') return '男';
  return '';
}

String formatAccountProfileMetric(int value) {
  if (value >= 100000000) {
    return '${(value / 100000000).toStringAsFixed(value >= 1000000000 ? 0 : 1)}亿';
  }
  if (value >= 10000) {
    return '${(value / 10000).toStringAsFixed(value >= 100000 ? 0 : 1)}万';
  }
  return '$value';
}

bool isAccountPromotionalFeedItem(Map<String, dynamic> row) {
  bool promotionalMap(Map value) {
    for (final key in const [
      'type',
      'card_type',
      'style_type',
      'content_type',
      'business_type',
    ]) {
      final marker = plainText(value[key]).toLowerCase().replaceAll('-', '_');
      if (const {
        'eventcard',
        'event_card',
        'advertisement',
        'commercial',
        'marketing',
        'promotion',
        'ad',
      }.contains(marker)) {
        return true;
      }
    }
    if (value['is_ad'] == true ||
        value['is_advertisement'] == true ||
        value['is_commercial'] == true) {
      return true;
    }
    for (final entry in value.entries) {
      final key = plainText(entry.key).toLowerCase();
      if ((key == 'ad' || key == 'advertisement' || key == 'commercial') &&
          entry.value != null &&
          entry.value != false) {
        return true;
      }
      final nested = entry.value;
      if (nested is Map && promotionalMap(nested)) return true;
    }
    return false;
  }

  return promotionalMap(row);
}

List<Map<String, dynamic>> extractAccountProfileFeedRows(Object? value) =>
    extractRows(value)
        .where((row) => !isAccountPromotionalFeedItem(row))
        .toList(growable: false);

bool accountActivityCanDelete(Map<String, dynamic> row) {
  bool find(Object? value) {
    if (value is Map) {
      final momentsData = value['moments_biz_data'];
      if (momentsData is Map) {
        final interaction = momentsData['interaction'];
        if (interaction is Map &&
            (interaction['can_delete'] == true ||
                interaction['canDelete'] == true)) {
          return true;
        }
      }
      return value.values.any(find);
    }
    return value is List && value.any(find);
  }

  return find(row);
}

String accountActivityBriefOf(Map<String, dynamic> row) {
  String find(Object? value, {bool inMomentsData = false}) {
    if (value is Map) {
      final nestedMoments = value['moments_biz_data'];
      if (nestedMoments != null) {
        final result = find(nestedMoments, inMomentsData: true);
        if (result.isNotEmpty) return result;
      }
      for (final key
          in inMomentsData
              ? const ['brief', 'item_brief']
              : const ['item_brief']) {
        final text = plainText(value[key]);
        if (text.isNotEmpty) return text;
      }
      for (final nested in value.values) {
        final result = find(nested, inMomentsData: inMomentsData);
        if (result.isNotEmpty) return result;
      }
    } else if (value is List) {
      for (final nested in value) {
        final result = find(nested, inMomentsData: inMomentsData);
        if (result.isNotEmpty) return result;
      }
    }
    return '';
  }

  return find(row);
}

String accountActivityShareUrlOf(Map<String, dynamic> row) {
  String findUrl(Object? value) {
    if (value is Map) {
      for (final key in const ['share_url', 'url', 'link_url']) {
        final text = plainText(value[key]);
        final uri = Uri.tryParse(text);
        if (uri?.scheme == 'https' &&
            (uri!.host == 'zhihu.com' || uri.host.endsWith('.zhihu.com'))) {
          return text;
        }
      }
      for (final nested in value.values) {
        final result = findUrl(nested);
        if (result.isNotEmpty) return result;
      }
    } else if (value is List) {
      for (final nested in value) {
        final result = findUrl(nested);
        if (result.isNotEmpty) return result;
      }
    }
    return '';
  }

  final captured = findUrl(row);
  if (captured.isNotEmpty) return captured;
  final object = unwrapObject(row);
  final type = typeOf(row).replaceAll('search_', '');
  final id = idOf(row);
  if (id.isEmpty) return 'https://www.zhihu.com';
  if (type.contains('answer')) {
    final question = object['question'];
    final questionId = question is Map ? plainText(question['id']) : '';
    return questionId.isEmpty
        ? 'https://www.zhihu.com/answer/$id'
        : 'https://www.zhihu.com/question/$questionId/answer/$id';
  }
  if (type.contains('article')) return 'https://zhuanlan.zhihu.com/p/$id';
  if (type.contains('pin')) return 'https://www.zhihu.com/pin/$id';
  if (type.contains('question')) return 'https://www.zhihu.com/question/$id';
  return 'https://www.zhihu.com';
}
