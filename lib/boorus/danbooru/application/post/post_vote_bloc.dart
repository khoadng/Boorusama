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
  });

  factory PostVoteState.initial(
    int score,
  ) =>
      PostVoteState(
        status: LoadStatus.initial,
        score: score,
      );

  final LoadStatus status;
  final int score;

  PostVoteState copyWith({
    LoadStatus? status,
    int? score,
  }) =>
      PostVoteState(
        status: status ?? this.status,
        score: score ?? this.score,
      );

  @override
  List<Object?> get props => [status, score];
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
  const PostVoteDownvoted();

  @override
  List<Object?> get props => [];
}

class PostVoteBloc extends Bloc<PostVoteEvent, PostVoteState> {
  PostVoteBloc({
    required PostVoteRepository postVoteRepository,
    required int initialScore,
  }) : super(PostVoteState.initial(initialScore)) {
    on<PostVoteUpvoted>((event, emit) async {
      await tryAsync<PostVote>(
        action: () => postVoteRepository.upvote(event.postId),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          emit(state.copyWith(
            status: LoadStatus.success,
            score: state.score + 1,
          ));
        },
      );
    });

    on<PostVoteUpvoted>((event, emit) async {
      await tryAsync<PostVote>(
        action: () => postVoteRepository.downvote(event.postId),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          emit(state.copyWith(
            status: LoadStatus.success,
            score: state.score - 1,
          ));
        },
      );
    });
  }
}
