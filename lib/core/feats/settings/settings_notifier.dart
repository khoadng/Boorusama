// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/widgets/widgets.dart';

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

  Future<void> importSettings(String path) async {
    await ref
        .read(settingIOHandlerProvider)
        .import(
          from: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => showErrorToast(l.toString()),
            (r) => updateSettings(r),
          ),
        );
  }

  Future<void> exportSettings(String path) async {
    await ref
        .read(settingIOHandlerProvider)
        .export(
          state,
          to: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => showErrorToast(l.toString()),
            (r) => showSuccessToast('Settings exported to $path'),
          ),
        );
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

  Future<void> setImageQuality(ImageQuality quality) => updateSettings(
        read(settingsProvider).copyWith(
          imageQuality: quality,
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
