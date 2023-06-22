// Project imports:
import 'package:boorusama/api/e621/e621_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';

abstract interface class E621FavoritesRepository {
  E621PostsOrError getFavorites(int page);
  Future<bool> addToFavorites(int postId);
  Future<bool> removeFromFavorites(int postId);
}

class E621FavoritesRepositoryApi implements E621FavoritesRepository {
  E621FavoritesRepositoryApi(
    this.api,
    this.booruConfig,
    this.postRepository,
  );

  final E621Api api;
  final BooruConfig booruConfig;
  final E621PostRepository postRepository;

  @override
  Future<bool> addToFavorites(int postId) => api
      .addToFavorites(
        booruConfig.login,
        booruConfig.apiKey,
        postId,
      )
      .then((value) => true)
      .catchError((obj) => false);

  @override
  Future<bool> removeFromFavorites(int postId) => api
      .removeFromFavorites(
        postId,
        booruConfig.login,
        booruConfig.apiKey,
      )
      .then((value) => true)
      .catchError((obj) => false);

  @override
  E621PostsOrError getFavorites(int page) => postRepository.getPosts(
      'fav:${booruConfig.login?.replaceAll(' ', '_')}', page);
}
