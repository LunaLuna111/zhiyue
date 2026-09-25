import 'package:flutter/material.dart';

import '../zh_theme.dart';

/// A small reusable skeleton surface with a low-contrast moving highlight.
///
/// The component intentionally contains no loading copy. Its geometry is
/// supplied by the caller so a page can reserve the same space before real
/// content arrives instead of showing a centred spinner and then reflowing.
class ZhSkeleton extends StatefulWidget {
  const ZhSkeleton({super.key, this.width, this.height = 16, this.radius = 10});

  final double? width;
  final double height;
  final double radius;

  @override
  State<ZhSkeleton> createState() => _ZhSkeletonState();
}

class _ZhSkeletonState extends State<ZhSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1450),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _baseColor =>
      ZhPalette.isDark ? const Color(0xFF252A31) : const Color(0xFFE9ECEF);

  Color get _highlightColor =>
      ZhPalette.isDark ? const Color(0xFF39424D) : const Color(0xFFF9FAFB);

  Widget _base() => DecoratedBox(
    decoration: BoxDecoration(
      color: _baseColor,
      borderRadius: BorderRadius.circular(widget.radius),
    ),
    child: SizedBox(width: widget.width, height: widget.height),
  );

  @override
  Widget build(BuildContext context) {
    final base = _base();
    if (MediaQuery.disableAnimationsOf(context)) return base;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: const Alignment(-1.4, 0),
          end: const Alignment(1.4, 0),
          colors: [_baseColor, _highlightColor, _baseColor],
          stops: const [0.2, 0.5, 0.8],
          transform: _ZhSkeletonGradientTransform(_controller.value),
        ).createShader(bounds),
        child: base,
      ),
    );
  }
}

class _ZhSkeletonGradientTransform extends GradientTransform {
  const _ZhSkeletonGradientTransform(this.progress);

  final double progress;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final offset = (progress * 2.4 - 1.2) * bounds.width;
    return Matrix4.translationValues(offset, 0, 0);
  }
}

/// A stable card list used while a feed, search result or paged list is
/// waiting for its first response.
class ZhListLoadingSkeleton extends StatelessWidget {
  const ZhListLoadingSkeleton({
    super.key,
    required this.topInset,
    this.showImages = false,
    this.count = 5,
    this.headerHeight = 0,
  });

  final double topInset;
  final bool showImages;
  final int count;
  final double headerHeight;

  @override
  Widget build(BuildContext context) => ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.fromLTRB(12, topInset + 12, 12, 120),
    itemCount: count + (headerHeight > 0 ? 1 : 0),
    itemBuilder: (context, index) {
      if (headerHeight > 0 && index == 0) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ZhSkeleton(height: headerHeight, radius: ZhRadius.card),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: _ZhLoadingCard(showImages: showImages),
      );
    },
  );
}

class _ZhLoadingCard extends StatelessWidget {
  const _ZhLoadingCard({required this.showImages});

  final bool showImages;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const ZhSkeleton(width: 42, height: 42, radius: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ZhSkeleton(width: 150, height: 17, radius: 8),
                const SizedBox(height: 8),
                ZhSkeleton(width: 96, height: 12, radius: 6),
              ],
            ),
          ),
          const ZhSkeleton(width: 42, height: 14, radius: 7),
        ],
      ),
      const SizedBox(height: 16),
      ZhSkeleton(width: double.infinity, height: 20, radius: 8),
      const SizedBox(height: 10),
      ZhSkeleton(width: double.infinity, height: 16, radius: 8),
      const SizedBox(height: 8),
      const FractionallySizedBox(
        widthFactor: .72,
        child: ZhSkeleton(width: double.infinity, height: 16, radius: 8),
      ),
      if (showImages) ...[
        const SizedBox(height: 14),
        ZhSkeleton(width: double.infinity, height: 148, radius: ZhRadius.card),
      ],
      const SizedBox(height: 14),
      Row(
        children: [
          const ZhSkeleton(width: 58, height: 13, radius: 6),
          const SizedBox(width: 22),
          const ZhSkeleton(width: 58, height: 13, radius: 6),
          const SizedBox(width: 22),
          const ZhSkeleton(width: 58, height: 13, radius: 6),
        ],
      ),
    ],
  );
}

/// A detail-page skeleton that follows the author, title, metadata, body and
/// image rhythm without exposing any real content while the document loads.
class ZhContentDetailSkeleton extends StatelessWidget {
  const ZhContentDetailSkeleton({
    super.key,
    required this.topInset,
    this.showQuestionHeader = false,
  });

  final double topInset;
  final bool showQuestionHeader;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const ClampingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    slivers: [
      SliverToBoxAdapter(child: SizedBox(height: topInset)),
      if (showQuestionHeader)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 12, 18, 4),
            child: ZhSkeleton(height: 58, radius: 16),
          ),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 104),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Row(
              children: [
                const ZhSkeleton(width: 48, height: 48, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ZhSkeleton(width: 156, height: 19, radius: 9),
                      const SizedBox(height: 9),
                      ZhSkeleton(width: 112, height: 13, radius: 6),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            ZhSkeleton(width: double.infinity, height: 26, radius: 10),
            const SizedBox(height: 12),
            const FractionallySizedBox(
              widthFactor: .78,
              child: ZhSkeleton(width: double.infinity, height: 20, radius: 8),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const ZhSkeleton(width: 76, height: 13, radius: 6),
                const SizedBox(width: 20),
                const ZhSkeleton(width: 76, height: 13, radius: 6),
                const SizedBox(width: 20),
                const ZhSkeleton(width: 76, height: 13, radius: 6),
              ],
            ),
            const SizedBox(height: 28),
            ZhSkeleton(width: double.infinity, height: 18, radius: 8),
            const SizedBox(height: 10),
            ZhSkeleton(width: double.infinity, height: 18, radius: 8),
            const SizedBox(height: 10),
            const FractionallySizedBox(
              widthFactor: .9,
              child: ZhSkeleton(width: double.infinity, height: 18, radius: 8),
            ),
            const SizedBox(height: 10),
            const FractionallySizedBox(
              widthFactor: .62,
              child: ZhSkeleton(width: double.infinity, height: 18, radius: 8),
            ),
            const SizedBox(height: 22),
            ZhSkeleton(width: double.infinity, height: 220, radius: 18),
            const SizedBox(height: 18),
            ZhSkeleton(width: double.infinity, height: 18, radius: 8),
            const SizedBox(height: 10),
            const FractionallySizedBox(
              widthFactor: .84,
              child: ZhSkeleton(width: double.infinity, height: 18, radius: 8),
            ),
          ]),
        ),
      ),
    ],
  );
}

/// A compact profile-shaped placeholder for account and user pages.
class ZhProfileLoadingSkeleton extends StatelessWidget {
  const ZhProfileLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
    children: [
      const ZhSkeleton(height: 224, radius: 24),
      const SizedBox(height: 18),
      Row(
        children: [
          const ZhSkeleton(width: 72, height: 72, radius: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ZhSkeleton(width: 164, height: 22, radius: 10),
                const SizedBox(height: 10),
                const ZhSkeleton(width: 224, height: 14, radius: 7),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 22),
      const ZhSkeleton(height: 50, radius: 18),
      const SizedBox(height: 18),
      const ZhSkeleton(height: 18, radius: 8),
      const SizedBox(height: 10),
      const FractionallySizedBox(
        widthFactor: .82,
        child: ZhSkeleton(width: double.infinity, height: 18, radius: 8),
      ),
      const SizedBox(height: 10),
      const FractionallySizedBox(
        widthFactor: .64,
        child: ZhSkeleton(width: double.infinity, height: 18, radius: 8),
      ),
    ],
  );
}

/// A stable form-shaped placeholder used by settings pages while preferences
/// are read. It does not expose labels or defaults before the load completes.
class ZhFormLoadingSkeleton extends StatelessWidget {
  const ZhFormLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
    children: [
      const ZhSkeleton(height: 92, radius: 20),
      const SizedBox(height: 16),
      const ZhSkeleton(height: 156, radius: 20),
      const SizedBox(height: 16),
      const ZhSkeleton(height: 124, radius: 20),
      const SizedBox(height: 16),
      const ZhSkeleton(height: 84, radius: 20),
    ],
  );
}

/// A conversation-shaped placeholder that keeps bubble positions stable.
class ZhConversationLoadingSkeleton extends StatelessWidget {
  const ZhConversationLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: .62,
          child: const ZhSkeleton(height: 64, radius: 18),
        ),
      ),
      const SizedBox(height: 14),
      Align(
        alignment: Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: .52,
          child: const ZhSkeleton(height: 52, radius: 18),
        ),
      ),
      const SizedBox(height: 14),
      Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: .78,
          child: const ZhSkeleton(height: 88, radius: 18),
        ),
      ),
      const SizedBox(height: 14),
      Align(
        alignment: Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: .68,
          child: const ZhSkeleton(height: 72, radius: 18),
        ),
      ),
      const SizedBox(height: 14),
      Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: .56,
          child: const ZhSkeleton(height: 56, radius: 18),
        ),
      ),
    ],
  );
}
