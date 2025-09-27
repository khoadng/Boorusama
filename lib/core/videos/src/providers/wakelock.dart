// Package imports:
import 'package:wakelock_plus/wakelock_plus.dart';

class Wakelock {
  /// The number of [Wakelock] instances in enabled state.
  static var _count = 0;

  /// Whether the wakelock is enabled for this instance.
  var _enabled = false;

  void enable() {
    if (!_enabled) {
      _enabled = true;
      _count++;
      _update();
    }
  }

  void disable() {
    if (_enabled) {
      _enabled = false;
      _count--;
      _update();
    }
  }

  void _update() {
    if (_count > 0) {
      WakelockPlus.enable().catchError((_) {});
    } else {
      WakelockPlus.disable().catchError((_) {});
    }
  }
}
