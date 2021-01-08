import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/accounts/i_favorite_post_repository.dart';
import 'package:boorusama/infrastructure/apis/i_api.dart';
import 'package:dio/dio.dart';

class FavoritePostRepository implements IFavoritePostRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  FavoritePostRepository(this._api, this._accountRepository);

  @override
  Future addToFavorites(int postId) async {
    final account = await _accountRepository.get();
    _api.addToFavorites(account.username, account.apiKey, postId).then((value) {
      print("Add post $postId to favorites success");
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final response = (obj as DioError).response;
          if (response.statusCode == 302) {
            // It's okay to be redirected here.
          } else {
            throw Exception("Failed to add post $postId to favorites");
          }
          break;
        default:
      }
    });
  }

  @override
  Future removeFromFavorites(int postId) async {
    final account = await _accountRepository.get();
    _api
        .removeFromFavorites(postId, account.username, account.apiKey, "delete")
        .then((value) {
      print("Remove post $postId from favorites success");
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final response = (obj as DioError).response;
          if (response.statusCode == 302) {
            // It's okay to be redirected here.
          } else {
            throw Exception("Failed to remove post $postId from favorites");
          }
          break;
        default:
      }
    });
  }
}
