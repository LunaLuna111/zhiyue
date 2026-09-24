import 'dart:async';

import 'package:flutter/material.dart';

import '../core/account_session_store.dart';
import '../core/api_client.dart';
import '../core/json_tools.dart';
import '../core/session_store.dart';
import '../l10n/zh_localization.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import 'native_login_page.dart';

class AccountSessionsPage extends StatefulWidget {
  const AccountSessionsPage({
    super.key,
    required this.api,
    required this.session,
  });

  final ZhihuApiClient api;
  final SessionStore session;

  @override
  State<AccountSessionsPage> createState() => _AccountSessionsPageState();
}

class _AccountSessionsPageState extends State<AccountSessionsPage> {
  final _store = AccountSessionStore.instance;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  Future<void> _saveCurrent() async {
    if (!widget.session.hasStoredCredentialSession) {
      _message(context.zhL10n.accountSessionsNoCurrent);
      return;
    }
    final saved = await _store.rememberCurrent(widget.session);
    if (mounted) {
      _message(
        saved
            ? context.zhL10n.accountSessionsSaved
            : context.zhL10n.accountSessionsSaveFailed,
      );
    }
  }

  Future<void> _switch(StoredAccountSession account) async {
    if (_busyId != null || account.id == _store.activeId) return;
    final l10n = context.zhL10n;
    setState(() => _busyId = account.id);
    try {
      final switched = await _store.activate(
        account.id,
        widget.session,
        verify: () => _verifyAccount(account),
      );
      if (!switched) {
        _message(l10n.accountSessionRestoreFailed);
        return;
      }
      _message(
        l10n.accountSessionsSwitched(
          localizedAccountDisplayName(l10n, account),
        ),
      );
    } catch (_) {
      _message(l10n.accountSessionsSwitchFailed);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _remove(StoredAccountSession account) async {
    final l10n = context.zhL10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountSessionsDeleteTitle),
        content: Text(
          account.id == _store.activeId
              ? l10n.accountSessionsDeleteActiveMessage(
                  localizedAccountDisplayName(l10n, account),
                )
              : l10n.accountSessionsDeleteMessage(
                  localizedAccountDisplayName(l10n, account),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final removed = await _store.remove(account.id, session: widget.session);
    if (mounted) {
      _message(
        removed
            ? context.zhL10n.accountSessionsDeleted
            : context.zhL10n.accountSessionsDeleteFailed,
      );
    }
  }

  Future<void> _restore() async {
    final restored = await widget.session.restoreLastClearedAccountSession();
    var saved = false;
    if (restored) {
      // Recreate/update the multi-account slot as well. This keeps recovery
      // useful even if the slot was removed after the active credentials were
      // cleared.
      saved = await _store.rememberCurrent(widget.session);
    }
    if (mounted) {
      _message(
        !restored
            ? context.zhL10n.accountSessionsNoRecovery
            : saved
            ? context.zhL10n.accountSessionsRestored
            : context.zhL10n.accountSessionsRestoreSaveFailed,
      );
    }
  }

  Future<bool> _verifyAccount(StoredAccountSession account) async {
    final response = await widget.api.get('/people/self');
    if (!response.isSuccess) return false;
    if (response.jsonMap == null) return false;
    final profile = unwrapObject(response.jsonMap!);
    final profileId = profile['id']?.toString().trim() ?? '';
    final profileUid = profile['uid']?.toString().trim() ?? '';
    if (account.accountUid.isNotEmpty &&
        profileId.isNotEmpty &&
        account.accountUid != profileId) {
      return false;
    }
    if (account.accountUserId.isNotEmpty &&
        profileUid.isNotEmpty &&
        account.accountUserId != profileUid) {
      return false;
    }
    return true;
  }

  Future<void> _permanentlyClearRecovery() async {
    final l10n = context.zhL10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountSessionsPurgeTitle),
        content: Text(l10n.accountSessionsPurgeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.accountSessionsPurgeAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final cleared = await widget.session
        .permanentlyClearRecoveredAccountSessions();
    if (mounted) {
      _message(
        cleared
            ? context.zhL10n.accountSessionsPurged
            : context.zhL10n.accountSessionsPurgeFailed,
      );
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: ZhTopBar(
      title: Text(context.zhL10n.accountSessionsTitle),
      actions: [
        ZhLiquidGlassIconButton(
          key: const ValueKey('account-session-save-current'),
          semanticLabel: context.zhL10n.accountSessionsSaveCurrent,
          onPressed: _saveCurrent,
          icon: const Icon(Icons.save_outlined),
          size: 44,
          iconSize: 22,
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: Listenable.merge([_store, widget.session]),
      builder: (context, _) {
        final accounts = _store.accounts;
        return ZhPageWidth(
          maxWidth: 680,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              ZhSpace.md,
              ZhSpace.xs,
              ZhSpace.md,
              ZhSpace.xl,
            ),
            children: [
              ZhSurface(
                padding: const EdgeInsets.all(ZhSpace.md),
                child: Text(
                  context.zhL10n.accountSessionsIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ZhPalette.mutedInk,
                    height: 1.45,
                  ),
                ),
              ),
              if (widget.session.hasRecoverableAccountSession) ...[
                const SizedBox(height: ZhSpace.md),
                ZhSurface(
                  key: const ValueKey('account-session-recovery'),
                  padding: const EdgeInsets.all(ZhSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.zhL10n.accountSessionsRecoveryTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.zhL10n.accountSessionsRecoveryMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.mutedInk,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ZhOutlineButton(
                              key: const ValueKey('account-session-restore'),
                              onPressed: _restore,
                              icon: Icons.restore_rounded,
                              label: context.zhL10n.accountSessionsRestore,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextButton(
                              key: const ValueKey(
                                'account-session-purge-recovery',
                              ),
                              onPressed: _permanentlyClearRecovery,
                              child: Text(
                                context.zhL10n.accountSessionsPurgeAction,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: ZhSpace.md),
              if (accounts.isEmpty)
                ZhSurface(
                  key: const ValueKey('account-session-empty'),
                  padding: const EdgeInsets.all(ZhSpace.lg),
                  child: Column(
                    children: [
                      const Icon(Icons.devices_other_outlined, size: 34),
                      const SizedBox(height: 10),
                      Text(context.zhL10n.accountSessionsEmptyTitle),
                      const SizedBox(height: 4),
                      Text(context.zhL10n.accountSessionsEmptyMessage),
                    ],
                  ),
                )
              else
                for (final account in accounts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ZhSurface(
                      key: ValueKey('account-session-${account.id}'),
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Icon(
                            account.isQr
                                ? Icons.qr_code_2_rounded
                                : Icons.person_outline_rounded,
                          ),
                        ),
                        title: Text(
                          localizedAccountDisplayName(context.zhL10n, account),
                        ),
                        subtitle: Text(
                          [
                            if (account.isQr)
                              context.zhL10n.accountSessionsQr
                            else
                              context.zhL10n.accountSessionsPassword,
                            if (account.id == _store.activeId)
                              context.zhL10n.accountSessionsCurrent,
                            if (account.isExpired && !account.isQr)
                              context.zhL10n.accountSessionsExpired,
                          ].join(' · '),
                        ),
                        trailing: ZhPopupMenuButton<String>(
                          tooltip: context.zhL10n.accountSessionsMenu,
                          onSelected: (value) {
                            if (value == 'switch') unawaited(_switch(account));
                            if (value == 'remove') unawaited(_remove(account));
                          },
                          itemBuilder: (_) => [
                            ZhMenuItem(
                              value: 'switch',
                              label: context.zhL10n.accountSessionsSwitch,
                            ),
                            ZhMenuItem(
                              value: 'remove',
                              label: context.zhL10n.accountSessionsRemoveSlot,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              ZhOutlineButton(
                key: const ValueKey('account-session-login'),
                onPressed: () async {
                  final loggedIn = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => NativeLoginPage(
                        session: widget.session,
                        api: widget.api,
                      ),
                    ),
                  );
                  if (loggedIn == true && mounted) setState(() {});
                },
                icon: Icons.add,
                label: context.zhL10n.accountSessionsAdd,
              ),
            ],
          ),
        );
      },
    ),
  );
}
