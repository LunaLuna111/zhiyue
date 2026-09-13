part of '../content_pages.dart';

extension _ContentDetailNavigation on _ContentDetailPageState {
  void _updateAnswerJumpPosition() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final atBottom =
        position.maxScrollExtent <= 1 || position.extentAfter <= 24;
    if (_answerAtBottomNotifier.value != atBottom) {
      _answerAtBottomNotifier.value = atBottom;
    }
  }

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
      if (mounted) _updateAnswerJumpPosition();
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
    // The first related answer is warmed as soon as this route opens. Reuse
    // that request here and give it a short head start so the pushed route
    // normally receives the complete author/body payload instead of first
    // painting the compact feed row and then reflowing after the detail call.
    final detailKey = 'answer:$answerId';
    final detailFuture =
        _ContentDetailPageState._relatedDetailPrefetches[detailKey] ??=
            _fetchRelatedAnswerDetail(answerId, answer);
    Map<String, dynamic>? prefetched;
    try {
      prefetched = await detailFuture.timeout(
        const Duration(milliseconds: 1200),
      );
    } catch (_) {
      // A slow or failed warmup must never block navigation. The next route
      // can still load the same answer from its regular cache/API path.
    }
    if (!mounted) return;
    final source = Map<String, dynamic>.from(
      prefetched == null ? answer : mergeListMetadata(prefetched, answer),
    )..putIfAbsent('type', () => 'answer');
    final result = await Navigator.of(context).push(
      _nextAnswerRoute(
        api: widget.api,
        answerId: answerId,
        initialValue: source,
        previousAnswer: _document ?? _initialSemantic,
      ),
    );
    if (!mounted) return;
    _answerSwitchBusy = false;
    _answerOverscrollRaw = 0;
    _setAnswerOverscroll(0);
    if (result == answerSwitchPreviousResult && _scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }

  Future<void> _switchToPreviousAnswer() async {
    if (_answerSwitchBusy || _previousAnswerPreview == null) return;
    _answerSwitchBusy = true;
    _answerOverscrollRaw = -answerSwitchTriggerDistance;
    _setAnswerOverscroll(answerSwitchMaxDistance);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      Navigator.of(context).pop(answerSwitchPreviousResult);
    }
  }

  PageRoute<String> _nextAnswerRoute({
    required ZhihuApiClient api,
    required String answerId,
    required Map<String, dynamic> initialValue,
    required Map<String, dynamic>? previousAnswer,
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
