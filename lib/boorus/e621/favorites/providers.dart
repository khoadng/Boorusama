// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/types.dart';
import '../client_provider.dart';
import '../posts/types.dart';

final e621FavoriteRepoProvider =
    Provider.family<FavoriteRepository<E621Post>, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(e621ClientProvider(config));

        return FavoriteRepositoryBuilder(
          add: (postId) => client
              .addToFavorites(postId: postId)
              .then(
                (value) => value
                    ? AddFavoriteStatus.success
                    : AddFavoriteStatus.failure,
              ),
          remove: (postId) => client.removeFromFavorites(postId: postId),
          isFavorited: (post) => post.isFavorited,
          canFavorite: () => config.hasLoginDetails(),
        );
      },
    );
