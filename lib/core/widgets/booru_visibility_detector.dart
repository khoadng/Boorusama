// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:visibility_detector/visibility_detector.dart';

class VisibilityController extends ChangeNotifier {
  var _isVisible = false;

  bool get isVisible => _isVisible;

  void setVisible(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      notifyListeners();
    }
  }
}

class BooruVisibilityDetector extends StatelessWidget {
  const BooruVisibilityDetector({
    super.key,
    required this.controller,
    required this.childKey,
  });

  final VisibilityController controller;
  final Key childKey;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: childKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0 && !controller.isVisible) {
          controller.setVisible(true);
        }
      },
      child: const SizedBox(
        height: 1,
      ),
    );
  }
}
