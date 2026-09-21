import 'package:flutter/material.dart';

import '../zh_theme.dart';

class ZhBrandMark extends StatelessWidget {
  const ZhBrandMark({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: '知阅',
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ZhPalette.ink,
        borderRadius: BorderRadius.circular(size * .34),
      ),
      child: Text(
        '知',
        style: TextStyle(
          color: ZhPalette.background,
          fontSize: size * .46,
          height: 1,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class ZhPageWidth extends StatelessWidget {
  const ZhPageWidth({super.key, required this.child, this.maxWidth = 920});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// Clips the app's mobile viewport independently from the route below it.
///
/// Android's predictive-back transition can temporarily move a pushed route
/// outside the display's normal rounded viewport. Pages that paint behind a
/// transparent app bar then expose square white corners during the gesture.
/// Keeping this clip above the app itself means every route (including custom
/// PageRouteBuilder pages, root overlays, and nested Navigators) keeps the same
/// phone-shaped surface while it is being transformed. This must stay outside
/// MaterialApp: a builder inside MaterialApp is still below some root-level
/// overlay/compositing layers used during predictive back.
class ZhMobileViewportSurface extends StatelessWidget {
  const ZhMobileViewportSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width >= ZhViewport.compact) return child;
    return ColoredBox(
      color: ZhPalette.canvas,
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
          bottom: Radius.circular(30),
        ),
        child: child,
      ),
    );
  }
}

/// Breakpoints shared by pages that need to adapt from a phone-sized canvas to
/// a desktop window. Keeping these values in one place prevents each page
/// from growing a subtly different definition of "desktop".
abstract final class ZhViewport {
  /// Below this width controls should stay in their compact/mobile form.
  static const compact = 600.0;

  /// At this width there is enough room for a reading column and a side rail.
  static const desktop = 960.0;

  /// At this width a second column can be shown without squeezing the main
  /// content below a comfortable reading width.
  static const wide = 1120.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wide;
}

/// A centered page frame with optional desktop gutters.
///
/// `ZhPageWidth` intentionally preserves the historical edge-to-edge mobile
/// behavior used by feed cards. New pages can opt into this frame when they
/// need a larger desktop canvas and predictable side whitespace. The width
/// includes the gutters, so children always receive finite constraints even
/// when the window is very wide.
class ZhResponsiveFrame extends StatelessWidget {
  const ZhResponsiveFrame({
    super.key,
    required this.child,
    this.maxWidth = 1180,
    this.mobileGutter = 0,
    this.desktopGutter = 24,
    this.desktopBreakpoint = ZhViewport.desktop,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final double mobileGutter;
  final double desktopGutter;
  final double desktopBreakpoint;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final viewport = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final frameWidth = viewport < maxWidth ? viewport : maxWidth;
      final requestedGutter = viewport >= desktopBreakpoint
          ? desktopGutter
          : mobileGutter;
      // Do not let gutters consume the whole frame on a tiny/embedded view.
      final gutter = requestedGutter.clamp(0.0, frameWidth / 2);
      return Align(
        alignment: alignment,
        child: SizedBox(
          width: frameWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Places a primary reading/list column beside an optional desktop rail.
///
/// On phones and narrow desktop windows the rail is omitted and `primary` is
/// returned unchanged. This is deliberately a layout-only component: both
/// children remain owned by the page, so navigation and API contracts do not
/// change when the viewport crosses the breakpoint.
class ZhResponsiveTwoPane extends StatelessWidget {
  const ZhResponsiveTwoPane({
    super.key,
    required this.primary,
    required this.secondary,
    this.maxWidth = 1180,
    this.secondaryWidth = 292,
    this.gap = 24,
    this.breakpoint = ZhViewport.wide,
    this.desktopGutter = 24,
  });

  final Widget primary;
  final Widget secondary;
  final double maxWidth;
  final double secondaryWidth;
  final double gap;
  final double breakpoint;
  final double desktopGutter;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final viewport = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      if (viewport < breakpoint) return primary;
      return ZhResponsiveFrame(
        maxWidth: maxWidth,
        desktopGutter: desktopGutter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: primary),
            SizedBox(width: gap),
            SizedBox(width: secondaryWidth, child: secondary),
          ],
        ),
      );
    },
  );
}
