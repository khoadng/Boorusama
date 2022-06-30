// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'comment.dart';

abstract class ICommentRepository {
  Future<List<Comment>> getCommentsFromPostId(
    int postId, {
    CancelToken? cancelToken,
  });

  Future<bool> postComment(int postId, String content);
  Future<bool> updateComment(int commentId, String content);
  Future<bool> deleteComment(int commentId);
}
