// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '지열';

  @override
  String get navRecommend => '추천';

  @override
  String get navSearch => '검색';

  @override
  String get navBookshelf => '책장';

  @override
  String get navMe => '내 정보';

  @override
  String get navWorkspace => '작업 공간';

  @override
  String get feedFollowing => '팔로잉';

  @override
  String get feedRecommend => '추천';

  @override
  String get feedHot => '인기';

  @override
  String get feedStory => '스토리';

  @override
  String get answerLabel => '답변';

  @override
  String get drawerBrowse => '둘러보기';

  @override
  String get drawerColumns => '칼럼 추천';

  @override
  String get drawerTopicCategories => '토픽 분류';

  @override
  String get drawerHotTopics => '인기 토픽';

  @override
  String get drawerHistory => '기록';

  @override
  String get drawerMyContent => '내 콘텐츠';

  @override
  String get drawerMessages => '메시지';

  @override
  String get drawerCollections => '즐겨찾기';

  @override
  String get drawerBookshelf => '책장';

  @override
  String get drawerFindUsers => '사용자 찾기';

  @override
  String get drawerAccount => '계정';

  @override
  String get drawerLoginOrAddAccount => '로그인 또는 계정 추가';

  @override
  String get drawerAccountManagement => '계정 관리';

  @override
  String get drawerApp => '앱';

  @override
  String get drawerSettings => '설정';

  @override
  String get drawerClose => '사이드바 닫기';

  @override
  String drawerVersion(String version) {
    return '지열 $version';
  }

  @override
  String get commonBack => '뒤로';

  @override
  String get commonClose => '닫기';

  @override
  String get commonCancel => '취소';

  @override
  String get commonConfirm => '확인';

  @override
  String get commonSave => '저장';

  @override
  String get commonReset => '기본값 복원';

  @override
  String get commonClear => '지우기';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonDone => '완료';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonSearch => '검색';

  @override
  String get commonLoading => '로드 중…';

  @override
  String get commonMore => '더 보기';

  @override
  String get commonReply => '답글';

  @override
  String get commonPublish => '게시';

  @override
  String get commonPublishing => '게시 중';

  @override
  String get commonFollow => '팔로우';

  @override
  String get commonRefresh => '새로고침';

  @override
  String get commonEdit => '편집';

  @override
  String get commonShare => '공유';

  @override
  String get commonFailed => '로드하지 못했습니다. 다시 시도하세요.';

  @override
  String get commonNoMore => '더 이상 콘텐츠가 없습니다';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsHomeContent => '홈 및 콘텐츠';

  @override
  String get settingsStartupPage => '시작 페이지';

  @override
  String get settingsRecommendation => '추천 방식';

  @override
  String get settingsServer => '서버';

  @override
  String get settingsLocal => '로컬';

  @override
  String get settingsHybrid => '혼합';

  @override
  String get settingsDensity => '콘텐츠 밀도';

  @override
  String get settingsComfortable => '편안함';

  @override
  String get settingsCompact => '간결함';

  @override
  String get settingsRefreshHome => '홈을 다시 누르면 새로고침';

  @override
  String get settingsRefreshHomeSubtitle => '선택한 홈을 다시 누르면 맨 위로 이동해 새로고침합니다';

  @override
  String get settingsShowImages => '추천 이미지 표시';

  @override
  String get settingsShowImagesSubtitle => '끄면 텍스트, 작성자, 반응만 표시합니다';

  @override
  String get settingsShowMetrics => '반응 수 표시';

  @override
  String get settingsShowMetricsSubtitle => '추천, 저장, 댓글, 날짜를 표시합니다';

  @override
  String get settingsLocalBehavior => '로컬 추천 기록';

  @override
  String settingsLocalEvents(int count) {
    return '이 기기에 $count개의 동작 기록';
  }

  @override
  String get settingsFeedOrder => '홈 섹션 순서';

  @override
  String get settingsFilterStats => '콘텐츠 필터 통계';

  @override
  String get settingsReadingDisplay => '읽기 및 표시';

  @override
  String get settingsDarkMode => '다크 모드';

  @override
  String get settingsDarkModeOnSubtitle => '어두운 배경과 낮은 밝기의 표면 사용';

  @override
  String get settingsDarkModeOffSubtitle => '밝은 배경과 표면 사용';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageSubtitle => '앱 인터페이스 언어 선택';

  @override
  String get settingsTextSize => '본문 글자 크기';

  @override
  String get settingsSmall => '작게';

  @override
  String get settingsStandard => '표준';

  @override
  String get settingsLarge => '크게';

  @override
  String get settingsFollowSystemTextScale => '시스템 글자 크기 따르기';

  @override
  String get settingsFollowSystemTextScaleSubtitle => '본문 크기에 시스템 표시 크기 적용';

  @override
  String get settingsReduceMotion => '동작 줄이기';

  @override
  String get settingsReduceMotionSubtitle => '페이지와 구성 요소 애니메이션 줄이기';

  @override
  String get settingsGlass => '리퀴드 글래스 효과';

  @override
  String get settingsGlassOnSubtitle => '유리 효과와 반투명 레이어 유지';

  @override
  String get settingsGlassOffSubtitle => '성능 모드: 가벼운 버튼과 탐색 사용';

  @override
  String get settingsPersonalization => '개인화';

  @override
  String get settingsFocusSearch => '검색 페이지에서 키보드 자동 열기';

  @override
  String get settingsFocusSearchOn => '검색창 자동 포커스';

  @override
  String get settingsFocusSearchOff => '검색창을 직접 누르기';

  @override
  String get settingsImagesStorage => '이미지 및 저장 공간';

  @override
  String get settingsKeepHistory => '탐색 기록 저장';

  @override
  String settingsKeepHistoryOn(int count) {
    return '이 기기에만 저장 · $count개';
  }

  @override
  String get settingsKeepHistoryOff => '열어 본 콘텐츠를 기기에 저장하지 않음';

  @override
  String get settingsPrefetchImages => '목록 이미지 미리 로드';

  @override
  String get settingsPrefetchImagesSubtitle => '표시 전에 아바타와 본문 이미지 로드';

  @override
  String get settingsImageCache => '이미지 캐시 용량';

  @override
  String get settingsEconomy => '절약';

  @override
  String get settingsRoomy => '넉넉함';

  @override
  String get settingsNoCacheImages => '캐시된 이미지가 없습니다';

  @override
  String settingsCachedImages(int count) {
    return '캐시 이미지 $count개 삭제';
  }

  @override
  String get settingsPrivacyData => '개인정보 및 데이터';

  @override
  String get settingsKeepSearch => '검색 기록 저장';

  @override
  String settingsKeepSearchOn(int count) {
    return '이 기기에만 저장 · $count개';
  }

  @override
  String get settingsKeepSearchOff => '새 검색을 기기에 저장하지 않음';

  @override
  String get settingsShowHot => '인기 검색 표시';

  @override
  String get settingsShowHotOn => '검색에 Zhihu 인기 검색 표시';

  @override
  String get settingsShowHotOff => '인기 검색을 불러오지 않음';

  @override
  String get settingsWebDav => 'WebDAV 동기화';

  @override
  String get settingsAccountSessions => '계정 및 다중 기기 로그인';

  @override
  String get settingsSignOut => '로그아웃';

  @override
  String get settingsOther => '기타';

  @override
  String get settingsDiagnostics => '진단 로그';

  @override
  String get settingsUpdate => '소프트웨어 업데이트';

  @override
  String get settingsRestoreDefaults => '기본 설정 복원';

  @override
  String get settingsAbout => '지열 정보';

  @override
  String settingsVersion(String version) {
    return '버전 $version';
  }

  @override
  String get settingsFeedOrderSubtitle =>
      '오른쪽을 길게 눌러 드래그하면 홈 탭과 스와이프 순서가 동기화됩니다.';

  @override
  String get settingsRestoreDefaultsMessage => '모든 설정을 기본값으로 되돌리며 로그아웃하지 않습니다.';

  @override
  String get settingsRestored => '설정을 기본값으로 복원했습니다';

  @override
  String get settingsSignOutMessage => '이 기기에 저장된 로그인 정보를 삭제합니다.';

  @override
  String get settingsSignedOut => '로그아웃했습니다';

  @override
  String get settingsClearBrowsing => '탐색 기록 지우기';

  @override
  String get settingsNoBrowsingHistory => '탐색 기록이 없습니다';

  @override
  String settingsDeleteBrowsing(int count) {
    return '기기의 기록 $count개 삭제';
  }

  @override
  String get settingsClearImageCache => '이미지 캐시 지우기';

  @override
  String get settingsClearOfflineChapters => '오프라인 장 삭제';

  @override
  String get settingsClearOfflineChaptersSubtitle => '읽거나 다운로드할 때 저장한 염선 본문 삭제';

  @override
  String get settingsClearSearch => '검색 기록 지우기';

  @override
  String get settingsNoSearchHistory => '검색 기록이 없습니다';

  @override
  String settingsDeleteSearch(int count) {
    return '기기의 기록 $count개 삭제';
  }

  @override
  String get settingsWebDavConfigured => '설정됨 · 검색, 기록, 오프라인 소설, 답변 캐시';

  @override
  String get settingsWebDavSubtitle => '검색 기록, 탐색 기록, 오프라인 소설, 답변 캐시 동기화';

  @override
  String get settingsAccountSessionsSubtitle => 'QR 로그인, 계정 슬롯 저장, 빠른 전환';

  @override
  String get settingsSignOutSubtitle => '이 기기의 로그인 정보 삭제';

  @override
  String get settingsDiagnosticsOn => '사용 중 · 네트워크 및 성능 로그 관리와 내보내기';

  @override
  String get settingsDiagnosticsOff => 'API 오류, 로딩 실패, 성능 문제 확인';

  @override
  String get settingsUpdateSubtitle => '안전하게 확인하고 새 버전 다운로드 및 설치';

  @override
  String get settingsRestoreDefaultsSubtitle => '계정은 로그아웃되지 않습니다';

  @override
  String get searchTitle => '검색';

  @override
  String get searchPlaceholder => 'Zhihu 콘텐츠 검색';

  @override
  String get searchFilter => '필터';

  @override
  String get searchGeneral => '종합';

  @override
  String get searchRealtime => '실시간';

  @override
  String get searchUsers => '사용자';

  @override
  String get searchStories => '소설';

  @override
  String get searchArticles => '논문';

  @override
  String get searchVideos => '동영상';

  @override
  String get searchTopics => '토픽';

  @override
  String get searchColumns => '칼럼';

  @override
  String get searchKnowledge => '지식';

  @override
  String get searchIdeas => '아이디어';

  @override
  String get searchCircles => '서클';

  @override
  String get searchPodcasts => '팟캐스트';

  @override
  String get searchHot => '인기 검색';

  @override
  String get searchHistory => '검색 기록';

  @override
  String get searchUnavailableTitle => '일시적으로 사용할 수 없음';

  @override
  String get searchUnavailableMessage =>
      '익명 콘텐츠 서비스를 사용할 수 없습니다. 나중에 다시 시도하세요.';

  @override
  String get searchNoResults => '관련 콘텐츠를 찾을 수 없습니다';

  @override
  String get searchScope => '검색 범위';

  @override
  String get searchMoreScopes => '좌우로 스와이프하여 더 보기';

  @override
  String get searchOverview => '검색 개요';

  @override
  String get searchStartHint => '키워드를 입력하여 검색';

  @override
  String get searchCurrentScope => '현재 범위';

  @override
  String get searchActiveFilters => '사용 중인 필터';

  @override
  String get searchFilterType => '콘텐츠 유형';

  @override
  String get searchFilterSort => '정렬';

  @override
  String get searchFilterTime => '시간 범위';

  @override
  String get commentAll => '모든 댓글';

  @override
  String commentCount(String count) {
    return '댓글 $count개';
  }

  @override
  String get commentDefault => '기본';

  @override
  String get commentLatest => '최신';

  @override
  String get commentInputPlaceholder => '배려하며 대화해 주세요';

  @override
  String get commentReply => '이 댓글에 답글';

  @override
  String get commentPublishReply => '답글 게시';

  @override
  String get commentPublishComment => '댓글 게시';

  @override
  String commentReplyTo(String name) {
    return '@$name에게 답글';
  }

  @override
  String get commentMention => '사용자 멘션';

  @override
  String get commentCollapse => '편집기 접기';

  @override
  String get commentExpand => '편집기 펼치기';

  @override
  String get commentImage => '이미지 댓글';

  @override
  String get loginTitle => '로그인';

  @override
  String get loginAccount => '계정';

  @override
  String get loginPhone => '전화번호';

  @override
  String get loginPassword => '비밀번호';

  @override
  String get loginCode => '인증 코드';

  @override
  String get loginContinue => '동의하고 계속';

  @override
  String get loginCancel => '지금은 안 함';

  @override
  String get loginScanSuccess => 'QR 로그인 성공';

  @override
  String get detailReadAnswer => '답변 작성';

  @override
  String get detailRefreshAnswers => '답변 새로고침';

  @override
  String get detailSearchBody => '본문 검색';

  @override
  String get detailReadAloud => '본문 읽어주기';

  @override
  String get detailExportTxt => 'TXT로 내보내기';

  @override
  String get detailExportMarkdown => 'Markdown으로 내보내기';

  @override
  String get detailExportHtml => 'HTML로 내보내기';
}
