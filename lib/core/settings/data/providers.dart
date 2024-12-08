// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/current.dart';
import 'settings_repository.dart';

final settingsRepoProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError(),
  name: 'settingsRepoProvider',
);

final hasCustomListingSettingsProvider = Provider<bool>((ref) {
  final listingConfigs =
      ref.watch(currentBooruConfigProvider.select((value) => value.listing));

  return listingConfigs != null && listingConfigs.enable;
});
