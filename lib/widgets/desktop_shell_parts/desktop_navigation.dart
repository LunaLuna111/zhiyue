part of '../desktop_shell.dart';

/// Width at which the app has enough room for a persistent navigation rail.
///
/// The breakpoint is intentionally based on available width instead of the
/// current platform.  A narrow desktop window should remain as usable as the
/// mobile layout, while a tablet/web window with enough room benefits from the
/// same persistent navigation used on desktop.
abstract final class ZhShellBreakpoints {
  /// Keep the shell in lock-step with page-level responsive layouts.
  static const desktop = ZhViewport.desktop;

  static bool isDesktop(double width) => width.isFinite && width >= desktop;
}

/// Intent used by the shell's Ctrl/Command+1..4 shortcuts.
class ZhShellSelectIntent extends Intent {
  const ZhShellSelectIntent(this.index);

  final int index;
}

/// Intent used by the shell's Ctrl/Command+M shortcut.
class ZhShellOpenDrawerIntent extends Intent {
  const ZhShellOpenDrawerIntent();
}

/// Imperative bridge used by menu buttons and drawer destinations.
///
/// The shell owns the animation; callers only express the desired state and
/// can await the transition before pushing a new route.
class ZhPushDrawerController extends ChangeNotifier {
  bool _isOpen = false;
  int _requestRevision = 0;
  Future<bool> Function(bool open)? _transition;
  final ValueNotifier<double> _animationProgress = ValueNotifier(0);
  final ValueNotifier<bool> _drawerVisible = ValueNotifier(false);

  bool get isOpen => _isOpen;
  ValueListenable<double> get animationProgress => _animationProgress;
  ValueListenable<bool> get drawerVisible => _drawerVisible;

  Future<bool> open() => _request(true);

  Future<bool> close() => _request(false);

  Future<bool> toggle() => _request(!_isOpen);

  Future<bool> _request(bool open) async {
    final revision = ++_requestRevision;
    _synchronize(open);
    final transition = _transition;
    final settled = transition == null ? true : await transition(open);
    return revision == _requestRevision && _isOpen == open && settled;
  }

  void _synchronize(bool open, {bool feedback = true}) {
    if (_isOpen == open) return;
    _isOpen = open;
    if (feedback) unawaited(HapticFeedback.selectionClick());
    notifyListeners();
  }

  void _setAnimationProgress(double progress) {
    if (_animationProgress.value == progress) return;
    _animationProgress.value = progress;
    final visible = progress > 0.0001;
    if (_drawerVisible.value != visible) _drawerVisible.value = visible;
  }

  /// Invalidates outstanding requests when the transient drawer disappears
  /// because the shell has switched to its persistent desktop navigation.
  void _resetClosed() {
    _requestRevision++;
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  void _attach(Future<bool> Function(bool open) transition) {
    _transition = transition;
  }

  void _detach(Future<bool> Function(bool open) transition) {
    if (identical(_transition, transition)) _transition = null;
  }

  @override
  void dispose() {
    _animationProgress.dispose();
    _drawerVisible.dispose();
    super.dispose();
  }
}

/// The persistent navigation shown on wide windows.
///
/// This deliberately shares the same destinations and callbacks as the mobile
/// drawer, but presents the high-frequency destinations first so a desktop
/// user can switch sections without opening a transient surface.
class ZhDesktopSidebar extends StatelessWidget {
  const ZhDesktopSidebar({
    super.key,
    required this.session,
    required this.selectedNavigationIndex,
    required this.onNavigationSelected,
    required this.onColumns,
    required this.onTopicCategories,
    required this.onHotTopics,
    required this.onHistory,
    required this.onNotifications,
    required this.onCollections,
    required this.onUsers,
    required this.onSettings,
  });

  final SessionStore session;
  final int selectedNavigationIndex;
  final ValueChanged<int> onNavigationSelected;
  final VoidCallback onColumns;
  final VoidCallback onTopicCategories;
  final VoidCallback onHotTopics;
  final VoidCallback onHistory;
  final VoidCallback onNotifications;
  final VoidCallback onCollections;
  final VoidCallback onUsers;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Material(
    key: const ValueKey('desktop-side-navigation'),
    color: ZhPalette.background,
    child: SizedBox(
      width: 264,
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 20, 18),
              child: Row(
                children: [
                  const ZhBrandMark(size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '知阅',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
                children: [
                  const _DesktopSectionLabel('工作区'),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-recommend'),
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: '推荐',
                    selected: selectedNavigationIndex == 0,
                    shortcut: '⌘/Ctrl 1',
                    onTap: () => onNavigationSelected(0),
                  ),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-search'),
                    icon: Icons.search,
                    label: '搜索',
                    selected: selectedNavigationIndex == 1,
                    shortcut: '⌘/Ctrl 2',
                    onTap: () => onNavigationSelected(1),
                  ),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-bookshelf'),
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book,
                    label: '书架',
                    selected: selectedNavigationIndex == 2,
                    shortcut: '⌘/Ctrl 3',
                    onTap: () => onNavigationSelected(2),
                  ),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-account'),
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: '我',
                    selected: selectedNavigationIndex == 3,
                    shortcut: '⌘/Ctrl 4',
                    onTap: () => onNavigationSelected(3),
                  ),
                  const SizedBox(height: 16),
                  const _DesktopSectionLabel('浏览'),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-columns'),
                    icon: Icons.view_column_outlined,
                    label: '专栏推荐',
                    onTap: onColumns,
                  ),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-topic-categories'),
                    icon: Icons.category_outlined,
                    label: '话题分类',
                    onTap: onTopicCategories,
                  ),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-hot-topics'),
                    icon: Icons.local_fire_department_outlined,
                    label: '热门话题',
                    onTap: onHotTopics,
                  ),
                  AnimatedBuilder(
                    animation: session.browsingHistoryChanges,
                    builder: (context, _) => _DesktopNavTile(
                      key: const ValueKey('desktop-nav-history'),
                      icon: Icons.history_rounded,
                      label: '历史记录',
                      badge: session.browsingHistory.isEmpty
                          ? null
                          : '${session.browsingHistory.length}',
                      onTap: onHistory,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _DesktopSectionLabel('我的内容'),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-notifications'),
                    icon: Icons.notifications_none_rounded,
                    label: '消息',
                    onTap: onNotifications,
                  ),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-collections'),
                    icon: Icons.star_border_rounded,
                    label: '收藏',
                    onTap: onCollections,
                  ),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-users'),
                    icon: Icons.person_search_outlined,
                    label: '查找用户',
                    onTap: onUsers,
                  ),
                  const SizedBox(height: 16),
                  const _DesktopSectionLabel('应用'),
                  _DesktopNavTile(
                    key: const ValueKey('desktop-nav-settings'),
                    icon: Icons.tune_rounded,
                    label: '设置',
                    onTap: onSettings,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '知阅 $zhiyueVersionName',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: ZhPalette.subtleInk),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DesktopSectionLabel extends StatelessWidget {
  const _DesktopSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 7, 14, 6),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: ZhPalette.subtleInk,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _DesktopNavTile extends StatefulWidget {
  const _DesktopNavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selectedIcon,
    this.selected = false,
    this.badge,
    this.shortcut,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? badge;
  final String? shortcut;

  @override
  State<_DesktopNavTile> createState() => _DesktopNavTileState();
}

class _DesktopNavTileState extends State<_DesktopNavTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final foreground = widget.selected ? ZhPalette.background : ZhPalette.ink;
    final iconColor = widget.selected
        ? ZhPalette.background
        : ZhPalette.mutedInk;
    final background = widget.selected
        ? ZhPalette.ink
        : _focused
        ? ZhPalette.pressed
        : Colors.transparent;
    final tile = Material(
      color: background,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(15),
        focusColor: Colors.transparent,
        hoverColor: widget.selected
            ? ZhPalette.ink
            : ZhPalette.pressed.withValues(alpha: .72),
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  widget.selectedIcon != null && widget.selected
                      ? widget.selectedIcon
                      : widget.icon,
                  size: 21,
                  color: iconColor,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: widget.selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.shortcut != null && widget.selected)
                  Text(
                    widget.shortcut!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ZhPalette.background.withValues(alpha: .72),
                      fontSize: 9,
                    ),
                  ),
                if (widget.badge != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: widget.selected
                          ? ZhPalette.background.withValues(alpha: .16)
                          : ZhPalette.canvas,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.badge!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: widget.selected
                            ? ZhPalette.background
                            : ZhPalette.mutedInk,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) {
          if (mounted && _focused != value) setState(() => _focused = value);
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: Semantics(
          selected: widget.selected,
          button: true,
          label: widget.shortcut == null
              ? widget.label
              : '${widget.label}，${widget.shortcut}',
          child: tile,
        ),
      ),
    );
  }
}
