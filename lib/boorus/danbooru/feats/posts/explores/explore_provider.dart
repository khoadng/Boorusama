// Package imports:

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/types.dart';

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

final danbooruExploreRepoProvider =
    Provider.family<ExploreRepository, BooruConfig>(
  (ref, config) {
    return ExploreRepositoryCacher(
      repository: ExploreRepositoryApi(
        transformer: (posts) =>
            ref.read(danbooruPostFetchTransformerProvider(config))(posts),
        client: ref.watch(danbooruClientProvider(config)),
        postRepository: ref.watch(danbooruPostRepoProvider(config)),
        settingsRepository: ref.watch(settingsRepoProvider),
        shouldFilter: switch (ref.watchConfig.ratingFilter) {
          BooruConfigRatingFilter.hideNSFW => (post) =>
              post.rating != Rating.general || !post.viewable,
          BooruConfigRatingFilter.hideExplicit => (post) =>
              post.rating.isNSFW() || !post.viewable,
          BooruConfigRatingFilter.none => (post) => !post.viewable,
        },
      ),
      popularStaleDuration: const Duration(minutes: 20),
      mostViewedStaleDuration: const Duration(hours: 1),
      hotStaleDuration: const Duration(minutes: 5),
    );
  },
  dependencies: [
    danbooruClientProvider,
    danbooruPostRepoProvider,
    settingsRepoProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruMostViewedTodayProvider =
    FutureProvider<List<DanbooruPost>>((ref) async {
  final repo = ref
      .watch(danbooruExploreRepoProvider(ref.watchConfig))
      .getMostViewedPosts(DateTime.now());

  return repo.run().then((value) => value.fold(
        (l) => <DanbooruPost>[],
        (r) => r,
      ));
});

final danbooruPopularTodayProvider =
    FutureProvider<List<DanbooruPost>>((ref) async {
  final repo = ref
      .watch(danbooruExploreRepoProvider(ref.watchConfig))
      .getPopularPosts(DateTime.now(), 1, TimeScale.day);

  return repo.run().then((value) => value.fold(
        (l) => <DanbooruPost>[],
        (r) => r,
      ));
});

final danbooruHotTodayProvider =
    FutureProvider<List<DanbooruPost>>((ref) async {
  final repo =
      ref.watch(danbooruExploreRepoProvider(ref.watchConfig)).getHotPosts(1);

  return repo.run().then((value) => value.fold(
        (l) => <DanbooruPost>[],
        (r) => r,
      ));
});
