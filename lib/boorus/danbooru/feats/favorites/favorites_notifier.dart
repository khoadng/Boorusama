// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'favorites_provider.dart';

class FavoritesNotifier extends FamilyNotifier<Map<int, bool>, BooruConfig> {
  final _limit = 200;

  @override
  Map<int, bool> build(BooruConfig arg) {
    return {};
  }

  Future<void> add(int postId) async {
    final success = await ref
        .read(danbooruFavoriteRepoProvider(arg))
        .addToFavorites(postId);
    if (success) {
      ref
          .read(danbooruPostVotesProvider(arg).notifier)
          .upvote(postId, localOnly: true);
      state = {
        ...state,
        postId: true,
      };
    }
  }

  Future<void> remove(int postId) async {
    final success = await ref
        .read(danbooruFavoriteRepoProvider(arg))
        .removeFromFavorites(postId);
    if (success) {
      ref.read(danbooruPostVotesProvider(arg).notifier).removeLocalVote(postId);
      state = {
        ...state,
        postId: false,
      };
    }
  }

  Future<void> checkFavorites(List<int> postIds) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);
    if (user == null) {
      throw Exception('Current User not found');
    }

    // Filter postIds that are not in the cache
    final postIdsToCheck =
        postIds.where((postId) => !state.containsKey(postId)).toList();

    final cache = {...state};

    if (postIdsToCheck.isNotEmpty) {
      final favorites = await ref
          .read(danbooruFavoriteRepoProvider(arg))
          .filterFavoritesFromUserId(postIdsToCheck, user.id, _limit);

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
  FavoritesNotifier get danbooruFavorites => read(
      danbooruFavoritesProvider(read(currentBooruConfigProvider)).notifier);
}
