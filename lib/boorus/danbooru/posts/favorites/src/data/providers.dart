// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../core/posts/favorites/providers.dart';
import '../../../../../../core/posts/favorites/types.dart';
import '../../../../client_provider.dart';
import '../../../../configs/providers.dart';
import '../../../../users/user/providers.dart';
import '../../../post/types.dart';
import '../../../votes/providers.dart';
import '../types/favorite.dart';
import 'parser.dart';

final danbooruFavoriteRepoProvider =
    Provider.family<FavoriteRepository<DanbooruPost>, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(danbooruClientProvider(config));
        final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));

        return FavoriteRepositoryBuilder(
          add: (postId) async {
            final success = await client.addToFavorites(postId: postId);

            if (success) {
              await ref
                  .read(danbooruPostVotesProvider(config).notifier)
                  .upvote(postId, localOnly: true);
            }

            return success
                ? AddFavoriteStatus.success
                : AddFavoriteStatus.failure;
          },
          remove: (postId) async {
            final success = await client.removeFromFavorites(postId: postId);

            if (success) {
              try {
                await ref
                    .read(danbooruPostVotesProvider(config).notifier)
                    .removeVote(postId, null);
              } catch (e) {
                return false;
              }
            }

            return success;
          },
          isFavorited: (post) => false,
          canFavorite: () => loginDetails.hasLogin(),
          filter: (postIds) async {
            final user = await ref.read(
              danbooruCurrentUserProvider(config).future,
            );
            if (user == null) throw Exception('Current User not found');

            final favorites = await client
                .filterFavoritesFromUserId(
                  postIds: postIds,
                  userId: user.id,
                )
                .then((value) => value.map(favoriteDtoToFavorite).toList())
                .catchError((Object obj) => <Favorite>[]);

            return favorites.map((f) => f.postId).toList();
          },
        );
      },
    );
