import 'dart:convert';

import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';

import 'package:http/http.dart' as http;

class PostRepository implements IPostRepository {
  final http.Client _httpClient = http.Client();
  final _url = "danbooru.donmai.us";
  final _username = "khoaharp";
  final _apiKey = "tstJTCP7ghdQ82LNfvuz1fAv";

  @override
  Future<List<Post>> getPosts(String tagString, int page) async {
    var uri = Uri.http(_url, "/posts.json", {
      "login": _username,
      "api_key": _apiKey,
      "page": page.toString(),
      "tags": tagString,
      "limit": "200",
    });

    var respond = await _httpClient.get(uri);

    if (respond.statusCode == 200) {
      var content = jsonDecode(respond.body);
      var posts = List<Post>();
      for (var item in content) {
        posts.add(Post.fromJson(item));
      }
      return posts;
      // return content.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception("Unable to perform request!");
    }
  }
}
