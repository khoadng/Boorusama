// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';
import 'black_listed_filter_decorator.dart';
import 'no_image_filter_decorator.dart';

final postProvider = Provider<IPostRepository>((ref) {
  final postRepo = PostRepository(ref);
  final filteredPostRepo = BlackListedFilterDecorator(
    postRepository: postRepo,
    settings: ref.watch(settingsNotifier.state).settings,
  );
  final removedNullImageRepo =
      NoImageFilterDecorator(postRepository: filteredPostRepo);
  return removedNullImageRepo;
});

class PostRepository implements IPostRepository {
  PostRepository(ProviderReference ref)
      : _api = ref.watch(apiProvider),
        _accountRepository = ref.watch(accountProvider),
        _favoritePostRepository = ref.watch(favoriteProvider),
        _ref = ref;

  final IAccountRepository _accountRepository;
  final IApi _api;
  final IFavoritePostRepository _favoritePostRepository;
  final ProviderReference _ref;

  static const int _limit = 60;

  @override
  Future<List<Post>> getCuratedPosts(
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
            _limit)
        .then((value) async {
      final dtos = <PostDto>[];
      await _appendIsFavoritedIfValid(value, account, limit: _limit);

      for (var item in value.response.data) {
        try {
          var dto = PostDto.fromJson(item);
          dtos.add(dto);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }

      final posts = dtos.map((dto) => dto.toEntity()).toList();

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
  Future<List<Post>> getMostViewedPosts(
    DateTime date,
  ) async {
    final account = await _accountRepository.get();

    return _api
        .getMostViewedPosts(account.username, account.apiKey,
            "${date.year}-${date.month}-${date.day}")
        .then((value) async {
      final dtos = <PostDto>[];
      await _appendIsFavoritedIfValid(value, account, limit: _limit);

      for (var item in value.response.data) {
        try {
          var dto = PostDto.fromJson(item);
          dtos.add(dto);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }

      final posts = dtos.map((dto) => dto.toEntity()).toList();

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
  Future<List<Post>> getPopularPosts(
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
            _limit)
        .then((value) async {
      final dtos = <PostDto>[];

      await _appendIsFavoritedIfValid(value, account, limit: _limit);
      for (var item in value.response.data) {
        try {
          var dto = PostDto.fromJson(item);
          dtos.add(dto);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }

      final posts = dtos.map((dto) => dto.toEntity()).toList();

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
  Future<List<Post>> getPosts(
    String tagString,
    int page, {
    int limit = 100,
    CancelToken cancelToken,
    bool skipFavoriteCheck = false,
  }) async {
    final account = await _accountRepository.get();
    final settings = _ref.watch(settingsNotifier.state).settings;

    try {
      final stopwatch = Stopwatch()..start();
      final value = await _api.getPosts(account.username, account.apiKey, page,
          settings.safeMode ? "$tagString rating:s" : tagString, limit,
          cancelToken: cancelToken);

      final dtos = <PostDto>[];
      if (!skipFavoriteCheck) {
        await _appendIsFavoritedIfValid(value, account, limit: limit);
      }

      for (var item in value.response.data) {
        try {
          var dto = PostDto.fromJson(item);
          dtos.add(dto);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }

      final posts = dtos.map((dto) => dto.toEntity()).toList();

      print('parsed posts in ${stopwatch.elapsed.inMilliseconds}ms'
          .toUpperCase());

      return posts;
    } on DioError catch (e) {
      if (e.type == DioErrorType.CANCEL) {
        // Cancel token triggered, skip this request
        return [];
      } else if (e.response.statusCode == 422) {
        throw CannotSearchMoreThanTwoTags(
            "You cannot search for more than 2 tags at a time. Upgrade your account to search for more tags at once.");
      } else if (e.response.statusCode == 500) {
        throw DatabaseTimeOut(
            "Your search took too long to execute and was cancelled.");
      } else {
        throw Exception("Failed to get posts for $tagString");
      }
    }
  }

  Future _appendIsFavoritedIfValid(
    HttpResponse value,
    Account account, {
    int limit = 100,
  }) async {
    var postIds =
        List<int>.from(value.response.data.map((post) => post["id"]).toList());

    final favorites = await _favoritePostRepository.filterFavoritesFromUserId(
      postIds,
      account.id,
      limit,
    );

    favorites.forEach((fav) {
      final data = value.response.data;
      for (var item in data) {
        if (item['id'].toString() == fav.post_id.toString()) {
          value.response.data[data.indexOf(item)]
              .putIfAbsent("is_favorited", () => true);
        }
      }
    });
  }
}

class CannotSearchMoreThanTwoTags implements Exception {
  CannotSearchMoreThanTwoTags(this.message);

  final String message;
}

class DatabaseTimeOut implements Exception {
  DatabaseTimeOut(this.message);

  final String message;
}
