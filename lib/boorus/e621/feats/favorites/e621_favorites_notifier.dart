// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';
import 'e621_favorites_provider.dart';

class E621FavoritesNotifier extends FamilyNotifier<IMap<int, bool>, BooruConfig>
    with FavoritesNotifierMixin {
  @override
  IMap<int, bool> build(BooruConfig arg) {
    ref.watchConfig;

    return <int, bool>{}.lock;
  }

  void preload(List<E621Post> posts) => preloadInternal(
        posts,
        selfFavorited: (post) => post.isFavorited,
      );

  @override
  Future<bool> Function(int postId) get favoriteAdder => (postId) =>
      ref.read(e621FavoritesRepoProvider(arg)).addToFavorites(postId);

  @override
  Future<bool> Function(int postId) get favoriteRemover => (postId) =>
      ref.read(e621FavoritesRepoProvider(arg)).removeFromFavorites(postId);

  @override
  IMap<int, bool> get favorites => state;

  @override
  void Function(IMap<int, bool> data) get updateFavorites =>
      (data) => state = data;
}
