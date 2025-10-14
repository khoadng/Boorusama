// Package imports:
import 'package:booru_clients/hydrus.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/types.dart';
import '../client_provider.dart';
import '../posts/types.dart';

final hydrusCanFavoriteProvider = FutureProvider.family<bool, BooruConfigAuth>((
  ref,
  config,
) async {
  final client = ref.watch(hydrusClientProvider(config));

  final services = await client.getServicesCached();

  return getLikeDislikeRatingKey(services) != null;
});

final ratingServiceNameProvider =
    FutureProvider.family<String?, BooruConfigAuth>((ref, config) async {
      final client = ref.read(hydrusClientProvider(config));

      final services = await client.getServicesCached();

      final key = getLikeDislikeRatingKey(services);

      if (key == null) {
        return null;
      }

      return services.firstWhereOrNull((e) => e.key == key)?.name;
    });

final hydrusFavoriteRepoProvider =
    Provider.family<FavoriteRepository<HydrusPost>, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(hydrusClientProvider(config));

        return FavoriteRepositoryBuilder(
          add: (postId) => client
              .changeLikeStatus(fileId: postId, liked: true)
              .then(
                (value) => value
                    ? AddFavoriteStatus.success
                    : AddFavoriteStatus.failure,
              ),
          remove: (postId) =>
              client.changeLikeStatus(fileId: postId, liked: null),
          isFavorited: (post) => post.ownFavorite ?? false,
          canFavorite: () => true,
        );
      },
    );
