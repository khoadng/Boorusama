// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorite_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';

class FavoritePostRepository implements IFavoritePostRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  FavoritePostRepository(this._api, this._accountRepository);

  @override
  Future<bool> addToFavorites(int postId) async {
    final account = await _accountRepository.get();
    return _api
        .addToFavorites(account.username, account.apiKey, postId)
        .then((value) {
      print("Add post $postId to favorites success");
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
            // throw Exception("Failed to add post $postId to favorites");
          }
        default:
      }
    });
  }

  @override
  Future<bool> removeFromFavorites(int postId) async {
    final account = await _accountRepository.get();
    return _api
        .removeFromFavorites(postId, account.username, account.apiKey, "delete")
        .then((value) {
      print("Remove post $postId from favorites success");
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
            // throw Exception("Failed to remove post $postId from favorites");
          }
          break;
        default:
      }
    });
  }

  @override
  Future<List<FavoriteDto>> filterFavoritesFromUserId(
      List<int> postIds, int userId, int limit) async {
    final account = await _accountRepository.get();
    final postIdsStringComma = postIds.join(',');
    return _api
        .filterFavoritesFromUserId(
            account.username, account.apiKey, postIdsStringComma, userId, limit)
        .then((value) {
      final favorites = <FavoriteDto>[];

      for (var item in value.response.data) {
        try {
          var post = FavoriteDto.fromJson(item);
          favorites.add(post);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }
      return favorites;
    }).catchError((Object obj) {
      return <FavoriteDto>[];
    });
  }

  @override
  Future<bool> checkIfFavoritedByUser(int userId, int postId) async {
    final account = await _accountRepository.get();

    return _api
        .filterFavoritesFromUserId(
            account.username, account.apiKey, postId.toString(), userId, 20)
        .then((value) {
      final result = value.response.data as List;

      return result.isEmpty ? false : true;
    }).catchError((Object obj) {
      return false;
    });
  }
}
