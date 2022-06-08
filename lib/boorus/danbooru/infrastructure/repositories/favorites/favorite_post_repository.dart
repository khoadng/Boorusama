// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorite_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

List<FavoriteDto> parseFavorite(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => FavoriteDto.fromJson(item),
    );

class FavoritePostRepository implements IFavoritePostRepository {
  FavoritePostRepository(
    this._api,
    this._accountRepository,
  );

  final IApi _api;
  final IAccountRepository _accountRepository;

  @override
  Future<bool> addToFavorites(int postId) => _accountRepository
          .get()
          .then(
            (account) => _api.addToFavorites(
              account.username,
              account.apiKey,
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
            if (response.statusCode == 302) {
              // It's okay to be redirected here.
              return true;
            } else {
              return false;
            }
          default:
        }
      });

  @override
  Future<bool> removeFromFavorites(int postId) async {
    return _accountRepository
        .get()
        .then(
          (account) => _api.removeFromFavorites(
            postId,
            account.username,
            account.apiKey,
            "delete",
          ),
        )
        .then((value) {
      return true;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final response = (obj as DioError).response;
          if (response == null) return false;
          if (response.statusCode == 302) {
            // It's okay to be redirected here.
            return true;
          } else {
            return false;
          }
        default:
      }
    });
  }

  @override
  Future<List<FavoriteDto>> filterFavoritesFromUserId(
    List<int> postIds,
    int userId,
    int limit,
  ) =>
      _accountRepository
          .get()
          .then(
            (account) => _api.filterFavoritesFromUserId(
              account.username,
              account.apiKey,
              postIds.join(','),
              userId,
              limit,
            ),
          )
          .then(parseFavorite)
          .catchError((Object obj) => <FavoriteDto>[]);

  @override
  Future<bool> checkIfFavoritedByUser(
    int userId,
    int postId,
  ) =>
      _accountRepository
          .get()
          .then(
            (account) => _api.filterFavoritesFromUserId(
              account.username,
              account.apiKey,
              postId.toString(),
              userId,
              20,
            ),
          )
          .then((value) => (value.response.data as List).isEmpty ? false : true)
          .catchError((Object obj) => false);
}
