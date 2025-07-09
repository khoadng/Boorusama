// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config.dart';

final hideDeletedProvider = StateProvider.autoDispose.family<bool, BooruConfig>(
  (ref, config) {
    return config.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide;
  },
);
