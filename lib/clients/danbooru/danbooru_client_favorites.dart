// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin DanbooruClientFavorites {
  Dio get dio;

  Future<bool> addToFavorites({
    required int postId,
  }) async {
    try {
      final _ = await dio.post(
        '/favorites.json',
        queryParameters: {
          'post_id': postId.toString(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromFavorites({
    required int postId,
  }) async {
    try {
      final _ = await dio.delete(
        '/favorites/$postId.json',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<FavoriteDto>> filterFavoritesFromUserId({
    required List<int> postIds,
    required int userId,
    int limit = 200,
  }) async {
    if (postIds.isEmpty) return [];

    final response = await dio.get(
      '/favorites.json',
      queryParameters: {
        'search[post_id]': postIds.join(' '),
        'search[user_id]': userId,
        'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => FavoriteDto.fromJson(item))
        .toList();
  }

  Future<List<FavoriteDto>> getFavorites({
    required int postId,
    int? page,
    int? limit,
  }) async {
    final response = await dio.get(
      '/posts/$postId/favorites.json',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => FavoriteDto.fromJson(item))
        .toList();
  }
}
