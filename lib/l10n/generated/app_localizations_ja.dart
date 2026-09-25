// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '知閲';

  @override
  String get navRecommend => 'おすすめ';

  @override
  String get navSearch => '検索';

  @override
  String get navBookshelf => '本棚';

  @override
  String get navMe => 'マイページ';

  @override
  String get navWorkspace => 'ワークスペース';

  @override
  String get feedFollowing => 'フォロー';

  @override
  String get feedRecommend => 'おすすめ';

  @override
  String get feedHot => '人気';

  @override
  String get feedStory => 'ストーリー';

  @override
  String get feedFollowingChoice => 'おすすめ';

  @override
  String get feedFollowingLatest => '最新';

  @override
  String get feedFollowingIdeas => 'アイデア';

  @override
  String get feedEmptyFollowing => 'フォロー中の新しいコンテンツはありません';

  @override
  String get feedEmptyHot => '表示できるホットランキングがありません';

  @override
  String get feedEmptyRecommend => '表示できるおすすめコンテンツがありません';

  @override
  String get feedNextLoadFailed => '追加読み込みに失敗しました。タップして再試行';

  @override
  String get feedAllShown => 'すべてのコンテンツを表示しました';

  @override
  String get feedLoadMore => '下にスクロールしてさらに読み込む';

  @override
  String get feedFollowingPeople => 'フォロー中';

  @override
  String feedViewPersonRecent(String name) {
    return '$name の最近のコンテンツを見る';
  }

  @override
  String get feedDiscoverFriends => '友達を見つける';

  @override
  String get feedFollowingSemantic => 'フォロータブ';

  @override
  String get feedSaltServiceFallback => '塩選からあなたへのおすすめ';

  @override
  String feedPersonRecentTitle(String name) {
    return '$name の最近のアクティビティ';
  }

  @override
  String get feedPersonRecentEmpty => '公開された最近のコンテンツはありません';

  @override
  String get storyCategoriesTitle => 'カテゴリ';

  @override
  String get storySearch => 'ストーリーを検索';

  @override
  String get storyLoadFailed => 'ストーリーカテゴリを読み込めません';

  @override
  String get storyEmptyCategories => 'ストーリーカテゴリはまだありません';

  @override
  String get storyBrowseByGenre => 'ジャンルからストーリーを探す';

  @override
  String get storyFilterStories => 'ストーリーを絞り込む';

  @override
  String get storyFeaturedCategories => 'おすすめカテゴリ';

  @override
  String get storyQuickFilter => 'クイックフィルター';

  @override
  String get storySort => '並べ替え';

  @override
  String get storyAll => 'すべて';

  @override
  String get storyCategory => 'カテゴリ';

  @override
  String get storyTabStories => 'ストーリー';

  @override
  String get storyTabBooks => '電子書籍';

  @override
  String get storyTabAssessments => 'レビュー';

  @override
  String get storyLong => '長編';

  @override
  String get storyShort => '短編';

  @override
  String get storyAudioBook => 'オーディオブック';

  @override
  String get storyFilter => '絞り込み';

  @override
  String get storySortHot => '人気順';

  @override
  String get storySortGood => '高評価';

  @override
  String get storySortNew => '新着';

  @override
  String get storyAllCategories => 'すべてのカテゴリ';

  @override
  String get storyMaxTags => '最大5つのタグを選択';

  @override
  String get storyNoCategories => 'カテゴリがありません';

  @override
  String get storyReset => 'リセット';

  @override
  String get storyConfirm => '確認';

  @override
  String get storyViewAll => 'すべて見る';

  @override
  String get storyEmptyCondition => '条件に一致するコンテンツはありません';

  @override
  String get storyCategoryFallback => 'ストーリーカテゴリ';

  @override
  String get storyEmptyCategory => 'このカテゴリにストーリーはありません';

  @override
  String get storyLongTitle => '長編ストーリー';

  @override
  String get storyEmptyLong => '長編ストーリーはまだありません';

  @override
  String storyLikeCount(String count) {
    return 'いいね $count 件';
  }

  @override
  String get storyOngoing => '連載中';

  @override
  String get storyFinished => '完結';

  @override
  String get storyFree => '無料';

  @override
  String get storyVip => 'VIP';

  @override
  String get storyVipDiscount => 'VIP割引';

  @override
  String get storyType => '種類';

  @override
  String get storyStatus => '状態';

  @override
  String get storyRights => '権利';

  @override
  String get storySectionHotTags => '人気タグ';

  @override
  String get storySectionGenre => 'ジャンル';

  @override
  String get storySectionCharacters => '登場人物';

  @override
  String get storySectionPlot => 'プロット';

  @override
  String get storySectionMood => '雰囲気';

  @override
  String get storySectionSetting => '舞台';

  @override
  String get storyTypeAssessment => 'レビュー';

  @override
  String get storyMaxSelection => '最大5つのタグを選択';

  @override
  String get saltContinueReading => '続きを読む';

  @override
  String get saltStartReading => '読み始める';

  @override
  String get saltAdded => '追加済み';

  @override
  String get saltAddToBookshelf => '本棚に追加';

  @override
  String get saltChapterOrder => '章の順序';

  @override
  String get saltAscending => '昇順';

  @override
  String get saltDescending => '降順';

  @override
  String get saltChapter => '章';

  @override
  String get saltCatalogTitle => '目次';

  @override
  String saltChapterCount(int count) {
    return '全 $count 章';
  }

  @override
  String get saltChapterDirectory => '章一覧';

  @override
  String saltProcessing(int index, int total, String title) {
    return '処理中 $index/$total · $title';
  }

  @override
  String get saltSelectAll => 'すべて選択';

  @override
  String get saltCancelSelectAll => 'すべて解除';

  @override
  String saltSelectedCount(int selected, int total) {
    return '選択済み $selected/$total';
  }

  @override
  String get saltDownloadingChapters => '章をダウンロード中';

  @override
  String saltExportChapters(String format, int count) {
    return '$format をエクスポート · $count 章';
  }

  @override
  String get saltDirectoryLoadFailed => '章を読み込めません';

  @override
  String get saltNetworkRetry => 'ネットワークを確認して再試行してください';

  @override
  String get saltDecodeFailed => '章を解析できませんでした。もう一度お試しください。';

  @override
  String get saltDecodeParamsMissing => '章のレスポンスに必要な解析パラメータがありません。もう一度お試しください。';

  @override
  String get saltDirectoryEmpty => 'この目次に章はありません';

  @override
  String get saltCached => 'キャッシュ済み';

  @override
  String get saltCommentsEmpty => 'コメントはまだありません';

  @override
  String get saltBulletCommentsEmpty => 'インラインコメントはまだありません';

  @override
  String get saltReaderTopBar => 'リーダー上部バー';

  @override
  String get saltReaderBottomBar => 'リーダー下部バー';

  @override
  String get saltReadingTitle => '塩選リーダー';

  @override
  String get saltMore => 'その他';

  @override
  String get saltSettingsTitle => '読書設定';

  @override
  String get saltVerticalScroll => '上下スクロール';

  @override
  String get saltHorizontalPage => '左右ページ送り';

  @override
  String get saltFontSize => '文字サイズ';

  @override
  String get saltLineSpacing => '行間';

  @override
  String get saltParagraphSpacing => '段落間隔';

  @override
  String get saltHorizontalMargins => '左右の余白';

  @override
  String get saltApply => '適用';

  @override
  String get saltChapterInfo => '章の情報';

  @override
  String get saltAuthor => '著者';

  @override
  String get saltReadable => '読めます';

  @override
  String get saltLocked => '未解放';

  @override
  String get saltChapterLocked => '章がロックされています';

  @override
  String get saltChapterReadable => '章を読めます';

  @override
  String saltSectionLabel(int index) {
    return '第 $index 章';
  }

  @override
  String saltSectionProgress(int index, int count) {
    return '第 $index/$count 章';
  }

  @override
  String saltLikes(String count) {
    return 'いいね $count 件';
  }

  @override
  String saltComments(String count) {
    return 'コメント $count 件';
  }

  @override
  String get saltAudioAvailable => '音声あり';

  @override
  String get saltNoPermission => '現在のアカウントに閲覧権限がありません';

  @override
  String get saltReload => '再読み込み';

  @override
  String get saltContentUnavailable => '章の内容を利用できません';

  @override
  String get saltPreviousChapter => '前の章';

  @override
  String get saltNextChapter => '次の章';

  @override
  String get saltMetadataReady => '資料を取得済み';

  @override
  String get saltEntitlementPassed => '権利を確認済み';

  @override
  String get saltPayloadReady => 'ペイロードを取得済み';

  @override
  String get saltBodyShown => '本文を表示済み';

  @override
  String get saltWaitingBody => '本文の解析を待っています';

  @override
  String get saltPayloadChars => 'ペイロード文字';

  @override
  String get saltCodeChars => 'code 文字';

  @override
  String get saltChapterBodyShown => '章の本文を表示済み';

  @override
  String get saltReadyDetail => '章の資料、バインド済みペイロード、本文の準備が完了しました。';

  @override
  String get saltShelfTitle => '本棚';

  @override
  String get saltWorkFallback => '塩選作品';

  @override
  String get saltCategory => 'カテゴリ';

  @override
  String get saltKnowledgeColumn => '知識コラム';

  @override
  String get saltLocalShelfEmpty => 'ローカル本棚は空です';

  @override
  String get saltMoreActions => 'その他の操作';

  @override
  String get saltReadAloud => 'この章を読み上げる';

  @override
  String get saltStopReading => '読み上げを停止';

  @override
  String get saltReadAloudSubtitle => 'システム音声でこの章を読み上げます';

  @override
  String saltExportChapter(String format) {
    return 'この章を $format としてエクスポート';
  }

  @override
  String get saltExportTxt => 'TXT ファイルをエクスポート';

  @override
  String get saltExportDocx => 'DOCX ファイルをエクスポート';

  @override
  String saltReadingStarted(String title) {
    return '$title を読み上げ中';
  }

  @override
  String get saltSpeechUnavailable => 'システム音声を利用できません。音声パッケージをインストールしてください';

  @override
  String saltExportedTo(String location) {
    return '$location にエクスポートしました';
  }

  @override
  String saltExportedAs(String format, String location) {
    return '$format としてエクスポートしました：$location';
  }

  @override
  String get saltExportFailed => 'エクスポートに失敗しました。再試行してください';

  @override
  String get saltCloudShelfUnavailable => 'クラウド本棚を同期できません';

  @override
  String get saltAccountSyncFailed => 'アカウントの同期に失敗しました。後でもう一度お試しください';

  @override
  String get saltStoryHomeLoadFailed => 'Salt Select のホームを読み込めません';

  @override
  String get saltStoryEntry => '入口';

  @override
  String get saltStoryModuleMustSee => '必見';

  @override
  String get saltStoryModuleTodayRead => '今日の読書';

  @override
  String get saltStoryModuleEveryoneWatch => 'みんなが読んでいる';

  @override
  String get saltStoryModuleRecommended => 'おすすめ';

  @override
  String get saltStoryBoard => 'ストーリーランキング';

  @override
  String get saltStoryHotBoard => '人気ランキング';

  @override
  String get saltStoryReputationBoard => '評価ランキング';

  @override
  String get saltStoryNewBoard => '新刊ランキング';

  @override
  String get saltStoryLongBoard => '長編ランキング';

  @override
  String saltStoryBoardNumber(int index) {
    return 'ランキング $index';
  }

  @override
  String get saltPillOnShelf => '本棚に追加済み';

  @override
  String get saltPillLiked => 'いいね済み';

  @override
  String get saltBrandLong => '長編';

  @override
  String saltScore(String score) {
    return '評価 $score';
  }

  @override
  String saltUpdatedSections(int count) {
    return '$count 章を更新';
  }

  @override
  String saltFinishedWithCount(int count) {
    return '完結 · 全 $count 章';
  }

  @override
  String saltUpdatedTo(int index) {
    return '$index 章まで更新';
  }

  @override
  String get saltShelfLiked => 'いいねした作品';

  @override
  String get saltShelfComments => 'インラインコメント';

  @override
  String get saltShelfHistory => '履歴';

  @override
  String get saltShelfLists => 'リスト';

  @override
  String get answerLabel => '回答';

  @override
  String get drawerBrowse => '閲覧';

  @override
  String get drawerColumns => 'コラムのおすすめ';

  @override
  String get drawerTopicCategories => 'トピック分類';

  @override
  String get drawerHotTopics => '人気トピック';

  @override
  String get drawerHistory => '履歴';

  @override
  String get drawerMyContent => 'マイコンテンツ';

  @override
  String get drawerMessages => 'メッセージ';

  @override
  String get drawerCollections => 'お気に入り';

  @override
  String get drawerBookshelf => '本棚';

  @override
  String get drawerFindUsers => 'ユーザーを探す';

  @override
  String get drawerAccount => 'アカウント';

  @override
  String get drawerLoginOrAddAccount => 'ログインまたはアカウント追加';

  @override
  String get drawerAccountManagement => 'アカウント管理';

  @override
  String get drawerApp => 'アプリ';

  @override
  String get drawerSettings => '設定';

  @override
  String get drawerClose => 'サイドバーを閉じる';

  @override
  String get drawerOpen => 'サイドバーを開く';

  @override
  String drawerVersion(String version) {
    return '知閲 $version';
  }

  @override
  String get commonBack => '戻る';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonSave => '保存';

  @override
  String get commonReset => '初期設定に戻す';

  @override
  String get commonClear => 'クリア';

  @override
  String get commonDelete => '削除';

  @override
  String get commonDone => '完了';

  @override
  String get commonRetry => '再試行';

  @override
  String get commonSearch => '検索';

  @override
  String get commonSelect => '選択してください';

  @override
  String get commonLoading => '読み込み中…';

  @override
  String get commonMore => 'もっと見る';

  @override
  String get commonReply => '返信';

  @override
  String get commonPublish => '投稿';

  @override
  String get commonPublishing => '投稿中';

  @override
  String get commonFollow => 'フォロー';

  @override
  String get commonRefresh => '更新';

  @override
  String get commonEdit => '編集';

  @override
  String get commonShare => '共有';

  @override
  String get commonFailed => '読み込みに失敗しました。再試行してください。';

  @override
  String get commonNoMore => 'これ以上ありません';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsBackup => 'バックアップ';

  @override
  String get settingsAccount => 'アカウント';

  @override
  String get settingsLogs => 'ログ';

  @override
  String get settingsAboutSection => '情報';

  @override
  String get settingsUpdates => '更新';

  @override
  String get settingsData => 'データ';

  @override
  String get settingsAppearanceSubtitle => 'ダークモード、言語、表示';

  @override
  String get settingsPersonalizationSubtitle => 'ホーム、おすすめ、コンテンツ設定';

  @override
  String get settingsBackupSubtitle => 'WebDAV データ同期';

  @override
  String get settingsAccountSubtitle => 'セッションとログイン状態';

  @override
  String get settingsLogsSubtitle => '診断ログとトラブルシューティング';

  @override
  String get settingsAboutSubtitle => '初期設定とアプリ情報';

  @override
  String get settingsUpdatesSubtitle => '新しいバージョンを確認してインストール';

  @override
  String get settingsDataSubtitle => '履歴、キャッシュ、ストレージ';

  @override
  String get settingsHomeContent => 'ホームとコンテンツ';

  @override
  String get settingsStartupPage => '起動ページ';

  @override
  String get settingsRecommendation => 'おすすめの方式';

  @override
  String get settingsServer => 'サーバー';

  @override
  String get settingsLocal => 'ローカル';

  @override
  String get settingsHybrid => 'ハイブリッド';

  @override
  String get settingsDensity => 'コンテンツ密度';

  @override
  String get settingsComfortable => '標準';

  @override
  String get settingsCompact => 'コンパクト';

  @override
  String get settingsRefreshHome => 'ホームを再タップしたら更新';

  @override
  String get settingsRefreshHomeSubtitle => '選択中のホームを再タップすると先頭に戻って更新します';

  @override
  String get settingsShowImages => 'おすすめ画像を表示';

  @override
  String get settingsShowImagesSubtitle => 'オフにすると文字、作者、反応のみ表示します';

  @override
  String get settingsShowMetrics => '反応数を表示';

  @override
  String get settingsShowMetricsSubtitle => '賛成、保存、コメント、日付を表示します';

  @override
  String get settingsLocalBehavior => 'ローカルおすすめ履歴';

  @override
  String settingsLocalEvents(int count) {
    return 'この端末に $count 件の操作を記録';
  }

  @override
  String get settingsFeedOrder => 'ホームのセクション順';

  @override
  String get settingsFilterStats => 'コンテンツフィルター統計';

  @override
  String get settingsReadingDisplay => '読書と表示';

  @override
  String get settingsDarkMode => 'ダークモード';

  @override
  String get settingsDarkModeOnSubtitle => '暗い背景と低輝度のサーフェスを使用';

  @override
  String get settingsDarkModeOffSubtitle => '明るい背景とサーフェスを使用';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSubtitle => 'アプリの表示言語を選択';

  @override
  String get settingsTextSize => '本文の文字サイズ';

  @override
  String get settingsSmall => '小';

  @override
  String get settingsStandard => '標準';

  @override
  String get settingsLarge => '大';

  @override
  String get settingsFollowSystemTextScale => 'システムの文字サイズに従う';

  @override
  String get settingsFollowSystemTextScaleSubtitle => '本文サイズにシステムの表示サイズを反映';

  @override
  String get settingsReduceMotion => 'アニメーションを減らす';

  @override
  String get settingsReduceMotionSubtitle => 'ページやコンポーネントのアニメーションを減らす';

  @override
  String get settingsGlass => 'リキッドガラス効果';

  @override
  String get settingsGlassOnSubtitle => 'ガラスの反応と半透明レイヤーを維持';

  @override
  String get settingsGlassOffSubtitle => 'パフォーマンスモード：軽量なボタンとナビゲーションを使用';

  @override
  String get settingsPersonalization => 'カスタマイズ';

  @override
  String get settingsFocusSearch => '検索ページでキーボードを自動表示';

  @override
  String get settingsFocusSearchOn => '検索欄に自動フォーカス';

  @override
  String get settingsFocusSearchOff => '検索欄を手動でタップ';

  @override
  String get settingsImagesStorage => '画像とストレージ';

  @override
  String get settingsKeepHistory => '閲覧履歴を保存';

  @override
  String settingsKeepHistoryOn(int count) {
    return 'この端末のみ · $count 件';
  }

  @override
  String get settingsKeepHistoryOff => '開いたコンテンツを端末に保存しない';

  @override
  String get settingsPrefetchImages => '一覧画像を先読み';

  @override
  String get settingsPrefetchImagesSubtitle => '表示前にアバターと本文画像を読み込む';

  @override
  String get settingsImageCache => '画像キャッシュ容量';

  @override
  String get settingsEconomy => '節約';

  @override
  String get settingsRoomy => '多め';

  @override
  String get settingsNoCacheImages => 'キャッシュ画像はありません';

  @override
  String settingsCachedImages(int count) {
    return 'キャッシュ画像を $count 枚削除しました';
  }

  @override
  String get settingsPrivacyData => 'プライバシーとデータ';

  @override
  String get settingsKeepSearch => '検索履歴を保存';

  @override
  String settingsKeepSearchOn(int count) {
    return 'この端末のみ · $count 件';
  }

  @override
  String get settingsKeepSearchOff => '新しい検索を端末に保存しない';

  @override
  String get settingsShowHot => '人気検索を表示';

  @override
  String get settingsShowHotOn => '検索ページに知乎の人気検索を表示';

  @override
  String get settingsShowHotOff => '人気検索を読み込まない';

  @override
  String get settingsWebDav => 'WebDAV 同期';

  @override
  String get settingsAccountSessions => 'アカウントと複数端末ログイン';

  @override
  String get settingsSignOut => 'ログアウト';

  @override
  String get settingsOther => 'その他';

  @override
  String get settingsDiagnostics => '診断ログ';

  @override
  String get settingsUpdate => 'ソフトウェア更新';

  @override
  String get settingsRestoreDefaults => '設定を初期化';

  @override
  String get settingsAbout => '知閲について';

  @override
  String settingsVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get settingsFeedOrderSubtitle => '右端を長押ししてドラッグすると、ホームのタブとスワイプ順が同期します。';

  @override
  String get settingsRestoreDefaultsMessage => 'すべての設定を初期化します。ログアウトはしません。';

  @override
  String get settingsRestored => '設定を初期化しました';

  @override
  String get settingsSignOutMessage => 'この端末に保存されたログイン情報を削除します。';

  @override
  String get settingsSignedOut => 'ログアウトしました';

  @override
  String get settingsClearBrowsing => '閲覧履歴を削除';

  @override
  String get settingsNoBrowsingHistory => '閲覧履歴はありません';

  @override
  String settingsDeleteBrowsing(int count) {
    return '端末内の $count 件を削除';
  }

  @override
  String get settingsClearImageCache => '画像キャッシュを削除';

  @override
  String get settingsClearOfflineChapters => 'オフライン章を削除';

  @override
  String get settingsClearOfflineChaptersSubtitle => '読書やダウンロード時に保存した塩選本文を削除';

  @override
  String get settingsClearSearch => '検索履歴を削除';

  @override
  String get settingsNoSearchHistory => '検索履歴はありません';

  @override
  String settingsDeleteSearch(int count) {
    return '端末内の $count 件を削除';
  }

  @override
  String get settingsWebDavConfigured => '設定済み · 検索、履歴、オフライン小説、回答キャッシュ';

  @override
  String get settingsWebDavSubtitle => '検索履歴、閲覧履歴、オフライン小説、回答キャッシュを同期';

  @override
  String get settingsAccountSessionsSubtitle => 'QR ログイン、アカウント枠の保存、すばやい切り替え';

  @override
  String get settingsSignOutSubtitle => 'この端末のログイン情報を削除';

  @override
  String get settingsDiagnosticsOn => '有効 · ネットワーク・パフォーマンスログを管理・出力';

  @override
  String get settingsDiagnosticsOff => 'API エラー、読み込み失敗、動作の重さを確認';

  @override
  String get settingsUpdateSubtitle => '安全に確認、ダウンロード、インストール';

  @override
  String get settingsRestoreDefaultsSubtitle => 'アカウントはログアウトされません';

  @override
  String get searchTitle => '検索';

  @override
  String get searchPlaceholder => '知乎のコンテンツを検索';

  @override
  String get searchFilter => '絞り込み';

  @override
  String get searchGeneral => '総合';

  @override
  String get searchRealtime => 'リアルタイム';

  @override
  String get searchUsers => 'ユーザー';

  @override
  String get searchStories => '小説';

  @override
  String get searchArticles => '論文';

  @override
  String get searchVideos => '動画';

  @override
  String get searchTopics => 'トピック';

  @override
  String get searchColumns => 'コラム';

  @override
  String get searchKnowledge => 'ナレッジ';

  @override
  String get searchIdeas => 'アイデア';

  @override
  String get searchCircles => 'サークル';

  @override
  String get searchPodcasts => 'ポッドキャスト';

  @override
  String get searchHot => '人気検索';

  @override
  String get searchHistory => '検索履歴';

  @override
  String get searchUnavailableTitle => '一時的に利用できません';

  @override
  String get searchUnavailableMessage => '匿名コンテンツは一時的に利用できません。後でもう一度お試しください。';

  @override
  String get searchNoResults => '関連するコンテンツが見つかりません';

  @override
  String get searchScope => '検索範囲';

  @override
  String get searchMoreScopes => '左右にスワイプして続きを表示';

  @override
  String get searchOverview => '検索の概要';

  @override
  String get searchStartHint => 'キーワードを入力して検索';

  @override
  String get searchCurrentScope => '現在の範囲';

  @override
  String get searchActiveFilters => '有効な絞り込み';

  @override
  String get searchFilterType => 'コンテンツ種別';

  @override
  String get searchFilterSort => '並べ替え';

  @override
  String get searchFilterTime => '期間';

  @override
  String get searchFilterAnyType => 'すべての種類';

  @override
  String get searchFilterAnswers => '回答のみ';

  @override
  String get searchFilterArticles => '記事のみ';

  @override
  String get searchFilterVideos => '動画のみ';

  @override
  String get searchSortRelevance => '関連度順';

  @override
  String get searchSortMostUpvoted => '賛成数順';

  @override
  String get searchSortNewest => '新しい順';

  @override
  String get searchTimeAny => '期間指定なし';

  @override
  String get searchTimeDay => '1日以内';

  @override
  String get searchTimeWeek => '1週間以内';

  @override
  String get searchTimeMonth => '1か月以内';

  @override
  String get searchTimeThreeMonths => '3か月以内';

  @override
  String get searchTimeHalfYear => '半年以内';

  @override
  String get searchTimeYear => '1年以内';

  @override
  String get commentAll => 'すべてのコメント';

  @override
  String commentCount(String count) {
    return 'コメント $count 件';
  }

  @override
  String get commentDefault => 'デフォルト';

  @override
  String get commentLatest => '最新';

  @override
  String get commentInputPlaceholder => '思いやりを持って交流しましょう';

  @override
  String get commentReply => 'このコメントに返信';

  @override
  String get commentPublishReply => '返信を投稿';

  @override
  String get commentPublishComment => 'コメントを投稿';

  @override
  String commentReplyTo(String name) {
    return '@$name に返信';
  }

  @override
  String get commentMention => 'ユーザーをメンション';

  @override
  String get commentCollapse => 'エディターを閉じる';

  @override
  String get commentExpand => 'エディターを展開';

  @override
  String get commentImage => '画像コメント';

  @override
  String get loginTitle => 'ログイン';

  @override
  String get loginAccount => 'アカウント';

  @override
  String get loginPhone => '電話番号';

  @override
  String get loginPassword => 'パスワード';

  @override
  String get loginCode => '認証コード';

  @override
  String get loginContinue => '同意して続ける';

  @override
  String get loginCancel => '今はしない';

  @override
  String get loginScanSuccess => 'QRログインに成功しました';

  @override
  String get detailReadAnswer => '回答を書く';

  @override
  String get detailRefreshAnswers => '回答を更新';

  @override
  String get detailSearchBody => '本文を検索';

  @override
  String get detailReadAloud => '本文を読み上げる';

  @override
  String get detailExportTxt => 'TXT として書き出す';

  @override
  String get detailExportMarkdown => 'Markdown として書き出す';

  @override
  String get detailExportHtml => 'HTML として書き出す';

  @override
  String get commonExitApp => 'もう一度戻ると終了します';

  @override
  String get commonEmoji => '絵文字';

  @override
  String get commonRemove => '削除';

  @override
  String get commonOpenZhihu => '知乎の確認を開く';

  @override
  String get commonExpired => '期限切れ';

  @override
  String get commonReport => '報告';

  @override
  String get commonUntitledContent => '無題のコンテンツ';

  @override
  String get commonUntitledObject => '無題の項目';

  @override
  String get commonAuthorProfile => '作者のプロフィールを表示';

  @override
  String get commonZhihuUser => '知乎ユーザー';

  @override
  String get commonLike => '賛成';

  @override
  String get commonUnlike => '賛成を取り消す';

  @override
  String get commonDislike => '反対';

  @override
  String get commonDeleteComment => 'コメントを削除';

  @override
  String get commonCommentActionFailed => 'コメント操作に失敗しました。後でもう一度お試しください。';

  @override
  String get commonOpenLink => 'リンクを開く';

  @override
  String commonReplyCount(String count) {
    return '返信 $count 件';
  }

  @override
  String commonViewAllReplies(String count) {
    return '返信をすべて表示（$count 件）';
  }

  @override
  String get drawerExpired => '期限切れ';

  @override
  String get loginHeader => '知乎にログイン';

  @override
  String get loginQrSubtitle => '知乎アプリでスキャンしてログイン';

  @override
  String get loginPasswordSubtitle => 'アカウントとパスワードで安全にログイン';

  @override
  String get loginPhoneSubtitle => '電話番号ですばやくログイン';

  @override
  String get loginProgressPassword => 'ログインの進行状況：アカウントとパスワード';

  @override
  String get loginProgressCode => 'ログインの進行状況：認証コード';

  @override
  String get loginProgressPhone => 'ログインの進行状況：電話番号';

  @override
  String get loginAgreementTitle => 'ログイン前に確認';

  @override
  String get loginAgreementMessage => '知乎ユーザー規約とプライバシーポリシーを読み、同意してから続行してください。';

  @override
  String get loginQrLoading => 'QRコードを取得中';

  @override
  String get loginQrInvalid => '知乎から有効なQRコードが返されませんでした';

  @override
  String get loginQrScanHint => '知乎アプリを開いてスキャンしてください';

  @override
  String loginQrFetchFailed(String error) {
    return 'QRコードを取得できませんでした：$error';
  }

  @override
  String get loginQrExpired => 'QRコードの期限が切れました。更新してください。';

  @override
  String get loginQrRiskControl => '知乎ウェブで安全確認を完了してから、QRコードを更新してください。';

  @override
  String get loginQrConfirm => '知乎アプリでログインを確認してください';

  @override
  String get loginVerifying => 'ログインを確認中';

  @override
  String get loginSuccess => 'ログインしました';

  @override
  String get loginQrLabel => '知乎ログインQRコード';

  @override
  String get loginRefreshQr => 'QRコードを更新';

  @override
  String get loginQrHint =>
      'QRコードの有効期限内に別の端末でログインを確認してください。成功後は現在のアカウント枠を保持します。';

  @override
  String get feedbackNotInterested => '興味がありません';

  @override
  String get feedbackReduceRecommendation => 'このようなおすすめを減らす';

  @override
  String get feedbackTitle => 'このような内容を減らす';

  @override
  String get feedbackReduced => 'このようなおすすめを減らしました';

  @override
  String get feedbackInvalidReport => '報告先アドレスが無効です';

  @override
  String get feedbackMissingAction => 'このフィードバックには実行可能な操作がありません';

  @override
  String get feedbackLoading => 'フィードバック項目をさらに読み込み中…';

  @override
  String get feedbackReload => '再読み込み';

  @override
  String get accountSessionCheckTitle => 'ログイン状態を確認';

  @override
  String get accountSessionCheckMessage =>
      '知乎からアカウントセッションの異常が返されました。現在のログイン情報はこの端末に残っています。削除しますか？';

  @override
  String get accountSessionCheckDetails =>
      '削除後も「設定 > アカウントと複数端末ログイン」から直近のセッションを復元できます。完全削除には再確認が必要です。';

  @override
  String get accountSessionClearKeepBackup => '削除して復元用コピーを残す';

  @override
  String get accountSessionKeep => 'ログイン状態を保持';

  @override
  String get settingsDisableSearchHistoryTitle => '検索履歴をオフにしますか？';

  @override
  String get settingsDisableSearchHistoryMessage =>
      'オフにすると、この端末に保存された検索履歴も削除されます。';

  @override
  String get settingsDisableAndClear => 'オフにして削除';

  @override
  String get settingsNoSearchHistoryMessage => '検索履歴はありません';

  @override
  String get settingsClearSearchHistoryTitle => '検索履歴を削除しますか？';

  @override
  String get settingsClearSearchHistoryMessage => 'この端末に保存された検索キーワードだけを削除します。';

  @override
  String get settingsSearchHistoryCleared => '検索履歴を削除しました';

  @override
  String get settingsDisableBrowsingHistoryTitle => '閲覧履歴をオフにしますか？';

  @override
  String get settingsDisableBrowsingHistoryMessage =>
      'オフにすると、この端末に保存された閲覧履歴も削除されます。';

  @override
  String get settingsNoBrowsingHistoryMessage => '閲覧履歴はありません';

  @override
  String get settingsClearBrowsingHistoryTitle => '閲覧履歴を削除しますか？';

  @override
  String get settingsClearBrowsingHistoryMessage =>
      'この端末に保存された閲覧コンテンツのインデックスだけを削除します。';

  @override
  String get settingsBrowsingHistoryCleared => '閲覧履歴を削除しました';

  @override
  String get settingsClearOfflineTitle => 'オフライン章を削除しますか？';

  @override
  String get settingsClearOfflineMessage =>
      '保存済みの塩選本文を削除します。次回の読書や書き出し時に再ダウンロードが必要です。';

  @override
  String get settingsClearOfflineAction => '削除';

  @override
  String settingsOfflineCleared(int count) {
    return 'オフライン章を $count 件削除しました';
  }

  @override
  String get settingsOfflineClearFailed => 'オフライン章を削除できませんでした。再試行してください。';

  @override
  String settingsCacheSummary(int count, String size) {
    return '画像 $count 枚 · $size MB';
  }

  @override
  String get commentEmoji => '絵文字';

  @override
  String get commentRemoveSticker => 'ステッカーを削除';

  @override
  String get commentSelectedImage => '選択したコメント画像';

  @override
  String get commentUploadingImage => '画像をアップロード中…';

  @override
  String get commentImageAdded => '画像を追加しました';

  @override
  String get commentRemoveImage => '画像を削除';

  @override
  String get commentUsernameRequired => 'メンションするユーザー名を入力してください';

  @override
  String commentMentioned(String name) {
    return '$name をメンションしました';
  }

  @override
  String get commentLoadingGift => 'ギフトを読み込み中';

  @override
  String get commentNoGifts => '利用できるギフトはありません';

  @override
  String get commentImageAddedPending => '画像を追加しました。ログイン後に投稿できます。';

  @override
  String get commentSignInRequired => '投稿するにはログインしてください';

  @override
  String get commentUploadSignInRequired => '画像を投稿するにはログインしてください';

  @override
  String get commentImageUploadNoUrl => '画像アップロードからアドレスが返されませんでした';

  @override
  String commentImagesCount(int count) {
    return 'コメント画像 $count 枚';
  }

  @override
  String get commentViewImage => 'コメント画像を見る';

  @override
  String get commentCloseImage => '画像を閉じる';

  @override
  String get commentSaveImage => '写真に保存';

  @override
  String commentSavedTo(String location) {
    return '$location に保存しました';
  }

  @override
  String get commentSaveFailed => '画像を保存できませんでした。後でもう一度お試しください';

  @override
  String get commentReportUnavailable => '報告機能はまだ利用できません';

  @override
  String get commentNoText => '表示できる本文がありません';

  @override
  String get commentAuthorBadge => '作者';

  @override
  String get commentQuestionAuthor => '質問者';

  @override
  String commentAuthorSemantics(String name) {
    return 'コメント作成者 $name';
  }

  @override
  String get feedHotBadge => '人気';

  @override
  String metricVoteup(String count) {
    return '賛成 $count';
  }

  @override
  String metricFavorite(String count) {
    return '保存 $count';
  }

  @override
  String metricComment(String count) {
    return 'コメント $count';
  }

  @override
  String metricThanks(String count) {
    return '感謝 $count';
  }

  @override
  String metricViews(String count) {
    return '閲覧 $count';
  }

  @override
  String get metricThanked => '回答に感謝済み';

  @override
  String get metricFavorited => '回答を保存済み';

  @override
  String metricFollowers(String count) {
    return 'フォロワー $count 人';
  }

  @override
  String metricAnswers(String count) {
    return '回答 $count 件';
  }

  @override
  String metricArticles(String count) {
    return '記事 $count 件';
  }

  @override
  String metricItems(String count) {
    return 'コンテンツ $count 件';
  }

  @override
  String get contentTypeAnswer => '回答';

  @override
  String get contentTypeArticle => '記事';

  @override
  String get contentTypePeople => 'ユーザー';

  @override
  String get contentTypeQuestion => '質問';

  @override
  String get contentTypeColumn => 'コラム';

  @override
  String get contentTypeTopic => 'トピック';

  @override
  String get contentTypeIdea => 'アイデア';

  @override
  String get contentTypeComment => 'コメント';

  @override
  String accountSwitchedTo(String name) {
    return '$name に切り替えました';
  }

  @override
  String get accountSessionRestoreFailed =>
      'アカウントセッションの確認に失敗しました。以前のログイン状態を復元しました。';

  @override
  String get collectionsLoginRequired => '知乎にログインするとコレクションを表示できます';

  @override
  String get collectionsTitle => 'マイコレクション';

  @override
  String get collectionTitle => 'コレクション';

  @override
  String get collectionEmpty => 'このコレクションにはまだコンテンツがありません';

  @override
  String get collectionsEmpty => '作成または保存したコンテンツはありません';

  @override
  String get loginPasswordRequired => 'パスワードを入力してください';

  @override
  String get loginQrSaveFailed =>
      'QRログインに成功しましたが、アカウント枠を保存できませんでした。後でもう一度お試しください。';

  @override
  String get loginHumanVerification => '先に本人確認を完了してください';

  @override
  String get loginCodeSendFailed => '認証コードを送信できませんでした。後でもう一度お試しください。';

  @override
  String get loginFailedNetwork => 'ログインに失敗しました。ネットワークを確認して再試行してください。';

  @override
  String get loginFailedCredentials => 'ログインに失敗しました。アカウントとパスワードを確認して再試行してください。';

  @override
  String get loginGetCode => '認証コードを取得';

  @override
  String get loginContinueSignIn => 'ログインを続ける';

  @override
  String get loginPasswordSignIn => 'パスワードでログイン';

  @override
  String get loginPhoneSignIn => '電話番号でログイン';

  @override
  String get loginQrSignIn => 'QRコードでログイン';

  @override
  String get loginAccountAppeal => 'アカウント申請';

  @override
  String get loginAccountAppealHint => '問題がありますか？アカウント申請';

  @override
  String get loginPhonePlaceholder => '国番号／地域番号 + 電話番号';

  @override
  String get loginAccountPlaceholder => '電話番号／メールアドレス';

  @override
  String get loginPasswordPlaceholder => 'パスワード';

  @override
  String get loginCodePlaceholder => '6桁の認証コードを入力';

  @override
  String loginCodeSent(String phone) {
    return '認証コードを $phone に送信しました';
  }

  @override
  String get loginChangePhone => '電話番号を変更';

  @override
  String get loginNoCode => '届きませんでしたか？';

  @override
  String loginResendAfter(int seconds) {
    return '$seconds秒後に再試行';
  }

  @override
  String get loginAgree => '同意';

  @override
  String get loginUserAgreement => '知乎ユーザー規約';

  @override
  String get loginPrivacyPolicy => 'とプライバシーポリシー';

  @override
  String get commonSelected => '、選択済み';

  @override
  String get searchSuggestion => '検索候補';

  @override
  String searchSuggestionFor(String query) {
    return '検索候補 $query';
  }

  @override
  String searchSearching(String query) {
    return '「$query」を検索中';
  }

  @override
  String get searchDesktopHint => '結果一覧をスクロールして追加読み込みし、カードを選択すると詳細を表示します。';

  @override
  String get searchRelated => '関連検索';

  @override
  String get searchRecentContent => '最近のコンテンツ';

  @override
  String get searchContinue => '検索を続ける';

  @override
  String get searchUntitledNovel => 'タイトル未設定の小説';

  @override
  String get searchUntitledVideo => 'タイトル未設定の動画';

  @override
  String searchMetricFollows(String count) {
    return 'フォロー $count';
  }

  @override
  String searchMetricQuestions(String count) {
    return '$count 件の質問';
  }

  @override
  String searchMetricMembers(String count) {
    return '$count 人のメンバー';
  }

  @override
  String searchMetricDiscussions(String count) {
    return '$count 件の議論';
  }

  @override
  String searchMetricParticipants(String count) {
    return '$count 人が参加';
  }

  @override
  String searchMetricLiveContent(String count) {
    return '$count 件のライブコンテンツ';
  }

  @override
  String searchMetricPlayCount(String count) {
    return '$count 回再生';
  }

  @override
  String searchHotScoreWan(String value) {
    return '$value 万';
  }

  @override
  String get userTitle => 'ユーザー';

  @override
  String get userProfileTitle => 'ユーザープロフィール';

  @override
  String get userFindTitle => 'ユーザーを探す';

  @override
  String get userFindSubtitle => 'プロフィールリンクのユーザートークンを入力して公開プロフィールとコンテンツを表示';

  @override
  String get userIdHint => 'ユーザー ID';

  @override
  String get userViewProfile => 'ユーザープロフィールを見る';

  @override
  String get userContentRelations => 'コンテンツと関係';

  @override
  String get userEmpty => 'ユーザーはいません';

  @override
  String get userSignInToFollow => 'ログインしてユーザーをフォローしてください';

  @override
  String get userFollowed => 'フォロー中';

  @override
  String get userFollow => '+ フォロー';

  @override
  String userSearchHint(String name) {
    return '$name の投稿を検索';
  }

  @override
  String userSearchPrompt(String name) {
    return '$name の回答、記事、アイデアを検索';
  }

  @override
  String get userNoResults => '一致するコンテンツがありません';

  @override
  String get userLoadFailed => 'ユーザープロフィールを開けません';

  @override
  String get userInfo => 'ユーザー情報';

  @override
  String get userFollowers => 'フォロワー';

  @override
  String get userFollowingPeople => 'フォロー中のユーザー';

  @override
  String get userAnswers => 'ユーザーの回答';

  @override
  String get userArticles => 'ユーザーの記事';

  @override
  String get userCreatedArticles => 'ユーザーが作成した記事';

  @override
  String get userContributedArticles => '投稿した記事';

  @override
  String get userColumns => 'ユーザーのコラム';

  @override
  String get userFollowingColumns => 'フォロー中のコラム';

  @override
  String get userFollowingQuestions => 'フォロー中の質問';

  @override
  String get userFollowingCollections => 'フォロー中のコレクション';

  @override
  String get userFollowingTopics => 'フォロー中のトピック';

  @override
  String get userIdRequired => 'ユーザー ID を入力してください';

  @override
  String get sessionTitle => 'アカウント';

  @override
  String get sessionSignInZhihu => '知乎にログイン';

  @override
  String get sessionPhoneLogin => '電話番号でログイン';

  @override
  String get sessionWebLogin => 'ウェブログイン';

  @override
  String get sessionSaved => 'ログイン情報を保存しました';

  @override
  String get sessionCleared => 'ログイン情報を削除しました';

  @override
  String get sessionImport => 'ログイン情報をインポート';

  @override
  String get sessionShowSensitive => '一時的に機密値を表示';

  @override
  String get sessionHideSensitive => '機密値を再び隠す';

  @override
  String get sessionAdvanced => '詳細設定';

  @override
  String get sessionOptionalCookie => 'Cookie（任意）';

  @override
  String get sessionOptionalMsId => 'X-MS-ID（任意）';

  @override
  String get sessionManualZse => '手動 X-Zse-96';

  @override
  String get sessionSignTarget => '署名対象';

  @override
  String get sessionOtherHeaders => 'その他の Header';

  @override
  String get sessionSaving => '保存中…';

  @override
  String get sessionSave => '保存';

  @override
  String get sessionClear => 'ログイン情報を削除';

  @override
  String get contentTypeContent => 'コンテンツ';

  @override
  String get userProfileSearchContent => 'このユーザーのコンテンツを検索';

  @override
  String get userProfileCopyLink => 'プロフィールリンクをコピー';

  @override
  String get userProfileHomeTab => 'ホーム';

  @override
  String get userProfileCreationsTab => '創作';

  @override
  String get userProfileActivitiesTab => 'アクティビティ';

  @override
  String get userProfileVoteupsTab => '賛同';

  @override
  String get userProfileFollowersList => 'フォロワー';

  @override
  String get userProfileFollowingList => 'フォロー中';

  @override
  String get userProfileLoginRequired => 'この機能を使うにはログインしてください';

  @override
  String get userProfileUnfollowTitle => 'フォローを解除しますか？';

  @override
  String userProfileUnfollowMessage(String name) {
    return '$nameのフォローを解除します';
  }

  @override
  String get userProfileUnfollowAction => 'フォローを解除';

  @override
  String get userProfileLinkCopied => 'プロフィールリンクをコピーしました';

  @override
  String userProfileIpLocation(String location) {
    return 'IP所在地：$location';
  }

  @override
  String get userProfileFollowers => 'フォロワー';

  @override
  String get userProfileFollowing => 'フォロー';

  @override
  String get userProfileUserAnswers => 'ユーザーの回答';

  @override
  String get userProfileUserArticles => 'ユーザーの記事';

  @override
  String get userProfileCreatedArticles => '作成した記事';

  @override
  String get userProfileUserCreatedArticles => 'ユーザーが作成した記事';

  @override
  String get userProfileContributedArticles => '投稿した記事';

  @override
  String get userProfileUserContributedArticles => 'ユーザーが投稿した記事';

  @override
  String get userProfileCreatedColumns => '作成したコラム';

  @override
  String get userProfileUserColumns => 'ユーザーのコラム';

  @override
  String get userProfileFollowingColumns => 'フォロー中のコラム';

  @override
  String get userProfileFollowingQuestions => 'フォロー中の質問';

  @override
  String get userProfileFollowingCollections => 'フォロー中のコレクション';

  @override
  String get userProfileFollowingTopics => 'フォロー中のトピック';

  @override
  String get userProfileReceivedUpvotes => '賛同された数';

  @override
  String get userProfileReceivedThanks => '感謝された数';

  @override
  String get userProfileReceivedFavorites => '保存された数';

  @override
  String get userProfilePersonalInfo => 'プロフィール情報';

  @override
  String get userProfileAchievements => '実績';

  @override
  String get userProfilePublicCreations => '公開した創作';

  @override
  String get userProfileFollowingAndCollections => 'フォローとコレクション';

  @override
  String get userProfileFollowingHidden => 'このユーザーはフォロー一覧を非公開にしています';

  @override
  String get userProfileFollowedYou => 'あなたをフォロー中';

  @override
  String get userProfileMutualFollow => '相互フォロー';

  @override
  String get userProfileMessage => 'メッセージ';

  @override
  String get userProfileNoPublicContent => '公開コンテンツはまだありません';

  @override
  String get webdavTitle => 'WebDAV同期';

  @override
  String get webdavIntroTitle => '端末間でローカルコンテンツを同期';

  @override
  String get webdavIntroMessage =>
      '検索履歴、閲覧履歴、塩選のオフライン章／本棚、回答キャッシュのみを同期します。ログイン情報、Cookie、端末識別子、この設定はアップロードしません。';

  @override
  String get webdavConnectionSettings => '接続設定';

  @override
  String get webdavProviderType => 'サービスの種類';

  @override
  String get webdavProviderGeneric => '汎用 WebDAV';

  @override
  String get webdavProviderGoogle => 'Google Drive（WebDAVゲートウェイ）';

  @override
  String get webdavProviderOneDrive => 'Microsoft OneDrive（WebDAV）';

  @override
  String get webdavProviderGenericDescription =>
      'WebDAV対応のクラウドドライブ、NAS、自前サービス向けです。';

  @override
  String get webdavProviderGoogleDescription =>
      'Google DriveはネイティブWebDAVを提供していません。Google Driveに接続するWebDAVゲートウェイのアドレスを入力してください。';

  @override
  String get webdavProviderOneDriveDescription =>
      'OneDriveのWebDAV互換エンドポイントを入力してください。一部のアカウントやサービスでは旧式の入口が制限されています。';

  @override
  String get webdavProviderGenericHint => 'https://dav.example.com/';

  @override
  String get webdavProviderGoogleHint => 'https://gateway.example.com/dav/';

  @override
  String get webdavProviderOneDriveHint => 'https://d.docs.live.net/<CID>/';

  @override
  String get webdavEndpoint => 'WebDAVアドレス';

  @override
  String get webdavHttpsHint => 'HTTPSのみ。URLにパスワードを入力しないでください';

  @override
  String get webdavRemoteDirectory => 'リモートディレクトリ';

  @override
  String get webdavRemoteDirectoryHint =>
      'v1、answers、chaptersのサブディレクトリを自動作成します';

  @override
  String get webdavAuthMethod => '認証方式';

  @override
  String get webdavAuthBasic => 'ユーザー名とパスワード／アプリパスワード';

  @override
  String get webdavAuthBearer => 'Bearerアクセストークン';

  @override
  String get webdavUsername => 'ユーザー名';

  @override
  String get webdavPasswordOrAppPassword => 'パスワード／アプリパスワード';

  @override
  String get webdavAccessToken => 'アクセストークン';

  @override
  String get webdavEnable => 'WebDAV同期を有効にする';

  @override
  String get webdavEnableSubtitle => '無効にするとネットワーク同期を停止しますが、保存済みのローカル設定は残ります';

  @override
  String get webdavStartupSync => '起動時に自動同期';

  @override
  String get webdavStartupSyncSubtitle =>
      '初回フレームをブロックせずバックグラウンドで実行。失敗後は手動で再試行できます';

  @override
  String get webdavSyncContent => '同期するコンテンツ';

  @override
  String get webdavSyncContentSummary =>
      '• 検索履歴と閲覧履歴\n• 塩選の本棚とダウンロード済みの章\n• 回答キャッシュ（復元後に手動更新して最新情報を取得できます）';

  @override
  String webdavStatus(String message) {
    return '状態：$message';
  }

  @override
  String get webdavLoading => 'WebDAV 設定を読み込んでいます';

  @override
  String get webdavConfiguredStatus => 'WebDAV は設定済みです';

  @override
  String get webdavNotConfigured => 'WebDAV は未設定です';

  @override
  String get webdavSettingsSaved => 'WebDAV 設定を保存しました';

  @override
  String get webdavClosedStatus => 'WebDAV を無効にしました';

  @override
  String get webdavTesting => 'WebDAV 接続をテストしています';

  @override
  String get webdavSyncing => '検索履歴、閲覧履歴、オフライン小説、回答キャッシュを同期しています';

  @override
  String webdavSyncCompleted(String uploaded, String downloaded) {
    return '同期完了：$uploaded 件をアップロード、$downloaded 件を復元';
  }

  @override
  String webdavConfigFailed(String error) {
    return 'WebDAV 設定が無効です：$error';
  }

  @override
  String get webdavSyncNotEnabled => 'WebDAV 同期は無効です';

  @override
  String get webdavNotSynced => 'まだ同期していません';

  @override
  String get webdavSyncNow => '今すぐ同期';

  @override
  String get webdavTestConnection => '接続をテスト';

  @override
  String get webdavDisable => '同期をオフにする';

  @override
  String get webdavClearLocalSettings => 'ローカル設定と認証情報を削除';

  @override
  String webdavLoadFailed(String error) {
    return 'WebDAV設定を読み込めませんでした：$error';
  }

  @override
  String webdavSaveFailed(String error) {
    return '保存に失敗しました：$error';
  }

  @override
  String get webdavConnected => 'WebDAVに接続しました';

  @override
  String webdavConnectionFailed(String error) {
    return '接続に失敗しました：$error';
  }

  @override
  String webdavSyncFailed(String error) {
    return '同期に失敗しました：$error';
  }

  @override
  String get webdavDisabled => 'WebDAV同期をオフにしました。認証情報はローカルの非公開データベースに残ります';

  @override
  String get webdavClearTitle => 'WebDAV設定を削除しますか？';

  @override
  String get webdavClearMessage =>
      'ローカルに保存したWebDAVアドレス、アカウント、認証情報を削除します。リモートの同期データは削除しません。';

  @override
  String get webdavCleared => 'ローカルのWebDAV設定と認証情報を削除しました';

  @override
  String webdavClearFailed(String error) {
    return '削除に失敗しました：$error';
  }

  @override
  String get webdavInvalidEndpoint => 'WebDAVアドレスが無効です';

  @override
  String get webdavHttpsRequired => 'WebDAVアドレスはHTTPSを使用してください';

  @override
  String get webdavEndpointCredentials =>
      'WebDAVアドレスに認証情報、クエリ、フラグメントを含めることはできません';

  @override
  String get webdavCredentialCharacters => 'WebDAV認証情報に改行や制御文字を含めることはできません';

  @override
  String get webdavInvalidDirectory => 'リモートディレクトリが無効です';

  @override
  String get webdavUsernameRequired => 'パスワード認証にはユーザー名が必要です';

  @override
  String get webdavSecretRequired => 'パスワード、アプリパスワード、アクセストークンを入力してください';

  @override
  String get webdavCredentialTooLong => 'アクセス認証情報が長すぎます';

  @override
  String get commonCopy => 'コピー';

  @override
  String get commonSelectAll => 'すべて選択';

  @override
  String get detailDownvote => '反対票';

  @override
  String get detailDownvoted => '反対票を投じました';

  @override
  String get detailCommentAction => 'コメント';

  @override
  String get detailViewComments => 'コメントを見る';

  @override
  String detailViewCommentsCount(String count) {
    return 'コメント $count 件を見る';
  }

  @override
  String get detailFavorite => '保存';

  @override
  String detailFavoriteCount(String count) {
    return '$count 件保存';
  }

  @override
  String get detailAuthor => '作者';

  @override
  String get detailFollowed => 'フォロー中';

  @override
  String get detailFollow => 'フォロー';

  @override
  String get detailUnfollowAuthor => '作者のフォローを解除';

  @override
  String get detailFollowAuthor => '作者をフォロー';

  @override
  String get detailTop => '上部';

  @override
  String get detailBackToTop => '投稿の先頭へ';

  @override
  String get detailBottom => '下部';

  @override
  String get detailJumpToBottom => '投稿の末尾へ';

  @override
  String get detailCollapseMore => 'その他の機能を閉じる';

  @override
  String get detailMoreActions => 'その他の操作';

  @override
  String get detailExportActions => 'コンテンツを書き出す';

  @override
  String get detailSignInFromMe => '先に「マイページ」からログインしてください。';

  @override
  String get detailWriteAnswerSubtitle => 'この質問への新しい回答を作成';

  @override
  String detailRefreshContent(String content) {
    return '$contentを更新';
  }

  @override
  String get detailRefreshSubtitle => 'キャッシュを無視して最新コンテンツを取得';

  @override
  String get detailSearchSubtitle => 'キーワードを入力して本文内を検索';

  @override
  String detailReadAloudSubtitle(String content) {
    return 'システム音声で$contentを読み上げる';
  }

  @override
  String get detailExportTextSubtitle => '現在のタイトル、作者、本文を保存';

  @override
  String detailExportDocument(String format) {
    return '$formatとして書き出す';
  }

  @override
  String get detailExportPdfSubtitle => '共有や印刷に適した文書を作成';

  @override
  String get detailExportDocumentSubtitle => 'タイトル、作者、段落、本文画像のリンクを保持';

  @override
  String get detailCopyAll => '全文をコピー';

  @override
  String get detailCopySubtitle => '現在のタイトル、作者、本文をコピー';

  @override
  String get detailClearCache => 'このキャッシュを削除';

  @override
  String get detailInviteAnswer => '回答を招待';

  @override
  String get detailCopyAnswer => '回答内容をコピー';

  @override
  String detailSelectionTooShort(int count) {
    return '$count文字以上選択してください';
  }

  @override
  String get detailCommentSelection => 'この文章にコメント';

  @override
  String get detailCommentHint => 'コメントを入力してください';

  @override
  String detailActionUnavailable(String action) {
    return '$actionは利用できません';
  }

  @override
  String get detailSignInRequired => 'この機能を使うにはログインしてください';

  @override
  String get detailUnfollowTitle => 'フォローを解除しますか？';

  @override
  String detailUnfollowMessage(String name) {
    return '$nameのフォローを解除します';
  }

  @override
  String get detailUnfollowAction => 'フォローを解除';

  @override
  String get detailCacheCleared => 'この回答のキャッシュを削除しました';

  @override
  String get detailImagePlaceholder => '[画像]';

  @override
  String get detailVideoPlaceholder => '[動画]';

  @override
  String detailImageCount(int count) {
    return '回答画像 $count 枚';
  }

  @override
  String get detailViewImage => '回答画像の原寸を見る';

  @override
  String get detailCloseImage => '画像を閉じる';

  @override
  String get detailSaveImage => '写真に保存';

  @override
  String get detailImageSaved => '画像を保存しました';

  @override
  String get detailImageSavedTo => '写真に保存しました';

  @override
  String get detailImageSaveFailed => '画像を保存できませんでした。後でもう一度お試しください';

  @override
  String get detailMyAnswer => '自分の回答';

  @override
  String detailAuthorPrefix(String name) {
    return '作者：$name';
  }

  @override
  String get detailNoExportableBody => 'この回答には書き出せる本文がありません';

  @override
  String get detailAnswerDetails => '回答の詳細';

  @override
  String detailExportedTo(String location) {
    return '$locationに書き出しました';
  }

  @override
  String get detailExportFailed => '書き出しに失敗しました。再試行してください';

  @override
  String detailDocumentExported(String format, String location) {
    return '$formatとして書き出しました：$location';
  }

  @override
  String get detailStoppedReading => '読み上げを停止しました';

  @override
  String get detailNoReadableBody => 'この回答には読み上げる本文がありません';

  @override
  String get detailReading => '本文を読み上げています';

  @override
  String get detailTtsUnavailable => 'システム音声を利用できません。音声パッケージをインストールしてください';

  @override
  String get detailNoCopyableText => 'この回答にはコピーできる本文がありません';

  @override
  String get detailCopied => '全文をコピーしました';

  @override
  String get detailSearchBodyTitle => '本文を検索';

  @override
  String get detailKeywordHint => 'キーワードを入力';

  @override
  String get detailLocate => '検索';

  @override
  String detailBodyNotFound(String keyword) {
    return '本文に「$keyword」が見つかりません';
  }

  @override
  String detailLocated(String keyword) {
    return '「$keyword」に移動しました';
  }

  @override
  String get detailWriteAnswer => '回答を書く';

  @override
  String get detailAnswerRequired => '回答内容を入力してください';

  @override
  String get detailAnswerPublished => '回答を投稿しました';

  @override
  String get commentSentence => '文のコメント';

  @override
  String commentSentenceCount(String count) {
    return '文のコメント $count 件';
  }

  @override
  String get commentWrite => 'コメントを書く';

  @override
  String commentReplyTitle(String target) {
    return '$targetに返信';
  }

  @override
  String get commentReplyTargetComment => 'このコメント';

  @override
  String get commentPublished => 'コメントを投稿しました。';

  @override
  String get commentReplyPublished => '返信を投稿しました。';

  @override
  String get commentDeleteTitle => 'コメントを削除しますか？';

  @override
  String get commentDeleteMessage => 'このコメントと現在の表示関係を一覧から削除します。';

  @override
  String get commentDeleted => 'コメントを削除しました。';

  @override
  String get commentDeleteReplyTitle => '返信を削除しますか？';

  @override
  String get commentDeleteReplyMessage => '削除すると元に戻せません。';

  @override
  String get commentReplyDeleted => '返信を削除しました。';

  @override
  String get commentRepliesTitle => 'コメントの返信';

  @override
  String get commentNoReplies => 'まだ返信はありません';

  @override
  String get commentNoComments => 'まだコメントはありません';

  @override
  String commentReplyCount(String count) {
    return '返信 $count 件';
  }

  @override
  String get commentEditorUnavailable => 'コメントを一時的に投稿できません';

  @override
  String get commentGif => 'GIF';

  @override
  String get commentExpandEditor => 'エディターを展開';

  @override
  String get contentFilterClearTitle => 'フィルタリング統計を消去しますか？';

  @override
  String get contentFilterClearMessage =>
      '端末内の記録だけを削除します。知乎アカウントとサーバー側のフィードバック設定は変更されません。';

  @override
  String get contentFilterCleared => 'フィルタリング統計を消去しました';

  @override
  String get contentFilterClearStats => '統計を消去';

  @override
  String get contentFilterStatsTitle => 'コンテンツフィルタリング統計';

  @override
  String get contentFilterStatsLabel => 'コンテンツフィルタリング統計';

  @override
  String get contentFilterActions => 'フィードバック操作';

  @override
  String get contentFilterHidden => '非表示にしたコンテンツ';

  @override
  String get contentFilterReasons => 'フィルタリング理由';

  @override
  String get contentFilterHint => 'ホームカードで「このようなコンテンツを減らす」を選ぶと、理由別にここへ集計されます。';

  @override
  String contentFilterCount(String count) {
    return '$count 回';
  }

  @override
  String get contentFilterLatest => '最新の記録';

  @override
  String get contentFilterEmpty => '記録はありません';

  @override
  String get contentFilterSummaryEmpty => '減らしたコンテンツの理由と結果を記録します';

  @override
  String contentFilterSummary(String actions, String hidden, String reasons) {
    return '$actions 回の操作 · $hidden 件を非表示 · $reasons 種類の理由';
  }

  @override
  String get accountSessionsNoCurrent => '保存できる現在のログインセッションはありません';

  @override
  String get accountSessionsSaved => '現在のログインセッションを保存しました';

  @override
  String get accountSessionsSaveFailed => 'アカウントスロットを保存できませんでした。後でもう一度お試しください。';

  @override
  String accountSessionsSwitched(String name) {
    return '$name に切り替えました';
  }

  @override
  String get accountSessionsSwitchFailed => 'アカウントを切り替えられませんでした。後でもう一度お試しください。';

  @override
  String get accountSessionsDeleteTitle => 'アカウントスロットを削除しますか？';

  @override
  String accountSessionsDeleteActiveMessage(String name) {
    return '端末に保存された $name だけを削除します。現在の端末のセッションからはログアウトし、復元可能なコピーを残します。他の端末からはログアウトしません。';
  }

  @override
  String accountSessionsDeleteMessage(String name) {
    return '端末に保存された $name だけを削除します。他の端末からはログアウトしません。';
  }

  @override
  String get accountSessionsDeleted => '端末のアカウントスロットを削除しました';

  @override
  String get accountSessionsDeleteFailed =>
      'アカウントスロットを削除できませんでした。後でもう一度お試しください。';

  @override
  String get accountSessionsNoRecovery => '復元できるアカウントセッションはありません';

  @override
  String get accountSessionsRestored => '最後に消去したアカウントセッションを復元しました';

  @override
  String get accountSessionsRestoreSaveFailed =>
      'セッションは復元されましたが、アカウントスロットの保存に失敗しました。後でもう一度お試しください。';

  @override
  String get accountSessionsPurgeTitle => '復元用認証情報を完全に消去しますか？';

  @override
  String get accountSessionsPurgeMessage =>
      '最後の消去後に保持された復元用コピーを完全に削除します。削除後は復元できません。';

  @override
  String get accountSessionsPurgeAction => '完全に削除';

  @override
  String get accountSessionsPurged => '復元用認証情報を完全に削除しました';

  @override
  String get accountSessionsPurgeFailed => '復元用認証情報を消去できませんでした。後でもう一度お試しください。';

  @override
  String get accountSessionsTitle => 'アカウントと複数端末ログイン';

  @override
  String get accountSessionsSaveCurrent => '現在のセッションを保存';

  @override
  String get accountSessionsIntro =>
      'QRコードまたは電話番号でログインしたセッションは、端末内の非公開認証情報データベースに保存されます。切り替え前に /people/self を再検証し、他の端末からはログアウトしません。';

  @override
  String get accountSessionsRecoveryTitle => '最近消去したログイン情報';

  @override
  String get accountSessionsRecoveryMessage =>
      'サーバーの無効確認後に消去したアカウントは、端末内の復元エリアに残ります。ここから復元または完全削除できます。';

  @override
  String get accountSessionsRestore => '復元';

  @override
  String get accountSessionsEmptyTitle => '保存されたアカウントスロットはありません';

  @override
  String get accountSessionsEmptyMessage => 'ログインすると、ここで複数端末のセッションを管理できます。';

  @override
  String get accountSessionsQr => 'QRコードセッション';

  @override
  String get accountSessionsPassword => '電話番号/パスワードセッション';

  @override
  String get accountSessionsCurrent => '使用中';

  @override
  String get accountSessionsExpired => '期限切れ';

  @override
  String get accountSessionsMenu => 'アカウント操作';

  @override
  String get accountSessionsSwitch => '切り替えて検証';

  @override
  String get accountSessionsRemoveSlot => 'スロットを削除';

  @override
  String get accountSessionsAdd => 'アカウントを追加 / QRコードでログイン';

  @override
  String get accountDefaultName => '知乎アカウント';

  @override
  String accountMaskedName(String id) {
    return 'アカウント $id';
  }

  @override
  String get browsingHistoryClearTitle => '閲覧履歴を消去しますか？';

  @override
  String get browsingHistoryClearMessage => '知乎が端末内に保存した閲覧履歴だけを削除します。';

  @override
  String get browsingHistoryTitle => '閲覧履歴';

  @override
  String get browsingHistoryClear => '閲覧履歴を消去';

  @override
  String get browsingHistoryEmptyTitle => '閲覧履歴はありません';

  @override
  String get browsingHistoryEmptyMessage => '開いた回答、記事、質問、トピックがここに表示されます';

  @override
  String browsingHistoryToday(String time) {
    return '今日 $time';
  }

  @override
  String browsingHistoryDate(int month, int day, String time) {
    return '$month/$day $time';
  }

  @override
  String get updateCheckFailed => 'アップデートを確認できませんでした。後でもう一度お試しください。';

  @override
  String get updateAllowInstallTitle => 'アプリのインストールを許可';

  @override
  String get updateAllowInstallMessage =>
      'Android では、ダウンロードしたアップデートを知阅がインストールする許可が必要です。有効にしてこの画面へ戻り、もう一度「ダウンロードしてインストール」をタップしてください。';

  @override
  String get updateOpenSettings => '設定を開く';

  @override
  String get updateCachedInstalling =>
      'ダウンロード済みのアップデートを使用して Android インストーラーを開いています';

  @override
  String get updateVerifiedInstalling => 'アップデートを検証しました。Android インストーラーを開いています';

  @override
  String get updateInstallFailed => 'アップデートのインストールに失敗しました。もう一度お試しください。';

  @override
  String get updateTitle => 'アプリの更新';

  @override
  String get updateAppName => '知阅';

  @override
  String get updateReadingVersion => 'バージョン情報を読み込んでいます';

  @override
  String updateCurrentVersion(String version, String code) {
    return '現在のバージョン $version ($code)';
  }

  @override
  String get updateUnsupportedTitle => 'アプリ内インストールはサポートされていません';

  @override
  String get updateUnsupportedMessage =>
      '安全なダウンロード、検証、システムインストーラーは現在 Android でのみ有効です。';

  @override
  String get updateCheckingTitle => 'アップデートを確認しています';

  @override
  String get updateCheckingMessage => 'GitHub Releases から安定版を読み込んでいます。';

  @override
  String get updateLatestTitle => '最新の状態です';

  @override
  String get updateNoRelease => '安定版チャンネルに公開済みのバージョンはありません。';

  @override
  String updateLatestVersion(String version, String code) {
    return '安定版の最新バージョンは $version ($code) です。';
  }

  @override
  String get updateChecking => '確認中';

  @override
  String get updateRecheck => '再確認';

  @override
  String get updateSecurity => '更新の安全性';

  @override
  String get updateSecuritySourceTitle => 'GitHub Releases';

  @override
  String get updateSecuritySourceDetail =>
      '指定した GitHub リポジトリにある、正しい名前の安定版 arm64 APK のみを受け付けます。';

  @override
  String get updateSecurityIntegrityTitle => '完全性の検証';

  @override
  String get updateSecurityIntegrityDetail =>
      'ダウンロード後に GitHub が提供する SHA-256 ダイジェストとファイルサイズを確認します。';

  @override
  String get updateSecurityInstallerTitle => 'システムインストーラーを使用';

  @override
  String get updateSecurityInstallerDetail =>
      'Android インストーラーを開く前に、パッケージ名、バージョン、証明書の継続性も確認します。';

  @override
  String get updateImportant => '重要なアップデート';

  @override
  String updateNewVersion(String version) {
    return '新しいバージョン $version';
  }

  @override
  String get updateImportantFound => '重要なアップデートがあります';

  @override
  String get updatePublishedToReleases =>
      '新しいバージョンが GitHub Releases に公開されています。';

  @override
  String get updateLater => '後で';

  @override
  String get updateView => 'アップデートを見る';

  @override
  String updateVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String updateReleaseMeta(String size, String code) {
    return '$size APK · 安定版チャンネル · ビルド $code';
  }

  @override
  String get updateViewDetails => '更新インターフェースの詳細を見る';

  @override
  String get updateVerifiedManifest => 'マニフェスト、パッケージサイズ、SHA-256 を検証済み';

  @override
  String get updateReleaseId => 'リリース ID';

  @override
  String get updatePublishedAt => '公開日時';

  @override
  String get updateReleaseTag => 'Release タグ';

  @override
  String get updatePackageType => 'パッケージ形式';

  @override
  String get updatePackageSha256 => 'APK SHA-256';

  @override
  String get updateManifestResponse => 'マニフェスト応答';

  @override
  String updateDownloadProgress(String received, String total) {
    return 'APK をダウンロード中 $received / $total';
  }

  @override
  String get updateVerifyingPackage => 'パッケージを検証しています';

  @override
  String get updateContinueInstall => 'インストールを続行';

  @override
  String get updateDownloadInstall => 'ダウンロードしてインストール';

  @override
  String get updateValidation => '検証済み';

  @override
  String updateManifestSummary(String size) {
    return '$size マニフェスト';
  }

  @override
  String get profileChange => '変更';

  @override
  String get profileUserFallback => '知乎ユーザー';

  @override
  String get profileAnswers => '回答';

  @override
  String get profileArticles => '記事';

  @override
  String get profileIdeas => 'アイデア';

  @override
  String get profileCollections => 'コレクション';

  @override
  String get profileUpvotes => '賛成';

  @override
  String get profileFollowers => 'フォロワー';

  @override
  String get profileFollowing => 'フォロー中';

  @override
  String get profileEdit => 'プロフィールを編集';

  @override
  String get profileAllDetails => 'すべてのプロフィール';

  @override
  String get profileMyContent => '自分のコンテンツ';

  @override
  String get profileMyAnswers => '自分の回答';

  @override
  String get profileMyArticles => '自分の記事';

  @override
  String get profileMyIdeas => '自分のアイデア';

  @override
  String get profileMyCollections => '自分のコレクション';

  @override
  String get profileIdeasTab => 'アイデア';

  @override
  String get profileCreationTab => '作成';

  @override
  String get profileActivityTab => 'アクティビティ';

  @override
  String get profileVoteupTab => '賛成';

  @override
  String get profilePublicActivitiesEmpty => '公開アクティビティはまだありません';

  @override
  String get profilePublicVoteupsEmpty => '公開した賛成はまだありません';

  @override
  String get profileVipSalt => '塩選メンバー';

  @override
  String get profileVipZhihu => '知乎メンバー';

  @override
  String get profileMetricWan => '万';

  @override
  String get profileMetricYi => '億';

  @override
  String profileMetricItems(String count) {
    return '$count 件';
  }

  @override
  String get profileGenderFemale => '女性';

  @override
  String get profileGenderMale => '男性';

  @override
  String get profileGenderUnspecified => '未設定';

  @override
  String get profileJustJoined => '参加したばかり';

  @override
  String profileAgeDays(int count) {
    return '$count 日';
  }

  @override
  String profileAgeMonthsDays(int months, int days) {
    return '$months か月 $days 日';
  }

  @override
  String profileAgeYearsMonths(int years, int months) {
    return '$years 年 $months か月';
  }

  @override
  String get profileBasicInfo => '基本情報';

  @override
  String get profileUsername => 'ユーザー名';

  @override
  String get profileAccountAge => '知齢';

  @override
  String get profileGender => '性別';

  @override
  String get profileBirthday => '誕生日';

  @override
  String get profileLocation => '居住地';

  @override
  String get profileVerification => '認証情報';

  @override
  String get profileManageVerification => '認証を管理';

  @override
  String get profileUnverified => '未認証';

  @override
  String get profileInfluence => '影響力';

  @override
  String get profileBadges => '自分のバッジ';

  @override
  String get profileLikes => '獲得したいいね';

  @override
  String get profileNone => 'なし';

  @override
  String profileCountPieces(int count) {
    return '$count 件';
  }

  @override
  String profileCountTimes(int count) {
    return '$count 回';
  }

  @override
  String get profileFriendImpression => '友人からの印象';

  @override
  String get profileImproveImage => 'プロフィールを充実させて、さらにフォローを獲得';

  @override
  String get profileAddKeywords => 'プロフィールキーワードを追加';

  @override
  String get profileLinkCopied => 'プロフィールリンクをコピーしました';

  @override
  String get profileTitle => 'マイプロフィール';

  @override
  String get profileLoadFailed => 'プロフィールを読み込めませんでした';

  @override
  String get profileNetworkRetry => 'ネットワークを確認して再試行してください';

  @override
  String get profileOpenDrawer => 'ナビゲーションドロワーを開く';

  @override
  String get profileFindUser => 'ユーザーを検索';

  @override
  String get profileCopyHomeLink => 'プロフィールリンクをコピー';

  @override
  String get profileUsernameEmpty => 'ユーザー名を入力してください';

  @override
  String get profileFieldTooLong => 'ユーザー名、紹介文、または自己紹介が長すぎます';

  @override
  String get profileImageUploadNoUrl => '画像アップロードからアドレスが返りませんでした';

  @override
  String get profileCoverUploadNoHash => 'カバー画像アップロードから画像ハッシュが返りませんでした';

  @override
  String get profileCoverUpdated => 'カバー画像を更新しました';

  @override
  String get profileAvatarUpdated => 'アバターを更新しました';

  @override
  String get profileAddEmployment => '職歴を追加';

  @override
  String get profileCompanyOrOrganization => '会社または組織';

  @override
  String get profileJob => '役職';

  @override
  String get profileAddEducation => '学歴を追加';

  @override
  String get profileSchool => '学校';

  @override
  String get profileMajor => '専攻';

  @override
  String get profileEditTitle => 'プロフィールを編集';

  @override
  String get profileSaving => '保存中';

  @override
  String get profileInfoNotice => '入力した内容はプロフィール表示とおすすめに使用されます';

  @override
  String get profileAvatar => 'アバター';

  @override
  String get profileCover => 'プロフィールカバー';

  @override
  String get profileHeadline => '一言紹介';

  @override
  String get profileHeadlinePlaceholder => '仕事や興味を紹介してください';

  @override
  String get profileBirthdayPlaceholder => '誕生日を入力';

  @override
  String get profileLocationPlaceholder => '居住地を入力';

  @override
  String get profileIndustry => '業界';

  @override
  String get profileIndustryPlaceholder => '業界を選択';

  @override
  String get profileEmployment => '職歴';

  @override
  String get profileEducation => '学歴';

  @override
  String get profilePersonalVerification => '個人認証';

  @override
  String get profileAddVerification => '個人認証を追加';

  @override
  String get profileBio => '自己紹介';

  @override
  String get profileBioPlaceholder => '短い自己紹介を入力してください';

  @override
  String get notificationCommentCategory => 'コメント・再投稿・メンション';

  @override
  String get notificationLikeCategory => '賛同・いいね';

  @override
  String get notificationFavoriteCategory => 'お気に入り登録';

  @override
  String get notificationFollowCategory => 'フォロー・購読';

  @override
  String get notificationInvite => '回答への招待';

  @override
  String get notificationMarkedRead => 'メッセージを既読にしました';

  @override
  String get notificationTitle => 'メッセージ';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get notificationMarkAllRead => 'すべて既読にする';

  @override
  String get notificationLoadFailed => 'メッセージを読み込めませんでした';

  @override
  String notificationInvitePending(String count) {
    return '保留中の招待 $count 件';
  }

  @override
  String get notificationInviteView => '回答に招待された質問を見る';

  @override
  String get notificationCategoryEmpty => 'この種類の通知はありません';

  @override
  String get notificationCategoryMarkedRead => 'このカテゴリをすべて既読にしました';

  @override
  String get notificationSettingsTitle => '通知設定';

  @override
  String get notificationSettingsSection => '交流とコンテンツの通知';

  @override
  String get notificationAll => 'すべて';

  @override
  String get notificationLoginTitle => 'ログインしてメッセージを確認';

  @override
  String get notificationLoginMessage => 'メッセージ通知は知乎アカウントのデータです';

  @override
  String get notificationBackLogin => '戻ってログイン';

  @override
  String get messageTitle => 'ダイレクトメッセージ';

  @override
  String get messageLoadFailed => 'ダイレクトメッセージを読み込めませんでした';

  @override
  String get messageComposeHint => 'メッセージを送信';

  @override
  String get messageSend => '送信';

  @override
  String get notificationSettingCommentMe => 'コメントされたとき';

  @override
  String get notificationSettingMentionMe => 'メンションされたとき';

  @override
  String get notificationSettingAnswerVoteup => '回答に賛同されたとき';

  @override
  String get notificationSettingContentVoteup => 'コンテンツに賛同されたとき';

  @override
  String get notificationSettingAnswerThanks => '回答に感謝されたとき';

  @override
  String get notificationSettingRepin => 'コンテンツをお気に入り登録されたとき';

  @override
  String get notificationSettingReaction => 'コンテンツに反応されたとき';

  @override
  String get notificationSettingMemberFollow => 'フォローされたとき';

  @override
  String get notificationSettingFavlistFollow => 'お気に入りリストをフォローされたとき';

  @override
  String get notificationSettingColumnFollow => 'コラムをフォローされたとき';

  @override
  String get notificationSettingQuestionAnswered => 'フォロー中の質問に新しい回答があるとき';

  @override
  String get notificationSettingAnswerQuestion => '質問に回答されたとき';

  @override
  String get notificationSettingQuestionInvite => '回答に招待されたとき';

  @override
  String get notificationSettingColumnUpdate => 'フォロー中のコラムが更新されたとき';

  @override
  String get notificationSettingMemberActivity => 'フォロー中のユーザーに新しい活動があるとき';

  @override
  String get notificationSettingSpecialUpdate => 'フォロー中の特集が更新されたとき';

  @override
  String get notificationSettingMessage => 'メッセージを受信したとき';

  @override
  String get notificationSettingStrangerMessage => '知らない人からメッセージを受信したとき';

  @override
  String get notificationSettingCoupon => 'オファーと特典のお知らせ';

  @override
  String get notificationSettingBoughtContent => '購入済みコンテンツの更新';

  @override
  String get notificationSettingEbook => '新しい電子書籍';

  @override
  String get notificationSettingArticleInvite => '記事作成への招待';

  @override
  String get notificationSettingTipjar => '記事への投げ銭を受け取ったとき';

  @override
  String get creationAll => 'すべて';

  @override
  String creationAnswers(String count) {
    return '回答 $count';
  }

  @override
  String creationIdeas(String count) {
    return 'アイデア $count';
  }

  @override
  String creationArticles(String count) {
    return '記事 $count';
  }

  @override
  String creationColumns(String count) {
    return 'コラム $count';
  }

  @override
  String creationQuestions(String count) {
    return '質問 $count';
  }

  @override
  String creationVideos(String count) {
    return '動画 $count';
  }

  @override
  String get creationMore => 'その他';

  @override
  String get creationEmpty => '公開したコンテンツはありません';

  @override
  String get creationFavorites => 'お気に入り';

  @override
  String get creationHighlights => 'ハイライト';

  @override
  String get creationFollowingColumns => 'フォロー中のコラム';

  @override
  String get creationFollowingTopics => 'フォロー中のトピック';

  @override
  String get creationFollowingCollections => 'フォロー中のコレクション';

  @override
  String get creationFollowingQuestions => 'フォロー中の質問';

  @override
  String get activityShare => '共有';

  @override
  String get activityDelete => 'このアクティビティを削除';

  @override
  String get activityLinkCopied => 'リンクをコピーしました';

  @override
  String get activityDeleteTitle => 'このアクティビティを削除しますか？';

  @override
  String get activityDeleteMessage => 'この操作は取り消せません。';

  @override
  String get activityDeleted => 'アクティビティを削除しました';

  @override
  String get questionIdUnavailable => '質問 ID を確認できません。更新してもう一度お試しください。';

  @override
  String get questionFollowed => '質問をフォローしました';

  @override
  String get questionUnfollowed => '質問のフォローを解除しました';

  @override
  String get questionAnswerPublishedRefreshing => '回答を公開しました。リストを更新しています。';

  @override
  String get questionDeleteTitle => '回答を削除しますか？';

  @override
  String get questionDeleteMessage => 'この操作は取り消せません。';

  @override
  String get questionDeleted => '回答を削除しました。';

  @override
  String get questionAnswersTitle => 'すべての回答';

  @override
  String get questionSearchAnswers => '回答を検索';

  @override
  String get questionMore => 'その他';

  @override
  String get questionLoginToWrite => 'ログインして回答を書く';

  @override
  String get questionUnfollow => '質問のフォローを解除';

  @override
  String get questionFollow => '質問をフォロー';

  @override
  String get questionAnswerRefresh => '回答を更新';

  @override
  String get questionCollapseDetails => '質問の詳細を折りたたむ';

  @override
  String get questionExpandDetails => '質問の詳細を展開';

  @override
  String get questionCollapse => '折りたたむ';

  @override
  String get questionExpandFull => '全文を表示';

  @override
  String questionOpenTopic(String name) {
    return 'トピック $name を開く';
  }

  @override
  String questionAllContentCount(String count) {
    return 'すべてのコンテンツ $count';
  }

  @override
  String get questionSortDefault => 'デフォルト';

  @override
  String get questionSortLatest => '最新';

  @override
  String get questionSortSemantic => '回答順：';

  @override
  String questionAuthor(String name) {
    return '質問者 $name';
  }

  @override
  String get questionAuthorBadge => '質問者';

  @override
  String get questionViewImage => '質問画像の原寸を見る';

  @override
  String get topicFollowersTitle => 'トピックのフォロワー';

  @override
  String get topicUnansweredTitle => 'トピックの未回答の質問';

  @override
  String topicFallbackTitle(String id) {
    return 'トピック $id';
  }

  @override
  String get topicRefresh => 'トピック情報を更新';

  @override
  String get topicLabel => 'トピック';

  @override
  String topicFollowers(String count) {
    return 'フォロワー $count 人';
  }

  @override
  String topicQuestions(String count) {
    return '質問 $count 件';
  }

  @override
  String topicAnswers(String count) {
    return '回答 $count 件';
  }

  @override
  String topicDiscussions(String count) {
    return 'ディスカッション $count 件';
  }

  @override
  String get topicBasicUnavailable => '基本情報を読み込めませんが、注目フィードは引き続き閲覧できます。';

  @override
  String get topicFollowersButton => 'フォロワー';

  @override
  String get topicUnansweredButton => '未回答';

  @override
  String get zvideoTitle => '動画';

  @override
  String get zvideoCommentsUnavailable => 'コメント';

  @override
  String zvideoActionUnavailable(String action) {
    return '$actionはまだ利用できません';
  }

  @override
  String get zvideoLoadFailed => '動画を一時的に利用できません';

  @override
  String zvideoFallbackTitle(String id) {
    return '動画 #$id';
  }

  @override
  String get zvideoViewComments => 'コメントを見る';

  @override
  String zvideoViewCommentsCount(String count) {
    return 'コメント $count 件を見る';
  }

  @override
  String get zvideoMissing => '再生可能な動画情報を取得できませんでした';

  @override
  String get zvideoVoteup => '賛成';

  @override
  String get zvideoComment => 'コメント';

  @override
  String get zvideoFavorite => '保存';

  @override
  String get zvideoShare => '共有';

  @override
  String get zvideoVoteupSemantic => '動画に賛成';

  @override
  String get zvideoCommentsSemantic => '動画コメントを見る';

  @override
  String get zvideoFavoriteSemantic => '動画を保存';

  @override
  String get zvideoShareSemantic => '動画を共有';

  @override
  String get inlineVideoPlatformUnsupported => 'このプラットフォームではインライン動画を再生できません';

  @override
  String get inlineVideoLoadFailed => '動画を再生できません。しばらくしてからもう一度お試しください。';

  @override
  String get inlineVideoInterruptedRetry => '動画の再生が中断されました。タップして再試行してください。';

  @override
  String get inlineVideoSwitchingLine => '再生が中断されました。別のソースに切り替えています…';

  @override
  String get inlineVideoPaidNoAccess => '有料動画 · このアカウントには視聴権限がありません';

  @override
  String get inlineVideoUnavailable => '動画を再生できません';

  @override
  String get inlineVideoPrivacyUnavailable =>
      'このプラットフォームではプライバシー制限付き動画を再生できません';

  @override
  String get inlineVideoPlay => '動画を再生';

  @override
  String inlineVideoPlayTitle(String title) {
    return '動画を再生：$title';
  }

  @override
  String get inlineVideoFullscreen => '全画面';

  @override
  String get inlineVideoStopped => '動画が停止したか、ソースを切り替えています';

  @override
  String get inlineVideoBack => '戻る';

  @override
  String get answerSwitchRelease => '放して切り替え';

  @override
  String get answerSwitchPreviousHint => 'さらに下へ引いて前の回答を見る';

  @override
  String get answerSwitchNextHint => 'さらに上へスワイプして次の回答を見る';

  @override
  String answerSwitchTo(String author) {
    return '放して $author の回答へ切り替え';
  }

  @override
  String get answerPrevious => '前の回答';

  @override
  String get answerNext => '次の回答';

  @override
  String get detailWriteAnswerLogin => 'ログインして回答を書く';

  @override
  String saltDownloadedProgress(int downloaded, int total) {
    return '$downloaded/$total ダウンロード済み';
  }

  @override
  String saltDownloadedSections(int count) {
    return '$count セクションをダウンロード済み';
  }

  @override
  String get saltAudio => 'プレミアム音声';

  @override
  String get saltVideo => 'プレミアム動画';

  @override
  String get saltStory => 'プレミアムストーリー';

  @override
  String get saltLimitedFree => '期間限定無料';

  @override
  String get saltUntitledContent => 'タイトルなしのプレミアムコンテンツ';

  @override
  String saltLikeCount(String count) {
    return '賛同 $count';
  }

  @override
  String saltCommentCount(String count) {
    return 'コメント $count';
  }

  @override
  String saltWordCount(String count) {
    return '$count 文字';
  }

  @override
  String saltReadCount(String count) {
    return '閲覧 $count';
  }

  @override
  String saltFavoriteCount(String count) {
    return 'お気に入り $count';
  }

  @override
  String get saltPlayable => '再生可能';

  @override
  String get saltSupportsAudio => '音声対応';

  @override
  String get saltFree => '無料';

  @override
  String get saltTrial => '試し読み';

  @override
  String get saltMember => 'プレミアム会員';

  @override
  String get saltEntitlementRequired => '権限が必要';

  @override
  String get saltLastRead => '前回の続き';

  @override
  String get saltReadFinished => '読了';

  @override
  String get saltUntitledChapter => 'タイトルなしの章';

  @override
  String get saltResourceAudio => '音声';

  @override
  String get saltResourceVideo => '動画';

  @override
  String get saltResourceSlide => 'スライド';

  @override
  String get saltResourceText => 'テキスト';

  @override
  String saltReadPercent(int percent) {
    return '読了 $percent%';
  }

  @override
  String saltCommentBadge(int count) {
    return 'インラインコメント $count 件を見る';
  }

  @override
  String followMoreAnswers(int count) {
    return 'ほかに $count 件の回答に賛同';
  }

  @override
  String get brandZhihu => '知乎';

  @override
  String detailQuestionAnswerCount(String count) {
    return '回答 $count 件';
  }

  @override
  String detailQuestionFollowerCount(String count) {
    return 'フォロワー $count 人';
  }

  @override
  String get detailQuestionAnswersSemantic => 'この質問のすべての回答を見る';

  @override
  String detailQuestionFallback(String id) {
    return '質問 #$id';
  }

  @override
  String get questionInviteTitle => '回答に招待';

  @override
  String get questionInviteEmpty => 'おすすめの招待先はありません';

  @override
  String get questionInviteInvited => '招待済み';

  @override
  String get questionInviteAction => '招待';

  @override
  String get routingSafetyTitle => '安全に関する注意';

  @override
  String get routingLeaveZhihu => '知乎を離れようとしています';

  @override
  String get routingExternalWarning =>
      'このリンクは知乎の公式ページではありません。アカウント、プライバシー、財産を保護してください。';

  @override
  String get routingConfirmVisit => '続行';

  @override
  String get routingOpenVerification => '知乎の確認を開く';

  @override
  String get webSafetyTitle => 'セキュリティ確認';

  @override
  String get webPageLoadFailedNetwork => 'ページを読み込めません。ネットワークを確認して再試行してください';

  @override
  String get webPageUnavailable => 'ページを一時的に開けません。後でもう一度お試しください';

  @override
  String get webSessionSyncFailed => 'ログイン状態を同期できません。再ログインしてお試しください';

  @override
  String get webLoginExpired => 'ウェブログインの有効期限が切れました。再ログインしてください';

  @override
  String get webSystemBrowserUnavailable => 'システムブラウザを開けません';

  @override
  String get webContinueInBrowser => 'ブラウザで続行';

  @override
  String get webDesktopSystemBrowser => 'デスクトップではシステムブラウザを使用します';

  @override
  String get webOpenBrowser => 'ブラウザを開く';

  @override
  String get webOpeningChapter => '章を開いています';

  @override
  String get webOpeningPage => 'ページを開いています';

  @override
  String get webOpenInBrowser => 'ブラウザで開く';

  @override
  String get webChapterReading => '章を読む';

  @override
  String get routingCannotOpen => '現在開けません。';

  @override
  String get routingCannotViewComments => '現在コメントを表示できません。';

  @override
  String get routingUnsupportedAction => '現在のコンテンツではこの操作をサポートしていません。';

  @override
  String get routingPinDownvoteUnavailable => 'アイデアでは反対を利用できません。';

  @override
  String get routingDownvoteCancelled => '反対を取り消しました。';

  @override
  String get routingDownvoted => '反対しました。';

  @override
  String get routingVoteCancelled => '賛同を取り消しました。';

  @override
  String get routingVoted => '賛同しました。';

  @override
  String get routingFavoriteRemoved => 'お気に入りから削除しました。';

  @override
  String get routingFavorited => '既定のお気に入りに追加しました。';

  @override
  String get objectDetailTitle => 'コンテンツの詳細';

  @override
  String get objectImages => '画像';

  @override
  String get objectContent => 'コンテンツ';

  @override
  String get contentTypeCollection => 'コレクション';

  @override
  String columnFallbackTitle(String token) {
    return 'コラム $token';
  }

  @override
  String get columnFollowersTitle => 'コラムのフォロワー';

  @override
  String get columnLoadFailed => 'コラム情報を読み込めません。';

  @override
  String get columnRetry => 'コラム情報を再試行';

  @override
  String get columnTitle => 'コラム';

  @override
  String columnArticleCount(String count) {
    return '記事 $count 件';
  }

  @override
  String columnFollowerCount(String count) {
    return 'フォロワー $count 人';
  }

  @override
  String columnContributionCount(String count) {
    return '投稿 $count 件';
  }

  @override
  String columnVoteupCount(String count) {
    return '賛同 $count';
  }

  @override
  String columnAuthorPrefix(String name) {
    return '作者 $name';
  }

  @override
  String get columnFollowers => 'フォロワー';

  @override
  String get columnAuthorProfile => '作者プロフィール';

  @override
  String get detailContentIncomplete => 'コンテンツが不完全な可能性があります';

  @override
  String get detailPaidUnlocked => 'プレミアム会員コンテンツはこのアカウントで解除されています。以下に全文を表示します。';

  @override
  String get detailPaidLocked =>
      'これはプレミアム会員コンテンツですが、このアカウントに返された本文はまだロックされています。';

  @override
  String get detailRelatedLoadFailed => '他の回答を読み込めませんでした。タップして再試行';

  @override
  String get detailViewCommentsButton => 'コメントを見る';

  @override
  String get detailContentInfo => 'コンテンツ情報';

  @override
  String get detailReadingHint => '本文の幅を制限しているため、スクロール中もインタラクション情報を確認できます。';

  @override
  String get blockedKeywordsTitle => 'ブロックするキーワード';

  @override
  String blockedKeywordsInvalidLength(int min, int max) {
    return 'キーワードは $min～$max 文字で入力してください';
  }

  @override
  String get blockedKeywordsExists => 'そのキーワードはすでに存在します';

  @override
  String blockedKeywordsLimit(int max) {
    return '設定できるキーワードは最大 $max 件です';
  }

  @override
  String get blockedKeywordsDescription => 'これらのキーワードを含むおすすめを減らします';

  @override
  String blockedKeywordsCount(int current, int max) {
    return '$current/$max 件設定済み';
  }

  @override
  String blockedKeywordsHint(int min, int max) {
    return '$min～$max 文字';
  }

  @override
  String get blockedKeywordsAdd => 'キーワードを追加';

  @override
  String get blockedKeywordsEmpty => 'ブロックするキーワードはありません';

  @override
  String blockedKeywordsDelete(String keyword) {
    return '$keyword を削除';
  }

  @override
  String get recommendationClearTitle => '端末内のおすすめプロファイルを消去しますか？';

  @override
  String get recommendationClearMessage =>
      '端末内の記録だけを削除します。知乎アカウントとサーバー側のおすすめは変更されません。';

  @override
  String get recommendationCleared => '端末内のおすすめプロファイルを消去しました';

  @override
  String get recommendationTitle => '端末内のおすすめ行動';

  @override
  String get recommendationClearSemantic => '端末内プロファイルを消去';

  @override
  String get recommendationEmptyTitle => '端末内の行動はまだありません';

  @override
  String get recommendationProfileTitle => '端末内のおすす​​めプロファイル';

  @override
  String get recommendationEmptyMessage =>
      'おすすめを開いたり「興味なし」を選択したりすると、知阅が端末内に限定的な興味シグナルを記録します。';

  @override
  String recommendationSummary(int total, int opened, int feedback) {
    return 'シグナル $total 件 · 開いた項目 $opened · フィードバック $feedback';
  }

  @override
  String get recommendationTopics => 'よくある興味の語句';

  @override
  String get recommendationAuthors => 'よくある作者';

  @override
  String get recommendationPrivacy =>
      'データは端末内だけに保存され、端末内または混合型のおすすめ順位付けに使用されます。行動の詳細はアップロードされません。';

  @override
  String get discoverColumns => 'コラムのおすすめ';

  @override
  String get discoverTopics => 'トピックカテゴリ';

  @override
  String get discoverHotTopics => '人気のトピック';

  @override
  String get discoverHotTopicsEmpty => '人気のトピックはありません';

  @override
  String get discoverContentIdInvalid => 'コンテンツ ID は 1～32 桁の数字で入力してください';

  @override
  String get discoverTitle => '発見';

  @override
  String get discoverColumnsAndTopics => 'コラムとトピック';

  @override
  String get discoverColumnsSubtitle => '編集部のおすすめと人気コラムの記事';

  @override
  String get discoverTopicsSubtitle => 'カテゴリからトピックを閲覧';

  @override
  String get discoverHotTopicsSubtitle => '現在人気の議論';

  @override
  String get discoverOpenById => 'ID でコンテンツを開く';

  @override
  String get discoverTypeAnswer => '回答';

  @override
  String get discoverTypeArticle => '記事';

  @override
  String get discoverTypeIdea => 'アイデア';

  @override
  String get discoverIdHint => 'コンテンツ ID を入力';

  @override
  String get discoverOpenDetails => '詳細を開く';

  @override
  String get pagedEnd => 'これ以上ありません';

  @override
  String get pagedEmpty => 'コンテンツはまだありません';

  @override
  String get diagnosticExported => 'ログ JSON をクリップボードにコピーしました';

  @override
  String get diagnosticEmpty => 'ログはありません';

  @override
  String get diagnosticClearTitle => '診断ログを消去しますか？';

  @override
  String get diagnosticClearMessage =>
      '端末内に保存された診断記録だけを削除します。アカウントとコンテンツキャッシュには影響しません。';

  @override
  String get diagnosticCleared => '診断ログを消去しました';

  @override
  String get diagnosticTitle => '診断ログ';

  @override
  String get diagnosticExport => 'ログを書き出す';

  @override
  String get diagnosticClear => 'ログを消去';

  @override
  String get diagnosticPurpose => '削除されたコンテンツ、API エラー、パフォーマンス問題の調査に使用します';

  @override
  String get diagnosticPrivacy =>
      '認証の期限切れ、復元、消去の判断は既定で記録されます。その他の診断ログは個別に切り替えられます。匿名化した状態だけを保存し、Cookie、トークン、本文、画像は保存しません。';

  @override
  String get diagnosticLocalEnabled => '端末内ログを有効にする';

  @override
  String get diagnosticLocalSubtitle => '最新 600 件の診断記録を保持';

  @override
  String get diagnosticAuthEnabled => '認証状態ログ';

  @override
  String get diagnosticAuthSubtitle => 'ログインの期限切れ、復元、保持、消去の判断を記録（既定で有効）';

  @override
  String get diagnosticNetworkEnabled => 'ネットワーク要求ログ';

  @override
  String get diagnosticNetworkSubtitle => 'API パス、HTTP ステータス、業務コード、所要時間を記録';

  @override
  String get diagnosticPerformanceEnabled => 'パフォーマンスログ';

  @override
  String get diagnosticPerformanceSubtitle => 'フレーム落ちや遅い要求の調査に要求時間を記録';

  @override
  String diagnosticInstallSummary(String id, int count) {
    return '端末 ID $id · $count 件';
  }

  @override
  String get diagnosticEmptyTitle => '診断ログはありません';

  @override
  String get diagnosticEmptyMessage =>
      '端末内ログを有効にしてもう一度操作してください。エラーとネットワーク状態がここに表示されます。';

  @override
  String get diagnosticNoDetails => '追加情報はありません';

  @override
  String get diagnosticLevelDebug => 'デバッグ';

  @override
  String get diagnosticLevelInfo => '情報';

  @override
  String get diagnosticLevelWarning => '警告';

  @override
  String get diagnosticLevelError => 'エラー';

  @override
  String get diagnosticCategoryApp => 'アプリ';

  @override
  String get diagnosticCategoryNetwork => 'ネットワーク';

  @override
  String get diagnosticCategoryPerformance => 'パフォーマンス';

  @override
  String get diagnosticCategoryError => 'エラー';

  @override
  String get diagnosticCategoryAuthentication => '認証';
}
