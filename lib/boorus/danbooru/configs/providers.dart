// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';

final hideDeletedProvider =
    StateProvider.autoDispose.family<bool, BooruConfig>((ref, config) {
  return config.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide;
});

final imageDetailsQualityProvider =
    StateProvider.autoDispose.family<String?, BooruConfig>((ref, config) {
  return config.imageDetaisQuality;
});
