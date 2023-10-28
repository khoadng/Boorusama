// Flutter imports:
import 'package:flutter/material.dart';

mixin SwipeDownToDismissMixin<T extends StatefulWidget> on State<T> {
  final _isSwipingDown = ValueNotifier(false);
  double _dragStartPosition = 0.0;
  final _dragDistance = ValueNotifier(0.0);
  double _dragStartXPosition = 0.0;
  final _dragDistanceX = ValueNotifier(0.0);
  double _scale = 1.0;

  void handlePointerMove(PointerMoveEvent event) {
    if (!_isSwipingDown.value &&
        event.delta.dy > 0 &&
        event.delta.dy.abs() > event.delta.dx.abs() * 2) {
      _isSwipingDown.value = true;
      _dragStartPosition = event.position.dy;
      _dragStartXPosition = event.position.dx;
    }

    if (_isSwipingDown.value) {
      _dragDistance.value = event.position.dy - _dragStartPosition;
      _dragDistanceX.value = event.position.dx - _dragStartXPosition;
      double scaleValue = 1 -
          (_dragDistance.value.abs() / MediaQuery.sizeOf(context).height) * 0.5;
      scaleValue = scaleValue.clamp(0.8, 1.0);
      _scale = scaleValue;
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    if (_isSwipingDown.value) {
      if (_dragDistance.value.abs() > MediaQuery.sizeOf(context).height * 0.2) {
        popper();
      } else {
        dragDistance.value = 0.0;
        dragDistanceX.value = 0.0;
        _dragStartPosition = 0.0;
        _dragStartXPosition = 0.0;
        _scale = 1.0;
      }
      _isSwipingDown.value = false;

      setState(() {});
    }
  }

  double calculateBackgroundOpacity() {
    if (!_isSwipingDown.value) {
      return 1.0;
    }
    double opacity =
        1 - (_dragDistance.value.abs() / MediaQuery.sizeOf(context).height);
    return opacity.clamp(0.0, 1.0);
  }

  double get scale => _scale;
  ValueNotifier<double> get dragDistance => _dragDistance;
  ValueNotifier<double> get dragDistanceX => _dragDistanceX;
  ValueNotifier<bool> get isSwipingDown => _isSwipingDown;

  Function() get popper;
}
