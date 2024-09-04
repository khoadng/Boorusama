// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';

final extraHttpHeaderProvider =
    Provider.family<Map<String, String>, BooruConfig>(
  (ref, config) => switch (config.booruType) {
    _ => {},
  },
);