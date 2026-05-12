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

  Future<CommentDto> getComment({
    required int commentId,
  }) async {
    final response = await dio.get('/api/comment/$commentId');

    return CommentDto.fromJson(response.data);
  }

  Future<CommentDto> createComment({
    required int postId,
    required String text,
  }) async {
    final response = await dio.post(
      '/api/comments',
      data: {
        'postId': postId,
        'text': text,
      },
    );

    return CommentDto.fromJson(response.data);
  }

  Future<CommentDto> updateComment({
    required int commentId,
    required String text,
    int? version,
  }) async {
    final effectiveVersion =
        version ??
        _versionValue((await getComment(commentId: commentId)).version);

    if (effectiveVersion == null) {
      throw StateError('Comment version is required');
    }

    final response = await dio.put(
      '/api/comment/$commentId',
      data: {
        'version': effectiveVersion,
        'text': text,
      },
    );

    return CommentDto.fromJson(response.data);
  }

  Future<void> deleteComment({
    required int commentId,
    int? version,
  }) async {
    final effectiveVersion =
        version ??
        _versionValue((await getComment(commentId: commentId)).version);

    if (effectiveVersion == null) {
      throw StateError('Comment version is required');
    }

    await dio.delete(
      '/api/comment/$commentId',
      data: {
        'version': effectiveVersion,
      },
    );
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

int? _versionValue(SzurubooruVersion? version) => switch (version) {
  IntVersion(value: final value) => value,
  StringVersion(value: final value) => int.tryParse(value),
  _ => null,
};
