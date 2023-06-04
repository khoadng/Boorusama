// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/core/boorus/boorus.dart';
import 'package:boorusama/foundation/http/http.dart';
import '../comments.dart';

List<CommentVote> parseCommentVote(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => CommentVoteDto.fromJson(item),
    ).map(commentVoteDtoToCommentVote).toList();

class CommentVoteApiRepository implements CommentVoteRepository {
  const CommentVoteApiRepository(
    DanbooruApi api,
    this.booruConfig,
  ) : _api = api;

  final DanbooruApi _api;
  final BooruConfig booruConfig;

  @override
  Future<List<CommentVote>> getCommentVotes(List<int> commentIds) => _api
          .getCommentVotes(
            booruConfig.login,
            booruConfig.apiKey,
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
        booruConfig.login,
        booruConfig.apiKey,
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
            booruConfig.login,
            booruConfig.apiKey,
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
        booruConfig.login,
        booruConfig.apiKey,
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
