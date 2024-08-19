// Project imports:
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'danbooru_post_vote.dart';
import 'post_vote_repository.dart';

class PostVoteApiRepositoryApi implements PostVoteRepository {
  const PostVoteApiRepositoryApi({
    required this.client,
    required this.booruConfig,
  });

  final BooruConfig booruConfig;
  final DanbooruClient client;

  @override
  Future<List<DanbooruPostVote>> getPostVotes(
      List<int> postIds, int userId) async {
    return client
        .getPostVotes(
          postIds: postIds,
          userId: userId,
          isDeleted: false,
        )
        .then((value) => value.map(postVoteDtoToPostVote).toList());
  }

  Future<DanbooruPostVote?> _vote(int postId, int score) => client
      .votePost(
        postId: postId,
        score: score,
      )
      .then(postVoteDtoToPostVote)
      .then((value) => Future<DanbooruPostVote?>.value(value))
      .catchError((e) => null);

  @override
  Future<DanbooruPostVote?> downvote(int postId) => _vote(postId, -1);

  @override
  Future<DanbooruPostVote?> upvote(int postId) => _vote(postId, 1);

  @override
  Future<bool> removeVote(int postId) => client.removePostVote(postId);
}

DanbooruPostVote postVoteDtoToPostVote(PostVoteDto d) {
  return DanbooruPostVote(
    id: d.id ?? 0,
    postId: d.postId ?? 0,
    userId: d.userId ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    score: d.score ?? 0,
    isDeleted: d.isDeleted ?? false,
  );
}
