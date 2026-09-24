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

String profileAccountAgeText(
  Map<String, dynamic> profile, {
  DateTime? now,
  AppLocalizations? l10n,
}) {
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
  if (!created.isBefore(current)) return l10n?.profileJustJoined ?? '刚刚加入';
  final days = current.difference(created).inDays;
  if (days < 31) return l10n?.profileAgeDays(days) ?? '$days 天';
  if (days < 365) {
    return l10n?.profileAgeMonthsDays(days ~/ 30, days % 30) ??
        '${days ~/ 30} 个月 ${days % 30} 天';
  }
  return l10n?.profileAgeYearsMonths(days ~/ 365, (days % 365) ~/ 30) ??
      '${days ~/ 365} 年 ${(days % 365) ~/ 30} 个月';
}

String _profileGender(Map<String, dynamic> profile) {
  final value = profile['gender'];
  final text = plainText(value).toLowerCase();
  if (value == 0 || text == 'female') return 'female';
  if (value == 1 || text == 'male') return 'male';
  return '';
}

String profileGenderLabel(String value, AppLocalizations l10n) =>
    switch (value) {
      'female' => l10n.profileGenderFemale,
      'male' => l10n.profileGenderMale,
      _ => l10n.profileGenderUnspecified,
    };

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
    final l10n = context.zhL10n;
    final name = plainText(profile['name']).isEmpty
        ? l10n.profileUserFallback
        : plainText(profile['name']);
    final age = profileAccountAgeText(profile, l10n: l10n);
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
        title: Text(l10n.profileAllDetails),
        leading: ZhLiquidGlassIconButton(
          size: 46,
          iconSize: 24,
          semanticLabel: l10n.commonClose,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _ProfileSection(
            title: l10n.profileBasicInfo,
            children: [
              _ProfileValueRow(label: l10n.profileUsername, value: name),
              if (age.isNotEmpty)
                _ProfileValueRow(label: l10n.profileAccountAge, value: age),
              _ProfileValueRow(
                label: l10n.profileGender,
                value: profileGenderLabel(_profileGender(profile), l10n),
              ),
              if (profileBirthdayText(profile).isNotEmpty)
                _ProfileValueRow(
                  label: l10n.profileBirthday,
                  value: profileBirthdayText(profile),
                ),
              if (_profileLocation(profile).isNotEmpty)
                _ProfileValueRow(
                  label: l10n.profileLocation,
                  value: _profileLocation(profile),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileSection(
            title: l10n.profileVerification,
            trailing: Text(
              l10n.profileManageVerification,
              style: TextStyle(color: ZhPalette.subtleInk),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  identities.isEmpty
                      ? l10n.profileUnverified
                      : identities.join(' · '),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileSection(
            title: l10n.profileInfluence,
            children: [
              _ProfileImpactRow(
                icon: Icons.workspace_premium_rounded,
                label: l10n.profileBadges,
                value: identities.isEmpty
                    ? l10n.profileNone
                    : l10n.profileCountPieces(identities.length),
              ),
              _ProfileImpactRow(
                icon: Icons.change_history_rounded,
                label: l10n.profileLikes,
                value: likes == null
                    ? l10n.profileNone
                    : l10n.profileCountTimes(likes),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileSection(
            title: l10n.profileFriendImpression,
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
                    Text(l10n.profileImproveImage),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.profileAddKeywords),
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
