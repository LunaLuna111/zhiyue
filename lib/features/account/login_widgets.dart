part of '../../pages/native_login_page.dart';

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({this.passwordMode = false, this.qrMode = false});

  final bool passwordMode;
  final bool qrMode;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const ZhBrandMark(size: 58),
      const SizedBox(width: ZhSpace.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('登录知乎', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 2),
            Text(
              qrMode
                  ? '知乎 App 扫码登录'
                  : passwordMode
                  ? '账号密码登录'
                  : '手机号快捷登录',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: ZhPalette.mutedInk),
            ),
          ],
        ),
      ),
    ],
  );
}

class _LoginProgress extends StatelessWidget {
  const _LoginProgress({required this.codeSent, this.passwordMode = false});

  final bool codeSent;
  final bool passwordMode;

  @override
  Widget build(BuildContext context) => Semantics(
    label: passwordMode
        ? '登录进度：账号密码'
        : codeSent
        ? '登录进度：验证码'
        : '登录进度：手机号',
    child: Row(
      children: [
        Expanded(
          child: _LoginStepLabel(
            label: passwordMode ? '账号' : '手机号',
            selected: passwordMode || !codeSent,
            completed: !passwordMode && codeSent,
          ),
        ),
        const SizedBox(width: ZhSpace.md),
        Expanded(
          child: _LoginStepLabel(
            label: passwordMode ? '密码' : '验证码',
            selected: !passwordMode && codeSent,
            completed: false,
          ),
        ),
      ],
    ),
  );
}

class _LoginStepLabel extends StatelessWidget {
  const _LoginStepLabel({
    required this.label,
    required this.selected,
    required this.completed,
  });

  final String label;
  final bool selected;
  final bool completed;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          if (completed) ...[
            const Icon(Icons.check_rounded, size: 16, color: ZhPalette.ink),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: selected ? ZhPalette.ink : ZhPalette.subtleInk,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        height: 3,
        decoration: BoxDecoration(
          color: selected ? ZhPalette.ink : ZhPalette.border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ],
  );
}

class _LoginTextButton extends StatelessWidget {
  const _LoginTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: ZhPalette.ink,
      disabledForegroundColor: ZhPalette.subtleInk,
      minimumSize: const Size(44, 42),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
    child: Text(label),
  );
}

class _LoginPrimaryButton extends StatelessWidget {
  const _LoginPrimaryButton({
    required this.busy,
    required this.label,
    required this.onPressed,
  });

  final bool busy;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ShadButton(
    width: double.infinity,
    height: 56,
    enabled: onPressed != null,
    onPressed: onPressed,
    pressedBackgroundColor: const Color(0xFF2A2A2A),
    decoration: ShadDecoration(
      border: ShadBorder.all(width: 0, radius: BorderRadius.circular(28)),
    ),
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: busy
          ? const SizedBox(
              key: ValueKey('login-busy'),
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ZhPalette.background,
              ),
            )
          : Text(label, key: ValueKey(label)),
    ),
  );
}

class _AgreementConsentDialog extends StatelessWidget {
  const _AgreementConsentDialog();

  @override
  Widget build(BuildContext context) => Dialog(
    key: const ValueKey('login-agreement-dialog'),
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    backgroundColor: ZhPalette.background,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: ZhPalette.canvas,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.verified_user_outlined, size: 23),
          ),
          const SizedBox(height: 18),
          Text('登录前请确认', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            '请阅读并同意《知乎用户协议》与隐私政策后继续登录。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('login-agreement-cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: ZhPalette.ink,
                    side: const BorderSide(color: ZhPalette.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('暂不同意'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const ValueKey('login-agreement-confirm'),
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('同意并继续'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _FeedbackMessage extends StatelessWidget {
  const _FeedbackMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: ZhSpace.sm,
      vertical: ZhSpace.xs,
    ),
    decoration: BoxDecoration(
      color: isError ? ZhPalette.dangerSurface : ZhPalette.canvas,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
          color: isError ? ZhPalette.danger : ZhPalette.mutedInk,
          size: 18,
        ),
        const SizedBox(width: ZhSpace.xs),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isError ? ZhPalette.danger : ZhPalette.mutedInk,
            ),
          ),
        ),
      ],
    ),
  );
}

class _QrLoginPane extends StatefulWidget {
  const _QrLoginPane({
    super.key,
    required this.api,
    required this.onLoginSuccess,
  });

  final ZhihuApiClient api;
  final Future<void> Function() onLoginSuccess;

  @override
  State<_QrLoginPane> createState() => _QrLoginPaneState();
}

class _QrLoginPaneState extends State<_QrLoginPane> {
  static const _channel = MethodChannel('com.zhiyue.client/qr_code');

  Timer? _pollTimer;
  Uint8List? _image;
  String _token = '';
  String _cookie = '';
  String _status = '正在获取二维码';
  DateTime _deadline = DateTime.now();
  bool _loading = true;
  bool _polling = false;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    _pollTimer?.cancel();
    if (mounted) {
      setState(() {
        _image = null;
        _token = '';
        _cookie = '';
        _status = '正在获取二维码';
        _loading = true;
      });
    }
    try {
      final code = await widget.api.requestQrLoginCode();
      if (!code.isUsable) {
        throw StateError(
          code.response.failure.userMessage.isEmpty
              ? '知乎没有返回有效二维码'
              : code.response.failure.userMessage,
        );
      }
      final image = await _channel.invokeMethod<Uint8List>('encode', {
        'content': code.link,
        'size': 720,
      });
      if (!mounted) return;
      setState(() {
        _image = image;
        _token = code.token;
        _cookie = code.cookie;
        _deadline = _normalizeDeadline(code.expiresAt);
        _status = '请打开知乎 App 扫一扫';
        _loading = false;
      });
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 700),
        (_) => unawaited(_poll()),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _status = '二维码获取失败：$error';
      });
    }
  }

  Future<void> _poll() async {
    if (_polling || _token.isEmpty || DateTime.now().isAfter(_deadline)) {
      if (_token.isNotEmpty && DateTime.now().isAfter(_deadline)) {
        _pollTimer?.cancel();
        if (mounted) setState(() => _status = '二维码已过期，请点击刷新');
      }
      return;
    }
    _polling = true;
    try {
      final poll = await widget.api.pollQrLogin(token: _token, cookie: _cookie);
      if (!mounted) return;
      if (poll.cookie.isNotEmpty) _cookie = poll.cookie;
      if (poll.needsRiskControl) {
        _pollTimer?.cancel();
        setState(() => _status = '需要先在知乎网页完成安全验证，请稍后刷新二维码');
        return;
      }
      if (poll.scanned && _status != '请在知乎 App 上确认登录') {
        setState(() => _status = '请在知乎 App 上确认登录');
      }
      if (poll.expired) {
        _pollTimer?.cancel();
        setState(() => _status = '二维码已过期，请点击刷新');
      } else if (poll.succeeded) {
        _pollTimer?.cancel();
        setState(() => _status = '正在验证登录');
        final result = await widget.api.completeQrLogin(poll);
        if (!mounted) return;
        if (result.signedIn) {
          setState(() => _status = '登录成功');
          await widget.onLoginSuccess();
        } else {
          setState(() => _status = result.message);
        }
      }
    } on Object catch (error) {
      // A transient poll failure should not make the QR disappear. The next
      // tick retries within the same deadline.
      if (mounted && error is ApiTransportException) {
        debugPrint('[zhihu-qr] poll transient failure=${error.message}');
      }
    } finally {
      _polling = false;
    }
  }

  DateTime _normalizeDeadline(int? expiresAt) {
    final now = DateTime.now();
    if (expiresAt == null || expiresAt <= 0) {
      return now.add(const Duration(minutes: 2));
    }
    if (expiresAt <= 86_400) {
      return now.add(Duration(seconds: expiresAt));
    }
    if (expiresAt < 10_000_000_000) {
      return DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    }
    return DateTime.fromMillisecondsSinceEpoch(expiresAt);
  }

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('qr-login-content'),
    children: [
      if (_image != null)
        Semantics(
          label: '知乎登录二维码',
          child: Image.memory(
            _image!,
            key: const ValueKey('qr-login-image'),
            width: 250,
            height: 250,
            gaplessPlayback: true,
            filterQuality: FilterQuality.none,
          ),
        )
      else if (_loading)
        const SizedBox.square(
          dimension: 250,
          child: Center(child: CircularProgressIndicator()),
        )
      else
        const SizedBox(height: 250),
      const SizedBox(height: 16),
      Text(
        _status,
        key: const ValueKey('qr-login-status'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: ZhPalette.mutedInk,
          height: 1.45,
        ),
      ),
      const SizedBox(height: 18),
      OutlinedButton.icon(
        key: const ValueKey('qr-login-retry'),
        onPressed: _loading ? null : _refresh,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('刷新二维码'),
      ),
      const SizedBox(height: 10),
      Text(
        '二维码有效期内可在其他设备确认登录；登录成功后会保留当前账号槽位。',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: ZhPalette.subtleInk,
          height: 1.4,
        ),
      ),
    ],
  );
}

class _InlineLink extends StatelessWidget {
  const _InlineLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(ZhRadius.pill),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ZhPalette.ink,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
  );
}
