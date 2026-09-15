import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/session_store.dart';
import '../core/content_filter_stats.dart';
import '../core/recommendation_behavior.dart';
import '../core/recommendation_engine.dart';
import '../core/salt_chapter_cache.dart';
import '../core/webdav_sync_service.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import 'app_update_page.dart';
import 'account_sessions_page.dart';
import 'diagnostic_logs_page.dart';
import 'content_filter_stats_page.dart';
import 'recommendation_behavior_page.dart';
import 'webdav_sync_page.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({
    super.key,
    required this.session,
    this.api,
    this.webDav,
  });

  final SessionStore session;
  final ZhihuApiClient? api;
  final WebDavSyncService? webDav;

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  SessionStore get session => widget.session;
  late final WebDavSyncService _webDav =
      widget.webDav ?? WebDavSyncService(session: widget.session);

  @override
  void initState() {
    super.initState();
    unawaited(_webDav.loadSettings());
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleSearchHistory(bool enabled) async {
    if (!enabled && session.searchHistory.isNotEmpty) {
      final confirmed = await _confirm(
        title: '关闭搜索记录？',
        message: '关闭后会同时清空本机已有的搜索记录。',
        action: '关闭并清空',
      );
      if (!confirmed) return;
    }
    await session.setRememberSearchHistory(enabled);
  }

  Future<void> _clearSearchHistory() async {
    if (session.searchHistory.isEmpty) {
      _showMessage('目前没有搜索记录');
      return;
    }
    final confirmed = await _confirm(
      title: '清空搜索记录？',
      message: '这只会删除保存在本机的搜索关键词。',
      action: '清空',
    );
    if (!confirmed) return;
    await session.clearSearchHistory();
    if (mounted) _showMessage('搜索记录已清空');
  }

  Future<void> _toggleBrowsingHistory(bool enabled) async {
    if (!enabled && session.browsingHistory.isNotEmpty) {
      final confirmed = await _confirm(
        title: '关闭浏览记录？',
        message: '关闭后会同时清空知阅保存在本机的浏览记录。',
        action: '关闭并清空',
      );
      if (!confirmed) return;
    }
    await session.setRememberBrowsingHistory(enabled);
  }

  Future<void> _clearBrowsingHistory() async {
    if (session.browsingHistory.isEmpty) {
      _showMessage('目前没有浏览记录');
      return;
    }
    final confirmed = await _confirm(
      title: '清空浏览记录？',
      message: '这只会删除知阅保存在本机的浏览内容索引。',
      action: '清空',
    );
    if (!confirmed) return;
    await session.clearBrowsingHistory();
    if (mounted) _showMessage('浏览记录已清空');
  }

  void _clearImageCache() {
    final cache = PaintingBinding.instance.imageCache;
    final count = cache.currentSize;
    cache
      ..clear()
      ..clearLiveImages();
    setState(() {});
    _showMessage(count == 0 ? '图片缓存已经是空的' : '已清理 $count 张缓存图片');
  }

  Future<void> _clearSaltChapterCache() async {
    final confirmed = await _confirm(
      title: '清理离线章节？',
      message: '已缓存的盐选正文将被删除，之后阅读或导出时需要重新下载。',
      action: '清理',
    );
    if (!confirmed) return;
    try {
      final count = await SaltChapterCache.instance.clear();
      if (mounted) _showMessage('已清理 $count 个离线章节');
    } catch (_) {
      if (mounted) _showMessage('离线章节清理失败，请重试');
    }
  }

  Future<void> _editHomeFeedOrder() async {
    var draft = List<HomeFeedChannel>.from(session.homeFeedOrder);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            ZhSpace.md,
            0,
            ZhSpace.md,
            MediaQuery.viewPaddingOf(sheetContext).bottom + ZhSpace.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('首页分区排序', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '按住右侧拖动，首页顶栏与左右滑动顺序会同步更新。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: ZhSpace.md),
              SizedBox(
                height: 4 * 58,
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: draft.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setSheetState(() {
                      final item = draft.removeAt(oldIndex);
                      draft.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final channel = draft[index];
                    return Material(
                      key: ValueKey('home-order-${channel.name}'),
                      color: ZhPalette.background,
                      child: ListTile(
                        minTileHeight: 58,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        leading: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: ZhPalette.canvas,
                            shape: BoxShape.circle,
                          ),
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          channel.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.drag_handle_rounded),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: ZhSpace.sm),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setSheetState(
                      () => draft = List<HomeFeedChannel>.from(
                        SessionStore.defaultHomeFeedOrder,
                      ),
                    ),
                    child: const Text('恢复默认'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      await session.setHomeFeedOrder(draft);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    child: const Text('保存排序'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetPreferences() async {
    final confirmed = await _confirm(
      title: '恢复默认设置？',
      message: '所有设置将恢复默认，不会退出账号。',
      action: '恢复默认',
    );
    if (!confirmed) return;
    await session.resetAppPreferences();
    if (mounted) _showMessage('软件设置已恢复默认');
  }

  Future<void> _signOut() async {
    final confirmed = await _confirm(
      title: '退出登录？',
      message: '本机保存的登录信息将被删。',
      action: '退出',
    );
    if (!confirmed) return;
    await session.clear();
    if (mounted) _showMessage('已退出登录');
  }

  String _cacheSummary() {
    final cache = PaintingBinding.instance.imageCache;
    final megabytes = cache.currentSizeBytes / (1024 * 1024);
    if (cache.currentSize == 0) return '当前没有缓存图片';
    return '${cache.currentSize} 张 · ${megabytes.toStringAsFixed(megabytes < 10 ? 1 : 0)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ZhPageWidth(
        maxWidth: 680,
        child: AnimatedBuilder(
          animation: session,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(
              ZhSpace.md,
              ZhSpace.xs,
              ZhSpace.md,
              ZhSpace.xl,
            ),
            children: [
              const _SectionLabel('首页与内容'),
              _SettingsGroup(
                children: [
                  _ChoiceTile<AppStartupPage>(
                    icon: Icons.rocket_launch_outlined,
                    title: '启动页面',
                    value: session.startupPage,
                    values: const {
                      AppStartupPage.recommend: '推荐',
                      AppStartupPage.bookshelf: '书架',
                    },
                    onChanged: session.setStartupPage,
                  ),
                  const Divider(),
                  _ChoiceTile<RecommendationMode>(
                    icon: Icons.auto_awesome_outlined,
                    title: '推荐策略',
                    value: session.recommendationMode,
                    values: const {
                      RecommendationMode.server: '服务器',
                      RecommendationMode.local: '本地',
                      RecommendationMode.hybrid: '混合',
                    },
                    onChanged: session.setRecommendationMode,
                  ),
                  const Divider(),
                  _ActionTile(
                    key: const ValueKey('recommendation-behavior-setting'),
                    icon: Icons.insights_outlined,
                    title: '本地推荐行为',
                    subtitle:
                        '本机已记录 ${RecommendationBehaviorStore.instance.profile.totalEvents} 条行为',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RecommendationBehaviorPage(),
                      ),
                    ),
                  ),
                  const Divider(),
                  _ActionTile(
                    key: const ValueKey('home-feed-order-setting'),
                    icon: Icons.swap_vert_rounded,
                    title: '首页分区排序',
                    subtitle: session.homeFeedOrder
                        .map((channel) => channel.label)
                        .join(' · '),
                    onTap: _editHomeFeedOrder,
                  ),
                  const Divider(),
                  _SwitchTile(
                    key: const ValueKey('home-reselect-refresh-setting'),
                    icon: Icons.vertical_align_top_rounded,
                    title: '重复点击首页时刷新',
                    subtitle: '再次点击已选中的首页按钮时回到顶部并刷新',
                    value: session.refreshHomeOnReselect,
                    onChanged: session.setRefreshHomeOnReselect,
                  ),
                  const Divider(),
                  _ChoiceTile<FeedDensity>(
                    icon: Icons.view_agenda_outlined,
                    title: '内容密度',
                    value: session.feedDensity,
                    values: const {
                      FeedDensity.comfortable: '舒适',
                      FeedDensity.compact: '紧凑',
                    },
                    onChanged: session.setFeedDensity,
                  ),
                  const Divider(),
                  _SwitchTile(
                    icon: Icons.image_outlined,
                    title: '显示推荐图片',
                    subtitle: '关闭后首页只显示文字、作者和互动信息',
                    value: session.showFeedImages,
                    onChanged: session.setShowFeedImages,
                  ),
                  const Divider(),
                  _SwitchTile(
                    icon: Icons.bar_chart_rounded,
                    title: '显示互动数据',
                    subtitle: '显示赞同、收藏、评论和发布日期',
                    value: session.showFeedMetrics,
                    onChanged: session.setShowFeedMetrics,
                  ),
                  const Divider(),
                  AnimatedBuilder(
                    animation: ContentFilterStatsStore.instance,
                    builder: (context, _) => _ActionTile(
                      key: const ValueKey('content-filter-stats-setting'),
                      icon: Icons.filter_alt_outlined,
                      title: '内容过滤统计',
                      subtitle:
                          ContentFilterStatsStore.instance.stats.summaryLabel,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ContentFilterStatsPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const _SectionLabel('阅读与显示'),
              _SettingsGroup(
                children: [
                  _ChoiceTile<ReadingTextSize>(
                    icon: Icons.text_fields_rounded,
                    title: '阅读字号',
                    value: session.readingTextSize,
                    values: const {
                      ReadingTextSize.compact: '小',
                      ReadingTextSize.standard: '标准',
                      ReadingTextSize.large: '大',
                    },
                    onChanged: session.setReadingTextSize,
                  ),
                  const Divider(),
                  _SwitchTile(
                    icon: Icons.accessibility_new_rounded,
                    title: '跟随系统字号',
                    subtitle: '在阅读字号基础上叠加系统显示大小',
                    value: session.followSystemTextScale,
                    onChanged: session.setFollowSystemTextScale,
                  ),
                  const Divider(),
                  _SwitchTile(
                    icon: Icons.motion_photos_off_outlined,
                    title: '减少动态效果',
                    subtitle: '减少页面切换和组件动画',
                    value: session.reduceMotion,
                    onChanged: session.setReduceMotion,
                  ),
                ],
              ),
              const _SectionLabel('图片与存储'),
              _SettingsGroup(
                children: [
                  _SwitchTile(
                    icon: Icons.visibility_outlined,
                    title: '保留浏览记录',
                    subtitle: session.rememberBrowsingHistory
                        ? '仅保存在本机 · ${session.browsingHistory.length} 条'
                        : '打开内容不会写入本机历史',
                    value: session.rememberBrowsingHistory,
                    onChanged: _toggleBrowsingHistory,
                  ),
                  const Divider(),
                  _ActionTile(
                    icon: Icons.delete_outline_rounded,
                    title: '清空浏览记录',
                    subtitle: session.browsingHistory.isEmpty
                        ? '目前没有记录'
                        : '删除 ${session.browsingHistory.length} 条本机记录',
                    onTap: _clearBrowsingHistory,
                  ),
                  const Divider(),
                  _SwitchTile(
                    icon: Icons.photo_library_outlined,
                    title: '预加载列表图片',
                    subtitle: '提前加载即将显示的头像和正文图片',
                    value: session.prefetchImages,
                    onChanged: session.setPrefetchImages,
                  ),
                  const Divider(),
                  _ChoiceTile<ImageCachePreset>(
                    icon: Icons.storage_rounded,
                    title: '图片缓存容量',
                    value: session.imageCachePreset,
                    values: const {
                      ImageCachePreset.economy: '节省',
                      ImageCachePreset.standard: '标准',
                      ImageCachePreset.roomy: '充足',
                    },
                    onChanged: session.setImageCachePreset,
                  ),
                  const Divider(),
                  _ActionTile(
                    icon: Icons.cleaning_services_outlined,
                    title: '清理图片缓存',
                    subtitle: _cacheSummary(),
                    onTap: _clearImageCache,
                  ),
                  const Divider(),
                  _ActionTile(
                    icon: Icons.auto_stories_outlined,
                    title: '清理离线章节',
                    subtitle: '删除阅读和下载时保存的盐选正文',
                    onTap: _clearSaltChapterCache,
                  ),
                ],
              ),
              const _SectionLabel('隐私与数据'),
              _SettingsGroup(
                children: [
                  _SwitchTile(
                    icon: Icons.history_rounded,
                    title: '保留搜索记录',
                    subtitle: session.rememberSearchHistory
                        ? '仅保存在本机 · ${session.searchHistory.length} 条'
                        : '新搜索不会写入本机',
                    value: session.rememberSearchHistory,
                    onChanged: _toggleSearchHistory,
                  ),
                  const Divider(),
                  _SwitchTile(
                    key: const ValueKey('show-search-hot-setting'),
                    icon: Icons.local_fire_department_outlined,
                    title: '显示热搜',
                    subtitle: session.showSearchHotSearch
                        ? '在搜索页显示知乎热搜'
                        : '搜索页不加载热搜内容',
                    value: session.showSearchHotSearch,
                    onChanged: session.setShowSearchHotSearch,
                  ),
                  const Divider(),
                  _ActionTile(
                    icon: Icons.delete_sweep_outlined,
                    title: '清空搜索记录',
                    subtitle: session.searchHistory.isEmpty
                        ? '目前没有记录'
                        : '删除 ${session.searchHistory.length} 条本机记录',
                    onTap: _clearSearchHistory,
                  ),
                  const Divider(),
                  AnimatedBuilder(
                    animation: _webDav,
                    builder: (context, _) => _ActionTile(
                      key: const ValueKey('webdav-sync-setting'),
                      icon: Icons.cloud_sync_outlined,
                      title: 'WebDAV 同步',
                      subtitle: _webDav.settings?.isConfigured == true
                          ? (_webDav.status.message.isEmpty
                                ? '已配置 · 搜索、历史、离线小说和回答缓存'
                                : _webDav.status.message)
                          : '同步搜索记录、浏览历史、离线小说和回答缓存',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WebDavSyncPage(service: _webDav),
                        ),
                      ),
                    ),
                  ),
                  if (widget.api != null) ...[
                    const Divider(),
                    _ActionTile(
                      key: const ValueKey('account-sessions-setting'),
                      icon: Icons.devices_other_outlined,
                      title: '账号与多端登录',
                      subtitle: '扫码登录、保存账号槽位并快速切换',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AccountSessionsPage(
                            api: widget.api!,
                            session: session,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (session.hasAuthorization) ...[
                    const Divider(),
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      title: '退出登录',
                      subtitle: '移除本机登录信息',
                      destructive: true,
                      onTap: _signOut,
                    ),
                  ],
                ],
              ),
              const _SectionLabel('其他'),
              _SettingsGroup(
                children: [
                  _ActionTile(
                    icon: Icons.bug_report_outlined,
                    title: '诊断日志',
                    subtitle: session.appLoggingEnabled
                        ? '已开启 · 管理网络、性能日志并导出'
                        : '定位接口异常、内容加载失败和卡顿问题',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DiagnosticLogsPage(session: session),
                      ),
                    ),
                  ),
                  const Divider(),
                  _ActionTile(
                    key: const ValueKey('app-update-setting'),
                    icon: Icons.system_update_alt_rounded,
                    title: '软件更新',
                    subtitle: '安全检查、下载并安装新版本',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AppUpdatePage()),
                    ),
                  ),
                  const Divider(),
                  _ActionTile(
                    icon: Icons.restart_alt_rounded,
                    title: '恢复默认设置',
                    subtitle: '不会退出账号',
                    onTap: _resetPreferences,
                  ),
                  const Divider(),
                  const _ActionTile(
                    icon: Icons.info_outline_rounded,
                    title: '关于知阅',
                    subtitle: '版本 0.3.10',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
    child: Text(label, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ZhSurface(
    padding: EdgeInsets.zero,
    radius: 22,
    child: Column(children: children),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      minTileHeight: 72,
      leading: _SettingIcon(icon: icon, destructive: destructive),
      title: Text(
        title,
        style: destructive
            ? const TextStyle(
                color: ZhPalette.danger,
                fontWeight: FontWeight.w700,
              )
            : null,
      ),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right_rounded, size: 22),
      onTap: onTap,
    ),
  );
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      minTileHeight: 72,
      leading: _SettingIcon(icon: icon),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    ),
  );
}

class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final T value;
  final Map<T, String> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final stacked = constraints.maxWidth < 340 || textScale > 1.2;
      final choices = Container(
        key: ValueKey('settings-choice-$title'),
        width: stacked ? double.infinity : null,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: ZhPalette.canvas,
          borderRadius: BorderRadius.circular(ZhRadius.pill),
        ),
        child: Row(
          mainAxisSize: stacked ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (final entry in values.entries)
              if (stacked)
                Expanded(
                  child: _ChoiceButton(
                    label: entry.value,
                    selected: entry.key == value,
                    onTap: () => onChanged(entry.key),
                  ),
                )
              else
                _ChoiceButton(
                  label: entry.value,
                  selected: entry.key == value,
                  onTap: () => onChanged(entry.key),
                ),
          ],
        ),
      );
      final heading = Row(
        children: [
          _SettingIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      );
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [heading, const SizedBox(height: 12), choices],
              )
            : Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 10),
                  choices,
                ],
              ),
      );
    },
  );
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ZhRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? ZhPalette.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(ZhRadius.pill),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? ZhPalette.background : ZhPalette.mutedInk,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon, this.destructive = false});

  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: destructive ? ZhPalette.dangerSurface : ZhPalette.canvas,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      icon,
      size: 20,
      color: destructive ? ZhPalette.danger : ZhPalette.ink,
    ),
  );
}
