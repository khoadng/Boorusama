// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<CommentVote> parseCommentVote(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => CommentVoteDto.fromJson(item),
    ).map(commentVoteDtoToCommentVote).toList();

class CommentVoteApiRepository implements CommentVoteRepository {
  const CommentVoteApiRepository(
    DanbooruApi api,
    CurrentBooruConfigRepository currentBooruConfigRepository,
  )   : _api = api,
        _currentUserBooruRepository = currentBooruConfigRepository;

  final DanbooruApi _api;
  final CurrentBooruConfigRepository _currentUserBooruRepository;

  @override
  Future<List<CommentVote>> getCommentVotes(List<int> commentIds) =>
      _currentUserBooruRepository
          .get()
          .then((booruConfig) => _api.getCommentVotes(
                booruConfig?.login,
                booruConfig?.apiKey,
                commentIds.join(','),
                false,
              ))
          .then(parseCommentVote)
          .catchError((Object error) {
        throw Exception(
          'Failed to get comment votes for ${commentIds.join(',')}',
        );
      });

  @override
  Future<CommentVote> downvote(int commentId) => _currentUserBooruRepository
      .get()
      .then((booruConfig) => _api.voteComment(
            booruConfig?.login,
            booruConfig?.apiKey,
            commentId,
            -1,
          ))
      .then(extractData)
      .then(CommentVoteDto.fromJson)
      .then(commentVoteDtoToCommentVote)
      .catchError(
        (Object error) => throw Exception('Failed to downvote $commentId'),
      );

  @override
  Future<CommentVote> upvote(int commentId) => _currentUserBooruRepository
          .get()
          .then((account) => _api.voteComment(
                account?.login,
                account?.apiKey,
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
  Future<bool> removeVote(int commentId) => _currentUserBooruRepository
      .get()
      .then((account) => _api.removeVoteComment(
            account?.login,
            account?.apiKey,
            commentId,
          ))
      .then((_) => true)
      .catchError((Object error) => false);
}

CommentVote commentVoteDtoToCommentVote(CommentVoteDto d) {
  return CommentVote(
    id: d.id ?? 0,
    commentId: d.commentId ?? 0,
    userId: d.userId ?? 0,
    score: d.score ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    isDeleted: d.isDeleted ?? false,
  );
}
