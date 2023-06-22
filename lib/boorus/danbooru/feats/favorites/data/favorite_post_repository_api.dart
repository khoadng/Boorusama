// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/foundation/http/http.dart';

List<Favorite> parseFavorite(HttpResponse<dynamic> value) => parseResponse(
      value: value,
      converter: (item) => FavoriteDto.fromJson(item),
    ).map(favoriteDtoToFavorite).toList();

class FavoritePostRepositoryApi implements FavoritePostRepository {
  FavoritePostRepositoryApi(
    this._api,
  );

  final DanbooruApi _api;

  @override
  Future<bool> addToFavorites(int postId) => _api
          .addToFavorites(postId)
          .then((value) => true)
          .catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioException:
            final response = (obj as DioException).response;
            if (response == null) return false;
            return response.statusCode == 302;
          default:
            return false;
        }
      });

  @override
  Future<bool> removeFromFavorites(int postId) => _api
          .removeFromFavorites(postId)
          .then((value) => true)
          .catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioException:
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
      _api
          .filterFavoritesFromUserId(
            postIds.join(','),
            userId,
            limit,
          )
          .then(parseFavorite)
          .catchError((Object obj) => <Favorite>[]);

  @override
  Future<bool> checkIfFavoritedByUser(
    int userId,
    int postId,
  ) =>
      _api
          .filterFavoritesFromUserId(
            postId.toString(),
            userId,
            20,
          )
          .then((value) => (value.response.data as List).isNotEmpty)
          .catchError((Object obj) => false);

  @override
  Future<List<Favorite>> getFavorites(int postId, int page) =>
      _api.getFavorites(postId, page, 100).then(parseFavorite);
}

Favorite favoriteDtoToFavorite(FavoriteDto d) => Favorite(
      id: d.id,
      postId: d.postId,
      userId: d.userId,
    );
