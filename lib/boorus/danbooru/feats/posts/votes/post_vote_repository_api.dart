// Project imports:
import 'package:boorusama/boorus/core/feats/booru_user_identity_provider.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'post_vote.dart';
import 'post_vote_repository.dart';

class PostVoteApiRepositoryApi implements PostVoteRepository {
  const PostVoteApiRepositoryApi({
    required this.client,
    required this.booruConfig,
    required this.booruUserIdentityProvider,
  });

  final BooruConfig booruConfig;
  final DanbooruClient client;
  final BooruUserIdentityProvider booruUserIdentityProvider;

  @override
  Future<List<PostVote>> getPostVotes(List<int> postIds) async {
    if (postIds.isEmpty) return Future.value([]);
    final id =
        await booruUserIdentityProvider.getAccountIdFromConfig(booruConfig);
    if (id == null) return [];

    return client
        .getPostVotes(
          postIds: postIds,
          userId: id,
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
