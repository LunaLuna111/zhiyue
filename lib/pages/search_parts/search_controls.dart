part of '../search_page.dart';

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.compact = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String> onSubmitted;
  final bool autofocus;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    height: compact ? 48 : 52,
    decoration: BoxDecoration(
      color: ZhPalette.canvas,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: ZhPalette.border),
    ),
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search_rounded, size: 22),
        suffixIcon: IconButton(
          tooltip: '搜索',
          onPressed: () => onSubmitted(controller.text),
          icon: const Icon(Icons.arrow_forward_rounded, size: 21),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: compact ? 12 : 14),
      ),
    ),
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
        color: selected ? ZhPalette.ink : ZhPalette.canvas,
        border: Border.all(color: selected ? ZhPalette.ink : ZhPalette.border),
        borderRadius: BorderRadius.circular(ZhRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected ? ZhPalette.background : ZhPalette.mutedInk,
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing, this.action});

  final String title;
  final String? trailing;
  final Widget? action;

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
      ?action,
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
        const Icon(Icons.history_rounded, color: ZhPalette.subtleInk),
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

class _InputAction extends StatelessWidget {
  const _InputAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: '打开',
    onPressed: onPressed,
    icon: const Icon(Icons.arrow_forward_rounded),
  );
}

class _ToolTitle extends StatelessWidget {
  const _ToolTitle({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 22),
      const SizedBox(width: ZhSpace.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(description, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}
