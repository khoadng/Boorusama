// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../../../core/favorites/favorite.dart';
import '../../../../../core/favorites/providers.dart';
import '../../../danbooru_provider.dart';
import '../../../users/user/providers.dart';
import '../../post/post.dart';
import '../../votes/providers.dart';
import 'providers.dart';

class DanbooruFavoriteRepository extends FavoriteRepository<DanbooruPost> {
  DanbooruFavoriteRepository(this.ref, this.config);

  final Ref ref;
  final BooruConfigAuth config;

  DanbooruClient get client => ref.read(danbooruClientProvider(config));

  @override
  bool canFavorite() => config.hasLoginDetails();

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async {
    final success = await client.addToFavorites(postId: postId);

    if (success) {
      await ref
          .read(danbooruPostVotesProvider(config).notifier)
          .upvote(postId, localOnly: true);
    }

    return success ? AddFavoriteStatus.success : AddFavoriteStatus.failure;
  }

  @override
  Future<bool> removeFromFavorites(int postId) async {
    final success = await client.removeFromFavorites(postId: postId);

    if (success) {
      try {
        await ref
            .read(danbooruPostVotesProvider(config).notifier)
            .removeVote(postId);
      } catch (e) {
        return false;
      }
    }

    return success;
  }

  @override
  bool isPostFavorited(DanbooruPost post) => false;

  @override
  Future<List<int>> filterFavoritedPosts(List<int> postIds) async {
    final user = await ref.read(danbooruCurrentUserProvider(config).future);
    if (user == null) throw Exception('Current User not found');

    final favorites = await ref
        .read(danbooruFavoriteRepoProvider(config))
        .filterFavoritesFromUserId(postIds, user.id, 200);

    return favorites.map((f) => f.postId).toList();
  }
}
