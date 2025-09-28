// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenLockNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void lock() {
    state = true;
  }

  void unlock() {
    state = false;
  }
}

final screenLockProvider = NotifierProvider<ScreenLockNotifier, bool>(
  ScreenLockNotifier.new,
);
