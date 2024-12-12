// Package imports:
import 'package:booru_clients/hydrus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/favorites/favorite.dart';
import '../../../core/favorites/providers.dart';
import '../hydrus.dart';

final hydrusCanFavoriteProvider =
    FutureProvider.family<bool, BooruConfigAuth>((ref, config) async {
  final client = ref.watch(hydrusClientProvider(config));

  final services = await client.getServicesCached();

  return getLikeDislikeRatingKey(services) != null;
});

class HydrusFavoriteRepository extends FavoriteRepository<HydrusPost> {
  HydrusFavoriteRepository(this.ref, this.config);

  final Ref ref;
  final BooruConfigAuth config;

  HydrusClient get client => ref.read(hydrusClientProvider(config));

  @override
  bool canFavorite() => true;

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async =>
      client.changeLikeStatus(fileId: postId, liked: true).then(
            (value) =>
                value ? AddFavoriteStatus.success : AddFavoriteStatus.failure,
          );

  @override
  Future<bool> removeFromFavorites(int postId) async =>
      client.changeLikeStatus(fileId: postId, liked: null);

  @override
  bool isPostFavorited(HydrusPost post) => post.ownFavorite ?? false;
}
