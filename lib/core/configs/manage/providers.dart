// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/foundation/gestures.dart';

final currentBooruConfigProvider =
    NotifierProvider<CurrentBooruConfigNotifier, BooruConfig>(
  CurrentBooruConfigNotifier.new,
  dependencies: [
    settingsProvider,
    loggerProvider,
    initialSettingsBooruConfigProvider,
  ],
  name: 'currentBooruConfigProvider',
);

final initialSettingsBooruConfigProvider = Provider<BooruConfig>(
  (ref) => throw UnimplementedError(),
  name: 'initialSettingsBooruConfigProvider',
);

final currentReadOnlyBooruConfigProvider = Provider<BooruConfig>(
  (ref) => ref.watch(currentBooruConfigProvider),
  name: 'currentReadOnlyBooruConfigProvider',
);

final currentReadOnlyBooruConfigAuthProvider = Provider<BooruConfigAuth>(
  (ref) => ref.watch(currentBooruConfigProvider.select((value) => value.auth)),
  name: 'currentReadOnlyBooruConfigAuthProvider',
);

final currentReadOnlyBooruConfigSearchProvider = Provider<BooruConfigSearch>(
  (ref) =>
      ref.watch(currentBooruConfigProvider.select((value) => value.search)),
  name: 'currentReadOnlyBooruConfigSearchProvider',
);

final currentReadOnlyBooruConfigGestureProvider = Provider<PostGestureConfig?>(
  (ref) => ref
      .watch(currentBooruConfigProvider.select((value) => value.postGestures)),
  name: 'currentReadOnlyBooruConfigGestureProvider',
);
