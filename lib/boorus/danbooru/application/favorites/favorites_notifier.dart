// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'favorites_provider.dart';

class FavoritesNotifier extends Notifier<Map<int, bool>> {
  final _limit = 200;

  @override
  Map<int, bool> build() {
    return {};
  }

  Future<void> add(int postId) async {
    final success =
        await ref.read(danbooruFavoriteRepoProvider).addToFavorites(postId);
    if (success) {
      state = {
        ...state,
        postId: true,
      };
    }
  }

  Future<void> remove(int postId) async {
    final success = await ref
        .read(danbooruFavoriteRepoProvider)
        .removeFromFavorites(postId);
    if (success) {
      state = {
        ...state,
        postId: false,
      };
    }
  }

  Future<void> checkFavorites(List<int> postIds) async {
    final config = ref.read(currentBooruConfigProvider);
    final userId = await ref
        .read(booruUserIdentityProviderProvider)
        .getAccountIdFromConfig(config);
    if (userId == null) {
      throw Exception('User ID not found');
    }

    // Filter postIds that are not in the cache
    final postIdsToCheck =
        postIds.where((postId) => !state.containsKey(postId)).toList();

    final cache = {...state};

    if (postIdsToCheck.isNotEmpty) {
      final favorites = await ref
          .read(danbooruFavoriteRepoProvider)
          .filterFavoritesFromUserId(postIdsToCheck, userId, _limit);

      for (final favorite in favorites) {
        cache[favorite.postId] = true;
      }
    }

    // Set false for postIds that are not in the cache and not in the favorites
    for (final postId in postIdsToCheck) {
      if (!cache.containsKey(postId)) {
        cache[postId] = false;
      }
    }

    state = cache;
  }
}

extension DanbooruFavoritesX on WidgetRef {
  FavoritesNotifier get danbooruFavorites =>
      read(danbooruFavoritesProvider.notifier);
}
