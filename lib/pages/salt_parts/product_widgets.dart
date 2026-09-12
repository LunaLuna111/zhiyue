part of '../salt_page.dart';

class _SaltProductCatalogControls extends StatelessWidget {
  const _SaltProductCatalogControls({
    required this.descending,
    required this.canRead,
    required this.continueReading,
    required this.bookshelfSaving,
    required this.addedToBookshelf,
    required this.onOrderChanged,
    required this.onRead,
    required this.onAddToBookshelf,
  });
  final bool descending;
  final bool canRead;
  final bool continueReading;
  final bool bookshelfSaving;
  final bool addedToBookshelf;
  final ValueChanged<bool> onOrderChanged;
  final VoidCallback? onRead;
  final VoidCallback? onAddToBookshelf;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 6,
              child: ZhPrimaryButton(
                expand: true,
                onPressed: canRead ? onRead : null,
                icon: continueReading
                    ? Icons.menu_book_rounded
                    : Icons.play_arrow_rounded,
                label: continueReading ? '继续阅读' : '开始阅读',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: ZhOutlineButton(
                expand: true,
                onPressed: onAddToBookshelf,
                leading: bookshelfSaving
                    ? const SizedBox.square(
                        dimension: 17,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        addedToBookshelf
                            ? Icons.bookmark_added_rounded
                            : Icons.bookmark_add_outlined,
                        size: 18,
                      ),
                label: addedToBookshelf ? '已加入' : '加入书架',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              '章节顺序',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: ZhPalette.mutedInk),
            ),
            const Spacer(),
            SizedBox(
              height: 38,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('正序')),
                  ButtonSegment(value: true, label: Text('倒序')),
                ],
                selected: {descending},
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 13),
                  ),
                ),
                onSelectionChanged: (selection) {
                  onOrderChanged(selection.first);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

@visibleForTesting
List<Map<String, dynamic>> saltReadableSections(Object? value) =>
    extractRows(value)
        .where(
          (row) =>
              _findString(row, const ['section_id', 'id']) != null &&
              _findString(row, const ['section_id', 'id']) != '0',
        )
        .toList(growable: false);

class _SaltProductSectionRow extends StatelessWidget {
  const _SaltProductSectionRow({required this.value, this.onTap});
  final Map<String, dynamic> value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final object = unwrapObject(value);
    final title = plainText(object['title']);
    final serial = plainText(object['serial_number_text']);
    final progress = plainText(object['progress_text']);
    final lastRead = object['last_read'] == true;
    final finished = object['read_finished'] == true;
    final secondary = [
      if (lastRead) '上次读到',
      if (finished) '已读',
      if (progress.isNotEmpty) progress,
    ].join(' · ');
    return Material(
      color: ZhPalette.background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ZhPalette.border, width: 0.7),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 58,
                child: Text(
                  serial.isEmpty ? '章节' : serial,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ZhPalette.mutedInk,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.isEmpty ? '未命名章节' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    if (secondary.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        secondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ZhPalette.mutedInk,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: ZhPalette.subtleInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
