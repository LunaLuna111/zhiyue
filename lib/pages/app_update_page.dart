import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_update_service.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';

class AppUpdatePage extends StatefulWidget {
  const AppUpdatePage({super.key, this.service});

  final AppUpdateService? service;

  @override
  State<AppUpdatePage> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends State<AppUpdatePage> {
  late final AppUpdateService _service = widget.service ?? AppUpdateService();
  late final bool _ownsService = widget.service == null;
  AppUpdateCheck? _check;
  String? _error;
  bool _checking = false;
  bool _installing = false;
  bool _cancelled = false;
  int _received = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_checkNow());
  }

  @override
  void dispose() {
    _cancelled = true;
    if (_ownsService) _service.close();
    super.dispose();
  }

  Future<void> _checkNow() async {
    if (_checking || _installing) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final result = await _service.check();
      if (mounted) setState(() => _check = result);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AppUpdateException
              ? error.message
              : '检查更新失败，请稍后重试',
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _install() async {
    final check = _check;
    if (check == null || !check.updateAvailable || _installing) return;
    if (!await _service.canInstallPackages()) {
      if (!mounted) return;
      final open = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('允许安装应用'),
          content: const Text('Android 需要你允许知阅安装下载的更新。开启后返回此页，再点一次下载并安装。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('前往设置'),
            ),
          ],
        ),
      );
      if (open == true) await _service.openInstallPermission();
      return;
    }
    setState(() {
      _installing = true;
      _cancelled = false;
      _received = 0;
      _total = check.release!.packageSize;
      _error = null;
    });
    try {
      final reusedCachedPackage = await _service.downloadAndInstall(
        check,
        onProgress: (received, total) {
          if (mounted) {
            setState(() {
              _received = received;
              _total = total;
            });
          }
        },
        isCancelled: () => _cancelled,
      );
      if (mounted) {
        setState(() {
          _check = AppUpdateCheck(
            installed: check.installed,
            release: check.release,
            cachedPackageAvailable: true,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reusedCachedPackage
                  ? '已使用下载好的更新包，正在打开 Android 安装器'
                  : '更新已验证，正在打开 Android 安装器',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AppUpdateException
              ? error.message
              : '更新安装失败，请重试',
        );
      }
    } finally {
      if (mounted) setState(() => _installing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final check = _check;
    final release = check?.release;
    final progress = _total <= 0 ? 0.0 : (_received / _total).clamp(0.0, 1.0);
    return Scaffold(
      appBar: ZhTopBar(title: const Text('软件更新')),
      body: ZhPageWidth(
        maxWidth: 680,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            ZhSpace.md,
            ZhSpace.md,
            ZhSpace.md,
            ZhSpace.xl,
          ),
          children: [
            ZhSurface(
              radius: 24,
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: ZhPalette.canvas,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: ZhSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '知阅',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          check == null
                              ? '正在读取版本信息'
                              : '当前版本 ${check.installed.versionName} (${check.installed.versionCode})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const _SecureBadge(),
                ],
              ),
            ),
            const SizedBox(height: ZhSpace.md),
            if (!_service.isSupported)
              const _StatusCard(
                icon: Icons.devices_other_rounded,
                title: '当前平台不支持应用内安装',
                message: '安全下载、校验和系统安装器目前仅在 Android 客户端启用。',
              )
            else if (_checking && check == null)
              const _StatusCard(
                icon: Icons.sync_rounded,
                title: '正在检查更新',
                message: '正在从 GitHub Releases 读取稳定版本。',
                loading: true,
              )
            else if (check != null && check.updateAvailable && release != null)
              _ReleaseCard(
                check: check,
                progress: progress,
                installing: _installing,
                received: _received,
                total: _total,
                onInstall: _install,
                onCancel: () => setState(() => _cancelled = true),
              )
            else if (check != null)
              _StatusCard(
                icon: Icons.verified_rounded,
                title: '已是最新版本',
                message: release == null
                    ? '稳定通道目前没有已发布版本。'
                    : '稳定通道最新版本为 ${release.versionName} (${release.versionCode})。',
              ),
            if (_error != null) ...[
              const SizedBox(height: ZhSpace.md),
              _ErrorCard(message: _error!),
            ],
            const SizedBox(height: ZhSpace.md),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _checking || _installing ? null : _checkNow,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(_checking ? '正在检查' : '重新检查'),
              ),
            ),
            const SizedBox(height: ZhSpace.lg),
            Text('更新安全', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: ZhSpace.sm),
            const ZhSurface(
              radius: 22,
              child: Column(
                children: [
                  _SecurityRow(
                    icon: Icons.cloud_download_outlined,
                    title: 'GitHub Releases',
                    detail: '只接受指定 GitHub 仓库中规范命名的稳定版 arm64 APK。',
                  ),
                  Divider(height: 28),
                  _SecurityRow(
                    icon: Icons.fingerprint_rounded,
                    title: '完整性校验',
                    detail: '下载后校验 GitHub 提供的 SHA-256 摘要和文件大小。',
                  ),
                  Divider(height: 28),
                  _SecurityRow(
                    icon: Icons.android_rounded,
                    title: '交给系统安装器',
                    detail: '还会校验包名、版本及证书连续性，再打开 Android 安装器。',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppUpdatePromptGate extends StatefulWidget {
  const AppUpdatePromptGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdatePromptGate> createState() => _AppUpdatePromptGateState();
}

class _AppUpdatePromptGateState extends State<AppUpdatePromptGate> {
  static bool _checkedThisProcess = false;

  @override
  void initState() {
    super.initState();
    if (!_checkedThisProcess) {
      _checkedThisProcess = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  Future<void> _check() async {
    final service = AppUpdateService();
    if (!service.isSupported) {
      service.close();
      return;
    }
    try {
      final check = await service.check();
      if (!mounted || !check.updateAvailable) return;
      final release = check.release!;
      await showDialog<void>(
        context: context,
        barrierDismissible: !check.mandatory,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            check.mandatory
                ? Icons.warning_amber_rounded
                : Icons.system_update_rounded,
          ),
          title: Text(
            check.mandatory ? '发现重要更新' : '发现新版本 ${release.versionName}',
          ),
          content: Text(
            release.notes.isEmpty ? '新版本已发布到 GitHub Releases。' : release.notes,
          ),
          actions: [
            if (!check.mandatory)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('稍后'),
              ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppUpdatePage()),
                );
              },
              child: const Text('查看更新'),
            ),
          ],
        ),
      );
    } catch (_) {
      // Startup checks stay quiet. Manual checks expose actionable errors.
    } finally {
      service.close();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({
    required this.check,
    required this.progress,
    required this.installing,
    required this.received,
    required this.total,
    required this.onInstall,
    required this.onCancel,
  });

  final AppUpdateCheck check;
  final double progress;
  final bool installing;
  final int received;
  final int total;
  final VoidCallback onInstall;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final release = check.release!;
    return ZhSurface(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '版本 ${release.versionName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (check.mandatory)
                const Chip(
                  avatar: Icon(Icons.priority_high_rounded, size: 17),
                  label: Text('重要更新'),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${_formatBytes(release.packageSize)} APK · stable 通道 · 构建 ${release.versionCode}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (release.notes.isNotEmpty) ...[
            const SizedBox(height: ZhSpace.md),
            Text(release.notes, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: ZhSpace.sm),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: ZhSpace.sm),
            title: const Text('查看更新接口详情'),
            subtitle: Text(
              release.packageFileName.isEmpty
                  ? '已验证清单、包大小和 SHA-256'
                  : release.packageFileName,
            ),
            children: [
              _UpdateDetailRow('发布编号', release.releaseId),
              _UpdateDetailRow('发布时间', _formatPublishedAt(release.publishedAt)),
              _UpdateDetailRow('Release 标签', release.tagName),
              _UpdateDetailRow('包类型', release.packageContentType),
              _UpdateDetailRow(
                'APK SHA-256',
                _shortHash(release.packageSha256),
              ),
              if (check.manifestMetadata != null)
                _UpdateDetailRow(
                  '清单响应',
                  _manifestResponseSummary(check.manifestMetadata!),
                ),
            ],
          ),
          const SizedBox(height: ZhSpace.md),
          if (installing) ...[
            LinearProgressIndicator(value: progress == 0 ? null : progress),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    received < total
                        ? '下载 APK ${_formatBytes(received)} / ${_formatBytes(total)}'
                        : '正在校验安装包',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton(onPressed: onCancel, child: const Text('取消')),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: onInstall,
                icon: Icon(
                  check.cachedPackageAvailable
                      ? Icons.install_mobile_rounded
                      : Icons.download_rounded,
                ),
                label: Text(check.cachedPackageAvailable ? '继续安装' : '下载并安装'),
              ),
            ),
        ],
      ),
    );
  }
}

class _UpdateDetailRow extends StatelessWidget {
  const _UpdateDetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ZhPalette.ink),
          ),
        ),
      ],
    ),
  );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;

  @override
  Widget build(BuildContext context) => ZhSurface(
    radius: 24,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Icon(icon, size: 28, color: ZhPalette.mutedInk),
        const SizedBox(width: ZhSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: ZhPalette.danger.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: ZhPalette.danger.withValues(alpha: .22)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(ZhSpace.md),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: ZhPalette.danger),
          const SizedBox(width: ZhSpace.sm),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

class _SecureBadge extends StatelessWidget {
  const _SecureBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: ZhPalette.canvas,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_rounded, size: 14),
        SizedBox(width: 4),
        Text('校验'),
      ],
    ),
  );
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 22, color: ZhPalette.mutedInk),
      const SizedBox(width: ZhSpace.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '$bytes B';
}

String _shortHash(String value) => value.length > 20
    ? '${value.substring(0, 12)}…${value.substring(value.length - 8)}'
    : value;

String _formatPublishedAt(DateTime value) {
  final utc = value.toUtc();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${utc.year}-${two(utc.month)}-${two(utc.day)} '
      '${two(utc.hour)}:${two(utc.minute)} UTC';
}

String _manifestResponseSummary(AppUpdateManifestMetadata metadata) {
  final response = '${_formatBytes(metadata.responseBytes)} 清单';
  final etag = metadata.etag;
  return etag == null || etag.isEmpty
      ? response
      : '$response · ETag ${_shortHash(etag)}';
}
