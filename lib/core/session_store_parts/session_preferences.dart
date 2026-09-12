part of '../session_store.dart';

mixin _SessionStorePreferencesMixin on _SessionStoreCore {
  Future<void> setReadingTextSize(ReadingTextSize value) async {
    if (readingTextSize == value) return;
    readingTextSize = value;
    await _writePreference(_SessionStoreCore._readingTextSizeKey, value.name);
    _notifyChanged();
  }

  Future<void> setReduceMotion(bool value) async {
    if (reduceMotion == value) return;
    reduceMotion = value;
    await _writePreference(
      _SessionStoreCore._reduceMotionKey,
      value.toString(),
    );
    _notifyChanged();
  }

  Future<void> setPrefetchImages(bool value) async {
    if (prefetchImages == value) return;
    prefetchImages = value;
    await _writePreference(
      _SessionStoreCore._prefetchImagesKey,
      value.toString(),
    );
    _notifyChanged();
  }

  Future<void> setRememberSearchHistory(bool value) async {
    if (rememberSearchHistory == value) return;
    rememberSearchHistory = value;
    await _writePreference(
      _SessionStoreCore._rememberSearchKey,
      value.toString(),
    );
    if (!value) {
      searchHistory = const [];
      if (!kIsWeb) await _safeDelete(_SessionStoreCore._searchHistoryKey);
    }
    _notifyChanged();
  }

  Future<void> setImageCachePreset(ImageCachePreset value) async {
    if (imageCachePreset == value) return;
    imageCachePreset = value;
    await _writePreference(_SessionStoreCore._imageCachePresetKey, value.name);
    _notifyChanged();
  }

  Future<void> setStartupPage(AppStartupPage value) async {
    if (startupPage == value) return;
    startupPage = value;
    await _writePreference(_SessionStoreCore._startupPageKey, value.name);
    _notifyChanged();
  }

  Future<void> setHomeFeedOrder(List<HomeFeedChannel> value) async {
    final normalized = _SessionStoreCore._validatedHomeFeedOrder(value);
    if (listEquals(homeFeedOrder, normalized)) return;
    homeFeedOrder = normalized;
    await _writePreference(
      _SessionStoreCore._homeFeedOrderKey,
      jsonEncode(homeFeedOrder.map((channel) => channel.name).toList()),
    );
    _notifyChanged();
  }

  Future<void> resetHomeFeedOrder() =>
      setHomeFeedOrder(_SessionStoreCore.defaultHomeFeedOrder);

  Future<void> setRefreshHomeOnReselect(bool value) async {
    if (refreshHomeOnReselect == value) return;
    refreshHomeOnReselect = value;
    await _writePreference(
      _SessionStoreCore._refreshHomeOnReselectKey,
      value.toString(),
    );
    _notifyChanged();
  }

  Future<void> setFeedDensity(FeedDensity value) async {
    if (feedDensity == value) return;
    feedDensity = value;
    await _writePreference(_SessionStoreCore._feedDensityKey, value.name);
    _notifyChanged();
  }

  Future<void> setShowFeedImages(bool value) async {
    if (showFeedImages == value) return;
    showFeedImages = value;
    await _writePreference(
      _SessionStoreCore._showFeedImagesKey,
      value.toString(),
    );
    _notifyChanged();
  }

  Future<void> setShowFeedMetrics(bool value) async {
    if (showFeedMetrics == value) return;
    showFeedMetrics = value;
    await _writePreference(
      _SessionStoreCore._showFeedMetricsKey,
      value.toString(),
    );
    _notifyChanged();
  }

  Future<void> setRecommendationMode(RecommendationMode value) async {
    if (recommendationMode == value) return;
    recommendationMode = value;
    await _writePreference(
      _SessionStoreCore._recommendationModeKey,
      value.name,
    );
    _notifyChanged();
  }

  Future<void> setFollowSystemTextScale(bool value) async {
    if (followSystemTextScale == value) return;
    followSystemTextScale = value;
    await _writePreference(
      _SessionStoreCore._followSystemTextScaleKey,
      value.toString(),
    );
    _notifyChanged();
  }

  Future<void> setRememberBrowsingHistory(bool value) async {
    if (rememberBrowsingHistory == value) return;
    rememberBrowsingHistory = value;
    if (!value) {
      browsingHistory = const [];
      _browsingHistoryChanges.emit();
    }
    _notifyChanged();
    await _writePreference(
      _SessionStoreCore._rememberBrowsingHistoryKey,
      value.toString(),
    );
    if (!value) await _persistBrowsingHistory();
  }

  Future<void> setAppLoggingEnabled(bool value) async {
    if (appLoggingEnabled == value) return;
    appLoggingEnabled = value;
    await _writePreference(
      _SessionStoreCore._appLoggingEnabledKey,
      value.toString(),
    );
    _notifyChanged();
  }

  Future<void> setNetworkLoggingEnabled(bool value) async {
    if (networkLoggingEnabled == value) return;
    networkLoggingEnabled = value;
    await _writePreference(
      _SessionStoreCore._networkLoggingEnabledKey,
      value.toString(),
    );
    _notifyChanged();
  }

  Future<void> setPerformanceLoggingEnabled(bool value) async {
    if (performanceLoggingEnabled == value) return;
    performanceLoggingEnabled = value;
    await _writePreference(
      _SessionStoreCore._performanceLoggingEnabledKey,
      value.toString(),
    );
    _notifyChanged();
  }

  Future<void> resetAppPreferences() async {
    readingTextSize = ReadingTextSize.standard;
    reduceMotion = false;
    prefetchImages = true;
    rememberSearchHistory = true;
    imageCachePreset = ImageCachePreset.standard;
    startupPage = AppStartupPage.recommend;
    homeFeedOrder = List<HomeFeedChannel>.from(
      _SessionStoreCore.defaultHomeFeedOrder,
    );
    refreshHomeOnReselect = true;
    feedDensity = FeedDensity.comfortable;
    showFeedImages = true;
    showFeedMetrics = true;
    recommendationMode = RecommendationMode.server;
    followSystemTextScale = true;
    rememberBrowsingHistory = true;
    appLoggingEnabled = false;
    networkLoggingEnabled = false;
    performanceLoggingEnabled = false;
    if (!kIsWeb) {
      await Future.wait([
        _safeDelete(_SessionStoreCore._readingTextSizeKey),
        _safeDelete(_SessionStoreCore._reduceMotionKey),
        _safeDelete(_SessionStoreCore._prefetchImagesKey),
        _safeDelete(_SessionStoreCore._rememberSearchKey),
        _safeDelete(_SessionStoreCore._imageCachePresetKey),
        _safeDelete(_SessionStoreCore._startupPageKey),
        _safeDelete(_SessionStoreCore._homeFeedOrderKey),
        _safeDelete(_SessionStoreCore._refreshHomeOnReselectKey),
        _safeDelete(_SessionStoreCore._feedDensityKey),
        _safeDelete(_SessionStoreCore._showFeedImagesKey),
        _safeDelete(_SessionStoreCore._showFeedMetricsKey),
        _safeDelete(_SessionStoreCore._recommendationModeKey),
        _safeDelete(_SessionStoreCore._followSystemTextScaleKey),
        _safeDelete(_SessionStoreCore._rememberBrowsingHistoryKey),
        _safeDelete(_SessionStoreCore._appLoggingEnabledKey),
        _safeDelete(_SessionStoreCore._networkLoggingEnabledKey),
        _safeDelete(_SessionStoreCore._performanceLoggingEnabledKey),
      ]);
    }
    _notifyChanged();
  }
}
