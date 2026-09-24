import 'package:flutter/widgets.dart';

import '../core/session_store.dart';
import 'generated/app_localizations.dart';
import 'generated/app_localizations_zh.dart';

export 'generated/app_localizations.dart';

final AppLocalizations _defaultZhLocalizations = AppLocalizationsZh();

extension ZhLocalizationContext on BuildContext {
  AppLocalizations get zhL10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      _defaultZhLocalizations;
}

extension ZhHomeFeedChannelLocalization on HomeFeedChannel {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    HomeFeedChannel.following => l10n.feedFollowing,
    HomeFeedChannel.recommend => l10n.feedRecommend,
    HomeFeedChannel.hot => l10n.feedHot,
    HomeFeedChannel.story => l10n.feedStory,
  };
}
