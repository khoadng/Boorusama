// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/types.dart';
import '../clients/providers.dart';
import '../configs/providers.dart';
import '../extensions/providers.dart';
import '../extensions/types.dart';
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
          canFavorite: () =>
              ref.read(shimmie2CanFavoriteProvider(config)).valueOrNull ??
              false,
        );
      },
    );

final shimmie2CanFavoriteProvider =
    FutureProvider.family<bool, BooruConfigAuth>(
      (ref, config) async {
        final loginDetails = ref.watch(shimmie2LoginDetailsProvider(config));

        if (!loginDetails.hasLogin()) {
          return false;
        }

        final hasFavoriteExtension = await ref.watch(
          shimmie2HasFavoriteExtensionProvider(config).future,
        );

        return hasFavoriteExtension;
      },
    );

final shimmie2HasFavoriteExtensionProvider =
    FutureProvider.family<bool, BooruConfigAuth>(
      (ref, config) async {
        final state = await ref.watch(
          shimmie2ExtensionsProvider(config.url).future,
        );

        return switch (state) {
          final Shimmie2ExtensionsData data => data.hasExtension(
            KnownExtension.favorites,
          ),
          _ => false,
        };
      },
    );
