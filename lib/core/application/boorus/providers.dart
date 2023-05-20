// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/provider.dart';

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
    currentBooruConfigRepoProvider,
    settingsProvider,
    authenticationProvider,
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
