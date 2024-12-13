// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../boorus/danbooru/_shared/guard_login.dart';
import '../boorus/engine/providers.dart';
import '../configs/config.dart';
import '../configs/current.dart';
import '../configs/ref.dart';
import '../posts/post/post.dart';
import 'favorite.dart';

final favoritesProvider = NotifierProvider.family<FavoritesNotifier,
    IMap<int, bool>, BooruConfigAuth>(
  FavoritesNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final favoriteProvider = Provider.autoDispose.family<bool, int>(
  (ref, postId) {
    final config = ref.watchConfigAuth;
    return ref.watch(favoritesProvider(config))[postId] ?? false;
  },
);

final favoriteRepoProvider =
    Provider.family<FavoriteRepository, BooruConfigAuth>(
  (ref, config) {
    final repo =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    final favoriteRepo = repo?.favorite(config);

    if (favoriteRepo != null) {
      return favoriteRepo;
    }

    return EmptyFavoriteRepository();
  },
);

class FavoritesNotifier extends FamilyNotifier<IMap<int, bool>, BooruConfigAuth>
    with FavoritesNotifierMixin {
  @override
  IMap<int, bool> build(BooruConfigAuth arg) {
    return <int, bool>{}.lock;
  }

  FavoriteRepository get repo => ref.read(favoriteRepoProvider(arg));

  void preload<T extends Post>(List<T> posts) => preloadInternal(
        posts,
        selfFavorited: (post) => repo.isPostFavorited(post),
      );

  @override
  Future<AddFavoriteStatus> Function(int postId) get favoriteAdder =>
      repo.addToFavorites;

  Future<void> checkFavorites(List<int> postIds) async {
    // Filter postIds not in cache
    final postIdsToCheck =
        postIds.where((postId) => !state.containsKey(postId)).toList();

    if (postIdsToCheck.isEmpty) return;

    final cache = state.unlock;

    final favoritedPosts = await repo.filterFavoritedPosts(postIdsToCheck);

    // Update cache with results
    for (final postId in postIdsToCheck) {
      cache[postId] = favoritedPosts.contains(postId);
    }

    state = cache.lock;
  }

  @override
  Future<bool> Function(int postId) get favoriteRemover =>
      repo.removeFromFavorites;

  @override
  IMap<int, bool> get favorites => state;

  @override
  void Function(IMap<int, bool> data) get updateFavorites =>
      (data) => state = data;
}

final canFavoriteProvider =
    Provider.family<bool, BooruConfigAuth>((ref, config) {
  return ref.watch(favoriteRepoProvider(config)).canFavorite();
});

extension FavX on WidgetRef {
  FavoritesNotifier get favorites =>
      read(favoritesProvider(readConfigAuth).notifier);

  void toggleFavorite(int postId) {
    guardLogin(this, () async {
      final isFaved = read(favoriteProvider(postId));
      if (isFaved) {
        await favorites.remove(postId);
        if (context.mounted) {
          showSuccessSnackBar(
            context,
            'Removed from favorites',
          );
        }
      } else {
        await favorites.add(postId);
        if (context.mounted) {
          showSuccessSnackBar(
            context,
            'Added to favorites',
          );
        }
      }
    });
  }
}

class EmptyFavoriteRepository extends FavoriteRepository<Post> {
  @override
  bool canFavorite() => false;

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async =>
      AddFavoriteStatus.failure;

  @override
  Future<bool> removeFromFavorites(int postId) async => false;

  @override
  bool isPostFavorited(Post post) => false;
}

abstract class FavoriteRepository<T extends Post> {
  bool canFavorite();
  Future<AddFavoriteStatus> addToFavorites(int postId);
  Future<bool> removeFromFavorites(int postId);
  bool isPostFavorited(T post);
  Future<List<int>> filterFavoritedPosts(List<int> postIds) async {
    return [];
  }
}
