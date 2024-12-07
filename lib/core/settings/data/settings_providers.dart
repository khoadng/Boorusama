// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/manage.dart';
import '../settings.dart';
import 'settings_notifier.dart';

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, Settings>(
  () => throw UnimplementedError(),
  name: 'settingsNotifierProvider',
);

final settingsProvider = Provider<Settings>(
  (ref) => ref.watch(settingsNotifierProvider),
  name: 'settingsProvider',
  dependencies: [settingsNotifierProvider],
);

final hasCustomListingSettingsProvider = Provider<bool>((ref) {
  final listingConfigs =
      ref.watch(currentBooruConfigProvider.select((value) => value.listing));

  return listingConfigs != null && listingConfigs.enable;
});

final imageListingSettingsProvider = Provider<ImageListingSettings>((ref) {
  final listing = ref.watch(settingsProvider.select((value) => value.listing));

  // check if user has set custom settings
  final listingConfigs =
      ref.watch(currentBooruConfigProvider.select((value) => value.listing));

  // if user has set it and it's enabled, return it
  if (listingConfigs != null && listingConfigs.enable) {
    return listingConfigs.settings;
  }

  // otherwise, return the global settings
  return listing;
});
