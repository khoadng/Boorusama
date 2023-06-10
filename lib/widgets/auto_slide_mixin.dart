// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

mixin AutomaticSlideMixin<T extends StatefulWidget> on State<T> {
  PageController get pageController;
  Timer? timer;
  int currentPage = 0;
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

    timer = Timer.periodic(
      duration ?? const Duration(seconds: 1),
      (timer) {
        if (currentPage < end - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }

        // skip if current page is in skipIndexes
        if (skipIndexes?.contains(currentPage) ?? false) {
          return;
        }

        if (_isSliding) {
          if (skipAnimation) {
            pageController.jumpToPage(currentPage);
          } else {
            pageController.animateToPage(
              currentPage,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeIn,
            );
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
