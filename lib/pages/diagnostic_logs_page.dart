import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_log.dart';
import '../core/session_store.dart';
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
    await Clipboard.setData(ClipboardData(text: logs.exportJson()));
    _message('日志 JSON 已复制到剪贴板');
  }

  Future<void> _clear() async {
    if (logs.entries.isEmpty) {
      _message('目前没有日志');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理诊断日志？'),
        content: const Text('这只会删除本机保存的诊断记录，不会影响账号和内容缓存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清理'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await logs.clear();
      _message('诊断日志已清理');
    }
  }

  String _formatTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.month}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('诊断日志'),
      actions: [
        IconButton(
          tooltip: '导出日志',
          onPressed: _copyExport,
          icon: const Icon(Icons.ios_share_outlined),
        ),
        IconButton(
          tooltip: '清理日志',
          onPressed: _clear,
          icon: const Icon(Icons.delete_sweep_outlined),
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
                    '用于定位“内容已被删除”、接口失败和卡顿问题',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '认证失效、恢复和清理决定默认记录；其它诊断日志可单独开关。日志只保存脱敏状态，不保存 Cookie、令牌、正文或图片。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Divider(height: 24),
                  ZhLiquidGlassSwitchTile(
                    title: '启用本地日志',
                    subtitle: '开启后保留最近 600 条诊断记录',
                    value: session.appLoggingEnabled,
                    onChanged: session.setAppLoggingEnabled,
                  ),
                  ZhLiquidGlassSwitchTile(
                    title: '认证状态日志',
                    subtitle: '记录登录失效、恢复、保留和清理决定，默认开启',
                    value: session.authenticationLoggingEnabled,
                    onChanged: session.setAuthenticationLoggingEnabled,
                  ),
                  ZhLiquidGlassSwitchTile(
                    title: '网络请求日志',
                    subtitle: '记录接口路径、HTTP 状态、业务码和耗时',
                    value: session.networkLoggingEnabled,
                    onChanged: session.appLoggingEnabled
                        ? session.setNetworkLoggingEnabled
                        : null,
                  ),
                  ZhLiquidGlassSwitchTile(
                    title: '性能日志',
                    subtitle: '记录接口耗时，帮助定位掉帧和慢请求',
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
                          '本机标识 ${logs.installId.length > 12 ? logs.installId.substring(0, 12) : logs.installId} · ${logs.entries.length} 条',
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
                      '暂无诊断日志',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text('开启本地日志后重新操作一次，异常和网络状态会显示在这里。'),
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

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: ZhSpace.sm),
      child: ZhSurface(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          leading: Icon(Icons.circle, size: 10, color: color),
          title: Text(entry.message),
          subtitle: Text(
            '${formatTime(entry.occurredAt)} · ${entry.category.label} · ${entry.level.label}',
          ),
          children: [
            if (entry.details.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('没有附加信息'),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(entry.details),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
