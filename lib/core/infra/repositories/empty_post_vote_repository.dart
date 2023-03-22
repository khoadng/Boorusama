import 'package:boorusama/boorus/danbooru/domain/posts.dart';

class EmptyPostVoteRepository implements PostVoteRepository {
  @override
  Future<PostVote?> downvote(int postId) async => null;

  @override
  Future<List<PostVote>> getAllVotes(int postId, int page) async => [];

  @override
  Future<List<PostVote>> getPostVotes(List<int> postIds) async => [];

  @override
  Future<PostVote?> upvote(int postId) async => null;
}
