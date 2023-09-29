// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';

abstract interface class E621FavoritesRepository {
  PostsOrError<E621Post> getFavorites(int page);
  Future<bool> addToFavorites(int postId);
  Future<bool> removeFromFavorites(int postId);
}

class E621FavoritesRepositoryApi implements E621FavoritesRepository {
  E621FavoritesRepositoryApi(
    this.client,
    this.booruConfig,
    this.postRepository,
  );

  final E621Client client;
  final BooruConfig booruConfig;
  final PostRepository<E621Post> postRepository;

  @override
  Future<bool> addToFavorites(int postId) => client
      .addToFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);

  @override
  Future<bool> removeFromFavorites(int postId) => client
      .removeFromFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);

  @override
  PostsOrError<E621Post> getFavorites(int page) => postRepository
      .getPosts(['fav:${booruConfig.login?.replaceAll(' ', '_')}'], page);
}
