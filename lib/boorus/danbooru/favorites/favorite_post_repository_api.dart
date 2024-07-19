// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';

class FavoritePostRepositoryApi implements FavoritePostRepository {
  FavoritePostRepositoryApi(
    this.client,
  );

  final DanbooruClient client;

  @override
  Future<bool> addToFavorites(int postId) => client
          .addToFavorites(postId: postId)
          .then((value) => true)
          .catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioException _:
            final response = (obj as DioException).response;
            if (response == null) return false;
            return response.statusCode == 302;
          default:
            return false;
        }
      });

  @override
  Future<bool> removeFromFavorites(int postId) => client
          .removeFromFavorites(postId: postId)
          .then((value) => true)
          .catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioException _:
            final response = (obj as DioException).response;
            if (response == null) return false;
            return response.statusCode == 302;
          default:
            return false;
        }
      });

  @override
  Future<List<Favorite>> filterFavoritesFromUserId(
    List<int> postIds,
    int userId,
    int limit,
  ) =>
      client
          .filterFavoritesFromUserId(
            postIds: postIds,
            userId: userId,
            limit: limit,
          )
          .then((value) => value.map(favoriteDtoToFavorite).toList())
          .catchError((Object obj) => <Favorite>[]);

  @override
  Future<List<Favorite>> getFavorites(int postId, int page) => client
      .getFavorites(
        postId: postId,
        page: page,
        limit: 100,
      )
      .then((value) => value.map(favoriteDtoToFavorite).toList());
}

Favorite favoriteDtoToFavorite(FavoriteDto d) => Favorite(
      id: d.id,
      postId: d.postId,
      userId: d.userId,
    );
