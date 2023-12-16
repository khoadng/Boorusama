// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/backup/data_io_handler.dart';
import 'package:boorusama/core/feats/settings/types.dart';
import 'settings_io_handler.dart';

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

final settingIOHandlerProvider = Provider<SettingsIOHandler>(
  (ref) => SettingsIOHandler(
    handler: DataIOHandler.file(
      version: 1,
      deviceInfo: ref.watch(deviceInfoProvider),
      prefixName: 'boorusama_settings',
    ),
  ),
);
