import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/accounts/i_favorite_post_repository.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:dio/dio.dart';

class FavoritePostRepository implements IFavoritePostRepository {
  final Danbooru _api;
  final IAccountRepository _accountRepository;

  FavoritePostRepository(this._api, this._accountRepository);

  @override
  Future addToFavorites(int postId) async {
    final account = await _accountRepository.get();
    var uri = Uri.https(_api.url, "/favorites", {
      "login": account.username,
      "api_key": account.apiKey,
      "post_id": postId.toString(),
    });

    var respond = await _api.dio.postUri(uri,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status < 500,
        ));

    if (respond.statusCode < 500) {
      print("Add post $postId to favorites success");
    } else {
      throw Exception("Failed to add post $postId to favorites");
    }
  }

  @override
  Future removeFromFavorites(int postId) async {
    final account = await _accountRepository.get();
    var uri = Uri.https(_api.url, "/favorites/$postId", {
      "login": account.username,
      "api_key": account.apiKey,
    });

    final content = {
      "_method": "delete",
    };

    var respond = await _api.dio.postUri(uri,
        data: content,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status < 500,
        ));

    if (respond.statusCode < 500) {
      print("Remove post $postId from favorites success");
    } else {
      throw Exception("Failed to remove post $postId from favorites");
    }
  }
}
