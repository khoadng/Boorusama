// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'slideshow_direction.dart';

const kDefaultAutoSlideDuration = Duration(seconds: 5);

class SlideshowOptions {
  const SlideshowOptions({
    this.duration = const Duration(seconds: 5),
    this.direction = SlideshowDirection.forward,
    this.skipTransition = false,
  });

  final Duration duration;
  final SlideshowDirection direction;
  final bool skipTransition;
}

class SlideshowController {
  SlideshowController({
    required this.pageController,
    this.options = const SlideshowOptions(),
  });

  final PageController pageController;
  SlideshowOptions options;

  Timer? _timer;
  var _currentPage = 0;
  var _isSliding = false;
  List<int>? _currentRandomPages;

  bool get isSliding => _isSliding;

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

  List<int> _generateRandomPages(int end) {
    final pages = List.generate(end, (index) => index)..shuffle();
    return pages;
  }

  void start(
    int startPage,
    int totalPages,
  ) {
    if (_isSliding) return;

    final duration = options.duration;
    final direction = options.direction;
    final skipAnimation = options.skipTransition;

    final skip = _shouldSkipAnimation(skipAnimation, duration);

    _isSliding = true;
    _timer?.cancel();
    _currentRandomPages = null;
    _currentPage = startPage;

    _timer = Timer.periodic(
      duration,
      (timer) {
        _currentPage = _calculateNextPage(direction, totalPages);

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

  void stop() {
    _isSliding = false;
    _currentRandomPages = null;
    _timer?.cancel();
  }

  void resume() {
    _isSliding = true;
  }

  void dispose() {
    _timer?.cancel();
  }
}
