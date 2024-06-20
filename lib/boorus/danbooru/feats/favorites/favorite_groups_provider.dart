// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';

//#region Previews
final danbooruFavoriteGroupPreviewProvider =
    Provider.autoDispose.family<String, int?>((ref, postId) {
  final config = ref.watchConfig;
  return ref.watch(danbooruFavoriteGroupPreviewsProvider(config))[postId] ?? '';
});

final danbooruFavoriteGroupPreviewsProvider = NotifierProvider.family<
    FavoriteGroupPreviewsNotifier, Map<int, String>, BooruConfig>(
  FavoriteGroupPreviewsNotifier.new,
  dependencies: [
    danbooruPostRepoProvider,
  ],
);
//#endregion

//#region Favorite Groups
final danbooruFavoriteGroupRepoProvider =
    Provider.family<FavoriteGroupRepository, BooruConfig>((ref, config) {
  return FavoriteGroupRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});

final danbooruFavoriteGroupsProvider = NotifierProvider.family<
    FavoriteGroupsNotifier, List<FavoriteGroup>?, BooruConfig>(
  FavoriteGroupsNotifier.new,
  dependencies: [
    danbooruFavoriteGroupRepoProvider,
    currentBooruConfigProvider,
    danbooruCurrentUserProvider,
  ],
);

final danbooruFavoriteGroupFilterableProvider = NotifierProvider.autoDispose
    .family<FavoriteGroupFilterableNotifier, List<FavoriteGroup>?, BooruConfig>(
  FavoriteGroupFilterableNotifier.new,
  dependencies: [
    danbooruFavoriteGroupsProvider,
  ],
);

//#endregion
