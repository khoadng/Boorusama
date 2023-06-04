// Project imports:
import '../comments.dart';

abstract class CommentVoteRepository {
  Future<List<CommentVote>> getCommentVotes(List<int> commentIds);
  Future<CommentVote> upvote(int commentId);
  Future<CommentVote> downvote(int commentId);
  Future<bool> removeVote(int commentId);
}
