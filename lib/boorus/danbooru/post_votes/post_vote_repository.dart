// Project imports:
import 'danbooru_post_vote.dart';

abstract class PostVoteRepository {
  Future<DanbooruPostVote?> upvote(int postId);
  Future<DanbooruPostVote?> downvote(int postId);
  Future<List<DanbooruPostVote>> getPostVotes(List<int> postIds, int userId);
  Future<bool> removeVote(int postId);
}
