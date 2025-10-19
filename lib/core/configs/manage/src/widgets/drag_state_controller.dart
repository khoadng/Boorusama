// Flutter imports:
import 'package:flutter/material.dart';

class DragStateController extends ChangeNotifier {
  var _isDragging = false;

  bool get isDragging => _isDragging;

  void startDrag() {
    _isDragging = true;
    notifyListeners();
  }

  void endDrag() {
    _isDragging = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDragging = false;
    super.dispose();
  }
}
