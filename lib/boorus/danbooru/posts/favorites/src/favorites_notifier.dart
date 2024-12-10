// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../../../core/configs/current.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/favorites/favorite.dart';
import '../../../_shared/guard_login.dart';
import '../../../users/user/providers.dart';
import '../../votes/providers.dart';
import 'providers.dart';

final danbooruFavoritesProvider = NotifierProvider.family<FavoritesNotifier,
    IMap<int, bool>, BooruConfigAuth>(
  FavoritesNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final danbooruFavoriteProvider = Provider.autoDispose.family<bool, int>(
  (ref, postId) {
    final config = ref.watchConfigAuth;
    return ref.watch(danbooruFavoritesProvider(config))[postId] ?? false;
  },
);

class FavoritesNotifier extends FamilyNotifier<IMap<int, bool>, BooruConfigAuth>
    with FavoritesNotifierMixin {
  final _limit = 200;

  @override
  IMap<int, bool> build(BooruConfigAuth arg) {
    return <int, bool>{}.lock;
  }

  @override
  Future<AddFavoriteStatus> Function(int postId) get favoriteAdder =>
      (postId) async {
        final success = await ref
            .read(danbooruFavoriteRepoProvider(arg))
            .addToFavorites(postId);
        if (success) {
          try {
            await ref
                .read(danbooruPostVotesProvider(arg).notifier)
                .upvote(postId, localOnly: true);
            return AddFavoriteStatus.success;
          } catch (e) {
            return AddFavoriteStatus.failure;
          }
        }

        return AddFavoriteStatus.failure;
      };

  Future<void> checkFavorites(List<int> postIds) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);
    if (user == null) {
      throw Exception('Current User not found');
    }

    // Filter postIds that are not in the cache
    final postIdsToCheck =
        postIds.where((postId) => !state.containsKey(postId)).toList();

    final cache = state.unlock;

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

    state = cache.lock;
  }

  @override
  Future<bool> Function(int postId) get favoriteRemover => (postId) async {
        final success = await ref
            .read(danbooruFavoriteRepoProvider(arg))
            .removeFromFavorites(postId);
        if (success) {
          try {
            await ref
                .read(danbooruPostVotesProvider(arg).notifier)
                .removeVote(postId);
          } catch (e) {
            return false;
          }
        }

        return success;
      };

  @override
  IMap<int, bool> get favorites => state;

  @override
  void Function(IMap<int, bool> data) get updateFavorites =>
      (data) => state = data;
}

extension DanbooruFavX on WidgetRef {
  FavoritesNotifier get danbooruFavorites =>
      read(danbooruFavoritesProvider(readConfigAuth).notifier);

  void danbooruToggleFavorite(int postId) {
    guardLogin(this, () async {
      final isFaved = read(danbooruFavoriteProvider(postId));
      if (isFaved) {
        await danbooruFavorites.remove(postId);
        if (context.mounted) {
          showSuccessSnackBar(
            context,
            'Removed from favorites',
          );
        }
      } else {
        await danbooruFavorites.add(postId);
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
