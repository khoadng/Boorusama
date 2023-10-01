// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/comments/comments.dart';
import 'comment_votes_provider.dart';
import 'danbooru_comment.dart';
import 'danbooru_comment_vote.dart';

class CommentVotesNotifier
    extends FamilyNotifier<Map<CommentId, DanbooruCommentVote>, BooruConfig> {
  @override
  Map<int, DanbooruCommentVote> build(BooruConfig arg) {
    return {};
  }

  CommentVoteRepository<DanbooruCommentVote> get repo =>
      ref.read(danbooruCommentVoteRepoProvider(arg));

  Future<void> fetch(List<int> commentIds) async {
    // filter out already fetched ids
    final ids = commentIds.where((id) => !state.containsKey(id)).toList();

    if (ids.isEmpty) return;

    final votes = await repo.getCommentVotes(ids);
    state = {
      ...state,
      for (final vote in votes) vote.commentId: vote,
    };
  }

  // upvote
  Future<void> upvote(int commentId) async {
    final vote = await repo.upvoteComment(commentId);
    state = {
      ...state,
      commentId: vote,
    };
  }

  // downvote
  Future<void> downvote(int commentId) async {
    final vote = await repo.downvoteComment(commentId);
    state = {
      ...state,
      commentId: vote,
    };
  }

  // unvote
  Future<void> unvote(DanbooruCommentVote? commentVote) async {
    if (commentVote == null) return;
    final currentVote = state[commentVote.commentId];

    if (currentVote == null) return;

    final success = await repo.unvoteComment(commentVote.id);

    if (!success) return;

    // update score base on current vote state
    final voteState = currentVote.voteState;
    final newScore =
        currentVote.score + (voteState == CommentVoteState.upvoted ? -1 : 1);

    state = {
      ...state,
      commentVote.commentId: currentVote.copyWith(score: newScore),
    };
  }
}
