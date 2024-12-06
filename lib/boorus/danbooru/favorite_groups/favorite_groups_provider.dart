// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/configs/manage.dart';
import '../danbooru_provider.dart';
import '../posts/posts.dart';
import '../users/users.dart';
import 'favorite_groups.dart';

//#region Previews
final danbooruFavoriteGroupPreviewProvider =
    Provider.autoDispose.family<String, int?>((ref, postId) {
  final config = ref.watchConfigSearch;
  return ref.watch(danbooruFavoriteGroupPreviewsProvider(config))[postId] ?? '';
});

final danbooruFavoriteGroupPreviewsProvider = NotifierProvider.family<
    FavoriteGroupPreviewsNotifier, Map<int, String>, BooruConfigSearch>(
  FavoriteGroupPreviewsNotifier.new,
  dependencies: [
    danbooruPostRepoProvider,
  ],
);
//#endregion

//#region Favorite Groups
final danbooruFavoriteGroupRepoProvider =
    Provider.family<FavoriteGroupRepository, BooruConfigAuth>((ref, config) {
  return FavoriteGroupRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});

final danbooruFavoriteGroupsProvider = NotifierProvider.family<
    FavoriteGroupsNotifier, List<DanbooruFavoriteGroup>?, BooruConfigSearch>(
  FavoriteGroupsNotifier.new,
  dependencies: [
    danbooruFavoriteGroupRepoProvider,
    currentBooruConfigProvider,
    danbooruCurrentUserProvider,
  ],
);

final danbooruFavoriteGroupFilterableProvider = NotifierProvider.autoDispose
    .family<FavoriteGroupFilterableNotifier, List<DanbooruFavoriteGroup>?,
        BooruConfigSearch>(
  FavoriteGroupFilterableNotifier.new,
  dependencies: [
    danbooruFavoriteGroupsProvider,
  ],
);

//#endregion
