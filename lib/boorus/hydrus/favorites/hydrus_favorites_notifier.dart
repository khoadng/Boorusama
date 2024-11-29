// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/hydrus/hydrus.dart';
import 'package:boorusama/clients/hydrus/hydrus_client.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/functional.dart';

class HydrusFavoritesNotifier
    extends FamilyNotifier<IMap<int, bool>, BooruConfigAuth>
    with FavoritesNotifierMixin {
  @override
  IMap<int, bool> build(BooruConfigAuth arg) {
    ref.watchConfig;

    return <int, bool>{}.lock;
  }

  void preload(List<HydrusPost> posts) => preloadInternal(
        posts,
        selfFavorited: (post) => post.ownFavorite == true,
      );

  HydrusClient get client => ref.read(hydrusClientProvider(arg));

  @override
  Future<AddFavoriteStatus> Function(int postId) get favoriteAdder =>
      (postId) async {
        try {
          await client.changeLikeStatus(fileId: postId, liked: true);

          return AddFavoriteStatus.success;
        } catch (e) {
          return AddFavoriteStatus.failure;
        }
      };

  @override
  Future<bool> Function(int postId) get favoriteRemover => (postId) async {
        try {
          await client.changeLikeStatus(fileId: postId, liked: null);

          return true;
        } catch (e) {
          return false;
        }
      };

  @override
  IMap<int, bool> get favorites => state;

  @override
  void Function(IMap<int, bool> data) get updateFavorites =>
      (data) => state = data;
}
