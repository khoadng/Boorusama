// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PostVoteState extends Equatable {
  const PostVoteState({
    required this.status,
    required this.score,
    required this.upScore,
    required this.downScore,
    required this.state,
  });

  factory PostVoteState.initial(
    int score,
    int upScore,
    int downScore,
    VoteState voteState,
  ) =>
      PostVoteState(
        status: LoadStatus.initial,
        score: score,
        upScore: upScore,
        downScore: downScore,
        state: voteState,
      );

  final LoadStatus status;
  final int score;
  final int upScore;
  final int downScore;
  final VoteState state;

  PostVoteState copyWith({
    LoadStatus? status,
    int? score,
    int? upScore,
    int? downScore,
    VoteState? state,
  }) =>
      PostVoteState(
        status: status ?? this.status,
        score: score ?? this.score,
        upScore: upScore ?? this.upScore,
        downScore: downScore ?? this.downScore,
        state: state ?? this.state,
      );

  @override
  List<Object?> get props => [status, score, upScore, downScore, state];
}

abstract class PostVoteEvent extends Equatable {
  const PostVoteEvent();
}

class PostVoteUpvoted extends PostVoteEvent {
  const PostVoteUpvoted({
    required this.postId,
  });

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostVoteDownvoted extends PostVoteEvent {
  const PostVoteDownvoted({
    required this.postId,
  });

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostVoteInit extends PostVoteEvent {
  const PostVoteInit({
    required this.score,
    required this.upScore,
    required this.downScore,
    required this.postId,
  });

  factory PostVoteInit.fromPost(Post post) => PostVoteInit(
        postId: post.id,
        score: post.score,
        upScore: post.upScore,
        downScore: post.downScore,
      );

  final int postId;
  final int score;
  final int upScore;
  final int downScore;

  @override
  List<Object?> get props => [postId, score, upScore, downScore];
}

class PostVoteBloc extends Bloc<PostVoteEvent, PostVoteState> {
  PostVoteBloc({
    required PostVoteRepository postVoteRepository,
  }) : super(PostVoteState.initial(0, 0, 0, VoteState.unvote)) {
    on<PostVoteUpvoted>((event, emit) async {
      if (state.state == VoteState.upvoted) return;

      await tryAsync<PostVote>(
        action: () => postVoteRepository.upvote(event.postId),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          final up = state.upScore + 1;
          final down = state.state == VoteState.downvoted
              ? state.downScore + 1
              : state.downScore;
          emit(state.copyWith(
            status: LoadStatus.success,
            score: up + down,
            upScore: up,
            downScore: down,
            state: VoteState.upvoted,
          ));
        },
      );
    });

    on<PostVoteDownvoted>((event, emit) async {
      if (state.state == VoteState.downvoted) return;
      await tryAsync<PostVote>(
        action: () => postVoteRepository.downvote(event.postId),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          final down = state.downScore - 1;
          final up = state.state == VoteState.upvoted
              ? state.upScore - 1
              : state.upScore;
          emit(state.copyWith(
            status: LoadStatus.success,
            score: up + down,
            upScore: up,
            downScore: down,
            state: VoteState.downvoted,
          ));
        },
      );
    });

    on<PostVoteInit>((event, emit) async {
      emit(PostVoteState.initial(
        event.score,
        event.upScore,
        event.downScore,
        VoteState.unvote,
      ));

      await tryAsync<List<PostVote>>(
        action: () => postVoteRepository.getPostVotes([event.postId]),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          emit(state.copyWith(
            status: LoadStatus.success,
            state: data.isEmpty ? VoteState.unvote : data.first.voteState,
          ));
        },
      );
    });
  }
}
