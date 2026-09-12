import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/api_client.dart';
import '../core/input_validation.dart';
import '../core/json_tools.dart';
import '../ui/zh_components.dart';
import '../ui/zh_theme.dart';
import 'content_pages.dart';
import 'paged_list_page.dart';

Widget discoverColumnsPage(ZhihuApiClient api) => PagedListPage(
  title: '专栏推荐',
  api: api,
  loadInitial: () => api.get('/column/column_tab/feed'),
  onObjectTap: (context, value) => openDetectedObject(context, api, value),
);

Widget discoverTopicCategoriesPage(ZhihuApiClient api) => PagedListPage(
  title: '话题分类',
  api: api,
  loadInitial: () => api.get('/topic_square/categories'),
  onObjectTap: (context, value) {
    final id = idOf(value);
    if (id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PagedListPage(
          title: titleOf(value),
          api: api,
          loadInitial: () => api.get(
            '/topic_square/categories/${Uri.encodeComponent(id)}/topics',
          ),
          onObjectTap: (context, topic) =>
              openDetectedObject(context, api, topic),
        ),
      ),
    );
  },
);

Widget discoverHotTopicsPage(ZhihuApiClient api) => PagedListPage(
  title: '热门话题',
  api: api,
  emptyMessage: '暂时没有热门话题',
  loadInitial: () => api.get('/hot/topics'),
  onObjectTap: (context, value) => openDetectedObject(context, api, value),
);

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key, required this.api});

  final ZhihuApiClient api;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin {
  final _contentId = TextEditingController();
  String _contentType = 'answer';
  bool _toolsExpanded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _contentId.dispose();
    super.dispose();
  }

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  void _openContentById() {
    final id = _contentId.text.trim();
    if (!isDecimalContentId(id)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('内容 ID 必须是 1–32 位数字')));
      return;
    }
    _open(
      ContentDetailPage(
        api: widget.api,
        contentType: _contentType,
        contentId: id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('发现')),
      body: ZhResponsiveFrame(
        maxWidth: 1040,
        desktopGutter: 24,
        child: ListView(
          padding: const EdgeInsets.only(bottom: ZhSpace.xl),
          children: [
            const ZhSectionHeader(title: '专栏与话题'),
            _ActionCard(
              icon: Icons.view_column_outlined,
              title: '专栏推荐',
              subtitle: '编辑精选与热门专栏文章',
              onTap: () => _open(discoverColumnsPage(widget.api)),
            ),
            _ActionCard(
              icon: Icons.category_outlined,
              title: '话题分类',
              subtitle: '按分类浏览话题',
              onTap: () => _open(discoverTopicCategoriesPage(widget.api)),
            ),
            _ActionCard(
              icon: Icons.local_fire_department_outlined,
              title: '热门话题',
              subtitle: '当前热门讨论',
              onTap: () => _open(discoverHotTopicsPage(widget.api)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ZhSpace.md,
                ZhSpace.sm,
                ZhSpace.md,
                0,
              ),
              child: ZhSurface(
                onTap: () => setState(() => _toolsExpanded = !_toolsExpanded),
                padding: const EdgeInsets.symmetric(
                  horizontal: ZhSpace.md,
                  vertical: ZhSpace.sm,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tag_rounded, size: 20),
                    const SizedBox(width: ZhSpace.sm),
                    Expanded(
                      child: Text(
                        '通过 ID 打开内容',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _toolsExpanded ? .5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ZhSpace.md,
                  ZhSpace.sm,
                  ZhSpace.md,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: ZhSpace.xs,
                      runSpacing: ZhSpace.xs,
                      children: [
                        _DiscoverTypeChip(
                          label: '回答',
                          selected: _contentType == 'answer',
                          onTap: () => setState(() => _contentType = 'answer'),
                        ),
                        _DiscoverTypeChip(
                          label: '文章',
                          selected: _contentType == 'article',
                          onTap: () => setState(() => _contentType = 'article'),
                        ),
                        _DiscoverTypeChip(
                          label: '想法',
                          selected: _contentType == 'pin',
                          onTap: () => setState(() => _contentType = 'pin'),
                        ),
                      ],
                    ),
                    const SizedBox(height: ZhSpace.sm),
                    ShadInput(
                      controller: _contentId,
                      keyboardType: TextInputType.number,
                      placeholder: const Text('输入内容 ID'),
                      constraints: const BoxConstraints(minHeight: 56),
                      leading: const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.numbers_rounded, size: 20),
                      ),
                      trailing: IconButton(
                        tooltip: '打开详情',
                        onPressed: _openContentById,
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                      onSubmitted: (_) => _openContentById(),
                    ),
                  ],
                ),
              ),
              crossFadeState: _toolsExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ZhSurface(
    onTap: onTap,
    margin: const EdgeInsets.fromLTRB(ZhSpace.md, 0, ZhSpace.md, ZhSpace.sm),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: ZhPalette.canvas,
            borderRadius: BorderRadius.circular(ZhRadius.input),
            border: Border.all(color: ZhPalette.border),
          ),
          child: Icon(icon, size: 21),
        ),
        const SizedBox(width: ZhSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: ZhSpace.xxs),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: ZhSpace.xs),
        const Icon(Icons.arrow_forward_rounded, size: 19),
      ],
    ),
  );
}

class _DiscoverTypeChip extends StatelessWidget {
  const _DiscoverTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ShadButton(
    height: 38,
    onPressed: onTap,
    backgroundColor: selected ? ZhPalette.ink : ZhPalette.background,
    foregroundColor: selected ? ZhPalette.background : ZhPalette.ink,
    decoration: ShadDecoration(border: ShadBorder.all(color: ZhPalette.border)),
    child: Text(label),
  );
}
