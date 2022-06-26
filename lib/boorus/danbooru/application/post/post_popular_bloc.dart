// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/main.dart';
import 'common.dart';

@immutable
class PostPopularState extends Equatable {
  const PostPopularState({
    required this.status,
    required this.posts,
    required this.filteredPosts,
    required this.page,
    required this.hasMore,
  });

  factory PostPopularState.initial() => const PostPopularState(
        status: LoadStatus.initial,
        posts: [],
        filteredPosts: [],
        page: 1,
        hasMore: true,
      );

  final List<Post> posts;
  final List<Post> filteredPosts;
  final LoadStatus status;
  final int page;
  final bool hasMore;

  PostPopularState copyWith({
    LoadStatus? status,
    List<Post>? posts,
    List<Post>? filteredPosts,
    int? page,
    bool? hasMore,
  }) =>
      PostPopularState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        filteredPosts: filteredPosts ?? this.filteredPosts,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
      );

  @override
  List<Object?> get props => [status, posts, filteredPosts, page, hasMore];
}

@immutable
abstract class PostPopularEvent extends Equatable {
  const PostPopularEvent();
}

class PostPopularFetched extends PostPopularEvent {
  const PostPopularFetched({
    required this.date,
    required this.scale,
  }) : super();

  final DateTime date;
  final TimeScale scale;

  @override
  List<Object?> get props => [date, scale];
}

class PostPopularRefreshed extends PostPopularEvent {
  const PostPopularRefreshed({
    required this.date,
    required this.scale,
  }) : super();

  final DateTime date;
  final TimeScale scale;

  @override
  List<Object?> get props => [];
}

class PostPopularBloc extends Bloc<PostPopularEvent, PostPopularState> {
  PostPopularBloc({
    required IPostRepository postRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
  }) : super(PostPopularState.initial()) {
    on<PostPopularFetched>(
      (event, emit) async {
        final blacklisted =
            await blacklistedTagsRepository.getBlacklistedTags();
        await tryAsync<List<Post>>(
          action: () => postRepository.getPopularPosts(
            event.date,
            state.page + 1,
            event.scale,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onSuccess: (posts) async {
            final filteredPosts = filterBlacklisted(posts, blacklisted);

            emit(
              state.copyWith(
                status: LoadStatus.success,
                posts: [
                  ...state.posts,
                  ...filter(posts, blacklisted),
                ],
                filteredPosts: [
                  ...state.filteredPosts,
                  ...filteredPosts,
                ],
                page: state.page + 1,
                hasMore: posts.isNotEmpty,
              ),
            );
          },
        );
      },
      transformer: droppable(),
    );

    on<PostPopularRefreshed>(
      (event, emit) async {
        final blacklisted =
            await blacklistedTagsRepository.getBlacklistedTags();
        await tryAsync<List<Post>>(
          action: () => postRepository.getPopularPosts(
            event.date,
            1,
            event.scale,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onSuccess: (posts) async => emit(
            state.copyWith(
              status: LoadStatus.success,
              posts: filter(posts, blacklisted),
              filteredPosts: filterBlacklisted(posts, blacklisted),
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
