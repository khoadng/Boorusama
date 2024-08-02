// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kUpvoteScore = 1;
const _kDownvoteScore = -1;
const _kUnvoteScore = 0;

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

  Future<PostDto> upvotePost({
    required int postId,
  }) async {
    final response = await dio.put(
      '/api/post/$postId/score',
      data: {
        'score': _kUpvoteScore,
      },
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: dio.options.baseUrl,
    );
  }

  Future<PostDto> downvotePost({
    required int postId,
  }) async {
    final response = await dio.put(
      '/api/post/$postId/score',
      data: {
        'score': _kDownvoteScore,
      },
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: dio.options.baseUrl,
    );
  }

  Future<PostDto> unvotePost({
    required int postId,
  }) async {
    final response = await dio.put(
      '/api/post/$postId/score',
      data: {
        'score': _kUnvoteScore,
      },
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: dio.options.baseUrl,
    );
  }
}
