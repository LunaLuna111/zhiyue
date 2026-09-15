import 'package:flutter/material.dart';

import '../zh_theme.dart';

/// A value and the text shown by a shared choice field.
class ZhChoiceItem<T> {
  const ZhChoiceItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;
}

/// The common popup menu button used by page actions and row actions.
///
/// Flutter's stock popup menu is intentionally very generic. Keeping the
/// visual contract here means small menus do not grow different widths,
/// radii, shadows, or touch targets as pages evolve.
class ZhPopupMenuButton<T> extends StatelessWidget {
  const ZhPopupMenuButton({
    super.key,
    required this.itemBuilder,
    this.initialValue,
    this.onOpened,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.padding = const EdgeInsets.all(8),
    this.menuPadding,
    this.child,
    this.borderRadius,
    this.splashRadius,
    this.icon,
    this.iconSize,
    this.offset = Offset.zero,
    this.enabled = true,
    this.shape,
    this.color,
    this.iconColor,
    this.enableFeedback,
    this.constraints,
    this.position,
    this.clipBehavior = Clip.none,
    this.useRootNavigator = false,
    this.popUpAnimationStyle,
    this.routeSettings,
    this.style,
    this.requestFocus,
  });

  final PopupMenuItemBuilder<T> itemBuilder;
  final T? initialValue;
  final VoidCallback? onOpened;
  final PopupMenuItemSelected<T>? onSelected;
  final PopupMenuCanceled? onCanceled;
  final String? tooltip;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? menuPadding;
  final Widget? child;
  final BorderRadius? borderRadius;
  final double? splashRadius;
  final Widget? icon;
  final double? iconSize;
  final Offset offset;
  final bool enabled;
  final ShapeBorder? shape;
  final Color? color;
  final Color? iconColor;
  final bool? enableFeedback;
  final BoxConstraints? constraints;
  final PopupMenuPosition? position;
  final Clip clipBehavior;
  final bool useRootNavigator;
  final AnimationStyle? popUpAnimationStyle;
  final RouteSettings? routeSettings;
  final ButtonStyle? style;
  final bool? requestFocus;

  static const _defaultShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(ZhRadius.card)),
  );
  static const _defaultConstraints = BoxConstraints(
    minWidth: 216,
    maxWidth: 360,
  );
  static const _defaultPadding = EdgeInsets.symmetric(vertical: ZhSpace.xs);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuShape = shape ?? _defaultShape;
    final menuColor = color ?? theme.colorScheme.surface;
    final itemStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    return PopupMenuTheme(
      data: PopupMenuTheme.of(context).copyWith(
        color: menuColor,
        shape: menuShape,
        menuPadding: menuPadding ?? _defaultPadding,
        elevation: elevation ?? 8,
        shadowColor: shadowColor ?? const Color(0x26000000),
        surfaceTintColor: surfaceTintColor ?? Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(itemStyle),
      ),
      child: PopupMenuButton<T>(
        itemBuilder: itemBuilder,
        initialValue: initialValue,
        onOpened: onOpened,
        onSelected: onSelected,
        onCanceled: onCanceled,
        tooltip: tooltip,
        elevation: elevation ?? 8,
        shadowColor: shadowColor ?? const Color(0x26000000),
        surfaceTintColor: surfaceTintColor ?? Colors.transparent,
        padding: padding,
        menuPadding: menuPadding ?? _defaultPadding,
        borderRadius: borderRadius ?? BorderRadius.circular(ZhRadius.input),
        splashRadius: splashRadius,
        icon: icon,
        iconSize: iconSize,
        offset: offset,
        enabled: enabled,
        shape: menuShape,
        color: menuColor,
        iconColor: iconColor,
        enableFeedback: enableFeedback,
        constraints: constraints ?? _defaultConstraints,
        position: position,
        clipBehavior: clipBehavior,
        useRootNavigator: useRootNavigator,
        popUpAnimationStyle: popUpAnimationStyle,
        routeSettings: routeSettings,
        style: style,
        requestFocus: requestFocus,
        child: child,
      ),
    );
  }
}

/// A menu entry with the shared row height and horizontal rhythm.
class ZhMenuItem<T> extends PopupMenuItem<T> {
  ZhMenuItem({
    super.key,
    required T value,
    required String label,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    super.enabled = true,
  }) : super(
         value: value,
         height: subtitle == null ? 52 : 68,
         padding: const EdgeInsets.symmetric(horizontal: ZhSpace.md),
         child: _ZhMenuItemContent(
           label: label,
           subtitle: subtitle,
           leading: leading,
           trailing: trailing,
         ),
       );
}

class _ZhMenuItemContent extends StatelessWidget {
  const _ZhMenuItemContent({
    required this.label,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String label;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = subtitle == null
        ? Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );

    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: ZhSpace.sm)],
        Expanded(child: text),
        if (trailing != null) ...[const SizedBox(width: ZhSpace.sm), trailing!],
      ],
    );
  }
}

/// A styled field that opens the shared anchored menu instead of Flutter's
/// platform-default dropdown route.
class ZhChoiceField<T> extends StatefulWidget {
  const ZhChoiceField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.helperText,
    this.hintText = '请选择',
  });

  final String label;
  final T value;
  final List<ZhChoiceItem<T>> items;
  final ValueChanged<T>? onChanged;
  final bool enabled;
  final String? helperText;
  final String hintText;

  @override
  State<ZhChoiceField<T>> createState() => _ZhChoiceFieldState<T>();
}

class _ZhChoiceFieldState<T> extends State<ZhChoiceField<T>> {
  bool _menuOpen = false;

  ZhChoiceItem<T>? get _selectedItem {
    for (final item in widget.items) {
      if (item.value == widget.value) return item;
    }
    return null;
  }

  bool get _enabled => widget.enabled && widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedItem;
    final label = selected?.label ?? widget.hintText;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: '${widget.label}，$label',
      child: InkWell(
        key: const ValueKey('zh-choice-field-tap-target'),
        borderRadius: BorderRadius.circular(ZhRadius.input),
        onTap: _enabled ? _open : null,
        child: InputDecorator(
          isFocused: _menuOpen,
          isEmpty: selected == null,
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: widget.helperText,
            enabled: _enabled,
            suffixIcon: const Icon(Icons.expand_more_rounded),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: selected == null ? ZhPalette.subtleInk : ZhPalette.ink,
              fontWeight: selected == null ? null : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open() async {
    if (!_enabled || widget.items.isEmpty) return;
    setState(() => _menuOpen = true);
    final value = await showZhChoiceMenu<T>(
      context: context,
      anchorContext: context,
      semanticLabel: widget.label,
      selected: widget.value,
      items: widget.items,
    );
    if (!mounted) return;
    setState(() => _menuOpen = false);
    if (value != null && widget.onChanged != null) widget.onChanged!(value);
  }
}

/// Opens a consistently styled menu at [anchorContext].
Future<T?> showZhChoiceMenu<T>({
  required BuildContext context,
  required BuildContext anchorContext,
  required String semanticLabel,
  required List<ZhChoiceItem<T>> items,
  T? selected,
}) async {
  if (items.isEmpty) return null;
  final navigator = Navigator.of(context);
  final overlay = navigator.overlay;
  final anchor = anchorContext.findRenderObject();
  final overlayBox = overlay?.context.findRenderObject();
  if (overlay == null || anchor is! RenderBox || overlayBox is! RenderBox) {
    return null;
  }

  final topLeft = anchor.localToGlobal(Offset.zero, ancestor: overlayBox);
  final bottomRight = anchor.localToGlobal(
    anchor.size.bottomRight(Offset.zero),
    ancestor: overlayBox,
  );
  final anchorRect = Rect.fromPoints(topLeft, bottomRight);
  final overlaySize = overlayBox.size;
  final availableWidth = (overlaySize.width - 16).clamp(1.0, double.infinity);
  final desiredWidth = anchorRect.width < 216 ? 216.0 : anchorRect.width;
  final menuWidth = desiredWidth > availableWidth
      ? availableWidth
      : desiredWidth;
  final position = RelativeRect.fromLTRB(
    anchorRect.left,
    anchorRect.bottom + 4,
    overlaySize.width - anchorRect.right,
    overlaySize.height - anchorRect.bottom,
  );

  return showMenu<T>(
    context: context,
    position: position,
    initialValue: selected,
    semanticLabel: semanticLabel,
    color: Theme.of(context).colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shadowColor: const Color(0x26000000),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(ZhRadius.card)),
    ),
    menuPadding: const EdgeInsets.symmetric(vertical: ZhSpace.xs),
    constraints: BoxConstraints(
      minWidth: menuWidth,
      maxWidth: menuWidth,
      maxHeight: overlaySize.height * .6,
    ),
    items: [
      for (final item in items)
        PopupMenuItem<T>(
          value: item.value,
          enabled: item.enabled,
          height: item.subtitle == null ? 52 : 68,
          padding: const EdgeInsets.symmetric(horizontal: ZhSpace.md),
          child: _ZhChoiceMenuItemContent(
            item: item,
            selected: item.value == selected,
          ),
        ),
    ],
  );
}

class _ZhChoiceMenuItemContent<T> extends StatelessWidget {
  const _ZhChoiceMenuItemContent({required this.item, required this.selected});

  final ZhChoiceItem<T> item;
  final bool selected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (item.icon != null) ...[
        Icon(item.icon, size: 20),
        const SizedBox(width: ZhSpace.sm),
      ],
      Expanded(
        child: item.subtitle == null
            ? Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
      ),
      if (selected) ...[
        const SizedBox(width: ZhSpace.sm),
        const Icon(Icons.check_rounded, size: 20),
      ],
    ],
  );
}
