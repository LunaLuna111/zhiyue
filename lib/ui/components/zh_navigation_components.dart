import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

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

  // The upstream bar preset is intentionally subtle.  The client uses a
  // white content surface, so its default 24% white tint can disappear into
  // the page unless the backdrop has strong contrast.  Keep the same
  // polycarbonate refraction profile while giving the chrome a slightly
  // denser frost and a visible specular edge.
  static const LiquidGlassSettings _barGlassSettings = LiquidGlassSettings(
    thickness: 34,
    blur: 5,
    chromaticAberration: .35,
    lightIntensity: .7,
    refractiveIndex: 1.59,
    saturation: .85,
    ambientStrength: .85,
    glassColor: Color(0x55FFFFFF),
  );

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Size get preferredSize =>
      const Size.fromHeight(_barHeight + _verticalPadding * 2);

  @override
  Widget build(BuildContext context) {
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

    return GlassTabBar.bottom(
      key: const ValueKey('zh-liquid-glass-bottom-navigation'),
      tabs: tabs,
      selectedIndex: safeIndex,
      onTabSelected: onDestinationSelected,
      barHeight: _barHeight,
      verticalPadding: _verticalPadding,
      horizontalPadding: 20,
      spacing: 8,
      tabPadding: const EdgeInsets.symmetric(horizontal: 4),
      barBorderRadius: 32,
      iconLabelSpacing: 4,
      iconSize: 24,
      labelFontSize: 11,
      settings: _barGlassSettings,
      quality: GlassQuality.premium,
      backgroundQuality: GlassQuality.premium,
      // A slightly stronger neutral lens keeps the selected tab legible on
      // white pages without returning to the opaque black pill.
      indicatorColor: Color(0x24000000),
      // Keep the native press scale, but omit the directional flash. On a
      // white feed the default full interaction glow washes out the lens
      // exactly while it is moving, making the glass harder to read.
      interactionBehavior: GlassInteractionBehavior.scaleOnly,
      pressScale: 1.02,
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
  static const LiquidGlassSettings _settings = LiquidGlassSettings(
    thickness: 34,
    blur: 3,
    chromaticAberration: .3,
    lightIntensity: .65,
    refractiveIndex: 1.59,
    saturation: .86,
    ambientStrength: .92,
    glassColor: Color(0x5CFFFFFF),
  );

  static const LiquidGlassSettings _indicatorSettings = LiquidGlassSettings(
    thickness: 38,
    blur: 2,
    chromaticAberration: .28,
    lightIntensity: .82,
    refractiveIndex: 1.5,
    saturation: 1,
    ambientStrength: .95,
    glassColor: Color(0x66FFFFFF),
  );

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
    final tabs = [
      for (final item in widget.items)
        GlassTab(
          icon: item.icon,
          activeIcon: item.activeIcon ?? item.icon,
          label: item.label,
          semanticLabel: item.semanticLabel,
        ),
    ];
    final glassBar = GlassTabBar.bottom(
      key: const ValueKey('zh-liquid-glass-detail-action-bar'),
      tabs: tabs,
      selectedIndex: _selectedIndex,
      onTabSelected: _select,
      barHeight: 64,
      verticalPadding: 12,
      horizontalPadding: 0,
      spacing: 4,
      tabPadding: const EdgeInsets.symmetric(horizontal: 2),
      iconLabelSpacing: 3,
      iconSize: 22,
      labelFontSize: 11,
      settings: _settings,
      indicatorSettings: _indicatorSettings,
      quality: GlassQuality.premium,
      backgroundQuality: GlassQuality.standard,
      indicatorColor: const Color(0x2E000000),
      indicatorPinchStrength: .28,
      indicatorExpansion: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      maskingQuality: MaskingQuality.high,
      interactionBehavior: GlassInteractionBehavior.scaleOnly,
      pressScale: 1.02,
      glowOpacity: 0,
      glowBlurRadius: 0,
      glowSpreadRadius: 0,
      interactionGlowColor: Colors.transparent,
      interactionGlowRadius: 0,
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
