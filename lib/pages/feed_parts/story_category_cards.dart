part of '../feed_page.dart';

class _SaltStoryCategoryCard extends StatelessWidget {
  const _SaltStoryCategoryCard({required this.value, required this.onTap});
  final Map<String, dynamic> value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final title = plainText(value['category_cn'] ?? value['title']);
    final subtitle = plainText(value['category_name'] ?? value['subtitle']);
    final image = plainText(value['banner'] ?? value['background']);
    final validImage = Uri.tryParse(image)?.scheme == 'https';
    return ZhSurface(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 14),
      radius: 22,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 128,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (validImage)
                ZhihuImage.network(
                  image,
                  headers: zhihuImageRequestHeaders,
                  fit: BoxFit.cover,
                  cacheWidth: 960,
                  filterQuality: FilterQuality.low,
                  frameBuilder: (_, child, frame, _) => frame == null
                      ? ColoredBox(color: ZhPalette.canvas)
                      : child,
                  errorBuilder: (_, _, _) =>
                      ColoredBox(color: ZhPalette.canvas),
                )
              else
                ColoredBox(color: ZhPalette.canvas),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xCC000000),
                      Color(0x55000000),
                      Color(0x11000000),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isEmpty ? '故事分类' : title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaltBookCitySectionPage extends StatelessWidget {
  const _SaltBookCitySectionPage({
    required this.api,
    required this.tagType,
    required this.title,
    this.filters = const <String, String>{},
  });
  final ZhihuApiClient api;
  final String tagType;
  final String title;
  final Map<String, String> filters;
  void _open(BuildContext context, Map<String, dynamic> value) {
    final object = unwrapObject(value);
    final navigation = parseSaltStoryNavigation(object);
    final businessId = navigation?.businessId ?? idOf(object);
    if (!_saltStoryIdUsable(businessId)) {
      openDetectedObject(context, api, value);
      return;
    }
    if (navigation?.opensReader == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SaltReaderPage(
            api: api,
            businessId: businessId,
            sectionId: navigation!.sectionId!,
            contract: SaltReaderContract.automatic,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaltProductPage(
          api: api,
          businessId: businessId,
          businessType: _saltStoryBusinessType(object),
          title: titleOf(value),
          initialMetadata: object,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PagedListPage(
    title: title.isEmpty ? '故事分类' : title,
    api: api,
    loadInitial: () async {
      final initial = await api.getSaltUri(
        api.saltBookCitySectionInitialUri(tagType: tagType, filters: filters),
      );
      if (initial.isSuccess) return initial;
      try {
        final fallback = await api.getSaltUri(
          api.saltBookCitySkuListUri(tagType: tagType, filters: filters),
        );
        if (fallback.isSuccess) return fallback;
      } catch (_) {
        // Keep the native error response.
      }
      return initial;
    },
    rowsExtractor: extractSaltLongStoryRows,
    rowBuilder: (context, value, onTap) => SaltCatalogCard(
      value: value,
      onTap: onTap,
      coverWidth: 80,
      coverHeight: 112,
    ),
    onObjectTap: _open,
    emptyMessage: '该分类暂时没有故事',
  );
}

class SaltStoryLongFormPage extends StatelessWidget {
  const SaltStoryLongFormPage({
    super.key,
    required this.api,
    required this.shortcut,
  });
  final ZhihuApiClient api;
  final Map<String, dynamic> shortcut;
  Future<ApiResponse> _load() async {
    final rawUrl = plainText(shortcut['url']);
    final parsed = Uri.tryParse(rawUrl);
    final candidates = <Uri>[];
    if (parsed != null &&
        parsed.scheme == 'https' &&
        parsed.host == ZhihuApiClient.apiHost &&
        parsed.path != api.saltStoryHomeUri().path) {
      candidates.add(parsed);
    }
    candidates.add(api.saltLongStoryDiscoverUri());
    final responses = await Future.wait(
      candidates.map((target) async {
        try {
          return await api.getSaltUri(target);
        } catch (_) {
          return null;
        }
      }),
    );
    ApiResponse? lastSuccess;
    for (final response in responses) {
      if (response == null || !response.isSuccess) continue;
      lastSuccess ??= response;
      if (extractSaltLongStoryRows(response.json).isNotEmpty) return response;
    }
    // Keep the server's successful empty response when every endpoint is
    // genuinely empty; PagedListPage can then show its normal empty state.
    return lastSuccess ?? await api.getSaltUri(api.saltLongStoryDiscoverUri());
  }

  void _open(BuildContext context, Map<String, dynamic> value) {
    final object = unwrapObject(value);
    final navigation = parseSaltStoryNavigation(object);
    final businessId = navigation?.businessId ?? idOf(object);
    if (_saltStoryIdUsable(businessId)) {
      if (navigation?.opensReader == true) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SaltReaderPage(
              api: api,
              businessId: businessId,
              sectionId: navigation!.sectionId!,
              contract: SaltReaderContract.automatic,
            ),
          ),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SaltProductPage(
            api: api,
            businessId: businessId,
            businessType: _saltStoryBusinessType(object),
            title: titleOf(value),
            initialMetadata: object,
          ),
        ),
      );
      return;
    }
    final url = <Object?>[
      object['url'],
      object['target_url'],
      object['redirect_url'],
      object['link'],
      object['deep_link'],
    ].map(plainText).firstWhere((value) => value.isNotEmpty, orElse: () => '');
    final questionId = saltQuestionIdFromUrl(url);
    if (questionId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionAnswersPage(
            api: api,
            questionId: questionId,
            title: titleOf(value),
          ),
        ),
      );
      return;
    }
    final parsed = Uri.tryParse(url);
    if (parsed != null &&
        parsed.scheme == 'https' &&
        (parsed.host == ZhihuApiClient.apiHost ||
            parsed.host == 'www.zhihu.com')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OfficialWebPage(title: titleOf(value), url: url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => PagedListPage(
    title: '长篇故事',
    api: api,
    loadInitial: _load,
    rowsExtractor: extractSaltLongStoryRows,
    rowBuilder: (context, value, onTap) => SaltCatalogCard(
      value: value,
      onTap: onTap,
      coverWidth: 80,
      coverHeight: 112,
    ),
    onObjectTap: _open,
    emptyMessage: '暂时没有长篇故事',
  );
}

String _saltStoryBusinessType(Map<String, dynamic> value) {
  final raw = plainText(value['business_type'] ?? value['type']).toLowerCase();
  if (raw.contains('audio')) return 'audio';
  if (raw.contains('video')) return 'video';
  return 'paid_column';
}

bool _saltStoryIdUsable(String value) => RegExp(r'^\d+$').hasMatch(value);
