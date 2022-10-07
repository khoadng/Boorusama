// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';

class PostVoteInfoState extends Equatable {
  const PostVoteInfoState({
    required this.upvoters,
    required this.page,
    required this.hasMore,
    required this.refreshing,
    required this.loading,
    this.error,
  });

  factory PostVoteInfoState.initial() => const PostVoteInfoState(
        upvoters: [],
        page: 1,
        hasMore: false,
        refreshing: false,
        loading: false,
      );

  final List<User> upvoters;
  final int page;
  final bool hasMore;
  final bool refreshing;
  final bool loading;
  final String? error;

  PostVoteInfoState copyWith({
    List<User>? upvoters,
    int? page,
    bool? hasMore,
    bool? refreshing,
    bool? loading,
    String? error,
  }) =>
      PostVoteInfoState(
        upvoters: upvoters ?? this.upvoters,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        refreshing: refreshing ?? this.refreshing,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [
        upvoters,
        page,
        hasMore,
        refreshing,
        loading,
        error,
      ];
}

abstract class PostVoteInfoEvent extends Equatable {
  const PostVoteInfoEvent();
}

class PostVoteInfoFetched extends PostVoteInfoEvent {
  const PostVoteInfoFetched({
    required this.postId,
    this.refresh = false,
  });

  final int postId;
  final bool refresh;

  @override
  List<Object?> get props => [
        postId,
        refresh,
      ];
}

class PostVoteInfoBloc extends Bloc<PostVoteInfoEvent, PostVoteInfoState> {
  PostVoteInfoBloc({
    required PostVoteRepository postVoteRepository,
    required IUserRepository userRepository,
  }) : super(PostVoteInfoState.initial()) {
    on<PostVoteInfoFetched>(
      (event, emit) async {
        try {
          if (state.loading || state.refreshing) return;

          if (event.refresh) {
            emit(state.copyWith(
              refreshing: true,
              page: 1,
            ));
            final votes = await postVoteRepository.getAllVotes(
              event.postId,
              state.page,
            );

            final users = await userRepository.getUsersByIdStringComma(
                votes.map((e) => e.userId.value).join(','));
            emit(state.copyWith(
              refreshing: false,
              upvoters: users,
              hasMore: true,
            ));
          } else {
            if (!state.hasMore) return;
            final page = state.page + 1;
            emit(state.copyWith(loading: true));

            // Fetch votes with post ID
            final votes =
                await postVoteRepository.getAllVotes(event.postId, page);

            // Prevent fetching more if next page is empty
            if (votes.isEmpty) {
              emit(state.copyWith(
                loading: false,
                hasMore: false,
              ));
            } else {
              final users = await userRepository.getUsersByIdStringComma(
                  votes.map((e) => e.userId.value).join(','));
              emit(state.copyWith(
                loading: false,
                upvoters: [...state.upvoters, ...users],
                hasMore: true,
              ));
            }

            emit(state.copyWith(page: page));
          }
        } catch (e) {
          emit(state.copyWith(error: 'Something went wrong'));
        }
      },
      transformer: debounce(const Duration(milliseconds: 100)),
    );
  }
}
