// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

final danbooruUserRepoProvider = Provider<UserRepository>((ref) {
  return UserRepositoryApi(
    ref.watch(danbooruApiProvider),
    ref.watch(tagInfoProvider).defaultBlacklistedTags,
  );
});

final danbooruCurrentUserProvider =
    NotifierProvider<CurrentUserNotifier, UserSelf?>(
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

  final repo = ref.watch(danbooruPostRepoProvider);
  final uploads = await repo
      .getPosts(
        'user:${user.name}',
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
  final user = await ref.watch(danbooruUserProvider(uid).future);
  final repo = ref.watch(danbooruPostRepoProvider);
  final favs = await repo
      .getPosts(
        buildFavoriteQuery(user.name),
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
