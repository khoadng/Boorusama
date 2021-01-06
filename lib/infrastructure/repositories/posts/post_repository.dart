import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      "limit": "200",
    });

    var respond;
    try {
      respond = await _api.dio.get(uri.toString());
    } on DioError catch (e) {
      if (e.response.statusCode == 422) {
        throw CannotSearchMoreThanTwoTags(
            "You cannot search for more than 2 tags at a time. Upgrade your account to search for more tags at once.");
      } else if (e.response.statusCode == 500) {
        throw DatabaseTimeOut(
            "Your search took too long to execute and was cancelled.");
      }
    }
    final Map<String, dynamic> data = {
      "settings": settings,
      "data": respond.data
    };
    final posts = compute(parsePosts, data);

    return posts;
  }

  @override
  Future<List<Post>> getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale,
  ) async {
    final account = await _accountRepository.get();
    final settings = await _settingRepository.load();

    final uri = Uri.https(_api.url, "/explore/posts/popular.json", {
      "login": account.username,
      "api_key": account.apiKey,
      "date": "${date.year}-${date.month}-${date.day}",
      "scale": scale.toString().split(".").last,
      "page": page.toString(),
      "limit": "200",
    });

    var respond;
    try {
      respond = await _api.dio.get(uri.toString());
    } on DioError catch (e) {
      if (e.response.statusCode == 500) {
        throw DatabaseTimeOut(
            "Your search took too long to execute and was cancelled.");
      }
    }
    final Map<String, dynamic> data = {
      "settings": settings,
      "data": respond.data
    };
    final posts = compute(parsePosts, data);

    return posts;
  }

  @override
  Future<List<Post>> getCuratedPosts(
    DateTime date,
    int page,
    TimeScale scale,
  ) async {
    final account = await _accountRepository.get();
    final settings = await _settingRepository.load();

    final uri = Uri.https(_api.url, "/explore/posts/curated.json", {
      "login": account.username,
      "api_key": account.apiKey,
      "date": "${date.year}-${date.month}-${date.day}",
      "scale": scale.toString().split(".").last,
      "page": page.toString(),
      "limit": "200",
    });

    var respond;
    try {
      respond = await _api.dio.get(uri.toString());
    } on DioError catch (e) {
      if (e.response.statusCode == 500) {
        throw DatabaseTimeOut(
            "Your search took too long to execute and was cancelled.");
      }
    }
    final Map<String, dynamic> data = {
      "settings": settings,
      "data": respond.data
    };
    final posts = compute(parsePosts, data);

    return posts;
  }

  @override
  Future<List<Post>> getMostViewedPosts(
    DateTime date,
  ) async {
    final account = await _accountRepository.get();
    final settings = await _settingRepository.load();

    final uri = Uri.https(_api.url, "/explore/posts/viewed.json", {
      "login": account.username,
      "api_key": account.apiKey,
      "date": "${date.year}-${date.month}-${date.day}",
    });

    var respond;
    try {
      respond = await _api.dio.get(uri.toString());
    } on DioError catch (e) {
      if (e.response.statusCode == 500) {
        throw DatabaseTimeOut(
            "Your search took too long to execute and was cancelled.");
      }
    }
    final Map<String, dynamic> data = {
      "settings": settings,
      "data": respond.data
    };
    final posts = compute(parsePosts, data);

    return posts;
  }
}

List<Post> parsePosts(Map<String, dynamic> data) {
  var posts = List<Post>();
  var settings = data["settings"];
  var json = data["data"];

  for (var item in json) {
    try {
      var post = Post.fromJson(item);

      if (!post.containsBlacklistedTag(settings.blacklistedTags)) {
        posts.add(post);
      }
    } catch (e) {
      print("Cant parse ${item['id']}");
    }
  }

  return posts;
}

class CannotSearchMoreThanTwoTags implements Exception {
  final String message;
  CannotSearchMoreThanTwoTags(this.message);
}

class DatabaseTimeOut implements Exception {
  final String message;
  DatabaseTimeOut(this.message);
}
