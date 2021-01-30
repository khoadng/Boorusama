// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:html/parser.dart' as html;

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_statistics.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';

final postProvider = Provider<IPostRepository>((ref) {
  return PostRepository(ref);
});

class PostRepository implements IPostRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;
  final ProviderReference _ref;

  PostRepository(ProviderReference ref)
      : _api = ref.watch(apiProvider),
        _accountRepository = ref.watch(accountProvider),
        _ref = ref;

  @override
  Future<List<PostDto>> getPosts(String tagString, int page,
      {int limit = 100}) async {
    final account = await _accountRepository.get();
    final settingsRepository = await _ref.watch(settingsProvider.future);
    final settings = await settingsRepository.load();

    return _api
        .getPosts(account.username, account.apiKey, page,
            settings.safeMode ? "$tagString rating:s" : tagString, limit)
        .then((value) {
      final posts = <PostDto>[];

      final stopwatch = Stopwatch()..start();

      for (var item in value.response.data) {
        try {
          var post = PostDto.fromJson(item);
          posts.add(post);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }
      print('parsed posts in ${stopwatch.elapsed.inMilliseconds}ms'
          .toUpperCase());
      return posts;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final response = (obj as DioError).response;
          if (response.statusCode == 422) {
            throw CannotSearchMoreThanTwoTags(
                "You cannot search for more than 2 tags at a time. Upgrade your account to search for more tags at once.");
          } else if (response.statusCode == 500) {
            throw DatabaseTimeOut(
                "Your search took too long to execute and was cancelled.");
          } else {
            throw Exception("Failed to get posts for $tagString");
          }
          break;
        default:
      }
      return List<Post>();
    });
  }

  @override
  Future<List<PostDto>> getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale,
  ) async {
    final account = await _accountRepository.get();
    return _api
        .getPopularPosts(
            account.username,
            account.apiKey,
            "${date.year}-${date.month}-${date.day}",
            scale.toString().split(".").last,
            page,
            100)
        .then((value) {
      final posts = <PostDto>[];

      for (var item in value.response.data) {
        try {
          var post = PostDto.fromJson(item);
          posts.add(post);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }

      return posts;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final response = (obj as DioError).response;
          if (response.statusCode == 500) {
            throw DatabaseTimeOut(
                "Your search took too long to execute and was cancelled.");
          } else {
            throw Exception("Failed to get popular posts for $date");
          }
          break;
        default:
      }
      return List<Post>();
    });
  }

  @override
  Future<List<PostDto>> getCuratedPosts(
    DateTime date,
    int page,
    TimeScale scale,
  ) async {
    final account = await _accountRepository.get();

    return _api
        .getCuratedPosts(
            account.username,
            account.apiKey,
            "${date.year}-${date.month}-${date.day}",
            scale.toString().split(".").last,
            page,
            100)
        .then((value) {
      final posts = <PostDto>[];

      for (var item in value.response.data) {
        try {
          var post = PostDto.fromJson(item);
          posts.add(post);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }

      return posts;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final response = (obj as DioError).response;
          if (response.statusCode == 500) {
            throw DatabaseTimeOut(
                "Your search took too long to execute and was cancelled.");
          } else {
            throw Exception("Failed to get popular posts for $date");
          }
          break;
        default:
      }
      return List<Post>();
    });
  }

  @override
  Future<List<PostDto>> getMostViewedPosts(
    DateTime date,
  ) async {
    final account = await _accountRepository.get();

    return _api
        .getMostViewedPosts(account.username, account.apiKey,
            "${date.year}-${date.month}-${date.day}")
        .then((value) {
      final posts = <PostDto>[];

      for (var item in value.response.data) {
        try {
          var post = PostDto.fromJson(item);
          posts.add(post);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }

      return posts;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final response = (obj as DioError).response;
          if (response.statusCode == 500) {
            throw DatabaseTimeOut(
                "Your search took too long to execute and was cancelled.");
          } else {
            throw Exception("Failed to get popular posts for $date");
          }
          break;
        default:
      }
      return List<Post>();
    });
  }
}

PostStatistics parseStatistics(Map<String, dynamic> data) {
  final htmlString = data["data"];
  final postId = data["postId"];

  final stopwatch = Stopwatch()..start();

  final document = html.parse(htmlString);

  final contentNode =
      document.documentElement.querySelector("section[id='content']");
  final isFavorited =
      contentNode.querySelector("div[class='fav-buttons fav-buttons-true']") !=
          null;

  final commentCount = contentNode
      .querySelector("section[id='comments']")
      .querySelector("div[class='list-of-comments list-of-messages']")
      .querySelectorAll("article[class='comment message']")
      .length;

  final favCount = document.documentElement
      .querySelector("span[id='favcount-for-post-$postId']")
      .text;

  print('parsed statistics in ${stopwatch.elapsed.inMilliseconds}ms'
      .toUpperCase());
  return PostStatistics(
      favCount: int.parse(favCount),
      commentCount: commentCount,
      isFavorited: isFavorited);
}

class CannotSearchMoreThanTwoTags implements Exception {
  final String message;
  CannotSearchMoreThanTwoTags(this.message);
}

class DatabaseTimeOut implements Exception {
  final String message;
  DatabaseTimeOut(this.message);
}
