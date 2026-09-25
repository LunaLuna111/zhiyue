part of '../feed_page.dart';

class _SaltStoryCategoryPayload {
  const _SaltStoryCategoryPayload({this.header, this.conditions});
  final ApiResponse? header;
  final ApiResponse? conditions;
  bool get hasSuccess =>
      (header?.isSuccess ?? false) || (conditions?.isSuccess ?? false);
}

class SaltStoryCategoryPage extends StatefulWidget {
  const SaltStoryCategoryPage({super.key, required this.api});
  final ZhihuApiClient api;
  @override
  State<SaltStoryCategoryPage> createState() => _SaltStoryCategoryPageState();
}

class _SaltStoryCategoryPageState extends State<SaltStoryCategoryPage> {
  late Future<_SaltStoryCategoryPayload> _request;
  @override
  void initState() {
    super.initState();
    _request = _load();
  }

  Future<_SaltStoryCategoryPayload> _load() async {
    // Warm both official contracts in parallel. The category header and the
    // native book-city conditions endpoint are independent on the server.
    final responses = await Future.wait<ApiResponse?>([
      _safeGet(widget.api.saltStoryCategoriesUri()),
      _safeGet(widget.api.saltBookCityConditionsUri()),
    ]);
    return _SaltStoryCategoryPayload(
      header: responses[0],
      conditions: responses[1],
    );
  }

  Future<ApiResponse?> _safeGet(Uri uri) async {
    try {
      return await widget.api.getSaltUri(uri);
    } catch (_) {
      return null;
    }
  }

  Future<void> _retry() async {
    setState(() {
      _request = _load();
    });
  }

  void _open(Map<String, dynamic> value) {
    final object = unwrapObject(value);
    final navigation = parseSaltStoryNavigation(object);
    final businessId = navigation?.businessId ?? idOf(object);
    if (_saltStoryIdUsable(businessId)) {
      if (navigation?.opensReader == true) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SaltReaderPage(
              api: widget.api,
              businessId: businessId,
              sectionId: navigation!.sectionId!,
              contract: SaltReaderContract.automatic,
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SaltProductPage(
              api: widget.api,
              businessId: businessId,
              businessType: _saltStoryBusinessType(object),
              title: titleOf(value),
              initialMetadata: object,
            ),
          ),
        );
      }
      return;
    }
    final url = plainText(value['url']);
    final parsed = Uri.tryParse(url);
    if (parsed != null &&
        parsed.scheme == 'https' &&
        (parsed.host == 'www.zhihu.com' ||
            parsed.host == ZhihuApiClient.apiHost)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OfficialWebPage(
            title: plainText(value['category_cn']).isEmpty
                ? plainText(value['title'])
                : plainText(value['category_cn']),
            url: parsed.toString(),
          ),
        ),
      );
      return;
    }
    final tagType = plainText(value['_salt_tag_type']);
    if (tagType.isNotEmpty) {
      final rawFilters = value['_salt_filter_query'];
      final filters = <String, String>{};
      if (rawFilters is Map) {
        rawFilters.forEach((key, item) {
          final filterKey = plainText(key);
          final filterValue = plainText(item);
          if (filterKey.isNotEmpty && filterValue.isNotEmpty) {
            filters[filterKey] = filterValue;
          }
        });
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _SaltBookCitySectionPage(
            api: widget.api,
            tagType: tagType,
            title: titleOf(value),
            filters: filters,
          ),
        ),
      );
      return;
    }
    // A malformed/expired category URL should still be inspectable rather
    // than dropping a tap on the floor.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ObjectInspectorPage(value: value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    return Scaffold(
      appBar: ZhTopBar(
        title: Text(l10n.storyCategoriesTitle),
        actions: [
          ZhLiquidGlassIconButton(
            semanticLabel: l10n.storySearch,
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchPage(api: widget.api, focusOnOpen: true),
              ),
            ),
            size: 44,
            iconSize: 22,
          ),
        ],
      ),
      body: FutureBuilder<_SaltStoryCategoryPayload>(
        future: _request,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ZhListLoadingSkeleton(
              topInset: 0,
              showImages: true,
              count: 4,
              headerHeight: 76,
            );
          }
          final payload = snapshot.data;
          if (payload == null || !payload.hasSuccess) {
            final response = payload?.header ?? payload?.conditions;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 460,
                  child: ApiErrorView(
                    error: response ?? l10n.storyLoadFailed,
                    onRetry: _retry,
                    titleOverride: l10n.storyLoadFailed,
                  ),
                ),
              ],
            );
          }
          final headerItems = payload.header?.isSuccess == true
              ? extractSaltStoryCategoryItems(payload.header!.json)
              : const <Map<String, dynamic>>[];
          final conditionItems = payload.conditions?.isSuccess == true
              ? extractSaltBookCityCategoryItems(payload.conditions!.json)
              : const <Map<String, dynamic>>[];
          if (headerItems.isEmpty && conditionItems.isEmpty) {
            return RefreshIndicator(
              onRefresh: _retry,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 460,
                    child: Center(child: Text(l10n.storyEmptyCategories)),
                  ),
                ],
              ),
            );
          }
          final conditionGroups = _groupConditionItems(conditionItems, l10n);
          if (conditionGroups.isNotEmpty) {
            return _SaltStoryCategoryTabs(
              api: widget.api,
              tags: _groupConditionTags(conditionGroups, l10n),
              conditionItems: conditionItems,
              headerItems: headerItems,
              onOpen: _open,
              onRefresh: _retry,
            );
          }
          final itemCount =
              1 +
              (conditionGroups.isEmpty ? 0 : conditionGroups.length + 1) +
              (headerItems.isEmpty ? 0 : headerItems.length + 1);
          return RefreshIndicator(
            onRefresh: _retry,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: Text(
                      l10n.storyBrowseByGenre,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }
                var cursor = 1;
                if (conditionGroups.isNotEmpty) {
                  if (index == cursor) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                      child: Text(
                        l10n.storyFilterStories,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    );
                  }
                  cursor++;
                  final groupIndex = index - cursor;
                  if (groupIndex < conditionGroups.length) {
                    final group = conditionGroups[groupIndex];
                    return _SaltStoryConditionGroup(
                      title: group.title,
                      tagTitle: group.tagTitle,
                      items: group.items,
                      onTap: _open,
                    );
                  }
                  cursor += conditionGroups.length;
                }
                if (headerItems.isNotEmpty) {
                  if (index == cursor) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
                      child: Text(
                        l10n.storyFeaturedCategories,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    );
                  }
                  final item = headerItems[index - cursor - 1];
                  return _SaltStoryCategoryCard(
                    value: item,
                    onTap: () => _open(item),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  List<_SaltConditionGroup> _groupConditionItems(
    List<Map<String, dynamic>> items,
    AppLocalizations l10n,
  ) {
    final groups = <String, _SaltConditionGroup>{};
    for (final item in items) {
      final tagType = plainText(item['_salt_tag_type']);
      final parentTitle = plainText(item['_salt_parent_title']);
      final tagTitle = plainText(item['subtitle']);
      final role = plainText(item['_salt_condition_role']);
      final key = [tagType, role, parentTitle, tagTitle].join('|');
      final existing = groups[key];
      if (existing == null) {
        groups[key] = _SaltConditionGroup(
          title: parentTitle.isNotEmpty
              ? parentTitle
              : switch (role) {
                  'quick' => l10n.storyQuickFilter,
                  'sort' => l10n.storySort,
                  _ => tagTitle.isEmpty ? l10n.storyAll : tagTitle,
                },
          tagTitle: tagTitle,
          items: [item],
        );
      } else {
        groups[key] = existing.copyWith(items: [...existing.items, item]);
      }
    }
    return groups.values.toList(growable: false);
  }

  List<_SaltStoryConditionTag> _groupConditionTags(
    List<_SaltConditionGroup> groups,
    AppLocalizations l10n,
  ) {
    final tags = <String, _SaltStoryConditionTag>{};
    for (final group in groups) {
      final tagType = plainText(group.items.first['_salt_tag_type']);
      final key = tagType.isEmpty ? group.tagTitle : tagType;
      final existing = tags[key];
      if (existing == null) {
        tags[key] = _SaltStoryConditionTag(
          type: tagType,
          title: group.tagTitle.isEmpty
              ? (tagType.isEmpty ? l10n.storyCategory : tagType)
              : group.tagTitle,
          groups: [group],
        );
      } else {
        tags[key] = existing.copyWith(groups: [...existing.groups, group]);
      }
    }
    return tags.values.toList(growable: false);
  }
}

class _SaltConditionGroup {
  const _SaltConditionGroup({
    required this.title,
    required this.tagTitle,
    required this.items,
  });
  final String title;
  final String tagTitle;
  final List<Map<String, dynamic>> items;
  _SaltConditionGroup copyWith({List<Map<String, dynamic>>? items}) =>
      _SaltConditionGroup(
        title: title,
        tagTitle: tagTitle,
        items: items ?? this.items,
      );
}

class _SaltStoryConditionTag {
  const _SaltStoryConditionTag({
    required this.type,
    required this.title,
    required this.groups,
  });
  final String type;
  final String title;
  final List<_SaltConditionGroup> groups;
  _SaltStoryConditionTag copyWith({List<_SaltConditionGroup>? groups}) =>
      _SaltStoryConditionTag(
        type: type,
        title: title,
        groups: groups ?? this.groups,
      );
}
