// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<Favorite> parseFavorite(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => FavoriteDto.fromJson(item),
    ).map(favoriteDtoToFavorite).toList();

class FavoritePostRepositoryApi implements FavoritePostRepository {
  FavoritePostRepositoryApi(
    this._api,
    this._currentUserBooruRepository,
  );

  final DanbooruApi _api;
  final CurrentBooruConfigRepository _currentUserBooruRepository;

  @override
  Future<bool> addToFavorites(int postId) => _currentUserBooruRepository
          .get()
          .then(
            (userBooru) => _api.addToFavorites(
              userBooru?.login,
              userBooru?.apiKey,
              postId,
            ),
          )
          .then((value) {
        return true;
      }).catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioError:
            final response = (obj as DioError).response;
            if (response == null) return false;
            return response.statusCode == 302;
          default:
            return false;
        }
      });

  @override
  Future<bool> removeFromFavorites(int postId) async {
    return _currentUserBooruRepository
        .get()
        .then(
          (userBooru) => _api.removeFromFavorites(
            postId,
            userBooru?.login,
            userBooru?.apiKey,
            'delete',
          ),
        )
        .then((value) {
      return true;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final response = (obj as DioError).response;
          if (response == null) return false;
          return response.statusCode == 302;
        default:
          return false;
      }
    });
  }

  @override
  Future<List<Favorite>> filterFavoritesFromUserId(
    List<int> postIds,
    int userId,
    int limit,
  ) =>
      _currentUserBooruRepository
          .get()
          .then(
            (userBooru) => _api.filterFavoritesFromUserId(
              userBooru?.login,
              userBooru?.apiKey,
              postIds.join(','),
              userId,
              limit,
            ),
          )
          .then(parseFavorite)
          .catchError((Object obj) => <Favorite>[]);

  @override
  Future<bool> checkIfFavoritedByUser(
    int userId,
    int postId,
  ) =>
      _currentUserBooruRepository
          .get()
          .then(
            (userBooru) => _api.filterFavoritesFromUserId(
              userBooru?.login,
              userBooru?.apiKey,
              postId.toString(),
              userId,
              20,
            ),
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
