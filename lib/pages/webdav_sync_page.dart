import 'dart:async';

import 'package:flutter/material.dart';

import '../core/webdav_models.dart';
import '../core/webdav_sync_service.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';

class WebDavSyncPage extends StatefulWidget {
  const WebDavSyncPage({super.key, required this.service});

  final WebDavSyncService service;

  @override
  State<WebDavSyncPage> createState() => _WebDavSyncPageState();
}

class _WebDavSyncPageState extends State<WebDavSyncPage> {
  final _endpointController = TextEditingController();
  final _directoryController = TextEditingController(text: 'zhiyue');
  final _usernameController = TextEditingController();
  final _secretController = TextEditingController();
  WebDavProviderKind _provider = WebDavProviderKind.generic;
  WebDavAuthMethod _authMethod = WebDavAuthMethod.basic;
  bool _enabled = false;
  bool _syncOnStartup = false;
  bool _loading = true;
  bool _saving = false;

  WebDavSyncService get service => widget.service;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _directoryController.dispose();
    _usernameController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final settings = await service.loadSettings();
      if (!mounted) return;
      setState(() {
        _provider = settings.provider;
        _authMethod = settings.authMethod;
        _enabled = settings.enabled;
        _syncOnStartup = settings.syncOnStartup;
        _endpointController.text = settings.endpoint;
        _directoryController.text = settings.remoteDirectory;
        _usernameController.text = settings.username;
        _secretController.text = settings.secret;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('读取 WebDAV 设置失败：$error');
    }
  }

  WebDavSettings _draft() => WebDavSettings(
    enabled: _enabled,
    provider: _provider,
    endpoint: _endpointController.text,
    remoteDirectory: _directoryController.text,
    username: _usernameController.text,
    secret: _secretController.text,
    authMethod: _authMethod,
    syncOnStartup: _syncOnStartup,
  );

  Future<bool> _saveDraft() async {
    final draft = _draft();
    final error = draft.validate();
    if (error != null) {
      _showMessage(error);
      return false;
    }
    setState(() => _saving = true);
    try {
      await service.saveSettings(draft);
      return true;
    } on Object catch (error) {
      _showMessage('保存失败：$error');
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _testConnection() async {
    if (!await _saveDraft()) return;
    setState(() => _saving = true);
    try {
      await service.testConnection();
      if (mounted) _showMessage('WebDAV 连接成功');
    } on Object catch (error) {
      if (mounted) _showMessage('连接失败：$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sync() async {
    if (!await _saveDraft()) return;
    setState(() => _saving = true);
    try {
      final result = await service.sync();
      if (mounted) _showMessage(result.message);
    } on Object catch (error) {
      if (mounted) _showMessage('同步失败：$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _disable() async {
    setState(() => _enabled = false);
    final saved = await _saveDraft();
    if (saved && mounted) _showMessage('WebDAV 同步已关闭，凭据仍保留在本机私有数据库');
  }

  Future<void> _clearSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除 WebDAV 配置？'),
        content: const Text('这会删除本机保存的 WebDAV 地址、账号和凭据，不会删除远端同步数据。'),
        actions: [
          TextButton(
            key: const ValueKey('webdav-clear-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const ValueKey('webdav-clear-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await service.clearSettings();
      if (!mounted) return;
      setState(() {
        _provider = WebDavProviderKind.generic;
        _authMethod = WebDavAuthMethod.basic;
        _enabled = false;
        _syncOnStartup = false;
        _endpointController.clear();
        _directoryController.text = 'zhiyue';
        _usernameController.clear();
        _secretController.clear();
      });
      _showMessage('本机 WebDAV 配置和凭据已清除');
    } on Object catch (error) {
      if (mounted) _showMessage('清除失败：$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebDAV 同步')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ZhPageWidth(
              maxWidth: 680,
              child: AnimatedBuilder(
                animation: service,
                builder: (context, _) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    ZhSpace.md,
                    ZhSpace.xs,
                    ZhSpace.md,
                    ZhSpace.xl,
                  ),
                  children: [
                    _introCard(context),
                    const SizedBox(height: ZhSpace.md),
                    _settingsCard(context),
                    const SizedBox(height: ZhSpace.md),
                    _dataCard(context),
                    const SizedBox(height: ZhSpace.md),
                    _actionsCard(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _introCard(BuildContext context) => ZhSurface(
    backgroundColor: ZhPalette.canvas,
    radius: 20,
    padding: const EdgeInsets.all(ZhSpace.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.cloud_sync_outlined, color: ZhPalette.ink, size: 30),
        const SizedBox(width: ZhSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('跨设备同步本地内容', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                '只同步搜索记录、浏览历史、盐选离线章节/书架和回答详情缓存。登录凭据、Cookie、设备标识与本设置不会上传。',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ZhPalette.subtleInk),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _settingsCard(BuildContext context) => ZhSurface(
    radius: 20,
    padding: const EdgeInsets.all(ZhSpace.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('连接设置', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ZhSpace.sm),
        ZhChoiceField<WebDavProviderKind>(
          key: const ValueKey('webdav-provider'),
          label: '服务类型',
          value: _provider,
          items: [
            for (final item in WebDavProviderKind.values)
              ZhChoiceItem(value: item, label: item.label),
          ],
          onChanged: _saving
              ? null
              : (value) => setState(() => _provider = value),
        ),
        const SizedBox(height: ZhSpace.sm),
        Text(
          _provider.description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: ZhPalette.subtleInk),
        ),
        const SizedBox(height: ZhSpace.sm),
        TextField(
          key: const ValueKey('webdav-endpoint'),
          controller: _endpointController,
          enabled: !_saving,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: 'WebDAV 地址',
            hintText: _provider.endpointHint,
            helperText: '仅支持 HTTPS，不要把密码写进 URL',
          ),
        ),
        const SizedBox(height: ZhSpace.sm),
        TextField(
          key: const ValueKey('webdav-directory'),
          controller: _directoryController,
          enabled: !_saving,
          decoration: const InputDecoration(
            labelText: '远程目录',
            hintText: 'zhiyue',
            helperText: '会自动创建 v1、answers 和 chapters 子目录',
          ),
        ),
        const SizedBox(height: ZhSpace.sm),
        ZhChoiceField<WebDavAuthMethod>(
          key: const ValueKey('webdav-auth-method'),
          label: '认证方式',
          value: _authMethod,
          items: [
            for (final item in WebDavAuthMethod.values)
              ZhChoiceItem(value: item, label: item.label),
          ],
          onChanged: _saving
              ? null
              : (value) => setState(() => _authMethod = value),
        ),
        const SizedBox(height: ZhSpace.sm),
        if (_authMethod == WebDavAuthMethod.basic)
          TextField(
            key: const ValueKey('webdav-username'),
            controller: _usernameController,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: '用户名'),
          ),
        if (_authMethod == WebDavAuthMethod.basic)
          const SizedBox(height: ZhSpace.sm),
        TextField(
          key: const ValueKey('webdav-secret'),
          controller: _secretController,
          enabled: !_saving,
          obscureText: true,
          decoration: InputDecoration(
            labelText: _authMethod == WebDavAuthMethod.basic
                ? '密码 / 应用专用密码'
                : '访问令牌',
          ),
        ),
        const SizedBox(height: ZhSpace.sm),
        SwitchListTile.adaptive(
          key: const ValueKey('webdav-enabled'),
          contentPadding: EdgeInsets.zero,
          title: const Text('启用 WebDAV 同步'),
          subtitle: const Text('关闭后不会执行网络同步，已保存的本机配置不会删除'),
          value: _enabled,
          onChanged: _saving
              ? null
              : (value) => setState(() => _enabled = value),
        ),
        SwitchListTile.adaptive(
          key: const ValueKey('webdav-sync-on-startup'),
          contentPadding: EdgeInsets.zero,
          title: const Text('启动后自动同步'),
          subtitle: const Text('后台执行，不阻塞首页首帧；失败后可手动重试'),
          value: _syncOnStartup,
          onChanged: _saving
              ? null
              : (value) => setState(() => _syncOnStartup = value),
        ),
      ],
    ),
  );

  Widget _dataCard(BuildContext context) => ZhSurface(
    backgroundColor: ZhPalette.canvas,
    radius: 20,
    padding: const EdgeInsets.all(ZhSpace.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('同步内容', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('• 搜索记录与浏览历史\n• 盐选书架及已下载章节\n• 回答详情缓存（恢复后仍可手动刷新获取最新内容）'),
        const SizedBox(height: 8),
        Text(
          '状态：${service.status.message.isEmpty ? '尚未同步' : service.status.message}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: service.status.phase == WebDavSyncPhase.failure
                ? ZhPalette.danger
                : ZhPalette.subtleInk,
          ),
        ),
      ],
    ),
  );

  Widget _actionsCard(BuildContext context) => ZhSurface(
    radius: 20,
    padding: const EdgeInsets.all(ZhSpace.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const ValueKey('webdav-sync'),
          onPressed: _saving || !_enabled ? null : _sync,
          icon: const Icon(Icons.sync_rounded),
          label: const Text('立即同步'),
        ),
        const SizedBox(height: ZhSpace.sm),
        OutlinedButton.icon(
          key: const ValueKey('webdav-test'),
          onPressed: _saving || !_enabled ? null : _testConnection,
          icon: const Icon(Icons.network_check_rounded),
          label: const Text('测试连接'),
        ),
        const SizedBox(height: ZhSpace.sm),
        TextButton(
          key: const ValueKey('webdav-disable'),
          onPressed: _saving ? null : _disable,
          child: const Text('关闭同步'),
        ),
        TextButton(
          key: const ValueKey('webdav-clear'),
          onPressed: _saving ? null : _clearSettings,
          child: const Text('清除本机配置和凭据'),
        ),
        if (_saving) ...[
          const SizedBox(height: ZhSpace.sm),
          const LinearProgressIndicator(),
        ],
      ],
    ),
  );
}
