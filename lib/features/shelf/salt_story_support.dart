part of '../../pages/salt_page.dart';

class _SaltCoverTile extends StatelessWidget {
  const _SaltCoverTile({required this.value, required this.onTap});

  final Map<String, dynamic> value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artwork = plainText(value['artwork']);
    final validArtwork = Uri.tryParse(artwork)?.scheme == 'https';
    final labels = value['labels'] is List
        ? (value['labels'] as List).map(plainText).where((e) => e.isNotEmpty)
        : const <String>[];
    final producerName = plainText(value['producer_name']);
    final capacityText = plainText(value['sku_cap_text']);
    return SizedBox(
      width: 108,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZhRadius.card),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: validArtwork
                  ? ZhihuImage.network(
                      artwork,
                      headers: zhihuImageRequestHeaders,
                      width: 108,
                      height: 126,
                      fit: BoxFit.cover,
                      cacheWidth: saltStoryCoverCacheWidth,
                      errorBuilder: (_, _, _) => const _SaltWidePlaceholder(),
                    )
                  : const _SaltWidePlaceholder(),
            ),
            const SizedBox(height: 8),
            Text(
              titleOf(value),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            if (producerName.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                producerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: ZhPalette.mutedInk,
                ),
              ),
            ],
            if (labels.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                labels.take(2).join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
            if (labels.isEmpty && capacityText.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                capacityText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SaltWidePlaceholder extends StatelessWidget {
  const _SaltWidePlaceholder();

  @override
  Widget build(BuildContext context) => Container(
    width: 108,
    height: 126,
    color: ZhPalette.canvas,
    alignment: Alignment.center,
    child: const Icon(Icons.auto_stories_outlined, size: 28),
  );
}

String _normalizedSaltBusinessType(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'paidcolumn') return 'paid_column';
  return normalized.isEmpty ? 'paid_column' : normalized;
}

SaltBookshelfEntry _localBookshelfEntry({
  required String businessId,
  required String propertyType,
  required String title,
  required String fallbackTitle,
  String artwork = '',
  String sectionId = '',
  Map<String, dynamic> rawJson = const <String, dynamic>{},
}) {
  final normalizedTitle = title.trim().isEmpty ? fallbackTitle : title.trim();
  final url = sectionId.isNotEmpty
      ? officialSaltSectionUrl(businessId: businessId, sectionId: sectionId)
      : Uri.https('www.zhihu.com', '/market/manuscript', {
          'business_id': businessId,
          'is_mid_long': '1',
        }).toString();
  return SaltBookshelfEntry(
    businessId: businessId,
    propertyType: propertyType,
    title: normalizedTitle,
    artwork: artwork,
    sectionId: sectionId,
    rawJson: <String, dynamic>{
      ...rawJson,
      'business_id': businessId,
      'property_type': propertyType,
      'title': normalizedTitle,
      if (artwork.isNotEmpty) 'artwork': artwork,
      if (sectionId.isNotEmpty) 'section_id': sectionId,
      'url': url,
    },
    addedAt: DateTime.now(),
  );
}

String? _findString(Object? value, List<String> keys, [int depth = 0]) {
  if (depth > 5) return null;
  if (value is Map) {
    for (final key in keys) {
      final candidate = value[key];
      if (candidate is String && candidate.isNotEmpty) return candidate;
      if (candidate is num) return candidate.toString();
    }
    for (final child in value.values) {
      final result = _findString(child, keys, depth + 1);
      if (result != null) return result;
    }
  } else if (value is List) {
    for (final child in value.take(5)) {
      final result = _findString(child, keys, depth + 1);
      if (result != null) return result;
    }
  }
  return null;
}
