import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_dto.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:boorusama/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/infrastructure/apis/i_api.dart';
import 'package:boorusama/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/all.dart';

final postProvider = Provider<IPostRepository>((ref) {
  return PostRepository(ref.watch(apiProvider), ref.watch(accountProvider),
      ref.watch(settingsProvider));
});

class PostRepository implements IPostRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;
  final ISettingRepository _settingRepository;

  PostRepository(this._api, this._accountRepository, this._settingRepository);

  @override
  Future<PostDto> getPost(int id) async {
    final account = await _accountRepository.get();

    return _api.getPost(account.username, account.apiKey, id).then((value) {
      try {
        var post = PostDto.fromJson(value.response.data);
        return post;
      } catch (e) {
        print("Cant parse $id");
        return null;
      }
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          throw Exception("Failed to get post for $id");
          break;
        default:
      }
      return null;
    });
  }

  @override
  Future<List<PostDto>> getPosts(String tagString, int page) async {
    final account = await _accountRepository.get();
    final settings = await _settingRepository.load();

    return _api
        .getPosts(account.username, account.apiKey, page,
            settings.safeMode ? "$tagString rating:s" : tagString, 100)
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
            200)
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
            200)
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

class CannotSearchMoreThanTwoTags implements Exception {
  final String message;
  CannotSearchMoreThanTwoTags(this.message);
}

class DatabaseTimeOut implements Exception {
  final String message;
  DatabaseTimeOut(this.message);
}
