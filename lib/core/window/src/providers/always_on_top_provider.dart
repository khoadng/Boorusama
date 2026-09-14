// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/platform.dart';
import '../../../../foundation/window.dart';

final alwaysOnTopProvider = AsyncNotifierProvider<AlwaysOnTopNotifier, bool>(
  AlwaysOnTopNotifier.new,
);

class AlwaysOnTopNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    if (ref.watch(appPlatformProvider).isDesktop) {
      return ref.watch(windowServiceProvider).isAlwaysOnTop();
    }
    return false;
  }

  Future<void> setAlwaysOnTop(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (ref.read(appPlatformProvider).isDesktop) {
        await ref.read(windowServiceProvider).setAlwaysOnTop(value);
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
