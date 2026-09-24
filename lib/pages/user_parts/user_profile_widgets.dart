part of '../user_page.dart';

enum _UserProfileTabKind { overview, creations, activities, voteups }

class _UserProfileSubTab {
  const _UserProfileSubTab({required this.label, required this.uri});
  final String label;
  final Uri uri;
}

class _UserProfileTabSpec {
  const _UserProfileTabSpec.local(this.label, this.kind) : subTabs = const [];
  const _UserProfileTabSpec.remote({
    required this.label,
    required this.kind,
    required this.subTabs,
  });
  final String label;
  final _UserProfileTabKind kind;
  final List<_UserProfileSubTab> subTabs;
}

class _UserProfileTabsSurface extends StatelessWidget {
  const _UserProfileTabsSurface(this.tabs);
  final List<_UserProfileTabSpec> tabs;
  static const height = 64.0;
  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => SizedBox(
        key: const ValueKey('user-profile-tabs-surface'),
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: ZhLiquidGlassSegmentedTabs(
            labels: [for (final tab in tabs) tab.label],
            selectedIndex: controller.index,
            onSelected: (index) => controller.animateTo(index),
            scrollable: tabs.length > 4,
            height: 48,
          ),
        ),
      ),
    );
  }
}

class _RemoteUserProfileTab extends StatefulWidget {
  const _RemoteUserProfileTab({
    super.key,
    required this.api,
    required this.kind,
    required this.tabs,
  });
  final ZhihuApiClient api;
  final _UserProfileTabKind kind;
  final List<_UserProfileSubTab> tabs;
  @override
  State<_RemoteUserProfileTab> createState() => _RemoteUserProfileTabState();
}

class _RemoteUserProfileTabState extends State<_RemoteUserProfileTab> {
  var _selected = 0;
  Widget _list(_UserProfileSubTab tab) => PagedListPage(
    key: ValueKey('user-profile-tab:${tab.uri}'),
    title: '',
    api: widget.api,
    embedded: true,
    loadInitial: () => widget.api.getUri(tab.uri),
    rowBuilder: (context, value, onTap) => _UserProfileFeedRow(
      api: widget.api,
      value: value,
      kind: widget.kind,
      onTap: onTap,
    ),
    onObjectTap: (context, value) =>
        openDetectedObject(context, widget.api, value),
    emptyMessage: context.zhL10n.userProfileNoPublicContent,
  );
  @override
  Widget build(BuildContext context) {
    if (widget.tabs.length == 1) {
      return ZhResponsiveFrame(
        maxWidth: 1120,
        desktopGutter: 24,
        child: _list(widget.tabs.first),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 54,
          child: ListView.separated(
            key: const ValueKey('user-profile-sub-tabs'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            scrollDirection: Axis.horizontal,
            itemCount: widget.tabs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) => ChoiceChip(
              label: Text(widget.tabs[index].label),
              labelStyle: TextStyle(
                color: ZhPalette.ink,
                fontSize: 14,
                fontWeight: index == _selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              selected: index == _selected,
              showCheckmark: false,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              selectedColor: ZhPalette.pressed,
              backgroundColor: ZhPalette.canvas,
              onSelected: (_) => setState(() => _selected = index),
            ),
          ),
        ),
        Expanded(
          child: ZhResponsiveFrame(
            maxWidth: 1120,
            desktopGutter: 24,
            child: _list(widget.tabs[_selected]),
          ),
        ),
      ],
    );
  }
}

class _UserProfileFeedRow extends StatefulWidget {
  const _UserProfileFeedRow({
    required this.api,
    required this.value,
    required this.kind,
    this.onTap,
  });
  final ZhihuApiClient api;
  final Map<String, dynamic> value;
  final _UserProfileTabKind kind;
  final VoidCallback? onTap;
  @override
  State<_UserProfileFeedRow> createState() => _UserProfileFeedRowState();
}

class _UserProfileFeedRowState extends State<_UserProfileFeedRow> {
  var _expanded = false;
  void _open(Map<String, dynamic> value) =>
      openDetectedObject(context, widget.api, value);
  void _openAuthor(Map<String, dynamic> value) {
    if (authorIdOf(value).isNotEmpty) {
      openContentAuthor(context, widget.api, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFollowItemGroupRow(widget.value)) {
      return FollowItemGroupCard(
        value: widget.value,
        expanded: _expanded,
        onExpand: () => setState(() => _expanded = true),
        onChildTap: _open,
        onChildAuthorTap: _openAuthor,
        compact: true,
      );
    }
    final object = unwrapObject(widget.value);
    final actionText = plainText(
      object['action_text'] ??
          widget.value['action_text'] ??
          object['verb'] ??
          widget.value['verb'],
    );
    final actor = object['actor'] is Map
        ? (object['actor'] as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          )
        : null;
    final actorName = plainText(actor?['name']);
    final showAction =
        widget.kind != _UserProfileTabKind.creations && actionText.isNotEmpty;
    return Material(
      color: ZhPalette.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAction)
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 11, 11, 0),
              child: Text.rich(
                TextSpan(
                  children: [
                    if (actorName.isNotEmpty)
                      TextSpan(
                        text: '$actorName  ',
                        style: TextStyle(
                          color: ZhPalette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    TextSpan(text: actionText),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ZhPalette.mutedInk,
                  fontSize: 12.5,
                ),
              ),
            ),
          ObjectCard(
            value: widget.value,
            onTap: widget.onTap,
            onAuthorTap: authorIdOf(widget.value).isEmpty
                ? null
                : () => _openAuthor(widget.value),
            feedMode: true,
            compact: true,
            showImages: true,
            showMetrics: true,
          ),
        ],
      ),
    );
  }
}

class _UserProfileCover extends StatelessWidget {
  const _UserProfileCover({required this.imageUrl});
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    if (Uri.tryParse(imageUrl)?.scheme != 'https') {
      return const ColoredBox(color: Color(0xFF326A66));
    }
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .clamp(720.0, 1920.0)
            .round();
    return ZhihuImage.network(
      imageUrl,
      headers: zhihuImageRequestHeaders,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.low,
      frameBuilder: (_, child, frame, _) =>
          frame == null ? const ColoredBox(color: Color(0xFF326A66)) : child,
      errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF326A66)),
    );
  }
}

class _ProfileHeaderStat extends StatelessWidget {
  const _ProfileHeaderStat({
    required this.value,
    required this.label,
    this.light = false,
    this.onTap,
  });
  final int? value;
  final String label;
  final bool light;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value == null ? '--' : compactCount(value!),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: light ? Colors.white : ZhPalette.ink,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: light ? Colors.white : ZhPalette.mutedInk,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileHeaderDivider extends StatelessWidget {
  const _ProfileHeaderDivider();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 30,
    child: VerticalDivider(width: 1, color: Colors.white54),
  );
}

class _ProfileInfoLine extends StatelessWidget {
  const _ProfileInfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 17, color: ZhPalette.subtleInk),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
        ),
      ),
    ],
  );
}

class _UserAction {
  const _UserAction(this.label, this.icon, this.builder);
  final String label;
  final IconData icon;
  final Widget Function(String id) builder;
}

class _ProfileShortcut {
  const _ProfileShortcut(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _UserActionTile extends StatelessWidget {
  const _UserActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ZhSurface(
    onTap: onTap,
    padding: const EdgeInsets.all(ZhSpace.sm),
    backgroundColor: ZhPalette.canvas,
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ZhPalette.background,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: ZhPalette.border),
          ),
          child: Icon(icon, size: 18),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(Icons.chevron_right_rounded, size: 17),
      ],
    ),
  );
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl, required this.fallback});
  final String imageUrl;
  final String fallback;
  static const size = 76.0;
  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: ZhPalette.ink,
      child: Center(
        child: Text(
          fallback.characters.first,
          style: TextStyle(
            color: ZhPalette.background,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ZhPalette.background,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Uri.tryParse(imageUrl)?.scheme != 'https'
            ? placeholder
            : ZhihuImage.network(
                imageUrl,
                headers: zhihuImageRequestHeaders,
                fit: BoxFit.cover,
                cacheWidth: (size * 3).round(),
                cacheHeight: (size * 3).round(),
                frameBuilder: (_, child, frame, _) =>
                    frame == null ? placeholder : child,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
