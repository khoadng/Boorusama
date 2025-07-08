// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/comments/types.dart';
import '../../../../../core/configs/config.dart';
import '../../../../../core/configs/ref.dart';
import '../../comment/comment.dart';
import 'data/providers.dart';
import 'types/danbooru_comment_vote.dart';

final danbooruCommentVotesProvider =
    NotifierProvider.family<
      CommentVotesNotifier,
      Map<CommentId, DanbooruCommentVote>,
      BooruConfigAuth
    >(
      CommentVotesNotifier.new,
    );

final danbooruCommentVoteProvider = Provider.autoDispose
    .family<DanbooruCommentVote?, CommentId>((ref, commentId) {
      final config = ref.watchConfigAuth;
      final votes = ref.watch(danbooruCommentVotesProvider(config));
      return votes[commentId];
    });

class CommentVotesNotifier
    extends
        FamilyNotifier<Map<CommentId, DanbooruCommentVote>, BooruConfigAuth> {
  @override
  Map<int, DanbooruCommentVote> build(BooruConfigAuth arg) {
    return {};
  }

  CommentVoteRepository<DanbooruCommentVote> get _repo =>
      ref.read(danbooruCommentVoteRepoProvider(arg));

  Future<void> fetch(List<int> commentIds) async {
    // filter out already fetched ids
    final ids = commentIds.where((id) => !state.containsKey(id)).toList();

    if (ids.isEmpty) return;

    final votes = await _repo.getCommentVotes(ids);
    state = {
      ...state,
      for (final vote in votes) vote.commentId: vote,
    };
  }

  // upvote
  Future<void> upvote(
    int commentId, {
    void Function(String msg)? onFailed,
  }) async {
    final vote = await _repo.upvoteComment(commentId);
    state = {
      ...state,
      commentId: vote,
    };
  }

  // downvote
  Future<void> downvote(int commentId) async {
    final vote = await _repo.downvoteComment(commentId);
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

    final success = await _repo.unvoteComment(commentVote.id);

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
