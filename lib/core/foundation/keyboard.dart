// Flutter imports:
import 'package:flutter/services.dart';

mixin KeyboardListenerMixin {
  HardwareKeyboard get keyboard => HardwareKeyboard.instance;

  void registerListener(bool Function(KeyEvent event) listener) {
    keyboard.addHandler(listener);
  }

  void removeListener(bool Function(KeyEvent event) listener) {
    keyboard.removeHandler(listener);
  }

  bool isKeyPressed(
    LogicalKeyboardKey key, {
    required KeyEvent event,
    bool controlOrMeta = false,
  }) {
    if (event is KeyDownEvent) {
      if (controlOrMeta) {
        if (keyboard.isControlOrMetaPressed && event.logicalKey == key) {
          return true;
        }
      } else {
        if (event.logicalKey == key) {
          return true;
        }
      }
    }

    return false;
  }
}

extension HardwareKeyboardX on HardwareKeyboard {
  bool get isControlOrMetaPressed => isMetaPressed || isControlPressed;
}
