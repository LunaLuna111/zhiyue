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
