// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

const kDefaultAutoSlideDuration = Duration(seconds: 5);

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

  void startAutoSlide(
    int start,
    int end, {
    bool skipAnimation = true,
    Duration duration = kDefaultAutoSlideDuration,
  }) {
    if (_isSliding) return;
    final skip = _shouldSkipAnimation(skipAnimation, duration);

    _isSliding = true;
    timer?.cancel();
    _currentPage = start;

    timer = Timer.periodic(
      duration,
      (timer) {
        _currentPage = (_currentPage + 1) % end;

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
