part of '../../pages/native_login_page.dart';

const _loginGlassSettings = LiquidGlassSettings(
  thickness: 26,
  blur: 12,
  chromaticAberration: .14,
  lightIntensity: .62,
  refractiveIndex: 1.51,
  saturation: .92,
  ambientStrength: .78,
  glassColor: Color(0xC9FFFFFF),
);

const _loginProgressGlassSettings = LiquidGlassSettings(
  thickness: 34,
  blur: 5,
  chromaticAberration: .35,
  lightIntensity: .7,
  refractiveIndex: 1.59,
  saturation: .85,
  ambientStrength: .85,
  glassColor: Color(0x55FFFFFF),
);

const _loginProgressIndicatorSettings = LiquidGlassSettings(
  thickness: 38,
  blur: 2,
  chromaticAberration: .28,
  lightIntensity: .82,
  refractiveIndex: 1.5,
  saturation: 1,
  ambientStrength: .95,
  glassColor: Color(0x66FFFFFF),
);

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF1F6FF), Color(0xFFF9FBFF), Color(0xFFF4F6FA)],
              stops: [0, .52, 1],
            ),
          ),
        ),
        Positioned(
          top: -86,
          right: -54,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 34, sigmaY: 34),
            child: const _LoginGlow(size: 230, color: Color(0x2D9AC8FF)),
          ),
        ),
        Positioned(
          left: -112,
          bottom: 80,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 46, sigmaY: 46),
            child: const _LoginGlow(size: 260, color: Color(0x1ECCD8FF)),
          ),
        ),
      ],
    ),
  );
}

class _LoginGlow extends StatelessWidget {
  const _LoginGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: SizedBox.square(dimension: size),
  );
}

class _LoginGlassTextField extends StatelessWidget {
  const _LoginGlassTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.prefixIcon,
    required this.keyboardType,
    required this.textInputAction,
    required this.onSubmitted,
    this.enabled = true,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.inputFormatters,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String> onSubmitted;
  final bool enabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => GlassTextField(
    key: key,
    controller: controller,
    focusNode: focusNode,
    enabled: enabled,
    obscureText: obscureText,
    placeholder: placeholder,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    inputFormatters: inputFormatters,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    prefixIcon: Icon(
      prefixIcon,
      size: 21,
      color: enabled ? ZhPalette.mutedInk : ZhPalette.subtleInk,
    ),
    suffixIcon: suffixIcon,
    onSuffixTap: onSuffixTap,
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    iconSpacing: 12,
    shape: const LiquidRoundedRectangle(borderRadius: 32),
    settings: _loginGlassSettings,
    useOwnLayer: true,
    quality: GlassQuality.premium,
    interactionBehavior: GlassInteractionBehavior.full,
    pressScale: 1.015,
    textStyle: Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.2),
    placeholderStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: ZhPalette.subtleInk,
      fontSize: 17,
      height: 1.2,
    ),
  );
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({this.passwordMode = false, this.qrMode = false});

  final bool passwordMode;
  final bool qrMode;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const ZhBrandMark(size: 66),
      ),
      const SizedBox(width: 18),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('登录知乎', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              qrMode
                  ? '知乎 App 扫码登录'
                  : passwordMode
                  ? '使用账号密码安全登录'
                  : '手机号快捷登录',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
            ),
          ],
        ),
      ),
    ],
  );
}

class _LoginProgress extends StatelessWidget {
  const _LoginProgress({
    required this.codeSent,
    this.passwordMode = false,
    this.onStepSelected,
  });

  final bool codeSent;
  final bool passwordMode;
  final ValueChanged<int>? onStepSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: passwordMode
        ? '登录进度：账号密码'
        : codeSent
        ? '登录进度：验证码'
        : '登录进度：手机号',
    child: GlassTabBar.inline(
      key: const ValueKey('login-progress-tabs'),
      tabs: [
        GlassTab(
          label: passwordMode ? '账号' : '手机号',
          semanticLabel: passwordMode ? '账号' : '手机号',
        ),
        GlassTab(
          label: passwordMode ? '密码' : '验证码',
          semanticLabel: passwordMode ? '密码' : '验证码',
        ),
      ],
      selectedIndex: passwordMode ? 0 : (codeSent ? 1 : 0),
      onTabSelected: onStepSelected ?? (_) {},
      horizontalPadding: 0,
      verticalPadding: 0,
      barHeight: 58,
      barBorderRadius: 29,
      spacing: 0,
      tabPadding: const EdgeInsets.symmetric(horizontal: 4),
      indicatorExpansion: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 5,
      ),
      indicatorColor: const Color(0x24000000),
      indicatorSettings: _loginProgressIndicatorSettings,
      indicatorPinchStrength: .28,
      selectedLabelStyle: const TextStyle(
        color: ZhPalette.ink,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      unselectedLabelStyle: const TextStyle(
        color: ZhPalette.mutedInk,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      settings: _loginProgressGlassSettings,
      quality: GlassQuality.premium,
      backgroundQuality: GlassQuality.standard,
      interactionBehavior: GlassInteractionBehavior.full,
      pressScale: 1.02,
    ),
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
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(18);
    final topColor = enabled
        ? const Color(0xFF2B2B2B)
        : const Color(0xFF555555);
    final bottomColor = enabled
        ? const Color(0xFF151515)
        : const Color(0xFF3E3E3E);

    // Keep the primary CTA on a regular composited surface. The prominent
    // liquid-glass shader is intentionally unsuitable here: when a scrolling
    // viewport invalidates its backdrop, the shader can brighten both the
    // dark surface and its white label until the button looks disabled.
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, bottomColor],
            ),
            border: Border.all(color: const Color(0x28FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Center(
              child: busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ZhPalette.background,
                      ),
                    )
                  : Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ZhPalette.background,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
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
