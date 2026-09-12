// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../post/types.dart';
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

final favoriteStatusProvider = Provider.autoDispose
    .family<bool?, (BooruConfigAuth, int)>(
      (ref, params) {
        final (config, postId) = params;
        return ref.watch(favoritesProvider(config))[postId];
      },
    );

final favoriteStatusLoaderProvider = FutureProvider.autoDispose
    .family<void, (BooruConfigAuth, int)>((ref, params) async {
      final (config, postId) = params;
      final status = ref.watch(favoriteStatusProvider(params));

      if (status != null) return;

      await ref.read(favoritesProvider(config).notifier).checkFavorites([
        postId,
      ]);
    });

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

    final favoritedPosts = await repo.filterFavoritedPosts(postIdsToCheck);

    // Merge into current state; another lookup or user action may have resolved
    // these IDs while the request was pending.
    final cache = state.unlock;
    for (final postId in postIdsToCheck) {
      cache.putIfAbsent(postId, () => favoritedPosts.contains(postId));
    }

    state = cache.lock;
  }

  Future<AddFavoriteStatus> add(int postId) async {
    if (state[postId] ?? false) return AddFavoriteStatus.alreadyExists;

    state = state.add(postId, true);

    final status = await repo.addToFavorites(postId);
    if (status != AddFavoriteStatus.success &&
        status != AddFavoriteStatus.alreadyExists) {
      state = state.add(postId, false);
    }

    return status;
  }

  Future<bool> remove(int postId) async {
    if (state[postId] == false) return true;

    state = state.add(postId, false);

    final success = await repo.removeFromFavorites(postId);
    if (!success) {
      state = state.add(postId, true);
    }

    return success;
  }

  void removeLocalFavorite(int postId) {
    final newData = state.add(postId, false);
    state = newData;
  }

  void preloadInternal<T extends Post>(
    List<T> posts, {
    bool Function(T post)? selfFavorited,
  }) {
    final data = state.unlock;

    for (final post in posts) {
      final favorited = selfFavorited != null ? selfFavorited(post) : false;
      data[post.id] = favorited;
    }

    state = data.lock;
  }
}
