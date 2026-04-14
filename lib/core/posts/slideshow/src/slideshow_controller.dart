// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;
import 'package:flutter/material.dart';

// Project imports:
import 'slideshow_options.dart';
import 'slideshow_state.dart';

const kDefaultAutoSlideDuration = Duration(seconds: 5);

typedef SlideshowAdvanceCallback =
    Future<void> Function(
      int currentPage,
      int nextPage,
    );

typedef SlideshowNavigateCallback =
    Future<void> Function(
      int targetPage,
      bool skipAnimation,
    );

typedef TimerFactory =
    Timer Function(
      Duration duration,
      void Function() callback,
    );

SlideshowNavigateCallback createDefaultSlideshowNavigateCallback(
  PageController pageController,
) {
  return (targetPage, skipAnimation) async {
    if (skipAnimation) {
      pageController.jumpToPage(targetPage);
    } else {
      // if last page, just jump to first page without animation
      if (targetPage == 0) {
        pageController.jumpToPage(0);
      } else {
        await pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    }
  };
}

class SlideshowController {
  SlideshowController({
    required this.onNavigateToPage,
    required ValueNotifier<int> totalPagesNotifier,
    this.options = const SlideshowOptions(),
    this.onBeforeAdvance,
    TimerFactory? createTimer,
  })  : _totalPagesNotifier = totalPagesNotifier,
        _state = ValueNotifier(const SlideshowState.idle()),
        _createTimer = createTimer ?? Timer.new {
    _totalPagesListener = () => _handleTotalPagesChanged(totalPagesNotifier.value);
    totalPagesNotifier.addListener(_totalPagesListener);
  }

  final SlideshowAdvanceCallback? onBeforeAdvance;
  final SlideshowNavigateCallback onNavigateToPage;
  final TimerFactory _createTimer;
  SlideshowOptions options;

  final ValueNotifier<int> _totalPagesNotifier;
  final ValueNotifier<SlideshowState> _state;
  Timer? _timer;
  var _skipOnBeforeAdvance = false;
  late final VoidCallback _totalPagesListener;

  ValueListenable<SlideshowState> get state => _state;
  bool get isRunning => _state.value.isRunning;

  void start(int startPage) {
    final totalPages = _totalPagesNotifier.value;
    assert(startPage >= 0 && startPage < totalPages,
        'startPage must be in range [0, totalPages)');

    switch (_state.value) {
      case SlideshowRunning():
        return;
      case SlideshowIdle() || SlideshowPaused():
        _timer?.cancel();
        _transitionTo(
          SlideshowRunning.initial(
            startPage: startPage,
            totalPages: totalPages,
            direction: options.direction,
          ),
        );
        _scheduleNextAdvance();
    }
  }

  void stop() {
    switch (_state.value) {
      case SlideshowRunning() && final running:
        _timer?.cancel();
        _transitionTo(running.pause());
      case SlideshowIdle() || SlideshowPaused():
        return;
    }
  }

  void resume() {
    switch (_state.value) {
      case SlideshowPaused() && final paused:
        _transitionTo(paused.resume(options.direction));
        _scheduleNextAdvance();
      case SlideshowIdle() || SlideshowRunning():
        return;
    }
  }

  void dispose() {
    _totalPagesNotifier.removeListener(_totalPagesListener);
    _timer?.cancel();
    _state.dispose();
  }

  void _scheduleNextAdvance() {
    _timer = _createTimer(options.duration, () async {
      await _advance();
      if (_state.value.isRunning) {
        _scheduleNextAdvance();
      }
    });
  }

  Future<void> _advance() async {
    switch (_state.value) {
      case SlideshowRunning() && final running:
        final nextState = running.advance();
        final skipAnimation = running.shouldSkipAnimation(options);

        if (!_skipOnBeforeAdvance) {
          await onBeforeAdvance?.call(
            running.currentPage,
            nextState.currentPage,
          );
        } else {
          _skipOnBeforeAdvance = false;
        }

        if (_state.value is! SlideshowRunning) return;

        _transitionTo(nextState);
        await onNavigateToPage(nextState.currentPage, skipAnimation);

      case SlideshowIdle() || SlideshowPaused():
        return;
    }
  }

  void _transitionTo(SlideshowState newState) {
    _state.value = newState;
  }

  void _handleTotalPagesChanged(int newTotalPages) {
    assert(newTotalPages > 0, 'totalPages must never be zero');

    final currentState = _state.value;
    final newState = currentState.withUpdatedTotalPages(newTotalPages);

    // If we have a new current page due to total gettign smaller, trigger navigation to sync UI.
    if (newState.currentPage != currentState.currentPage) {
      // Navigate without animation (skip animation)
      onNavigateToPage(newState.currentPage, true);
    }
  }
}