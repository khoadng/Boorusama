// Package imports:
import 'package:booru_clients/danbooru.dart' as d;

// Project imports:
import 'parser.dart';
import 'post_vote.dart';
import 'post_vote_repository.dart';

class PostVoteApiRepositoryApi implements PostVoteRepository {
  const PostVoteApiRepositoryApi({
    required this.client,
  });

  final d.DanbooruClient client;

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
  Future<bool> removeVote(PostVoteId id) => client.removePostVote(id);
}
