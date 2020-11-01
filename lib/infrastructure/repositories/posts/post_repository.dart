import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class PostRepository implements IPostRepository {
  //TODO: shouldn't use concrete type
  final Danbooru _api;
  final IAccountRepository _accountRepository;

  PostRepository(this._api, this._accountRepository);

  //TODO: update to remove duplicate code
  @override
  Future<List<Post>> getPosts(String tagString, int page) async {
    final account = await _accountRepository.get();
    final uri = Uri.https(_api.url, "/posts.json", {
      "login": account.username,
      "api_key": account.apiKey,
      "page": page.toString(),
      "tags": tagString,
      "limit": "200",
    });

    var posts = List<Post>();
    try {
      final respond = await _api.dio.get(uri.toString(),
          options: buildCacheOptions(Duration(minutes: 1)));

      for (var item in respond.data) {
        try {
          posts.add(Post.fromJson(item));
        } catch (e) {
          print("Cant parse $item[id]");
        }
      }
    } on DioError catch (e) {
      if (e.response.statusCode == 422) {
        throw CannotSearchMoreThanTwoTags(
            "You cannot search for more than 2 tags at a time. Upgrade your account to search for more tags at once.");
      }
    }

    return posts;
  }
}

class CannotSearchMoreThanTwoTags implements Exception {
  final String message;
  CannotSearchMoreThanTwoTags(this.message);
}
