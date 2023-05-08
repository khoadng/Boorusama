// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';

final gridSizeSettingsProvider = Provider<GridSize>(
    (ref) => ref.watch(settingsProvider.select((value) => value.gridSize)));

final imageListTypeSettingsProvider = Provider<ImageListType>((ref) =>
    ref.watch(settingsProvider.select((value) => value.imageListType)));

//FIXME: PageMode should be move to settings
final pageModeSettingsProvider = Provider<PageMode>((ref) => ref.watch(
    settingsProvider.select((value) => value.contentOrganizationCategory ==
            ContentOrganizationCategory.infiniteScroll
        ? PageMode.infinite
        : PageMode.paginated)));

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
          contentOrganizationCategory: mode == PageMode.infinite
              ? ContentOrganizationCategory.infiniteScroll
              : ContentOrganizationCategory.pagination,
        ),
      );
}
