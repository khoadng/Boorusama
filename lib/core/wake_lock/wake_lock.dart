// Dart imports:
import 'dart:async';

// Package imports:
import 'package:wakelock_plus/wakelock_plus.dart';

class WakeLock {
  WakeLock._();

  static final WakeLock _instance = WakeLock._();

  bool _isWakeLockEnabled = false;

  static Future<void> enable() => _instance._enable();
  static Future<void> disable() => _instance._disable();
  static Future<void> dispose() => _instance._dispose();

  Future<void> _enable() async {
    if (_isWakeLockEnabled) return;
    await WakelockPlus.enable();
    _isWakeLockEnabled = await WakelockPlus.enabled;
  }

  Future<void> _disable() async {
    if (!_isWakeLockEnabled) return;
    await WakelockPlus.disable();
    _isWakeLockEnabled = await WakelockPlus.enabled;
  }

  Future<void> _dispose() async {
    await _disable();
  }
}
