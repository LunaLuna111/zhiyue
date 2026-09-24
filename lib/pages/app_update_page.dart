import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_update_service.dart';
import '../l10n/zh_localization.dart';
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
        setState(() => _error = context.zhL10n.updateCheckFailed);
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
      final l10n = context.zhL10n;
      final open = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.updateAllowInstallTitle),
          content: Text(l10n.updateAllowInstallMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.updateOpenSettings),
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
                  ? context.zhL10n.updateCachedInstalling
                  : context.zhL10n.updateVerifiedInstalling,
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = context.zhL10n.updateInstallFailed);
      }
    } finally {
      if (mounted) setState(() => _installing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final check = _check;
    final release = check?.release;
    final progress = _total <= 0 ? 0.0 : (_received / _total).clamp(0.0, 1.0);
    return Scaffold(
      appBar: ZhTopBar(title: Text(l10n.updateTitle)),
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
                    decoration: BoxDecoration(
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
                          l10n.updateAppName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          check == null
                              ? l10n.updateReadingVersion
                              : l10n.updateCurrentVersion(
                                  check.installed.versionName,
                                  check.installed.versionCode.toString(),
                                ),
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
              _StatusCard(
                icon: Icons.devices_other_rounded,
                title: l10n.updateUnsupportedTitle,
                message: l10n.updateUnsupportedMessage,
              )
            else if (_checking && check == null)
              _StatusCard(
                icon: Icons.sync_rounded,
                title: l10n.updateCheckingTitle,
                message: l10n.updateCheckingMessage,
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
                title: l10n.updateLatestTitle,
                message: release == null
                    ? l10n.updateNoRelease
                    : l10n.updateLatestVersion(
                        release.versionName,
                        release.versionCode.toString(),
                      ),
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
                label: Text(
                  _checking ? l10n.updateChecking : l10n.updateRecheck,
                ),
              ),
            ),
            const SizedBox(height: ZhSpace.lg),
            Text(
              l10n.updateSecurity,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: ZhSpace.sm),
            ZhSurface(
              radius: 22,
              child: Column(
                children: [
                  _SecurityRow(
                    icon: Icons.cloud_download_outlined,
                    title: l10n.updateSecuritySourceTitle,
                    detail: l10n.updateSecuritySourceDetail,
                  ),
                  Divider(height: 28),
                  _SecurityRow(
                    icon: Icons.fingerprint_rounded,
                    title: l10n.updateSecurityIntegrityTitle,
                    detail: l10n.updateSecurityIntegrityDetail,
                  ),
                  Divider(height: 28),
                  _SecurityRow(
                    icon: Icons.android_rounded,
                    title: l10n.updateSecurityInstallerTitle,
                    detail: l10n.updateSecurityInstallerDetail,
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
            check.mandatory
                ? context.zhL10n.updateImportantFound
                : context.zhL10n.updateNewVersion(release.versionName),
          ),
          content: Text(
            release.notes.isEmpty
                ? context.zhL10n.updatePublishedToReleases
                : release.notes,
          ),
          actions: [
            if (!check.mandatory)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(context.zhL10n.updateLater),
              ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppUpdatePage()),
                );
              },
              child: Text(context.zhL10n.updateView),
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
                  context.zhL10n.updateVersion(release.versionName),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (check.mandatory)
                Chip(
                  avatar: const Icon(Icons.priority_high_rounded, size: 17),
                  label: Text(context.zhL10n.updateImportant),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            context.zhL10n.updateReleaseMeta(
              _formatBytes(release.packageSize),
              release.versionCode.toString(),
            ),
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
            title: Text(context.zhL10n.updateViewDetails),
            subtitle: Text(
              release.packageFileName.isEmpty
                  ? context.zhL10n.updateVerifiedManifest
                  : release.packageFileName,
            ),
            children: [
              _UpdateDetailRow(
                context.zhL10n.updateReleaseId,
                release.releaseId,
              ),
              _UpdateDetailRow(
                context.zhL10n.updatePublishedAt,
                _formatPublishedAt(release.publishedAt),
              ),
              _UpdateDetailRow(
                context.zhL10n.updateReleaseTag,
                release.tagName,
              ),
              _UpdateDetailRow(
                context.zhL10n.updatePackageType,
                release.packageContentType,
              ),
              _UpdateDetailRow(
                context.zhL10n.updatePackageSha256,
                _shortHash(release.packageSha256),
              ),
              if (check.manifestMetadata != null)
                _UpdateDetailRow(
                  context.zhL10n.updateManifestResponse,
                  _manifestResponseSummary(
                    check.manifestMetadata!,
                    context.zhL10n,
                  ),
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
                        ? context.zhL10n.updateDownloadProgress(
                            _formatBytes(received),
                            _formatBytes(total),
                          )
                        : context.zhL10n.updateVerifyingPackage,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: onCancel,
                  child: Text(context.zhL10n.commonCancel),
                ),
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
                label: Text(
                  check.cachedPackageAvailable
                      ? context.zhL10n.updateContinueInstall
                      : context.zhL10n.updateDownloadInstall,
                ),
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
          Icon(Icons.error_outline_rounded, color: ZhPalette.danger),
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
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_rounded, size: 14),
        const SizedBox(width: 4),
        Text(context.zhL10n.updateValidation),
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

String _manifestResponseSummary(
  AppUpdateManifestMetadata metadata,
  AppLocalizations l10n,
) {
  final response = l10n.updateManifestSummary(
    _formatBytes(metadata.responseBytes),
  );
  final etag = metadata.etag;
  return etag == null || etag.isEmpty
      ? response
      : '$response · ETag ${_shortHash(etag)}';
}
