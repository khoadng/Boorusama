// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/accounts.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

List<CommentVote> parseCommentVote(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => CommentVoteDto.fromJson(item),
    ).map(commentVoteDtoToCommentVote).toList();

class CommentVoteApiRepository implements CommentVoteRepository {
  const CommentVoteApiRepository(Api api, AccountRepository accountRepository)
      : _api = api,
        _accountRepository = accountRepository;

  final Api _api;
  final AccountRepository _accountRepository;

  @override
  Future<List<CommentVote>> getCommentVotes(List<int> commentIds) =>
      _accountRepository
          .get()
          .then((account) => _api.getCommentVotes(
                account.username,
                account.apiKey,
                commentIds.join(','),
                false,
              ))
          .then(parseCommentVote)
          .catchError((Object error) {
        throw Exception(
            'Failed to get comment votes for ${commentIds.join(',')}');
      });
}
