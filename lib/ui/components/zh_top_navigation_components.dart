import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../zh_theme.dart';

const _zhToolbarGlassSettings = LiquidGlassSettings(
  thickness: 30,
  blur: 10,
  chromaticAberration: .18,
  lightIntensity: .65,
  refractiveIndex: 1.52,
  saturation: .9,
  ambientStrength: .8,
  glassColor: Color(0xA6F8F8FA),
);

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

  final Widget icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final double size;
  final double? iconSize;
  final GlassIconButtonShape shape;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final glassShape = shape == GlassIconButtonShape.circle
        ? const LiquidOval()
        : LiquidRoundedRectangle(borderRadius: borderRadius);
    return GlassButton.custom(
      key: key,
      onTap: onPressed ?? _disabledAction,
      enabled: onPressed != null,
      label: semanticLabel ?? '',
      width: size,
      height: size,
      shape: glassShape,
      useOwnLayer: true,
      settings: _zhToolbarGlassSettings,
      quality: GlassQuality.premium,
      // Leave the interaction values at the package defaults. They provide
      // the native press inflation, spring return and touch-following glass
      // that a toolbar control is expected to have.
      child: IconTheme(
        data: IconThemeData(
          color: onPressed == null ? ZhPalette.subtleInk : ZhPalette.ink,
          size: iconSize ?? size * .5,
        ),
        child: icon,
      ),
    );
  }

  static void _disabledAction() {}
}

/// A pull-down menu whose trigger and morphing menu share the same glass
/// language as the rest of the toolbar.
class ZhLiquidGlassMenuItem<T> {
  const ZhLiquidGlassMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
    this.enabled = true,
    this.destructive = false,
  });

  final T value;
  final String label;
  final Widget? icon;
  final String? subtitle;
  final bool enabled;
  final bool destructive;
}

class ZhLiquidGlassMenuButton<T> extends StatelessWidget {
  const ZhLiquidGlassMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
    required this.icon,
    required this.semanticLabel,
    this.size = 44,
    this.iconSize,
    this.menuWidth = 240,
    this.menuAlignment,
    this.shape = GlassIconButtonShape.circle,
    this.borderRadius = 16,
  });

  final List<ZhLiquidGlassMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final Widget icon;
  final String semanticLabel;
  final double size;
  final double? iconSize;
  final double menuWidth;
  final GlassMenuAlignment? menuAlignment;
  final GlassIconButtonShape shape;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => GlassMenu(
    key: key,
    menuWidth: menuWidth,
    menuAlignment: menuAlignment,
    menuBorderRadius: 28,
    itemBorderRadius: 20,
    menuPadding: const EdgeInsets.symmetric(vertical: 8),
    settings: _zhToolbarGlassSettings,
    quality: GlassQuality.premium,
    triggerBuilder: (context, toggleMenu) => ZhLiquidGlassIconButton(
      icon: icon,
      onPressed: toggleMenu,
      semanticLabel: semanticLabel,
      size: size,
      iconSize: iconSize,
      shape: shape,
      borderRadius: borderRadius,
    ),
    items: [
      for (final item in items)
        GlassMenuItem(
          title: item.label,
          icon: item.icon,
          enabled: item.enabled,
          isDestructive: item.destructive,
          onTap: item.enabled ? () => onSelected(item.value) : () {},
        ),
    ],
  );
}

/// A text-and-icon action that uses the package's native iOS 26 glass button.
///
/// The wrapper keeps CTA sizing and semantic labels consistent across pages;
/// the glass surface, press animation and disabled treatment remain owned by
/// [GlassButton].
class ZhLiquidGlassLabelButton extends StatelessWidget {
  const ZhLiquidGlassLabelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.expand = false,
    this.prominent = false,
    this.semanticLabel,
  });

  static const LiquidGlassSettings _settings = LiquidGlassSettings(
    thickness: 28,
    blur: 8,
    chromaticAberration: .2,
    lightIntensity: .7,
    refractiveIndex: 1.52,
    saturation: .94,
    ambientStrength: .85,
    glassColor: Color(0xB8F8F8FA),
  );

  static const LiquidGlassSettings _prominentSettings = LiquidGlassSettings(
    thickness: 34,
    blur: 7,
    chromaticAberration: .16,
    lightIntensity: .72,
    refractiveIndex: 1.5,
    saturation: .9,
    ambientStrength: .88,
    glassColor: Color(0xE3141414),
  );

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final bool expand;
  final bool prominent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final foreground = prominent ? ZhPalette.background : ZhPalette.ink;
    return GlassButton.custom(
      key: key,
      onTap: onPressed ?? _disabledAction,
      enabled: onPressed != null,
      label: semanticLabel ?? label,
      width: expand ? double.infinity : null,
      height: 50,
      shape: const LiquidRoundedRectangle(borderRadius: 18),
      settings: prominent ? _prominentSettings : _settings,
      useOwnLayer: true,
      quality: GlassQuality.premium,
      style: prominent ? GlassButtonStyle.prominent : GlassButtonStyle.filled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?leading,
          if (leading != null && (icon != null || label.isNotEmpty))
            const SizedBox(width: 8),
          if (icon != null) Icon(icon, size: 18, color: foreground),
          if (icon != null && label.isNotEmpty) const SizedBox(width: 8),
          if (label.isNotEmpty)
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
        ],
      ),
    );
  }

  static void _disabledAction() {}
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

/// A connected capsule with one direct action and one pull-down menu action.
///
/// The menu item stays inside the same [GlassButtonGroup] as the direct
/// action, so compact page toolbars keep one continuous glass surface.
class ZhLiquidGlassCapsuleMenuActionGroup<T> extends StatelessWidget {
  const ZhLiquidGlassCapsuleMenuActionGroup({
    super.key,
    required this.primaryAction,
    this.additionalActions = const <ZhLiquidGlassCapsuleAction>[],
    required this.menuIcon,
    required this.menuSemanticLabel,
    required this.menuItems,
    required this.onSelected,
    this.menuWidth = 240,
    this.menuAlignment,
  });

  final ZhLiquidGlassCapsuleAction primaryAction;
  final List<ZhLiquidGlassCapsuleAction> additionalActions;
  final Widget menuIcon;
  final String menuSemanticLabel;
  final List<ZhLiquidGlassMenuItem<T>> menuItems;
  final ValueChanged<T> onSelected;
  final double menuWidth;
  final GlassMenuAlignment? menuAlignment;

  @override
  Widget build(BuildContext context) => GlassButtonGroup.icons(
    key: key,
    items: [
      for (final action in [primaryAction, ...additionalActions])
        GlassButtonGroupItem(
          icon: action.icon,
          label: action.semanticLabel,
          enabled: action.onPressed != null,
          onTap: action.onPressed ?? _disabledAction,
        ),
      GlassButtonGroupItem.menu(
        icon: menuIcon,
        label: menuSemanticLabel,
        menuWidth: menuWidth,
        menuAlignment: menuAlignment,
        menuItems: [
          for (final item in menuItems)
            GlassMenuItem(
              title: item.label,
              icon: item.icon,
              subtitle: item.subtitle,
              enabled: item.enabled,
              isDestructive: item.destructive,
              onTap: item.enabled
                  ? () => onSelected(item.value)
                  : _disabledAction,
            ),
        ],
      ),
    ],
    borderRadius: 28,
    itemPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
    iconSize: 22,
    settings: ZhLiquidGlassCapsuleActionGroup._settings,
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
    this.inlineActions = true,
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
  final bool inlineActions;

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
          suffixIcon: inlineActions
              ? Row(
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
                )
              : null,
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
    this.interactionBehavior = GlassInteractionBehavior.full,
    this.pressScale = 1.02,
    this.indicatorExpansion = const EdgeInsets.symmetric(
      horizontal: 5,
      vertical: 5,
    ),
    this.indicatorPinchStrength = .18,
    this.shadowElevation = 1,
    this.labelFontSize = 15,
    this.plainSelection = false,
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
  final GlassInteractionBehavior interactionBehavior;
  final double pressScale;
  final EdgeInsetsGeometry indicatorExpansion;
  final double indicatorPinchStrength;
  final double shadowElevation;
  final double labelFontSize;
  final bool plainSelection;

  int get _safeIndex => selectedIndex.clamp(0, labels.length - 1).toInt();

  TextStyle get _selectedStyle => TextStyle(
    color: ZhPalette.ink,
    fontSize: labelFontSize,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  TextStyle get _unselectedStyle => TextStyle(
    color: ZhPalette.mutedInk,
    fontSize: labelFontSize,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    if (plainSelection) {
      return _ZhLiquidGlassStaticSegmentedTabs(
        key: key,
        labels: labels,
        selectedIndex: _safeIndex,
        onSelected: onSelected,
        semanticPrefix: semanticPrefix,
        height: height,
        labelFontSize: labelFontSize,
        shadowElevation: shadowElevation,
      );
    }
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
          // The indicator blooms beyond the resting track while it is being
          // dragged. A finite capsule sentinel keeps its corners circular at
          // both sizes instead of turning into a rounded rectangle.
          indicatorBorderRadius: GlassDefaults.capsuleRadius,
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
      indicatorBorderRadius: height / 2,
      indicatorColor: const Color(0x1C000000),
      indicatorPinchStrength: indicatorPinchStrength,
      indicatorExpansion: indicatorExpansion,
      selectedLabelStyle: _selectedStyle,
      unselectedLabelStyle: _unselectedStyle,
      settings: _settings.copyWith(shadowElevation: shadowElevation),
      quality: GlassQuality.premium,
      backgroundQuality: GlassQuality.premium,
      pressScale: pressScale,
      // Inline sort controls should not flash a full-surface directional glow
      // when their parent list starts a new request. The selected lens still
      // animates, while the track keeps a stable tone during loading.
      interactionBehavior: interactionBehavior,
    );
  }
}

/// A deliberately simple segmented capsule for compact sort controls.
///
/// The package tab bar uses a refractive indicator that is ideal for large
/// navigation surfaces but can briefly darken its inner ring when a parent
/// list is rebuilt. Sort controls do not need that shader path: they keep the
/// shared glass group and animate only a light selection pill.
class _ZhLiquidGlassStaticSegmentedTabs extends StatelessWidget {
  const _ZhLiquidGlassStaticSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    required this.semanticPrefix,
    required this.height,
    required this.labelFontSize,
    required this.shadowElevation,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String semanticPrefix;
  final double height;
  final double labelFontSize;
  final double shadowElevation;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (!width.isFinite || width <= 0) return const SizedBox.shrink();
      final segmentWidth = width / labels.length;
      final selected = selectedIndex.clamp(0, labels.length - 1).toInt();
      return GlassButtonGroup(
        key: key,
        borderRadius: height / 2,
        borderColor: Colors.transparent,
        settings: ZhLiquidGlassSegmentedTabs._settings.copyWith(
          shadowElevation: shadowElevation,
        ),
        quality: GlassQuality.premium,
        useOwnLayer: true,
        showDividers: false,
        itemPadding: EdgeInsets.zero,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedPositioned(
                  left: segmentWidth * selected,
                  top: 0,
                  width: segmentWidth,
                  height: height,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x24000000),
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var index = 0; index < labels.length; index++)
                      SizedBox(
                        width: segmentWidth,
                        height: height,
                        child: Semantics(
                          button: true,
                          selected: index == selected,
                          label: '$semanticPrefix${labels[index]}',
                          onTap: () => onSelected(index),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onSelected(index),
                            child: Center(
                              child: Text(
                                labels[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: index == selected
                                      ? ZhPalette.ink
                                      : ZhPalette.mutedInk,
                                  fontSize: labelFontSize,
                                  fontWeight: index == selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
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
      backgroundColor: Colors.transparent,
      toolbarHeight: toolbarHeight,
      bottom: bottom,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(child: ZhProgressiveGlassBackdrop()),
        appBar,
      ],
    );
  }
}

/// Shared translucent chrome for app bars that float above scrolling content.
///
/// The lower edge remains nearly clear while the upper edge gains a gentle
/// progressive blur. This lets the scrolling content dissolve naturally into
/// the toolbar without creating a hard divider or hiding the text below it.
class ZhProgressiveGlassBackdrop extends StatelessWidget {
  const ZhProgressiveGlassBackdrop({super.key, this.gradient});

  static const _defaultGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, .28, .68, 1],
    colors: [
      Color(0xD8D7E8FF),
      Color(0x70EAF6FF),
      Color(0x20F7FCFF),
      Color(0x00FFFFFF),
    ],
  );

  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      fit: StackFit.expand,
      children: [
        const ProgressiveBlur(
          maxSigma: 6,
          // The lower edge should dissolve into the page while the upper edge
          // carries the strongest blur, matching the iOS 26 toolbar gradient.
          direction: ProgressiveBlurDirection.topToBottom,
          falloff: 1.8,
        ),
        DecoratedBox(
          decoration: BoxDecoration(gradient: gradient ?? _defaultGradient),
        ),
      ],
    ),
  );
}

/// The shared top-level navigation surface used by ordinary pages.
///
/// Detail pages can still provide their own title/action widgets, while every
/// regular page gets the same transparent progressive backdrop, toolbar
/// height, back-button geometry and route-aware back behaviour. Keeping this
/// policy here prevents each page from growing a slightly different AppBar.
class ZhTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ZhTopBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle,
    this.toolbarHeight,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;
  final double? toolbarHeight;
  final bool automaticallyImplyLeading;

  /// The scrollable body's starting inset when this bar overlays it.
  ///
  /// [Scaffold.extendBodyBehindAppBar] keeps the body under the transparent
  /// chrome. The outer [MediaQuery] still exposes the system status-bar inset,
  /// so ordinary pages can reserve the public bar height in one place instead
  /// of duplicating platform-safe-area arithmetic.
  static double bodyTopInset(
    BuildContext context, {
    double toolbarHeight = 56,
  }) => MediaQuery.paddingOf(context).top + toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? 56) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final routeCanPop = ModalRoute.of(context)?.canPop ?? false;
    final effectiveLeading =
        leading ??
        (automaticallyImplyLeading && routeCanPop
            ? ZhLiquidGlassIconButton(
                key: const ValueKey('zh-top-bar-back'),
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
                semanticLabel: '返回',
                size: 46,
                iconSize: 24,
              )
            : null);
    return ZhLiquidGlassAppBar(
      title: title,
      leading: effectiveLeading,
      actions: actions ?? const <Widget>[],
      bottom: bottom,
      centerTitle: centerTitle ?? false,
      toolbarHeight: toolbarHeight ?? 56,
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
          child: Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(child: ZhProgressiveGlassBackdrop()),
              Padding(
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
            ],
          ),
        );
      },
    );
  }
}
