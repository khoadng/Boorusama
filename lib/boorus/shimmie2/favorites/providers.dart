// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/types.dart';
import '../clients/providers.dart';
import '../posts/types.dart';

final shimmie2FavoriteRepoProvider =
    Provider.family<FavoriteRepository<Shimmie2Post>, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(shimmie2ClientProvider(config));

        return FavoriteRepositoryBuilder(
          add: (postId) => client
              .addFavorite(postId: postId)
              .then(
                (success) => success
                    ? AddFavoriteStatus.success
                    : AddFavoriteStatus.failure,
              ),
          remove: (postId) => client.removeFavorite(postId: postId),
          isFavorited: (post) => false,
          canFavorite: () => client.canFavorite,
        );
      },
    );
