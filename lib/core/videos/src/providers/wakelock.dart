// Package imports:
import 'package:wakelock_plus/wakelock_plus.dart';

/// Wakelock manager with reference counting, based on media-kit implementation.
/// Each instance tracks its own enabled state to prevent duplicate calls.
class Wakelock {
  /// Whether the wakelock is enabled for this instance.
  bool _enabled = false;

  /// Marks the wakelock as enabled for this instance.
  void enable() {
    if (!_enabled) {
      _enabled = true;
      _count++;
      _update();
    }
  }

  /// Marks the wakelock as disabled for this instance.
  void disable() {
    if (_enabled) {
      _enabled = false;
      _count--;
      _update();
    }
  }

  /// Acquires the wakelock if enabled count is greater than 0.
  void _update() {
    if (_count > 0) {
      WakelockPlus.enable().catchError((_) {});
    } else {
      WakelockPlus.disable().catchError((_) {});
    }
  }

  /// The number of [Wakelock] instances in enabled state.
  static int _count = 0;

  /// Current reference count for debugging purposes.
  static int get referenceCount => _count;
}
