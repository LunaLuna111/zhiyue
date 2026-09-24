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
}
