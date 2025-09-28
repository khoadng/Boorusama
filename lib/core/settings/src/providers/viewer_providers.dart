// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/manage/providers.dart';
import '../types/settings.dart';
import 'settings_provider.dart';

final imageViewerSettingsProvider = Provider<ImageViewerSettings>((ref) {
  final viewer = ref.watch(settingsProvider.select((value) => value.viewer));

  // check if user has set custom settings
  final viewerConfigs = ref.watch(
    currentBooruConfigProvider.select((value) => value.viewerConfigs),
  );

  // if user has set it and it's enabled, return it
  if (viewerConfigs != null && viewerConfigs.enable) {
    return viewerConfigs.settings;
  }

  // otherwise, return the global settings
  return viewer;
});

final hasCustomViewerSettingsProvider = Provider<bool>((ref) {
  final viewerConfigs = ref.watch(
    currentBooruConfigProvider.select((value) => value.viewerConfigs),
  );

  return viewerConfigs != null && viewerConfigs.enable;
});
