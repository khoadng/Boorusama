// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/clients/e621/e621_client.dart';

abstract interface class E621FavoritesRepository {
  E621PostsOrError getFavorites(int page);
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
  final E621PostRepository postRepository;

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
  E621PostsOrError getFavorites(int page) => postRepository.getPosts(
      'fav:${booruConfig.login?.replaceAll(' ', '_')}', page);
}
