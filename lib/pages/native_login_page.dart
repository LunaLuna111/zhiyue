import 'dart:ui' as ui;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/account_session_store.dart';
import '../core/mobile_login_contract.dart';
import '../core/session_store.dart';
import '../l10n/zh_localization.dart';
import '../ui/zh_components.dart';
import '../ui/zh_glass.dart';
import '../ui/zh_theme.dart';
import 'web_page.dart';

part '../features/account/login_widgets.dart';

String maskLoginPhone(String value) {
  final normalized = value.replaceAll(RegExp(r'[\s()-]'), '');
  if (normalized.length < 7) return normalized;
  return '${normalized.substring(0, normalized.length - 8)}'
      '****${normalized.substring(normalized.length - 4)}';
}

enum _LoginMode { sms, password, qr }

class NativeLoginPage extends StatefulWidget {
  const NativeLoginPage({
    super.key,
    required this.session,
    this.api,
    this.embedded = false,
    this.onMenuPressed,
  });

  final SessionStore session;
  final ZhihuApiClient? api;
  final bool embedded;
  final VoidCallback? onMenuPressed;

  @override
  State<NativeLoginPage> createState() => _NativeLoginPageState();
}

class _NativeLoginPageState extends State<NativeLoginPage> {
  final _phone = TextEditingController();
  final _digitsController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _firstOtpFocus = FocusNode();
  final _passwordFocus = FocusNode();
  late final bool _ownsApi = widget.api == null;
  late final ZhihuApiClient _api = widget.api ?? ZhihuApiClient(widget.session);

  Timer? _countdownTimer;
  var _agreed = false;
  var _busy = false;
  var _codeSent = false;
  var _countdown = 0;
  var _digits = '';
  var _otpRevision = 0;
  var _mode = _LoginMode.sms;
  var _obscurePassword = true;
  String? _feedback;
  var _feedbackIsError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.embedded) _phoneFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phone.dispose();
    _digitsController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _firstOtpFocus.dispose();
    _passwordFocus.dispose();
    if (_ownsApi) _api.close();
    super.dispose();
  }

  bool _validate({bool requireDigits = false}) {
    try {
      MobileLoginContract.normalizeUsername(_phone.text);
      if (requireDigits) MobileLoginContract.normalizeDigits(_digits);
      _setFeedback(null);
      return true;
    } on FormatException catch (error) {
      _setFeedback(error.message.toString(), isError: true);
      return false;
    }
  }

  bool _validatePassword() {
    try {
      MobileLoginContract.normalizePasswordUsername(_phone.text);
      if (_passwordController.text.isEmpty) {
        throw FormatException(context.zhL10n.loginPasswordRequired);
      }
      _setFeedback(null);
      return true;
    } on FormatException catch (error) {
      _setFeedback(error.message.toString(), isError: true);
      return false;
    }
  }

  Future<bool> _ensureAgreement() async {
    if (_agreed) return true;
    FocusManager.instance.primaryFocus?.unfocus();
    final agreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AgreementConsentDialog(),
    );
    if (!mounted || agreed != true) return false;
    setState(() => _agreed = true);
    return true;
  }

  void _setFeedback(String? message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _feedback = message;
      _feedbackIsError = isError;
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _countdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _countdown = 0);
        return;
      }
      setState(() => _countdown -= 1);
    });
  }

  void _switchLoginMode() {
    if (_busy) return;
    _countdownTimer?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _mode = _mode == _LoginMode.sms ? _LoginMode.password : _LoginMode.sms;
      _codeSent = false;
      _countdown = 0;
      _digits = '';
      _digitsController.clear();
      _feedback = null;
      _otpRevision += 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _phoneFocus.requestFocus();
    });
  }

  void _switchQrMode() {
    if (_busy) return;
    _countdownTimer?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _mode = _mode == _LoginMode.qr ? _LoginMode.sms : _LoginMode.qr;
      _codeSent = false;
      _countdown = 0;
      _digits = '';
      _digitsController.clear();
      _feedback = null;
      _otpRevision += 1;
    });
  }

  Future<void> _onQrLoginSuccess() async {
    final saved = await AccountSessionStore.instance.rememberCurrent(
      widget.session,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? context.zhL10n.loginScanSuccess
              : context.zhL10n.loginQrSaveFailed,
        ),
      ),
    );
    if (!widget.embedded) Navigator.of(context).pop(true);
  }

  Future<bool> _rememberLoggedInSession() async {
    final saved = await AccountSessionStore.instance.rememberCurrent(
      widget.session,
    );
    if (!mounted) return saved;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? context.zhL10n.loginSuccess
              : context.zhL10n.loginQrSaveFailed,
        ),
      ),
    );
    return saved;
  }

  Future<void> _requestDigits() async {
    if (_busy || (_codeSent && _countdown > 0)) return;
    if (!await _ensureAgreement() || !_validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _feedback = null;
    });
    try {
      final result = await _api.requestLoginDigits(username: _phone.text);
      if (!mounted) return;
      if (result.sent) {
        _digitsController.clear();
        setState(() {
          _codeSent = true;
          _digits = '';
          _otpRevision += 1;
          _feedback = result.message;
          _feedbackIsError = false;
        });
        _startCountdown();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _firstOtpFocus.requestFocus();
        });
      } else {
        _setFeedback(result.message, isError: true);
      }
      if (result.requiresCaptcha && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.zhL10n.loginHumanVerification)),
        );
      }
    } catch (_) {
      if (mounted) {
        _setFeedback(context.zhL10n.loginCodeSendFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signIn() async {
    if (_busy) return;
    if (!await _ensureAgreement() || !_validate(requireDigits: true)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _feedback = null;
    });
    try {
      final result = await _api.signInWithDigits(
        username: _phone.text,
        digits: _digits,
      );
      if (!mounted) return;
      _setFeedback(result.message, isError: !result.signedIn);
      if (result.signedIn) {
        await _rememberLoggedInSession();
        if (!mounted) return;
        if (!widget.embedded) Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        _setFeedback(context.zhL10n.loginFailedNetwork, isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithPassword() async {
    if (_busy) return;
    if (!await _ensureAgreement() || !_validatePassword()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _feedback = null;
    });
    try {
      final result = await _api.signInWithPassword(
        username: _phone.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      _setFeedback(result.message, isError: !result.signedIn);
      if (result.signedIn) {
        await _rememberLoggedInSession();
        if (!mounted) return;
        if (!widget.embedded) Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        _setFeedback(context.zhL10n.loginFailedCredentials, isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _editPhone() {
    _countdownTimer?.cancel();
    setState(() {
      _codeSent = false;
      _countdown = 0;
      _digits = '';
      _digitsController.clear();
      _feedback = null;
      _otpRevision += 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _phoneFocus.requestFocus();
    });
  }

  void _selectLoginStep(int index) {
    if (_busy) return;
    if (_mode == _LoginMode.password) {
      (index == 0 ? _phoneFocus : _passwordFocus).requestFocus();
      return;
    }
    if (index == 0 && _codeSent) _editPhone();
  }

  void _openOfficialHelp(String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OfficialWebPage(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toolbarHeight = widget.embedded ? 56.0 : 46.0;
    final contentTopPadding =
        ZhTopBar.bodyTopInset(context, toolbarHeight: toolbarHeight) + 18;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: dark
            ? const Color(0xFF101419)
            : const Color(0xFFF4F6FA),
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: dark
            ? const Color(0xFF111821)
            : const Color(0xFFF1F6FF),
        key: widget.embedded ? const ValueKey('embedded-native-login') : null,
        appBar: widget.embedded
            ? ZhTopBar(
                leading: widget.onMenuPressed == null
                    ? null
                    : ZhLiquidGlassIconButton(
                        size: 46,
                        iconSize: 24,
                        semanticLabel: context.zhL10n.drawerOpen,
                        onPressed: widget.onMenuPressed,
                        icon: const Icon(Icons.menu_rounded),
                      ),
                title: Text(context.zhL10n.loginTitle),
              )
            : ZhTopBar(
                toolbarHeight: toolbarHeight,
                automaticallyImplyLeading: false,
              ),
        body: Stack(
          children: [
            const Positioned.fill(child: _LoginBackdrop()),
            SafeArea(
              top: false,
              child: ZhPageWidth(
                maxWidth: 600,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(20, contentTopPadding, 20, 36),
                  children: [
                    _LoginHeader(
                      passwordMode: _mode == _LoginMode.password,
                      qrMode: _mode == _LoginMode.qr,
                    ),
                    const SizedBox(height: 30),
                    if (_mode != _LoginMode.qr) ...[
                      _LoginProgress(
                        codeSent: _codeSent,
                        passwordMode: _mode == _LoginMode.password,
                        onStepSelected: _selectLoginStep,
                      ),
                      const SizedBox(height: 30),
                    ],
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.045, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _mode == _LoginMode.qr
                          ? _QrLoginPane(
                              key: const ValueKey('qr-login-pane'),
                              api: _api,
                              onLoginSuccess: _onQrLoginSuccess,
                            )
                          : _mode == _LoginMode.password
                          ? _buildPasswordStep()
                          : _codeSent
                          ? _buildCodeStep()
                          : _buildPhoneStep(),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: _feedback == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: ZhSpace.sm),
                              child: _FeedbackMessage(
                                message: _feedback!,
                                isError: _feedbackIsError,
                              ),
                            ),
                    ),
                    if (_mode != _LoginMode.qr) ...[
                      const SizedBox(height: ZhSpace.lg),
                      _LoginPrimaryButton(
                        busy: _busy,
                        label: _mode == _LoginMode.password
                            ? context.zhL10n.loginTitle
                            : (_codeSent
                                  ? context.zhL10n.loginContinueSignIn
                                  : context.zhL10n.loginGetCode),
                        onPressed: _busy
                            ? null
                            : _mode == _LoginMode.password
                            ? _signInWithPassword
                            : (_codeSent ? _signIn : _requestDigits),
                      ),
                      const SizedBox(height: ZhSpace.sm),
                      if (!_codeSent || _mode == _LoginMode.password)
                        _buildAgreement(),
                      if (_codeSent && _mode == _LoginMode.sms)
                        _buildCodeActions(),
                      const SizedBox(height: 4),
                      _LoginTextButton(
                        key: const ValueKey('login-mode-toggle'),
                        onPressed: _busy ? null : _switchLoginMode,
                        label: _mode == _LoginMode.password
                            ? context.zhL10n.loginPhoneSignIn
                            : context.zhL10n.loginPasswordSignIn,
                      ),
                    ],
                    const SizedBox(height: 4),
                    _LoginTextButton(
                      key: const ValueKey('qr-login-mode-toggle'),
                      onPressed: _busy ? null : _switchQrMode,
                      label: _mode == _LoginMode.qr
                          ? context.zhL10n.loginPhoneSignIn
                          : context.zhL10n.loginQrSignIn,
                    ),
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: ZhSpace.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _LoginTextButton(
                        onPressed: () => _openOfficialHelp(
                          context.zhL10n.loginAccountAppeal,
                          'https://www.zhihu.com/account/appeal?utm_source=android',
                        ),
                        label: context.zhL10n.loginAccountAppealHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneStep() => Column(
    key: const ValueKey('login-phone-step'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _LoginGlassTextField(
        key: const ValueKey('login-phone-input'),
        controller: _phone,
        focusNode: _phoneFocus,
        placeholder: context.zhL10n.loginPhonePlaceholder,
        prefixIcon: Icons.phone_iphone_rounded,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\s-]')),
        ],
        onSubmitted: (_) => _requestDigits(),
      ),
    ],
  );

  Widget _buildPasswordStep() => Column(
    key: const ValueKey('login-password-step'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _LoginGlassTextField(
        key: const ValueKey('login-username-input'),
        controller: _phone,
        focusNode: _phoneFocus,
        placeholder: context.zhL10n.loginAccountPlaceholder,
        prefixIcon: Icons.person_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _passwordFocus.requestFocus(),
      ),
      const SizedBox(height: 12),
      _LoginGlassTextField(
        key: const ValueKey('login-password-input'),
        controller: _passwordController,
        focusNode: _passwordFocus,
        enabled: !_busy,
        obscureText: _obscurePassword,
        placeholder: context.zhL10n.loginPasswordPlaceholder,
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: ZhPalette.mutedInk,
          size: 21,
        ),
        onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _signInWithPassword(),
      ),
    ],
  );

  Widget _buildCodeStep() => Column(
    key: const ValueKey('login-code-step'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              context.zhL10n.loginCodeSent(maskLoginPhone(_phone.text)),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
            ),
          ),
          _LoginTextButton(
            onPressed: _busy ? null : _editPhone,
            label: context.zhL10n.loginChangePhone,
          ),
        ],
      ),
      const SizedBox(height: ZhSpace.md),
      _LoginGlassTextField(
        key: ValueKey('login-otp-$_otpRevision'),
        controller: _digitsController,
        focusNode: _firstOtpFocus,
        enabled: !_busy,
        placeholder: context.zhL10n.loginCodePlaceholder,
        prefixIcon: Icons.password_rounded,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        onChanged: (value) {
          if (value == _digits) return;
          setState(() => _digits = value);
          if (value.length == 6) _signIn();
        },
        onSubmitted: (_) => _signIn(),
      ),
    ],
  );

  Widget _buildAgreement() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 44,
        height: 44,
        child: Checkbox(
          value: _agreed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onChanged: (value) => setState(() => _agreed = value ?? false),
        ),
      ),
      Expanded(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              context.zhL10n.loginAgree,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            _InlineLink(
              label: context.zhL10n.loginUserAgreement,
              onTap: () => _openOfficialHelp(
                context.zhL10n.loginUserAgreement,
                'https://www.zhihu.com/term/zhihu-terms',
              ),
            ),
            Text(
              context.zhL10n.loginPrivacyPolicy,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildCodeActions() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        context.zhL10n.loginNoCode,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      _LoginTextButton(
        onPressed: !_busy && _countdown == 0 ? _requestDigits : null,
        label: _countdown == 0
            ? context.zhL10n.commonRefresh
            : context.zhL10n.loginResendAfter(_countdown),
      ),
    ],
  );
}
