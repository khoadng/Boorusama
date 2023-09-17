// Project imports:
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'comment_vote.dart';
import 'comment_vote_repository.dart';

class CommentVoteApiRepository implements CommentVoteRepository {
  const CommentVoteApiRepository(
    this.client,
  );

  final DanbooruClient client;

  @override
  Future<List<CommentVote>> getCommentVotes(List<int> commentIds) => client
      .getCommentVotes(
        commentIds: commentIds,
        isDeleted: false,
      )
      .then((value) => value.map(commentVoteDtoToCommentVote).toList())
      .catchError((Object error) => throw Exception(
            'Failed to get comment votes for ${commentIds.join(',')}',
          ));

  @override
  Future<CommentVote> downvote(int commentId) => client
      .downvoteComment(
        commentId: commentId,
      )
      .then(commentVoteDtoToCommentVote)
      .catchError(
        (error) => throw Exception('Failed to downvote $commentId'),
      );

  @override
  Future<CommentVote> upvote(int commentId) => client
      .upvoteComment(
        commentId: commentId,
      )
      .then(commentVoteDtoToCommentVote)
      .catchError((error) => throw Exception('Failed to upvote $commentId'));

  @override
  Future<bool> removeVote(int commentId) => client
      .removeCommentVote(
        commentId: commentId,
      )
      .then((_) => true)
      .catchError((error) => false);
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
