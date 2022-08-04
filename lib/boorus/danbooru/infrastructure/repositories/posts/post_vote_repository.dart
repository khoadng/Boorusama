// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_vote.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_vote_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_vote_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

class PostVoteApiRepository implements PostVoteRepository {
  const PostVoteApiRepository({
    required Api api,
    required IAccountRepository accountRepo,
  })  : _api = api,
        _accountRepository = accountRepo;

  final IAccountRepository _accountRepository;
  final Api _api;

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
