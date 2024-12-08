// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/posts/posts.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/favorites/favorite.dart';
import 'package:boorusama/functional.dart';
import 'e621_favorites_provider.dart';

class E621FavoritesNotifier
    extends FamilyNotifier<IMap<int, bool>, BooruConfigAuth>
    with FavoritesNotifierMixin {
  @override
  IMap<int, bool> build(BooruConfigAuth arg) {
    ref.watchConfig;

    return <int, bool>{}.lock;
  }

  void preload(List<E621Post> posts) => preloadInternal(
        posts,
        selfFavorited: (post) => post.isFavorited,
      );

  @override
  Future<AddFavoriteStatus> Function(int postId) get favoriteAdder =>
      (postId) => ref
          .read(e621FavoritesRepoProvider(arg))
          .addToFavorites(postId)
          .then(
            (value) =>
                value ? AddFavoriteStatus.success : AddFavoriteStatus.failure,
          );

  @override
  Future<bool> Function(int postId) get favoriteRemover => (postId) =>
      ref.read(e621FavoritesRepoProvider(arg)).removeFromFavorites(postId);

  @override
  IMap<int, bool> get favorites => state;

  @override
  void Function(IMap<int, bool> data) get updateFavorites =>
      (data) => state = data;
}
