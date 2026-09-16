import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../zh_theme.dart';

/// The floating iOS 26-style channel switcher used by the compact home feed.
///
/// The tab track and the menu control intentionally own separate glass
/// surfaces. This keeps the controls readable on the mostly-white feed while
/// avoiding nested refractive layers that can wash out the active lens.
class ZhLiquidGlassTopNavigation extends StatelessWidget
    implements PreferredSizeWidget {
  const ZhLiquidGlassTopNavigation({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onMenuPressed,
  }) : assert(labels.length > 0);

  static const double barHeight = 64;

  static const LiquidGlassSettings _tabGlassSettings = LiquidGlassSettings(
    thickness: 28,
    blur: 10,
    chromaticAberration: .18,
    lightIntensity: .65,
    refractiveIndex: 1.52,
    saturation: .9,
    ambientStrength: .8,
    // A neutral frost remains visible over the feed's white cards while the
    // shader still samples and refracts the content underneath.
    glassColor: Color(0xA6F8F8FA),
  );

  static const LiquidGlassSettings _menuGlassSettings = LiquidGlassSettings(
    thickness: 30,
    blur: 10,
    chromaticAberration: .18,
    lightIntensity: .65,
    refractiveIndex: 1.52,
    saturation: .9,
    ambientStrength: .8,
    glassColor: Color(0xA6F8F8FA),
  );

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onMenuPressed;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    final safeIndex = selectedIndex.clamp(0, labels.length - 1);
    final tabs = [
      for (final label in labels) GlassTab(label: label, semanticLabel: label),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final tabBar = GlassTabBar.inline(
          key: const ValueKey('zh-liquid-glass-feed-tabs'),
          tabs: tabs,
          selectedIndex: safeIndex,
          onTabSelected: onTabSelected,
          barHeight: 46,
          horizontalPadding: 4,
          verticalPadding: 0,
          spacing: 2,
          tabPadding: const EdgeInsets.symmetric(horizontal: 8),
          indicatorExpansion: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          indicatorBorderRadius: 22,
          indicatorColor: const Color(0x1C000000),
          indicatorPinchStrength: .18,
          selectedLabelStyle: const TextStyle(
            color: ZhPalette.ink,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          unselectedLabelStyle: const TextStyle(
            color: ZhPalette.mutedInk,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          settings: _tabGlassSettings,
          quality: GlassQuality.premium,
          backgroundQuality: GlassQuality.premium,
          interactionBehavior: GlassInteractionBehavior.scaleOnly,
          pressScale: 1.01,
          glowOpacity: 0,
          glowBlurRadius: 0,
          glowSpreadRadius: 0,
          interactionGlowColor: Colors.transparent,
          interactionGlowRadius: 0,
        );

        final constrainedTabs = desktop
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: tabBar,
              )
            : tabBar;

        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          child: Row(
            children: [
              if (onMenuPressed != null) ...[
                Semantics(
                  button: true,
                  label: '打开侧边栏',
                  child: GlassIconButton(
                    key: const ValueKey('home-drawer-button'),
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: onMenuPressed,
                    semanticLabel: '打开侧边栏',
                    size: 48,
                    iconSize: 23,
                    shape: GlassIconButtonShape.roundedSquare,
                    borderRadius: 17,
                    useOwnLayer: true,
                    settings: _menuGlassSettings,
                    quality: GlassQuality.premium,
                    glowColor: Colors.transparent,
                    glowRadius: 0,
                    interactionScale: .98,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: constrainedTabs,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
