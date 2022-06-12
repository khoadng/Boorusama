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
class PostCuratedState extends Equatable {
  const PostCuratedState({
    required this.status,
    required this.posts,
    required this.page,
    required this.hasMore,
  });

  final List<Post> posts;
  final LoadStatus status;
  final int page;
  final bool hasMore;

  PostCuratedState copyWith({
    LoadStatus? status,
    List<Post>? posts,
    int? page,
    bool? hasMore,
  }) =>
      PostCuratedState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
      );

  factory PostCuratedState.initial() => const PostCuratedState(
        status: LoadStatus.initial,
        posts: [],
        page: 1,
        hasMore: true,
      );

  @override
  List<Object?> get props => [status, posts, page, hasMore];
}

@immutable
abstract class PostCuratedEvent extends Equatable {
  const PostCuratedEvent();
}

class PostCuratedFetched extends PostCuratedEvent {
  const PostCuratedFetched({
    required this.date,
    required this.scale,
  }) : super();

  final DateTime date;
  final TimeScale scale;

  @override
  List<Object?> get props => [date, scale];
}

class PostCuratedRefreshed extends PostCuratedEvent {
  const PostCuratedRefreshed({
    required this.date,
    required this.scale,
  }) : super();

  final DateTime date;
  final TimeScale scale;

  @override
  List<Object?> get props => [];
}

class PostCuratedBloc extends Bloc<PostCuratedEvent, PostCuratedState> {
  PostCuratedBloc({
    required IPostRepository postRepository,
  }) : super(PostCuratedState.initial()) {
    on<PostCuratedFetched>(
      (event, emit) async {
        await tryAsync<List<Post>>(
          action: () => postRepository.getCuratedPosts(
            event.date,
            state.page + 1,
            event.scale,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onSuccess: (posts) => emit(
            state.copyWith(
              status: LoadStatus.success,
              posts: [...state.posts, ...posts],
              page: state.page + 1,
              hasMore: posts.isNotEmpty,
            ),
          ),
        );
      },
      transformer: droppable(),
    );

    on<PostCuratedRefreshed>(
      (event, emit) async {
        await tryAsync<List<Post>>(
          action: () => postRepository.getCuratedPosts(
            event.date,
            1,
            event.scale,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onSuccess: (posts) => emit(
            state.copyWith(
              status: LoadStatus.success,
              posts: posts,
              page: 1,
              hasMore: posts.isNotEmpty,
            ),
          ),
        );
      },
      transformer: restartable(),
    );
  }
}
