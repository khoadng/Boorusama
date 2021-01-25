// Project imports:
import 'comment_dto.dart';

abstract class ICommentRepository {
  Future<List<CommentDto>> getCommentsFromPostId(int postId);
  Future<bool> postComment(int postId, String content);
  Future<bool> updateComment(int commentId, String content);
}
