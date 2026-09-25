import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('zh', 'TW'),
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'知阅'**
  String get appTitle;

  /// No description provided for @navRecommend.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get navRecommend;

  /// No description provided for @navSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get navSearch;

  /// No description provided for @navBookshelf.
  ///
  /// In zh, this message translates to:
  /// **'书架'**
  String get navBookshelf;

  /// No description provided for @navMe.
  ///
  /// In zh, this message translates to:
  /// **'我'**
  String get navMe;

  /// No description provided for @navWorkspace.
  ///
  /// In zh, this message translates to:
  /// **'工作区'**
  String get navWorkspace;

  /// No description provided for @feedFollowing.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get feedFollowing;

  /// No description provided for @feedRecommend.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get feedRecommend;

  /// No description provided for @feedHot.
  ///
  /// In zh, this message translates to:
  /// **'热榜'**
  String get feedHot;

  /// No description provided for @feedStory.
  ///
  /// In zh, this message translates to:
  /// **'故事'**
  String get feedStory;

  /// No description provided for @feedFollowingChoice.
  ///
  /// In zh, this message translates to:
  /// **'精选'**
  String get feedFollowingChoice;

  /// No description provided for @feedFollowingLatest.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get feedFollowingLatest;

  /// No description provided for @feedFollowingIdeas.
  ///
  /// In zh, this message translates to:
  /// **'想法'**
  String get feedFollowingIdeas;

  /// No description provided for @feedEmptyFollowing.
  ///
  /// In zh, this message translates to:
  /// **'关注流暂时没有新内容'**
  String get feedEmptyFollowing;

  /// No description provided for @feedEmptyHot.
  ///
  /// In zh, this message translates to:
  /// **'当前没有可显示的热榜内容'**
  String get feedEmptyHot;

  /// No description provided for @feedEmptyRecommend.
  ///
  /// In zh, this message translates to:
  /// **'当前没有可显示的推荐内容'**
  String get feedEmptyRecommend;

  /// No description provided for @feedNextLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'续页加载失败，点击重试'**
  String get feedNextLoadFailed;

  /// No description provided for @feedAllShown.
  ///
  /// In zh, this message translates to:
  /// **'已显示当前全部内容'**
  String get feedAllShown;

  /// No description provided for @feedLoadMore.
  ///
  /// In zh, this message translates to:
  /// **'继续下滑加载更多'**
  String get feedLoadMore;

  /// No description provided for @feedFollowingPeople.
  ///
  /// In zh, this message translates to:
  /// **'关注的人'**
  String get feedFollowingPeople;

  /// No description provided for @feedViewPersonRecent.
  ///
  /// In zh, this message translates to:
  /// **'查看 {name} 最近发布的内容'**
  String feedViewPersonRecent(String name);

  /// No description provided for @feedDiscoverFriends.
  ///
  /// In zh, this message translates to:
  /// **'发现好友'**
  String get feedDiscoverFriends;

  /// No description provided for @feedFollowingSemantic.
  ///
  /// In zh, this message translates to:
  /// **'关注页'**
  String get feedFollowingSemantic;

  /// No description provided for @feedSaltServiceFallback.
  ///
  /// In zh, this message translates to:
  /// **'知乎盐选会员 为你严选好内容'**
  String get feedSaltServiceFallback;

  /// No description provided for @feedPersonRecentTitle.
  ///
  /// In zh, this message translates to:
  /// **'{name} 的最近动态'**
  String feedPersonRecentTitle(String name);

  /// No description provided for @feedPersonRecentEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有公开的最近内容'**
  String get feedPersonRecentEmpty;

  /// No description provided for @storyCategoriesTitle.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get storyCategoriesTitle;

  /// No description provided for @storySearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索故事'**
  String get storySearch;

  /// No description provided for @storyLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'故事分类暂时无法加载'**
  String get storyLoadFailed;

  /// No description provided for @storyEmptyCategories.
  ///
  /// In zh, this message translates to:
  /// **'暂时没有故事分类'**
  String get storyEmptyCategories;

  /// No description provided for @storyBrowseByGenre.
  ///
  /// In zh, this message translates to:
  /// **'按题材浏览故事'**
  String get storyBrowseByGenre;

  /// No description provided for @storyFilterStories.
  ///
  /// In zh, this message translates to:
  /// **'筛选故事'**
  String get storyFilterStories;

  /// No description provided for @storyFeaturedCategories.
  ///
  /// In zh, this message translates to:
  /// **'精选分类'**
  String get storyFeaturedCategories;

  /// No description provided for @storyQuickFilter.
  ///
  /// In zh, this message translates to:
  /// **'快捷筛选'**
  String get storyQuickFilter;

  /// No description provided for @storySort.
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get storySort;

  /// No description provided for @storyAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get storyAll;

  /// No description provided for @storyCategory.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get storyCategory;

  /// No description provided for @storyTabStories.
  ///
  /// In zh, this message translates to:
  /// **'故事'**
  String get storyTabStories;

  /// No description provided for @storyTabBooks.
  ///
  /// In zh, this message translates to:
  /// **'电子书'**
  String get storyTabBooks;

  /// No description provided for @storyTabAssessments.
  ///
  /// In zh, this message translates to:
  /// **'测评'**
  String get storyTabAssessments;

  /// No description provided for @storyLong.
  ///
  /// In zh, this message translates to:
  /// **'长篇'**
  String get storyLong;

  /// No description provided for @storyShort.
  ///
  /// In zh, this message translates to:
  /// **'短篇'**
  String get storyShort;

  /// No description provided for @storyAudioBook.
  ///
  /// In zh, this message translates to:
  /// **'有声书'**
  String get storyAudioBook;

  /// No description provided for @storyFilter.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get storyFilter;

  /// No description provided for @storySortHot.
  ///
  /// In zh, this message translates to:
  /// **'热度'**
  String get storySortHot;

  /// No description provided for @storySortGood.
  ///
  /// In zh, this message translates to:
  /// **'好评'**
  String get storySortGood;

  /// No description provided for @storySortNew.
  ///
  /// In zh, this message translates to:
  /// **'上新'**
  String get storySortNew;

  /// No description provided for @storyAllCategories.
  ///
  /// In zh, this message translates to:
  /// **'全部分类'**
  String get storyAllCategories;

  /// No description provided for @storyMaxTags.
  ///
  /// In zh, this message translates to:
  /// **'最多支持选择 5 个标签'**
  String get storyMaxTags;

  /// No description provided for @storyNoCategories.
  ///
  /// In zh, this message translates to:
  /// **'暂无分类'**
  String get storyNoCategories;

  /// No description provided for @storyReset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get storyReset;

  /// No description provided for @storyConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get storyConfirm;

  /// No description provided for @storyViewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get storyViewAll;

  /// No description provided for @storyEmptyCondition.
  ///
  /// In zh, this message translates to:
  /// **'暂时没有符合条件的内容'**
  String get storyEmptyCondition;

  /// No description provided for @storyCategoryFallback.
  ///
  /// In zh, this message translates to:
  /// **'故事分类'**
  String get storyCategoryFallback;

  /// No description provided for @storyEmptyCategory.
  ///
  /// In zh, this message translates to:
  /// **'该分类暂时没有故事'**
  String get storyEmptyCategory;

  /// No description provided for @storyLongTitle.
  ///
  /// In zh, this message translates to:
  /// **'长篇故事'**
  String get storyLongTitle;

  /// No description provided for @storyEmptyLong.
  ///
  /// In zh, this message translates to:
  /// **'暂时没有长篇故事'**
  String get storyEmptyLong;

  /// No description provided for @storyLikeCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 赞'**
  String storyLikeCount(String count);

  /// No description provided for @storyOngoing.
  ///
  /// In zh, this message translates to:
  /// **'连载中'**
  String get storyOngoing;

  /// No description provided for @storyFinished.
  ///
  /// In zh, this message translates to:
  /// **'完结'**
  String get storyFinished;

  /// No description provided for @storyFree.
  ///
  /// In zh, this message translates to:
  /// **'免费'**
  String get storyFree;

  /// No description provided for @storyVip.
  ///
  /// In zh, this message translates to:
  /// **'VIP'**
  String get storyVip;

  /// No description provided for @storyVipDiscount.
  ///
  /// In zh, this message translates to:
  /// **'VIP 折扣'**
  String get storyVipDiscount;

  /// No description provided for @storyType.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get storyType;

  /// No description provided for @storyStatus.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get storyStatus;

  /// No description provided for @storyRights.
  ///
  /// In zh, this message translates to:
  /// **'权益'**
  String get storyRights;

  /// No description provided for @storySectionHotTags.
  ///
  /// In zh, this message translates to:
  /// **'热门标签'**
  String get storySectionHotTags;

  /// No description provided for @storySectionGenre.
  ///
  /// In zh, this message translates to:
  /// **'题材'**
  String get storySectionGenre;

  /// No description provided for @storySectionCharacters.
  ///
  /// In zh, this message translates to:
  /// **'角色'**
  String get storySectionCharacters;

  /// No description provided for @storySectionPlot.
  ///
  /// In zh, this message translates to:
  /// **'情节'**
  String get storySectionPlot;

  /// No description provided for @storySectionMood.
  ///
  /// In zh, this message translates to:
  /// **'情绪'**
  String get storySectionMood;

  /// No description provided for @storySectionSetting.
  ///
  /// In zh, this message translates to:
  /// **'时空'**
  String get storySectionSetting;

  /// No description provided for @storyTypeAssessment.
  ///
  /// In zh, this message translates to:
  /// **'测评'**
  String get storyTypeAssessment;

  /// No description provided for @storyMaxSelection.
  ///
  /// In zh, this message translates to:
  /// **'最多选择 5 个标签'**
  String get storyMaxSelection;

  /// No description provided for @saltContinueReading.
  ///
  /// In zh, this message translates to:
  /// **'继续阅读'**
  String get saltContinueReading;

  /// No description provided for @saltStartReading.
  ///
  /// In zh, this message translates to:
  /// **'开始阅读'**
  String get saltStartReading;

  /// No description provided for @saltAdded.
  ///
  /// In zh, this message translates to:
  /// **'已加入'**
  String get saltAdded;

  /// No description provided for @saltAddToBookshelf.
  ///
  /// In zh, this message translates to:
  /// **'加入书架'**
  String get saltAddToBookshelf;

  /// No description provided for @saltChapterOrder.
  ///
  /// In zh, this message translates to:
  /// **'章节顺序'**
  String get saltChapterOrder;

  /// No description provided for @saltAscending.
  ///
  /// In zh, this message translates to:
  /// **'正序'**
  String get saltAscending;

  /// No description provided for @saltDescending.
  ///
  /// In zh, this message translates to:
  /// **'倒序'**
  String get saltDescending;

  /// No description provided for @saltChapter.
  ///
  /// In zh, this message translates to:
  /// **'章节'**
  String get saltChapter;

  /// No description provided for @saltCatalogTitle.
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get saltCatalogTitle;

  /// No description provided for @saltChapterCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 节'**
  String saltChapterCount(int count);

  /// No description provided for @saltChapterDirectory.
  ///
  /// In zh, this message translates to:
  /// **'章节目录'**
  String get saltChapterDirectory;

  /// No description provided for @saltProcessing.
  ///
  /// In zh, this message translates to:
  /// **'正在处理 {index}/{total} · {title}'**
  String saltProcessing(int index, int total, String title);

  /// No description provided for @saltSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get saltSelectAll;

  /// No description provided for @saltCancelSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'取消全选'**
  String get saltCancelSelectAll;

  /// No description provided for @saltSelectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {selected}/{total}'**
  String saltSelectedCount(int selected, int total);

  /// No description provided for @saltDownloadingChapters.
  ///
  /// In zh, this message translates to:
  /// **'正在下载章节'**
  String get saltDownloadingChapters;

  /// No description provided for @saltExportChapters.
  ///
  /// In zh, this message translates to:
  /// **'导出 {format} · {count} 章'**
  String saltExportChapters(String format, int count);

  /// No description provided for @saltDirectoryLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'目录载入失败'**
  String get saltDirectoryLoadFailed;

  /// No description provided for @saltNetworkRetry.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络后重试'**
  String get saltNetworkRetry;

  /// No description provided for @saltDecodeFailed.
  ///
  /// In zh, this message translates to:
  /// **'章节解码失败，请重试。'**
  String get saltDecodeFailed;

  /// No description provided for @saltDecodeParamsMissing.
  ///
  /// In zh, this message translates to:
  /// **'章节响应缺少完整解码参数，请重试。'**
  String get saltDecodeParamsMissing;

  /// No description provided for @saltDirectoryEmpty.
  ///
  /// In zh, this message translates to:
  /// **'目录中暂时没有章节'**
  String get saltDirectoryEmpty;

  /// No description provided for @saltCached.
  ///
  /// In zh, this message translates to:
  /// **'已缓存'**
  String get saltCached;

  /// No description provided for @saltCommentsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有评论'**
  String get saltCommentsEmpty;

  /// No description provided for @saltBulletCommentsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有弹评'**
  String get saltBulletCommentsEmpty;

  /// No description provided for @saltReaderTopBar.
  ///
  /// In zh, this message translates to:
  /// **'阅读顶部栏'**
  String get saltReaderTopBar;

  /// No description provided for @saltReaderBottomBar.
  ///
  /// In zh, this message translates to:
  /// **'阅读底部栏'**
  String get saltReaderBottomBar;

  /// No description provided for @saltReadingTitle.
  ///
  /// In zh, this message translates to:
  /// **'盐选阅读'**
  String get saltReadingTitle;

  /// No description provided for @saltMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get saltMore;

  /// No description provided for @saltSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'阅读设置'**
  String get saltSettingsTitle;

  /// No description provided for @saltVerticalScroll.
  ///
  /// In zh, this message translates to:
  /// **'上下滑动'**
  String get saltVerticalScroll;

  /// No description provided for @saltHorizontalPage.
  ///
  /// In zh, this message translates to:
  /// **'左右翻页'**
  String get saltHorizontalPage;

  /// No description provided for @saltFontSize.
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get saltFontSize;

  /// No description provided for @saltLineSpacing.
  ///
  /// In zh, this message translates to:
  /// **'行距'**
  String get saltLineSpacing;

  /// No description provided for @saltParagraphSpacing.
  ///
  /// In zh, this message translates to:
  /// **'段距'**
  String get saltParagraphSpacing;

  /// No description provided for @saltHorizontalMargins.
  ///
  /// In zh, this message translates to:
  /// **'左右边距'**
  String get saltHorizontalMargins;

  /// No description provided for @saltApply.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get saltApply;

  /// No description provided for @saltChapterInfo.
  ///
  /// In zh, this message translates to:
  /// **'章节信息'**
  String get saltChapterInfo;

  /// No description provided for @saltAuthor.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get saltAuthor;

  /// No description provided for @saltReadable.
  ///
  /// In zh, this message translates to:
  /// **'可读'**
  String get saltReadable;

  /// No description provided for @saltLocked.
  ///
  /// In zh, this message translates to:
  /// **'未解锁'**
  String get saltLocked;

  /// No description provided for @saltChapterLocked.
  ///
  /// In zh, this message translates to:
  /// **'章节锁定'**
  String get saltChapterLocked;

  /// No description provided for @saltChapterReadable.
  ///
  /// In zh, this message translates to:
  /// **'章节可读'**
  String get saltChapterReadable;

  /// No description provided for @saltSectionLabel.
  ///
  /// In zh, this message translates to:
  /// **'第 {index} 节'**
  String saltSectionLabel(int index);

  /// No description provided for @saltSectionProgress.
  ///
  /// In zh, this message translates to:
  /// **'第 {index}/{count} 节'**
  String saltSectionProgress(int index, int count);

  /// No description provided for @saltLikes.
  ///
  /// In zh, this message translates to:
  /// **'{count} 赞'**
  String saltLikes(String count);

  /// No description provided for @saltComments.
  ///
  /// In zh, this message translates to:
  /// **'{count} 评论'**
  String saltComments(String count);

  /// No description provided for @saltAudioAvailable.
  ///
  /// In zh, this message translates to:
  /// **'可听'**
  String get saltAudioAvailable;

  /// No description provided for @saltNoPermission.
  ///
  /// In zh, this message translates to:
  /// **'当前账号暂无阅读权限'**
  String get saltNoPermission;

  /// No description provided for @saltReload.
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get saltReload;

  /// No description provided for @saltContentUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'章节内容暂不可用'**
  String get saltContentUnavailable;

  /// No description provided for @saltPreviousChapter.
  ///
  /// In zh, this message translates to:
  /// **'上一节'**
  String get saltPreviousChapter;

  /// No description provided for @saltNextChapter.
  ///
  /// In zh, this message translates to:
  /// **'下一节'**
  String get saltNextChapter;

  /// No description provided for @saltMetadataReady.
  ///
  /// In zh, this message translates to:
  /// **'资料已获取'**
  String get saltMetadataReady;

  /// No description provided for @saltEntitlementPassed.
  ///
  /// In zh, this message translates to:
  /// **'权益通过'**
  String get saltEntitlementPassed;

  /// No description provided for @saltPayloadReady.
  ///
  /// In zh, this message translates to:
  /// **'载荷已获取'**
  String get saltPayloadReady;

  /// No description provided for @saltBodyShown.
  ///
  /// In zh, this message translates to:
  /// **'正文已显示'**
  String get saltBodyShown;

  /// No description provided for @saltWaitingBody.
  ///
  /// In zh, this message translates to:
  /// **'等待正文解析'**
  String get saltWaitingBody;

  /// No description provided for @saltPayloadChars.
  ///
  /// In zh, this message translates to:
  /// **'字符载荷'**
  String get saltPayloadChars;

  /// No description provided for @saltCodeChars.
  ///
  /// In zh, this message translates to:
  /// **'位 code'**
  String get saltCodeChars;

  /// No description provided for @saltChapterBodyShown.
  ///
  /// In zh, this message translates to:
  /// **'章节正文已显示'**
  String get saltChapterBodyShown;

  /// No description provided for @saltReadyDetail.
  ///
  /// In zh, this message translates to:
  /// **'章节资料、绑定载荷和完整正文均已就绪。'**
  String get saltReadyDetail;

  /// No description provided for @saltShelfTitle.
  ///
  /// In zh, this message translates to:
  /// **'书架'**
  String get saltShelfTitle;

  /// No description provided for @saltWorkFallback.
  ///
  /// In zh, this message translates to:
  /// **'盐选作品'**
  String get saltWorkFallback;

  /// No description provided for @saltCategory.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get saltCategory;

  /// No description provided for @saltKnowledgeColumn.
  ///
  /// In zh, this message translates to:
  /// **'知识专栏'**
  String get saltKnowledgeColumn;

  /// No description provided for @saltLocalShelfEmpty.
  ///
  /// In zh, this message translates to:
  /// **'本地书架暂无内容'**
  String get saltLocalShelfEmpty;

  /// No description provided for @saltMoreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多操作'**
  String get saltMoreActions;

  /// No description provided for @saltReadAloud.
  ///
  /// In zh, this message translates to:
  /// **'朗读本节'**
  String get saltReadAloud;

  /// No description provided for @saltStopReading.
  ///
  /// In zh, this message translates to:
  /// **'停止朗读'**
  String get saltStopReading;

  /// No description provided for @saltReadAloudSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用系统语音朗读当前章节'**
  String get saltReadAloudSubtitle;

  /// No description provided for @saltExportChapter.
  ///
  /// In zh, this message translates to:
  /// **'导出当前章节为 {format}'**
  String saltExportChapter(String format);

  /// No description provided for @saltExportTxt.
  ///
  /// In zh, this message translates to:
  /// **'导出 TXT 文件'**
  String get saltExportTxt;

  /// No description provided for @saltExportDocx.
  ///
  /// In zh, this message translates to:
  /// **'导出 DOCX 文件'**
  String get saltExportDocx;

  /// No description provided for @saltReadingStarted.
  ///
  /// In zh, this message translates to:
  /// **'正在朗读{title}'**
  String saltReadingStarted(String title);

  /// No description provided for @saltSpeechUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'系统语音不可用，请安装语音包'**
  String get saltSpeechUnavailable;

  /// No description provided for @saltExportedTo.
  ///
  /// In zh, this message translates to:
  /// **'已导出到 {location}'**
  String saltExportedTo(String location);

  /// No description provided for @saltExportedAs.
  ///
  /// In zh, this message translates to:
  /// **'已导出为 {format}：{location}'**
  String saltExportedAs(String format, String location);

  /// No description provided for @saltExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败，请重试'**
  String get saltExportFailed;

  /// No description provided for @saltCloudShelfUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'云书架暂时无法同步'**
  String get saltCloudShelfUnavailable;

  /// No description provided for @saltAccountSyncFailed.
  ///
  /// In zh, this message translates to:
  /// **'账号同步失败，请稍后重试'**
  String get saltAccountSyncFailed;

  /// No description provided for @saltStoryHomeLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'盐选首页暂时无法加载'**
  String get saltStoryHomeLoadFailed;

  /// No description provided for @saltStoryEntry.
  ///
  /// In zh, this message translates to:
  /// **'入口'**
  String get saltStoryEntry;

  /// No description provided for @saltStoryModuleMustSee.
  ///
  /// In zh, this message translates to:
  /// **'进站必看'**
  String get saltStoryModuleMustSee;

  /// No description provided for @saltStoryModuleTodayRead.
  ///
  /// In zh, this message translates to:
  /// **'今日阅读'**
  String get saltStoryModuleTodayRead;

  /// No description provided for @saltStoryModuleEveryoneWatch.
  ///
  /// In zh, this message translates to:
  /// **'大家都在看'**
  String get saltStoryModuleEveryoneWatch;

  /// No description provided for @saltStoryModuleRecommended.
  ///
  /// In zh, this message translates to:
  /// **'为你推荐'**
  String get saltStoryModuleRecommended;

  /// No description provided for @saltStoryBoard.
  ///
  /// In zh, this message translates to:
  /// **'故事榜单'**
  String get saltStoryBoard;

  /// No description provided for @saltStoryHotBoard.
  ///
  /// In zh, this message translates to:
  /// **'热度榜'**
  String get saltStoryHotBoard;

  /// No description provided for @saltStoryReputationBoard.
  ///
  /// In zh, this message translates to:
  /// **'口碑榜'**
  String get saltStoryReputationBoard;

  /// No description provided for @saltStoryNewBoard.
  ///
  /// In zh, this message translates to:
  /// **'新书榜'**
  String get saltStoryNewBoard;

  /// No description provided for @saltStoryLongBoard.
  ///
  /// In zh, this message translates to:
  /// **'长篇榜'**
  String get saltStoryLongBoard;

  /// No description provided for @saltStoryBoardNumber.
  ///
  /// In zh, this message translates to:
  /// **'榜单 {index}'**
  String saltStoryBoardNumber(int index);

  /// No description provided for @saltPillOnShelf.
  ///
  /// In zh, this message translates to:
  /// **'已加入书架'**
  String get saltPillOnShelf;

  /// No description provided for @saltPillLiked.
  ///
  /// In zh, this message translates to:
  /// **'已赞'**
  String get saltPillLiked;

  /// No description provided for @saltBrandLong.
  ///
  /// In zh, this message translates to:
  /// **'长篇'**
  String get saltBrandLong;

  /// No description provided for @saltScore.
  ///
  /// In zh, this message translates to:
  /// **'评分 {score}'**
  String saltScore(String score);

  /// No description provided for @saltUpdatedSections.
  ///
  /// In zh, this message translates to:
  /// **'更新 {count} 节'**
  String saltUpdatedSections(int count);

  /// No description provided for @saltFinishedWithCount.
  ///
  /// In zh, this message translates to:
  /// **'已完结，共 {count} 节'**
  String saltFinishedWithCount(int count);

  /// No description provided for @saltUpdatedTo.
  ///
  /// In zh, this message translates to:
  /// **'已更新至第 {index} 节'**
  String saltUpdatedTo(int index);

  /// No description provided for @saltShelfLiked.
  ///
  /// In zh, this message translates to:
  /// **'赞过'**
  String get saltShelfLiked;

  /// No description provided for @saltShelfComments.
  ///
  /// In zh, this message translates to:
  /// **'弹评'**
  String get saltShelfComments;

  /// No description provided for @saltShelfHistory.
  ///
  /// In zh, this message translates to:
  /// **'历史记录'**
  String get saltShelfHistory;

  /// No description provided for @saltShelfLists.
  ///
  /// In zh, this message translates to:
  /// **'书单'**
  String get saltShelfLists;

  /// No description provided for @answerLabel.
  ///
  /// In zh, this message translates to:
  /// **'回答'**
  String get answerLabel;

  /// No description provided for @drawerBrowse.
  ///
  /// In zh, this message translates to:
  /// **'浏览'**
  String get drawerBrowse;

  /// No description provided for @drawerColumns.
  ///
  /// In zh, this message translates to:
  /// **'专栏推荐'**
  String get drawerColumns;

  /// No description provided for @drawerTopicCategories.
  ///
  /// In zh, this message translates to:
  /// **'话题分类'**
  String get drawerTopicCategories;

  /// No description provided for @drawerHotTopics.
  ///
  /// In zh, this message translates to:
  /// **'热门话题'**
  String get drawerHotTopics;

  /// No description provided for @drawerHistory.
  ///
  /// In zh, this message translates to:
  /// **'历史记录'**
  String get drawerHistory;

  /// No description provided for @drawerMyContent.
  ///
  /// In zh, this message translates to:
  /// **'我的内容'**
  String get drawerMyContent;

  /// No description provided for @drawerMessages.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get drawerMessages;

  /// No description provided for @drawerCollections.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get drawerCollections;

  /// No description provided for @drawerBookshelf.
  ///
  /// In zh, this message translates to:
  /// **'书架'**
  String get drawerBookshelf;

  /// No description provided for @drawerFindUsers.
  ///
  /// In zh, this message translates to:
  /// **'查找用户'**
  String get drawerFindUsers;

  /// No description provided for @drawerAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get drawerAccount;

  /// No description provided for @drawerLoginOrAddAccount.
  ///
  /// In zh, this message translates to:
  /// **'登录或添加账号'**
  String get drawerLoginOrAddAccount;

  /// No description provided for @drawerAccountManagement.
  ///
  /// In zh, this message translates to:
  /// **'账号管理'**
  String get drawerAccountManagement;

  /// No description provided for @drawerApp.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get drawerApp;

  /// No description provided for @drawerSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get drawerSettings;

  /// No description provided for @drawerClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭侧边栏'**
  String get drawerClose;

  /// No description provided for @drawerOpen.
  ///
  /// In zh, this message translates to:
  /// **'打开侧边栏'**
  String get drawerOpen;

  /// No description provided for @drawerVersion.
  ///
  /// In zh, this message translates to:
  /// **'知阅 {version}'**
  String drawerVersion(String version);

  /// No description provided for @commonBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonReset.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get commonReset;

  /// No description provided for @commonClear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get commonClear;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get commonDone;

  /// No description provided for @commonRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get commonRetry;

  /// No description provided for @commonSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get commonSearch;

  /// No description provided for @commonSelect.
  ///
  /// In zh, this message translates to:
  /// **'请选择'**
  String get commonSelect;

  /// No description provided for @commonLoading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get commonLoading;

  /// No description provided for @commonMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get commonMore;

  /// No description provided for @commonReply.
  ///
  /// In zh, this message translates to:
  /// **'回复'**
  String get commonReply;

  /// No description provided for @commonPublish.
  ///
  /// In zh, this message translates to:
  /// **'发布'**
  String get commonPublish;

  /// No description provided for @commonPublishing.
  ///
  /// In zh, this message translates to:
  /// **'发布中'**
  String get commonPublishing;

  /// No description provided for @commonFollow.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get commonFollow;

  /// No description provided for @commonRefresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get commonRefresh;

  /// No description provided for @commonEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get commonShare;

  /// No description provided for @commonFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请重试'**
  String get commonFailed;

  /// No description provided for @commonNoMore.
  ///
  /// In zh, this message translates to:
  /// **'没有更多内容了'**
  String get commonNoMore;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get settingsAppearance;

  /// No description provided for @settingsBackup.
  ///
  /// In zh, this message translates to:
  /// **'备份'**
  String get settingsBackup;

  /// No description provided for @settingsAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get settingsAccount;

  /// No description provided for @settingsLogs.
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get settingsLogs;

  /// No description provided for @settingsAboutSection.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsAboutSection;

  /// No description provided for @settingsUpdates.
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get settingsUpdates;

  /// No description provided for @settingsData.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get settingsData;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'深色模式、语言与显示'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsPersonalizationSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'首页、推荐与内容偏好'**
  String get settingsPersonalizationSubtitle;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 数据同步'**
  String get settingsBackupSubtitle;

  /// No description provided for @settingsAccountSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'会话与登录状态'**
  String get settingsAccountSubtitle;

  /// No description provided for @settingsLogsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'诊断日志与问题排查'**
  String get settingsLogsSubtitle;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认设置与应用信息'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsUpdatesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'检查并安装新版本'**
  String get settingsUpdatesSubtitle;

  /// No description provided for @settingsDataSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'历史记录、缓存与存储'**
  String get settingsDataSubtitle;

  /// No description provided for @settingsHomeContent.
  ///
  /// In zh, this message translates to:
  /// **'首页与内容'**
  String get settingsHomeContent;

  /// No description provided for @settingsStartupPage.
  ///
  /// In zh, this message translates to:
  /// **'启动页面'**
  String get settingsStartupPage;

  /// No description provided for @settingsRecommendation.
  ///
  /// In zh, this message translates to:
  /// **'推荐策略'**
  String get settingsRecommendation;

  /// No description provided for @settingsServer.
  ///
  /// In zh, this message translates to:
  /// **'服务器'**
  String get settingsServer;

  /// No description provided for @settingsLocal.
  ///
  /// In zh, this message translates to:
  /// **'本地'**
  String get settingsLocal;

  /// No description provided for @settingsHybrid.
  ///
  /// In zh, this message translates to:
  /// **'混合'**
  String get settingsHybrid;

  /// No description provided for @settingsDensity.
  ///
  /// In zh, this message translates to:
  /// **'内容密度'**
  String get settingsDensity;

  /// No description provided for @settingsComfortable.
  ///
  /// In zh, this message translates to:
  /// **'舒适'**
  String get settingsComfortable;

  /// No description provided for @settingsCompact.
  ///
  /// In zh, this message translates to:
  /// **'紧凑'**
  String get settingsCompact;

  /// No description provided for @settingsRefreshHome.
  ///
  /// In zh, this message translates to:
  /// **'重复点击首页时刷新'**
  String get settingsRefreshHome;

  /// No description provided for @settingsRefreshHomeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'再次点击已选中的首页按钮时回到顶部并刷新'**
  String get settingsRefreshHomeSubtitle;

  /// No description provided for @settingsShowImages.
  ///
  /// In zh, this message translates to:
  /// **'显示推荐图片'**
  String get settingsShowImages;

  /// No description provided for @settingsShowImagesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭后首页只显示文字、作者和互动信息'**
  String get settingsShowImagesSubtitle;

  /// No description provided for @settingsShowMetrics.
  ///
  /// In zh, this message translates to:
  /// **'显示互动数据'**
  String get settingsShowMetrics;

  /// No description provided for @settingsShowMetricsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'显示赞同、收藏、评论和发布日期'**
  String get settingsShowMetricsSubtitle;

  /// No description provided for @settingsLocalBehavior.
  ///
  /// In zh, this message translates to:
  /// **'本地推荐行为'**
  String get settingsLocalBehavior;

  /// No description provided for @settingsLocalEvents.
  ///
  /// In zh, this message translates to:
  /// **'本机已记录 {count} 条行为'**
  String settingsLocalEvents(int count);

  /// No description provided for @settingsFeedOrder.
  ///
  /// In zh, this message translates to:
  /// **'首页分区排序'**
  String get settingsFeedOrder;

  /// No description provided for @settingsFilterStats.
  ///
  /// In zh, this message translates to:
  /// **'内容过滤统计'**
  String get settingsFilterStats;

  /// No description provided for @settingsReadingDisplay.
  ///
  /// In zh, this message translates to:
  /// **'阅读与显示'**
  String get settingsReadingDisplay;

  /// No description provided for @settingsDarkMode.
  ///
  /// In zh, this message translates to:
  /// **'黑夜模式'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeOnSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用深色背景和低亮度表面'**
  String get settingsDarkModeOnSubtitle;

  /// No description provided for @settingsDarkModeOffSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用浅色背景和明亮表面'**
  String get settingsDarkModeOffSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'选择应用界面语言'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsTextSize.
  ///
  /// In zh, this message translates to:
  /// **'阅读字号'**
  String get settingsTextSize;

  /// No description provided for @settingsSmall.
  ///
  /// In zh, this message translates to:
  /// **'小'**
  String get settingsSmall;

  /// No description provided for @settingsStandard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get settingsStandard;

  /// No description provided for @settingsLarge.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get settingsLarge;

  /// No description provided for @settingsFollowSystemTextScale.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统字号'**
  String get settingsFollowSystemTextScale;

  /// No description provided for @settingsFollowSystemTextScaleSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在阅读字号基础上叠加系统显示大小'**
  String get settingsFollowSystemTextScaleSubtitle;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In zh, this message translates to:
  /// **'减少动态效果'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'减少页面切换和组件动画'**
  String get settingsReduceMotionSubtitle;

  /// No description provided for @settingsGlass.
  ///
  /// In zh, this message translates to:
  /// **'液态玻璃效果'**
  String get settingsGlass;

  /// No description provided for @settingsGlassOnSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'保留玻璃反馈与透明层次'**
  String get settingsGlassOnSubtitle;

  /// No description provided for @settingsGlassOffSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'流畅模式：使用低开销的实色按钮和导航栏'**
  String get settingsGlassOffSubtitle;

  /// No description provided for @settingsPersonalization.
  ///
  /// In zh, this message translates to:
  /// **'个性化功能'**
  String get settingsPersonalization;

  /// No description provided for @settingsFocusSearch.
  ///
  /// In zh, this message translates to:
  /// **'进入搜索页时自动打开输入法'**
  String get settingsFocusSearch;

  /// No description provided for @settingsFocusSearchOn.
  ///
  /// In zh, this message translates to:
  /// **'进入搜索页后自动聚焦搜索框'**
  String get settingsFocusSearchOn;

  /// No description provided for @settingsFocusSearchOff.
  ///
  /// In zh, this message translates to:
  /// **'进入搜索页后手动点击搜索框'**
  String get settingsFocusSearchOff;

  /// No description provided for @settingsImagesStorage.
  ///
  /// In zh, this message translates to:
  /// **'图片与存储'**
  String get settingsImagesStorage;

  /// No description provided for @settingsKeepHistory.
  ///
  /// In zh, this message translates to:
  /// **'保留浏览记录'**
  String get settingsKeepHistory;

  /// No description provided for @settingsKeepHistoryOn.
  ///
  /// In zh, this message translates to:
  /// **'仅保存在本机 · {count} 条'**
  String settingsKeepHistoryOn(int count);

  /// No description provided for @settingsKeepHistoryOff.
  ///
  /// In zh, this message translates to:
  /// **'打开内容不会写入本机历史'**
  String get settingsKeepHistoryOff;

  /// No description provided for @settingsPrefetchImages.
  ///
  /// In zh, this message translates to:
  /// **'预加载列表图片'**
  String get settingsPrefetchImages;

  /// No description provided for @settingsPrefetchImagesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'提前加载即将显示的头像和正文图片'**
  String get settingsPrefetchImagesSubtitle;

  /// No description provided for @settingsImageCache.
  ///
  /// In zh, this message translates to:
  /// **'图片缓存容量'**
  String get settingsImageCache;

  /// No description provided for @settingsEconomy.
  ///
  /// In zh, this message translates to:
  /// **'节省'**
  String get settingsEconomy;

  /// No description provided for @settingsRoomy.
  ///
  /// In zh, this message translates to:
  /// **'充足'**
  String get settingsRoomy;

  /// No description provided for @settingsNoCacheImages.
  ///
  /// In zh, this message translates to:
  /// **'当前没有缓存图片'**
  String get settingsNoCacheImages;

  /// No description provided for @settingsCachedImages.
  ///
  /// In zh, this message translates to:
  /// **'已清理 {count} 张缓存图片'**
  String settingsCachedImages(int count);

  /// No description provided for @settingsPrivacyData.
  ///
  /// In zh, this message translates to:
  /// **'隐私与数据'**
  String get settingsPrivacyData;

  /// No description provided for @settingsKeepSearch.
  ///
  /// In zh, this message translates to:
  /// **'保留搜索记录'**
  String get settingsKeepSearch;

  /// No description provided for @settingsKeepSearchOn.
  ///
  /// In zh, this message translates to:
  /// **'仅保存在本机 · {count} 条'**
  String settingsKeepSearchOn(int count);

  /// No description provided for @settingsKeepSearchOff.
  ///
  /// In zh, this message translates to:
  /// **'新搜索不会写入本机'**
  String get settingsKeepSearchOff;

  /// No description provided for @settingsShowHot.
  ///
  /// In zh, this message translates to:
  /// **'显示热搜'**
  String get settingsShowHot;

  /// No description provided for @settingsShowHotOn.
  ///
  /// In zh, this message translates to:
  /// **'在搜索页显示知乎热搜'**
  String get settingsShowHotOn;

  /// No description provided for @settingsShowHotOff.
  ///
  /// In zh, this message translates to:
  /// **'搜索页不加载热搜内容'**
  String get settingsShowHotOff;

  /// No description provided for @settingsWebDav.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 同步'**
  String get settingsWebDav;

  /// No description provided for @settingsAccountSessions.
  ///
  /// In zh, this message translates to:
  /// **'账号与多端登录'**
  String get settingsAccountSessions;

  /// No description provided for @settingsSignOut.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get settingsSignOut;

  /// No description provided for @settingsOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get settingsOther;

  /// No description provided for @settingsDiagnostics.
  ///
  /// In zh, this message translates to:
  /// **'诊断日志'**
  String get settingsDiagnostics;

  /// No description provided for @settingsUpdate.
  ///
  /// In zh, this message translates to:
  /// **'软件更新'**
  String get settingsUpdate;

  /// No description provided for @settingsRestoreDefaults.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认设置'**
  String get settingsRestoreDefaults;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于知阅'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsFeedOrderSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'按住右侧拖动，首页顶栏与左右滑动顺序会同步更新。'**
  String get settingsFeedOrderSubtitle;

  /// No description provided for @settingsRestoreDefaultsMessage.
  ///
  /// In zh, this message translates to:
  /// **'所有设置将恢复默认，不会退出账号。'**
  String get settingsRestoreDefaultsMessage;

  /// No description provided for @settingsRestored.
  ///
  /// In zh, this message translates to:
  /// **'软件设置已恢复默认'**
  String get settingsRestored;

  /// No description provided for @settingsSignOutMessage.
  ///
  /// In zh, this message translates to:
  /// **'本机保存的登录信息将被删除。'**
  String get settingsSignOutMessage;

  /// No description provided for @settingsSignedOut.
  ///
  /// In zh, this message translates to:
  /// **'已退出登录'**
  String get settingsSignedOut;

  /// No description provided for @settingsClearBrowsing.
  ///
  /// In zh, this message translates to:
  /// **'清空浏览记录'**
  String get settingsClearBrowsing;

  /// No description provided for @settingsNoBrowsingHistory.
  ///
  /// In zh, this message translates to:
  /// **'目前没有记录'**
  String get settingsNoBrowsingHistory;

  /// No description provided for @settingsDeleteBrowsing.
  ///
  /// In zh, this message translates to:
  /// **'删除 {count} 条本机记录'**
  String settingsDeleteBrowsing(int count);

  /// No description provided for @settingsClearImageCache.
  ///
  /// In zh, this message translates to:
  /// **'清理图片缓存'**
  String get settingsClearImageCache;

  /// No description provided for @settingsClearOfflineChapters.
  ///
  /// In zh, this message translates to:
  /// **'清理离线章节'**
  String get settingsClearOfflineChapters;

  /// No description provided for @settingsClearOfflineChaptersSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'删除阅读和下载时保存的盐选正文'**
  String get settingsClearOfflineChaptersSubtitle;

  /// No description provided for @settingsClearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清空搜索记录'**
  String get settingsClearSearch;

  /// No description provided for @settingsNoSearchHistory.
  ///
  /// In zh, this message translates to:
  /// **'目前没有记录'**
  String get settingsNoSearchHistory;

  /// No description provided for @settingsDeleteSearch.
  ///
  /// In zh, this message translates to:
  /// **'删除 {count} 条本机记录'**
  String settingsDeleteSearch(int count);

  /// No description provided for @settingsWebDavConfigured.
  ///
  /// In zh, this message translates to:
  /// **'已配置 · 搜索、历史、离线小说和回答缓存'**
  String get settingsWebDavConfigured;

  /// No description provided for @settingsWebDavSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'同步搜索记录、浏览历史、离线小说和回答缓存'**
  String get settingsWebDavSubtitle;

  /// No description provided for @settingsAccountSessionsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'扫码登录、保存账号槽位并快速切换'**
  String get settingsAccountSessionsSubtitle;

  /// No description provided for @settingsSignOutSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'移除本机登录信息'**
  String get settingsSignOutSubtitle;

  /// No description provided for @settingsDiagnosticsOn.
  ///
  /// In zh, this message translates to:
  /// **'已开启 · 管理网络、性能日志并导出'**
  String get settingsDiagnosticsOn;

  /// No description provided for @settingsDiagnosticsOff.
  ///
  /// In zh, this message translates to:
  /// **'定位接口异常、内容加载失败和卡顿问题'**
  String get settingsDiagnosticsOff;

  /// No description provided for @settingsUpdateSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'安全检查、下载并安装新版本'**
  String get settingsUpdateSubtitle;

  /// No description provided for @settingsRestoreDefaultsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'不会退出账号'**
  String get settingsRestoreDefaultsSubtitle;

  /// No description provided for @settingsGithub.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 开源地址'**
  String get settingsGithub;

  /// No description provided for @settingsGithubSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'查看源码、提交问题和发布记录'**
  String get settingsGithubSubtitle;

  /// No description provided for @settingsGithubOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开 GitHub 地址'**
  String get settingsGithubOpenFailed;

  /// No description provided for @searchTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get searchTitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'搜索知平内容'**
  String get searchPlaceholder;

  /// No description provided for @searchFilter.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get searchFilter;

  /// No description provided for @searchGeneral.
  ///
  /// In zh, this message translates to:
  /// **'综合'**
  String get searchGeneral;

  /// No description provided for @searchRealtime.
  ///
  /// In zh, this message translates to:
  /// **'实时'**
  String get searchRealtime;

  /// No description provided for @searchUsers.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get searchUsers;

  /// No description provided for @searchStories.
  ///
  /// In zh, this message translates to:
  /// **'小说'**
  String get searchStories;

  /// No description provided for @searchArticles.
  ///
  /// In zh, this message translates to:
  /// **'论文'**
  String get searchArticles;

  /// No description provided for @searchVideos.
  ///
  /// In zh, this message translates to:
  /// **'视频'**
  String get searchVideos;

  /// No description provided for @searchTopics.
  ///
  /// In zh, this message translates to:
  /// **'话题'**
  String get searchTopics;

  /// No description provided for @searchColumns.
  ///
  /// In zh, this message translates to:
  /// **'专栏'**
  String get searchColumns;

  /// No description provided for @searchKnowledge.
  ///
  /// In zh, this message translates to:
  /// **'知识'**
  String get searchKnowledge;

  /// No description provided for @searchIdeas.
  ///
  /// In zh, this message translates to:
  /// **'想法'**
  String get searchIdeas;

  /// No description provided for @searchCircles.
  ///
  /// In zh, this message translates to:
  /// **'圈子'**
  String get searchCircles;

  /// No description provided for @searchPodcasts.
  ///
  /// In zh, this message translates to:
  /// **'播客'**
  String get searchPodcasts;

  /// No description provided for @searchHot.
  ///
  /// In zh, this message translates to:
  /// **'热搜'**
  String get searchHot;

  /// No description provided for @searchHistory.
  ///
  /// In zh, this message translates to:
  /// **'历史搜索'**
  String get searchHistory;

  /// No description provided for @searchUnavailableTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法加载'**
  String get searchUnavailableTitle;

  /// No description provided for @searchUnavailableMessage.
  ///
  /// In zh, this message translates to:
  /// **'匿名内容服务暂时不可用，请稍后重试。'**
  String get searchUnavailableMessage;

  /// No description provided for @searchNoResults.
  ///
  /// In zh, this message translates to:
  /// **'没有找到相关内容'**
  String get searchNoResults;

  /// No description provided for @searchScope.
  ///
  /// In zh, this message translates to:
  /// **'搜索范围'**
  String get searchScope;

  /// No description provided for @searchMoreScopes.
  ///
  /// In zh, this message translates to:
  /// **'左右滑动查看更多'**
  String get searchMoreScopes;

  /// No description provided for @searchOverview.
  ///
  /// In zh, this message translates to:
  /// **'搜索概览'**
  String get searchOverview;

  /// No description provided for @searchStartHint.
  ///
  /// In zh, this message translates to:
  /// **'输入关键词开始搜索'**
  String get searchStartHint;

  /// No description provided for @searchCurrentScope.
  ///
  /// In zh, this message translates to:
  /// **'当前范围'**
  String get searchCurrentScope;

  /// No description provided for @searchActiveFilters.
  ///
  /// In zh, this message translates to:
  /// **'已启用筛选'**
  String get searchActiveFilters;

  /// No description provided for @searchFilterType.
  ///
  /// In zh, this message translates to:
  /// **'内容类型'**
  String get searchFilterType;

  /// No description provided for @searchFilterSort.
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get searchFilterSort;

  /// No description provided for @searchFilterTime.
  ///
  /// In zh, this message translates to:
  /// **'时间范围'**
  String get searchFilterTime;

  /// No description provided for @searchFilterAnyType.
  ///
  /// In zh, this message translates to:
  /// **'不限类型'**
  String get searchFilterAnyType;

  /// No description provided for @searchFilterAnswers.
  ///
  /// In zh, this message translates to:
  /// **'只看回答'**
  String get searchFilterAnswers;

  /// No description provided for @searchFilterArticles.
  ///
  /// In zh, this message translates to:
  /// **'只看文章'**
  String get searchFilterArticles;

  /// No description provided for @searchFilterVideos.
  ///
  /// In zh, this message translates to:
  /// **'只看视频'**
  String get searchFilterVideos;

  /// No description provided for @searchSortRelevance.
  ///
  /// In zh, this message translates to:
  /// **'综合排序'**
  String get searchSortRelevance;

  /// No description provided for @searchSortMostUpvoted.
  ///
  /// In zh, this message translates to:
  /// **'最多赞同'**
  String get searchSortMostUpvoted;

  /// No description provided for @searchSortNewest.
  ///
  /// In zh, this message translates to:
  /// **'最新发布'**
  String get searchSortNewest;

  /// No description provided for @searchTimeAny.
  ///
  /// In zh, this message translates to:
  /// **'不限时间'**
  String get searchTimeAny;

  /// No description provided for @searchTimeDay.
  ///
  /// In zh, this message translates to:
  /// **'一天内'**
  String get searchTimeDay;

  /// No description provided for @searchTimeWeek.
  ///
  /// In zh, this message translates to:
  /// **'一周内'**
  String get searchTimeWeek;

  /// No description provided for @searchTimeMonth.
  ///
  /// In zh, this message translates to:
  /// **'一月内'**
  String get searchTimeMonth;

  /// No description provided for @searchTimeThreeMonths.
  ///
  /// In zh, this message translates to:
  /// **'三月内'**
  String get searchTimeThreeMonths;

  /// No description provided for @searchTimeHalfYear.
  ///
  /// In zh, this message translates to:
  /// **'半年内'**
  String get searchTimeHalfYear;

  /// No description provided for @searchTimeYear.
  ///
  /// In zh, this message translates to:
  /// **'一年内'**
  String get searchTimeYear;

  /// No description provided for @commentAll.
  ///
  /// In zh, this message translates to:
  /// **'全部评论'**
  String get commentAll;

  /// No description provided for @commentCount.
  ///
  /// In zh, this message translates to:
  /// **'评论 {count}'**
  String commentCount(String count);

  /// No description provided for @commentDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get commentDefault;

  /// No description provided for @commentLatest.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get commentLatest;

  /// No description provided for @commentInputPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'理性发言，友善互动'**
  String get commentInputPlaceholder;

  /// No description provided for @commentReply.
  ///
  /// In zh, this message translates to:
  /// **'回复这条评论'**
  String get commentReply;

  /// No description provided for @commentPublishReply.
  ///
  /// In zh, this message translates to:
  /// **'发布你的回复'**
  String get commentPublishReply;

  /// No description provided for @commentPublishComment.
  ///
  /// In zh, this message translates to:
  /// **'发布你的评论'**
  String get commentPublishComment;

  /// No description provided for @commentReplyTo.
  ///
  /// In zh, this message translates to:
  /// **'回复 @{name}'**
  String commentReplyTo(String name);

  /// No description provided for @commentMention.
  ///
  /// In zh, this message translates to:
  /// **'提及用户'**
  String get commentMention;

  /// No description provided for @commentCollapse.
  ///
  /// In zh, this message translates to:
  /// **'收起编辑器'**
  String get commentCollapse;

  /// No description provided for @commentExpand.
  ///
  /// In zh, this message translates to:
  /// **'展开编辑器'**
  String get commentExpand;

  /// No description provided for @commentImage.
  ///
  /// In zh, this message translates to:
  /// **'图片评论'**
  String get commentImage;

  /// No description provided for @loginTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get loginTitle;

  /// No description provided for @loginAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get loginAccount;

  /// No description provided for @loginPhone.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get loginPhone;

  /// No description provided for @loginPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get loginPassword;

  /// No description provided for @loginCode.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get loginCode;

  /// No description provided for @loginContinue.
  ///
  /// In zh, this message translates to:
  /// **'同意并继续'**
  String get loginContinue;

  /// No description provided for @loginCancel.
  ///
  /// In zh, this message translates to:
  /// **'暂不同意'**
  String get loginCancel;

  /// No description provided for @loginScanSuccess.
  ///
  /// In zh, this message translates to:
  /// **'扫码登录成功'**
  String get loginScanSuccess;

  /// No description provided for @detailReadAnswer.
  ///
  /// In zh, this message translates to:
  /// **'写回答'**
  String get detailReadAnswer;

  /// No description provided for @detailRefreshAnswers.
  ///
  /// In zh, this message translates to:
  /// **'刷新回答'**
  String get detailRefreshAnswers;

  /// No description provided for @detailSearchBody.
  ///
  /// In zh, this message translates to:
  /// **'搜索正文'**
  String get detailSearchBody;

  /// No description provided for @detailReadAloud.
  ///
  /// In zh, this message translates to:
  /// **'朗读正文'**
  String get detailReadAloud;

  /// No description provided for @detailExportTxt.
  ///
  /// In zh, this message translates to:
  /// **'导出为 TXT'**
  String get detailExportTxt;

  /// No description provided for @detailExportMarkdown.
  ///
  /// In zh, this message translates to:
  /// **'导出为 Markdown'**
  String get detailExportMarkdown;

  /// No description provided for @detailExportHtml.
  ///
  /// In zh, this message translates to:
  /// **'导出为 HTML'**
  String get detailExportHtml;

  /// No description provided for @commonExitApp.
  ///
  /// In zh, this message translates to:
  /// **'再按一次退出应用'**
  String get commonExitApp;

  /// No description provided for @commonEmoji.
  ///
  /// In zh, this message translates to:
  /// **'表情'**
  String get commonEmoji;

  /// No description provided for @commonRemove.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get commonRemove;

  /// No description provided for @commonOpenZhihu.
  ///
  /// In zh, this message translates to:
  /// **'打开知乎验证'**
  String get commonOpenZhihu;

  /// No description provided for @commonExpired.
  ///
  /// In zh, this message translates to:
  /// **'过期'**
  String get commonExpired;

  /// No description provided for @commonReport.
  ///
  /// In zh, this message translates to:
  /// **'举报'**
  String get commonReport;

  /// No description provided for @commonUntitledContent.
  ///
  /// In zh, this message translates to:
  /// **'未命名内容'**
  String get commonUntitledContent;

  /// No description provided for @commonUntitledObject.
  ///
  /// In zh, this message translates to:
  /// **'未命名对象'**
  String get commonUntitledObject;

  /// No description provided for @commonAuthorProfile.
  ///
  /// In zh, this message translates to:
  /// **'查看作者个人主页'**
  String get commonAuthorProfile;

  /// No description provided for @commonZhihuUser.
  ///
  /// In zh, this message translates to:
  /// **'知乎用户'**
  String get commonZhihuUser;

  /// No description provided for @commonLike.
  ///
  /// In zh, this message translates to:
  /// **'赞同'**
  String get commonLike;

  /// No description provided for @commonUnlike.
  ///
  /// In zh, this message translates to:
  /// **'取消赞同'**
  String get commonUnlike;

  /// No description provided for @commonDislike.
  ///
  /// In zh, this message translates to:
  /// **'踩'**
  String get commonDislike;

  /// No description provided for @commonDeleteComment.
  ///
  /// In zh, this message translates to:
  /// **'删除评论'**
  String get commonDeleteComment;

  /// No description provided for @commonCommentActionFailed.
  ///
  /// In zh, this message translates to:
  /// **'评论操作失败，请稍后重试'**
  String get commonCommentActionFailed;

  /// No description provided for @commonOpenLink.
  ///
  /// In zh, this message translates to:
  /// **'打开链接'**
  String get commonOpenLink;

  /// No description provided for @commonReplyCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条回复'**
  String commonReplyCount(String count);

  /// No description provided for @commonViewAllReplies.
  ///
  /// In zh, this message translates to:
  /// **'查看全部 {count} 条回复'**
  String commonViewAllReplies(String count);

  /// No description provided for @drawerExpired.
  ///
  /// In zh, this message translates to:
  /// **'过期'**
  String get drawerExpired;

  /// No description provided for @loginHeader.
  ///
  /// In zh, this message translates to:
  /// **'登录知乎'**
  String get loginHeader;

  /// No description provided for @loginQrSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'知乎 App 扫码登录'**
  String get loginQrSubtitle;

  /// No description provided for @loginPasswordSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用账号密码安全登录'**
  String get loginPasswordSubtitle;

  /// No description provided for @loginPhoneSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'手机号快捷登录'**
  String get loginPhoneSubtitle;

  /// No description provided for @loginProgressPassword.
  ///
  /// In zh, this message translates to:
  /// **'登录进度：账号密码'**
  String get loginProgressPassword;

  /// No description provided for @loginProgressCode.
  ///
  /// In zh, this message translates to:
  /// **'登录进度：验证码'**
  String get loginProgressCode;

  /// No description provided for @loginProgressPhone.
  ///
  /// In zh, this message translates to:
  /// **'登录进度：手机号'**
  String get loginProgressPhone;

  /// No description provided for @loginAgreementTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录前请确认'**
  String get loginAgreementTitle;

  /// No description provided for @loginAgreementMessage.
  ///
  /// In zh, this message translates to:
  /// **'请阅读并同意《知乎用户协议》与隐私政策后继续登录。'**
  String get loginAgreementMessage;

  /// No description provided for @loginQrLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在获取二维码'**
  String get loginQrLoading;

  /// No description provided for @loginQrInvalid.
  ///
  /// In zh, this message translates to:
  /// **'知乎没有返回有效二维码'**
  String get loginQrInvalid;

  /// No description provided for @loginQrScanHint.
  ///
  /// In zh, this message translates to:
  /// **'请打开知乎 App 扫一扫'**
  String get loginQrScanHint;

  /// No description provided for @loginQrFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'二维码获取失败：{error}'**
  String loginQrFetchFailed(String error);

  /// No description provided for @loginQrExpired.
  ///
  /// In zh, this message translates to:
  /// **'二维码已过期，请点击刷新'**
  String get loginQrExpired;

  /// No description provided for @loginQrRiskControl.
  ///
  /// In zh, this message translates to:
  /// **'需要先在知乎网页完成安全验证，请稍后刷新二维码'**
  String get loginQrRiskControl;

  /// No description provided for @loginQrConfirm.
  ///
  /// In zh, this message translates to:
  /// **'请在知乎 App 上确认登录'**
  String get loginQrConfirm;

  /// No description provided for @loginVerifying.
  ///
  /// In zh, this message translates to:
  /// **'正在验证登录'**
  String get loginVerifying;

  /// No description provided for @loginSuccess.
  ///
  /// In zh, this message translates to:
  /// **'登录成功'**
  String get loginSuccess;

  /// No description provided for @loginQrLabel.
  ///
  /// In zh, this message translates to:
  /// **'知乎登录二维码'**
  String get loginQrLabel;

  /// No description provided for @loginRefreshQr.
  ///
  /// In zh, this message translates to:
  /// **'刷新二维码'**
  String get loginRefreshQr;

  /// No description provided for @loginQrHint.
  ///
  /// In zh, this message translates to:
  /// **'二维码有效期内可在其他设备确认登录；登录成功后会保留当前账号槽位。'**
  String get loginQrHint;

  /// No description provided for @feedbackNotInterested.
  ///
  /// In zh, this message translates to:
  /// **'不喜欢该内容'**
  String get feedbackNotInterested;

  /// No description provided for @feedbackReduceRecommendation.
  ///
  /// In zh, this message translates to:
  /// **'将减少推荐'**
  String get feedbackReduceRecommendation;

  /// No description provided for @feedbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'减少此类内容'**
  String get feedbackTitle;

  /// No description provided for @feedbackReduced.
  ///
  /// In zh, this message translates to:
  /// **'已减少此类内容'**
  String get feedbackReduced;

  /// No description provided for @feedbackInvalidReport.
  ///
  /// In zh, this message translates to:
  /// **'举报地址无效'**
  String get feedbackInvalidReport;

  /// No description provided for @feedbackMissingAction.
  ///
  /// In zh, this message translates to:
  /// **'该反馈项缺少可执行动作'**
  String get feedbackMissingAction;

  /// No description provided for @feedbackLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载更多反馈选项…'**
  String get feedbackLoading;

  /// No description provided for @feedbackReload.
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get feedbackReload;

  /// No description provided for @accountSessionCheckTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认登录状态'**
  String get accountSessionCheckTitle;

  /// No description provided for @accountSessionCheckMessage.
  ///
  /// In zh, this message translates to:
  /// **'知乎返回了账号会话异常信号。当前登录信息仍保留在本机，是否清理？'**
  String get accountSessionCheckMessage;

  /// No description provided for @accountSessionCheckDetails.
  ///
  /// In zh, this message translates to:
  /// **'确认清理后仍可在“设置 > 账号与多端登录”中恢复最近一次会话；彻底删除需要再次手动确认。'**
  String get accountSessionCheckDetails;

  /// No description provided for @accountSessionClearKeepBackup.
  ///
  /// In zh, this message translates to:
  /// **'清理并保留恢复副本'**
  String get accountSessionClearKeepBackup;

  /// No description provided for @accountSessionKeep.
  ///
  /// In zh, this message translates to:
  /// **'保留登录状态'**
  String get accountSessionKeep;

  /// No description provided for @settingsDisableSearchHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭搜索记录？'**
  String get settingsDisableSearchHistoryTitle;

  /// No description provided for @settingsDisableSearchHistoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'关闭后会同时清空本机已有的搜索记录。'**
  String get settingsDisableSearchHistoryMessage;

  /// No description provided for @settingsDisableAndClear.
  ///
  /// In zh, this message translates to:
  /// **'关闭并清空'**
  String get settingsDisableAndClear;

  /// No description provided for @settingsNoSearchHistoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'目前没有搜索记录'**
  String get settingsNoSearchHistoryMessage;

  /// No description provided for @settingsClearSearchHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空搜索记录？'**
  String get settingsClearSearchHistoryTitle;

  /// No description provided for @settingsClearSearchHistoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'这只会删除保存在本机的搜索关键词。'**
  String get settingsClearSearchHistoryMessage;

  /// No description provided for @settingsSearchHistoryCleared.
  ///
  /// In zh, this message translates to:
  /// **'搜索记录已清空'**
  String get settingsSearchHistoryCleared;

  /// No description provided for @settingsDisableBrowsingHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭浏览记录？'**
  String get settingsDisableBrowsingHistoryTitle;

  /// No description provided for @settingsDisableBrowsingHistoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'关闭后会同时清空知阅保存在本机的浏览记录。'**
  String get settingsDisableBrowsingHistoryMessage;

  /// No description provided for @settingsNoBrowsingHistoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'目前没有浏览记录'**
  String get settingsNoBrowsingHistoryMessage;

  /// No description provided for @settingsClearBrowsingHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空浏览记录？'**
  String get settingsClearBrowsingHistoryTitle;

  /// No description provided for @settingsClearBrowsingHistoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'这只会删除知阅保存在本机的浏览内容索引。'**
  String get settingsClearBrowsingHistoryMessage;

  /// No description provided for @settingsBrowsingHistoryCleared.
  ///
  /// In zh, this message translates to:
  /// **'浏览记录已清空'**
  String get settingsBrowsingHistoryCleared;

  /// No description provided for @settingsClearOfflineTitle.
  ///
  /// In zh, this message translates to:
  /// **'清理离线章节？'**
  String get settingsClearOfflineTitle;

  /// No description provided for @settingsClearOfflineMessage.
  ///
  /// In zh, this message translates to:
  /// **'已缓存的盐选正文将被删除，之后阅读或导出时需要重新下载。'**
  String get settingsClearOfflineMessage;

  /// No description provided for @settingsClearOfflineAction.
  ///
  /// In zh, this message translates to:
  /// **'清理'**
  String get settingsClearOfflineAction;

  /// No description provided for @settingsOfflineCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清理 {count} 个离线章节'**
  String settingsOfflineCleared(int count);

  /// No description provided for @settingsOfflineClearFailed.
  ///
  /// In zh, this message translates to:
  /// **'离线章节清理失败，请重试'**
  String get settingsOfflineClearFailed;

  /// No description provided for @settingsCacheSummary.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张 · {size} MB'**
  String settingsCacheSummary(int count, String size);

  /// No description provided for @commentEmoji.
  ///
  /// In zh, this message translates to:
  /// **'表情'**
  String get commentEmoji;

  /// No description provided for @commentRemoveSticker.
  ///
  /// In zh, this message translates to:
  /// **'移除贴纸'**
  String get commentRemoveSticker;

  /// No description provided for @commentSelectedImage.
  ///
  /// In zh, this message translates to:
  /// **'已选择的评论图片'**
  String get commentSelectedImage;

  /// No description provided for @commentUploadingImage.
  ///
  /// In zh, this message translates to:
  /// **'正在上传图片…'**
  String get commentUploadingImage;

  /// No description provided for @commentImageAdded.
  ///
  /// In zh, this message translates to:
  /// **'图片已添加'**
  String get commentImageAdded;

  /// No description provided for @commentRemoveImage.
  ///
  /// In zh, this message translates to:
  /// **'移除图片'**
  String get commentRemoveImage;

  /// No description provided for @commentUsernameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名完成提及'**
  String get commentUsernameRequired;

  /// No description provided for @commentMentioned.
  ///
  /// In zh, this message translates to:
  /// **'已提及 {name}'**
  String commentMentioned(String name);

  /// No description provided for @commentLoadingGift.
  ///
  /// In zh, this message translates to:
  /// **'正在加载礼物'**
  String get commentLoadingGift;

  /// No description provided for @commentNoGifts.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用礼物'**
  String get commentNoGifts;

  /// No description provided for @commentImageAddedPending.
  ///
  /// In zh, this message translates to:
  /// **'图片已添加，登录后可发布'**
  String get commentImageAddedPending;

  /// No description provided for @commentSignInRequired.
  ///
  /// In zh, this message translates to:
  /// **'请先登录后再发布'**
  String get commentSignInRequired;

  /// No description provided for @commentUploadSignInRequired.
  ///
  /// In zh, this message translates to:
  /// **'请先登录后再发布图片'**
  String get commentUploadSignInRequired;

  /// No description provided for @commentImageUploadNoUrl.
  ///
  /// In zh, this message translates to:
  /// **'图片上传未返回地址'**
  String get commentImageUploadNoUrl;

  /// No description provided for @commentImagesCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张评论图片'**
  String commentImagesCount(int count);

  /// No description provided for @commentViewImage.
  ///
  /// In zh, this message translates to:
  /// **'查看评论图片'**
  String get commentViewImage;

  /// No description provided for @commentCloseImage.
  ///
  /// In zh, this message translates to:
  /// **'关闭图片'**
  String get commentCloseImage;

  /// No description provided for @commentSaveImage.
  ///
  /// In zh, this message translates to:
  /// **'保存到相册'**
  String get commentSaveImage;

  /// No description provided for @commentSavedTo.
  ///
  /// In zh, this message translates to:
  /// **'已保存到 {location}'**
  String commentSavedTo(String location);

  /// No description provided for @commentSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片保存失败，请稍后重试'**
  String get commentSaveFailed;

  /// No description provided for @commentReportUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'举报功能暂未开放'**
  String get commentReportUnavailable;

  /// No description provided for @commentNoText.
  ///
  /// In zh, this message translates to:
  /// **'该评论没有可显示的文字内容'**
  String get commentNoText;

  /// No description provided for @commentAuthorBadge.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get commentAuthorBadge;

  /// No description provided for @commentQuestionAuthor.
  ///
  /// In zh, this message translates to:
  /// **'题主'**
  String get commentQuestionAuthor;

  /// No description provided for @commentAuthorSemantics.
  ///
  /// In zh, this message translates to:
  /// **'评论作者 {name}'**
  String commentAuthorSemantics(String name);

  /// No description provided for @feedHotBadge.
  ///
  /// In zh, this message translates to:
  /// **'热榜'**
  String get feedHotBadge;

  /// No description provided for @metricVoteup.
  ///
  /// In zh, this message translates to:
  /// **'赞同 {count}'**
  String metricVoteup(String count);

  /// No description provided for @metricFavorite.
  ///
  /// In zh, this message translates to:
  /// **'收藏 {count}'**
  String metricFavorite(String count);

  /// No description provided for @metricComment.
  ///
  /// In zh, this message translates to:
  /// **'评论 {count}'**
  String metricComment(String count);

  /// No description provided for @metricThanks.
  ///
  /// In zh, this message translates to:
  /// **'感谢 {count}'**
  String metricThanks(String count);

  /// No description provided for @metricViews.
  ///
  /// In zh, this message translates to:
  /// **'浏览 {count}'**
  String metricViews(String count);

  /// No description provided for @metricThanked.
  ///
  /// In zh, this message translates to:
  /// **'已感谢该回答'**
  String get metricThanked;

  /// No description provided for @metricFavorited.
  ///
  /// In zh, this message translates to:
  /// **'已收藏该回答'**
  String get metricFavorited;

  /// No description provided for @metricFollowers.
  ///
  /// In zh, this message translates to:
  /// **'{count} 位关注者'**
  String metricFollowers(String count);

  /// No description provided for @metricAnswers.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个回答'**
  String metricAnswers(String count);

  /// No description provided for @metricArticles.
  ///
  /// In zh, this message translates to:
  /// **'{count} 篇文章'**
  String metricArticles(String count);

  /// No description provided for @metricItems.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条内容'**
  String metricItems(String count);

  /// No description provided for @contentTypeAnswer.
  ///
  /// In zh, this message translates to:
  /// **'回答'**
  String get contentTypeAnswer;

  /// No description provided for @contentTypeArticle.
  ///
  /// In zh, this message translates to:
  /// **'文章'**
  String get contentTypeArticle;

  /// No description provided for @contentTypePeople.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get contentTypePeople;

  /// No description provided for @contentTypeQuestion.
  ///
  /// In zh, this message translates to:
  /// **'问题'**
  String get contentTypeQuestion;

  /// No description provided for @contentTypeColumn.
  ///
  /// In zh, this message translates to:
  /// **'专栏'**
  String get contentTypeColumn;

  /// No description provided for @contentTypeTopic.
  ///
  /// In zh, this message translates to:
  /// **'话题'**
  String get contentTypeTopic;

  /// No description provided for @contentTypeIdea.
  ///
  /// In zh, this message translates to:
  /// **'想法'**
  String get contentTypeIdea;

  /// No description provided for @contentTypeComment.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get contentTypeComment;

  /// No description provided for @accountSwitchedTo.
  ///
  /// In zh, this message translates to:
  /// **'已切换到 {name}'**
  String accountSwitchedTo(String name);

  /// No description provided for @accountSessionRestoreFailed.
  ///
  /// In zh, this message translates to:
  /// **'账号会话验证失败，已恢复之前的登录状态'**
  String get accountSessionRestoreFailed;

  /// No description provided for @collectionsLoginRequired.
  ///
  /// In zh, this message translates to:
  /// **'登录知乎后可以查看自己的收藏'**
  String get collectionsLoginRequired;

  /// No description provided for @collectionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的收藏'**
  String get collectionsTitle;

  /// No description provided for @collectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'收藏集'**
  String get collectionTitle;

  /// No description provided for @collectionEmpty.
  ///
  /// In zh, this message translates to:
  /// **'这个收藏集暂时没有内容'**
  String get collectionEmpty;

  /// No description provided for @collectionsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有创建或收藏内容'**
  String get collectionsEmpty;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get loginPasswordRequired;

  /// No description provided for @loginQrSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'扫码登录成功，但账号槽位保存失败，请稍后重试'**
  String get loginQrSaveFailed;

  /// No description provided for @loginHumanVerification.
  ///
  /// In zh, this message translates to:
  /// **'请先完成人机验证'**
  String get loginHumanVerification;

  /// No description provided for @loginCodeSendFailed.
  ///
  /// In zh, this message translates to:
  /// **'验证码发送失败，请稍后重试'**
  String get loginCodeSendFailed;

  /// No description provided for @loginFailedNetwork.
  ///
  /// In zh, this message translates to:
  /// **'登录失败，请检查网络后重试'**
  String get loginFailedNetwork;

  /// No description provided for @loginFailedCredentials.
  ///
  /// In zh, this message translates to:
  /// **'登录失败，请检查账号和密码后重试'**
  String get loginFailedCredentials;

  /// No description provided for @loginGetCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get loginGetCode;

  /// No description provided for @loginContinueSignIn.
  ///
  /// In zh, this message translates to:
  /// **'继续登录'**
  String get loginContinueSignIn;

  /// No description provided for @loginPasswordSignIn.
  ///
  /// In zh, this message translates to:
  /// **'账号密码登录'**
  String get loginPasswordSignIn;

  /// No description provided for @loginPhoneSignIn.
  ///
  /// In zh, this message translates to:
  /// **'手机号登录'**
  String get loginPhoneSignIn;

  /// No description provided for @loginQrSignIn.
  ///
  /// In zh, this message translates to:
  /// **'扫码登录'**
  String get loginQrSignIn;

  /// No description provided for @loginAccountAppeal.
  ///
  /// In zh, this message translates to:
  /// **'账号申诉'**
  String get loginAccountAppeal;

  /// No description provided for @loginAccountAppealHint.
  ///
  /// In zh, this message translates to:
  /// **'遇到问题？账号申诉'**
  String get loginAccountAppealHint;

  /// No description provided for @loginPhonePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'国家/地区代码 + 手机号'**
  String get loginPhonePlaceholder;

  /// No description provided for @loginAccountPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'手机号 / 邮箱'**
  String get loginAccountPlaceholder;

  /// No description provided for @loginPasswordPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get loginPasswordPlaceholder;

  /// No description provided for @loginCodePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'输入 6 位验证码'**
  String get loginCodePlaceholder;

  /// No description provided for @loginCodeSent.
  ///
  /// In zh, this message translates to:
  /// **'验证码已发送至 {phone}'**
  String loginCodeSent(String phone);

  /// No description provided for @loginChangePhone.
  ///
  /// In zh, this message translates to:
  /// **'更换手机号'**
  String get loginChangePhone;

  /// No description provided for @loginNoCode.
  ///
  /// In zh, this message translates to:
  /// **'没有收到？'**
  String get loginNoCode;

  /// No description provided for @loginResendAfter.
  ///
  /// In zh, this message translates to:
  /// **'{seconds}s 后重试'**
  String loginResendAfter(int seconds);

  /// No description provided for @loginAgree.
  ///
  /// In zh, this message translates to:
  /// **'同意'**
  String get loginAgree;

  /// No description provided for @loginUserAgreement.
  ///
  /// In zh, this message translates to:
  /// **'《知乎用户协议》'**
  String get loginUserAgreement;

  /// No description provided for @loginPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'与隐私政策'**
  String get loginPrivacyPolicy;

  /// No description provided for @commonSelected.
  ///
  /// In zh, this message translates to:
  /// **'，已选择'**
  String get commonSelected;

  /// No description provided for @searchSuggestion.
  ///
  /// In zh, this message translates to:
  /// **'搜索补全'**
  String get searchSuggestion;

  /// No description provided for @searchSuggestionFor.
  ///
  /// In zh, this message translates to:
  /// **'搜索建议 {query}'**
  String searchSuggestionFor(String query);

  /// No description provided for @searchSearching.
  ///
  /// In zh, this message translates to:
  /// **'正在查找“{query}”'**
  String searchSearching(String query);

  /// No description provided for @searchDesktopHint.
  ///
  /// In zh, this message translates to:
  /// **'滚动结果列表加载更多，点击卡片查看详情。'**
  String get searchDesktopHint;

  /// No description provided for @searchRelated.
  ///
  /// In zh, this message translates to:
  /// **'相关搜索'**
  String get searchRelated;

  /// No description provided for @searchRecentContent.
  ///
  /// In zh, this message translates to:
  /// **'近期内容'**
  String get searchRecentContent;

  /// No description provided for @searchContinue.
  ///
  /// In zh, this message translates to:
  /// **'继续查找'**
  String get searchContinue;

  /// No description provided for @searchUntitledNovel.
  ///
  /// In zh, this message translates to:
  /// **'未命名小说'**
  String get searchUntitledNovel;

  /// No description provided for @searchUntitledVideo.
  ///
  /// In zh, this message translates to:
  /// **'未命名视频'**
  String get searchUntitledVideo;

  /// No description provided for @searchMetricFollows.
  ///
  /// In zh, this message translates to:
  /// **'{count} 关注'**
  String searchMetricFollows(String count);

  /// No description provided for @searchMetricQuestions.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个问题'**
  String searchMetricQuestions(String count);

  /// No description provided for @searchMetricMembers.
  ///
  /// In zh, this message translates to:
  /// **'{count} 成员'**
  String searchMetricMembers(String count);

  /// No description provided for @searchMetricDiscussions.
  ///
  /// In zh, this message translates to:
  /// **'{count} 讨论'**
  String searchMetricDiscussions(String count);

  /// No description provided for @searchMetricParticipants.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人参与'**
  String searchMetricParticipants(String count);

  /// No description provided for @searchMetricLiveContent.
  ///
  /// In zh, this message translates to:
  /// **'{count} 场内容'**
  String searchMetricLiveContent(String count);

  /// No description provided for @searchMetricPlayCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次播放'**
  String searchMetricPlayCount(String count);

  /// No description provided for @searchHotScoreWan.
  ///
  /// In zh, this message translates to:
  /// **'{value} 万'**
  String searchHotScoreWan(String value);

  /// No description provided for @userTitle.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get userTitle;

  /// No description provided for @userProfileTitle.
  ///
  /// In zh, this message translates to:
  /// **'用户主页'**
  String get userProfileTitle;

  /// No description provided for @userFindTitle.
  ///
  /// In zh, this message translates to:
  /// **'查找用户'**
  String get userFindTitle;

  /// No description provided for @userFindSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'输入资料链接中的用户 token，查看公开资料与内容列表'**
  String get userFindSubtitle;

  /// No description provided for @userIdHint.
  ///
  /// In zh, this message translates to:
  /// **'用户 ID'**
  String get userIdHint;

  /// No description provided for @userViewProfile.
  ///
  /// In zh, this message translates to:
  /// **'查看用户资料'**
  String get userViewProfile;

  /// No description provided for @userContentRelations.
  ///
  /// In zh, this message translates to:
  /// **'内容与关系'**
  String get userContentRelations;

  /// No description provided for @userEmpty.
  ///
  /// In zh, this message translates to:
  /// **'这里还没有用户'**
  String get userEmpty;

  /// No description provided for @userSignInToFollow.
  ///
  /// In zh, this message translates to:
  /// **'登录后可关注用户'**
  String get userSignInToFollow;

  /// No description provided for @userFollowed.
  ///
  /// In zh, this message translates to:
  /// **'已关注'**
  String get userFollowed;

  /// No description provided for @userFollow.
  ///
  /// In zh, this message translates to:
  /// **'＋ 关注'**
  String get userFollow;

  /// No description provided for @userSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索 {name} 发布的内容'**
  String userSearchHint(String name);

  /// No description provided for @userSearchPrompt.
  ///
  /// In zh, this message translates to:
  /// **'搜索 {name} 发布过的回答、文章和想法'**
  String userSearchPrompt(String name);

  /// No description provided for @userNoResults.
  ///
  /// In zh, this message translates to:
  /// **'没有找到相关内容'**
  String get userNoResults;

  /// No description provided for @userLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法打开用户资料'**
  String get userLoadFailed;

  /// No description provided for @userInfo.
  ///
  /// In zh, this message translates to:
  /// **'用户信息'**
  String get userInfo;

  /// No description provided for @userFollowers.
  ///
  /// In zh, this message translates to:
  /// **'关注者'**
  String get userFollowers;

  /// No description provided for @userFollowingPeople.
  ///
  /// In zh, this message translates to:
  /// **'关注的人'**
  String get userFollowingPeople;

  /// No description provided for @userAnswers.
  ///
  /// In zh, this message translates to:
  /// **'用户回答'**
  String get userAnswers;

  /// No description provided for @userArticles.
  ///
  /// In zh, this message translates to:
  /// **'用户文章'**
  String get userArticles;

  /// No description provided for @userCreatedArticles.
  ///
  /// In zh, this message translates to:
  /// **'用户创作文章'**
  String get userCreatedArticles;

  /// No description provided for @userContributedArticles.
  ///
  /// In zh, this message translates to:
  /// **'用户贡献文章'**
  String get userContributedArticles;

  /// No description provided for @userColumns.
  ///
  /// In zh, this message translates to:
  /// **'用户专栏'**
  String get userColumns;

  /// No description provided for @userFollowingColumns.
  ///
  /// In zh, this message translates to:
  /// **'关注专栏'**
  String get userFollowingColumns;

  /// No description provided for @userFollowingQuestions.
  ///
  /// In zh, this message translates to:
  /// **'关注问题'**
  String get userFollowingQuestions;

  /// No description provided for @userFollowingCollections.
  ///
  /// In zh, this message translates to:
  /// **'关注收藏集'**
  String get userFollowingCollections;

  /// No description provided for @userFollowingTopics.
  ///
  /// In zh, this message translates to:
  /// **'关注话题'**
  String get userFollowingTopics;

  /// No description provided for @userIdRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户 ID'**
  String get userIdRequired;

  /// No description provided for @sessionTitle.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get sessionTitle;

  /// No description provided for @sessionSignInZhihu.
  ///
  /// In zh, this message translates to:
  /// **'登录知乎'**
  String get sessionSignInZhihu;

  /// No description provided for @sessionPhoneLogin.
  ///
  /// In zh, this message translates to:
  /// **'手机号登录'**
  String get sessionPhoneLogin;

  /// No description provided for @sessionWebLogin.
  ///
  /// In zh, this message translates to:
  /// **'网页登录'**
  String get sessionWebLogin;

  /// No description provided for @sessionSaved.
  ///
  /// In zh, this message translates to:
  /// **'登录信息已保存'**
  String get sessionSaved;

  /// No description provided for @sessionCleared.
  ///
  /// In zh, this message translates to:
  /// **'登录信息已清除'**
  String get sessionCleared;

  /// No description provided for @sessionImport.
  ///
  /// In zh, this message translates to:
  /// **'导入登录信息'**
  String get sessionImport;

  /// No description provided for @sessionShowSensitive.
  ///
  /// In zh, this message translates to:
  /// **'临时显示敏感值'**
  String get sessionShowSensitive;

  /// No description provided for @sessionHideSensitive.
  ///
  /// In zh, this message translates to:
  /// **'重新隐藏敏感值'**
  String get sessionHideSensitive;

  /// No description provided for @sessionAdvanced.
  ///
  /// In zh, this message translates to:
  /// **'高级设置'**
  String get sessionAdvanced;

  /// No description provided for @sessionOptionalCookie.
  ///
  /// In zh, this message translates to:
  /// **'Cookie（可选）'**
  String get sessionOptionalCookie;

  /// No description provided for @sessionOptionalMsId.
  ///
  /// In zh, this message translates to:
  /// **'X-MS-ID（可选）'**
  String get sessionOptionalMsId;

  /// No description provided for @sessionManualZse.
  ///
  /// In zh, this message translates to:
  /// **'手工 X-Zse-96'**
  String get sessionManualZse;

  /// No description provided for @sessionSignTarget.
  ///
  /// In zh, this message translates to:
  /// **'签名目标'**
  String get sessionSignTarget;

  /// No description provided for @sessionOtherHeaders.
  ///
  /// In zh, this message translates to:
  /// **'其他 Header'**
  String get sessionOtherHeaders;

  /// No description provided for @sessionSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中…'**
  String get sessionSaving;

  /// No description provided for @sessionSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get sessionSave;

  /// No description provided for @sessionClear.
  ///
  /// In zh, this message translates to:
  /// **'清除登录信息'**
  String get sessionClear;

  /// No description provided for @contentTypeContent.
  ///
  /// In zh, this message translates to:
  /// **'内容'**
  String get contentTypeContent;

  /// No description provided for @userProfileSearchContent.
  ///
  /// In zh, this message translates to:
  /// **'搜索 TA 的内容'**
  String get userProfileSearchContent;

  /// No description provided for @userProfileCopyLink.
  ///
  /// In zh, this message translates to:
  /// **'复制主页链接'**
  String get userProfileCopyLink;

  /// No description provided for @userProfileHomeTab.
  ///
  /// In zh, this message translates to:
  /// **'主页'**
  String get userProfileHomeTab;

  /// No description provided for @userProfileCreationsTab.
  ///
  /// In zh, this message translates to:
  /// **'创作'**
  String get userProfileCreationsTab;

  /// No description provided for @userProfileActivitiesTab.
  ///
  /// In zh, this message translates to:
  /// **'动态'**
  String get userProfileActivitiesTab;

  /// No description provided for @userProfileVoteupsTab.
  ///
  /// In zh, this message translates to:
  /// **'赞同'**
  String get userProfileVoteupsTab;

  /// No description provided for @userProfileFollowersList.
  ///
  /// In zh, this message translates to:
  /// **'关注他的人'**
  String get userProfileFollowersList;

  /// No description provided for @userProfileFollowingList.
  ///
  /// In zh, this message translates to:
  /// **'他关注的人'**
  String get userProfileFollowingList;

  /// No description provided for @userProfileLoginRequired.
  ///
  /// In zh, this message translates to:
  /// **'登录后可使用此功能'**
  String get userProfileLoginRequired;

  /// No description provided for @userProfileUnfollowTitle.
  ///
  /// In zh, this message translates to:
  /// **'取消关注？'**
  String get userProfileUnfollowTitle;

  /// No description provided for @userProfileUnfollowMessage.
  ///
  /// In zh, this message translates to:
  /// **'将不再关注 {name}'**
  String userProfileUnfollowMessage(String name);

  /// No description provided for @userProfileUnfollowAction.
  ///
  /// In zh, this message translates to:
  /// **'取消关注'**
  String get userProfileUnfollowAction;

  /// No description provided for @userProfileLinkCopied.
  ///
  /// In zh, this message translates to:
  /// **'主页链接已复制'**
  String get userProfileLinkCopied;

  /// No description provided for @userProfileIpLocation.
  ///
  /// In zh, this message translates to:
  /// **'IP 属地 {location}'**
  String userProfileIpLocation(String location);

  /// No description provided for @userProfileFollowers.
  ///
  /// In zh, this message translates to:
  /// **'关注者'**
  String get userProfileFollowers;

  /// No description provided for @userProfileFollowing.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get userProfileFollowing;

  /// No description provided for @userProfileUserAnswers.
  ///
  /// In zh, this message translates to:
  /// **'用户回答'**
  String get userProfileUserAnswers;

  /// No description provided for @userProfileUserArticles.
  ///
  /// In zh, this message translates to:
  /// **'用户文章'**
  String get userProfileUserArticles;

  /// No description provided for @userProfileCreatedArticles.
  ///
  /// In zh, this message translates to:
  /// **'创作文章'**
  String get userProfileCreatedArticles;

  /// No description provided for @userProfileUserCreatedArticles.
  ///
  /// In zh, this message translates to:
  /// **'用户创作文章'**
  String get userProfileUserCreatedArticles;

  /// No description provided for @userProfileContributedArticles.
  ///
  /// In zh, this message translates to:
  /// **'贡献文章'**
  String get userProfileContributedArticles;

  /// No description provided for @userProfileUserContributedArticles.
  ///
  /// In zh, this message translates to:
  /// **'用户贡献文章'**
  String get userProfileUserContributedArticles;

  /// No description provided for @userProfileCreatedColumns.
  ///
  /// In zh, this message translates to:
  /// **'创建的专栏'**
  String get userProfileCreatedColumns;

  /// No description provided for @userProfileUserColumns.
  ///
  /// In zh, this message translates to:
  /// **'用户专栏'**
  String get userProfileUserColumns;

  /// No description provided for @userProfileFollowingColumns.
  ///
  /// In zh, this message translates to:
  /// **'关注专栏'**
  String get userProfileFollowingColumns;

  /// No description provided for @userProfileFollowingQuestions.
  ///
  /// In zh, this message translates to:
  /// **'关注问题'**
  String get userProfileFollowingQuestions;

  /// No description provided for @userProfileFollowingCollections.
  ///
  /// In zh, this message translates to:
  /// **'关注收藏集'**
  String get userProfileFollowingCollections;

  /// No description provided for @userProfileFollowingTopics.
  ///
  /// In zh, this message translates to:
  /// **'关注话题'**
  String get userProfileFollowingTopics;

  /// No description provided for @userProfileReceivedUpvotes.
  ///
  /// In zh, this message translates to:
  /// **'获赞'**
  String get userProfileReceivedUpvotes;

  /// No description provided for @userProfileReceivedThanks.
  ///
  /// In zh, this message translates to:
  /// **'获感谢'**
  String get userProfileReceivedThanks;

  /// No description provided for @userProfileReceivedFavorites.
  ///
  /// In zh, this message translates to:
  /// **'获收藏'**
  String get userProfileReceivedFavorites;

  /// No description provided for @userProfilePersonalInfo.
  ///
  /// In zh, this message translates to:
  /// **'个人资料'**
  String get userProfilePersonalInfo;

  /// No description provided for @userProfileAchievements.
  ///
  /// In zh, this message translates to:
  /// **'个人成就'**
  String get userProfileAchievements;

  /// No description provided for @userProfilePublicCreations.
  ///
  /// In zh, this message translates to:
  /// **'公开创作'**
  String get userProfilePublicCreations;

  /// No description provided for @userProfileFollowingAndCollections.
  ///
  /// In zh, this message translates to:
  /// **'关注与收藏'**
  String get userProfileFollowingAndCollections;

  /// No description provided for @userProfileFollowingHidden.
  ///
  /// In zh, this message translates to:
  /// **'对方已隐藏关注列表'**
  String get userProfileFollowingHidden;

  /// No description provided for @userProfileFollowedYou.
  ///
  /// In zh, this message translates to:
  /// **'关注了你'**
  String get userProfileFollowedYou;

  /// No description provided for @userProfileMutualFollow.
  ///
  /// In zh, this message translates to:
  /// **'互相关注'**
  String get userProfileMutualFollow;

  /// No description provided for @userProfileMessage.
  ///
  /// In zh, this message translates to:
  /// **'私信'**
  String get userProfileMessage;

  /// No description provided for @userProfileNoPublicContent.
  ///
  /// In zh, this message translates to:
  /// **'还没有公开内容'**
  String get userProfileNoPublicContent;

  /// No description provided for @webdavTitle.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 同步'**
  String get webdavTitle;

  /// No description provided for @webdavIntroTitle.
  ///
  /// In zh, this message translates to:
  /// **'跨设备同步本地内容'**
  String get webdavIntroTitle;

  /// No description provided for @webdavIntroMessage.
  ///
  /// In zh, this message translates to:
  /// **'只同步搜索记录、浏览历史、盐选离线章节/书架和回答详情缓存。登录凭据、Cookie、设备标识与本设置不会上传。'**
  String get webdavIntroMessage;

  /// No description provided for @webdavConnectionSettings.
  ///
  /// In zh, this message translates to:
  /// **'连接设置'**
  String get webdavConnectionSettings;

  /// No description provided for @webdavProviderType.
  ///
  /// In zh, this message translates to:
  /// **'服务类型'**
  String get webdavProviderType;

  /// No description provided for @webdavProviderGeneric.
  ///
  /// In zh, this message translates to:
  /// **'通用 WebDAV'**
  String get webdavProviderGeneric;

  /// No description provided for @webdavProviderGoogle.
  ///
  /// In zh, this message translates to:
  /// **'Google Drive（WebDAV 网关）'**
  String get webdavProviderGoogle;

  /// No description provided for @webdavProviderOneDrive.
  ///
  /// In zh, this message translates to:
  /// **'Microsoft OneDrive（WebDAV）'**
  String get webdavProviderOneDrive;

  /// No description provided for @webdavProviderGenericDescription.
  ///
  /// In zh, this message translates to:
  /// **'适用于支持 WebDAV 的云盘、NAS 和自建服务。'**
  String get webdavProviderGenericDescription;

  /// No description provided for @webdavProviderGoogleDescription.
  ///
  /// In zh, this message translates to:
  /// **'Google Drive 本身不提供原生 WebDAV，请填写连接到 Google Drive 的 WebDAV 网关地址。'**
  String get webdavProviderGoogleDescription;

  /// No description provided for @webdavProviderOneDriveDescription.
  ///
  /// In zh, this message translates to:
  /// **'填写 OneDrive 的 WebDAV 兼容入口；部分账号或服务可能已限制旧版入口。'**
  String get webdavProviderOneDriveDescription;

  /// No description provided for @webdavProviderGenericHint.
  ///
  /// In zh, this message translates to:
  /// **'https://dav.example.com/'**
  String get webdavProviderGenericHint;

  /// No description provided for @webdavProviderGoogleHint.
  ///
  /// In zh, this message translates to:
  /// **'https://gateway.example.com/dav/'**
  String get webdavProviderGoogleHint;

  /// No description provided for @webdavProviderOneDriveHint.
  ///
  /// In zh, this message translates to:
  /// **'https://d.docs.live.net/<CID>/'**
  String get webdavProviderOneDriveHint;

  /// No description provided for @webdavEndpoint.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 地址'**
  String get webdavEndpoint;

  /// No description provided for @webdavHttpsHint.
  ///
  /// In zh, this message translates to:
  /// **'仅支持 HTTPS，不要把密码写进 URL'**
  String get webdavHttpsHint;

  /// No description provided for @webdavRemoteDirectory.
  ///
  /// In zh, this message translates to:
  /// **'远程目录'**
  String get webdavRemoteDirectory;

  /// No description provided for @webdavRemoteDirectoryHint.
  ///
  /// In zh, this message translates to:
  /// **'会自动创建 v1、answers 和 chapters 子目录'**
  String get webdavRemoteDirectoryHint;

  /// No description provided for @webdavAuthMethod.
  ///
  /// In zh, this message translates to:
  /// **'认证方式'**
  String get webdavAuthMethod;

  /// No description provided for @webdavAuthBasic.
  ///
  /// In zh, this message translates to:
  /// **'账号密码 / 应用专用密码'**
  String get webdavAuthBasic;

  /// No description provided for @webdavAuthBearer.
  ///
  /// In zh, this message translates to:
  /// **'Bearer 访问令牌'**
  String get webdavAuthBearer;

  /// No description provided for @webdavUsername.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get webdavUsername;

  /// No description provided for @webdavPasswordOrAppPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码 / 应用专用密码'**
  String get webdavPasswordOrAppPassword;

  /// No description provided for @webdavAccessToken.
  ///
  /// In zh, this message translates to:
  /// **'访问令牌'**
  String get webdavAccessToken;

  /// No description provided for @webdavEnable.
  ///
  /// In zh, this message translates to:
  /// **'启用 WebDAV 同步'**
  String get webdavEnable;

  /// No description provided for @webdavEnableSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭后不会执行网络同步，已保存的本机配置不会删除'**
  String get webdavEnableSubtitle;

  /// No description provided for @webdavStartupSync.
  ///
  /// In zh, this message translates to:
  /// **'启动后自动同步'**
  String get webdavStartupSync;

  /// No description provided for @webdavStartupSyncSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'后台执行，不阻塞首页首帧；失败后可手动重试'**
  String get webdavStartupSyncSubtitle;

  /// No description provided for @webdavSyncContent.
  ///
  /// In zh, this message translates to:
  /// **'同步内容'**
  String get webdavSyncContent;

  /// No description provided for @webdavSyncContentSummary.
  ///
  /// In zh, this message translates to:
  /// **'• 搜索记录与浏览历史\n• 盐选书架及已下载章节\n• 回答详情缓存（恢复后仍可手动刷新获取最新内容）'**
  String get webdavSyncContentSummary;

  /// No description provided for @webdavStatus.
  ///
  /// In zh, this message translates to:
  /// **'状态：{message}'**
  String webdavStatus(String message);

  /// No description provided for @webdavLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在读取 WebDAV 设置'**
  String get webdavLoading;

  /// No description provided for @webdavConfiguredStatus.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 已配置'**
  String get webdavConfiguredStatus;

  /// No description provided for @webdavNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'尚未配置 WebDAV'**
  String get webdavNotConfigured;

  /// No description provided for @webdavSettingsSaved.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 设置已保存'**
  String get webdavSettingsSaved;

  /// No description provided for @webdavClosedStatus.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 已关闭'**
  String get webdavClosedStatus;

  /// No description provided for @webdavTesting.
  ///
  /// In zh, this message translates to:
  /// **'正在测试 WebDAV 连接'**
  String get webdavTesting;

  /// No description provided for @webdavSyncing.
  ///
  /// In zh, this message translates to:
  /// **'正在同步搜索、历史、小说和回答缓存'**
  String get webdavSyncing;

  /// No description provided for @webdavSyncCompleted.
  ///
  /// In zh, this message translates to:
  /// **'同步完成：上传 {uploaded} 项，恢复 {downloaded} 项'**
  String webdavSyncCompleted(String uploaded, String downloaded);

  /// No description provided for @webdavConfigFailed.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 配置无效：{error}'**
  String webdavConfigFailed(String error);

  /// No description provided for @webdavSyncNotEnabled.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 同步未启用'**
  String get webdavSyncNotEnabled;

  /// No description provided for @webdavNotSynced.
  ///
  /// In zh, this message translates to:
  /// **'尚未同步'**
  String get webdavNotSynced;

  /// No description provided for @webdavSyncNow.
  ///
  /// In zh, this message translates to:
  /// **'立即同步'**
  String get webdavSyncNow;

  /// No description provided for @webdavTestConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get webdavTestConnection;

  /// No description provided for @webdavDisable.
  ///
  /// In zh, this message translates to:
  /// **'关闭同步'**
  String get webdavDisable;

  /// No description provided for @webdavClearLocalSettings.
  ///
  /// In zh, this message translates to:
  /// **'清除本机配置和凭据'**
  String get webdavClearLocalSettings;

  /// No description provided for @webdavLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'读取 WebDAV 设置失败：{error}'**
  String webdavLoadFailed(String error);

  /// No description provided for @webdavSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败：{error}'**
  String webdavSaveFailed(String error);

  /// No description provided for @webdavConnected.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 连接成功'**
  String get webdavConnected;

  /// No description provided for @webdavConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败：{error}'**
  String webdavConnectionFailed(String error);

  /// No description provided for @webdavSyncFailed.
  ///
  /// In zh, this message translates to:
  /// **'同步失败：{error}'**
  String webdavSyncFailed(String error);

  /// No description provided for @webdavDisabled.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 同步已关闭，凭据仍保留在本机私有数据库'**
  String get webdavDisabled;

  /// No description provided for @webdavClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清除 WebDAV 配置？'**
  String get webdavClearTitle;

  /// No description provided for @webdavClearMessage.
  ///
  /// In zh, this message translates to:
  /// **'这会删除本机保存的 WebDAV 地址、账号和凭据，不会删除远端同步数据。'**
  String get webdavClearMessage;

  /// No description provided for @webdavCleared.
  ///
  /// In zh, this message translates to:
  /// **'本机 WebDAV 配置和凭据已清除'**
  String get webdavCleared;

  /// No description provided for @webdavClearFailed.
  ///
  /// In zh, this message translates to:
  /// **'清除失败：{error}'**
  String webdavClearFailed(String error);

  /// No description provided for @webdavInvalidEndpoint.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 地址无效'**
  String get webdavInvalidEndpoint;

  /// No description provided for @webdavHttpsRequired.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 地址必须使用 HTTPS'**
  String get webdavHttpsRequired;

  /// No description provided for @webdavEndpointCredentials.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 地址不能包含账号、密码、查询参数或片段'**
  String get webdavEndpointCredentials;

  /// No description provided for @webdavCredentialCharacters.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 凭据不能包含换行或控制字符'**
  String get webdavCredentialCharacters;

  /// No description provided for @webdavInvalidDirectory.
  ///
  /// In zh, this message translates to:
  /// **'远程目录无效'**
  String get webdavInvalidDirectory;

  /// No description provided for @webdavUsernameRequired.
  ///
  /// In zh, this message translates to:
  /// **'账号密码认证需要填写用户名'**
  String get webdavUsernameRequired;

  /// No description provided for @webdavSecretRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写密码、应用专用密码或访问令牌'**
  String get webdavSecretRequired;

  /// No description provided for @webdavCredentialTooLong.
  ///
  /// In zh, this message translates to:
  /// **'访问凭据过长'**
  String get webdavCredentialTooLong;

  /// No description provided for @commonCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get commonCopy;

  /// No description provided for @commonSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get commonSelectAll;

  /// No description provided for @detailDownvote.
  ///
  /// In zh, this message translates to:
  /// **'反对'**
  String get detailDownvote;

  /// No description provided for @detailDownvoted.
  ///
  /// In zh, this message translates to:
  /// **'已反对'**
  String get detailDownvoted;

  /// No description provided for @detailCommentAction.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get detailCommentAction;

  /// No description provided for @detailViewComments.
  ///
  /// In zh, this message translates to:
  /// **'查看评论'**
  String get detailViewComments;

  /// No description provided for @detailViewCommentsCount.
  ///
  /// In zh, this message translates to:
  /// **'查看 {count} 条评论'**
  String detailViewCommentsCount(String count);

  /// No description provided for @detailFavorite.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get detailFavorite;

  /// No description provided for @detailFavoriteCount.
  ///
  /// In zh, this message translates to:
  /// **'收藏 {count}'**
  String detailFavoriteCount(String count);

  /// No description provided for @detailAuthor.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get detailAuthor;

  /// No description provided for @detailFollowed.
  ///
  /// In zh, this message translates to:
  /// **'已关注'**
  String get detailFollowed;

  /// No description provided for @detailFollow.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get detailFollow;

  /// No description provided for @detailUnfollowAuthor.
  ///
  /// In zh, this message translates to:
  /// **'取消关注作者'**
  String get detailUnfollowAuthor;

  /// No description provided for @detailFollowAuthor.
  ///
  /// In zh, this message translates to:
  /// **'关注作者'**
  String get detailFollowAuthor;

  /// No description provided for @detailTop.
  ///
  /// In zh, this message translates to:
  /// **'顶部'**
  String get detailTop;

  /// No description provided for @detailBackToTop.
  ///
  /// In zh, this message translates to:
  /// **'回到帖子顶部'**
  String get detailBackToTop;

  /// No description provided for @detailBottom.
  ///
  /// In zh, this message translates to:
  /// **'底部'**
  String get detailBottom;

  /// No description provided for @detailJumpToBottom.
  ///
  /// In zh, this message translates to:
  /// **'跳到帖子底部'**
  String get detailJumpToBottom;

  /// No description provided for @detailCollapseMore.
  ///
  /// In zh, this message translates to:
  /// **'收起更多功能'**
  String get detailCollapseMore;

  /// No description provided for @detailMoreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多操作'**
  String get detailMoreActions;

  /// No description provided for @detailExportActions.
  ///
  /// In zh, this message translates to:
  /// **'导出内容'**
  String get detailExportActions;

  /// No description provided for @detailSignInFromMe.
  ///
  /// In zh, this message translates to:
  /// **'请先在“我”中登录。'**
  String get detailSignInFromMe;

  /// No description provided for @detailWriteAnswerSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'创建对这个问题的新回答'**
  String get detailWriteAnswerSubtitle;

  /// No description provided for @detailRefreshContent.
  ///
  /// In zh, this message translates to:
  /// **'刷新{content}'**
  String detailRefreshContent(String content);

  /// No description provided for @detailRefreshSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'忽略缓存并重新获取最新内容'**
  String get detailRefreshSubtitle;

  /// No description provided for @detailSearchSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'输入关键词快速定位到正文内容'**
  String get detailSearchSubtitle;

  /// No description provided for @detailReadAloudSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用系统语音朗读当前{content}'**
  String detailReadAloudSubtitle(String content);

  /// No description provided for @detailExportTextSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'保存当前标题、作者和正文'**
  String get detailExportTextSubtitle;

  /// No description provided for @detailExportDocument.
  ///
  /// In zh, this message translates to:
  /// **'导出为 {format}'**
  String detailExportDocument(String format);

  /// No description provided for @detailExportPdfSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'生成适合分享和打印的文档'**
  String get detailExportPdfSubtitle;

  /// No description provided for @detailExportDocumentSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'保留标题、作者、段落和正文图片链接'**
  String get detailExportDocumentSubtitle;

  /// No description provided for @detailCopyAll.
  ///
  /// In zh, this message translates to:
  /// **'复制全文'**
  String get detailCopyAll;

  /// No description provided for @detailCopySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'复制当前标题、作者和正文'**
  String get detailCopySubtitle;

  /// No description provided for @detailClearCache.
  ///
  /// In zh, this message translates to:
  /// **'清除本条缓存'**
  String get detailClearCache;

  /// No description provided for @detailInviteAnswer.
  ///
  /// In zh, this message translates to:
  /// **'邀请回答'**
  String get detailInviteAnswer;

  /// No description provided for @detailCopyAnswer.
  ///
  /// In zh, this message translates to:
  /// **'复制回答内容'**
  String get detailCopyAnswer;

  /// No description provided for @detailSelectionTooShort.
  ///
  /// In zh, this message translates to:
  /// **'至少选择 {count} 个字'**
  String detailSelectionTooShort(int count);

  /// No description provided for @detailCommentSelection.
  ///
  /// In zh, this message translates to:
  /// **'评论这段话'**
  String get detailCommentSelection;

  /// No description provided for @detailCommentHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入你的评论'**
  String get detailCommentHint;

  /// No description provided for @detailActionUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'{action}功能暂不可用'**
  String detailActionUnavailable(String action);

  /// No description provided for @detailSignInRequired.
  ///
  /// In zh, this message translates to:
  /// **'登录后可使用此功能'**
  String get detailSignInRequired;

  /// No description provided for @detailUnfollowTitle.
  ///
  /// In zh, this message translates to:
  /// **'取消关注？'**
  String get detailUnfollowTitle;

  /// No description provided for @detailUnfollowMessage.
  ///
  /// In zh, this message translates to:
  /// **'将不再关注 {name}'**
  String detailUnfollowMessage(String name);

  /// No description provided for @detailUnfollowAction.
  ///
  /// In zh, this message translates to:
  /// **'取消关注'**
  String get detailUnfollowAction;

  /// No description provided for @detailCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清除本条回答缓存'**
  String get detailCacheCleared;

  /// No description provided for @detailImagePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'[图片]'**
  String get detailImagePlaceholder;

  /// No description provided for @detailVideoPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'[视频]'**
  String get detailVideoPlaceholder;

  /// No description provided for @detailImageCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张正文图片'**
  String detailImageCount(int count);

  /// No description provided for @detailViewImage.
  ///
  /// In zh, this message translates to:
  /// **'查看正文图片原图'**
  String get detailViewImage;

  /// No description provided for @detailCloseImage.
  ///
  /// In zh, this message translates to:
  /// **'关闭图片'**
  String get detailCloseImage;

  /// No description provided for @detailSaveImage.
  ///
  /// In zh, this message translates to:
  /// **'保存到相册'**
  String get detailSaveImage;

  /// No description provided for @detailImageSaved.
  ///
  /// In zh, this message translates to:
  /// **'图片已保存'**
  String get detailImageSaved;

  /// No description provided for @detailImageSavedTo.
  ///
  /// In zh, this message translates to:
  /// **'已保存到相册'**
  String get detailImageSavedTo;

  /// No description provided for @detailImageSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片保存失败，请稍后重试'**
  String get detailImageSaveFailed;

  /// No description provided for @detailMyAnswer.
  ///
  /// In zh, this message translates to:
  /// **'我的回答'**
  String get detailMyAnswer;

  /// No description provided for @detailAuthorPrefix.
  ///
  /// In zh, this message translates to:
  /// **'作者：{name}'**
  String detailAuthorPrefix(String name);

  /// No description provided for @detailNoExportableBody.
  ///
  /// In zh, this message translates to:
  /// **'当前回答没有可导出的正文'**
  String get detailNoExportableBody;

  /// No description provided for @detailAnswerDetails.
  ///
  /// In zh, this message translates to:
  /// **'回答详情'**
  String get detailAnswerDetails;

  /// No description provided for @detailExportedTo.
  ///
  /// In zh, this message translates to:
  /// **'已导出到 {location}'**
  String detailExportedTo(String location);

  /// No description provided for @detailExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败，请重试'**
  String get detailExportFailed;

  /// No description provided for @detailDocumentExported.
  ///
  /// In zh, this message translates to:
  /// **'已导出为 {format}：{location}'**
  String detailDocumentExported(String format, String location);

  /// No description provided for @detailStoppedReading.
  ///
  /// In zh, this message translates to:
  /// **'已停止朗读'**
  String get detailStoppedReading;

  /// No description provided for @detailNoReadableBody.
  ///
  /// In zh, this message translates to:
  /// **'当前回答没有可朗读的正文'**
  String get detailNoReadableBody;

  /// No description provided for @detailReading.
  ///
  /// In zh, this message translates to:
  /// **'正在朗读正文'**
  String get detailReading;

  /// No description provided for @detailTtsUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'系统语音不可用，请安装语音包'**
  String get detailTtsUnavailable;

  /// No description provided for @detailNoCopyableText.
  ///
  /// In zh, this message translates to:
  /// **'当前回答没有可复制的正文'**
  String get detailNoCopyableText;

  /// No description provided for @detailCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制全文'**
  String get detailCopied;

  /// No description provided for @detailSearchBodyTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索正文'**
  String get detailSearchBodyTitle;

  /// No description provided for @detailKeywordHint.
  ///
  /// In zh, this message translates to:
  /// **'输入关键词'**
  String get detailKeywordHint;

  /// No description provided for @detailLocate.
  ///
  /// In zh, this message translates to:
  /// **'定位'**
  String get detailLocate;

  /// No description provided for @detailBodyNotFound.
  ///
  /// In zh, this message translates to:
  /// **'正文中没有找到“{keyword}”'**
  String detailBodyNotFound(String keyword);

  /// No description provided for @detailLocated.
  ///
  /// In zh, this message translates to:
  /// **'已定位到“{keyword}”'**
  String detailLocated(String keyword);

  /// No description provided for @detailWriteAnswer.
  ///
  /// In zh, this message translates to:
  /// **'写回答'**
  String get detailWriteAnswer;

  /// No description provided for @detailAnswerRequired.
  ///
  /// In zh, this message translates to:
  /// **'回答内容不能为空'**
  String get detailAnswerRequired;

  /// No description provided for @detailAnswerPublished.
  ///
  /// In zh, this message translates to:
  /// **'回答已发布'**
  String get detailAnswerPublished;

  /// No description provided for @commentSentence.
  ///
  /// In zh, this message translates to:
  /// **'句子评论'**
  String get commentSentence;

  /// No description provided for @commentSentenceCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条句子评论'**
  String commentSentenceCount(String count);

  /// No description provided for @commentWrite.
  ///
  /// In zh, this message translates to:
  /// **'写评论'**
  String get commentWrite;

  /// No description provided for @commentReplyTitle.
  ///
  /// In zh, this message translates to:
  /// **'回复 {target}'**
  String commentReplyTitle(String target);

  /// No description provided for @commentReplyTargetComment.
  ///
  /// In zh, this message translates to:
  /// **'这条评论'**
  String get commentReplyTargetComment;

  /// No description provided for @commentPublished.
  ///
  /// In zh, this message translates to:
  /// **'评论已发布。'**
  String get commentPublished;

  /// No description provided for @commentReplyPublished.
  ///
  /// In zh, this message translates to:
  /// **'回复已发布。'**
  String get commentReplyPublished;

  /// No description provided for @commentDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除评论？'**
  String get commentDeleteTitle;

  /// No description provided for @commentDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'该评论及其当前展示关系将从列表中移除。'**
  String get commentDeleteMessage;

  /// No description provided for @commentDeleted.
  ///
  /// In zh, this message translates to:
  /// **'评论已删除。'**
  String get commentDeleted;

  /// No description provided for @commentDeleteReplyTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除回复？'**
  String get commentDeleteReplyTitle;

  /// No description provided for @commentDeleteReplyMessage.
  ///
  /// In zh, this message translates to:
  /// **'删除后不可恢复。'**
  String get commentDeleteReplyMessage;

  /// No description provided for @commentReplyDeleted.
  ///
  /// In zh, this message translates to:
  /// **'回复已删除。'**
  String get commentReplyDeleted;

  /// No description provided for @commentRepliesTitle.
  ///
  /// In zh, this message translates to:
  /// **'评论回复'**
  String get commentRepliesTitle;

  /// No description provided for @commentNoReplies.
  ///
  /// In zh, this message translates to:
  /// **'还没有回复'**
  String get commentNoReplies;

  /// No description provided for @commentNoComments.
  ///
  /// In zh, this message translates to:
  /// **'还没有评论'**
  String get commentNoComments;

  /// No description provided for @commentReplyCount.
  ///
  /// In zh, this message translates to:
  /// **'回复 {count}'**
  String commentReplyCount(String count);

  /// No description provided for @commentEditorUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法发表评论'**
  String get commentEditorUnavailable;

  /// No description provided for @commentGif.
  ///
  /// In zh, this message translates to:
  /// **'GIF'**
  String get commentGif;

  /// No description provided for @commentExpandEditor.
  ///
  /// In zh, this message translates to:
  /// **'展开编辑器'**
  String get commentExpandEditor;

  /// No description provided for @contentFilterClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空过滤统计？'**
  String get contentFilterClearTitle;

  /// No description provided for @contentFilterClearMessage.
  ///
  /// In zh, this message translates to:
  /// **'只会删除本机记录，不会改变知乎账号和服务端反馈设置。'**
  String get contentFilterClearMessage;

  /// No description provided for @contentFilterCleared.
  ///
  /// In zh, this message translates to:
  /// **'内容过滤统计已清空'**
  String get contentFilterCleared;

  /// No description provided for @contentFilterClearStats.
  ///
  /// In zh, this message translates to:
  /// **'清空统计'**
  String get contentFilterClearStats;

  /// No description provided for @contentFilterStatsTitle.
  ///
  /// In zh, this message translates to:
  /// **'内容过滤统计'**
  String get contentFilterStatsTitle;

  /// No description provided for @contentFilterStatsLabel.
  ///
  /// In zh, this message translates to:
  /// **'内容过滤统计'**
  String get contentFilterStatsLabel;

  /// No description provided for @contentFilterActions.
  ///
  /// In zh, this message translates to:
  /// **'反馈操作'**
  String get contentFilterActions;

  /// No description provided for @contentFilterHidden.
  ///
  /// In zh, this message translates to:
  /// **'已隐藏内容'**
  String get contentFilterHidden;

  /// No description provided for @contentFilterReasons.
  ///
  /// In zh, this message translates to:
  /// **'过滤原因'**
  String get contentFilterReasons;

  /// No description provided for @contentFilterHint.
  ///
  /// In zh, this message translates to:
  /// **'在首页卡片中选择“减少此类内容”后，这里会按原因累计统计。'**
  String get contentFilterHint;

  /// No description provided for @contentFilterCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次'**
  String contentFilterCount(String count);

  /// No description provided for @contentFilterLatest.
  ///
  /// In zh, this message translates to:
  /// **'最近一次'**
  String get contentFilterLatest;

  /// No description provided for @contentFilterEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无记录'**
  String get contentFilterEmpty;

  /// No description provided for @contentFilterSummaryEmpty.
  ///
  /// In zh, this message translates to:
  /// **'记录每次减少内容的原因和结果'**
  String get contentFilterSummaryEmpty;

  /// No description provided for @contentFilterSummary.
  ///
  /// In zh, this message translates to:
  /// **'{actions} 次操作 · 已隐藏 {hidden} 条 · {reasons} 类原因'**
  String contentFilterSummary(String actions, String hidden, String reasons);

  /// No description provided for @accountSessionsNoCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前没有可保存的登录会话'**
  String get accountSessionsNoCurrent;

  /// No description provided for @accountSessionsSaved.
  ///
  /// In zh, this message translates to:
  /// **'当前登录会话已保存'**
  String get accountSessionsSaved;

  /// No description provided for @accountSessionsSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'账号槽位保存失败，请稍后重试'**
  String get accountSessionsSaveFailed;

  /// No description provided for @accountSessionsSwitched.
  ///
  /// In zh, this message translates to:
  /// **'已切换到 {name}'**
  String accountSessionsSwitched(String name);

  /// No description provided for @accountSessionsSwitchFailed.
  ///
  /// In zh, this message translates to:
  /// **'账号切换失败，请稍后重试'**
  String get accountSessionsSwitchFailed;

  /// No description provided for @accountSessionsDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除账号槽位？'**
  String get accountSessionsDeleteTitle;

  /// No description provided for @accountSessionsDeleteActiveMessage.
  ///
  /// In zh, this message translates to:
  /// **'只删除本机保存的 {name}，当前会话会退出本机并保留可恢复副本，不会退出其他设备。'**
  String accountSessionsDeleteActiveMessage(String name);

  /// No description provided for @accountSessionsDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'只删除本机保存的 {name}，不会退出其他设备。'**
  String accountSessionsDeleteMessage(String name);

  /// No description provided for @accountSessionsDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除本机账号槽位'**
  String get accountSessionsDeleted;

  /// No description provided for @accountSessionsDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'账号槽位删除失败，请稍后重试'**
  String get accountSessionsDeleteFailed;

  /// No description provided for @accountSessionsNoRecovery.
  ///
  /// In zh, this message translates to:
  /// **'没有可恢复的账号会话'**
  String get accountSessionsNoRecovery;

  /// No description provided for @accountSessionsRestored.
  ///
  /// In zh, this message translates to:
  /// **'已恢复最近一次清理的账号会话'**
  String get accountSessionsRestored;

  /// No description provided for @accountSessionsRestoreSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'会话已恢复，但账号槽位保存失败，请稍后重试'**
  String get accountSessionsRestoreSaveFailed;

  /// No description provided for @accountSessionsPurgeTitle.
  ///
  /// In zh, this message translates to:
  /// **'彻底清理恢复凭据？'**
  String get accountSessionsPurgeTitle;

  /// No description provided for @accountSessionsPurgeMessage.
  ///
  /// In zh, this message translates to:
  /// **'这会永久删除最近清理后保留的恢复副本，之后无法恢复。'**
  String get accountSessionsPurgeMessage;

  /// No description provided for @accountSessionsPurgeAction.
  ///
  /// In zh, this message translates to:
  /// **'彻底删除'**
  String get accountSessionsPurgeAction;

  /// No description provided for @accountSessionsPurged.
  ///
  /// In zh, this message translates to:
  /// **'恢复凭据已彻底删除'**
  String get accountSessionsPurged;

  /// No description provided for @accountSessionsPurgeFailed.
  ///
  /// In zh, this message translates to:
  /// **'恢复凭据清理失败，请稍后重试'**
  String get accountSessionsPurgeFailed;

  /// No description provided for @accountSessionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'账号与多端登录'**
  String get accountSessionsTitle;

  /// No description provided for @accountSessionsSaveCurrent.
  ///
  /// In zh, this message translates to:
  /// **'保存当前会话'**
  String get accountSessionsSaveCurrent;

  /// No description provided for @accountSessionsIntro.
  ///
  /// In zh, this message translates to:
  /// **'扫码登录或手机号登录后的会话会保存在本机私有凭据数据库中。切换前会重新验证 /people/self；不会主动退出其他设备。'**
  String get accountSessionsIntro;

  /// No description provided for @accountSessionsRecoveryTitle.
  ///
  /// In zh, this message translates to:
  /// **'最近清理的登录信息'**
  String get accountSessionsRecoveryTitle;

  /// No description provided for @accountSessionsRecoveryMessage.
  ///
  /// In zh, this message translates to:
  /// **'服务器失效确认后清理的账号仍保留在本机恢复区。可以恢复，也可以在这里永久删除。'**
  String get accountSessionsRecoveryMessage;

  /// No description provided for @accountSessionsRestore.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get accountSessionsRestore;

  /// No description provided for @accountSessionsEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有保存的账号槽位'**
  String get accountSessionsEmptyTitle;

  /// No description provided for @accountSessionsEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'登录成功后可在这里管理多端会话。'**
  String get accountSessionsEmptyMessage;

  /// No description provided for @accountSessionsQr.
  ///
  /// In zh, this message translates to:
  /// **'扫码会话'**
  String get accountSessionsQr;

  /// No description provided for @accountSessionsPassword.
  ///
  /// In zh, this message translates to:
  /// **'手机号/密码会话'**
  String get accountSessionsPassword;

  /// No description provided for @accountSessionsCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前使用'**
  String get accountSessionsCurrent;

  /// No description provided for @accountSessionsExpired.
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get accountSessionsExpired;

  /// No description provided for @accountSessionsMenu.
  ///
  /// In zh, this message translates to:
  /// **'账号操作'**
  String get accountSessionsMenu;

  /// No description provided for @accountSessionsSwitch.
  ///
  /// In zh, this message translates to:
  /// **'切换并验证'**
  String get accountSessionsSwitch;

  /// No description provided for @accountSessionsRemoveSlot.
  ///
  /// In zh, this message translates to:
  /// **'删除槽位'**
  String get accountSessionsRemoveSlot;

  /// No description provided for @accountSessionsAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加账号 / 扫码登录'**
  String get accountSessionsAdd;

  /// No description provided for @accountDefaultName.
  ///
  /// In zh, this message translates to:
  /// **'知乎账号'**
  String get accountDefaultName;

  /// No description provided for @accountMaskedName.
  ///
  /// In zh, this message translates to:
  /// **'账号 {id}'**
  String accountMaskedName(String id);

  /// No description provided for @browsingHistoryClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空历史记录？'**
  String get browsingHistoryClearTitle;

  /// No description provided for @browsingHistoryClearMessage.
  ///
  /// In zh, this message translates to:
  /// **'这只会删除知阅保存在本机的浏览记录。'**
  String get browsingHistoryClearMessage;

  /// No description provided for @browsingHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'历史记录'**
  String get browsingHistoryTitle;

  /// No description provided for @browsingHistoryClear.
  ///
  /// In zh, this message translates to:
  /// **'清空历史记录'**
  String get browsingHistoryClear;

  /// No description provided for @browsingHistoryEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有浏览记录'**
  String get browsingHistoryEmptyTitle;

  /// No description provided for @browsingHistoryEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'打开回答、文章、问题或话题后会显示在这里'**
  String get browsingHistoryEmptyMessage;

  /// No description provided for @browsingHistoryToday.
  ///
  /// In zh, this message translates to:
  /// **'今天 {time}'**
  String browsingHistoryToday(String time);

  /// No description provided for @browsingHistoryDate.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日 {time}'**
  String browsingHistoryDate(int month, int day, String time);

  /// No description provided for @updateCheckFailed.
  ///
  /// In zh, this message translates to:
  /// **'检查更新失败，请稍后重试'**
  String get updateCheckFailed;

  /// No description provided for @updateAllowInstallTitle.
  ///
  /// In zh, this message translates to:
  /// **'允许安装应用'**
  String get updateAllowInstallTitle;

  /// No description provided for @updateAllowInstallMessage.
  ///
  /// In zh, this message translates to:
  /// **'Android 需要你允许知阅安装下载的更新。开启后返回此页，再点一次下载并安装。'**
  String get updateAllowInstallMessage;

  /// No description provided for @updateOpenSettings.
  ///
  /// In zh, this message translates to:
  /// **'前往设置'**
  String get updateOpenSettings;

  /// No description provided for @updateCachedInstalling.
  ///
  /// In zh, this message translates to:
  /// **'已使用下载好的更新包，正在打开 Android 安装器'**
  String get updateCachedInstalling;

  /// No description provided for @updateVerifiedInstalling.
  ///
  /// In zh, this message translates to:
  /// **'更新已验证，正在打开 Android 安装器'**
  String get updateVerifiedInstalling;

  /// No description provided for @updateInstallFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新安装失败，请重试'**
  String get updateInstallFailed;

  /// No description provided for @updateTitle.
  ///
  /// In zh, this message translates to:
  /// **'软件更新'**
  String get updateTitle;

  /// No description provided for @updateAppName.
  ///
  /// In zh, this message translates to:
  /// **'知阅'**
  String get updateAppName;

  /// No description provided for @updateReadingVersion.
  ///
  /// In zh, this message translates to:
  /// **'正在读取版本信息'**
  String get updateReadingVersion;

  /// No description provided for @updateCurrentVersion.
  ///
  /// In zh, this message translates to:
  /// **'当前版本 {version} ({code})'**
  String updateCurrentVersion(String version, String code);

  /// No description provided for @updateUnsupportedTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前平台不支持应用内安装'**
  String get updateUnsupportedTitle;

  /// No description provided for @updateUnsupportedMessage.
  ///
  /// In zh, this message translates to:
  /// **'安全下载、校验和系统安装器目前仅在 Android 客户端启用。'**
  String get updateUnsupportedMessage;

  /// No description provided for @updateCheckingTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在检查更新'**
  String get updateCheckingTitle;

  /// No description provided for @updateCheckingMessage.
  ///
  /// In zh, this message translates to:
  /// **'正在从 GitHub Releases 读取稳定版本。'**
  String get updateCheckingMessage;

  /// No description provided for @updateLatestTitle.
  ///
  /// In zh, this message translates to:
  /// **'已是最新版本'**
  String get updateLatestTitle;

  /// No description provided for @updateNoRelease.
  ///
  /// In zh, this message translates to:
  /// **'稳定通道目前没有已发布版本。'**
  String get updateNoRelease;

  /// No description provided for @updateLatestVersion.
  ///
  /// In zh, this message translates to:
  /// **'稳定通道最新版本为 {version} ({code})。'**
  String updateLatestVersion(String version, String code);

  /// No description provided for @updateChecking.
  ///
  /// In zh, this message translates to:
  /// **'正在检查'**
  String get updateChecking;

  /// No description provided for @updateRecheck.
  ///
  /// In zh, this message translates to:
  /// **'重新检查'**
  String get updateRecheck;

  /// No description provided for @updateSecurity.
  ///
  /// In zh, this message translates to:
  /// **'更新安全'**
  String get updateSecurity;

  /// No description provided for @updateSecuritySourceTitle.
  ///
  /// In zh, this message translates to:
  /// **'GitHub Releases'**
  String get updateSecuritySourceTitle;

  /// No description provided for @updateSecuritySourceDetail.
  ///
  /// In zh, this message translates to:
  /// **'只接受指定 GitHub 仓库中规范命名的稳定版 arm64 APK。'**
  String get updateSecuritySourceDetail;

  /// No description provided for @updateSecurityIntegrityTitle.
  ///
  /// In zh, this message translates to:
  /// **'完整性校验'**
  String get updateSecurityIntegrityTitle;

  /// No description provided for @updateSecurityIntegrityDetail.
  ///
  /// In zh, this message translates to:
  /// **'下载后校验 GitHub 提供的 SHA-256 摘要和文件大小。'**
  String get updateSecurityIntegrityDetail;

  /// No description provided for @updateSecurityInstallerTitle.
  ///
  /// In zh, this message translates to:
  /// **'交给系统安装器'**
  String get updateSecurityInstallerTitle;

  /// No description provided for @updateSecurityInstallerDetail.
  ///
  /// In zh, this message translates to:
  /// **'还会校验包名、版本及证书连续性，再打开 Android 安装器。'**
  String get updateSecurityInstallerDetail;

  /// No description provided for @updateImportant.
  ///
  /// In zh, this message translates to:
  /// **'重要更新'**
  String get updateImportant;

  /// No description provided for @updateNewVersion.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本 {version}'**
  String updateNewVersion(String version);

  /// No description provided for @updateImportantFound.
  ///
  /// In zh, this message translates to:
  /// **'发现重要更新'**
  String get updateImportantFound;

  /// No description provided for @updatePublishedToReleases.
  ///
  /// In zh, this message translates to:
  /// **'新版本已发布到 GitHub Releases。'**
  String get updatePublishedToReleases;

  /// No description provided for @updateLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后'**
  String get updateLater;

  /// No description provided for @updateView.
  ///
  /// In zh, this message translates to:
  /// **'查看更新'**
  String get updateView;

  /// No description provided for @updateVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String updateVersion(String version);

  /// No description provided for @updateReleaseMeta.
  ///
  /// In zh, this message translates to:
  /// **'{size} APK · stable 通道 · 构建 {code}'**
  String updateReleaseMeta(String size, String code);

  /// No description provided for @updateViewDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看更新接口详情'**
  String get updateViewDetails;

  /// No description provided for @updateVerifiedManifest.
  ///
  /// In zh, this message translates to:
  /// **'已验证清单、包大小和 SHA-256'**
  String get updateVerifiedManifest;

  /// No description provided for @updateReleaseId.
  ///
  /// In zh, this message translates to:
  /// **'发布编号'**
  String get updateReleaseId;

  /// No description provided for @updatePublishedAt.
  ///
  /// In zh, this message translates to:
  /// **'发布时间'**
  String get updatePublishedAt;

  /// No description provided for @updateReleaseTag.
  ///
  /// In zh, this message translates to:
  /// **'Release 标签'**
  String get updateReleaseTag;

  /// No description provided for @updatePackageType.
  ///
  /// In zh, this message translates to:
  /// **'包类型'**
  String get updatePackageType;

  /// No description provided for @updatePackageSha256.
  ///
  /// In zh, this message translates to:
  /// **'APK SHA-256'**
  String get updatePackageSha256;

  /// No description provided for @updateManifestResponse.
  ///
  /// In zh, this message translates to:
  /// **'清单响应'**
  String get updateManifestResponse;

  /// No description provided for @updateDownloadProgress.
  ///
  /// In zh, this message translates to:
  /// **'下载 APK {received} / {total}'**
  String updateDownloadProgress(String received, String total);

  /// No description provided for @updateVerifyingPackage.
  ///
  /// In zh, this message translates to:
  /// **'正在校验安装包'**
  String get updateVerifyingPackage;

  /// No description provided for @updateContinueInstall.
  ///
  /// In zh, this message translates to:
  /// **'继续安装'**
  String get updateContinueInstall;

  /// No description provided for @updateDownloadInstall.
  ///
  /// In zh, this message translates to:
  /// **'下载并安装'**
  String get updateDownloadInstall;

  /// No description provided for @updateValidation.
  ///
  /// In zh, this message translates to:
  /// **'校验'**
  String get updateValidation;

  /// No description provided for @updateManifestSummary.
  ///
  /// In zh, this message translates to:
  /// **'{size} 清单'**
  String updateManifestSummary(String size);

  /// No description provided for @profileChange.
  ///
  /// In zh, this message translates to:
  /// **'更换'**
  String get profileChange;

  /// No description provided for @profileUserFallback.
  ///
  /// In zh, this message translates to:
  /// **'知乎用户'**
  String get profileUserFallback;

  /// No description provided for @profileAnswers.
  ///
  /// In zh, this message translates to:
  /// **'回答'**
  String get profileAnswers;

  /// No description provided for @profileArticles.
  ///
  /// In zh, this message translates to:
  /// **'文章'**
  String get profileArticles;

  /// No description provided for @profileIdeas.
  ///
  /// In zh, this message translates to:
  /// **'想法'**
  String get profileIdeas;

  /// No description provided for @profileCollections.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get profileCollections;

  /// No description provided for @profileUpvotes.
  ///
  /// In zh, this message translates to:
  /// **'获赞'**
  String get profileUpvotes;

  /// No description provided for @profileFollowers.
  ///
  /// In zh, this message translates to:
  /// **'被关注'**
  String get profileFollowers;

  /// No description provided for @profileFollowing.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get profileFollowing;

  /// No description provided for @profileEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑资料'**
  String get profileEdit;

  /// No description provided for @profileAllDetails.
  ///
  /// In zh, this message translates to:
  /// **'全部资料'**
  String get profileAllDetails;

  /// No description provided for @profileMyContent.
  ///
  /// In zh, this message translates to:
  /// **'我的内容'**
  String get profileMyContent;

  /// No description provided for @profileMyAnswers.
  ///
  /// In zh, this message translates to:
  /// **'我的回答'**
  String get profileMyAnswers;

  /// No description provided for @profileMyArticles.
  ///
  /// In zh, this message translates to:
  /// **'我的文章'**
  String get profileMyArticles;

  /// No description provided for @profileMyIdeas.
  ///
  /// In zh, this message translates to:
  /// **'我的想法'**
  String get profileMyIdeas;

  /// No description provided for @profileMyCollections.
  ///
  /// In zh, this message translates to:
  /// **'我的收藏'**
  String get profileMyCollections;

  /// No description provided for @profileIdeasTab.
  ///
  /// In zh, this message translates to:
  /// **'灵感'**
  String get profileIdeasTab;

  /// No description provided for @profileCreationTab.
  ///
  /// In zh, this message translates to:
  /// **'创作'**
  String get profileCreationTab;

  /// No description provided for @profileActivityTab.
  ///
  /// In zh, this message translates to:
  /// **'动态'**
  String get profileActivityTab;

  /// No description provided for @profileVoteupTab.
  ///
  /// In zh, this message translates to:
  /// **'赞同'**
  String get profileVoteupTab;

  /// No description provided for @profilePublicActivitiesEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有公开动态'**
  String get profilePublicActivitiesEmpty;

  /// No description provided for @profilePublicVoteupsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有公开赞同'**
  String get profilePublicVoteupsEmpty;

  /// No description provided for @profileVipSalt.
  ///
  /// In zh, this message translates to:
  /// **'盐选会员'**
  String get profileVipSalt;

  /// No description provided for @profileVipZhihu.
  ///
  /// In zh, this message translates to:
  /// **'知乎会员'**
  String get profileVipZhihu;

  /// No description provided for @profileMetricWan.
  ///
  /// In zh, this message translates to:
  /// **'万'**
  String get profileMetricWan;

  /// No description provided for @profileMetricYi.
  ///
  /// In zh, this message translates to:
  /// **'亿'**
  String get profileMetricYi;

  /// No description provided for @profileMetricItems.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条'**
  String profileMetricItems(String count);

  /// No description provided for @profileGenderFemale.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get profileGenderFemale;

  /// No description provided for @profileGenderMale.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get profileGenderMale;

  /// No description provided for @profileGenderUnspecified.
  ///
  /// In zh, this message translates to:
  /// **'未填写'**
  String get profileGenderUnspecified;

  /// No description provided for @profileJustJoined.
  ///
  /// In zh, this message translates to:
  /// **'刚刚加入'**
  String get profileJustJoined;

  /// No description provided for @profileAgeDays.
  ///
  /// In zh, this message translates to:
  /// **'{count} 天'**
  String profileAgeDays(int count);

  /// No description provided for @profileAgeMonthsDays.
  ///
  /// In zh, this message translates to:
  /// **'{months} 个月 {days} 天'**
  String profileAgeMonthsDays(int months, int days);

  /// No description provided for @profileAgeYearsMonths.
  ///
  /// In zh, this message translates to:
  /// **'{years} 年 {months} 个月'**
  String profileAgeYearsMonths(int years, int months);

  /// No description provided for @profileBasicInfo.
  ///
  /// In zh, this message translates to:
  /// **'基本资料'**
  String get profileBasicInfo;

  /// No description provided for @profileUsername.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get profileUsername;

  /// No description provided for @profileAccountAge.
  ///
  /// In zh, this message translates to:
  /// **'知龄'**
  String get profileAccountAge;

  /// No description provided for @profileGender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get profileGender;

  /// No description provided for @profileBirthday.
  ///
  /// In zh, this message translates to:
  /// **'生日'**
  String get profileBirthday;

  /// No description provided for @profileLocation.
  ///
  /// In zh, this message translates to:
  /// **'居住地'**
  String get profileLocation;

  /// No description provided for @profileVerification.
  ///
  /// In zh, this message translates to:
  /// **'认证信息'**
  String get profileVerification;

  /// No description provided for @profileManageVerification.
  ///
  /// In zh, this message translates to:
  /// **'管理认证'**
  String get profileManageVerification;

  /// No description provided for @profileUnverified.
  ///
  /// In zh, this message translates to:
  /// **'未认证'**
  String get profileUnverified;

  /// No description provided for @profileInfluence.
  ///
  /// In zh, this message translates to:
  /// **'影响力'**
  String get profileInfluence;

  /// No description provided for @profileBadges.
  ///
  /// In zh, this message translates to:
  /// **'我的徽章'**
  String get profileBadges;

  /// No description provided for @profileLikes.
  ///
  /// In zh, this message translates to:
  /// **'获得喜欢'**
  String get profileLikes;

  /// No description provided for @profileNone.
  ///
  /// In zh, this message translates to:
  /// **'暂无'**
  String get profileNone;

  /// No description provided for @profileCountPieces.
  ///
  /// In zh, this message translates to:
  /// **'{count} 枚'**
  String profileCountPieces(int count);

  /// No description provided for @profileCountTimes.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次'**
  String profileCountTimes(int count);

  /// No description provided for @profileFriendImpression.
  ///
  /// In zh, this message translates to:
  /// **'好友印象'**
  String get profileFriendImpression;

  /// No description provided for @profileImproveImage.
  ///
  /// In zh, this message translates to:
  /// **'完善我的知乎形象，获取更多关注'**
  String get profileImproveImage;

  /// No description provided for @profileAddKeywords.
  ///
  /// In zh, this message translates to:
  /// **'添加形象关键词'**
  String get profileAddKeywords;

  /// No description provided for @profileLinkCopied.
  ///
  /// In zh, this message translates to:
  /// **'主页链接已复制'**
  String get profileLinkCopied;

  /// No description provided for @profileTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的主页'**
  String get profileTitle;

  /// No description provided for @profileLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'个人资料加载失败'**
  String get profileLoadFailed;

  /// No description provided for @profileNetworkRetry.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络后重试'**
  String get profileNetworkRetry;

  /// No description provided for @profileOpenDrawer.
  ///
  /// In zh, this message translates to:
  /// **'打开侧边栏'**
  String get profileOpenDrawer;

  /// No description provided for @profileFindUser.
  ///
  /// In zh, this message translates to:
  /// **'查找用户'**
  String get profileFindUser;

  /// No description provided for @profileCopyHomeLink.
  ///
  /// In zh, this message translates to:
  /// **'复制主页链接'**
  String get profileCopyHomeLink;

  /// No description provided for @profileUsernameEmpty.
  ///
  /// In zh, this message translates to:
  /// **'用户名不能为空'**
  String get profileUsernameEmpty;

  /// No description provided for @profileFieldTooLong.
  ///
  /// In zh, this message translates to:
  /// **'用户名、介绍或个人简介超过长度限制'**
  String get profileFieldTooLong;

  /// No description provided for @profileImageUploadNoUrl.
  ///
  /// In zh, this message translates to:
  /// **'图片上传未返回地址'**
  String get profileImageUploadNoUrl;

  /// No description provided for @profileCoverUploadNoHash.
  ///
  /// In zh, this message translates to:
  /// **'主页背景上传未返回图片哈希'**
  String get profileCoverUploadNoHash;

  /// No description provided for @profileCoverUpdated.
  ///
  /// In zh, this message translates to:
  /// **'主页背景已更新'**
  String get profileCoverUpdated;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In zh, this message translates to:
  /// **'头像已更新'**
  String get profileAvatarUpdated;

  /// No description provided for @profileAddEmployment.
  ///
  /// In zh, this message translates to:
  /// **'添加职业经历'**
  String get profileAddEmployment;

  /// No description provided for @profileCompanyOrOrganization.
  ///
  /// In zh, this message translates to:
  /// **'公司或组织'**
  String get profileCompanyOrOrganization;

  /// No description provided for @profileJob.
  ///
  /// In zh, this message translates to:
  /// **'职位'**
  String get profileJob;

  /// No description provided for @profileAddEducation.
  ///
  /// In zh, this message translates to:
  /// **'添加教育经历'**
  String get profileAddEducation;

  /// No description provided for @profileSchool.
  ///
  /// In zh, this message translates to:
  /// **'学校'**
  String get profileSchool;

  /// No description provided for @profileMajor.
  ///
  /// In zh, this message translates to:
  /// **'专业'**
  String get profileMajor;

  /// No description provided for @profileEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑个人资料'**
  String get profileEditTitle;

  /// No description provided for @profileSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中'**
  String get profileSaving;

  /// No description provided for @profileInfoNotice.
  ///
  /// In zh, this message translates to:
  /// **'您填写的内容将用于个人页展示及内容推荐'**
  String get profileInfoNotice;

  /// No description provided for @profileAvatar.
  ///
  /// In zh, this message translates to:
  /// **'头像'**
  String get profileAvatar;

  /// No description provided for @profileCover.
  ///
  /// In zh, this message translates to:
  /// **'主页背景'**
  String get profileCover;

  /// No description provided for @profileHeadline.
  ///
  /// In zh, this message translates to:
  /// **'一句话介绍'**
  String get profileHeadline;

  /// No description provided for @profileHeadlinePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'介绍自己的职业或兴趣'**
  String get profileHeadlinePlaceholder;

  /// No description provided for @profileBirthdayPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'请填写生日'**
  String get profileBirthdayPlaceholder;

  /// No description provided for @profileLocationPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'请填写居住地'**
  String get profileLocationPlaceholder;

  /// No description provided for @profileIndustry.
  ///
  /// In zh, this message translates to:
  /// **'所在行业'**
  String get profileIndustry;

  /// No description provided for @profileIndustryPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'请选择行业'**
  String get profileIndustryPlaceholder;

  /// No description provided for @profileEmployment.
  ///
  /// In zh, this message translates to:
  /// **'职业经历'**
  String get profileEmployment;

  /// No description provided for @profileEducation.
  ///
  /// In zh, this message translates to:
  /// **'教育经历'**
  String get profileEducation;

  /// No description provided for @profilePersonalVerification.
  ///
  /// In zh, this message translates to:
  /// **'个人认证'**
  String get profilePersonalVerification;

  /// No description provided for @profileAddVerification.
  ///
  /// In zh, this message translates to:
  /// **'添加个人认证'**
  String get profileAddVerification;

  /// No description provided for @profileBio.
  ///
  /// In zh, this message translates to:
  /// **'个人简介'**
  String get profileBio;

  /// No description provided for @profileBioPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'用一段话介绍自己'**
  String get profileBioPlaceholder;

  /// No description provided for @notificationCommentCategory.
  ///
  /// In zh, this message translates to:
  /// **'评论转发@'**
  String get notificationCommentCategory;

  /// No description provided for @notificationLikeCategory.
  ///
  /// In zh, this message translates to:
  /// **'赞同喜欢'**
  String get notificationLikeCategory;

  /// No description provided for @notificationFavoriteCategory.
  ///
  /// In zh, this message translates to:
  /// **'收藏了我'**
  String get notificationFavoriteCategory;

  /// No description provided for @notificationFollowCategory.
  ///
  /// In zh, this message translates to:
  /// **'关注订阅'**
  String get notificationFollowCategory;

  /// No description provided for @notificationInvite.
  ///
  /// In zh, this message translates to:
  /// **'邀请回答'**
  String get notificationInvite;

  /// No description provided for @notificationMarkedRead.
  ///
  /// In zh, this message translates to:
  /// **'已将消息标为已读'**
  String get notificationMarkedRead;

  /// No description provided for @notificationTitle.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get notificationTitle;

  /// No description provided for @notificationSettings.
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationSettings;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In zh, this message translates to:
  /// **'全部已读'**
  String get notificationMarkAllRead;

  /// No description provided for @notificationLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'消息加载失败'**
  String get notificationLoadFailed;

  /// No description provided for @notificationInvitePending.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条待处理邀请'**
  String notificationInvitePending(String count);

  /// No description provided for @notificationInviteView.
  ///
  /// In zh, this message translates to:
  /// **'查看邀请你回答的问题'**
  String get notificationInviteView;

  /// No description provided for @notificationCategoryEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂时没有这类通知'**
  String get notificationCategoryEmpty;

  /// No description provided for @notificationCategoryMarkedRead.
  ///
  /// In zh, this message translates to:
  /// **'该分类已全部标为已读'**
  String get notificationCategoryMarkedRead;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsSection.
  ///
  /// In zh, this message translates to:
  /// **'互动与内容通知'**
  String get notificationSettingsSection;

  /// No description provided for @notificationAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get notificationAll;

  /// No description provided for @notificationLoginTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录后查看消息'**
  String get notificationLoginTitle;

  /// No description provided for @notificationLoginMessage.
  ///
  /// In zh, this message translates to:
  /// **'消息通知属于知乎账号数据'**
  String get notificationLoginMessage;

  /// No description provided for @notificationBackLogin.
  ///
  /// In zh, this message translates to:
  /// **'返回并登录'**
  String get notificationBackLogin;

  /// No description provided for @messageTitle.
  ///
  /// In zh, this message translates to:
  /// **'私信'**
  String get messageTitle;

  /// No description provided for @messageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'私信加载失败'**
  String get messageLoadFailed;

  /// No description provided for @messageComposeHint.
  ///
  /// In zh, this message translates to:
  /// **'发私信'**
  String get messageComposeHint;

  /// No description provided for @messageSend.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get messageSend;

  /// No description provided for @notificationSettingCommentMe.
  ///
  /// In zh, this message translates to:
  /// **'评论了我'**
  String get notificationSettingCommentMe;

  /// No description provided for @notificationSettingMentionMe.
  ///
  /// In zh, this message translates to:
  /// **'提及了我'**
  String get notificationSettingMentionMe;

  /// No description provided for @notificationSettingAnswerVoteup.
  ///
  /// In zh, this message translates to:
  /// **'赞同了我的回答'**
  String get notificationSettingAnswerVoteup;

  /// No description provided for @notificationSettingContentVoteup.
  ///
  /// In zh, this message translates to:
  /// **'赞同了我的内容'**
  String get notificationSettingContentVoteup;

  /// No description provided for @notificationSettingAnswerThanks.
  ///
  /// In zh, this message translates to:
  /// **'感谢了我的回答'**
  String get notificationSettingAnswerThanks;

  /// No description provided for @notificationSettingRepin.
  ///
  /// In zh, this message translates to:
  /// **'收藏了我的内容'**
  String get notificationSettingRepin;

  /// No description provided for @notificationSettingReaction.
  ///
  /// In zh, this message translates to:
  /// **'回应了我的内容'**
  String get notificationSettingReaction;

  /// No description provided for @notificationSettingMemberFollow.
  ///
  /// In zh, this message translates to:
  /// **'关注了我'**
  String get notificationSettingMemberFollow;

  /// No description provided for @notificationSettingFavlistFollow.
  ///
  /// In zh, this message translates to:
  /// **'关注了我的收藏夹'**
  String get notificationSettingFavlistFollow;

  /// No description provided for @notificationSettingColumnFollow.
  ///
  /// In zh, this message translates to:
  /// **'关注了我的专栏'**
  String get notificationSettingColumnFollow;

  /// No description provided for @notificationSettingQuestionAnswered.
  ///
  /// In zh, this message translates to:
  /// **'我关注的问题有新回答'**
  String get notificationSettingQuestionAnswered;

  /// No description provided for @notificationSettingAnswerQuestion.
  ///
  /// In zh, this message translates to:
  /// **'回答了我的问题'**
  String get notificationSettingAnswerQuestion;

  /// No description provided for @notificationSettingQuestionInvite.
  ///
  /// In zh, this message translates to:
  /// **'邀请我回答'**
  String get notificationSettingQuestionInvite;

  /// No description provided for @notificationSettingColumnUpdate.
  ///
  /// In zh, this message translates to:
  /// **'关注的专栏有更新'**
  String get notificationSettingColumnUpdate;

  /// No description provided for @notificationSettingMemberActivity.
  ///
  /// In zh, this message translates to:
  /// **'关注的人有新动态'**
  String get notificationSettingMemberActivity;

  /// No description provided for @notificationSettingSpecialUpdate.
  ///
  /// In zh, this message translates to:
  /// **'关注的专题有更新'**
  String get notificationSettingSpecialUpdate;

  /// No description provided for @notificationSettingMessage.
  ///
  /// In zh, this message translates to:
  /// **'收到私信'**
  String get notificationSettingMessage;

  /// No description provided for @notificationSettingStrangerMessage.
  ///
  /// In zh, this message translates to:
  /// **'陌生人私信'**
  String get notificationSettingStrangerMessage;

  /// No description provided for @notificationSettingCoupon.
  ///
  /// In zh, this message translates to:
  /// **'优惠与权益提醒'**
  String get notificationSettingCoupon;

  /// No description provided for @notificationSettingBoughtContent.
  ///
  /// In zh, this message translates to:
  /// **'已购内容更新'**
  String get notificationSettingBoughtContent;

  /// No description provided for @notificationSettingEbook.
  ///
  /// In zh, this message translates to:
  /// **'电子书上新'**
  String get notificationSettingEbook;

  /// No description provided for @notificationSettingArticleInvite.
  ///
  /// In zh, this message translates to:
  /// **'邀请我创作文章'**
  String get notificationSettingArticleInvite;

  /// No description provided for @notificationSettingTipjar.
  ///
  /// In zh, this message translates to:
  /// **'文章赞赏到账'**
  String get notificationSettingTipjar;

  /// No description provided for @creationAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get creationAll;

  /// No description provided for @creationAnswers.
  ///
  /// In zh, this message translates to:
  /// **'回答 {count}'**
  String creationAnswers(String count);

  /// No description provided for @creationIdeas.
  ///
  /// In zh, this message translates to:
  /// **'想法 {count}'**
  String creationIdeas(String count);

  /// No description provided for @creationArticles.
  ///
  /// In zh, this message translates to:
  /// **'文章 {count}'**
  String creationArticles(String count);

  /// No description provided for @creationColumns.
  ///
  /// In zh, this message translates to:
  /// **'专栏 {count}'**
  String creationColumns(String count);

  /// No description provided for @creationQuestions.
  ///
  /// In zh, this message translates to:
  /// **'提问 {count}'**
  String creationQuestions(String count);

  /// No description provided for @creationVideos.
  ///
  /// In zh, this message translates to:
  /// **'视频 {count}'**
  String creationVideos(String count);

  /// No description provided for @creationMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get creationMore;

  /// No description provided for @creationEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有发布内容'**
  String get creationEmpty;

  /// No description provided for @creationFavorites.
  ///
  /// In zh, this message translates to:
  /// **'我的收藏'**
  String get creationFavorites;

  /// No description provided for @creationHighlights.
  ///
  /// In zh, this message translates to:
  /// **'我的划线'**
  String get creationHighlights;

  /// No description provided for @creationFollowingColumns.
  ///
  /// In zh, this message translates to:
  /// **'订阅的专栏'**
  String get creationFollowingColumns;

  /// No description provided for @creationFollowingTopics.
  ///
  /// In zh, this message translates to:
  /// **'关注的话题'**
  String get creationFollowingTopics;

  /// No description provided for @creationFollowingCollections.
  ///
  /// In zh, this message translates to:
  /// **'关注的收藏夹'**
  String get creationFollowingCollections;

  /// No description provided for @creationFollowingQuestions.
  ///
  /// In zh, this message translates to:
  /// **'关注的问题'**
  String get creationFollowingQuestions;

  /// No description provided for @activityShare.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get activityShare;

  /// No description provided for @activityDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除此条动态'**
  String get activityDelete;

  /// No description provided for @activityLinkCopied.
  ///
  /// In zh, this message translates to:
  /// **'链接已复制'**
  String get activityLinkCopied;

  /// No description provided for @activityDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除此条动态？'**
  String get activityDeleteTitle;

  /// No description provided for @activityDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'删除后无法恢复。'**
  String get activityDeleteMessage;

  /// No description provided for @activityDeleted.
  ///
  /// In zh, this message translates to:
  /// **'动态已删除'**
  String get activityDeleted;

  /// No description provided for @questionIdUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法识别问题 ID，请刷新后重试'**
  String get questionIdUnavailable;

  /// No description provided for @questionFollowed.
  ///
  /// In zh, this message translates to:
  /// **'已关注问题'**
  String get questionFollowed;

  /// No description provided for @questionUnfollowed.
  ///
  /// In zh, this message translates to:
  /// **'已取消关注问题'**
  String get questionUnfollowed;

  /// No description provided for @questionAnswerPublishedRefreshing.
  ///
  /// In zh, this message translates to:
  /// **'回答已发布，列表正在刷新。'**
  String get questionAnswerPublishedRefreshing;

  /// No description provided for @questionDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除回答？'**
  String get questionDeleteTitle;

  /// No description provided for @questionDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'删除后不可恢复。'**
  String get questionDeleteMessage;

  /// No description provided for @questionDeleted.
  ///
  /// In zh, this message translates to:
  /// **'回答已删除。'**
  String get questionDeleted;

  /// No description provided for @questionAnswersTitle.
  ///
  /// In zh, this message translates to:
  /// **'全部回答'**
  String get questionAnswersTitle;

  /// No description provided for @questionSearchAnswers.
  ///
  /// In zh, this message translates to:
  /// **'搜索回答'**
  String get questionSearchAnswers;

  /// No description provided for @questionMore.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get questionMore;

  /// No description provided for @questionLoginToWrite.
  ///
  /// In zh, this message translates to:
  /// **'登录后写回答'**
  String get questionLoginToWrite;

  /// No description provided for @questionUnfollow.
  ///
  /// In zh, this message translates to:
  /// **'取消关注问题'**
  String get questionUnfollow;

  /// No description provided for @questionFollow.
  ///
  /// In zh, this message translates to:
  /// **'关注问题'**
  String get questionFollow;

  /// No description provided for @questionAnswerRefresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新回答'**
  String get questionAnswerRefresh;

  /// No description provided for @questionCollapseDetails.
  ///
  /// In zh, this message translates to:
  /// **'收起问题详情'**
  String get questionCollapseDetails;

  /// No description provided for @questionExpandDetails.
  ///
  /// In zh, this message translates to:
  /// **'展开问题详情'**
  String get questionExpandDetails;

  /// No description provided for @questionCollapse.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get questionCollapse;

  /// No description provided for @questionExpandFull.
  ///
  /// In zh, this message translates to:
  /// **'展开全文'**
  String get questionExpandFull;

  /// No description provided for @questionOpenTopic.
  ///
  /// In zh, this message translates to:
  /// **'打开话题 {name}'**
  String questionOpenTopic(String name);

  /// No description provided for @questionAllContentCount.
  ///
  /// In zh, this message translates to:
  /// **'全部内容 {count}'**
  String questionAllContentCount(String count);

  /// No description provided for @questionSortDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get questionSortDefault;

  /// No description provided for @questionSortLatest.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get questionSortLatest;

  /// No description provided for @questionSortSemantic.
  ///
  /// In zh, this message translates to:
  /// **'回答排序：'**
  String get questionSortSemantic;

  /// No description provided for @questionAuthor.
  ///
  /// In zh, this message translates to:
  /// **'提问者 {name}'**
  String questionAuthor(String name);

  /// No description provided for @questionAuthorBadge.
  ///
  /// In zh, this message translates to:
  /// **'提问者'**
  String get questionAuthorBadge;

  /// No description provided for @questionViewImage.
  ///
  /// In zh, this message translates to:
  /// **'查看问题图片原图'**
  String get questionViewImage;

  /// No description provided for @topicFollowersTitle.
  ///
  /// In zh, this message translates to:
  /// **'话题关注者'**
  String get topicFollowersTitle;

  /// No description provided for @topicUnansweredTitle.
  ///
  /// In zh, this message translates to:
  /// **'话题待回答问题'**
  String get topicUnansweredTitle;

  /// No description provided for @topicFallbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'话题 {id}'**
  String topicFallbackTitle(String id);

  /// No description provided for @topicRefresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新话题资料'**
  String get topicRefresh;

  /// No description provided for @topicLabel.
  ///
  /// In zh, this message translates to:
  /// **'话题'**
  String get topicLabel;

  /// No description provided for @topicFollowers.
  ///
  /// In zh, this message translates to:
  /// **'{count} 关注者'**
  String topicFollowers(String count);

  /// No description provided for @topicQuestions.
  ///
  /// In zh, this message translates to:
  /// **'{count} 问题'**
  String topicQuestions(String count);

  /// No description provided for @topicAnswers.
  ///
  /// In zh, this message translates to:
  /// **'{count} 回答'**
  String topicAnswers(String count);

  /// No description provided for @topicDiscussions.
  ///
  /// In zh, this message translates to:
  /// **'{count} 讨论'**
  String topicDiscussions(String count);

  /// No description provided for @topicBasicUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'基础资料暂未加载，精华列表仍可独立浏览。'**
  String get topicBasicUnavailable;

  /// No description provided for @topicFollowersButton.
  ///
  /// In zh, this message translates to:
  /// **'关注者'**
  String get topicFollowersButton;

  /// No description provided for @topicUnansweredButton.
  ///
  /// In zh, this message translates to:
  /// **'待回答'**
  String get topicUnansweredButton;

  /// No description provided for @zvideoTitle.
  ///
  /// In zh, this message translates to:
  /// **'视频'**
  String get zvideoTitle;

  /// No description provided for @zvideoCommentsUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get zvideoCommentsUnavailable;

  /// No description provided for @zvideoActionUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'{action}功能暂不可用'**
  String zvideoActionUnavailable(String action);

  /// No description provided for @zvideoLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'视频暂时无法加载'**
  String get zvideoLoadFailed;

  /// No description provided for @zvideoFallbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'视频 #{id}'**
  String zvideoFallbackTitle(String id);

  /// No description provided for @zvideoViewComments.
  ///
  /// In zh, this message translates to:
  /// **'查看评论'**
  String get zvideoViewComments;

  /// No description provided for @zvideoViewCommentsCount.
  ///
  /// In zh, this message translates to:
  /// **'查看 {count} 条评论'**
  String zvideoViewCommentsCount(String count);

  /// No description provided for @zvideoMissing.
  ///
  /// In zh, this message translates to:
  /// **'没有取得可播放的视频信息'**
  String get zvideoMissing;

  /// No description provided for @zvideoVoteup.
  ///
  /// In zh, this message translates to:
  /// **'赞同'**
  String get zvideoVoteup;

  /// No description provided for @zvideoComment.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get zvideoComment;

  /// No description provided for @zvideoFavorite.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get zvideoFavorite;

  /// No description provided for @zvideoShare.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get zvideoShare;

  /// No description provided for @zvideoVoteupSemantic.
  ///
  /// In zh, this message translates to:
  /// **'赞同视频'**
  String get zvideoVoteupSemantic;

  /// No description provided for @zvideoCommentsSemantic.
  ///
  /// In zh, this message translates to:
  /// **'查看视频评论'**
  String get zvideoCommentsSemantic;

  /// No description provided for @zvideoFavoriteSemantic.
  ///
  /// In zh, this message translates to:
  /// **'收藏视频'**
  String get zvideoFavoriteSemantic;

  /// No description provided for @zvideoShareSemantic.
  ///
  /// In zh, this message translates to:
  /// **'分享视频'**
  String get zvideoShareSemantic;

  /// No description provided for @inlineVideoPlatformUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'当前平台暂不支持内联视频播放'**
  String get inlineVideoPlatformUnsupported;

  /// No description provided for @inlineVideoLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'视频暂时无法播放，请稍后重试'**
  String get inlineVideoLoadFailed;

  /// No description provided for @inlineVideoInterruptedRetry.
  ///
  /// In zh, this message translates to:
  /// **'视频播放已中断，请点按重试'**
  String get inlineVideoInterruptedRetry;

  /// No description provided for @inlineVideoSwitchingLine.
  ///
  /// In zh, this message translates to:
  /// **'播放中断，正在切换线路…'**
  String get inlineVideoSwitchingLine;

  /// No description provided for @inlineVideoPaidNoAccess.
  ///
  /// In zh, this message translates to:
  /// **'付费视频 · 当前账号无观看权限'**
  String get inlineVideoPaidNoAccess;

  /// No description provided for @inlineVideoUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'视频暂不可播放'**
  String get inlineVideoUnavailable;

  /// No description provided for @inlineVideoPrivacyUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'当前平台暂不支持隐私受限的视频播放'**
  String get inlineVideoPrivacyUnavailable;

  /// No description provided for @inlineVideoPlay.
  ///
  /// In zh, this message translates to:
  /// **'播放视频'**
  String get inlineVideoPlay;

  /// No description provided for @inlineVideoPlayTitle.
  ///
  /// In zh, this message translates to:
  /// **'播放视频：{title}'**
  String inlineVideoPlayTitle(String title);

  /// No description provided for @inlineVideoFullscreen.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get inlineVideoFullscreen;

  /// No description provided for @inlineVideoStopped.
  ///
  /// In zh, this message translates to:
  /// **'视频已停止或正在切换线路'**
  String get inlineVideoStopped;

  /// No description provided for @inlineVideoBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get inlineVideoBack;

  /// No description provided for @answerSwitchRelease.
  ///
  /// In zh, this message translates to:
  /// **'松开切换'**
  String get answerSwitchRelease;

  /// No description provided for @answerSwitchPreviousHint.
  ///
  /// In zh, this message translates to:
  /// **'继续下拉查看上一个回答'**
  String get answerSwitchPreviousHint;

  /// No description provided for @answerSwitchNextHint.
  ///
  /// In zh, this message translates to:
  /// **'继续上滑查看下一个回答'**
  String get answerSwitchNextHint;

  /// No description provided for @answerSwitchTo.
  ///
  /// In zh, this message translates to:
  /// **'松开切换到 {author} 的回答'**
  String answerSwitchTo(String author);

  /// No description provided for @answerPrevious.
  ///
  /// In zh, this message translates to:
  /// **'上一个'**
  String get answerPrevious;

  /// No description provided for @answerNext.
  ///
  /// In zh, this message translates to:
  /// **'下一个'**
  String get answerNext;

  /// No description provided for @detailWriteAnswerLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录后写回答'**
  String get detailWriteAnswerLogin;

  /// No description provided for @saltDownloadedProgress.
  ///
  /// In zh, this message translates to:
  /// **'{downloaded}/{total} 已下载'**
  String saltDownloadedProgress(int downloaded, int total);

  /// No description provided for @saltDownloadedSections.
  ///
  /// In zh, this message translates to:
  /// **'{count} 节已下载'**
  String saltDownloadedSections(int count);

  /// No description provided for @saltAudio.
  ///
  /// In zh, this message translates to:
  /// **'盐选音频'**
  String get saltAudio;

  /// No description provided for @saltVideo.
  ///
  /// In zh, this message translates to:
  /// **'盐选视频'**
  String get saltVideo;

  /// No description provided for @saltStory.
  ///
  /// In zh, this message translates to:
  /// **'盐选故事'**
  String get saltStory;

  /// No description provided for @saltLimitedFree.
  ///
  /// In zh, this message translates to:
  /// **'限时免费'**
  String get saltLimitedFree;

  /// No description provided for @saltUntitledContent.
  ///
  /// In zh, this message translates to:
  /// **'未命名盐选内容'**
  String get saltUntitledContent;

  /// No description provided for @saltLikeCount.
  ///
  /// In zh, this message translates to:
  /// **'点赞 {count}'**
  String saltLikeCount(String count);

  /// No description provided for @saltCommentCount.
  ///
  /// In zh, this message translates to:
  /// **'评论 {count}'**
  String saltCommentCount(String count);

  /// No description provided for @saltWordCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 字'**
  String saltWordCount(String count);

  /// No description provided for @saltReadCount.
  ///
  /// In zh, this message translates to:
  /// **'阅读 {count}'**
  String saltReadCount(String count);

  /// No description provided for @saltFavoriteCount.
  ///
  /// In zh, this message translates to:
  /// **'收藏 {count}'**
  String saltFavoriteCount(String count);

  /// No description provided for @saltPlayable.
  ///
  /// In zh, this message translates to:
  /// **'可听'**
  String get saltPlayable;

  /// No description provided for @saltSupportsAudio.
  ///
  /// In zh, this message translates to:
  /// **'支持听书'**
  String get saltSupportsAudio;

  /// No description provided for @saltFree.
  ///
  /// In zh, this message translates to:
  /// **'免费'**
  String get saltFree;

  /// No description provided for @saltTrial.
  ///
  /// In zh, this message translates to:
  /// **'试读'**
  String get saltTrial;

  /// No description provided for @saltMember.
  ///
  /// In zh, this message translates to:
  /// **'盐选会员'**
  String get saltMember;

  /// No description provided for @saltEntitlementRequired.
  ///
  /// In zh, this message translates to:
  /// **'需权益'**
  String get saltEntitlementRequired;

  /// No description provided for @saltLastRead.
  ///
  /// In zh, this message translates to:
  /// **'上次读到'**
  String get saltLastRead;

  /// No description provided for @saltReadFinished.
  ///
  /// In zh, this message translates to:
  /// **'已读完'**
  String get saltReadFinished;

  /// No description provided for @saltUntitledChapter.
  ///
  /// In zh, this message translates to:
  /// **'未命名章节'**
  String get saltUntitledChapter;

  /// No description provided for @saltResourceAudio.
  ///
  /// In zh, this message translates to:
  /// **'音频'**
  String get saltResourceAudio;

  /// No description provided for @saltResourceVideo.
  ///
  /// In zh, this message translates to:
  /// **'视频'**
  String get saltResourceVideo;

  /// No description provided for @saltResourceSlide.
  ///
  /// In zh, this message translates to:
  /// **'课件'**
  String get saltResourceSlide;

  /// No description provided for @saltResourceText.
  ///
  /// In zh, this message translates to:
  /// **'图文'**
  String get saltResourceText;

  /// No description provided for @saltReadPercent.
  ///
  /// In zh, this message translates to:
  /// **'已读 {percent}%'**
  String saltReadPercent(int percent);

  /// No description provided for @saltCommentBadge.
  ///
  /// In zh, this message translates to:
  /// **'查看 {count} 条弹评'**
  String saltCommentBadge(int count);

  /// No description provided for @followMoreAnswers.
  ///
  /// In zh, this message translates to:
  /// **'TA 还赞同了 {count} 个回答'**
  String followMoreAnswers(int count);

  /// No description provided for @brandZhihu.
  ///
  /// In zh, this message translates to:
  /// **'知乎'**
  String get brandZhihu;

  /// No description provided for @detailQuestionAnswerCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个回答'**
  String detailQuestionAnswerCount(String count);

  /// No description provided for @detailQuestionFollowerCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人关注'**
  String detailQuestionFollowerCount(String count);

  /// No description provided for @detailQuestionAnswersSemantic.
  ///
  /// In zh, this message translates to:
  /// **'查看该问题的全部回答'**
  String get detailQuestionAnswersSemantic;

  /// No description provided for @detailQuestionFallback.
  ///
  /// In zh, this message translates to:
  /// **'问题 #{id}'**
  String detailQuestionFallback(String id);

  /// No description provided for @questionInviteTitle.
  ///
  /// In zh, this message translates to:
  /// **'邀请回答'**
  String get questionInviteTitle;

  /// No description provided for @questionInviteEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂时没有推荐邀请人'**
  String get questionInviteEmpty;

  /// No description provided for @questionInviteInvited.
  ///
  /// In zh, this message translates to:
  /// **'已邀请'**
  String get questionInviteInvited;

  /// No description provided for @questionInviteAction.
  ///
  /// In zh, this message translates to:
  /// **'邀请'**
  String get questionInviteAction;

  /// No description provided for @routingSafetyTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全提示'**
  String get routingSafetyTitle;

  /// No description provided for @routingLeaveZhihu.
  ///
  /// In zh, this message translates to:
  /// **'即将离开知乎'**
  String get routingLeaveZhihu;

  /// No description provided for @routingExternalWarning.
  ///
  /// In zh, this message translates to:
  /// **'该链接并非知乎官方页面，请注意保护账号、隐私和财产安全。'**
  String get routingExternalWarning;

  /// No description provided for @routingConfirmVisit.
  ///
  /// In zh, this message translates to:
  /// **'确认访问'**
  String get routingConfirmVisit;

  /// No description provided for @routingOpenVerification.
  ///
  /// In zh, this message translates to:
  /// **'打开知乎验证'**
  String get routingOpenVerification;

  /// No description provided for @webSafetyTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全验证'**
  String get webSafetyTitle;

  /// No description provided for @webPageLoadFailedNetwork.
  ///
  /// In zh, this message translates to:
  /// **'页面加载失败，请检查网络后重试'**
  String get webPageLoadFailedNetwork;

  /// No description provided for @webPageUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'页面暂时无法打开，请稍后重试'**
  String get webPageUnavailable;

  /// No description provided for @webSessionSyncFailed.
  ///
  /// In zh, this message translates to:
  /// **'登录状态未能同步，请重新登录后再试'**
  String get webSessionSyncFailed;

  /// No description provided for @webLoginExpired.
  ///
  /// In zh, this message translates to:
  /// **'网页登录状态已失效，请重新登录后再试'**
  String get webLoginExpired;

  /// No description provided for @webSystemBrowserUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'无法调用系统浏览器'**
  String get webSystemBrowserUnavailable;

  /// No description provided for @webContinueInBrowser.
  ///
  /// In zh, this message translates to:
  /// **'请在浏览器中继续'**
  String get webContinueInBrowser;

  /// No description provided for @webDesktopSystemBrowser.
  ///
  /// In zh, this message translates to:
  /// **'当前桌面平台使用系统浏览器'**
  String get webDesktopSystemBrowser;

  /// No description provided for @webOpenBrowser.
  ///
  /// In zh, this message translates to:
  /// **'打开浏览器'**
  String get webOpenBrowser;

  /// No description provided for @webOpeningChapter.
  ///
  /// In zh, this message translates to:
  /// **'正在打开章节'**
  String get webOpeningChapter;

  /// No description provided for @webOpeningPage.
  ///
  /// In zh, this message translates to:
  /// **'正在打开页面'**
  String get webOpeningPage;

  /// No description provided for @webOpenInBrowser.
  ///
  /// In zh, this message translates to:
  /// **'在浏览器中打开'**
  String get webOpenInBrowser;

  /// No description provided for @webChapterReading.
  ///
  /// In zh, this message translates to:
  /// **'章节阅读'**
  String get webChapterReading;

  /// No description provided for @routingCannotOpen.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法打开。'**
  String get routingCannotOpen;

  /// No description provided for @routingCannotViewComments.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法查看评论。'**
  String get routingCannotViewComments;

  /// No description provided for @routingUnsupportedAction.
  ///
  /// In zh, this message translates to:
  /// **'当前内容暂不支持此操作。'**
  String get routingUnsupportedAction;

  /// No description provided for @routingPinDownvoteUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'想法暂不提供反对操作。'**
  String get routingPinDownvoteUnavailable;

  /// No description provided for @routingDownvoteCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消反对。'**
  String get routingDownvoteCancelled;

  /// No description provided for @routingDownvoted.
  ///
  /// In zh, this message translates to:
  /// **'已反对该内容。'**
  String get routingDownvoted;

  /// No description provided for @routingVoteCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消赞同。'**
  String get routingVoteCancelled;

  /// No description provided for @routingVoted.
  ///
  /// In zh, this message translates to:
  /// **'已赞同该内容。'**
  String get routingVoted;

  /// No description provided for @routingFavoriteRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已取消收藏。'**
  String get routingFavoriteRemoved;

  /// No description provided for @routingFavorited.
  ///
  /// In zh, this message translates to:
  /// **'已加入默认收藏夹。'**
  String get routingFavorited;

  /// No description provided for @objectDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'内容详情'**
  String get objectDetailTitle;

  /// No description provided for @objectImages.
  ///
  /// In zh, this message translates to:
  /// **'图片'**
  String get objectImages;

  /// No description provided for @objectContent.
  ///
  /// In zh, this message translates to:
  /// **'内容'**
  String get objectContent;

  /// No description provided for @contentTypeCollection.
  ///
  /// In zh, this message translates to:
  /// **'收藏集'**
  String get contentTypeCollection;

  /// No description provided for @columnFallbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'专栏 {token}'**
  String columnFallbackTitle(String token);

  /// No description provided for @columnFollowersTitle.
  ///
  /// In zh, this message translates to:
  /// **'专栏关注者'**
  String get columnFollowersTitle;

  /// No description provided for @columnLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'专栏信息暂未加载。'**
  String get columnLoadFailed;

  /// No description provided for @columnRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试专栏资料'**
  String get columnRetry;

  /// No description provided for @columnTitle.
  ///
  /// In zh, this message translates to:
  /// **'专栏'**
  String get columnTitle;

  /// No description provided for @columnArticleCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 篇文章'**
  String columnArticleCount(String count);

  /// No description provided for @columnFollowerCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 关注者'**
  String columnFollowerCount(String count);

  /// No description provided for @columnContributionCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 篇投稿'**
  String columnContributionCount(String count);

  /// No description provided for @columnVoteupCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 获赞'**
  String columnVoteupCount(String count);

  /// No description provided for @columnAuthorPrefix.
  ///
  /// In zh, this message translates to:
  /// **'作者 {name}'**
  String columnAuthorPrefix(String name);

  /// No description provided for @columnFollowers.
  ///
  /// In zh, this message translates to:
  /// **'关注者'**
  String get columnFollowers;

  /// No description provided for @columnAuthorProfile.
  ///
  /// In zh, this message translates to:
  /// **'作者资料'**
  String get columnAuthorProfile;

  /// No description provided for @detailContentIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'内容可能不完整'**
  String get detailContentIncomplete;

  /// No description provided for @detailPaidUnlocked.
  ///
  /// In zh, this message translates to:
  /// **'盐选会员内容已解锁，以下为当前账号可读的完整正文。'**
  String get detailPaidUnlocked;

  /// No description provided for @detailPaidLocked.
  ///
  /// In zh, this message translates to:
  /// **'这是盐选会员内容，当前账号返回的正文仍处于未解锁状态。'**
  String get detailPaidLocked;

  /// No description provided for @detailRelatedLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载其它回答失败，点击重试'**
  String get detailRelatedLoadFailed;

  /// No description provided for @detailViewCommentsButton.
  ///
  /// In zh, this message translates to:
  /// **'查看评论'**
  String get detailViewCommentsButton;

  /// No description provided for @detailContentInfo.
  ///
  /// In zh, this message translates to:
  /// **'内容信息'**
  String get detailContentInfo;

  /// No description provided for @detailReadingHint.
  ///
  /// In zh, this message translates to:
  /// **'主内容栏已限制阅读宽度，滚动时可随时查看互动数据。'**
  String get detailReadingHint;

  /// No description provided for @blockedKeywordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'屏蔽关键词'**
  String get blockedKeywordsTitle;

  /// No description provided for @blockedKeywordsInvalidLength.
  ///
  /// In zh, this message translates to:
  /// **'关键词需为 {min}-{max} 个字符'**
  String blockedKeywordsInvalidLength(int min, int max);

  /// No description provided for @blockedKeywordsExists.
  ///
  /// In zh, this message translates to:
  /// **'该关键词已经存在'**
  String get blockedKeywordsExists;

  /// No description provided for @blockedKeywordsLimit.
  ///
  /// In zh, this message translates to:
  /// **'最多可设置 {max} 个关键词'**
  String blockedKeywordsLimit(int max);

  /// No description provided for @blockedKeywordsDescription.
  ///
  /// In zh, this message translates to:
  /// **'包含这些关键词的推荐将被减少'**
  String get blockedKeywordsDescription;

  /// No description provided for @blockedKeywordsCount.
  ///
  /// In zh, this message translates to:
  /// **'已设置 {current}/{max}'**
  String blockedKeywordsCount(int current, int max);

  /// No description provided for @blockedKeywordsHint.
  ///
  /// In zh, this message translates to:
  /// **'{min}-{max} 个字符'**
  String blockedKeywordsHint(int min, int max);

  /// No description provided for @blockedKeywordsAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加关键词'**
  String get blockedKeywordsAdd;

  /// No description provided for @blockedKeywordsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂未设置屏蔽关键词'**
  String get blockedKeywordsEmpty;

  /// No description provided for @blockedKeywordsDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除 {keyword}'**
  String blockedKeywordsDelete(String keyword);

  /// No description provided for @recommendationClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空本地推荐画像？'**
  String get recommendationClearTitle;

  /// No description provided for @recommendationClearMessage.
  ///
  /// In zh, this message translates to:
  /// **'只会删除本机记录，不会影响知乎账号和服务器推荐。'**
  String get recommendationClearMessage;

  /// No description provided for @recommendationCleared.
  ///
  /// In zh, this message translates to:
  /// **'本地推荐画像已清空'**
  String get recommendationCleared;

  /// No description provided for @recommendationTitle.
  ///
  /// In zh, this message translates to:
  /// **'本地推荐行为'**
  String get recommendationTitle;

  /// No description provided for @recommendationClearSemantic.
  ///
  /// In zh, this message translates to:
  /// **'清空本地画像'**
  String get recommendationClearSemantic;

  /// No description provided for @recommendationEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂时还没有本地行为'**
  String get recommendationEmptyTitle;

  /// No description provided for @recommendationProfileTitle.
  ///
  /// In zh, this message translates to:
  /// **'本地推荐画像'**
  String get recommendationProfileTitle;

  /// No description provided for @recommendationEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'打开推荐内容或使用“不感兴趣”后，知阅会在本机记录有限的兴趣信号。'**
  String get recommendationEmptyMessage;

  /// No description provided for @recommendationSummary.
  ///
  /// In zh, this message translates to:
  /// **'已记录 {total} 条信号 · 打开 {opened} · 反馈 {feedback}'**
  String recommendationSummary(int total, int opened, int feedback);

  /// No description provided for @recommendationTopics.
  ///
  /// In zh, this message translates to:
  /// **'常见兴趣词'**
  String get recommendationTopics;

  /// No description provided for @recommendationAuthors.
  ///
  /// In zh, this message translates to:
  /// **'常见作者'**
  String get recommendationAuthors;

  /// No description provided for @recommendationPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'数据仅保存在本机，用于本地或混合推荐排序；不会上传行为明细。'**
  String get recommendationPrivacy;

  /// No description provided for @discoverColumns.
  ///
  /// In zh, this message translates to:
  /// **'专栏推荐'**
  String get discoverColumns;

  /// No description provided for @discoverTopics.
  ///
  /// In zh, this message translates to:
  /// **'话题分类'**
  String get discoverTopics;

  /// No description provided for @discoverHotTopics.
  ///
  /// In zh, this message translates to:
  /// **'热门话题'**
  String get discoverHotTopics;

  /// No description provided for @discoverHotTopicsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂时没有热门话题'**
  String get discoverHotTopicsEmpty;

  /// No description provided for @discoverContentIdInvalid.
  ///
  /// In zh, this message translates to:
  /// **'内容 ID 必须是 1–32 位数字'**
  String get discoverContentIdInvalid;

  /// No description provided for @discoverTitle.
  ///
  /// In zh, this message translates to:
  /// **'发现'**
  String get discoverTitle;

  /// No description provided for @discoverColumnsAndTopics.
  ///
  /// In zh, this message translates to:
  /// **'专栏与话题'**
  String get discoverColumnsAndTopics;

  /// No description provided for @discoverColumnsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑精选与热门专栏文章'**
  String get discoverColumnsSubtitle;

  /// No description provided for @discoverTopicsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'按分类浏览话题'**
  String get discoverTopicsSubtitle;

  /// No description provided for @discoverHotTopicsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'当前热门讨论'**
  String get discoverHotTopicsSubtitle;

  /// No description provided for @discoverOpenById.
  ///
  /// In zh, this message translates to:
  /// **'通过 ID 打开内容'**
  String get discoverOpenById;

  /// No description provided for @discoverTypeAnswer.
  ///
  /// In zh, this message translates to:
  /// **'回答'**
  String get discoverTypeAnswer;

  /// No description provided for @discoverTypeArticle.
  ///
  /// In zh, this message translates to:
  /// **'文章'**
  String get discoverTypeArticle;

  /// No description provided for @discoverTypeIdea.
  ///
  /// In zh, this message translates to:
  /// **'想法'**
  String get discoverTypeIdea;

  /// No description provided for @discoverIdHint.
  ///
  /// In zh, this message translates to:
  /// **'输入内容 ID'**
  String get discoverIdHint;

  /// No description provided for @discoverOpenDetails.
  ///
  /// In zh, this message translates to:
  /// **'打开详情'**
  String get discoverOpenDetails;

  /// No description provided for @pagedEnd.
  ///
  /// In zh, this message translates to:
  /// **'已经到底了'**
  String get pagedEnd;

  /// No description provided for @pagedEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有内容'**
  String get pagedEmpty;

  /// No description provided for @diagnosticExported.
  ///
  /// In zh, this message translates to:
  /// **'日志 JSON 已复制到剪贴板'**
  String get diagnosticExported;

  /// No description provided for @diagnosticEmpty.
  ///
  /// In zh, this message translates to:
  /// **'目前没有日志'**
  String get diagnosticEmpty;

  /// No description provided for @diagnosticClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清理诊断日志？'**
  String get diagnosticClearTitle;

  /// No description provided for @diagnosticClearMessage.
  ///
  /// In zh, this message translates to:
  /// **'这只会删除本机保存的诊断记录，不会影响账号和内容缓存。'**
  String get diagnosticClearMessage;

  /// No description provided for @diagnosticCleared.
  ///
  /// In zh, this message translates to:
  /// **'诊断日志已清理'**
  String get diagnosticCleared;

  /// No description provided for @diagnosticTitle.
  ///
  /// In zh, this message translates to:
  /// **'诊断日志'**
  String get diagnosticTitle;

  /// No description provided for @diagnosticExport.
  ///
  /// In zh, this message translates to:
  /// **'导出日志'**
  String get diagnosticExport;

  /// No description provided for @diagnosticClear.
  ///
  /// In zh, this message translates to:
  /// **'清理日志'**
  String get diagnosticClear;

  /// No description provided for @diagnosticPurpose.
  ///
  /// In zh, this message translates to:
  /// **'用于定位“内容已被删除”、接口失败和卡顿问题'**
  String get diagnosticPurpose;

  /// No description provided for @diagnosticPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'认证失效、恢复和清理决定默认记录；其它诊断日志可单独开关。日志只保存脱敏状态，不保存 Cookie、令牌、正文或图片。'**
  String get diagnosticPrivacy;

  /// No description provided for @diagnosticLocalEnabled.
  ///
  /// In zh, this message translates to:
  /// **'启用本地日志'**
  String get diagnosticLocalEnabled;

  /// No description provided for @diagnosticLocalSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'开启后保留最近 600 条诊断记录'**
  String get diagnosticLocalSubtitle;

  /// No description provided for @diagnosticAuthEnabled.
  ///
  /// In zh, this message translates to:
  /// **'认证状态日志'**
  String get diagnosticAuthEnabled;

  /// No description provided for @diagnosticAuthSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'记录登录失效、恢复、保留和清理决定，默认开启'**
  String get diagnosticAuthSubtitle;

  /// No description provided for @diagnosticNetworkEnabled.
  ///
  /// In zh, this message translates to:
  /// **'网络请求日志'**
  String get diagnosticNetworkEnabled;

  /// No description provided for @diagnosticNetworkSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'记录接口路径、HTTP 状态、业务码和耗时'**
  String get diagnosticNetworkSubtitle;

  /// No description provided for @diagnosticPerformanceEnabled.
  ///
  /// In zh, this message translates to:
  /// **'性能日志'**
  String get diagnosticPerformanceEnabled;

  /// No description provided for @diagnosticPerformanceSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'记录接口耗时，帮助定位掉帧和慢请求'**
  String get diagnosticPerformanceSubtitle;

  /// No description provided for @diagnosticInstallSummary.
  ///
  /// In zh, this message translates to:
  /// **'本机标识 {id} · {count} 条'**
  String diagnosticInstallSummary(String id, int count);

  /// No description provided for @diagnosticEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无诊断日志'**
  String get diagnosticEmptyTitle;

  /// No description provided for @diagnosticEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'开启本地日志后重新操作一次，异常和网络状态会显示在这里。'**
  String get diagnosticEmptyMessage;

  /// No description provided for @diagnosticNoDetails.
  ///
  /// In zh, this message translates to:
  /// **'没有附加信息'**
  String get diagnosticNoDetails;

  /// No description provided for @diagnosticLevelDebug.
  ///
  /// In zh, this message translates to:
  /// **'调试'**
  String get diagnosticLevelDebug;

  /// No description provided for @diagnosticLevelInfo.
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get diagnosticLevelInfo;

  /// No description provided for @diagnosticLevelWarning.
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get diagnosticLevelWarning;

  /// No description provided for @diagnosticLevelError.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get diagnosticLevelError;

  /// No description provided for @diagnosticCategoryApp.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get diagnosticCategoryApp;

  /// No description provided for @diagnosticCategoryNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络'**
  String get diagnosticCategoryNetwork;

  /// No description provided for @diagnosticCategoryPerformance.
  ///
  /// In zh, this message translates to:
  /// **'性能'**
  String get diagnosticCategoryPerformance;

  /// No description provided for @diagnosticCategoryError.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get diagnosticCategoryError;

  /// No description provided for @diagnosticCategoryAuthentication.
  ///
  /// In zh, this message translates to:
  /// **'认证'**
  String get diagnosticCategoryAuthentication;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
