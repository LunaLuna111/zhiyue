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
  String get feedFollowingChoice => '추천';

  @override
  String get feedFollowingLatest => '최신';

  @override
  String get feedFollowingIdeas => '아이디어';

  @override
  String get feedEmptyFollowing => '팔로우한 계정의 새 콘텐츠가 없습니다';

  @override
  String get feedEmptyHot => '표시할 인기 순위 콘텐츠가 없습니다';

  @override
  String get feedEmptyRecommend => '표시할 추천 콘텐츠가 없습니다';

  @override
  String get feedNextLoadFailed => '추가 로드에 실패했습니다. 탭하여 재시도하세요';

  @override
  String get feedAllShown => '모든 콘텐츠를 표시했습니다';

  @override
  String get feedLoadMore => '아래로 스크롤하여 더 보기';

  @override
  String get feedFollowingPeople => '팔로우 중';

  @override
  String feedViewPersonRecent(String name) {
    return '$name의 최근 콘텐츠 보기';
  }

  @override
  String get feedDiscoverFriends => '친구 찾기';

  @override
  String get feedFollowingSemantic => '팔로우 탭';

  @override
  String get feedSaltServiceFallback => 'Salt Select가 고른 콘텐츠';

  @override
  String feedPersonRecentTitle(String name) {
    return '$name의 최근 활동';
  }

  @override
  String get feedPersonRecentEmpty => '공개된 최근 콘텐츠가 없습니다';

  @override
  String get storyCategoriesTitle => '카테고리';

  @override
  String get storySearch => '스토리 검색';

  @override
  String get storyLoadFailed => '스토리 카테고리를 불러올 수 없습니다';

  @override
  String get storyEmptyCategories => '스토리 카테고리가 아직 없습니다';

  @override
  String get storyBrowseByGenre => '장르별 스토리 보기';

  @override
  String get storyFilterStories => '스토리 필터';

  @override
  String get storyFeaturedCategories => '추천 카테고리';

  @override
  String get storyQuickFilter => '빠른 필터';

  @override
  String get storySort => '정렬';

  @override
  String get storyAll => '전체';

  @override
  String get storyCategory => '카테고리';

  @override
  String get storyTabStories => '스토리';

  @override
  String get storyTabBooks => '전자책';

  @override
  String get storyTabAssessments => '리뷰';

  @override
  String get storyLong => '장편';

  @override
  String get storyShort => '단편';

  @override
  String get storyAudioBook => '오디오북';

  @override
  String get storyFilter => '필터';

  @override
  String get storySortHot => '인기순';

  @override
  String get storySortGood => '평점순';

  @override
  String get storySortNew => '최신순';

  @override
  String get storyAllCategories => '전체 카테고리';

  @override
  String get storyMaxTags => '최대 5개 태그 선택';

  @override
  String get storyNoCategories => '카테고리 없음';

  @override
  String get storyReset => '초기화';

  @override
  String get storyConfirm => '확인';

  @override
  String get storyViewAll => '모두 보기';

  @override
  String get storyEmptyCondition => '조건에 맞는 콘텐츠가 없습니다';

  @override
  String get storyCategoryFallback => '스토리 카테고리';

  @override
  String get storyEmptyCategory => '이 카테고리에 스토리가 없습니다';

  @override
  String get storyLongTitle => '장편 스토리';

  @override
  String get storyEmptyLong => '장편 스토리가 아직 없습니다';

  @override
  String storyLikeCount(String count) {
    return '좋아요 $count개';
  }

  @override
  String get storyOngoing => '연재 중';

  @override
  String get storyFinished => '완결';

  @override
  String get storyFree => '무료';

  @override
  String get storyVip => 'VIP';

  @override
  String get storyVipDiscount => 'VIP 할인';

  @override
  String get storyType => '유형';

  @override
  String get storyStatus => '상태';

  @override
  String get storyRights => '권한';

  @override
  String get storySectionHotTags => '인기 태그';

  @override
  String get storySectionGenre => '장르';

  @override
  String get storySectionCharacters => '등장인물';

  @override
  String get storySectionPlot => '줄거리';

  @override
  String get storySectionMood => '분위기';

  @override
  String get storySectionSetting => '배경';

  @override
  String get storyTypeAssessment => '리뷰';

  @override
  String get storyMaxSelection => '최대 5개 태그 선택';

  @override
  String get saltContinueReading => '계속 읽기';

  @override
  String get saltStartReading => '읽기 시작';

  @override
  String get saltAdded => '추가됨';

  @override
  String get saltAddToBookshelf => '책장에 추가';

  @override
  String get saltChapterOrder => '챕터 순서';

  @override
  String get saltAscending => '오름차순';

  @override
  String get saltDescending => '내림차순';

  @override
  String get saltChapter => '챕터';

  @override
  String get saltCatalogTitle => '목차';

  @override
  String saltChapterCount(int count) {
    return '총 $count개 챕터';
  }

  @override
  String get saltChapterDirectory => '챕터 목록';

  @override
  String saltProcessing(int index, int total, String title) {
    return '처리 중 $index/$total · $title';
  }

  @override
  String get saltSelectAll => '모두 선택';

  @override
  String get saltCancelSelectAll => '모두 선택 해제';

  @override
  String saltSelectedCount(int selected, int total) {
    return '선택 $selected/$total';
  }

  @override
  String get saltDownloadingChapters => '챕터 다운로드 중';

  @override
  String saltExportChapters(String format, int count) {
    return '$format 내보내기 · $count개 챕터';
  }

  @override
  String get saltDirectoryLoadFailed => '챕터를 불러오지 못했습니다';

  @override
  String get saltNetworkRetry => '네트워크를 확인하고 다시 시도하세요';

  @override
  String get saltDecodeFailed => '챕터를 디코딩하지 못했습니다. 다시 시도하세요.';

  @override
  String get saltDecodeParamsMissing => '챕터 응답에 필요한 디코딩 매개변수가 없습니다. 다시 시도하세요.';

  @override
  String get saltDirectoryEmpty => '목차에 챕터가 없습니다';

  @override
  String get saltCached => '캐시됨';

  @override
  String get saltCommentsEmpty => '댓글이 없습니다';

  @override
  String get saltBulletCommentsEmpty => '인라인 댓글이 없습니다';

  @override
  String get saltReaderTopBar => '리더 상단 바';

  @override
  String get saltReaderBottomBar => '리더 하단 바';

  @override
  String get saltReadingTitle => 'Salt Select 리더';

  @override
  String get saltMore => '더보기';

  @override
  String get saltSettingsTitle => '읽기 설정';

  @override
  String get saltVerticalScroll => '세로 스크롤';

  @override
  String get saltHorizontalPage => '가로 페이지';

  @override
  String get saltFontSize => '글자 크기';

  @override
  String get saltLineSpacing => '줄 간격';

  @override
  String get saltParagraphSpacing => '문단 간격';

  @override
  String get saltHorizontalMargins => '좌우 여백';

  @override
  String get saltApply => '적용';

  @override
  String get saltChapterInfo => '챕터 정보';

  @override
  String get saltAuthor => '작성자';

  @override
  String get saltReadable => '읽을 수 있음';

  @override
  String get saltLocked => '잠김';

  @override
  String get saltChapterLocked => '챕터 잠김';

  @override
  String get saltChapterReadable => '챕터 읽기 가능';

  @override
  String saltSectionLabel(int index) {
    return '$index장';
  }

  @override
  String saltSectionProgress(int index, int count) {
    return '$index/$count장';
  }

  @override
  String saltLikes(String count) {
    return '좋아요 $count개';
  }

  @override
  String saltComments(String count) {
    return '댓글 $count개';
  }

  @override
  String get saltAudioAvailable => '오디오';

  @override
  String get saltNoPermission => '현재 계정에 읽기 권한이 없습니다';

  @override
  String get saltReload => '다시 로드';

  @override
  String get saltContentUnavailable => '챕터 콘텐츠를 사용할 수 없습니다';

  @override
  String get saltPreviousChapter => '이전 챕터';

  @override
  String get saltNextChapter => '다음 챕터';

  @override
  String get saltMetadataReady => '자료 준비됨';

  @override
  String get saltEntitlementPassed => '권한 확인됨';

  @override
  String get saltPayloadReady => '페이로드 준비됨';

  @override
  String get saltBodyShown => '본문 표시됨';

  @override
  String get saltWaitingBody => '본문 분석 대기 중';

  @override
  String get saltPayloadChars => '페이로드 문자';

  @override
  String get saltCodeChars => 'code 문자';

  @override
  String get saltChapterBodyShown => '챕터 본문 표시됨';

  @override
  String get saltReadyDetail => '챕터 자료, 바인딩된 페이로드와 전체 본문이 준비되었습니다.';

  @override
  String get saltShelfTitle => '책장';

  @override
  String get saltWorkFallback => 'Salt Select 작품';

  @override
  String get saltCategory => '카테고리';

  @override
  String get saltKnowledgeColumn => '지식 칼럼';

  @override
  String get saltLocalShelfEmpty => '로컬 책장이 비어 있습니다';

  @override
  String get saltMoreActions => '추가 작업';

  @override
  String get saltReadAloud => '이 챕터 소리 내어 읽기';

  @override
  String get saltStopReading => '읽기 중지';

  @override
  String get saltReadAloudSubtitle => '시스템 음성으로 이 챕터를 읽습니다';

  @override
  String saltExportChapter(String format) {
    return '이 챕터를 $format(으)로 내보내기';
  }

  @override
  String get saltExportTxt => 'TXT 파일 내보내기';

  @override
  String get saltExportDocx => 'DOCX 파일 내보내기';

  @override
  String saltReadingStarted(String title) {
    return '$title 읽는 중';
  }

  @override
  String get saltSpeechUnavailable => '시스템 음성을 사용할 수 없습니다. 음성 패키지를 설치하세요';

  @override
  String saltExportedTo(String location) {
    return '$location(으)로 내보냈습니다';
  }

  @override
  String saltExportedAs(String format, String location) {
    return '$format(으)로 내보냈습니다: $location';
  }

  @override
  String get saltExportFailed => '내보내기에 실패했습니다. 다시 시도하세요';

  @override
  String get saltCloudShelfUnavailable => '클라우드 책장을 동기화할 수 없습니다';

  @override
  String get saltAccountSyncFailed => '계정 동기화에 실패했습니다. 나중에 다시 시도하세요';

  @override
  String get saltStoryHomeLoadFailed => 'Salt Select 홈을 불러올 수 없습니다';

  @override
  String get saltStoryEntry => '입구';

  @override
  String get saltStoryModuleMustSee => '필독';

  @override
  String get saltStoryModuleTodayRead => '오늘의 읽을거리';

  @override
  String get saltStoryModuleEveryoneWatch => '모두가 읽는 콘텐츠';

  @override
  String get saltStoryModuleRecommended => '추천 콘텐츠';

  @override
  String get saltStoryBoard => '스토리 순위';

  @override
  String get saltStoryHotBoard => '인기 순위';

  @override
  String get saltStoryReputationBoard => '평점 순위';

  @override
  String get saltStoryNewBoard => '신간 순위';

  @override
  String get saltStoryLongBoard => '장편 순위';

  @override
  String saltStoryBoardNumber(int index) {
    return '순위 $index';
  }

  @override
  String get saltPillOnShelf => '책장에 추가됨';

  @override
  String get saltPillLiked => '좋아요 표시됨';

  @override
  String get saltBrandLong => '장편';

  @override
  String saltScore(String score) {
    return '평점 $score';
  }

  @override
  String saltUpdatedSections(int count) {
    return '$count개 섹션 업데이트';
  }

  @override
  String saltFinishedWithCount(int count) {
    return '완결 · 전체 $count개 섹션';
  }

  @override
  String saltUpdatedTo(int index) {
    return '$index번째 섹션까지 업데이트';
  }

  @override
  String get saltShelfLiked => '赞同한 콘텐츠';

  @override
  String get saltShelfComments => '인라인 댓글';

  @override
  String get saltShelfHistory => '기록';

  @override
  String get saltShelfLists => '목록';

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
  String get drawerOpen => '사이드바 열기';

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
  String get commonSelect => '선택하세요';

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
  String get settingsAppearance => '외관';

  @override
  String get settingsBackup => '백업';

  @override
  String get settingsAccount => '계정';

  @override
  String get settingsLogs => '로그';

  @override
  String get settingsAboutSection => '정보';

  @override
  String get settingsUpdates => '업데이트';

  @override
  String get settingsData => '데이터';

  @override
  String get settingsAppearanceSubtitle => '다크 모드, 언어 및 표시';

  @override
  String get settingsPersonalizationSubtitle => '홈, 추천 및 콘텐츠 설정';

  @override
  String get settingsBackupSubtitle => 'WebDAV 데이터 동기화';

  @override
  String get settingsAccountSubtitle => '세션 및 로그인 상태';

  @override
  String get settingsLogsSubtitle => '진단 로그 및 문제 해결';

  @override
  String get settingsOpenSourceLicenses => '오픈 소스 라이선스';

  @override
  String get settingsOpenSourceLicensesSubtitle =>
      '앱에서 사용하는 오픈 소스 라이브러리와 라이선스 보기';

  @override
  String get settingsAboutSubtitle => '기본값 복원 및 앱 정보';

  @override
  String get settingsUpdatesSubtitle => '새 버전 확인 및 설치';

  @override
  String get settingsDataSubtitle => '기록, 캐시 및 저장 공간';

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
  String get settingsGithub => 'GitHub 오픈 소스 저장소';

  @override
  String get settingsGithubSubtitle => '소스 코드, 이슈 및 릴리스 기록 보기';

  @override
  String get settingsGithubOpenFailed => 'GitHub 주소를 열 수 없습니다';

  @override
  String get settingsOpenSourceLicensesIntro =>
      '아래에는 지열이 직접 사용하는 오픈 소스 프로젝트와 라이선스 정보가 정리되어 있습니다.';

  @override
  String get settingsOpenSourceLicenseOpenFailed => '프로젝트 주소를 열 수 없습니다';

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
  String get searchFilterAnyType => '모든 유형';

  @override
  String get searchFilterAnswers => '답변만';

  @override
  String get searchFilterArticles => '게시글만';

  @override
  String get searchFilterVideos => '동영상만';

  @override
  String get searchSortRelevance => '관련도순';

  @override
  String get searchSortMostUpvoted => '공감순';

  @override
  String get searchSortNewest => '최신순';

  @override
  String get searchTimeAny => '기간 제한 없음';

  @override
  String get searchTimeDay => '하루 이내';

  @override
  String get searchTimeWeek => '일주일 이내';

  @override
  String get searchTimeMonth => '한 달 이내';

  @override
  String get searchTimeThreeMonths => '3개월 이내';

  @override
  String get searchTimeHalfYear => '6개월 이내';

  @override
  String get searchTimeYear => '1년 이내';

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
  String get detailReadAloud => '본문 소리 내어 읽기';

  @override
  String get detailExportTxt => 'TXT로 내보내기';

  @override
  String get detailExportMarkdown => 'Markdown으로 내보내기';

  @override
  String get detailExportHtml => 'HTML로 내보내기';

  @override
  String get commonExitApp => '뒤로가기를 한 번 더 누르면 종료합니다';

  @override
  String get commonEmoji => '이모지';

  @override
  String get commonRemove => '삭제';

  @override
  String get commonOpenZhihu => 'Zhihu 인증 열기';

  @override
  String get commonExpired => '만료됨';

  @override
  String get commonReport => '신고';

  @override
  String get commonUntitledContent => '제목 없는 콘텐츠';

  @override
  String get commonUntitledObject => '제목 없는 항목';

  @override
  String get commonAuthorProfile => '작성자 프로필 보기';

  @override
  String get commonZhihuUser => 'Zhihu 사용자';

  @override
  String get commonLike => '공감';

  @override
  String get commonUnlike => '공감 취소';

  @override
  String get commonDislike => '반대';

  @override
  String get commonDeleteComment => '댓글 삭제';

  @override
  String get commonCommentActionFailed => '댓글 작업에 실패했습니다. 나중에 다시 시도하세요.';

  @override
  String get commonOpenLink => '링크 열기';

  @override
  String commonReplyCount(String count) {
    return '답글 $count개';
  }

  @override
  String commonViewAllReplies(String count) {
    return '답글 $count개 모두 보기';
  }

  @override
  String get drawerExpired => '만료됨';

  @override
  String get loginHeader => 'Zhihu 로그인';

  @override
  String get loginQrSubtitle => 'Zhihu 앱으로 스캔하여 로그인';

  @override
  String get loginPasswordSubtitle => '계정과 비밀번호로 안전하게 로그인';

  @override
  String get loginPhoneSubtitle => '전화번호로 빠르게 로그인';

  @override
  String get loginProgressPassword => '로그인 진행: 계정 및 비밀번호';

  @override
  String get loginProgressCode => '로그인 진행: 인증 코드';

  @override
  String get loginProgressPhone => '로그인 진행: 전화번호';

  @override
  String get loginAgreementTitle => '로그인 전 확인';

  @override
  String get loginAgreementMessage =>
      '계속하려면 Zhihu 사용자 약관과 개인정보 보호정책을 읽고 동의하세요.';

  @override
  String get loginQrLoading => 'QR 코드 가져오는 중';

  @override
  String get loginQrInvalid => 'Zhihu에서 유효한 QR 코드를 반환하지 않았습니다';

  @override
  String get loginQrScanHint => 'Zhihu 앱을 열고 스캔하세요';

  @override
  String loginQrFetchFailed(String error) {
    return 'QR 코드를 가져오지 못했습니다: $error';
  }

  @override
  String get loginQrExpired => 'QR 코드가 만료되었습니다. 새로 고침을 누르세요.';

  @override
  String get loginQrRiskControl => 'Zhihu 웹에서 보안 확인을 완료한 후 QR 코드를 새로 고침하세요.';

  @override
  String get loginQrConfirm => 'Zhihu 앱에서 로그인을 확인하세요';

  @override
  String get loginVerifying => '로그인 확인 중';

  @override
  String get loginSuccess => '로그인 성공';

  @override
  String get loginQrLabel => 'Zhihu 로그인 QR 코드';

  @override
  String get loginRefreshQr => 'QR 코드 새로 고침';

  @override
  String get loginQrHint =>
      'QR 코드가 만료되기 전에 다른 기기에서 로그인을 확인하세요. 성공하면 현재 계정 슬롯이 유지됩니다.';

  @override
  String get feedbackNotInterested => '관심 없음';

  @override
  String get feedbackReduceRecommendation => '이와 같은 추천 줄이기';

  @override
  String get feedbackTitle => '이런 콘텐츠 줄이기';

  @override
  String get feedbackReduced => '이와 같은 추천을 줄였습니다';

  @override
  String get feedbackInvalidReport => '잘못된 신고 주소';

  @override
  String get feedbackMissingAction => '이 피드백 항목에 실행할 수 있는 작업이 없습니다';

  @override
  String get feedbackLoading => '피드백 옵션을 더 불러오는 중…';

  @override
  String get feedbackReload => '다시 불러오기';

  @override
  String get accountSessionCheckTitle => '로그인 상태 확인';

  @override
  String get accountSessionCheckMessage =>
      'Zhihu에서 계정 세션 이상 신호를 반환했습니다. 현재 로그인 정보는 이 기기에 남아 있습니다. 삭제할까요?';

  @override
  String get accountSessionCheckDetails =>
      '삭제 후에도 설정 > 계정 및 다중 기기 로그인에서 최근 세션을 복원할 수 있습니다. 완전히 삭제하려면 다시 확인해야 합니다.';

  @override
  String get accountSessionClearKeepBackup => '삭제하고 복구 사본 유지';

  @override
  String get accountSessionKeep => '로그인 상태 유지';

  @override
  String get settingsDisableSearchHistoryTitle => '검색 기록을 끌까요?';

  @override
  String get settingsDisableSearchHistoryMessage =>
      '끄면 이 기기에 저장된 검색 기록도 삭제됩니다.';

  @override
  String get settingsDisableAndClear => '끄고 삭제';

  @override
  String get settingsNoSearchHistoryMessage => '검색 기록이 없습니다';

  @override
  String get settingsClearSearchHistoryTitle => '검색 기록을 삭제할까요?';

  @override
  String get settingsClearSearchHistoryMessage => '이 기기에 저장된 검색어만 삭제됩니다.';

  @override
  String get settingsSearchHistoryCleared => '검색 기록을 삭제했습니다';

  @override
  String get settingsDisableBrowsingHistoryTitle => '탐색 기록을 끌까요?';

  @override
  String get settingsDisableBrowsingHistoryMessage =>
      '끄면 이 기기에 저장된 탐색 기록도 삭제됩니다.';

  @override
  String get settingsNoBrowsingHistoryMessage => '탐색 기록이 없습니다';

  @override
  String get settingsClearBrowsingHistoryTitle => '탐색 기록을 삭제할까요?';

  @override
  String get settingsClearBrowsingHistoryMessage =>
      '이 기기에 저장된 열어 본 콘텐츠 색인만 삭제됩니다.';

  @override
  String get settingsBrowsingHistoryCleared => '탐색 기록을 삭제했습니다';

  @override
  String get settingsClearOfflineTitle => '오프라인 챕터를 삭제할까요?';

  @override
  String get settingsClearOfflineMessage =>
      '저장된 염선 본문을 삭제합니다. 다음에 읽거나 내보낼 때 다시 다운로드해야 합니다.';

  @override
  String get settingsClearOfflineAction => '삭제';

  @override
  String settingsOfflineCleared(int count) {
    return '오프라인 챕터 $count개를 삭제했습니다';
  }

  @override
  String get settingsOfflineClearFailed => '오프라인 챕터를 삭제하지 못했습니다. 다시 시도하세요.';

  @override
  String settingsCacheSummary(int count, String size) {
    return '이미지 $count장 · ${size}MB';
  }

  @override
  String get commentEmoji => '이모지';

  @override
  String get commentRemoveSticker => '스티커 삭제';

  @override
  String get commentSelectedImage => '선택한 댓글 이미지';

  @override
  String get commentUploadingImage => '이미지 업로드 중…';

  @override
  String get commentImageAdded => '이미지를 추가했습니다';

  @override
  String get commentRemoveImage => '이미지 삭제';

  @override
  String get commentUsernameRequired => '멘션할 사용자 이름을 입력하세요';

  @override
  String commentMentioned(String name) {
    return '$name님을 멘션했습니다';
  }

  @override
  String get commentLoadingGift => '선물 불러오는 중';

  @override
  String get commentNoGifts => '사용 가능한 선물이 없습니다';

  @override
  String get commentImageAddedPending => '이미지를 추가했습니다. 로그인 후 게시할 수 있습니다.';

  @override
  String get commentSignInRequired => '게시하려면 로그인하세요';

  @override
  String get commentUploadSignInRequired => '이미지를 게시하려면 로그인하세요';

  @override
  String get commentImageUploadNoUrl => '이미지 업로드에서 주소를 반환하지 않았습니다';

  @override
  String commentImagesCount(int count) {
    return '댓글 이미지 $count장';
  }

  @override
  String get commentViewImage => '댓글 이미지 보기';

  @override
  String get commentCloseImage => '이미지 닫기';

  @override
  String get commentSaveImage => '사진에 저장';

  @override
  String commentSavedTo(String location) {
    return '$location에 저장됨';
  }

  @override
  String get commentSaveFailed => '이미지를 저장할 수 없습니다. 나중에 다시 시도해 주세요';

  @override
  String get commentReportUnavailable => '신고 기능은 아직 제공되지 않습니다';

  @override
  String get commentNoText => '표시할 댓글 내용이 없습니다';

  @override
  String get commentAuthorBadge => '작성자';

  @override
  String get commentQuestionAuthor => '질문 작성자';

  @override
  String commentAuthorSemantics(String name) {
    return '댓글 작성자 $name';
  }

  @override
  String get feedHotBadge => '인기';

  @override
  String metricVoteup(String count) {
    return '공감 $count';
  }

  @override
  String metricFavorite(String count) {
    return '저장 $count';
  }

  @override
  String metricComment(String count) {
    return '댓글 $count개';
  }

  @override
  String metricThanks(String count) {
    return '감사 $count';
  }

  @override
  String metricViews(String count) {
    return '조회 $count';
  }

  @override
  String get metricThanked => '답변에 감사 표시함';

  @override
  String get metricFavorited => '답변을 저장함';

  @override
  String metricFollowers(String count) {
    return '팔로워 $count명';
  }

  @override
  String metricAnswers(String count) {
    return '답변 $count개';
  }

  @override
  String metricArticles(String count) {
    return '게시글 $count개';
  }

  @override
  String metricItems(String count) {
    return '콘텐츠 $count개';
  }

  @override
  String get contentTypeAnswer => '답변';

  @override
  String get contentTypeArticle => '게시글';

  @override
  String get contentTypePeople => '사용자';

  @override
  String get contentTypeQuestion => '질문';

  @override
  String get contentTypeColumn => '칼럼';

  @override
  String get contentTypeTopic => '토픽';

  @override
  String get contentTypeIdea => '아이디어';

  @override
  String get contentTypeComment => '댓글';

  @override
  String accountSwitchedTo(String name) {
    return '$name(으)로 전환했습니다';
  }

  @override
  String get accountSessionRestoreFailed =>
      '계정 세션 확인에 실패했습니다. 이전 로그인 상태를 복원했습니다.';

  @override
  String get collectionsLoginRequired => 'Zhihu에 로그인하면 내 컬렉션을 볼 수 있습니다';

  @override
  String get collectionsTitle => '내 컬렉션';

  @override
  String get collectionTitle => '컬렉션';

  @override
  String get collectionEmpty => '이 컬렉션에는 아직 콘텐츠가 없습니다';

  @override
  String get collectionsEmpty => '만들거나 저장한 콘텐츠가 없습니다';

  @override
  String get loginPasswordRequired => '비밀번호를 입력하세요';

  @override
  String get loginQrSaveFailed =>
      'QR 로그인에 성공했지만 계정 슬롯을 저장하지 못했습니다. 나중에 다시 시도하세요.';

  @override
  String get loginHumanVerification => '먼저 본인 확인을 완료하세요';

  @override
  String get loginCodeSendFailed => '인증 코드를 보내지 못했습니다. 나중에 다시 시도하세요.';

  @override
  String get loginFailedNetwork => '로그인에 실패했습니다. 네트워크를 확인하고 다시 시도하세요.';

  @override
  String get loginFailedCredentials => '로그인에 실패했습니다. 계정과 비밀번호를 확인하고 다시 시도하세요.';

  @override
  String get loginGetCode => '인증 코드 받기';

  @override
  String get loginContinueSignIn => '로그인 계속하기';

  @override
  String get loginPasswordSignIn => '비밀번호로 로그인';

  @override
  String get loginPhoneSignIn => '전화번호로 로그인';

  @override
  String get loginQrSignIn => 'QR 코드로 로그인';

  @override
  String get loginAccountAppeal => '계정 이의 제기';

  @override
  String get loginAccountAppealHint => '문제가 있나요? 계정 이의 제기';

  @override
  String get loginPhonePlaceholder => '국가/지역 번호 + 전화번호';

  @override
  String get loginAccountPlaceholder => '전화번호 / 이메일';

  @override
  String get loginPasswordPlaceholder => '비밀번호';

  @override
  String get loginCodePlaceholder => '6자리 인증 코드 입력';

  @override
  String loginCodeSent(String phone) {
    return '$phone(으)로 인증 코드를 보냈습니다';
  }

  @override
  String get loginChangePhone => '전화번호 변경';

  @override
  String get loginNoCode => '받지 못했나요?';

  @override
  String loginResendAfter(int seconds) {
    return '$seconds초 후 다시 시도';
  }

  @override
  String get loginAgree => '동의';

  @override
  String get loginUserAgreement => 'Zhihu 사용자 약관';

  @override
  String get loginPrivacyPolicy => ' 및 개인정보 보호정책';

  @override
  String get commonSelected => ' 선택됨';

  @override
  String get searchSuggestion => '검색어 자동 완성';

  @override
  String searchSuggestionFor(String query) {
    return '검색 제안 $query';
  }

  @override
  String searchSearching(String query) {
    return '“$query” 검색 중';
  }

  @override
  String get searchDesktopHint =>
      '결과 목록을 스크롤하여 더 불러오고 카드를 선택하면 세부 정보를 볼 수 있습니다.';

  @override
  String get searchRelated => '관련 검색';

  @override
  String get searchRecentContent => '최근 콘텐츠';

  @override
  String get searchContinue => '계속 검색';

  @override
  String get searchUntitledNovel => '제목 없는 소설';

  @override
  String get searchUntitledVideo => '제목 없는 동영상';

  @override
  String searchMetricFollows(String count) {
    return '팔로우 $count개';
  }

  @override
  String searchMetricQuestions(String count) {
    return '질문 $count개';
  }

  @override
  String searchMetricMembers(String count) {
    return '멤버 $count명';
  }

  @override
  String searchMetricDiscussions(String count) {
    return '토론 $count개';
  }

  @override
  String searchMetricParticipants(String count) {
    return '참여자 $count명';
  }

  @override
  String searchMetricLiveContent(String count) {
    return '라이브 콘텐츠 $count개';
  }

  @override
  String searchMetricPlayCount(String count) {
    return '재생 $count회';
  }

  @override
  String searchHotScoreWan(String value) {
    return '$value만';
  }

  @override
  String get userTitle => '사용자';

  @override
  String get userProfileTitle => '사용자 프로필';

  @override
  String get userFindTitle => '사용자 찾기';

  @override
  String get userFindSubtitle => '프로필 링크의 사용자 토큰을 입력해 공개 프로필과 콘텐츠 목록을 확인하세요';

  @override
  String get userIdHint => '사용자 ID';

  @override
  String get userViewProfile => '사용자 프로필 보기';

  @override
  String get userContentRelations => '콘텐츠 및 관계';

  @override
  String get userEmpty => '아직 사용자가 없습니다';

  @override
  String get userSignInToFollow => '사용자를 팔로우하려면 로그인하세요';

  @override
  String get userFollowed => '팔로우 중';

  @override
  String get userFollow => '+ 팔로우';

  @override
  String userSearchHint(String name) {
    return '$name이(가) 게시한 콘텐츠 검색';
  }

  @override
  String userSearchPrompt(String name) {
    return '$name의 답변, 글, 아이디어 검색';
  }

  @override
  String get userNoResults => '일치하는 콘텐츠가 없습니다';

  @override
  String get userLoadFailed => '사용자 프로필을 열 수 없습니다';

  @override
  String get userInfo => '사용자 정보';

  @override
  String get userFollowers => '팔로워';

  @override
  String get userFollowingPeople => '팔로우 중인 사용자';

  @override
  String get userAnswers => '사용자 답변';

  @override
  String get userArticles => '사용자 글';

  @override
  String get userCreatedArticles => '사용자가 작성한 글';

  @override
  String get userContributedArticles => '기여한 글';

  @override
  String get userColumns => '사용자 칼럼';

  @override
  String get userFollowingColumns => '팔로우 중인 칼럼';

  @override
  String get userFollowingQuestions => '팔로우 중인 질문';

  @override
  String get userFollowingCollections => '팔로우 중인 컬렉션';

  @override
  String get userFollowingTopics => '팔로우 중인 주제';

  @override
  String get userIdRequired => '사용자 ID를 입력하세요';

  @override
  String get sessionTitle => '계정';

  @override
  String get sessionSignInZhihu => 'Zhihu 로그인';

  @override
  String get sessionPhoneLogin => '전화번호 로그인';

  @override
  String get sessionWebLogin => '웹 로그인';

  @override
  String get sessionSaved => '로그인 정보가 저장되었습니다';

  @override
  String get sessionCleared => '로그인 정보가 삭제되었습니다';

  @override
  String get sessionImport => '로그인 정보 가져오기';

  @override
  String get sessionShowSensitive => '민감한 값을 잠시 표시';

  @override
  String get sessionHideSensitive => '민감한 값을 다시 숨기기';

  @override
  String get sessionAdvanced => '고급 설정';

  @override
  String get sessionOptionalCookie => 'Cookie (선택 사항)';

  @override
  String get sessionOptionalMsId => 'X-MS-ID (선택 사항)';

  @override
  String get sessionManualZse => '수동 X-Zse-96';

  @override
  String get sessionSignTarget => '서명 대상';

  @override
  String get sessionOtherHeaders => '기타 Header';

  @override
  String get sessionSaving => '저장 중…';

  @override
  String get sessionSave => '저장';

  @override
  String get sessionClear => '로그인 정보 삭제';

  @override
  String get contentTypeContent => '콘텐츠';

  @override
  String get userProfileSearchContent => '이 사용자의 콘텐츠 검색';

  @override
  String get userProfileCopyLink => '프로필 링크 복사';

  @override
  String get userProfileHomeTab => '홈';

  @override
  String get userProfileCreationsTab => '창작';

  @override
  String get userProfileActivitiesTab => '활동';

  @override
  String get userProfileVoteupsTab => '추천함';

  @override
  String get userProfileFollowersList => '팔로워';

  @override
  String get userProfileFollowingList => '팔로잉';

  @override
  String get userProfileLoginRequired => '이 기능을 사용하려면 로그인하세요';

  @override
  String get userProfileUnfollowTitle => '팔로우를 취소할까요?';

  @override
  String userProfileUnfollowMessage(String name) {
    return '$name을(를) 더 이상 팔로우하지 않습니다';
  }

  @override
  String get userProfileUnfollowAction => '팔로우 취소';

  @override
  String get userProfileLinkCopied => '프로필 링크를 복사했습니다';

  @override
  String userProfileIpLocation(String location) {
    return 'IP 위치: $location';
  }

  @override
  String get userProfileFollowers => '팔로워';

  @override
  String get userProfileFollowing => '팔로잉';

  @override
  String get userProfileUserAnswers => '사용자 답변';

  @override
  String get userProfileUserArticles => '사용자 글';

  @override
  String get userProfileCreatedArticles => '작성한 글';

  @override
  String get userProfileUserCreatedArticles => '사용자가 작성한 글';

  @override
  String get userProfileContributedArticles => '기여한 글';

  @override
  String get userProfileUserContributedArticles => '사용자가 기여한 글';

  @override
  String get userProfileCreatedColumns => '만든 칼럼';

  @override
  String get userProfileUserColumns => '사용자 칼럼';

  @override
  String get userProfileFollowingColumns => '팔로우한 칼럼';

  @override
  String get userProfileFollowingQuestions => '팔로우한 질문';

  @override
  String get userProfileFollowingCollections => '팔로우한 컬렉션';

  @override
  String get userProfileFollowingTopics => '팔로우한 주제';

  @override
  String get userProfileReceivedUpvotes => '받은 추천';

  @override
  String get userProfileReceivedThanks => '받은 감사';

  @override
  String get userProfileReceivedFavorites => '받은 저장';

  @override
  String get userProfilePersonalInfo => '개인 정보';

  @override
  String get userProfileAchievements => '성과';

  @override
  String get userProfilePublicCreations => '공개 창작물';

  @override
  String get userProfileFollowingAndCollections => '팔로잉 및 컬렉션';

  @override
  String get userProfileFollowingHidden => '이 사용자는 팔로잉 목록을 숨겼습니다';

  @override
  String get userProfileFollowedYou => '회원님을 팔로우함';

  @override
  String get userProfileMutualFollow => '서로 팔로우';

  @override
  String get userProfileMessage => '메시지';

  @override
  String get userProfileNoPublicContent => '아직 공개 콘텐츠가 없습니다';

  @override
  String get webdavTitle => 'WebDAV 동기화';

  @override
  String get webdavIntroTitle => '기기 간 로컬 콘텐츠 동기화';

  @override
  String get webdavIntroMessage =>
      '검색 기록, 탐색 기록, 염선 오프라인 챕터/책장 및 답변 캐시만 동기화합니다. 로그인 정보, 쿠키, 기기 식별자와 이 설정은 업로드하지 않습니다.';

  @override
  String get webdavConnectionSettings => '연결 설정';

  @override
  String get webdavProviderType => '서비스 유형';

  @override
  String get webdavProviderGeneric => '일반 WebDAV';

  @override
  String get webdavProviderGoogle => 'Google Drive(WebDAV 게이트웨이)';

  @override
  String get webdavProviderOneDrive => 'Microsoft OneDrive(WebDAV)';

  @override
  String get webdavProviderGenericDescription =>
      'WebDAV를 지원하는 클라우드 드라이브, NAS 및 자체 호스팅 서비스에 사용합니다.';

  @override
  String get webdavProviderGoogleDescription =>
      'Google Drive는 기본 WebDAV를 제공하지 않습니다. Google Drive에 연결된 WebDAV 게이트웨이 주소를 입력하세요.';

  @override
  String get webdavProviderOneDriveDescription =>
      'OneDrive의 WebDAV 호환 엔드포인트를 입력하세요. 일부 계정이나 서비스에서는 이전 엔드포인트를 제한할 수 있습니다.';

  @override
  String get webdavProviderGenericHint => 'https://dav.example.com/';

  @override
  String get webdavProviderGoogleHint => 'https://gateway.example.com/dav/';

  @override
  String get webdavProviderOneDriveHint => 'https://d.docs.live.net/<CID>/';

  @override
  String get webdavEndpoint => 'WebDAV 주소';

  @override
  String get webdavHttpsHint => 'HTTPS만 지원하며 URL에 비밀번호를 넣지 마세요';

  @override
  String get webdavRemoteDirectory => '원격 디렉터리';

  @override
  String get webdavRemoteDirectoryHint =>
      'v1, answers, chapters 하위 디렉터리를 자동으로 만듭니다';

  @override
  String get webdavAuthMethod => '인증 방식';

  @override
  String get webdavAuthBasic => '사용자 이름 및 비밀번호/앱 비밀번호';

  @override
  String get webdavAuthBearer => 'Bearer 액세스 토큰';

  @override
  String get webdavUsername => '사용자 이름';

  @override
  String get webdavPasswordOrAppPassword => '비밀번호/앱 비밀번호';

  @override
  String get webdavAccessToken => '액세스 토큰';

  @override
  String get webdavEnable => 'WebDAV 동기화 사용';

  @override
  String get webdavEnableSubtitle => '끄면 네트워크 동기화를 중지하지만 저장된 로컬 설정은 삭제하지 않습니다';

  @override
  String get webdavStartupSync => '시작 시 자동 동기화';

  @override
  String get webdavStartupSyncSubtitle =>
      '첫 화면을 막지 않고 백그라운드에서 실행하며 실패 후 수동으로 다시 시도할 수 있습니다';

  @override
  String get webdavSyncContent => '동기화할 콘텐츠';

  @override
  String get webdavSyncContentSummary =>
      '• 검색 및 탐색 기록\n• 염선 책장 및 다운로드한 챕터\n• 답변 캐시(복원 후 수동으로 새로 고쳐 최신 콘텐츠를 가져올 수 있음)';

  @override
  String webdavStatus(String message) {
    return '상태: $message';
  }

  @override
  String get webdavLoading => 'WebDAV 설정을 읽는 중';

  @override
  String get webdavConfiguredStatus => 'WebDAV가 설정됨';

  @override
  String get webdavNotConfigured => 'WebDAV가 설정되지 않음';

  @override
  String get webdavSettingsSaved => 'WebDAV 설정을 저장함';

  @override
  String get webdavClosedStatus => 'WebDAV를 비활성화함';

  @override
  String get webdavTesting => 'WebDAV 연결을 테스트하는 중';

  @override
  String get webdavSyncing => '검색 기록, 탐색 기록, 오프라인 소설, 답변 캐시를 동기화하는 중';

  @override
  String webdavSyncCompleted(String uploaded, String downloaded) {
    return '동기화 완료: $uploaded개 업로드, $downloaded개 복원';
  }

  @override
  String webdavConfigFailed(String error) {
    return 'WebDAV 설정이 올바르지 않음: $error';
  }

  @override
  String get webdavSyncNotEnabled => 'WebDAV 동기화가 비활성화됨';

  @override
  String get webdavNotSynced => '아직 동기화하지 않음';

  @override
  String get webdavSyncNow => '지금 동기화';

  @override
  String get webdavTestConnection => '연결 테스트';

  @override
  String get webdavDisable => '동기화 끄기';

  @override
  String get webdavClearLocalSettings => '로컬 설정 및 인증 정보 삭제';

  @override
  String webdavLoadFailed(String error) {
    return 'WebDAV 설정을 읽지 못했습니다: $error';
  }

  @override
  String webdavSaveFailed(String error) {
    return '저장하지 못했습니다: $error';
  }

  @override
  String get webdavConnected => 'WebDAV에 연결됨';

  @override
  String webdavConnectionFailed(String error) {
    return '연결 실패: $error';
  }

  @override
  String webdavSyncFailed(String error) {
    return '동기화 실패: $error';
  }

  @override
  String get webdavDisabled =>
      'WebDAV 동기화를 껐습니다. 인증 정보는 비공개 로컬 데이터베이스에 남아 있습니다';

  @override
  String get webdavClearTitle => 'WebDAV 설정을 삭제할까요?';

  @override
  String get webdavClearMessage =>
      '로컬에 저장된 WebDAV 주소, 계정 및 인증 정보를 삭제하며 원격 동기화 데이터는 삭제하지 않습니다.';

  @override
  String get webdavCleared => '로컬 WebDAV 설정 및 인증 정보를 삭제했습니다';

  @override
  String webdavClearFailed(String error) {
    return '삭제 실패: $error';
  }

  @override
  String get webdavInvalidEndpoint => '잘못된 WebDAV 주소';

  @override
  String get webdavHttpsRequired => 'WebDAV 주소는 HTTPS를 사용해야 합니다';

  @override
  String get webdavEndpointCredentials =>
      'WebDAV 주소에 인증 정보, 쿼리 매개변수 또는 프래그먼트를 포함할 수 없습니다';

  @override
  String get webdavCredentialCharacters =>
      'WebDAV 인증 정보에 줄바꿈이나 제어 문자를 포함할 수 없습니다';

  @override
  String get webdavInvalidDirectory => '잘못된 원격 디렉터리';

  @override
  String get webdavUsernameRequired => '비밀번호 인증에는 사용자 이름이 필요합니다';

  @override
  String get webdavSecretRequired => '비밀번호, 앱 비밀번호 또는 액세스 토큰을 입력하세요';

  @override
  String get webdavCredentialTooLong => '액세스 인증 정보가 너무 깁니다';

  @override
  String get commonCopy => '복사';

  @override
  String get commonSelectAll => '모두 선택';

  @override
  String get detailDownvote => '반대';

  @override
  String get detailDownvoted => '반대함';

  @override
  String get detailCommentAction => '댓글';

  @override
  String get detailViewComments => '댓글 보기';

  @override
  String detailViewCommentsCount(String count) {
    return '댓글 $count개 보기';
  }

  @override
  String get detailFavorite => '저장';

  @override
  String detailFavoriteCount(String count) {
    return '$count개 저장';
  }

  @override
  String get detailAuthor => '작성자';

  @override
  String get detailFollowed => '팔로잉';

  @override
  String get detailFollow => '팔로우';

  @override
  String get detailUnfollowAuthor => '작성자 팔로우 취소';

  @override
  String get detailFollowAuthor => '작성자 팔로우';

  @override
  String get detailTop => '위로';

  @override
  String get detailBackToTop => '게시물 상단으로';

  @override
  String get detailBottom => '아래로';

  @override
  String get detailJumpToBottom => '게시물 하단으로';

  @override
  String get detailCollapseMore => '추가 기능 닫기';

  @override
  String get detailMoreActions => '추가 작업';

  @override
  String get detailExportActions => '콘텐츠 내보내기';

  @override
  String get detailSignInFromMe => '먼저 ‘나’ 페이지에서 로그인하세요.';

  @override
  String get detailWriteAnswerSubtitle => '이 질문에 새 답변 만들기';

  @override
  String detailRefreshContent(String content) {
    return '$content 새로 고침';
  }

  @override
  String get detailRefreshSubtitle => '캐시를 무시하고 최신 콘텐츠 가져오기';

  @override
  String get detailSearchSubtitle => '키워드를 입력하여 본문에서 찾기';

  @override
  String detailReadAloudSubtitle(String content) {
    return '시스템 음성으로 이 $content 읽기';
  }

  @override
  String get detailExportTextSubtitle => '현재 제목, 작성자, 본문 저장';

  @override
  String detailExportDocument(String format) {
    return '$format(으)로 내보내기';
  }

  @override
  String get detailExportPdfSubtitle => '공유 및 인쇄용 문서 만들기';

  @override
  String get detailExportDocumentSubtitle => '제목, 작성자, 문단 및 본문 이미지 링크 유지';

  @override
  String get detailCopyAll => '전체 텍스트 복사';

  @override
  String get detailCopySubtitle => '현재 제목, 작성자, 본문 복사';

  @override
  String get detailClearCache => '이 캐시 삭제';

  @override
  String get detailInviteAnswer => '답변 초대';

  @override
  String get detailCopyAnswer => '답변 내용 복사';

  @override
  String detailSelectionTooShort(int count) {
    return '최소 $count자를 선택하세요';
  }

  @override
  String get detailCommentSelection => '이 문단에 댓글';

  @override
  String get detailCommentHint => '댓글을 입력하세요';

  @override
  String detailActionUnavailable(String action) {
    return '$action 기능을 사용할 수 없습니다';
  }

  @override
  String get detailSignInRequired => '이 기능을 사용하려면 로그인하세요';

  @override
  String get detailUnfollowTitle => '팔로우를 취소할까요?';

  @override
  String detailUnfollowMessage(String name) {
    return '$name을(를) 더 이상 팔로우하지 않습니다';
  }

  @override
  String get detailUnfollowAction => '팔로우 취소';

  @override
  String get detailCacheCleared => '이 답변의 캐시를 삭제했습니다';

  @override
  String get detailImagePlaceholder => '[이미지]';

  @override
  String get detailVideoPlaceholder => '[동영상]';

  @override
  String detailImageCount(int count) {
    return '본문 이미지 $count장';
  }

  @override
  String get detailViewImage => '본문 이미지 원본 보기';

  @override
  String get detailCloseImage => '이미지 닫기';

  @override
  String get detailSaveImage => '사진에 저장';

  @override
  String get detailImageSaved => '이미지가 저장되었습니다';

  @override
  String get detailImageSavedTo => '사진에 저장되었습니다';

  @override
  String get detailImageSaveFailed => '이미지를 저장할 수 없습니다. 나중에 다시 시도해 주세요';

  @override
  String get detailMyAnswer => '내 답변';

  @override
  String detailAuthorPrefix(String name) {
    return '작성자: $name';
  }

  @override
  String get detailNoExportableBody => '내보낼 답변 본문이 없습니다';

  @override
  String get detailAnswerDetails => '답변 세부 정보';

  @override
  String detailExportedTo(String location) {
    return '$location에 내보냈습니다';
  }

  @override
  String get detailExportFailed => '내보내기에 실패했습니다. 다시 시도하세요.';

  @override
  String detailDocumentExported(String format, String location) {
    return '$format(으)로 내보냈습니다: $location';
  }

  @override
  String get detailStoppedReading => '읽기를 중지했습니다';

  @override
  String get detailNoReadableBody => '읽어 줄 답변 본문이 없습니다';

  @override
  String get detailReading => '본문을 읽는 중';

  @override
  String get detailTtsUnavailable => '시스템 음성을 사용할 수 없습니다. 음성 패키지를 설치하세요.';

  @override
  String get detailNoCopyableText => '복사할 답변 본문이 없습니다';

  @override
  String get detailCopied => '전체 텍스트를 복사했습니다';

  @override
  String get detailSearchBodyTitle => '본문 검색';

  @override
  String get detailKeywordHint => '키워드 입력';

  @override
  String get detailLocate => '찾기';

  @override
  String detailBodyNotFound(String keyword) {
    return '본문에서 “$keyword”을(를) 찾지 못했습니다';
  }

  @override
  String detailLocated(String keyword) {
    return '“$keyword” 위치로 이동했습니다';
  }

  @override
  String get detailWriteAnswer => '답변 작성';

  @override
  String get detailAnswerRequired => '답변 내용을 입력하세요';

  @override
  String get detailAnswerPublished => '답변을 게시했습니다';

  @override
  String get commentSentence => '문장 댓글';

  @override
  String commentSentenceCount(String count) {
    return '문장 댓글 $count개';
  }

  @override
  String get commentWrite => '댓글 작성';

  @override
  String commentReplyTitle(String target) {
    return '$target에 답글';
  }

  @override
  String get commentReplyTargetComment => '이 댓글';

  @override
  String get commentPublished => '댓글을 게시했습니다.';

  @override
  String get commentReplyPublished => '답글을 게시했습니다.';

  @override
  String get commentDeleteTitle => '댓글을 삭제할까요?';

  @override
  String get commentDeleteMessage => '이 댓글과 현재 표시 관계가 목록에서 삭제됩니다.';

  @override
  String get commentDeleted => '댓글을 삭제했습니다.';

  @override
  String get commentDeleteReplyTitle => '답글을 삭제할까요?';

  @override
  String get commentDeleteReplyMessage => '삭제한 내용은 복구할 수 없습니다.';

  @override
  String get commentReplyDeleted => '답글을 삭제했습니다.';

  @override
  String get commentRepliesTitle => '댓글 답글';

  @override
  String get commentNoReplies => '아직 답글이 없습니다';

  @override
  String get commentNoComments => '아직 댓글이 없습니다';

  @override
  String commentReplyCount(String count) {
    return '답글 $count개';
  }

  @override
  String get commentEditorUnavailable => '댓글을 작성할 수 없습니다';

  @override
  String get commentGif => 'GIF';

  @override
  String get commentExpandEditor => '편집기 펼치기';

  @override
  String get contentFilterClearTitle => '필터링 통계를 지울까요?';

  @override
  String get contentFilterClearMessage =>
      '기기에 저장된 기록만 삭제합니다. Zhihu 계정과 서버 피드백 설정은 변경되지 않습니다.';

  @override
  String get contentFilterCleared => '필터링 통계를 지웠습니다';

  @override
  String get contentFilterClearStats => '통계 지우기';

  @override
  String get contentFilterStatsTitle => '콘텐츠 필터링 통계';

  @override
  String get contentFilterStatsLabel => '콘텐츠 필터링 통계';

  @override
  String get contentFilterActions => '피드백 작업';

  @override
  String get contentFilterHidden => '숨긴 콘텐츠';

  @override
  String get contentFilterReasons => '필터링 이유';

  @override
  String get contentFilterHint =>
      '홈 카드에서 ‘이런 콘텐츠 덜 보기’를 선택하면 이유별 누계가 여기에 표시됩니다.';

  @override
  String contentFilterCount(String count) {
    return '$count회';
  }

  @override
  String get contentFilterLatest => '최근 기록';

  @override
  String get contentFilterEmpty => '기록 없음';

  @override
  String get contentFilterSummaryEmpty => '줄인 콘텐츠의 이유와 결과를 기록합니다';

  @override
  String contentFilterSummary(String actions, String hidden, String reasons) {
    return '$actions회 작업 · $hidden개 숨김 · $reasons가지 이유';
  }

  @override
  String get accountSessionsNoCurrent => '저장할 현재 로그인 세션이 없습니다';

  @override
  String get accountSessionsSaved => '현재 로그인 세션을 저장했습니다';

  @override
  String get accountSessionsSaveFailed => '계정 슬롯을 저장하지 못했습니다. 나중에 다시 시도하세요.';

  @override
  String accountSessionsSwitched(String name) {
    return '$name(으)로 전환했습니다';
  }

  @override
  String get accountSessionsSwitchFailed => '계정을 전환하지 못했습니다. 나중에 다시 시도하세요.';

  @override
  String get accountSessionsDeleteTitle => '계정 슬롯을 삭제할까요?';

  @override
  String accountSessionsDeleteActiveMessage(String name) {
    return '기기에 저장된 $name만 삭제합니다. 현재 기기의 세션에서는 로그아웃하고 복구 가능한 사본을 남기며, 다른 기기에서는 로그아웃하지 않습니다.';
  }

  @override
  String accountSessionsDeleteMessage(String name) {
    return '기기에 저장된 $name만 삭제합니다. 다른 기기에서는 로그아웃하지 않습니다.';
  }

  @override
  String get accountSessionsDeleted => '기기의 계정 슬롯을 삭제했습니다';

  @override
  String get accountSessionsDeleteFailed => '계정 슬롯을 삭제하지 못했습니다. 나중에 다시 시도하세요.';

  @override
  String get accountSessionsNoRecovery => '복구할 수 있는 계정 세션이 없습니다';

  @override
  String get accountSessionsRestored => '최근에 삭제한 계정 세션을 복구했습니다';

  @override
  String get accountSessionsRestoreSaveFailed =>
      '세션은 복구했지만 계정 슬롯 저장에 실패했습니다. 나중에 다시 시도하세요.';

  @override
  String get accountSessionsPurgeTitle => '복구 자격 증명을 영구적으로 지울까요?';

  @override
  String get accountSessionsPurgeMessage =>
      '마지막 정리 후 보관된 복구 사본을 영구적으로 삭제합니다. 이후에는 복구할 수 없습니다.';

  @override
  String get accountSessionsPurgeAction => '영구 삭제';

  @override
  String get accountSessionsPurged => '복구 자격 증명을 영구적으로 삭제했습니다';

  @override
  String get accountSessionsPurgeFailed => '복구 자격 증명을 지우지 못했습니다. 나중에 다시 시도하세요.';

  @override
  String get accountSessionsTitle => '계정 및 여러 기기 로그인';

  @override
  String get accountSessionsSaveCurrent => '현재 세션 저장';

  @override
  String get accountSessionsIntro =>
      'QR 코드 또는 전화번호로 로그인한 세션은 기기의 비공개 자격 증명 데이터베이스에 저장됩니다. 전환 전에 /people/self를 다시 확인하며 다른 기기에서는 로그아웃하지 않습니다.';

  @override
  String get accountSessionsRecoveryTitle => '최근 정리한 로그인 정보';

  @override
  String get accountSessionsRecoveryMessage =>
      '서버 만료 확인 후 정리된 계정은 기기의 복구 영역에 남아 있습니다. 여기서 복구하거나 영구 삭제할 수 있습니다.';

  @override
  String get accountSessionsRestore => '복구';

  @override
  String get accountSessionsEmptyTitle => '저장된 계정 슬롯이 없습니다';

  @override
  String get accountSessionsEmptyMessage => '로그인하면 여기서 여러 기기의 세션을 관리할 수 있습니다.';

  @override
  String get accountSessionsQr => 'QR 코드 세션';

  @override
  String get accountSessionsPassword => '전화번호/비밀번호 세션';

  @override
  String get accountSessionsCurrent => '사용 중';

  @override
  String get accountSessionsExpired => '만료됨';

  @override
  String get accountSessionsMenu => '계정 작업';

  @override
  String get accountSessionsSwitch => '전환 및 확인';

  @override
  String get accountSessionsRemoveSlot => '슬롯 삭제';

  @override
  String get accountSessionsAdd => '계정 추가 / QR 코드로 로그인';

  @override
  String get accountDefaultName => 'Zhihu 계정';

  @override
  String accountMaskedName(String id) {
    return '계정 $id';
  }

  @override
  String get browsingHistoryClearTitle => '검색 기록을 지울까요?';

  @override
  String get browsingHistoryClearMessage => 'Zhiyue가 기기에 저장한 검색 기록만 삭제합니다.';

  @override
  String get browsingHistoryTitle => '검색 기록';

  @override
  String get browsingHistoryClear => '검색 기록 지우기';

  @override
  String get browsingHistoryEmptyTitle => '검색 기록이 없습니다';

  @override
  String get browsingHistoryEmptyMessage => '열어 본 답변, 글, 질문 또는 주제가 여기에 표시됩니다';

  @override
  String browsingHistoryToday(String time) {
    return '오늘 $time';
  }

  @override
  String browsingHistoryDate(int month, int day, String time) {
    return '$month/$day $time';
  }

  @override
  String get updateCheckFailed => '업데이트를 확인하지 못했습니다. 나중에 다시 시도하세요.';

  @override
  String get updateAllowInstallTitle => '앱 설치 허용';

  @override
  String get updateAllowInstallMessage =>
      'Android에서 Zhiyue가 다운로드한 업데이트를 설치하려면 권한이 필요합니다. 활성화한 뒤 이 화면으로 돌아와 ‘다운로드 및 설치’를 다시 누르세요.';

  @override
  String get updateOpenSettings => '설정으로 이동';

  @override
  String get updateCachedInstalling => '다운로드한 업데이트를 사용하여 Android 설치 프로그램을 여는 중';

  @override
  String get updateVerifiedInstalling => '업데이트를 확인했으며 Android 설치 프로그램을 여는 중';

  @override
  String get updateInstallFailed => '업데이트 설치에 실패했습니다. 다시 시도하세요.';

  @override
  String get updateTitle => '앱 업데이트';

  @override
  String get updateAppName => 'Zhiyue';

  @override
  String get updateReadingVersion => '버전 정보 읽는 중';

  @override
  String updateCurrentVersion(String version, String code) {
    return '현재 버전 $version ($code)';
  }

  @override
  String get updateUnsupportedTitle => '앱 내 설치를 지원하지 않음';

  @override
  String get updateUnsupportedMessage =>
      '안전한 다운로드, 확인 및 시스템 설치 프로그램은 현재 Android에서만 활성화되어 있습니다.';

  @override
  String get updateCheckingTitle => '업데이트 확인 중';

  @override
  String get updateCheckingMessage => 'GitHub Releases에서 안정 버전을 읽는 중입니다.';

  @override
  String get updateLatestTitle => '최신 상태입니다';

  @override
  String get updateNoRelease => '안정 채널에 게시된 버전이 없습니다.';

  @override
  String updateLatestVersion(String version, String code) {
    return '안정 채널의 최신 버전은 $version ($code)입니다.';
  }

  @override
  String get updateChecking => '확인 중';

  @override
  String get updateRecheck => '다시 확인';

  @override
  String get updateSecurity => '업데이트 보안';

  @override
  String get updateSecuritySourceTitle => 'GitHub Releases';

  @override
  String get updateSecuritySourceDetail =>
      '지정한 GitHub 저장소에서 규격에 맞는 안정 버전 arm64 APK만 허용합니다.';

  @override
  String get updateSecurityIntegrityTitle => '무결성 확인';

  @override
  String get updateSecurityIntegrityDetail =>
      '다운로드 후 GitHub에서 제공한 SHA-256 요약과 파일 크기를 확인합니다.';

  @override
  String get updateSecurityInstallerTitle => '시스템 설치 프로그램 사용';

  @override
  String get updateSecurityInstallerDetail =>
      'Android 설치 프로그램을 열기 전에 패키지 이름, 버전 및 인증서 연속성도 확인합니다.';

  @override
  String get updateImportant => '중요 업데이트';

  @override
  String updateNewVersion(String version) {
    return '새 버전 $version';
  }

  @override
  String get updateImportantFound => '중요 업데이트가 있습니다';

  @override
  String get updatePublishedToReleases => '새 버전이 GitHub Releases에 게시되었습니다.';

  @override
  String get updateLater => '나중에';

  @override
  String get updateView => '업데이트 보기';

  @override
  String updateVersion(String version) {
    return '버전 $version';
  }

  @override
  String updateReleaseMeta(String size, String code) {
    return '$size APK · 안정 채널 · 빌드 $code';
  }

  @override
  String get updateViewDetails => '업데이트 인터페이스 세부정보 보기';

  @override
  String get updateVerifiedManifest => '매니페스트, 패키지 크기 및 SHA-256 확인됨';

  @override
  String get updateReleaseId => '릴리스 ID';

  @override
  String get updatePublishedAt => '게시 시간';

  @override
  String get updateReleaseTag => 'Release 태그';

  @override
  String get updatePackageType => '패키지 유형';

  @override
  String get updatePackageSha256 => 'APK SHA-256';

  @override
  String get updateManifestResponse => '매니페스트 응답';

  @override
  String updateDownloadProgress(String received, String total) {
    return 'APK 다운로드 중 $received / $total';
  }

  @override
  String get updateVerifyingPackage => '패키지 확인 중';

  @override
  String get updateContinueInstall => '설치 계속';

  @override
  String get updateDownloadInstall => '다운로드 및 설치';

  @override
  String get updateValidation => '확인됨';

  @override
  String updateManifestSummary(String size) {
    return '$size 매니페스트';
  }

  @override
  String get profileChange => '변경';

  @override
  String get profileUserFallback => 'Zhihu 사용자';

  @override
  String get profileAnswers => '답변';

  @override
  String get profileArticles => '文章';

  @override
  String get profileIdeas => '아이디어';

  @override
  String get profileCollections => '컬렉션';

  @override
  String get profileUpvotes => '赞同';

  @override
  String get profileFollowers => '팔로워';

  @override
  String get profileFollowing => '팔로잉';

  @override
  String get profileEdit => '프로필 편집';

  @override
  String get profileAllDetails => '모든 프로필 정보';

  @override
  String get profileMyContent => '내 콘텐츠';

  @override
  String get profileMyAnswers => '내 답변';

  @override
  String get profileMyArticles => '내 글';

  @override
  String get profileMyIdeas => '내 아이디어';

  @override
  String get profileMyCollections => '내 컬렉션';

  @override
  String get profileIdeasTab => '아이디어';

  @override
  String get profileCreationTab => '작성';

  @override
  String get profileActivityTab => '활동';

  @override
  String get profileVoteupTab => '赞同';

  @override
  String get profilePublicActivitiesEmpty => '공개 활동이 아직 없습니다';

  @override
  String get profilePublicVoteupsEmpty => '공개赞同이 아직 없습니다';

  @override
  String get profileVipSalt => '盐选 회원';

  @override
  String get profileVipZhihu => 'Zhihu 회원';

  @override
  String get profileMetricWan => '만';

  @override
  String get profileMetricYi => '억';

  @override
  String profileMetricItems(String count) {
    return '$count개';
  }

  @override
  String get profileGenderFemale => '여성';

  @override
  String get profileGenderMale => '남성';

  @override
  String get profileGenderUnspecified => '미지정';

  @override
  String get profileJustJoined => '방금 가입';

  @override
  String profileAgeDays(int count) {
    return '$count일';
  }

  @override
  String profileAgeMonthsDays(int months, int days) {
    return '$months개월 $days일';
  }

  @override
  String profileAgeYearsMonths(int years, int months) {
    return '$years년 $months개월';
  }

  @override
  String get profileBasicInfo => '기본 정보';

  @override
  String get profileUsername => '사용자 이름';

  @override
  String get profileAccountAge => '가입 기간';

  @override
  String get profileGender => '성별';

  @override
  String get profileBirthday => '생일';

  @override
  String get profileLocation => '거주지';

  @override
  String get profileVerification => '인증 정보';

  @override
  String get profileManageVerification => '인증 관리';

  @override
  String get profileUnverified => '미인증';

  @override
  String get profileInfluence => '영향력';

  @override
  String get profileBadges => '내 배지';

  @override
  String get profileLikes => '받은 좋아요';

  @override
  String get profileNone => '없음';

  @override
  String profileCountPieces(int count) {
    return '$count개';
  }

  @override
  String profileCountTimes(int count) {
    return '$count회';
  }

  @override
  String get profileFriendImpression => '친구들의 인상';

  @override
  String get profileImproveImage => '프로필을 완성하고 더 많은 팔로워를 만나보세요';

  @override
  String get profileAddKeywords => '프로필 키워드 추가';

  @override
  String get profileLinkCopied => '프로필 링크를 복사했습니다';

  @override
  String get profileTitle => '내 프로필';

  @override
  String get profileLoadFailed => '프로필을 불러오지 못했습니다';

  @override
  String get profileNetworkRetry => '네트워크를 확인하고 다시 시도하세요';

  @override
  String get profileOpenDrawer => '탐색 서랍 열기';

  @override
  String get profileFindUser => '사용자 찾기';

  @override
  String get profileCopyHomeLink => '프로필 링크 복사';

  @override
  String get profileUsernameEmpty => '사용자 이름을 입력하세요';

  @override
  String get profileFieldTooLong => '사용자 이름, 소개 또는 자기소개가 너무 깁니다';

  @override
  String get profileImageUploadNoUrl => '이미지 업로드에서 주소를 반환하지 않았습니다';

  @override
  String get profileCoverUploadNoHash => '커버 업로드에서 이미지 해시를 반환하지 않았습니다';

  @override
  String get profileCoverUpdated => '커버를 업데이트했습니다';

  @override
  String get profileAvatarUpdated => '아바타를 업데이트했습니다';

  @override
  String get profileAddEmployment => '경력 추가';

  @override
  String get profileCompanyOrOrganization => '회사 또는 조직';

  @override
  String get profileJob => '직책';

  @override
  String get profileAddEducation => '학력 추가';

  @override
  String get profileSchool => '학교';

  @override
  String get profileMajor => '전공';

  @override
  String get profileEditTitle => '프로필 편집';

  @override
  String get profileSaving => '저장 중';

  @override
  String get profileInfoNotice => '입력한 내용은 프로필 표시와 추천에 사용됩니다';

  @override
  String get profileAvatar => '아바타';

  @override
  String get profileCover => '프로필 커버';

  @override
  String get profileHeadline => '한 줄 소개';

  @override
  String get profileHeadlinePlaceholder => '직업이나 관심사를 소개하세요';

  @override
  String get profileBirthdayPlaceholder => '생일을 입력하세요';

  @override
  String get profileLocationPlaceholder => '거주지를 입력하세요';

  @override
  String get profileIndustry => '업종';

  @override
  String get profileIndustryPlaceholder => '업종을 선택하세요';

  @override
  String get profileEmployment => '경력';

  @override
  String get profileEducation => '학력';

  @override
  String get profilePersonalVerification => '개인 인증';

  @override
  String get profileAddVerification => '개인 인증 추가';

  @override
  String get profileBio => '자기소개';

  @override
  String get profileBioPlaceholder => '짧게 자신을 소개하세요';

  @override
  String get notificationCommentCategory => '댓글·재게시·멘션';

  @override
  String get notificationLikeCategory => '공감·좋아요';

  @override
  String get notificationFavoriteCategory => '저장함';

  @override
  String get notificationFollowCategory => '팔로우·구독';

  @override
  String get notificationInvite => '답변 초대';

  @override
  String get notificationMarkedRead => '메시지를 읽음으로 표시했습니다';

  @override
  String get notificationTitle => '메시지';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get notificationMarkAllRead => '모두 읽음으로 표시';

  @override
  String get notificationLoadFailed => '메시지를 불러오지 못했습니다';

  @override
  String notificationInvitePending(String count) {
    return '처리할 초대 $count개';
  }

  @override
  String get notificationInviteView => '답변 초대를 받은 질문 보기';

  @override
  String get notificationCategoryEmpty => '이 유형의 알림이 없습니다';

  @override
  String get notificationCategoryMarkedRead => '이 카테고리를 모두 읽음으로 표시했습니다';

  @override
  String get notificationSettingsTitle => '알림 설정';

  @override
  String get notificationSettingsSection => '상호작용 및 콘텐츠 알림';

  @override
  String get notificationAll => '모두';

  @override
  String get notificationLoginTitle => '로그인하여 메시지 보기';

  @override
  String get notificationLoginMessage => '메시지 알림은 Zhihu 계정 데이터입니다';

  @override
  String get notificationBackLogin => '돌아가서 로그인';

  @override
  String get messageTitle => '쪽지';

  @override
  String get messageLoadFailed => '쪽지를 불러오지 못했습니다';

  @override
  String get messageComposeHint => '쪽지 보내기';

  @override
  String get messageSend => '보내기';

  @override
  String get notificationSettingCommentMe => '내게 댓글을 남김';

  @override
  String get notificationSettingMentionMe => '나를 멘션함';

  @override
  String get notificationSettingAnswerVoteup => '내 답변에 공감함';

  @override
  String get notificationSettingContentVoteup => '내 콘텐츠에 공감함';

  @override
  String get notificationSettingAnswerThanks => '내 답변에 감사함';

  @override
  String get notificationSettingRepin => '내 콘텐츠를 저장함';

  @override
  String get notificationSettingReaction => '내 콘텐츠에 반응함';

  @override
  String get notificationSettingMemberFollow => '나를 팔로우함';

  @override
  String get notificationSettingFavlistFollow => '내 저장 목록을 팔로우함';

  @override
  String get notificationSettingColumnFollow => '내 칼럼을 팔로우함';

  @override
  String get notificationSettingQuestionAnswered => '팔로우한 질문에 새 답변이 있음';

  @override
  String get notificationSettingAnswerQuestion => '내 질문에 답변함';

  @override
  String get notificationSettingQuestionInvite => '답변에 초대함';

  @override
  String get notificationSettingColumnUpdate => '팔로우한 칼럼이 업데이트됨';

  @override
  String get notificationSettingMemberActivity => '팔로우한 사람에게 새 활동이 있음';

  @override
  String get notificationSettingSpecialUpdate => '팔로우한 주제가 업데이트됨';

  @override
  String get notificationSettingMessage => '쪽지를 받음';

  @override
  String get notificationSettingStrangerMessage => '모르는 사람에게서 쪽지를 받음';

  @override
  String get notificationSettingCoupon => '혜택 및 할인 알림';

  @override
  String get notificationSettingBoughtContent => '구매한 콘텐츠 업데이트';

  @override
  String get notificationSettingEbook => '새 전자책';

  @override
  String get notificationSettingArticleInvite => '글 작성 초대';

  @override
  String get notificationSettingTipjar => '글 후원금 수령';

  @override
  String get creationAll => '모두';

  @override
  String creationAnswers(String count) {
    return '답변 $count';
  }

  @override
  String creationIdeas(String count) {
    return '아이디어 $count';
  }

  @override
  String creationArticles(String count) {
    return '글 $count';
  }

  @override
  String creationColumns(String count) {
    return '칼럼 $count';
  }

  @override
  String creationQuestions(String count) {
    return '질문 $count';
  }

  @override
  String creationVideos(String count) {
    return '동영상 $count';
  }

  @override
  String get creationMore => '더보기';

  @override
  String get creationEmpty => '게시한 콘텐츠가 없습니다';

  @override
  String get creationFavorites => '내 저장함';

  @override
  String get creationHighlights => '내 하이라이트';

  @override
  String get creationFollowingColumns => '팔로우한 칼럼';

  @override
  String get creationFollowingTopics => '팔로우한 주제';

  @override
  String get creationFollowingCollections => '팔로우한 컬렉션';

  @override
  String get creationFollowingQuestions => '팔로우한 질문';

  @override
  String get activityShare => '공유';

  @override
  String get activityDelete => '이 활동 삭제';

  @override
  String get activityLinkCopied => '링크를 복사했습니다';

  @override
  String get activityDeleteTitle => '이 활동을 삭제할까요?';

  @override
  String get activityDeleteMessage => '삭제한 내용은 되돌릴 수 없습니다.';

  @override
  String get activityDeleted => '활동을 삭제했습니다';

  @override
  String get questionIdUnavailable => '질문 ID를 확인할 수 없습니다. 새로고침 후 다시 시도하세요.';

  @override
  String get questionFollowed => '질문을 팔로우했습니다';

  @override
  String get questionUnfollowed => '질문 팔로우를 취소했습니다';

  @override
  String get questionAnswerPublishedRefreshing =>
      '답변을 게시했습니다. 목록을 새로 고치는 중입니다.';

  @override
  String get questionDeleteTitle => '답변을 삭제할까요?';

  @override
  String get questionDeleteMessage => '삭제한 내용은 되돌릴 수 없습니다.';

  @override
  String get questionDeleted => '답변을 삭제했습니다.';

  @override
  String get questionAnswersTitle => '모든 답변';

  @override
  String get questionSearchAnswers => '답변 검색';

  @override
  String get questionMore => '더보기';

  @override
  String get questionLoginToWrite => '로그인하여 답변 작성';

  @override
  String get questionUnfollow => '질문 팔로우 취소';

  @override
  String get questionFollow => '질문 팔로우';

  @override
  String get questionAnswerRefresh => '답변 새로 고침';

  @override
  String get questionCollapseDetails => '질문 세부정보 접기';

  @override
  String get questionExpandDetails => '질문 세부정보 펼치기';

  @override
  String get questionCollapse => '접기';

  @override
  String get questionExpandFull => '전체 내용 펼치기';

  @override
  String questionOpenTopic(String name) {
    return '주제 $name 열기';
  }

  @override
  String questionAllContentCount(String count) {
    return '모든 콘텐츠 $count';
  }

  @override
  String get questionSortDefault => '기본';

  @override
  String get questionSortLatest => '최신';

  @override
  String get questionSortSemantic => '답변 정렬: ';

  @override
  String questionAuthor(String name) {
    return '질문자 $name';
  }

  @override
  String get questionAuthorBadge => '질문자';

  @override
  String get questionViewImage => '질문 이미지 원본 보기';

  @override
  String get topicFollowersTitle => '주제 팔로워';

  @override
  String get topicUnansweredTitle => '주제의 미답변 질문';

  @override
  String topicFallbackTitle(String id) {
    return '주제 $id';
  }

  @override
  String get topicRefresh => '주제 정보 새로 고침';

  @override
  String get topicLabel => '주제';

  @override
  String topicFollowers(String count) {
    return '팔로워 $count명';
  }

  @override
  String topicQuestions(String count) {
    return '질문 $count개';
  }

  @override
  String topicAnswers(String count) {
    return '답변 $count개';
  }

  @override
  String topicDiscussions(String count) {
    return '토론 $count개';
  }

  @override
  String get topicBasicUnavailable => '기본 정보를 불러오지 못했지만 주요 피드는 계속 볼 수 있습니다.';

  @override
  String get topicFollowersButton => '팔로워';

  @override
  String get topicUnansweredButton => '미답변';

  @override
  String get zvideoTitle => '동영상';

  @override
  String get zvideoCommentsUnavailable => '댓글';

  @override
  String zvideoActionUnavailable(String action) {
    return '$action 기능은 아직 사용할 수 없습니다';
  }

  @override
  String get zvideoLoadFailed => '동영상을 잠시 사용할 수 없습니다';

  @override
  String zvideoFallbackTitle(String id) {
    return '동영상 #$id';
  }

  @override
  String get zvideoViewComments => '댓글 보기';

  @override
  String zvideoViewCommentsCount(String count) {
    return '댓글 $count개 보기';
  }

  @override
  String get zvideoMissing => '재생 가능한 동영상 정보를 가져오지 못했습니다';

  @override
  String get zvideoVoteup => '찬성';

  @override
  String get zvideoComment => '댓글';

  @override
  String get zvideoFavorite => '저장';

  @override
  String get zvideoShare => '공유';

  @override
  String get zvideoVoteupSemantic => '동영상 찬성';

  @override
  String get zvideoCommentsSemantic => '동영상 댓글 보기';

  @override
  String get zvideoFavoriteSemantic => '동영상 저장';

  @override
  String get zvideoShareSemantic => '동영상 공유';

  @override
  String get inlineVideoPlatformUnsupported => '이 플랫폼에서는 인라인 동영상 재생을 지원하지 않습니다';

  @override
  String get inlineVideoLoadFailed => '동영상을 재생할 수 없습니다. 잠시 후 다시 시도하세요.';

  @override
  String get inlineVideoInterruptedRetry => '동영상 재생이 중단되었습니다. 탭하여 다시 시도하세요.';

  @override
  String get inlineVideoSwitchingLine => '재생이 중단되었습니다. 다른 소스로 전환하는 중…';

  @override
  String get inlineVideoPaidNoAccess => '유료 동영상 · 이 계정에는 시청 권한이 없습니다';

  @override
  String get inlineVideoUnavailable => '동영상을 재생할 수 없습니다';

  @override
  String get inlineVideoPrivacyUnavailable =>
      '이 플랫폼에서는 개인정보 제한 동영상 재생을 지원하지 않습니다';

  @override
  String get inlineVideoPlay => '동영상 재생';

  @override
  String inlineVideoPlayTitle(String title) {
    return '동영상 재생: $title';
  }

  @override
  String get inlineVideoFullscreen => '전체 화면';

  @override
  String get inlineVideoStopped => '동영상이 중지되었거나 소스를 전환하는 중입니다';

  @override
  String get inlineVideoBack => '뒤로';

  @override
  String get answerSwitchRelease => '놓아서 전환';

  @override
  String get answerSwitchPreviousHint => '계속 아래로 당겨 이전 답변 보기';

  @override
  String get answerSwitchNextHint => '계속 위로 밀어 다음 답변 보기';

  @override
  String answerSwitchTo(String author) {
    return '놓아서 $author의 답변으로 전환';
  }

  @override
  String get answerPrevious => '이전';

  @override
  String get answerNext => '다음';

  @override
  String get detailWriteAnswerLogin => '로그인하여 답변 작성';

  @override
  String saltDownloadedProgress(int downloaded, int total) {
    return '$downloaded/$total 다운로드됨';
  }

  @override
  String saltDownloadedSections(int count) {
    return '섹션 $count개 다운로드됨';
  }

  @override
  String get saltAudio => '프리미엄 오디오';

  @override
  String get saltVideo => '프리미엄 동영상';

  @override
  String get saltStory => '프리미엄 스토리';

  @override
  String get saltLimitedFree => '기간 한정 무료';

  @override
  String get saltUntitledContent => '제목 없는 프리미엄 콘텐츠';

  @override
  String saltLikeCount(String count) {
    return '공감 $count';
  }

  @override
  String saltCommentCount(String count) {
    return '댓글 $count';
  }

  @override
  String saltWordCount(String count) {
    return '$count자';
  }

  @override
  String saltReadCount(String count) {
    return '조회 $count';
  }

  @override
  String saltFavoriteCount(String count) {
    return '저장 $count';
  }

  @override
  String get saltPlayable => '재생 가능';

  @override
  String get saltSupportsAudio => '오디오 지원';

  @override
  String get saltFree => '무료';

  @override
  String get saltTrial => '미리 읽기';

  @override
  String get saltMember => '프리미엄 회원';

  @override
  String get saltEntitlementRequired => '권한 필요';

  @override
  String get saltLastRead => '마지막 읽은 위치';

  @override
  String get saltReadFinished => '읽음 완료';

  @override
  String get saltUntitledChapter => '제목 없는 장';

  @override
  String get saltResourceAudio => '오디오';

  @override
  String get saltResourceVideo => '동영상';

  @override
  String get saltResourceSlide => '슬라이드';

  @override
  String get saltResourceText => '텍스트';

  @override
  String saltReadPercent(int percent) {
    return '$percent% 읽음';
  }

  @override
  String saltCommentBadge(int count) {
    return '인라인 댓글 $count개 보기';
  }

  @override
  String followMoreAnswers(int count) {
    return '답변 $count개에도 공감함';
  }

  @override
  String get brandZhihu => 'Zhihu';

  @override
  String detailQuestionAnswerCount(String count) {
    return '답변 $count개';
  }

  @override
  String detailQuestionFollowerCount(String count) {
    return '팔로워 $count명';
  }

  @override
  String get detailQuestionAnswersSemantic => '이 질문의 모든 답변 보기';

  @override
  String detailQuestionFallback(String id) {
    return '질문 #$id';
  }

  @override
  String get questionInviteTitle => '답변 초대';

  @override
  String get questionInviteEmpty => '추천할 초대 대상이 없습니다';

  @override
  String get questionInviteInvited => '초대함';

  @override
  String get questionInviteAction => '초대';

  @override
  String get routingSafetyTitle => '안전 안내';

  @override
  String get routingLeaveZhihu => 'Zhihu를 나가려고 합니다';

  @override
  String get routingExternalWarning =>
      '이 링크는 Zhihu 공식 페이지가 아닙니다. 계정, 개인정보 및 재산을 보호하세요.';

  @override
  String get routingConfirmVisit => '계속';

  @override
  String get routingOpenVerification => 'Zhihu 인증 열기';

  @override
  String get webSafetyTitle => '보안 인증';

  @override
  String get webPageLoadFailedNetwork => '페이지를 불러오지 못했습니다. 네트워크를 확인하고 다시 시도하세요';

  @override
  String get webPageUnavailable => '페이지를 잠시 열 수 없습니다. 나중에 다시 시도하세요';

  @override
  String get webSessionSyncFailed => '로그인 상태를 동기화하지 못했습니다. 다시 로그인해 보세요';

  @override
  String get webLoginExpired => '웹 로그인 세션이 만료되었습니다. 다시 로그인해 보세요';

  @override
  String get webSystemBrowserUnavailable => '시스템 브라우저를 열 수 없습니다';

  @override
  String get webContinueInBrowser => '브라우저에서 계속';

  @override
  String get webDesktopSystemBrowser => '데스크톱에서는 시스템 브라우저를 사용합니다';

  @override
  String get webOpenBrowser => '브라우저 열기';

  @override
  String get webOpeningChapter => '섹션 여는 중';

  @override
  String get webOpeningPage => '페이지 여는 중';

  @override
  String get webOpenInBrowser => '브라우저에서 열기';

  @override
  String get webChapterReading => '섹션 읽기';

  @override
  String get routingCannotOpen => '지금은 열 수 없습니다.';

  @override
  String get routingCannotViewComments => '지금은 댓글을 볼 수 없습니다.';

  @override
  String get routingUnsupportedAction => '현재 콘텐츠에서는 이 작업을 지원하지 않습니다.';

  @override
  String get routingPinDownvoteUnavailable => '아이디어에는 반대 기능이 지원되지 않습니다.';

  @override
  String get routingDownvoteCancelled => '반대를 취소했습니다.';

  @override
  String get routingDownvoted => '반대했습니다.';

  @override
  String get routingVoteCancelled => '공감을 취소했습니다.';

  @override
  String get routingVoted => '공감했습니다.';

  @override
  String get routingFavoriteRemoved => '저장함에서 삭제했습니다.';

  @override
  String get routingFavorited => '기본 저장함에 추가했습니다.';

  @override
  String get objectDetailTitle => '콘텐츠 세부정보';

  @override
  String get objectImages => '이미지';

  @override
  String get objectContent => '콘텐츠';

  @override
  String get contentTypeCollection => '컬렉션';

  @override
  String columnFallbackTitle(String token) {
    return '칼럼 $token';
  }

  @override
  String get columnFollowersTitle => '칼럼 팔로워';

  @override
  String get columnLoadFailed => '칼럼 정보를 불러오지 못했습니다.';

  @override
  String get columnRetry => '칼럼 정보 다시 시도';

  @override
  String get columnTitle => '칼럼';

  @override
  String columnArticleCount(String count) {
    return '글 $count개';
  }

  @override
  String columnFollowerCount(String count) {
    return '팔로워 $count명';
  }

  @override
  String columnContributionCount(String count) {
    return '기고 $count개';
  }

  @override
  String columnVoteupCount(String count) {
    return '공감 $count';
  }

  @override
  String columnAuthorPrefix(String name) {
    return '작성자 $name';
  }

  @override
  String get columnFollowers => '팔로워';

  @override
  String get columnAuthorProfile => '작성자 프로필';

  @override
  String get detailContentIncomplete => '콘텐츠가 불완전할 수 있습니다';

  @override
  String get detailPaidUnlocked =>
      '이 계정에서 프리미엄 회원 콘텐츠가 잠금 해제되었습니다. 읽을 수 있는 전체 본문이 이어집니다.';

  @override
  String get detailPaidLocked => '프리미엄 회원 콘텐츠이지만 이 계정에 반환된 본문은 아직 잠겨 있습니다.';

  @override
  String get detailRelatedLoadFailed => '다른 답변을 불러오지 못했습니다. 눌러서 다시 시도';

  @override
  String get detailViewCommentsButton => '댓글 보기';

  @override
  String get detailContentInfo => '콘텐츠 정보';

  @override
  String get detailReadingHint => '본문 열의 너비를 제한하여 스크롤 중에도 상호작용 정보를 확인할 수 있습니다.';

  @override
  String get blockedKeywordsTitle => '차단 키워드';

  @override
  String blockedKeywordsInvalidLength(int min, int max) {
    return '키워드는 $min~$max자로 입력해야 합니다';
  }

  @override
  String get blockedKeywordsExists => '이미 존재하는 키워드입니다';

  @override
  String blockedKeywordsLimit(int max) {
    return '최대 $max개의 키워드를 설정할 수 있습니다';
  }

  @override
  String get blockedKeywordsDescription => '이 키워드가 포함된 추천을 줄입니다';

  @override
  String blockedKeywordsCount(int current, int max) {
    return '$current/$max개 설정됨';
  }

  @override
  String blockedKeywordsHint(int min, int max) {
    return '$min~$max자';
  }

  @override
  String get blockedKeywordsAdd => '키워드 추가';

  @override
  String get blockedKeywordsEmpty => '차단한 키워드가 없습니다';

  @override
  String blockedKeywordsDelete(String keyword) {
    return '$keyword 삭제';
  }

  @override
  String get recommendationClearTitle => '기기의 추천 프로필을 지울까요?';

  @override
  String get recommendationClearMessage =>
      '기기에 저장된 기록만 삭제합니다. Zhihu 계정과 서버 추천은 변경되지 않습니다.';

  @override
  String get recommendationCleared => '기기의 추천 프로필을 지웠습니다';

  @override
  String get recommendationTitle => '기기의 추천 행동';

  @override
  String get recommendationClearSemantic => '기기 프로필 지우기';

  @override
  String get recommendationEmptyTitle => '아직 기기 행동 기록이 없습니다';

  @override
  String get recommendationProfileTitle => '기기의 추천 프로필';

  @override
  String get recommendationEmptyMessage =>
      '추천 콘텐츠를 열거나 ‘관심 없음’을 선택하면 Zhiyue가 기기에 제한적인 관심 신호를 기록합니다.';

  @override
  String recommendationSummary(int total, int opened, int feedback) {
    return '신호 $total개 · 열람 $opened개 · 피드백 $feedback개';
  }

  @override
  String get recommendationTopics => '자주 관심을 보인 단어';

  @override
  String get recommendationAuthors => '자주 본 작성자';

  @override
  String get recommendationPrivacy =>
      '데이터는 기기에만 저장되며 기기 또는 혼합 추천 순위에 사용됩니다. 행동 세부정보는 업로드하지 않습니다.';

  @override
  String get discoverColumns => '칼럼 추천';

  @override
  String get discoverTopics => '주제 카테고리';

  @override
  String get discoverHotTopics => '인기 주제';

  @override
  String get discoverHotTopicsEmpty => '현재 인기 주제가 없습니다';

  @override
  String get discoverContentIdInvalid => '콘텐츠 ID는 1~32자리 숫자여야 합니다';

  @override
  String get discoverTitle => '탐색';

  @override
  String get discoverColumnsAndTopics => '칼럼 및 주제';

  @override
  String get discoverColumnsSubtitle => '편집 추천 및 인기 칼럼 글';

  @override
  String get discoverTopicsSubtitle => '카테고리별 주제 찾아보기';

  @override
  String get discoverHotTopicsSubtitle => '현재 인기 토론';

  @override
  String get discoverOpenById => 'ID로 콘텐츠 열기';

  @override
  String get discoverTypeAnswer => '답변';

  @override
  String get discoverTypeArticle => '글';

  @override
  String get discoverTypeIdea => '아이디어';

  @override
  String get discoverIdHint => '콘텐츠 ID 입력';

  @override
  String get discoverOpenDetails => '세부정보 열기';

  @override
  String get pagedEnd => '마지막 항목입니다';

  @override
  String get pagedEmpty => '아직 콘텐츠가 없습니다';

  @override
  String get diagnosticExported => '로그 JSON을 클립보드에 복사했습니다';

  @override
  String get diagnosticEmpty => '로그가 없습니다';

  @override
  String get diagnosticClearTitle => '진단 로그를 지울까요?';

  @override
  String get diagnosticClearMessage =>
      '기기에 저장된 진단 기록만 삭제합니다. 계정과 콘텐츠 캐시는 영향을 받지 않습니다.';

  @override
  String get diagnosticCleared => '진단 로그를 지웠습니다';

  @override
  String get diagnosticTitle => '진단 로그';

  @override
  String get diagnosticExport => '로그 내보내기';

  @override
  String get diagnosticClear => '로그 지우기';

  @override
  String get diagnosticPurpose => '삭제된 콘텐츠, API 오류 및 성능 문제를 조사하는 데 사용됩니다';

  @override
  String get diagnosticPrivacy =>
      '인증 만료, 복구 및 정리 결정은 기본적으로 기록됩니다. 다른 진단 로그는 별도로 켤 수 있습니다. 비식별화된 상태만 저장하며 Cookie, 토큰, 본문 및 이미지는 저장하지 않습니다.';

  @override
  String get diagnosticLocalEnabled => '기기 로그 사용';

  @override
  String get diagnosticLocalSubtitle => '최근 진단 기록 600개 보관';

  @override
  String get diagnosticAuthEnabled => '인증 상태 로그';

  @override
  String get diagnosticAuthSubtitle => '로그인 만료, 복구, 유지 및 정리 결정을 기록하며 기본으로 켭니다';

  @override
  String get diagnosticNetworkEnabled => '네트워크 요청 로그';

  @override
  String get diagnosticNetworkSubtitle => 'API 경로, HTTP 상태, 비즈니스 코드 및 소요 시간 기록';

  @override
  String get diagnosticPerformanceEnabled => '성능 로그';

  @override
  String get diagnosticPerformanceSubtitle => '프레임 드롭과 느린 요청을 찾도록 요청 시간 기록';

  @override
  String diagnosticInstallSummary(String id, int count) {
    return '기기 ID $id · $count개';
  }

  @override
  String get diagnosticEmptyTitle => '진단 로그 없음';

  @override
  String get diagnosticEmptyMessage =>
      '기기 로그를 켠 뒤 다시 작업해 보세요. 오류와 네트워크 상태가 여기에 표시됩니다.';

  @override
  String get diagnosticNoDetails => '추가 정보 없음';

  @override
  String get diagnosticLevelDebug => '디버그';

  @override
  String get diagnosticLevelInfo => '정보';

  @override
  String get diagnosticLevelWarning => '경고';

  @override
  String get diagnosticLevelError => '오류';

  @override
  String get diagnosticCategoryApp => '앱';

  @override
  String get diagnosticCategoryNetwork => '네트워크';

  @override
  String get diagnosticCategoryPerformance => '성능';

  @override
  String get diagnosticCategoryError => '오류';

  @override
  String get diagnosticCategoryAuthentication => '인증';
}
