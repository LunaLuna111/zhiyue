import 'dart:async';

import 'package:flutter/material.dart';

import '../core/account_session_store.dart';
import '../core/api_client.dart';
import '../core/json_tools.dart';
import '../core/session_store.dart';
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
      _message('当前没有可保存的登录会话');
      return;
    }
    final saved = await _store.rememberCurrent(widget.session);
    if (mounted) {
      _message(saved ? '当前登录会话已保存' : '账号槽位保存失败，请稍后重试');
    }
  }

  Future<void> _switch(StoredAccountSession account) async {
    if (_busyId != null || account.id == _store.activeId) return;
    setState(() => _busyId = account.id);
    try {
      final switched = await _store.activate(
        account.id,
        widget.session,
        verify: () => _verifyAccount(account),
      );
      if (!switched) {
        _message('账号会话验证失败，已恢复之前的登录状态');
        return;
      }
      _message('已切换到 ${account.displayName}');
    } catch (_) {
      _message('账号切换失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _remove(StoredAccountSession account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除账号槽位？'),
        content: Text(
          account.id == _store.activeId
              ? '只删除本机保存的 ${account.displayName}，当前会话会退出本机并保留可恢复副本，不会退出其他设备。'
              : '只删除本机保存的 ${account.displayName}，不会退出其他设备。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final removed = await _store.remove(account.id, session: widget.session);
    if (mounted) {
      _message(removed ? '已删除本机账号槽位' : '账号槽位删除失败，请稍后重试');
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
            ? '没有可恢复的账号会话'
            : saved
            ? '已恢复最近一次清理的账号会话'
            : '会话已恢复，但账号槽位保存失败，请稍后重试',
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('彻底清理恢复凭据？'),
        content: const Text('这会永久删除最近清理后保留的恢复副本，之后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('彻底删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final cleared = await widget.session
        .permanentlyClearRecoveredAccountSessions();
    if (mounted) {
      _message(cleared ? '恢复凭据已彻底删除' : '恢复凭据清理失败，请稍后重试');
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
    appBar: AppBar(
      title: const Text('账号与多端登录'),
      actions: [
        IconButton(
          key: const ValueKey('account-session-save-current'),
          tooltip: '保存当前会话',
          onPressed: _saveCurrent,
          icon: const Icon(Icons.save_outlined),
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
                  '扫码登录或手机号登录后的会话会保存在本机私有凭据数据库中。切换前会重新验证 /people/self；不会主动退出其他设备。',
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
                        '最近清理的登录信息',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '服务器失效确认后清理的账号仍保留在本机恢复区。可以恢复，也可以在这里永久删除。',
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
                              label: '恢复',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextButton(
                              key: const ValueKey(
                                'account-session-purge-recovery',
                              ),
                              onPressed: _permanentlyClearRecovery,
                              child: const Text('彻底删除'),
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
                  child: const Column(
                    children: [
                      Icon(Icons.devices_other_outlined, size: 34),
                      SizedBox(height: 10),
                      Text('还没有保存的账号槽位'),
                      SizedBox(height: 4),
                      Text('登录成功后可在这里管理多端会话。'),
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
                        title: Text(account.displayName),
                        subtitle: Text(
                          [
                            if (account.isQr) '扫码会话' else '手机号/密码会话',
                            if (account.id == _store.activeId) '当前使用',
                            if (account.isExpired && !account.isQr) '已过期',
                          ].join(' · '),
                        ),
                        trailing: ZhPopupMenuButton<String>(
                          tooltip: '账号操作',
                          onSelected: (value) {
                            if (value == 'switch') unawaited(_switch(account));
                            if (value == 'remove') unawaited(_remove(account));
                          },
                          itemBuilder: (_) => [
                            ZhMenuItem(value: 'switch', label: '切换并验证'),
                            ZhMenuItem(value: 'remove', label: '删除槽位'),
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
                label: '添加账号 / 扫码登录',
              ),
            ],
          ),
        );
      },
    ),
  );
}
