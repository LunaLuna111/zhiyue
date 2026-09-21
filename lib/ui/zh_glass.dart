import 'package:flutter/widgets.dart';

/// Runtime switch for the client's liquid-glass visual layer.
///
/// The default is enabled so previews and pages that are mounted without the
/// application shell keep the existing appearance. The shared glass wrappers
/// use this scope to select lightweight Material fallbacks when the user
/// enables 流畅模式 in Settings.
class ZhGlassScope extends InheritedWidget {
  const ZhGlassScope({super.key, required this.enabled, required super.child});

  final bool enabled;

  static bool enabledOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ZhGlassScope>()?.enabled ??
      true;

  @override
  bool updateShouldNotify(ZhGlassScope oldWidget) =>
      enabled != oldWidget.enabled;
}
