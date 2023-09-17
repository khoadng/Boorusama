// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

//#region Previews
final danbooruFavoriteGroupPreviewProvider = Provider.autoDispose
    .family<String, int?>((ref, postId) =>
        ref.watch(danbooruFavoriteGroupPreviewsProvider)[postId] ?? '');

final danbooruFavoriteGroupPreviewsProvider =
    NotifierProvider<FavoriteGroupPreviewsNotifier, Map<int, String>>(
  FavoriteGroupPreviewsNotifier.new,
  dependencies: [
    danbooruPostRepoProvider,
  ],
);
//#endregion

//#region Favorite Groups
final danbooruFavoriteGroupRepoProvider =
    Provider<FavoriteGroupRepository>((ref) {
  return FavoriteGroupRepositoryApi(
    client: ref.watch(danbooruClientProvider),
  );
});

final danbooruFavoriteGroupsProvider =
    NotifierProvider<FavoriteGroupsNotifier, List<FavoriteGroup>?>(
  FavoriteGroupsNotifier.new,
  dependencies: [
    danbooruFavoriteGroupRepoProvider,
    currentBooruConfigProvider,
    danbooruCurrentUserProvider,
  ],
);

final danbooruFavoriteGroupFilterableProvider = NotifierProvider.autoDispose<
    FavoriteGroupFilterableNotifier, List<FavoriteGroup>?>(
  FavoriteGroupFilterableNotifier.new,
  dependencies: [
    danbooruFavoriteGroupsProvider,
  ],
);

//#endregion
