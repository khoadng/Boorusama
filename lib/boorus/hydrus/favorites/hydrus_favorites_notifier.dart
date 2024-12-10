// Package imports:
import 'package:booru_clients/hydrus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../../../core/favorites/favorite.dart';
import '../hydrus.dart';

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
