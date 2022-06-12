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
class PostState extends Equatable {
  const PostState({
    required this.status,
    required this.posts,
    required this.page,
    required this.hasMore,
  });

  final List<Post> posts;
  final LoadStatus status;
  final int page;
  final bool hasMore;

  PostState copyWith({
    LoadStatus? status,
    List<Post>? posts,
    int? page,
    bool? hasMore,
  }) =>
      PostState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
      );

  factory PostState.initial() => const PostState(
        status: LoadStatus.initial,
        posts: [],
        page: 1,
        hasMore: true,
      );

  @override
  List<Object?> get props => [status, posts, page, hasMore];
}

@immutable
abstract class PostEvent extends Equatable {
  const PostEvent();
}

class PostFetched extends PostEvent {
  const PostFetched({
    required this.tags,
  }) : super();
  final String tags;

  @override
  List<Object?> get props => [tags];
}

class PostRefreshed extends PostEvent {
  const PostRefreshed({
    this.tag,
  }) : super();

  final String? tag;

  @override
  List<Object?> get props => [tag];
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({
    required IPostRepository postRepository,
  }) : super(PostState.initial()) {
    on<PostFetched>(
      (event, emit) => tryAsync<List<Post>>(
        action: () => postRepository.getPosts(event.tags, state.page + 1),
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
      ),
      transformer: droppable(),
    );

    on<PostRefreshed>(
      (event, emit) => tryAsync<List<Post>>(
        action: () => postRepository.getPosts(event.tag ?? '', 1),
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
      ),
      transformer: restartable(),
    );
  }
}
