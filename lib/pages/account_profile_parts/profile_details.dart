part of '../account_profile_pages.dart';

List<Map<String, dynamic>> _profileMaps(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => item.map((key, value) => MapEntry('$key', value)))
      .toList(growable: false);
}

String _profileObjectName(Object? value) {
  if (value is Map) {
    for (final key in const ['name', 'title', 'address', 'value']) {
      final text = plainText(value[key]);
      if (text.isNotEmpty) return text;
    }
  }
  return plainText(value);
}

String profileBirthdayText(Map<String, dynamic> profile) {
  final value = profile['birthday'];
  if (value is Map) {
    final year = int.tryParse(plainText(value['year']));
    final month = int.tryParse(plainText(value['month']));
    final day = int.tryParse(plainText(value['day']));
    if (year != null && month != null && day != null) {
      return '$year-${month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')}';
    }
  }
  final text = plainText(value);
  final match = RegExp(r'(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})').firstMatch(text);
  if (match == null) return '';
  return '${match.group(1)}-${match.group(2)!.padLeft(2, '0')}-'
      '${match.group(3)!.padLeft(2, '0')}';
}

DateTime? _profileBirthday(Map<String, dynamic> profile) {
  final text = profileBirthdayText(profile);
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String profileAccountAgeText(Map<String, dynamic> profile, {DateTime? now}) {
  final official = plainText(profile['zhi_age']);
  if (official.isNotEmpty) return official;
  int? timestamp;
  for (final key in const [
    'account_created_at',
    'created_at',
    'created_time',
    'member_since',
  ]) {
    final value = profile[key];
    timestamp = value is num ? value.round() : int.tryParse(plainText(value));
    if (timestamp != null) break;
  }
  if (timestamp == null || timestamp <= 0) return '';
  final created = DateTime.fromMillisecondsSinceEpoch(
    timestamp > 100000000000 ? timestamp : timestamp * 1000,
  );
  final current = now ?? DateTime.now();
  if (!created.isBefore(current)) return '刚刚加入';
  final days = current.difference(created).inDays;
  if (days < 31) return '$days 天';
  if (days < 365) return '${days ~/ 30} 个月 ${days % 30} 天';
  return '${days ~/ 365} 年 ${(days % 365) ~/ 30} 个月';
}

String _profileGender(Map<String, dynamic> profile) {
  final value = profile['gender'];
  final text = plainText(value).toLowerCase();
  if (value == 0 || text == 'female') return '女';
  if (value == 1 || text == 'male') return '男';
  return '未填写';
}

String _profileLocation(Map<String, dynamic> profile) {
  final values = _profileMaps(profile['locations']);
  if (values.isEmpty) return '';
  return _profileObjectName(values.first['name'] ?? values.first['address']);
}

String _profileBusiness(Map<String, dynamic> profile) =>
    _profileObjectName(profile['business']);

List<String> _profileIdentityLabels(Map<String, dynamic> profile) {
  final result = <String>[];
  void add(Object? value) {
    if (value is List) {
      for (final item in value) {
        add(item);
      }
      return;
    }
    if (value is Map) {
      for (final key in const ['title', 'name', 'description', 'identity']) {
        final text = plainText(value[key]);
        if (text.isNotEmpty && !result.contains(text)) {
          result.add(text);
          return;
        }
      }
    }
  }

  add(profile['identity_infos']);
  add(profile['badge_v2']);
  add(profile['badges']);
  add(profile['medals']);
  return result;
}

int? _profileMetric(Map<String, dynamic> profile, List<String> keys) {
  for (final key in keys) {
    final value = profile[key];
    if (value is num) return value.round();
    final parsed = int.tryParse(plainText(value).replaceAll(',', ''));
    if (parsed != null) return parsed;
  }
  return null;
}

class AccountProfileDetailsPage extends StatelessWidget {
  const AccountProfileDetailsPage({super.key, required this.profile});

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final name = plainText(profile['name']).isEmpty
        ? '知乎用户'
        : plainText(profile['name']);
    final age = profileAccountAgeText(profile);
    final identities = _profileIdentityLabels(profile);
    final likes = _profileMetric(profile, const [
      'voteup_count',
      'get_praise_count',
    ]);
    final avatar = plainText(
      profile['avatar_url'] ?? profile['avatar_url_template'],
    );
    return Scaffold(
      backgroundColor: ZhPalette.canvas,
      appBar: ZhTopBar(
        title: const Text('个人资料'),
        leading: ZhLiquidGlassIconButton(
          size: 46,
          iconSize: 24,
          semanticLabel: '关闭',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _ProfileSection(
            title: '基本资料',
            children: [
              _ProfileValueRow(label: '用户名', value: name),
              if (age.isNotEmpty) _ProfileValueRow(label: '知龄', value: age),
              _ProfileValueRow(label: '性别', value: _profileGender(profile)),
              if (profileBirthdayText(profile).isNotEmpty)
                _ProfileValueRow(
                  label: '生日',
                  value: profileBirthdayText(profile),
                ),
              if (_profileLocation(profile).isNotEmpty)
                _ProfileValueRow(
                  label: '居住地',
                  value: _profileLocation(profile),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileSection(
            title: '认证信息',
            trailing: const Text(
              '管理认证',
              style: TextStyle(color: ZhPalette.subtleInk),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  identities.isEmpty ? '未认证' : identities.join(' · '),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileSection(
            title: '影响力',
            children: [
              _ProfileImpactRow(
                icon: Icons.workspace_premium_rounded,
                label: '我的徽章',
                value: identities.isEmpty ? '暂无' : '${identities.length} 枚',
              ),
              _ProfileImpactRow(
                icon: Icons.change_history_rounded,
                label: '获得喜欢',
                value: likes == null ? '暂无' : '$likes 次',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileSection(
            title: '好友印象',
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: ZhPalette.pressed,
                      backgroundImage: Uri.tryParse(avatar)?.scheme == 'https'
                          ? ZhihuCachedNetworkImageProvider(
                              avatar,
                              headers: zhihuImageRequestHeaders,
                            )
                          : null,
                      child: Uri.tryParse(avatar)?.scheme == 'https'
                          ? null
                          : Text(name.characters.first),
                    ),
                    const SizedBox(height: 12),
                    const Text('完善我的知乎形象，获取更多关注'),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('添加形象关键词'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
