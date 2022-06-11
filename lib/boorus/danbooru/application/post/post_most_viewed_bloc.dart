// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

@immutable
class PostMostViewedState extends Equatable {
  const PostMostViewedState({
    required this.status,
    required this.posts,
    required this.hasMore,
  });

  final List<Post> posts;
  final LoadStatus status;
  final bool hasMore;

  PostMostViewedState copyWith({
    LoadStatus? status,
    List<Post>? posts,
    bool? hasMore,
  }) =>
      PostMostViewedState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        hasMore: hasMore ?? this.hasMore,
      );

  factory PostMostViewedState.initial() => const PostMostViewedState(
        status: LoadStatus.initial,
        posts: [],
        hasMore: true,
      );

  @override
  List<Object?> get props => [status, posts, hasMore];
}

@immutable
abstract class PostMostViewedEvent extends Equatable {
  const PostMostViewedEvent();
}

class PostMostViewedFetched extends PostMostViewedEvent {
  const PostMostViewedFetched({
    required this.date,
  }) : super();

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class PostMostViewedRefreshed extends PostMostViewedEvent {
  const PostMostViewedRefreshed({
    required this.date,
  }) : super();

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class PostMostViewedBloc
    extends Bloc<PostMostViewedEvent, PostMostViewedState> {
  PostMostViewedBloc({
    required IPostRepository postRepository,
  }) : super(PostMostViewedState.initial()) {
    on<PostMostViewedFetched>(
      (event, emit) => tryAsync<List<Post>>(
        action: () => postRepository.getMostViewedPosts(
          event.date,
        ),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (stackTrace, error) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (posts) => emit(
          state.copyWith(
            status: LoadStatus.success,
            posts: [...state.posts, ...posts],
            hasMore: false,
          ),
        ),
      ),
      transformer: droppable(),
    );

    on<PostMostViewedRefreshed>(
      (event, emit) => tryAsync<List<Post>>(
        action: () => postRepository.getMostViewedPosts(
          event.date,
        ),
        onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
        onFailure: (stackTrace, error) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (posts) => emit(
          state.copyWith(
            status: LoadStatus.success,
            posts: posts,
            hasMore: false,
          ),
        ),
      ),
      transformer: restartable(),
    );
  }
}
