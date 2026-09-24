import 'package:flutter/material.dart';

import '../core/follow_item_group.dart';
import '../core/json_tools.dart';
import '../ui/zh_theme.dart';
import 'api_views.dart';

class FollowItemGroupCard extends StatelessWidget {
  const FollowItemGroupCard({
    super.key,
    required this.value,
    required this.expanded,
    required this.onExpand,
    required this.onChildTap,
    required this.onChildAuthorTap,
    this.compact = false,
    this.showImages = true,
    this.showMetrics = true,
  });

  final Map<String, dynamic> value;
  final bool expanded;
  final VoidCallback onExpand;
  final ValueChanged<Map<String, dynamic>> onChildTap;
  final ValueChanged<Map<String, dynamic>> onChildAuthorTap;
  final bool compact;
  final bool showImages;
  final bool showMetrics;

  @override
  Widget build(BuildContext context) {
    final object = unwrapObject(value);
    final children = followItemGroupChildren(value);
    final initialSize = followItemGroupInitialSize(
      value,
      childCount: children.length,
    );
    final visibleChildren = expanded ? children : children.take(initialSize);
    final actor = _stringMap(object['actor']);
    final actorName = plainText(actor?['name']);
    final actionText = plainText(object['action_text']);
    final groupText = plainText(object['group_text']);
    final actionDate = _actionDate(object['action_time']);

    return Material(
      color: ZhPalette.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(11, compact ? 9 : 12, 11, 3),
            child: Row(
              children: [
                _ActorAvatar(actor: actor, name: actorName),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (actorName.isNotEmpty)
                          TextSpan(
                            text: actorName,
                            style: TextStyle(
                              color: ZhPalette.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (actorName.isNotEmpty && actionText.isNotEmpty)
                          const TextSpan(text: '  '),
                        if (actionText.isNotEmpty)
                          TextSpan(
                            text: actionText,
                            style: TextStyle(
                              color: ZhPalette.mutedInk,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 12.5),
                  ),
                ),
                if (actionDate.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    actionDate,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ZhPalette.subtleInk,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          for (final child in visibleChildren)
            ObjectCard(
              value: child,
              feedMode: true,
              compact: true,
              showImages: showImages,
              showMetrics: showMetrics,
              onTap: () => onChildTap(child),
              onAuthorTap: authorIdOf(child).isEmpty
                  ? null
                  : () => onChildAuthorTap(child),
            ),
          if (!expanded && children.length > initialSize)
            InkWell(
              key: ValueKey('follow-group-expand-${plainText(object['id'])}'),
              onTap: onExpand,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(43, 11, 11, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: ZhPalette.border, width: 0.7),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        groupText.isEmpty
                            ? 'TA 还赞同了 ${children.length - initialSize} 个回答'
                            : groupText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.mutedInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: ZhPalette.mutedInk,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActorAvatar extends StatelessWidget {
  const _ActorAvatar({required this.actor, required this.name});

  final Map<String, dynamic>? actor;
  final String name;

  @override
  Widget build(BuildContext context) {
    final url = plainText(actor?['avatar_url']);
    final fallback = name.isEmpty ? '知' : name.characters.first;
    final placeholder = _AvatarPlaceholder(text: fallback);
    if (Uri.tryParse(url)?.scheme != 'https') return placeholder;
    return ClipOval(
      child: ZhihuImage.network(
        url,
        headers: zhihuImageRequestHeaders,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        cacheWidth: 84,
        cacheHeight: 84,
        frameBuilder: (_, child, frame, _) =>
            frame == null ? placeholder : child,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: ZhPalette.canvas, shape: BoxShape.circle),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Map<String, dynamic>? _stringMap(Object? value) {
  if (value is! Map) return null;
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String _actionDate(Object? value) {
  final timestamp = value is num
      ? value.toInt()
      : int.tryParse(plainText(value));
  if (timestamp == null || timestamp <= 0) return '';
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(date.month)}-${twoDigits(date.day)}';
}
