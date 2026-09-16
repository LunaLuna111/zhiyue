import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../zh_theme.dart';

/// A circular iOS 26-style glass control for navigation and toolbar actions.
class ZhLiquidGlassIconButton extends StatelessWidget {
  const ZhLiquidGlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.size = 44,
    this.iconSize,
    this.shape = GlassIconButtonShape.circle,
    this.borderRadius = 16,
  });

  static const LiquidGlassSettings _settings = LiquidGlassSettings(
    thickness: 30,
    blur: 10,
    chromaticAberration: .18,
    lightIntensity: .65,
    refractiveIndex: 1.52,
    saturation: .9,
    ambientStrength: .8,
    glassColor: Color(0xA6F8F8FA),
  );

  final Widget icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final double size;
  final double? iconSize;
  final GlassIconButtonShape shape;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => GlassIconButton(
    icon: icon,
    onPressed: onPressed,
    semanticLabel: semanticLabel,
    size: size,
    iconSize: iconSize,
    shape: shape,
    borderRadius: borderRadius,
    useOwnLayer: true,
    settings: _settings,
    quality: GlassQuality.premium,
    glowColor: Colors.transparent,
    glowRadius: 0,
    interactionScale: .98,
  );
}

/// A single connected iOS 26 capsule for compact toolbar actions.
class ZhLiquidGlassCapsuleAction {
  const ZhLiquidGlassCapsuleAction({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
}

/// A shared icon-only action group for detail-page top bars.
///
/// [GlassButtonGroup] owns the shared glass surface and the individual hit
/// targets, keeping adjacent actions connected without merging their
/// accessibility labels.
class ZhLiquidGlassCapsuleActionGroup extends StatelessWidget {
  const ZhLiquidGlassCapsuleActionGroup({super.key, required this.actions})
    : assert(actions.length > 0);

  static const LiquidGlassSettings _settings = LiquidGlassSettings(
    thickness: 30,
    blur: 6,
    chromaticAberration: .24,
    lightIntensity: .7,
    refractiveIndex: 1.56,
    saturation: .92,
    ambientStrength: .9,
    glassColor: Color(0xB8F8F8FA),
  );

  final List<ZhLiquidGlassCapsuleAction> actions;

  @override
  Widget build(BuildContext context) => GlassButtonGroup.icons(
    key: key,
    items: [
      for (final action in actions)
        GlassButtonGroupItem(
          icon: action.icon,
          label: action.semanticLabel,
          enabled: action.onPressed != null,
          onTap: action.onPressed ?? _disabledAction,
        ),
    ],
    borderRadius: 28,
    itemPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
    iconSize: 22,
    settings: _settings,
    quality: GlassQuality.premium,
    useOwnLayer: true,
    showDividers: false,
  );

  static void _disabledAction() {}
}

/// A shared rounded search field used by the search landing and result pages.
///
/// Keeping the controller callbacks here prevents the two search surfaces from
/// drifting apart while preserving the page-owned suggestion and submit state.
class ZhLiquidGlassSearchField extends StatelessWidget {
  const ZhLiquidGlassSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    this.focusNode,
    this.onChanged,
    this.autofocus = false,
    this.compact = false,
  });

  static const LiquidGlassSettings _settings = LiquidGlassSettings(
    thickness: 24,
    blur: 11,
    chromaticAberration: .14,
    lightIntensity: .58,
    refractiveIndex: 1.5,
    saturation: .9,
    ambientStrength: .72,
    glassColor: Color(0xA6F8F8FA),
  );

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool compact;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => GlassTextField(
          controller: controller,
          focusNode: focusNode,
          placeholder: hintText,
          autofocus: autofocus,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          height: compact ? 48 : 56,
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
          shape: LiquidRoundedRectangle(borderRadius: compact ? 24 : 28),
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.text.isNotEmpty)
                IconButton(
                  key: const ValueKey('search-clear'),
                  tooltip: '清除',
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                    focusNode?.requestFocus();
                  },
                  icon: const Icon(Icons.clear_rounded, size: 20),
                ),
              IconButton(
                key: const ValueKey('search-submit'),
                tooltip: '搜索',
                onPressed: () => onSubmitted(controller.text),
                icon: const Icon(Icons.arrow_forward_rounded, size: 21),
              ),
            ],
          ),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textStyle: const TextStyle(
            color: ZhPalette.ink,
            fontSize: 16,
            height: 1.2,
          ),
          placeholderStyle: const TextStyle(
            color: ZhPalette.mutedInk,
            fontSize: 16,
            height: 1.2,
          ),
          settings: _settings,
          useOwnLayer: true,
          quality: GlassQuality.premium,
          interactionBehavior: GlassInteractionBehavior.scaleOnly,
          glowColor: Colors.transparent,
          glowRadius: 0,
          pressScale: 1.005,
        ),
      );
}

/// A shared fixed or horizontally scrollable Liquid Glass segment control.
///
/// Fixed controls use the package's inline tab-bar lens. Long collections use
/// the package's scrollable segmented control so every option keeps a stable
/// touch target without forcing the page to overflow.
class ZhLiquidGlassSegmentedTabs extends StatelessWidget {
  const ZhLiquidGlassSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.semanticPrefix = '',
    this.scrollable = false,
    this.height = 46,
  }) : assert(labels.length > 0);

  static const LiquidGlassSettings _settings = LiquidGlassSettings(
    thickness: 28,
    blur: 10,
    chromaticAberration: .18,
    lightIntensity: .65,
    refractiveIndex: 1.52,
    saturation: .9,
    ambientStrength: .8,
    glassColor: Color(0xA6F8F8FA),
  );

  // The package's scrollable segmented preset intentionally uses a native
  // black12 track. That is useful for a stock UISegmentedControl look, but it
  // reads as a flat gray strip on the client's white canvas. Keep the moving
  // lens in the package and use a lighter, low-opacity surface profile for
  // the shared frosted track.
  static const LiquidGlassSettings _scrollableSettings = LiquidGlassSettings(
    thickness: 24,
    blur: 8,
    chromaticAberration: .24,
    lightIntensity: .72,
    refractiveIndex: 1.5,
    saturation: .98,
    ambientStrength: .82,
    glassColor: Color(0x3DF8FBFF),
  );

  static const LiquidGlassSettings _scrollableIndicatorSettings =
      LiquidGlassSettings(
        thickness: 34,
        blur: 3,
        chromaticAberration: .28,
        lightIntensity: .86,
        refractiveIndex: 1.48,
        saturation: 1.02,
        ambientStrength: .9,
        glassColor: Color(0x66FFFFFF),
      );

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String semanticPrefix;
  final bool scrollable;
  final double height;

  int get _safeIndex => selectedIndex.clamp(0, labels.length - 1).toInt();

  TextStyle get _selectedStyle => const TextStyle(
    color: ZhPalette.ink,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  TextStyle get _unselectedStyle => const TextStyle(
    color: ZhPalette.mutedInk,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return _ZhLiquidGlassScrollableSurface(
        height: height,
        child: GlassSegmentedControl.scrollable(
          segments: [
            for (final label in labels)
              GlassSegment(
                id: label,
                label: label,
                semanticLabel: '$semanticPrefix$label',
              ),
          ],
          selectedIndex: _safeIndex,
          onSegmentSelected: onSelected,
          height: height,
          borderRadius: height / 2,
          padding: const EdgeInsets.all(2),
          labelPadding: const EdgeInsets.symmetric(horizontal: 11),
          selectedTextStyle: _selectedStyle,
          unselectedTextStyle: _unselectedStyle,
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0x42FFFFFF),
          indicatorSettings: _scrollableIndicatorSettings,
          indicatorBorderRadius: height / 2,
          indicatorPinchStrength: .18,
          settings: _scrollableSettings,
          useOwnLayer: true,
          quality: GlassQuality.premium,
          maskingQuality: MaskingQuality.high,
        ),
      );
    }

    return GlassTabBar.inline(
      tabs: [
        for (final label in labels)
          GlassTab(label: label, semanticLabel: '$semanticPrefix$label'),
      ],
      selectedIndex: _safeIndex,
      onTabSelected: onSelected,
      barHeight: height,
      horizontalPadding: 4,
      verticalPadding: 0,
      spacing: 2,
      tabPadding: const EdgeInsets.symmetric(horizontal: 8),
      indicatorExpansion: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      indicatorBorderRadius: height / 2,
      indicatorColor: const Color(0x1C000000),
      indicatorPinchStrength: .18,
      selectedLabelStyle: _selectedStyle,
      unselectedLabelStyle: _unselectedStyle,
      settings: _settings,
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
  }
}

/// A frosted glass track for long tab collections.
///
/// `GlassSegmentedControl.scrollable` owns the actual liquid indicator and
/// gesture model. This surface only supplies the material behind it, so the
/// control stays within the package's supported API instead of duplicating
/// its scrolling or spring implementation.
class _ZhLiquidGlassScrollableSurface extends StatelessWidget {
  const _ZhLiquidGlassScrollableSurface({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xCFFFFFFF), Color(0x82EEF5FF)],
                  ),
                  borderRadius: radius,
                ),
              ),
            ),
          ),
        ),
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: const Color(0xB8FFFFFF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Transparent iOS 26 navigation chrome with glass controls in its slots.
class ZhLiquidGlassAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ZhLiquidGlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.bottom,
    this.centerTitle = false,
    this.toolbarHeight = 64,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final double toolbarHeight;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final appBar = GlassAppBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      bottom: bottom,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: ProgressiveBlur(
              // Keep the edge effect light enough that content remains
              // readable through the header. The strongest frost belongs at
              // the lower edge where the scroll view meets the bar; the
              // status-bar side should stay almost clear.
              maxSigma: 6,
              direction: ProgressiveBlurDirection.bottomToTop,
              falloff: 1.8,
            ),
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FFFFFF), Color(0x18F8FBFF)],
                ),
              ),
            ),
          ),
        ),
        appBar,
      ],
    );
  }
}

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

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onMenuPressed;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final tabBar = ZhLiquidGlassSegmentedTabs(
          key: const ValueKey('zh-liquid-glass-feed-tabs'),
          labels: labels,
          selectedIndex: selectedIndex,
          onSelected: onTabSelected,
        );

        final constrainedTabs = desktop
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: tabBar,
              )
            : tabBar;

        final topInset = MediaQuery.viewPaddingOf(context).top;
        return SizedBox(
          height: topInset + barHeight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, topInset + 8, 12, 8),
            child: Row(
              children: [
                if (onMenuPressed != null) ...[
                  Semantics(
                    button: true,
                    label: '打开侧边栏',
                    child: ZhLiquidGlassIconButton(
                      key: const ValueKey('home-drawer-button'),
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: onMenuPressed,
                      semanticLabel: '打开侧边栏',
                      size: 48,
                      iconSize: 23,
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
          ),
        );
      },
    );
  }
}
