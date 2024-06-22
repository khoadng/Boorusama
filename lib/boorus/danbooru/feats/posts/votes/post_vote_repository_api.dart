// Project imports:
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'post_vote.dart';
import 'post_vote_repository.dart';

class PostVoteApiRepositoryApi implements PostVoteRepository {
  const PostVoteApiRepositoryApi({
    required this.client,
    required this.booruConfig,
  });

  final BooruConfig booruConfig;
  final DanbooruClient client;

  @override
  Future<List<PostVote>> getPostVotes(List<int> postIds, int userId) async {
    return client
        .getPostVotes(
          postIds: postIds,
          userId: userId,
          isDeleted: false,
          limit: 100,
        )
        .then((value) => value.map(postVoteDtoToPostVote).toList());
  }

  Future<PostVote?> _vote(int postId, int score) => client
      .votePost(
        postId: postId,
        score: score,
      )
      .then(postVoteDtoToPostVote)
      .then((value) => Future<PostVote?>.value(value))
      .catchError((e) => null);

  @override
  Future<PostVote?> downvote(int postId) => _vote(postId, -1);

  @override
  Future<PostVote?> upvote(int postId) => _vote(postId, 1);

  @override
  Future<bool> removeVote(int postId) => client.removePostVote(postId);
}

PostVote postVoteDtoToPostVote(PostVoteDto d) {
  return PostVote(
    id: d.id ?? 0,
    postId: d.postId ?? 0,
    userId: d.userId ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    score: d.score ?? 0,
    isDeleted: d.isDeleted ?? false,
  );
}
