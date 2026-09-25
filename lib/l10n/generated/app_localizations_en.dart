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
  String get feedFollowingChoice => 'Featured';

  @override
  String get feedFollowingLatest => 'Latest';

  @override
  String get feedFollowingIdeas => 'Ideas';

  @override
  String get feedEmptyFollowing => 'No new content from followed accounts';

  @override
  String get feedEmptyHot => 'No hot-list content is available';

  @override
  String get feedEmptyRecommend => 'No recommended content is available';

  @override
  String get feedNextLoadFailed => 'Could not load more, tap to retry';

  @override
  String get feedAllShown => 'All available content is shown';

  @override
  String get feedLoadMore => 'Scroll down to load more';

  @override
  String get feedFollowingPeople => 'Following';

  @override
  String feedViewPersonRecent(String name) {
    return 'View recent content from $name';
  }

  @override
  String get feedDiscoverFriends => 'Discover people';

  @override
  String get feedFollowingSemantic => 'Following tab';

  @override
  String get feedSaltServiceFallback => 'Salt Select picks for you';

  @override
  String feedPersonRecentTitle(String name) {
    return '$name\'s recent activity';
  }

  @override
  String get feedPersonRecentEmpty => 'No public recent content';

  @override
  String get storyCategoriesTitle => 'Categories';

  @override
  String get storySearch => 'Search stories';

  @override
  String get storyLoadFailed => 'Story categories are unavailable';

  @override
  String get storyEmptyCategories => 'No story categories yet';

  @override
  String get storyBrowseByGenre => 'Browse stories by genre';

  @override
  String get storyFilterStories => 'Filter stories';

  @override
  String get storyFeaturedCategories => 'Featured categories';

  @override
  String get storyQuickFilter => 'Quick filter';

  @override
  String get storySort => 'Sort';

  @override
  String get storyAll => 'All';

  @override
  String get storyCategory => 'Category';

  @override
  String get storyTabStories => 'Stories';

  @override
  String get storyTabBooks => 'E-books';

  @override
  String get storyTabAssessments => 'Reviews';

  @override
  String get storyLong => 'Long form';

  @override
  String get storyShort => 'Short form';

  @override
  String get storyAudioBook => 'Audiobooks';

  @override
  String get storyFilter => 'Filter';

  @override
  String get storySortHot => 'Popular';

  @override
  String get storySortGood => 'Top rated';

  @override
  String get storySortNew => 'New';

  @override
  String get storyAllCategories => 'All categories';

  @override
  String get storyMaxTags => 'Select up to 5 tags';

  @override
  String get storyNoCategories => 'No categories';

  @override
  String get storyReset => 'Reset';

  @override
  String get storyConfirm => 'Confirm';

  @override
  String get storyViewAll => 'View all';

  @override
  String get storyEmptyCondition => 'No content matches these filters';

  @override
  String get storyCategoryFallback => 'Story category';

  @override
  String get storyEmptyCategory => 'No stories in this category';

  @override
  String get storyLongTitle => 'Long-form stories';

  @override
  String get storyEmptyLong => 'No long-form stories yet';

  @override
  String storyLikeCount(String count) {
    return '$count likes';
  }

  @override
  String get storyOngoing => 'Ongoing';

  @override
  String get storyFinished => 'Completed';

  @override
  String get storyFree => 'Free';

  @override
  String get storyVip => 'VIP';

  @override
  String get storyVipDiscount => 'VIP discount';

  @override
  String get storyType => 'Type';

  @override
  String get storyStatus => 'Status';

  @override
  String get storyRights => 'Access';

  @override
  String get storySectionHotTags => 'Popular tags';

  @override
  String get storySectionGenre => 'Genres';

  @override
  String get storySectionCharacters => 'Characters';

  @override
  String get storySectionPlot => 'Plot';

  @override
  String get storySectionMood => 'Mood';

  @override
  String get storySectionSetting => 'Setting';

  @override
  String get storyTypeAssessment => 'Reviews';

  @override
  String get storyMaxSelection => 'Select up to 5 tags';

  @override
  String get saltContinueReading => 'Continue reading';

  @override
  String get saltStartReading => 'Start reading';

  @override
  String get saltAdded => 'Added';

  @override
  String get saltAddToBookshelf => 'Add to bookshelf';

  @override
  String get saltChapterOrder => 'Chapter order';

  @override
  String get saltAscending => 'Ascending';

  @override
  String get saltDescending => 'Descending';

  @override
  String get saltChapter => 'Chapter';

  @override
  String get saltCatalogTitle => 'Table of contents';

  @override
  String saltChapterCount(int count) {
    return '$count chapters';
  }

  @override
  String get saltChapterDirectory => 'Chapter list';

  @override
  String saltProcessing(int index, int total, String title) {
    return 'Processing $index/$total · $title';
  }

  @override
  String get saltSelectAll => 'Select all';

  @override
  String get saltCancelSelectAll => 'Deselect all';

  @override
  String saltSelectedCount(int selected, int total) {
    return 'Selected $selected/$total';
  }

  @override
  String get saltDownloadingChapters => 'Downloading chapters';

  @override
  String saltExportChapters(String format, int count) {
    return 'Export $format · $count chapters';
  }

  @override
  String get saltDirectoryLoadFailed => 'Could not load chapters';

  @override
  String get saltNetworkRetry => 'Check your network and try again';

  @override
  String get saltDecodeFailed => 'The chapter could not be decoded. Try again.';

  @override
  String get saltDecodeParamsMissing =>
      'The chapter response is missing required decoding parameters. Try again.';

  @override
  String get saltDirectoryEmpty => 'No chapters in this list';

  @override
  String get saltCached => 'Cached';

  @override
  String get saltCommentsEmpty => 'No comments yet';

  @override
  String get saltBulletCommentsEmpty => 'No inline comments yet';

  @override
  String get saltReaderTopBar => 'Reader top bar';

  @override
  String get saltReaderBottomBar => 'Reader bottom bar';

  @override
  String get saltReadingTitle => 'Salt Select reader';

  @override
  String get saltMore => 'More';

  @override
  String get saltSettingsTitle => 'Reading settings';

  @override
  String get saltVerticalScroll => 'Vertical scroll';

  @override
  String get saltHorizontalPage => 'Horizontal pages';

  @override
  String get saltFontSize => 'Font size';

  @override
  String get saltLineSpacing => 'Line spacing';

  @override
  String get saltParagraphSpacing => 'Paragraph spacing';

  @override
  String get saltHorizontalMargins => 'Side margins';

  @override
  String get saltApply => 'Apply';

  @override
  String get saltChapterInfo => 'Chapter information';

  @override
  String get saltAuthor => 'Author';

  @override
  String get saltReadable => 'Readable';

  @override
  String get saltLocked => 'Locked';

  @override
  String get saltChapterLocked => 'Chapter locked';

  @override
  String get saltChapterReadable => 'Chapter available';

  @override
  String saltSectionLabel(int index) {
    return 'Section $index';
  }

  @override
  String saltSectionProgress(int index, int count) {
    return 'Section $index/$count';
  }

  @override
  String saltLikes(String count) {
    return '$count likes';
  }

  @override
  String saltComments(String count) {
    return '$count comments';
  }

  @override
  String get saltAudioAvailable => 'Audio';

  @override
  String get saltNoPermission => 'This account cannot read this content';

  @override
  String get saltReload => 'Reload';

  @override
  String get saltContentUnavailable => 'Chapter content is unavailable';

  @override
  String get saltPreviousChapter => 'Previous';

  @override
  String get saltNextChapter => 'Next';

  @override
  String get saltMetadataReady => 'Metadata ready';

  @override
  String get saltEntitlementPassed => 'Access granted';

  @override
  String get saltPayloadReady => 'Payload ready';

  @override
  String get saltBodyShown => 'Body displayed';

  @override
  String get saltWaitingBody => 'Waiting for body parsing';

  @override
  String get saltPayloadChars => 'payload characters';

  @override
  String get saltCodeChars => 'code characters';

  @override
  String get saltChapterBodyShown => 'Chapter body displayed';

  @override
  String get saltReadyDetail =>
      'Chapter metadata, bound payload, and full body are ready.';

  @override
  String get saltShelfTitle => 'Bookshelf';

  @override
  String get saltWorkFallback => 'Salt Select work';

  @override
  String get saltCategory => 'Categories';

  @override
  String get saltKnowledgeColumn => 'Knowledge columns';

  @override
  String get saltLocalShelfEmpty => 'The local bookshelf is empty';

  @override
  String get saltMoreActions => 'More actions';

  @override
  String get saltReadAloud => 'Read this chapter aloud';

  @override
  String get saltStopReading => 'Stop reading';

  @override
  String get saltReadAloudSubtitle => 'Use system speech to read this chapter';

  @override
  String saltExportChapter(String format) {
    return 'Export this chapter as $format';
  }

  @override
  String get saltExportTxt => 'Export TXT file';

  @override
  String get saltExportDocx => 'Export DOCX file';

  @override
  String saltReadingStarted(String title) {
    return 'Reading $title';
  }

  @override
  String get saltSpeechUnavailable =>
      'System speech is unavailable; install a speech package';

  @override
  String saltExportedTo(String location) {
    return 'Exported to $location';
  }

  @override
  String saltExportedAs(String format, String location) {
    return 'Exported as $format: $location';
  }

  @override
  String get saltExportFailed => 'Export failed. Try again.';

  @override
  String get saltCloudShelfUnavailable =>
      'Cloud bookshelf is temporarily unavailable';

  @override
  String get saltAccountSyncFailed => 'Account sync failed. Try again later.';

  @override
  String get saltStoryHomeLoadFailed => 'The Salt Select home is unavailable';

  @override
  String get saltStoryEntry => 'Entry';

  @override
  String get saltStoryModuleMustSee => 'Must see';

  @override
  String get saltStoryModuleTodayRead => 'Today\'s reading';

  @override
  String get saltStoryModuleEveryoneWatch => 'Everyone is reading';

  @override
  String get saltStoryModuleRecommended => 'Recommended for you';

  @override
  String get saltStoryBoard => 'Story rankings';

  @override
  String get saltStoryHotBoard => 'Popular';

  @override
  String get saltStoryReputationBoard => 'Top rated';

  @override
  String get saltStoryNewBoard => 'New releases';

  @override
  String get saltStoryLongBoard => 'Long-form';

  @override
  String saltStoryBoardNumber(int index) {
    return 'Ranking $index';
  }

  @override
  String get saltPillOnShelf => 'On bookshelf';

  @override
  String get saltPillLiked => 'Liked';

  @override
  String get saltBrandLong => 'Long-form';

  @override
  String saltScore(String score) {
    return 'Rating $score';
  }

  @override
  String saltUpdatedSections(int count) {
    return 'Updated $count sections';
  }

  @override
  String saltFinishedWithCount(int count) {
    return 'Completed · $count chapters';
  }

  @override
  String saltUpdatedTo(int index) {
    return 'Updated to section $index';
  }

  @override
  String get saltShelfLiked => 'Liked';

  @override
  String get saltShelfComments => 'Inline comments';

  @override
  String get saltShelfHistory => 'History';

  @override
  String get saltShelfLists => 'Lists';

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
  String get drawerOpen => 'Open sidebar';

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
  String get commonSelect => 'Select';

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
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLogs => 'Logs';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAppearanceSubtitle => 'Dark mode, language, and display';

  @override
  String get settingsPersonalizationSubtitle =>
      'Home, recommendations, and content';

  @override
  String get settingsBackupSubtitle => 'WebDAV data sync';

  @override
  String get settingsAccountSubtitle => 'Sessions and sign-in status';

  @override
  String get settingsLogsSubtitle => 'Diagnostics and troubleshooting';

  @override
  String get settingsOpenSourceLicenses => 'Open-source licenses';

  @override
  String get settingsOpenSourceLicensesSubtitle =>
      'View the open-source libraries and licenses used by the app';

  @override
  String get settingsAboutSubtitle => 'Defaults and app information';

  @override
  String get settingsUpdatesSubtitle => 'Check for and install new versions';

  @override
  String get settingsDataSubtitle => 'History, cache, and storage';

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
  String get settingsGithub => 'GitHub repository';

  @override
  String get settingsGithubSubtitle =>
      'View source code, issues, and release history';

  @override
  String get settingsGithubOpenFailed => 'Unable to open the GitHub repository';

  @override
  String get settingsOpenSourceLicensesIntro =>
      'The list below covers the open-source projects used directly by Zhiyue and their license information.';

  @override
  String get settingsOpenSourceLicenseOpenFailed =>
      'Unable to open the project link';

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
  String get searchFilterAnyType => 'Any type';

  @override
  String get searchFilterAnswers => 'Answers only';

  @override
  String get searchFilterArticles => 'Articles only';

  @override
  String get searchFilterVideos => 'Videos only';

  @override
  String get searchSortRelevance => 'Relevance';

  @override
  String get searchSortMostUpvoted => 'Most liked';

  @override
  String get searchSortNewest => 'Newest';

  @override
  String get searchTimeAny => 'Any time';

  @override
  String get searchTimeDay => 'Past day';

  @override
  String get searchTimeWeek => 'Past week';

  @override
  String get searchTimeMonth => 'Past month';

  @override
  String get searchTimeThreeMonths => 'Past 3 months';

  @override
  String get searchTimeHalfYear => 'Past 6 months';

  @override
  String get searchTimeYear => 'Past year';

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

  @override
  String get commonExitApp => 'Press back again to exit';

  @override
  String get commonEmoji => 'Emoji';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonOpenZhihu => 'Open Zhihu verification';

  @override
  String get commonExpired => 'Expired';

  @override
  String get commonReport => 'Report';

  @override
  String get commonUntitledContent => 'Untitled content';

  @override
  String get commonUntitledObject => 'Untitled item';

  @override
  String get commonAuthorProfile => 'View author profile';

  @override
  String get commonZhihuUser => 'Zhihu user';

  @override
  String get commonLike => 'Like';

  @override
  String get commonUnlike => 'Unlike';

  @override
  String get commonDislike => 'Dislike';

  @override
  String get commonDeleteComment => 'Delete comment';

  @override
  String get commonCommentActionFailed =>
      'Comment action failed. Try again later.';

  @override
  String get commonOpenLink => 'Open link';

  @override
  String commonReplyCount(String count) {
    return '$count replies';
  }

  @override
  String commonViewAllReplies(String count) {
    return 'View all $count replies';
  }

  @override
  String get drawerExpired => 'Expired';

  @override
  String get loginHeader => 'Sign in to Zhihu';

  @override
  String get loginQrSubtitle => 'Scan with the Zhihu app';

  @override
  String get loginPasswordSubtitle => 'Use your account and password';

  @override
  String get loginPhoneSubtitle => 'Sign in quickly with your phone';

  @override
  String get loginProgressPassword => 'Sign-in progress: account and password';

  @override
  String get loginProgressCode => 'Sign-in progress: verification code';

  @override
  String get loginProgressPhone => 'Sign-in progress: phone number';

  @override
  String get loginAgreementTitle => 'Before signing in';

  @override
  String get loginAgreementMessage =>
      'Read and agree to the Zhihu User Agreement and Privacy Policy to continue.';

  @override
  String get loginQrLoading => 'Getting QR code';

  @override
  String get loginQrInvalid => 'Zhihu did not return a valid QR code';

  @override
  String get loginQrScanHint => 'Open the Zhihu app and scan this code';

  @override
  String loginQrFetchFailed(String error) {
    return 'Could not get QR code: $error';
  }

  @override
  String get loginQrExpired => 'QR code expired. Tap refresh.';

  @override
  String get loginQrRiskControl =>
      'Complete the security check on Zhihu web, then refresh the QR code.';

  @override
  String get loginQrConfirm => 'Confirm sign-in in the Zhihu app';

  @override
  String get loginVerifying => 'Verifying sign-in';

  @override
  String get loginSuccess => 'Signed in';

  @override
  String get loginQrLabel => 'Zhihu sign-in QR code';

  @override
  String get loginRefreshQr => 'Refresh QR code';

  @override
  String get loginQrHint =>
      'Confirm sign-in on another device before the QR code expires. The account slot will be kept after success.';

  @override
  String get feedbackNotInterested => 'Not interested';

  @override
  String get feedbackReduceRecommendation =>
      'Show fewer recommendations like this';

  @override
  String get feedbackTitle => 'Show fewer like this';

  @override
  String get feedbackReduced => 'Fewer similar recommendations will be shown';

  @override
  String get feedbackInvalidReport => 'Invalid report address';

  @override
  String get feedbackMissingAction =>
      'This feedback item has no available action';

  @override
  String get feedbackLoading => 'Loading more feedback options…';

  @override
  String get feedbackReload => 'Reload';

  @override
  String get accountSessionCheckTitle => 'Confirm sign-in status';

  @override
  String get accountSessionCheckMessage =>
      'Zhihu reported an unusual account session. The current sign-in information is still stored on this device. Clear it?';

  @override
  String get accountSessionCheckDetails =>
      'After clearing, the latest session can still be restored from Settings > Accounts & multi-device sign-in. Permanent deletion requires another confirmation.';

  @override
  String get accountSessionClearKeepBackup => 'Clear and keep a recovery copy';

  @override
  String get accountSessionKeep => 'Keep signed-in state';

  @override
  String get settingsDisableSearchHistoryTitle => 'Turn off search history?';

  @override
  String get settingsDisableSearchHistoryMessage =>
      'Turning it off also clears existing search history on this device.';

  @override
  String get settingsDisableAndClear => 'Turn off and clear';

  @override
  String get settingsNoSearchHistoryMessage => 'There is no search history';

  @override
  String get settingsClearSearchHistoryTitle => 'Clear search history?';

  @override
  String get settingsClearSearchHistoryMessage =>
      'Only locally saved search terms will be deleted.';

  @override
  String get settingsSearchHistoryCleared => 'Search history cleared';

  @override
  String get settingsDisableBrowsingHistoryTitle =>
      'Turn off browsing history?';

  @override
  String get settingsDisableBrowsingHistoryMessage =>
      'Turning it off also clears browsing history saved on this device.';

  @override
  String get settingsNoBrowsingHistoryMessage => 'There is no browsing history';

  @override
  String get settingsClearBrowsingHistoryTitle => 'Clear browsing history?';

  @override
  String get settingsClearBrowsingHistoryMessage =>
      'Only the local index of opened content will be deleted.';

  @override
  String get settingsBrowsingHistoryCleared => 'Browsing history cleared';

  @override
  String get settingsClearOfflineTitle => 'Clear offline chapters?';

  @override
  String get settingsClearOfflineMessage =>
      'Cached salt-content chapters will be deleted and downloaded again when needed.';

  @override
  String get settingsClearOfflineAction => 'Clear';

  @override
  String settingsOfflineCleared(int count) {
    return 'Cleared $count offline chapters';
  }

  @override
  String get settingsOfflineClearFailed =>
      'Could not clear offline chapters. Try again.';

  @override
  String settingsCacheSummary(int count, String size) {
    return '$count images · $size MB';
  }

  @override
  String get commentEmoji => 'Emoji';

  @override
  String get commentRemoveSticker => 'Remove sticker';

  @override
  String get commentSelectedImage => 'Selected comment image';

  @override
  String get commentUploadingImage => 'Uploading image…';

  @override
  String get commentImageAdded => 'Image added';

  @override
  String get commentRemoveImage => 'Remove image';

  @override
  String get commentUsernameRequired => 'Enter a username to mention';

  @override
  String commentMentioned(String name) {
    return 'Mentioned $name';
  }

  @override
  String get commentLoadingGift => 'Loading gifts';

  @override
  String get commentNoGifts => 'No gifts available';

  @override
  String get commentImageAddedPending => 'Image added. Sign in to publish.';

  @override
  String get commentSignInRequired => 'Sign in before publishing';

  @override
  String get commentUploadSignInRequired => 'Sign in before publishing images';

  @override
  String get commentImageUploadNoUrl => 'Image upload returned no address';

  @override
  String commentImagesCount(int count) {
    return '$count comment images';
  }

  @override
  String get commentViewImage => 'View comment image';

  @override
  String get commentCloseImage => 'Close image';

  @override
  String get commentSaveImage => 'Save to photos';

  @override
  String commentSavedTo(String location) {
    return 'Saved to $location';
  }

  @override
  String get commentSaveFailed => 'Could not save the image. Try again later.';

  @override
  String get commentReportUnavailable => 'Reporting is not available yet';

  @override
  String get commentNoText => 'This comment has no text to display';

  @override
  String get commentAuthorBadge => 'Author';

  @override
  String get commentQuestionAuthor => 'Question author';

  @override
  String commentAuthorSemantics(String name) {
    return 'Comment author $name';
  }

  @override
  String get feedHotBadge => 'Hot';

  @override
  String metricVoteup(String count) {
    return '$count likes';
  }

  @override
  String metricFavorite(String count) {
    return '$count favorites';
  }

  @override
  String metricComment(String count) {
    return '$count comments';
  }

  @override
  String metricThanks(String count) {
    return '$count thanks';
  }

  @override
  String metricViews(String count) {
    return '$count views';
  }

  @override
  String get metricThanked => 'Thanked answer';

  @override
  String get metricFavorited => 'Saved answer';

  @override
  String metricFollowers(String count) {
    return '$count followers';
  }

  @override
  String metricAnswers(String count) {
    return '$count answers';
  }

  @override
  String metricArticles(String count) {
    return '$count articles';
  }

  @override
  String metricItems(String count) {
    return '$count items';
  }

  @override
  String get contentTypeAnswer => 'Answer';

  @override
  String get contentTypeArticle => 'Article';

  @override
  String get contentTypePeople => 'User';

  @override
  String get contentTypeQuestion => 'Question';

  @override
  String get contentTypeColumn => 'Column';

  @override
  String get contentTypeTopic => 'Topic';

  @override
  String get contentTypeIdea => 'Idea';

  @override
  String get contentTypeComment => 'Comment';

  @override
  String accountSwitchedTo(String name) {
    return 'Switched to $name';
  }

  @override
  String get accountSessionRestoreFailed =>
      'Account session verification failed. The previous sign-in state was restored.';

  @override
  String get collectionsLoginRequired =>
      'Sign in to Zhihu to view your collections';

  @override
  String get collectionsTitle => 'My collections';

  @override
  String get collectionTitle => 'Collection';

  @override
  String get collectionEmpty => 'This collection has no content yet';

  @override
  String get collectionsEmpty => 'You have not created or saved any content';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginQrSaveFailed =>
      'QR sign-in succeeded, but the account slot could not be saved. Try again later.';

  @override
  String get loginHumanVerification => 'Complete the human verification first';

  @override
  String get loginCodeSendFailed =>
      'Could not send the verification code. Try again later.';

  @override
  String get loginFailedNetwork =>
      'Sign-in failed. Check your network and try again.';

  @override
  String get loginFailedCredentials =>
      'Sign-in failed. Check your account and password and try again.';

  @override
  String get loginGetCode => 'Get code';

  @override
  String get loginContinueSignIn => 'Continue signing in';

  @override
  String get loginPasswordSignIn => 'Sign in with password';

  @override
  String get loginPhoneSignIn => 'Sign in with phone';

  @override
  String get loginQrSignIn => 'Sign in with QR code';

  @override
  String get loginAccountAppeal => 'Account appeal';

  @override
  String get loginAccountAppealHint =>
      'Having trouble? Submit an account appeal';

  @override
  String get loginPhonePlaceholder => 'Country/region code + phone';

  @override
  String get loginAccountPlaceholder => 'Phone / email';

  @override
  String get loginPasswordPlaceholder => 'Password';

  @override
  String get loginCodePlaceholder => 'Enter the 6-digit code';

  @override
  String loginCodeSent(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get loginChangePhone => 'Change phone number';

  @override
  String get loginNoCode => 'Didn\'t receive it?';

  @override
  String loginResendAfter(int seconds) {
    return 'Retry in ${seconds}s';
  }

  @override
  String get loginAgree => 'Agree';

  @override
  String get loginUserAgreement => 'Zhihu User Agreement';

  @override
  String get loginPrivacyPolicy => ' and Privacy Policy';

  @override
  String get commonSelected => ', selected';

  @override
  String get searchSuggestion => 'Search suggestions';

  @override
  String searchSuggestionFor(String query) {
    return 'Search suggestion $query';
  }

  @override
  String searchSearching(String query) {
    return 'Searching for “$query”';
  }

  @override
  String get searchDesktopHint =>
      'Scroll to load more results, then select a card to view details.';

  @override
  String get searchRelated => 'Related searches';

  @override
  String get searchRecentContent => 'Recent content';

  @override
  String get searchContinue => 'Continue searching';

  @override
  String get searchUntitledNovel => 'Untitled novel';

  @override
  String get searchUntitledVideo => 'Untitled video';

  @override
  String searchMetricFollows(String count) {
    return '$count follows';
  }

  @override
  String searchMetricQuestions(String count) {
    return '$count questions';
  }

  @override
  String searchMetricMembers(String count) {
    return '$count members';
  }

  @override
  String searchMetricDiscussions(String count) {
    return '$count discussions';
  }

  @override
  String searchMetricParticipants(String count) {
    return '$count participants';
  }

  @override
  String searchMetricLiveContent(String count) {
    return '$count live items';
  }

  @override
  String searchMetricPlayCount(String count) {
    return '$count plays';
  }

  @override
  String searchHotScoreWan(String value) {
    return '$value ten-thousand';
  }

  @override
  String get userTitle => 'Users';

  @override
  String get userProfileTitle => 'User profile';

  @override
  String get userFindTitle => 'Find a user';

  @override
  String get userFindSubtitle =>
      'Enter the user token from a profile link to view public profile and content lists';

  @override
  String get userIdHint => 'User ID';

  @override
  String get userViewProfile => 'View user profile';

  @override
  String get userContentRelations => 'Content and relationships';

  @override
  String get userEmpty => 'No users yet';

  @override
  String get userSignInToFollow => 'Sign in to follow users';

  @override
  String get userFollowed => 'Following';

  @override
  String get userFollow => '+ Follow';

  @override
  String userSearchHint(String name) {
    return 'Search content posted by $name';
  }

  @override
  String userSearchPrompt(String name) {
    return 'Search $name\'s answers, articles, and ideas';
  }

  @override
  String get userNoResults => 'No matching content';

  @override
  String get userLoadFailed => 'Unable to open the user profile';

  @override
  String get userInfo => 'User information';

  @override
  String get userFollowers => 'Followers';

  @override
  String get userFollowingPeople => 'Following';

  @override
  String get userAnswers => 'User answers';

  @override
  String get userArticles => 'User articles';

  @override
  String get userCreatedArticles => 'User-created articles';

  @override
  String get userContributedArticles => 'Contributed articles';

  @override
  String get userColumns => 'User columns';

  @override
  String get userFollowingColumns => 'Followed columns';

  @override
  String get userFollowingQuestions => 'Followed questions';

  @override
  String get userFollowingCollections => 'Followed collections';

  @override
  String get userFollowingTopics => 'Followed topics';

  @override
  String get userIdRequired => 'Enter a user ID';

  @override
  String get sessionTitle => 'Account';

  @override
  String get sessionSignInZhihu => 'Sign in to Zhihu';

  @override
  String get sessionPhoneLogin => 'Phone sign-in';

  @override
  String get sessionWebLogin => 'Web sign-in';

  @override
  String get sessionSaved => 'Sign-in information saved';

  @override
  String get sessionCleared => 'Sign-in information cleared';

  @override
  String get sessionImport => 'Import sign-in information';

  @override
  String get sessionShowSensitive => 'Temporarily show sensitive values';

  @override
  String get sessionHideSensitive => 'Hide sensitive values again';

  @override
  String get sessionAdvanced => 'Advanced settings';

  @override
  String get sessionOptionalCookie => 'Cookie (optional)';

  @override
  String get sessionOptionalMsId => 'X-MS-ID (optional)';

  @override
  String get sessionManualZse => 'Manual X-Zse-96';

  @override
  String get sessionSignTarget => 'Signing target';

  @override
  String get sessionOtherHeaders => 'Other headers';

  @override
  String get sessionSaving => 'Saving…';

  @override
  String get sessionSave => 'Save';

  @override
  String get sessionClear => 'Clear sign-in information';

  @override
  String get contentTypeContent => 'Content';

  @override
  String get userProfileSearchContent => 'Search this user’s content';

  @override
  String get userProfileCopyLink => 'Copy profile link';

  @override
  String get userProfileHomeTab => 'Home';

  @override
  String get userProfileCreationsTab => 'Creations';

  @override
  String get userProfileActivitiesTab => 'Activity';

  @override
  String get userProfileVoteupsTab => 'Upvoted';

  @override
  String get userProfileFollowersList => 'Followers';

  @override
  String get userProfileFollowingList => 'Following';

  @override
  String get userProfileLoginRequired => 'Sign in to use this feature';

  @override
  String get userProfileUnfollowTitle => 'Unfollow?';

  @override
  String userProfileUnfollowMessage(String name) {
    return 'You will no longer follow $name';
  }

  @override
  String get userProfileUnfollowAction => 'Unfollow';

  @override
  String get userProfileLinkCopied => 'Profile link copied';

  @override
  String userProfileIpLocation(String location) {
    return 'IP location: $location';
  }

  @override
  String get userProfileFollowers => 'Followers';

  @override
  String get userProfileFollowing => 'Following';

  @override
  String get userProfileUserAnswers => 'User answers';

  @override
  String get userProfileUserArticles => 'User articles';

  @override
  String get userProfileCreatedArticles => 'Created articles';

  @override
  String get userProfileUserCreatedArticles => 'User-created articles';

  @override
  String get userProfileContributedArticles => 'Contributed articles';

  @override
  String get userProfileUserContributedArticles => 'User-contributed articles';

  @override
  String get userProfileCreatedColumns => 'Created columns';

  @override
  String get userProfileUserColumns => 'User columns';

  @override
  String get userProfileFollowingColumns => 'Following columns';

  @override
  String get userProfileFollowingQuestions => 'Following questions';

  @override
  String get userProfileFollowingCollections => 'Following collections';

  @override
  String get userProfileFollowingTopics => 'Following topics';

  @override
  String get userProfileReceivedUpvotes => 'Upvotes received';

  @override
  String get userProfileReceivedThanks => 'Thanks received';

  @override
  String get userProfileReceivedFavorites => 'Saves received';

  @override
  String get userProfilePersonalInfo => 'Personal information';

  @override
  String get userProfileAchievements => 'Achievements';

  @override
  String get userProfilePublicCreations => 'Public creations';

  @override
  String get userProfileFollowingAndCollections => 'Following and collections';

  @override
  String get userProfileFollowingHidden =>
      'This user has hidden their following list';

  @override
  String get userProfileFollowedYou => 'Follows you';

  @override
  String get userProfileMutualFollow => 'Mutual follow';

  @override
  String get userProfileMessage => 'Message';

  @override
  String get userProfileNoPublicContent => 'No public content yet';

  @override
  String get webdavTitle => 'WebDAV sync';

  @override
  String get webdavIntroTitle => 'Sync local content across devices';

  @override
  String get webdavIntroMessage =>
      'Only search history, browsing history, Salt content, bookshelf items, and answer caches are synced. Sign-in credentials, cookies, device identifiers, and these settings are never uploaded.';

  @override
  String get webdavConnectionSettings => 'Connection settings';

  @override
  String get webdavProviderType => 'Service type';

  @override
  String get webdavProviderGeneric => 'Generic WebDAV';

  @override
  String get webdavProviderGoogle => 'Google Drive (WebDAV gateway)';

  @override
  String get webdavProviderOneDrive => 'Microsoft OneDrive (WebDAV)';

  @override
  String get webdavProviderGenericDescription =>
      'For WebDAV-compatible cloud drives, NAS devices, and self-hosted services.';

  @override
  String get webdavProviderGoogleDescription =>
      'Google Drive does not provide native WebDAV. Enter a WebDAV gateway connected to Google Drive.';

  @override
  String get webdavProviderOneDriveDescription =>
      'Enter a WebDAV-compatible OneDrive endpoint. Some accounts or services may restrict legacy endpoints.';

  @override
  String get webdavProviderGenericHint => 'https://dav.example.com/';

  @override
  String get webdavProviderGoogleHint => 'https://gateway.example.com/dav/';

  @override
  String get webdavProviderOneDriveHint => 'https://d.docs.live.net/<CID>/';

  @override
  String get webdavEndpoint => 'WebDAV address';

  @override
  String get webdavHttpsHint => 'HTTPS only; do not put a password in the URL';

  @override
  String get webdavRemoteDirectory => 'Remote directory';

  @override
  String get webdavRemoteDirectoryHint =>
      'v1, answers, and chapters subdirectories are created automatically';

  @override
  String get webdavAuthMethod => 'Authentication method';

  @override
  String get webdavAuthBasic => 'Username and password / app password';

  @override
  String get webdavAuthBearer => 'Bearer access token';

  @override
  String get webdavUsername => 'Username';

  @override
  String get webdavPasswordOrAppPassword => 'Password / app password';

  @override
  String get webdavAccessToken => 'Access token';

  @override
  String get webdavEnable => 'Enable WebDAV sync';

  @override
  String get webdavEnableSubtitle =>
      'Disabling stops network sync but keeps saved local settings';

  @override
  String get webdavStartupSync => 'Sync automatically at startup';

  @override
  String get webdavStartupSyncSubtitle =>
      'Runs in the background without blocking the first frame; retry manually after a failure';

  @override
  String get webdavSyncContent => 'Synced content';

  @override
  String get webdavSyncContentSummary =>
      '• Search and browsing history\n• Salt bookshelf and downloaded chapters\n• Answer caches (refresh manually after restoring to fetch the latest content)';

  @override
  String webdavStatus(String message) {
    return 'Status: $message';
  }

  @override
  String get webdavLoading => 'Loading WebDAV settings';

  @override
  String get webdavConfiguredStatus => 'WebDAV configured';

  @override
  String get webdavNotConfigured => 'WebDAV not configured';

  @override
  String get webdavSettingsSaved => 'WebDAV settings saved';

  @override
  String get webdavClosedStatus => 'WebDAV disabled';

  @override
  String get webdavTesting => 'Testing WebDAV connection';

  @override
  String get webdavSyncing =>
      'Syncing search history, browsing history, offline books, and answer cache';

  @override
  String webdavSyncCompleted(String uploaded, String downloaded) {
    return 'Sync complete: uploaded $uploaded, restored $downloaded';
  }

  @override
  String webdavConfigFailed(String error) {
    return 'WebDAV configuration is invalid: $error';
  }

  @override
  String get webdavSyncNotEnabled => 'WebDAV sync is disabled';

  @override
  String get webdavNotSynced => 'Not synced yet';

  @override
  String get webdavSyncNow => 'Sync now';

  @override
  String get webdavTestConnection => 'Test connection';

  @override
  String get webdavDisable => 'Turn off sync';

  @override
  String get webdavClearLocalSettings => 'Clear local settings and credentials';

  @override
  String webdavLoadFailed(String error) {
    return 'Could not read WebDAV settings: $error';
  }

  @override
  String webdavSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get webdavConnected => 'WebDAV connected';

  @override
  String webdavConnectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String webdavSyncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get webdavDisabled =>
      'WebDAV sync is off; credentials remain in the private local database';

  @override
  String get webdavClearTitle => 'Clear WebDAV settings?';

  @override
  String get webdavClearMessage =>
      'This removes the WebDAV address, account, and credentials saved locally without deleting remote sync data.';

  @override
  String get webdavCleared => 'Local WebDAV settings and credentials cleared';

  @override
  String webdavClearFailed(String error) {
    return 'Clear failed: $error';
  }

  @override
  String get webdavInvalidEndpoint => 'Invalid WebDAV address';

  @override
  String get webdavHttpsRequired => 'The WebDAV address must use HTTPS';

  @override
  String get webdavEndpointCredentials =>
      'The WebDAV address cannot include credentials, query parameters, or fragments';

  @override
  String get webdavCredentialCharacters =>
      'WebDAV credentials cannot contain line breaks or control characters';

  @override
  String get webdavInvalidDirectory => 'Invalid remote directory';

  @override
  String get webdavUsernameRequired =>
      'Username is required for password authentication';

  @override
  String get webdavSecretRequired =>
      'Enter a password, app password, or access token';

  @override
  String get webdavCredentialTooLong => 'The access credential is too long';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonSelectAll => 'Select all';

  @override
  String get detailDownvote => 'Downvote';

  @override
  String get detailDownvoted => 'Downvoted';

  @override
  String get detailCommentAction => 'Comment';

  @override
  String get detailViewComments => 'View comments';

  @override
  String detailViewCommentsCount(String count) {
    return 'View $count comments';
  }

  @override
  String get detailFavorite => 'Save';

  @override
  String detailFavoriteCount(String count) {
    return 'Save $count';
  }

  @override
  String get detailAuthor => 'Author';

  @override
  String get detailFollowed => 'Following';

  @override
  String get detailFollow => 'Follow';

  @override
  String get detailUnfollowAuthor => 'Unfollow author';

  @override
  String get detailFollowAuthor => 'Follow author';

  @override
  String get detailTop => 'Top';

  @override
  String get detailBackToTop => 'Back to top of post';

  @override
  String get detailBottom => 'Bottom';

  @override
  String get detailJumpToBottom => 'Jump to bottom of post';

  @override
  String get detailCollapseMore => 'Hide more actions';

  @override
  String get detailMoreActions => 'More actions';

  @override
  String get detailExportActions => 'Export content';

  @override
  String get detailSignInFromMe => 'Sign in from the Me page first.';

  @override
  String get detailWriteAnswerSubtitle =>
      'Create a new answer to this question';

  @override
  String detailRefreshContent(String content) {
    return 'Refresh $content';
  }

  @override
  String get detailRefreshSubtitle =>
      'Ignore the cache and fetch the latest content';

  @override
  String get detailSearchSubtitle => 'Enter a keyword to find it in the body';

  @override
  String detailReadAloudSubtitle(String content) {
    return 'Use system speech to read this $content';
  }

  @override
  String get detailExportTextSubtitle =>
      'Save the current title, author, and body';

  @override
  String detailExportDocument(String format) {
    return 'Export as $format';
  }

  @override
  String get detailExportPdfSubtitle =>
      'Create a document for sharing and printing';

  @override
  String get detailExportDocumentSubtitle =>
      'Keep the title, author, paragraphs, and body image links';

  @override
  String get detailCopyAll => 'Copy full text';

  @override
  String get detailCopySubtitle => 'Copy the current title, author, and body';

  @override
  String get detailClearCache => 'Clear this cache';

  @override
  String get detailInviteAnswer => 'Invite an answer';

  @override
  String get detailCopyAnswer => 'Copy answer content';

  @override
  String detailSelectionTooShort(int count) {
    return 'Select at least $count characters';
  }

  @override
  String get detailCommentSelection => 'Comment on this passage';

  @override
  String get detailCommentHint => 'Enter your comment';

  @override
  String detailActionUnavailable(String action) {
    return '$action is unavailable';
  }

  @override
  String get detailSignInRequired => 'Sign in to use this feature';

  @override
  String get detailUnfollowTitle => 'Unfollow?';

  @override
  String detailUnfollowMessage(String name) {
    return 'You will no longer follow $name';
  }

  @override
  String get detailUnfollowAction => 'Unfollow';

  @override
  String get detailCacheCleared => 'Answer cache cleared';

  @override
  String get detailImagePlaceholder => '[Image]';

  @override
  String get detailVideoPlaceholder => '[Video]';

  @override
  String detailImageCount(int count) {
    return '$count answer images';
  }

  @override
  String get detailViewImage => 'View original answer image';

  @override
  String get detailCloseImage => 'Close image';

  @override
  String get detailSaveImage => 'Save to photos';

  @override
  String get detailImageSaved => 'Image saved';

  @override
  String get detailImageSavedTo => 'Saved to photos';

  @override
  String get detailImageSaveFailed =>
      'Could not save the image. Try again later.';

  @override
  String get detailMyAnswer => 'My answer';

  @override
  String detailAuthorPrefix(String name) {
    return 'Author: $name';
  }

  @override
  String get detailNoExportableBody => 'This answer has no body to export';

  @override
  String get detailAnswerDetails => 'Answer details';

  @override
  String detailExportedTo(String location) {
    return 'Exported to $location';
  }

  @override
  String get detailExportFailed => 'Export failed. Try again.';

  @override
  String detailDocumentExported(String format, String location) {
    return 'Exported as $format: $location';
  }

  @override
  String get detailStoppedReading => 'Reading stopped';

  @override
  String get detailNoReadableBody => 'This answer has no body to read aloud';

  @override
  String get detailReading => 'Reading aloud';

  @override
  String get detailTtsUnavailable =>
      'System speech is unavailable. Install a speech voice package.';

  @override
  String get detailNoCopyableText => 'This answer has no text to copy';

  @override
  String get detailCopied => 'Full text copied';

  @override
  String get detailSearchBodyTitle => 'Search body';

  @override
  String get detailKeywordHint => 'Enter a keyword';

  @override
  String get detailLocate => 'Find';

  @override
  String detailBodyNotFound(String keyword) {
    return 'Could not find “$keyword” in the body';
  }

  @override
  String detailLocated(String keyword) {
    return 'Located at “$keyword”';
  }

  @override
  String get detailWriteAnswer => 'Write an answer';

  @override
  String get detailAnswerRequired => 'Answer content cannot be empty';

  @override
  String get detailAnswerPublished => 'Answer published';

  @override
  String get commentSentence => 'Sentence comments';

  @override
  String commentSentenceCount(String count) {
    return '$count sentence comments';
  }

  @override
  String get commentWrite => 'Write a comment';

  @override
  String commentReplyTitle(String target) {
    return 'Reply to $target';
  }

  @override
  String get commentReplyTargetComment => 'this comment';

  @override
  String get commentPublished => 'Comment published.';

  @override
  String get commentReplyPublished => 'Reply published.';

  @override
  String get commentDeleteTitle => 'Delete comment?';

  @override
  String get commentDeleteMessage =>
      'This comment and its current display relationship will be removed from the list.';

  @override
  String get commentDeleted => 'Comment deleted.';

  @override
  String get commentDeleteReplyTitle => 'Delete reply?';

  @override
  String get commentDeleteReplyMessage => 'This cannot be undone.';

  @override
  String get commentReplyDeleted => 'Reply deleted.';

  @override
  String get commentRepliesTitle => 'Comment replies';

  @override
  String get commentNoReplies => 'No replies yet';

  @override
  String get commentNoComments => 'No comments yet';

  @override
  String commentReplyCount(String count) {
    return '$count replies';
  }

  @override
  String get commentEditorUnavailable => 'Comments are temporarily unavailable';

  @override
  String get commentGif => 'GIF';

  @override
  String get commentExpandEditor => 'Expand editor';

  @override
  String get contentFilterClearTitle => 'Clear filtering statistics?';

  @override
  String get contentFilterClearMessage =>
      'Only local records will be deleted. Your Zhihu account and server feedback settings will not change.';

  @override
  String get contentFilterCleared => 'Filtering statistics cleared';

  @override
  String get contentFilterClearStats => 'Clear statistics';

  @override
  String get contentFilterStatsTitle => 'Content filtering statistics';

  @override
  String get contentFilterStatsLabel => 'Content filtering statistics';

  @override
  String get contentFilterActions => 'Feedback actions';

  @override
  String get contentFilterHidden => 'Hidden content';

  @override
  String get contentFilterReasons => 'Filtering reasons';

  @override
  String get contentFilterHint =>
      'Choose “See less of this” on a home card to accumulate counts by reason here.';

  @override
  String contentFilterCount(String count) {
    return '$count times';
  }

  @override
  String get contentFilterLatest => 'Most recent';

  @override
  String get contentFilterEmpty => 'No records';

  @override
  String get contentFilterSummaryEmpty =>
      'Track why content was reduced and what happened';

  @override
  String contentFilterSummary(String actions, String hidden, String reasons) {
    return '$actions actions · $hidden hidden · $reasons reasons';
  }

  @override
  String get accountSessionsNoCurrent =>
      'There is no current login session to save';

  @override
  String get accountSessionsSaved => 'Current login session saved';

  @override
  String get accountSessionsSaveFailed =>
      'Could not save the account slot. Try again later.';

  @override
  String accountSessionsSwitched(String name) {
    return 'Switched to $name';
  }

  @override
  String get accountSessionsSwitchFailed =>
      'Could not switch accounts. Try again later.';

  @override
  String get accountSessionsDeleteTitle => 'Delete account slot?';

  @override
  String accountSessionsDeleteActiveMessage(String name) {
    return 'Only the locally saved $name will be deleted. The current local session will be signed out and kept as a recoverable copy; other devices will not be signed out.';
  }

  @override
  String accountSessionsDeleteMessage(String name) {
    return 'Only the locally saved $name will be deleted. Other devices will not be signed out.';
  }

  @override
  String get accountSessionsDeleted => 'Local account slot deleted';

  @override
  String get accountSessionsDeleteFailed =>
      'Could not delete the account slot. Try again later.';

  @override
  String get accountSessionsNoRecovery => 'No account session can be recovered';

  @override
  String get accountSessionsRestored =>
      'The most recently cleared account session was restored';

  @override
  String get accountSessionsRestoreSaveFailed =>
      'The session was restored, but saving the account slot failed. Try again later.';

  @override
  String get accountSessionsPurgeTitle =>
      'Permanently clear recovery credentials?';

  @override
  String get accountSessionsPurgeMessage =>
      'This permanently deletes the recovery copy kept after the last cleanup. It cannot be recovered afterward.';

  @override
  String get accountSessionsPurgeAction => 'Delete permanently';

  @override
  String get accountSessionsPurged =>
      'Recovery credentials permanently deleted';

  @override
  String get accountSessionsPurgeFailed =>
      'Could not clear recovery credentials. Try again later.';

  @override
  String get accountSessionsTitle => 'Accounts and multi-device login';

  @override
  String get accountSessionsSaveCurrent => 'Save current session';

  @override
  String get accountSessionsIntro =>
      'Sessions created by QR-code or phone login are stored in a private local credential database. /people/self is verified before switching; other devices are not signed out.';

  @override
  String get accountSessionsRecoveryTitle =>
      'Recently cleared login information';

  @override
  String get accountSessionsRecoveryMessage =>
      'Accounts cleared after a server-expiration check remain in the local recovery area. You can restore or permanently delete them here.';

  @override
  String get accountSessionsRestore => 'Restore';

  @override
  String get accountSessionsEmptyTitle => 'No saved account slots';

  @override
  String get accountSessionsEmptyMessage =>
      'After signing in, manage multi-device sessions here.';

  @override
  String get accountSessionsQr => 'QR-code session';

  @override
  String get accountSessionsPassword => 'Phone/password session';

  @override
  String get accountSessionsCurrent => 'In use';

  @override
  String get accountSessionsExpired => 'Expired';

  @override
  String get accountSessionsMenu => 'Account actions';

  @override
  String get accountSessionsSwitch => 'Switch and verify';

  @override
  String get accountSessionsRemoveSlot => 'Delete slot';

  @override
  String get accountSessionsAdd => 'Add account / sign in with QR code';

  @override
  String get accountDefaultName => 'Zhihu account';

  @override
  String accountMaskedName(String id) {
    return 'Account $id';
  }

  @override
  String get browsingHistoryClearTitle => 'Clear browsing history?';

  @override
  String get browsingHistoryClearMessage =>
      'This only deletes browsing history stored locally by Zhiyue.';

  @override
  String get browsingHistoryTitle => 'Browsing history';

  @override
  String get browsingHistoryClear => 'Clear browsing history';

  @override
  String get browsingHistoryEmptyTitle => 'No browsing history';

  @override
  String get browsingHistoryEmptyMessage =>
      'Opened answers, articles, questions, or topics will appear here';

  @override
  String browsingHistoryToday(String time) {
    return 'Today $time';
  }

  @override
  String browsingHistoryDate(int month, int day, String time) {
    return '$month/$day $time';
  }

  @override
  String get updateCheckFailed =>
      'Could not check for updates. Try again later.';

  @override
  String get updateAllowInstallTitle => 'Allow app installation';

  @override
  String get updateAllowInstallMessage =>
      'Android needs permission for Zhiyue to install the downloaded update. Enable it, return here, and tap Download and install again.';

  @override
  String get updateOpenSettings => 'Open settings';

  @override
  String get updateCachedInstalling =>
      'Using the downloaded update and opening the Android installer';

  @override
  String get updateVerifiedInstalling =>
      'Update verified and opening the Android installer';

  @override
  String get updateInstallFailed => 'Update installation failed. Try again.';

  @override
  String get updateTitle => 'App updates';

  @override
  String get updateAppName => 'Zhiyue';

  @override
  String get updateReadingVersion => 'Reading version information';

  @override
  String updateCurrentVersion(String version, String code) {
    return 'Current version $version ($code)';
  }

  @override
  String get updateUnsupportedTitle => 'In-app installation is not supported';

  @override
  String get updateUnsupportedMessage =>
      'Secure downloads, verification, and the system installer are currently enabled only on Android.';

  @override
  String get updateCheckingTitle => 'Checking for updates';

  @override
  String get updateCheckingMessage =>
      'Reading the stable version from GitHub Releases.';

  @override
  String get updateLatestTitle => 'You\'re up to date';

  @override
  String get updateNoRelease =>
      'There is no published version on the stable channel.';

  @override
  String updateLatestVersion(String version, String code) {
    return 'The latest stable version is $version ($code).';
  }

  @override
  String get updateChecking => 'Checking';

  @override
  String get updateRecheck => 'Check again';

  @override
  String get updateSecurity => 'Update security';

  @override
  String get updateSecuritySourceTitle => 'GitHub Releases';

  @override
  String get updateSecuritySourceDetail =>
      'Only a correctly named stable arm64 APK from the specified GitHub repository is accepted.';

  @override
  String get updateSecurityIntegrityTitle => 'Integrity verification';

  @override
  String get updateSecurityIntegrityDetail =>
      'The GitHub-provided SHA-256 digest and file size are checked after download.';

  @override
  String get updateSecurityInstallerTitle => 'Use the system installer';

  @override
  String get updateSecurityInstallerDetail =>
      'The package name, version, and certificate continuity are checked before opening the Android installer.';

  @override
  String get updateImportant => 'Important update';

  @override
  String updateNewVersion(String version) {
    return 'New version $version';
  }

  @override
  String get updateImportantFound => 'Important update available';

  @override
  String get updatePublishedToReleases =>
      'A new version is available on GitHub Releases.';

  @override
  String get updateLater => 'Later';

  @override
  String get updateView => 'View update';

  @override
  String updateVersion(String version) {
    return 'Version $version';
  }

  @override
  String updateReleaseMeta(String size, String code) {
    return '$size APK · stable channel · build $code';
  }

  @override
  String get updateViewDetails => 'View update interface details';

  @override
  String get updateVerifiedManifest =>
      'Manifest, package size, and SHA-256 verified';

  @override
  String get updateReleaseId => 'Release ID';

  @override
  String get updatePublishedAt => 'Published';

  @override
  String get updateReleaseTag => 'Release tag';

  @override
  String get updatePackageType => 'Package type';

  @override
  String get updatePackageSha256 => 'APK SHA-256';

  @override
  String get updateManifestResponse => 'Manifest response';

  @override
  String updateDownloadProgress(String received, String total) {
    return 'Downloading APK $received / $total';
  }

  @override
  String get updateVerifyingPackage => 'Verifying package';

  @override
  String get updateContinueInstall => 'Continue installation';

  @override
  String get updateDownloadInstall => 'Download and install';

  @override
  String get updateValidation => 'Verified';

  @override
  String updateManifestSummary(String size) {
    return '$size manifest';
  }

  @override
  String get profileChange => 'Change';

  @override
  String get profileUserFallback => 'Zhihu user';

  @override
  String get profileAnswers => 'Answers';

  @override
  String get profileArticles => 'Articles';

  @override
  String get profileIdeas => 'Ideas';

  @override
  String get profileCollections => 'Collections';

  @override
  String get profileUpvotes => 'Upvotes';

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileAllDetails => 'All details';

  @override
  String get profileMyContent => 'My content';

  @override
  String get profileMyAnswers => 'My answers';

  @override
  String get profileMyArticles => 'My articles';

  @override
  String get profileMyIdeas => 'My ideas';

  @override
  String get profileMyCollections => 'My collections';

  @override
  String get profileIdeasTab => 'Ideas';

  @override
  String get profileCreationTab => 'Created';

  @override
  String get profileActivityTab => 'Activity';

  @override
  String get profileVoteupTab => 'Upvoted';

  @override
  String get profilePublicActivitiesEmpty => 'No public activity yet';

  @override
  String get profilePublicVoteupsEmpty => 'No public upvotes yet';

  @override
  String get profileVipSalt => 'Salt Select member';

  @override
  String get profileVipZhihu => 'Zhihu member';

  @override
  String get profileMetricWan => ' ten-thousand';

  @override
  String get profileMetricYi => ' hundred-million';

  @override
  String profileMetricItems(String count) {
    return '$count items';
  }

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderUnspecified => 'Not specified';

  @override
  String get profileJustJoined => 'Just joined';

  @override
  String profileAgeDays(int count) {
    return '$count days';
  }

  @override
  String profileAgeMonthsDays(int months, int days) {
    return '$months months $days days';
  }

  @override
  String profileAgeYearsMonths(int years, int months) {
    return '$years years $months months';
  }

  @override
  String get profileBasicInfo => 'Basic information';

  @override
  String get profileUsername => 'Username';

  @override
  String get profileAccountAge => 'Account age';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileBirthday => 'Birthday';

  @override
  String get profileLocation => 'Location';

  @override
  String get profileVerification => 'Verification';

  @override
  String get profileManageVerification => 'Manage verification';

  @override
  String get profileUnverified => 'Not verified';

  @override
  String get profileInfluence => 'Influence';

  @override
  String get profileBadges => 'My badges';

  @override
  String get profileLikes => 'Likes received';

  @override
  String get profileNone => 'None';

  @override
  String profileCountPieces(int count) {
    return '$count';
  }

  @override
  String profileCountTimes(int count) {
    return '$count times';
  }

  @override
  String get profileFriendImpression => 'How friends see me';

  @override
  String get profileImproveImage =>
      'Complete your Zhihu profile to get more followers';

  @override
  String get profileAddKeywords => 'Add profile keywords';

  @override
  String get profileLinkCopied => 'Profile link copied';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileLoadFailed => 'Could not load profile';

  @override
  String get profileNetworkRetry => 'Check your network and try again';

  @override
  String get profileOpenDrawer => 'Open navigation drawer';

  @override
  String get profileFindUser => 'Find users';

  @override
  String get profileCopyHomeLink => 'Copy profile link';

  @override
  String get profileUsernameEmpty => 'Username cannot be empty';

  @override
  String get profileFieldTooLong => 'Username, headline, or bio is too long';

  @override
  String get profileImageUploadNoUrl => 'Image upload returned no address';

  @override
  String get profileCoverUploadNoHash => 'Cover upload returned no image hash';

  @override
  String get profileCoverUpdated => 'Cover updated';

  @override
  String get profileAvatarUpdated => 'Avatar updated';

  @override
  String get profileAddEmployment => 'Add work experience';

  @override
  String get profileCompanyOrOrganization => 'Company or organization';

  @override
  String get profileJob => 'Role';

  @override
  String get profileAddEducation => 'Add education';

  @override
  String get profileSchool => 'School';

  @override
  String get profileMajor => 'Major';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileSaving => 'Saving';

  @override
  String get profileInfoNotice =>
      'This information appears on your profile and helps with recommendations';

  @override
  String get profileAvatar => 'Avatar';

  @override
  String get profileCover => 'Profile cover';

  @override
  String get profileHeadline => 'Headline';

  @override
  String get profileHeadlinePlaceholder => 'Describe your work or interests';

  @override
  String get profileBirthdayPlaceholder => 'Enter your birthday';

  @override
  String get profileLocationPlaceholder => 'Enter your location';

  @override
  String get profileIndustry => 'Industry';

  @override
  String get profileIndustryPlaceholder => 'Choose an industry';

  @override
  String get profileEmployment => 'Work experience';

  @override
  String get profileEducation => 'Education';

  @override
  String get profilePersonalVerification => 'Personal verification';

  @override
  String get profileAddVerification => 'Add personal verification';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileBioPlaceholder => 'Introduce yourself in a few words';

  @override
  String get notificationCommentCategory => 'Comments, reposts & mentions';

  @override
  String get notificationLikeCategory => 'Likes';

  @override
  String get notificationFavoriteCategory => 'Favorites';

  @override
  String get notificationFollowCategory => 'Follows & subscriptions';

  @override
  String get notificationInvite => 'Answer invitations';

  @override
  String get notificationMarkedRead => 'Messages marked as read';

  @override
  String get notificationTitle => 'Messages';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get notificationMarkAllRead => 'Mark all as read';

  @override
  String get notificationLoadFailed => 'Could not load messages';

  @override
  String notificationInvitePending(String count) {
    return '$count pending invitations';
  }

  @override
  String get notificationInviteView => 'View questions inviting you to answer';

  @override
  String get notificationCategoryEmpty => 'No notifications of this type';

  @override
  String get notificationCategoryMarkedRead =>
      'This category was marked as read';

  @override
  String get notificationSettingsTitle => 'Notification settings';

  @override
  String get notificationSettingsSection =>
      'Interactions and content notifications';

  @override
  String get notificationAll => 'All';

  @override
  String get notificationLoginTitle => 'Sign in to view messages';

  @override
  String get notificationLoginMessage =>
      'Message notifications belong to your Zhihu account';

  @override
  String get notificationBackLogin => 'Back to sign in';

  @override
  String get messageTitle => 'Direct message';

  @override
  String get messageLoadFailed => 'Could not load direct messages';

  @override
  String get messageComposeHint => 'Send a direct message';

  @override
  String get messageSend => 'Send';

  @override
  String get notificationSettingCommentMe => 'Someone commented on me';

  @override
  String get notificationSettingMentionMe => 'Someone mentioned me';

  @override
  String get notificationSettingAnswerVoteup => 'Someone liked my answer';

  @override
  String get notificationSettingContentVoteup => 'Someone liked my content';

  @override
  String get notificationSettingAnswerThanks => 'Someone thanked my answer';

  @override
  String get notificationSettingRepin => 'Someone favorited my content';

  @override
  String get notificationSettingReaction => 'Someone reacted to my content';

  @override
  String get notificationSettingMemberFollow => 'Someone followed me';

  @override
  String get notificationSettingFavlistFollow =>
      'Someone followed my favorites';

  @override
  String get notificationSettingColumnFollow => 'Someone followed my column';

  @override
  String get notificationSettingQuestionAnswered =>
      'A followed question has a new answer';

  @override
  String get notificationSettingAnswerQuestion =>
      'Someone answered my question';

  @override
  String get notificationSettingQuestionInvite =>
      'Someone invited me to answer';

  @override
  String get notificationSettingColumnUpdate => 'A followed column was updated';

  @override
  String get notificationSettingMemberActivity =>
      'A followed person has new activity';

  @override
  String get notificationSettingSpecialUpdate =>
      'A followed topic has an update';

  @override
  String get notificationSettingMessage => 'Received a direct message';

  @override
  String get notificationSettingStrangerMessage =>
      'Direct message from a stranger';

  @override
  String get notificationSettingCoupon => 'Offers and benefits';

  @override
  String get notificationSettingBoughtContent => 'Purchased content updates';

  @override
  String get notificationSettingEbook => 'New e-books';

  @override
  String get notificationSettingArticleInvite =>
      'Invitations to create articles';

  @override
  String get notificationSettingTipjar => 'Article tip received';

  @override
  String get creationAll => 'All';

  @override
  String creationAnswers(String count) {
    return 'Answers $count';
  }

  @override
  String creationIdeas(String count) {
    return 'Ideas $count';
  }

  @override
  String creationArticles(String count) {
    return 'Articles $count';
  }

  @override
  String creationColumns(String count) {
    return 'Columns $count';
  }

  @override
  String creationQuestions(String count) {
    return 'Questions $count';
  }

  @override
  String creationVideos(String count) {
    return 'Videos $count';
  }

  @override
  String get creationMore => 'More';

  @override
  String get creationEmpty => 'No published content';

  @override
  String get creationFavorites => 'My favorites';

  @override
  String get creationHighlights => 'My highlights';

  @override
  String get creationFollowingColumns => 'Followed columns';

  @override
  String get creationFollowingTopics => 'Followed topics';

  @override
  String get creationFollowingCollections => 'Followed collections';

  @override
  String get creationFollowingQuestions => 'Followed questions';

  @override
  String get activityShare => 'Share';

  @override
  String get activityDelete => 'Delete this activity';

  @override
  String get activityLinkCopied => 'Link copied';

  @override
  String get activityDeleteTitle => 'Delete this activity?';

  @override
  String get activityDeleteMessage => 'This cannot be undone.';

  @override
  String get activityDeleted => 'Activity deleted';

  @override
  String get questionIdUnavailable =>
      'The question ID is unavailable. Refresh and try again.';

  @override
  String get questionFollowed => 'Question followed';

  @override
  String get questionUnfollowed => 'Question unfollowed';

  @override
  String get questionAnswerPublishedRefreshing =>
      'Answer published. Refreshing the list.';

  @override
  String get questionDeleteTitle => 'Delete answer?';

  @override
  String get questionDeleteMessage => 'This cannot be undone.';

  @override
  String get questionDeleted => 'Answer deleted.';

  @override
  String get questionAnswersTitle => 'All answers';

  @override
  String get questionSearchAnswers => 'Search answers';

  @override
  String get questionMore => 'More';

  @override
  String get questionLoginToWrite => 'Sign in to write an answer';

  @override
  String get questionUnfollow => 'Unfollow question';

  @override
  String get questionFollow => 'Follow question';

  @override
  String get questionAnswerRefresh => 'Refresh answers';

  @override
  String get questionCollapseDetails => 'Collapse question details';

  @override
  String get questionExpandDetails => 'Expand question details';

  @override
  String get questionCollapse => 'Collapse';

  @override
  String get questionExpandFull => 'Expand full text';

  @override
  String questionOpenTopic(String name) {
    return 'Open topic $name';
  }

  @override
  String questionAllContentCount(String count) {
    return 'All content $count';
  }

  @override
  String get questionSortDefault => 'Default';

  @override
  String get questionSortLatest => 'Latest';

  @override
  String get questionSortSemantic => 'Answer order: ';

  @override
  String questionAuthor(String name) {
    return 'Question author $name';
  }

  @override
  String get questionAuthorBadge => 'Question author';

  @override
  String get questionViewImage => 'View original question image';

  @override
  String get topicFollowersTitle => 'Topic followers';

  @override
  String get topicUnansweredTitle => 'Unanswered questions in this topic';

  @override
  String topicFallbackTitle(String id) {
    return 'Topic $id';
  }

  @override
  String get topicRefresh => 'Refresh topic details';

  @override
  String get topicLabel => 'Topic';

  @override
  String topicFollowers(String count) {
    return '$count followers';
  }

  @override
  String topicQuestions(String count) {
    return '$count questions';
  }

  @override
  String topicAnswers(String count) {
    return '$count answers';
  }

  @override
  String topicDiscussions(String count) {
    return '$count discussions';
  }

  @override
  String get topicBasicUnavailable =>
      'Topic details are unavailable, but the featured feed can still be browsed.';

  @override
  String get topicFollowersButton => 'Followers';

  @override
  String get topicUnansweredButton => 'Unanswered';

  @override
  String get zvideoTitle => 'Video';

  @override
  String get zvideoCommentsUnavailable => 'Comments';

  @override
  String zvideoActionUnavailable(String action) {
    return '$action is not available yet';
  }

  @override
  String get zvideoLoadFailed => 'The video is temporarily unavailable';

  @override
  String zvideoFallbackTitle(String id) {
    return 'Video #$id';
  }

  @override
  String get zvideoViewComments => 'View comments';

  @override
  String zvideoViewCommentsCount(String count) {
    return 'View $count comments';
  }

  @override
  String get zvideoMissing => 'No playable video information was received';

  @override
  String get zvideoVoteup => 'Upvote';

  @override
  String get zvideoComment => 'Comments';

  @override
  String get zvideoFavorite => 'Save';

  @override
  String get zvideoShare => 'Share';

  @override
  String get zvideoVoteupSemantic => 'Upvote video';

  @override
  String get zvideoCommentsSemantic => 'View video comments';

  @override
  String get zvideoFavoriteSemantic => 'Save video';

  @override
  String get zvideoShareSemantic => 'Share video';

  @override
  String get inlineVideoPlatformUnsupported =>
      'Inline video playback is not supported on this platform';

  @override
  String get inlineVideoLoadFailed =>
      'The video could not be played. Try again later.';

  @override
  String get inlineVideoInterruptedRetry =>
      'Video playback was interrupted. Tap to retry.';

  @override
  String get inlineVideoSwitchingLine =>
      'Playback interrupted. Switching to another source…';

  @override
  String get inlineVideoPaidNoAccess =>
      'Premium video · This account cannot watch it';

  @override
  String get inlineVideoUnavailable => 'Video playback is unavailable';

  @override
  String get inlineVideoPrivacyUnavailable =>
      'Privacy-restricted video playback is not supported on this platform';

  @override
  String get inlineVideoPlay => 'Play video';

  @override
  String inlineVideoPlayTitle(String title) {
    return 'Play video: $title';
  }

  @override
  String get inlineVideoFullscreen => 'Full screen';

  @override
  String get inlineVideoStopped => 'Video stopped or switching sources';

  @override
  String get inlineVideoBack => 'Back';

  @override
  String get answerSwitchRelease => 'Release to switch';

  @override
  String get answerSwitchPreviousHint =>
      'Keep pulling down to view the previous answer';

  @override
  String get answerSwitchNextHint => 'Keep swiping up to view the next answer';

  @override
  String answerSwitchTo(String author) {
    return 'Release to switch to $author\'s answer';
  }

  @override
  String get answerPrevious => 'previous';

  @override
  String get answerNext => 'next';

  @override
  String get detailWriteAnswerLogin => 'Sign in to write an answer';

  @override
  String saltDownloadedProgress(int downloaded, int total) {
    return '$downloaded/$total downloaded';
  }

  @override
  String saltDownloadedSections(int count) {
    return '$count sections downloaded';
  }

  @override
  String get saltAudio => 'Premium audio';

  @override
  String get saltVideo => 'Premium video';

  @override
  String get saltStory => 'Premium story';

  @override
  String get saltLimitedFree => 'Limited-time free';

  @override
  String get saltUntitledContent => 'Untitled premium content';

  @override
  String saltLikeCount(String count) {
    return 'Likes $count';
  }

  @override
  String saltCommentCount(String count) {
    return 'Comments $count';
  }

  @override
  String saltWordCount(String count) {
    return '$count words';
  }

  @override
  String saltReadCount(String count) {
    return 'Views $count';
  }

  @override
  String saltFavoriteCount(String count) {
    return 'Favorites $count';
  }

  @override
  String get saltPlayable => 'Playable';

  @override
  String get saltSupportsAudio => 'Audio available';

  @override
  String get saltFree => 'Free';

  @override
  String get saltTrial => 'Preview';

  @override
  String get saltMember => 'Premium member';

  @override
  String get saltEntitlementRequired => 'Requires entitlement';

  @override
  String get saltLastRead => 'Last read';

  @override
  String get saltReadFinished => 'Finished';

  @override
  String get saltUntitledChapter => 'Untitled chapter';

  @override
  String get saltResourceAudio => 'Audio';

  @override
  String get saltResourceVideo => 'Video';

  @override
  String get saltResourceSlide => 'Slides';

  @override
  String get saltResourceText => 'Text';

  @override
  String saltReadPercent(int percent) {
    return 'Read $percent%';
  }

  @override
  String saltCommentBadge(int count) {
    return 'View $count inline comments';
  }

  @override
  String followMoreAnswers(int count) {
    return 'Also liked $count answers';
  }

  @override
  String get brandZhihu => 'Zhihu';

  @override
  String detailQuestionAnswerCount(String count) {
    return '$count answers';
  }

  @override
  String detailQuestionFollowerCount(String count) {
    return '$count followers';
  }

  @override
  String get detailQuestionAnswersSemantic =>
      'View all answers to this question';

  @override
  String detailQuestionFallback(String id) {
    return 'Question #$id';
  }

  @override
  String get questionInviteTitle => 'Invite answers';

  @override
  String get questionInviteEmpty => 'No recommended invitees';

  @override
  String get questionInviteInvited => 'Invited';

  @override
  String get questionInviteAction => 'Invite';

  @override
  String get routingSafetyTitle => 'Safety notice';

  @override
  String get routingLeaveZhihu => 'You\'re about to leave Zhihu';

  @override
  String get routingExternalWarning =>
      'This link is not an official Zhihu page. Protect your account, privacy, and property.';

  @override
  String get routingConfirmVisit => 'Continue';

  @override
  String get routingOpenVerification => 'Open Zhihu verification';

  @override
  String get webSafetyTitle => 'Security verification';

  @override
  String get webPageLoadFailedNetwork =>
      'Could not load the page. Check your network and try again.';

  @override
  String get webPageUnavailable =>
      'This page is temporarily unavailable. Try again later.';

  @override
  String get webSessionSyncFailed =>
      'Could not sync the sign-in state. Sign in again and retry.';

  @override
  String get webLoginExpired =>
      'The web sign-in session expired. Sign in again and retry.';

  @override
  String get webSystemBrowserUnavailable => 'Could not open the system browser';

  @override
  String get webContinueInBrowser => 'Continue in a browser';

  @override
  String get webDesktopSystemBrowser =>
      'Desktop platforms use the system browser';

  @override
  String get webOpenBrowser => 'Open browser';

  @override
  String get webOpeningChapter => 'Opening chapter';

  @override
  String get webOpeningPage => 'Opening page';

  @override
  String get webOpenInBrowser => 'Open in browser';

  @override
  String get webChapterReading => 'Chapter reading';

  @override
  String get routingCannotOpen => 'Unable to open this for now.';

  @override
  String get routingCannotViewComments => 'Unable to view comments for now.';

  @override
  String get routingUnsupportedAction =>
      'This action is not supported for the current content.';

  @override
  String get routingPinDownvoteUnavailable => 'Ideas do not support downvotes.';

  @override
  String get routingDownvoteCancelled => 'Downvote removed.';

  @override
  String get routingDownvoted => 'Downvoted.';

  @override
  String get routingVoteCancelled => 'Like removed.';

  @override
  String get routingVoted => 'Liked.';

  @override
  String get routingFavoriteRemoved => 'Removed from favorites.';

  @override
  String get routingFavorited => 'Added to the default favorites.';

  @override
  String get objectDetailTitle => 'Content details';

  @override
  String get objectImages => 'Images';

  @override
  String get objectContent => 'Content';

  @override
  String get contentTypeCollection => 'Collection';

  @override
  String columnFallbackTitle(String token) {
    return 'Column $token';
  }

  @override
  String get columnFollowersTitle => 'Column followers';

  @override
  String get columnLoadFailed => 'Column information is not available.';

  @override
  String get columnRetry => 'Retry column information';

  @override
  String get columnTitle => 'Column';

  @override
  String columnArticleCount(String count) {
    return '$count articles';
  }

  @override
  String columnFollowerCount(String count) {
    return '$count followers';
  }

  @override
  String columnContributionCount(String count) {
    return '$count submissions';
  }

  @override
  String columnVoteupCount(String count) {
    return '$count likes';
  }

  @override
  String columnAuthorPrefix(String name) {
    return 'Author $name';
  }

  @override
  String get columnFollowers => 'Followers';

  @override
  String get columnAuthorProfile => 'Author profile';

  @override
  String get detailContentIncomplete => 'Content may be incomplete';

  @override
  String get detailPaidUnlocked =>
      'Premium content is unlocked for this account. The complete readable body follows.';

  @override
  String get detailPaidLocked =>
      'This is premium content, but the body returned for this account is still locked.';

  @override
  String get detailRelatedLoadFailed =>
      'Could not load other answers. Tap to retry';

  @override
  String get detailViewCommentsButton => 'View comments';

  @override
  String get detailContentInfo => 'Content information';

  @override
  String get detailReadingHint =>
      'The main content column is width-limited so interaction data stays available while you scroll.';

  @override
  String get blockedKeywordsTitle => 'Blocked keywords';

  @override
  String blockedKeywordsInvalidLength(int min, int max) {
    return 'Keywords must be $min–$max characters';
  }

  @override
  String get blockedKeywordsExists => 'That keyword already exists';

  @override
  String blockedKeywordsLimit(int max) {
    return 'You can set up to $max keywords';
  }

  @override
  String get blockedKeywordsDescription =>
      'Recommendations containing these keywords will be reduced';

  @override
  String blockedKeywordsCount(int current, int max) {
    return '$current/$max set';
  }

  @override
  String blockedKeywordsHint(int min, int max) {
    return '$min–$max characters';
  }

  @override
  String get blockedKeywordsAdd => 'Add keyword';

  @override
  String get blockedKeywordsEmpty => 'No blocked keywords';

  @override
  String blockedKeywordsDelete(String keyword) {
    return 'Delete $keyword';
  }

  @override
  String get recommendationClearTitle => 'Clear local recommendation profile?';

  @override
  String get recommendationClearMessage =>
      'Only local records will be deleted. Your Zhihu account and server recommendations will not change.';

  @override
  String get recommendationCleared => 'Local recommendation profile cleared';

  @override
  String get recommendationTitle => 'Local recommendation behavior';

  @override
  String get recommendationClearSemantic => 'Clear local profile';

  @override
  String get recommendationEmptyTitle => 'No local behavior yet';

  @override
  String get recommendationProfileTitle => 'Local recommendation profile';

  @override
  String get recommendationEmptyMessage =>
      'After opening recommendations or choosing Not interested, Zhiyue records limited interest signals locally.';

  @override
  String recommendationSummary(int total, int opened, int feedback) {
    return '$total signals · $opened opened · $feedback feedback';
  }

  @override
  String get recommendationTopics => 'Common interests';

  @override
  String get recommendationAuthors => 'Common authors';

  @override
  String get recommendationPrivacy =>
      'Data stays on this device and is used for local or hybrid recommendation ranking; behavior details are not uploaded.';

  @override
  String get discoverColumns => 'Column recommendations';

  @override
  String get discoverTopics => 'Topic categories';

  @override
  String get discoverHotTopics => 'Hot topics';

  @override
  String get discoverHotTopicsEmpty => 'No hot topics right now';

  @override
  String get discoverContentIdInvalid => 'Content ID must be 1–32 digits';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverColumnsAndTopics => 'Columns and topics';

  @override
  String get discoverColumnsSubtitle =>
      'Editor\'s picks and popular column articles';

  @override
  String get discoverTopicsSubtitle => 'Browse topics by category';

  @override
  String get discoverHotTopicsSubtitle => 'Current popular discussions';

  @override
  String get discoverOpenById => 'Open content by ID';

  @override
  String get discoverTypeAnswer => 'Answer';

  @override
  String get discoverTypeArticle => 'Article';

  @override
  String get discoverTypeIdea => 'Idea';

  @override
  String get discoverIdHint => 'Enter content ID';

  @override
  String get discoverOpenDetails => 'Open details';

  @override
  String get pagedEnd => 'You\'ve reached the end';

  @override
  String get pagedEmpty => 'No content yet';

  @override
  String get diagnosticExported => 'Log JSON copied to clipboard';

  @override
  String get diagnosticEmpty => 'No logs yet';

  @override
  String get diagnosticClearTitle => 'Clear diagnostic logs?';

  @override
  String get diagnosticClearMessage =>
      'Only diagnostic records stored locally will be deleted. Accounts and content caches are not affected.';

  @override
  String get diagnosticCleared => 'Diagnostic logs cleared';

  @override
  String get diagnosticTitle => 'Diagnostic logs';

  @override
  String get diagnosticExport => 'Export logs';

  @override
  String get diagnosticClear => 'Clear logs';

  @override
  String get diagnosticPurpose =>
      'Used to investigate deleted content, API failures, and performance issues';

  @override
  String get diagnosticPrivacy =>
      'Authentication expiration, recovery, and cleanup decisions are logged by default. Other diagnostics can be enabled separately. Only redacted state is stored; cookies, tokens, body text, and images are not stored.';

  @override
  String get diagnosticLocalEnabled => 'Enable local logs';

  @override
  String get diagnosticLocalSubtitle =>
      'Keep the latest 600 diagnostic records';

  @override
  String get diagnosticAuthEnabled => 'Authentication logs';

  @override
  String get diagnosticAuthSubtitle =>
      'Record login expiration, recovery, retention, and cleanup decisions; enabled by default';

  @override
  String get diagnosticNetworkEnabled => 'Network request logs';

  @override
  String get diagnosticNetworkSubtitle =>
      'Record API paths, HTTP status, business codes, and durations';

  @override
  String get diagnosticPerformanceEnabled => 'Performance logs';

  @override
  String get diagnosticPerformanceSubtitle =>
      'Record request durations to help find dropped frames and slow requests';

  @override
  String diagnosticInstallSummary(String id, int count) {
    return 'Device ID $id · $count entries';
  }

  @override
  String get diagnosticEmptyTitle => 'No diagnostic logs';

  @override
  String get diagnosticEmptyMessage =>
      'Enable local logs and perform the action again. Errors and network status will appear here.';

  @override
  String get diagnosticNoDetails => 'No additional information';

  @override
  String get diagnosticLevelDebug => 'Debug';

  @override
  String get diagnosticLevelInfo => 'Info';

  @override
  String get diagnosticLevelWarning => 'Warning';

  @override
  String get diagnosticLevelError => 'Error';

  @override
  String get diagnosticCategoryApp => 'App';

  @override
  String get diagnosticCategoryNetwork => 'Network';

  @override
  String get diagnosticCategoryPerformance => 'Performance';

  @override
  String get diagnosticCategoryError => 'Error';

  @override
  String get diagnosticCategoryAuthentication => 'Authentication';
}
