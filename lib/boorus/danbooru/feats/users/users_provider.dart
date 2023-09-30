// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/creator_repository.dart';
import 'package:boorusama/boorus/danbooru/feats/users/creators_notifier.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';

final danbooruUserRepoProvider =
    Provider.family<UserRepository, BooruConfig>((ref, config) {
  return UserRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
    ref.watch(tagInfoProvider).defaultBlacklistedTags,
  );
});

final danbooruCurrentUserProvider =
    NotifierProvider.family<CurrentUserNotifier, UserSelf?, BooruConfig>(
  CurrentUserNotifier.new,
  dependencies: [
    danbooruUserRepoProvider,
    currentBooruConfigProvider,
    booruUserIdentityProviderProvider
  ],
);

final danbooruUserProvider =
    AsyncNotifierProvider.family<UserNotifier, User, int>(
  UserNotifier.new,
);

final danbooruUserUploadsProvider = FutureProvider.autoDispose
    .family<List<DanbooruPost>, int>((ref, uid) async {
  final user = await ref.watch(danbooruUserProvider(uid).future);

  if (user.uploadCount == 0) return [];
  final config = ref.watchConfig;

  final repo = ref.watch(danbooruPostRepoProvider(config));
  final uploads = await repo
      .getPosts(
        ['user:${user.name}'],
        1,
        limit: 50,
      )
      .run()
      .then((value) => value.fold(
            (l) => <DanbooruPost>[],
            (r) => r,
          ));

  return uploads;
});

final danbooruUserFavoritesProvider = FutureProvider.autoDispose
    .family<List<DanbooruPost>, int>((ref, uid) async {
  final config = ref.watchConfig;
  final user = await ref.watch(danbooruUserProvider(uid).future);
  final repo = ref.watch(danbooruPostRepoProvider(config));
  final favs = await repo
      .getPosts(
        [buildFavoriteQuery(user.name)],
        1,
        limit: 50,
      )
      .run()
      .then((value) => value.fold(
            (l) => <DanbooruPost>[],
            (r) => r,
          ));

  return favs;
});

final danbooruCreatorHiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

final danbooruCreatorRepoProvider =
    Provider.family<CreatorRepository, BooruConfig>(
  (ref, config) {
    return CreatorRepositoryFromUserRepo(
      ref.watch(danbooruUserRepoProvider(config)),
      ref.watch(danbooruCreatorHiveBoxProvider),
    );
  },
  dependencies: [
    danbooruCreatorHiveBoxProvider,
  ],
);

final danbooruCreatorsProvider =
    NotifierProvider.family<CreatorsNotifier, IMap<int, Creator>, BooruConfig>(
        CreatorsNotifier.new);

final danbooruCreatorProvider = Provider.family<Creator?, int>((ref, id) {
  final config = ref.watchConfig;
  return ref.watch(danbooruCreatorsProvider(config))[id];
});
