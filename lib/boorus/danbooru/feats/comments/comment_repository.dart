// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'danbooru_comment.dart';

abstract class CommentRepository {
  Future<List<DanbooruComment>> getCommentsFromPostId(
    int postId, {
    CancelToken? cancelToken,
  });

  Future<bool> postComment(int postId, String content);
  Future<bool> updateComment(int commentId, String content);
  Future<bool> deleteComment(int commentId);
}
