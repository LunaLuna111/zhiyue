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
