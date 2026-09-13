part of '../content_pages.dart';

const answerSwitchTriggerDistance = 80.0;
const answerSwitchMaxDistance = 200.0;

double dampedAnswerOverscroll(double rawDistance) {
  final normalized = rawDistance / (answerSwitchMaxDistance * 1.2);
  // Dart's math library does not expose tanh on every Flutter channel. This
  // rational curve has the same useful properties for the gesture: it starts
  // linearly, then approaches the maximum distance without a hard edge.
  return answerSwitchMaxDistance * (normalized.abs() / (1 + normalized.abs()));
}

class _AnswerSwitchPreview extends StatelessWidget {
  const _AnswerSwitchPreview({
    super.key,
    required this.value,
    required this.progress,
    required this.triggered,
    required this.onTap,
  });

  final Map<String, dynamic> value;
  final double progress;
  final bool triggered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final author = authorNameOf(value);
    final question = titleOf(value);
    final excerpt = _answerListExcerpt(value);
    final avatar = authorAvatarOf(value);
    final label = triggered ? '松开切换' : '继续上滑查看下一个回答';
    return Semantics(
      container: true,
      button: true,
      label: triggered
          ? '松开切换到${author.isEmpty ? '下一个' : author}的回答'
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
              key: const ValueKey('answer-switch-next-preview'),
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
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
