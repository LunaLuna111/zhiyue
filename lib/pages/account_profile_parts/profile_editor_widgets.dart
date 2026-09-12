part of '../account_profile_pages.dart';

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
    decoration: BoxDecoration(
      color: ZhPalette.background,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    ),
  );
}

class _ProfileValueRow extends StatelessWidget {
  const _ProfileValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 15),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: ZhPalette.border)),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: const TextStyle(color: ZhPalette.subtleInk),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class _ProfileImpactRow extends StatelessWidget {
  const _ProfileImpactRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(color: ZhPalette.subtleInk)),
      ],
    ),
  );
}

class _ProfileEditRow extends StatelessWidget {
  const _ProfileEditRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = '',
  });
  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ZhPalette.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(color: ZhPalette.subtleInk),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? placeholder : value,
              style: TextStyle(
                color: value.isEmpty ? ZhPalette.subtleInk : ZhPalette.ink,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: ZhPalette.subtleInk),
        ],
      ),
    ),
  );
}

class _ProfileImageEditRow extends StatelessWidget {
  const _ProfileImageEditRow({
    required this.label,
    required this.preview,
    required this.onTap,
    required this.uploading,
  });

  final String label;
  final Widget preview;
  final VoidCallback? onTap;
  final bool uploading;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 112, child: Text(label)),
          preview,
          const Spacer(),
          if (uploading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            const Text('更换', style: TextStyle(color: ZhPalette.subtleInk)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: ZhPalette.subtleInk),
          ],
        ],
      ),
    ),
  );
}

class _ProfileImagePreview extends StatelessWidget {
  const _ProfileImagePreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final valid = Uri.tryParse(imageUrl)?.scheme == 'https';
    return Container(
      width: 92,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ZhPalette.canvas,
        borderRadius: BorderRadius.circular(10),
      ),
      child: valid
          ? ZhihuImage.network(
              imageUrl,
              headers: zhihuImageRequestHeaders,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
            )
          : const Icon(Icons.image_outlined),
    );
  }
}

class _ProfileListEditor extends StatelessWidget {
  const _ProfileListEditor({
    required this.title,
    required this.actionLabel,
    required this.rows,
    this.onAdd,
    this.onRemove,
  });
  final String title;
  final String actionLabel;
  final List<String> rows;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        for (var index = 0; index < rows.length; index++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(rows[index]),
            trailing: onRemove == null
                ? null
                : IconButton(
                    tooltip: '删除',
                    onPressed: () => onRemove!(index),
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: Text(actionLabel),
        ),
      ],
    ),
  );
}

class _ProfileTextEditorSheet extends StatefulWidget {
  const _ProfileTextEditorSheet({
    required this.title,
    required this.value,
    required this.maxLength,
    required this.maxLines,
  });
  final String title;
  final String value;
  final int maxLength;
  final int maxLines;

  @override
  State<_ProfileTextEditorSheet> createState() =>
      _ProfileTextEditorSheetState();
}

class _ProfileTextEditorSheetState extends State<_ProfileTextEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_controller.text.trim()),
                child: const Text('完成'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: widget.maxLength,
            minLines: widget.maxLines == 1 ? 1 : 3,
            maxLines: widget.maxLines,
          ),
        ],
      ),
    ),
  );
}

class _ProfilePairEditorSheet extends StatefulWidget {
  const _ProfilePairEditorSheet({
    required this.title,
    required this.firstLabel,
    required this.secondLabel,
  });
  final String title;
  final String firstLabel;
  final String secondLabel;

  @override
  State<_ProfilePairEditorSheet> createState() =>
      _ProfilePairEditorSheetState();
}

class _ProfilePairEditorSheetState extends State<_ProfilePairEditorSheet> {
  final _first = TextEditingController();
  final _second = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          TextField(
            controller: _first,
            decoration: InputDecoration(labelText: widget.firstLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _second,
            decoration: InputDecoration(labelText: widget.secondLabel),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final first = _first.text.trim();
                final second = _second.text.trim();
                if (first.isNotEmpty || second.isNotEmpty) {
                  Navigator.of(context).pop([first, second]);
                }
              },
              child: const Text('完成'),
            ),
          ),
        ],
      ),
    ),
  );
}
