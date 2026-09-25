import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_log.dart';
import '../core/session_store.dart';
import '../l10n/zh_localization.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';

class DiagnosticLogsPage extends StatefulWidget {
  const DiagnosticLogsPage({super.key, required this.session});

  final SessionStore session;

  @override
  State<DiagnosticLogsPage> createState() => _DiagnosticLogsPageState();
}

class _DiagnosticLogsPageState extends State<DiagnosticLogsPage> {
  SessionStore get session => widget.session;
  AppLogStore get logs => AppLogStore.instance;

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _copyExport() async {
    final l10n = context.zhL10n;
    await Clipboard.setData(ClipboardData(text: logs.exportJson()));
    _message(l10n.diagnosticExported);
  }

  Future<void> _clear() async {
    if (logs.entries.isEmpty) {
      _message(context.zhL10n.diagnosticEmpty);
      return;
    }
    final l10n = context.zhL10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.diagnosticClearTitle),
        content: Text(l10n.diagnosticClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonClear),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await logs.clear();
      _message(l10n.diagnosticCleared);
    }
  }

  String _formatTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.month}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: ZhTopBar(
      title: Text(context.zhL10n.diagnosticTitle),
      actions: [
        ZhLiquidGlassIconButton(
          semanticLabel: context.zhL10n.diagnosticExport,
          onPressed: _copyExport,
          icon: const Icon(Icons.ios_share_outlined),
          size: 44,
          iconSize: 22,
        ),
        ZhLiquidGlassIconButton(
          semanticLabel: context.zhL10n.diagnosticClear,
          onPressed: _clear,
          icon: const Icon(Icons.delete_sweep_outlined),
          size: 44,
          iconSize: 22,
        ),
      ],
    ),
    body: ZhPageWidth(
      maxWidth: 720,
      child: AnimatedBuilder(
        animation: Listenable.merge([session, logs]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(
            ZhSpace.md,
            ZhSpace.xs,
            ZhSpace.md,
            ZhSpace.xl,
          ),
          children: [
            ZhSurface(
              padding: const EdgeInsets.fromLTRB(
                ZhSpace.md,
                ZhSpace.sm,
                ZhSpace.md,
                ZhSpace.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.zhL10n.diagnosticPurpose,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.zhL10n.diagnosticPrivacy,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Divider(height: 24),
                  ZhLiquidGlassSwitchTile(
                    title: context.zhL10n.diagnosticLocalEnabled,
                    subtitle: context.zhL10n.diagnosticLocalSubtitle,
                    value: session.appLoggingEnabled,
                    onChanged: session.setAppLoggingEnabled,
                  ),
                  ZhLiquidGlassSwitchTile(
                    title: context.zhL10n.diagnosticAuthEnabled,
                    subtitle: context.zhL10n.diagnosticAuthSubtitle,
                    value: session.authenticationLoggingEnabled,
                    onChanged: session.setAuthenticationLoggingEnabled,
                  ),
                  ZhLiquidGlassSwitchTile(
                    title: context.zhL10n.diagnosticNetworkEnabled,
                    subtitle: context.zhL10n.diagnosticNetworkSubtitle,
                    value: session.networkLoggingEnabled,
                    onChanged: session.appLoggingEnabled
                        ? session.setNetworkLoggingEnabled
                        : null,
                  ),
                  ZhLiquidGlassSwitchTile(
                    title: context.zhL10n.diagnosticPerformanceEnabled,
                    subtitle: context.zhL10n.diagnosticPerformanceSubtitle,
                    value: session.performanceLoggingEnabled,
                    onChanged: session.appLoggingEnabled
                        ? session.setPerformanceLoggingEnabled
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.zhL10n.diagnosticInstallSummary(
                            logs.installId.length > 12
                                ? logs.installId.substring(0, 12)
                                : logs.installId,
                            logs.entries.length,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: ZhSpace.md),
            if (logs.entries.isEmpty)
              ZhSurface(
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      context.zhL10n.diagnosticEmptyTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(context.zhL10n.diagnosticEmptyMessage),
                  ],
                ),
              )
            else
              ...logs.entries.map(
                (entry) => _LogEntryTile(entry: entry, formatTime: _formatTime),
              ),
          ],
        ),
      ),
    ),
  );
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry, required this.formatTime});

  final AppLogEntry entry;
  final String Function(DateTime) formatTime;

  Color _color(BuildContext context) => switch (entry.level) {
    AppLogLevel.error => Theme.of(context).colorScheme.error,
    AppLogLevel.warning => Colors.orange.shade800,
    _ => Theme.of(context).colorScheme.primary,
  };

  String _levelLabel(AppLocalizations l10n) => switch (entry.level) {
    AppLogLevel.debug => l10n.diagnosticLevelDebug,
    AppLogLevel.info => l10n.diagnosticLevelInfo,
    AppLogLevel.warning => l10n.diagnosticLevelWarning,
    AppLogLevel.error => l10n.diagnosticLevelError,
  };

  String _categoryLabel(AppLocalizations l10n) => switch (entry.category) {
    AppLogCategory.app => l10n.diagnosticCategoryApp,
    AppLogCategory.network => l10n.diagnosticCategoryNetwork,
    AppLogCategory.performance => l10n.diagnosticCategoryPerformance,
    AppLogCategory.error => l10n.diagnosticCategoryError,
    AppLogCategory.authentication => l10n.diagnosticCategoryAuthentication,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final color = _color(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: ZhSpace.sm),
      child: ZhSurface(
        padding: EdgeInsets.zero,
        // ShadCard paints its fill through a DecoratedBox. ExpansionTile's
        // ink must have a Material immediately above it, otherwise Flutter's
        // debug check reports an unhandled error and hides the splash.
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            leading: Icon(Icons.circle, size: 10, color: color),
            title: Text(entry.message),
            subtitle: Text(
              '${formatTime(entry.occurredAt)} · ${_categoryLabel(l10n)} · ${_levelLabel(l10n)}',
            ),
            children: [
              if (entry.details.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(context.zhL10n.diagnosticNoDetails),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: SelectableText(
                    const JsonEncoder.withIndent('  ').convert(entry.details),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
