// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/users/users_provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'favorite_groups_filterable_notifier.dart';

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
