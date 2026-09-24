part of '../salt_page.dart';

class _SaltCommentsSheet extends StatefulWidget {
  const _SaltCommentsSheet({
    required this.api,
    required this.objectType,
    required this.objectId,
    required this.title,
    required this.count,
    required this.showSort,
    required this.bulletComments,
  });

  final ZhihuApiClient api;
  final String objectType;
  final String objectId;
  final String title;
  final int? count;
  final bool showSort;
  final bool bulletComments;

  @override
  State<_SaltCommentsSheet> createState() => _SaltCommentsSheetState();
}

class _SaltCommentsSheetState extends State<_SaltCommentsSheet> {
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    child: Column(
      children: [
        _SaltSheetHeader(
          title: widget.title,
          onClose: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: CommentThreadView(
            api: widget.api,
            title: widget.title,
            contentType: widget.objectType,
            contentId: widget.objectId,
            embedded: true,
            showSort: widget.showSort,
            fallbackCount: widget.count,
            loadContextHeader: widget.showSort
                ? () => widget.api.getUri(
                    widget.api.saltCommentListHeadersUri(
                      objectType: widget.objectType,
                      objectId: widget.objectId,
                    ),
                  )
                : null,
            loadInitial: (orderBy, _) => widget.api.getUri(
              widget.api.saltCommentsInitialUri(
                objectType: widget.objectType,
                objectId: widget.objectId,
                orderBy: orderBy == 'time' ? 'ts' : orderBy,
              ),
            ),
            submitComment: (value, target) => widget.api.createSaltComment(
              objectType: widget.objectType,
              objectId: widget.objectId,
              content: value.text,
              replyCommentId: target.replyCommentId,
              sticker: value.sticker,
            ),
            emptyMessage: widget.bulletComments
                ? context.zhL10n.saltBulletCommentsEmpty
                : context.zhL10n.saltCommentsEmpty,
          ),
        ),
      ],
    ),
  );
}

class _SaltSheetHeader extends StatelessWidget {
  const _SaltSheetHeader({
    required this.title,
    required this.onClose,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ZhPalette.ink,
                  fontSize: 17,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle case final subtitle?)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ZhPalette.subtleInk,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          right: 8,
          child: IconButton(
            key: const Key('salt-comments-close-action'),
            onPressed: onClose,
            tooltip: context.zhL10n.commonClose,
            icon: Icon(
              Icons.close_rounded,
              size: 24,
              color: ZhPalette.subtleInk,
            ),
          ),
        ),
      ],
    ),
  );
}
