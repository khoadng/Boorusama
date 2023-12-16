// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';

final gridSizeSettingsProvider = Provider<GridSize>(
    (ref) => ref.watch(settingsProvider.select((value) => value.gridSize)));

final imageListTypeSettingsProvider = Provider<ImageListType>((ref) =>
    ref.watch(settingsProvider.select((value) => value.imageListType)));

final pageModeSettingsProvider = Provider<PageMode>(
    (ref) => ref.watch(settingsProvider.select((value) => value.pageMode)));

final gridSpacingSettingsProvider = Provider<double>((ref) => ref.watch(
    settingsProvider.select((value) => value.imageGridSpacing.toDouble())));

final imageBorderRadiusSettingsProvider = Provider<double>((ref) => ref.watch(
    settingsProvider.select((value) => value.imageBorderRadius.toDouble())));

class SettingsNotifier extends Notifier<Settings> {
  SettingsNotifier(this.initialSettings) : super();

  final Settings initialSettings;

  @override
  Settings build() {
    return initialSettings;
  }

  Future<void> updateSettings(Settings settings) async {
    final currentSettings = state;
    final success = await ref.read(settingsRepoProvider).save(settings);

    if (success) {
      for (var i = 0; i < currentSettings.props.length; i++) {
        final cs = currentSettings.props[i];
        final ns = settings.props[i];

        if (cs != ns) {
          ref.read(loggerProvider).logI(
              'Settings', 'Settings updated: ${cs.runtimeType} $cs -> $ns');
        }
      }
      state = settings;
    }
  }

  // export
  Future<void> exportSettings() async {
    final data = await ref.read(settingsRepoProvider).export(state);
    print(data);
  }
}

extension SettingsNotifierX on WidgetRef {
  Future<void> updateSettings(Settings settings) =>
      read(settingsProvider.notifier).updateSettings(settings);

  Future<void> setGridSize(GridSize size) => updateSettings(
        read(settingsProvider).copyWith(
          gridSize: size,
        ),
      );

  Future<void> setImageListType(ImageListType type) => updateSettings(
        read(settingsProvider).copyWith(
          imageListType: type,
        ),
      );

  Future<void> setPageMode(PageMode mode) => updateSettings(
        read(settingsProvider).copyWith(
          pageMode: mode,
        ),
      );

  Future<void> setPostListConfigHeaderStatus({
    required bool active,
  }) =>
      updateSettings(
        read(settingsProvider).copyWith(
          showPostListConfigHeader: active,
        ),
      );

  Future<void> setBooruConfigOrder(List<int> configIds) => updateSettings(
        read(settingsProvider).copyWith(
          booruConfigIdOrders: configIds.join(' '),
        ),
      );
}

extension SettingsNotifierProviderRef on NotifierProviderRef {
  Future<void> updateSettings(Settings settings) =>
      read(settingsProvider.notifier).updateSettings(settings);

  Future<void> setBooruConfigOrder(List<int> configIds) => updateSettings(
        read(settingsProvider).copyWith(
          booruConfigIdOrders: configIds.join(' '),
        ),
      );
}

extension SettingsProviderRef on ProviderRef {
  Future<void> updateSettings(Settings settings) =>
      read(settingsProvider.notifier).updateSettings(settings);

  Future<void> setBooruConfigOrder(List<int> configIds) => updateSettings(
        read(settingsProvider).copyWith(
          booruConfigIdOrders: configIds.join(' '),
        ),
      );
}
