import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/all.dart';

final favoriteProvider = Provider<FavoritePostRepository>((ref) =>
    FavoritePostRepository(ref.watch(apiProvider), ref.watch(accountProvider)));

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
          if (response.statusCode == 302) {
            // It's okay to be redirected here.
            return true;
          } else {
            return false;
            // throw Exception("Failed to add post $postId to favorites");
          }
          break;
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
}
