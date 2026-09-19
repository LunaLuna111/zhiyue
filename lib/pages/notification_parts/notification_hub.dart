part of '../notifications_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.api});

  final ZhihuApiClient api;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _controller = ScrollController();
  final _rows = <Map<String, dynamic>>[];
  Map<String, dynamic>? _root;
  Object? _error;
  String? _next;
  bool _loading = false;
  bool _markingRead = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadMore);
    if (_hasAccountContext(widget.api)) _load(reset: true);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_maybeLoadMore)
      ..dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_loading || _next == null || !_controller.hasClients) return;
    if (_controller.position.extentAfter < 420) _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _rows.clear();
        _root = null;
        _next = null;
      }
    });
    try {
      final response = reset
          ? await widget.api.getUri(widget.api.notificationsMessageInitialUri())
          : await widget.api.getUri(widget.api.validatePagingUri(_next!));
      if (!mounted) return;
      if (!response.isSuccess) {
        setState(() => _error = response);
      } else {
        setState(() {
          if (reset) _root = response.jsonMap;
          _rows.addAll(notificationRows(response.json));
          _next = pagingNext(response.json);
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    if (_markingRead) return;
    setState(() => _markingRead = true);
    try {
      final response = await widget.api.markAllNotificationsRead();
      if (!mounted) return;
      if (!response.isSuccess) throw response;
      await _load(reset: true);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已将消息标为已读')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ApiFailure.from(error).detail)));
      }
    } finally {
      if (mounted) setState(() => _markingRead = false);
    }
  }

  void _openCategory(String name, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationTimelinePage(
          api: widget.api,
          entryName: name,
          title: title,
        ),
      ),
    );
  }

  void _openRow(Map<String, dynamic> row) {
    final senderId = notificationMessageSenderId(row);
    if (senderId.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MessageConversationPage(
            api: widget.api,
            senderId: senderId,
            title: notificationTitle(row),
            avatarUrl: notificationAvatarUrl(row),
          ),
        ),
      );
      return;
    }
    final entry = notificationEntryNameOf(row);
    if (entry.isNotEmpty) {
      _openCategory(entry, notificationTitle(row));
      return;
    }
    _openNotificationTarget(context, widget.api, row);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZhTopBar(
        centerTitle: true,
        title: const Text('消息'),
        actions: [
          ZhLiquidGlassIconButton(
            key: const ValueKey('notification-settings'),
            semanticLabel: '通知设置',
            onPressed: _hasAccountContext(widget.api)
                ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NotificationSettingsPage(api: widget.api),
                    ),
                  )
                : null,
            icon: const Icon(Icons.notifications_active_outlined),
            size: 44,
            iconSize: 22,
          ),
          ZhLiquidGlassIconButton(
            key: const ValueKey('notification-read-all'),
            semanticLabel: '全部已读',
            onPressed: _markingRead || !_hasAccountContext(widget.api)
                ? null
                : _markAllRead,
            icon: _markingRead
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.mark_email_read_outlined),
            size: 44,
            iconSize: 22,
          ),
        ],
      ),
      body: ZhResponsiveFrame(
        maxWidth: 1120,
        desktopGutter: 24,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasAccountContext(widget.api)) {
      return _LoginRequired(onBack: () => Navigator.of(context).pop());
    }
    if (_loading && _root == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _root == null) {
      return ApiErrorView(
        error: _error!,
        onRetry: () => _load(reset: true),
        titleOverride: '消息加载失败',
      );
    }
    final header = notificationHeaderEntries(_root);
    final invite = notificationInviteEntry(_root);
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.builder(
        key: const ValueKey('notifications-list'),
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 2 + _rows.length + (_next != null || _error != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _NotificationCategoryHeader(
              entries: header,
              onOpen: _openCategory,
            );
          }
          if (index == 1) {
            return invite == null
                ? const SizedBox(height: 8)
                : _InviteEntry(
                    value: invite,
                    onTap: () => _openCategory('invite', '邀请回答'),
                  );
          }
          final rowIndex = index - 2;
          if (rowIndex < _rows.length) {
            return NotificationListRow(
              value: _rows[rowIndex],
              onTap: () => _openRow(_rows[rowIndex]),
            );
          }
          if (_error != null) {
            return ApiErrorView(
              error: _error!,
              compact: true,
              onRetry: () => _load(reset: false),
            );
          }
          return ZhPagingIndicator(loading: _loading, height: 60);
        },
      ),
    );
  }
}

class _NotificationCategoryHeader extends StatelessWidget {
  const _NotificationCategoryHeader({
    required this.entries,
    required this.onOpen,
  });

  final List<Map<String, dynamic>> entries;
  final void Function(String name, String title) onOpen;

  static const _icons = {
    'comment': Icons.chat_bubble_outline_rounded,
    'like': Icons.favorite_border_rounded,
    'favorite': Icons.star_border_rounded,
    'follow': Icons.person_add_alt_1_outlined,
  };

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: ZhPalette.border)),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            Expanded(
              child: _CategoryButton(
                value: entry,
                icon:
                    _icons[notificationEntryNameOf(entry)] ??
                    Icons.notifications_none_rounded,
                onTap: () => onOpen(
                  notificationEntryNameOf(entry),
                  notificationTitle(entry),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final Map<String, dynamic> value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = _intValue(value['unread_count']);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 82,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              backgroundColor: const Color(0xFFE04F50),
              child: Icon(icon, size: 31),
            ),
            const SizedBox(height: 11),
            Text(
              notificationTitle(value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteEntry extends StatelessWidget {
  const _InviteEntry({required this.value, required this.onTap});

  final Map<String, dynamic> value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = _intValue(value['unread_count']);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2F82F6),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.assignment_ind_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificationTitle(value),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    unread > 0 ? '$unread 条待处理邀请' : '查看邀请你回答的问题',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (unread > 0) _UnreadBadge(count: unread),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: ZhPalette.subtleInk),
          ],
        ),
      ),
    );
  }
}
