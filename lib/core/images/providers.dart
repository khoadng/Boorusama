// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/hydrus/hydrus.dart';
import 'package:boorusama/core/configs/configs.dart';

final extraHttpHeaderProvider =
    Provider.family<Map<String, String>, BooruConfig>(
  (ref, config) => switch (config.booruType) {
    BooruType.hydrus => ref.watch(hydrusClientProvider(config)).apiKeyHeader,
    _ => {},
  },
);
