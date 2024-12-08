// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kUpvoteScore = 1;
const _kDownvoteScore = -1;
const _kUnvoteScore = 0;

mixin SzurubooruClientComments {
  Dio get dio;

  Future<List<CommentDto>> getComments({
    required int postId,
  }) async {
    final response = await dio.get(
      '/api/comments',
      queryParameters: {
        'query': 'post:$postId',
      },
    );

    final results = response.data['results'] as List;

    return results.map((e) => CommentDto.fromJson(e)).toList();
  }

  Future<CommentDto> upvoteComment({
    required int commentId,
  }) async {
    final response = await dio.put(
      '/api/comment/$commentId/score',
      data: {
        'score': _kUpvoteScore,
      },
    );

    return CommentDto.fromJson(response.data);
  }

  Future<CommentDto> downvoteComment({
    required int commentId,
  }) async {
    final response = await dio.put(
      '/api/comment/$commentId/score',
      data: {
        'score': _kDownvoteScore,
      },
    );

    return CommentDto.fromJson(response.data);
  }

  Future<CommentDto> unvoteComment({
    required int commentId,
  }) async {
    final response = await dio.put(
      '/api/comment/$commentId/score',
      data: {
        'score': _kUnvoteScore,
      },
    );

    return CommentDto.fromJson(response.data);
  }
}
