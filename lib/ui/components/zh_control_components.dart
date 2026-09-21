import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../zh_glass.dart';
import '../zh_theme.dart';

/// The client's shared iOS 26-style toggle.
///
/// The interaction, thumb animation, haptics and accessibility behavior stay
/// in the package-provided [GlassSwitch]. This wrapper only fixes the visual
/// contract used by settings and feature pages, including the disabled state.
class ZhLiquidGlassSwitch extends StatelessWidget {
  const ZhLiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  static const _activeColor = Color(0xEE141414);
  static const _inactiveColor = Color(0xB8D8DADF);
  static const _thumbColor = Color(0xFFFDFDFD);

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    if (!ZhGlassScope.enabledOf(context)) {
      return Semantics(
        container: true,
        button: true,
        enabled: enabled,
        toggled: value,
        label: semanticLabel,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: ZhPalette.background,
          activeTrackColor: ZhPalette.ink,
          inactiveThumbColor: ZhPalette.background,
          inactiveTrackColor: ZhPalette.canvas,
          trackOutlineColor: WidgetStatePropertyAll(ZhPalette.border),
        ),
      );
    }
    final switchWidget = GlassSwitch(
      value: value,
      onChanged: onChanged ?? (_) {},
      activeColor: _activeColor,
      inactiveColor: _inactiveColor,
      thumbColor: _thumbColor,
      width: 60,
      height: 30,
      useOwnLayer: true,
      quality: GlassQuality.standard,
      enableHaptics: enabled,
      semanticLabel: semanticLabel,
    );

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      toggled: value,
      label: semanticLabel,
      child: enabled
          ? switchWidget
          : IgnorePointer(child: Opacity(opacity: .5, child: switchWidget)),
    );
  }
}

/// A shared text row with a [ZhLiquidGlassSwitch] trailing control.
class ZhLiquidGlassSwitchTile extends StatelessWidget {
  const ZhLiquidGlassSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.contentPadding = EdgeInsets.zero,
    this.minTileHeight = 72,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final EdgeInsetsGeometry contentPadding;
  final double minTileHeight;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      contentPadding: contentPadding,
      minTileHeight: minTileHeight,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: ZhLiquidGlassSwitch(
        value: value,
        onChanged: onChanged,
        semanticLabel: title,
      ),
      onTap: onChanged == null ? null : () => onChanged!(!value),
    ),
  );
}
