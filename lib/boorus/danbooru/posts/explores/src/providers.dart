// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/boorus/engine/providers.dart';
import '../../../../../core/configs/config.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/explores/explore.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/posts/rating/rating.dart';
import '../../../../../core/settings/providers.dart';
import '../../../client_provider.dart';
import '../../../constants.dart';
import '../../post/post.dart';
import '../../post/providers.dart';
import 'data/explore_repository_cacher.dart';
import 'data/explore_repository_impl.dart';
import 'types/explore_repository.dart';

final danbooruExploreRepoProvider =
    Provider.family<ExploreRepository, BooruConfigSearch>(
      (ref, config) {
        return ExploreRepositoryCacher(
          repository: ExploreRepositoryApi(
            transformer: (posts) => transformPosts(ref, posts, config),
            client: ref.watch(danbooruClientProvider(config.auth)),
            postRepository: ref.watch(danbooruPostRepoProvider(config)),
            settings: () => ref.read(imageListingSettingsProvider),
            shouldFilter: (post) {
              // A special rule for safebooru to make sure inappropriate posts are not shown
              if (config.auth.url == kDanbooruSafeUrl) {
                return post.rating != Rating.general;
              }

              final filterer = ref
                  .read(booruRepoProvider(config.auth))
                  ?.granularRatingFilterer(config);

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
        settingsRepoProvider,
        booruBuilderProvider,
      ],
    );

final danbooruMostViewedTodayProvider =
    FutureProvider<PostResult<DanbooruPost>>((ref) {
      final repo = ref
          .watch(danbooruExploreRepoProvider(ref.watchConfigSearch))
          .getMostViewedPosts(DateTime.now());

      return repo.run().then(
        (value) => value.fold(
          (l) => <DanbooruPost>[].toResult(),
          (r) => r,
        ),
      );
    });

final danbooruPopularTodayProvider = FutureProvider<PostResult<DanbooruPost>>((
  ref,
) {
  final repo = ref
      .watch(danbooruExploreRepoProvider(ref.watchConfigSearch))
      .getPopularPosts(DateTime.now(), 1, TimeScale.day);

  return repo.run().then(
    (value) => value.fold(
      (l) => <DanbooruPost>[].toResult(),
      (r) => r,
    ),
  );
});

final danbooruHotTodayProvider = FutureProvider<PostResult<DanbooruPost>>((
  ref,
) {
  final repo = ref
      .watch(danbooruExploreRepoProvider(ref.watchConfigSearch))
      .getHotPosts(1);

  return repo.run().then(
    (value) => value.fold(
      (l) => <DanbooruPost>[].toResult(),
      (r) => r,
    ),
  );
});
