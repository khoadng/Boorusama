// Project imports:
import 'post_vote.dart';

abstract class PostVoteRepository {
  Future<DanbooruPostVote?> upvote(int postId);
  Future<DanbooruPostVote?> downvote(int postId);
  Future<List<DanbooruPostVote>> getPostVotesFromUser(
    List<int> postIds,
    int userId,
  );
  Future<List<DanbooruPostVote>> getPostVotes(
    int postId, {
    int? page,
  });
  Future<bool> removeVote(PostVoteId id);
}
