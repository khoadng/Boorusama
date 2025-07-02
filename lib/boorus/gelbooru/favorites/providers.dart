// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/posts/favorites/providers.dart';
import '../client_provider.dart';
import '../posts/types.dart';

class GelbooruFavoriteRepository extends FavoriteRepository<GelbooruPost> {
  GelbooruFavoriteRepository(this.ref, this.config);

  final Ref ref;
  final BooruConfigAuth config;

  GelbooruClient get client => ref.read(gelbooruClientProvider(config));

  @override
  bool canFavorite() => client.canFavorite;

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async =>
      client.addFavorite(postId: postId).then(
            (value) => switch (value) {
              GelbooruFavoriteStatus.success => AddFavoriteStatus.success,
              GelbooruFavoriteStatus.alreadyFavorited =>
                AddFavoriteStatus.alreadyExists,
              _ => AddFavoriteStatus.failure,
            },
          );

  @override
  Future<bool> removeFromFavorites(int postId) async => client
      .removeFavorite(postId: postId)
      .then((value) => true)
      .catchError((e) => false);

  @override
  bool isPostFavorited(GelbooruPost post) => false;
}
