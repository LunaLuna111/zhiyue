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
    appBar: ZhTopBar(title: Text(context.zhL10n.notificationSettingsTitle)),
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
    final l10n = context.zhL10n;
    final settings = _settings ?? const <String, dynamic>{};
    final keys =
        settings.keys.where((key) {
          final value = _stringMap(settings[key]);
          return value['switch'] is bool;
        }).toList()..sort((a, b) {
          final ai = _notificationSettingKeys.indexOf(a);
          final bi = _notificationSettingKeys.indexOf(b);
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
              l10n.notificationSettingsSection,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }
        final key = keys[index - 1];
        final setting = _stringMap(settings[key]);
        return ZhLiquidGlassSwitchTile(
          key: ValueKey('notification-setting-$key'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: _notificationSettingLabel(key, l10n),
          subtitle: plainText(setting['scope']).isEmpty
              ? null
              : plainText(setting['scope']) == 'all'
              ? l10n.notificationAll
              : plainText(setting['scope']),
          value: setting['switch'] == true,
          onChanged: _saving ? null : (value) => _toggle(key, value),
        );
      },
    );
  }
}

const _notificationSettingKeys = [
  'comment_me',
  'mention_me',
  'answer_voteup2',
  'content_voteup',
  'answer_thanks',
  'repin_me',
  'reaction_me',
  'member_follow',
  'member_follow_favlist',
  'column_follow',
  'question_answered',
  'answer_my_question',
  'question_invite',
  'column_update',
  'following_member_new_activity',
  'special_update',
  'message_recv',
  'inbox_stranger',
  'coupon_notify',
  'bought_content',
  'ebook_publish',
  'article_invite',
  'article_tipjar_success',
];

String _notificationSettingLabel(String key, AppLocalizations l10n) =>
    switch (key) {
      'comment_me' => l10n.notificationSettingCommentMe,
      'mention_me' => l10n.notificationSettingMentionMe,
      'answer_voteup2' => l10n.notificationSettingAnswerVoteup,
      'content_voteup' => l10n.notificationSettingContentVoteup,
      'answer_thanks' => l10n.notificationSettingAnswerThanks,
      'repin_me' => l10n.notificationSettingRepin,
      'reaction_me' => l10n.notificationSettingReaction,
      'member_follow' => l10n.notificationSettingMemberFollow,
      'member_follow_favlist' => l10n.notificationSettingFavlistFollow,
      'column_follow' => l10n.notificationSettingColumnFollow,
      'question_answered' => l10n.notificationSettingQuestionAnswered,
      'answer_my_question' => l10n.notificationSettingAnswerQuestion,
      'question_invite' => l10n.notificationSettingQuestionInvite,
      'column_update' => l10n.notificationSettingColumnUpdate,
      'following_member_new_activity' => l10n.notificationSettingMemberActivity,
      'special_update' => l10n.notificationSettingSpecialUpdate,
      'message_recv' => l10n.notificationSettingMessage,
      'inbox_stranger' => l10n.notificationSettingStrangerMessage,
      'coupon_notify' => l10n.notificationSettingCoupon,
      'bought_content' => l10n.notificationSettingBoughtContent,
      'ebook_publish' => l10n.notificationSettingEbook,
      'article_invite' => l10n.notificationSettingArticleInvite,
      'article_tipjar_success' => l10n.notificationSettingTipjar,
      _ => key.replaceAll('_', ' '),
    };

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
          Text(
            context.zhL10n.notificationLoginTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            context.zhL10n.notificationLoginMessage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: ZhPalette.mutedInk),
          ),
          const SizedBox(height: 22),
          ZhPrimaryButton(
            label: context.zhL10n.notificationBackLogin,
            icon: Icons.login_rounded,
            onPressed: onBack,
          ),
        ],
      ),
    ),
  );
}
