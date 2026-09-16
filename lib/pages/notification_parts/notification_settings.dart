part of '../notifications_page.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key, required this.api});

  final ZhihuApiClient api;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  Map<String, dynamic>? _settings;
  Object? _error;
  bool _loading = false;
  bool _saving = false;

  static const _labels = <String, String>{
    'comment_me': '评论了我',
    'mention_me': '提及了我',
    'answer_voteup2': '赞同了我的回答',
    'content_voteup': '赞同了我的内容',
    'answer_thanks': '感谢了我的回答',
    'repin_me': '收藏了我的内容',
    'reaction_me': '回应了我的内容',
    'member_follow': '关注了我',
    'member_follow_favlist': '关注了我的收藏夹',
    'column_follow': '关注了我的专栏',
    'question_answered': '我关注的问题有新回答',
    'answer_my_question': '回答了我的问题',
    'question_invite': '邀请我回答',
    'column_update': '关注的专栏有更新',
    'following_member_new_activity': '关注的人有新动态',
    'special_update': '关注的专题有更新',
    'message_recv': '收到私信',
    'inbox_stranger': '陌生人私信',
    'coupon_notify': '优惠与权益提醒',
    'bought_content': '已购内容更新',
    'ebook_publish': '电子书上新',
    'article_invite': '邀请我创作文章',
    'article_tipjar_success': '文章赞赏到账',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await widget.api.getUri(
        widget.api.notificationSettingsUri(),
      );
      if (!mounted) return;
      if (!response.isSuccess || response.jsonMap == null) throw response;
      setState(() => _settings = Map<String, dynamic>.from(response.jsonMap!));
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(String key, bool enabled) async {
    final settings = _settings;
    if (settings == null || _saving) return;
    final previous = _stringMap(settings[key]);
    setState(() {
      settings[key] = {...previous, 'switch': enabled};
      _saving = true;
    });
    try {
      final response = await widget.api.updateNotificationSettings(settings);
      if (!mounted) return;
      if (!response.isSuccess) throw response;
    } catch (error) {
      if (!mounted) return;
      setState(() => settings[key] = previous);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ApiFailure.from(error).detail)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('通知设置')),
    body: ZhResponsiveFrame(
      maxWidth: 760,
      desktopGutter: 24,
      child: _loading && _settings == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _settings == null
          ? ApiErrorView(error: _error!, onRetry: _load)
          : _settingsList(),
    ),
  );

  Widget _settingsList() {
    final settings = _settings ?? const <String, dynamic>{};
    final keys =
        settings.keys.where((key) {
          final value = _stringMap(settings[key]);
          return value['switch'] is bool;
        }).toList()..sort((a, b) {
          final ai = _labels.keys.toList().indexOf(a);
          final bi = _labels.keys.toList().indexOf(b);
          return (ai < 0 ? 999 : ai).compareTo(bi < 0 ? 999 : bi);
        });
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: keys.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 20),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 13),
            child: Text(
              '互动与内容通知',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }
        final key = keys[index - 1];
        final setting = _stringMap(settings[key]);
        return ZhLiquidGlassSwitchTile(
          key: ValueKey('notification-setting-$key'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: _labels[key] ?? key.replaceAll('_', ' '),
          subtitle: plainText(setting['scope']).isEmpty
              ? null
              : plainText(setting['scope']) == 'all'
              ? '全部'
              : plainText(setting['scope']),
          value: setting['switch'] == true,
          onChanged: _saving ? null : (value) => _toggle(key, value),
        );
      },
    );
  }
}

class _LoginRequired extends StatelessWidget {
  const _LoginRequired({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_none_rounded, size: 58),
          const SizedBox(height: 18),
          Text('登录后查看消息', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '消息通知属于知乎账号数据',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
          ),
          const SizedBox(height: 22),
          ZhPrimaryButton(
            label: '返回并登录',
            icon: Icons.login_rounded,
            onPressed: onBack,
          ),
        ],
      ),
    ),
  );
}
