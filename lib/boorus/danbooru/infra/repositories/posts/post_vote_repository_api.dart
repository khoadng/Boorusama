// Package imports:
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_vote.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_vote_repository.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<PostVote> parsePostVote(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => PostVoteDto.fromJson(item),
    ).map(postVoteDtoToPostVote).toList();

class PostVoteApiRepositoryApi implements PostVoteRepository {
  const PostVoteApiRepositoryApi({
    required Api api,
    required AccountRepository accountRepo,
  })  : _api = api,
        _accountRepository = accountRepo;

  final AccountRepository _accountRepository;
  final Api _api;

  @override
  Future<List<PostVote>> getPostVotes(List<int> postIds) => _accountRepository
      .get()
      .then((account) => _api.getPostVotes(
            account.username,
            account.apiKey,
            1,
            postIds.join(','),
            account.id.toString(),
            false,
            100,
          ))
      .then(parsePostVote);

  @override
  Future<List<PostVote>> getAllVotes(int postId, int page) => _accountRepository
      .get()
      .then((account) => _api.getPostVotes(
            account.username,
            account.apiKey,
            page,
            postId.toString(),
            '',
            false,
            100,
          ))
      .then(parsePostVote);

  Future<PostVote> _vote(int postId, int score) => _accountRepository
      .get()
      .then(
        (account) => _api.votePost(
          account.username,
          account.apiKey,
          postId,
          score,
        ),
      )
      .then(extractData)
      .then(PostVoteDto.fromJson)
      .then(postVoteDtoToPostVote);

  @override
  Future<PostVote> downvote(int postId) => _vote(postId, -1);

  @override
  Future<PostVote> upvote(int postId) => _vote(postId, 1);
}

PostVote postVoteDtoToPostVote(PostVoteDto d) {
  return PostVote(
    id: d.id ?? 0,
    postId: d.postId ?? 0,
    userId: UserId(d.userId ?? 0),
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    score: d.score ?? 0,
    isDeleted: d.isDeleted ?? false,
  );
}
