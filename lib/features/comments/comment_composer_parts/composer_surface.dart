part of '../../../widgets/comment_composer_sheet.dart';

/// Places the composer above the platform IME.
///
/// This used to use [Transform.translate] to move a bottom-aligned editor.
/// That paints the editor in the right place, but on some Android IME/window
/// combinations its transformed semantic bounds and pointer hit-test bounds
/// diverge. A toolbar button can therefore be visible above the keyboard yet
/// never receive the tap. Padding participates in normal layout and keeps the
/// visual and interactive rectangles identical during inset changes.
class _KeyboardInsetLift extends StatelessWidget {
  const _KeyboardInsetLift({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = enabled ? MediaQuery.viewInsetsOf(context).bottom : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: child,
    );
  }
}

class _ComposerToolbar extends StatelessWidget {
  const _ComposerToolbar({
    required this.canSubmit,
    required this.sending,
    required this.submitLabel,
    required this.onEmoticons,
    required this.onMention,
    required this.onImage,
    required this.onSubmit,
  });

  final bool canSubmit;
  final bool sending;
  final String submitLabel;
  final VoidCallback onEmoticons;
  final VoidCallback onMention;
  final VoidCallback? onImage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      children: [
        _ComposerToolbarIcon(
          key: const Key('comment-composer-image'),
          semanticLabel: context.zhL10n.commentImage,
          onPointerDown: onImage,
          icon: const Icon(Icons.image_outlined, size: 26),
        ),
        _ComposerToolbarIcon(
          key: const Key('comment-composer-emoticons'),
          semanticLabel: context.zhL10n.commentEmoji,
          onPointerDown: onEmoticons,
          icon: const _ComposerEmojiCircle(),
        ),
        _ComposerToolbarIcon(
          key: const Key('comment-composer-mention'),
          semanticLabel: context.zhL10n.commentMention,
          onPointerDown: onMention,
          icon: const Icon(Icons.alternate_email_rounded, size: 24),
        ),
        const Spacer(),
        SizedBox(
          height: 30,
          child: FilledButton(
            key: const Key('comment-composer-submit'),
            onPressed: canSubmit ? onSubmit : null,
            style: FilledButton.styleFrom(
              foregroundColor: ZhPalette.background,
              backgroundColor: ZhPalette.accent,
              disabledForegroundColor: ZhPalette.disabledInk,
              disabledBackgroundColor: ZhPalette.accentSurface,
              minimumSize: const Size(96, 42),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const StadiumBorder(),
            ),
            child: Text(
              sending ? context.zhL10n.commonPublishing : submitLabel,
              style: const TextStyle(fontSize: 17, height: 1),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    ),
  );
}

class _ComposerEmojiCircle extends StatelessWidget {
  const _ComposerEmojiCircle();

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: ZhPalette.softSurface,
      shape: BoxShape.circle,
      border: Border.all(color: ZhPalette.softBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: ZhPalette.isDark ? .18 : .06),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Icon(
      Icons.sentiment_satisfied_alt_outlined,
      size: 19,
      color: ZhPalette.mutedInk,
    ),
  );
}

/// Handles editor toolbar actions on pointer-down. Android may start closing
/// the IME as soon as a pointer leaves the text field; waiting for pointer-up
/// then moves the bottom sheet under the gesture and can cancel the tap before
/// the emoji panel receives it.
class _ComposerToolbarIcon extends StatelessWidget {
  const _ComposerToolbarIcon({
    super.key,
    required this.semanticLabel,
    required this.onPointerDown,
    required this.icon,
  });

  final String semanticLabel;
  final VoidCallback? onPointerDown;
  final Widget icon;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    enabled: onPointerDown != null,
    onTap: onPointerDown,
    child: Tooltip(
      message: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: onPointerDown != null ? (_) => onPointerDown!() : null,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: IconTheme(
              data: IconTheme.of(context).copyWith(
                color: onPointerDown != null
                    ? null
                    : Theme.of(context).disabledColor,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    ),
  );
}

class _SelectedSticker extends StatelessWidget {
  const _SelectedSticker({required this.value, required this.onRemove});

  final CommentEmoticon value;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: ZhSpace.xs),
    child: Row(
      children: [
        _EmoticonImage(value: value, size: 34),
        const SizedBox(width: ZhSpace.xs),
        Expanded(
          child: Text(
            value.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          tooltip: context.zhL10n.commentRemoveSticker,
          onPressed: onRemove,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close_rounded, size: 18),
        ),
      ],
    ),
  );
}

class _SelectedImage extends StatelessWidget {
  const _SelectedImage({
    required this.value,
    required this.uploading,
    required this.onRemove,
  });

  final CommentImageAttachment value;
  final bool uploading;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: ZhSpace.xs),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            value.bytes,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            semanticLabel: context.zhL10n.commentSelectedImage,
          ),
        ),
        const SizedBox(width: ZhSpace.xs),
        Expanded(
          child: Text(
            uploading
                ? context.zhL10n.commentUploadingImage
                : context.zhL10n.commentImageAdded,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (uploading)
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            key: const Key('comment-composer-image-remove'),
            tooltip: context.zhL10n.commentRemoveImage,
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
      ],
    ),
  );
}

class _EmoticonPanel extends StatelessWidget {
  const _EmoticonPanel({
    required this.loading,
    required this.groups,
    required this.selectedGroup,
    required this.onGroup,
    required this.onEmoticon,
    required this.onBackspace,
  });

  final bool loading;
  final List<CommentEmoticonGroup> groups;
  final int selectedGroup;
  final ValueChanged<int> onGroup;
  final ValueChanged<CommentEmoticon> onEmoticon;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (groups.isEmpty) return const SizedBox.shrink();
    final index = selectedGroup.clamp(0, groups.length - 1);
    final group = groups[index];
    return Column(
      children: [
        const Divider(height: 1),
        Expanded(
          child: GridView.builder(
            key: ValueKey('comment-emoticon-grid-${group.id}'),
            padding: const EdgeInsets.symmetric(vertical: ZhSpace.sm),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: ZhSpace.xs,
              crossAxisSpacing: ZhSpace.xs,
            ),
            itemCount: group.emoticons.length + 1,
            itemBuilder: (context, itemIndex) {
              if (itemIndex == group.emoticons.length) {
                return IconButton(
                  key: const Key('comment-emoticon-backspace'),
                  tooltip: context.zhL10n.commonDelete,
                  onPressed: onBackspace,
                  icon: const Icon(Icons.backspace_outlined, size: 23),
                );
              }
              final value = group.emoticons[itemIndex];
              return Semantics(
                button: true,
                label: value.title,
                child: InkResponse(
                  key: ValueKey('comment-emoticon-${value.id}'),
                  onTap: () => onEmoticon(value),
                  radius: 27,
                  child: Center(child: _EmoticonImage(value: value, size: 35)),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 44,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(groups.length, (groupIndex) {
                final value = groups[groupIndex];
                final selected = groupIndex == index;
                return Padding(
                  padding: EdgeInsets.only(
                    right: groupIndex == groups.length - 1 ? 0 : ZhSpace.xs,
                  ),
                  child: IconButton(
                    key: ValueKey('comment-emoticon-group-${value.id}'),
                    tooltip: value.title.isEmpty
                        ? context.zhL10n.commentEmoji
                        : value.title,
                    onPressed: () => onGroup(groupIndex),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      maximumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                      backgroundColor: selected ? ZhPalette.pressed : null,
                    ),
                    icon: value.assetIconPath.isNotEmpty
                        ? Image.asset(
                            selected && value.assetSelectedIconPath.isNotEmpty
                                ? value.assetSelectedIconPath
                                : value.assetIconPath,
                            width: 24,
                            height: 24,
                          )
                        : value.iconUrl.isEmpty
                        ? const Icon(Icons.sentiment_satisfied_alt_outlined)
                        : ZhihuImage.network(
                            value.iconUrl,
                            headers: zhihuImageRequestHeaders,
                            width: 24,
                            height: 24,
                            cacheWidth: 72,
                            cacheHeight: 72,
                            filterQuality: FilterQuality.low,
                            frameBuilder: (_, child, frame, _) => frame == null
                                ? const Icon(
                                    Icons.sentiment_satisfied_alt_outlined,
                                  )
                                : child,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.sentiment_satisfied_alt_outlined,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmoticonImage extends StatelessWidget {
  const _EmoticonImage({required this.value, required this.size});

  final CommentEmoticon value;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (value.assetImagePath.isNotEmpty) {
      return Image.asset(
        value.assetImagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    if (value.imageUrl.isEmpty) {
      return Text(value.title, style: TextStyle(fontSize: size * .72));
    }
    return ZhihuImage.network(
      value.imageUrl,
      headers: zhihuImageRequestHeaders,
      width: size,
      height: size,
      fit: BoxFit.contain,
      cacheWidth: (size * 3).round(),
      cacheHeight: (size * 3).round(),
      frameBuilder: (_, child, frame, _) => frame == null
          ? Text(value.title, style: TextStyle(fontSize: size * .72))
          : child,
      errorBuilder: (_, _, _) => Text(
        value.title,
        style: TextStyle(fontSize: size * .45),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }
}
