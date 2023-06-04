// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';

final booruConfigProvider =
    NotifierProvider<BooruConfigNotifier, List<BooruConfig>>(
  BooruConfigNotifier.new,
  dependencies: [
    booruConfigRepoProvider,
  ],
);

final currentBooruConfigProvider =
    NotifierProvider<CurrentBooruConfigNotifier, BooruConfig>(
  () => throw UnimplementedError(),
  dependencies: [
    settingsProvider,
    loggerProvider,
  ],
);

final currentBooruProvider = Provider<Booru>(
  (ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final booruFactory = ref.watch(booruFactoryProvider);
    final booru = booruFactory.from(type: intToBooruType(booruConfig.booruId));

    return booru;
  },
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);
