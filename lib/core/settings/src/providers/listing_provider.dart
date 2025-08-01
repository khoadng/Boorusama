// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/manage/providers.dart';
import '../types/settings.dart';
import '../types/types.dart';
import 'settings_provider.dart';

final imageListingSettingsProvider = Provider<ImageListingSettings>((ref) {
  final listing = ref.watch(settingsProvider.select((value) => value.listing));

  // check if user has set custom settings
  final listingConfigs = ref.watch(
    currentBooruConfigProvider.select((value) => value.listing),
  );

  // if user has set it and it's enabled, return it
  if (listingConfigs != null && listingConfigs.enable) {
    return listingConfigs.settings;
  }

  // otherwise, return the global settings
  return listing;
});

final hasCustomListingSettingsProvider = Provider<bool>((ref) {
  final listingConfigs = ref.watch(
    currentBooruConfigProvider.select((value) => value.listing),
  );

  return listingConfigs != null && listingConfigs.enable;
});

final imageListingQualityProvider = Provider<ImageQuality>((ref) {
  return ref.watch(
    imageListingSettingsProvider.select((value) => value.imageQuality),
  );
});

final selectionIndicatorSizeProvider = Provider<double>((ref) {
  final gridSize = ref.watch(
    imageListingSettingsProvider.select((value) => value.gridSize),
  );

  return 32 * _getGridSizeFactor(gridSize);
});

double _getGridSizeFactor(GridSize gridSize) => switch (gridSize) {
  GridSize.small => 0.95,
  GridSize.normal => 1.0,
  GridSize.large => 1.05,
  GridSize.tiny => 0.85,
  GridSize.micro => 0.75,
};
