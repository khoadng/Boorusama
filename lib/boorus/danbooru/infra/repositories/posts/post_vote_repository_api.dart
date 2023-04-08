// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_vote.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_vote_repository.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<PostVote> parsePostVote(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => PostVoteDto.fromJson(item),
    ).map(postVoteDtoToPostVote).toList();

class PostVoteApiRepositoryApi implements PostVoteRepository {
  const PostVoteApiRepositoryApi(
      {required DanbooruApi api,
      required CurrentBooruConfigRepository currentBooruConfigRepository,
      required this.booruUserIdentityProvider})
      : _api = api,
        _currentUserBooruRepository = currentBooruConfigRepository;

  final CurrentBooruConfigRepository _currentUserBooruRepository;
  final DanbooruApi _api;
  final BooruUserIdentityProvider booruUserIdentityProvider;

  @override
  Future<List<PostVote>> getPostVotes(List<int> postIds) async {
    if (postIds.isEmpty) return Future.value([]);
    final booruConfig = await _currentUserBooruRepository.get();
    final id =
        await booruUserIdentityProvider.getAccountIdFromConfig(booruConfig);
    if (id == null) return [];

    return _api
        .getPostVotes(
          booruConfig?.login,
          booruConfig?.apiKey,
          1,
          postIds.join(','),
          id.toString(),
          false,
          100,
        )
        .then(parsePostVote);
  }

  @override
  Future<List<PostVote>> getAllVotes(int postId, int page) =>
      _currentUserBooruRepository
          .get()
          .then((booruConfig) => _api.getPostVotes(
                booruConfig?.login,
                booruConfig?.apiKey,
                page,
                postId.toString(),
                null,
                false,
                100,
              ))
          .then(parsePostVote);

  Future<PostVote?> _vote(int postId, int score) => _currentUserBooruRepository
      .get()
      .then(
        (booruConfig) => _api.votePost(
          booruConfig?.login,
          booruConfig?.apiKey,
          postId,
          score,
        ),
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
