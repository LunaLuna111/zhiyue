import 'package:flutter/material.dart';

import '../core/account_session_store.dart';
import '../core/app_version.dart';
import '../core/session_store.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';

void _ignoreDrawerAccount(String _) {}

class ZhAppDrawer extends StatelessWidget {
  const ZhAppDrawer({
    super.key,
    required this.session,
    this.accountStore,
    required this.selectedNavigationIndex,
    required this.onColumns,
    required this.onTopicCategories,
    required this.onHotTopics,
    required this.onHistory,
    required this.onNotifications,
    required this.onCollections,
    required this.onBookshelf,
    required this.onUsers,
    required this.onSettings,
    this.onAccountSelected = _ignoreDrawerAccount,
    this.onManageAccounts = _ignoreDrawerAction,
    this.onClose,
  });

  final SessionStore session;
  final AccountSessionStore? accountStore;
  final int selectedNavigationIndex;
  final VoidCallback onColumns;
  final VoidCallback onTopicCategories;
  final VoidCallback onHotTopics;
  final VoidCallback onHistory;
  final VoidCallback onNotifications;
  final VoidCallback onCollections;
  final VoidCallback onBookshelf;
  final VoidCallback onUsers;
  final VoidCallback onSettings;
  final ValueChanged<String> onAccountSelected;
  final VoidCallback onManageAccounts;
  final VoidCallback? onClose;

  AccountSessionStore get _accountStore =>
      accountStore ?? AccountSessionStore.instance;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final preferredDrawerWidth = (screenWidth * .86)
        .clamp(300.0, 368.0)
        .toDouble();
    final drawerWidth = preferredDrawerWidth.clamp(0.0, screenWidth).toDouble();
    // This surface is hosted by ZhAdaptiveHomeShell rather than Scaffold's
    // DrawerController.  Using Drawer with an explicit zero-radius shape makes
    // Material take its shaped (and clipped) rendering path.  A plain canvas
    // Material stays rectangular by default and preserves the fast path while
    // still providing the InkWell ancestor needed by each destination.
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: MaterialLocalizations.of(context).drawerLabel,
      child: SizedBox(
        key: const ValueKey('app-side-drawer'),
        width: drawerWidth,
        child: Material(
          type: MaterialType.canvas,
          color: ZhPalette.background,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 14, 10),
                  child: Row(
                    children: [
                      const Spacer(),
                      ZhLiquidGlassIconButton(
                        key: const ValueKey('close-side-drawer'),
                        semanticLabel: '关闭侧边栏',
                        size: 46,
                        onPressed:
                            onClose ?? () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                    children: [
                      const _DrawerSectionLabel('浏览'),
                      _DrawerTile(
                        key: const ValueKey('drawer-columns'),
                        icon: Icons.view_column_outlined,
                        label: '专栏推荐',
                        onTap: onColumns,
                      ),
                      _DrawerTile(
                        key: const ValueKey('drawer-topic-categories'),
                        icon: Icons.category_outlined,
                        label: '话题分类',
                        onTap: onTopicCategories,
                      ),
                      _DrawerTile(
                        key: const ValueKey('drawer-hot-topics'),
                        icon: Icons.local_fire_department_outlined,
                        label: '热门话题',
                        onTap: onHotTopics,
                      ),
                      AnimatedBuilder(
                        animation: session.browsingHistoryChanges,
                        builder: (context, _) => _DrawerTile(
                          key: const ValueKey('drawer-history'),
                          icon: Icons.history_rounded,
                          label: '历史记录',
                          badge: session.browsingHistory.isEmpty
                              ? null
                              : '${session.browsingHistory.length}',
                          onTap: onHistory,
                        ),
                      ),
                      const SizedBox(height: 13),
                      const _DrawerSectionLabel('我的内容'),
                      _DrawerTile(
                        key: const ValueKey('drawer-notifications'),
                        icon: Icons.notifications_none_rounded,
                        label: '消息',
                        onTap: onNotifications,
                      ),
                      _DrawerTile(
                        key: const ValueKey('drawer-collections'),
                        icon: Icons.star_border_rounded,
                        label: '收藏',
                        onTap: onCollections,
                      ),
                      _DrawerTile(
                        key: const ValueKey('drawer-bookshelf'),
                        icon: Icons.menu_book_outlined,
                        selected: selectedNavigationIndex == 2,
                        label: '书架',
                        onTap: onBookshelf,
                      ),
                      _DrawerTile(
                        key: const ValueKey('drawer-users'),
                        icon: Icons.person_search_outlined,
                        label: '查找用户',
                        onTap: onUsers,
                      ),
                      const SizedBox(height: 13),
                      AnimatedBuilder(
                        animation: _accountStore,
                        builder: (context, _) {
                          if (_accountStore.accounts.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              _DrawerAccounts(
                                store: _accountStore,
                                onAccountSelected: onAccountSelected,
                                onManageAccounts: onManageAccounts,
                              ),
                              const SizedBox(height: 13),
                            ],
                          );
                        },
                      ),
                      const _DrawerSectionLabel('应用'),
                      _DrawerTile(
                        key: const ValueKey('drawer-settings'),
                        icon: Icons.tune_rounded,
                        label: '设置',
                        onTap: onSettings,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
                  child: Row(
                    children: [
                      Text(
                        '知阅 $zhiyueVersionName',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _ignoreDrawerAction() {}

class _DrawerAccounts extends StatelessWidget {
  const _DrawerAccounts({
    required this.store,
    required this.onAccountSelected,
    required this.onManageAccounts,
  });

  final AccountSessionStore store;
  final ValueChanged<String> onAccountSelected;
  final VoidCallback onManageAccounts;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _DrawerSectionLabel('账号'),
      for (final account in store.accounts)
        _DrawerTile(
          key: ValueKey('drawer-account-${account.id}'),
          icon: account.isQr
              ? Icons.qr_code_2_rounded
              : Icons.account_circle_outlined,
          label: account.displayName,
          selected: account.id == store.activeId,
          badge: account.isExpired && !account.isQr ? '过期' : null,
          onTap: () => onAccountSelected(account.id),
        ),
      _DrawerTile(
        key: const ValueKey('drawer-account-manager'),
        icon: Icons.manage_accounts_outlined,
        label: store.accounts.isEmpty ? '登录或添加账号' : '账号管理',
        onTap: onManageAccounts,
      ),
    ],
  );
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.label);

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

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? badge;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Material(
      color: selected ? ZhPalette.ink : Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: SizedBox(
          height: 54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: selected ? ZhPalette.background : ZhPalette.mutedInk,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? ZhPalette.background : ZhPalette.ink,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? ZhPalette.background.withValues(alpha: .16)
                          : ZhPalette.canvas,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected
                            ? ZhPalette.background
                            : ZhPalette.mutedInk,
                      ),
                    ),
                  ),
                if (badge == null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: selected
                        ? ZhPalette.background.withValues(alpha: .78)
                        : ZhPalette.subtleInk,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
