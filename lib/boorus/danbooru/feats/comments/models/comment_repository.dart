// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getCommentsFromPostId(
    int postId, {
    CancelToken? cancelToken,
  });

  Future<bool> postComment(int postId, String content);
  Future<bool> updateComment(int commentId, String content);
  Future<bool> deleteComment(int commentId);
}
