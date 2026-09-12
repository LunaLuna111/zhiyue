part of '../desktop_shell.dart';

/// Scaffold and navigation that adapt between mobile and desktop widths.
class ZhAdaptiveHomeShell extends StatefulWidget {
  const ZhAdaptiveHomeShell({
    super.key,
    required this.scaffoldKey,
    required this.pages,
    required this.selectedIndex,
    required this.onSelectedIndex,
    required this.drawer,
    required this.desktopSidebar,
    required this.destinations,
    required this.onOpenDrawer,
    this.pushDrawerController,
    this.drawerEnableOpenDragGesture = true,
    this.drawerEdgeDragWidth = 72,
    this.drawerScrimColor,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<Widget> pages;
  final int selectedIndex;
  final ValueChanged<int> onSelectedIndex;
  final Widget drawer;
  final Widget desktopSidebar;
  final List<NavigationDestination> destinations;
  final VoidCallback onOpenDrawer;
  final ZhPushDrawerController? pushDrawerController;
  final bool drawerEnableOpenDragGesture;
  final double drawerEdgeDragWidth;
  final Color? drawerScrimColor;

  @override
  State<ZhAdaptiveHomeShell> createState() => _ZhAdaptiveHomeShellState();
}

class _ZhAdaptiveHomeShellState extends State<ZhAdaptiveHomeShell>
    with SingleTickerProviderStateMixin {
  static const _motionCurve = Cubic(.2, .9, .3, 1);
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    reverseDuration: const Duration(milliseconds: 300),
  );
  late final ZhPushDrawerController _ownedController = ZhPushDrawerController();
  late ZhPushDrawerController _drawerController;
  late final Future<bool> Function(bool open) _transition = _animateDrawer;
  double _drawerExtent = 0;
  double _dragOriginX = 0;
  double _dragOriginProgress = 0;
  bool _hasDragOrigin = false;
  bool _dragActive = false;
  bool _edgeDragActive = false;
  bool _desktopLayout = false;
  bool _desktopResetScheduled = false;
  DateTime? _exitConfirmationDeadline;

  bool get _confirmsAndroidRootExit =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _attachController(widget.pushDrawerController ?? _ownedController);
  }

  @override
  void didUpdateWidget(covariant ZhAdaptiveHomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.pushDrawerController ?? _ownedController;
    if (!identical(next, _drawerController)) {
      _drawerController._detach(_transition);
      _attachController(next);
    }
  }

  void _attachController(ZhPushDrawerController controller) {
    _drawerController = controller;
    _progress.value = controller.isOpen ? 1 : 0;
    controller._attach(_transition);
  }

  Future<bool> _animateDrawer(bool open) async {
    final target = open ? 1.0 : 0.0;
    if (_progress.value == target) return true;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations == true;
    if (reduceMotion) {
      _progress.value = target;
      return true;
    }
    try {
      await _progress.animateTo(target, curve: _motionCurve).orCancel;
    } on TickerCanceled {
      // A reverse request, breakpoint change, or direct manipulation can
      // cancel the ticker. Resolve the old request instead of leaving route
      // navigation awaiting a TickerFuture that never completes.
      return false;
    }
    return mounted && _progress.value == target;
  }

  void _rememberDragOrigin(PointerDownEvent details) {
    _progress.stop();
    _dragOriginX = details.position.dx;
    _dragOriginProgress = _progress.value;
    _hasDragOrigin = true;
  }

  void _dragStart(DragStartDetails details) {
    _progress.stop();
    _dragActive = true;
    if (!_hasDragOrigin) {
      _dragOriginX = details.globalPosition.dx;
      _dragOriginProgress = _progress.value;
    }
  }

  void _edgeDragStart(DragStartDetails details) {
    _edgeDragActive = true;
    _dragStart(details);
  }

  void _dragUpdate(DragUpdateDetails details) {
    if (_drawerExtent <= 0) return;
    final displacement = details.globalPosition.dx - _dragOriginX;
    _progress.value = (_dragOriginProgress + displacement / _drawerExtent)
        .clamp(0.0, 1.0);
  }

  void _dragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final open = velocity.abs() >= 450 ? velocity > 0 : _progress.value >= .5;
    _finishDrag();
    _drawerController._synchronize(open);
    unawaited(_animateDrawer(open));
  }

  void _dragCancel() {
    final open = _progress.value >= .5;
    _finishDrag();
    _drawerController._synchronize(open);
    unawaited(_animateDrawer(open));
  }

  void _finishDrag() {
    _hasDragOrigin = false;
    if (!_dragActive && !_edgeDragActive) return;
    setState(() {
      _dragActive = false;
      _edgeDragActive = false;
    });
  }

  void _handleCompactPop(bool didPop, double drawerProgress) {
    if (didPop) return;
    if (drawerProgress > 0) {
      unawaited(_drawerController.close());
      return;
    }
    if (!_confirmsAndroidRootExit) return;

    final now = DateTime.now();
    final deadline = _exitConfirmationDeadline;
    if (deadline != null && now.isBefore(deadline)) {
      _exitConfirmationDeadline = null;
      unawaited(SystemNavigator.pop());
      return;
    }

    _exitConfirmationDeadline = now.add(const Duration(seconds: 2));
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('再返回一次退出应用'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _scheduleDesktopDrawerReset() {
    if (_desktopResetScheduled ||
        (!_progress.isAnimating &&
            _progress.value == 0 &&
            !_drawerController.isOpen &&
            !_dragActive &&
            !_edgeDragActive &&
            !_hasDragOrigin)) {
      return;
    }
    _desktopResetScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _desktopResetScheduled = false;
      if (!mounted || !_desktopLayout) return;
      _progress.stop();
      _progress.value = 0;
      _hasDragOrigin = false;
      _dragActive = false;
      _edgeDragActive = false;
      _drawerController._resetClosed();
    });
  }

  @override
  void dispose() {
    _drawerController._detach(_transition);
    _ownedController.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // A shell is normally laid out by the window's bounded Scaffold.  The
      // MediaQuery fallback keeps embedded/previews safe if an ancestor gives
      // us an unconstrained width instead of accidentally building a Row with
      // an infinite Expanded child.
      final viewportWidth = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final desktop = ZhShellBreakpoints.isDesktop(viewportWidth);
      _desktopLayout = desktop;
      if (desktop) _scheduleDesktopDrawerReset();
      return _ZhShellShortcuts(
        onSelectedIndex: widget.onSelectedIndex,
        onOpenDrawer: widget.onOpenDrawer,
        child: desktop
            ? _KeyboardStableHome(
                child: Scaffold(
                  key: widget.scaffoldKey,
                  resizeToAvoidBottomInset: false,
                  body: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      widget.desktopSidebar,
                      const VerticalDivider(width: 1, thickness: 1),
                      Expanded(
                        child: IndexedStack(
                          index: widget.selectedIndex,
                          children: widget.pages,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _buildPushDrawer(context, viewportWidth),
      );
    },
  );

  Widget _buildPushDrawer(BuildContext context, double viewportWidth) {
    final width = viewportWidth.isFinite
        ? viewportWidth
        : MediaQuery.sizeOf(context).width;
    final preferredDrawerWidth = (width * .86).clamp(300.0, 368.0).toDouble();
    final drawerWidth = preferredDrawerWidth.clamp(0.0, width).toDouble();
    _drawerExtent = drawerWidth;
    final mainScaffold = _KeyboardStableHome(
      child: Scaffold(
        key: widget.scaffoldKey,
        // Every home section is kept alive in the IndexedStack. Letting this
        // outer Scaffold follow the IME would therefore lay out all four page
        // trees on every keyboard animation frame. Input pages and modal
        // composers handle their own keyboard insets instead.
        resizeToAvoidBottomInset: false,
        body: IndexedStack(index: widget.selectedIndex, children: widget.pages),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: ZhPalette.border)),
          ),
          child: NavigationBar(
            height: 62,
            // Keep the mobile bar icon-only. NavigationDestination retains
            // the label in semantics and exposes it as a tooltip on long
            // press, so accessibility text remains available without a
            // permanent second line below every icon.
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            selectedIndex: widget.selectedIndex,
            onDestinationSelected: widget.onSelectedIndex,
            destinations: widget.destinations,
          ),
        ),
      ),
    );
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final value = _progress.value;
        return PopScope(
          canPop: value == 0 && !_confirmsAndroidRootExit,
          onPopInvokedWithResult: (didPop, _) =>
              _handleCompactPop(didPop, value),
          // Keep this gesture wrapper mounted throughout the transition.
          // Switching from Stack to Listener/GestureDetector at the first
          // animation tick used to replace the whole subtree, including the
          // expensive main-page repaint boundary, exactly when the drawer was
          // supposed to begin moving.
          child: Listener(
            onPointerDown: value == 0 || _edgeDragActive
                ? null
                : _rememberDragOrigin,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              dragStartBehavior: DragStartBehavior.down,
              onHorizontalDragStart: value == 0 || _edgeDragActive
                  ? null
                  : _dragStart,
              onHorizontalDragUpdate: value == 0 || _edgeDragActive
                  ? null
                  : _dragUpdate,
              onHorizontalDragEnd: value == 0 || _edgeDragActive
                  ? null
                  : _dragEnd,
              onHorizontalDragCancel: value == 0 || _edgeDragActive
                  ? null
                  : _dragCancel,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: [
                  ColoredBox(color: ZhPalette.canvas),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: drawerWidth,
                    child: Transform.translate(
                      key: const ValueKey('push-drawer-surface'),
                      offset: Offset(-drawerWidth * (1 - value), 0),
                      // The drawer is usually a long, image-bearing list. A
                      // cached layer keeps its rasterization independent from
                      // the animated horizontal transform.
                      child: ExcludeSemantics(
                        excluding: value == 0,
                        child: RepaintBoundary(
                          key: const ValueKey('push-drawer-repaint-boundary'),
                          child: widget.drawer,
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    key: const ValueKey('push-main-surface'),
                    offset: Offset(drawerWidth * value, 0),
                    child: ExcludeSemantics(
                      excluding: value > 0,
                      child: RepaintBoundary(
                        child: PhysicalModel(
                          key: const ValueKey('push-main-physical-surface'),
                          color: ZhPalette.background,
                          // Keep the physical layer static while it moves. A
                          // changing elevation forces Flutter to regenerate a
                          // large shadow texture on every animation tick.
                          elevation: 18,
                          shadowColor: Colors.black54,
                          borderRadius: BorderRadius.zero,
                          clipBehavior: Clip.none,
                          child: mainScaffold,
                        ),
                      ),
                    ),
                  ),
                  if (value > 0)
                    Transform.translate(
                      key: const ValueKey('push-drawer-scrim-surface'),
                      offset: Offset(drawerWidth * value, 0),
                      child: Semantics(
                        button: true,
                        label: '关闭侧边栏',
                        child: GestureDetector(
                          key: const ValueKey('push-drawer-dismiss'),
                          behavior: HitTestBehavior.opaque,
                          onTap: _drawerController.close,
                          child: ColoredBox(
                            color: (widget.drawerScrimColor ?? ZhPalette.ink)
                                .withValues(alpha: .08 * value),
                          ),
                        ),
                      ),
                    ),
                  if ((value == 0 || _edgeDragActive) &&
                      widget.drawerEnableOpenDragGesture)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: widget.drawerEdgeDragWidth,
                      child: Listener(
                        onPointerDown: _rememberDragOrigin,
                        child: GestureDetector(
                          key: const ValueKey('push-drawer-edge-gesture'),
                          behavior: HitTestBehavior.translucent,
                          dragStartBehavior: DragStartBehavior.down,
                          onHorizontalDragStart: _edgeDragStart,
                          onHorizontalDragUpdate: _dragUpdate,
                          onHorizontalDragEnd: _dragEnd,
                          onHorizontalDragCancel: _dragCancel,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shields every kept-alive home tab from transient keyboard metrics.
///
/// The active input surface is either configured to stay fixed (search) or is
/// presented on a route above the home shell (comments and editors). Passing
/// the IME inset into this IndexedStack only makes inactive, image-heavy tabs
/// repeatedly lay themselves out behind the keyboard.
class _KeyboardStableHome extends StatelessWidget {
  const _KeyboardStableHome({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      key: const ValueKey('keyboard-stable-home'),
      data: media.copyWith(
        padding: media.padding.copyWith(bottom: media.viewPadding.bottom),
        viewInsets: media.viewInsets.copyWith(bottom: 0),
      ),
      child: child,
    );
  }
}

class _ZhShellShortcuts extends StatelessWidget {
  const _ZhShellShortcuts({
    required this.onSelectedIndex,
    required this.onOpenDrawer,
    required this.child,
  });

  final ValueChanged<int> onSelectedIndex;
  final VoidCallback onOpenDrawer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shortcuts = <LogicalKeySet, Intent>{
      for (var index = 0; index < 4; index++) ...{
        LogicalKeySet(LogicalKeyboardKey.control, _digitKey(index)):
            ZhShellSelectIntent(index),
        LogicalKeySet(LogicalKeyboardKey.meta, _digitKey(index)):
            ZhShellSelectIntent(index),
      },
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyM):
          const ZhShellOpenDrawerIntent(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyM):
          const ZhShellOpenDrawerIntent(),
    };
    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          ZhShellSelectIntent: CallbackAction<ZhShellSelectIntent>(
            onInvoke: (intent) {
              if (intent.index >= 0 && intent.index < 4) {
                onSelectedIndex(intent.index);
              }
              return null;
            },
          ),
          ZhShellOpenDrawerIntent: CallbackAction<ZhShellOpenDrawerIntent>(
            onInvoke: (_) {
              onOpenDrawer();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }

  static LogicalKeyboardKey _digitKey(int index) => switch (index) {
    0 => LogicalKeyboardKey.digit1,
    1 => LogicalKeyboardKey.digit2,
    2 => LogicalKeyboardKey.digit3,
    _ => LogicalKeyboardKey.digit4,
  };
}
