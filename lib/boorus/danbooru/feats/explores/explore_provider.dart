// Package imports:

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/types.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';

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
    return ExploreRepositoryCacher(
      repository: ExploreRepositoryApi(
        api: ref.watch(danbooruApiProvider),
        postRepository: ref.watch(danbooruPostRepoProvider),
        settingsRepository: ref.watch(settingsRepoProvider),
        blacklistedTagRepository: ref.watch(globalBlacklistedTagRepoProvider),
        shouldFilter: switch (
            ref.watch(currentBooruConfigProvider).ratingFilter) {
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
    danbooruApiProvider,
    danbooruPostRepoProvider,
    settingsRepoProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
  ],
);
