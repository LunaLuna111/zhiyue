part of '../content_pages.dart';

const answerSwitchTriggerDistance = 80.0;
const answerSwitchMaxDistance = 200.0;

double dampedAnswerOverscroll(double rawDistance) {
  final sign = rawDistance < 0 ? -1.0 : 1.0;
  final normalized = rawDistance / (answerSwitchMaxDistance * 1.2);
  // Dart's math library does not expose tanh on every Flutter channel. This
  // rational curve has the same useful properties for the gesture: it starts
  // linearly, then approaches the maximum distance without a hard edge.
  return sign *
      answerSwitchMaxDistance *
      (normalized.abs() / (1 + normalized.abs()));
}

class _AnswerSwitchPreview extends StatelessWidget {
  const _AnswerSwitchPreview({
    super.key,
    required this.value,
    required this.progress,
    required this.triggered,
    required this.onTap,
    this.previous = false,
  });

  final Map<String, dynamic> value;
  final double progress;
  final bool triggered;
  final VoidCallback onTap;
  final bool previous;

  @override
  Widget build(BuildContext context) {
    final author = authorNameOf(value);
    final question = titleOf(value);
    final excerpt = _answerListExcerpt(value);
    final avatar = authorAvatarOf(value);
    final label = triggered
        ? '松开切换'
        : previous
        ? '继续下拉查看上一个回答'
        : '继续上滑查看下一个回答';
    return Semantics(
      container: true,
      button: true,
      label: triggered
          ? '松开切换到${author.isEmpty ? (previous ? '上一个' : '下一个') : author}的回答'
          : previous
          ? '继续下拉查看上一个回答'
          : '继续上滑查看下一个回答',
      child: Opacity(
        opacity: progress.clamp(0, 1).toDouble(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Material(
            color: triggered
                ? const Color(0xFFEAF3FF)
                : const Color(0xFFF4F5F6),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              key: ValueKey(
                'answer-switch-${previous ? 'previous' : 'next'}-preview',
              ),
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    Icon(
                      previous
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 18,
                      color: triggered
                          ? const Color(0xFF175199)
                          : ZhPalette.mutedInk,
                    ),
                    const SizedBox(width: 8),
                    _AuthorAvatar(
                      imageUrl: avatar,
                      fallback: author.isEmpty ? '知' : author.characters.first,
                      size: 30,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: triggered
                                      ? const Color(0xFF175199)
                                      : ZhPalette.mutedInk,
                                  fontWeight: triggered
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                          ),
                          if (author.isNotEmpty || question.isNotEmpty)
                            const SizedBox(height: 3),
                          if (author.isNotEmpty || question.isNotEmpty)
                            Text(
                              [
                                if (author.isNotEmpty) author,
                                if (question.isNotEmpty) question,
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          if (excerpt.isNotEmpty)
                            Text(
                              excerpt,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: ZhPalette.mutedInk),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: triggered
                          ? const Color(0xFF175199)
                          : ZhPalette.mutedInk,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerJumpButton extends StatefulWidget {
  const _AnswerJumpButton({
    required this.atBottom,
    required this.onJumpToTop,
    required this.onJumpToBottom,
  });

  final bool atBottom;
  final VoidCallback onJumpToTop;
  final VoidCallback onJumpToBottom;

  @override
  State<_AnswerJumpButton> createState() => _AnswerJumpButtonState();
}

class _AnswerJumpButtonState extends State<_AnswerJumpButton> {
  bool _showTopButton = false;

  void _handleMainTap() {
    setState(() => _showTopButton = false);
    if (widget.atBottom) {
      widget.onJumpToTop();
    } else {
      widget.onJumpToBottom();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    setState(() => _showTopButton = true);
  }

  void _handleTopTap() {
    setState(() => _showTopButton = false);
    widget.onJumpToTop();
  }

  Widget _circleButton({
    required Key key,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: ZhPalette.ink,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        key: key,
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: 44,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 48,
    height: _showTopButton ? 100 : 48,
    child: Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        if (_showTopButton)
          Positioned(
            right: 0,
            bottom: 54,
            child: _circleButton(
              key: const ValueKey('answer-jump-top'),
              label: '回到回答顶部',
              icon: Icons.arrow_upward_rounded,
              onTap: _handleTopTap,
            ),
          ),
        _circleButton(
          key: const ValueKey('answer-jump-button'),
          label: widget.atBottom ? '回到回答顶部' : '跳到回答底部',
          icon: widget.atBottom
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded,
          onTap: _handleMainTap,
          onLongPress: _handleLongPress,
        ),
      ],
    ),
  );
}
