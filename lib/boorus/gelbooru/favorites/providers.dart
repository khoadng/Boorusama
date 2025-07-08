// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/types.dart';
import '../client_provider.dart';
import '../posts/types.dart';

final gelbooruFavoriteRepoProvider =
    Provider.family<FavoriteRepository<GelbooruPost>, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(gelbooruClientProvider(config));

        return FavoriteRepositoryBuilder(
          add: (postId) => client
              .addFavorite(postId: postId)
              .then(
                (value) => switch (value) {
                  GelbooruFavoriteStatus.success => AddFavoriteStatus.success,
                  GelbooruFavoriteStatus.alreadyFavorited =>
                    AddFavoriteStatus.alreadyExists,
                  _ => AddFavoriteStatus.failure,
                },
              ),
          remove: (postId) => client
              .removeFavorite(postId: postId)
              .then((value) => true)
              .catchError((e) => false),
          isFavorited: (post) => false,
          canFavorite: () => client.canFavorite,
        );
      },
    );
