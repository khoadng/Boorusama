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
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/functional.dart';

final danbooruUserRepoProvider =
    Provider.family<UserRepository, BooruConfig>((ref, config) {
  return UserRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
    ref.watch(tagInfoProvider).defaultBlacklistedTags,
  );
});

const _kCurrentUserIdKey = '_danbooru_current_user_id';

final danbooruCurrentUserProvider = FutureProvider.autoDispose
    .family<UserSelf?, BooruConfig>((ref, config) async {
  if (!config.hasLoginDetails()) return null;

  // First, we try to get the user id from the cache
  final miscData = await ref.watch(miscDataBoxProvider.future);
  final key = '${_kCurrentUserIdKey}_${config.login}';
  final cached = miscData.get(key);
  var id = cached != null ? int.tryParse(cached) : null;

  // If the cached id is null, we need to fetch it from the api
  if (id == null) {
    final dio = newDio(ref.watch(dioArgsProvider(config)));

    final data = await DanbooruClient(
            dio: dio,
            baseUrl: config.url,
            apiKey: config.apiKey,
            login: config.login)
        .getProfile()
        .then((value) => value.data['id']);

    id = switch (data) {
      int i => i,
      _ => null,
    };

    // If the id is not null, we cache it
    if (id != null) {
      miscData.put(key, id.toString());
    }
  }

  // If the id is still null, we can't do anything else here
  if (id == null) return null;

  return ref.watch(danbooruUserRepoProvider(config)).getUserSelfById(id);
});

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
