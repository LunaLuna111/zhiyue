import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../zh_glass.dart';
import '../zh_theme.dart';

/// Shared visual defaults for modal surfaces that float above app content.
///
/// Keep these values in one place so future bottom sheets can adopt the same
/// iOS 26 surface without each page reimplementing its own glass settings.
abstract final class ZhLiquidGlassSheetStyle {
  static const topBorderRadius = 32.0;
  static const bottomBorderRadius = 0.0;

  static LiquidGlassSettings get settings => LiquidGlassSettings(
    thickness: 12,
    blur: 12,
    chromaticAberration: 0,
    lightIntensity: .62,
    refractiveIndex: .2,
    saturation: 1.15,
    ambientStrength: .45,
    glassColor: ZhPalette.isDark
        ? const Color(0xE61B2026)
        : const Color(0xE6FFFFFF),
  );
}

/// Shows a client-standard iOS 26 liquid-glass bottom sheet.
///
/// This is the app-level adapter around the package's [GlassSheet]. It keeps
/// the package surface, drag behavior, safe-area handling and reduced-glass
/// fallback consistent while allowing each caller to provide its own content.
Future<T?> showZhLiquidGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = false,
}) {
  Widget materialContent(BuildContext sheetContext) => Material(
    type: MaterialType.transparency,
    child: GlassInteractionSilence(child: builder(sheetContext)),
  );

  if (!ZhGlassScope.enabledOf(context)) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: ZhPalette.background,
      builder: materialContent,
    );
  }

  return GlassSheet.show<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    showDragIndicator: true,
    topBorderRadius: ZhLiquidGlassSheetStyle.topBorderRadius,
    bottomBorderRadius: ZhLiquidGlassSheetStyle.bottomBorderRadius,
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    isScrollable: false,
    interactionScale: 1.01,
    stretch: .35,
    resistance: .1,
    enableInteractionGlow: true,
    enableSaturationGlow: true,
    suppressInteractionOnChildren: true,
    settings: ZhLiquidGlassSheetStyle.settings,
    quality: GlassQuality.standard,
    barrierColor: Colors.black.withValues(alpha: .54),
    builder: materialContent,
  );
}
