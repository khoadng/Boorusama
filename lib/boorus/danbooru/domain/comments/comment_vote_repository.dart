import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';

abstract class CommentVoteRepository {
  Future<List<CommentVote>> getCommentVotes(List<int> commentIds);
}
