import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../zh_theme.dart';

class ZhSurface extends StatefulWidget {
  const ZhSurface({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(ZhSpace.md),
    this.margin = EdgeInsets.zero,
    this.radius = ZhRadius.card,
    this.backgroundColor = ZhPalette.background,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final Color backgroundColor;

  @override
  State<ZhSurface> createState() => _ZhSurfaceState();
}

class _ZhSurfaceState extends State<ZhSurface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final card = ShadCard(
      width: double.infinity,
      padding: widget.padding,
      radius: BorderRadius.circular(widget.radius),
      backgroundColor: widget.backgroundColor,
      shadows: const [],
      child: widget.child,
    );
    final interactive = widget.onTap != null;
    final decoratedCard = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: _hovered && interactive
            ? const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: card,
    );
    final interactiveCard = interactive
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => _setHovered(true),
            onExit: (_) => _setHovered(false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: decoratedCard,
            ),
          )
        : decoratedCard;
    return Padding(
      padding: widget.margin,
      child: Semantics(button: interactive, child: interactiveCard),
    );
  }

  void _setHovered(bool value) {
    if (mounted && _hovered != value) setState(() => _hovered = value);
  }
}

/// A Material-native bordered panel for list rows and compact settings cards.
///
/// `ZhSurface` is backed by shadcn and is ideal for content cards that need
/// hover feedback. This lighter primitive is intended for the many small
/// panels that only need the application's shared fill, border and radius.
class ZhPanel extends StatelessWidget {
  const ZhPanel({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(ZhSpace.md),
    this.margin = EdgeInsets.zero,
    this.radius = ZhRadius.card,
    this.backgroundColor = ZhPalette.background,
    this.borderColor = ZhPalette.border,
    this.borderWidth = 1,
    this.elevation = 0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: borderColor == null || borderWidth <= 0
          ? BorderSide.none
          : BorderSide(color: borderColor!, width: borderWidth),
    );
    return Padding(
      padding: margin,
      child: Material(
        color: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? Padding(padding: padding, child: child)
            : InkWell(
                onTap: onTap,
                customBorder: shape,
                child: Padding(padding: padding, child: child),
              ),
      ),
    );
  }
}

/// A shared icon tile used by history rows, empty states and settings cards.
///
/// The tile exposes only visual parameters. Navigation and actions stay on
/// the surrounding widget, preventing duplicated gesture semantics when it
/// is embedded in a row.
class ZhIconTile extends StatelessWidget {
  const ZhIconTile({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize = 21,
    this.backgroundColor = ZhPalette.canvas,
    this.iconColor = ZhPalette.ink,
    this.radius = 14,
    this.circle = false,
    this.borderColor,
    this.borderWidth = 0,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final double radius;
  final bool circle;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
        border: borderColor == null || borderWidth <= 0
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    ),
  );
}
