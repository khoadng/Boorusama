// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/core/booru_user_identity_provider.dart';
import 'package:boorusama/core/boorus/boorus.dart';
import 'package:boorusama/core/http_parser.dart';
import '../models/post_vote.dart';
import '../models/post_vote_repository.dart';
import 'post_vote_dto.dart';

List<PostVote> parsePostVote(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => PostVoteDto.fromJson(item),
    ).map(postVoteDtoToPostVote).toList();

class PostVoteApiRepositoryApi implements PostVoteRepository {
  const PostVoteApiRepositoryApi({
    required DanbooruApi api,
    required this.booruConfig,
    required this.booruUserIdentityProvider,
  }) : _api = api;

  final BooruConfig booruConfig;
  final DanbooruApi _api;
  final BooruUserIdentityProvider booruUserIdentityProvider;

  @override
  Future<List<PostVote>> getPostVotes(List<int> postIds) async {
    if (postIds.isEmpty) return Future.value([]);
    final id =
        await booruUserIdentityProvider.getAccountIdFromConfig(booruConfig);
    if (id == null) return [];

    return _api
        .getPostVotes(
          booruConfig.login,
          booruConfig.apiKey,
          1,
          postIds.join(','),
          id.toString(),
          false,
          100,
        )
        .then(parsePostVote);
  }

  @override
  Future<List<PostVote>> getAllVotes(int postId, int page) => _api
      .getPostVotes(
        booruConfig.login,
        booruConfig.apiKey,
        page,
        postId.toString(),
        null,
        false,
        100,
      )
      .then(parsePostVote);

  Future<PostVote?> _vote(int postId, int score) => _api
      .votePost(
        booruConfig.login,
        booruConfig.apiKey,
        postId,
        score,
      )
      .then(extractData)
      .then(PostVoteDto.fromJson)
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
