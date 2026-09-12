part of '../../../widgets/comment_composer_sheet.dart';

/// Moves only the already-laid-out composer surface with the platform IME.
///
/// Keeping the view-inset dependency in this tiny widget means Android's IME
/// animation no longer rebuilds or lays out the editor and emoji catalog for
/// each intermediate inset value.
class _KeyboardInsetLift extends StatelessWidget {
  const _KeyboardInsetLift({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = enabled ? MediaQuery.viewInsetsOf(context).bottom : 0.0;
    return Transform.translate(offset: Offset(0, -bottom), child: child);
  }
}

class _ComposerToolbar extends StatelessWidget {
  const _ComposerToolbar({
    required this.showEmoticons,
    required this.canSubmit,
    required this.sending,
    required this.onEmoticons,
    required this.onMention,
    required this.onSubmit,
  });

  final bool showEmoticons;
  final bool canSubmit;
  final bool sending;
  final VoidCallback onEmoticons;
  final VoidCallback onMention;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: Row(
      children: [
        _ComposerToolbarIcon(
          key: const Key('comment-composer-emoticons'),
          semanticLabel: '表情',
          onPointerDown: onEmoticons,
          icon: Icon(
            showEmoticons
                ? Icons.keyboard_alt_outlined
                : Icons.sentiment_satisfied_alt_outlined,
            size: 26,
          ),
        ),
        _ComposerToolbarIcon(
          key: const Key('comment-composer-mention'),
          semanticLabel: '提及用户',
          onPointerDown: onMention,
          icon: const Icon(Icons.alternate_email_rounded, size: 26),
        ),
        const IconButton(
          tooltip: '图片评论',
          onPressed: null,
          icon: Icon(Icons.image_outlined, size: 26),
        ),
        const IconButton(
          tooltip: '礼物',
          onPressed: null,
          icon: Icon(Icons.card_giftcard_outlined, size: 25),
        ),
        const Spacer(),
        SizedBox(
          height: 30,
          child: FilledButton(
            key: const Key('comment-composer-submit'),
            onPressed: canSubmit ? onSubmit : null,
            style: FilledButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF1772F6),
              disabledForegroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFC9DCF8),
              minimumSize: const Size(64, 30),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const StadiumBorder(),
            ),
            child: Text(
              sending ? '发布中' : '发布',
              style: const TextStyle(fontSize: 15, height: 1),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
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
  final VoidCallback onPointerDown;
  final Widget icon;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    onTap: onPointerDown,
    child: Tooltip(
      message: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onPointerDown(),
        child: SizedBox.square(dimension: 48, child: Center(child: icon)),
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
          tooltip: '移除贴纸',
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
                  tooltip: '删除',
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
                    tooltip: value.title.isEmpty ? '表情' : value.title,
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
      errorBuilder: (_, _, _) => Text(
        value.title,
        style: TextStyle(fontSize: size * .45),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }
}
