part of '../api_views.dart';

class _CardMetric extends StatelessWidget {
  const _CardMetric({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final metric = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: selected ? ZhPalette.accent : ZhPalette.subtleInk,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: selected ? ZhPalette.accent : ZhPalette.subtleInk,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 11.5,
            height: 1.2,
          ),
        ),
      ],
    );
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      excludeSemantics: true,
      child: onTap == null
          ? metric
          : InkWell(
              borderRadius: BorderRadius.circular(ZhRadius.pill),
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 38, minHeight: 34),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Center(child: metric),
                ),
              ),
            ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type, this.size = 42, this.circular = false});

  final String type;
  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      'answer' => Icons.question_answer_outlined,
      'article' => Icons.article_outlined,
      'people' || 'member' => Icons.person_outline,
      'question' => Icons.help_outline,
      'column' => Icons.view_column_outlined,
      'topic' => Icons.tag,
      'pin' => Icons.push_pin_outlined,
      _ => Icons.notes_rounded,
    };
    return ZhIconTile(
      icon: icon,
      size: size,
      iconSize: size * .48,
      circle: circular,
      radius: 12,
      borderColor: ZhPalette.border,
      borderWidth: 1,
    );
  }
}
