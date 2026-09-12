part of '../../pages/salt_page.dart';

/// Renders the two shelf content modes without owning synchronization state.
/// The page keeps network/cache state; this widget only receives a snapshot and
/// emits navigation or selection callbacks.
class SaltShelfContent extends StatelessWidget {
  const SaltShelfContent({
    super.key,
    required this.tabIndex,
    required this.entries,
    required this.remoteRows,
    required this.propertyFilter,
    required this.downloadedOnly,
    required this.downloadCounts,
    required this.manageMode,
    required this.selectedIds,
    required this.loading,
    required this.syncError,
    required this.loadingTabs,
    required this.errors,
    required this.onLoadTab,
    required this.onOpenCard,
    required this.onToggleSelection,
  });

  final int tabIndex;
  final List<SaltBookshelfEntry> entries;
  final List<Map<String, dynamic>> remoteRows;
  final String propertyFilter;
  final bool downloadedOnly;
  final Map<String, int> downloadCounts;
  final bool manageMode;
  final Set<String> selectedIds;
  final bool loading;
  final Object? syncError;
  final Set<int> loadingTabs;
  final Map<int, Object?> errors;
  final Future<void> Function(int tab, {bool refresh}) onLoadTab;
  final ValueChanged<Map<String, dynamic>> onOpenCard;
  final ValueChanged<String> onToggleSelection;

  @override
  Widget build(BuildContext context) => tabIndex == 0
      ? _buildShelfEntries(context)
      : _buildRemoteShelfEntries(context);

  Widget _buildShelfEntries(BuildContext context) {
    final filtered = entries
        .where((entry) {
          if (propertyFilter.isNotEmpty &&
              entry.propertyType != propertyFilter) {
            return false;
          }
          if (downloadedOnly && (downloadCounts[entry.businessId] ?? 0) == 0) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
    if (filtered.isEmpty) return _buildShelfEmpty(context, '还没有内容');
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= ZhViewport.desktop;
        if (!desktop) {
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 28),
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                _shelfEntryCard(context, filtered[index]),
          );
        }
        final cardWidth = ((constraints.maxWidth - 60) / 2)
            .clamp(220.0, 720.0)
            .toDouble();
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 28),
          children: [
            Wrap(
              spacing: 12,
              children: [
                for (final entry in filtered)
                  SizedBox(
                    width: cardWidth,
                    child: _shelfEntryCard(context, entry),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRemoteShelfEntries(BuildContext context) {
    if (loadingTabs.contains(tabIndex) && remoteRows.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 360,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    final error = errors[tabIndex];
    if (error != null && remoteRows.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 430,
            child: ApiErrorView(
              error: error,
              onRetry: () => onLoadTab(tabIndex, refresh: true),
              titleOverride: '该分区暂时无法加载',
            ),
          ),
        ],
      );
    }
    if (remoteRows.isEmpty) return _buildShelfEmpty(context, '还没有内容');
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 28),
      itemCount: remoteRows.length,
      itemBuilder: (context, index) => SaltCatalogCard(
        value: remoteRows[index],
        coverWidth: 76,
        coverHeight: 106,
        onTap: () => onOpenCard(remoteRows[index]),
      ),
    );
  }

  Widget _buildShelfEmpty(BuildContext context, String message) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.58,
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_stories_outlined,
                      size: 46,
                      color: ZhPalette.subtleInk,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (syncError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '云书架同步暂时失败，下拉重试',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.mutedInk,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    ],
  );

  Widget _shelfEntryCard(BuildContext context, SaltBookshelfEntry entry) {
    final cardValue = <String, dynamic>{
      ...entry.cardJson,
      '_downloaded_section_count': downloadCounts[entry.businessId] ?? 0,
    };
    final card = SaltCatalogCard(
      value: cardValue,
      coverWidth: 76,
      coverHeight: 106,
      onTap: () => onOpenCard(cardValue),
    );
    if (!manageMode) return card;
    final selected = selectedIds.contains(entry.businessId);
    return Stack(
      children: [
        IgnorePointer(child: card),
        Positioned.fill(
          child: Material(
            color: selected ? const Color(0x141772F6) : Colors.transparent,
            child: InkWell(
              key: ValueKey('shelf-select-${entry.businessId}'),
              onTap: () => onToggleSelection(entry.businessId),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 18,
          child: IgnorePointer(
            child: Checkbox(
              value: selected,
              shape: const CircleBorder(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}
