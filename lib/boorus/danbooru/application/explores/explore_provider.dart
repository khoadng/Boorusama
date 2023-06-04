// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/posts/app.dart';
import 'package:boorusama/boorus/danbooru/features/posts/data.dart';
import 'package:boorusama/boorus/danbooru/features/posts/models.dart';
import 'package:boorusama/core/application/blacklists.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/rating.dart';
import 'package:boorusama/core/provider.dart';

typedef ScaleAndTime = ({
  TimeScale scale,
  DateTime date,
});

final timeScaleProvider = StateProvider<TimeScale>((ref) => TimeScale.day);
final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final timeAndDateProvider = Provider<ScaleAndTime>((ref) {
  final timeScale = ref.watch(timeScaleProvider);
  final date = ref.watch(dateProvider);

  return (scale: timeScale, date: date);
}, dependencies: [
  timeScaleProvider,
  dateProvider,
]);

final danbooruExploreRepoProvider = Provider<ExploreRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final postRepository = ref.watch(danbooruPostRepoProvider);
    final settingsRepository = ref.watch(settingsRepoProvider);
    final blacklistedTagRepository =
        ref.watch(globalBlacklistedTagRepoProvider);
    final config = ref.watch(currentBooruConfigProvider);

    return ExploreRepositoryCacher(
      repository: ExploreRepositoryApi(
        api: api,
        booruConfig: config,
        postRepository: postRepository,
        settingsRepository: settingsRepository,
        blacklistedTagRepository: blacklistedTagRepository,
        shouldFilter: switch (config.ratingFilter) {
          BooruConfigRatingFilter.hideNSFW => (post) =>
              post.rating != Rating.general,
          BooruConfigRatingFilter.hideExplicit => (post) =>
              post.rating.isNSFW(),
          BooruConfigRatingFilter.none => null,
        },
      ),
      popularStaleDuration: const Duration(minutes: 20),
      mostViewedStaleDuration: const Duration(hours: 1),
      hotStaleDuration: const Duration(minutes: 5),
    );
  },
  dependencies: [
    danbooruApiProvider,
    danbooruPostRepoProvider,
    settingsRepoProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
  ],
);
