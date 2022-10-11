// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/api.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/accounts/accounts.dart';
import 'package:boorusama/core/infra/http_parser.dart';

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

  @override
  Future<CommentVote> downvote(int commentId) => _accountRepository
      .get()
      .then((account) => _api.voteComment(
            account.username,
            account.apiKey,
            commentId,
            -1,
          ))
      .then(extractData)
      .then(CommentVoteDto.fromJson)
      .then(commentVoteDtoToCommentVote)
      .catchError(
          (Object error) => throw Exception('Failed to downvote $commentId'));

  @override
  Future<CommentVote> upvote(int commentId) => _accountRepository
          .get()
          .then((account) => _api.voteComment(
                account.username,
                account.apiKey,
                commentId,
                1,
              ))
          .then(extractData)
          .then(CommentVoteDto.fromJson)
          .then(commentVoteDtoToCommentVote)
          .catchError((Object error) {
        throw Exception('Failed to upvote $commentId');
      });

  @override
  Future<bool> removeVote(int commentId) => _accountRepository
      .get()
      .then((account) => _api.removeVoteComment(
            account.username,
            account.apiKey,
            commentId,
          ))
      .then((_) => true)
      .catchError((Object error) => false);
}
