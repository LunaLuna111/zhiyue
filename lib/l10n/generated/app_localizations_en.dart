// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zhiyue';

  @override
  String get navRecommend => 'For You';

  @override
  String get navSearch => 'Search';

  @override
  String get navBookshelf => 'Shelf';

  @override
  String get navMe => 'Me';

  @override
  String get navWorkspace => 'Workspace';

  @override
  String get feedFollowing => 'Following';

  @override
  String get feedRecommend => 'For You';

  @override
  String get feedHot => 'Hot';

  @override
  String get feedStory => 'Stories';

  @override
  String get answerLabel => 'Answer';

  @override
  String get drawerBrowse => 'Browse';

  @override
  String get drawerColumns => 'Column picks';

  @override
  String get drawerTopicCategories => 'Topic categories';

  @override
  String get drawerHotTopics => 'Hot topics';

  @override
  String get drawerHistory => 'History';

  @override
  String get drawerMyContent => 'My content';

  @override
  String get drawerMessages => 'Messages';

  @override
  String get drawerCollections => 'Collections';

  @override
  String get drawerBookshelf => 'Shelf';

  @override
  String get drawerFindUsers => 'Find users';

  @override
  String get drawerAccount => 'Account';

  @override
  String get drawerLoginOrAddAccount => 'Sign in or add account';

  @override
  String get drawerAccountManagement => 'Account management';

  @override
  String get drawerApp => 'App';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerClose => 'Close sidebar';

  @override
  String drawerVersion(String version) {
    return 'Zhiyue $version';
  }

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonMore => 'More';

  @override
  String get commonReply => 'Reply';

  @override
  String get commonPublish => 'Publish';

  @override
  String get commonPublishing => 'Publishing';

  @override
  String get commonFollow => 'Follow';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonShare => 'Share';

  @override
  String get commonFailed => 'Failed to load. Try again.';

  @override
  String get commonNoMore => 'No more content';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHomeContent => 'Home & content';

  @override
  String get settingsStartupPage => 'Startup page';

  @override
  String get settingsRecommendation => 'Recommendation strategy';

  @override
  String get settingsServer => 'Server';

  @override
  String get settingsLocal => 'Local';

  @override
  String get settingsHybrid => 'Hybrid';

  @override
  String get settingsDensity => 'Content density';

  @override
  String get settingsComfortable => 'Comfortable';

  @override
  String get settingsCompact => 'Compact';

  @override
  String get settingsRefreshHome => 'Refresh when tapping Home again';

  @override
  String get settingsRefreshHomeSubtitle =>
      'Return to the top and refresh when tapping the selected Home tab';

  @override
  String get settingsShowImages => 'Show recommendation images';

  @override
  String get settingsShowImagesSubtitle =>
      'When off, Home shows only text, authors, and interactions';

  @override
  String get settingsShowMetrics => 'Show interaction metrics';

  @override
  String get settingsShowMetricsSubtitle =>
      'Show votes, collections, comments, and dates';

  @override
  String get settingsLocalBehavior => 'Local recommendation behavior';

  @override
  String settingsLocalEvents(int count) {
    return '$count events recorded on this device';
  }

  @override
  String get settingsFeedOrder => 'Home section order';

  @override
  String get settingsFilterStats => 'Content filter statistics';

  @override
  String get settingsReadingDisplay => 'Reading & display';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsDarkModeOnSubtitle =>
      'Use dark backgrounds and low-light surfaces';

  @override
  String get settingsDarkModeOffSubtitle =>
      'Use light backgrounds and bright surfaces';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app interface language';

  @override
  String get settingsTextSize => 'Reading text size';

  @override
  String get settingsSmall => 'Small';

  @override
  String get settingsStandard => 'Standard';

  @override
  String get settingsLarge => 'Large';

  @override
  String get settingsFollowSystemTextScale => 'Follow system text size';

  @override
  String get settingsFollowSystemTextScaleSubtitle =>
      'Apply the system display size on top of the reading size';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionSubtitle =>
      'Reduce page and component animations';

  @override
  String get settingsGlass => 'Liquid glass effects';

  @override
  String get settingsGlassOnSubtitle =>
      'Keep glass feedback and translucent layers';

  @override
  String get settingsGlassOffSubtitle =>
      'Performance mode: use lightweight solid controls and navigation';

  @override
  String get settingsPersonalization => 'Personalization';

  @override
  String get settingsFocusSearch => 'Open the keyboard on the Search page';

  @override
  String get settingsFocusSearchOn => 'Focus the search field automatically';

  @override
  String get settingsFocusSearchOff => 'Tap the search field manually';

  @override
  String get settingsImagesStorage => 'Images & storage';

  @override
  String get settingsKeepHistory => 'Keep browsing history';

  @override
  String settingsKeepHistoryOn(int count) {
    return 'On this device only · $count items';
  }

  @override
  String get settingsKeepHistoryOff =>
      'Opened content will not be saved locally';

  @override
  String get settingsPrefetchImages => 'Prefetch list images';

  @override
  String get settingsPrefetchImagesSubtitle =>
      'Preload avatars and article images before they appear';

  @override
  String get settingsImageCache => 'Image cache size';

  @override
  String get settingsEconomy => 'Economy';

  @override
  String get settingsRoomy => 'Roomy';

  @override
  String get settingsNoCacheImages => 'No cached images';

  @override
  String settingsCachedImages(int count) {
    return 'Cleared $count cached images';
  }

  @override
  String get settingsPrivacyData => 'Privacy & data';

  @override
  String get settingsKeepSearch => 'Keep search history';

  @override
  String settingsKeepSearchOn(int count) {
    return 'On this device only · $count items';
  }

  @override
  String get settingsKeepSearchOff => 'New searches will not be saved locally';

  @override
  String get settingsShowHot => 'Show hot searches';

  @override
  String get settingsShowHotOn => 'Show Zhihu hot searches on Search';

  @override
  String get settingsShowHotOff => 'Do not load hot searches';

  @override
  String get settingsWebDav => 'WebDAV sync';

  @override
  String get settingsAccountSessions => 'Accounts & multi-device sign-in';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsOther => 'Other';

  @override
  String get settingsDiagnostics => 'Diagnostic logs';

  @override
  String get settingsUpdate => 'Software update';

  @override
  String get settingsRestoreDefaults => 'Restore default settings';

  @override
  String get settingsAbout => 'About Zhiyue';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsFeedOrderSubtitle =>
      'Drag from the right to sync the home tabs and swipe order.';

  @override
  String get settingsRestoreDefaultsMessage =>
      'All settings will be restored without signing out.';

  @override
  String get settingsRestored => 'Settings restored';

  @override
  String get settingsSignOutMessage =>
      'Saved sign-in information on this device will be removed.';

  @override
  String get settingsSignedOut => 'Signed out';

  @override
  String get settingsClearBrowsing => 'Clear browsing history';

  @override
  String get settingsNoBrowsingHistory => 'No browsing history';

  @override
  String settingsDeleteBrowsing(int count) {
    return 'Delete $count local records';
  }

  @override
  String get settingsClearImageCache => 'Clear image cache';

  @override
  String get settingsClearOfflineChapters => 'Clear offline chapters';

  @override
  String get settingsClearOfflineChaptersSubtitle =>
      'Delete salt-content chapters saved while reading or downloading';

  @override
  String get settingsClearSearch => 'Clear search history';

  @override
  String get settingsNoSearchHistory => 'No search history';

  @override
  String settingsDeleteSearch(int count) {
    return 'Delete $count local records';
  }

  @override
  String get settingsWebDavConfigured =>
      'Configured · search, history, offline books, and answer cache';

  @override
  String get settingsWebDavSubtitle =>
      'Sync search history, browsing history, offline books, and answer cache';

  @override
  String get settingsAccountSessionsSubtitle =>
      'Scan to sign in, save account slots, and switch quickly';

  @override
  String get settingsSignOutSubtitle =>
      'Remove sign-in information from this device';

  @override
  String get settingsDiagnosticsOn =>
      'Enabled · manage and export network and performance logs';

  @override
  String get settingsDiagnosticsOff =>
      'Find API errors, loading failures, and performance issues';

  @override
  String get settingsUpdateSubtitle =>
      'Check, download, and install new versions securely';

  @override
  String get settingsRestoreDefaultsSubtitle =>
      'Your account will remain signed in';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchPlaceholder => 'Search Zhihu content';

  @override
  String get searchFilter => 'Filter';

  @override
  String get searchGeneral => 'General';

  @override
  String get searchRealtime => 'Live';

  @override
  String get searchUsers => 'Users';

  @override
  String get searchStories => 'Stories';

  @override
  String get searchArticles => 'Articles';

  @override
  String get searchVideos => 'Videos';

  @override
  String get searchTopics => 'Topics';

  @override
  String get searchColumns => 'Columns';

  @override
  String get searchKnowledge => 'Knowledge';

  @override
  String get searchIdeas => 'Ideas';

  @override
  String get searchCircles => 'Circles';

  @override
  String get searchPodcasts => 'Podcasts';

  @override
  String get searchHot => 'Hot searches';

  @override
  String get searchHistory => 'Search history';

  @override
  String get searchUnavailableTitle => 'Temporarily unavailable';

  @override
  String get searchUnavailableMessage =>
      'Anonymous content is temporarily unavailable. Try again later.';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get searchScope => 'Search scope';

  @override
  String get searchMoreScopes => 'Swipe to see more';

  @override
  String get searchOverview => 'Search overview';

  @override
  String get searchStartHint => 'Enter keywords to search';

  @override
  String get searchCurrentScope => 'Current scope';

  @override
  String get searchActiveFilters => 'Active filters';

  @override
  String get searchFilterType => 'Content type';

  @override
  String get searchFilterSort => 'Sort';

  @override
  String get searchFilterTime => 'Time range';

  @override
  String get commentAll => 'All comments';

  @override
  String commentCount(String count) {
    return '$count comments';
  }

  @override
  String get commentDefault => 'Default';

  @override
  String get commentLatest => 'Latest';

  @override
  String get commentInputPlaceholder => 'Be thoughtful and kind';

  @override
  String get commentReply => 'Reply to this comment';

  @override
  String get commentPublishReply => 'Post your reply';

  @override
  String get commentPublishComment => 'Post your comment';

  @override
  String commentReplyTo(String name) {
    return 'Reply to @$name';
  }

  @override
  String get commentMention => 'Mention user';

  @override
  String get commentCollapse => 'Collapse editor';

  @override
  String get commentExpand => 'Expand editor';

  @override
  String get commentImage => 'Image comment';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginAccount => 'Account';

  @override
  String get loginPhone => 'Phone';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginCode => 'Verification code';

  @override
  String get loginContinue => 'Agree and continue';

  @override
  String get loginCancel => 'Not now';

  @override
  String get loginScanSuccess => 'QR sign-in succeeded';

  @override
  String get detailReadAnswer => 'Write an answer';

  @override
  String get detailRefreshAnswers => 'Refresh answers';

  @override
  String get detailSearchBody => 'Search body';

  @override
  String get detailReadAloud => 'Read aloud';

  @override
  String get detailExportTxt => 'Export as TXT';

  @override
  String get detailExportMarkdown => 'Export as Markdown';

  @override
  String get detailExportHtml => 'Export as HTML';
}
