// Package imports:
import 'package:booru_clients/hydrus.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/favorites/providers.dart';
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

class HydrusFavoriteRepository extends FavoriteRepository<HydrusPost> {
  HydrusFavoriteRepository(this.ref, this.config);

  final Ref ref;
  final BooruConfigAuth config;

  HydrusClient get client => ref.read(hydrusClientProvider(config));

  @override
  bool canFavorite() => true;

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async => client
      .changeLikeStatus(fileId: postId, liked: true)
      .then(
        (value) =>
            value ? AddFavoriteStatus.success : AddFavoriteStatus.failure,
      );

  @override
  Future<bool> removeFromFavorites(int postId) async =>
      client.changeLikeStatus(fileId: postId, liked: null);

  @override
  bool isPostFavorited(HydrusPost post) => post.ownFavorite ?? false;
}
