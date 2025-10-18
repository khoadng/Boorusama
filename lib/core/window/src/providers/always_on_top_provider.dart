// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

// Project imports:
import '../../../../foundation/platform.dart';

final alwaysOnTopProvider = AsyncNotifierProvider<AlwaysOnTopNotifier, bool>(
  AlwaysOnTopNotifier.new,
);

class AlwaysOnTopNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    if (isDesktopPlatform()) {
      return windowManager.isAlwaysOnTop();
    }
    return false;
  }

  Future<void> setAlwaysOnTop(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (isDesktopPlatform()) {
        await windowManager.setAlwaysOnTop(value);
        return value;
      }
      return false;
    });
  }

  Future<void> toggle() async {
    final currentValue = await future;
    await setAlwaysOnTop(!currentValue);
  }
}
