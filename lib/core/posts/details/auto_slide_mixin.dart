// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

const kDefaultAutoSlideDuration = Duration(seconds: 5);

enum SlideDirection {
  forward,
  backward,
  random,
}

mixin AutomaticSlideMixin<T extends StatefulWidget> on State<T> {
  PageController get pageController;
  Timer? timer;
  int _currentPage = 0;
  bool _isSliding = false;

  bool _shouldSkipAnimation(bool value, Duration duration) {
    // less than 1 second, skip animation
    if (duration.inSeconds < 1) return true;

    return value;
  }

  int _calculateNextPage(SlideDirection direction, int end) {
    switch (direction) {
      case SlideDirection.forward:
        return (_currentPage + 1) % end;
      case SlideDirection.backward:
        return (_currentPage - 1) % end;
      case SlideDirection.random:
        if (_currentRandomPages == null || _currentRandomPages!.isEmpty) {
          _currentRandomPages = _generateRandomPages(end);
        }
        // pick a random page then remove it from the list
        return _currentRandomPages!.removeAt(0);
    }
  }

  List<int>? _currentRandomPages;

  List<int> _generateRandomPages(int end) {
    final pages = List.generate(end, (index) => index);
    pages.shuffle();
    return pages;
  }

  void startAutoSlide(
    int start,
    int end, {
    bool skipAnimation = true,
    SlideDirection direction = SlideDirection.forward,
    Duration duration = kDefaultAutoSlideDuration,
  }) {
    if (_isSliding) return;
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
