part of '../notifications_page.dart';

class NotificationListRow extends StatelessWidget {
  const NotificationListRow({
    super.key,
    required this.value,
    required this.onTap,
  });

  final Map<String, dynamic> value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = notificationAvatarUrl(value);
    final unread = _intValue(value['unread_count']);
    final subtitle = plainText(_stringMap(value['content'])['sub_title']);
    final text = notificationText(value);
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 86),
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: ZhPalette.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationAvatar(url: avatar, size: 50),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notificationTitle(value),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        _timestampLabel(value['created']),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.subtleInk,
                        ),
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (text.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: ZhPalette.subtleInk,
                                  height: 1.35,
                                ),
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: 8),
                          _UnreadBadge(count: unread),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationAvatar extends StatelessWidget {
  const _NotificationAvatar({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Container(
      width: size,
      height: size,
      color: ZhPalette.canvas,
      child: url.isEmpty
          ? const Icon(
              Icons.notifications_none_rounded,
              color: ZhPalette.mutedInk,
            )
          : ZhihuImage.network(
              url,
              headers: zhihuImageRequestHeaders,
              fit: BoxFit.cover,
              // Notification rows only display a small avatar. Avoid
              // decoding the original CDN bitmap while a message list is
              // being created or rapidly scrolled.
              cacheWidth: (size * 3).round(),
              cacheHeight: (size * 3).round(),
              filterQuality: FilterQuality.low,
              frameBuilder: (_, child, frame, _) => frame == null
                  ? const Icon(
                      Icons.notifications_none_rounded,
                      color: ZhPalette.mutedInk,
                    )
                  : child,
              errorBuilder: (_, _, _) => const Icon(
                Icons.notifications_none_rounded,
                color: ZhPalette.mutedInk,
              ),
            ),
    ),
  );
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 21, minHeight: 21),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFE04F50),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Text(
      count > 99 ? '99+' : '$count',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        height: 1,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class NotificationTimelinePage extends StatelessWidget {
  const NotificationTimelinePage({
    super.key,
    required this.api,
    required this.entryName,
    required this.title,
  });

  final ZhihuApiClient api;
  final String entryName;
  final String title;

  @override
  Widget build(BuildContext context) => PagedListPage(
    title: title.isEmpty ? '通知' : title,
    api: api,
    loadInitial: () => api.getUri(api.notificationEntryInitialUri(entryName)),
    rowsExtractor: notificationRows,
    emptyMessage: '暂时没有这类通知',
    actions: [
      ZhLiquidGlassIconButton(
        semanticLabel: '全部已读',
        onPressed: () async {
          try {
            final response = await api.markNotificationEntryRead(entryName);
            if (!context.mounted) return;
            if (!response.isSuccess) throw response;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('该分类已全部标为已读')));
          } catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ApiFailure.from(error).detail)),
              );
            }
          }
        },
        icon: const Icon(Icons.mark_email_read_outlined),
        size: 44,
        iconSize: 22,
      ),
    ],
    rowBuilder: (context, value, onTap) =>
        NotificationListRow(value: value, onTap: onTap ?? () {}),
    onObjectTap: (context, value) =>
        _openNotificationTarget(context, api, value),
  );
}

void _openNotificationTarget(
  BuildContext context,
  ZhihuApiClient api,
  Map<String, dynamic> row,
) {
  final target = notificationTargetObject(row);
  if (target != null) {
    openDetectedObject(context, api, target);
    return;
  }
  final text = notificationText(row);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 2, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notificationTitle(row),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 14),
              Flexible(child: SingleChildScrollView(child: Text(text))),
            ],
          ],
        ),
      ),
    ),
  );
}
