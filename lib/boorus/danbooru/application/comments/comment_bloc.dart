// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/domain/boorus.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc({
    required CommentRepository commentRepository,
    required CurrentBooruConfigRepository currentBooruConfigRepository,
    required BooruUserIdentityProvider booruUserIdentityProvider,
    required CommentVoteRepository commentVoteRepository,
  }) : super(CommentState.initial()) {
    on<CommentFetched>((event, emit) async {
      await tryAsync<List<CommentData>>(
        action: () => commentRepository
            .getCommentsFromPostId(event.postId)
            .then(filterDeleted())
            .then(createCommentDataWith(
              currentBooruConfigRepository,
              booruUserIdentityProvider,
              commentVoteRepository,
            ))
            .then(sortDescendedById()),
        onFailure: (stackTrace, error) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
        onSuccess: (comments) async {
          emit(state.copyWith(
            comments: comments,
            status: LoadStatus.success,
          ));
        },
      );
    });

    on<CommentUpdated>((event, emit) async {
      await tryAsync<bool>(
        action: () =>
            commentRepository.updateComment(event.commentId, event.content),
        onSuccess: (success) async {
          add(CommentFetched(postId: event.postId));
        },
      );
    });

    on<CommentUpvoted>((event, emit) async {
      await tryAsync<CommentVote>(
        action: () => commentVoteRepository.upvote(event.commentId),
        onSuccess: (vote) async {
          final comments = _updateWith(
            state.comments,
            vote,
            CommentVoteState.upvoted,
          );
          emit(state.copyWith(comments: comments));
        },
      );
    });

    on<CommentDownvoted>((event, emit) async {
      await tryAsync<CommentVote>(
        action: () => commentVoteRepository.downvote(event.commentId),
        onSuccess: (vote) async {
          final comments = _updateWith(
            state.comments,
            vote,
            CommentVoteState.downvoted,
          );
          emit(state.copyWith(comments: comments));
        },
      );
    });

    on<CommentVoteRemoved>((event, emit) async {
      await tryAsync<bool>(
        action: () => commentVoteRepository.removeVote(event.commentVoteId),
        onSuccess: (success) async {
          final comments = {for (var c in state.comments) c.id: c};
          final old = comments[event.commentId]!;
          final $new = old.copyWith(
            score: event.voteState == CommentVoteState.downvoted
                ? old.score + 1
                : old.score - 1,
            voteState: CommentVoteState.unvote,
          );
          comments[event.commentId] = $new;
          emit(state.copyWith(comments: comments.values.toList()));
        },
      );
    });
  }
}

List<CommentData> _updateWith(
  List<CommentData> comments,
  CommentVote vote,
  CommentVoteState voteState,
) {
  final cmts = {for (var c in comments) c.id: c};
  final old = cmts[vote.commentId]!;
  final $new = old.copyWith(
    score: _getScore(voteState, old.score, vote.score),
    voteState: voteState,
    voteId: vote.id,
  );
  cmts[vote.commentId] = $new;

  return cmts.values.toList();
}

int _getScore(CommentVoteState state, int initialScore, int vote) {
  //TODO: need to check if already voted by self, if user vote up and vote down immediately. The score value will be incorrect
  // GOOD: score = 1 -> vote down -> score = -1 (remove the upvote and then decrease the score)
  // CURRENT: score = 1 -> vote down -> score = 0
  if (state == CommentVoteState.downvoted) return initialScore + vote;
  if (state == CommentVoteState.upvoted) return initialScore + vote;

  return initialScore;
}
