// Flutter imports:
import 'package:flutter/gestures.dart';

class TouchCountRecognizer extends OneSequenceGestureRecognizer {
  TouchCountRecognizer(this.onMultiTouchUpdated);
  final Function(bool multiTouch) onMultiTouchUpdated;
  int touchcount = 0;

  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    if (touchcount < 1) {
      onMultiTouchUpdated(false);
    } else {
      onMultiTouchUpdated(true);
    }
    touchcount++;
  }

  @override
  String get debugDescription => 'touch count recognizer';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {
    if (!event.down) {
      touchcount--;
      if (touchcount < 1) {
        onMultiTouchUpdated(false);
      }
    }
  }
}
