// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/favorites/providers.dart';
import '../e621.dart';
import '../posts/e621_post.dart';

class E621FavoriteRepository extends FavoriteRepository<E621Post> {
  E621FavoriteRepository(this.ref, this.config);

  final Ref ref;
  final BooruConfigAuth config;

  E621Client get client => ref.read(e621ClientProvider(config));

  @override
  bool canFavorite() => config.hasLoginDetails();

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async =>
      client.addToFavorites(postId: postId).then(
            (value) =>
                value ? AddFavoriteStatus.success : AddFavoriteStatus.failure,
          );

  @override
  Future<bool> removeFromFavorites(int postId) async =>
      client.removeFromFavorites(postId: postId);

  @override
  bool isPostFavorited(E621Post post) => post.isFavorited;
}
