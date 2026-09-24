part of '../feed_page.dart';

class _SaltStoryFilterChoice {
  const _SaltStoryFilterChoice({
    required this.title,
    required this.key,
    required this.value,
  });
  final String title;
  final String key;
  final String value;
}

class _SaltStoryFilterSheet extends StatefulWidget {
  const _SaltStoryFilterSheet({
    required this.storyLength,
    required this.filters,
    required this.conditionItems,
  });
  final String storyLength;
  final Map<String, String> filters;
  final List<Map<String, dynamic>> conditionItems;
  @override
  State<_SaltStoryFilterSheet> createState() => _SaltStoryFilterSheetState();
}

class _SaltStoryFilterSheetState extends State<_SaltStoryFilterSheet> {
  late String _length;
  late Map<String, String> _filters;
  @override
  void initState() {
    super.initState();
    _length = widget.storyLength;
    _filters = {...widget.filters};
  }

  List<_SaltStoryFilterChoice> _choices(String group, AppLocalizations l10n) {
    final output = <_SaltStoryFilterChoice>[];
    for (final item in widget.conditionItems) {
      if (plainText(item['_salt_filter_group']) != group) continue;
      final title = plainText(item['title']);
      final key = plainText(item['_salt_filter_key']);
      final value = plainText(item['_salt_filter_value']);
      if (title.isNotEmpty && key.isNotEmpty && value.isNotEmpty) {
        output.add(
          _SaltStoryFilterChoice(title: title, key: key, value: value),
        );
      }
    }
    if (output.isNotEmpty) return output;
    return switch (group) {
      'content_status' => [
        _SaltStoryFilterChoice(
          title: l10n.storyOngoing,
          key: 'content_status',
          value: 'update',
        ),
        _SaltStoryFilterChoice(
          title: l10n.storyFinished,
          key: 'content_status',
          value: 'finished',
        ),
      ],
      'right_types' => [
        _SaltStoryFilterChoice(
          title: l10n.storyFree,
          key: 'right_type',
          value: 'free',
        ),
        _SaltStoryFilterChoice(
          title: l10n.storyVip,
          key: 'right_type',
          value: 'svip_free',
        ),
        _SaltStoryFilterChoice(
          title: l10n.storyVipDiscount,
          key: 'right_type',
          value: 'svip_discount',
        ),
      ],
      _ => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      height: (MediaQuery.sizeOf(context).height * .76).clamp(460.0, 720.0),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomInset),
      decoration: BoxDecoration(
        color: ZhPalette.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.storyFilter,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                tooltip: l10n.commonClose,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                _filterSection(
                  l10n.storyType,
                  [
                    _SaltStoryFilterChoice(
                      title: l10n.storyLong,
                      key: '__length',
                      value: 'long',
                    ),
                    _SaltStoryFilterChoice(
                      title: l10n.storyShort,
                      key: '__length',
                      value: 'short',
                    ),
                    _SaltStoryFilterChoice(
                      title: l10n.storyAudioBook,
                      key: '__length',
                      value: 'audio',
                    ),
                  ],
                  selected: _length,
                  selectedKey: '__length',
                ),
                _filterSection(
                  l10n.storyStatus,
                  _choices('content_status', l10n),
                ),
                _filterSection(l10n.storyRights, _choices('right_types', l10n)),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _length = 'long';
                    _filters.clear();
                  }),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.storyReset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, {
                    ..._filters,
                    '__length': _length,
                  }),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.storyConfirm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterSection(
    String title,
    List<_SaltStoryFilterChoice> choices, {
    String? selected,
    String? selectedKey,
  }) {
    if (choices.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              for (final choice in choices)
                _SaltFilterOption(
                  title: choice.title,
                  selected: selectedKey == '__length'
                      ? selected == choice.value
                      : _filters[choice.key] == choice.value,
                  onTap: () => setState(() {
                    if (selectedKey == '__length') {
                      _length = choice.value;
                    } else {
                      _filters.removeWhere((key, _) => key == choice.key);
                      _filters[choice.key] = choice.value;
                    }
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaltFilterOption extends StatelessWidget {
  const _SaltFilterOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? ZhPalette.accentSurface : ZhPalette.softSurface,
    borderRadius: BorderRadius.circular(7),
    child: InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? ZhPalette.link : ZhPalette.ink,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    ),
  );
}

class _SaltAllCategorySheet extends StatefulWidget {
  const _SaltAllCategorySheet({
    required this.items,
    required this.selectedFilters,
  });
  final List<Map<String, dynamic>> items;
  final Map<String, String> selectedFilters;
  @override
  State<_SaltAllCategorySheet> createState() => _SaltAllCategorySheetState();
}

class _SaltAllCategorySheetState extends State<_SaltAllCategorySheet> {
  List<String> _sections(AppLocalizations l10n) => [
    l10n.storySectionHotTags,
    l10n.storySectionGenre,
    l10n.storySectionCharacters,
    l10n.storySectionPlot,
    l10n.storySectionMood,
    l10n.storySectionSetting,
  ];
  int _sectionIndex = 0;
  late final List<Map<String, dynamic>> _allItems;
  late final Set<String> _selected;
  @override
  void initState() {
    super.initState();
    _allItems = widget.items
        .where((item) => plainText(item['title']).isNotEmpty)
        .toList(growable: false);
    _selected = {
      for (final item in _allItems)
        if (_matches(item)) _identity(item),
    };
  }

  bool _matches(Map<String, dynamic> item) {
    final raw = item['_salt_filter_query'];
    if (raw is! Map || raw.isEmpty) return false;
    return raw.entries.every(
      (entry) =>
          widget.selectedFilters[plainText(entry.key)] ==
          plainText(entry.value),
    );
  }

  String _identity(Map<String, dynamic> item) {
    final raw = item['_salt_filter_query'];
    if (raw is Map) {
      return raw.entries
          .map((entry) => '${plainText(entry.key)}=${plainText(entry.value)}')
          .join('&');
    }
    return plainText(item['title']);
  }

  List<Map<String, dynamic>> get _visibleItems {
    if (_sectionIndex == 0) {
      final output = <Map<String, dynamic>>[];
      final seen = <String>{};
      for (final item in _allItems) {
        final parent = plainText(item['_salt_parent_title']);
        final title = plainText(item['title']);
        final label = parent.isNotEmpty && title == '全部' ? parent : title;
        if (label.isEmpty || label == '全部' || !seen.add(label)) continue;
        output.add(item);
      }
      return output.take(18).toList(growable: false);
    }
    if (_sectionIndex == 1) return _allItems;
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final sections = _sections(l10n);
    final height = (MediaQuery.sizeOf(context).height * .82).clamp(
      560.0,
      820.0,
    );
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: ZhPalette.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.storyAllCategories,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.storyMaxTags,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ZhPalette.mutedInk,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.commonClose,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 106,
                  child: ListView.builder(
                    itemCount: sections.length,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () => setState(() => _sectionIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 17,
                        ),
                        color: _sectionIndex == index
                            ? ZhPalette.accentSurface
                            : Colors.transparent,
                        child: Text(
                          sections[index],
                          style: TextStyle(
                            color: _sectionIndex == index
                                ? ZhPalette.link
                                : ZhPalette.mutedInk,
                            fontWeight: _sectionIndex == index
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 18, 8),
                    child: _visibleItems.isEmpty
                        ? Center(
                            child: Text(
                              l10n.storyNoCategories,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: ZhPalette.mutedInk),
                            ),
                          )
                        : ListView(
                            children: [
                              Text(
                                sections[_sectionIndex],
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final item in _visibleItems)
                                    _SaltFilterOption(
                                      title: plainText(item['title']),
                                      selected: _selected.contains(
                                        _identity(item),
                                      ),
                                      onTap: () => _toggle(item),
                                    ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selected.clear()),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(l10n.storyReset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, [
                        for (final item in _allItems)
                          if (_selected.contains(_identity(item))) item,
                      ]),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(l10n.storyConfirm),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(Map<String, dynamic> item) {
    final identity = _identity(item);
    setState(() {
      if (_selected.contains(identity)) {
        _selected.remove(identity);
      } else if (_selected.length < 5) {
        _selected.add(identity);
      }
    });
  }
}

class _SaltStoryConditionGroup extends StatelessWidget {
  const _SaltStoryConditionGroup({
    required this.title,
    required this.tagTitle,
    required this.items,
    required this.onTap,
  });
  final String title;
  final String tagTitle;
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onTap;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final tagType = plainText(items.first['_salt_tag_type']);
    final all = <String, dynamic>{
      'title':
          '${context.zhL10n.storyAll}${title == context.zhL10n.storyAll ? '' : title}',
      'subtitle': tagTitle,
      '_salt_tag_type': tagType,
    };
    return ZhSurface(
      margin: const EdgeInsets.only(bottom: 12),
      radius: 18,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: tagType.isEmpty ? null : () => onTap(all),
                child: Text(context.zhL10n.storyViewAll),
              ),
            ],
          ),
          if (tagTitle.isNotEmpty && tagTitle != title)
            Text(
              tagTitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: ZhPalette.mutedInk),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                ActionChip(
                  label: Text(titleOf(item)),
                  onPressed: () => onTap(item),
                  avatar: const Icon(Icons.auto_stories_outlined, size: 16),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
