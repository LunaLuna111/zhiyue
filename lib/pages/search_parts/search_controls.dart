part of '../search_page.dart';

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    this.focusNode,
    this.onChanged,
    this.autofocus = false,
    this.compact = false,
    this.inlineActions = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool compact;
  final bool inlineActions;

  @override
  Widget build(BuildContext context) => ZhLiquidGlassSearchField(
    key: const ValueKey('search-input'),
    controller: controller,
    focusNode: focusNode,
    hintText: hintText,
    autofocus: autofocus,
    compact: compact,
    inlineActions: inlineActions,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
  );
}

class _SearchChoice extends StatelessWidget {
  const _SearchChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static double rowHeight(BuildContext context) {
    // The horizontal viewport gives every choice a tight cross-axis extent.
    // Grow that extent with the effective label size so accessibility text is
    // not clipped, while preserving a Material-sized touch target at 1x.
    final scaledFontSize = MediaQuery.textScalerOf(context).scale(14);
    final contentHeight = scaledFontSize * 1.4 + 14;
    return contentHeight < 48 ? 48 : contentHeight;
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(ZhRadius.pill),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.center,
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? (ZhPalette.isDark ? ZhPalette.pressed : ZhPalette.ink)
            : ZhPalette.canvas,
        border: Border.all(
          color: selected
              ? (ZhPalette.isDark ? ZhPalette.softBorder : ZhPalette.ink)
              : ZhPalette.border,
        ),
        borderRadius: BorderRadius.circular(ZhRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected
              ? (ZhPalette.isDark ? ZhPalette.ink : ZhPalette.background)
              : ZhPalette.mutedInk,
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      if (trailing != null)
        Text(
          trailing!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ZhPalette.subtleInk,
            fontSize: 12,
          ),
        ),
    ],
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    decoration: BoxDecoration(
      color: ZhPalette.canvas,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(Icons.history_rounded, color: ZhPalette.subtleInk),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '搜索过的关键词会显示在这里',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
          ),
        ),
      ],
    ),
  );
}

class _SearchHotSection extends StatelessWidget {
  const _SearchHotSection({
    required this.items,
    required this.loading,
    required this.onSelected,
  });

  final List<SearchHotItem> items;
  final bool loading;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !loading) return const SizedBox.shrink();
    return Semantics(
      container: true,
      label: '热搜',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '热搜',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (loading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
            ),
          for (var index = 0; index < items.length; index++)
            Semantics(
              button: true,
              label: '热搜 ${items[index].displayQuery}',
              child: InkWell(
                key: ValueKey('search-hot:${items[index].query}'),
                onTap: () => onSelected(items[index].query),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: index < 3
                                    ? ZhPalette.ink
                                    : ZhPalette.subtleInk,
                                fontWeight: index < 3 ? FontWeight.w700 : null,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          items[index].displayQuery,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      if (items[index].hotShow.isNotEmpty ||
                          items[index].heatScore > 0)
                        Text(
                          items[index].hotShow.isNotEmpty
                              ? items[index].hotShow
                              : _formatHotScore(items[index].heatScore),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ZhPalette.subtleInk),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatHotScore(int score) {
    if (score < 10000) return '$score';
    final value = score / 10000;
    final text = value >= 100
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(value >= 10 ? 1 : 2);
    return '${text.replaceFirst(RegExp(r'\.0+$'), '')} 万';
  }
}

class _EmptySearchPrompt extends StatelessWidget {
  const _EmptySearchPrompt();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text(
      '请输入搜索内容',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
    ),
  );
}
