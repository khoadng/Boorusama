// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PostDetailState extends Equatable {
  const PostDetailState({
    required this.details,
    required this.status,
  });

  factory PostDetailState.initial() => const PostDetailState(
        details: {},
        status: LoadStatus.initial,
      );

  final Map<int, PostDetail> details;
  final LoadStatus status;

  PostDetailState copyWith({
    Map<int, PostDetail>? details,
    LoadStatus? status,
  }) =>
      PostDetailState(
        details: details ?? this.details,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [details, status];
}

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();
}

class PostDetailFetched extends PostDetailEvent {
  const PostDetailFetched({
    required this.postIds,
  });

  final List<int> postIds;

  @override
  List<Object?> get props => [postIds];
}

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({
    required PostVoteRepository postVoteRepository,
  }) : super(PostDetailState.initial()) {
    on<PostDetailFetched>((event, emit) async {
      await tryAsync<List<PostVote>>(
        action: () => postVoteRepository.getPostVotes(event.postIds),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          final map = {for (final d in data) d.postId: d};
          final details = event.postIds
              .map((id) => PostDetail(
                    postId: id,
                    isFavorited: false,
                    voteState: map[id]?.voteState ?? VoteState.none,
                  ))
              .toList();

          emit(state.copyWith(
            status: LoadStatus.success,
            details: {for (final d in details) d.postId: d},
          ));
        },
      );
    });
  }
}

class PostDetail extends Equatable {
  const PostDetail({
    required this.postId,
    required this.isFavorited,
    required this.voteState,
  });

  factory PostDetail.empty(int postId) => PostDetail(
        postId: postId,
        isFavorited: false,
        voteState: VoteState.none,
      );

  final int postId;
  final bool isFavorited;
  final VoteState voteState;

  @override
  List<Object?> get props => [postId, isFavorited, voteState];
}
