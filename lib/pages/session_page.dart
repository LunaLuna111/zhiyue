import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/session_store.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import 'native_login_page.dart';
import 'web_page.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.session});

  final SessionStore session;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  late final TextEditingController _authorization;
  late final TextEditingController _udid;
  late final TextEditingController _cookie;
  late final TextEditingController _msId;
  late final TextEditingController _zse96;
  late final TextEditingController _zse96Target;
  late final TextEditingController _extra;
  bool _obscure = true;
  bool _editorExpanded = false;
  bool _advancedExpanded = false;
  bool _saving = false;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _authorization = TextEditingController(text: widget.session.authorization);
    _udid = TextEditingController(text: widget.session.udid);
    _cookie = TextEditingController(text: widget.session.cookie);
    _msId = TextEditingController(text: widget.session.msId);
    _zse96 = TextEditingController(text: widget.session.xZse96);
    _zse96Target = TextEditingController(text: widget.session.xZse96Target);
    _extra = TextEditingController(text: widget.session.extraHeadersJson);
  }

  @override
  void dispose() {
    _authorization.dispose();
    _udid.dispose();
    _cookie.dispose();
    _msId.dispose();
    _zse96.dispose();
    _zse96Target.dispose();
    _extra.dispose();
    super.dispose();
  }

  void _open(String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OfficialWebPage(title: title, url: url),
      ),
    );
  }

  void _openNativeLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NativeLoginPage(session: widget.session),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.session.save(
        authorization: _authorization.text,
        udid: _udid.text,
        cookie: _cookie.text,
        msId: _msId.text,
        xZse96: _zse96.text,
        xZse96Target: _zse96Target.text,
        extraHeadersJson: _extra.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('登录信息已保存')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clear() async {
    if (_clearing) return;
    setState(() => _clearing = true);
    try {
      await widget.session.clear();
      if (!mounted) return;
      _authorization.clear();
      _udid.clear();
      _cookie.clear();
      _msId.clear();
      _zse96.clear();
      _zse96Target.clear();
      _extra.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('登录信息已清除')));
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportsApiSession = widget.session.supportsPersistentApiSession;
    return Scaffold(
      appBar: AppBar(title: const Text('账号')),
      body: ZhPageWidth(
        child: ListView(
          padding: const EdgeInsets.all(ZhSpace.md),
          children: [
            Text('登录知乎', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: ZhSpace.md),
            Row(
              children: [
                Expanded(
                  child: ZhPrimaryButton(
                    onPressed: _openNativeLogin,
                    icon: Icons.login,
                    label: '手机号登录',
                    expand: true,
                  ),
                ),
                const SizedBox(width: ZhSpace.sm),
                Expanded(
                  child: ZhOutlineButton(
                    onPressed: () =>
                        _open('网页登录', 'https://www.zhihu.com/signin'),
                    icon: Icons.open_in_browser_outlined,
                    label: '网页登录',
                    expand: true,
                  ),
                ),
              ],
            ),
            const Divider(height: 36),
            if (supportsApiSession) ...[
              _SessionEditor(
                expanded: _editorExpanded,
                advancedExpanded: _advancedExpanded,
                obscure: _obscure,
                saving: _saving,
                hasContext: widget.session.hasCompleteMobileContext,
                authorization: _authorization,
                udid: _udid,
                cookie: _cookie,
                msId: _msId,
                zse96: _zse96,
                zse96Target: _zse96Target,
                extra: _extra,
                onToggle: () =>
                    setState(() => _editorExpanded = !_editorExpanded),
                onToggleAdvanced: () =>
                    setState(() => _advancedExpanded = !_advancedExpanded),
                onToggleObscure: () => setState(() => _obscure = !_obscure),
                onSave: _saving ? null : _save,
                onClear: _saving || _clearing ? null : _clear,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionEditor extends StatelessWidget {
  const _SessionEditor({
    required this.expanded,
    required this.advancedExpanded,
    required this.obscure,
    required this.saving,
    required this.hasContext,
    required this.authorization,
    required this.udid,
    required this.cookie,
    required this.msId,
    required this.zse96,
    required this.zse96Target,
    required this.extra,
    required this.onToggle,
    required this.onToggleAdvanced,
    required this.onToggleObscure,
    required this.onSave,
    required this.onClear,
  });

  final bool expanded;
  final bool advancedExpanded;
  final bool obscure;
  final bool saving;
  final bool hasContext;
  final TextEditingController authorization;
  final TextEditingController udid;
  final TextEditingController cookie;
  final TextEditingController msId;
  final TextEditingController zse96;
  final TextEditingController zse96Target;
  final TextEditingController extra;
  final VoidCallback onToggle;
  final VoidCallback onToggleAdvanced;
  final VoidCallback onToggleObscure;
  final VoidCallback? onSave;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => ZhSurface(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(ZhRadius.card),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(ZhSpace.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasContext ? ZhPalette.ink : ZhPalette.canvas,
                    borderRadius: BorderRadius.circular(ZhRadius.input),
                  ),
                  child: Icon(
                    hasContext
                        ? Icons.verified_user_outlined
                        : Icons.vpn_key_outlined,
                    color: hasContext
                        ? ZhPalette.background
                        : ZhPalette.mutedInk,
                  ),
                ),
                const SizedBox(width: ZhSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasContext ? '登录信息已保存' : '导入登录信息',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? .5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: expanded
                ? Column(
                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(ZhSpace.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SessionField(
                              label: 'Authorization',
                              controller: authorization,
                              obscure: obscure,
                              icon: Icons.key_outlined,
                            ),
                            const SizedBox(height: ZhSpace.md),
                            _SessionField(
                              label: 'x-udid',
                              controller: udid,
                              obscure: obscure,
                              icon: Icons.smartphone_outlined,
                            ),
                            const SizedBox(height: ZhSpace.sm),
                            _EditorActionRow(
                              icon: obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              title: obscure ? '临时显示敏感值' : '重新隐藏敏感值',
                              onTap: onToggleObscure,
                            ),
                            const SizedBox(height: ZhSpace.xs),
                            _EditorActionRow(
                              icon: Icons.tune_rounded,
                              title: '高级设置',
                              trailing: AnimatedRotation(
                                turns: advancedExpanded ? .5 : 0,
                                duration: const Duration(milliseconds: 180),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                              ),
                              onTap: onToggleAdvanced,
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(top: ZhSpace.md),
                                child: Column(
                                  children: [
                                    _SessionField(
                                      label: 'Cookie（可选）',
                                      controller: cookie,
                                      obscure: obscure,
                                      icon: Icons.cookie_outlined,
                                    ),
                                    const SizedBox(height: ZhSpace.md),
                                    _SessionField(
                                      label: 'X-MS-ID（可选）',
                                      controller: msId,
                                      obscure: obscure,
                                      icon: Icons.fingerprint_rounded,
                                    ),
                                    const SizedBox(height: ZhSpace.md),
                                    _SessionField(
                                      label: '手工 X-Zse-96',
                                      controller: zse96,
                                      obscure: obscure,
                                      icon: Icons.lock_outline_rounded,
                                    ),
                                    const SizedBox(height: ZhSpace.md),
                                    _SessionField(
                                      label: '签名目标',
                                      controller: zse96Target,
                                      obscure: obscure,
                                      icon: Icons.route_outlined,
                                    ),
                                    const SizedBox(height: ZhSpace.md),
                                    _SessionField(
                                      label: '其他 Header',
                                      controller: extra,
                                      obscure: false,
                                      icon: Icons.data_object_rounded,
                                      minLines: 3,
                                      maxLines: 6,
                                    ),
                                  ],
                                ),
                              ),
                              crossFadeState: advancedExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 180),
                            ),
                            const SizedBox(height: ZhSpace.lg),
                            ZhPrimaryButton(
                              onPressed: onSave,
                              icon: Icons.shield_outlined,
                              label: saving ? '保存中…' : '保存',
                              expand: true,
                            ),
                            const SizedBox(height: ZhSpace.xs),
                            ZhOutlineButton(
                              onPressed: onClear,
                              icon: Icons.delete_outline,
                              label: '清除登录信息',
                              expand: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    ),
  );
}

class _SessionField extends StatelessWidget {
  const _SessionField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final IconData icon;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: ZhSpace.xs),
      Semantics(
        textField: true,
        label: label,
        child: ShadInput(
          controller: controller,
          obscureText: obscure,
          autocorrect: false,
          enableSuggestions: false,
          minLines: minLines,
          maxLines: maxLines,
          constraints: BoxConstraints(minHeight: maxLines > 1 ? 118 : 54),
          leading: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(icon, size: 19),
          ),
        ),
      ),
    ],
  );
}

class _EditorActionRow extends StatelessWidget {
  const _EditorActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(ZhRadius.input),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: ZhSpace.sm),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          ?trailing,
        ],
      ),
    ),
  );
}
