// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../post/post.dart';
import '../data/providers.dart';
import '../types/types.dart';

final favoritesProvider =
    NotifierProvider.family<
      FavoritesNotifier,
      IMap<int, bool>,
      BooruConfigAuth
    >(
      FavoritesNotifier.new,
    );

final favoriteProvider = Provider.autoDispose
    .family<bool, (BooruConfigAuth, int)>(
      (ref, params) {
        final (config, postId) = params;
        return ref.watch(favoritesProvider(config))[postId] ?? false;
      },
    );

final canFavoriteProvider = Provider.family<bool, BooruConfigAuth>((
  ref,
  config,
) {
  return ref.watch(favoriteRepoProvider(config)).canFavorite();
});

class FavoritesNotifier
    extends FamilyNotifier<IMap<int, bool>, BooruConfigAuth> {
  @override
  IMap<int, bool> build(BooruConfigAuth arg) {
    return <int, bool>{}.lock;
  }

  FavoriteRepository get repo => ref.read(favoriteRepoProvider(arg));

  void preload<T extends Post>(List<T> posts) => preloadInternal(
    posts,
    selfFavorited: (post) => repo.isPostFavorited(post),
  );

  Future<void> checkFavorites(List<int> postIds) async {
    // Filter postIds not in cache
    final postIdsToCheck = postIds
        .where((postId) => !state.containsKey(postId))
        .toList();

    if (postIdsToCheck.isEmpty) return;

    final cache = state.unlock;

    final favoritedPosts = await repo.filterFavoritedPosts(postIdsToCheck);

    // Update cache with results
    for (final postId in postIdsToCheck) {
      cache[postId] = favoritedPosts.contains(postId);
    }

    state = cache.lock;
  }

  Future<AddFavoriteStatus> add(int postId) async {
    if (state[postId] == true) return AddFavoriteStatus.alreadyExists;

    final status = await repo.addToFavorites(postId);
    if (status == AddFavoriteStatus.success ||
        status == AddFavoriteStatus.alreadyExists) {
      final newData = state.add(postId, true);
      state = newData;
    }

    return status;
  }

  Future<void> remove(int postId) async {
    if (state[postId] == false) return;

    final success = await repo.removeFromFavorites(postId);
    if (success) {
      final newData = state.add(postId, false);
      state = newData;
    }
  }

  void removeLocalFavorite(int postId) {
    final newData = state.add(postId, false);
    state = newData;
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

    state = data.lock;
  }
}
