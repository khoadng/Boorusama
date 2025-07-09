// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/types.dart';
import '../client_provider.dart';
import '../post_votes/providers.dart';
import '../posts/types.dart';

final szurubooruFavoriteRepoProvider =
    Provider.family<FavoriteRepository<SzurubooruPost>, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(szurubooruClientProvider(config));

        return FavoriteRepositoryBuilder(
          add: (postId) async {
            try {
              await client.addToFavorites(postId: postId);

              await ref
                  .read(szurubooruPostVotesProvider(config).notifier)
                  .upvote(postId, localOnly: true);

              return AddFavoriteStatus.success;
            } catch (e) {
              return AddFavoriteStatus.failure;
            }
          },
          remove: (postId) =>
              client.removeFromFavorites(postId: postId).then((value) => true),
          isFavorited: (post) => post.ownFavorite,
          canFavorite: () => config.hasLoginDetails(),
        );
      },
    );
