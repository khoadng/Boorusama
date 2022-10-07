// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post_vote.dart';

abstract class PostVoteRepository {
  Future<PostVote> upvote(int postId);
  Future<PostVote> downvote(int postId);
  Future<List<PostVote>> getPostVotes(List<int> postIds);
  Future<List<PostVote>> getAllVotes(int postId, int page);
}
