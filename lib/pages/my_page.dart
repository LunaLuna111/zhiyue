import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api_client.dart';
import '../core/app_locale.dart';
import '../core/app_version.dart';
import '../core/content_filter_stats.dart';
import '../core/recommendation_behavior.dart';
import '../core/recommendation_engine.dart';
import '../core/salt_chapter_cache.dart';
import '../core/session_store.dart';
import '../core/webdav_sync_service.dart';
import '../l10n/zh_localization.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import 'app_update_page.dart';
import 'account_sessions_page.dart';
import 'diagnostic_logs_page.dart';
import 'content_filter_stats_page.dart';
import 'recommendation_behavior_page.dart';
import 'webdav_sync_page.dart';

enum _SettingsCategory {
  appearance,
  personalization,
  backup,
  account,
  logs,
  about,
  updates,
  data,
}

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
              child: Text(context.zhL10n.commonCancel),
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

  Future<void> _openGithubRepository() async {
    final opened = await launchUrl(
      Uri.parse('https://github.com/LunaLuna111/zhiyue'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showMessage(context.zhL10n.settingsGithubOpenFailed);
    }
  }

  Future<void> _toggleSearchHistory(bool enabled) async {
    if (!enabled && session.searchHistory.isNotEmpty) {
      final confirmed = await _confirm(
        title: context.zhL10n.settingsDisableSearchHistoryTitle,
        message: context.zhL10n.settingsDisableSearchHistoryMessage,
        action: context.zhL10n.settingsDisableAndClear,
      );
      if (!confirmed) return;
    }
    await session.setRememberSearchHistory(enabled);
  }

  Future<void> _clearSearchHistory() async {
    if (session.searchHistory.isEmpty) {
      _showMessage(context.zhL10n.settingsNoSearchHistoryMessage);
      return;
    }
    final confirmed = await _confirm(
      title: context.zhL10n.settingsClearSearchHistoryTitle,
      message: context.zhL10n.settingsClearSearchHistoryMessage,
      action: context.zhL10n.commonClear,
    );
    if (!confirmed) return;
    await session.clearSearchHistory();
    if (mounted) _showMessage(context.zhL10n.settingsSearchHistoryCleared);
  }

  Future<void> _toggleBrowsingHistory(bool enabled) async {
    if (!enabled && session.browsingHistory.isNotEmpty) {
      final confirmed = await _confirm(
        title: context.zhL10n.settingsDisableBrowsingHistoryTitle,
        message: context.zhL10n.settingsDisableBrowsingHistoryMessage,
        action: context.zhL10n.settingsDisableAndClear,
      );
      if (!confirmed) return;
    }
    await session.setRememberBrowsingHistory(enabled);
  }

  Future<void> _clearBrowsingHistory() async {
    if (session.browsingHistory.isEmpty) {
      _showMessage(context.zhL10n.settingsNoBrowsingHistoryMessage);
      return;
    }
    final confirmed = await _confirm(
      title: context.zhL10n.settingsClearBrowsingHistoryTitle,
      message: context.zhL10n.settingsClearBrowsingHistoryMessage,
      action: context.zhL10n.commonClear,
    );
    if (!confirmed) return;
    await session.clearBrowsingHistory();
    if (mounted) _showMessage(context.zhL10n.settingsBrowsingHistoryCleared);
  }

  void _clearImageCache() {
    final cache = PaintingBinding.instance.imageCache;
    final count = cache.currentSize;
    cache
      ..clear()
      ..clearLiveImages();
    setState(() {});
    _showMessage(
      count == 0
          ? context.zhL10n.settingsNoCacheImages
          : context.zhL10n.settingsCachedImages(count),
    );
  }

  Future<void> _clearSaltChapterCache() async {
    final confirmed = await _confirm(
      title: context.zhL10n.settingsClearOfflineTitle,
      message: context.zhL10n.settingsClearOfflineMessage,
      action: context.zhL10n.settingsClearOfflineAction,
    );
    if (!confirmed) return;
    try {
      final count = await SaltChapterCache.instance.clear();
      if (mounted) {
        _showMessage(context.zhL10n.settingsOfflineCleared(count));
      }
    } catch (_) {
      if (mounted) _showMessage(context.zhL10n.settingsOfflineClearFailed);
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
              Text(
                context.zhL10n.settingsFeedOrder,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                context.zhL10n.settingsFeedOrderSubtitle,
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
                          decoration: BoxDecoration(
                            color: ZhPalette.canvas,
                            shape: BoxShape.circle,
                          ),
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          channel.localizedLabel(context.zhL10n),
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
                    child: Text(context.zhL10n.commonReset),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      await session.setHomeFeedOrder(draft);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    child: Text(context.zhL10n.commonSave),
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
      title: context.zhL10n.settingsRestoreDefaults,
      message: context.zhL10n.settingsRestoreDefaultsMessage,
      action: context.zhL10n.commonReset,
    );
    if (!confirmed) return;
    await session.resetAppPreferences();
    if (mounted) _showMessage(context.zhL10n.settingsRestored);
  }

  Future<void> _signOut() async {
    final confirmed = await _confirm(
      title: context.zhL10n.settingsSignOut,
      message: context.zhL10n.settingsSignOutMessage,
      action: context.zhL10n.settingsSignOut,
    );
    if (!confirmed) return;
    await session.clear();
    if (mounted) _showMessage(context.zhL10n.settingsSignedOut);
  }

  String _cacheSummary() {
    final cache = PaintingBinding.instance.imageCache;
    final megabytes = cache.currentSizeBytes / (1024 * 1024);
    if (cache.currentSize == 0) return context.zhL10n.settingsNoCacheImages;
    return context.zhL10n.settingsCacheSummary(
      cache.currentSize,
      megabytes.toStringAsFixed(megabytes < 10 ? 1 : 0),
    );
  }

  String _categoryTitle(BuildContext context, _SettingsCategory category) {
    final l10n = context.zhL10n;
    switch (category) {
      case _SettingsCategory.appearance:
        return l10n.settingsAppearance;
      case _SettingsCategory.personalization:
        return l10n.settingsPersonalization;
      case _SettingsCategory.backup:
        return l10n.settingsBackup;
      case _SettingsCategory.account:
        return l10n.settingsAccount;
      case _SettingsCategory.logs:
        return l10n.settingsLogs;
      case _SettingsCategory.about:
        return l10n.settingsAboutSection;
      case _SettingsCategory.updates:
        return l10n.settingsUpdates;
      case _SettingsCategory.data:
        return l10n.settingsData;
    }
  }

  String _categorySubtitle(BuildContext context, _SettingsCategory category) {
    final l10n = context.zhL10n;
    switch (category) {
      case _SettingsCategory.appearance:
        return l10n.settingsAppearanceSubtitle;
      case _SettingsCategory.personalization:
        return l10n.settingsPersonalizationSubtitle;
      case _SettingsCategory.backup:
        return l10n.settingsBackupSubtitle;
      case _SettingsCategory.account:
        return l10n.settingsAccountSubtitle;
      case _SettingsCategory.logs:
        return l10n.settingsLogsSubtitle;
      case _SettingsCategory.about:
        return l10n.settingsAboutSubtitle;
      case _SettingsCategory.updates:
        return l10n.settingsUpdatesSubtitle;
      case _SettingsCategory.data:
        return l10n.settingsDataSubtitle;
    }
  }

  IconData _categoryIcon(_SettingsCategory category) {
    switch (category) {
      case _SettingsCategory.appearance:
        return Icons.palette_outlined;
      case _SettingsCategory.personalization:
        return Icons.tune_rounded;
      case _SettingsCategory.backup:
        return Icons.cloud_outlined;
      case _SettingsCategory.account:
        return Icons.person_outline;
      case _SettingsCategory.logs:
        return Icons.bug_report_outlined;
      case _SettingsCategory.about:
        return Icons.info_outline;
      case _SettingsCategory.updates:
        return Icons.system_update_alt;
      case _SettingsCategory.data:
        return Icons.storage_outlined;
    }
  }

  void _openCategory(_SettingsCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SettingsCategoryPage(
          title: _categoryTitle(context, category),
          session: session,
          childrenBuilder: (pageContext) =>
              _categoryChildren(pageContext, category),
        ),
      ),
    );
  }

  List<Widget> _categoryChildren(
    BuildContext context,
    _SettingsCategory category,
  ) {
    final l10n = context.zhL10n;
    switch (category) {
      case _SettingsCategory.appearance:
        return [
          _SettingsGroup(
            children: [
              _SwitchTile(
                key: const ValueKey('dark-mode-setting'),
                icon: Icons.dark_mode_outlined,
                title: l10n.settingsDarkMode,
                subtitle: session.darkModeEnabled
                    ? l10n.settingsDarkModeOnSubtitle
                    : l10n.settingsDarkModeOffSubtitle,
                value: session.darkModeEnabled,
                onChanged: session.setDarkModeEnabled,
              ),
              const Divider(),
              _LanguageChoiceTile(
                icon: Icons.translate_rounded,
                title: l10n.settingsLanguage,
                subtitle: l10n.settingsLanguageSubtitle,
                value: session.locale,
                onChanged: session.setLocale,
              ),
              const Divider(),
              _ChoiceTile<ReadingTextSize>(
                icon: Icons.text_fields_rounded,
                title: l10n.settingsTextSize,
                value: session.readingTextSize,
                values: {
                  ReadingTextSize.compact: l10n.settingsSmall,
                  ReadingTextSize.standard: l10n.settingsStandard,
                  ReadingTextSize.large: l10n.settingsLarge,
                },
                onChanged: session.setReadingTextSize,
              ),
              const Divider(),
              _SwitchTile(
                icon: Icons.accessibility_new_rounded,
                title: l10n.settingsFollowSystemTextScale,
                subtitle: l10n.settingsFollowSystemTextScaleSubtitle,
                value: session.followSystemTextScale,
                onChanged: session.setFollowSystemTextScale,
              ),
              const Divider(),
              _SwitchTile(
                icon: Icons.motion_photos_off_outlined,
                title: l10n.settingsReduceMotion,
                subtitle: l10n.settingsReduceMotionSubtitle,
                value: session.reduceMotion,
                onChanged: session.setReduceMotion,
              ),
              const Divider(),
              _SwitchTile(
                icon: Icons.blur_on_outlined,
                title: l10n.settingsGlass,
                subtitle: session.glassEffectsEnabled
                    ? l10n.settingsGlassOnSubtitle
                    : l10n.settingsGlassOffSubtitle,
                value: session.glassEffectsEnabled,
                onChanged: session.setGlassEffectsEnabled,
              ),
            ],
          ),
        ];
      case _SettingsCategory.personalization:
        return [
          _SettingsGroup(
            children: [
              _ChoiceTile<AppStartupPage>(
                icon: Icons.rocket_launch_outlined,
                title: l10n.settingsStartupPage,
                value: session.startupPage,
                values: {
                  AppStartupPage.recommend: l10n.navRecommend,
                  AppStartupPage.bookshelf: l10n.navBookshelf,
                },
                onChanged: session.setStartupPage,
              ),
              const Divider(),
              _ChoiceTile<RecommendationMode>(
                icon: Icons.auto_awesome_outlined,
                title: l10n.settingsRecommendation,
                value: session.recommendationMode,
                values: {
                  RecommendationMode.server: l10n.settingsServer,
                  RecommendationMode.local: l10n.settingsLocal,
                  RecommendationMode.hybrid: l10n.settingsHybrid,
                },
                onChanged: session.setRecommendationMode,
              ),
              const Divider(),
              _ChoiceTile<FeedDensity>(
                icon: Icons.view_agenda_outlined,
                title: l10n.settingsDensity,
                value: session.feedDensity,
                values: {
                  FeedDensity.comfortable: l10n.settingsComfortable,
                  FeedDensity.compact: l10n.settingsCompact,
                },
                onChanged: session.setFeedDensity,
              ),
            ],
          ),
          const SizedBox(height: ZhSpace.sm),
          _SettingsGroup(
            children: [
              _SwitchTile(
                key: const ValueKey('home-reselect-refresh-setting'),
                icon: Icons.vertical_align_top_rounded,
                title: l10n.settingsRefreshHome,
                subtitle: l10n.settingsRefreshHomeSubtitle,
                value: session.refreshHomeOnReselect,
                onChanged: session.setRefreshHomeOnReselect,
              ),
              const Divider(),
              _SwitchTile(
                icon: Icons.image_outlined,
                title: l10n.settingsShowImages,
                subtitle: l10n.settingsShowImagesSubtitle,
                value: session.showFeedImages,
                onChanged: session.setShowFeedImages,
              ),
              const Divider(),
              _SwitchTile(
                icon: Icons.bar_chart_rounded,
                title: l10n.settingsShowMetrics,
                subtitle: l10n.settingsShowMetricsSubtitle,
                value: session.showFeedMetrics,
                onChanged: session.setShowFeedMetrics,
              ),
            ],
          ),
          const SizedBox(height: ZhSpace.sm),
          _SettingsGroup(
            children: [
              _ActionTile(
                key: const ValueKey('recommendation-behavior-setting'),
                icon: Icons.insights_outlined,
                title: l10n.settingsLocalBehavior,
                subtitle: l10n.settingsLocalEvents(
                  RecommendationBehaviorStore.instance.profile.totalEvents,
                ),
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
                title: l10n.settingsFeedOrder,
                subtitle: session.homeFeedOrder
                    .map((channel) => channel.localizedLabel(l10n))
                    .join(' · '),
                onTap: _editHomeFeedOrder,
              ),
              const Divider(),
              AnimatedBuilder(
                animation: ContentFilterStatsStore.instance,
                builder: (context, _) => _ActionTile(
                  key: const ValueKey('content-filter-stats-setting'),
                  icon: Icons.filter_alt_outlined,
                  title: l10n.settingsFilterStats,
                  subtitle: localizedContentFilterSummary(
                    l10n,
                    ContentFilterStatsStore.instance.stats,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ContentFilterStatsPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ZhSpace.sm),
          _SettingsGroup(
            children: [
              _SwitchTile(
                key: const ValueKey('focus-search-on-open-setting'),
                icon: Icons.keyboard_alt_outlined,
                title: l10n.settingsFocusSearch,
                subtitle: session.focusSearchOnOpen
                    ? l10n.settingsFocusSearchOn
                    : l10n.settingsFocusSearchOff,
                value: session.focusSearchOnOpen,
                onChanged: session.setFocusSearchOnOpen,
              ),
            ],
          ),
        ];
      case _SettingsCategory.backup:
        return [
          _SettingsGroup(
            children: [
              AnimatedBuilder(
                animation: _webDav,
                builder: (context, _) => _ActionTile(
                  key: const ValueKey('webdav-sync-setting'),
                  icon: Icons.cloud_sync_outlined,
                  title: l10n.settingsWebDav,
                  subtitle: _webDav.settings?.isConfigured == true
                      ? (_webDav.status.message.isEmpty
                            ? l10n.settingsWebDavConfigured
                            : localizedWebDavStatusMessage(
                                l10n,
                                _webDav.status.message,
                              ))
                      : l10n.settingsWebDavSubtitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WebDavSyncPage(service: _webDav),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ];
      case _SettingsCategory.account:
        final hasAccountFeatures =
            widget.api != null || session.hasAuthorization;
        return [
          _SettingsGroup(
            children: [
              if (widget.api != null)
                _ActionTile(
                  key: const ValueKey('account-sessions-setting'),
                  icon: Icons.devices_other_outlined,
                  title: l10n.settingsAccountSessions,
                  subtitle: l10n.settingsAccountSessionsSubtitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AccountSessionsPage(
                        api: widget.api!,
                        session: session,
                      ),
                    ),
                  ),
                ),
              if (widget.api != null && session.hasAuthorization)
                const Divider(),
              if (session.hasAuthorization)
                _ActionTile(
                  icon: Icons.logout_rounded,
                  title: l10n.settingsSignOut,
                  subtitle: l10n.settingsSignOutSubtitle,
                  destructive: true,
                  onTap: _signOut,
                ),
              if (!hasAccountFeatures)
                _ActionTile(
                  icon: Icons.person_outline,
                  title: l10n.settingsAccountSessions,
                  subtitle: l10n.settingsAccountSessionsSubtitle,
                ),
            ],
          ),
        ];
      case _SettingsCategory.logs:
        return [
          _SettingsGroup(
            children: [
              _ActionTile(
                icon: Icons.bug_report_outlined,
                title: l10n.settingsDiagnostics,
                subtitle: session.appLoggingEnabled
                    ? l10n.settingsDiagnosticsOn
                    : l10n.settingsDiagnosticsOff,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DiagnosticLogsPage(session: session),
                  ),
                ),
              ),
            ],
          ),
        ];
      case _SettingsCategory.about:
        return [
          _SettingsGroup(
            children: [
              _ActionTile(
                icon: Icons.restart_alt_rounded,
                title: l10n.settingsRestoreDefaults,
                subtitle: l10n.settingsRestoreDefaultsSubtitle,
                onTap: _resetPreferences,
              ),
              const Divider(),
              _ActionTile(
                icon: Icons.info_outline_rounded,
                title: l10n.settingsAbout,
                subtitle: l10n.settingsVersion(zhiyueVersionName),
              ),
              const Divider(),
              _ActionTile(
                key: const ValueKey('settings-github-repository'),
                icon: Icons.code_rounded,
                title: l10n.settingsGithub,
                subtitle: l10n.settingsGithubSubtitle,
                onTap: _openGithubRepository,
              ),
            ],
          ),
        ];
      case _SettingsCategory.updates:
        return [
          _SettingsGroup(
            children: [
              _ActionTile(
                key: const ValueKey('app-update-setting'),
                icon: Icons.system_update_alt_rounded,
                title: l10n.settingsUpdate,
                subtitle: l10n.settingsUpdateSubtitle,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppUpdatePage()),
                ),
              ),
            ],
          ),
        ];
      case _SettingsCategory.data:
        return [
          _SettingsGroup(
            children: [
              _SwitchTile(
                icon: Icons.visibility_outlined,
                title: l10n.settingsKeepHistory,
                subtitle: session.rememberBrowsingHistory
                    ? l10n.settingsKeepHistoryOn(session.browsingHistory.length)
                    : l10n.settingsKeepHistoryOff,
                value: session.rememberBrowsingHistory,
                onChanged: _toggleBrowsingHistory,
              ),
              const Divider(),
              _SwitchTile(
                icon: Icons.photo_library_outlined,
                title: l10n.settingsPrefetchImages,
                subtitle: l10n.settingsPrefetchImagesSubtitle,
                value: session.prefetchImages,
                onChanged: session.setPrefetchImages,
              ),
              const Divider(),
              _ChoiceTile<ImageCachePreset>(
                icon: Icons.storage_rounded,
                title: l10n.settingsImageCache,
                value: session.imageCachePreset,
                values: {
                  ImageCachePreset.economy: l10n.settingsEconomy,
                  ImageCachePreset.standard: l10n.settingsStandard,
                  ImageCachePreset.roomy: l10n.settingsRoomy,
                },
                onChanged: session.setImageCachePreset,
              ),
            ],
          ),
          const SizedBox(height: ZhSpace.sm),
          _SettingsGroup(
            children: [
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                title: l10n.settingsClearBrowsing,
                subtitle: session.browsingHistory.isEmpty
                    ? l10n.settingsNoBrowsingHistory
                    : l10n.settingsDeleteBrowsing(
                        session.browsingHistory.length,
                      ),
                onTap: _clearBrowsingHistory,
              ),
              const Divider(),
              _ActionTile(
                icon: Icons.cleaning_services_outlined,
                title: l10n.settingsClearImageCache,
                subtitle: _cacheSummary(),
                onTap: _clearImageCache,
              ),
              const Divider(),
              _ActionTile(
                icon: Icons.auto_stories_outlined,
                title: l10n.settingsClearOfflineChapters,
                subtitle: l10n.settingsClearOfflineChaptersSubtitle,
                onTap: _clearSaltChapterCache,
              ),
            ],
          ),
          const SizedBox(height: ZhSpace.sm),
          _SettingsGroup(
            children: [
              _SwitchTile(
                icon: Icons.history_rounded,
                title: l10n.settingsKeepSearch,
                subtitle: session.rememberSearchHistory
                    ? l10n.settingsKeepSearchOn(session.searchHistory.length)
                    : l10n.settingsKeepSearchOff,
                value: session.rememberSearchHistory,
                onChanged: _toggleSearchHistory,
              ),
              const Divider(),
              _SwitchTile(
                key: const ValueKey('show-search-hot-setting'),
                icon: Icons.local_fire_department_outlined,
                title: l10n.settingsShowHot,
                subtitle: session.showSearchHotSearch
                    ? l10n.settingsShowHotOn
                    : l10n.settingsShowHotOff,
                value: session.showSearchHotSearch,
                onChanged: session.setShowSearchHotSearch,
              ),
              const Divider(),
              _ActionTile(
                icon: Icons.delete_sweep_outlined,
                title: l10n.settingsClearSearch,
                subtitle: session.searchHistory.isEmpty
                    ? l10n.settingsNoSearchHistory
                    : l10n.settingsDeleteSearch(session.searchHistory.length),
                onTap: _clearSearchHistory,
              ),
            ],
          ),
        ];
    }
  }

  Widget _buildSettingsHome(BuildContext context) {
    final topInset = ZhTopBar.bodyTopInset(context, toolbarHeight: 72);
    final categories = _SettingsCategory.values;
    final l10n = context.zhL10n;
    final rows = <Widget>[];
    for (var index = 0; index < categories.length; index++) {
      if (index > 0) rows.add(const Divider());
      final category = categories[index];
      rows.add(
        _ActionTile(
          key: ValueKey('settings-category-${category.name}'),
          icon: _categoryIcon(category),
          title: _categoryTitle(context, category),
          subtitle: _categorySubtitle(context, category),
          onTap: () => _openCategory(category),
        ),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ZhTopBar(
        toolbarHeight: 72,
        leading: ZhLiquidGlassIconButton(
          key: const ValueKey('settings-back'),
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
          semanticLabel: l10n.commonBack,
          size: 46,
          iconSize: 24,
        ),
        title: Text(l10n.settingsTitle),
      ),
      body: ZhPageWidth(
        maxWidth: 680,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            ZhSpace.md,
            topInset + ZhSpace.xs,
            ZhSpace.md,
            ZhSpace.xl,
          ),
          children: [_SettingsGroup(children: rows)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildSettingsHome(context);
}

class _SettingsCategoryPage extends StatelessWidget {
  const _SettingsCategoryPage({
    required this.title,
    required this.session,
    required this.childrenBuilder,
  });

  final String title;
  final SessionStore session;
  final List<Widget> Function(BuildContext context) childrenBuilder;

  @override
  Widget build(BuildContext context) {
    final topInset = ZhTopBar.bodyTopInset(context, toolbarHeight: 72);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ZhTopBar(toolbarHeight: 72, title: Text(title)),
      body: ZhPageWidth(
        maxWidth: 680,
        child: AnimatedBuilder(
          animation: session,
          builder: (context, _) => ListView(
            padding: EdgeInsets.fromLTRB(
              ZhSpace.md,
              topInset + ZhSpace.xs,
              ZhSpace.md,
              ZhSpace.xl,
            ),
            children: childrenBuilder(context),
          ),
        ),
      ),
    );
  }
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: destructive
            ? TextStyle(color: ZhPalette.danger, fontWeight: FontWeight.w700)
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
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: ZhLiquidGlassSwitch(
        value: value,
        onChanged: onChanged,
        semanticLabel: title,
      ),
      onTap: () => onChanged(!value),
    ),
  );
}

class _LanguageChoiceTile extends StatelessWidget {
  const _LanguageChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ZhLocale value;
  final ValueChanged<ZhLocale> onChanged;

  Future<void> _pick(BuildContext context) async {
    final selected = await showModalBottomSheet<ZhLocale>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            for (final locale in ZhLocale.values)
              ListTile(
                selected: locale == value,
                title: Text(locale.nativeName),
                trailing: locale == value
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop(locale),
              ),
          ],
        ),
      ),
    );
    if (selected != null && selected != value) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: ListTile(
      key: const ValueKey('settings-language-setting'),
      minTileHeight: 72,
      leading: _SettingIcon(icon: icon),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 112),
            child: Text(
              value.nativeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(color: ZhPalette.mutedInk),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 22),
        ],
      ),
      onTap: () => _pick(context),
    ),
  );
}

class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final T value;
  final Map<T, String> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final entries = values.entries.toList(growable: false);
      final stacked =
          constraints.maxWidth < 480 || textScale > 1.2 || entries.length > 3;
      final selectedIndex = entries.indexWhere((entry) => entry.key == value);
      final choices = SizedBox(
        key: ValueKey('settings-choice-$title'),
        width: stacked ? double.infinity : entries.length * 80.0,
        child: ZhLiquidGlassSegmentedTabs(
          labels: [for (final entry in entries) entry.value],
          selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
          onSelected: (index) => onChanged(entries[index].key),
          semanticPrefix: '$title：',
          height: 44,
        ),
      );
      final heading = Row(
        children: [
          _SettingIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
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
