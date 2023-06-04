// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/users.dart';
import 'package:boorusama/boorus/danbooru/application/users/users_notifier.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/posts/app.dart';
import 'package:boorusama/boorus/danbooru/features/posts/models.dart';
import 'package:boorusama/boorus/danbooru/features/users/users.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';

final danbooruUserRepoProvider = Provider<UserRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final defaultBlacklistedTags =
      ref.watch(tagInfoProvider).defaultBlacklistedTags;

  return UserRepositoryApi(
    api,
    booruConfig,
    defaultBlacklistedTags,
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
        'ordfav:${user.name}',
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
