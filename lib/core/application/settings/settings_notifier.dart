import 'dart:async';

import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends AsyncNotifier<Settings> {
  SettingsNotifier() : super();
  @override
  FutureOr<Settings> build() {
    final repo = ref.watch(settingsRepoProvider);

    return repo
        .load()
        .run()
        .then((value) => value.getOrElse((e) => Settings.defaultSettings));
  }

  Future<void> updateSettings(Settings settings) async {
    final success = await ref.read(settingsRepoProvider).save(settings);
    if (success) {
      state = AsyncData(settings);
    }
  }
}
