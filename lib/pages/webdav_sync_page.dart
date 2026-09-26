import 'dart:async';

import 'package:flutter/material.dart';

import '../core/cloud_sync_auth.dart';
import '../core/one_drive_folder_client.dart';
import '../core/webdav_models.dart';
import '../core/webdav_sync_service.dart';
import '../l10n/zh_localization.dart';
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
      _showMessage(context.zhL10n.webdavLoadFailed(error.toString()));
    }
  }

  WebDavSettings _draft() => WebDavSettings(
    enabled: _enabled,
    provider: _provider,
    endpoint: _directCloud ? '' : _endpointController.text,
    remoteDirectory: _directoryController.text,
    username: _directCloud ? '' : _usernameController.text,
    secret: _directCloud ? '' : _secretController.text,
    authMethod: _authMethod,
    syncOnStartup: _syncOnStartup,
  );

  bool get _directCloud =>
      _provider == WebDavProviderKind.googleDrive ||
      _provider == WebDavProviderKind.oneDrive;

  Future<void> _authorizeCloud() async {
    setState(() => _saving = true);
    try {
      await CloudSyncAuth.instance.signIn(_provider);
      if (!mounted) return;
      setState(() => _enabled = true);
      if (await _saveDraft() && mounted) {
        _showMessage(context.zhL10n.webdavCloudAuthorized);
      }
    } on Object {
      if (mounted) _showMessage(context.zhL10n.webdavCloudAuthorizationFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _chooseOneDriveFolder() async {
    setState(() => _saving = true);
    try {
      final folderName = await OneDriveFolderClient.pickFolder();
      if (!mounted || folderName == null) return;
      setState(() => _enabled = true);
      if (await _saveDraft() && mounted) {
        _showMessage(context.zhL10n.webdavCloudFolderSelected);
      }
    } on Object {
      if (mounted) {
        _showMessage(context.zhL10n.webdavCloudFolderAuthorizationFailed);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _saveDraft() async {
    final draft = _draft();
    final error = draft.validate();
    if (error != null) {
      _showMessage(localizedWebDavError(context.zhL10n, error));
      return false;
    }
    setState(() => _saving = true);
    try {
      await service.saveSettings(draft);
      return true;
    } on Object catch (error) {
      if (mounted) {
        _showMessage(context.zhL10n.webdavSaveFailed(error.toString()));
      }
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
      if (mounted) _showMessage(context.zhL10n.webdavConnected);
    } on Object catch (error) {
      if (mounted) {
        _showMessage(context.zhL10n.webdavConnectionFailed(error.toString()));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sync() async {
    if (!await _saveDraft()) return;
    setState(() => _saving = true);
    try {
      final result = await service.sync();
      if (mounted) {
        _showMessage(
          localizedWebDavStatusMessage(context.zhL10n, result.message),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        _showMessage(context.zhL10n.webdavSyncFailed(error.toString()));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _disable() async {
    setState(() => _enabled = false);
    final saved = await _saveDraft();
    if (saved && mounted) _showMessage(context.zhL10n.webdavDisabled);
  }

  Future<void> _clearSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.zhL10n.webdavClearTitle),
        content: Text(context.zhL10n.webdavClearMessage),
        actions: [
          TextButton(
            key: const ValueKey('webdav-clear-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.zhL10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('webdav-clear-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.zhL10n.commonClear),
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
      _showMessage(context.zhL10n.webdavCleared);
    } on Object catch (error) {
      if (mounted) {
        _showMessage(context.zhL10n.webdavClearFailed(error.toString()));
      }
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

  String _providerLabel(AppLocalizations l10n, WebDavProviderKind provider) =>
      switch (provider) {
        WebDavProviderKind.generic => l10n.webdavProviderGeneric,
        WebDavProviderKind.googleDriveGateway => l10n.webdavProviderGoogle,
        WebDavProviderKind.microsoftOneDrive => l10n.webdavProviderOneDrive,
        WebDavProviderKind.googleDrive => l10n.webdavProviderGoogleDirect,
        WebDavProviderKind.oneDrive => l10n.webdavProviderOneDriveDirect,
      };

  String _providerDescription(
    AppLocalizations l10n,
    WebDavProviderKind provider,
  ) => switch (provider) {
    WebDavProviderKind.generic => l10n.webdavProviderGenericDescription,
    WebDavProviderKind.googleDriveGateway =>
      l10n.webdavProviderGoogleDescription,
    WebDavProviderKind.microsoftOneDrive =>
      l10n.webdavProviderOneDriveDescription,
    WebDavProviderKind.googleDrive =>
      l10n.webdavProviderGoogleDirectDescription,
    WebDavProviderKind.oneDrive => l10n.webdavProviderOneDriveDirectDescription,
  };

  String _providerHint(AppLocalizations l10n, WebDavProviderKind provider) =>
      switch (provider) {
        WebDavProviderKind.generic => l10n.webdavProviderGenericHint,
        WebDavProviderKind.googleDriveGateway => l10n.webdavProviderGoogleHint,
        WebDavProviderKind.microsoftOneDrive => l10n.webdavProviderOneDriveHint,
        WebDavProviderKind.googleDrive || WebDavProviderKind.oneDrive => '',
      };

  String _authMethodLabel(AppLocalizations l10n, WebDavAuthMethod method) =>
      switch (method) {
        WebDavAuthMethod.basic => l10n.webdavAuthBasic,
        WebDavAuthMethod.bearer => l10n.webdavAuthBearer,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZhTopBar(title: Text(context.zhL10n.webdavTitle)),
      body: _loading
          ? const ZhFormLoadingSkeleton()
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
        Icon(Icons.cloud_sync_outlined, color: ZhPalette.ink, size: 30),
        const SizedBox(width: ZhSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.zhL10n.webdavIntroTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                context.zhL10n.webdavIntroMessage,
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
        Text(
          context.zhL10n.webdavConnectionSettings,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: ZhSpace.sm),
        ZhChoiceField<WebDavProviderKind>(
          key: const ValueKey('webdav-provider'),
          label: context.zhL10n.webdavProviderType,
          value: _provider,
          items: [
            for (final item in [
              WebDavProviderKind.generic,
              WebDavProviderKind.googleDrive,
              WebDavProviderKind.oneDrive,
              if (_provider == WebDavProviderKind.googleDriveGateway ||
                  _provider == WebDavProviderKind.microsoftOneDrive)
                _provider,
            ])
              ZhChoiceItem(
                value: item,
                label: _providerLabel(context.zhL10n, item),
              ),
          ],
          onChanged: _saving
              ? null
              : (value) => setState(() => _provider = value),
        ),
        const SizedBox(height: ZhSpace.sm),
        Text(
          _providerDescription(context.zhL10n, _provider),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: ZhPalette.subtleInk),
        ),
        const SizedBox(height: ZhSpace.sm),
        if (!_directCloud)
          TextField(
            key: const ValueKey('webdav-endpoint'),
            controller: _endpointController,
            enabled: !_saving,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: context.zhL10n.webdavEndpoint,
              hintText: _providerHint(context.zhL10n, _provider),
              helperText: context.zhL10n.webdavHttpsHint,
            ),
          ),
        if (!_directCloud) const SizedBox(height: ZhSpace.sm),
        TextField(
          key: const ValueKey('webdav-directory'),
          controller: _directoryController,
          enabled: !_saving,
          decoration: InputDecoration(
            labelText: context.zhL10n.webdavRemoteDirectory,
            hintText: 'zhiyue',
            helperText: context.zhL10n.webdavRemoteDirectoryHint,
          ),
        ),
        const SizedBox(height: ZhSpace.sm),
        if (_provider == WebDavProviderKind.googleDrive)
          FilledButton.icon(
            onPressed: _saving || !CloudSyncAuth.instance.isAvailable(_provider)
                ? null
                : _authorizeCloud,
            icon: const Icon(Icons.open_in_browser),
            label: Text(context.zhL10n.webdavCloudAuthorize),
          ),
        if (_provider == WebDavProviderKind.googleDrive &&
            !CloudSyncAuth.instance.isAvailable(_provider))
          Text(context.zhL10n.webdavCloudRegistrationRequired),
        if (_provider == WebDavProviderKind.oneDrive)
          FilledButton.icon(
            onPressed: _saving || !OneDriveFolderClient.isAvailable
                ? null
                : _chooseOneDriveFolder,
            icon: const Icon(Icons.folder_open),
            label: Text(context.zhL10n.webdavCloudChooseFolder),
          ),
        if (_provider == WebDavProviderKind.oneDrive &&
            !OneDriveFolderClient.isAvailable)
          Text(context.zhL10n.webdavCloudFolderUnavailable),
        if (!_directCloud)
          ZhChoiceField<WebDavAuthMethod>(
            key: const ValueKey('webdav-auth-method'),
            label: context.zhL10n.webdavAuthMethod,
            value: _authMethod,
            items: [
              for (final item in WebDavAuthMethod.values)
                ZhChoiceItem(
                  value: item,
                  label: _authMethodLabel(context.zhL10n, item),
                ),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _authMethod = value),
          ),
        if (!_directCloud) const SizedBox(height: ZhSpace.sm),
        if (!_directCloud && _authMethod == WebDavAuthMethod.basic)
          TextField(
            key: const ValueKey('webdav-username'),
            controller: _usernameController,
            enabled: !_saving,
            decoration: InputDecoration(
              labelText: context.zhL10n.webdavUsername,
            ),
          ),
        if (!_directCloud && _authMethod == WebDavAuthMethod.basic)
          const SizedBox(height: ZhSpace.sm),
        if (!_directCloud)
          TextField(
            key: const ValueKey('webdav-secret'),
            controller: _secretController,
            enabled: !_saving,
            obscureText: true,
            decoration: InputDecoration(
              labelText: _authMethod == WebDavAuthMethod.basic
                  ? context.zhL10n.webdavPasswordOrAppPassword
                  : context.zhL10n.webdavAccessToken,
            ),
          ),
        const SizedBox(height: ZhSpace.sm),
        ZhLiquidGlassSwitchTile(
          key: const ValueKey('webdav-enabled'),
          title: context.zhL10n.webdavEnable,
          subtitle: context.zhL10n.webdavEnableSubtitle,
          value: _enabled,
          onChanged: _saving
              ? null
              : (value) => setState(() => _enabled = value),
        ),
        ZhLiquidGlassSwitchTile(
          key: const ValueKey('webdav-sync-on-startup'),
          title: context.zhL10n.webdavStartupSync,
          subtitle: context.zhL10n.webdavStartupSyncSubtitle,
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
        Text(
          context.zhL10n.webdavSyncContent,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(context.zhL10n.webdavSyncContentSummary),
        const SizedBox(height: 8),
        Text(
          context.zhL10n.webdavStatus(
            service.status.message.isEmpty
                ? context.zhL10n.webdavNotSynced
                : localizedWebDavStatusMessage(
                    context.zhL10n,
                    service.status.message,
                  ),
          ),
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
          label: Text(context.zhL10n.webdavSyncNow),
        ),
        const SizedBox(height: ZhSpace.sm),
        OutlinedButton.icon(
          key: const ValueKey('webdav-test'),
          onPressed: _saving || !_enabled ? null : _testConnection,
          icon: const Icon(Icons.network_check_rounded),
          label: Text(context.zhL10n.webdavTestConnection),
        ),
        const SizedBox(height: ZhSpace.sm),
        TextButton(
          key: const ValueKey('webdav-disable'),
          onPressed: _saving ? null : _disable,
          child: Text(context.zhL10n.webdavDisable),
        ),
        TextButton(
          key: const ValueKey('webdav-clear'),
          onPressed: _saving ? null : _clearSettings,
          child: Text(context.zhL10n.webdavClearLocalSettings),
        ),
        if (_saving) ...[
          const SizedBox(height: ZhSpace.sm),
          const LinearProgressIndicator(),
        ],
      ],
    ),
  );
}
