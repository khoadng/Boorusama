// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin DanbooruClientExplores {
  Dio get dio;

  String _formatDate(DateTime date) => '${date.year}-${date.month}-${date.day}';

  Future<List<PostDto>> getPopularPosts({
    required DateTime date,
    required TimeScale scale,
    int? page,
    int? limit,
  }) async {
    final response = await dio.get(
      '/explore/posts/popular.json',
      queryParameters: {
        'date': _formatDate(date),
        'scale': scale.name,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => PostDto.fromJson(item))
        .toList();
  }

  Future<List<PostDto>> getMostViewedPosts({
    required DateTime date,
  }) async {
    final response = await dio.get(
      '/explore/posts/viewed.json',
      queryParameters: {
        'date': _formatDate(date),
      },
    );

    return (response.data as List)
        .map((item) => PostDto.fromJson(item))
        .toList();
  }

  Future<List<SearchKeywordDto>> getPopularSearchByDate({
    required DateTime date,
  }) async {
    final response = await dio.get(
      '/explore/posts/searches.json',
      queryParameters: {
        'date': _formatDate(date),
      },
    );

    return (response.data as List)
        .map((item) => SearchKeywordDto.fromJson(item))
        .toList();
  }
}
