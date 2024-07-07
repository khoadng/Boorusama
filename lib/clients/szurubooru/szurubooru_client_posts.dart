// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin SzurubooruClientPosts {
  Dio get dio;

  Future<List<PostDto>> getPosts({
    int? limit,
    int? page,
    List<String>? tags,
  }) async {
    final response = await dio.get(
      '/api/posts',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (page != null && page > 0) 'offset': (page - 1) * (limit ?? 100),
        if (tags != null && tags.isNotEmpty) 'query': tags.join(' '),
      },
    );

    final results = response.data['results'] as List;

    return results
        .map((e) => PostDto.fromJson(
              e,
              baseUrl: dio.options.baseUrl,
            ))
        .toList();
  }
}
