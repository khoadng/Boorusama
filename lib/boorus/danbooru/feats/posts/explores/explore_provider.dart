// Package imports:

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
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
        shouldFilter: (post) {
          // A special rule for safebooru to make sure inappropriate posts are not shown
          if (config.url == kDanbooruSafeUrl) {
            return post.rating != Rating.general;
          }

          final filterer =
              ref.readCurrentBooruBuilder()?.granularRatingFilterer;

          if (filterer == null) return false;

          return filterer(post, config);
        },
      ),
      popularStaleDuration: const Duration(seconds: 10),
      mostViewedStaleDuration: const Duration(seconds: 30),
      hotStaleDuration: const Duration(seconds: 5),
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
