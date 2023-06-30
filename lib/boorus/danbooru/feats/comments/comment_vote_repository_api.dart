// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'comment_vote.dart';
import 'comment_vote_dto.dart';
import 'comment_vote_repository.dart';

List<CommentVote> parseCommentVote(HttpResponse<dynamic> value) =>
    parseResponse(
      value: value,
      converter: (item) => CommentVoteDto.fromJson(item),
    ).map(commentVoteDtoToCommentVote).toList();

class CommentVoteApiRepository implements CommentVoteRepository {
  const CommentVoteApiRepository(
    DanbooruApi api,
  ) : _api = api;

  final DanbooruApi _api;

  @override
  Future<List<CommentVote>> getCommentVotes(List<int> commentIds) => _api
          .getCommentVotes(
            commentIds.join(','),
            false,
          )
          .then(parseCommentVote)
          .catchError((Object error) {
        throw Exception(
          'Failed to get comment votes for ${commentIds.join(',')}',
        );
      });

  @override
  Future<CommentVote> downvote(int commentId) => _api
      .voteComment(
        commentId,
        -1,
      )
      .then(extractData)
      .then(CommentVoteDto.fromJson)
      .then(commentVoteDtoToCommentVote)
      .catchError(
        (Object error) => throw Exception('Failed to downvote $commentId'),
      );

  @override
  Future<CommentVote> upvote(int commentId) => _api
          .voteComment(
            commentId,
            1,
          )
          .then(extractData)
          .then(CommentVoteDto.fromJson)
          .then(commentVoteDtoToCommentVote)
          .catchError((Object error) {
        throw Exception('Failed to upvote $commentId');
      });

  @override
  Future<bool> removeVote(int commentId) => _api
      .removeVoteComment(
        commentId,
      )
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
