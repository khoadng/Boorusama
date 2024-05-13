// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

mixin AutomaticSlideMixin<T extends StatefulWidget> on State<T> {
  PageController get pageController;
  Timer? timer;
  int _currentPage = 0;
  bool _isSliding = false;

  void startAutoSlide(
    int start,
    int end, {
    List<int>? skipIndexes,
    bool skipAnimation = true,
    Duration? duration,
  }) {
    if (_isSliding) return;
    _isSliding = true;
    timer?.cancel();
    _currentPage = start;

    timer = Timer.periodic(
      duration ?? const Duration(seconds: 1),
      (timer) {
        _currentPage = (_currentPage + 1) % end;

        if (_isSliding) {
          if (skipAnimation) {
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
