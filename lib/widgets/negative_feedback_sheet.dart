import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/api_response.dart';
import '../core/negative_feedback.dart';
import '../pages/blocked_keywords_page.dart';
import '../pages/native_login_page.dart';
import '../pages/web_page.dart';
import '../ui/zh_theme.dart';

Future<bool> showNegativeFeedbackSheet({
  required BuildContext context,
  required ZhihuApiClient api,
  required NegativeFeedbackIdentity identity,
  Future<ApiResponse>? initialResponse,
  Future<ApiResponse> Function()? initialResponseLoader,
  ValueChanged<NegativeFeedbackMenuItem>? onAction,
}) async {
  if (!identity.isUsable) return false;
  return await showModalBottomSheet<bool>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
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
  static const _immediateUninterestItem = NegativeFeedbackMenuItem(
    label: '不喜欢该内容',
    toastText: '将减少推荐',
    action: NegativeFeedbackAction(intentUrl: 'zhihu://uninterest_feed'),
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

  List<NegativeFeedbackMenuItem> get _visibleItems {
    final items = <NegativeFeedbackMenuItem>[
      if (_canImmediatelyUninterest) _immediateUninterestItem,
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
        throw const ApiTransportException('该反馈项缺少可执行动作');
      }
      if (!mounted) return;
      final message = item.toastText.isEmpty ? '已减少此类内容' : item.toastText;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('举报地址无效')));
      return;
    }
    navigator.pop(false);
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => OfficialWebPage(
          title: '举报',
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
      child: Material(
        color: ZhPalette.background,
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: ZhPalette.mutedInk,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
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
                          '减少此类内容',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
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
      ),
    );
  }

  Widget _content() {
    final items = _visibleItems;
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

  Widget _loadingChoices() => const Padding(
    key: Key('negative-feedback-loading'),
    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 20),
    child: Row(
      children: [
        SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 16),
        Expanded(child: Text('正在加载更多反馈选项…')),
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
            label: const Text('重新加载'),
          ),
        ),
      ],
    ),
  );
}
