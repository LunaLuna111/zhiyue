import 'package:flutter/widgets.dart';

import '../core/account_session_store.dart';
import '../core/content_filter_stats.dart';
import '../core/session_store.dart';
import 'generated/app_localizations.dart';
import 'generated/app_localizations_zh.dart';

export 'generated/app_localizations.dart';

final AppLocalizations _defaultZhLocalizations = AppLocalizationsZh();

extension ZhLocalizationContext on BuildContext {
  AppLocalizations get zhL10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      _defaultZhLocalizations;
}

extension ZhHomeFeedChannelLocalization on HomeFeedChannel {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    HomeFeedChannel.following => l10n.feedFollowing,
    HomeFeedChannel.recommend => l10n.feedRecommend,
    HomeFeedChannel.hot => l10n.feedHot,
    HomeFeedChannel.story => l10n.feedStory,
  };
}

String localizedAccountDisplayName(
  AppLocalizations l10n,
  StoredAccountSession account,
) {
  final name = account.displayName.trim();
  final identity = account.accountUid.isNotEmpty
      ? account.accountUid
      : account.accountUserId.isNotEmpty
      ? account.accountUserId
      : account.id;
  final isGeneratedName =
      name.isEmpty || name == '知乎账号' || name.startsWith('账号 ');
  if (!isGeneratedName) return name;
  if (identity.isEmpty) return l10n.accountDefaultName;
  final shortPrefixLength = identity.length < 2 ? identity.length : 2;
  final masked = identity.length <= 8
      ? '${identity.substring(0, shortPrefixLength)}…'
      : '${identity.substring(0, 3)}…${identity.substring(identity.length - 3)}';
  return l10n.accountMaskedName(masked);
}

String localizedContentFilterSummary(
  AppLocalizations l10n,
  ContentFilterStats stats,
) {
  if (stats.totalActions == 0) return l10n.contentFilterSummaryEmpty;
  return l10n.contentFilterSummary(
    stats.totalActions.toString(),
    stats.removedItems.toString(),
    stats.distinctReasons.toString(),
  );
}

String localizedWebDavError(AppLocalizations l10n, String error) =>
    switch (error) {
      'WebDAV 地址无效' => l10n.webdavInvalidEndpoint,
      'WebDAV 地址必须使用 HTTPS' => l10n.webdavHttpsRequired,
      'WebDAV 地址不能包含账号、密码、查询参数或片段' => l10n.webdavEndpointCredentials,
      'WebDAV 凭据不能包含换行或控制字符' => l10n.webdavCredentialCharacters,
      '远程目录无效' => l10n.webdavInvalidDirectory,
      '账号密码认证需要填写用户名' => l10n.webdavUsernameRequired,
      '请填写密码、应用专用密码或访问令牌' => l10n.webdavSecretRequired,
      '访问凭据过长' => l10n.webdavCredentialTooLong,
      'WebDAV 同步未启用' => l10n.webdavSyncNotEnabled,
      _ => error,
    };

String localizedWebDavStatusMessage(AppLocalizations l10n, String message) {
  final value = message.trim();
  switch (value) {
    case '正在读取 WebDAV 设置':
      return l10n.webdavLoading;
    case 'WebDAV 已配置':
      return l10n.webdavConfiguredStatus;
    case '尚未配置 WebDAV':
      return l10n.webdavNotConfigured;
    case 'WebDAV 设置已保存':
      return l10n.webdavSettingsSaved;
    case 'WebDAV 已关闭':
      return l10n.webdavClosedStatus;
    case '正在测试 WebDAV 连接':
      return l10n.webdavTesting;
    case 'WebDAV 连接成功':
      return l10n.webdavConnected;
    case '正在同步搜索、历史、小说和回答缓存':
      return l10n.webdavSyncing;
  }
  final completed = RegExp(r'^同步完成：上传 (\d+) 项，恢复 (\d+) 项$').firstMatch(value);
  if (completed != null) {
    return l10n.webdavSyncCompleted(completed.group(1)!, completed.group(2)!);
  }
  for (final prefix in const ['WebDAV 配置无效：', 'WebDAV 连接失败：', 'WebDAV 同步失败：']) {
    if (!value.startsWith(prefix)) continue;
    final detail = localizedWebDavError(l10n, value.substring(prefix.length));
    return switch (prefix) {
      'WebDAV 配置无效：' => l10n.webdavConfigFailed(detail),
      'WebDAV 连接失败：' => l10n.webdavConnectionFailed(detail),
      _ => l10n.webdavSyncFailed(detail),
    };
  }
  return localizedWebDavError(l10n, value);
}
