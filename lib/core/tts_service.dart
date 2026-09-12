import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_log.dart';

enum TtsPlaybackState { idle, preparing, playing, error }

/// Small foreground TTS controller. The Android implementation owns the
/// platform queue and language selection; Flutter only owns the current
/// document and exposes a stable state for reader menus.
class TtsService extends ChangeNotifier {
  TtsService._();

  static final instance = TtsService._();
  static const _channel = MethodChannel('com.zhiyue.client/tts');

  TtsPlaybackState _state = TtsPlaybackState.idle;
  String _currentTitle = '';
  double _rate = 1;
  bool _available = false;
  Future<bool>? _initializing;

  TtsPlaybackState get state => _state;
  String get currentTitle => _currentTitle;
  double get rate => _rate;
  bool get isPlaying => _state == TtsPlaybackState.playing;
  bool get isAvailable => _available;

  Future<bool> initialize() {
    final existing = _initializing;
    if (existing != null) return existing;
    final future = _initializeOnce();
    _initializing = future;
    return future.whenComplete(() {
      if (identical(_initializing, future)) _initializing = null;
    });
  }

  Future<bool> _initializeOnce() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('initialize');
      _available = result is Map ? result['available'] == true : result == true;
      return _available;
    } on Object catch (error, stackTrace) {
      _available = false;
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: 'TTS 初始化失败',
          category: AppLogCategory.app,
        ),
      );
      return false;
    }
  }

  Future<bool> speak(String text, {String title = '', double rate = 1}) async {
    final normalized = text.trim();
    if (normalized.isEmpty) return false;
    _state = TtsPlaybackState.preparing;
    _currentTitle = title.trim();
    _rate = rate.clamp(0.5, 2.0).toDouble();
    notifyListeners();
    if (!await initialize()) {
      _state = TtsPlaybackState.error;
      notifyListeners();
      return false;
    }
    try {
      await _channel.invokeMethod<void>('speak', {
        'text': normalized,
        'rate': _rate,
      });
      _state = TtsPlaybackState.playing;
      unawaited(
        AppLogStore.instance.record(
          category: AppLogCategory.app,
          level: AppLogLevel.info,
          message: 'TTS 开始朗读',
          details: {'characters': normalized.runes.length},
        ),
      );
      notifyListeners();
      return true;
    } on Object catch (error, stackTrace) {
      _state = TtsPlaybackState.error;
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: 'TTS 开始朗读失败',
          category: AppLogCategory.error,
        ),
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on Object catch (error, stackTrace) {
      unawaited(
        AppLogStore.instance.recordError(
          error,
          stackTrace,
          message: 'TTS 停止失败',
          category: AppLogCategory.app,
        ),
      );
    } finally {
      _state = TtsPlaybackState.idle;
      _currentTitle = '';
      notifyListeners();
    }
  }

  Future<void> refreshState() async {
    try {
      final speaking = await _channel.invokeMethod<bool>('isSpeaking') ?? false;
      if (speaking == isPlaying) return;
      _state = speaking ? TtsPlaybackState.playing : TtsPlaybackState.idle;
      notifyListeners();
    } on Object {
      // A missing platform channel is handled by speak/initialize.
    }
  }
}
