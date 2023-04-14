// Flutter imports:
import 'package:flutter/material.dart';

mixin SwipeDownToDismissMixin<T extends StatefulWidget> on State<T> {
  bool _isSwipingDown = false;
  double _dragStartPosition = 0.0;
  double _dragDistance = 0.0;
  double _dragStartXPosition = 0.0;
  double _dragDistanceX = 0.0;
  double _scale = 1.0;

  void handlePointerMove(PointerMoveEvent event) {
    if (!_isSwipingDown &&
        event.delta.dy > 0 &&
        event.delta.dy.abs() > event.delta.dx.abs() * 2) {
      _isSwipingDown = true;
      _dragStartPosition = event.position.dy;
      _dragStartXPosition = event.position.dx;
    }

    if (_isSwipingDown) {
      setState(() {
        _dragDistance = event.position.dy - _dragStartPosition;
        _dragDistanceX = event.position.dx - _dragStartXPosition;
        double scaleValue = 1 -
            (_dragDistance.abs() / MediaQuery.of(context).size.height) * 0.5;
        scaleValue = scaleValue.clamp(0.8, 1.0);
        _scale = scaleValue;
      });
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    if (_isSwipingDown) {
      Navigator.of(context).pop();
      _isSwipingDown = false;
    }
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (_isSwipingDown) {
      return true;
    }
    return false;
  }

  double calculateBackgroundOpacity() {
    if (!_isSwipingDown) {
      return 1.0;
    }
    double opacity =
        1 - (_dragDistance.abs() / MediaQuery.of(context).size.height);
    return opacity.clamp(0.0, 1.0);
  }

  double get scale => _scale;
  double get dragDistance => _dragDistance;
  double get dragDistanceX => _dragDistanceX;
  bool get isSwipingDown => _isSwipingDown;
}
