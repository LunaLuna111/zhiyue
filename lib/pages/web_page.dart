import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/privacy_device_profile.dart';
import '../l10n/zh_localization.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';

part 'web_page_parts/privacy_profile.dart';

/// `webview_flutter` ships Android, iOS and macOS implementations.  Windows,
/// Linux and the browser use the safe external-browser/text fallback instead
/// of constructing a controller that has no registered host implementation.
bool get supportsEmbeddedOfficialWebView {
  if (kIsWeb) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    _ => false,
  };
}

bool isAllowedOfficialNavigation(String value) {
  final uri = Uri.tryParse(value);
  return uri?.scheme == 'https' &&
      uri!.userInfo.isEmpty &&
      (!uri.hasPort || uri.port == 443) &&
      (uri.host == 'zhihu.com' || uri.host.endsWith('.zhihu.com'));
}

bool isOfficialLoginNavigation(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || !isAllowedOfficialNavigation(value)) return false;
  return uri.path == '/signin' ||
      uri.path.startsWith('/signin/') ||
      uri.path == '/account/login' ||
      uri.path.startsWith('/account/unhuman');
}

/// The native client routes account/network safety verification through its
/// official `unhuman` page. Keep this URL in one place so an anonymous API
/// challenge never falls through to a generic login screen or an untrusted
/// browser destination.
const zhihuSafetyVerificationUrl =
    'https://www.zhihu.com/account/unhuman?type=unhuman';

/// Opens the official verification page only after an explicit user action.
/// The returned future completes when the user comes back, allowing the
/// caller to refresh its anonymous request without changing the page while
/// the verification screen is still visible.
Future<void> openZhihuSafetyVerification(BuildContext context) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'zhihu-safety-verification'),
      builder: (_) => OfficialWebPage(
        title: context.zhL10n.webSafetyTitle,
        url: zhihuSafetyVerificationUrl,
      ),
    ),
  );
}

class OfficialCookiePair {
  const OfficialCookiePair({required this.name, required this.value});

  final String name;
  final String value;
}

List<OfficialCookiePair> parseOfficialCookieHeader(String header) {
  final result = <OfficialCookiePair>[];
  final seen = <String>{};
  for (final part in header.split(';')) {
    final separator = part.indexOf('=');
    if (separator <= 0) continue;
    final name = part.substring(0, separator).trim();
    final value = part.substring(separator + 1).trim();
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(name) || value.isEmpty) {
      continue;
    }
    if (seen.add(name)) {
      result.add(OfficialCookiePair(name: name, value: value));
    }
  }
  return result;
}

class OfficialWebPage extends StatefulWidget {
  const OfficialWebPage({
    super.key,
    required this.title,
    required this.url,
    this.cookieHeader = '',
    this.requiresSessionCookie = false,
    this.previousUrl,
    this.nextUrl,
    this.onChapterNavigation,
    this.allowExternalNavigation = false,
  });

  final String title;
  final String url;
  final String cookieHeader;
  final bool requiresSessionCookie;
  final String? previousUrl;
  final String? nextUrl;
  final ValueChanged<String>? onChapterNavigation;
  final bool allowExternalNavigation;

  @override
  State<OfficialWebPage> createState() => _OfficialWebPageState();
}

class _OfficialWebPageState extends State<OfficialWebPage> {
  static const _androidCookieChannel = MethodChannel(
    'com.zhiyue.client/official_web_cookie',
  );
  static const _androidWebPrivacyChannel = MethodChannel(
    'com.zhiyue.client/web_privacy',
  );

  WebViewController? _controller;
  var _progress = 0;
  String? _pageError;
  Uri? _targetUri;
  Uri? _currentUri;
  var _preparing = true;
  var _pageReady = false;
  var _canGoBack = false;
  late String _displayTitle = widget.title;

  bool get _supportsEmbeddedWebView => supportsEmbeddedOfficialWebView;

  bool _isAllowedNavigation(String value) {
    if (!widget.allowExternalNavigation) {
      return isAllowedOfficialNavigation(value);
    }
    final uri = Uri.tryParse(value);
    final target = _targetUri;
    if (uri == null || target == null || uri.userInfo.isNotEmpty) return false;
    if (!const {'http', 'https'}.contains(uri.scheme)) return false;
    if (uri.host.toLowerCase() != target.host.toLowerCase()) return false;
    return !uri.hasPort ||
        (uri.scheme == 'https' && uri.port == 443) ||
        (uri.scheme == 'http' && uri.port == 80);
  }

  @override
  void initState() {
    super.initState();
    if (!_supportsEmbeddedWebView) return;
    _targetUri = Uri.parse(widget.url);
    _controller = WebViewController()
      ..setUserAgent(PrivacyDeviceProfile.appUserAgent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value);
          },
          onPageStarted: (value) {
            final controller = _controller;
            if (controller != null) {
              unawaited(_applyWebPrivacyProfile(controller));
            }
            if (!mounted) return;
            setState(() {
              _currentUri = Uri.tryParse(value);
              _pageError = null;
              _preparing = false;
              _pageReady = false;
            });
          },
          onPageFinished: (value) {
            _pageFinished(value);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != false && mounted) {
              setState(() {
                _preparing = false;
                _pageReady = false;
                _pageError = context.zhL10n.webPageLoadFailedNetwork;
              });
            }
          },
          onHttpError: (error) {
            final requestUri = error.request?.uri;
            final current = _currentUri;
            if (mounted &&
                requestUri != null &&
                current != null &&
                requestUri == current &&
                (error.response?.statusCode ?? 0) >= 400) {
              setState(() {
                _pageReady = false;
                _pageError = context.zhL10n.webPageUnavailable;
              });
            }
          },
          onUrlChange: (change) {
            final value = change.url;
            if (value == null || !mounted) return;
            setState(() => _currentUri = Uri.tryParse(value));
          },
          onNavigationRequest: (request) {
            return _isAllowedNavigation(request.url)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      );
    _prepareCookiesAndLoad();
  }

  @override
  void didUpdateWidget(OfficialWebPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.title != oldWidget.title && _displayTitle == oldWidget.title) {
      _displayTitle = widget.title;
    }
  }

  Future<void> _prepareCookiesAndLoad() async {
    final controller = _controller;
    if (controller == null) return;
    if (mounted) {
      setState(() {
        _preparing = true;
        _pageReady = false;
        _pageError = null;
        _progress = 0;
      });
    }
    try {
      final uri = _targetUri ?? Uri.parse(widget.url);
      await _installAndroidDocumentStartPrivacyProfile();
      final cookies = parseOfficialCookieHeader(widget.cookieHeader);
      final cookieNames = cookies.map((cookie) => cookie.name).toSet();
      if (widget.requiresSessionCookie && !cookieNames.contains('z_c0')) {
        throw const FormatException('missing z_c0');
      }
      if (cookies.isNotEmpty) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          final response = await _androidCookieChannel
              .invokeMapMethod<Object?, Object?>('sync', {
                'url': uri.toString(),
                'cookies': [
                  for (final cookie in cookies)
                    {'name': cookie.name, 'value': cookie.value},
                ],
              });
          final presentNames =
              (response?['presentNames'] as List<Object?>? ?? [])
                  .whereType<String>()
                  .toSet();
          if (widget.requiresSessionCookie && !presentNames.contains('z_c0')) {
            throw const FormatException('z_c0 not stored');
          }
          assert(() {
            final accepted =
                (response?['acceptedNames'] as List<Object?>? ?? [])
                    .whereType<String>()
                    .join(',');
            debugPrint(
              '[zhihu-web] cookieSync requested=${cookieNames.join(',')} '
              'accepted=$accepted present=${presentNames.join(',')}',
            );
            return true;
          }());
        } else {
          final manager = WebViewCookieManager();
          for (final cookie in _cookiesForWebView(cookies, uri.host)) {
            await manager.setCookie(cookie);
          }
        }
      }
      await controller.loadRequest(uri);
    } catch (error) {
      assert(() {
        debugPrint('[zhihu-web] prepareFailure=${error.runtimeType}');
        return true;
      }());
      if (mounted) {
        setState(() {
          _preparing = false;
          _pageReady = false;
          _pageError = widget.requiresSessionCookie
              ? context.zhL10n.webSessionSyncFailed
              : context.zhL10n.commonFailed;
        });
      }
    }
  }

  Future<void> _installAndroidDocumentStartPrivacyProfile() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await WidgetsBinding.instance.endOfFrame;
      final response = await _androidWebPrivacyChannel
          .invokeMapMethod<String, Object?>('installDocumentStart', {
            'script': buildPrivacyWebFingerprintScript(),
          })
          .timeout(const Duration(seconds: 2));
      assert(() {
        debugPrint(
          '[zhihu-web] documentStartPrivacy '
          'supported=${response?['supported']} installed=${response?['installed']}',
        );
        return true;
      }());
    } on Object catch (error) {
      assert(() {
        debugPrint('[zhihu-web] documentStartPrivacy=${error.runtimeType}');
        return true;
      }());
    }
  }

  List<WebViewCookie> _cookiesForWebView(
    List<OfficialCookiePair> cookies,
    String host,
  ) {
    final domain = host == 'zhihu.com' || host.endsWith('.zhihu.com')
        ? '.zhihu.com'
        : host;
    return [
      for (final cookie in cookies)
        WebViewCookie(name: cookie.name, value: cookie.value, domain: domain),
    ];
  }

  Future<void> _pageFinished(String value) async {
    final controller = _controller;
    if (controller == null) return;
    final current = Uri.tryParse(value);
    await _applyWebPrivacyProfile(controller);
    if (widget.requiresSessionCookie) {
      await _applyReaderPresentation(controller);
    }
    final canGoBack = await controller.canGoBack();
    final title = (await controller.getTitle())?.trim() ?? '';
    assert(() {
      debugPrint(
        '[zhihu-web] pageFinished url=$value '
        'loginRedirect=${isOfficialLoginNavigation(value)}',
      );
      return true;
    }());
    if (!mounted) return;
    setState(() {
      _currentUri = current;
      _progress = 100;
      _preparing = false;
      _pageReady = true;
      _canGoBack = canGoBack;
      if (title.isNotEmpty) _displayTitle = title;
      if (widget.requiresSessionCookie && isOfficialLoginNavigation(value)) {
        _pageReady = false;
        _pageError = context.zhL10n.webLoginExpired;
      }
    });
  }

  Future<void> _applyWebPrivacyProfile(WebViewController controller) async {
    try {
      await controller.runJavaScript(buildPrivacyWebFingerprintScript());
    } catch (error) {
      assert(() {
        debugPrint('[zhihu-web] privacyProfile=${error.runtimeType}');
        return true;
      }());
    }
  }

  Future<void> _applyReaderPresentation(WebViewController controller) async {
    try {
      await controller.runJavaScript(r'''
(() => {
  const clean = () => {
    for (const element of document.querySelectorAll('a,button,[role="button"]')) {
      const label = (element.innerText || element.textContent || '')
        .replace(/\s+/g, ' ')
        .trim();
      if (label === 'App 内打开' || label === '打开 App') {
        element.style.setProperty('display', 'none', 'important');
      }
    }
  };
  clean();
  if (!window.__zhiyueReaderCleanup) {
    window.__zhiyueReaderCleanup = new MutationObserver(clean);
    window.__zhiyueReaderCleanup.observe(document.documentElement, {
      childList: true,
      subtree: true,
    });
  }
})();
''');
    } catch (error) {
      assert(() {
        debugPrint('[zhihu-web] readerPresentation=${error.runtimeType}');
        return true;
      }());
    }
  }

  Future<void> _handleBack() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return;
    }
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _openChapter(String? value) async {
    if (value == null || !isAllowedOfficialNavigation(value)) return;
    final onChapterNavigation = widget.onChapterNavigation;
    if (onChapterNavigation != null) {
      onChapterNavigation(value);
      return;
    }
    final uri = Uri.parse(value);
    _targetUri = uri;
    if (mounted) {
      setState(() {
        _pageError = null;
        _pageReady = false;
        _progress = 0;
      });
    }
    await _controller?.loadRequest(uri);
  }

  Future<void> _openExternal() async {
    final uri = _currentUri ?? _targetUri ?? Uri.parse(widget.url);
    if (!isAllowedOfficialNavigation(uri.toString())) return;
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!opened && mounted) {
      setState(() => _pageError = context.zhL10n.webSystemBrowserUnavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsEmbeddedWebView) {
      return Scaffold(
        appBar: ZhTopBar(title: Text(widget.title)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ZhSurface(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_new, size: 44),
                  const SizedBox(height: 16),
                  Text(
                    kIsWeb
                        ? context.zhL10n.webContinueInBrowser
                        : context.zhL10n.webDesktopSystemBrowser,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  ZhPrimaryButton(
                    onPressed: _openExternal,
                    icon: Icons.open_in_browser,
                    label: context.zhL10n.webOpenBrowser,
                  ),
                  if (_pageError != null) ...[
                    const SizedBox(height: 12),
                    Text(_pageError!),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }
    final controller = _controller!;
    return PopScope<void>(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _canGoBack) controller.goBack();
      },
      child: Scaffold(
        appBar: ZhTopBar(
          leading: ZhLiquidGlassIconButton(
            size: 46,
            iconSize: 24,
            semanticLabel: context.zhL10n.commonBack,
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(
            _displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            ZhLiquidGlassIconButton(
              size: 44,
              iconSize: 22,
              semanticLabel: context.zhL10n.commonRefresh,
              onPressed: _preparing ? null : _prepareCookiesAndLoad,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: _progress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(value: _progress / 100),
                )
              : null,
        ),
        body: Stack(
          children: [
            Positioned.fill(child: WebViewWidget(controller: controller)),
            if (_preparing || (!_pageReady && _pageError == null))
              Positioned.fill(
                child: ColoredBox(
                  color: ZhPalette.background,
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 34, 20, 40),
                    children: [
                      const ZhSkeleton(width: 168, height: 24, radius: 10),
                      const SizedBox(height: 18),
                      const ZhSkeleton(
                        width: double.infinity,
                        height: 18,
                        radius: 8,
                      ),
                      const SizedBox(height: 10),
                      const ZhSkeleton(
                        width: double.infinity,
                        height: 18,
                        radius: 8,
                      ),
                      const SizedBox(height: 10),
                      const FractionallySizedBox(
                        widthFactor: .72,
                        child: ZhSkeleton(
                          width: double.infinity,
                          height: 18,
                          radius: 8,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const ZhSkeleton(height: 230, radius: ZhRadius.card),
                      const SizedBox(height: 24),
                      const ZhSkeleton(width: 220, height: 22, radius: 10),
                      const SizedBox(height: 14),
                      const ZhSkeleton(
                        width: double.infinity,
                        height: 18,
                        radius: 8,
                      ),
                      const SizedBox(height: 10),
                      const FractionallySizedBox(
                        widthFactor: .86,
                        child: ZhSkeleton(
                          width: double.infinity,
                          height: 18,
                          radius: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_pageError case final message?)
              Positioned.fill(
                child: ColoredBox(
                  color: ZhPalette.background,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ZhSurface(
                        margin: const EdgeInsets.all(ZhSpace.lg),
                        padding: const EdgeInsets.all(ZhSpace.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: 42,
                              color: ZhPalette.danger,
                            ),
                            const SizedBox(height: ZhSpace.md),
                            Text(message, textAlign: TextAlign.center),
                            const SizedBox(height: ZhSpace.md),
                            ZhPrimaryButton(
                              onPressed: _prepareCookiesAndLoad,
                              label: context.zhL10n.commonRetry,
                              icon: Icons.refresh_rounded,
                              expand: true,
                            ),
                            const SizedBox(height: ZhSpace.xs),
                            ZhGhostButton(
                              onPressed: _openExternal,
                              label: context.zhL10n.webOpenInBrowser,
                              icon: Icons.open_in_browser_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar:
            widget.previousUrl == null && widget.nextUrl == null
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: ZhPalette.background,
                    border: Border(top: BorderSide(color: ZhPalette.border)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: IconButton(
                          onPressed: widget.previousUrl == null
                              ? null
                              : () => _openChapter(widget.previousUrl),
                          tooltip: context.zhL10n.saltPreviousChapter,
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          context.zhL10n.webChapterReading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      SizedBox(
                        width: 72,
                        child: IconButton(
                          onPressed: widget.nextUrl == null
                              ? null
                              : () => _openChapter(widget.nextUrl),
                          tooltip: context.zhL10n.saltNextChapter,
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class HtmlReaderPage extends StatefulWidget {
  const HtmlReaderPage({super.key, required this.title, required this.html});

  final String title;
  final String html;

  @override
  State<HtmlReaderPage> createState() => _HtmlReaderPageState();
}

class _HtmlReaderPageState extends State<HtmlReaderPage> {
  WebViewController? _controller;
  late final String _safeHtml;

  bool get _supportsEmbeddedWebView => supportsEmbeddedOfficialWebView;

  @override
  void initState() {
    super.initState();
    _safeHtml = _sanitize(widget.html);
    if (!_supportsEmbeddedWebView) return;
    _controller = WebViewController()
      ..setUserAgent(PrivacyDeviceProfile.appUserAgent)
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (_) => NavigationDecision.prevent,
        ),
      )
      ..loadHtmlString('''
<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1">
<style>body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;line-height:1.75;padding:16px;color:#222}img{max-width:100%;height:auto}pre{white-space:pre-wrap}a{color:#0066cc}</style>
</head><body>$_safeHtml</body></html>
''');
  }

  String _sanitize(String value) => value
      .replaceAll(
        RegExp(r'<script\b[^>]*>[\s\S]*?</script>', caseSensitive: false),
        '',
      )
      .replaceAll(
        RegExp(r'<iframe\b[^>]*>[\s\S]*?</iframe>', caseSensitive: false),
        '',
      )
      .replaceAll(
        RegExp("\\son\\w+\\s*=\\s*([\"']).*?\\1", caseSensitive: false),
        '',
      );

  String _plainText(String value) => value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZhTopBar(title: Text(widget.title)),
      body: !_supportsEmbeddedWebView
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: SelectableText(
                    _plainText(_safeHtml),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.75),
                  ),
                ),
              ),
            )
          : WebViewWidget(controller: _controller!),
    );
  }
}
