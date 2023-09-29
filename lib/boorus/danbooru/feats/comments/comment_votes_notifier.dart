// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'comment_vote.dart';
import 'comment_vote_repository.dart';
import 'comment_votes_provider.dart';
import 'danbooru_comment.dart';

class CommentVotesNotifier extends Notifier<Map<CommentId, CommentVote>> {
  @override
  Map<int, CommentVote> build() {
    ref.listen(
      currentBooruConfigProvider,
      (previous, next) => ref.invalidateSelf(),
    );

    return {};
  }

  CommentVoteRepository get repo => ref.read(danbooruCommentVoteRepoProvider);

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
    final vote = await repo.upvote(commentId);
    state = {
      ...state,
      commentId: vote,
    };
  }

  // downvote
  Future<void> downvote(int commentId) async {
    final vote = await repo.downvote(commentId);
    state = {
      ...state,
      commentId: vote,
    };
  }

  // unvote
  Future<void> unvote(CommentVote? commentVote) async {
    if (commentVote == null) return;
    final currentVote = state[commentVote.commentId];

    if (currentVote == null) return;

    final success = await repo.removeVote(commentVote.id);

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
