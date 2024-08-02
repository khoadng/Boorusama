// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/functional.dart';

enum AddFavoriteStatus {
  success,
  failure,
  alreadyExists,
}

mixin FavoritesNotifierMixin {
  Future<AddFavoriteStatus> Function(int postId) get favoriteAdder;
  Future<bool> Function(int postId) get favoriteRemover;

  IMap<int, bool> get favorites;

  void Function(IMap<int, bool> data) get updateFavorites;

  Future<AddFavoriteStatus> add(int postId) async {
    if (favorites[postId] == true) return AddFavoriteStatus.alreadyExists;

    final status = await favoriteAdder(postId);
    if (status == AddFavoriteStatus.success ||
        status == AddFavoriteStatus.alreadyExists) {
      final newData = favorites.add(postId, true);
      updateFavorites(newData);
    }

    return status;
  }

  Future<void> remove(int postId) async {
    if (favorites[postId] == false) return;

    final success = await favoriteRemover(postId);
    if (success) {
      final newData = favorites.add(postId, false);
      updateFavorites(newData);
    }
  }

  void removeLocalFavorite(int postId) {
    final newData = favorites.add(postId, false);
    updateFavorites(newData);
  }

  void preloadInternal<T extends Post>(
    List<T> posts, {
    bool Function(T post)? selfFavorited,
  }) {
    final data = <int, bool>{};

    for (final post in posts) {
      final favorited = selfFavorited != null ? selfFavorited(post) : false;
      data[post.id] = favorited;
    }

    updateFavorites(data.lock);
  }
}
