// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'types/slideshow_direction.dart';

const kDefaultAutoSlideDuration = Duration(seconds: 5);

class SlideshowOptions extends Equatable {
  const SlideshowOptions({
    this.duration = const Duration(seconds: 5),
    this.direction = SlideshowDirection.forward,
    this.skipTransition = false,
  });

  final Duration duration;
  final SlideshowDirection direction;
  final bool skipTransition;

  @override
  List<Object?> get props => [duration, direction, skipTransition];
}

mixin AutomaticSlideMixin on ChangeNotifier {
  PageController get pageController;
  Timer? timer;
  var _currentPage = 0;
  var _isSliding = false;

  bool _shouldSkipAnimation(bool value, Duration duration) {
    // less than 1 second, skip animation
    if (duration.inSeconds < 1) return true;

    return value;
  }

  int _calculateNextPage(SlideshowDirection direction, int end) {
    switch (direction) {
      case SlideshowDirection.forward:
        return (_currentPage + 1) % end;
      case SlideshowDirection.backward:
        return (_currentPage - 1) % end;
      case SlideshowDirection.random:
        if (_currentRandomPages == null || _currentRandomPages!.isEmpty) {
          _currentRandomPages = _generateRandomPages(end);
        }
        // pick a random page then remove it from the list
        return _currentRandomPages!.removeAt(0);
    }
  }

  List<int>? _currentRandomPages;

  List<int> _generateRandomPages(int end) {
    final pages = List.generate(end, (index) => index)..shuffle();
    return pages;
  }

  void startAutoSlide(
    int start,
    int end, {
    SlideshowOptions options = const SlideshowOptions(),
  }) {
    if (_isSliding) return;

    final duration = options.duration;
    final direction = options.direction;
    final skipAnimation = options.skipTransition;

    final skip = _shouldSkipAnimation(skipAnimation, duration);

    _isSliding = true;
    timer?.cancel();
    _currentRandomPages = null;
    _currentPage = start;

    timer = Timer.periodic(
      duration,
      (timer) {
        _currentPage = _calculateNextPage(direction, end);

        if (_isSliding) {
          if (skip) {
            pageController.jumpToPage(_currentPage);
          } else {
            // if last page, just jump to first page without animation
            if (_currentPage == 0) {
              pageController.jumpToPage(0);
            } else {
              pageController.animateToPage(
                _currentPage,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeIn,
              );
            }
          }
        }
      },
    );
  }

  void stopAutoSlide() {
    _isSliding = false;
    _currentRandomPages = null;
    timer?.cancel();
  }

  void resumeAutoSlide() {
    _isSliding = true;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
