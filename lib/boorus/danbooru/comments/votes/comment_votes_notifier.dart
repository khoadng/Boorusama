// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/comments/comment_vote.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/current.dart';
import 'package:boorusama/core/configs/ref.dart';
import '../../_shared/guard_login.dart';
import '../comment/danbooru_comment.dart';
import 'danbooru_comment_vote.dart';
import 'providers.dart';

final danbooruCommentVotesProvider = NotifierProvider.family<
    CommentVotesNotifier, Map<CommentId, DanbooruCommentVote>, BooruConfigAuth>(
  CommentVotesNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final danbooruCommentVoteProvider = Provider.autoDispose
    .family<DanbooruCommentVote?, CommentId>((ref, commentId) {
  final config = ref.watchConfigAuth;
  final votes = ref.watch(danbooruCommentVotesProvider(config));
  return votes[commentId];
});

class CommentVotesNotifier extends FamilyNotifier<
    Map<CommentId, DanbooruCommentVote>, BooruConfigAuth> {
  @override
  Map<int, DanbooruCommentVote> build(BooruConfigAuth arg) {
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
  Future<void> upvote(
    int commentId, {
    void Function(String msg)? onFailed,
  }) async {
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

extension CommentVotesNotifierX on CommentVotesNotifier {
  Future<void> guardUpvote(WidgetRef ref, int commentId) async => guardLogin(
        ref,
        () async => upvote(commentId),
      );

  Future<void> guardDownvote(WidgetRef ref, int commentId) async => guardLogin(
        ref,
        () async => downvote(commentId),
      );

  Future<void> guardUnvote(
          WidgetRef ref, DanbooruCommentVote? commentVote) async =>
      guardLogin(
        ref,
        () async => unvote(commentVote),
      );
}
