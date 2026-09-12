import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../zh_theme.dart';

class ZhPrimaryButton extends StatelessWidget {
  const ZhPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final bool expand;

  @override
  Widget build(BuildContext context) => ShadButton(
    width: expand ? double.infinity : null,
    height: 48,
    enabled: onPressed != null,
    onPressed: onPressed,
    leading: leading ?? (icon == null ? null : Icon(icon, size: 18)),
    child: Text(label),
  );
}

class ZhOutlineButton extends StatelessWidget {
  const ZhOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final bool expand;

  @override
  Widget build(BuildContext context) => ShadButton.outline(
    width: expand ? double.infinity : null,
    height: 48,
    enabled: onPressed != null,
    onPressed: onPressed,
    leading: leading ?? (icon == null ? null : Icon(icon, size: 18)),
    child: Text(label),
  );
}

/// A compact, non-interactive footer used while a paged list preloads its
/// next response. Pagination is triggered by scroll position, so showing a
/// large action button here makes the list feel blocked and encourages repeat
/// taps. Keep a small footprint while idle so the next page can still be
/// requested when the list is shorter than the viewport.
class ZhPagingIndicator extends StatelessWidget {
  const ZhPagingIndicator({super.key, required this.loading, this.height = 52});

  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(
      child: loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const SizedBox.shrink(),
    ),
  );
}

class ZhGhostButton extends StatelessWidget {
  const ZhGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => ShadButton.ghost(
    enabled: onPressed != null,
    onPressed: onPressed,
    leading: icon == null ? null : Icon(icon, size: 18),
    child: Text(label),
  );
}

class ZhSectionHeader extends StatelessWidget {
  const ZhSectionHeader({
    super.key,
    required this.title,
    this.description,
    this.trailing,
  });

  final String title;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      ZhSpace.md,
      ZhSpace.lg,
      ZhSpace.md,
      ZhSpace.sm,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (description != null) ...[
                const SizedBox(height: ZhSpace.xxs),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class ZhPill extends StatelessWidget {
  const ZhPill({
    super.key,
    required this.label,
    this.inverted = false,
    this.compact = false,
  });

  final String label;
  final bool inverted;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 9 : 10,
      vertical: compact ? 3 : 5,
    ),
    decoration: BoxDecoration(
      color: inverted ? ZhPalette.ink : ZhPalette.canvas,
      border: Border.all(color: inverted ? ZhPalette.ink : ZhPalette.border),
      borderRadius: BorderRadius.circular(ZhRadius.pill),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: inverted ? ZhPalette.background : ZhPalette.mutedInk,
        fontSize: compact ? 10.5 : null,
      ),
    ),
  );
}
