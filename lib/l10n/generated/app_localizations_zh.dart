// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '知阅';

  @override
  String get navRecommend => '推荐';

  @override
  String get navSearch => '搜索';

  @override
  String get navBookshelf => '书架';

  @override
  String get navMe => '我';

  @override
  String get navWorkspace => '工作区';

  @override
  String get feedFollowing => '关注';

  @override
  String get feedRecommend => '推荐';

  @override
  String get feedHot => '热榜';

  @override
  String get feedStory => '故事';

  @override
  String get feedFollowingChoice => '精选';

  @override
  String get feedFollowingLatest => '最新';

  @override
  String get feedFollowingIdeas => '想法';

  @override
  String get feedEmptyFollowing => '关注流暂时没有新内容';

  @override
  String get feedEmptyHot => '当前没有可显示的热榜内容';

  @override
  String get feedEmptyRecommend => '当前没有可显示的推荐内容';

  @override
  String get feedNextLoadFailed => '续页加载失败，点击重试';

  @override
  String get feedAllShown => '已显示当前全部内容';

  @override
  String get feedLoadMore => '继续下滑加载更多';

  @override
  String get feedFollowingPeople => '关注的人';

  @override
  String feedViewPersonRecent(String name) {
    return '查看 $name 最近发布的内容';
  }

  @override
  String get feedDiscoverFriends => '发现好友';

  @override
  String get feedFollowingSemantic => '关注页';

  @override
  String get feedSaltServiceFallback => '知乎盐选会员 为你严选好内容';

  @override
  String feedPersonRecentTitle(String name) {
    return '$name 的最近动态';
  }

  @override
  String get feedPersonRecentEmpty => '还没有公开的最近内容';

  @override
  String get storyCategoriesTitle => '分类';

  @override
  String get storySearch => '搜索故事';

  @override
  String get storyLoadFailed => '故事分类暂时无法加载';

  @override
  String get storyEmptyCategories => '暂时没有故事分类';

  @override
  String get storyBrowseByGenre => '按题材浏览故事';

  @override
  String get storyFilterStories => '筛选故事';

  @override
  String get storyFeaturedCategories => '精选分类';

  @override
  String get storyQuickFilter => '快捷筛选';

  @override
  String get storySort => '排序';

  @override
  String get storyAll => '全部';

  @override
  String get storyCategory => '分类';

  @override
  String get storyTabStories => '故事';

  @override
  String get storyTabBooks => '电子书';

  @override
  String get storyTabAssessments => '测评';

  @override
  String get storyLong => '长篇';

  @override
  String get storyShort => '短篇';

  @override
  String get storyAudioBook => '有声书';

  @override
  String get storyFilter => '筛选';

  @override
  String get storySortHot => '热度';

  @override
  String get storySortGood => '好评';

  @override
  String get storySortNew => '上新';

  @override
  String get storyAllCategories => '全部分类';

  @override
  String get storyMaxTags => '最多支持选择 5 个标签';

  @override
  String get storyNoCategories => '暂无分类';

  @override
  String get storyReset => '重置';

  @override
  String get storyConfirm => '确认';

  @override
  String get storyViewAll => '查看全部';

  @override
  String get storyEmptyCondition => '暂时没有符合条件的内容';

  @override
  String get storyCategoryFallback => '故事分类';

  @override
  String get storyEmptyCategory => '该分类暂时没有故事';

  @override
  String get storyLongTitle => '长篇故事';

  @override
  String get storyEmptyLong => '暂时没有长篇故事';

  @override
  String storyLikeCount(String count) {
    return '$count 赞';
  }

  @override
  String get storyOngoing => '连载中';

  @override
  String get storyFinished => '完结';

  @override
  String get storyFree => '免费';

  @override
  String get storyVip => 'VIP';

  @override
  String get storyVipDiscount => 'VIP 折扣';

  @override
  String get storyType => '类型';

  @override
  String get storyStatus => '状态';

  @override
  String get storyRights => '权益';

  @override
  String get storySectionHotTags => '热门标签';

  @override
  String get storySectionGenre => '题材';

  @override
  String get storySectionCharacters => '角色';

  @override
  String get storySectionPlot => '情节';

  @override
  String get storySectionMood => '情绪';

  @override
  String get storySectionSetting => '时空';

  @override
  String get storyTypeAssessment => '测评';

  @override
  String get storyMaxSelection => '最多选择 5 个标签';

  @override
  String get saltContinueReading => '继续阅读';

  @override
  String get saltStartReading => '开始阅读';

  @override
  String get saltAdded => '已加入';

  @override
  String get saltAddToBookshelf => '加入书架';

  @override
  String get saltChapterOrder => '章节顺序';

  @override
  String get saltAscending => '正序';

  @override
  String get saltDescending => '倒序';

  @override
  String get saltChapter => '章节';

  @override
  String get saltCatalogTitle => '目录';

  @override
  String saltChapterCount(int count) {
    return '共 $count 节';
  }

  @override
  String get saltChapterDirectory => '章节目录';

  @override
  String saltProcessing(int index, int total, String title) {
    return '正在处理 $index/$total · $title';
  }

  @override
  String get saltSelectAll => '全选';

  @override
  String get saltCancelSelectAll => '取消全选';

  @override
  String saltSelectedCount(int selected, int total) {
    return '已选 $selected/$total';
  }

  @override
  String get saltDownloadingChapters => '正在下载章节';

  @override
  String saltExportChapters(String format, int count) {
    return '导出 $format · $count 章';
  }

  @override
  String get saltDirectoryLoadFailed => '目录载入失败';

  @override
  String get saltNetworkRetry => '请检查网络后重试';

  @override
  String get saltDecodeFailed => '章节解码失败，请重试。';

  @override
  String get saltDecodeParamsMissing => '章节响应缺少完整解码参数，请重试。';

  @override
  String get saltDirectoryEmpty => '目录中暂时没有章节';

  @override
  String get saltCached => '已缓存';

  @override
  String get saltCommentsEmpty => '还没有评论';

  @override
  String get saltBulletCommentsEmpty => '还没有弹评';

  @override
  String get saltReaderTopBar => '阅读顶部栏';

  @override
  String get saltReaderBottomBar => '阅读底部栏';

  @override
  String get saltReadingTitle => '盐选阅读';

  @override
  String get saltMore => '更多';

  @override
  String get saltSettingsTitle => '阅读设置';

  @override
  String get saltVerticalScroll => '上下滑动';

  @override
  String get saltHorizontalPage => '左右翻页';

  @override
  String get saltFontSize => '字体大小';

  @override
  String get saltLineSpacing => '行距';

  @override
  String get saltParagraphSpacing => '段距';

  @override
  String get saltHorizontalMargins => '左右边距';

  @override
  String get saltApply => '应用';

  @override
  String get saltChapterInfo => '章节信息';

  @override
  String get saltAuthor => '作者';

  @override
  String get saltReadable => '可读';

  @override
  String get saltLocked => '未解锁';

  @override
  String get saltChapterLocked => '章节锁定';

  @override
  String get saltChapterReadable => '章节可读';

  @override
  String saltSectionLabel(int index) {
    return '第 $index 节';
  }

  @override
  String saltSectionProgress(int index, int count) {
    return '第 $index/$count 节';
  }

  @override
  String saltLikes(String count) {
    return '$count 赞';
  }

  @override
  String saltComments(String count) {
    return '$count 评论';
  }

  @override
  String get saltAudioAvailable => '可听';

  @override
  String get saltNoPermission => '当前账号暂无阅读权限';

  @override
  String get saltReload => '重新加载';

  @override
  String get saltContentUnavailable => '章节内容暂不可用';

  @override
  String get saltPreviousChapter => '上一节';

  @override
  String get saltNextChapter => '下一节';

  @override
  String get saltMetadataReady => '资料已获取';

  @override
  String get saltEntitlementPassed => '权益通过';

  @override
  String get saltPayloadReady => '载荷已获取';

  @override
  String get saltBodyShown => '正文已显示';

  @override
  String get saltWaitingBody => '等待正文解析';

  @override
  String get saltPayloadChars => '字符载荷';

  @override
  String get saltCodeChars => '位 code';

  @override
  String get saltChapterBodyShown => '章节正文已显示';

  @override
  String get saltReadyDetail => '章节资料、绑定载荷和完整正文均已就绪。';

  @override
  String get saltShelfTitle => '书架';

  @override
  String get saltWorkFallback => '盐选作品';

  @override
  String get saltCategory => '分类';

  @override
  String get saltKnowledgeColumn => '知识专栏';

  @override
  String get saltLocalShelfEmpty => '本地书架暂无内容';

  @override
  String get saltMoreActions => '更多操作';

  @override
  String get saltReadAloud => '朗读本节';

  @override
  String get saltStopReading => '停止朗读';

  @override
  String get saltReadAloudSubtitle => '使用系统语音朗读当前章节';

  @override
  String saltExportChapter(String format) {
    return '导出当前章节为 $format';
  }

  @override
  String get saltExportTxt => '导出 TXT 文件';

  @override
  String get saltExportDocx => '导出 DOCX 文件';

  @override
  String saltReadingStarted(String title) {
    return '正在朗读$title';
  }

  @override
  String get saltSpeechUnavailable => '系统语音不可用，请安装语音包';

  @override
  String saltExportedTo(String location) {
    return '已导出到 $location';
  }

  @override
  String saltExportedAs(String format, String location) {
    return '已导出为 $format：$location';
  }

  @override
  String get saltExportFailed => '导出失败，请重试';

  @override
  String get saltCloudShelfUnavailable => '云书架暂时无法同步';

  @override
  String get saltAccountSyncFailed => '账号同步失败，请稍后重试';

  @override
  String get saltStoryHomeLoadFailed => '盐选首页暂时无法加载';

  @override
  String get saltStoryEntry => '入口';

  @override
  String get saltStoryModuleMustSee => '进站必看';

  @override
  String get saltStoryModuleTodayRead => '今日阅读';

  @override
  String get saltStoryModuleEveryoneWatch => '大家都在看';

  @override
  String get saltStoryModuleRecommended => '为你推荐';

  @override
  String get saltStoryBoard => '故事榜单';

  @override
  String get saltStoryHotBoard => '热度榜';

  @override
  String get saltStoryReputationBoard => '口碑榜';

  @override
  String get saltStoryNewBoard => '新书榜';

  @override
  String get saltStoryLongBoard => '长篇榜';

  @override
  String saltStoryBoardNumber(int index) {
    return '榜单 $index';
  }

  @override
  String get saltPillOnShelf => '已加入书架';

  @override
  String get saltPillLiked => '已赞';

  @override
  String get saltBrandLong => '长篇';

  @override
  String saltScore(String score) {
    return '评分 $score';
  }

  @override
  String saltUpdatedSections(int count) {
    return '更新 $count 节';
  }

  @override
  String saltFinishedWithCount(int count) {
    return '已完结，共 $count 节';
  }

  @override
  String saltUpdatedTo(int index) {
    return '已更新至第 $index 节';
  }

  @override
  String get saltShelfLiked => '赞过';

  @override
  String get saltShelfComments => '弹评';

  @override
  String get saltShelfHistory => '历史记录';

  @override
  String get saltShelfLists => '书单';

  @override
  String get answerLabel => '回答';

  @override
  String get drawerBrowse => '浏览';

  @override
  String get drawerColumns => '专栏推荐';

  @override
  String get drawerTopicCategories => '话题分类';

  @override
  String get drawerHotTopics => '热门话题';

  @override
  String get drawerHistory => '历史记录';

  @override
  String get drawerMyContent => '我的内容';

  @override
  String get drawerMessages => '消息';

  @override
  String get drawerCollections => '收藏';

  @override
  String get drawerBookshelf => '书架';

  @override
  String get drawerFindUsers => '查找用户';

  @override
  String get drawerAccount => '账号';

  @override
  String get drawerLoginOrAddAccount => '登录或添加账号';

  @override
  String get drawerAccountManagement => '账号管理';

  @override
  String get drawerApp => '应用';

  @override
  String get drawerSettings => '设置';

  @override
  String get drawerClose => '关闭侧边栏';

  @override
  String get drawerOpen => '打开侧边栏';

  @override
  String drawerVersion(String version) {
    return '知阅 $version';
  }

  @override
  String get commonBack => '返回';

  @override
  String get commonClose => '关闭';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确定';

  @override
  String get commonSave => '保存';

  @override
  String get commonReset => '恢复默认';

  @override
  String get commonClear => '清空';

  @override
  String get commonDelete => '删除';

  @override
  String get commonDone => '完成';

  @override
  String get commonRetry => '重试';

  @override
  String get commonSearch => '搜索';

  @override
  String get commonSelect => '请选择';

  @override
  String get commonLoading => '加载中…';

  @override
  String get commonMore => '更多';

  @override
  String get commonReply => '回复';

  @override
  String get commonPublish => '发布';

  @override
  String get commonPublishing => '发布中';

  @override
  String get commonFollow => '关注';

  @override
  String get commonRefresh => '刷新';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonShare => '分享';

  @override
  String get commonFailed => '加载失败，请重试';

  @override
  String get commonNoMore => '没有更多内容了';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsBackup => '备份';

  @override
  String get settingsAccount => '账号';

  @override
  String get settingsLogs => '日志';

  @override
  String get settingsAboutSection => '关于';

  @override
  String get settingsUpdates => '更新';

  @override
  String get settingsData => '数据';

  @override
  String get settingsAppearanceSubtitle => '深色模式、语言与显示';

  @override
  String get settingsPersonalizationSubtitle => '首页、推荐与内容偏好';

  @override
  String get settingsBackupSubtitle => 'WebDAV 数据同步';

  @override
  String get settingsAccountSubtitle => '会话与登录状态';

  @override
  String get settingsLogsSubtitle => '诊断日志与问题排查';

  @override
  String get settingsAboutSubtitle => '恢复默认设置与应用信息';

  @override
  String get settingsUpdatesSubtitle => '检查并安装新版本';

  @override
  String get settingsDataSubtitle => '历史记录、缓存与存储';

  @override
  String get settingsHomeContent => '首页与内容';

  @override
  String get settingsStartupPage => '启动页面';

  @override
  String get settingsRecommendation => '推荐策略';

  @override
  String get settingsServer => '服务器';

  @override
  String get settingsLocal => '本地';

  @override
  String get settingsHybrid => '混合';

  @override
  String get settingsDensity => '内容密度';

  @override
  String get settingsComfortable => '舒适';

  @override
  String get settingsCompact => '紧凑';

  @override
  String get settingsRefreshHome => '重复点击首页时刷新';

  @override
  String get settingsRefreshHomeSubtitle => '再次点击已选中的首页按钮时回到顶部并刷新';

  @override
  String get settingsShowImages => '显示推荐图片';

  @override
  String get settingsShowImagesSubtitle => '关闭后首页只显示文字、作者和互动信息';

  @override
  String get settingsShowMetrics => '显示互动数据';

  @override
  String get settingsShowMetricsSubtitle => '显示赞同、收藏、评论和发布日期';

  @override
  String get settingsLocalBehavior => '本地推荐行为';

  @override
  String settingsLocalEvents(int count) {
    return '本机已记录 $count 条行为';
  }

  @override
  String get settingsFeedOrder => '首页分区排序';

  @override
  String get settingsFilterStats => '内容过滤统计';

  @override
  String get settingsReadingDisplay => '阅读与显示';

  @override
  String get settingsDarkMode => '黑夜模式';

  @override
  String get settingsDarkModeOnSubtitle => '使用深色背景和低亮度表面';

  @override
  String get settingsDarkModeOffSubtitle => '使用浅色背景和明亮表面';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSubtitle => '选择应用界面语言';

  @override
  String get settingsTextSize => '阅读字号';

  @override
  String get settingsSmall => '小';

  @override
  String get settingsStandard => '标准';

  @override
  String get settingsLarge => '大';

  @override
  String get settingsFollowSystemTextScale => '跟随系统字号';

  @override
  String get settingsFollowSystemTextScaleSubtitle => '在阅读字号基础上叠加系统显示大小';

  @override
  String get settingsReduceMotion => '减少动态效果';

  @override
  String get settingsReduceMotionSubtitle => '减少页面切换和组件动画';

  @override
  String get settingsGlass => '液态玻璃效果';

  @override
  String get settingsGlassOnSubtitle => '保留玻璃反馈与透明层次';

  @override
  String get settingsGlassOffSubtitle => '流畅模式：使用低开销的实色按钮和导航栏';

  @override
  String get settingsPersonalization => '个性化功能';

  @override
  String get settingsFocusSearch => '进入搜索页时自动打开输入法';

  @override
  String get settingsFocusSearchOn => '进入搜索页后自动聚焦搜索框';

  @override
  String get settingsFocusSearchOff => '进入搜索页后手动点击搜索框';

  @override
  String get settingsImagesStorage => '图片与存储';

  @override
  String get settingsKeepHistory => '保留浏览记录';

  @override
  String settingsKeepHistoryOn(int count) {
    return '仅保存在本机 · $count 条';
  }

  @override
  String get settingsKeepHistoryOff => '打开内容不会写入本机历史';

  @override
  String get settingsPrefetchImages => '预加载列表图片';

  @override
  String get settingsPrefetchImagesSubtitle => '提前加载即将显示的头像和正文图片';

  @override
  String get settingsImageCache => '图片缓存容量';

  @override
  String get settingsEconomy => '节省';

  @override
  String get settingsRoomy => '充足';

  @override
  String get settingsNoCacheImages => '当前没有缓存图片';

  @override
  String settingsCachedImages(int count) {
    return '已清理 $count 张缓存图片';
  }

  @override
  String get settingsPrivacyData => '隐私与数据';

  @override
  String get settingsKeepSearch => '保留搜索记录';

  @override
  String settingsKeepSearchOn(int count) {
    return '仅保存在本机 · $count 条';
  }

  @override
  String get settingsKeepSearchOff => '新搜索不会写入本机';

  @override
  String get settingsShowHot => '显示热搜';

  @override
  String get settingsShowHotOn => '在搜索页显示知乎热搜';

  @override
  String get settingsShowHotOff => '搜索页不加载热搜内容';

  @override
  String get settingsWebDav => 'WebDAV 同步';

  @override
  String get settingsAccountSessions => '账号与多端登录';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsOther => '其他';

  @override
  String get settingsDiagnostics => '诊断日志';

  @override
  String get settingsUpdate => '软件更新';

  @override
  String get settingsRestoreDefaults => '恢复默认设置';

  @override
  String get settingsAbout => '关于知阅';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String get settingsFeedOrderSubtitle => '按住右侧拖动，首页顶栏与左右滑动顺序会同步更新。';

  @override
  String get settingsRestoreDefaultsMessage => '所有设置将恢复默认，不会退出账号。';

  @override
  String get settingsRestored => '软件设置已恢复默认';

  @override
  String get settingsSignOutMessage => '本机保存的登录信息将被删除。';

  @override
  String get settingsSignedOut => '已退出登录';

  @override
  String get settingsClearBrowsing => '清空浏览记录';

  @override
  String get settingsNoBrowsingHistory => '目前没有记录';

  @override
  String settingsDeleteBrowsing(int count) {
    return '删除 $count 条本机记录';
  }

  @override
  String get settingsClearImageCache => '清理图片缓存';

  @override
  String get settingsClearOfflineChapters => '清理离线章节';

  @override
  String get settingsClearOfflineChaptersSubtitle => '删除阅读和下载时保存的盐选正文';

  @override
  String get settingsClearSearch => '清空搜索记录';

  @override
  String get settingsNoSearchHistory => '目前没有记录';

  @override
  String settingsDeleteSearch(int count) {
    return '删除 $count 条本机记录';
  }

  @override
  String get settingsWebDavConfigured => '已配置 · 搜索、历史、离线小说和回答缓存';

  @override
  String get settingsWebDavSubtitle => '同步搜索记录、浏览历史、离线小说和回答缓存';

  @override
  String get settingsAccountSessionsSubtitle => '扫码登录、保存账号槽位并快速切换';

  @override
  String get settingsSignOutSubtitle => '移除本机登录信息';

  @override
  String get settingsDiagnosticsOn => '已开启 · 管理网络、性能日志并导出';

  @override
  String get settingsDiagnosticsOff => '定位接口异常、内容加载失败和卡顿问题';

  @override
  String get settingsUpdateSubtitle => '安全检查、下载并安装新版本';

  @override
  String get settingsRestoreDefaultsSubtitle => '不会退出账号';

  @override
  String get searchTitle => '搜索';

  @override
  String get searchPlaceholder => '搜索知平内容';

  @override
  String get searchFilter => '筛选';

  @override
  String get searchGeneral => '综合';

  @override
  String get searchRealtime => '实时';

  @override
  String get searchUsers => '用户';

  @override
  String get searchStories => '小说';

  @override
  String get searchArticles => '论文';

  @override
  String get searchVideos => '视频';

  @override
  String get searchTopics => '话题';

  @override
  String get searchColumns => '专栏';

  @override
  String get searchKnowledge => '知识';

  @override
  String get searchIdeas => '想法';

  @override
  String get searchCircles => '圈子';

  @override
  String get searchPodcasts => '播客';

  @override
  String get searchHot => '热搜';

  @override
  String get searchHistory => '历史搜索';

  @override
  String get searchUnavailableTitle => '暂时无法加载';

  @override
  String get searchUnavailableMessage => '匿名内容服务暂时不可用，请稍后重试。';

  @override
  String get searchNoResults => '没有找到相关内容';

  @override
  String get searchScope => '搜索范围';

  @override
  String get searchMoreScopes => '左右滑动查看更多';

  @override
  String get searchOverview => '搜索概览';

  @override
  String get searchStartHint => '输入关键词开始搜索';

  @override
  String get searchCurrentScope => '当前范围';

  @override
  String get searchActiveFilters => '已启用筛选';

  @override
  String get searchFilterType => '内容类型';

  @override
  String get searchFilterSort => '排序';

  @override
  String get searchFilterTime => '时间范围';

  @override
  String get searchFilterAnyType => '不限类型';

  @override
  String get searchFilterAnswers => '只看回答';

  @override
  String get searchFilterArticles => '只看文章';

  @override
  String get searchFilterVideos => '只看视频';

  @override
  String get searchSortRelevance => '综合排序';

  @override
  String get searchSortMostUpvoted => '最多赞同';

  @override
  String get searchSortNewest => '最新发布';

  @override
  String get searchTimeAny => '不限时间';

  @override
  String get searchTimeDay => '一天内';

  @override
  String get searchTimeWeek => '一周内';

  @override
  String get searchTimeMonth => '一月内';

  @override
  String get searchTimeThreeMonths => '三月内';

  @override
  String get searchTimeHalfYear => '半年内';

  @override
  String get searchTimeYear => '一年内';

  @override
  String get commentAll => '全部评论';

  @override
  String commentCount(String count) {
    return '评论 $count';
  }

  @override
  String get commentDefault => '默认';

  @override
  String get commentLatest => '最新';

  @override
  String get commentInputPlaceholder => '理性发言，友善互动';

  @override
  String get commentReply => '回复这条评论';

  @override
  String get commentPublishReply => '发布你的回复';

  @override
  String get commentPublishComment => '发布你的评论';

  @override
  String commentReplyTo(String name) {
    return '回复 @$name';
  }

  @override
  String get commentMention => '提及用户';

  @override
  String get commentCollapse => '收起编辑器';

  @override
  String get commentExpand => '展开编辑器';

  @override
  String get commentImage => '图片评论';

  @override
  String get loginTitle => '登录';

  @override
  String get loginAccount => '账号';

  @override
  String get loginPhone => '手机号';

  @override
  String get loginPassword => '密码';

  @override
  String get loginCode => '验证码';

  @override
  String get loginContinue => '同意并继续';

  @override
  String get loginCancel => '暂不同意';

  @override
  String get loginScanSuccess => '扫码登录成功';

  @override
  String get detailReadAnswer => '写回答';

  @override
  String get detailRefreshAnswers => '刷新回答';

  @override
  String get detailSearchBody => '搜索正文';

  @override
  String get detailReadAloud => '朗读正文';

  @override
  String get detailExportTxt => '导出为 TXT';

  @override
  String get detailExportMarkdown => '导出为 Markdown';

  @override
  String get detailExportHtml => '导出为 HTML';

  @override
  String get commonExitApp => '再按一次退出应用';

  @override
  String get commonEmoji => '表情';

  @override
  String get commonRemove => '移除';

  @override
  String get commonOpenZhihu => '打开知乎验证';

  @override
  String get commonExpired => '过期';

  @override
  String get commonReport => '举报';

  @override
  String get commonUntitledContent => '未命名内容';

  @override
  String get commonUntitledObject => '未命名对象';

  @override
  String get commonAuthorProfile => '查看作者个人主页';

  @override
  String get commonZhihuUser => '知乎用户';

  @override
  String get commonLike => '赞同';

  @override
  String get commonUnlike => '取消赞同';

  @override
  String get commonDislike => '踩';

  @override
  String get commonDeleteComment => '删除评论';

  @override
  String get commonCommentActionFailed => '评论操作失败，请稍后重试';

  @override
  String get commonOpenLink => '打开链接';

  @override
  String commonReplyCount(String count) {
    return '$count 条回复';
  }

  @override
  String commonViewAllReplies(String count) {
    return '查看全部 $count 条回复';
  }

  @override
  String get drawerExpired => '过期';

  @override
  String get loginHeader => '登录知乎';

  @override
  String get loginQrSubtitle => '知乎 App 扫码登录';

  @override
  String get loginPasswordSubtitle => '使用账号密码安全登录';

  @override
  String get loginPhoneSubtitle => '手机号快捷登录';

  @override
  String get loginProgressPassword => '登录进度：账号密码';

  @override
  String get loginProgressCode => '登录进度：验证码';

  @override
  String get loginProgressPhone => '登录进度：手机号';

  @override
  String get loginAgreementTitle => '登录前请确认';

  @override
  String get loginAgreementMessage => '请阅读并同意《知乎用户协议》与隐私政策后继续登录。';

  @override
  String get loginQrLoading => '正在获取二维码';

  @override
  String get loginQrInvalid => '知乎没有返回有效二维码';

  @override
  String get loginQrScanHint => '请打开知乎 App 扫一扫';

  @override
  String loginQrFetchFailed(String error) {
    return '二维码获取失败：$error';
  }

  @override
  String get loginQrExpired => '二维码已过期，请点击刷新';

  @override
  String get loginQrRiskControl => '需要先在知乎网页完成安全验证，请稍后刷新二维码';

  @override
  String get loginQrConfirm => '请在知乎 App 上确认登录';

  @override
  String get loginVerifying => '正在验证登录';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get loginQrLabel => '知乎登录二维码';

  @override
  String get loginRefreshQr => '刷新二维码';

  @override
  String get loginQrHint => '二维码有效期内可在其他设备确认登录；登录成功后会保留当前账号槽位。';

  @override
  String get feedbackNotInterested => '不喜欢该内容';

  @override
  String get feedbackReduceRecommendation => '将减少推荐';

  @override
  String get feedbackTitle => '减少此类内容';

  @override
  String get feedbackReduced => '已减少此类内容';

  @override
  String get feedbackInvalidReport => '举报地址无效';

  @override
  String get feedbackMissingAction => '该反馈项缺少可执行动作';

  @override
  String get feedbackLoading => '正在加载更多反馈选项…';

  @override
  String get feedbackReload => '重新加载';

  @override
  String get accountSessionCheckTitle => '确认登录状态';

  @override
  String get accountSessionCheckMessage => '知乎返回了账号会话异常信号。当前登录信息仍保留在本机，是否清理？';

  @override
  String get accountSessionCheckDetails =>
      '确认清理后仍可在“设置 > 账号与多端登录”中恢复最近一次会话；彻底删除需要再次手动确认。';

  @override
  String get accountSessionClearKeepBackup => '清理并保留恢复副本';

  @override
  String get accountSessionKeep => '保留登录状态';

  @override
  String get settingsDisableSearchHistoryTitle => '关闭搜索记录？';

  @override
  String get settingsDisableSearchHistoryMessage => '关闭后会同时清空本机已有的搜索记录。';

  @override
  String get settingsDisableAndClear => '关闭并清空';

  @override
  String get settingsNoSearchHistoryMessage => '目前没有搜索记录';

  @override
  String get settingsClearSearchHistoryTitle => '清空搜索记录？';

  @override
  String get settingsClearSearchHistoryMessage => '这只会删除保存在本机的搜索关键词。';

  @override
  String get settingsSearchHistoryCleared => '搜索记录已清空';

  @override
  String get settingsDisableBrowsingHistoryTitle => '关闭浏览记录？';

  @override
  String get settingsDisableBrowsingHistoryMessage => '关闭后会同时清空知阅保存在本机的浏览记录。';

  @override
  String get settingsNoBrowsingHistoryMessage => '目前没有浏览记录';

  @override
  String get settingsClearBrowsingHistoryTitle => '清空浏览记录？';

  @override
  String get settingsClearBrowsingHistoryMessage => '这只会删除知阅保存在本机的浏览内容索引。';

  @override
  String get settingsBrowsingHistoryCleared => '浏览记录已清空';

  @override
  String get settingsClearOfflineTitle => '清理离线章节？';

  @override
  String get settingsClearOfflineMessage => '已缓存的盐选正文将被删除，之后阅读或导出时需要重新下载。';

  @override
  String get settingsClearOfflineAction => '清理';

  @override
  String settingsOfflineCleared(int count) {
    return '已清理 $count 个离线章节';
  }

  @override
  String get settingsOfflineClearFailed => '离线章节清理失败，请重试';

  @override
  String settingsCacheSummary(int count, String size) {
    return '$count 张 · $size MB';
  }

  @override
  String get commentEmoji => '表情';

  @override
  String get commentRemoveSticker => '移除贴纸';

  @override
  String get commentSelectedImage => '已选择的评论图片';

  @override
  String get commentUploadingImage => '正在上传图片…';

  @override
  String get commentImageAdded => '图片已添加';

  @override
  String get commentRemoveImage => '移除图片';

  @override
  String get commentUsernameRequired => '请输入用户名完成提及';

  @override
  String commentMentioned(String name) {
    return '已提及 $name';
  }

  @override
  String get commentLoadingGift => '正在加载礼物';

  @override
  String get commentNoGifts => '暂无可用礼物';

  @override
  String get commentImageAddedPending => '图片已添加，登录后可发布';

  @override
  String get commentSignInRequired => '请先登录后再发布';

  @override
  String get commentUploadSignInRequired => '请先登录后再发布图片';

  @override
  String get commentImageUploadNoUrl => '图片上传未返回地址';

  @override
  String commentImagesCount(int count) {
    return '$count 张评论图片';
  }

  @override
  String get commentViewImage => '查看评论图片';

  @override
  String get commentCloseImage => '关闭图片';

  @override
  String get commentSaveImage => '保存到相册';

  @override
  String commentSavedTo(String location) {
    return '已保存到 $location';
  }

  @override
  String get commentSaveFailed => '图片保存失败，请稍后重试';

  @override
  String get commentReportUnavailable => '举报功能暂未开放';

  @override
  String get commentNoText => '该评论没有可显示的文字内容';

  @override
  String get commentAuthorBadge => '作者';

  @override
  String get commentQuestionAuthor => '题主';

  @override
  String commentAuthorSemantics(String name) {
    return '评论作者 $name';
  }

  @override
  String get feedHotBadge => '热榜';

  @override
  String metricVoteup(String count) {
    return '赞同 $count';
  }

  @override
  String metricFavorite(String count) {
    return '收藏 $count';
  }

  @override
  String metricComment(String count) {
    return '评论 $count';
  }

  @override
  String metricThanks(String count) {
    return '感谢 $count';
  }

  @override
  String metricViews(String count) {
    return '浏览 $count';
  }

  @override
  String get metricThanked => '已感谢该回答';

  @override
  String get metricFavorited => '已收藏该回答';

  @override
  String metricFollowers(String count) {
    return '$count 位关注者';
  }

  @override
  String metricAnswers(String count) {
    return '$count 个回答';
  }

  @override
  String metricArticles(String count) {
    return '$count 篇文章';
  }

  @override
  String metricItems(String count) {
    return '$count 条内容';
  }

  @override
  String get contentTypeAnswer => '回答';

  @override
  String get contentTypeArticle => '文章';

  @override
  String get contentTypePeople => '用户';

  @override
  String get contentTypeQuestion => '问题';

  @override
  String get contentTypeColumn => '专栏';

  @override
  String get contentTypeTopic => '话题';

  @override
  String get contentTypeIdea => '想法';

  @override
  String get contentTypeComment => '评论';

  @override
  String accountSwitchedTo(String name) {
    return '已切换到 $name';
  }

  @override
  String get accountSessionRestoreFailed => '账号会话验证失败，已恢复之前的登录状态';

  @override
  String get collectionsLoginRequired => '登录知乎后可以查看自己的收藏';

  @override
  String get collectionsTitle => '我的收藏';

  @override
  String get collectionTitle => '收藏集';

  @override
  String get collectionEmpty => '这个收藏集暂时没有内容';

  @override
  String get collectionsEmpty => '还没有创建或收藏内容';

  @override
  String get loginPasswordRequired => '请输入密码';

  @override
  String get loginQrSaveFailed => '扫码登录成功，但账号槽位保存失败，请稍后重试';

  @override
  String get loginHumanVerification => '请先完成人机验证';

  @override
  String get loginCodeSendFailed => '验证码发送失败，请稍后重试';

  @override
  String get loginFailedNetwork => '登录失败，请检查网络后重试';

  @override
  String get loginFailedCredentials => '登录失败，请检查账号和密码后重试';

  @override
  String get loginGetCode => '获取验证码';

  @override
  String get loginContinueSignIn => '继续登录';

  @override
  String get loginPasswordSignIn => '账号密码登录';

  @override
  String get loginPhoneSignIn => '手机号登录';

  @override
  String get loginQrSignIn => '扫码登录';

  @override
  String get loginAccountAppeal => '账号申诉';

  @override
  String get loginAccountAppealHint => '遇到问题？账号申诉';

  @override
  String get loginPhonePlaceholder => '国家/地区代码 + 手机号';

  @override
  String get loginAccountPlaceholder => '手机号 / 邮箱';

  @override
  String get loginPasswordPlaceholder => '密码';

  @override
  String get loginCodePlaceholder => '输入 6 位验证码';

  @override
  String loginCodeSent(String phone) {
    return '验证码已发送至 $phone';
  }

  @override
  String get loginChangePhone => '更换手机号';

  @override
  String get loginNoCode => '没有收到？';

  @override
  String loginResendAfter(int seconds) {
    return '${seconds}s 后重试';
  }

  @override
  String get loginAgree => '同意';

  @override
  String get loginUserAgreement => '《知乎用户协议》';

  @override
  String get loginPrivacyPolicy => '与隐私政策';

  @override
  String get commonSelected => '，已选择';

  @override
  String get searchSuggestion => '搜索补全';

  @override
  String searchSuggestionFor(String query) {
    return '搜索建议 $query';
  }

  @override
  String searchSearching(String query) {
    return '正在查找“$query”';
  }

  @override
  String get searchDesktopHint => '滚动结果列表加载更多，点击卡片查看详情。';

  @override
  String get searchRelated => '相关搜索';

  @override
  String get searchRecentContent => '近期内容';

  @override
  String get searchContinue => '继续查找';

  @override
  String get searchUntitledNovel => '未命名小说';

  @override
  String get searchUntitledVideo => '未命名视频';

  @override
  String searchMetricFollows(String count) {
    return '$count 关注';
  }

  @override
  String searchMetricQuestions(String count) {
    return '$count 个问题';
  }

  @override
  String searchMetricMembers(String count) {
    return '$count 成员';
  }

  @override
  String searchMetricDiscussions(String count) {
    return '$count 讨论';
  }

  @override
  String searchMetricParticipants(String count) {
    return '$count 人参与';
  }

  @override
  String searchMetricLiveContent(String count) {
    return '$count 场内容';
  }

  @override
  String searchMetricPlayCount(String count) {
    return '$count 次播放';
  }

  @override
  String searchHotScoreWan(String value) {
    return '$value 万';
  }

  @override
  String get userTitle => '用户';

  @override
  String get userProfileTitle => '用户主页';

  @override
  String get userFindTitle => '查找用户';

  @override
  String get userFindSubtitle => '输入资料链接中的用户 token，查看公开资料与内容列表';

  @override
  String get userIdHint => '用户 ID';

  @override
  String get userViewProfile => '查看用户资料';

  @override
  String get userContentRelations => '内容与关系';

  @override
  String get userEmpty => '这里还没有用户';

  @override
  String get userSignInToFollow => '登录后可关注用户';

  @override
  String get userFollowed => '已关注';

  @override
  String get userFollow => '＋ 关注';

  @override
  String userSearchHint(String name) {
    return '搜索 $name 发布的内容';
  }

  @override
  String userSearchPrompt(String name) {
    return '搜索 $name 发布过的回答、文章和想法';
  }

  @override
  String get userNoResults => '没有找到相关内容';

  @override
  String get userLoadFailed => '暂时无法打开用户资料';

  @override
  String get userInfo => '用户信息';

  @override
  String get userFollowers => '关注者';

  @override
  String get userFollowingPeople => '关注的人';

  @override
  String get userAnswers => '用户回答';

  @override
  String get userArticles => '用户文章';

  @override
  String get userCreatedArticles => '用户创作文章';

  @override
  String get userContributedArticles => '用户贡献文章';

  @override
  String get userColumns => '用户专栏';

  @override
  String get userFollowingColumns => '关注专栏';

  @override
  String get userFollowingQuestions => '关注问题';

  @override
  String get userFollowingCollections => '关注收藏集';

  @override
  String get userFollowingTopics => '关注话题';

  @override
  String get userIdRequired => '请输入用户 ID';

  @override
  String get sessionTitle => '账号';

  @override
  String get sessionSignInZhihu => '登录知乎';

  @override
  String get sessionPhoneLogin => '手机号登录';

  @override
  String get sessionWebLogin => '网页登录';

  @override
  String get sessionSaved => '登录信息已保存';

  @override
  String get sessionCleared => '登录信息已清除';

  @override
  String get sessionImport => '导入登录信息';

  @override
  String get sessionShowSensitive => '临时显示敏感值';

  @override
  String get sessionHideSensitive => '重新隐藏敏感值';

  @override
  String get sessionAdvanced => '高级设置';

  @override
  String get sessionOptionalCookie => 'Cookie（可选）';

  @override
  String get sessionOptionalMsId => 'X-MS-ID（可选）';

  @override
  String get sessionManualZse => '手工 X-Zse-96';

  @override
  String get sessionSignTarget => '签名目标';

  @override
  String get sessionOtherHeaders => '其他 Header';

  @override
  String get sessionSaving => '保存中…';

  @override
  String get sessionSave => '保存';

  @override
  String get sessionClear => '清除登录信息';

  @override
  String get contentTypeContent => '内容';

  @override
  String get userProfileSearchContent => '搜索 TA 的内容';

  @override
  String get userProfileCopyLink => '复制主页链接';

  @override
  String get userProfileHomeTab => '主页';

  @override
  String get userProfileCreationsTab => '创作';

  @override
  String get userProfileActivitiesTab => '动态';

  @override
  String get userProfileVoteupsTab => '赞同';

  @override
  String get userProfileFollowersList => '关注他的人';

  @override
  String get userProfileFollowingList => '他关注的人';

  @override
  String get userProfileLoginRequired => '登录后可使用此功能';

  @override
  String get userProfileUnfollowTitle => '取消关注？';

  @override
  String userProfileUnfollowMessage(String name) {
    return '将不再关注 $name';
  }

  @override
  String get userProfileUnfollowAction => '取消关注';

  @override
  String get userProfileLinkCopied => '主页链接已复制';

  @override
  String userProfileIpLocation(String location) {
    return 'IP 属地 $location';
  }

  @override
  String get userProfileFollowers => '关注者';

  @override
  String get userProfileFollowing => '关注';

  @override
  String get userProfileUserAnswers => '用户回答';

  @override
  String get userProfileUserArticles => '用户文章';

  @override
  String get userProfileCreatedArticles => '创作文章';

  @override
  String get userProfileUserCreatedArticles => '用户创作文章';

  @override
  String get userProfileContributedArticles => '贡献文章';

  @override
  String get userProfileUserContributedArticles => '用户贡献文章';

  @override
  String get userProfileCreatedColumns => '创建的专栏';

  @override
  String get userProfileUserColumns => '用户专栏';

  @override
  String get userProfileFollowingColumns => '关注专栏';

  @override
  String get userProfileFollowingQuestions => '关注问题';

  @override
  String get userProfileFollowingCollections => '关注收藏集';

  @override
  String get userProfileFollowingTopics => '关注话题';

  @override
  String get userProfileReceivedUpvotes => '获赞';

  @override
  String get userProfileReceivedThanks => '获感谢';

  @override
  String get userProfileReceivedFavorites => '获收藏';

  @override
  String get userProfilePersonalInfo => '个人资料';

  @override
  String get userProfileAchievements => '个人成就';

  @override
  String get userProfilePublicCreations => '公开创作';

  @override
  String get userProfileFollowingAndCollections => '关注与收藏';

  @override
  String get userProfileFollowingHidden => '对方已隐藏关注列表';

  @override
  String get userProfileFollowedYou => '关注了你';

  @override
  String get userProfileMutualFollow => '互相关注';

  @override
  String get userProfileMessage => '私信';

  @override
  String get userProfileNoPublicContent => '还没有公开内容';

  @override
  String get webdavTitle => 'WebDAV 同步';

  @override
  String get webdavIntroTitle => '跨设备同步本地内容';

  @override
  String get webdavIntroMessage =>
      '只同步搜索记录、浏览历史、盐选离线章节/书架和回答详情缓存。登录凭据、Cookie、设备标识与本设置不会上传。';

  @override
  String get webdavConnectionSettings => '连接设置';

  @override
  String get webdavProviderType => '服务类型';

  @override
  String get webdavProviderGeneric => '通用 WebDAV';

  @override
  String get webdavProviderGoogle => 'Google Drive（WebDAV 网关）';

  @override
  String get webdavProviderOneDrive => 'Microsoft OneDrive（WebDAV）';

  @override
  String get webdavProviderGenericDescription => '适用于支持 WebDAV 的云盘、NAS 和自建服务。';

  @override
  String get webdavProviderGoogleDescription =>
      'Google Drive 本身不提供原生 WebDAV，请填写连接到 Google Drive 的 WebDAV 网关地址。';

  @override
  String get webdavProviderOneDriveDescription =>
      '填写 OneDrive 的 WebDAV 兼容入口；部分账号或服务可能已限制旧版入口。';

  @override
  String get webdavProviderGenericHint => 'https://dav.example.com/';

  @override
  String get webdavProviderGoogleHint => 'https://gateway.example.com/dav/';

  @override
  String get webdavProviderOneDriveHint => 'https://d.docs.live.net/<CID>/';

  @override
  String get webdavEndpoint => 'WebDAV 地址';

  @override
  String get webdavHttpsHint => '仅支持 HTTPS，不要把密码写进 URL';

  @override
  String get webdavRemoteDirectory => '远程目录';

  @override
  String get webdavRemoteDirectoryHint => '会自动创建 v1、answers 和 chapters 子目录';

  @override
  String get webdavAuthMethod => '认证方式';

  @override
  String get webdavAuthBasic => '账号密码 / 应用专用密码';

  @override
  String get webdavAuthBearer => 'Bearer 访问令牌';

  @override
  String get webdavUsername => '用户名';

  @override
  String get webdavPasswordOrAppPassword => '密码 / 应用专用密码';

  @override
  String get webdavAccessToken => '访问令牌';

  @override
  String get webdavEnable => '启用 WebDAV 同步';

  @override
  String get webdavEnableSubtitle => '关闭后不会执行网络同步，已保存的本机配置不会删除';

  @override
  String get webdavStartupSync => '启动后自动同步';

  @override
  String get webdavStartupSyncSubtitle => '后台执行，不阻塞首页首帧；失败后可手动重试';

  @override
  String get webdavSyncContent => '同步内容';

  @override
  String get webdavSyncContentSummary =>
      '• 搜索记录与浏览历史\n• 盐选书架及已下载章节\n• 回答详情缓存（恢复后仍可手动刷新获取最新内容）';

  @override
  String webdavStatus(String message) {
    return '状态：$message';
  }

  @override
  String get webdavLoading => '正在读取 WebDAV 设置';

  @override
  String get webdavConfiguredStatus => 'WebDAV 已配置';

  @override
  String get webdavNotConfigured => '尚未配置 WebDAV';

  @override
  String get webdavSettingsSaved => 'WebDAV 设置已保存';

  @override
  String get webdavClosedStatus => 'WebDAV 已关闭';

  @override
  String get webdavTesting => '正在测试 WebDAV 连接';

  @override
  String get webdavSyncing => '正在同步搜索、历史、小说和回答缓存';

  @override
  String webdavSyncCompleted(String uploaded, String downloaded) {
    return '同步完成：上传 $uploaded 项，恢复 $downloaded 项';
  }

  @override
  String webdavConfigFailed(String error) {
    return 'WebDAV 配置无效：$error';
  }

  @override
  String get webdavSyncNotEnabled => 'WebDAV 同步未启用';

  @override
  String get webdavNotSynced => '尚未同步';

  @override
  String get webdavSyncNow => '立即同步';

  @override
  String get webdavTestConnection => '测试连接';

  @override
  String get webdavDisable => '关闭同步';

  @override
  String get webdavClearLocalSettings => '清除本机配置和凭据';

  @override
  String webdavLoadFailed(String error) {
    return '读取 WebDAV 设置失败：$error';
  }

  @override
  String webdavSaveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String get webdavConnected => 'WebDAV 连接成功';

  @override
  String webdavConnectionFailed(String error) {
    return '连接失败：$error';
  }

  @override
  String webdavSyncFailed(String error) {
    return '同步失败：$error';
  }

  @override
  String get webdavDisabled => 'WebDAV 同步已关闭，凭据仍保留在本机私有数据库';

  @override
  String get webdavClearTitle => '清除 WebDAV 配置？';

  @override
  String get webdavClearMessage => '这会删除本机保存的 WebDAV 地址、账号和凭据，不会删除远端同步数据。';

  @override
  String get webdavCleared => '本机 WebDAV 配置和凭据已清除';

  @override
  String webdavClearFailed(String error) {
    return '清除失败：$error';
  }

  @override
  String get webdavInvalidEndpoint => 'WebDAV 地址无效';

  @override
  String get webdavHttpsRequired => 'WebDAV 地址必须使用 HTTPS';

  @override
  String get webdavEndpointCredentials => 'WebDAV 地址不能包含账号、密码、查询参数或片段';

  @override
  String get webdavCredentialCharacters => 'WebDAV 凭据不能包含换行或控制字符';

  @override
  String get webdavInvalidDirectory => '远程目录无效';

  @override
  String get webdavUsernameRequired => '账号密码认证需要填写用户名';

  @override
  String get webdavSecretRequired => '请填写密码、应用专用密码或访问令牌';

  @override
  String get webdavCredentialTooLong => '访问凭据过长';

  @override
  String get commonCopy => '复制';

  @override
  String get commonSelectAll => '全选';

  @override
  String get detailDownvote => '反对';

  @override
  String get detailDownvoted => '已反对';

  @override
  String get detailCommentAction => '评论';

  @override
  String get detailViewComments => '查看评论';

  @override
  String detailViewCommentsCount(String count) {
    return '查看 $count 条评论';
  }

  @override
  String get detailFavorite => '收藏';

  @override
  String detailFavoriteCount(String count) {
    return '收藏 $count';
  }

  @override
  String get detailAuthor => '作者';

  @override
  String get detailFollowed => '已关注';

  @override
  String get detailFollow => '关注';

  @override
  String get detailUnfollowAuthor => '取消关注作者';

  @override
  String get detailFollowAuthor => '关注作者';

  @override
  String get detailTop => '顶部';

  @override
  String get detailBackToTop => '回到帖子顶部';

  @override
  String get detailBottom => '底部';

  @override
  String get detailJumpToBottom => '跳到帖子底部';

  @override
  String get detailCollapseMore => '收起更多功能';

  @override
  String get detailMoreActions => '更多操作';

  @override
  String get detailExportActions => '导出内容';

  @override
  String get detailSignInFromMe => '请先在“我”中登录。';

  @override
  String get detailWriteAnswerSubtitle => '创建对这个问题的新回答';

  @override
  String detailRefreshContent(String content) {
    return '刷新$content';
  }

  @override
  String get detailRefreshSubtitle => '忽略缓存并重新获取最新内容';

  @override
  String get detailSearchSubtitle => '输入关键词快速定位到正文内容';

  @override
  String detailReadAloudSubtitle(String content) {
    return '使用系统语音朗读当前$content';
  }

  @override
  String get detailExportTextSubtitle => '保存当前标题、作者和正文';

  @override
  String detailExportDocument(String format) {
    return '导出为 $format';
  }

  @override
  String get detailExportPdfSubtitle => '生成适合分享和打印的文档';

  @override
  String get detailExportDocumentSubtitle => '保留标题、作者、段落和正文图片链接';

  @override
  String get detailCopyAll => '复制全文';

  @override
  String get detailCopySubtitle => '复制当前标题、作者和正文';

  @override
  String get detailClearCache => '清除本条缓存';

  @override
  String get detailInviteAnswer => '邀请回答';

  @override
  String get detailCopyAnswer => '复制回答内容';

  @override
  String detailSelectionTooShort(int count) {
    return '至少选择 $count 个字';
  }

  @override
  String get detailCommentSelection => '评论这段话';

  @override
  String get detailCommentHint => '请输入你的评论';

  @override
  String detailActionUnavailable(String action) {
    return '$action功能暂不可用';
  }

  @override
  String get detailSignInRequired => '登录后可使用此功能';

  @override
  String get detailUnfollowTitle => '取消关注？';

  @override
  String detailUnfollowMessage(String name) {
    return '将不再关注 $name';
  }

  @override
  String get detailUnfollowAction => '取消关注';

  @override
  String get detailCacheCleared => '已清除本条回答缓存';

  @override
  String get detailImagePlaceholder => '[图片]';

  @override
  String get detailVideoPlaceholder => '[视频]';

  @override
  String detailImageCount(int count) {
    return '$count 张正文图片';
  }

  @override
  String get detailViewImage => '查看正文图片原图';

  @override
  String get detailCloseImage => '关闭图片';

  @override
  String get detailSaveImage => '保存到相册';

  @override
  String get detailImageSaved => '图片已保存';

  @override
  String get detailImageSavedTo => '已保存到相册';

  @override
  String get detailImageSaveFailed => '图片保存失败，请稍后重试';

  @override
  String get detailMyAnswer => '我的回答';

  @override
  String detailAuthorPrefix(String name) {
    return '作者：$name';
  }

  @override
  String get detailNoExportableBody => '当前回答没有可导出的正文';

  @override
  String get detailAnswerDetails => '回答详情';

  @override
  String detailExportedTo(String location) {
    return '已导出到 $location';
  }

  @override
  String get detailExportFailed => '导出失败，请重试';

  @override
  String detailDocumentExported(String format, String location) {
    return '已导出为 $format：$location';
  }

  @override
  String get detailStoppedReading => '已停止朗读';

  @override
  String get detailNoReadableBody => '当前回答没有可朗读的正文';

  @override
  String get detailReading => '正在朗读正文';

  @override
  String get detailTtsUnavailable => '系统语音不可用，请安装语音包';

  @override
  String get detailNoCopyableText => '当前回答没有可复制的正文';

  @override
  String get detailCopied => '已复制全文';

  @override
  String get detailSearchBodyTitle => '搜索正文';

  @override
  String get detailKeywordHint => '输入关键词';

  @override
  String get detailLocate => '定位';

  @override
  String detailBodyNotFound(String keyword) {
    return '正文中没有找到“$keyword”';
  }

  @override
  String detailLocated(String keyword) {
    return '已定位到“$keyword”';
  }

  @override
  String get detailWriteAnswer => '写回答';

  @override
  String get detailAnswerRequired => '回答内容不能为空';

  @override
  String get detailAnswerPublished => '回答已发布';

  @override
  String get commentSentence => '句子评论';

  @override
  String commentSentenceCount(String count) {
    return '$count 条句子评论';
  }

  @override
  String get commentWrite => '写评论';

  @override
  String commentReplyTitle(String target) {
    return '回复 $target';
  }

  @override
  String get commentReplyTargetComment => '这条评论';

  @override
  String get commentPublished => '评论已发布。';

  @override
  String get commentReplyPublished => '回复已发布。';

  @override
  String get commentDeleteTitle => '删除评论？';

  @override
  String get commentDeleteMessage => '该评论及其当前展示关系将从列表中移除。';

  @override
  String get commentDeleted => '评论已删除。';

  @override
  String get commentDeleteReplyTitle => '删除回复？';

  @override
  String get commentDeleteReplyMessage => '删除后不可恢复。';

  @override
  String get commentReplyDeleted => '回复已删除。';

  @override
  String get commentRepliesTitle => '评论回复';

  @override
  String get commentNoReplies => '还没有回复';

  @override
  String get commentNoComments => '还没有评论';

  @override
  String commentReplyCount(String count) {
    return '回复 $count';
  }

  @override
  String get commentEditorUnavailable => '暂时无法发表评论';

  @override
  String get commentGif => 'GIF';

  @override
  String get commentExpandEditor => '展开编辑器';

  @override
  String get contentFilterClearTitle => '清空过滤统计？';

  @override
  String get contentFilterClearMessage => '只会删除本机记录，不会改变知乎账号和服务端反馈设置。';

  @override
  String get contentFilterCleared => '内容过滤统计已清空';

  @override
  String get contentFilterClearStats => '清空统计';

  @override
  String get contentFilterStatsTitle => '内容过滤统计';

  @override
  String get contentFilterStatsLabel => '内容过滤统计';

  @override
  String get contentFilterActions => '反馈操作';

  @override
  String get contentFilterHidden => '已隐藏内容';

  @override
  String get contentFilterReasons => '过滤原因';

  @override
  String get contentFilterHint => '在首页卡片中选择“减少此类内容”后，这里会按原因累计统计。';

  @override
  String contentFilterCount(String count) {
    return '$count 次';
  }

  @override
  String get contentFilterLatest => '最近一次';

  @override
  String get contentFilterEmpty => '暂无记录';

  @override
  String get contentFilterSummaryEmpty => '记录每次减少内容的原因和结果';

  @override
  String contentFilterSummary(String actions, String hidden, String reasons) {
    return '$actions 次操作 · 已隐藏 $hidden 条 · $reasons 类原因';
  }

  @override
  String get accountSessionsNoCurrent => '当前没有可保存的登录会话';

  @override
  String get accountSessionsSaved => '当前登录会话已保存';

  @override
  String get accountSessionsSaveFailed => '账号槽位保存失败，请稍后重试';

  @override
  String accountSessionsSwitched(String name) {
    return '已切换到 $name';
  }

  @override
  String get accountSessionsSwitchFailed => '账号切换失败，请稍后重试';

  @override
  String get accountSessionsDeleteTitle => '删除账号槽位？';

  @override
  String accountSessionsDeleteActiveMessage(String name) {
    return '只删除本机保存的 $name，当前会话会退出本机并保留可恢复副本，不会退出其他设备。';
  }

  @override
  String accountSessionsDeleteMessage(String name) {
    return '只删除本机保存的 $name，不会退出其他设备。';
  }

  @override
  String get accountSessionsDeleted => '已删除本机账号槽位';

  @override
  String get accountSessionsDeleteFailed => '账号槽位删除失败，请稍后重试';

  @override
  String get accountSessionsNoRecovery => '没有可恢复的账号会话';

  @override
  String get accountSessionsRestored => '已恢复最近一次清理的账号会话';

  @override
  String get accountSessionsRestoreSaveFailed => '会话已恢复，但账号槽位保存失败，请稍后重试';

  @override
  String get accountSessionsPurgeTitle => '彻底清理恢复凭据？';

  @override
  String get accountSessionsPurgeMessage => '这会永久删除最近清理后保留的恢复副本，之后无法恢复。';

  @override
  String get accountSessionsPurgeAction => '彻底删除';

  @override
  String get accountSessionsPurged => '恢复凭据已彻底删除';

  @override
  String get accountSessionsPurgeFailed => '恢复凭据清理失败，请稍后重试';

  @override
  String get accountSessionsTitle => '账号与多端登录';

  @override
  String get accountSessionsSaveCurrent => '保存当前会话';

  @override
  String get accountSessionsIntro =>
      '扫码登录或手机号登录后的会话会保存在本机私有凭据数据库中。切换前会重新验证 /people/self；不会主动退出其他设备。';

  @override
  String get accountSessionsRecoveryTitle => '最近清理的登录信息';

  @override
  String get accountSessionsRecoveryMessage =>
      '服务器失效确认后清理的账号仍保留在本机恢复区。可以恢复，也可以在这里永久删除。';

  @override
  String get accountSessionsRestore => '恢复';

  @override
  String get accountSessionsEmptyTitle => '还没有保存的账号槽位';

  @override
  String get accountSessionsEmptyMessage => '登录成功后可在这里管理多端会话。';

  @override
  String get accountSessionsQr => '扫码会话';

  @override
  String get accountSessionsPassword => '手机号/密码会话';

  @override
  String get accountSessionsCurrent => '当前使用';

  @override
  String get accountSessionsExpired => '已过期';

  @override
  String get accountSessionsMenu => '账号操作';

  @override
  String get accountSessionsSwitch => '切换并验证';

  @override
  String get accountSessionsRemoveSlot => '删除槽位';

  @override
  String get accountSessionsAdd => '添加账号 / 扫码登录';

  @override
  String get accountDefaultName => '知乎账号';

  @override
  String accountMaskedName(String id) {
    return '账号 $id';
  }

  @override
  String get browsingHistoryClearTitle => '清空历史记录？';

  @override
  String get browsingHistoryClearMessage => '这只会删除知阅保存在本机的浏览记录。';

  @override
  String get browsingHistoryTitle => '历史记录';

  @override
  String get browsingHistoryClear => '清空历史记录';

  @override
  String get browsingHistoryEmptyTitle => '还没有浏览记录';

  @override
  String get browsingHistoryEmptyMessage => '打开回答、文章、问题或话题后会显示在这里';

  @override
  String browsingHistoryToday(String time) {
    return '今天 $time';
  }

  @override
  String browsingHistoryDate(int month, int day, String time) {
    return '$month月$day日 $time';
  }

  @override
  String get updateCheckFailed => '检查更新失败，请稍后重试';

  @override
  String get updateAllowInstallTitle => '允许安装应用';

  @override
  String get updateAllowInstallMessage =>
      'Android 需要你允许知阅安装下载的更新。开启后返回此页，再点一次下载并安装。';

  @override
  String get updateOpenSettings => '前往设置';

  @override
  String get updateCachedInstalling => '已使用下载好的更新包，正在打开 Android 安装器';

  @override
  String get updateVerifiedInstalling => '更新已验证，正在打开 Android 安装器';

  @override
  String get updateInstallFailed => '更新安装失败，请重试';

  @override
  String get updateTitle => '软件更新';

  @override
  String get updateAppName => '知阅';

  @override
  String get updateReadingVersion => '正在读取版本信息';

  @override
  String updateCurrentVersion(String version, String code) {
    return '当前版本 $version ($code)';
  }

  @override
  String get updateUnsupportedTitle => '当前平台不支持应用内安装';

  @override
  String get updateUnsupportedMessage => '安全下载、校验和系统安装器目前仅在 Android 客户端启用。';

  @override
  String get updateCheckingTitle => '正在检查更新';

  @override
  String get updateCheckingMessage => '正在从 GitHub Releases 读取稳定版本。';

  @override
  String get updateLatestTitle => '已是最新版本';

  @override
  String get updateNoRelease => '稳定通道目前没有已发布版本。';

  @override
  String updateLatestVersion(String version, String code) {
    return '稳定通道最新版本为 $version ($code)。';
  }

  @override
  String get updateChecking => '正在检查';

  @override
  String get updateRecheck => '重新检查';

  @override
  String get updateSecurity => '更新安全';

  @override
  String get updateSecuritySourceTitle => 'GitHub Releases';

  @override
  String get updateSecuritySourceDetail =>
      '只接受指定 GitHub 仓库中规范命名的稳定版 arm64 APK。';

  @override
  String get updateSecurityIntegrityTitle => '完整性校验';

  @override
  String get updateSecurityIntegrityDetail =>
      '下载后校验 GitHub 提供的 SHA-256 摘要和文件大小。';

  @override
  String get updateSecurityInstallerTitle => '交给系统安装器';

  @override
  String get updateSecurityInstallerDetail =>
      '还会校验包名、版本及证书连续性，再打开 Android 安装器。';

  @override
  String get updateImportant => '重要更新';

  @override
  String updateNewVersion(String version) {
    return '发现新版本 $version';
  }

  @override
  String get updateImportantFound => '发现重要更新';

  @override
  String get updatePublishedToReleases => '新版本已发布到 GitHub Releases。';

  @override
  String get updateLater => '稍后';

  @override
  String get updateView => '查看更新';

  @override
  String updateVersion(String version) {
    return '版本 $version';
  }

  @override
  String updateReleaseMeta(String size, String code) {
    return '$size APK · stable 通道 · 构建 $code';
  }

  @override
  String get updateViewDetails => '查看更新接口详情';

  @override
  String get updateVerifiedManifest => '已验证清单、包大小和 SHA-256';

  @override
  String get updateReleaseId => '发布编号';

  @override
  String get updatePublishedAt => '发布时间';

  @override
  String get updateReleaseTag => 'Release 标签';

  @override
  String get updatePackageType => '包类型';

  @override
  String get updatePackageSha256 => 'APK SHA-256';

  @override
  String get updateManifestResponse => '清单响应';

  @override
  String updateDownloadProgress(String received, String total) {
    return '下载 APK $received / $total';
  }

  @override
  String get updateVerifyingPackage => '正在校验安装包';

  @override
  String get updateContinueInstall => '继续安装';

  @override
  String get updateDownloadInstall => '下载并安装';

  @override
  String get updateValidation => '校验';

  @override
  String updateManifestSummary(String size) {
    return '$size 清单';
  }

  @override
  String get profileChange => '更换';

  @override
  String get profileUserFallback => '知乎用户';

  @override
  String get profileAnswers => '回答';

  @override
  String get profileArticles => '文章';

  @override
  String get profileIdeas => '想法';

  @override
  String get profileCollections => '收藏';

  @override
  String get profileUpvotes => '获赞';

  @override
  String get profileFollowers => '被关注';

  @override
  String get profileFollowing => '关注';

  @override
  String get profileEdit => '编辑资料';

  @override
  String get profileAllDetails => '全部资料';

  @override
  String get profileMyContent => '我的内容';

  @override
  String get profileMyAnswers => '我的回答';

  @override
  String get profileMyArticles => '我的文章';

  @override
  String get profileMyIdeas => '我的想法';

  @override
  String get profileMyCollections => '我的收藏';

  @override
  String get profileIdeasTab => '灵感';

  @override
  String get profileCreationTab => '创作';

  @override
  String get profileActivityTab => '动态';

  @override
  String get profileVoteupTab => '赞同';

  @override
  String get profilePublicActivitiesEmpty => '还没有公开动态';

  @override
  String get profilePublicVoteupsEmpty => '还没有公开赞同';

  @override
  String get profileVipSalt => '盐选会员';

  @override
  String get profileVipZhihu => '知乎会员';

  @override
  String get profileMetricWan => '万';

  @override
  String get profileMetricYi => '亿';

  @override
  String profileMetricItems(String count) {
    return '$count 条';
  }

  @override
  String get profileGenderFemale => '女';

  @override
  String get profileGenderMale => '男';

  @override
  String get profileGenderUnspecified => '未填写';

  @override
  String get profileJustJoined => '刚刚加入';

  @override
  String profileAgeDays(int count) {
    return '$count 天';
  }

  @override
  String profileAgeMonthsDays(int months, int days) {
    return '$months 个月 $days 天';
  }

  @override
  String profileAgeYearsMonths(int years, int months) {
    return '$years 年 $months 个月';
  }

  @override
  String get profileBasicInfo => '基本资料';

  @override
  String get profileUsername => '用户名';

  @override
  String get profileAccountAge => '知龄';

  @override
  String get profileGender => '性别';

  @override
  String get profileBirthday => '生日';

  @override
  String get profileLocation => '居住地';

  @override
  String get profileVerification => '认证信息';

  @override
  String get profileManageVerification => '管理认证';

  @override
  String get profileUnverified => '未认证';

  @override
  String get profileInfluence => '影响力';

  @override
  String get profileBadges => '我的徽章';

  @override
  String get profileLikes => '获得喜欢';

  @override
  String get profileNone => '暂无';

  @override
  String profileCountPieces(int count) {
    return '$count 枚';
  }

  @override
  String profileCountTimes(int count) {
    return '$count 次';
  }

  @override
  String get profileFriendImpression => '好友印象';

  @override
  String get profileImproveImage => '完善我的知乎形象，获取更多关注';

  @override
  String get profileAddKeywords => '添加形象关键词';

  @override
  String get profileLinkCopied => '主页链接已复制';

  @override
  String get profileTitle => '我的主页';

  @override
  String get profileLoadFailed => '个人资料加载失败';

  @override
  String get profileNetworkRetry => '请检查网络后重试';

  @override
  String get profileOpenDrawer => '打开侧边栏';

  @override
  String get profileFindUser => '查找用户';

  @override
  String get profileCopyHomeLink => '复制主页链接';

  @override
  String get profileUsernameEmpty => '用户名不能为空';

  @override
  String get profileFieldTooLong => '用户名、介绍或个人简介超过长度限制';

  @override
  String get profileImageUploadNoUrl => '图片上传未返回地址';

  @override
  String get profileCoverUploadNoHash => '主页背景上传未返回图片哈希';

  @override
  String get profileCoverUpdated => '主页背景已更新';

  @override
  String get profileAvatarUpdated => '头像已更新';

  @override
  String get profileAddEmployment => '添加职业经历';

  @override
  String get profileCompanyOrOrganization => '公司或组织';

  @override
  String get profileJob => '职位';

  @override
  String get profileAddEducation => '添加教育经历';

  @override
  String get profileSchool => '学校';

  @override
  String get profileMajor => '专业';

  @override
  String get profileEditTitle => '编辑个人资料';

  @override
  String get profileSaving => '保存中';

  @override
  String get profileInfoNotice => '您填写的内容将用于个人页展示及内容推荐';

  @override
  String get profileAvatar => '头像';

  @override
  String get profileCover => '主页背景';

  @override
  String get profileHeadline => '一句话介绍';

  @override
  String get profileHeadlinePlaceholder => '介绍自己的职业或兴趣';

  @override
  String get profileBirthdayPlaceholder => '请填写生日';

  @override
  String get profileLocationPlaceholder => '请填写居住地';

  @override
  String get profileIndustry => '所在行业';

  @override
  String get profileIndustryPlaceholder => '请选择行业';

  @override
  String get profileEmployment => '职业经历';

  @override
  String get profileEducation => '教育经历';

  @override
  String get profilePersonalVerification => '个人认证';

  @override
  String get profileAddVerification => '添加个人认证';

  @override
  String get profileBio => '个人简介';

  @override
  String get profileBioPlaceholder => '用一段话介绍自己';

  @override
  String get notificationCommentCategory => '评论转发@';

  @override
  String get notificationLikeCategory => '赞同喜欢';

  @override
  String get notificationFavoriteCategory => '收藏了我';

  @override
  String get notificationFollowCategory => '关注订阅';

  @override
  String get notificationInvite => '邀请回答';

  @override
  String get notificationMarkedRead => '已将消息标为已读';

  @override
  String get notificationTitle => '消息';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get notificationMarkAllRead => '全部已读';

  @override
  String get notificationLoadFailed => '消息加载失败';

  @override
  String notificationInvitePending(String count) {
    return '$count 条待处理邀请';
  }

  @override
  String get notificationInviteView => '查看邀请你回答的问题';

  @override
  String get notificationCategoryEmpty => '暂时没有这类通知';

  @override
  String get notificationCategoryMarkedRead => '该分类已全部标为已读';

  @override
  String get notificationSettingsTitle => '通知设置';

  @override
  String get notificationSettingsSection => '互动与内容通知';

  @override
  String get notificationAll => '全部';

  @override
  String get notificationLoginTitle => '登录后查看消息';

  @override
  String get notificationLoginMessage => '消息通知属于知乎账号数据';

  @override
  String get notificationBackLogin => '返回并登录';

  @override
  String get messageTitle => '私信';

  @override
  String get messageLoadFailed => '私信加载失败';

  @override
  String get messageComposeHint => '发私信';

  @override
  String get messageSend => '发送';

  @override
  String get notificationSettingCommentMe => '评论了我';

  @override
  String get notificationSettingMentionMe => '提及了我';

  @override
  String get notificationSettingAnswerVoteup => '赞同了我的回答';

  @override
  String get notificationSettingContentVoteup => '赞同了我的内容';

  @override
  String get notificationSettingAnswerThanks => '感谢了我的回答';

  @override
  String get notificationSettingRepin => '收藏了我的内容';

  @override
  String get notificationSettingReaction => '回应了我的内容';

  @override
  String get notificationSettingMemberFollow => '关注了我';

  @override
  String get notificationSettingFavlistFollow => '关注了我的收藏夹';

  @override
  String get notificationSettingColumnFollow => '关注了我的专栏';

  @override
  String get notificationSettingQuestionAnswered => '我关注的问题有新回答';

  @override
  String get notificationSettingAnswerQuestion => '回答了我的问题';

  @override
  String get notificationSettingQuestionInvite => '邀请我回答';

  @override
  String get notificationSettingColumnUpdate => '关注的专栏有更新';

  @override
  String get notificationSettingMemberActivity => '关注的人有新动态';

  @override
  String get notificationSettingSpecialUpdate => '关注的专题有更新';

  @override
  String get notificationSettingMessage => '收到私信';

  @override
  String get notificationSettingStrangerMessage => '陌生人私信';

  @override
  String get notificationSettingCoupon => '优惠与权益提醒';

  @override
  String get notificationSettingBoughtContent => '已购内容更新';

  @override
  String get notificationSettingEbook => '电子书上新';

  @override
  String get notificationSettingArticleInvite => '邀请我创作文章';

  @override
  String get notificationSettingTipjar => '文章赞赏到账';

  @override
  String get creationAll => '全部';

  @override
  String creationAnswers(String count) {
    return '回答 $count';
  }

  @override
  String creationIdeas(String count) {
    return '想法 $count';
  }

  @override
  String creationArticles(String count) {
    return '文章 $count';
  }

  @override
  String creationColumns(String count) {
    return '专栏 $count';
  }

  @override
  String creationQuestions(String count) {
    return '提问 $count';
  }

  @override
  String creationVideos(String count) {
    return '视频 $count';
  }

  @override
  String get creationMore => '更多';

  @override
  String get creationEmpty => '还没有发布内容';

  @override
  String get creationFavorites => '我的收藏';

  @override
  String get creationHighlights => '我的划线';

  @override
  String get creationFollowingColumns => '订阅的专栏';

  @override
  String get creationFollowingTopics => '关注的话题';

  @override
  String get creationFollowingCollections => '关注的收藏夹';

  @override
  String get creationFollowingQuestions => '关注的问题';

  @override
  String get activityShare => '分享';

  @override
  String get activityDelete => '删除此条动态';

  @override
  String get activityLinkCopied => '链接已复制';

  @override
  String get activityDeleteTitle => '删除此条动态？';

  @override
  String get activityDeleteMessage => '删除后无法恢复。';

  @override
  String get activityDeleted => '动态已删除';

  @override
  String get questionIdUnavailable => '暂时无法识别问题 ID，请刷新后重试';

  @override
  String get questionFollowed => '已关注问题';

  @override
  String get questionUnfollowed => '已取消关注问题';

  @override
  String get questionAnswerPublishedRefreshing => '回答已发布，列表正在刷新。';

  @override
  String get questionDeleteTitle => '删除回答？';

  @override
  String get questionDeleteMessage => '删除后不可恢复。';

  @override
  String get questionDeleted => '回答已删除。';

  @override
  String get questionAnswersTitle => '全部回答';

  @override
  String get questionSearchAnswers => '搜索回答';

  @override
  String get questionMore => '更多';

  @override
  String get questionLoginToWrite => '登录后写回答';

  @override
  String get questionUnfollow => '取消关注问题';

  @override
  String get questionFollow => '关注问题';

  @override
  String get questionAnswerRefresh => '刷新回答';

  @override
  String get questionCollapseDetails => '收起问题详情';

  @override
  String get questionExpandDetails => '展开问题详情';

  @override
  String get questionCollapse => '收起';

  @override
  String get questionExpandFull => '展开全文';

  @override
  String questionOpenTopic(String name) {
    return '打开话题 $name';
  }

  @override
  String questionAllContentCount(String count) {
    return '全部内容 $count';
  }

  @override
  String get questionSortDefault => '默认';

  @override
  String get questionSortLatest => '最新';

  @override
  String get questionSortSemantic => '回答排序：';

  @override
  String questionAuthor(String name) {
    return '提问者 $name';
  }

  @override
  String get questionAuthorBadge => '提问者';

  @override
  String get questionViewImage => '查看问题图片原图';

  @override
  String get topicFollowersTitle => '话题关注者';

  @override
  String get topicUnansweredTitle => '话题待回答问题';

  @override
  String topicFallbackTitle(String id) {
    return '话题 $id';
  }

  @override
  String get topicRefresh => '刷新话题资料';

  @override
  String get topicLabel => '话题';

  @override
  String topicFollowers(String count) {
    return '$count 关注者';
  }

  @override
  String topicQuestions(String count) {
    return '$count 问题';
  }

  @override
  String topicAnswers(String count) {
    return '$count 回答';
  }

  @override
  String topicDiscussions(String count) {
    return '$count 讨论';
  }

  @override
  String get topicBasicUnavailable => '基础资料暂未加载，精华列表仍可独立浏览。';

  @override
  String get topicFollowersButton => '关注者';

  @override
  String get topicUnansweredButton => '待回答';

  @override
  String get zvideoTitle => '视频';

  @override
  String get zvideoCommentsUnavailable => '评论';

  @override
  String zvideoActionUnavailable(String action) {
    return '$action功能暂不可用';
  }

  @override
  String get zvideoLoadFailed => '视频暂时无法加载';

  @override
  String zvideoFallbackTitle(String id) {
    return '视频 #$id';
  }

  @override
  String get zvideoViewComments => '查看评论';

  @override
  String zvideoViewCommentsCount(String count) {
    return '查看 $count 条评论';
  }

  @override
  String get zvideoMissing => '没有取得可播放的视频信息';

  @override
  String get zvideoVoteup => '赞同';

  @override
  String get zvideoComment => '评论';

  @override
  String get zvideoFavorite => '收藏';

  @override
  String get zvideoShare => '分享';

  @override
  String get zvideoVoteupSemantic => '赞同视频';

  @override
  String get zvideoCommentsSemantic => '查看视频评论';

  @override
  String get zvideoFavoriteSemantic => '收藏视频';

  @override
  String get zvideoShareSemantic => '分享视频';

  @override
  String get inlineVideoPlatformUnsupported => '当前平台暂不支持内联视频播放';

  @override
  String get inlineVideoLoadFailed => '视频暂时无法播放，请稍后重试';

  @override
  String get inlineVideoInterruptedRetry => '视频播放已中断，请点按重试';

  @override
  String get inlineVideoSwitchingLine => '播放中断，正在切换线路…';

  @override
  String get inlineVideoPaidNoAccess => '付费视频 · 当前账号无观看权限';

  @override
  String get inlineVideoUnavailable => '视频暂不可播放';

  @override
  String get inlineVideoPrivacyUnavailable => '当前平台暂不支持隐私受限的视频播放';

  @override
  String get inlineVideoPlay => '播放视频';

  @override
  String inlineVideoPlayTitle(String title) {
    return '播放视频：$title';
  }

  @override
  String get inlineVideoFullscreen => '全屏';

  @override
  String get inlineVideoStopped => '视频已停止或正在切换线路';

  @override
  String get inlineVideoBack => '返回';

  @override
  String get answerSwitchRelease => '松开切换';

  @override
  String get answerSwitchPreviousHint => '继续下拉查看上一个回答';

  @override
  String get answerSwitchNextHint => '继续上滑查看下一个回答';

  @override
  String answerSwitchTo(String author) {
    return '松开切换到 $author 的回答';
  }

  @override
  String get answerPrevious => '上一个';

  @override
  String get answerNext => '下一个';

  @override
  String get detailWriteAnswerLogin => '登录后写回答';

  @override
  String saltDownloadedProgress(int downloaded, int total) {
    return '$downloaded/$total 已下载';
  }

  @override
  String saltDownloadedSections(int count) {
    return '$count 节已下载';
  }

  @override
  String get saltAudio => '盐选音频';

  @override
  String get saltVideo => '盐选视频';

  @override
  String get saltStory => '盐选故事';

  @override
  String get saltLimitedFree => '限时免费';

  @override
  String get saltUntitledContent => '未命名盐选内容';

  @override
  String saltLikeCount(String count) {
    return '点赞 $count';
  }

  @override
  String saltCommentCount(String count) {
    return '评论 $count';
  }

  @override
  String saltWordCount(String count) {
    return '$count 字';
  }

  @override
  String saltReadCount(String count) {
    return '阅读 $count';
  }

  @override
  String saltFavoriteCount(String count) {
    return '收藏 $count';
  }

  @override
  String get saltPlayable => '可听';

  @override
  String get saltSupportsAudio => '支持听书';

  @override
  String get saltFree => '免费';

  @override
  String get saltTrial => '试读';

  @override
  String get saltMember => '盐选会员';

  @override
  String get saltEntitlementRequired => '需权益';

  @override
  String get saltLastRead => '上次读到';

  @override
  String get saltReadFinished => '已读完';

  @override
  String get saltUntitledChapter => '未命名章节';

  @override
  String get saltResourceAudio => '音频';

  @override
  String get saltResourceVideo => '视频';

  @override
  String get saltResourceSlide => '课件';

  @override
  String get saltResourceText => '图文';

  @override
  String saltReadPercent(int percent) {
    return '已读 $percent%';
  }

  @override
  String saltCommentBadge(int count) {
    return '查看 $count 条弹评';
  }

  @override
  String followMoreAnswers(int count) {
    return 'TA 还赞同了 $count 个回答';
  }

  @override
  String get brandZhihu => '知乎';

  @override
  String detailQuestionAnswerCount(String count) {
    return '$count 个回答';
  }

  @override
  String detailQuestionFollowerCount(String count) {
    return '$count 人关注';
  }

  @override
  String get detailQuestionAnswersSemantic => '查看该问题的全部回答';

  @override
  String detailQuestionFallback(String id) {
    return '问题 #$id';
  }

  @override
  String get questionInviteTitle => '邀请回答';

  @override
  String get questionInviteEmpty => '暂时没有推荐邀请人';

  @override
  String get questionInviteInvited => '已邀请';

  @override
  String get questionInviteAction => '邀请';

  @override
  String get routingSafetyTitle => '安全提示';

  @override
  String get routingLeaveZhihu => '即将离开知乎';

  @override
  String get routingExternalWarning => '该链接并非知乎官方页面，请注意保护账号、隐私和财产安全。';

  @override
  String get routingConfirmVisit => '确认访问';

  @override
  String get routingOpenVerification => '打开知乎验证';

  @override
  String get webSafetyTitle => '安全验证';

  @override
  String get webPageLoadFailedNetwork => '页面加载失败，请检查网络后重试';

  @override
  String get webPageUnavailable => '页面暂时无法打开，请稍后重试';

  @override
  String get webSessionSyncFailed => '登录状态未能同步，请重新登录后再试';

  @override
  String get webLoginExpired => '网页登录状态已失效，请重新登录后再试';

  @override
  String get webSystemBrowserUnavailable => '无法调用系统浏览器';

  @override
  String get webContinueInBrowser => '请在浏览器中继续';

  @override
  String get webDesktopSystemBrowser => '当前桌面平台使用系统浏览器';

  @override
  String get webOpenBrowser => '打开浏览器';

  @override
  String get webOpeningChapter => '正在打开章节';

  @override
  String get webOpeningPage => '正在打开页面';

  @override
  String get webOpenInBrowser => '在浏览器中打开';

  @override
  String get webChapterReading => '章节阅读';

  @override
  String get routingCannotOpen => '暂时无法打开。';

  @override
  String get routingCannotViewComments => '暂时无法查看评论。';

  @override
  String get routingUnsupportedAction => '当前内容暂不支持此操作。';

  @override
  String get routingPinDownvoteUnavailable => '想法暂不提供反对操作。';

  @override
  String get routingDownvoteCancelled => '已取消反对。';

  @override
  String get routingDownvoted => '已反对该内容。';

  @override
  String get routingVoteCancelled => '已取消赞同。';

  @override
  String get routingVoted => '已赞同该内容。';

  @override
  String get routingFavoriteRemoved => '已取消收藏。';

  @override
  String get routingFavorited => '已加入默认收藏夹。';

  @override
  String get objectDetailTitle => '内容详情';

  @override
  String get objectImages => '图片';

  @override
  String get objectContent => '内容';

  @override
  String get contentTypeCollection => '收藏集';

  @override
  String columnFallbackTitle(String token) {
    return '专栏 $token';
  }

  @override
  String get columnFollowersTitle => '专栏关注者';

  @override
  String get columnLoadFailed => '专栏信息暂未加载。';

  @override
  String get columnRetry => '重试专栏资料';

  @override
  String get columnTitle => '专栏';

  @override
  String columnArticleCount(String count) {
    return '$count 篇文章';
  }

  @override
  String columnFollowerCount(String count) {
    return '$count 关注者';
  }

  @override
  String columnContributionCount(String count) {
    return '$count 篇投稿';
  }

  @override
  String columnVoteupCount(String count) {
    return '$count 获赞';
  }

  @override
  String columnAuthorPrefix(String name) {
    return '作者 $name';
  }

  @override
  String get columnFollowers => '关注者';

  @override
  String get columnAuthorProfile => '作者资料';

  @override
  String get detailContentIncomplete => '内容可能不完整';

  @override
  String get detailPaidUnlocked => '盐选会员内容已解锁，以下为当前账号可读的完整正文。';

  @override
  String get detailPaidLocked => '这是盐选会员内容，当前账号返回的正文仍处于未解锁状态。';

  @override
  String get detailRelatedLoadFailed => '加载其它回答失败，点击重试';

  @override
  String get detailViewCommentsButton => '查看评论';

  @override
  String get detailContentInfo => '内容信息';

  @override
  String get detailReadingHint => '主内容栏已限制阅读宽度，滚动时可随时查看互动数据。';

  @override
  String get blockedKeywordsTitle => '屏蔽关键词';

  @override
  String blockedKeywordsInvalidLength(int min, int max) {
    return '关键词需为 $min-$max 个字符';
  }

  @override
  String get blockedKeywordsExists => '该关键词已经存在';

  @override
  String blockedKeywordsLimit(int max) {
    return '最多可设置 $max 个关键词';
  }

  @override
  String get blockedKeywordsDescription => '包含这些关键词的推荐将被减少';

  @override
  String blockedKeywordsCount(int current, int max) {
    return '已设置 $current/$max';
  }

  @override
  String blockedKeywordsHint(int min, int max) {
    return '$min-$max 个字符';
  }

  @override
  String get blockedKeywordsAdd => '添加关键词';

  @override
  String get blockedKeywordsEmpty => '暂未设置屏蔽关键词';

  @override
  String blockedKeywordsDelete(String keyword) {
    return '删除 $keyword';
  }

  @override
  String get recommendationClearTitle => '清空本地推荐画像？';

  @override
  String get recommendationClearMessage => '只会删除本机记录，不会影响知乎账号和服务器推荐。';

  @override
  String get recommendationCleared => '本地推荐画像已清空';

  @override
  String get recommendationTitle => '本地推荐行为';

  @override
  String get recommendationClearSemantic => '清空本地画像';

  @override
  String get recommendationEmptyTitle => '暂时还没有本地行为';

  @override
  String get recommendationProfileTitle => '本地推荐画像';

  @override
  String get recommendationEmptyMessage => '打开推荐内容或使用“不感兴趣”后，知阅会在本机记录有限的兴趣信号。';

  @override
  String recommendationSummary(int total, int opened, int feedback) {
    return '已记录 $total 条信号 · 打开 $opened · 反馈 $feedback';
  }

  @override
  String get recommendationTopics => '常见兴趣词';

  @override
  String get recommendationAuthors => '常见作者';

  @override
  String get recommendationPrivacy => '数据仅保存在本机，用于本地或混合推荐排序；不会上传行为明细。';

  @override
  String get discoverColumns => '专栏推荐';

  @override
  String get discoverTopics => '话题分类';

  @override
  String get discoverHotTopics => '热门话题';

  @override
  String get discoverHotTopicsEmpty => '暂时没有热门话题';

  @override
  String get discoverContentIdInvalid => '内容 ID 必须是 1–32 位数字';

  @override
  String get discoverTitle => '发现';

  @override
  String get discoverColumnsAndTopics => '专栏与话题';

  @override
  String get discoverColumnsSubtitle => '编辑精选与热门专栏文章';

  @override
  String get discoverTopicsSubtitle => '按分类浏览话题';

  @override
  String get discoverHotTopicsSubtitle => '当前热门讨论';

  @override
  String get discoverOpenById => '通过 ID 打开内容';

  @override
  String get discoverTypeAnswer => '回答';

  @override
  String get discoverTypeArticle => '文章';

  @override
  String get discoverTypeIdea => '想法';

  @override
  String get discoverIdHint => '输入内容 ID';

  @override
  String get discoverOpenDetails => '打开详情';

  @override
  String get pagedEnd => '已经到底了';

  @override
  String get pagedEmpty => '还没有内容';

  @override
  String get diagnosticExported => '日志 JSON 已复制到剪贴板';

  @override
  String get diagnosticEmpty => '目前没有日志';

  @override
  String get diagnosticClearTitle => '清理诊断日志？';

  @override
  String get diagnosticClearMessage => '这只会删除本机保存的诊断记录，不会影响账号和内容缓存。';

  @override
  String get diagnosticCleared => '诊断日志已清理';

  @override
  String get diagnosticTitle => '诊断日志';

  @override
  String get diagnosticExport => '导出日志';

  @override
  String get diagnosticClear => '清理日志';

  @override
  String get diagnosticPurpose => '用于定位“内容已被删除”、接口失败和卡顿问题';

  @override
  String get diagnosticPrivacy =>
      '认证失效、恢复和清理决定默认记录；其它诊断日志可单独开关。日志只保存脱敏状态，不保存 Cookie、令牌、正文或图片。';

  @override
  String get diagnosticLocalEnabled => '启用本地日志';

  @override
  String get diagnosticLocalSubtitle => '开启后保留最近 600 条诊断记录';

  @override
  String get diagnosticAuthEnabled => '认证状态日志';

  @override
  String get diagnosticAuthSubtitle => '记录登录失效、恢复、保留和清理决定，默认开启';

  @override
  String get diagnosticNetworkEnabled => '网络请求日志';

  @override
  String get diagnosticNetworkSubtitle => '记录接口路径、HTTP 状态、业务码和耗时';

  @override
  String get diagnosticPerformanceEnabled => '性能日志';

  @override
  String get diagnosticPerformanceSubtitle => '记录接口耗时，帮助定位掉帧和慢请求';

  @override
  String diagnosticInstallSummary(String id, int count) {
    return '本机标识 $id · $count 条';
  }

  @override
  String get diagnosticEmptyTitle => '暂无诊断日志';

  @override
  String get diagnosticEmptyMessage => '开启本地日志后重新操作一次，异常和网络状态会显示在这里。';

  @override
  String get diagnosticNoDetails => '没有附加信息';

  @override
  String get diagnosticLevelDebug => '调试';

  @override
  String get diagnosticLevelInfo => '信息';

  @override
  String get diagnosticLevelWarning => '警告';

  @override
  String get diagnosticLevelError => '错误';

  @override
  String get diagnosticCategoryApp => '应用';

  @override
  String get diagnosticCategoryNetwork => '网络';

  @override
  String get diagnosticCategoryPerformance => '性能';

  @override
  String get diagnosticCategoryError => '错误';

  @override
  String get diagnosticCategoryAuthentication => '认证';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '知閱';

  @override
  String get navRecommend => '推薦';

  @override
  String get navSearch => '搜尋';

  @override
  String get navBookshelf => '書架';

  @override
  String get navMe => '我';

  @override
  String get navWorkspace => '工作區';

  @override
  String get feedFollowing => '關注';

  @override
  String get feedRecommend => '推薦';

  @override
  String get feedHot => '熱榜';

  @override
  String get feedStory => '故事';

  @override
  String get feedFollowingChoice => '精選';

  @override
  String get feedFollowingLatest => '最新';

  @override
  String get feedFollowingIdeas => '想法';

  @override
  String get feedEmptyFollowing => '關注流暫時沒有新內容';

  @override
  String get feedEmptyHot => '目前沒有可顯示的熱榜內容';

  @override
  String get feedEmptyRecommend => '目前沒有可顯示的推薦內容';

  @override
  String get feedNextLoadFailed => '續頁載入失敗，點選重試';

  @override
  String get feedAllShown => '已顯示目前全部內容';

  @override
  String get feedLoadMore => '繼續下滑載入更多';

  @override
  String get feedFollowingPeople => '關注的人';

  @override
  String feedViewPersonRecent(String name) {
    return '查看 $name 最近發布的內容';
  }

  @override
  String get feedDiscoverFriends => '發現好友';

  @override
  String get feedFollowingSemantic => '關注頁';

  @override
  String get feedSaltServiceFallback => '知乎鹽選會員 為你嚴選好內容';

  @override
  String feedPersonRecentTitle(String name) {
    return '$name 的最近動態';
  }

  @override
  String get feedPersonRecentEmpty => '還沒有公開的最近內容';

  @override
  String get storyCategoriesTitle => '分類';

  @override
  String get storySearch => '搜尋故事';

  @override
  String get storyLoadFailed => '故事分類暫時無法載入';

  @override
  String get storyEmptyCategories => '暫時沒有故事分類';

  @override
  String get storyBrowseByGenre => '按題材瀏覽故事';

  @override
  String get storyFilterStories => '篩選故事';

  @override
  String get storyFeaturedCategories => '精選分類';

  @override
  String get storyQuickFilter => '快速篩選';

  @override
  String get storySort => '排序';

  @override
  String get storyAll => '全部';

  @override
  String get storyCategory => '分類';

  @override
  String get storyTabStories => '故事';

  @override
  String get storyTabBooks => '電子書';

  @override
  String get storyTabAssessments => '測評';

  @override
  String get storyLong => '長篇';

  @override
  String get storyShort => '短篇';

  @override
  String get storyAudioBook => '有聲書';

  @override
  String get storyFilter => '篩選';

  @override
  String get storySortHot => '熱度';

  @override
  String get storySortGood => '好評';

  @override
  String get storySortNew => '上新';

  @override
  String get storyAllCategories => '全部分類';

  @override
  String get storyMaxTags => '最多支援選擇 5 個標籤';

  @override
  String get storyNoCategories => '暫無分類';

  @override
  String get storyReset => '重設';

  @override
  String get storyConfirm => '確認';

  @override
  String get storyViewAll => '查看全部';

  @override
  String get storyEmptyCondition => '暫時沒有符合條件的內容';

  @override
  String get storyCategoryFallback => '故事分類';

  @override
  String get storyEmptyCategory => '該分類暫時沒有故事';

  @override
  String get storyLongTitle => '長篇故事';

  @override
  String get storyEmptyLong => '暫時沒有長篇故事';

  @override
  String storyLikeCount(String count) {
    return '$count 個讚';
  }

  @override
  String get storyOngoing => '連載中';

  @override
  String get storyFinished => '完結';

  @override
  String get storyFree => '免費';

  @override
  String get storyVip => 'VIP';

  @override
  String get storyVipDiscount => 'VIP 折扣';

  @override
  String get storyType => '類型';

  @override
  String get storyStatus => '狀態';

  @override
  String get storyRights => '權益';

  @override
  String get storySectionHotTags => '熱門標籤';

  @override
  String get storySectionGenre => '題材';

  @override
  String get storySectionCharacters => '角色';

  @override
  String get storySectionPlot => '情節';

  @override
  String get storySectionMood => '情緒';

  @override
  String get storySectionSetting => '時空';

  @override
  String get storyTypeAssessment => '測評';

  @override
  String get storyMaxSelection => '最多選擇 5 個標籤';

  @override
  String get saltContinueReading => '繼續閱讀';

  @override
  String get saltStartReading => '開始閱讀';

  @override
  String get saltAdded => '已加入';

  @override
  String get saltAddToBookshelf => '加入書架';

  @override
  String get saltChapterOrder => '章節順序';

  @override
  String get saltAscending => '正序';

  @override
  String get saltDescending => '倒序';

  @override
  String get saltChapter => '章節';

  @override
  String get saltCatalogTitle => '目錄';

  @override
  String saltChapterCount(int count) {
    return '共 $count 節';
  }

  @override
  String get saltChapterDirectory => '章節目錄';

  @override
  String saltProcessing(int index, int total, String title) {
    return '正在處理 $index/$total · $title';
  }

  @override
  String get saltSelectAll => '全選';

  @override
  String get saltCancelSelectAll => '取消全選';

  @override
  String saltSelectedCount(int selected, int total) {
    return '已選 $selected/$total';
  }

  @override
  String get saltDownloadingChapters => '正在下載章節';

  @override
  String saltExportChapters(String format, int count) {
    return '匯出 $format · $count 章';
  }

  @override
  String get saltDirectoryLoadFailed => '目錄載入失敗';

  @override
  String get saltNetworkRetry => '請檢查網路後重試';

  @override
  String get saltDecodeFailed => '章節解碼失敗，請重試。';

  @override
  String get saltDecodeParamsMissing => '章節回應缺少完整解碼參數，請重試。';

  @override
  String get saltDirectoryEmpty => '目錄中暫時沒有章節';

  @override
  String get saltCached => '已快取';

  @override
  String get saltCommentsEmpty => '還沒有評論';

  @override
  String get saltBulletCommentsEmpty => '還沒有彈評';

  @override
  String get saltReaderTopBar => '閱讀頂部列';

  @override
  String get saltReaderBottomBar => '閱讀底部列';

  @override
  String get saltReadingTitle => '鹽選閱讀';

  @override
  String get saltMore => '更多';

  @override
  String get saltSettingsTitle => '閱讀設定';

  @override
  String get saltVerticalScroll => '上下滑動';

  @override
  String get saltHorizontalPage => '左右翻頁';

  @override
  String get saltFontSize => '字型大小';

  @override
  String get saltLineSpacing => '行距';

  @override
  String get saltParagraphSpacing => '段距';

  @override
  String get saltHorizontalMargins => '左右邊距';

  @override
  String get saltApply => '套用';

  @override
  String get saltChapterInfo => '章節資訊';

  @override
  String get saltAuthor => '作者';

  @override
  String get saltReadable => '可讀';

  @override
  String get saltLocked => '未解鎖';

  @override
  String get saltChapterLocked => '章節鎖定';

  @override
  String get saltChapterReadable => '章節可讀';

  @override
  String saltSectionLabel(int index) {
    return '第 $index 節';
  }

  @override
  String saltSectionProgress(int index, int count) {
    return '第 $index/$count 節';
  }

  @override
  String saltLikes(String count) {
    return '$count 個讚';
  }

  @override
  String saltComments(String count) {
    return '$count 則評論';
  }

  @override
  String get saltAudioAvailable => '可聽';

  @override
  String get saltNoPermission => '目前帳號沒有閱讀權限';

  @override
  String get saltReload => '重新載入';

  @override
  String get saltContentUnavailable => '章節內容暫不可用';

  @override
  String get saltPreviousChapter => '上一節';

  @override
  String get saltNextChapter => '下一節';

  @override
  String get saltMetadataReady => '資料已取得';

  @override
  String get saltEntitlementPassed => '權益通過';

  @override
  String get saltPayloadReady => '載荷已取得';

  @override
  String get saltBodyShown => '正文已顯示';

  @override
  String get saltWaitingBody => '等待正文解析';

  @override
  String get saltPayloadChars => '字元載荷';

  @override
  String get saltCodeChars => '位 code';

  @override
  String get saltChapterBodyShown => '章節正文已顯示';

  @override
  String get saltReadyDetail => '章節資料、繫結載荷和完整正文均已就緒。';

  @override
  String get saltShelfTitle => '書架';

  @override
  String get saltWorkFallback => '鹽選作品';

  @override
  String get saltCategory => '分類';

  @override
  String get saltKnowledgeColumn => '知識專欄';

  @override
  String get saltLocalShelfEmpty => '本地書架暫無內容';

  @override
  String get saltMoreActions => '更多操作';

  @override
  String get saltReadAloud => '朗讀本節';

  @override
  String get saltStopReading => '停止朗讀';

  @override
  String get saltReadAloudSubtitle => '使用系統語音朗讀目前章節';

  @override
  String saltExportChapter(String format) {
    return '匯出目前章節為 $format';
  }

  @override
  String get saltExportTxt => '匯出 TXT 檔案';

  @override
  String get saltExportDocx => '匯出 DOCX 檔案';

  @override
  String saltReadingStarted(String title) {
    return '正在朗讀$title';
  }

  @override
  String get saltSpeechUnavailable => '系統語音不可用，請安裝語音套件';

  @override
  String saltExportedTo(String location) {
    return '已匯出到 $location';
  }

  @override
  String saltExportedAs(String format, String location) {
    return '已匯出為 $format：$location';
  }

  @override
  String get saltExportFailed => '匯出失敗，請重試';

  @override
  String get saltCloudShelfUnavailable => '雲書架暫時無法同步';

  @override
  String get saltAccountSyncFailed => '帳號同步失敗，請稍後重試';

  @override
  String get saltStoryHomeLoadFailed => '鹽選首頁暫時無法載入';

  @override
  String get saltStoryEntry => '入口';

  @override
  String get saltStoryModuleMustSee => '進站必看';

  @override
  String get saltStoryModuleTodayRead => '今日閱讀';

  @override
  String get saltStoryModuleEveryoneWatch => '大家都在看';

  @override
  String get saltStoryModuleRecommended => '為你推薦';

  @override
  String get saltStoryBoard => '故事榜單';

  @override
  String get saltStoryHotBoard => '熱度榜';

  @override
  String get saltStoryReputationBoard => '口碑榜';

  @override
  String get saltStoryNewBoard => '新書榜';

  @override
  String get saltStoryLongBoard => '長篇榜';

  @override
  String saltStoryBoardNumber(int index) {
    return '榜單 $index';
  }

  @override
  String get saltPillOnShelf => '已加入書架';

  @override
  String get saltPillLiked => '已讚';

  @override
  String get saltBrandLong => '長篇';

  @override
  String saltScore(String score) {
    return '評分 $score';
  }

  @override
  String saltUpdatedSections(int count) {
    return '更新 $count 節';
  }

  @override
  String saltFinishedWithCount(int count) {
    return '已完結，共 $count 節';
  }

  @override
  String saltUpdatedTo(int index) {
    return '已更新至第 $index 節';
  }

  @override
  String get saltShelfLiked => '讚過';

  @override
  String get saltShelfComments => '彈評';

  @override
  String get saltShelfHistory => '歷史紀錄';

  @override
  String get saltShelfLists => '書單';

  @override
  String get answerLabel => '回答';

  @override
  String get drawerBrowse => '瀏覽';

  @override
  String get drawerColumns => '專欄推薦';

  @override
  String get drawerTopicCategories => '話題分類';

  @override
  String get drawerHotTopics => '熱門話題';

  @override
  String get drawerHistory => '歷史記錄';

  @override
  String get drawerMyContent => '我的內容';

  @override
  String get drawerMessages => '訊息';

  @override
  String get drawerCollections => '收藏';

  @override
  String get drawerBookshelf => '書架';

  @override
  String get drawerFindUsers => '尋找使用者';

  @override
  String get drawerAccount => '帳號';

  @override
  String get drawerLoginOrAddAccount => '登入或新增帳號';

  @override
  String get drawerAccountManagement => '帳號管理';

  @override
  String get drawerApp => '應用程式';

  @override
  String get drawerSettings => '設定';

  @override
  String get drawerClose => '關閉側邊欄';

  @override
  String get drawerOpen => '開啟側邊欄';

  @override
  String drawerVersion(String version) {
    return '知閱 $version';
  }

  @override
  String get commonBack => '返回';

  @override
  String get commonClose => '關閉';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '確定';

  @override
  String get commonSave => '儲存';

  @override
  String get commonReset => '恢復預設';

  @override
  String get commonClear => '清除';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonDone => '完成';

  @override
  String get commonRetry => '重試';

  @override
  String get commonSearch => '搜尋';

  @override
  String get commonSelect => '請選擇';

  @override
  String get commonLoading => '載入中…';

  @override
  String get commonMore => '更多';

  @override
  String get commonReply => '回覆';

  @override
  String get commonPublish => '發佈';

  @override
  String get commonPublishing => '發佈中';

  @override
  String get commonFollow => '關注';

  @override
  String get commonRefresh => '重新整理';

  @override
  String get commonEdit => '編輯';

  @override
  String get commonShare => '分享';

  @override
  String get commonFailed => '載入失敗，請重試';

  @override
  String get commonNoMore => '沒有更多內容了';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAppearance => '外觀';

  @override
  String get settingsBackup => '備份';

  @override
  String get settingsAccount => '帳號';

  @override
  String get settingsLogs => '記錄';

  @override
  String get settingsAboutSection => '關於';

  @override
  String get settingsUpdates => '更新';

  @override
  String get settingsData => '資料';

  @override
  String get settingsAppearanceSubtitle => '深色模式、語言與顯示';

  @override
  String get settingsPersonalizationSubtitle => '首頁、推薦與內容偏好';

  @override
  String get settingsBackupSubtitle => 'WebDAV 資料同步';

  @override
  String get settingsAccountSubtitle => '工作階段與登入狀態';

  @override
  String get settingsLogsSubtitle => '診斷記錄與問題排查';

  @override
  String get settingsAboutSubtitle => '還原預設設定與應用程式資訊';

  @override
  String get settingsUpdatesSubtitle => '檢查並安裝新版本';

  @override
  String get settingsDataSubtitle => '歷史記錄、快取與儲存空間';

  @override
  String get settingsHomeContent => '首頁與內容';

  @override
  String get settingsStartupPage => '啟動頁面';

  @override
  String get settingsRecommendation => '推薦策略';

  @override
  String get settingsServer => '伺服器';

  @override
  String get settingsLocal => '本機';

  @override
  String get settingsHybrid => '混合';

  @override
  String get settingsDensity => '內容密度';

  @override
  String get settingsComfortable => '舒適';

  @override
  String get settingsCompact => '緊湊';

  @override
  String get settingsRefreshHome => '重複點選首頁時重新整理';

  @override
  String get settingsRefreshHomeSubtitle => '再次點選已選取的首頁按鈕時回到頂部並重新整理';

  @override
  String get settingsShowImages => '顯示推薦圖片';

  @override
  String get settingsShowImagesSubtitle => '關閉後首頁只顯示文字、作者和互動資訊';

  @override
  String get settingsShowMetrics => '顯示互動資料';

  @override
  String get settingsShowMetricsSubtitle => '顯示讚同、收藏、評論和發佈日期';

  @override
  String get settingsLocalBehavior => '本機推薦行為';

  @override
  String settingsLocalEvents(int count) {
    return '本機已記錄 $count 條行為';
  }

  @override
  String get settingsFeedOrder => '首頁分區排序';

  @override
  String get settingsFilterStats => '內容過濾統計';

  @override
  String get settingsReadingDisplay => '閱讀與顯示';

  @override
  String get settingsDarkMode => '夜間模式';

  @override
  String get settingsDarkModeOnSubtitle => '使用深色背景和低亮度表面';

  @override
  String get settingsDarkModeOffSubtitle => '使用淺色背景和明亮表面';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsLanguageSubtitle => '選擇應用程式介面語言';

  @override
  String get settingsTextSize => '閱讀字號';

  @override
  String get settingsSmall => '小';

  @override
  String get settingsStandard => '標準';

  @override
  String get settingsLarge => '大';

  @override
  String get settingsFollowSystemTextScale => '跟隨系統字號';

  @override
  String get settingsFollowSystemTextScaleSubtitle => '在閱讀字號基礎上疊加系統顯示大小';

  @override
  String get settingsReduceMotion => '減少動態效果';

  @override
  String get settingsReduceMotionSubtitle => '減少頁面切換和元件動畫';

  @override
  String get settingsGlass => '液態玻璃效果';

  @override
  String get settingsGlassOnSubtitle => '保留玻璃回饋與透明層次';

  @override
  String get settingsGlassOffSubtitle => '流暢模式：使用低開銷的實色按鈕和導覽列';

  @override
  String get settingsPersonalization => '個人化功能';

  @override
  String get settingsFocusSearch => '進入搜尋頁時自動開啟輸入法';

  @override
  String get settingsFocusSearchOn => '進入搜尋頁後自動聚焦搜尋框';

  @override
  String get settingsFocusSearchOff => '進入搜尋頁後手動點選搜尋框';

  @override
  String get settingsImagesStorage => '圖片與儲存空間';

  @override
  String get settingsKeepHistory => '保留瀏覽記錄';

  @override
  String settingsKeepHistoryOn(int count) {
    return '僅儲存在本機 · $count 條';
  }

  @override
  String get settingsKeepHistoryOff => '開啟內容不會寫入本機歷史';

  @override
  String get settingsPrefetchImages => '預先載入列表圖片';

  @override
  String get settingsPrefetchImagesSubtitle => '提前載入即將顯示的頭像和正文圖片';

  @override
  String get settingsImageCache => '圖片快取容量';

  @override
  String get settingsEconomy => '節省';

  @override
  String get settingsRoomy => '充足';

  @override
  String get settingsNoCacheImages => '目前沒有快取圖片';

  @override
  String settingsCachedImages(int count) {
    return '已清理 $count 張快取圖片';
  }

  @override
  String get settingsPrivacyData => '隱私與資料';

  @override
  String get settingsKeepSearch => '保留搜尋記錄';

  @override
  String settingsKeepSearchOn(int count) {
    return '僅儲存在本機 · $count 條';
  }

  @override
  String get settingsKeepSearchOff => '新搜尋不會寫入本機';

  @override
  String get settingsShowHot => '顯示熱搜';

  @override
  String get settingsShowHotOn => '在搜尋頁顯示知乎熱搜';

  @override
  String get settingsShowHotOff => '搜尋頁不載入熱搜內容';

  @override
  String get settingsWebDav => 'WebDAV 同步';

  @override
  String get settingsAccountSessions => '帳號與多端登入';

  @override
  String get settingsSignOut => '登出';

  @override
  String get settingsOther => '其他';

  @override
  String get settingsDiagnostics => '診斷記錄';

  @override
  String get settingsUpdate => '軟體更新';

  @override
  String get settingsRestoreDefaults => '恢復預設設定';

  @override
  String get settingsAbout => '關於知閱';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String get settingsFeedOrderSubtitle => '按住右側拖曳，首頁頂欄與左右滑動順序會同步更新。';

  @override
  String get settingsRestoreDefaultsMessage => '所有設定將恢復預設，不會登出帳號。';

  @override
  String get settingsRestored => '軟體設定已恢復預設';

  @override
  String get settingsSignOutMessage => '本機儲存的登入資訊將被刪除。';

  @override
  String get settingsSignedOut => '已登出';

  @override
  String get settingsClearBrowsing => '清空瀏覽記錄';

  @override
  String get settingsNoBrowsingHistory => '目前沒有記錄';

  @override
  String settingsDeleteBrowsing(int count) {
    return '刪除 $count 筆本機記錄';
  }

  @override
  String get settingsClearImageCache => '清理圖片快取';

  @override
  String get settingsClearOfflineChapters => '清理離線章節';

  @override
  String get settingsClearOfflineChaptersSubtitle => '刪除閱讀和下載時儲存的鹽選正文';

  @override
  String get settingsClearSearch => '清空搜尋記錄';

  @override
  String get settingsNoSearchHistory => '目前沒有記錄';

  @override
  String settingsDeleteSearch(int count) {
    return '刪除 $count 筆本機記錄';
  }

  @override
  String get settingsWebDavConfigured => '已設定 · 搜尋、歷史、離線小說和回答快取';

  @override
  String get settingsWebDavSubtitle => '同步搜尋記錄、瀏覽歷史、離線小說和回答快取';

  @override
  String get settingsAccountSessionsSubtitle => '掃碼登入、儲存帳號槽位並快速切換';

  @override
  String get settingsSignOutSubtitle => '移除本機登入資訊';

  @override
  String get settingsDiagnosticsOn => '已開啟 · 管理網路、效能記錄並匯出';

  @override
  String get settingsDiagnosticsOff => '定位介面異常、內容載入失敗和卡頓問題';

  @override
  String get settingsUpdateSubtitle => '安全檢查、下載並安裝新版本';

  @override
  String get settingsRestoreDefaultsSubtitle => '不會登出帳號';

  @override
  String get searchTitle => '搜尋';

  @override
  String get searchPlaceholder => '搜尋知平內容';

  @override
  String get searchFilter => '篩選';

  @override
  String get searchGeneral => '綜合';

  @override
  String get searchRealtime => '即時';

  @override
  String get searchUsers => '使用者';

  @override
  String get searchStories => '小說';

  @override
  String get searchArticles => '論文';

  @override
  String get searchVideos => '影片';

  @override
  String get searchTopics => '話題';

  @override
  String get searchColumns => '專欄';

  @override
  String get searchKnowledge => '知識';

  @override
  String get searchIdeas => '想法';

  @override
  String get searchCircles => '圈子';

  @override
  String get searchPodcasts => 'Podcast';

  @override
  String get searchHot => '熱搜';

  @override
  String get searchHistory => '搜尋歷史';

  @override
  String get searchUnavailableTitle => '暫時無法載入';

  @override
  String get searchUnavailableMessage => '匿名內容服務暫時無法使用，請稍後重試。';

  @override
  String get searchNoResults => '找不到相關內容';

  @override
  String get searchScope => '搜尋範圍';

  @override
  String get searchMoreScopes => '左右滑動查看更多';

  @override
  String get searchOverview => '搜尋概覽';

  @override
  String get searchStartHint => '輸入關鍵字開始搜尋';

  @override
  String get searchCurrentScope => '目前範圍';

  @override
  String get searchActiveFilters => '已啟用篩選';

  @override
  String get searchFilterType => '內容類型';

  @override
  String get searchFilterSort => '排序';

  @override
  String get searchFilterTime => '時間範圍';

  @override
  String get searchFilterAnyType => '不限類型';

  @override
  String get searchFilterAnswers => '只看回答';

  @override
  String get searchFilterArticles => '只看文章';

  @override
  String get searchFilterVideos => '只看影片';

  @override
  String get searchSortRelevance => '綜合排序';

  @override
  String get searchSortMostUpvoted => '最多讚同';

  @override
  String get searchSortNewest => '最新發佈';

  @override
  String get searchTimeAny => '不限時間';

  @override
  String get searchTimeDay => '一天內';

  @override
  String get searchTimeWeek => '一週內';

  @override
  String get searchTimeMonth => '一個月內';

  @override
  String get searchTimeThreeMonths => '三個月內';

  @override
  String get searchTimeHalfYear => '半年內';

  @override
  String get searchTimeYear => '一年內';

  @override
  String get commentAll => '全部評論';

  @override
  String commentCount(String count) {
    return '評論 $count';
  }

  @override
  String get commentDefault => '預設';

  @override
  String get commentLatest => '最新';

  @override
  String get commentInputPlaceholder => '理性發言，友善互動';

  @override
  String get commentReply => '回覆這則留言';

  @override
  String get commentPublishReply => '發佈你的回覆';

  @override
  String get commentPublishComment => '發佈你的評論';

  @override
  String commentReplyTo(String name) {
    return '回覆 @$name';
  }

  @override
  String get commentMention => '提及使用者';

  @override
  String get commentCollapse => '收起編輯器';

  @override
  String get commentExpand => '展開編輯器';

  @override
  String get commentImage => '圖片評論';

  @override
  String get loginTitle => '登入';

  @override
  String get loginAccount => '帳號';

  @override
  String get loginPhone => '手機號碼';

  @override
  String get loginPassword => '密碼';

  @override
  String get loginCode => '驗證碼';

  @override
  String get loginContinue => '同意並繼續';

  @override
  String get loginCancel => '暫不同意';

  @override
  String get loginScanSuccess => '掃碼登入成功';

  @override
  String get detailReadAnswer => '寫回答';

  @override
  String get detailRefreshAnswers => '重新整理回答';

  @override
  String get detailSearchBody => '搜尋正文';

  @override
  String get detailReadAloud => '朗讀正文';

  @override
  String get detailExportTxt => '匯出為 TXT';

  @override
  String get detailExportMarkdown => '匯出為 Markdown';

  @override
  String get detailExportHtml => '匯出為 HTML';

  @override
  String get commonExitApp => '再按一次退出應用程式';

  @override
  String get commonEmoji => '表情符號';

  @override
  String get commonRemove => '移除';

  @override
  String get commonOpenZhihu => '開啟知乎驗證';

  @override
  String get commonExpired => '已過期';

  @override
  String get commonReport => '檢舉';

  @override
  String get commonUntitledContent => '未命名內容';

  @override
  String get commonUntitledObject => '未命名項目';

  @override
  String get commonAuthorProfile => '檢視作者個人主頁';

  @override
  String get commonZhihuUser => '知乎使用者';

  @override
  String get commonLike => '讚同';

  @override
  String get commonUnlike => '取消讚同';

  @override
  String get commonDislike => '反對';

  @override
  String get commonDeleteComment => '刪除評論';

  @override
  String get commonCommentActionFailed => '評論操作失敗，請稍後再試。';

  @override
  String get commonOpenLink => '開啟連結';

  @override
  String commonReplyCount(String count) {
    return '$count 則回覆';
  }

  @override
  String commonViewAllReplies(String count) {
    return '檢視全部 $count 則回覆';
  }

  @override
  String get drawerExpired => '已過期';

  @override
  String get loginHeader => '登入知乎';

  @override
  String get loginQrSubtitle => '使用知乎 App 掃碼登入';

  @override
  String get loginPasswordSubtitle => '使用帳號密碼安全登入';

  @override
  String get loginPhoneSubtitle => '使用手機號碼快速登入';

  @override
  String get loginProgressPassword => '登入進度：帳號密碼';

  @override
  String get loginProgressCode => '登入進度：驗證碼';

  @override
  String get loginProgressPhone => '登入進度：手機號碼';

  @override
  String get loginAgreementTitle => '登入前請確認';

  @override
  String get loginAgreementMessage => '請閱讀並同意《知乎使用者協議》與隱私權政策後繼續登入。';

  @override
  String get loginQrLoading => '正在取得 QR 碼';

  @override
  String get loginQrInvalid => '知乎沒有回傳有效的 QR 碼';

  @override
  String get loginQrScanHint => '請開啟知乎 App 掃描';

  @override
  String loginQrFetchFailed(String error) {
    return '取得 QR 碼失敗：$error';
  }

  @override
  String get loginQrExpired => 'QR 碼已過期，請點選重新整理';

  @override
  String get loginQrRiskControl => '請先在知乎網頁完成安全驗證，再重新整理 QR 碼';

  @override
  String get loginQrConfirm => '請在知乎 App 上確認登入';

  @override
  String get loginVerifying => '正在驗證登入';

  @override
  String get loginSuccess => '登入成功';

  @override
  String get loginQrLabel => '知乎登入 QR 碼';

  @override
  String get loginRefreshQr => '重新整理 QR 碼';

  @override
  String get loginQrHint => '請在 QR 碼有效期間於其他裝置確認登入；成功後會保留目前帳號欄位。';

  @override
  String get feedbackNotInterested => '不喜歡這項內容';

  @override
  String get feedbackReduceRecommendation => '減少這類推薦';

  @override
  String get feedbackTitle => '減少這類內容';

  @override
  String get feedbackReduced => '已減少這類內容';

  @override
  String get feedbackInvalidReport => '檢舉網址無效';

  @override
  String get feedbackMissingAction => '此回饋項目沒有可執行的操作';

  @override
  String get feedbackLoading => '正在載入更多回饋選項…';

  @override
  String get feedbackReload => '重新載入';

  @override
  String get accountSessionCheckTitle => '確認登入狀態';

  @override
  String get accountSessionCheckMessage =>
      '知乎回傳了帳號工作階段異常訊號。目前登入資訊仍保留在此裝置上，要清理嗎？';

  @override
  String get accountSessionCheckDetails =>
      '清理後仍可從「設定 > 帳號與多端登入」恢復最近一次工作階段；永久刪除需要再次確認。';

  @override
  String get accountSessionClearKeepBackup => '清理並保留復原副本';

  @override
  String get accountSessionKeep => '保留登入狀態';

  @override
  String get settingsDisableSearchHistoryTitle => '關閉搜尋記錄？';

  @override
  String get settingsDisableSearchHistoryMessage => '關閉後也會清除這部裝置上現有的搜尋記錄。';

  @override
  String get settingsDisableAndClear => '關閉並清除';

  @override
  String get settingsNoSearchHistoryMessage => '目前沒有搜尋記錄';

  @override
  String get settingsClearSearchHistoryTitle => '清除搜尋記錄？';

  @override
  String get settingsClearSearchHistoryMessage => '只會刪除儲存在這部裝置上的搜尋關鍵字。';

  @override
  String get settingsSearchHistoryCleared => '搜尋記錄已清除';

  @override
  String get settingsDisableBrowsingHistoryTitle => '關閉瀏覽記錄？';

  @override
  String get settingsDisableBrowsingHistoryMessage => '關閉後也會清除知乎儲存在這部裝置上的瀏覽記錄。';

  @override
  String get settingsNoBrowsingHistoryMessage => '目前沒有瀏覽記錄';

  @override
  String get settingsClearBrowsingHistoryTitle => '清除瀏覽記錄？';

  @override
  String get settingsClearBrowsingHistoryMessage => '只會刪除儲存在這部裝置上的瀏覽內容索引。';

  @override
  String get settingsBrowsingHistoryCleared => '瀏覽記錄已清除';

  @override
  String get settingsClearOfflineTitle => '清理離線章節？';

  @override
  String get settingsClearOfflineMessage => '已快取的鹽選正文將被刪除，之後閱讀或匯出時需要重新下載。';

  @override
  String get settingsClearOfflineAction => '清理';

  @override
  String settingsOfflineCleared(int count) {
    return '已清理 $count 個離線章節';
  }

  @override
  String get settingsOfflineClearFailed => '離線章節清理失敗，請重試';

  @override
  String settingsCacheSummary(int count, String size) {
    return '$count 張 · $size MB';
  }

  @override
  String get commentEmoji => '表情符號';

  @override
  String get commentRemoveSticker => '移除貼圖';

  @override
  String get commentSelectedImage => '已選取的評論圖片';

  @override
  String get commentUploadingImage => '正在上傳圖片…';

  @override
  String get commentImageAdded => '圖片已加入';

  @override
  String get commentRemoveImage => '移除圖片';

  @override
  String get commentUsernameRequired => '請輸入使用者名稱以提及';

  @override
  String commentMentioned(String name) {
    return '已提及 $name';
  }

  @override
  String get commentLoadingGift => '正在載入禮物';

  @override
  String get commentNoGifts => '目前沒有可用禮物';

  @override
  String get commentImageAddedPending => '圖片已加入，登入後才能發佈';

  @override
  String get commentSignInRequired => '請先登入再發佈';

  @override
  String get commentUploadSignInRequired => '請先登入再發佈圖片';

  @override
  String get commentImageUploadNoUrl => '圖片上傳沒有回傳網址';

  @override
  String commentImagesCount(int count) {
    return '$count 張評論圖片';
  }

  @override
  String get commentViewImage => '查看評論圖片';

  @override
  String get commentCloseImage => '關閉圖片';

  @override
  String get commentSaveImage => '儲存到相簿';

  @override
  String commentSavedTo(String location) {
    return '已儲存到 $location';
  }

  @override
  String get commentSaveFailed => '圖片儲存失敗，請稍後重試';

  @override
  String get commentReportUnavailable => '舉報功能尚未開放';

  @override
  String get commentNoText => '這則評論沒有可顯示的文字內容';

  @override
  String get commentAuthorBadge => '作者';

  @override
  String get commentQuestionAuthor => '提問者';

  @override
  String commentAuthorSemantics(String name) {
    return '評論作者 $name';
  }

  @override
  String get feedHotBadge => '熱榜';

  @override
  String metricVoteup(String count) {
    return '讚同 $count';
  }

  @override
  String metricFavorite(String count) {
    return '收藏 $count';
  }

  @override
  String metricComment(String count) {
    return '評論 $count';
  }

  @override
  String metricThanks(String count) {
    return '感謝 $count';
  }

  @override
  String metricViews(String count) {
    return '瀏覽 $count';
  }

  @override
  String get metricThanked => '已感謝該回答';

  @override
  String get metricFavorited => '已收藏該回答';

  @override
  String metricFollowers(String count) {
    return '$count 位關注者';
  }

  @override
  String metricAnswers(String count) {
    return '$count 個回答';
  }

  @override
  String metricArticles(String count) {
    return '$count 篇文章';
  }

  @override
  String metricItems(String count) {
    return '$count 則內容';
  }

  @override
  String get contentTypeAnswer => '回答';

  @override
  String get contentTypeArticle => '文章';

  @override
  String get contentTypePeople => '使用者';

  @override
  String get contentTypeQuestion => '問題';

  @override
  String get contentTypeColumn => '專欄';

  @override
  String get contentTypeTopic => '話題';

  @override
  String get contentTypeIdea => '想法';

  @override
  String get contentTypeComment => '評論';

  @override
  String accountSwitchedTo(String name) {
    return '已切換至 $name';
  }

  @override
  String get accountSessionRestoreFailed => '帳號工作階段驗證失敗，已恢復先前的登入狀態';

  @override
  String get collectionsLoginRequired => '登入知乎後才能查看自己的收藏';

  @override
  String get collectionsTitle => '我的收藏';

  @override
  String get collectionTitle => '收藏集';

  @override
  String get collectionEmpty => '這個收藏集目前沒有內容';

  @override
  String get collectionsEmpty => '尚未建立或收藏任何內容';

  @override
  String get loginPasswordRequired => '請輸入密碼';

  @override
  String get loginQrSaveFailed => '掃碼登入成功，但帳號欄位儲存失敗，請稍後再試';

  @override
  String get loginHumanVerification => '請先完成真人驗證';

  @override
  String get loginCodeSendFailed => '驗證碼傳送失敗，請稍後再試';

  @override
  String get loginFailedNetwork => '登入失敗，請檢查網路後再試';

  @override
  String get loginFailedCredentials => '登入失敗，請檢查帳號和密碼後再試';

  @override
  String get loginGetCode => '取得驗證碼';

  @override
  String get loginContinueSignIn => '繼續登入';

  @override
  String get loginPasswordSignIn => '使用帳號密碼登入';

  @override
  String get loginPhoneSignIn => '使用手機號碼登入';

  @override
  String get loginQrSignIn => '掃碼登入';

  @override
  String get loginAccountAppeal => '帳號申訴';

  @override
  String get loginAccountAppealHint => '遇到問題？提出帳號申訴';

  @override
  String get loginPhonePlaceholder => '國家／地區碼 + 手機號碼';

  @override
  String get loginAccountPlaceholder => '手機號碼／電子郵件';

  @override
  String get loginPasswordPlaceholder => '密碼';

  @override
  String get loginCodePlaceholder => '輸入 6 位驗證碼';

  @override
  String loginCodeSent(String phone) {
    return '驗證碼已傳送至 $phone';
  }

  @override
  String get loginChangePhone => '更換手機號碼';

  @override
  String get loginNoCode => '沒有收到？';

  @override
  String loginResendAfter(int seconds) {
    return '$seconds 秒後重試';
  }

  @override
  String get loginAgree => '同意';

  @override
  String get loginUserAgreement => '《知乎使用者協議》';

  @override
  String get loginPrivacyPolicy => '與隱私權政策';

  @override
  String get commonSelected => '，已選取';

  @override
  String get searchSuggestion => '搜尋補全';

  @override
  String searchSuggestionFor(String query) {
    return '搜尋建議 $query';
  }

  @override
  String searchSearching(String query) {
    return '正在尋找「$query」';
  }

  @override
  String get searchDesktopHint => '捲動結果清單載入更多內容，點擊卡片查看詳情。';

  @override
  String get searchRelated => '相關搜尋';

  @override
  String get searchRecentContent => '近期內容';

  @override
  String get searchContinue => '繼續尋找';

  @override
  String get searchUntitledNovel => '未命名小說';

  @override
  String get searchUntitledVideo => '未命名影片';

  @override
  String searchMetricFollows(String count) {
    return '$count 關注';
  }

  @override
  String searchMetricQuestions(String count) {
    return '$count 個問題';
  }

  @override
  String searchMetricMembers(String count) {
    return '$count 位成員';
  }

  @override
  String searchMetricDiscussions(String count) {
    return '$count 個討論';
  }

  @override
  String searchMetricParticipants(String count) {
    return '$count 人參與';
  }

  @override
  String searchMetricLiveContent(String count) {
    return '$count 項內容';
  }

  @override
  String searchMetricPlayCount(String count) {
    return '播放 $count 次';
  }

  @override
  String searchHotScoreWan(String value) {
    return '$value 萬';
  }

  @override
  String get userTitle => '使用者';

  @override
  String get userProfileTitle => '使用者主頁';

  @override
  String get userFindTitle => '尋找使用者';

  @override
  String get userFindSubtitle => '輸入個人資料連結中的使用者 token，查看公開資料與內容清單';

  @override
  String get userIdHint => '使用者 ID';

  @override
  String get userViewProfile => '查看使用者資料';

  @override
  String get userContentRelations => '內容與關係';

  @override
  String get userEmpty => '這裡還沒有使用者';

  @override
  String get userSignInToFollow => '登入後可關注使用者';

  @override
  String get userFollowed => '已關注';

  @override
  String get userFollow => '＋ 關注';

  @override
  String userSearchHint(String name) {
    return '搜尋 $name 發佈的內容';
  }

  @override
  String userSearchPrompt(String name) {
    return '搜尋 $name 發佈過的回答、文章和想法';
  }

  @override
  String get userNoResults => '找不到相關內容';

  @override
  String get userLoadFailed => '暫時無法開啟使用者資料';

  @override
  String get userInfo => '使用者資訊';

  @override
  String get userFollowers => '關注者';

  @override
  String get userFollowingPeople => '關注的人';

  @override
  String get userAnswers => '使用者回答';

  @override
  String get userArticles => '使用者文章';

  @override
  String get userCreatedArticles => '使用者創作文章';

  @override
  String get userContributedArticles => '使用者貢獻文章';

  @override
  String get userColumns => '使用者專欄';

  @override
  String get userFollowingColumns => '關注專欄';

  @override
  String get userFollowingQuestions => '關注問題';

  @override
  String get userFollowingCollections => '關注收藏集';

  @override
  String get userFollowingTopics => '關注話題';

  @override
  String get userIdRequired => '請輸入使用者 ID';

  @override
  String get sessionTitle => '帳號';

  @override
  String get sessionSignInZhihu => '登入知乎';

  @override
  String get sessionPhoneLogin => '手機號登入';

  @override
  String get sessionWebLogin => '網頁登入';

  @override
  String get sessionSaved => '登入資訊已儲存';

  @override
  String get sessionCleared => '登入資訊已清除';

  @override
  String get sessionImport => '匯入登入資訊';

  @override
  String get sessionShowSensitive => '暫時顯示敏感值';

  @override
  String get sessionHideSensitive => '重新隱藏敏感值';

  @override
  String get sessionAdvanced => '進階設定';

  @override
  String get sessionOptionalCookie => 'Cookie（選填）';

  @override
  String get sessionOptionalMsId => 'X-MS-ID（選填）';

  @override
  String get sessionManualZse => '手動 X-Zse-96';

  @override
  String get sessionSignTarget => '簽名目標';

  @override
  String get sessionOtherHeaders => '其他 Header';

  @override
  String get sessionSaving => '儲存中…';

  @override
  String get sessionSave => '儲存';

  @override
  String get sessionClear => '清除登入資訊';

  @override
  String get contentTypeContent => '內容';

  @override
  String get userProfileSearchContent => '搜尋 TA 的內容';

  @override
  String get userProfileCopyLink => '複製主頁連結';

  @override
  String get userProfileHomeTab => '主頁';

  @override
  String get userProfileCreationsTab => '創作';

  @override
  String get userProfileActivitiesTab => '動態';

  @override
  String get userProfileVoteupsTab => '讚同';

  @override
  String get userProfileFollowersList => '關注他的人';

  @override
  String get userProfileFollowingList => '他關注的人';

  @override
  String get userProfileLoginRequired => '登入後才能使用此功能';

  @override
  String get userProfileUnfollowTitle => '取消關注？';

  @override
  String userProfileUnfollowMessage(String name) {
    return '將不再關注 $name';
  }

  @override
  String get userProfileUnfollowAction => '取消關注';

  @override
  String get userProfileLinkCopied => '主頁連結已複製';

  @override
  String userProfileIpLocation(String location) {
    return 'IP 所在地：$location';
  }

  @override
  String get userProfileFollowers => '關注者';

  @override
  String get userProfileFollowing => '關注';

  @override
  String get userProfileUserAnswers => '使用者回答';

  @override
  String get userProfileUserArticles => '使用者文章';

  @override
  String get userProfileCreatedArticles => '創作文章';

  @override
  String get userProfileUserCreatedArticles => '使用者創作文章';

  @override
  String get userProfileContributedArticles => '貢獻文章';

  @override
  String get userProfileUserContributedArticles => '使用者貢獻文章';

  @override
  String get userProfileCreatedColumns => '建立的專欄';

  @override
  String get userProfileUserColumns => '使用者專欄';

  @override
  String get userProfileFollowingColumns => '關注專欄';

  @override
  String get userProfileFollowingQuestions => '關注問題';

  @override
  String get userProfileFollowingCollections => '關注收藏集';

  @override
  String get userProfileFollowingTopics => '關注話題';

  @override
  String get userProfileReceivedUpvotes => '獲讚同';

  @override
  String get userProfileReceivedThanks => '獲感謝';

  @override
  String get userProfileReceivedFavorites => '獲收藏';

  @override
  String get userProfilePersonalInfo => '個人資料';

  @override
  String get userProfileAchievements => '個人成就';

  @override
  String get userProfilePublicCreations => '公開創作';

  @override
  String get userProfileFollowingAndCollections => '關注與收藏';

  @override
  String get userProfileFollowingHidden => '對方已隱藏關注清單';

  @override
  String get userProfileFollowedYou => '關注了你';

  @override
  String get userProfileMutualFollow => '互相關注';

  @override
  String get userProfileMessage => '私訊';

  @override
  String get userProfileNoPublicContent => '還沒有公開內容';

  @override
  String get webdavTitle => 'WebDAV 同步';

  @override
  String get webdavIntroTitle => '跨裝置同步本機內容';

  @override
  String get webdavIntroMessage =>
      '只同步搜尋記錄、瀏覽歷史、鹽選離線章節／書架和回答詳情快取。登入憑據、Cookie、裝置識別與本設定不會上傳。';

  @override
  String get webdavConnectionSettings => '連線設定';

  @override
  String get webdavProviderType => '服務類型';

  @override
  String get webdavProviderGeneric => '通用 WebDAV';

  @override
  String get webdavProviderGoogle => 'Google Drive（WebDAV 閘道）';

  @override
  String get webdavProviderOneDrive => 'Microsoft OneDrive（WebDAV）';

  @override
  String get webdavProviderGenericDescription =>
      '適用於支援 WebDAV 的雲端硬碟、NAS 和自建服務。';

  @override
  String get webdavProviderGoogleDescription =>
      'Google Drive 本身不提供原生 WebDAV，請填寫連線到 Google Drive 的 WebDAV 閘道地址。';

  @override
  String get webdavProviderOneDriveDescription =>
      '填寫 OneDrive 的 WebDAV 相容入口；部分帳號或服務可能已限制舊版入口。';

  @override
  String get webdavProviderGenericHint => 'https://dav.example.com/';

  @override
  String get webdavProviderGoogleHint => 'https://gateway.example.com/dav/';

  @override
  String get webdavProviderOneDriveHint => 'https://d.docs.live.net/<CID>/';

  @override
  String get webdavEndpoint => 'WebDAV 地址';

  @override
  String get webdavHttpsHint => '僅支援 HTTPS，請勿將密碼寫入 URL';

  @override
  String get webdavRemoteDirectory => '遠端目錄';

  @override
  String get webdavRemoteDirectoryHint => '會自動建立 v1、answers 和 chapters 子目錄';

  @override
  String get webdavAuthMethod => '驗證方式';

  @override
  String get webdavAuthBasic => '帳號密碼／應用程式專用密碼';

  @override
  String get webdavAuthBearer => 'Bearer 存取權杖';

  @override
  String get webdavUsername => '使用者名稱';

  @override
  String get webdavPasswordOrAppPassword => '密碼／應用程式專用密碼';

  @override
  String get webdavAccessToken => '存取權杖';

  @override
  String get webdavEnable => '啟用 WebDAV 同步';

  @override
  String get webdavEnableSubtitle => '關閉後不會執行網路同步，已儲存的本機設定不會刪除';

  @override
  String get webdavStartupSync => '啟動後自動同步';

  @override
  String get webdavStartupSyncSubtitle => '在背景執行，不阻塞首頁首幀；失敗後可手動重試';

  @override
  String get webdavSyncContent => '同步內容';

  @override
  String get webdavSyncContentSummary =>
      '• 搜尋記錄與瀏覽歷史\n• 鹽選書架及已下載章節\n• 回答詳情快取（恢復後仍可手動重新整理取得最新內容）';

  @override
  String webdavStatus(String message) {
    return '狀態：$message';
  }

  @override
  String get webdavLoading => '正在讀取 WebDAV 設定';

  @override
  String get webdavConfiguredStatus => 'WebDAV 已設定';

  @override
  String get webdavNotConfigured => '尚未設定 WebDAV';

  @override
  String get webdavSettingsSaved => 'WebDAV 設定已儲存';

  @override
  String get webdavClosedStatus => 'WebDAV 已關閉';

  @override
  String get webdavTesting => '正在測試 WebDAV 連線';

  @override
  String get webdavSyncing => '正在同步搜尋、歷史、小說和回答快取';

  @override
  String webdavSyncCompleted(String uploaded, String downloaded) {
    return '同步完成：上傳 $uploaded 項，恢復 $downloaded 項';
  }

  @override
  String webdavConfigFailed(String error) {
    return 'WebDAV 設定無效：$error';
  }

  @override
  String get webdavSyncNotEnabled => 'WebDAV 同步未啟用';

  @override
  String get webdavNotSynced => '尚未同步';

  @override
  String get webdavSyncNow => '立即同步';

  @override
  String get webdavTestConnection => '測試連線';

  @override
  String get webdavDisable => '關閉同步';

  @override
  String get webdavClearLocalSettings => '清除本機設定和憑據';

  @override
  String webdavLoadFailed(String error) {
    return '讀取 WebDAV 設定失敗：$error';
  }

  @override
  String webdavSaveFailed(String error) {
    return '儲存失敗：$error';
  }

  @override
  String get webdavConnected => 'WebDAV 連線成功';

  @override
  String webdavConnectionFailed(String error) {
    return '連線失敗：$error';
  }

  @override
  String webdavSyncFailed(String error) {
    return '同步失敗：$error';
  }

  @override
  String get webdavDisabled => 'WebDAV 同步已關閉，憑據仍保留在本機私有資料庫';

  @override
  String get webdavClearTitle => '清除 WebDAV 設定？';

  @override
  String get webdavClearMessage => '這會刪除本機儲存的 WebDAV 地址、帳號和憑據，不會刪除遠端同步資料。';

  @override
  String get webdavCleared => '本機 WebDAV 設定和憑據已清除';

  @override
  String webdavClearFailed(String error) {
    return '清除失敗：$error';
  }

  @override
  String get webdavInvalidEndpoint => 'WebDAV 地址無效';

  @override
  String get webdavHttpsRequired => 'WebDAV 地址必須使用 HTTPS';

  @override
  String get webdavEndpointCredentials => 'WebDAV 地址不能包含帳號、密碼、查詢參數或片段';

  @override
  String get webdavCredentialCharacters => 'WebDAV 憑據不能包含換行或控制字元';

  @override
  String get webdavInvalidDirectory => '遠端目錄無效';

  @override
  String get webdavUsernameRequired => '帳號密碼驗證需要填寫使用者名稱';

  @override
  String get webdavSecretRequired => '請填寫密碼、應用程式專用密碼或存取權杖';

  @override
  String get webdavCredentialTooLong => '存取憑據過長';

  @override
  String get commonCopy => '複製';

  @override
  String get commonSelectAll => '全選';

  @override
  String get detailDownvote => '反對';

  @override
  String get detailDownvoted => '已反對';

  @override
  String get detailCommentAction => '留言';

  @override
  String get detailViewComments => '查看留言';

  @override
  String detailViewCommentsCount(String count) {
    return '查看 $count 則留言';
  }

  @override
  String get detailFavorite => '收藏';

  @override
  String detailFavoriteCount(String count) {
    return '收藏 $count';
  }

  @override
  String get detailAuthor => '作者';

  @override
  String get detailFollowed => '已關注';

  @override
  String get detailFollow => '關注';

  @override
  String get detailUnfollowAuthor => '取消關注作者';

  @override
  String get detailFollowAuthor => '關注作者';

  @override
  String get detailTop => '頂部';

  @override
  String get detailBackToTop => '回到文章頂部';

  @override
  String get detailBottom => '底部';

  @override
  String get detailJumpToBottom => '跳到文章底部';

  @override
  String get detailCollapseMore => '收起更多功能';

  @override
  String get detailMoreActions => '更多操作';

  @override
  String get detailExportActions => '匯出內容';

  @override
  String get detailSignInFromMe => '請先在「我」中登入。';

  @override
  String get detailWriteAnswerSubtitle => '為這個問題建立新回答';

  @override
  String detailRefreshContent(String content) {
    return '重新整理$content';
  }

  @override
  String get detailRefreshSubtitle => '忽略快取並重新取得最新內容';

  @override
  String get detailSearchSubtitle => '輸入關鍵字快速定位正文';

  @override
  String detailReadAloudSubtitle(String content) {
    return '使用系統語音朗讀目前的$content';
  }

  @override
  String get detailExportTextSubtitle => '儲存目前標題、作者和正文';

  @override
  String detailExportDocument(String format) {
    return '匯出為 $format';
  }

  @override
  String get detailExportPdfSubtitle => '建立適合分享和列印的文件';

  @override
  String get detailExportDocumentSubtitle => '保留標題、作者、段落和正文圖片連結';

  @override
  String get detailCopyAll => '複製全文';

  @override
  String get detailCopySubtitle => '複製目前標題、作者和正文';

  @override
  String get detailClearCache => '清除這則快取';

  @override
  String get detailInviteAnswer => '邀請回答';

  @override
  String get detailCopyAnswer => '複製回答內容';

  @override
  String detailSelectionTooShort(int count) {
    return '至少選擇 $count 個字';
  }

  @override
  String get detailCommentSelection => '留言這段話';

  @override
  String get detailCommentHint => '請輸入你的留言';

  @override
  String detailActionUnavailable(String action) {
    return '$action功能暫不可用';
  }

  @override
  String get detailSignInRequired => '登入後才能使用此功能';

  @override
  String get detailUnfollowTitle => '取消關注？';

  @override
  String detailUnfollowMessage(String name) {
    return '將不再關注 $name';
  }

  @override
  String get detailUnfollowAction => '取消關注';

  @override
  String get detailCacheCleared => '已清除這則回答的快取';

  @override
  String get detailImagePlaceholder => '[圖片]';

  @override
  String get detailVideoPlaceholder => '[影片]';

  @override
  String detailImageCount(int count) {
    return '$count 張正文圖片';
  }

  @override
  String get detailViewImage => '查看正文圖片原圖';

  @override
  String get detailCloseImage => '關閉圖片';

  @override
  String get detailSaveImage => '儲存到相簿';

  @override
  String get detailImageSaved => '圖片已儲存';

  @override
  String get detailImageSavedTo => '已儲存到相簿';

  @override
  String get detailImageSaveFailed => '圖片儲存失敗，請稍後重試';

  @override
  String get detailMyAnswer => '我的回答';

  @override
  String detailAuthorPrefix(String name) {
    return '作者：$name';
  }

  @override
  String get detailNoExportableBody => '目前回答沒有可匯出的正文';

  @override
  String get detailAnswerDetails => '回答詳情';

  @override
  String detailExportedTo(String location) {
    return '已匯出至 $location';
  }

  @override
  String get detailExportFailed => '匯出失敗，請再試一次';

  @override
  String detailDocumentExported(String format, String location) {
    return '已匯出為 $format：$location';
  }

  @override
  String get detailStoppedReading => '已停止朗讀';

  @override
  String get detailNoReadableBody => '目前回答沒有可朗讀的正文';

  @override
  String get detailReading => '正在朗讀正文';

  @override
  String get detailTtsUnavailable => '系統語音無法使用，請安裝語音套件';

  @override
  String get detailNoCopyableText => '目前回答沒有可複製的正文';

  @override
  String get detailCopied => '已複製全文';

  @override
  String get detailSearchBodyTitle => '搜尋正文';

  @override
  String get detailKeywordHint => '輸入關鍵字';

  @override
  String get detailLocate => '定位';

  @override
  String detailBodyNotFound(String keyword) {
    return '正文中找不到「$keyword」';
  }

  @override
  String detailLocated(String keyword) {
    return '已定位到「$keyword」';
  }

  @override
  String get detailWriteAnswer => '寫回答';

  @override
  String get detailAnswerRequired => '回答內容不能為空';

  @override
  String get detailAnswerPublished => '回答已發布';

  @override
  String get commentSentence => '句子留言';

  @override
  String commentSentenceCount(String count) {
    return '$count 則句子留言';
  }

  @override
  String get commentWrite => '寫留言';

  @override
  String commentReplyTitle(String target) {
    return '回覆 $target';
  }

  @override
  String get commentReplyTargetComment => '這則留言';

  @override
  String get commentPublished => '留言已發布。';

  @override
  String get commentReplyPublished => '回覆已發布。';

  @override
  String get commentDeleteTitle => '刪除留言？';

  @override
  String get commentDeleteMessage => '這則留言及其目前的顯示關係將從清單中移除。';

  @override
  String get commentDeleted => '留言已刪除。';

  @override
  String get commentDeleteReplyTitle => '刪除回覆？';

  @override
  String get commentDeleteReplyMessage => '刪除後無法復原。';

  @override
  String get commentReplyDeleted => '回覆已刪除。';

  @override
  String get commentRepliesTitle => '留言回覆';

  @override
  String get commentNoReplies => '還沒有回覆';

  @override
  String get commentNoComments => '還沒有留言';

  @override
  String commentReplyCount(String count) {
    return '回覆 $count';
  }

  @override
  String get commentEditorUnavailable => '暫時無法發表留言';

  @override
  String get commentGif => 'GIF';

  @override
  String get commentExpandEditor => '展開編輯器';

  @override
  String get contentFilterClearTitle => '清空過濾統計？';

  @override
  String get contentFilterClearMessage => '只會刪除本機記錄，不會改變知乎帳號和服務端回饋設定。';

  @override
  String get contentFilterCleared => '內容過濾統計已清空';

  @override
  String get contentFilterClearStats => '清空統計';

  @override
  String get contentFilterStatsTitle => '內容過濾統計';

  @override
  String get contentFilterStatsLabel => '內容過濾統計';

  @override
  String get contentFilterActions => '回饋操作';

  @override
  String get contentFilterHidden => '已隱藏內容';

  @override
  String get contentFilterReasons => '過濾原因';

  @override
  String get contentFilterHint => '在首頁卡片中選擇「減少此類內容」後，這裡會按原因累計統計。';

  @override
  String contentFilterCount(String count) {
    return '$count 次';
  }

  @override
  String get contentFilterLatest => '最近一次';

  @override
  String get contentFilterEmpty => '暫無記錄';

  @override
  String get contentFilterSummaryEmpty => '記錄每次減少內容的原因和結果';

  @override
  String contentFilterSummary(String actions, String hidden, String reasons) {
    return '$actions 次操作 · 已隱藏 $hidden 條 · $reasons 類原因';
  }

  @override
  String get accountSessionsNoCurrent => '目前沒有可儲存的登入工作階段';

  @override
  String get accountSessionsSaved => '目前登入工作階段已儲存';

  @override
  String get accountSessionsSaveFailed => '帳號欄位儲存失敗，請稍後重試';

  @override
  String accountSessionsSwitched(String name) {
    return '已切換到 $name';
  }

  @override
  String get accountSessionsSwitchFailed => '帳號切換失敗，請稍後重試';

  @override
  String get accountSessionsDeleteTitle => '刪除帳號欄位？';

  @override
  String accountSessionsDeleteActiveMessage(String name) {
    return '只刪除本機儲存的 $name，目前工作階段會退出本機並保留可復原副本，不會退出其他裝置。';
  }

  @override
  String accountSessionsDeleteMessage(String name) {
    return '只刪除本機儲存的 $name，不會退出其他裝置。';
  }

  @override
  String get accountSessionsDeleted => '已刪除本機帳號欄位';

  @override
  String get accountSessionsDeleteFailed => '帳號欄位刪除失敗，請稍後重試';

  @override
  String get accountSessionsNoRecovery => '沒有可復原的帳號工作階段';

  @override
  String get accountSessionsRestored => '已復原最近一次清理的帳號工作階段';

  @override
  String get accountSessionsRestoreSaveFailed => '工作階段已復原，但帳號欄位儲存失敗，請稍後重試';

  @override
  String get accountSessionsPurgeTitle => '徹底清理復原憑據？';

  @override
  String get accountSessionsPurgeMessage => '這會永久刪除最近清理後保留的復原副本，之後無法復原。';

  @override
  String get accountSessionsPurgeAction => '徹底刪除';

  @override
  String get accountSessionsPurged => '復原憑據已徹底刪除';

  @override
  String get accountSessionsPurgeFailed => '復原憑據清理失敗，請稍後重試';

  @override
  String get accountSessionsTitle => '帳號與多裝置登入';

  @override
  String get accountSessionsSaveCurrent => '儲存目前工作階段';

  @override
  String get accountSessionsIntro =>
      '使用掃碼或手機登入後的工作階段會儲存在本機私有憑據資料庫中。切換前會重新驗證 /people/self；不會主動退出其他裝置。';

  @override
  String get accountSessionsRecoveryTitle => '最近清理的登入資訊';

  @override
  String get accountSessionsRecoveryMessage =>
      '伺服器失效確認後清理的帳號仍保留在本機復原區。可以復原，也可以在這裡永久刪除。';

  @override
  String get accountSessionsRestore => '復原';

  @override
  String get accountSessionsEmptyTitle => '還沒有儲存的帳號欄位';

  @override
  String get accountSessionsEmptyMessage => '登入成功後可在這裡管理多裝置工作階段。';

  @override
  String get accountSessionsQr => '掃碼工作階段';

  @override
  String get accountSessionsPassword => '手機/密碼工作階段';

  @override
  String get accountSessionsCurrent => '目前使用';

  @override
  String get accountSessionsExpired => '已過期';

  @override
  String get accountSessionsMenu => '帳號操作';

  @override
  String get accountSessionsSwitch => '切換並驗證';

  @override
  String get accountSessionsRemoveSlot => '刪除欄位';

  @override
  String get accountSessionsAdd => '新增帳號 / 掃碼登入';

  @override
  String get accountDefaultName => '知乎帳號';

  @override
  String accountMaskedName(String id) {
    return '帳號 $id';
  }

  @override
  String get browsingHistoryClearTitle => '清空瀏覽記錄？';

  @override
  String get browsingHistoryClearMessage => '這只會刪除知閱儲存在本機的瀏覽記錄。';

  @override
  String get browsingHistoryTitle => '瀏覽記錄';

  @override
  String get browsingHistoryClear => '清空瀏覽記錄';

  @override
  String get browsingHistoryEmptyTitle => '還沒有瀏覽記錄';

  @override
  String get browsingHistoryEmptyMessage => '開啟回答、文章、問題或話題後會顯示在這裡';

  @override
  String browsingHistoryToday(String time) {
    return '今天 $time';
  }

  @override
  String browsingHistoryDate(int month, int day, String time) {
    return '$month月$day日 $time';
  }

  @override
  String get updateCheckFailed => '檢查更新失敗，請稍後重試';

  @override
  String get updateAllowInstallTitle => '允許安裝應用程式';

  @override
  String get updateAllowInstallMessage =>
      'Android 需要你允許知閱安裝下載的更新。開啟後返回此頁，再點一次下載並安裝。';

  @override
  String get updateOpenSettings => '前往設定';

  @override
  String get updateCachedInstalling => '已使用下載好的更新套件，正在開啟 Android 安裝程式';

  @override
  String get updateVerifiedInstalling => '更新已驗證，正在開啟 Android 安裝程式';

  @override
  String get updateInstallFailed => '更新安裝失敗，請重試';

  @override
  String get updateTitle => '軟體更新';

  @override
  String get updateAppName => '知閱';

  @override
  String get updateReadingVersion => '正在讀取版本資訊';

  @override
  String updateCurrentVersion(String version, String code) {
    return '目前版本 $version ($code)';
  }

  @override
  String get updateUnsupportedTitle => '目前平台不支援應用程式內安裝';

  @override
  String get updateUnsupportedMessage => '安全下載、驗證和系統安裝程式目前僅在 Android 用戶端啟用。';

  @override
  String get updateCheckingTitle => '正在檢查更新';

  @override
  String get updateCheckingMessage => '正在從 GitHub Releases 讀取穩定版本。';

  @override
  String get updateLatestTitle => '已是最新版本';

  @override
  String get updateNoRelease => '穩定頻道目前沒有已發布版本。';

  @override
  String updateLatestVersion(String version, String code) {
    return '穩定頻道最新版本為 $version ($code)。';
  }

  @override
  String get updateChecking => '正在檢查';

  @override
  String get updateRecheck => '重新檢查';

  @override
  String get updateSecurity => '更新安全';

  @override
  String get updateSecuritySourceTitle => 'GitHub Releases';

  @override
  String get updateSecuritySourceDetail =>
      '只接受指定 GitHub 儲存庫中規範命名的穩定版 arm64 APK。';

  @override
  String get updateSecurityIntegrityTitle => '完整性驗證';

  @override
  String get updateSecurityIntegrityDetail =>
      '下載後驗證 GitHub 提供的 SHA-256 摘要和檔案大小。';

  @override
  String get updateSecurityInstallerTitle => '交給系統安裝程式';

  @override
  String get updateSecurityInstallerDetail =>
      '還會驗證套件名稱、版本及憑證連續性，再開啟 Android 安裝程式。';

  @override
  String get updateImportant => '重要更新';

  @override
  String updateNewVersion(String version) {
    return '發現新版本 $version';
  }

  @override
  String get updateImportantFound => '發現重要更新';

  @override
  String get updatePublishedToReleases => '新版本已發布到 GitHub Releases。';

  @override
  String get updateLater => '稍後';

  @override
  String get updateView => '查看更新';

  @override
  String updateVersion(String version) {
    return '版本 $version';
  }

  @override
  String updateReleaseMeta(String size, String code) {
    return '$size APK · 穩定頻道 · 建置 $code';
  }

  @override
  String get updateViewDetails => '查看更新介面詳情';

  @override
  String get updateVerifiedManifest => '已驗證清單、套件大小和 SHA-256';

  @override
  String get updateReleaseId => '發布編號';

  @override
  String get updatePublishedAt => '發布時間';

  @override
  String get updateReleaseTag => 'Release 標籤';

  @override
  String get updatePackageType => '套件類型';

  @override
  String get updatePackageSha256 => 'APK SHA-256';

  @override
  String get updateManifestResponse => '清單回應';

  @override
  String updateDownloadProgress(String received, String total) {
    return '下載 APK $received / $total';
  }

  @override
  String get updateVerifyingPackage => '正在驗證安裝套件';

  @override
  String get updateContinueInstall => '繼續安裝';

  @override
  String get updateDownloadInstall => '下載並安裝';

  @override
  String get updateValidation => '驗證';

  @override
  String updateManifestSummary(String size) {
    return '$size 清單';
  }

  @override
  String get profileChange => '更換';

  @override
  String get profileUserFallback => '知乎用戶';

  @override
  String get profileAnswers => '回答';

  @override
  String get profileArticles => '文章';

  @override
  String get profileIdeas => '想法';

  @override
  String get profileCollections => '收藏';

  @override
  String get profileUpvotes => '獲讚';

  @override
  String get profileFollowers => '被關注';

  @override
  String get profileFollowing => '關注';

  @override
  String get profileEdit => '編輯資料';

  @override
  String get profileAllDetails => '全部資料';

  @override
  String get profileMyContent => '我的內容';

  @override
  String get profileMyAnswers => '我的回答';

  @override
  String get profileMyArticles => '我的文章';

  @override
  String get profileMyIdeas => '我的想法';

  @override
  String get profileMyCollections => '我的收藏';

  @override
  String get profileIdeasTab => '靈感';

  @override
  String get profileCreationTab => '創作';

  @override
  String get profileActivityTab => '動態';

  @override
  String get profileVoteupTab => '讚同';

  @override
  String get profilePublicActivitiesEmpty => '還沒有公開動態';

  @override
  String get profilePublicVoteupsEmpty => '還沒有公開讚同';

  @override
  String get profileVipSalt => '鹽選會員';

  @override
  String get profileVipZhihu => '知乎會員';

  @override
  String get profileMetricWan => '萬';

  @override
  String get profileMetricYi => '億';

  @override
  String profileMetricItems(String count) {
    return '$count 條';
  }

  @override
  String get profileGenderFemale => '女';

  @override
  String get profileGenderMale => '男';

  @override
  String get profileGenderUnspecified => '未填寫';

  @override
  String get profileJustJoined => '剛剛加入';

  @override
  String profileAgeDays(int count) {
    return '$count 天';
  }

  @override
  String profileAgeMonthsDays(int months, int days) {
    return '$months 個月 $days 天';
  }

  @override
  String profileAgeYearsMonths(int years, int months) {
    return '$years 年 $months 個月';
  }

  @override
  String get profileBasicInfo => '基本資料';

  @override
  String get profileUsername => '使用者名稱';

  @override
  String get profileAccountAge => '知齡';

  @override
  String get profileGender => '性別';

  @override
  String get profileBirthday => '生日';

  @override
  String get profileLocation => '居住地';

  @override
  String get profileVerification => '認證資訊';

  @override
  String get profileManageVerification => '管理認證';

  @override
  String get profileUnverified => '未認證';

  @override
  String get profileInfluence => '影響力';

  @override
  String get profileBadges => '我的徽章';

  @override
  String get profileLikes => '獲得喜歡';

  @override
  String get profileNone => '暫無';

  @override
  String profileCountPieces(int count) {
    return '$count 枚';
  }

  @override
  String profileCountTimes(int count) {
    return '$count 次';
  }

  @override
  String get profileFriendImpression => '好友印象';

  @override
  String get profileImproveImage => '完善我的知乎形象，獲取更多關注';

  @override
  String get profileAddKeywords => '新增形象關鍵字';

  @override
  String get profileLinkCopied => '主頁連結已複製';

  @override
  String get profileTitle => '我的主頁';

  @override
  String get profileLoadFailed => '個人資料載入失敗';

  @override
  String get profileNetworkRetry => '請檢查網路後重試';

  @override
  String get profileOpenDrawer => '開啟側邊欄';

  @override
  String get profileFindUser => '尋找使用者';

  @override
  String get profileCopyHomeLink => '複製主頁連結';

  @override
  String get profileUsernameEmpty => '使用者名稱不能為空';

  @override
  String get profileFieldTooLong => '使用者名稱、介紹或個人簡介超過長度限制';

  @override
  String get profileImageUploadNoUrl => '圖片上傳未返回位址';

  @override
  String get profileCoverUploadNoHash => '主頁背景上傳未返回圖片雜湊';

  @override
  String get profileCoverUpdated => '主頁背景已更新';

  @override
  String get profileAvatarUpdated => '頭像已更新';

  @override
  String get profileAddEmployment => '新增職業經歷';

  @override
  String get profileCompanyOrOrganization => '公司或組織';

  @override
  String get profileJob => '職位';

  @override
  String get profileAddEducation => '新增教育經歷';

  @override
  String get profileSchool => '學校';

  @override
  String get profileMajor => '專業';

  @override
  String get profileEditTitle => '編輯個人資料';

  @override
  String get profileSaving => '儲存中';

  @override
  String get profileInfoNotice => '您填寫的內容將用於個人頁展示及內容推薦';

  @override
  String get profileAvatar => '頭像';

  @override
  String get profileCover => '主頁背景';

  @override
  String get profileHeadline => '一句話介紹';

  @override
  String get profileHeadlinePlaceholder => '介紹自己的職業或興趣';

  @override
  String get profileBirthdayPlaceholder => '請填寫生日';

  @override
  String get profileLocationPlaceholder => '請填寫居住地';

  @override
  String get profileIndustry => '所在產業';

  @override
  String get profileIndustryPlaceholder => '請選擇產業';

  @override
  String get profileEmployment => '職業經歷';

  @override
  String get profileEducation => '教育經歷';

  @override
  String get profilePersonalVerification => '個人認證';

  @override
  String get profileAddVerification => '新增個人認證';

  @override
  String get profileBio => '個人簡介';

  @override
  String get profileBioPlaceholder => '用一段話介紹自己';

  @override
  String get notificationCommentCategory => '留言轉發@';

  @override
  String get notificationLikeCategory => '讚同喜歡';

  @override
  String get notificationFavoriteCategory => '收藏了我';

  @override
  String get notificationFollowCategory => '關注訂閱';

  @override
  String get notificationInvite => '邀請回答';

  @override
  String get notificationMarkedRead => '已將訊息標為已讀';

  @override
  String get notificationTitle => '訊息';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get notificationMarkAllRead => '全部標為已讀';

  @override
  String get notificationLoadFailed => '訊息載入失敗';

  @override
  String notificationInvitePending(String count) {
    return '$count 條待處理邀請';
  }

  @override
  String get notificationInviteView => '查看邀請你回答的問題';

  @override
  String get notificationCategoryEmpty => '暫時沒有這類通知';

  @override
  String get notificationCategoryMarkedRead => '該分類已全部標為已讀';

  @override
  String get notificationSettingsTitle => '通知設定';

  @override
  String get notificationSettingsSection => '互動與內容通知';

  @override
  String get notificationAll => '全部';

  @override
  String get notificationLoginTitle => '登入後查看訊息';

  @override
  String get notificationLoginMessage => '訊息通知屬於知乎帳號資料';

  @override
  String get notificationBackLogin => '返回並登入';

  @override
  String get messageTitle => '私訊';

  @override
  String get messageLoadFailed => '私訊載入失敗';

  @override
  String get messageComposeHint => '發私訊';

  @override
  String get messageSend => '傳送';

  @override
  String get notificationSettingCommentMe => '留言了我';

  @override
  String get notificationSettingMentionMe => '提及了我';

  @override
  String get notificationSettingAnswerVoteup => '讚同了我的回答';

  @override
  String get notificationSettingContentVoteup => '讚同了我的內容';

  @override
  String get notificationSettingAnswerThanks => '感謝了我的回答';

  @override
  String get notificationSettingRepin => '收藏了我的內容';

  @override
  String get notificationSettingReaction => '回應了我的內容';

  @override
  String get notificationSettingMemberFollow => '關注了我';

  @override
  String get notificationSettingFavlistFollow => '關注了我的收藏夾';

  @override
  String get notificationSettingColumnFollow => '關注了我的專欄';

  @override
  String get notificationSettingQuestionAnswered => '我關注的問題有新回答';

  @override
  String get notificationSettingAnswerQuestion => '回答了我的問題';

  @override
  String get notificationSettingQuestionInvite => '邀請我回答';

  @override
  String get notificationSettingColumnUpdate => '關注的專欄有更新';

  @override
  String get notificationSettingMemberActivity => '關注的人有新動態';

  @override
  String get notificationSettingSpecialUpdate => '關注的專題有更新';

  @override
  String get notificationSettingMessage => '收到私訊';

  @override
  String get notificationSettingStrangerMessage => '陌生人私訊';

  @override
  String get notificationSettingCoupon => '優惠與權益提醒';

  @override
  String get notificationSettingBoughtContent => '已購內容更新';

  @override
  String get notificationSettingEbook => '電子書上新';

  @override
  String get notificationSettingArticleInvite => '邀請我創作文章';

  @override
  String get notificationSettingTipjar => '文章讚賞到帳';

  @override
  String get creationAll => '全部';

  @override
  String creationAnswers(String count) {
    return '回答 $count';
  }

  @override
  String creationIdeas(String count) {
    return '想法 $count';
  }

  @override
  String creationArticles(String count) {
    return '文章 $count';
  }

  @override
  String creationColumns(String count) {
    return '專欄 $count';
  }

  @override
  String creationQuestions(String count) {
    return '提問 $count';
  }

  @override
  String creationVideos(String count) {
    return '影片 $count';
  }

  @override
  String get creationMore => '更多';

  @override
  String get creationEmpty => '還沒有發布內容';

  @override
  String get creationFavorites => '我的收藏';

  @override
  String get creationHighlights => '我的劃線';

  @override
  String get creationFollowingColumns => '訂閱的專欄';

  @override
  String get creationFollowingTopics => '關注的話題';

  @override
  String get creationFollowingCollections => '關注的收藏夾';

  @override
  String get creationFollowingQuestions => '關注的問題';

  @override
  String get activityShare => '分享';

  @override
  String get activityDelete => '刪除這條動態';

  @override
  String get activityLinkCopied => '連結已複製';

  @override
  String get activityDeleteTitle => '刪除這條動態？';

  @override
  String get activityDeleteMessage => '刪除後無法復原。';

  @override
  String get activityDeleted => '動態已刪除';

  @override
  String get questionIdUnavailable => '暫時無法識別問題 ID，請重新整理後重試';

  @override
  String get questionFollowed => '已關注問題';

  @override
  String get questionUnfollowed => '已取消關注問題';

  @override
  String get questionAnswerPublishedRefreshing => '回答已發布，清單正在重新整理。';

  @override
  String get questionDeleteTitle => '刪除回答？';

  @override
  String get questionDeleteMessage => '刪除後無法復原。';

  @override
  String get questionDeleted => '回答已刪除。';

  @override
  String get questionAnswersTitle => '全部回答';

  @override
  String get questionSearchAnswers => '搜尋回答';

  @override
  String get questionMore => '更多';

  @override
  String get questionLoginToWrite => '登入後寫回答';

  @override
  String get questionUnfollow => '取消關注問題';

  @override
  String get questionFollow => '關注問題';

  @override
  String get questionAnswerRefresh => '重新整理回答';

  @override
  String get questionCollapseDetails => '收起問題詳細資料';

  @override
  String get questionExpandDetails => '展開問題詳細資料';

  @override
  String get questionCollapse => '收起';

  @override
  String get questionExpandFull => '展開全文';

  @override
  String questionOpenTopic(String name) {
    return '開啟話題 $name';
  }

  @override
  String questionAllContentCount(String count) {
    return '全部內容 $count';
  }

  @override
  String get questionSortDefault => '預設';

  @override
  String get questionSortLatest => '最新';

  @override
  String get questionSortSemantic => '回答排序：';

  @override
  String questionAuthor(String name) {
    return '提問者 $name';
  }

  @override
  String get questionAuthorBadge => '提問者';

  @override
  String get questionViewImage => '查看問題圖片原圖';

  @override
  String get topicFollowersTitle => '話題關注者';

  @override
  String get topicUnansweredTitle => '話題待回答問題';

  @override
  String topicFallbackTitle(String id) {
    return '話題 $id';
  }

  @override
  String get topicRefresh => '重新整理話題資料';

  @override
  String get topicLabel => '話題';

  @override
  String topicFollowers(String count) {
    return '$count 位關注者';
  }

  @override
  String topicQuestions(String count) {
    return '$count 個問題';
  }

  @override
  String topicAnswers(String count) {
    return '$count 個回答';
  }

  @override
  String topicDiscussions(String count) {
    return '$count 個討論';
  }

  @override
  String get topicBasicUnavailable => '基本資料尚未載入，精華清單仍可獨立瀏覽。';

  @override
  String get topicFollowersButton => '關注者';

  @override
  String get topicUnansweredButton => '待回答';

  @override
  String get zvideoTitle => '影片';

  @override
  String get zvideoCommentsUnavailable => '留言';

  @override
  String zvideoActionUnavailable(String action) {
    return '$action功能暫不可用';
  }

  @override
  String get zvideoLoadFailed => '影片暫時無法載入';

  @override
  String zvideoFallbackTitle(String id) {
    return '影片 #$id';
  }

  @override
  String get zvideoViewComments => '查看留言';

  @override
  String zvideoViewCommentsCount(String count) {
    return '查看 $count 則留言';
  }

  @override
  String get zvideoMissing => '沒有取得可播放的影片資訊';

  @override
  String get zvideoVoteup => '讚同';

  @override
  String get zvideoComment => '留言';

  @override
  String get zvideoFavorite => '收藏';

  @override
  String get zvideoShare => '分享';

  @override
  String get zvideoVoteupSemantic => '讚同影片';

  @override
  String get zvideoCommentsSemantic => '查看影片留言';

  @override
  String get zvideoFavoriteSemantic => '收藏影片';

  @override
  String get zvideoShareSemantic => '分享影片';

  @override
  String get inlineVideoPlatformUnsupported => '目前平台不支援內嵌影片播放';

  @override
  String get inlineVideoLoadFailed => '影片暫時無法播放，請稍後重試';

  @override
  String get inlineVideoInterruptedRetry => '影片播放已中斷，請點按重試';

  @override
  String get inlineVideoSwitchingLine => '播放中斷，正在切換線路…';

  @override
  String get inlineVideoPaidNoAccess => '付費影片 · 目前帳號沒有觀看權限';

  @override
  String get inlineVideoUnavailable => '影片暫時無法播放';

  @override
  String get inlineVideoPrivacyUnavailable => '目前平台不支援隱私受限的影片播放';

  @override
  String get inlineVideoPlay => '播放影片';

  @override
  String inlineVideoPlayTitle(String title) {
    return '播放影片：$title';
  }

  @override
  String get inlineVideoFullscreen => '全螢幕';

  @override
  String get inlineVideoStopped => '影片已停止或正在切換線路';

  @override
  String get inlineVideoBack => '返回';

  @override
  String get answerSwitchRelease => '放開以切換';

  @override
  String get answerSwitchPreviousHint => '繼續下拉查看上一個回答';

  @override
  String get answerSwitchNextHint => '繼續上滑查看下一個回答';

  @override
  String answerSwitchTo(String author) {
    return '放開以切換到 $author 的回答';
  }

  @override
  String get answerPrevious => '上一個';

  @override
  String get answerNext => '下一個';

  @override
  String get detailWriteAnswerLogin => '登入後寫回答';

  @override
  String saltDownloadedProgress(int downloaded, int total) {
    return '$downloaded/$total 已下載';
  }

  @override
  String saltDownloadedSections(int count) {
    return '$count 節已下載';
  }

  @override
  String get saltAudio => '鹽選音訊';

  @override
  String get saltVideo => '鹽選影片';

  @override
  String get saltStory => '鹽選故事';

  @override
  String get saltLimitedFree => '限時免費';

  @override
  String get saltUntitledContent => '未命名鹽選內容';

  @override
  String saltLikeCount(String count) {
    return '讚同 $count';
  }

  @override
  String saltCommentCount(String count) {
    return '留言 $count';
  }

  @override
  String saltWordCount(String count) {
    return '$count 字';
  }

  @override
  String saltReadCount(String count) {
    return '瀏覽 $count';
  }

  @override
  String saltFavoriteCount(String count) {
    return '收藏 $count';
  }

  @override
  String get saltPlayable => '可聽';

  @override
  String get saltSupportsAudio => '支援聽書';

  @override
  String get saltFree => '免費';

  @override
  String get saltTrial => '試讀';

  @override
  String get saltMember => '鹽選會員';

  @override
  String get saltEntitlementRequired => '需要權益';

  @override
  String get saltLastRead => '上次讀到';

  @override
  String get saltReadFinished => '已讀完';

  @override
  String get saltUntitledChapter => '未命名章節';

  @override
  String get saltResourceAudio => '音訊';

  @override
  String get saltResourceVideo => '影片';

  @override
  String get saltResourceSlide => '課件';

  @override
  String get saltResourceText => '圖文';

  @override
  String saltReadPercent(int percent) {
    return '已讀 $percent%';
  }

  @override
  String saltCommentBadge(int count) {
    return '查看 $count 條彈評';
  }

  @override
  String followMoreAnswers(int count) {
    return 'TA 還讚同了 $count 個回答';
  }

  @override
  String get brandZhihu => '知乎';

  @override
  String detailQuestionAnswerCount(String count) {
    return '$count 個回答';
  }

  @override
  String detailQuestionFollowerCount(String count) {
    return '$count 人關注';
  }

  @override
  String get detailQuestionAnswersSemantic => '查看該問題的全部回答';

  @override
  String detailQuestionFallback(String id) {
    return '問題 #$id';
  }

  @override
  String get questionInviteTitle => '邀請回答';

  @override
  String get questionInviteEmpty => '暫時沒有推薦邀請人';

  @override
  String get questionInviteInvited => '已邀請';

  @override
  String get questionInviteAction => '邀請';

  @override
  String get routingSafetyTitle => '安全提示';

  @override
  String get routingLeaveZhihu => '即將離開知乎';

  @override
  String get routingExternalWarning => '該連結並非知乎官方頁面，請注意保護帳號、隱私和財產安全。';

  @override
  String get routingConfirmVisit => '確認存取';

  @override
  String get routingOpenVerification => '開啟知乎驗證';

  @override
  String get webSafetyTitle => '安全驗證';

  @override
  String get webPageLoadFailedNetwork => '頁面載入失敗，請檢查網路後重試';

  @override
  String get webPageUnavailable => '頁面暫時無法開啟，請稍後重試';

  @override
  String get webSessionSyncFailed => '登入狀態未能同步，請重新登入後再試';

  @override
  String get webLoginExpired => '網頁登入狀態已失效，請重新登入後再試';

  @override
  String get webSystemBrowserUnavailable => '無法呼叫系統瀏覽器';

  @override
  String get webContinueInBrowser => '請在瀏覽器中繼續';

  @override
  String get webDesktopSystemBrowser => '目前桌面平台使用系統瀏覽器';

  @override
  String get webOpenBrowser => '開啟瀏覽器';

  @override
  String get webOpeningChapter => '正在開啟章節';

  @override
  String get webOpeningPage => '正在開啟頁面';

  @override
  String get webOpenInBrowser => '在瀏覽器中開啟';

  @override
  String get webChapterReading => '章節閱讀';

  @override
  String get routingCannotOpen => '暫時無法開啟。';

  @override
  String get routingCannotViewComments => '暫時無法查看留言。';

  @override
  String get routingUnsupportedAction => '目前內容暫不支援此操作。';

  @override
  String get routingPinDownvoteUnavailable => '想法暫不提供反對操作。';

  @override
  String get routingDownvoteCancelled => '已取消反對。';

  @override
  String get routingDownvoted => '已反對該內容。';

  @override
  String get routingVoteCancelled => '已取消讚同。';

  @override
  String get routingVoted => '已讚同該內容。';

  @override
  String get routingFavoriteRemoved => '已取消收藏。';

  @override
  String get routingFavorited => '已加入預設收藏夾。';

  @override
  String get objectDetailTitle => '內容詳情';

  @override
  String get objectImages => '圖片';

  @override
  String get objectContent => '內容';

  @override
  String get contentTypeCollection => '收藏集';

  @override
  String columnFallbackTitle(String token) {
    return '專欄 $token';
  }

  @override
  String get columnFollowersTitle => '專欄關注者';

  @override
  String get columnLoadFailed => '專欄資訊暫未載入。';

  @override
  String get columnRetry => '重試專欄資料';

  @override
  String get columnTitle => '專欄';

  @override
  String columnArticleCount(String count) {
    return '$count 篇文章';
  }

  @override
  String columnFollowerCount(String count) {
    return '$count 關注者';
  }

  @override
  String columnContributionCount(String count) {
    return '$count 篇投稿';
  }

  @override
  String columnVoteupCount(String count) {
    return '$count 獲讚';
  }

  @override
  String columnAuthorPrefix(String name) {
    return '作者 $name';
  }

  @override
  String get columnFollowers => '關注者';

  @override
  String get columnAuthorProfile => '作者資料';

  @override
  String get detailContentIncomplete => '內容可能不完整';

  @override
  String get detailPaidUnlocked => '鹽選會員內容已解鎖，以下為目前帳號可讀的完整正文。';

  @override
  String get detailPaidLocked => '這是鹽選會員內容，目前帳號返回的正文仍處於未解鎖狀態。';

  @override
  String get detailRelatedLoadFailed => '載入其他回答失敗，點擊重試';

  @override
  String get detailViewCommentsButton => '查看留言';

  @override
  String get detailContentInfo => '內容資訊';

  @override
  String get detailReadingHint => '主要內容欄已限制閱讀寬度，捲動時仍可隨時查看互動資料。';

  @override
  String get blockedKeywordsTitle => '封鎖關鍵字';

  @override
  String blockedKeywordsInvalidLength(int min, int max) {
    return '關鍵字需為 $min-$max 個字元';
  }

  @override
  String get blockedKeywordsExists => '該關鍵字已存在';

  @override
  String blockedKeywordsLimit(int max) {
    return '最多可設定 $max 個關鍵字';
  }

  @override
  String get blockedKeywordsDescription => '包含這些關鍵字的推薦將會減少';

  @override
  String blockedKeywordsCount(int current, int max) {
    return '已設定 $current/$max';
  }

  @override
  String blockedKeywordsHint(int min, int max) {
    return '$min-$max 個字元';
  }

  @override
  String get blockedKeywordsAdd => '新增關鍵字';

  @override
  String get blockedKeywordsEmpty => '尚未設定封鎖關鍵字';

  @override
  String blockedKeywordsDelete(String keyword) {
    return '刪除 $keyword';
  }

  @override
  String get recommendationClearTitle => '清空本機推薦畫像？';

  @override
  String get recommendationClearMessage => '只會刪除本機記錄，不會影響知乎帳號和伺服器推薦。';

  @override
  String get recommendationCleared => '本機推薦畫像已清空';

  @override
  String get recommendationTitle => '本機推薦行為';

  @override
  String get recommendationClearSemantic => '清空本機畫像';

  @override
  String get recommendationEmptyTitle => '暫時還沒有本機行為';

  @override
  String get recommendationProfileTitle => '本機推薦畫像';

  @override
  String get recommendationEmptyMessage => '開啟推薦內容或使用「不感興趣」後，知閱會在本機記錄有限的興趣訊號。';

  @override
  String recommendationSummary(int total, int opened, int feedback) {
    return '已記錄 $total 條訊號 · 開啟 $opened · 回饋 $feedback';
  }

  @override
  String get recommendationTopics => '常見興趣詞';

  @override
  String get recommendationAuthors => '常見作者';

  @override
  String get recommendationPrivacy => '資料僅儲存在本機，用於本機或混合推薦排序；不會上傳行為明細。';

  @override
  String get discoverColumns => '專欄推薦';

  @override
  String get discoverTopics => '話題分類';

  @override
  String get discoverHotTopics => '熱門話題';

  @override
  String get discoverHotTopicsEmpty => '暫時沒有熱門話題';

  @override
  String get discoverContentIdInvalid => '內容 ID 必須是 1–32 位數字';

  @override
  String get discoverTitle => '探索';

  @override
  String get discoverColumnsAndTopics => '專欄與話題';

  @override
  String get discoverColumnsSubtitle => '編輯精選與熱門專欄文章';

  @override
  String get discoverTopicsSubtitle => '按分類瀏覽話題';

  @override
  String get discoverHotTopicsSubtitle => '目前熱門討論';

  @override
  String get discoverOpenById => '透過 ID 開啟內容';

  @override
  String get discoverTypeAnswer => '回答';

  @override
  String get discoverTypeArticle => '文章';

  @override
  String get discoverTypeIdea => '想法';

  @override
  String get discoverIdHint => '輸入內容 ID';

  @override
  String get discoverOpenDetails => '開啟詳情';

  @override
  String get pagedEnd => '已經到底了';

  @override
  String get pagedEmpty => '還沒有內容';

  @override
  String get diagnosticExported => '日誌 JSON 已複製到剪貼簿';

  @override
  String get diagnosticEmpty => '目前沒有日誌';

  @override
  String get diagnosticClearTitle => '清理診斷日誌？';

  @override
  String get diagnosticClearMessage => '這只會刪除本機保存的診斷記錄，不會影響帳號和內容快取。';

  @override
  String get diagnosticCleared => '診斷日誌已清理';

  @override
  String get diagnosticTitle => '診斷日誌';

  @override
  String get diagnosticExport => '匯出日誌';

  @override
  String get diagnosticClear => '清理日誌';

  @override
  String get diagnosticPurpose => '用於定位「內容已被刪除」、介面失敗和卡頓問題';

  @override
  String get diagnosticPrivacy =>
      '認證失效、復原和清理決定預設記錄；其他診斷日誌可單獨開關。日誌只儲存去識別化狀態，不儲存 Cookie、權杖、正文或圖片。';

  @override
  String get diagnosticLocalEnabled => '啟用本機日誌';

  @override
  String get diagnosticLocalSubtitle => '開啟後保留最近 600 條診斷記錄';

  @override
  String get diagnosticAuthEnabled => '認證狀態日誌';

  @override
  String get diagnosticAuthSubtitle => '記錄登入失效、復原、保留和清理決定，預設開啟';

  @override
  String get diagnosticNetworkEnabled => '網路請求日誌';

  @override
  String get diagnosticNetworkSubtitle => '記錄介面路徑、HTTP 狀態、業務碼和耗時';

  @override
  String get diagnosticPerformanceEnabled => '效能日誌';

  @override
  String get diagnosticPerformanceSubtitle => '記錄介面耗時，協助定位掉幀和慢請求';

  @override
  String diagnosticInstallSummary(String id, int count) {
    return '本機識別碼 $id · $count 條';
  }

  @override
  String get diagnosticEmptyTitle => '暫無診斷日誌';

  @override
  String get diagnosticEmptyMessage => '開啟本機日誌後重新操作一次，異常和網路狀態會顯示在這裡。';

  @override
  String get diagnosticNoDetails => '沒有附加資訊';

  @override
  String get diagnosticLevelDebug => '除錯';

  @override
  String get diagnosticLevelInfo => '資訊';

  @override
  String get diagnosticLevelWarning => '警告';

  @override
  String get diagnosticLevelError => '錯誤';

  @override
  String get diagnosticCategoryApp => '應用程式';

  @override
  String get diagnosticCategoryNetwork => '網路';

  @override
  String get diagnosticCategoryPerformance => '效能';

  @override
  String get diagnosticCategoryError => '錯誤';

  @override
  String get diagnosticCategoryAuthentication => '驗證';
}
