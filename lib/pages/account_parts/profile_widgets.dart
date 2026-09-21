part of '../account_page.dart';

enum _ActivityMenuAction { share, delete }

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (Uri.tryParse(imageUrl)?.scheme != 'https') {
      return const ColoredBox(color: Color(0xFF326A66));
    }
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .clamp(720.0, 1920.0)
            .round();
    return ZhihuImage.network(
      imageUrl,
      headers: zhihuImageRequestHeaders,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.low,
      frameBuilder: (_, child, frame, _) =>
          frame == null ? const ColoredBox(color: Color(0xFF326A66)) : child,
      errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF326A66)),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
    required this.fallback,
    this.size = 82,
  });

  final String imageUrl;
  final String fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: ZhPalette.ink,
      child: Center(
        child: Text(
          fallback.characters.first,
          style: const TextStyle(
            color: ZhPalette.background,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: ZhPalette.background,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Uri.tryParse(imageUrl)?.scheme != 'https'
            ? placeholder
            : ZhihuImage.network(
                imageUrl,
                headers: zhihuImageRequestHeaders,
                fit: BoxFit.cover,
                cacheWidth: (size * 3).round(),
                cacheHeight: (size * 3).round(),
                frameBuilder: (_, child, frame, _) =>
                    frame == null ? placeholder : child,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

class _ProfileMeta extends StatelessWidget {
  const _ProfileMeta({
    required this.icon,
    required this.text,
    this.emphasized = false,
    this.light = false,
  });

  final IconData icon;
  final String text;
  final bool emphasized;
  final bool light;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 15,
        color: light
            ? (emphasized ? const Color(0xFFF3C86A) : Colors.white)
            : (emphasized ? const Color(0xFF9A6A16) : ZhPalette.subtleInk),
      ),
      const SizedBox(width: 4),
      Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: light
              ? Colors.white
              : (emphasized ? const Color(0xFF7C5617) : ZhPalette.mutedInk),
          fontWeight: emphasized ? FontWeight.w700 : null,
        ),
      ),
    ],
  );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    this.onTap,
    this.light = false,
  });

  final int? value;
  final String label;
  final VoidCallback? onTap;
  final bool light;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(
            value == null ? '--' : formatAccountProfileMetric(value!),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: light ? Colors.white : null,
              fontSize: 16,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: light ? Colors.white : null),
          ),
        ],
      ),
    ),
  );
}

class _ProfileStatDivider extends StatelessWidget {
  const _ProfileStatDivider({this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 30,
    child: VerticalDivider(width: 1, color: light ? Colors.white54 : null),
  );
}

String _metricSummary(Map<String, dynamic> profile, List<String> keys) {
  final value = accountProfileMetric(profile, keys);
  return value == null ? '' : '${formatAccountProfileMetric(value)} 条';
}

String _profileIp(Map<String, dynamic> profile) {
  final value = profile['ip_info'];
  if (value is Map) {
    final location = plainText(
      value['location'] ?? value['province'] ?? value['ip_location'],
    );
    return location.isEmpty ? '' : 'IP $location';
  }
  final text = plainText(value);
  return text.isEmpty ? '' : (text.startsWith('IP') ? text : 'IP $text');
}

String _profileVipLabel(Map<String, dynamic> profile) {
  bool active(Object? value) {
    if (value is! Map) return false;
    if (value['is_vip'] == true || value['is_annual'] == true) return true;
    final type = value['vip_type'];
    return type is num && type > 0;
  }

  if (active(profile['kvip_info'])) return '盐选会员';
  if (active(profile['vip_info'])) return '知乎会员';
  return '';
}

bool _isVerified(Map<String, dynamic> profile) {
  final badge = profile['badge'];
  if (badge is List && badge.isNotEmpty) return true;
  final badgeV2 = profile['badge_v2'];
  if (badgeV2 is Map) {
    final details = badgeV2['detail_badges'];
    if (details is List && details.isNotEmpty) return true;
    return plainText(badgeV2['title']).isNotEmpty;
  }
  return false;
}
