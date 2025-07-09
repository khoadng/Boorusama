// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import 'post_vote.dart';
import 'post_vote_repository.dart';

class PostVoteApiRepositoryApi implements PostVoteRepository {
  const PostVoteApiRepositoryApi({
    required this.client,
    required this.authConfig,
  });

  final BooruConfigAuth authConfig;
  final DanbooruClient client;

  @override
  Future<List<DanbooruPostVote>> getPostVotesFromUser(
    List<int> postIds,
    int userId,
  ) => client
      .getPostVotesFromUser(
        postIds: postIds,
        userId: userId,
        isDeleted: false,
      )
      .then((value) => value.map(postVoteDtoToPostVote).toList());

  @override
  Future<List<DanbooruPostVote>> getPostVotes(
    int postId, {
    int? page,
  }) => client
      .getPostVotes(
        postIds: [postId],
        isDeleted: false,
        page: page,
      )
      .then((value) => value.map(postVoteDtoToPostVote).toList());

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
