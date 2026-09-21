part of '../notifications_page.dart';

class MessageConversationPage extends StatefulWidget {
  const MessageConversationPage({
    super.key,
    required this.api,
    required this.senderId,
    required this.title,
    required this.avatarUrl,
  });

  final ZhihuApiClient api;
  final String senderId;
  final String title;
  final String avatarUrl;

  @override
  State<MessageConversationPage> createState() =>
      _MessageConversationPageState();
}

class _MessageConversationPageState extends State<MessageConversationPage> {
  final _controller = ScrollController();
  final _composer = TextEditingController();
  final _messages = <Map<String, dynamic>>[];
  Object? _error;
  String? _next;
  bool _loading = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadEarlier);
    _load(reset: true);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_maybeLoadEarlier)
      ..dispose();
    _composer.dispose();
    super.dispose();
  }

  void _maybeLoadEarlier() {
    if (_loading || _next == null || !_controller.hasClients) return;
    if (_controller.position.pixels <= 420) _load(reset: false);
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _send() async {
    final content = _composer.text.trim();
    if (content.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final response = await widget.api.sendTextMessage(
        widget.senderId,
        content,
      );
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      final returned = response.jsonMap == null
          ? <String, dynamic>{}
          : unwrapObject(response.jsonMap!);
      final message = returned.isEmpty
          ? <String, dynamic>{
              'id': 'local-${DateTime.now().microsecondsSinceEpoch}',
              'content': content,
              'created_time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
              'sender': {'id': widget.api.session.accountUid},
            }
          : returned;
      setState(() {
        _messages.add(message);
        _composer.clear();
      });
      _scrollToLatest();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiFailure.from(error).userMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    final previousExtent = _controller.hasClients
        ? _controller.position.maxScrollExtent
        : 0.0;
    final previousOffset = _controller.hasClients
        ? _controller.position.pixels
        : 0.0;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _messages.clear();
        _next = null;
      }
    });
    try {
      final response = reset
          ? await widget.api.getUri(
              widget.api.messagesInitialUri(widget.senderId),
            )
          : await widget.api.getUri(widget.api.validatePagingUri(_next!));
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      final incoming = notificationRows(response.json).reversed.toList();
      final known = _messages.map((row) => plainText(row['id'])).toSet();
      incoming.removeWhere((row) => known.contains(plainText(row['id'])));
      setState(() {
        if (reset) {
          _messages.addAll(incoming);
        } else {
          _messages.insertAll(0, incoming);
        }
        _next = pagingNext(response.json);
      });
      if (reset) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.hasClients) {
            _controller.jumpTo(_controller.position.maxScrollExtent);
          }
        });
      } else if (incoming.isNotEmpty) {
        // Older messages are prepended. Keep the currently visible bubble in
        // place so the near-top prefetch does not leave the controller at zero
        // and immediately consume every remaining page in a tight loop.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_controller.hasClients) return;
          final delta = _controller.position.maxScrollExtent - previousExtent;
          final target = (previousOffset + delta).clamp(
            _controller.position.minScrollExtent,
            _controller.position.maxScrollExtent,
          );
          _controller.jumpTo(target);
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: ZhTopBar(
      title: Row(
        children: [
          _NotificationAvatar(url: widget.avatarUrl, size: 36),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.title.isEmpty ? '私信' : widget.title)),
        ],
      ),
    ),
    body: ZhResponsiveFrame(
      maxWidth: 880,
      desktopGutter: 24,
      child: Column(
        children: [
          Expanded(
            child: _loading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _messages.isEmpty
                ? ApiErrorView(
                    error: _error!,
                    onRetry: () => _load(reset: true),
                    titleOverride: '私信加载失败',
                  )
                : ListView.builder(
                    key: const ValueKey('message-conversation'),
                    controller: _controller,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                    // Keep a short bubble-sized buffer. Older messages can
                    // be numerous and each incoming avatar/text row is
                    // otherwise built before it is close to the viewport.
                    scrollCacheExtent: const ScrollCacheExtent.pixels(320),
                    itemCount: _messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        if (_next == null) return const SizedBox(height: 8);
                        return ZhPagingIndicator(loading: _loading, height: 52);
                      }
                      final message = _messages[index - 1];
                      final sender = _stringMap(message['sender']);
                      final mine =
                          plainText(sender['id']) ==
                          widget.api.session.accountUid;
                      return _MessageBubble(value: message, mine: mine);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: ZhPalette.background,
                border: Border(top: BorderSide(color: ZhPalette.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('message-composer'),
                        controller: _composer,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: '发私信',
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      key: const ValueKey('send-message'),
                      tooltip: '发送',
                      onPressed: _sending || _composer.text.trim().isEmpty
                          ? null
                          : _send,
                      icon: _sending
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.value, required this.mine});

  final Map<String, dynamic> value;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final sender = _stringMap(value['sender']);
    final avatar = plainText(sender['avatar_url']);
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 580),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? ZhPalette.ink : ZhPalette.canvas,
        borderRadius: BorderRadius.circular(16).copyWith(
          topRight: mine ? const Radius.circular(4) : null,
          topLeft: mine ? null : const Radius.circular(4),
        ),
      ),
      child: Text(
        plainText(value['content']),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: mine ? Colors.white : ZhPalette.ink,
          height: 1.55,
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: mine
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: mine
                ? [Flexible(child: bubble)]
                : [
                    _NotificationAvatar(url: avatar, size: 34),
                    const SizedBox(width: 8),
                    Flexible(child: bubble),
                  ],
          ),
          Padding(
            padding: EdgeInsets.only(left: mine ? 0 : 42, top: 3),
            child: Text(
              _timestampLabel(value['created_time']),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: ZhPalette.subtleInk),
            ),
          ),
        ],
      ),
    );
  }
}
