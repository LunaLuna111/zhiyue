part of '../content_pages.dart';

extension _ContentDetailNavigation on _ContentDetailPageState {
  void _jumpAnswerToBottom() {
    if (!_scrollController.hasClients) return;
    unawaited(_animateAnswerJump(_scrollController.position.maxScrollExtent));
  }

  void _jumpAnswerToTop() {
    if (!_scrollController.hasClients) return;
    unawaited(_animateAnswerJump(_scrollController.position.minScrollExtent));
  }

  Future<void> _animateAnswerJump(double target) async {
    if (!_scrollController.hasClients || _answerJumpInProgress) return;
    _answerJumpInProgress = true;
    try {
      await _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {
      // The route can be disposed while the animated jump is in flight.
    } finally {
      _answerJumpInProgress = false;
    }
  }

  bool _handleAnswerScrollNotification(ScrollNotification notification) {
    if (widget.contentType != 'answer') return false;
    if (notification is ScrollStartNotification) {
      _answerOverscrollRaw = 0;
      _answerOverscrollResetAnimation.stop();
      _setAnswerOverscroll(0);
      return false;
    }
    if (notification is OverscrollNotification &&
        !_answerSwitchBusy &&
        !_answerJumpInProgress) {
      final atBottom =
          notification.metrics.pixels >=
          notification.metrics.maxScrollExtent - 1;
      final atTop =
          notification.metrics.pixels <=
          notification.metrics.minScrollExtent + 1;
      final goingNext =
          atBottom && notification.overscroll > 0 && _nextAnswerPreview != null;
      final goingPrevious =
          atTop &&
          notification.overscroll < 0 &&
          _previousAnswerPreview != null;
      if (goingNext || goingPrevious) {
        _answerOverscrollRaw = (_answerOverscrollRaw + notification.overscroll)
            .clamp(-10000, 10000)
            .toDouble();
        _setAnswerOverscroll(-dampedAnswerOverscroll(_answerOverscrollRaw));
        return false;
      }
    }
    if (notification is ScrollEndNotification &&
        !_answerSwitchBusy &&
        !_answerJumpInProgress) {
      final next = _nextAnswerPreview;
      final previous = _previousAnswerPreview;
      if (next != null && _answerOverscrollRaw >= answerSwitchTriggerDistance) {
        unawaited(_switchToNextAnswer(next));
      } else if (previous != null &&
          _answerOverscrollRaw <= -answerSwitchTriggerDistance) {
        unawaited(_switchToPreviousAnswer());
      } else if (_answerOverscrollRaw != 0) {
        _answerOverscrollRaw = 0;
        _animateAnswerOverscrollBack();
      }
    }
    return false;
  }

  void _setAnswerOverscroll(double value) {
    if (!mounted) return;
    final clamped = value
        .clamp(-answerSwitchMaxDistance, answerSwitchMaxDistance)
        .toDouble();
    if ((_answerOverscrollNotifier.value - clamped).abs() < .5) return;
    _answerOverscrollNotifier.value = clamped;
  }

  void _animateAnswerOverscrollBack() {
    final begin = _answerOverscrollNotifier.value;
    if (begin == 0) return;
    _answerOverscrollResetAnimation
      ..stop()
      ..reset();
    void listener() {
      _answerOverscrollNotifier.value =
          begin * (1 - _answerOverscrollResetAnimation.value);
    }

    _answerOverscrollResetAnimation.addListener(listener);
    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _answerOverscrollResetAnimation.removeListener(listener);
        _answerOverscrollResetAnimation.removeStatusListener(statusListener);
        if (mounted) _answerOverscrollNotifier.value = 0;
      }
    }

    _answerOverscrollResetAnimation.addStatusListener(statusListener);
    unawaited(_answerOverscrollResetAnimation.forward());
  }

  Future<void> _switchToNextAnswer(Map<String, dynamic> answer) async {
    if (_answerSwitchBusy) return;
    final answerId = idOf(answer);
    if (answerId.isEmpty) return;
    _answerSwitchBusy = true;
    _answerOverscrollRaw = answerSwitchTriggerDistance;
    _setAnswerOverscroll(-answerSwitchMaxDistance);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    // The first related answer is warmed as soon as this route opens. Pass
    // the exact same future to the replacement route; waiting here would
    // leave the old page frozen, while starting a second request in the new
    // route makes the preload ineffective.
    final detailKey = 'answer:$answerId';
    final detailFuture =
        _ContentDetailPageState._relatedDetailPrefetches[detailKey] ??=
            _fetchRelatedAnswerDetail(answerId, answer);
    final source = Map<String, dynamic>.from(answer)
      ..putIfAbsent('type', () => 'answer');
    final answerHistory = <Map<String, dynamic>>[
      for (final value in widget.answerHistory)
        Map<String, dynamic>.from(value),
      if (widget.previousAnswer case final previous?)
        Map<String, dynamic>.from(previous),
    ];
    unawaited(
      Navigator.of(context).pushReplacement(
        _nextAnswerRoute(
          api: widget.api,
          answerId: answerId,
          initialValue: source,
          previousAnswer: _document ?? _initialSemantic,
          answerHistory: answerHistory,
          prefetchedDetail: detailFuture,
        ),
      ),
    );
  }

  Future<void> _switchToPreviousAnswer() async {
    if (_answerSwitchBusy || _previousAnswerPreview == null) return;
    _answerSwitchBusy = true;
    _answerOverscrollRaw = -answerSwitchTriggerDistance;
    _setAnswerOverscroll(answerSwitchMaxDistance);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    final history = [
      for (final value in widget.answerHistory)
        Map<String, dynamic>.from(value),
    ];
    final previous = history.isEmpty ? null : history.removeLast();
    final source = Map<String, dynamic>.from(_previousAnswerPreview!)
      ..putIfAbsent('type', () => 'answer');
    unawaited(
      Navigator.of(context).pushReplacement(
        _nextAnswerRoute(
          api: widget.api,
          answerId: idOf(source),
          initialValue: source,
          previousAnswer: previous,
          answerHistory: history,
        ),
      ),
    );
  }

  PageRoute<String> _nextAnswerRoute({
    required ZhihuApiClient api,
    required String answerId,
    required Map<String, dynamic> initialValue,
    required Map<String, dynamic>? previousAnswer,
    required List<Map<String, dynamic>> answerHistory,
    Future<Map<String, dynamic>?>? prefetchedDetail,
  }) => PageRouteBuilder<String>(
    settings: RouteSettings(name: '/answer/$answerId'),
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, _, _) => ContentDetailPage(
      api: api,
      contentType: 'answer',
      contentId: answerId,
      initialValue: initialValue,
      previousAnswer: previousAnswer,
      answerHistory: answerHistory,
      prefetchedDetail: prefetchedDetail,
    ),
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .12),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}
