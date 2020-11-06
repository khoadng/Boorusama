import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class PostRepository implements IPostRepository {
  //TODO: shouldn't use concrete type
  final Danbooru _api;
  final IAccountRepository _accountRepository;
  final ISettingRepository _settingRepository;

  PostRepository(this._api, this._accountRepository, this._settingRepository);
  //TODO: update to remove duplicate code
  @override
  Future<List<Post>> getPosts(String tagString, int page) async {
    final account = await _accountRepository.get();
    final settings = await _settingRepository.load();

    final uri = Uri.https(_api.url, "/posts.json", {
      "login": account.username,
      "api_key": account.apiKey,
      "page": page.toString(),
      "tags": settings.safeMode ? "$tagString rating:s" : tagString,
      "limit": "100",
    });

    var posts = List<Post>();
    try {
      final respond = await _api.dio.get(uri.toString(),
          options: buildCacheOptions(
            Duration(minutes: 1),
          ));

      for (var item in respond.data) {
        try {
          var post = Post.fromJson(item);

          if (!post.containsBlacklistedTag(settings.blacklistedTags)) {
            posts.add(post);
          }
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }
    } on DioError catch (e) {
      if (e.response.statusCode == 422) {
        throw CannotSearchMoreThanTwoTags(
            "You cannot search for more than 2 tags at a time. Upgrade your account to search for more tags at once.");
      } else if (e.response.statusCode == 500) {
        throw DatabaseTimeOut(
            "Your search took too long to execute and was cancelled.");
      }
    }

    return posts;
  }
}

class CannotSearchMoreThanTwoTags implements Exception {
  final String message;
  CannotSearchMoreThanTwoTags(this.message);
}

class DatabaseTimeOut implements Exception {
  final String message;
  DatabaseTimeOut(this.message);
}
