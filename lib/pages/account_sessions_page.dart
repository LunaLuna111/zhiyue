import 'dart:async';

import 'package:flutter/material.dart';

import '../core/account_session_store.dart';
import '../core/api_client.dart';
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

  String _currentId() {
    final uid = widget.session.accountUid.trim();
    if (uid.isNotEmpty) return uid;
    final userId = widget.session.accountUserId.trim();
    if (userId.isNotEmpty) return userId;
    return '';
  }

  Future<void> _saveCurrent() async {
    if (!widget.session.hasAccountSession) {
      _message('当前没有可保存的登录会话');
      return;
    }
    await _store.rememberCurrent(widget.session);
    if (mounted) _message('当前登录会话已保存');
  }

  Future<void> _switch(StoredAccountSession account) async {
    if (_busyId != null || account.id == _currentId()) return;
    setState(() => _busyId = account.id);
    try {
      final switched = await _store.activate(account.id, widget.session);
      if (!switched) {
        _message(account.isExpired ? '该账号 Token 已过期，请重新登录' : '账号会话无效，请重新登录');
        return;
      }
      // Verify the candidate after activation. A failed identity check is
      // surfaced without deleting the stored slot, allowing a later retry.
      final response = await widget.api.get('/people/self');
      if (!response.isSuccess) {
        _message('已切换本地会话，但账号验证失败');
      } else {
        _message('已切换到 ${account.displayName}');
      }
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
        content: Text('只删除本机保存的 ${account.displayName}，不会退出其他设备。'),
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
    await _store.remove(account.id);
    if (mounted) _message('已删除本机账号槽位');
  }

  Future<void> _restore() async {
    final restored = await widget.session.restoreLastClearedAccountSession();
    if (restored) {
      // Recreate/update the multi-account slot as well. This keeps recovery
      // useful even if the slot was removed after the active credentials were
      // cleared.
      await _store.rememberCurrent(widget.session);
    }
    if (mounted) {
      _message(restored ? '已恢复最近一次清理的账号会话' : '没有可恢复的账号会话');
    }
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
    await widget.session.permanentlyClearRecoveredAccountSessions();
    if (mounted) _message('恢复凭据已彻底删除');
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
                            if (account.id == _currentId()) '当前使用',
                            if (account.isExpired && !account.isQr) '已过期',
                          ].join(' · '),
                        ),
                        trailing: PopupMenuButton<String>(
                          tooltip: '账号操作',
                          onSelected: (value) {
                            if (value == 'switch') unawaited(_switch(account));
                            if (value == 'remove') unawaited(_remove(account));
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'switch',
                              child: Text('切换并验证'),
                            ),
                            PopupMenuItem(value: 'remove', child: Text('删除槽位')),
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
