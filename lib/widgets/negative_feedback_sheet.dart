import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/negative_feedback.dart';
import '../l10n/zh_localization.dart';
import '../pages/blocked_keywords_page.dart';
import '../pages/native_login_page.dart';
import '../pages/web_page.dart';
import '../ui/components/zh_overlay_components.dart';

Future<bool> showNegativeFeedbackSheet({
  required BuildContext context,
  required ZhihuApiClient api,
  required NegativeFeedbackIdentity identity,
  Future<ApiResponse>? initialResponse,
  Future<ApiResponse> Function()? initialResponseLoader,
  ValueChanged<NegativeFeedbackMenuItem>? onAction,
}) async {
  if (!identity.isUsable) return false;
  return await showZhLiquidGlassSheet<bool>(
        context: context,
        builder: (_) => NegativeFeedbackSheet(
          api: api,
          identity: identity,
          initialResponse: initialResponse,
          initialResponseLoader: initialResponseLoader,
          onAction: onAction,
        ),
      ) ??
      false;
}

class NegativeFeedbackSheet extends StatefulWidget {
  const NegativeFeedbackSheet({
    super.key,
    required this.api,
    required this.identity,
    this.initialResponse,
    this.initialResponseLoader,
    this.onAction,
  }) : assert(initialResponse == null || initialResponseLoader == null);

  final ZhihuApiClient api;
  final NegativeFeedbackIdentity identity;
  final Future<ApiResponse>? initialResponse;
  final Future<ApiResponse> Function()? initialResponseLoader;
  final ValueChanged<NegativeFeedbackMenuItem>? onAction;

  @override
  State<NegativeFeedbackSheet> createState() => _NegativeFeedbackSheetState();
}

class _NegativeFeedbackSheetState extends State<NegativeFeedbackSheet> {
  static const _immediateUninterestAction = NegativeFeedbackAction(
    intentUrl: 'zhihu://uninterest_feed',
  );

  NegativeFeedbackMenuItem _immediateUninterestItem(BuildContext context) =>
      NegativeFeedbackMenuItem(
        label: context.zhL10n.feedbackNotInterested,
        toastText: context.zhL10n.feedbackReduceRecommendation,
        action: _immediateUninterestAction,
        hasRightIcon: false,
        attachedInfo: '',
        isRawButton: true,
      );

  NegativeFeedbackMenu? _menu;
  Object? _error;
  bool _loading = true;
  int? _runningIndex;
  bool _consumedInitialResponse = false;

  @override
  void initState() {
    super.initState();
    // Let the modal route paint its shell before request setup/signing and
    // response parsing get a chance to occupy the UI isolate.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final initialResponse = widget.initialResponse;
      final Future<ApiResponse> request;
      if (!_consumedInitialResponse &&
          (initialResponse != null || widget.initialResponseLoader != null)) {
        _consumedInitialResponse = true;
        request = initialResponse ?? widget.initialResponseLoader!();
      } else {
        request = widget.api.getNegativeFeedbackPanel(widget.identity);
      }
      final response = await request;
      if (!response.isSuccess) throw response;
      final menu = NegativeFeedbackMenu.fromJson(response.json);
      if (!mounted) return;
      setState(() {
        _menu = menu;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  bool get _canImmediatelyUninterest {
    final brief = widget.identity.itemBrief.trim();
    return brief.isNotEmpty && brief.length <= 20000;
  }

  List<NegativeFeedbackMenuItem> _visibleItems(BuildContext context) {
    final items = <NegativeFeedbackMenuItem>[
      if (_canImmediatelyUninterest) _immediateUninterestItem(context),
    ];
    for (final item in _menu?.items ?? const <NegativeFeedbackMenuItem>[]) {
      final duplicateIndex = items.indexWhere(
        (candidate) =>
            candidate.label == item.label ||
            (candidate.action.isUninterest && item.action.isUninterest),
      );
      if (duplicateIndex < 0) {
        items.add(item);
      } else {
        // Prefer the server copy once available because it may carry a newer
        // toast or action contract than the immediate local affordance.
        items[duplicateIndex] = item;
      }
    }
    return items;
  }

  String _errorMessage(Object error) => error is ApiResponse
      ? error.failure.detail
      : ApiFailure.from(error).detail;

  Future<void> _activate(int index, NegativeFeedbackMenuItem item) async {
    if (_runningIndex != null) return;
    final action = item.action;
    if (action.isBlockKeywords) {
      final navigator = Navigator.of(context);
      navigator.pop(false);
      await navigator.push(
        MaterialPageRoute(
          builder: (_) =>
              BlockedKeywordsPage(api: widget.api, identity: widget.identity),
        ),
      );
      return;
    }
    if (action.isReport) {
      await _openReport(action.intentUrl);
      return;
    }
    setState(() => _runningIndex = index);
    try {
      if (action.isUninterest) {
        final response = await widget.api.uninterestFeed(widget.identity);
        if (!response.isSuccess) throw response;
      } else if (item.isRawButton) {
        // The official holder removes raw feedback rows locally. Only
        // alternative_button actions enter the generic backend branch below.
      } else if (action.hasBackend) {
        final response = await widget.api.executeNegativeFeedbackAction(action);
        if (!response.isSuccess) throw response;
      } else if (item.toastText.isEmpty) {
        throw ApiTransportException(context.zhL10n.feedbackMissingAction);
      }
      if (!mounted) return;
      final message = item.toastText.isEmpty
          ? context.zhL10n.feedbackReduced
          : item.toastText;
      final messenger = ScaffoldMessenger.of(context);
      widget.onAction?.call(item);
      Navigator.of(context).pop(item.removesFeedItem);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_errorMessage(error))));
      setState(() => _runningIndex = null);
    }
  }

  Future<void> _openReport(String value) async {
    final navigator = Navigator.of(context);
    if (!widget.api.canWrite) {
      navigator.pop(false);
      await navigator.push(
        MaterialPageRoute(
          builder: (_) =>
              NativeLoginPage(session: widget.api.session, api: widget.api),
        ),
      );
      return;
    }
    var url = value.trim();
    if (url.startsWith('www.zhihu.com/')) url = 'https://$url';
    if (!isAllowedOfficialNavigation(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.zhL10n.feedbackInvalidReport)),
      );
      return;
    }
    navigator.pop(false);
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => OfficialWebPage(
          title: context.zhL10n.commonReport,
          url: url,
          cookieHeader: widget.api.session.cookie,
          requiresSessionCookie: true,
        ),
      ),
    );
  }

  IconData _iconFor(NegativeFeedbackMenuItem item) {
    final text = item.label;
    if (item.action.isReport || text.contains('举报')) {
      return Icons.warning_amber_rounded;
    }
    if (item.action.isBlockKeywords || text.contains('关键词')) {
      return Icons.block_rounded;
    }
    if (text.contains('作者')) return Icons.person_remove_outlined;
    if (text.contains('重复') || text.contains('相似')) {
      return Icons.copy_all_outlined;
    }
    if (text.contains('极端') || text.contains('引战')) {
      return Icons.crisis_alert_outlined;
    }
    if (text.contains('质量')) return Icons.sentiment_dissatisfied_outlined;
    return Icons.heart_broken_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final preferredHeight = (height * 0.86).clamp(300.0, 560.0).toDouble();
    final sheetHeight = preferredHeight > height * 0.86
        ? height * 0.86
        : preferredHeight;
    return SizedBox(
      key: const Key('negative-feedback-sheet'),
      height: sheetHeight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 2, 10, 0),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        context.zhL10n.feedbackTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.zhL10n.commonClose,
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _content() {
    final items = _visibleItems(context);
    final children = <Widget>[];
    for (var index = 0; index < items.length; index++) {
      if (children.isNotEmpty) children.add(const Divider(height: 1));
      children.add(_feedbackTile(index, items[index]));
    }
    if (_loading || _error != null) {
      if (children.isNotEmpty) children.add(const Divider(height: 1));
      children.add(_loading ? _loadingChoices() : _loadError(_error!));
    }
    return ListView(
      key: const Key('negative-feedback-options'),
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
      children: children,
    );
  }

  Widget _feedbackTile(int index, NegativeFeedbackMenuItem item) {
    final running = _runningIndex == index;
    return ListTile(
      key: ValueKey('negative-feedback-item-$index-${item.label}'),
      minTileHeight: 64,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(_iconFor(item), size: 25),
      title: Text(
        item.label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: running
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : item.hasRightIcon ||
                item.action.isBlockKeywords ||
                item.action.isReport
          ? const Icon(Icons.chevron_right_rounded)
          : null,
      onTap: _runningIndex == null ? () => _activate(index, item) : null,
    );
  }

  Widget _loadingChoices() => Padding(
    key: Key('negative-feedback-loading'),
    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 20),
    child: Row(
      children: [
        const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(context.zhL10n.feedbackLoading)),
      ],
    ),
  );

  Widget _loadError(Object error) => Padding(
    key: const Key('negative-feedback-load-error'),
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.wifi_off_rounded),
            const SizedBox(width: 12),
            Expanded(child: Text(_errorMessage(error))),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.zhL10n.feedbackReload),
          ),
        ),
      ],
    ),
  );
}
