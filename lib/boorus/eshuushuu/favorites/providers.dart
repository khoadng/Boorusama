// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/types.dart';
import '../client_provider.dart';
import '../posts/types.dart';

final eshuushuuFavoriteRepoProvider =
    Provider.family<FavoriteRepository<EshuushuuPost>, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(eshuushuuClientProvider(config));
        final hasAuth =
            config.login != null &&
            config.login!.isNotEmpty &&
            config.apiKey != null &&
            config.apiKey!.isNotEmpty;

        return FavoriteRepositoryBuilder(
          add: (postId) async {
            try {
              final result = await client.addFavorite(postId);
              return (result?.favorited ?? false)
                  ? AddFavoriteStatus.success
                  : AddFavoriteStatus.alreadyExists;
            } catch (_) {
              return AddFavoriteStatus.failure;
            }
          },
          remove: (postId) async {
            try {
              await client.removeFavorite(postId);
              return true;
            } catch (_) {
              return false;
            }
          },
          isFavorited: (post) => post.isFavorited ?? false,
          canFavorite: () => hasAuth,
        );
      },
    );
