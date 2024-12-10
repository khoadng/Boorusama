// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/hydrus/hydrus.dart';
import '../boorus.dart';
import '../configs/config.dart';

final extraHttpHeaderProvider =
    Provider.family<Map<String, String>, BooruConfigAuth>(
  (ref, config) => switch (config.booruType) {
    BooruType.hydrus => ref.watch(hydrusClientProvider(config)).apiKeyHeader,
    _ => {},
  },
);

const kDefaultImageCacheDuration = Duration(days: 2);
