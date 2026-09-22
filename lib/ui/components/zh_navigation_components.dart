import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../zh_glass.dart';
import '../zh_theme.dart';

/// Shared visual tokens for every action/navigation tab bar in the client.
///
/// Pages provide only their tab data and callbacks. The selected foreground,
/// neutral moving lens, capsule geometry and interaction glow stay here so a
/// press has the same feedback on the home bar and on detail-page actions.
abstract final class ZhLiquidGlassNavigationStyle {
  static const selectedColor = Color(0xFF1677FF);
  static const unselectedColor = Color(0xCC202733);
  static const indicatorColor = Color(0x42000000);
  static const interactionGlowColor = Color(0x260A6FFF);
  static const capsuleRadius = GlassDefaults.capsuleRadius;

  static const barSettings = LiquidGlassSettings(
    thickness: 30,
    blur: 4,
    chromaticAberration: .42,
    lightIntensity: .5,
    refractiveIndex: 1.59,
    saturation: .8,
    ambientStrength: .72,
    glassColor: Color(0x4AFFFFFF),
    specularSharpness: GlassSpecularSharpness.soft,
  );

  static const indicatorSettings = LiquidGlassSettings(
    thickness: 42,
    blur: 4,
    chromaticAberration: .52,
    lightIntensity: .24,
    refractiveIndex: 1.59,
    saturation: .95,
    ambientStrength: .35,
    ambientRim: .12,
    fresnelStrength: 1.05,
    edgeAbsorption: .25,
    bodyMode: GlassBodyMode.clear,
    glassColor: Color(0x702F343D),
    specularSharpness: GlassSpecularSharpness.soft,
  );
}

/// The iOS 26-style floating navigation used on phones and narrow windows.
///
/// [GlassTabBar.bottom] owns the complete visual treatment: the floating glass
/// platter, animated selection lens, icon/label layout and touch animation.
/// The app keeps [NavigationDestination] at its boundary so existing page
/// selection and accessibility labels continue to work.
class ZhLiquidGlassBottomNavigation extends StatelessWidget
    implements PreferredSizeWidget {
  const ZhLiquidGlassBottomNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : assert(destinations.length > 0);

  // These are the defaults used by the library's bottom-bar demo. Keeping
  // them explicit also keeps this wrapper's preferred size in sync with the
  // rendered glass bar when the app is built inside a Scaffold.
  static const double _barHeight = 64;
  static const double _verticalPadding = 20;

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Size get preferredSize =>
      const Size.fromHeight(_barHeight + _verticalPadding * 2);

  @override
  Widget build(BuildContext context) {
    if (!ZhGlassScope.enabledOf(context)) {
      return _ZhPlainBottomNavigation(
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      );
    }
    final tabs = [
      for (final destination in destinations)
        GlassTab(
          icon: destination.icon,
          activeIcon: destination.selectedIcon,
          label: destination.label,
          semanticLabel: destination.label,
        ),
    ];
    final safeIndex = selectedIndex.clamp(0, tabs.length - 1);

    return _ZhReleaseActivatedGlassTabBar(
      tabCount: tabs.length,
      horizontalPadding: 20,
      verticalPadding: _verticalPadding,
      barHeight: _barHeight,
      onTabSelected: onDestinationSelected,
      childBuilder: (handleTabSelected) => GlassTabBar.bottom(
        key: const ValueKey('zh-liquid-glass-bottom-navigation'),
        tabs: tabs,
        selectedIndex: safeIndex,
        onTabSelected: handleTabSelected,
        barHeight: _barHeight,
        verticalPadding: _verticalPadding,
        horizontalPadding: 20,
        spacing: 8,
        tabPadding: const EdgeInsets.symmetric(horizontal: 4),
        barBorderRadius: ZhLiquidGlassNavigationStyle.capsuleRadius,
        iconLabelSpacing: 4,
        iconSize: 24,
        labelFontSize: 11,
        settings: ZhLiquidGlassNavigationStyle.barSettings,
        indicatorSettings: ZhLiquidGlassNavigationStyle.indicatorSettings,
        // The home bar is visible underneath every pushed route during
        // predictive back. Both layers must stay on the lightweight shader;
        // premium texture capture here makes the returning route redraw the
        // whole feed and glass platter together.
        quality: GlassQuality.standard,
        backgroundQuality: GlassQuality.standard,
        // The package's lightweight path places its full selected-tab row
        // inside one fractional tab slot, which shifts the blue icon/label
        // toward the slot's leading edge. Keep the standard glass quality,
        // but use the correctly aligned mask layout for the selected layer.
        maskingQuality: MaskingQuality.high,
        // The package's selected layer follows the animated lens while it
        // moves, so the active icon and label become blue before the spring
        // settles instead of waiting for a separate page repaint.
        selectedIconColor: ZhLiquidGlassNavigationStyle.selectedColor,
        unselectedIconColor: ZhLiquidGlassNavigationStyle.unselectedColor,
        selectedLabelColor: ZhLiquidGlassNavigationStyle.selectedColor,
        unselectedLabelColor: ZhLiquidGlassNavigationStyle.unselectedColor,
        indicatorColor: ZhLiquidGlassNavigationStyle.indicatorColor,
        indicatorBorderRadius: ZhLiquidGlassNavigationStyle.capsuleRadius,
        // The lightweight indicator path keeps the unselected icon layer
        // visible beneath the selected layer. Do not magnify the selected
        // icon here: the default 1.15 scale makes the blue active glyph
        // visibly drift from the original icon bounds.
        magnification: 1.0,
        indicatorPinchStrength: .46,
        indicatorExpansion: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        interactionGlowColor: ZhLiquidGlassNavigationStyle.interactionGlowColor,
        // Keep the package's complete press treatment so each destination
        // gets the same spring, stretch and touch-reactive glass as toolbar
        // buttons.
        interactionBehavior: GlassInteractionBehavior.full,
        pressScale: 1.02,
      ),
    );
  }
}

/// A detail-page action item rendered by the package-owned liquid indicator.
class ZhLiquidGlassActionItem {
  const ZhLiquidGlassActionItem({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    this.activeIcon,
    this.onPressed,
  });

  final Widget icon;
  final Widget? activeIcon;
  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;
}

/// Gates a package tab callback until the pointer is released inside the tab
/// that the package resolved. The upstream bottom bar intentionally selects on
/// pointer-down for its default native mode; the app's navigation should not
/// leave a page as soon as a finger merely touches it.
class _ZhReleaseActivatedGlassTabBar extends StatefulWidget {
  const _ZhReleaseActivatedGlassTabBar({
    required this.tabCount,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.barHeight,
    required this.onTabSelected,
    required this.childBuilder,
  }) : assert(tabCount > 0);

  final int tabCount;
  final double horizontalPadding;
  final double verticalPadding;
  final double barHeight;
  final ValueChanged<int> onTabSelected;
  final Widget Function(ValueChanged<int> onTabSelected) childBuilder;

  @override
  State<_ZhReleaseActivatedGlassTabBar> createState() =>
      _ZhReleaseActivatedGlassTabBarState();
}

class _ZhReleaseActivatedGlassTabBarState
    extends State<_ZhReleaseActivatedGlassTabBar> {
  int? _pendingIndex;
  var _pointerActive = false;
  var _pointerCancelled = false;
  var _pointerGeneration = 0;

  int? _tabIndexAt(Offset globalPosition) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final local = renderObject.globalToLocal(globalPosition);
    final left = widget.horizontalPadding;
    final right = renderObject.size.width - widget.horizontalPadding;
    final top = widget.verticalPadding;
    final bottom = top + widget.barHeight;
    if (right <= left ||
        local.dx < left ||
        local.dx >= right ||
        local.dy < top ||
        local.dy >= bottom) {
      return null;
    }
    final fraction = ((local.dx - left) / (right - left)).clamp(0.0, .999999);
    return (fraction * widget.tabCount).floor();
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerGeneration++;
    _pointerActive = true;
    _pointerCancelled = false;
    _pendingIndex = null;
  }

  void _onPackageTabSelected(int index) {
    if (_pointerActive) {
      if (!_pointerCancelled) _pendingIndex = index;
      return;
    }
    // Keyboard and screen-reader activation has no pointer lifecycle. Keep
    // those activations immediate and accessible.
    widget.onTabSelected(index);
  }

  void _finishPointer(Offset position) {
    if (!_pointerActive) return;
    final pending = _pendingIndex;
    final releaseIndex = _tabIndexAt(position);
    _pointerActive = false;
    _pointerCancelled = false;
    _pendingIndex = null;
    if (pending != null && releaseIndex == pending) {
      widget.onTabSelected(pending);
    }
  }

  void _schedulePointerFinish(Offset position) {
    final generation = _pointerGeneration;
    // The package's raw pointer listener runs before its gesture recognizer.
    // Defer the gate until the current pointer event has finished dispatching
    // so drag/tap resolution is captured while [_pointerActive] is still true.
    Future<void>.microtask(() {
      if (!mounted ||
          !_pointerActive ||
          _pointerCancelled ||
          generation != _pointerGeneration) {
        return;
      }
      _finishPointer(position);
    });
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_pointerActive) return;
    _pointerCancelled = true;
    final generation = _pointerGeneration;
    // Keep the cancelled pointer active for the rest of this dispatch. If the
    // package resolves a drag during the same event, its callback is discarded
    // rather than being forwarded as an accidental selection.
    Future<void>.microtask(() {
      if (!mounted || !_pointerActive || generation != _pointerGeneration) {
        return;
      }
      _pointerActive = false;
      _pointerCancelled = false;
      _pendingIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: _onPointerDown,
    onPointerUp: (event) => _schedulePointerFinish(event.position),
    onPointerCancel: _onPointerCancel,
    child: widget.childBuilder(_onPackageTabSelected),
  );
}

class _ZhPlainBottomNavigation extends StatelessWidget
    implements PreferredSizeWidget {
  const _ZhPlainBottomNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Size get preferredSize => const Size.fromHeight(104);

  @override
  Widget build(BuildContext context) {
    final safeIndex = selectedIndex.clamp(0, destinations.length - 1).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Material(
        color: ZhPalette.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: ZhPalette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: _ZhPlainBottomNavigationItem(
                    destination: destinations[index],
                    selected: index == safeIndex,
                    onPressed: () => onDestinationSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZhPlainBottomNavigationItem extends StatelessWidget {
  const _ZhPlainBottomNavigationItem({
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  final NavigationDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = selected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;
    final foreground = selected
        ? ZhLiquidGlassNavigationStyle.selectedColor
        : ZhLiquidGlassNavigationStyle.unselectedColor;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      onTap: onPressed,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 54,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE1E3E8) : Colors.transparent,
              borderRadius: BorderRadius.circular(27),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTheme(
                  data: IconThemeData(color: foreground, size: 24),
                  child: icon,
                ),
                const SizedBox(height: 2),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A floating, draggable glass action bar for detail pages.
///
/// [GlassTabBar.bottom] supplies the un-clipped spring indicator and the
/// package-owned tap/drag interaction while the caller retains independent
/// callbacks for each action.
class ZhLiquidGlassFloatingActionBar extends StatefulWidget {
  const ZhLiquidGlassFloatingActionBar({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.trailing,
    this.transitionKey = 'default',
  }) : assert(items.length > 0);

  final List<ZhLiquidGlassActionItem> items;
  final int initialIndex;
  final Widget? trailing;

  /// Changes when the bar switches between distinct action sets. The key
  /// lets the wrapper animate the whole glass surface while the package keeps
  /// ownership of the indicator's spring interaction inside each surface.
  final String transitionKey;

  @override
  State<ZhLiquidGlassFloatingActionBar> createState() =>
      _ZhLiquidGlassFloatingActionBarState();
}

class _ZhLiquidGlassFloatingActionBarState
    extends State<ZhLiquidGlassFloatingActionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _modeTransitionController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _modeTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      value: 1,
    );
    _selectedIndex = _safeIndex(widget.initialIndex, widget.items.length);
  }

  @override
  void didUpdateWidget(covariant ZhLiquidGlassFloatingActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _selectedIndex = _safeIndex(_selectedIndex, widget.items.length);
    }
    if (oldWidget.transitionKey != widget.transitionKey) {
      _modeTransitionController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _modeTransitionController.dispose();
    super.dispose();
  }

  int _safeIndex(int index, int length) => index.clamp(0, length - 1).toInt();

  void _select(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
    widget.items[index].onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!ZhGlassScope.enabledOf(context)) {
      final plainBar = _ZhPlainFloatingActionBar(
        items: widget.items,
        selectedIndex: _selectedIndex,
        onSelected: _select,
      );
      if (widget.trailing == null) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: plainBar,
        );
      }
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: SizedBox(
          height: 88,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: plainBar),
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ),
        ),
      );
    }
    final tabs = [
      for (final item in widget.items)
        GlassTab(
          icon: item.icon,
          activeIcon: item.activeIcon ?? item.icon,
          label: item.label,
          semanticLabel: item.semanticLabel,
        ),
    ];
    final glassBar = _ZhReleaseActivatedGlassTabBar(
      tabCount: tabs.length,
      horizontalPadding: 0,
      verticalPadding: 12,
      barHeight: 64,
      onTabSelected: _select,
      childBuilder: (handleTabSelected) => GlassTabBar.bottom(
        key: const ValueKey('zh-liquid-glass-detail-action-bar'),
        tabs: tabs,
        selectedIndex: _selectedIndex,
        onTabSelected: handleTabSelected,
        barHeight: 64,
        verticalPadding: 12,
        horizontalPadding: 0,
        spacing: 4,
        tabPadding: const EdgeInsets.symmetric(horizontal: 2),
        iconLabelSpacing: 3,
        iconSize: 22,
        labelFontSize: 11,
        settings: ZhLiquidGlassNavigationStyle.barSettings,
        indicatorSettings: ZhLiquidGlassNavigationStyle.indicatorSettings,
        // Detail pages are frequently transformed during back navigation.
        // Standard keeps the same liquid surface while avoiding a premium
        // backdrop capture on every gesture frame.
        quality: GlassQuality.standard,
        backgroundQuality: GlassQuality.standard,
        selectedIconColor: ZhLiquidGlassNavigationStyle.selectedColor,
        unselectedIconColor: ZhLiquidGlassNavigationStyle.unselectedColor,
        selectedLabelColor: ZhLiquidGlassNavigationStyle.selectedColor,
        unselectedLabelColor: ZhLiquidGlassNavigationStyle.unselectedColor,
        indicatorColor: ZhLiquidGlassNavigationStyle.indicatorColor,
        indicatorBorderRadius: ZhLiquidGlassNavigationStyle.capsuleRadius,
        indicatorPinchStrength: .28,
        indicatorExpansion: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 7,
        ),
        // The lightweight path has the same fractional selected-row layout
        // bug as the home bar. The aligned mask is limited to this small
        // action surface and keeps predictive-back icon positions correct.
        maskingQuality: MaskingQuality.high,
        interactionGlowColor: ZhLiquidGlassNavigationStyle.interactionGlowColor,
        interactionBehavior: GlassInteractionBehavior.full,
        pressScale: 1.02,
      ),
    );
    final animatedGlassBar = AnimatedBuilder(
      animation: _modeTransitionController,
      child: glassBar,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(
          _modeTransitionController.value,
        );
        return Opacity(
          opacity: .84 + (.16 * progress),
          child: Transform.scale(
            scale: .96 + (.04 * progress),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
    if (widget.trailing == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: animatedGlassBar,
      );
    }
    // Keep the mode toggle outside the animated subtree so its semantic
    // label and hit target change immediately while the glass tabs crossfade.
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: SizedBox(
        height: 88,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: animatedGlassBar),
            const SizedBox(width: 8),
            widget.trailing!,
          ],
        ),
      ),
    );
  }
}

class _ZhPlainFloatingActionBar extends StatelessWidget {
  const _ZhPlainFloatingActionBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ZhLiquidGlassActionItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final safeIndex = selectedIndex.clamp(0, items.length - 1).toInt();
    return Material(
      color: ZhPalette.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: ZhPalette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: index == safeIndex,
                  label: items[index].semanticLabel,
                  onTap: () => onSelected(index),
                  child: InkWell(
                    onTap: () => onSelected(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconTheme(
                            data: IconThemeData(
                              size: 22,
                              color: index == safeIndex
                                  ? ZhLiquidGlassNavigationStyle.selectedColor
                                  : ZhLiquidGlassNavigationStyle
                                        .unselectedColor,
                            ),
                            child: index == safeIndex
                                ? (items[index].activeIcon ?? items[index].icon)
                                : items[index].icon,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[index].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: index == safeIndex
                                  ? ZhLiquidGlassNavigationStyle.selectedColor
                                  : ZhLiquidGlassNavigationStyle
                                        .unselectedColor,
                              fontSize: 11,
                              fontWeight: index == safeIndex
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
