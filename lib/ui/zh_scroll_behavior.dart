import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Shared scrolling policy for phone, tablet and desktop windows.
///
/// Flutter's default desktop behavior intentionally excludes the mouse from
/// drag devices.  Including it here makes long feed/search lists feel natural
/// with a trackpad or a pressed mouse button while retaining the platform
/// scrollbar and overscroll behavior supplied by [MaterialScrollBehavior].
class ZhScrollBehavior extends MaterialScrollBehavior {
  const ZhScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
