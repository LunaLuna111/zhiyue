part of '../salt_page.dart';

class _SaltStoryBlock {
  const _SaltStoryBlock.module(this.module) : card = null, headerOnly = false;

  const _SaltStoryBlock.header(this.module) : card = null, headerOnly = true;

  const _SaltStoryBlock.card(this.module, this.card) : headerOnly = false;

  final Map<String, dynamic> module;
  final Map<String, dynamic>? card;
  final bool headerOnly;
}

/// Keeps every work returned by the seven-module official home response, but
/// promotes long vertical feeds to top-level list rows. This preserves module
/// headings while allowing ListView to build the 40-card feed lazily instead
/// of laying out the whole module during the first frame.
List<_SaltStoryBlock> _saltStoryBlocks(Iterable<Map<String, dynamic>> modules) {
  final blocks = <_SaltStoryBlock>[];
  var shortcutInserted = false;
  int? firstContentModuleEndIndex;
  int? preferredShortcutInsertionIndex;
  for (final module in modules) {
    final type = plainText(
      module['module_type'] ?? module['card_type'],
    ).toLowerCase();
    final data = _saltModuleData(module);
    final cards = _saltMapList(data?['content_list']);
    final horizontal = type == 'today_read' || type == 'story_everyone_watch';
    if (type == 'vip_card') continue;

    // The live service has shipped the shortcut module as both `tab_nav` and
    // a generic module carrying an `items` list. Keep either shape visible.
    // An empty/missing `items` list is repaired by _saltStoryShortcutItems in
    // _SaltModuleView below, so a transient response cannot remove the entry
    // points from the story home.
    final hasShortcutItems = _saltMapList(data?['items']).isNotEmpty;
    if (type == 'tab_nav' && data == null) {
      preferredShortcutInsertionIndex ??= blocks.length;
      continue;
    }
    if (type == 'tab_nav' || hasShortcutItems) shortcutInserted = true;
    if (cards.isEmpty || horizontal) {
      blocks.add(_SaltStoryBlock.module(module));
      firstContentModuleEndIndex ??= blocks.length;
      if (type == 'billboard') {
        preferredShortcutInsertionIndex ??= blocks.length;
      }
      continue;
    }
    blocks.add(_SaltStoryBlock.header(module));
    for (final card in cards) {
      blocks.add(_SaltStoryBlock.card(module, card));
    }
    firstContentModuleEndIndex ??= blocks.length;
    if (type == 'billboard') {
      preferredShortcutInsertionIndex ??= blocks.length;
    }
  }
  // A partial/expired story response can omit the whole tab module. Insert a
  // single fallback after the first rendered module rather than leaving the
  // user with no way to reach 分类、长篇 and 书架. Real API cards still take
  // precedence and therefore do not produce duplicates.
  if (!shortcutInserted) {
    final fallback = _SaltStoryBlock.module(_saltFallbackStoryShortcutModule());
    final insertion =
        preferredShortcutInsertionIndex ?? firstContentModuleEndIndex ?? 0;
    blocks.insert(insertion, fallback);
  }
  return blocks;
}

Map<String, dynamic> _saltFallbackStoryShortcutModule() => {
  'module_type': 'tab_nav',
  'module_data': {
    'data': {
      'items': [
        {'card_type': 'bookshelf', 'title': '书架'},
        {'card_type': 'well', 'title': '长篇'},
        {'card_type': 'category', 'title': '分类'},
      ],
    },
  },
};

List<Map<String, dynamic>> _saltStoryShortcutItems(
  Object? value, {
  bool includeFallback = true,
}) {
  final source = _saltMapList(value);
  final items = <Map<String, dynamic>>[];
  final seen = <String>{};
  for (final item in source) {
    final rawType = plainText(
      item['card_type'] ?? item['type'] ?? item['key'] ?? item['name'],
    ).trim().toLowerCase();
    final type = switch (rawType) {
      '书架' || 'bookshelf' || 'book_shelf' => 'bookshelf',
      '长篇' || 'well' || 'long_story' || 'longstory' || 'long_form' => 'well',
      '分类' || 'category' || 'classify' || 'classification' => 'category',
      _ => '',
    };
    if (type.isEmpty) {
      continue;
    }
    if (seen.add(type)) {
      final fallbackTitle = switch (type) {
        'bookshelf' => '书架',
        'well' => '长篇',
        _ => '分类',
      };
      items.add({
        ...item,
        'card_type': type,
        if (plainText(item['title']).isEmpty) 'title': fallbackTitle,
      });
    }
  }
  const fallback = <Map<String, dynamic>>[
    {'card_type': 'bookshelf', 'title': '书架'},
    {'card_type': 'well', 'title': '长篇'},
    {'card_type': 'category', 'title': '分类'},
  ];
  if (includeFallback) {
    for (final item in fallback) {
      final type = item['card_type']! as String;
      if (seen.add(type)) items.add(item);
    }
  }
  return items;
}

String _saltFallbackTitle(String type) => switch (type) {
  'must_see' => '进站必看',
  'today_read' => '今日阅读',
  'story_everyone_watch' => '大家都在看',
  'feed_card' => '为你推荐',
  _ => '盐选故事',
};

class _SaltModuleView extends StatelessWidget {
  const _SaltModuleView({
    required this.module,
    required this.onOpenCard,
    required this.onOpenShortcut,
  });

  final Map<String, dynamic> module;
  final ValueChanged<Map<String, dynamic>> onOpenCard;
  final ValueChanged<Map<String, dynamic>> onOpenShortcut;

  @override
  Widget build(BuildContext context) {
    final type = plainText(
      module['module_type'] ?? module['card_type'],
    ).toLowerCase();
    final data = _saltModuleData(module);
    if (data == null) return const SizedBox.shrink();
    final shortcutItems = _saltStoryShortcutItems(data['items']);
    if (type == 'tab_nav' || _saltMapList(data['items']).isNotEmpty) {
      return _SaltShortcutRow(items: shortcutItems, onTap: onOpenShortcut);
    }
    return switch (type) {
      'vip_card' => _SaltMembershipCard(
        data: data,
        onTap: plainText(data['url']).isEmpty ? null : () => onOpenCard(data),
      ),
      'billboard' => _SaltBillboardModule(
        title: _saltModuleTitle(module, data),
        groups: _saltMapList(data['data']),
        onTap: onOpenCard,
      ),
      _ => _SaltContentModule(
        type: type,
        title: _saltModuleTitle(module, data),
        subtitle: plainText(data['sub_title']),
        cards: _saltMapList(data['content_list']),
        onTap: onOpenCard,
      ),
    };
  }
}

Map<String, dynamic>? _saltModuleData(Map<String, dynamic> module) {
  final moduleData = _saltMap(module['module_data']);
  if (moduleData == null) return null;
  return _saltMap(moduleData['data']) ?? moduleData;
}

String _saltModuleTitle(
  Map<String, dynamic> module,
  Map<String, dynamic> data,
) => plainText(module['module_title'] ?? data['title'] ?? module['title']);

List<Map<String, dynamic>> _saltMapList(Object? value) {
  if (value is! List) return const [];
  return value.map(_saltMap).whereType<Map<String, dynamic>>().toList();
}

class _SaltMembershipCard extends StatelessWidget {
  const _SaltMembershipCard({required this.data, this.onTap});

  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final title = plainText(data['title']);
    final subtitle = plainText(data['sub_title']);
    final button = plainText(data['button_text']);
    final iconUrl = plainText(data['icon']);
    final validIcon = Uri.tryParse(iconUrl)?.scheme == 'https';
    return ZhSurface(
      onTap: onTap,
      margin: const EdgeInsets.fromLTRB(
        ZhSpace.md,
        ZhSpace.sm,
        ZhSpace.md,
        ZhSpace.xs,
      ),
      radius: ZhRadius.hero,
      backgroundColor: ZhPalette.ink,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: validIcon
                ? Padding(
                    padding: const EdgeInsets.all(9),
                    child: ZhihuImage.network(
                      iconUrl,
                      headers: zhihuImageRequestHeaders,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.workspace_premium_outlined,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.workspace_premium_outlined,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '盐选会员' : title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          if (button.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(
              button,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ],
      ),
    );
  }
}

class _SaltShortcutRow extends StatelessWidget {
  const _SaltShortcutRow({required this.items, required this.onTap});

  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ZhSpace.md,
        ZhSpace.xs,
        ZhSpace.md,
        ZhSpace.sm,
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(
              child: _SaltShortcutButton(
                value: items[index],
                onTap: () => onTap(items[index]),
              ),
            ),
            if (index != items.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _SaltShortcutButton extends StatelessWidget {
  const _SaltShortcutButton({required this.value, required this.onTap});

  final Map<String, dynamic> value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = plainText(value['card_type']).toLowerCase();
    final title = titleOf(value);
    final artwork = plainText(value['artwork']);
    final validArtwork = Uri.tryParse(artwork)?.scheme == 'https';
    final icon = switch (type) {
      'bookshelf' => Icons.bookmarks_outlined,
      'category' => Icons.grid_view_rounded,
      'well' => Icons.auto_stories_outlined,
      _ => Icons.explore_outlined,
    };
    final iconColor = switch (type) {
      'bookshelf' => const Color(0xFF6655E8),
      'category' => const Color(0xFFFF9D00),
      'well' => const Color(0xFF16B59D),
      _ => ZhPalette.ink,
    };
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZhRadius.card),
        onTap: onTap,
        child: Container(
          height: 112,
          decoration: BoxDecoration(
            color: ZhPalette.canvas,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ZhPalette.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (validArtwork)
                ZhihuImage.network(
                  artwork,
                  headers: zhihuImageRequestHeaders,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      Icon(icon, size: 28, color: iconColor),
                )
              else
                Icon(icon, size: 28, color: iconColor),
              const SizedBox(height: 9),
              Text(
                title.isEmpty ? '入口' : title,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaltBillboardModule extends StatefulWidget {
  const _SaltBillboardModule({
    required this.title,
    required this.groups,
    required this.onTap,
  });

  final String title;
  final List<Map<String, dynamic>> groups;
  final ValueChanged<Map<String, dynamic>> onTap;

  @override
  State<_SaltBillboardModule> createState() => _SaltBillboardModuleState();
}

class _SaltBillboardModuleState extends State<_SaltBillboardModule> {
  int _selected = 0;
  bool _selectionInitialized = false;

  static const _supportedTypes = <String>{
    'hot',
    'reputation',
    'new_book',
    'well',
  };

  List<Map<String, dynamic>> _visibleGroups() {
    // Some older responses still include the generic "推荐榜" group. The
    // official story surface exposes the four named boards below, so keep
    // the server order while hiding that legacy duplicate when possible.
    final supported = widget.groups
        .where((group) {
          final type = plainText(
            _saltMap(group['head'])?['type'],
          ).trim().toLowerCase();
          return type.isEmpty || _supportedTypes.contains(type);
        })
        .toList(growable: false);
    return supported.isEmpty ? widget.groups : supported;
  }

  int _defaultIndex(List<Map<String, dynamic>> groups) {
    final hot = groups.indexWhere(
      (group) =>
          plainText(_saltMap(group['head'])?['type']).toLowerCase() == 'hot',
    );
    return hot >= 0 ? hot : 0;
  }

  String _groupLabel(Map<String, dynamic> group, int index) {
    final head = _saltMap(group['head']);
    final type = plainText(head?['type']).trim().toLowerCase();
    final title = plainText(head?['title']);
    if (title.isNotEmpty && type.isEmpty) return title;
    return switch (type) {
      'hot' => '热度榜',
      'reputation' => '口碑榜',
      'new_book' => '新书榜',
      'well' => '长篇榜',
      _ => title.isEmpty ? '榜单 ${index + 1}' : title,
    };
  }

  @override
  Widget build(BuildContext context) {
    final groups = _visibleGroups();
    if (groups.isEmpty) return const SizedBox.shrink();
    if (!_selectionInitialized || _selected >= groups.length) {
      _selected = _defaultIndex(groups);
      _selectionInitialized = true;
    }
    final selected = _selected.clamp(0, groups.length - 1);
    final group = groups[selected];
    final cards = _saltMapList(group['content_list']).take(12).toList();
    return ZhSurface(
      margin: const EdgeInsets.fromLTRB(
        ZhSpace.md,
        ZhSpace.sm,
        ZhSpace.md,
        ZhSpace.md,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      radius: ZhRadius.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.isEmpty ? '故事榜单' : widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < groups.length; index++) ...[
                  ChoiceChip(
                    selected: selected == index,
                    showCheckmark: false,
                    selectedColor: ZhPalette.ink,
                    backgroundColor: ZhPalette.canvas,
                    side: BorderSide(
                      color: selected == index
                          ? ZhPalette.ink
                          : ZhPalette.border,
                    ),
                    onSelected: (_) => setState(() => _selected = index),
                    label: Text(
                      _groupLabel(groups[index], index),
                      style: TextStyle(
                        color: selected == index
                            ? ZhPalette.background
                            : ZhPalette.ink,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (index != groups.length - 1) const SizedBox(width: 7),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 104,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) => _SaltRankTile(
              rank: index + 1,
              value: cards[index],
              onTap: () => widget.onTap(cards[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaltRankTile extends StatelessWidget {
  const _SaltRankTile({
    required this.rank,
    required this.value,
    required this.onTap,
  });

  final int rank;
  final Map<String, dynamic> value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artwork = plainText(value['artwork']);
    final validArtwork = Uri.tryParse(artwork)?.scheme == 'https';
    final label = plainText(value['label_text'] ?? value['subtitle']);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: validArtwork
                      ? ZhihuImage.network(
                          artwork,
                          headers: zhihuImageRequestHeaders,
                          width: 56,
                          height: 80,
                          fit: BoxFit.cover,
                          cacheWidth: saltStoryCoverCacheWidth,
                          errorBuilder: (_, _, _) => const SizedBox(
                            width: 56,
                            height: 80,
                            child: ColoredBox(color: ZhPalette.canvas),
                          ),
                        )
                      : const SizedBox(
                          width: 56,
                          height: 80,
                          child: ColoredBox(color: ZhPalette.canvas),
                        ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rank <= 3 ? ZhPalette.ink : ZhPalette.mutedInk,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(9),
                      bottomRight: Radius.circular(9),
                    ),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleOf(value),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaltContentModule extends StatelessWidget {
  const _SaltContentModule({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.cards,
    required this.onTap,
  });

  final String type;
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> cards;
  final ValueChanged<Map<String, dynamic>> onTap;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    final horizontal = type == 'today_read' || type == 'story_everyone_watch';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ZhSectionHeader(
          title: title.isEmpty ? _fallbackTitle(type) : title,
          description: subtitle.isEmpty ? null : subtitle,
        ),
        if (horizontal)
          SizedBox(
            height: 224,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: ZhSpace.md),
              itemCount: cards.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _SaltCoverTile(
                value: cards[index],
                onTap: () => onTap(cards[index]),
              ),
            ),
          )
        else
          for (final card in cards)
            SaltCatalogCard(
              value: card,
              coverWidth: 72,
              coverHeight: 100,
              onTap: () => onTap(card),
            ),
      ],
    );
  }

  String _fallbackTitle(String type) => switch (type) {
    'must_see' => '进站必看',
    'today_read' => '今日阅读',
    'story_everyone_watch' => '大家都在看',
    'feed_card' => '为你推荐',
    _ => '盐选故事',
  };
}
