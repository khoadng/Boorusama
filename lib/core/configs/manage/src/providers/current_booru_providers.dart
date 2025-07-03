// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../settings/providers.dart';
import '../../../../theme/theme_configs.dart';
import '../../../config/types.dart';
import '../../../gesture/gesture.dart';

final currentBooruConfigProvider =
    NotifierProvider<CurrentBooruConfigNotifier, BooruConfig>(
  CurrentBooruConfigNotifier.new,
  dependencies: [
    settingsProvider,
    loggerProvider,
    initialSettingsBooruConfigProvider,
  ],
  name: 'currentBooruConfigProvider',
);

final initialSettingsBooruConfigProvider = Provider<BooruConfig>(
  (ref) => throw UnimplementedError(),
  name: 'initialSettingsBooruConfigProvider',
);

final currentReadOnlyBooruConfigProvider = Provider<BooruConfig>(
  (ref) => ref.watch(currentBooruConfigProvider),
  name: 'currentReadOnlyBooruConfigProvider',
);

final currentReadOnlyBooruConfigAuthProvider = Provider<BooruConfigAuth>(
  (ref) => ref.watch(currentBooruConfigProvider.select((value) => value.auth)),
  name: 'currentReadOnlyBooruConfigAuthProvider',
);

final currentReadOnlyBooruConfigSearchProvider = Provider<BooruConfigSearch>(
  (ref) =>
      ref.watch(currentBooruConfigProvider.select((value) => value.search)),
  name: 'currentReadOnlyBooruConfigSearchProvider',
);

final currentReadOnlyBooruConfigFilterProvider = Provider<BooruConfigFilter>(
  (ref) =>
      ref.watch(currentBooruConfigProvider.select((value) => value.filter)),
  name: 'currentReadOnlyBooruConfigFilterProvider',
);

final currentReadOnlyBooruConfigGestureProvider = Provider<PostGestureConfig?>(
  (ref) => ref
      .watch(currentBooruConfigProvider.select((value) => value.postGestures)),
  name: 'currentReadOnlyBooruConfigGestureProvider',
);

final currentReadOnlyBooruConfigThemeProvider = Provider<ThemeConfigs?>(
  (ref) => ref.watch(currentBooruConfigProvider.select((value) => value.theme)),
  name: 'currentReadOnlyBooruConfigThemeProvider',
);

final currentReadOnlyBooruConfigLayoutProvider = Provider<LayoutConfigs?>(
  (ref) =>
      ref.watch(currentBooruConfigProvider.select((value) => value.layout)),
  name: 'currentReadOnlyBooruConfigLayoutProvider',
);

final currentReadOnlyBooruConfigViewerProvider = Provider<BooruConfigViewer>(
  (ref) =>
      ref.watch(currentBooruConfigProvider.select((value) => value.viewer)),
  name: 'currentReadOnlyBooruConfigViewerProvider',
);

class CurrentBooruConfigNotifier extends Notifier<BooruConfig> {
  @override
  BooruConfig build() {
    final config = ref.watch(initialSettingsBooruConfigProvider);

    return config;
  }

  Future<void> setEmpty() async {
    return update(BooruConfig.empty);
  }

  Future<void> update(BooruConfig booruConfig) async {
    // if same config, do nothing
    if (booruConfig == state) return;

    state = booruConfig;
    final settings = ref
        .read(settingsProvider)
        .copyWith(currentBooruConfigId: booruConfig.id);
    await ref.read(settingsNotifierProvider.notifier).updateSettings(settings);
  }
}
