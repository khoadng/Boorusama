// Package imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user_repository.dart';

class PostVoteInfoState extends Equatable
    implements InfiniteLoadState<Voter, PostVoteInfoState> {
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

  final List<Voter> upvoters;
  @override
  List<Voter> get data => upvoters;
  @override
  final int page;
  @override
  final bool hasMore;
  @override
  final bool refreshing;
  @override
  final bool loading;
  final String? error;

  PostVoteInfoState copyWith({
    List<Voter>? upvoters,
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

  @override
  PostVoteInfoState copyLoadState({
    required int page,
    required bool hasMore,
    required bool refreshing,
    required bool loading,
    required List<Voter> data,
  }) =>
      copyWith(
        page: page,
        hasMore: hasMore,
        refreshing: refreshing,
        loading: loading,
        upvoters: [...data],
      );
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

class Voter extends Equatable {
  const Voter({
    required this.user,
    required this.voteTime,
  });

  factory Voter.create(User user, PostVote vote) => Voter(
        user: user,
        voteTime: vote.createdAt,
      );

  final User user;
  final DateTime voteTime;

  @override
  List<Object?> get props => [user, voteTime];
}

class PostVoteInfoBloc extends Bloc<PostVoteInfoEvent, PostVoteInfoState>
    with InfiniteLoadMixin<Voter, PostVoteInfoState> {
  PostVoteInfoBloc({
    required PostVoteRepository postVoteRepository,
    required UserRepository userRepository,
  }) : super(PostVoteInfoState.initial()) {
    on<PostVoteInfoFetched>(
      (event, emit) async {
        if (loading || refreshing) return;

        if (event.refresh) {
          await refresh(
            emitter: emit,
            stateGetter: () => state,
            refresh: (page) => postVoteRepository
                .getAllVotes(event.postId, 1)
                .then((votes) => _createVoters(userRepository, votes)),
            onError: (error, stackTrace) =>
                emit(state.copyWith(error: 'Something went wrong')),
          );
        } else {
          if (!hasMore) return;
          await fetch(
            emitter: emit,
            stateGetter: () => state,
            fetch: (page) => postVoteRepository
                .getAllVotes(event.postId, page)
                .then((votes) => _createVoters(userRepository, votes)),
            onError: (error, stackTrace) =>
                emit(state.copyWith(error: 'Something went wrong')),
          );
        }
      },
    );
  }
}

Future<List<Voter>> _createVoters(
  UserRepository userRepository,
  List<PostVote> votes,
) async {
  if (votes.isEmpty) return [];

  final voteMap = {for (final vote in votes) vote.userId: vote};

  final users = await userRepository
      .getUsersByIdStringComma(votes.map((e) => e.userId).join(','));

  return users.map((user) => Voter.create(user, voteMap[user.id]!)).toList();
}
