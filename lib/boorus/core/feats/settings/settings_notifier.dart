// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/provider.dart';

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
    final success = await ref.read(settingsRepoProvider).save(settings);
    if (success) {
      ref.read(loggerProvider).logI('Settings', 'Settings updated');
      state = settings;
    }
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
}
