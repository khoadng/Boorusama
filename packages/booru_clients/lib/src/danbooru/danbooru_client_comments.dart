// Dart imports:
import 'dart:isolate';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kCommentParams =
    'creator,id,post_id,body,score,is_deleted,created_at,updated_at,is_sticky,do_not_bump_post,updater_id';

mixin DanbooruClientComments {
  Dio get dio;

  Future<int> getCommentCount({
    required int postId,
  }) async {
    final response = await dio.get(
      '/comments.json',
      queryParameters: {
        'search[post_id]': postId,
        'only': 'id,is_deleted',
      },
    );

    return (response.data as List)
        .where((item) => (item['is_deleted'] ?? false) == false)
        .length;
  }

  Future<List<CommentDto>> getComments({
    required int postId,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/comments.json',
      queryParameters: {
        'search[post_id]': postId,
        if (limit != null) 'limit': limit,
        'only': _kCommentParams,
      },
      cancelToken: cancelToken,
    );

    return Isolate.run(() => (response.data as List)
        .map((item) => CommentDto.fromJson(item))
        .toList());
  }

  Future<CommentDto> postComment({
    required int postId,
    required String content,
  }) async {
    final formData = {
      'comment[post_id]': postId,
      'comment[body]': content,
      'comment[do_not_bump_post]': true,
    };

    final response = await dio.post(
      '/comments.json',
      data: formData,
      options: Options(
        headers: dio.options.headers,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return CommentDto.fromJson(response.data);
  }

  Future<void> updateComment({
    required int commentId,
    required String content,
  }) async {
    final formData = {
      'comment[body]': content,
    };

    final _ = await dio.put(
      '/comments/$commentId.json',
      data: formData,
      options: Options(
        headers: dio.options.headers,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
  }

  Future<void> deleteComment({
    required int commentId,
  }) async {
    final _ = await dio.delete(
      '/comments/$commentId.json',
    );
  }

  Future<List<CommentVoteDto>> getCommentVotes({
    required List<int> commentIds,
    bool? isDeleted,
  }) async {
    if (commentIds.isEmpty) {
      throw ArgumentError('commentIds cannot be empty');
    }

    final response = await dio.get(
      '/comment_votes.json',
      queryParameters: {
        'search[comment_id]': commentIds.join(','),
        if (isDeleted != null) 'search[is_deleted]': isDeleted.toString(),
      },
    );

    return (response.data as List)
        .map((item) => CommentVoteDto.fromJson(item))
        .toList();
  }

  Future<CommentVoteDto> voteComment({
    required int commentId,
    required int score,
  }) async {
    final response = await dio.post(
      '/comments/$commentId/votes.json',
      queryParameters: {
        'score': score,
      },
    );

    return CommentVoteDto.fromJson(response.data);
  }

  Future<void> removeCommentVote({
    required int commentId,
  }) async {
    final _ = await dio.delete(
      '/comment_votes/$commentId.json',
    );
  }

  Future<CommentVoteDto> upvoteComment({
    required int commentId,
  }) =>
      voteComment(
        commentId: commentId,
        score: 1,
      );

  Future<CommentVoteDto> downvoteComment({
    required int commentId,
  }) =>
      voteComment(
        commentId: commentId,
        score: -1,
      );
}
