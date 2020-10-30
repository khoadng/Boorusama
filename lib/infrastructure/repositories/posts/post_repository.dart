import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
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

    var respond = await _api.dio
        .get(uri.toString(), options: buildCacheOptions(Duration(minutes: 1)));

    if (respond.statusCode == 200) {
      var posts = List<Post>();
      for (var item in respond.data) {
        try {
          posts.add(Post.fromJson(item));
        } catch (e) {
          print("Cant parse $item[id]");
        }
      }
      return posts;
      // return content.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception("Unable to perform request!");
    }
  }
}
