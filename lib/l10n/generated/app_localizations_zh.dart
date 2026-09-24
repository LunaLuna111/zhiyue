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
}
